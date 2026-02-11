import 'dart:io';
import 'package:cooking_master/core/di/service_locator.dart';
import 'package:cooking_master/core/i18n/app_localizations.dart';
import 'package:cooking_master/domain/entities/ingredient.dart';
import 'package:cooking_master/domain/usecases/save_ingredient_usecase.dart';
import 'package:cooking_master/domain/usecases/update_ingredient_usecase.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:cooking_master/core/ai/openai_client.dart';

class AddIngredientScreen extends StatefulWidget {
  const AddIngredientScreen({super.key});

  @override
  State<AddIngredientScreen> createState() => _AddIngredientScreenState();
}

class _AddIngredientScreenState extends State<AddIngredientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  String? _imagePath;
  bool _initialized = false;
  bool _isEditing = false;
  int? _editingId;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _askAIForCalories() async {
    final loc = AppLocalizations.of(context);

    // Ensure ingredient name exists
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('please_fill_all'))),
        );
      }
      return;
    }

    // Check for API key stored in storage; OpenAIClient will throw if missing.
    // Prompt user to enter API key if absent
    try {
      // show waiting
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          content: Row(
            children: [
              const SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
              const SizedBox(width: 16),
              Expanded(child: Text(loc.translate('ai_suggesting'))),
            ],
          ),
        ),
      );

      final client = OpenAIClient.instance();
      final suggestion = await client.suggestCalories(name);

      if (mounted) Navigator.of(context).pop();

      if (suggestion == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('error'))));
        return;
      }

      final accept = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(loc.translate('ask_ai')),
          content: Text(loc.translate('ai_suggestion', {'value': suggestion.toString()})),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(loc.translate('cancel'))),
            TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(loc.translate('accept'))),
          ],
        ),
      );

      if (accept == true) {
        _caloriesController.text = suggestion.toString();
      }
    } catch (e) {
      // If missing API key, prompt user to enter it
      if (e.toString().contains('NO_API_KEY')) {
        if (!mounted) return;
        final entered = await showDialog<String?>(
          context: context,
          builder: (ctx) {
            final keyCtrl = TextEditingController();
            return AlertDialog(
              title: Text(loc.translate('enter_api_key')),
              content: TextField(controller: keyCtrl, decoration: InputDecoration(hintText: 'sk-...')),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: Text(loc.translate('cancel'))),
                TextButton(onPressed: () => Navigator.of(ctx).pop(keyCtrl.text.trim()), child: Text(loc.translate('save'))),
              ],
            );
          },
        );

        if (entered != null && entered.isNotEmpty) {
          await OpenAIClient.instance().setApiKey(entered);
          // Retry once
          await _askAIForCalories();
        }
      } else {
        if (mounted) {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('error')), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Ingredient) {
        _isEditing = true;
        _editingId = args.id;
        _nameController.text = args.name;
        _caloriesController.text = args.calories.toString();
        _imagePath = args.photoPath;
      }
      _initialized = true;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(pickedFile.path)}';
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
      setState(() {
        _imagePath = savedImage.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? loc.translate('edit_ingredient') : loc.translate('add_ingredient')),
        actions: [
          TextButton(
            child: Text(
              _isEditing ? loc.translate('update') : loc.translate('save'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final calories = int.tryParse(_caloriesController.text);
                // The validator should prevent this from being null, but this is a safe fallback.
                if (calories == null) return;

                final ingredient = Ingredient(
                    id: _editingId, name: _nameController.text, calories: calories, photoPath: _imagePath);
                
                if (_isEditing) {
                  await ServiceLocator.instance.get<UpdateIngredientUseCase>().call(ingredient);
                } else {
                  await ServiceLocator.instance.get<SaveIngredientUseCase>().call(ingredient);
                }
                if (mounted) Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: loc.translate('ingredient_name'),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.translate('please_fill_all');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _caloriesController,
                decoration: InputDecoration(
                  labelText: loc.translate('calories'),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: TextButton.icon(
                    onPressed: _askAIForCalories,
                    icon: const Icon(Icons.smart_toy, size: 18),
                    label: Text(loc.translate('ask_ai')),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.translate('please_fill_all');
                  }
                  if (int.tryParse(value) == null) {
                    return loc.translate('invalid_number');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _imagePath != null
                        ? Image.file(File(_imagePath!), fit: BoxFit.cover)
                        : const Icon(Icons.image, size: 40, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.upload),
                    label: Text(loc.translate('upload_photo')),
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