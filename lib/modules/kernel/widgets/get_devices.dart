import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Asegúrate de cargar tu .env si es necesario
import 'package:dio/dio.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetDevices {
  GetDevices._();
  static final GetDevices instance = GetDevices._();

  Future<void> getData() async {
    final Dio _dio = Dio(BaseOptions(baseUrl: '${dotenv.env['BASE_URL']}'));
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {

          String? authority = prefs.getString('rol');
          int? id = prefs.getInt('id');
          String? token = prefs.getString('token');

        if (authority == "TECHNICIAN") {
          final devices = await _dio.get(
            '/repair/technician/$id',
            options: Options(
              headers: {
                'Authorization':
                    'Bearer ${token}',
              },
            ),
          );
           var response = devices.data;
          var ListDevices = jsonEncode(response['data']);
          await prefs.setString('listDevices', ListDevices);
        } else if (authority == "CLIENT") {
          final devices = await _dio.get(
            '/repair/client/$id',
            options: Options(
              headers: {
                'Authorization':
                    'Bearer ${token}',
              },
            ),
          );
          var response = devices.data;
          var ListDevices = jsonEncode(response['data']);
          await prefs.setString('listDevices', ListDevices);

          
        }
      
    } catch (e) {
      print("Error en makePayment: $e");
    }
  }
}
