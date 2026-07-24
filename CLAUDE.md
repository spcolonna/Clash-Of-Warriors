# Clash of Warriors

Juego de cartas de lucha en Flutter (`arena_project/`) + panel admin React (`../admin-web/`). Firebase (Firestore + Storage).

- Prioridad de producto: game feel — haptics, SFX y animaciones pesan tanto como la lógica.
- Lógica de juego en `lib/`. Nunca leas ni explores `build/` ni `.dart_tool/`.
- Tras cambios Dart: `flutter analyze` (sin errores) + `flutter test`. En admin-web: `npm run build`.

## Contexto que no está en el código (evita re-derivarlo = ahorra tokens)
- Las cartas de mazo viven en Firestore (`gameData/cards/items`), NO hardcodeadas; `CardCatalog` mezcla remoto + local; se importan desde el admin.
- Motor de combate: RPSLS de 5 categorías en `lib/domain/usecases/resolve_combat_use_case.dart` (funciones puras → testeable sin UI).
