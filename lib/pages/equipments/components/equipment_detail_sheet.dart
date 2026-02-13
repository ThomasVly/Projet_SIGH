import 'package:flutter/material.dart';
import '../models/appliance.dart';
import '../models/equipment.dart';
import '../services/equipment_service.dart';

class EquipmentDetailBottomSheet extends StatefulWidget {
  final Equipment equipment;
  final Function(Equipment) onSave;
  final Function() onDelete;
  final Function(Appliance) onReset;
  final List<String> availableRooms;

  const EquipmentDetailBottomSheet({
    super.key,
    required this.equipment,
    required this.onSave,
    required this.onDelete,
    required this.onReset,
    required this.availableRooms,
  });

  @override
  _EquipmentDetailBottomSheetState createState() => _EquipmentDetailBottomSheetState();
}

class _EquipmentDetailBottomSheetState extends State<EquipmentDetailBottomSheet> {
  late TextEditingController _consumptionPerHourController;
  late TextEditingController _hoursPerDayController;
  late TextEditingController _daysPerWeekController;
  late String _selectedRoom;
  double? _kwhPrice;

  final _formKey = GlobalKey<FormState>();

  Appliance? get defaultAppliance {
    return Appliance.predefinedAppliances.firstWhere(
      (appliance) => appliance.name == widget.equipment.name,
      orElse: () => Appliance(
        id: 0,
        name: widget.equipment.name,
        icon: Icons.cloud,
        consumptionPerHour: widget.equipment.consumptionPerHour,
        usageHoursPerDay: widget.equipment.usageHoursPerDay,
        usageDaysPerWeek: widget.equipment.usageDaysPerWeek,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _consumptionPerHourController = TextEditingController(
      text: widget.equipment.consumptionPerHour.toStringAsFixed(2)
    );
    _hoursPerDayController = TextEditingController(
      text: widget.equipment.usageHoursPerDay.toStringAsFixed(1)
    );
    _daysPerWeekController = TextEditingController(
      text: widget.equipment.usageDaysPerWeek.toString()
    );
    _selectedRoom = widget.equipment.roomName;
    _loadKwhPrice();
  }

  Future<void> _loadKwhPrice() async {
    final price = await Equipment.getKwhPrice();
    setState(() {
      _kwhPrice = price;
    });
  }

  @override
  void dispose() {
    _consumptionPerHourController.dispose();
    _hoursPerDayController.dispose();
    _daysPerWeekController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedEquipment = widget.equipment.withCustomValues(
        customConsumptionPerHour: double.parse(_consumptionPerHourController.text),
        customUsageHoursPerDay: double.parse(_hoursPerDayController.text),
        customUsageDaysPerWeek: int.parse(_daysPerWeekController.text),
      );
      
      if (_selectedRoom != widget.equipment.roomName) {
        final equipmentWithNewRoom = updatedEquipment.copyWith(roomName: _selectedRoom);
        widget.onSave(equipmentWithNewRoom);
      } else {
        widget.onSave(updatedEquipment);
      }
    }
  }

  void _resetToDefault() {
    if (defaultAppliance != null) {
      widget.onReset(defaultAppliance!);
    }
  }

  Widget _buildResultItem(String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF405F90),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.equipment.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF264777),
                  ),
                ),
                IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete, color: Color(0xFFFC0001)),
                  tooltip: 'Supprimer l\'appareil',
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CHANGER DE PIÈCE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF405F90),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF405F90),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF405F90).withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFF405F90),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Pièce actuelle :',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF405F90),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedRoom,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedRoom = newValue;
                                  });
                                }
                              },
                              items: widget.availableRooms.map<DropdownMenuItem<String>>((String room) {
                                return DropdownMenuItem<String>(
                                  value: room,
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 8),
                                      Text(
                                        room,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF003063),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFF405F90),
                                size: 24,
                              ),
                              isExpanded: true,
                              dropdownColor: Colors.white,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF003063),
                                fontWeight: FontWeight.w500,
                              ),
                              selectedItemBuilder: (BuildContext context) {
                                return widget.availableRooms.map<Widget>((String room) {
                                  return Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      room,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF003063),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD6E3FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            Container(
              margin: const EdgeInsets.only(top: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD6E3FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF405F90)),
              ),
              child: Column(
                children: [
                  const Text(
                    'CONSOMMATION MENSUELLE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF264777),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildResultItem(
                        '${widget.equipment.monthlyConsumptionKwh.toStringAsFixed(1)} kWh',
                        Icons.bolt,
                        const Color(0xFF003063),
                      ),
                      _buildResultItem(
                        _kwhPrice != null
                            ? '${widget.equipment.monthlyCostWithPrice(_kwhPrice!).toStringAsFixed(1)} €'
                            : '... €',                        Icons.euro,
                        const Color(0xFF72BA00),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'PARAMÉTRAGE DES VALEURS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF264777),
              ),
            ),
            const SizedBox(height: 16),
            
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _consumptionPerHourController,
                    decoration: const InputDecoration(
                      labelText: 'Consommation (kWh par heure)',
                      labelStyle: TextStyle(color: Color(0xFF405F90)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF405F90)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF405F90)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF264777), width: 2),
                      ),
                      helperText: '(Ex: 1.5 pour 1500W par heure d\'utilisation)',
                      helperStyle: TextStyle(color: Color(0xFF405F90)),
                      prefixIcon: Icon(Icons.bolt, color: Color(0xFF405F90)),
                    ),
                    style: const TextStyle(color: Color(0xFF003063)),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une valeur';
                      }
                      final numValue = double.tryParse(value);
                      if (numValue == null || numValue < 0) {
                        return 'Valeur invalide';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _hoursPerDayController,
                          decoration: const InputDecoration(
                            labelText: 'Heures d\'utilisation/jour',
                            labelStyle: TextStyle(color: Color(0xFF405F90)),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF405F90)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF405F90)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF264777), width: 2),
                            ),
                            helperText: '(Ex: 2.5 pour 2h30)',
                            helperStyle: TextStyle(color: Color(0xFF405F90)),
                            prefixIcon: Icon(Icons.schedule, color: Color(0xFF405F90)),
                          ),
                          style: const TextStyle(color: Color(0xFF003063)),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer une valeur';
                            }
                            final numValue = double.tryParse(value);
                            if (numValue == null || numValue < 0 || numValue > 24) {
                              return 'Entre 0 et 24 heures';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _daysPerWeekController,
                          decoration: const InputDecoration(
                            labelText: 'Jours d\'utilisation/semaine',
                            labelStyle: TextStyle(color: Color(0xFF405F90)),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF405F90)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF405F90)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF264777), width: 2),
                            ),
                            helperText: '(Ex: 5 pour 5 jours)',
                            helperStyle: TextStyle(color: Color(0xFF405F90)),
                            prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF405F90)),
                          ),
                          style: const TextStyle(color: Color(0xFF003063)),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer une valeur';
                            }
                            final numValue = int.tryParse(value);
                            if (numValue == null || numValue < 0 || numValue > 7) {
                              return 'Entre 0 et 7 jours';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _resetToDefault,
                    icon: const Icon(Icons.restore, color: Color(0xFF405F90)),
                    label: const Text(
                      'Réinitialiser',
                      style: TextStyle(color: Color(0xFF405F90)),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 50),
                      side: const BorderSide(color: Color(0xFF405F90)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.save),
                    label: const Text('Enregistrer'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 50),
                      backgroundColor: const Color(0xFF405F90),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}