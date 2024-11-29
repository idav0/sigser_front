import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class DialogService {
  static final DialogService _instance = DialogService._internal();

  factory DialogService() => _instance;

  DialogService._internal();

  void showSuccessDialog(BuildContext context,
      {String? title, String? description}) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: title,
      desc: description,
      btnOkOnPress: () {},
    ).show();
  }

  void showErrorDialog(BuildContext context,
      {String? title, String? description}) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.bottomSlide,
      title: title,
      desc: description,
      btnOkOnPress: () {},
    ).show();
  }

  void showInfoDialog(BuildContext context,
      {String? title, String? description}) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      title: title,
      desc: description,
      btnOkOnPress: () {},
    ).show();
  }
}
