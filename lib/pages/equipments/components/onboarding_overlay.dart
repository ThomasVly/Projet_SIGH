import 'package:flutter/material.dart';

class OnboardingOverlay extends StatefulWidget {
  final Function() onComplete;

  const OnboardingOverlay({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Bienvenue dans l\'inventaire des équipements !',
      description: 'Cette fonctionnalité vous permet gérer la liste des équipements électriques de votre maison et de suivre leur consommation en un seul endroit.',
      image: Icons.inventory,
      color: Color(0xFF003366),
    ),
    OnboardingPage(
      title: 'Ajoutez vos pièces',
      description: 'Commencez d\'abord par créer des pièces (e.g., cuisine, salon, etc.).',
      image: Icons.add_home_work,
      color: Color(0xFF003366),
    ),
    OnboardingPage(
      title: 'Sélectionnez vos appareils',
      description: 'Vous pouvez ensuite, pour chaque pièce, ajouter les appareils présents. Choissisez parmi une liste de 80+ appareils prédéfinis.',
      image: Icons.devices,
      color: Color(0xFF003366),
    ),
    OnboardingPage(
      title: 'Personnalisez vos appareils',
      description: 'Par défaut, chaque appareil a une valeur par défaut concernant sa consommation en kWh/h, sa durée d\'utilisation moyenne au quotidien et sa fréquence d\'utilisation par semaine. Mais vous pouvez aussi personnaliser ces valeurs unitairement en cliquant sur l\'appareil dans votre inventaire !',
      image: Icons.settings,
      color: Color(0xFF003366),
    ),
    OnboardingPage(
      title: 'Analysez votre consommation',
      description: 'Vous pouvez visualiser votre consommation théorique mensuel en kWh et €. Les appareils les plus consommateurs sont en surbrillance. ATTENTION : cette simulation est à titre indicatif uniquement et peut différer de la réalité.',
      image: Icons.analytics,
      color: Color(0xFF72BA00),
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Material(
      color: Colors.black.withOpacity(0.5),
      child: GestureDetector(
        onTap: () {},
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),

            Positioned.fill(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: screenHeight * 0.05,
                  ),
                  child: Container(
                    width: screenWidth * 0.9,
                    constraints: BoxConstraints(
                      maxWidth: 400,
                      maxHeight: screenHeight * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 300, 
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: _pages.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final page = _pages[index];
                              return _buildPage(page);
                            },
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _pages.length,
                              (index) => Container(
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                width: _currentPage == index ? 12 : 8,
                                height: _currentPage == index ? 12 : 8,
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? _pages[index].color
                                      : Color(0xFFD6E3FF),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Row(
                            children: [
                              if (_currentPage > 0)
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _previousPage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFE0E0E0),
                                      foregroundColor: Color(0xFF405F90),
                                      padding: EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Retour',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Expanded(child: SizedBox()),

                              if (_currentPage > 0) SizedBox(width: 12),

                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _nextPage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _currentPage == _pages.length - 1
                                        ? Color(0xFF72BA00) 
                                        : Color(0xFF003366),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: Text(
                                    _currentPage == _pages.length - 1
                                        ? 'OK'
                                        : 'Suivant',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: page.color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                page.image,
                size: 40,
                color: page.color,
              ),
            ),
          ),
          SizedBox(height: 20),

          // Titre
          Text(
            page.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF003063),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (_currentPage != _pages.length - 1)
                    Text(
                      page.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF405F90),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    )
                  else
                    Column(
                      children: [
                        Text(
                          'Vous pouvez visualiser votre consommation théorique mensuel en kWh et €.  Les appareils les plus consommateurs sont en surbrillance',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF405F90),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'ATTENTION : cette simulation est à titre indicatif uniquement et peut différer de la réalité.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData image;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    required this.color,
  });
}