import 'package:flutter/material.dart';
import '../../common-widget/header/header_widget.dart';
import 'components/appliance_card.dart';
import 'models/appliance.dart';
import 'models/room.dart';
import 'services/equipment_service.dart';


class ApplianceSelectionPage extends StatefulWidget {
  final Room room;

  const ApplianceSelectionPage({
    super.key,
    required this.room,
  });

  @override
  _ApplianceSelectionPageState createState() => _ApplianceSelectionPageState();
}

class _ApplianceSelectionPageState extends State<ApplianceSelectionPage> {
  final EquipmentService _equipmentService = EquipmentService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Appliance> _selectedAppliances = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  List<Appliance> _getFilteredAppliances() {
    List<Appliance> appliances;
    
    // Filtrer par recherche
    if (_searchQuery.isNotEmpty) {
      appliances = Appliance.search(_searchQuery);
    } else {
      appliances = List.from(Appliance.predefinedAppliances);
    }
    
    return appliances;
  }

  void _toggleApplianceSelection(Appliance appliance) {
    setState(() {
      if (_selectedAppliances.contains(appliance)) {
        _selectedAppliances.remove(appliance);
      } else {
        _selectedAppliances.add(appliance);
      }
    });
  }

  Future<void> _saveSelectedAppliances() async {
    if (_selectedAppliances.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez sélectionner au moins un appareil'),
          backgroundColor: const Color(0xFFFC0001),
        ),
      );
      return;
    }

    try {
      for (final appliance in _selectedAppliances) {
        final equipment = appliance.toEquipment(widget.room.name);
        await _equipmentService.insertEquipment(equipment);
      }

      Navigator.pop(context, true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_selectedAppliances.length} appareil(s) ajouté(s) à ${widget.room.name}',
          ),
          backgroundColor: const Color(0xFF72BA00),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'ajout: $e'),
          backgroundColor: const Color(0xFFFC0001),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAppliances = _getFilteredAppliances();

    return Scaffold(
      // Suppression de l'appBar originale et ajout du HeaderWidget
      appBar: null,
      body: Column(
        children: [
          // Ajout du HeaderWidget
          HeaderWidget(
            title: 'Sélection d\'appareils',
            isHomePage: false,
            navigationContext: context,
          ),

          // Le reste de votre code original reste exactement le même
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF003366),
                    Color(0xFF0055AA),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    widget.room.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFFC0001)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Les valeurs affichées sont des estimations par défaut. '
                      'Vous pourrez les personnaliser après ajout.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFFC0001),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un appareil...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF405F90)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF405F90)),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF405F90)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF405F90)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF264777), width: 2),
                ),
                filled: true,
                fillColor: const Color(0xFFD6E3FF),
                hintStyle: const TextStyle(color: Color(0xFF405F90)),
              ),
              style: const TextStyle(color: Color(0xFF003063)),
            ),
          ),

          const SizedBox(height: 16),

          // Nombre de résultats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_selectedAppliances.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedAppliances.clear();
                      });
                    },
                    icon: const Icon(Icons.clear_all, size: 16, color: Color(0xFF405F90)),
                    label: const Text(
                      'Tout désélectionner',
                      style: TextStyle(color: Color(0xFF405F90)),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Liste des appareils
          Expanded(
            child: filteredAppliances.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 60,
                          color: Color(0xFF405F90),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucun appareil trouvé',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF405F90),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Essayez avec d\'autres termes de recherche',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF405F90),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredAppliances.length,
                    itemBuilder: (context, index) {
                      final appliance = filteredAppliances[index];
                      final isSelected = _selectedAppliances.contains(appliance);
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ApplianceCard(
                          appliance: appliance,
                          isSelected: isSelected,
                          onTap: () => _toggleApplianceSelection(appliance),
                        ),
                      );
                    },
                  ),
          ),

          // Bouton de validation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: const Color(0xFFD6E3FF))),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveSelectedAppliances,
                    icon: const Icon(Icons.add_circle),
                    label: Text(
                      _selectedAppliances.isEmpty
                          ? 'Sélectionner des appareils'
                          : 'Ajouter (${_selectedAppliances.length})',
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: _selectedAppliances.isEmpty
                          ? const Color(0xFFD6E3FF)
                          : const Color(0xFF405F90),
                      foregroundColor: _selectedAppliances.isEmpty
                          ? const Color(0xFF405F90)
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}