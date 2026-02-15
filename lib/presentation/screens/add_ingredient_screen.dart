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
import 'package:cooking_master/core/ai/ai_client.dart';

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

    debugPrint('[AI] _askAIForCalories invoked');

    // Ensure ingredient name exists
    final name = _nameController.text.trim();
    debugPrint('[AI] Ingredient name: "$name"');
    if (name.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('please_fill_all'))),
        );
      }
      return;
    }

    // If no API key present, prompt user before starting the request
    final ai = ServiceLocator.instance.get<AIClient>();
    if (!await ai.hasApiKey()) {
      debugPrint('[AI] No API key present; will prompt user to enter one');
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

      if (entered == null || entered.isEmpty) {
        debugPrint('[AI] API key entry cancelled or empty by user');
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('cancel'))));
        return;
      }

      debugPrint('[AI] User provided API key (value not logged)');
      await ai.setApiKey(entered);
    }

    // Prompt is ready; perform request
    try {
      debugPrint('[AI] Showing progress dialog and calling OpenAI.suggestCalories');
      // show waiting
      var progressShown = true;
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
      ).then((_) {
        progressShown = false;
      });

      final client = ServiceLocator.instance.get<AIClient>();
      debugPrint('[AI] Calling AI client suggestCalories');
      final suggestion = await client.suggestCalories(name);

      if (progressShown && mounted) Navigator.of(context).pop();

      debugPrint('[AI] suggestCalories returned: $suggestion');

      if (suggestion == null) {
        debugPrint('[AI] suggestion is null — showing error snackbar');
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

      debugPrint('[AI] User accept dialog result: $accept');

      if (accept == true) {
        debugPrint('[AI] User accepted suggestion — filling calories field');
        _caloriesController.text = suggestion.toString();
      }
    } catch (e) {
      debugPrint('[AI] Exception in _askAIForCalories: $e');
      // Ensure progress dialog closed before prompting
      try {
        if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
      } catch (_) {}

      // If missing API key, prompt user to enter it
      if (e.toString().contains('NO_API_KEY')) {
        debugPrint('[AI] Caught NO_API_KEY during suggest — prompting user');
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

        // If user cancelled or entered empty key, do not start request
        if (entered == null || entered.isEmpty) {
          debugPrint('[AI] User cancelled API key entry after NO_API_KEY');
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('cancel'))));
          return;
        }

        debugPrint('[AI] User provided API key after NO_API_KEY (value not logged)');
        await ServiceLocator.instance.get<AIClient>().setApiKey(entered);
        // Retry once
        await _askAIForCalories();
      } else {
        if (mounted) {
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
              if (_isEditing) ...[
                TextButton(
                  child: Text(
                    loc.translate('update'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final calories = int.tryParse(_caloriesController.text);
                      // The validator should prevent this from being null, but this is a safe fallback.
                      if (calories == null) return;
                      
                      final ingredient = Ingredient(
                          id: _editingId, name: _nameController.text, calories: calories, photoPath: _imagePath);
                      
                      await ServiceLocator.instance.get<UpdateIngredientUseCase>().call(ingredient);
                      if (mounted) Navigator.of(context).pop();
                    }
                  },
                ),
              ] else ...[
                TextButton(
                  child: Text(
                    loc.translate('save'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final calories = int.tryParse(_caloriesController.text);
                      // The validator should prevent this from being null, but this is a safe fallback.
                      if (calories == null) return;
                      
                      final ingredient = Ingredient(
                          id: _editingId, name: _nameController.text, calories: calories, photoPath: _imagePath);
                      
                      await ServiceLocator.instance.get<SaveIngredientUseCase>().call(ingredient);
                      if (mounted) Navigator.of(context).pop();
                    }
                  },
                ),
              ],
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