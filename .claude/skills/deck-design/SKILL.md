---
name: deck-design
description: Diseñar el mazo de 10 cartas de una facción de Clash of Warriors — balance, dirección de arte y seed del admin. Usar cuando el usuario pida armar/diseñar las cartas o el mazo de una facción o héroe (shaolin, ninja, judoka, boxer, capoeira).
---

# Diseño de mazo de facción (Clash of Warriors)

Workflow repetible para crear el mazo de 10 cartas de una facción. Ya hechos: Shaolin (Puo Liu), Ninja (Kage), Judoka (Ryoto). Faltan: Boxer (Kai), Capoeira (Mila). Verificá stats y cartas existentes antes de empezar (no colisionar ids).

## 1. Identidad desde los stats del héroe
Leé `lib/infra/local/heroes_data.dart` (stats punch/kick/grapple/defense/dodge, maxHp, maxStamina) y `factionEnemies` en `hero_entity.dart` (rival = −20%). Definí las 2 categorías firma (los stats más altos) y el arquetipo de efecto: shaolin=heal, ninja/judoka=drain, boxer/capoeira=boost.

## 2. Composición de las 10 cartas (patrón fijo)
**4 cartas firma + 3 defensa + 1 de cada categoría restante** (cubre las 5 categorías para viabilidad en el RPSLS). Tiers de balance (mismos que Shaolin/Ninja/Judoka):

| tier | costo | daño | extra | tienda |
|---|---|---|---|---|
| common firma | 1 | 14-16 | — | 150 |
| common utilidad | 2 | 12 | +2 stamina o drain | 250 |
| common defensa | 1 | 14 | — | 200 |
| rare firma | 3 | 30 | bonus: wonPreviousSlot | 400 |
| rare cobertura | 2 | 28 | — | 400 |
| rare efecto | 2 | 18-22 | efecto (drain/heal/boost) 2 | 350-400 |
| epic firma | 4 | 42 | — | 750 |
| epic efecto | 3 | 18 | efecto 3 | 700 |
| legendary firma | 5 | 48 | bonus: lowHp (comeback) | 1200 |

Anclaje: daño efectivo = base × stat/10 × 1.3 escala × 1.2 afinidad. La legendaria firma debe rondar ~57-67 efectivo (≈90+ con comeback). Total colección ~4200-4800 monedas. Enums válidos: `ConditionalBonus` (wonPreviousSlot, opponentRested, playerAhead, lowHp); `CardEffect` (drainStamina, heal, staminaBoost, denyDefense, weaken, pierce).

## 3. Dirección de arte (para que el usuario genere las imágenes con IA)
- **Formato**: vertical 2:3, **700×1050 px**, fondo OPACO con escenario (sangra a los bordes, `BoxFit.cover`). Dejar el tercio inferior y las esquinas superiores relativamente limpios (ahí van nombre/lore/gemas). Pipeline: WebP 100-180KB al subir por el admin.
- **Estilo**: pintura digital TCG (Hearthstone/LoR).
- **Paleta**: energía/chi en el `factionColor` oficial (`lib/delivery/theme/app_theme.dart`); sujeto vs fondo con contraste térmico (sujeto cálido/fondo frío o viceversa) para legibilidad.
- **Sujeto**: el héroe según `assets/images/heros/<faccion>_common.png`, dirección de luz constante.
- **Escalado por rareza**: common = sin energía; rare = aura/estela + partículas; epic = efecto fuerte envolviendo; legendary = energía plena + onda/dramatismo máximo.
- Escribir 1 párrafo por carta: pose, efecto, fondo, nota de rareza.

## 4. Convención de nombres
Cada imagen = el `cardId` exacto (ej. `judoka_hip_throw`). Al subirla desde el admin se guarda sola en `cards/{cardId}.webp` y setea el `imageUrl`.

## 5. Seed del admin
`admin-web/src/pages/ImportCardsPage.tsx`: reemplazar la constante `TEMPLATE` por las 10 cartas (JSON: id, name, lore, category, rarity, staminaCost, baseDamage, opcionales conditionalBonus/effect/effectValue/staminaBonus, factionId, shopCost, `imageUrl:""`, `isEnabled:true`). Lores cortos y evocativos, terminando en la mecánica cuando aplica. Actualizar el texto del botón a "Cargar plantilla (mazo <Facción> — 10 cartas)". Las 10 cartas viven solo en Firestore vía import — NO se hardcodean en Dart.

## 6. (Opcional) Bundle premium
En `lib/infra/config/premium_shop_config.dart`, apuntar los `cardIds` del `bundle_<faccion>_rare` a 3 de las cartas nuevas para que el pack las muestre.

## Verificación
`cd admin-web && npm run build` (typecheck del template). Manual: importar → 10 cartas en Firestore → visibles en tienda/mazo con fallback por categoría hasta subir el arte.
