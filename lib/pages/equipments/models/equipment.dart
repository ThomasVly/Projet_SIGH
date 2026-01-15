import 'package:flutter/material.dart';

import 'appliance.dart';

class Equipment {
  final int? id;
  final String name;
  final String roomName;
  final double consumptionPerHour;
  final double usageHoursPerDay;
  final int usageDaysPerWeek;
  final double pricePerKwh;
  final IconData? icon;
  final DateTime createdAt;
  
  bool get hasCustomValues => _hasCustomValues;
  bool _hasCustomValues = false;

  Equipment({
    this.id,
    required this.name,
    required this.roomName,
    required this.consumptionPerHour,
    required this.usageHoursPerDay,
    required this.usageDaysPerWeek,
    required this.pricePerKwh,
    this.icon,
    DateTime? createdAt,
    bool hasCustomValues = false,
  })  : _hasCustomValues = hasCustomValues,
        createdAt = createdAt ?? DateTime.now();

  double get monthlyConsumptionKwh {
    return consumptionPerHour * usageHoursPerDay * usageDaysPerWeek * 4.33;
  }

  double get monthlyCost {
    return monthlyConsumptionKwh * pricePerKwh;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'room_name': roomName,
      'consumption_per_hour': consumptionPerHour,
      'usage_hours_per_day': usageHoursPerDay,
      'usage_days_per_week': usageDaysPerWeek,
      'price_per_kwh': pricePerKwh,
      'icon_code_point': icon?.codePoint,
      'icon_font_family': icon?.fontFamily,
      'icon_font_package': icon?.fontPackage,
      'has_custom_values': _hasCustomValues ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Equipment.fromMap(Map<String, dynamic> map) {
    IconData? iconData;
    final codePoint = map['icon_code_point'];
    final fontFamily = map['icon_font_family'];
    final fontPackage = map['icon_font_package'];
    
    if (codePoint != null && fontFamily != null) {
      iconData = IconData(
        codePoint,
        fontFamily: fontFamily,
        fontPackage: fontPackage,
      );
    }

    return Equipment(
      id: map['id'],
      name: map['name'],
      roomName: map['room_name'],
      consumptionPerHour: map['consumption_per_hour']?.toDouble() ?? 0.0,
      usageHoursPerDay: map['usage_hours_per_day']?.toDouble() ?? 1.0,
      usageDaysPerWeek: map['usage_days_per_week']?.toInt() ?? 7,
      pricePerKwh: map['price_per_kwh']?.toDouble() ?? Appliance.defaultPricePerKwh,
      icon: iconData,
      createdAt: DateTime.parse(map['created_at']),
      hasCustomValues: map['has_custom_values'] == 1,
    );
  }

  Equipment copyWith({
    int? id,
    String? name,
    String? roomName,
    double? consumptionPerHour,
    double? usageHoursPerDay,
    int? usageDaysPerWeek,
    double? pricePerKwh,
    IconData? icon,
    bool? hasCustomValues,
    DateTime? createdAt,
  }) {
    return Equipment(
      id: id ?? this.id,
      name: name ?? this.name,
      roomName: roomName ?? this.roomName,
      consumptionPerHour: consumptionPerHour ?? this.consumptionPerHour,
      usageHoursPerDay: usageHoursPerDay ?? this.usageHoursPerDay,
      usageDaysPerWeek: usageDaysPerWeek ?? this.usageDaysPerWeek,
      pricePerKwh: pricePerKwh ?? this.pricePerKwh,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      hasCustomValues: hasCustomValues ?? _hasCustomValues,
    );
  }

  Equipment withCustomValues({
    double? customConsumptionPerHour,
    double? customUsageHoursPerDay,
    int? customUsageDaysPerWeek,
  }) {
    return copyWith(
      consumptionPerHour: customConsumptionPerHour ?? consumptionPerHour,
      usageHoursPerDay: customUsageHoursPerDay ?? usageHoursPerDay,
      usageDaysPerWeek: customUsageDaysPerWeek ?? usageDaysPerWeek,
      hasCustomValues: true,
    );
  }

  Equipment resetToDefault(Appliance defaultAppliance) {
    return copyWith(
      consumptionPerHour: defaultAppliance.consumptionPerHour,
      usageHoursPerDay: defaultAppliance.usageHoursPerDay,
      usageDaysPerWeek: defaultAppliance.usageDaysPerWeek,
      icon: defaultAppliance.icon,
      hasCustomValues: false,
    );
  }
}