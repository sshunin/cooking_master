import 'dart:io';

import 'package:cooking_master/core/di/service_locator.dart';
import 'package:cooking_master/core/i18n/app_localizations.dart';
import 'package:cooking_master/domain/entities/ingredient.dart';
import 'package:cooking_master/domain/entities/recipe.dart';
import 'package:cooking_master/domain/entities/recipe_step.dart';
import 'package:cooking_master/domain/repositories/recipe_repository.dart';
import 'package:cooking_master/presentation/providers/auth_provider.dart';
import 'package:cooking_master/presentation/screens/add_step_screen.dart';
import 'package:cooking_master/presentation/screens/select_ingredients_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddRecipeScreen extends StatefulWidget {
  final Recipe? recipeToEdit;

  const AddRecipeScreen({super.key, this.recipeToEdit});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _photoPath;
  bool _isLoading = false;
  List<Ingredient> _selectedIngredients = [];
  List<RecipeStep> _steps = [];

  @override
  void initState() {
    super.initState();
    if (widget.recipeToEdit != null) {
      _nameController.text = widget.recipeToEdit!.name;
      _descriptionController.text = widget.recipeToEdit!.description;
      _photoPath = widget.recipeToEdit!.photoPath;
      _selectedIngredients = List.from(widget.recipeToEdit!.ingredients);
      _steps = List.from(widget.recipeToEdit!.steps);
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

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final recipe = Recipe(
        id: widget.recipeToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: widget.recipeToEdit?.userId ?? user.id,
        name: _nameController.text,
        description: _descriptionController.text,
        photoPath: _photoPath,
        ingredients: _selectedIngredients,
        steps: _steps,
      );

      await ServiceLocator.instance.get<RecipeRepository>().saveRecipe(recipe);

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('error'))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleBackPress() async {
    if (_formKey.currentState!.validate()) {
      await _saveRecipe();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipeToEdit != null ? loc.translate('edit_recipe') : loc.translate('add_recipe_title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBackPress,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveRecipe,
            tooltip: loc.translate('save'),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton.extended(
              heroTag: 'select_ingredients',
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SelectIngredientsScreen(
                      initialSelectedIngredients: _selectedIngredients,
                    ),
                  ),
                );
                if (result != null && result is List<Ingredient>) {
                  setState(() => _selectedIngredients = result);
                }
              },
              label: Text(
                (loc.translate('select_ingredients') != 'select_ingredients' ? loc.translate('select_ingredients') : 'Select Ingredients').replaceAll(' ', '\n'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
              icon: const Icon(Icons.shopping_basket, size: 20),
              tooltip: loc.translate('select_ingredients') != 'select_ingredients' ? loc.translate('select_ingredients') : 'Select Ingredients',
              extendedPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            FloatingActionButton.extended(
              heroTag: 'add_step',
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddStepScreen(),
                  ),
                );
                if (result != null && result is RecipeStep) {
                  setState(() => _steps.add(result));
                }
              },
              label: Text(
                (loc.translate('add_step') != 'add_step' ? loc.translate('add_step') : 'Add Step').replaceAll(' ', '\n'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
              icon: const Icon(Icons.add, size: 20),
              tooltip: loc.translate('add_step') != 'add_step' ? loc.translate('add_step') : 'Add Step',
              extendedPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/CM_ingredients_list_background.png',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
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
                      labelText: loc.translate('recipe_name'),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty == true ? loc.translate('please_fill_all') : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: loc.translate('recipe_description'),
                      border: const OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                  ),
                  if (_selectedIngredients.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('${loc.translate('ingredients')}: ${_selectedIngredients.length}'),
                  ],
                  const SizedBox(height: 16),
                  Text(loc.translate('steps'), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: _steps.length,
                    onReorder: (int oldIndex, int newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final RecipeStep item = _steps.removeAt(oldIndex);
                        _steps.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final step = _steps[index];
                      return Card(
                        key: ObjectKey(step),
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Text(step.name),
                          subtitle: Text(step.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => setState(() => _steps.removeAt(index)),
                              ),
                              ReorderableDragStartListener(
                                index: index,
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.drag_handle),
                                ),
                              ),
                            ],
                          ),
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AddStepScreen(stepToEdit: step),
                              ),
                            );
                            if (result != null && result is RecipeStep) {
                              setState(() => _steps[index] = result);
                            }
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}