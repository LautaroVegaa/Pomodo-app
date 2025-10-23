// lib/providers/block_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/blocked_app.dart';

// 🆕 Import para obtener apps reales instaladas
import 'package:device_apps/device_apps.dart';

class BlockProvider extends ChangeNotifier {
  // 🔹 Lista mock inicial (en Fase 2 se reemplaza por apps reales del dispositivo)
  final List<BlockedApp> _catalog = const [
    BlockedApp(id: 'tiktok', name: 'TikTok', icon: '🎵'),
    BlockedApp(id: 'instagram', name: 'Instagram', icon: '📸'),
    BlockedApp(id: 'youtube', name: 'YouTube', icon: '▶️'),
    BlockedApp(id: 'facebook', name: 'Facebook', icon: '📘'),
    BlockedApp(id: 'x', name: 'X (Twitter)', icon: '🕊️'),
  ];

  // 🆕 Lista de apps reales del dispositivo
  List<Application> _installedApps = [];

  final Set<String> _selectedIds = {};
  bool _focusLockEnabled = false;

  List<BlockedApp> get catalog => _catalog;
  Set<String> get selectedIds => _selectedIds;
  bool get focusLockEnabled => _focusLockEnabled;

  // 🆕 Getter para las apps reales instaladas
  List<Application> get installedApps => _installedApps;

  static const _kSelectedKey = 'pomodo.block.selected';
  static const _kFocusLockKey = 'pomodo.block.enabled';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _focusLockEnabled = prefs.getBool(_kFocusLockKey) ?? false;

    final raw = prefs.getStringList(_kSelectedKey) ?? [];
    _selectedIds
      ..clear()
      ..addAll(raw);

    // 🆕 Cargar apps instaladas (solo las lanzables, no del sistema)
    try {
      _installedApps = await DeviceApps.getInstalledApplications(
        includeAppIcons: true, // ✅ agregado: carga los íconos originales
        includeSystemApps: false,
        onlyAppsWithLaunchIntent: true,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener apps instaladas: $e');
      }
      _installedApps = [];
    }

    notifyListeners();
  }

  Future<void> toggleSelection(String appId) async {
    if (_selectedIds.contains(appId)) {
      _selectedIds.remove(appId);
    } else {
      _selectedIds.add(appId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kSelectedKey, _selectedIds.toList());
    notifyListeners();
  }

  Future<void> setFocusLock(bool value) async {
    _focusLockEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kFocusLockKey, value);
    notifyListeners();
  }

  // 🔸 Helper para debug/logs (no sensible)
  String debugState() => jsonEncode({
        'enabled': _focusLockEnabled,
        'selected': _selectedIds.toList(),
        // 🆕 Muestra cuántas apps se detectaron
        'installed_apps': _installedApps.length,
      });
}
