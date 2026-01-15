import 'package:flutter/material.dart';
import '../models/appliance.dart';

class ApplianceCard extends StatelessWidget {
  final Appliance appliance;
  final bool isSelected;
  final VoidCallback onTap;

  const ApplianceCard({
    super.key,
    required this.appliance,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? const Color(0xFFD6E3FF) : Colors.white,
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF264777) : const Color(0xFF405F90),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icône
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD6E3FF) : const Color(0xFF405F90),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Icon(
                    appliance.icon,
                    size: 24,
                    color: isSelected ? const Color(0xFF264777) : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appliance.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? const Color(0xFF264777) : const Color(0xFF003063),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.bolt, size: 12, color: const Color(0xFF405F90)),
                        const SizedBox(width: 4),
                        Text(
                          '${appliance.consumptionPerHour.toStringAsFixed(2)} kWh/h',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF405F90),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.schedule, size: 12, color: const Color(0xFF405F90)),
                        const SizedBox(width: 4),
                        Text(
                          '${appliance.usageHoursPerDay}h/j',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF405F90),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.schedule, size: 12, color: const Color(0xFF405F90)),
                        const SizedBox(height: 4),
                        Text(
                          ' ${appliance.usageDaysPerWeek}j/semaine',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF405F90),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Consommation mensuelle
              /*
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${appliance.monthlyConsumptionKwh.toStringAsFixed(1)} kWh/mois',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003063),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${appliance.monthlyCost.toStringAsFixed(1)} €/mois',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF72BA00),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${appliance.usageDaysPerWeek}j/semaine',
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFF405F90),
                    ),
                  ),
                ],
              ),
              */
              
              // Checkbox de sélection
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.check_circle,
                    color: const Color(0xFF264777),
                    size: 24,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}