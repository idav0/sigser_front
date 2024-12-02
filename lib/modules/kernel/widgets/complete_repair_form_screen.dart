import 'package:flutter/material.dart';
import 'dart:convert'; // Para Base64
import 'dart:typed_data'; // Para manipular bytes
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:awesome_dialog/awesome_dialog.dart'; // Paquete para los diálogos
import 'package:image/image.dart' as img; // Para redimensionar y comprimir
import 'package:image_picker/image_picker.dart';
import 'package:image_input/image_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompleteRepairFormScreen extends StatefulWidget {
  final int repairId;

  const CompleteRepairFormScreen({Key? key, required this.repairId})
      : super(key: key);

  @override
  State<CompleteRepairFormScreen> createState() =>
      _CompleteRepairFormScreenState();
}

class _CompleteRepairFormScreenState extends State<CompleteRepairFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repairObservationsController = TextEditingController();
  final Dio _dio = Dio();
  List<XFile> imageInputImages = [];
  final RegExp _validInputRegex = RegExp(r'^[a-zA-Z0-9ñÑ\s]+$');
  bool isLoading = false; // Indicador de carga

  @override
  void dispose() {
    _repairObservationsController.dispose();
    super.dispose();
  }

  Future<String> compressAndConvertToBase64(Uint8List imageBytes,
      {int maxSizeInBytes = 3 * 1024 * 1024}) async {
    img.Image? decodedImage = img.decodeImage(imageBytes);

    if (decodedImage == null) {
      throw Exception('Error al decodificar la imagen');
    }

    int quality = 100;
    Uint8List compressedImage;

    do {
      compressedImage =
          Uint8List.fromList(img.encodeJpg(decodedImage, quality: quality));
      quality -= 10;
    } while (compressedImage.lengthInBytes > maxSizeInBytes && quality > 0);

    return base64Encode(compressedImage);
  }
 Future<void> _onImageSelected(XFile image) async {
    final imageBytes = await image.readAsBytes();
    final imageSizeInBytes = imageBytes.lengthInBytes;

    // Verificar el tipo de archivo (JPG o JPEG)
    final fileExtension = image.name.split('.').last.toLowerCase();
    if (fileExtension != 'jpg' && fileExtension != 'jpeg') {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.bottomSlide,
        title: 'Formato no válido',
        desc: 'Solo se permiten imágenes en formato JPG o JPEG.',
      ).show();
      return;
    }
    if (imageSizeInBytes > 3 * 1024 * 1024) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.bottomSlide,
        title: 'Tamaño de la imagen',
        desc: 'El tamaño de la imagen no puede ser mayor a 3MB.',
      ).show();
      return;
    }
    setState(() {
      imageInputImages.add(image);
    });
  }
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true; // Inicia el indicador de carga
      });

      final repairObservations = _repairObservationsController.text;

      final List<String> base64Images = await Future.wait(
        imageInputImages.map(
          (image) async {
            final imageBytes = await image.readAsBytes();
            return await compressAndConvertToBase64(imageBytes);
          },
        ),
      );

      final requestData = {
        'id': widget.repairId,
        'repair_observations': repairObservations,
        'repair_images': base64Images,
      };

      try {
        final response = await _dio.put(
          '${dotenv.env['BASE_URL']}/repair/status/end-repair',
          data: requestData,
        );

        if (response.statusCode == 200) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.bottomSlide,
            title: 'Formulario enviado correctamente',
            desc: 'El diagnóstico se ha enviado con éxito.',
          ).show().then((_) {
            Navigator.pop(context);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al enviar el formulario')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')),
        );
      } finally {
        setState(() {
          isLoading = false; // Finaliza el indicador de carga
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terminar Reparación',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 19, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF172554),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Observaciones de la Reparación'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _repairObservationsController,
                    hintText:
                        'Escriba las observaciones de la reparación aquí...',
                    validator: _validateInput,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Evidencia (Imágenes)'),
                  const SizedBox(height: 8),
                  ImageInput(
                    images: imageInputImages,
                    allowEdit: true,
                    allowMaxImage: 10,
                    onImageSelected: _onImageSelected,
                    onImageRemoved: (image, index) {
                      setState(() {
                        imageInputImages.removeAt(index);
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF172554),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Enviar Formulario',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  Navigator.pop(context);
                                },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor:
                                const Color.fromARGB(255, 111, 3, 3),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  String? _validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es obligatorio.';
    } else if (!_validInputRegex.hasMatch(value)) {
      return 'Solo se permiten letras, números y espacios.';
    } else if (value.length > 100) {
      return 'El texto no debe superar los 100 caracteres.';
    }
    return null;
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
    );
  }
}
