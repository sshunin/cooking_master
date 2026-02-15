class RecipeStep {
  final String name;
  final String description;
  final String? photoPath;

  const RecipeStep({
    required this.name,
    required this.description,
    this.photoPath,
  });
}