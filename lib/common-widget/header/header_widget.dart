import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HeaderWidget extends StatelessWidget {
  final String? title;
  final String? userName;
  final bool isHomePage;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final bool isCollapsed;
  final BuildContext? navigationContext;

  const HeaderWidget({
    super.key,
    this.title,
    this.userName,
    this.isHomePage = false,
    this.onNotificationTap,
    this.onProfileTap,
    this.isCollapsed = false,
    this.navigationContext,
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
              // Logo compte (profil) - seulement sur la homepage
              if (isHomePage)
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
                  padding: EdgeInsets.symmetric(horizontal: isHomePage ? 16 : 0),
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
                      Navigator.of(navigationContext!).pushNamed('/notifications');
                    } else if (onNotificationTap != null) {
                      onNotificationTap!();
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
            ],
          ),
        ],
      ),
    );
  }
}

