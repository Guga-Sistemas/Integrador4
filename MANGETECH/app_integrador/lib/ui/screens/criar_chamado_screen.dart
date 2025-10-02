import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';

class CriarChamadoScreen extends StatefulWidget {
  const CriarChamadoScreen({Key? key}) : super(key: key);

  @override
  State<CriarChamadoScreen> createState() => _CriarChamadoScreenState();
}

class _CriarChamadoScreenState extends State<CriarChamadoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _ativoController = TextEditingController();
  final _ambienteController = TextEditingController();
  final _descricaoController = TextEditingController();
  
  String _urgencia = 'Média';
  DateTime? _dataSugerida;
  final List<XFile> _anexos = [];
  bool _isLoading = false;

  final List<String> _urgenciaOptions = ['Baixo', 'Médio', 'Alto', 'Crítico'];

  @override
  void dispose() {
    _tituloController.dispose();
    _ativoController.dispose();
    _ambienteController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_anexos.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Máximo de 5 arquivos permitidos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        final remainingSlots = 5 - _anexos.length;
        _anexos.addAll(images.take(remainingSlots));
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _dataSugerida = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chamado criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Chamado'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  hintText: 'Descreva brevemente o problema',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O título é obrigatório';
                  }
                  if (value.length < 5) {
                    return 'O título deve ter pelo menos 5 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ativoController,
                decoration: const InputDecoration(
                  labelText: 'Ativo *',
                  hintText: 'Buscar por nome ou QR tag',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                  suffixIcon: Icon(Icons.qr_code_scanner),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O ativo é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ambienteController,
                decoration: const InputDecoration(
                  labelText: 'Ambiente',
                  hintText: 'Ex: Setor Financeiro - Sala 204',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição *',
                  hintText: 'Descreva o problema detalhadamente',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'A descrição é obrigatória';
                  }
                  if (value.length < 15) {
                    return 'A descrição deve ter pelo menos 15 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Data sugerida de resolução'),
                subtitle: Text(
                  _dataSugerida != null
                      ? '${_dataSugerida!.day}/${_dataSugerida!.month}/${_dataSugerida!.year} ${_dataSugerida!.hour}:${_dataSugerida!.minute.toString().padLeft(2, '0')}'
                      : 'Nenhuma data selecionada',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _selectDate,
              ),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Nível de urgência *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _urgenciaOptions.map((option) {
                  final isSelected = _urgencia == option;
                  return ChoiceChip(
                    label: Text(option),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _urgencia = option);
                      }
                    },
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Fotos / Anexos (opcional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              if (_anexos.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _anexos.asMap().entries.map((entry) {
                    final index = entry.key;
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: const Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _anexos.removeAt(index));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(
                  _anexos.isEmpty
                      ? 'Adicionar fotos'
                      : 'Adicionar mais fotos (${_anexos.length}/5)',
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Criar Chamado'),
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
}