import 'package:flutter/material.dart';
import 'dart:async';
import '../../common-widget/header/header_widget.dart';
import '../../shared/models/quiz_model.dart';
import '../../shared/services/user_experience_service.dart';
import '../../shared/services/user_preferences_service.dart';
import '../../shared/models/user_profile.dart';

class QuizPage extends StatefulWidget {
  final Quiz quiz;

  const QuizPage({super.key, required this.quiz});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  bool _hasAnswered = false;
  int? _selectedAnswer;
  bool _quizCompleted = false;

  late Stopwatch _stopwatch;
  late Timer _timer;
  String _elapsedTime = '00:00';

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedTime = _formatDuration(_stopwatch.elapsed);
        });
      }
    });
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Color _parseColor(String colorString) {
    try {
      String cleanColor = colorString.replaceAll('#', '');
      if (cleanColor.length == 6) {
        return Color(int.parse('FF$cleanColor', radix: 16));
      }
      return const Color(0xFF264777);
    } catch (e) {
      return const Color(0xFF264777);
    }
  }

  void _handleAnswer(int selectedIndex) {
    if (_hasAnswered) return;

    setState(() {
      _selectedAnswer = selectedIndex;
      _hasAnswered = true;

      final currentQuestion = widget.quiz.questions[_currentQuestionIndex];
      if (selectedIndex == currentQuestion.correctAnswer) {
        _correctAnswers++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _hasAnswered = false;
        _selectedAnswer = null;
      });
    } else {
      _completeQuiz();
    }
  }

  Future<void> _completeQuiz() async {
    _stopwatch.stop();
    _timer.cancel();

    setState(() {
      _quizCompleted = true;
    });

    // Calculer le pourcentage de réussite
    final percentage = (_correctAnswers / widget.quiz.questions.length) * 100;

    // Si réussite >= 50%, ajouter XP et incrémenter le compteur
    if (percentage >= 50) {
      try {
        // Créer les instances de service
        final preferencesService = UserPreferencesService();
        final userExperienceService = UserExperienceService();

        // Récupérer le profil actuel
        final currentProfile = await preferencesService.loadUserProfile();

        if (currentProfile != null) {
          // Ajouter l'XP avec le service
          final updatedProfile = userExperienceService.onQuizCompleted(currentProfile);

          // Sauvegarder le profil mis à jour
          await preferencesService.saveUserProfile(updatedProfile);

          print('✅ XP ajoutée: +${UserExperienceService.xpPerQuizCompleted}');
          print('✅ Quiz count: ${updatedProfile.quizCount}');
          print('✅ Niveau: ${updatedProfile.currentLevel}');
          print('✅ XP actuel: ${updatedProfile.currentXP}/${updatedProfile.maxXP}');
        } else {
          print('⚠️ Aucun profil trouvé - création d\'un nouveau profil');
          // Créer un nouveau profil si nécessaire
          final newProfile = UserProfile(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userName: 'Utilisateur',
            memberSince: 'Membre depuis ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
          );
          final updatedProfile = userExperienceService.onQuizCompleted(newProfile);
          await preferencesService.saveUserProfile(updatedProfile);
        }
      } catch (e) {
        print('❌ Erreur lors de l\'ajout d\'XP: $e');
      }
    }
  }

  Widget _buildCompletionScreen() {
    final percentage = (_correctAnswers / widget.quiz.questions.length) * 100;
    final isPassed = percentage >= 50;
    final themeColor = _parseColor(widget.quiz.color);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Icône principale avec animation
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isPassed
                    ? [Colors.green.shade400, Colors.green.shade600]
                    : [Colors.orange.shade400, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isPassed ? Colors.green : Colors.orange).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                isPassed ? Icons.celebration_outlined : Icons.emoji_events_outlined,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Titre
            Text(
              isPassed ? 'Félicitations !' : 'Bon effort !',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isPassed
                ? 'Vous avez réussi le quiz !'
                : 'Continuez à vous améliorer !',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Carte de résultats
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [themeColor.withOpacity(0.1), themeColor.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: themeColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Score principal
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_correctAnswers/${widget.quiz.questions.length} réponses correctes',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Temps
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_outlined, color: themeColor, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'Temps: $_elapsedTime',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: themeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Badge XP si réussi
            if (isPassed) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.stars, color: Colors.white, size: 32),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '+20 XP',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Quiz complété',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 8),

            // Bouton retour
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Retour aux quiz',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_quizCompleted) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              HeaderWidget(
                title: widget.quiz.theme,
                isHomePage: false,
              ),
              Expanded(child: _buildCompletionScreen()),
            ],
          ),
        ),
      );
    }

    final currentQuestion = widget.quiz.questions[_currentQuestionIndex];
    final themeColor = _parseColor(widget.quiz.color);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            HeaderWidget(
              title: widget.quiz.theme,
              isHomePage: false,
            ),
            // Progress bar et timer
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${_currentQuestionIndex + 1}/${widget.quiz.questions.length}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: themeColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.timer, size: 16, color: themeColor),
                            const SizedBox(width: 4),
                            Text(
                              _elapsedTime,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: themeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            themeColor.withOpacity(0.15),
                            themeColor.withOpacity(0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: themeColor.withOpacity(0.3), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: themeColor.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: themeColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.help_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              currentQuestion.question,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Options
                    ...List.generate(
                      currentQuestion.options.length,
                      (index) {
                        final isSelected = _selectedAnswer == index;
                        final isCorrect = index == currentQuestion.correctAnswer;

                        Color cardColor;
                        if (_hasAnswered) {
                          if (isCorrect) {
                            cardColor = Colors.green;
                          } else if (isSelected) {
                            cardColor = Colors.red;
                          } else {
                            cardColor = Colors.grey;
                          }
                        } else {
                          cardColor = themeColor;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          child: InkWell(
                            onTap: _hasAnswered ? null : () => _handleAnswer(index),
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: _hasAnswered
                                    ? cardColor.withOpacity(0.15)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected || (_hasAnswered && isCorrect)
                                      ? cardColor
                                      : Colors.grey[300]!,
                                  width: isSelected || (_hasAnswered && isCorrect) ? 2.5 : 2,
                                ),
                                boxShadow: [
                                  if (!_hasAnswered && !isSelected)
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  if (isSelected || (_hasAnswered && isCorrect))
                                    BoxShadow(
                                      color: cardColor.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isSelected || (_hasAnswered && isCorrect)
                                          ? cardColor
                                          : Colors.grey[200],
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        if (isSelected || (_hasAnswered && isCorrect))
                                          BoxShadow(
                                            color: cardColor.withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        String.fromCharCode(65 + index),
                                        style: TextStyle(
                                          color: isSelected || (_hasAnswered && isCorrect)
                                              ? Colors.white
                                              : Colors.black54,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      currentQuestion.options[index],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: _hasAnswered && isCorrect
                                          ? Colors.green.shade800
                                          : _hasAnswered && isSelected
                                            ? Colors.red.shade800
                                            : Colors.grey.shade800,
                                      ),
                                    ),
                                  ),
                                  if (_hasAnswered && isCorrect)
                                    Icon(Icons.check_circle, color: Colors.green.shade600, size: 28),
                                  if (_hasAnswered && isSelected && !isCorrect)
                                    Icon(Icons.cancel, color: Colors.red.shade600, size: 28),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Explication si réponse incorrecte
                    if (_hasAnswered && _selectedAnswer != currentQuestion.correctAnswer) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue, width: 1),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, color: Colors.blue, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Explication',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currentQuestion.explanation,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_hasAnswered) ...[
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _nextQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            shadowColor: themeColor.withOpacity(0.4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentQuestionIndex < widget.quiz.questions.length - 1
                                    ? 'Question suivante'
                                    : 'Terminer le quiz',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentQuestionIndex < widget.quiz.questions.length - 1
                                    ? Icons.arrow_forward
                                    : Icons.check_circle_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

