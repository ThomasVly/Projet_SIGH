import 'package:flutter/material.dart';
import '../../common-widget/header/header_widget.dart';

class NotificationsHistoryPage extends StatefulWidget {
  const NotificationsHistoryPage({super.key});

  @override
  State<NotificationsHistoryPage> createState() =>
      _NotificationsHistoryPageState();
}

class _NotificationsHistoryPageState extends State<NotificationsHistoryPage> {
  // Liste de notifications vide
  final List<Map<String, dynamic>> notifications = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                HeaderWidget(
                  title: 'Notifications',
                  isHomePage: false,
                  onNotificationTap: () {
                    Navigator.pop(context);
                  },
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
              child: notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune notification',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: notification['read']
                                  ? Colors.white
                                  : const Color(0xFF063A6B).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!notification['read'])
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(
                                      right: 12,
                                      top: 6,
                                    ),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF0A82C6),
                                    ),
                                  )
                                else
                                  const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notification['title'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: notification['read']
                                              ? Colors.grey[800]
                                              : const Color(0xFF063A6B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notification['description'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notification['time'],
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

