import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CompleteRepairFormScreen extends StatefulWidget {
  final int repairId;
  const CompleteRepairFormScreen({Key? key, required this.repairId}) : super(key: key);

  @override
  State<CompleteRepairFormScreen> createState() =>
      _CompleteRepairFormScreenState();
}

class _CompleteRepairFormScreenState extends State<CompleteRepairFormScreen> {
final _formKey = GlobalKey<FormState>();
  final _repairObservationsController = TextEditingController();
  final Dio _dio = Dio();
  final List<TextEditingController> _installedPartsControllers = [];
  List<String> images = [];

  final RegExp _validInputRegex = RegExp(r'^[a-zA-Z0-9\s]+$');

  @override
  void dispose() {
    _repairObservationsController.dispose();
    for (var controller in _installedPartsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addPartField() {
    setState(() {
      _installedPartsControllers.add(TextEditingController());
    });
  }

  void _removePartField(int index) {
    setState(() {
      _installedPartsControllers[index].dispose();
      _installedPartsControllers.removeAt(index);
    });
  }

  void _addImage() {
    setState(() {
      images.add("assets/logo.png");
    });
  }

  void _removeImage(int index) {
    setState(() {
      images.removeAt(index);
    });
  }

Future<void> _submitForm() async {
  if (_formKey.currentState!.validate()) {
    final repairObservations = _repairObservationsController.text;

    final requestData = {
      'id': widget.repairId,
      'repair_observations': repairObservations,
    };

    debugPrint('Datos del formulario a enviar: $requestData');

    try {
      final response = await _dio.put(
        '${dotenv.env['BASE_URL']}/repair/status/end-repair',
        data: requestData,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Formulario enviado con éxito')),
        );
        debugPrint('Respuesta del servidor: ${response.data}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar el formulario')),
        );
        debugPrint('Error: ${response.statusCode} - ${response.data}');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
      debugPrint('Error al enviar la solicitud: $error');
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
              _buildSectionTitle('Observaciones de la Reparación'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _repairObservationsController,
                hintText: 'Escriba las observaciones de la reparación aquí...',
                validator: _validateInput,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              _buildSectionTitle('Piezas Instaladas'),
              const SizedBox(height: 8),
              _buildInstalledPartsSection(),
              const SizedBox(height: 16),

              _buildSectionTitle('Evidencia (Imágenes)'),
              const SizedBox(height: 8),
              _buildImageUploadSection(),
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
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
    );
  }

  Widget _buildInstalledPartsSection() {
    return Column(
      children: [
        for (int i = 0; i < _installedPartsControllers.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _installedPartsControllers[i],
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
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: _addPartField,
            icon: const Icon(Icons.build, color: Colors.white),
            label: const Text(
              'Agregar pieza',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563eb),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (int i = 0; i < images.length; i++)
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(images[i]),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeImage(i),
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
            child:
                const Icon(Icons.add_a_photo, size: 40, color: Colors.black54),
          ),
        ),
      ],
    );
  }
}
