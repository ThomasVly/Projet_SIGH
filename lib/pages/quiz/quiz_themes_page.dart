import 'package:flutter/material.dart';
import '../../common-widget/header/header_widget.dart';
import '../../shared/models/quiz_model.dart';
import '../../shared/firebase/firestore_service.dart';
import 'quiz_page.dart';

class QuizThemesPage extends StatefulWidget {
  const QuizThemesPage({super.key});

  @override
  State<QuizThemesPage> createState() => _QuizThemesPageState();
}

class _QuizThemesPageState extends State<QuizThemesPage> {
  List<Quiz> _quizzes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });


      final quizData = await FirestoreService.getQuizzes();

      setState(() {
        _quizzes = quizData.map((data) => Quiz.fromMap(data)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement des quiz: $e';
        _isLoading = false;
      });
      print('❌ Error loading quizzes: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header avec bouton retour intégré
            Stack(
              children: [
                const HeaderWidget(
                  title: 'Quiz',
                  isHomePage: false,
                ),
                Positioned(
                  left: -5,
                  top: -80,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Retour',
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(_error!, textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadQuizzes,
                                child: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        )
                      : _quizzes.isEmpty
                          ? const Center(
                              child: Text(
                                'Aucun quiz disponible',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Choisissez un thème',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF264777),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Testez vos connaissances et gagnez de l\'XP !',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: _quizzes.length,
                                      itemBuilder: (context, index) {
                                        final quiz = _quizzes[index];
                                        final themeColor = _parseColor(quiz.color);

                                        return Card(
                                          elevation: 3,
                                          margin: const EdgeInsets.only(bottom: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => QuizPage(quiz: quiz),
                                                ),
                                              );
                                            },
                                            borderRadius: BorderRadius.circular(16),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(16),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    themeColor,
                                                    themeColor.withOpacity(0.7),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                              ),
                                              padding: const EdgeInsets.all(20),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 60,
                                                    height: 60,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.3),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        quiz.icon,
                                                        style: const TextStyle(
                                                          fontSize: 32,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          quiz.theme,
                                                          style: const TextStyle(
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          '${quiz.questions.length} questions',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.white.withOpacity(0.9),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const Icon(
                                                    Icons.arrow_forward_ios,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
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

