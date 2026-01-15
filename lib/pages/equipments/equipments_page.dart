import 'package:flutter/material.dart';
import '../../common-widget/header/header_widget.dart';
import 'components/summary_box.dart';
import 'components/warning_banner.dart';
import 'components/room_card.dart';
import 'components/equipment_detail_sheet.dart';
import 'components/dialogs.dart';
import 'components/onboarding_overlay.dart';
import 'models/room.dart';
import 'models/equipment.dart';
import 'services/equipment_service.dart';
import 'services/onboarding_service.dart';
import 'appliance_selection_page.dart';

class EquipmentsPage extends StatefulWidget {
  const EquipmentsPage({super.key});

  @override
  _EquipmentsPageState createState() => _EquipmentsPageState();
}

class _EquipmentsPageState extends State<EquipmentsPage> {
  late EquipmentService _equipmentService;
  List<Room> _rooms = [];
  Map<String, List<Equipment>> _equipmentsByRoom = {};
  InventoryStats _stats = InventoryStats(
    monthlyConsumption: 0,
    monthlyCost: 0,
    equipmentCount: 0,
    totalConsumption: 0,
  );
  
  List<Equipment> _topConsumingEquipments = [];
  bool _showOnboarding = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _equipmentService = EquipmentService();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final isCompleted = await OnboardingService.isOnboardingCompleted();
    
