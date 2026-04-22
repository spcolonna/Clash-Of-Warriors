# ⚔️ Arena de Guerreros — Flutter Project

## Arquitectura

```
lib/
├── domain/                    ← LÓGICA PURA (sin dependencias externas)
│   ├── config/
│   │   └── game_config.dart   ← TODAS las variables de balance
│   ├── entities/
│   │   ├── technique.dart     ← 5 técnicas RPSLS, reglas, beat verbs
│   │   ├── hero.dart          ← 20 héroes con stats, moves, relaciones
│   │   └── player.dart        ← Perfil, BattleHero, ClashResult, Difficulty
│   ├── repositories/
│   │   └── player_repository.dart  ← Interface (implementa Firestore)
│   └── usecases/
│       └── combat_use_case.dart    ← Toda la lógica de combate 1v1 + 3v3
│
├── delivery/                  ← UI (Flutter widgets, screens)
│   ├── screens/
│   │   ├── home/              ← Menú principal
│   │   ├── battle/            ← Combate 1v1
│   │   ├── battle_3v3/        ← Combate 3v3 con animación secuencial
│   │   ├── heroes/            ← Selección de héroe
│   │   ├── story/             ← Modo Leyenda (20 capítulos)
│   │   ├── shop/              ← Tienda IAP + tokens
│   │   ├── ranking/           ← Leaderboard ELO
│   │   ├── settings/          ← Ajustes (idioma, sonido, PRO)
│   │   └── auth/              ← Login (email, Google, Apple, guest)
│   ├── widgets/               ← Componentes reutilizables
│   ├── state/                 ← Riverpod providers
│   └── theme/                 ← Colores, tipografía, estilos
│
├── infra/                     ← IMPLEMENTACIONES EXTERNAS
│   ├── firebase/
│   │   └── auth_service.dart  ← Firebase Auth
│   ├── local/
│   │   └── local_storage.dart ← SharedPreferences (offline)
│   ├── services/
│   │   ├── analytics_service.dart  ← Firebase Analytics
│   │   └── ad_service.dart         ← AdMob
│   └── sound/
│       └── sound_service.dart      ← audioplayers SFX
│
├── l10n/                      ← 4 idiomas (~400 keys cada uno)
│   ├── app_es.arb             ← Español (template base)
│   ├── app_en.arb             ← English
│   ├── app_pt.arb             ← Português
│   └── app_ja.arb             ← 日本語
│
└── assets/
    ├── images/heroes/         ← 20 sprites PNG (90×110px)
    └── sounds/                ← 15 SFX (ver SOUNDS_GUIDE.md)
```

## Config centralizada

**`game_config.dart`** contiene TODAS las variables tunables:
- HP, stats, daño en empate
- Rewards por dificultad, costos de héroes/cartas
- Frecuencia de ads, tokens por rewarded
- Precios de IAP, daily rewards
- Bot AI params, ELO multipliers
- Duración de animaciones

→ Cambiar un valor acá lo cambia en todo el juego.
→ Migrable a Firebase Remote Config sin tocar código.

## l10n

Usa `flutter_localizations` con ARB files.
Config en `l10n.yaml` → genera clase `S` automáticamente.

```dart
// Uso en código:
Text(S.of(context).battle_win)
Text(S.of(context).home_hello(playerName))
```

## Dependencias requeridas

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: any
  flutter_riverpod: ^2.x
  audioplayers: ^6.x
  shared_preferences: ^2.x
  # Firebase (cuando esté configurado):
  # firebase_core: ^3.x
  # firebase_auth: ^5.x
  # cloud_firestore: ^5.x
  # firebase_analytics: ^11.x
  # google_mobile_ads: ^5.x
  # in_app_purchase: ^3.x
  # google_sign_in: ^6.x
  # sign_in_with_apple: ^6.x
```

## Setup

1. `flutter create arena_de_guerreros --org com.spcolonna`
2. Copiar este directorio `lib/` al proyecto
3. Copiar `l10n/` y `l10n.yaml` a la raíz
4. Copiar `assets/` y agregar sprites + sounds
5. Agregar dependencias a `pubspec.yaml`
6. `flutter gen-l10n` para generar las traducciones
7. Configurar Firebase con `flutterfire configure`

## Archivos adicionales
- `LOGO_BRIEF.md` — Brief para diseño del logo
- `SOUNDS_GUIDE.md` — Guía de SFX con fuentes gratuitas
