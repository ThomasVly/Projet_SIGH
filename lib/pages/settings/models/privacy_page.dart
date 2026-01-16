import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../common-widget/header/header_widget.dart';
import '../../../shared/local_database/db-creator.dart';
import '../../../pages/equipments/services/equipment_service.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({Key? key}) : super(key: key);

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  bool _locationPermission = false;
  bool _notificationPermission = false;
  bool _showDataDeletedMessage = false;
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadPermissions();
  }

  // Initialiser les notifications locales
  Future<void> _initializeNotifications() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    
    // Configuration Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Gérer le clic sur la notification
      },
    );

    // Créer le canal de notifications (requis pour Android 8+)
    await _createNotificationChannel();
  }

  // Créer un canal de notifications
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'default_channel', // id
      'Notifications principales', // nom
      description: 'Canal pour les notifications principales',
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Envoyer une notification test
  Future<void> _sendTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'default_channel',
      'Notifications principales',
      channelDescription: 'Canal pour les notifications principales',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      '🔔 Notifications activées',
      'Les notifications sont maintenant activées pour cette application.',
      platformChannelSpecifics,
      payload: 'test_notification',
    );
  }

  // Charger les autorisations sauvegardées
  Future<void> _loadPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Vérifier les permissions réelles
    final locationStatus = await Permission.location.status;
    final notificationStatus = await Permission.notification.status;
    
    setState(() {
      _locationPermission = locationStatus.isGranted;
      _notificationPermission = notificationStatus.isGranted;
    });
  }

  // Sauvegarder les autorisations
  Future<void> _savePermission(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // Demander la permission de localisation réelle
  Future<void> _toggleLocationPermission() async {
    if (_locationPermission) {
      // Désactiver - ouvrir les paramètres système
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Désactiver la localisation'),
          content: const Text(
            'Pour désactiver la localisation, vous devez le faire dans les paramètres système de votre appareil.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF264777),
                foregroundColor: Colors.white,
              ),
              child: const Text('Ouvrir paramètres'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await openAppSettings();
        await _loadPermissions();
      }
    } else {
      // Activer - demander la permission
      final status = await Permission.location.request();
      
      setState(() {
        _locationPermission = status.isGranted;
      });
      
      await _savePermission('location_permission', _locationPermission);
    }
  }

  // Demander la permission de notifications réelle
  Future<void> _toggleNotificationPermission() async {
    if (_notificationPermission) {
      // Désactiver - ouvrir les paramètres système
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Désactiver les notifications'),
          content: const Text(
            'Pour désactiver les notifications, vous devez le faire dans les paramètres système de votre appareil.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF264777),
                foregroundColor: Colors.white,
              ),
              child: const Text('Ouvrir paramètres'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await openAppSettings();
        await _loadPermissions();
      }
    } else {
      // Activer - demander la permission
      final status = await Permission.notification.request();
      
      setState(() {
        _notificationPermission = status.isGranted;
      });
      
      await _savePermission('notification_permission', _notificationPermission);
      
      // Envoyer une notification test si la permission est accordée
      if (_notificationPermission) {
        // Petit délai pour s'assurer que la permission est bien prise en compte
        await Future.delayed(const Duration(milliseconds: 500));
        await _sendTestNotification();
      }
    }
  }

  // Supprimer toutes les données
  Future<void> _deleteAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer les données'),
        content: const Text(
          'Voulez-vous supprimer toutes les données locales ?\n'
          'Cela supprimera :\n'
          '• Vos équipements\n'
          '• Votre historique de consommation\n'
          '• Votre localisation enregistrée\n\n'
          'Ces données sont stockées uniquement sur votre appareil.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Supprimer la base de données SQLite (inclut les équipements)
        final dbHelper = DatabaseHelper.instance;
        await dbHelper.resetDatabase();

        // Supprimer aussi les données spécifiques aux équipements
        final equipmentService = EquipmentService();
        final db = await equipmentService.database;
        await db.delete('equipments');
        await db.delete('rooms');

        // Supprimer SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Afficher le message temporairement
        setState(() {
          _showDataDeletedMessage = true;
        });

        // Réinitialiser les permissions
        setState(() {
          _locationPermission = false;
          _notificationPermission = false;
        });
        
        await _savePermission('location_permission', false);
        await _savePermission('notification_permission', false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Données supprimées'),
            backgroundColor: Colors.green,
          ),
        );

        // Cacher le message après 5 secondes
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _showDataDeletedMessage = false;
            });
          }
        });

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            HeaderWidget(
              title: 'Confidentialité & Données',
              isHomePage: false,
              navigationContext: context,
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Autorisations
                    _buildSectionTitle('Autorisations'),
                    const SizedBox(height: 12),
                    
                    // Localisation
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.grey[700]),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Services de localisation',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Switch.adaptive(
                              value: _locationPermission,
                              onChanged: (value) => _toggleLocationPermission(),
                              activeColor: const Color(0xFF264777),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Notifications
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.notifications, color: Colors.grey[700]),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Notifications',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Switch.adaptive(
                              value: _notificationPermission,
                              onChanged: (value) => _toggleNotificationPermission(),
                              activeColor: const Color(0xFF264777),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Section Données locales
                    _buildSectionTitle('Données locales'),
                    const SizedBox(height: 8),
                    
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Les informations suivantes sont stockées uniquement sur votre appareil :',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            _buildDataItem(
                              icon: Icons.location_on,
                              text: 'Localisation',
                            ),
                            
                            _buildDataItem(
                              icon: Icons.devices,
                              text: 'Inventaire des équipements',
                            ),
                            
                            _buildDataItem(
                              icon: Icons.history,
                              text: 'Historique de consommation',
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Bouton supprimer
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _deleteAllData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Supprimer toutes les données',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    // Message temporaire (apparaît seulement après suppression)
                    if (_showDataDeletedMessage)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Données supprimées',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              color: Colors.green,
                              onPressed: () {
                                setState(() {
                                  _showDataDeletedMessage = false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF264777),
        ),
      ),
    );
  }

  Widget _buildDataItem({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}