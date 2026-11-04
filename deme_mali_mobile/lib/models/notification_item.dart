import 'package:flutter/material.dart';

import '../styles/couleurs.dart';

enum TypeNotification {
  donRecu,
  demandeValidee,
  demandeRefusee,
  objectifAtteint,
  distributionPrevue,
  distributionEffectuee,
  compteValide,
  systeme,
}

class NotificationItem {
  final String id;
  final TypeNotification type;
  final String titre;
  final String message;
  final DateTime date;
  final bool lu;
  final int? demandeId;
  final double? montant;
  final String? quantite;
  final String? nomOrganisation;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.titre,
    required this.message,
    required this.date,
    this.lu = false,
    this.demandeId,
    this.montant,
    this.quantite,
    this.nomOrganisation,
  });

  NotificationItem copyWith({
    String? id,
    TypeNotification? type,
    String? titre,
    String? message,
    DateTime? date,
    bool? lu,
    int? demandeId,
    double? montant,
    String? quantite,
    String? nomOrganisation,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      titre: titre ?? this.titre,
      message: message ?? this.message,
      date: date ?? this.date,
      lu: lu ?? this.lu,
      demandeId: demandeId ?? this.demandeId,
      montant: montant ?? this.montant,
      quantite: quantite ?? this.quantite,
      nomOrganisation: nomOrganisation ?? this.nomOrganisation,
    );
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final rawType = (json['type'] ?? json['typeNotification'] ?? '').toString().toUpperCase();
    TypeNotification typeEnum = TypeNotification.systeme;

    if (rawType.contains('DON') || rawType.contains('AFFECTATION')) {
      typeEnum = TypeNotification.donRecu;
    } else if (rawType.contains('VALID') && rawType.contains('DEMANDE')) {
      typeEnum = TypeNotification.demandeValidee;
    } else if (rawType.contains('REJET') || rawType.contains('REFUS')) {
      typeEnum = TypeNotification.demandeRefusee;
    } else if (rawType.contains('OBJECTIF') || rawType.contains('COMPLET')) {
      typeEnum = TypeNotification.objectifAtteint;
    } else if (rawType.contains('DISTRIB')) {
      typeEnum = TypeNotification.distributionEffectuee;
    } else if (rawType.contains('COMPTE') || rawType.contains('ORGANISATION')) {
      typeEnum = TypeNotification.compteValide;
    }

    DateTime parsedDate;
    try {
      final dateStr = json['timestamp'] ?? json['date'] ?? json['dateNotification'];
      parsedDate = dateStr != null ? DateTime.parse(dateStr.toString()) : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return NotificationItem(
      id: (json['id'] ?? UniqueKey().toString()).toString(),
      type: typeEnum,
      titre: (json['titre'] ?? 'Notification').toString(),
      message: (json['message'] ?? '').toString(),
      date: parsedDate,
      lu: json['lu'] == true,
      demandeId: (json['demandeId'] as num?)?.toInt(),
      montant: (json['montant'] as num?)?.toDouble(),
      quantite: json['quantite']?.toString(),
      nomOrganisation: json['nomOrganisation']?.toString(),
    );
  }

  IconData get icone {
    switch (type) {
      case TypeNotification.donRecu:
        return Icons.volunteer_activism_rounded;
      case TypeNotification.demandeValidee:
        return Icons.check_circle_rounded;
      case TypeNotification.demandeRefusee:
        return Icons.cancel_rounded;
      case TypeNotification.objectifAtteint:
        return Icons.emoji_events_rounded;
      case TypeNotification.distributionPrevue:
      case TypeNotification.distributionEffectuee:
        return Icons.local_shipping_rounded;
      case TypeNotification.compteValide:
        return Icons.verified_user_rounded;
      case TypeNotification.systeme:
        return Icons.notifications_rounded;
    }
  }

  Color get couleur {
    switch (type) {
      case TypeNotification.donRecu:
        return CouleursApp.vert;
      case TypeNotification.demandeValidee:
        return const Color(0xFF1E88E5);
      case TypeNotification.demandeRefusee:
        return const Color(0xFFE53935);
      case TypeNotification.objectifAtteint:
        return CouleursApp.jaune;
      case TypeNotification.distributionPrevue:
      case TypeNotification.distributionEffectuee:
        return const Color(0xFFFB8C00);
      case TypeNotification.compteValide:
        return CouleursApp.vert;
      case TypeNotification.systeme:
        return const Color(0xFF546E7A);
    }
  }

  String get dateFormatee {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'À l’instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24 && now.day == date.day) {
      final h = date.hour.toString().padLeft(2, '0');
      final m = date.minute.toString().padLeft(2, '0');
      return 'Aujourd’hui à $h:$m';
    } else if (difference.inDays < 2) {
      final h = date.hour.toString().padLeft(2, '0');
      final m = date.minute.toString().padLeft(2, '0');
      return 'Hier à $h:$m';
    } else {
      final j = date.day.toString().padLeft(2, '0');
      final m = date.month.toString().padLeft(2, '0');
      final a = date.year;
      return '$j/$m/$a';
    }
  }
}
