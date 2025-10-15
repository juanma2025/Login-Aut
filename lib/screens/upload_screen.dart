import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage_service.dart';
import '../services/supabase_config.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  FilePickerResult? _result;
  String? _selectedTag;
  final _nameController = TextEditingController();
  bool _loading = false;

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['mp3', 'wav'],
      withData: true,
    );
    if (res != null && res.files.isNotEmpty) {
      setState(() {
        _result = res;
        _nameController.text = res.files.first.name.split('.').first;
      });
    }
  }

  Future<void> _upload() async {
    if (_result == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Selecciona un archivo')));
      return;
    }
    if (_selectedTag == null || _selectedTag!.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Elige una etiqueta')));
      return;
    }
    setState(() => _loading = true);
    try {
      await StorageService().uploadSoundAndInsertMetadata(
        result: _result!,
        tag: _selectedTag!,
        customName: _nameController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Subido correctamente')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al subir: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Subir nuevo sonido', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del sonido',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.file_upload_outlined),
                label: const Text('Elegir archivo (.mp3/.wav)'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_result != null)
            Text('Archivo: ${_result!.files.first.name}'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedTag,
            items: [
              ...defaultTags.map((t) => DropdownMenuItem(value: t, child: Text(t))),
            ],
            onChanged: (v) => setState(() => _selectedTag = v),
            decoration: const InputDecoration(
              labelText: 'Etiqueta',
              border: OutlineInputBorder(),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _upload,
              child: _loading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Subir'),
            ),
          ),
        ],
      ),
    );
  }
}