import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Configuración para Android
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('app_icon'); // Cambia 'app_icon' al nombre de tu ícono en mipmap

    // Configuración para iOS
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Configuración combinada
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Inicializar el plugin
    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap, // Maneja el toque en la notificación
    );
  }

  Future<void> showNotification(String title, String body) async {
    // Detalles para Android
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel', // ID único del canal
      'Default',         // Nombre del canal
      channelDescription: 'Canal para notificaciones generales', // Descripción del canal
      importance: Importance.max,
      priority: Priority.high,
    );

    // Detalles para iOS
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    // Configuración combinada
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Mostrar notificación
    await _notificationsPlugin.show(
      0,        // ID de la notificación
      title,    // Título de la notificación
      body,     // Cuerpo de la notificación
      details,  // Detalles específicos para cada plataforma
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    // Aquí puedes manejar el toque en la notificación
    print("Notificación pulsada: ${response.payload}");
  }
}
