// lib/models/blocked_app.dart
class BlockedApp {
  final String id;      // identificador único (por ahora, un slug)
  final String name;    // nombre visible (TikTok, Instagram)
  final String icon;    // nombre del asset o emoji temporal

  const BlockedApp({required this.id, required this.name, required this.icon});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'icon': icon};
  factory BlockedApp.fromJson(Map<String, dynamic> j) =>
      BlockedApp(id: j['id'], name: j['name'], icon: j['icon']);
}
