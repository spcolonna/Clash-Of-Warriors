// lib/domain/config/ring_events.dart
//
// Eventos de ring: modificadores ambientales que se activan cada N rondas y
// duran una ronda. Autocontenidos — el motor de combate aplica su regla al
// resolver, sin reescribir el core. No aparecen en tutorial.

import 'dart:math';
import 'package:flutter/material.dart';

enum RingEventRule {
  kicksMayFail,      // patadas 20% de fallar (sin efecto ese slot)
  dodgesMayFail,     // esquives 25% de fallar
  punchPriority,     // Puño gana los empates de mismo tipo
  weakDefenses,      // defensas mitigan menos (absorben −15%)
  doubleCardEffects, // los efectos de carta se duplican
}

class RingEvent {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final RingEventRule rule;

  const RingEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.rule,
  });
}

class RingEvents {
  static const List<RingEvent> all = [
    RingEvent(
      id: 'loose_ropes',
      name: 'Cuerdas Flojas',
      description: 'Las patadas pueden fallar (20%).',
      icon: Icons.waves,
      rule: RingEventRule.kicksMayFail,
    ),
    RingEvent(
      id: 'blinding_light',
      name: 'Luz Cegadora',
      description: 'Los esquives pueden fallar (25%).',
      icon: Icons.flare,
      rule: RingEventRule.dodgesMayFail,
    ),
    RingEvent(
      id: 'roaring_crowd',
      name: 'Público Enfervorizado',
      description: 'El Puño gana los empates de tipo.',
      icon: Icons.campaign,
      rule: RingEventRule.punchPriority,
    ),
    RingEvent(
      id: 'bottle_rain',
      name: 'Lluvia de Botellas',
      description: 'Las defensas absorben menos.',
      icon: Icons.umbrella,
      rule: RingEventRule.weakDefenses,
    ),
    RingEvent(
      id: 'distracted_ref',
      name: 'Árbitro Distraído',
      description: 'Los efectos de carta se duplican.',
      icon: Icons.sports,
      rule: RingEventRule.doubleCardEffects,
    ),
  ];

  static RingEvent? byId(String? id) {
    if (id == null) return null;
    for (final e in all) {
      if (e.id == id) return e;
    }
    return null;
  }

  static RingEvent random([Random? rng]) {
    final r = rng ?? Random();
    return all[r.nextInt(all.length)];
  }
}
