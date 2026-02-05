import 'package:flutter/material.dart';
import 'services/conseils_preferences_service.dart';

class ConseilsSettingsPage extends StatefulWidget {
  const ConseilsSettingsPage({super.key});

  @override
  State<ConseilsSettingsPage> createState() => _ConseilsSettingsPageState();
}

class _ConseilsSettingsPageState extends State<ConseilsSettingsPage> {
  String? _heatingType; // 'collectif' | 'individuel'
  String? _heatingEnergy; // 'gaz' | 'electrique'

  final ConseilsPreferencesService _prefs = ConseilsPreferencesService();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Si la page revient au premier plan après une autre page, on resynchronise.
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final heatingType = await _prefs.getHeatingType();
    final heatingEnergy = await _prefs.getHeatingEnergy();

    if (!mounted) return;
    setState(() {
      _heatingType = heatingType;
      _heatingEnergy = heatingEnergy;
    });
  }

  Future<void> _savePreferences() async {
    await _prefs.setHeatingType(_heatingType);
    await _prefs.setHeatingEnergy(_heatingEnergy);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Paramètres des conseils'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          _buildSectionHeader('Chauffage', Icons.local_fire_department),
          _buildHeatingTypeCard(colorScheme),
          _buildHeatingEnergyCard(colorScheme),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Ces choix permettent d\'affiner les conseils affichés (ex: conseils spécifiques au chauffage électrique ou individuel).',
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// Clone "light" du pattern de `RappelPage` (Type de chauffage)
  Widget _buildHeatingTypeCard(ColorScheme colorScheme) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.secondaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.home_work_outlined),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Type de chauffage',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chauffage collectif ou individuel',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildChoiceButton(
                    label: 'Collectif',
                    icon: Icons.apartment,
                    isSelected: _heatingType == 'collectif',
                    onTap: () async {
                      setState(
                        () => _heatingType = _heatingType == 'collectif'
                            ? null
                            : 'collectif',
                      );
                      await _savePreferences();
                    },
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildChoiceButton(
                    label: 'Individuel',
                    icon: Icons.home,
                    isSelected: _heatingType == 'individuel',
                    onTap: () async {
                      setState(
                        () => _heatingType = _heatingType == 'individuel'
                            ? null
                            : 'individuel',
                      );
                      await _savePreferences();
                    },
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Clone "light" du pattern de `RappelPage` (Énergie de chauffage)
  Widget _buildHeatingEnergyCard(ColorScheme colorScheme) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.secondaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.bolt),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Énergie de chauffage',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chauffage au gaz ou électrique',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildChoiceButton(
                    label: 'Gaz',
                    icon: Icons.local_fire_department,
                    isSelected: _heatingEnergy == 'gaz',
                    onTap: () async {
                      setState(
                        () => _heatingEnergy = _heatingEnergy == 'gaz'
                            ? null
                            : 'gaz',
                      );
                      await _savePreferences();
                    },
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildChoiceButton(
                    label: 'Électrique',
                    icon: Icons.bolt,
                    isSelected: _heatingEnergy == 'electrique',
                    onTap: () async {
                      setState(
                        () => _heatingEnergy = _heatingEnergy == 'electrique'
                            ? null
                            : 'electrique',
                      );
                      await _savePreferences();
                    },
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
