import 'dart:io';

import 'package:cooking_master/core/i18n/app_localizations.dart';
import 'package:cooking_master/domain/entities/recipe.dart';
import 'package:cooking_master/presentation/providers/auth_provider.dart';
import 'package:cooking_master/presentation/providers/shopping_list_provider.dart';
import 'package:cooking_master/presentation/screens/add_recipe_screen.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:cooking_master/presentation/providers/meal_planner_provider.dart';

class RecipeViewScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeViewScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printRecipe(context),
            tooltip: loc.translate('print'),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareRecipe(context),
            tooltip: loc.translate('share'),
          ),
          IconButton(
            icon: const Icon(Icons.edit_calendar_outlined),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                helpText: loc.translate('select_date'),
              );
              if (date != null && context.mounted) {
                final userId = context.read<AuthProvider>().user?.id;
                if (userId != null) {
                  await context
                      .read<MealPlannerProvider>()
                      .addRecipeToPlan(userId, date, recipe.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.translate('added_to_meal_plan_on', {'date': '${date.toLocal()}'.split(' ')[0]})),
                    ),
                  );
                }
              }
            },
            tooltip: loc.translate('add_to_meal_plan'),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_checkout),
            onPressed: () {
              context.read<ShoppingListProvider>().addIngredients(recipe.ingredients);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.translate('added_to_shopping_list')),
                ),
              );
            },
            tooltip: loc.translate('add_to_shopping_list'),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddRecipeScreen(recipeToEdit: recipe),
                  ),
                );
                if (result == true && context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              tooltip: loc.translate('edit_recipe'),
              child: const Icon(Icons.edit),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (recipe.photoPath != null)
                  SizedBox(
                    height: 250,
                    child: Image.file(
                      File(recipe.photoPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        );
                      },
                    ),
                  )
                else
                  SizedBox(
                    height: 250,
                    child: Image.asset(
                      'assets/images/CM_Default_Receipe.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      if (recipe.description.isNotEmpty) ...[
                        Text(
                          recipe.description,
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                      ],
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        loc.translate('ingredients'),
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (recipe.ingredients.isEmpty)
                        Text(loc.translate('no_ingredients_added') == 'no_ingredients_added'
                            ? 'No ingredients added'
                            : loc.translate('no_ingredients_added'))
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recipe.ingredients.length,
                          itemBuilder: (context, index) {
                            final ingredient = recipe.ingredients[index];
                            return ListTile(
                              leading: const Icon(Icons.circle, size: 8),
                              title: Text(ingredient.name),
                              trailing: Text('${ingredient.calories} kcal'),
                              contentPadding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            );
                          },
                        ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        loc.translate('steps'),
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (recipe.steps.isEmpty)
                        Text(loc.translate('no_steps_added') == 'no_steps_added'
                            ? 'No steps added'
                            : loc.translate('no_steps_added'))
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recipe.steps.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final step = recipe.steps[index];
                            return ListTile(
                              leading: CircleAvatar(child: Text('${index + 1}')),
                              title: Text(step.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(step.description),
                              contentPadding: EdgeInsets.zero,
                            );
                          },
                        ),
                      const SizedBox(height: 80), // Space for FAB
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareRecipe(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final sb = StringBuffer();

    sb.writeln(recipe.name);
    if (recipe.description.isNotEmpty) {
      sb.writeln(recipe.description);
    }
    sb.writeln();

    sb.writeln(loc.translate('ingredients'));
    for (final ingredient in recipe.ingredients) {
      sb.writeln('• ${ingredient.name}: ${ingredient.calories} kcal');
    }
    sb.writeln();

    sb.writeln(loc.translate('steps'));
    for (int i = 0; i < recipe.steps.length; i++) {
      final step = recipe.steps[i];
      sb.writeln('${i + 1}. ${step.name}');
      if (step.description.isNotEmpty) {
        sb.writeln(step.description);
      }
      sb.writeln();
    }

    final text = sb.toString();

    if (recipe.photoPath != null && await File(recipe.photoPath!).exists()) {
      await Share.shareXFiles([XFile(recipe.photoPath!)], text: text);
    } else {
      await Share.share(text);
    }
  }

  Future<void> _printRecipe(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final doc = pw.Document();

    // Load fonts (using Google Fonts for better language support, e.g. Cyrillic)
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    pw.MemoryImage? image;
    if (recipe.photoPath != null && await File(recipe.photoPath!).exists()) {
      final imageBytes = await File(recipe.photoPath!).readAsBytes();
      image = pw.MemoryImage(imageBytes);
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Text(
              recipe.name,
              style: pw.TextStyle(font: boldFont, fontSize: 24),
            ),
            pw.SizedBox(height: 10),
            if (recipe.description.isNotEmpty)
              pw.Text(
                recipe.description,
                style: pw.TextStyle(font: font, fontSize: 14),
              ),
            pw.SizedBox(height: 10),
            if (image != null)
              pw.Container(
                height: 200,
                child: pw.Image(image, fit: pw.BoxFit.cover),
              ),
            pw.SizedBox(height: 20),
            pw.Text(
              loc.translate('ingredients'),
              style: pw.TextStyle(font: boldFont, fontSize: 18),
            ),
            pw.SizedBox(height: 5),
            ...recipe.ingredients.map(
              (e) => pw.Bullet(
                text: '${e.name}: ${e.calories} kcal',
                style: pw.TextStyle(font: font),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              loc.translate('steps'),
              style: pw.TextStyle(font: boldFont, fontSize: 18),
            ),
            pw.SizedBox(height: 5),
            ...recipe.steps.asMap().entries.map((e) {
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${e.key + 1}. ${e.value.name}',
                      style: pw.TextStyle(font: boldFont, fontSize: 14),
                    ),
                    if (e.value.description.isNotEmpty)
                      pw.Text(
                        e.value.description,
                        style: pw.TextStyle(font: font),
                      ),
                  ],
                ),
              );
            }),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: '${recipe.name}.pdf',
    );
  }
}