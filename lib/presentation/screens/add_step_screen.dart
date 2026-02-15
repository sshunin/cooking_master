import 'dart:io';

import 'package:cooking_master/core/i18n/app_localizations.dart';
import 'package:cooking_master/domain/entities/recipe_step.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddStepScreen extends StatefulWidget {
  final RecipeStep? stepToEdit;

  const AddStepScreen({super.key, this.stepToEdit});

  @override
  State<AddStepScreen> createState() => _AddStepScreenState();
}

class _AddStepScreenState extends State<AddStepScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    if (widget.stepToEdit != null) {
      _nameController.text = widget.stepToEdit!.name;
      _descriptionController.text = widget.stepToEdit!.description;
      _photoPath = widget.stepToEdit!.photoPath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _photoPath = pickedFile.path;
      });
    }
  }

  void _saveStep() {
    if (!_formKey.currentState!.validate()) return;

    final step = RecipeStep(
      name: _nameController.text,
      description: _descriptionController.text,
      photoPath: _photoPath,
    );

    Navigator.of(context).pop(step);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stepToEdit != null ? loc.translate('edit_step') : loc.translate('add_step')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveStep,
            tooltip: loc.translate('save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    image: _photoPath != null
                        ? DecorationImage(
                            image: FileImage(File(_photoPath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _photoPath == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text(loc.translate('pick_photo'), style: const TextStyle(color: Colors.grey)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: loc.translate('step_name'),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? loc.translate('please_fill_all') : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: loc.translate('step_description'),
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) => value?.isEmpty == true ? loc.translate('please_fill_all') : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}