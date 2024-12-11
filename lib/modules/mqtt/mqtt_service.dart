import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MqttService {
  late MqttServerClient client;
  final NotificationService _notificationService = NotificationService();

  Future<void> connect(String topic) async {
    var mqttBroker = dotenv.env['MQTT_BROKER'] ?? '';
    var mqttPort = dotenv.env['MQTT_PORT'] ?? '';
    client = MqttServerClient(mqttBroker, 'flutter_client');
    client.port = mqttPort as int;
    client.logging(on: true);
    client.keepAlivePeriod = 20;

    try {
      await client.connect();
      client.subscribe(topic, MqttQos.atMostOnce);
      _notificationService.initialize();
    } catch (e) {
      print('Error conectando al broker: $e');
    }

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>>? messages) {
      final MqttPublishMessage message = messages![0].payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);

      print('Mensaje recibido: $payload');
      _notificationService.showNotification('Nuevo mensaje', payload);
    });
  }

  void disconnect() {
    client.disconnect();
  }
}
