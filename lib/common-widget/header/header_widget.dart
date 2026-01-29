import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../pages/Rappel/rappel_page.dart';
import '../../pages/settings/models/reminder_page.dart';

class HeaderWidget extends StatelessWidget {
  final String? title;
  final String? userName;
  final bool isHomePage;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final bool isCollapsed;
  final BuildContext? navigationContext;
  final Widget? trailing;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const HeaderWidget({
    super.key,
    this.title,
    this.userName,
    this.isHomePage = false,
    this.onNotificationTap,
    this.onProfileTap,
    this.isCollapsed = false,
    this.navigationContext,
    this.trailing,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Tailles différentes selon le state
    final double verticalPadding = isCollapsed ? 14 : (isHomePage ? 48 : 32);
    final double horizontalPadding = isCollapsed ? 16 : 20;
    final double fontSize = isCollapsed ? 14 : 18;
    final double logoSize = isCollapsed ? 36 : 54;
    final double logoIconSize = isCollapsed ? 20 : 32;
    final double notifSize = isCollapsed ? 22 : 32;
    final double bottomMargin = isCollapsed ? 8 : 20;

    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      margin: EdgeInsets.only(bottom: bottomMargin),
      decoration: BoxDecoration(
        color: const Color(0xFF264777),
        border: Border.all(
          color: const Color(0xFF264777),
          width: 2,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: Stack(
        children: [
          // SVG des bâtiments en arrière-plan - sur tous les headers
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: SvgPicture.asset(
                'assets/images/buildings.svg',
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.85),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          // Contenu du header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Bouton retour (si showBackButton = true)
              if (showBackButton)
                GestureDetector(
                  onTap: onBackPressed ?? () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                )
              // Logo compte (profil) - seulement sur la homepage
              else if (isHomePage)
                GestureDetector(
                  onTap: () {
                    if (navigationContext != null) {
                      Navigator.of(navigationContext!).pushNamed('/profile');
                    } else if (onProfileTap != null) {
                      onProfileTap!();
                    }
                  },
                  child: Container(
                    width: logoSize,
                    height: logoSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.5,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: logoIconSize,
                    ),
                  ),
                ),

              // Texte de salutation ou titre
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: (isHomePage || showBackButton) ? 16 : 0,
                  ),
                  child: Text(
                    isHomePage
                        ? 'Bonjour ${userName ?? "Clara"} !'
                        : title ?? 'Page',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // Cloche notification - seulement sur la homepage
              if (isHomePage)
                GestureDetector(
                  onTap: () {
                    if (navigationContext != null) {
                      Navigator.push(
                        navigationContext!,
                        MaterialPageRoute(builder: (context) => const RappelPage()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RappelPage()),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                      size: notifSize,
                    ),
                  ),
                ),

              // Trailing widget (pour le bouton d'aide)
              if (!isHomePage && trailing != null)
                trailing!,
            ],
          ),
        ],
      ),
    );
  }
}