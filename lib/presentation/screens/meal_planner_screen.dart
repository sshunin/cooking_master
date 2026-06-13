import 'package:cooking_master/core/i18n/app_localizations.dart';
import 'package:cooking_master/domain/entities/recipe.dart';
import 'package:cooking_master/presentation/providers/auth_provider.dart';
import 'package:cooking_master/presentation/providers/meal_planner_provider.dart';
import 'package:cooking_master/presentation/screens/recipe_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().user?.id;
      if (userId != null) {
        context.read<MealPlannerProvider>().loadPlansForMonth(userId, _focusedDay);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<MealPlannerProvider>();
    final userId = context.read<AuthProvider>().user?.id;

    List<Recipe> getEventsForDay(DateTime day) {
      final dateOnly = DateUtils.dateOnly(day);
      return provider.mealPlans[dateOnly]?.recipes ?? [];
    }

    final selectedDate = DateUtils.dateOnly(_selectedDay ?? DateTime.now());
    final recipesForDay = provider.mealPlans[selectedDate]?.recipes ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('meal_planner')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
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
          Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    if (userId != null) {
                      provider.loadPlanForDate(userId, selectedDay);
                    }
                  }
                },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              if (userId != null) {
                provider.loadPlansForMonth(userId, focusedDay);
              }
            },
            eventLoader: getEventsForDay,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
              markerDecoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
                ),
              ),
              const Divider(),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: recipesForDay.length,
                        itemBuilder: (context, index) {
                          final recipe = recipesForDay[index];
                          return ListTile(
                            title: Text(recipe.name),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                if (userId != null) {
                                  provider.removeRecipeFromPlan(
                                      userId, selectedDate, recipe.id);
                                }
                              },
                            ),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => RecipeViewScreen(recipe: recipe),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}