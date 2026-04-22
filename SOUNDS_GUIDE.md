# 🔊 Guía de Efectos de Sonido

## Archivos necesarios (assets/sounds/)

| Key | Archivo | Descripción | Duración |
|-----|---------|-------------|----------|
| punch | punch.mp3 | Golpe de puño seco | 0.3s |
| kick | kick.mp3 | Patada (swoosh + impacto) | 0.4s |
| block | block.mp3 | Bloqueo metálico/escudo | 0.3s |
| grapple | grapple.mp3 | Agarre/forcejeo rápido | 0.5s |
| palm | palm.mp3 | Palma abierta (whoosh suave) | 0.3s |
| hit | hit.mp3 | Impacto genérico | 0.2s |
| ko | ko.mp3 | KO dramático (impacto + caída) | 0.8s |
| victory | victory.mp3 | Fanfarria de victoria | 1.5s |
| defeat | defeat.mp3 | Sonido de derrota (grave) | 1.2s |
| round_start | round_start.mp3 | Campana/gong de inicio | 0.8s |
| select | select.mp3 | Click de selección | 0.1s |
| coin | coin.mp3 | Moneda/token obtenido | 0.3s |
| level_up | level_up.mp3 | Level up brillante | 1.0s |
| unlock | unlock.mp3 | Desbloqueo (candado) | 0.6s |
| menu_tap | menu_tap.mp3 | Tap de botón suave | 0.1s |

## Fuentes gratuitas (licencia comercial)

### 🥇 Recomendadas
1. **Kenney.nl** → https://kenney.nl/assets?q=audio
   - Packs: "Impact Sounds", "UI Audio", "RPG Audio"
   - Licencia: CC0 (dominio público, uso comercial sin atribución)
   - ⭐ Mejor opción para punch/kick/block/hit

2. **OpenGameArt.org** → https://opengameart.org/art-search-advanced?keys=&field_art_type_tid%5B%5D=13
   - Buscar: "fighting sfx", "combat sounds", "punch kick"
   - Verificar licencia por cada asset (CC0 o CC-BY)

3. **Freesound.org** → https://freesound.org
   - Filtrar por licencia CC0
   - Buscar: "punch impact", "kick swoosh", "shield block", "victory fanfare"
   - Requiere cuenta gratuita para descargar

### 🥈 Alternativas
4. **Zapsplat.com** → https://www.zapsplat.com
   - Gratis con atribución, o $4/mes sin atribución
   - Muy buena calidad de SFX de combate

5. **Mixkit.co** → https://mixkit.co/free-sound-effects/
   - Gratis para uso comercial
   - Categoría "Game" tiene buenos SFX

## Formato recomendado
- **MP3** a 128kbps (suficiente para SFX mobile)
- Mono, no estéreo (ahorra espacio)
- Normalizar volumen a -3dB
- Recortar silencios al inicio/final

## Herramientas de edición
- **Audacity** (gratis): recortar, normalizar, exportar
- **ffmpeg**: `ffmpeg -i input.wav -ac 1 -ab 128k output.mp3`
