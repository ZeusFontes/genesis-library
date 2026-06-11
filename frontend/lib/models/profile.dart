class Profile {
  final String id;
  final String name;
  final String avatar;
  final bool isKids;

  Profile({
    required this.id,
    required this.name,
    required this.avatar,
    this.isKids = false,
  });
}
