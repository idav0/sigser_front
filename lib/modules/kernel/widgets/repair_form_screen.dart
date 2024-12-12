import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:image_input/image_input.dart';

class RepairFormScreen extends StatefulWidget {
  final int repairId;

  const RepairFormScreen({Key? key, required this.repairId}) : super(key: key);

  @override
  State<RepairFormScreen> createState() => _RepairFormScreenState();
}

class _RepairFormScreenState extends State<RepairFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _technicianObservationsController = TextEditingController();
  final _estimatedCostController = TextEditingController();
  final List<TextEditingController> _partsControllers = [];
  final Dio _dio = Dio();
  bool _addPartsVisible = false;
  bool isLoading = false;
  List<XFile> imageInputImages = [];
  final RegExp _validInputRegex = RegExp(r'^[a-zA-Z0-9ñÑ\s]+$');

  @override
  void dispose() {
    _technicianObservationsController.dispose();
    _estimatedCostController.dispose();
    for (var controller in _partsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es obligatorio.';
    } else if (value.length > 50) {
      return 'El texto no puede exceder los 50 caracteres.';
    } else if (!_validInputRegex.hasMatch(value)) {
      return 'Solo se permiten letras, números y espacios.';
    }
    return null;
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

  // Convertir a Base64
  String base64Image = base64Encode(compressedImage);
 
  // Imprimir el resultado de la conversión a Base64
  print('Imagen convertida a Base64: $base64Image');

  return base64Image;
  }

  void _addPartField() {
    setState(() {
      _partsControllers.add(TextEditingController());
    });
  }

  void _removePartField(int index) {
    setState(() {
      _partsControllers[index].dispose();
      _partsControllers.removeAt(index);
    });
  }

  void _clearParts() {
    setState(() {
      for (var controller in _partsControllers) {
        controller.dispose();
      }
      _partsControllers.clear();
    });
  }

  void _saveDevices(devices) async {
    final prefs = await SharedPreferences.getInstance();
    final listDevices = jsonEncode(devices['data']);
    await prefs.setString('listDevices', listDevices);
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      final String diagnosticObservations =
          _technicianObservationsController.text;
      final double diagnosticEstimatedCost =
          double.parse(_estimatedCostController.text);
      final String diagnosticParts =
          _partsControllers.map((controller) => controller.text).join(', ');
      final List<String> base64Images = await Future.wait(
        imageInputImages.map((image) async {
          final imageBytes = await image.readAsBytes();
          return await compressAndConvertToBase64(imageBytes);
        }),
      );
      print(base64Images);
      final Map<String, dynamic> requestData = {
        "id": widget.repairId,
        "diagnostic_observations": diagnosticObservations,
        "diagnostic_parts": diagnosticParts,
        "diagnostic_estimated_cost": diagnosticEstimatedCost,
        "diagnostic_images": base64Images,
      };
      final String url =
          '${dotenv.env['BASE_URL']}/repair/status/end-diagnostic';
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token') ?? '';
        final authority = prefs.getString('rol') ?? '';
        final userId = prefs.getInt('id') ?? 0;
        final response = await _dio.put(
          url,
          data: jsonEncode(requestData),
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          }),
        );
        if (response.statusCode == 200) {
          final String devicesUrl = authority == "TECHNICIAN"
              ? '${dotenv.env['BASE_URL']}/repair/technician/$userId'
              : '${dotenv.env['BASE_URL']}/repair/client/$userId';
          final devicesResponse = await _dio.get(
            devicesUrl,
            options: Options(headers: {'Authorization': 'Bearer $token'}),
          );
          if (devicesResponse.statusCode == 200) {
            final devicesData = devicesResponse.data;
            _saveDevices(devicesData);
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
            AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.bottomSlide,
              title: 'Formulario enviado correctamente',
              desc: 'El diagnóstico se ha enviado con éxito.',
            ).show();
          }
        } else {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            title: 'Error al enviar',
            desc: 'Error al enviar diagnóstico.',
          ).show();
        }
      } catch (e) {
        AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.bottomSlide,
              title: 'Formulario enviado correctamente',
              desc: 'El diagnóstico se ha enviado con éxito.',
            ).show();
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Seleccionar fuente de la imagen'),
          children: [
            SimpleDialogOption(
              child: const Text('Cámara'),
              onPressed: () => Navigator.pop(context, ImageSource.camera),
            ),
            SimpleDialogOption(
              child: const Text('Galería'),
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Formulario de Diagnóstico',
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
                  _buildSectionTitle('Observaciones del Técnico'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _technicianObservationsController,
                    hintText: 'Escriba las observaciones del técnico aquí...',
                    validator: _validateInput,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('¿Desea agregar una pieza?'),
                  const SizedBox(height: 8),
                  _buildAddPartButtons(),
                  const SizedBox(height: 16),
                  if (_addPartsVisible) ...[
                    _buildPartsSection(),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        onPressed: _addPartField,
                        icon: const Icon(Icons.build, color: Colors.white),
                        label: const Text(
                          'Agregar pieza',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 113, 121, 137),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 24),
                  _buildSectionTitle('Evidencia (Imágenes)'),
                  const SizedBox(height: 8),
                  ImageInput(
                    images: imageInputImages,
                    allowEdit: true,
                    allowMaxImage: 10,
                    onImageSelected: (image) async {
                      final imageBytes = await image.readAsBytes();
                      final fileSize = imageBytes.lengthInBytes;
                      print('Imagen seleccionada: ${image.name}');

                      if (fileSize > 3 * 1024 * 1024) {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.warning,
                          animType: AnimType.bottomSlide,
                          title: 'Tamaño de la imagen',
                          desc:
                              'El tamaño de la imagen no puede ser mayor a 3MB.',
                        ).show();
                        return;
                      }
                      final fileExtension =
                          image.name.split('.').last.toLowerCase();
                      if (fileExtension != 'jpg' && fileExtension != 'jpeg') {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.warning,
                          animType: AnimType.bottomSlide,
                          title: 'Formato no válido',
                          desc:
                              'Solo se permiten imágenes en formato JPG o JPEG.',
                        ).show();
                        return;
                      }
                      setState(() {
                        imageInputImages.add(image);
                      });
                    },
                    onImageRemoved: (image, index) {
                      setState(() {
                        imageInputImages.removeAt(index);
                      });
                    },
                    getImageSource: _showImageSourceDialog,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Costo Estimado de Diagnóstico'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _estimatedCostController,
                    hintText: 'Ingrese el costo estimado (\$)...',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese el costo estimado.';
                      }
                      final cost = double.tryParse(value);
                      if (cost == null || cost < 0) {
                        return 'Ingrese un valor válido mayor o igual a 0.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF172554),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Enviar Diagnóstico',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  Widget _buildAddPartButtons() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              _addPartsVisible = true;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF172554),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            elevation: 5,
          ),
          child: const Row(
            children: [
              Icon(Icons.check, size: 20),
              SizedBox(width: 8),
              Text('Sí',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _addPartsVisible = false;
              _clearParts();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 119, 25, 25),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            elevation: 5,
          ),
          child: const Row(
            children: [
              Icon(Icons.close, size: 20),
              SizedBox(width: 8),
              Text('No',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Piezas Reemplazadas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        for (int i = 0; i < _partsControllers.length; i++) ...[
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _partsControllers[i],
                  hintText: 'Nombre de la pieza',
                  validator: _validateInput,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removePartField(i),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