    if (!isCompleted) {
      await Future.delayed(Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() {
          _showOnboarding = true;
          _isLoading = false;
        });
      }
    } else {
      _loadData();
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    final rooms = await _equipmentService.getAllRooms();
    rooms.sort((a, b) => a.name.compareTo(b.name));
    
    final equipmentsByRoom = await _equipmentService.getEquipmentsByRooms();
    final stats = await _equipmentService.getInventoryStats();
    
    final allEquipments = await _equipmentService.getAllEquipments();
    _updateTopConsumingEquipments(allEquipments);

    setState(() {
      _rooms = rooms;
      _equipmentsByRoom = equipmentsByRoom;
      _stats = stats;
    });
  }

  void _updateTopConsumingEquipments(List<Equipment> allEquipments) {
    allEquipments.sort((a, b) => 
        b.monthlyConsumptionKwh.compareTo(a.monthlyConsumptionKwh));
    
    _topConsumingEquipments = allEquipments.take(5).toList();
  }

  Future<void> _addNewRoom() async {
    final newRoomName = await showDialog<String>(
      context: context,
      builder: (context) => AddRoomDialog(),
    );

    if (newRoomName != null && newRoomName.isNotEmpty) {
      final newRoom = Room(name: newRoomName);
      await _equipmentService.insertRoom(newRoom);
      _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pièce "$newRoomName" ajoutée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _editRoomName(Room room) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => EditRoomDialog(initialName: room.name),
    );

    if (newName != null && newName.isNotEmpty && newName != room.name) {
      try {
        final oldName = room.name;
        final updatedRoom = room.copyWith(name: newName);
        
        await _equipmentService.updateRoom(updatedRoom);
        
        final db = await _equipmentService.database;
        await db.update(
          'equipments',
          {'room_name': newName},
          where: 'room_name = ?',
          whereArgs: [oldName],
        );
        
        _loadData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pièce renommée en "$newName"'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du renommage: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteRoom(Room room) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDeleteDialog(
        title: 'Supprimer la pièce',
        message: 'Êtes-vous sûr de vouloir supprimer la pièce "${room.name}" ?',
        warning: 'Tous les équipements associés seront également supprimés.',
      ),
    );

    if (confirmDelete == true && room.id != null) {
      try {
        await _equipmentService.deleteRoom(room.id!);
        _loadData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pièce "${room.name}" supprimée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteEquipment(Equipment equipment, BuildContext bottomSheetContext) async {
    final confirmDelete = await showDialog<bool>(
      context: bottomSheetContext,
      builder: (context) => ConfirmDeleteDialog(
        title: 'Supprimer l\'appareil',
        message: 'Êtes-vous sûr de vouloir supprimer "${equipment.name}" ?',
        warning: 'Cette action est irréversible.',
      ),
    );

    if (confirmDelete == true && equipment.id != null) {
      try {
        final db = await _equipmentService.database;
        await db.delete(
          'equipments',
          where: 'id = ?',
          whereArgs: [equipment.id],
        );
        
        Navigator.pop(bottomSheetContext);
        
        await _loadData();
        
        ScaffoldMessenger.of(bottomSheetContext).showSnackBar(
          SnackBar(
            content: Text('"${equipment.name}" supprimé avec succès'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        Navigator.pop(bottomSheetContext);
        ScaffoldMessenger.of(bottomSheetContext).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _addEquipmentToRoom(String roomName) {
    final room = _rooms.firstWhere((r) => r.name == roomName);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplianceSelectionPage(room: room),
      ),
    ).then((added) {
      if (added == true) {
        _loadData();
      }
    });
  }

  void _showEquipmentDetails(BuildContext context, Equipment equipment) {
    final availableRooms = _rooms.map((room) => room.name).toList();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return EquipmentDetailBottomSheet(
          equipment: equipment,
          availableRooms: availableRooms,
          onSave: (updatedEquipment) async {
            try {
              await _equipmentService.updateEquipment(updatedEquipment);
              _loadData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Modifications enregistrées'),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erreur: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          onDelete: () => _deleteEquipment(equipment, context),
          onReset: (defaultAppliance) async {
            try {
              final defaultEquipment = equipment.resetToDefault(defaultAppliance);
              await _equipmentService.updateEquipment(defaultEquipment);
              _loadData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Valeurs réinitialisées'),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erreur: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );
      },
    );
  }

  bool _isTopConsumingEquipment(Equipment equipment) {
    return _topConsumingEquipments.any((topEquipment) => 
        topEquipment.id == equipment.id);
  }

  Widget _buildAddRoomButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Center(
        child: IconButton(
          onPressed: _addNewRoom,
          icon: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.add,
              size: 28,
              color: Colors.white,
            ),
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    await OnboardingService.completeOnboarding();
    setState(() {
      _showOnboarding = false;
    });
    _loadData();
  }

  void _showOnboardingAgain() async {
    await OnboardingService.resetOnboarding();
    setState(() {
      _showOnboarding = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Column(
            children: [
              HeaderWidget(
                title: 'Inventaire des Équipements',
                isHomePage: false,
                navigationContext: context,
                trailing: IconButton(
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.help_outline,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  onPressed: _showOnboardingAgain,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Voir le guide d\'utilisation',
                ),
              ),
              
              if (_isLoading)
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF405F90),
                    ),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _rooms.isEmpty ? 5 : _rooms.length + 5,
                      itemBuilder: (context, index) {
                        // Ajuster les indices pour le contenu fixe
                        if (index == 0) {
                          return SummaryBox(
                            monthlyConsumption: _stats.monthlyConsumption,
                            monthlyCost: _stats.monthlyCost,
                            equipmentCount: _stats.equipmentCount,
                          );
                        }

                        if (index == 1) {
                          return const SizedBox(height: 16);
                        }

                        if (index == 2) {
                          return const WarningBanner();
                        }

                        if (index == 3) {
                          return const SizedBox(height: 24);
                        }

                        // Si pas de pièces, afficher message + bouton
                        if (_rooms.isEmpty) {
                          if (index == 4) {
                            return Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 40),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.home_work,
                                          size: 60,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Aucune pièce n\'a été créée',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                _buildAddRoomButton(),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        }

                        // Index pour les pièces
                        final roomIndex = index - 4;

                        // Bouton d'ajout de pièce à la fin
                        if (roomIndex == _rooms.length) {
                          return _buildAddRoomButton();
                        }

                        // Afficher la pièce
                        final room = _rooms[roomIndex];
                        final equipments = _equipmentsByRoom[room.name] ?? [];

                        return RoomCard(
                          room: room,
                          equipments: equipments,
                          onEdit: () => _editRoomName(room),
                          onAddEquipment: () => _addEquipmentToRoom(room.name),
                          onDelete: () => _deleteRoom(room),
                          onEquipmentTap: (equipment) {
                            _showEquipmentDetails(context, equipment);
                          },
                          isTopConsumingEquipment: _isTopConsumingEquipment,
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),

        if (_showOnboarding)
          OnboardingOverlay(
            onComplete: _completeOnboarding,
          ),
      ],
    );
  }
}