import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final String diagnosticObservations =
          _technicianObservationsController.text;
      final double diagnosticEstimatedCost =
          double.parse(_estimatedCostController.text);
      final String diagnosticParts =
          _partsControllers.map((controller) => controller.text).join(', ');

      final Map<String, dynamic> requestData = {
        "id": widget.repairId,
        "diagnostic_observations": diagnosticObservations,
        "diagnostic_parts": diagnosticParts,
        "diagnostic_estimated_cost": diagnosticEstimatedCost,
      };
      debugPrint('Data a enviar: ${jsonEncode(requestData)}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enviando formulario...')),
      );

      final String url =
          '${dotenv.env['BASE_URL']}/repair/status/end-diagnostic';

      try {
        final response = await _dio.put(
          url,
          data: jsonEncode(requestData),
          options: Options(headers: {'Content-Type': 'application/json'}),
        );

        debugPrint('Respuesta del servidor: ${response.data}');

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Diagnóstico enviado con éxito.')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error al enviar diagnóstico: ${response.data}')),
          );
        }
      } on DioError catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Error de conexión: ${e.response?.data ?? e.message}')),
        );
        debugPrint('Error en la petición: ${e.response?.data ?? e.message}');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inesperado: $e')),
        );
        debugPrint('Error inesperado: $e');
      }
    }
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
        backgroundColor: const Color(0xFF1e40af),
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 113, 121, 137),
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
                        backgroundColor: const Color(0xFF172554), // Azul
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
                        Navigator.pop(
                            context); // Regresar a la pantalla anterior
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromARGB(255, 111, 3, 3),
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
    );
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
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
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
        const Text(
          'Piezas Reemplazadas',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
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
