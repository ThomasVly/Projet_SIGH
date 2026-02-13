import 'package:flutter/material.dart';
import '../models/room.dart';
import '../models/equipment.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final List<Equipment> equipments;
  final VoidCallback onEdit;
  final VoidCallback onAddEquipment;
  final VoidCallback onDelete;
  final void Function(Equipment equipment) onEquipmentTap;
  final bool Function(Equipment equipment) isTopConsumingEquipment;

  const RoomCard({
    super.key,
    required this.room,
    required this.equipments,
    required this.onEdit,
    required this.onAddEquipment,
    required this.onDelete,
    required this.onEquipmentTap,
    required this.isTopConsumingEquipment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${room.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                Row(
                  children: [
                    // Bouton crayon pour modifier
                    IconButton(
                      onPressed: onEdit,
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF003366),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Modifier la pièce',
                    ),
                    const SizedBox(width: 4),
                    // Bouton "+" pour ajouter une pièce
                    IconButton(
                      onPressed: onAddEquipment,
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF003366),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    // Bouton poubelle pour supprimer
                    IconButton(
                      onPressed: onDelete,
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF003366),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.delete,
                          size: 18,
                          color: Color(0xFFFF4C4C),
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Supprimer la pièce',
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            const Divider(
              height: 1,
              color: Color(0xFFE0E0E0),
            ),
            
            const SizedBox(height: 12),
            
            // Liste des équipements
            if (equipments.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Aucun équipement',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: equipments.map((equipment) {
                  return _buildEquipmentSquare(equipment);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentSquare(Equipment equipment) {
    final isTopConsuming = isTopConsumingEquipment(equipment);
    
    return InkWell(
      onTap: () => onEquipmentTap(equipment),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          // Rectangle en orange pour les top consommateurs
          border: Border.all(
            color: isTopConsuming 
                ? const Color(0xFFFF8C00) // Orange
                : const Color(0xFFE0E0E0), // Gris par défaut
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône en orange pour les top consommateurs
            Icon(
              equipment.icon ?? Icons.device_unknown,
              size: 32,
              color: isTopConsuming 
                  ? const Color(0xFFFF8C00) // Orange
                  : const Color(0xFF003366), // Bleu par défaut
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                equipment.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isTopConsuming 
                      ? const Color(0xFF333333) // Texte normal
                      : const Color(0xFF333333),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}