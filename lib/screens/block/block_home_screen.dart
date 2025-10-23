// lib/screens/block/block_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:device_apps/device_apps.dart'; // 🆕 Import para mostrar apps reales
import '../../providers/block_provider.dart';
import 'blocked_app_screen.dart';

class BlockHomeScreen extends StatefulWidget {
  const BlockHomeScreen({super.key});

  @override
  State<BlockHomeScreen> createState() => _BlockHomeScreenState();
}

class _BlockHomeScreenState extends State<BlockHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<BlockProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final block = context.watch<BlockProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF111827) : Colors.grey[100];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Lock'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // 🔘 Header toggle
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.shield_outlined,
                    color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enable Focus Lock',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Block distracting apps during focus time',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: block.focusLockEnabled,
                  onChanged: (v) => block.setFocusLock(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 🔹 Section title
          Text(
            'Choose apps to block',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Select which apps should be blocked during focus sessions',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // 🆕 Loader mientras se cargan las apps reales
          if (block.installedApps.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(
                    color: Color(0xFF3579F6),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Cargando aplicaciones...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            )
          else
            // 🧩 Una vez cargadas, muestra las apps reales
            ...block.installedApps.map((app) {
              final isSelected =
                  block.selectedIds.contains(app.packageName); // usa packageName
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withOpacity(0.3)
                        : Colors.white10,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  // ✅ Muestra el ícono real de la app si está disponible
                  leading: app is ApplicationWithIcon
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            app.icon,
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.apps, color: Colors.white54),
                  title: Text(
                    app.appName,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  trailing: Checkbox(
                    value: isSelected,
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: (_) => block.toggleSelection(app.packageName),
                  ),
                  onTap: () => block.toggleSelection(app.packageName),
                ),
              );
            }).toList(),

          const SizedBox(height: 16),

          // 👁️ Preview button
          Center(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                final first = block.catalog.first;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlockedAppScreen(
                      appName: first.name,
                      icon: first.icon,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.visibility_outlined,
                  color: Theme.of(context).primaryColor),
              label: Text(
                'Preview blocked screen',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
