import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart' show IconData;

/// Todos los íconos de la app en un solo lugar.
/// Para cambiar un ícono: solo tocar este archivo.
/// Nunca usar Icons.* ni PhosphorIcons.* directamente en los widgets.
class AppIcons {
  AppIcons._();

  // ─── NAVEGACIÓN ───────────────────────────────────────────────────────────
  static const IconData navDojo       = PhosphorIconsFill.house;
  static const IconData navTraining   = PhosphorIconsFill.barbell;
  static const IconData navTournament = PhosphorIconsFill.trophy;
  static const IconData navStudents   = PhosphorIconsFill.users;
  static const IconData navShop       = PhosphorIconsFill.storefront;
  static const IconData navMarket     = PhosphorIconsRegular.storefront;
  static const IconData navSettings   = PhosphorIconsRegular.gear;
  static const IconData navMessages   = PhosphorIconsRegular.bell;

  // ─── ACCIONES ─────────────────────────────────────────────────────────────
  static const IconData actionConfirm  = PhosphorIconsFill.checkCircle;
  static const IconData actionLock     = PhosphorIconsRegular.lock;
  static const IconData actionUnlock   = PhosphorIconsRegular.lockOpen;
  static const IconData actionEdit     = PhosphorIconsRegular.pencil;
  static const IconData actionDelete   = PhosphorIconsRegular.trash;
  static const IconData actionAdd      = PhosphorIconsRegular.plus;
  static const IconData actionBack     = PhosphorIconsRegular.caretLeft;
  static const IconData actionForward  = PhosphorIconsRegular.caretRight;
  static const IconData actionExpand   = PhosphorIconsRegular.caretDown;
  static const IconData actionCollapse = PhosphorIconsRegular.caretUp;
  static const IconData actionSearch   = PhosphorIconsRegular.magnifyingGlass;
  static const IconData actionSignOut  = PhosphorIconsRegular.signOut;
  static const IconData actionClose    = PhosphorIconsRegular.x;
  static const IconData actionHistory  = PhosphorIconsRegular.clockCounterClockwise;
  static const IconData actionTree     = PhosphorIconsRegular.treeStructure;

  // ─── ESTUDIANTES ──────────────────────────────────────────────────────────
  static const IconData student        = PhosphorIconsRegular.user;
  static const IconData studentFill    = PhosphorIconsFill.user;
  static const IconData studentGroup   = PhosphorIconsRegular.users;
  static const IconData studentBelt    = PhosphorIconsRegular.medal;
  static const IconData studentXP      = PhosphorIconsFill.star;
  static const IconData studentInjured = PhosphorIconsRegular.bandaids;
  static const IconData studentMedal = PhosphorIconsRegular.medal;

  // ─── DOJO ─────────────────────────────────────────────────────────────────
  static const IconData dojo           = PhosphorIconsFill.house;
  static const IconData dojoUpgrade    = PhosphorIconsRegular.wrench;
  static const IconData dojoSlot       = PhosphorIconsRegular.plusCircle;

  // ─── COMBATE ──────────────────────────────────────────────────────────────
  static const IconData fight          = PhosphorIconsFill.sword;
  static const IconData fightStrategy  = PhosphorIconsRegular.strategy;
  static const IconData fightWin       = PhosphorIconsFill.trophy;
  static const IconData fightLoss      = PhosphorIconsRegular.arrowDown;
  static const IconData fightStar      = PhosphorIconsFill.star;

  // ─── ESTRATEGIAS ──────────────────────────────────────────────────────────
  static const IconData strategyAggressive = PhosphorIconsFill.lightning;
  static const IconData strategyDefensive  = PhosphorIconsFill.shield;
  static const IconData strategyTechnical  = PhosphorIconsFill.target;
  static const IconData strategyGrappling  = PhosphorIconsRegular.arrowsDownUp;
  static const IconData strategyAdaptive   = PhosphorIconsFill.wind;

  // ─── ENTRENAMIENTO ────────────────────────────────────────────────────────
  static const IconData trainingStrength   = PhosphorIconsRegular.barbell;
  static const IconData trainingCardio     = PhosphorIconsRegular.sneaker;
  static const IconData trainingTechnique  = PhosphorIconsRegular.target;
  static const IconData trainingMind       = PhosphorIconsRegular.brain;
  static const IconData trainingCombat     = PhosphorIconsRegular.sword;
  static const IconData trainingRecovery   = PhosphorIconsRegular.heartbeat;

  // ─── ÁRBOL DE HABILIDADES ─────────────────────────────────────────────────
  static const IconData branchPower     = PhosphorIconsRegular.lightning;
  static const IconData branchAgility   = PhosphorIconsRegular.wind;
  static const IconData branchTechnique = PhosphorIconsRegular.target;
  static const IconData branchGuard     = PhosphorIconsRegular.shield;
  static const IconData branchMind      = PhosphorIconsRegular.brain;
  static const IconData nodeUnlocked    = PhosphorIconsFill.checkCircle;
  static const IconData nodeLocked      = PhosphorIconsRegular.lock;
  static const IconData nodeAvailable   = PhosphorIconsRegular.lockOpen;

  // ─── MONEDAS ──────────────────────────────────────────────────────────────
  static const IconData currencyMD  = PhosphorIconsFill.coin;
  static const IconData currencyGM  = PhosphorIconsFill.diamond;
  static const IconData currencyPH  = PhosphorIconsFill.star;
  static const IconData currencyRep = PhosphorIconsFill.medal;

  // ─── SETTINGS ─────────────────────────────────────────────────────────────
  static const IconData settingsSound    = PhosphorIconsRegular.speakerHigh;
  static const IconData settingsMusic    = PhosphorIconsRegular.musicNote;
  static const IconData settingsLanguage = PhosphorIconsRegular.translate;
  static const IconData settingsAccount  = PhosphorIconsRegular.user;

  // ─── ESTADOS ──────────────────────────────────────────────────────────────
  static const IconData statusSuccess = PhosphorIconsFill.checkCircle;
  static const IconData statusWarning = PhosphorIconsFill.warning;
  static const IconData statusError   = PhosphorIconsFill.xCircle;
  static const IconData statusInfo    = PhosphorIconsFill.info;
  static const IconData statusFatigue = PhosphorIconsRegular.flame;
  static const IconData statusFire     = PhosphorIconsRegular.flame;
  static const IconData statusHeal     = PhosphorIconsRegular.bandaids;
}