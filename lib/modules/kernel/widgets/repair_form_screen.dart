import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

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
  List<String> images = [];

  final Dio _dio = Dio();

  final RegExp _validInputRegex = RegExp(r'^[a-zA-Z0-9\s]+$');

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

  void _addImage() {
    setState(() {
      images.add("assets/logo.png"); // Ejemplo de imagen placeholder
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final observations = _technicianObservationsController.text;
      final parts = _partsControllers.map((controller) => controller.text).toList();
      final estimatedCost = double.parse(_estimatedCostController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enviando formulario...')),
      );

      final url = 'http://<tu-servidor>/api-sigser/repair/status/start-diagnostic/${widget.repairId}';

      try {
        final response = await _dio.put(url, options: Options(headers: {
          'Content-Type': 'application/json',
        }));

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Estado actualizado a DIAGNOSIS.')),
          );

          debugPrint('Observaciones del técnico: $observations');
          debugPrint('Piezas necesarias: $parts');
          debugPrint('Cotización Aproximada: $estimatedCost');
          debugPrint('Evidencia: $images');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar el estado: ${response.data}')),
          );
        }
      } on DioError catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión: ${e.response?.data ?? e.message}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inesperado: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Formulario de Reparación',
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
              _buildSectionTitle('Evidencia (Imágenes)'),
              const SizedBox(height: 8),
              _buildImageUploadSection(),
              const SizedBox(height: 16),
              _buildSectionTitle('¿Desea agregar una pieza?'),
              const SizedBox(height: 8),
              _buildAddPartButtons(),
              const SizedBox(height: 16),
              _buildPartsSection(),
              const SizedBox(height: 16),
              _buildSectionTitle('Cotización Aproximada'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _estimatedCostController,
                hintText: 'Ingrese el monto aproximado (\$)...',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese la cotización aproximada.';
                  }
                  final cost = double.tryParse(value);
                  if (cost == null || cost < 0) {
                    return 'Ingrese un valor válido mayor o igual a 0.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF172554),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Enviar Formulario',
                      style: TextStyle(fontSize: 16)),
                ),
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

  Widget _buildPartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _partsControllers.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _partsControllers[i],
                    hintText: 'Nombre de la pieza...',
                    validator: _validateInput,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _removePartField(i),
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAddPartButtons() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: _addPartField,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF34D399),
            foregroundColor: Colors.white,
          ),
          child: const Text('Agregar Pieza'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF87171),
            foregroundColor: Colors.white,
          ),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var image in images)
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(image),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      images.remove(image);
                    });
                  },
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        GestureDetector(
          onTap: _addImage,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add_a_photo, size: 40),
          ),
        ),
      ],
    );
  }
}
