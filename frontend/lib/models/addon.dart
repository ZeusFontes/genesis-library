class Addon {
  final String id;
  final String name;
  final String description;
  final String author;
  final String category;
  bool enabled;

  Addon({
    required this.id,
    required this.name,
    required this.description,
    required this.author,
    required this.category,
    this.enabled = false,
  });
}
