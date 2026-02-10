import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../shared/services/onboarding_service.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;
  bool _dataConsentChecked = false;

  final List<OnboardingScreen> _screens = [
    OnboardingScreen(
      title: 'Bienvenue sur\nSIGH Energies & Moi',
      description:
          'Découvrez comment gérer votre consommation d\'énergie de manière intelligente et responsable.',
      icon: Icons.eco,
      showBuildings: true,
    ),
    OnboardingScreen(
      title: 'Suivez votre\nconsommation',
      description:
          'Analysez vos équipements et comprenez votre impact énergétique en temps réel.',
      icon: Icons.analytics_outlined,
      showBuildings: false,
    ),
    OnboardingScreen(
      title: 'Gagnez des badges',
      description:
          'Relevez des défis, adoptez des éco-gestes et débloquez des récompenses.',
      icon: Icons.emoji_events_outlined,
      showBuildings: false,
    ),
    OnboardingScreen(
      title: 'Des conseils\npersonnalisés',
      description:
          'Recevez des recommandations adaptées pour réduire votre empreinte énergétique.',
      icon: Icons.lightbulb_outline,
      showBuildings: false,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    if (!_dataConsentChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter la collecte de données'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Utiliser "clara" par défaut si le champ est vide
    final userName = _nameController.text.trim().isEmpty
        ? 'clara'
        : _nameController.text.trim();

    await OnboardingService.completeOnboarding(userName);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  void _nextPage() {
    if (_currentPage < _screens.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Indicateur de progression
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      onPressed: _previousPage,
                      icon: const Icon(Icons.arrow_back),
                      color: const Color(0xFF264777),
                    ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _screens.length + 1,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? const Color(0xFF264777)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: _currentPage > 0 ? 48 : 0),
                ],
              ),
            ),
            // Contenu principal
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  ..._screens.map((screen) => _buildScreen(screen)),
                  _buildFinalScreen(),
                ],
              ),
            ),
            // Boutons de navigation
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _currentPage < _screens.length
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            _pageController.jumpToPage(_screens.length);
                          },
                          child: const Text(
                            'Passer',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF264777),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Suivant',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _completeOnboarding,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF264777),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Commencer',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreen(OnboardingScreen screen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icône ou illustration
          if (screen.showBuildings)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF264777),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SvgPicture.asset(
                      'assets/images/buildings.svg',
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.white.withOpacity(0.85),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      screen.icon,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF264777).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                screen.icon,
                size: 100,
                color: const Color(0xFF264777),
              ),
            ),
          const SizedBox(height: 48),
          // Titre
          Text(
            screen.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF264777),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          // Description
          Text(
            screen.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Titre
          const Text(
            'Une dernière chose...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF264777),
            ),
          ),
          const SizedBox(height: 32),
          // Champ prénom
          const Text(
            'Comment souhaitez-vous être appelé ?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF264777),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Entrez votre prénom',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF264777)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF264777),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Section RGPD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.privacy_tip_outlined,
                      color: Color(0xFF264777),
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Vos données personnelles',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF264777),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Nous respectons votre vie privée. Les données collectées sont :',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                _buildDataPoint('• Votre prénom (stocké localement)'),
                _buildDataPoint('• Vos statistiques de consommation'),
                _buildDataPoint('• Vos préférences et badges'),
                const SizedBox(height: 12),
                Text(
                  'Ces données sont stockées localement sur votre appareil et ne sont jamais partagées sans votre consentement explicite.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Case à cocher consentement
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _dataConsentChecked,
                onChanged: (value) {
                  setState(() {
                    _dataConsentChecked = value ?? false;
                  });
                },
                activeColor: const Color(0xFF264777),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _dataConsentChecked = !_dataConsentChecked;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        children: const [
                          TextSpan(
                            text: 'J\'accepte la collecte et le traitement de mes données personnelles conformément à la ',
                          ),
                          TextSpan(
                            text: 'politique de confidentialité',
                            style: TextStyle(
                              color: Color(0xFF264777),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDataPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}

class OnboardingScreen {
  final String title;
  final String description;
  final IconData icon;
  final bool showBuildings;

  OnboardingScreen({
    required this.title,
    required this.description,
    required this.icon,
    this.showBuildings = false,
  });
}

