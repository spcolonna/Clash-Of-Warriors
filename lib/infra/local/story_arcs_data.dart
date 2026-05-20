// lib/infra/local/story_arcs_data.dart
//
// Contenido narrativo de todos los arcos de historia.
// Los arcos common tienen contenido completo. Los arcos rare/epic/legendary
// son estructuralmente idénticos pero con dificultad escalada — su contenido
// narrativo puede reemplazarse desde Firestore via el admin web.

import '../../domain/entities/story_arc.dart';
import '../../domain/entities/battle_state.dart' show BotDifficulty, GameMode;

class StoryArcsData {
  static final List<StoryArc> _localArcs = [
    ..._puoLiuArcs,
    ..._kageArcs,
    ..._ryotoArcs,
    ..._kaiArcs,
    ..._milaArcs,
  ];

  // Cache de arcos cargados desde Firestore (sustituyen a los locales)
  static final Map<String, StoryArc> _remoteArcs = {};

  /// Reemplaza arcos locales con los recibidos desde Firestore.
  /// Llamado al startup desde GameConfigNotifier.
  static void applyRemoteArcs(List<Map<String, dynamic>> firestoreArcs) {
    for (final data in firestoreArcs) {
      final id = data['arcId'] as String? ?? '${data['heroId']}_${data['rarity']}';
      if (id.isNotEmpty) {
        _remoteArcs[id] = StoryArc.fromMap(id, data);
      }
    }
  }

  static StoryArc? findArc(String heroId, String rarity) {
    final id = '${heroId}_$rarity';
    return _remoteArcs[id] ?? _localArcs.where((a) => a.arcId == id).firstOrNull;
  }

  static List<StoryArc> get allArcs => _localArcs;
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

DialogueLine _line(String id, String name, String text, {bool left = true}) =>
    DialogueLine(speakerId: id, speakerName: name, text: text, speakerIsLeft: left);

DialogueLine _narrator(String text) =>
    DialogueLine(speakerId: 'narrator', speakerName: 'Narrador', text: text, speakerIsLeft: true);

StoryStage _dialogue(int index, String location, List<DialogueLine> lines) =>
    StoryStage.dialogue(stage: DialogueStage(stageIndex: index, locationName: location, lines: lines));

StoryStage _battle(int index, String botId, BotDifficulty diff, String briefing) =>
    StoryStage.battle(stage: BattleStage(
      stageIndex: index, botHeroId: botId, difficulty: diff,
      gameMode: GameMode.expert, briefingText: briefing,
    ));

/// Genera un arco con dificultad escalada para raridades superiores.
/// El contenido narrativo es idéntico al arco common (placeholder hasta que
/// el admin cargue contenido propio en Firestore).
StoryArc _scaledArc(StoryArc base, String rarity, String title, BotDifficulty minDiff) {
  final scaled = base.stages.map((s) {
    if (s.type == StageType.battle && s.battle != null) {
      final orig = s.battle!;
      final newDiff = _scaleDiff(orig.difficulty, minDiff);
      return StoryStage.battle(stage: BattleStage(
        stageIndex:  orig.stageIndex,
        botHeroId:   orig.botHeroId,
        difficulty:  newDiff,
        gameMode:    orig.gameMode,
        briefingText: orig.briefingText,
      ));
    }
    return s;
  }).toList();
  return StoryArc(heroId: base.heroId, rarity: rarity, title: title, stages: scaled);
}

BotDifficulty _scaleDiff(BotDifficulty orig, BotDifficulty min) {
  final order = [BotDifficulty.easy, BotDifficulty.normal, BotDifficulty.hard];
  final origIdx = order.indexOf(orig);
  final minIdx  = order.indexOf(min);
  return order[origIdx < minIdx ? minIdx : origIdx];
}

// ─────────────────────────────────────────────────────────────────────────────
// PUO LIU (SHAOLIN) — "El Descenso de la Montaña"
// ─────────────────────────────────────────────────────────────────────────────

final StoryArc _puoLiuCommon = StoryArc(
  heroId: 'puo_liu',
  rarity: 'common',
  title: 'El Descenso de la Montaña',
  stages: [
    _dialogue(0, 'La Montaña Sagrada', [
      _line('maestro_lin', 'Maestro Lin', 'Puo Liu, hoy bajas de la montaña. No como estudiante. Como representante del Templo.'),
      _line('puo_liu', 'Puo Liu', 'Maestro... ¿Estoy listo?', left: false),
      _line('maestro_lin', 'Maestro Lin', 'Nadie lo está. Pero el torneo no espera. Recuerda: la fuerza sin sabiduría es solo violencia.'),
      _line('puo_liu', 'Puo Liu', 'Entiendo, Maestro.', left: false),
      _line('maestro_lin', 'Maestro Lin', 'No entendés. Todavía no. Pero lo harás.'),
    ]),
    _battle(1, 'kai', BotDifficulty.easy,
        'Un pendenciero del barrio bajo te bloquea el paso. Tu primer combate en La Ciudadela.'),
    _dialogue(2, 'Las Calles de La Ciudadela', [
      _line('kage', 'Kage', '¿Así que el templo Shaolin manda a un chico?'),
      _line('puo_liu', 'Puo Liu', 'Manda a quien es necesario.', left: false),
      _line('kage', 'Kage', 'Tu maestro desapareció anoche. Qué conveniente, justo antes del torneo.'),
      _line('puo_liu', 'Puo Liu', '¿Qué sabés de eso?', left: false),
      _line('kage', 'Kage', 'Sé que alguien no quiere que el Templo compita. Y ese alguien no es del Clan.'),
      _line('puo_liu', 'Puo Liu', '¿Por qué me contás esto?', left: false),
      _line('kage', 'Kage', 'Porque los dos somos peones en el mismo tablero.'),
    ]),
    _battle(3, 'kage', BotDifficulty.normal,
        'Kage dice que está de tu lado, pero sus acciones hablan diferente. Demostrá que merecés su respeto.'),
    _dialogue(4, 'El Mercado Subterráneo', [
      _line('puo_liu', 'Puo Liu', 'Ryoto. Escuché que vos también buscás algo en las sombras de La Ciudadela.', left: false),
      _line('ryoto', 'Ryoto', 'Busco al responsable de lo que le pasó a mi sensei. Fue descalificado del torneo hace diez años. Sin razón válida.'),
      _line('puo_liu', 'Puo Liu', 'Mi maestro también desapareció. Alguien los tiene a ambos.', left: false),
      _line('ryoto', 'Ryoto', 'Entonces tenemos el mismo enemigo.'),
      _narrator('Los dos guerreros miraron hacia el corazón oscuro de La Ciudadela. El Gran Torneo se acercaba. Y alguien no quería que llegaran a él.'),
    ]),
    _battle(5, 'kage', BotDifficulty.hard,
        'El lugarteniente ninja. No va a dejar que sigas avanzando.'),
    _dialogue(6, 'El Edificio Abandonado', [
      _line('ryoto', 'Ryoto', 'Ganaste. Pero el lugarteniente escapó.'),
      _line('puo_liu', 'Puo Liu', '¿Quién lo financia? ¿Quién mueve estas piezas?', left: false),
      _line('ryoto', 'Ryoto', 'El Consejo Sombra. No son una facción. Son una red. Están en todas las facciones.'),
      _line('puo_liu', 'Puo Liu', 'Entonces cualquiera podría ser uno de ellos.', left: false),
      _line('ryoto', 'Ryoto', 'Tu maestro lo descubrió. Por eso lo silenciaron.'),
      _line('puo_liu', 'Puo Liu', 'Si llego al final del torneo y lo expongo ante todos...', left: false),
      _line('ryoto', 'Ryoto', 'No lo van a dejar llegar.'),
    ]),
    _battle(7, 'ryoto', BotDifficulty.hard,
        'Ryoto necesita probarte antes de confiar completamente en vos. La alianza se forja en el tatami.'),
    _dialogue(8, 'Antesala de la Arena', [
      _line('puo_liu', 'Puo Liu', 'Maestro Lin. Estás vivo.', left: false),
      _line('maestro_lin', 'Maestro Lin', 'Me tenían prisionero. Pero no pudieron callarme para siempre. Kage me encontró.'),
      _line('kage', 'Kage', 'Digamos que yo también tengo cuentas que saldar con el Consejo.', left: false),
      _line('maestro_lin', 'Maestro Lin', 'El que te espera al final no es un luchador cualquiera. Es el Arquitecto. Fundó el Consejo hace veinte años.'),
      _line('puo_liu', 'Puo Liu', '¿Usted lo conoce?', left: false),
      _line('maestro_lin', 'Maestro Lin', 'Lo conozco. Fui su maestro. Y fue mi mayor fracaso. Ahora es tu turno de corregirlo.'),
    ]),
    _battle(9, 'kage', BotDifficulty.hard,
        'El Arquitecto. El fundador del Consejo Sombra. Este combate decide el destino del Templo Shaolin y de La Ciudadela.'),
  ],
);

final _puoLiuArcs = [
  _puoLiuCommon,
  _scaledArc(_puoLiuCommon, 'rare',      'El Camino del Dragón I',       BotDifficulty.normal),
  _scaledArc(_puoLiuCommon, 'epic',      'El Camino del Dragón II',      BotDifficulty.hard),
  _scaledArc(_puoLiuCommon, 'legendary', 'El Camino del Dragón: Maestro', BotDifficulty.hard),
];

// ─────────────────────────────────────────────────────────────────────────────
// KAGE (NINJA) — "La Sombra Tiene Nombre"
// ─────────────────────────────────────────────────────────────────────────────

final StoryArc _kageCommon = StoryArc(
  heroId: 'kage',
  rarity: 'common',
  title: 'La Sombra Tiene Nombre',
  stages: [
    _dialogue(0, 'Los Tejados de La Ciudadela', [
      _line('maestro_clan', 'Maestro del Clan', 'El objetivo entra al torneo esta semana. Un luchador Shaolin. Viejo. Fácil.'),
      _line('kage', 'Kage', '¿Cuál es el crimen?', left: false),
      _line('maestro_clan', 'Maestro del Clan', 'Los que mandan no explican. Ni nosotros preguntamos.'),
      _line('kage', 'Kage', 'Entendido.', left: false),
      _narrator('Pero Kage sí preguntó. En silencio. Y lo que encontró cambió todo.'),
    ]),
    _battle(1, 'mila', BotDifficulty.easy,
        'Una capoeirista cruzó tu camino antes de que puedas investigar. Resolvé esto rápido.'),
    _dialogue(2, 'La Biblioteca del Templo', [
      _line('kage', 'Kage', 'El monje al que debo eliminar está investigando al Consejo Sombra.', left: false),
      _line('kage', 'Kage', 'Alguien dentro del Clan lo contrató para silenciarlo. Alguien que pertenece al Consejo.', left: false),
      _line('mila', 'Mila', '¿Hablás solo entre los tejados o tenés la costumbre de pensar en voz alta?'),
      _line('kage', 'Kage', 'Seguirme fue un error.', left: false),
      _line('mila', 'Mila', 'Quizás. O quizás soy la única que puede ayudarte a salir de este lío.'),
    ]),
    _battle(3, 'puo_liu', BotDifficulty.normal,
        'El monje Shaolin te confundió con un asesino. Tenés que detenerlo sin lastimarle.'),
    _dialogue(4, 'Las Catacumbas', [
      _line('kage', 'Kage', 'El Clan sabe que no cumplí la misión. Ya hay sicarios tras mis pasos.', left: false),
      _line('mila', 'Mila', 'Bienvenido a mi mundo. Llevo años siendo perseguida.'),
      _line('kage', 'Kage', '¿Por qué me ayudás? No me conocés.', left: false),
      _line('mila', 'Mila', 'Conozco el tipo de decisión que tomaste. Es la única que importa.'),
      _line('kage', 'Kage', 'El que me manda desde el Clan se llama El Arquitecto.', left: false),
      _line('mila', 'Mila', '¿El fundador del Consejo Sombra?'),
      _line('kage', 'Kage', 'Y alguien tiene que detenerlo. Hoy.', left: false),
    ]),
    _battle(5, 'ryoto', BotDifficulty.hard,
        'Un mercenario contratado por el Clan. Bloquea el único camino hacia el Arquitecto.'),
    _dialogue(6, 'El Puente Roto', [
      _line('kage', 'Kage', 'Lo que queda del Clan lo sé. Me entrenaron para esto.', left: false),
      _line('mila', 'Mila', '¿Y si dentro del torneo hay más del Consejo?'),
      _line('kage', 'Kage', 'Los hay. El torneo es su trampa perfecta. Todos los guerreros en un lugar, sin sospechar nada.', left: false),
      _line('mila', 'Mila', '¿Y el monje Shaolin?'),
      _line('kage', 'Kage', 'Está vivo. Lo mantengo vivo.', left: false),
      _line('mila', 'Mila', 'Eso tiene que contar para algo.'),
      _line('kage', 'Kage', 'Tiene que contar para todo.', left: false),
    ]),
    _battle(7, 'kai', BotDifficulty.hard,
        'Kai te confundió con un agente del Consejo. Un malentendido que se resuelve en el ring.'),
    _dialogue(8, 'El Corazón de la Arena', [
      _line('puo_liu', 'Puo Liu', 'Así que eras vos quien cuidaba a mi maestro.'),
      _line('kage', 'Kage', 'Guardalo entre nosotros.', left: false),
      _line('puo_liu', 'Puo Liu', 'El Arquitecto está esperando en la cima de la Arena. Sabe que venís.'),
      _line('kage', 'Kage', 'Bien. Que me espere.', left: false),
      _line('mila', 'Mila', 'Kage. Si no volvés...'),
      _line('kage', 'Kage', 'Siempre vuelvo. Soy una sombra. Las sombras no mueren.', left: false),
    ]),
    _battle(9, 'puo_liu', BotDifficulty.hard,
        'El Arquitecto. El cerebro detrás del Consejo Sombra. Este es el combate más importante de tu vida.'),
  ],
);

final _kageArcs = [
  _kageCommon,
  _scaledArc(_kageCommon, 'rare',      'La Sombra Profunda I',      BotDifficulty.normal),
  _scaledArc(_kageCommon, 'epic',      'La Sombra Profunda II',     BotDifficulty.hard),
  _scaledArc(_kageCommon, 'legendary', 'La Sombra Profunda: Maestro', BotDifficulty.hard),
];

// ─────────────────────────────────────────────────────────────────────────────
// RYOTO (JUDOKA) — "El Tatami de la Ciudad"
// ─────────────────────────────────────────────────────────────────────────────

final StoryArc _ryotoCommon = StoryArc(
  heroId: 'ryoto',
  rarity: 'common',
  title: 'El Tatami de la Ciudad',
  stages: [
    _dialogue(0, 'La Entrada a La Ciudadela', [
      _narrator('Diez años. El Sensei Hiroshi fue descalificado sin razón válida. Nadie hizo nada.'),
      _line('ryoto', 'Ryoto', 'El Gran Torneo me da una oportunidad. Gano el torneo, restauro el nombre del dojo.', left: false),
      _narrator('Nada era simple en La Ciudadela.'),
    ]),
    _battle(1, 'kai', BotDifficulty.easy,
        'Un boxeador ocupa ilegalmente el dojo de tu sensei. Primer paso para recuperar lo que es tuyo.'),
    _dialogue(2, 'La Sede de la Federación', [
      _line('oficial', 'Oficial', 'La inscripción del Dojo Mushin fue rechazada. Irregularidades administrativas.'),
      _line('ryoto', 'Ryoto', '¿Qué irregularidades? El dojo cumple todos los requisitos.', left: false),
      _line('oficial', 'Oficial', 'Eso no es de mi competencia.'),
      _line('ryoto', 'Ryoto', '¿De quién es?', left: false),
      _line('oficial', 'Oficial', 'Le sugiero que se retire antes de que esto se complique más.'),
      _line('ryoto', 'Ryoto', 'Ya está complicado. Desde hace diez años.', left: false),
    ]),
    _battle(3, 'mila', BotDifficulty.normal,
        'Un inspector corrupto mandó una guardiana capoeirista para intimidarte. No vas a detenerte acá.'),
    _dialogue(4, 'La Sala de Archivos', [
      _line('ryoto', 'Ryoto', 'Aquí está. El expediente de mi sensei. Manipulado. Las firmas no coinciden.', left: false),
      _line('kai', 'Kai', 'Eso es corrupción.'),
      _line('ryoto', 'Ryoto', '¿Kai? ¿Qué hacés acá?', left: false),
      _line('kai', 'Kai', 'Lo mismo que vos. Buscar evidencia. Al promotor del torneo también lo manipularon.'),
      _line('ryoto', 'Ryoto', '¿El promotor y la Federación trabajan juntos?', left: false),
      _line('kai', 'Kai', 'Para lo mismo. Alguien muy poderoso quiere controlar quién llega a la final.'),
      _line('ryoto', 'Ryoto', 'El Consejo Sombra.', left: false),
    ]),
    _battle(5, 'mila', BotDifficulty.hard,
        'La guardiana regresó con refuerzos. Esta vez no hay margen para errores.'),
    _dialogue(6, 'Los Pasillos de la Arena', [
      _line('kage', 'Kage', '¿Los dos con evidencia y sin saber qué hacer con ella? Qué amateur.'),
      _line('ryoto', 'Ryoto', 'El ninja.', left: false),
      _line('kage', 'Kage', 'Tengo el nombre del Arquitecto y su ubicación. Pero necesito que lleguen a la final.'),
      _line('ryoto', 'Ryoto', '¿Por qué?', left: false),
      _line('kage', 'Kage', 'Porque la final es el único momento en que baja la guardia. Nadie mira hacia arriba.'),
      _line('ryoto', 'Ryoto', '¿Qué hay arriba?', left: false),
      _line('kage', 'Kage', 'Él.'),
    ]),
    _battle(7, 'kage', BotDifficulty.hard,
        'Kage necesita saber que podés llegar hasta el final. Una prueba en el piso de la arena.'),
    _dialogue(8, 'El Tatami de los Campeones', [
      _line('sensei_hiroshi', 'Sensei Hiroshi', 'Ryoto. Viniste.'),
      _line('ryoto', 'Ryoto', 'Sensei. ¿Estás bien?', left: false),
      _line('sensei_hiroshi', 'Sensei Hiroshi', 'Estoy aquí. Eso es suficiente. ¿Sabés lo que te espera?'),
      _line('ryoto', 'Ryoto', 'El Arquitecto. El hombre que destruyó tu carrera.', left: false),
      _line('sensei_hiroshi', 'Sensei Hiroshi', 'Y las de otros doce maestros. Llevás diez años preparándote para esto.'),
      _line('ryoto', 'Ryoto', 'No fui perfecto.', left: false),
      _line('sensei_hiroshi', 'Sensei Hiroshi', 'Nadie lo es. Pero nunca dejaste de levantarte. Eso es el Judo.'),
    ]),
    _battle(9, 'puo_liu', BotDifficulty.hard,
        'El Arquitecto. El hombre que destruyó al Sensei Hiroshi. Hoy rendís cuentas en el tatami.'),
  ],
);

final _ryotoArcs = [
  _ryotoCommon,
  _scaledArc(_ryotoCommon, 'rare',      'Honor en el Tatami I',       BotDifficulty.normal),
  _scaledArc(_ryotoCommon, 'epic',      'Honor en el Tatami II',      BotDifficulty.hard),
  _scaledArc(_ryotoCommon, 'legendary', 'Honor en el Tatami: Maestro', BotDifficulty.hard),
];

// ─────────────────────────────────────────────────────────────────────────────
// KAI (BOXER) — "El Barrio Contra el Mundo"
// ─────────────────────────────────────────────────────────────────────────────

final StoryArc _kaiCommon = StoryArc(
  heroId: 'kai',
  rarity: 'common',
  title: 'El Barrio Contra el Mundo',
  stages: [
    _dialogue(0, 'El Gimnasio del Barrio Sur', [
      _line('entrenador', 'Entrenador', 'Kai. Llegó la notificación. Si no pagan en 30 días, el gimnasio se demuele.'),
      _line('kai', 'Kai', '¿Cuánto?', left: false),
      _line('entrenador', 'Entrenador', 'Más de lo que tenemos. Mucho más.'),
      _line('kai', 'Kai', 'El Gran Torneo tiene premio. Si llego a la final...', left: false),
      _line('entrenador', 'Entrenador', 'Los equipos del Barrio Sur nunca llegan a la final.'),
      _line('kai', 'Kai', 'Yo no soy un equipo.', left: false),
    ]),
    _battle(1, 'ryoto', BotDifficulty.easy,
        'Clasificatorio del torneo. El primer rival no te conoce. Todavía.'),
    _dialogue(2, 'La Oficina del Promotor', [
      _line('promotor', 'Promotor Vespa', 'Kai. Qué sorpresa llegar hasta acá. Tenés talento.'),
      _line('kai', 'Kai', 'Vine por el gimnasio.', left: false),
      _line('promotor', 'Promotor Vespa', 'Podrías tener un futuro en este negocio. Bajo mis condiciones.'),
      _line('kai', 'Kai', '¿Qué condiciones?', left: false),
      _line('promotor', 'Promotor Vespa', 'Llegás a la final. Perdés. Hacemos que parezca real. El gimnasio queda pagado.'),
      _line('kai', 'Kai', 'No.', left: false),
      _line('promotor', 'Promotor Vespa', 'Pensalo bien. La alternativa es peor.'),
    ]),
    _battle(3, 'puo_liu', BotDifficulty.normal,
        'El campeón del torneo fue enviado a intimidarte. Le vas a demostrar que no te van a parar.'),
    _dialogue(4, 'La Calle Trasera del Gimnasio', [
      _line('entrenador', 'Entrenador', 'Kai. Alguien me amenazó. Si seguís en el torneo...'),
      _line('kai', 'Kai', '¿Qué querés que haga?', left: false),
      _line('entrenador', 'Entrenador', 'Lo que debés hacer. Pero quiero que sepas el costo.'),
      _line('kai', 'Kai', 'El costo de no rendirse es más alto que el de rendirse. Pero es el único que vale la pena pagar.', left: false),
    ]),
    _battle(5, 'kage', BotDifficulty.hard,
        'Los matones del promotor. No van a detenerte. Nadie va a detenerte.'),
    _dialogue(6, 'Los Vestuarios de la Arena', [
      _line('ryoto', 'Ryoto', 'Vi lo que le hicieron a tu entrenador. Eso no tiene nada que ver con el deporte.'),
      _line('kai', 'Kai', 'Lo sé.', left: false),
      _line('ryoto', 'Ryoto', 'Tengo evidencia de la corrupción. Suficiente para exponer al promotor.'),
      _line('kai', 'Kai', 'Evidencia no alcanza si los jueces son parte del sistema.', left: false),
      _line('ryoto', 'Ryoto', 'Hay alguien por encima de los jueces. Si lo exponemos...'),
      _line('kai', 'Kai', 'Primero tengo que llegar. Un round a la vez.', left: false),
      _line('ryoto', 'Ryoto', 'Un round a la vez.'),
    ]),
    _battle(7, 'mila', BotDifficulty.hard,
        'Semifinal del torneo. Mila también está en su propio camino. Solo uno sigue.'),
    _dialogue(8, 'El Ring de la Final', [
      _line('mila', 'Mila', 'Kai. El promotor acaba de salir del edificio. Cuando terminés esto, ya no va a tener poder.'),
      _line('kai', 'Kai', '¿Cómo?', left: false),
      _line('mila', 'Mila', 'Kage se encargó. El Consejo Sombra cayó esta noche.'),
      _line('kai', 'Kai', '¿Y el que me espera en el ring?', left: false),
      _line('mila', 'Mila', 'El último de pie. El campeón que usaban para controlar el resultado.'),
      _line('kai', 'Kai', 'Entonces lo derroto en el ring. Justo. Como siempre debió haber sido.', left: false),
    ]),
    _battle(9, 'ryoto', BotDifficulty.hard,
        'La final del torneo. Sin trampas. Sin sobornos. Solo dos peleadores y la verdad del ring.'),
  ],
);

final _kaiArcs = [
  _kaiCommon,
  _scaledArc(_kaiCommon, 'rare',      'Barrio Sur I',      BotDifficulty.normal),
  _scaledArc(_kaiCommon, 'epic',      'Barrio Sur II',     BotDifficulty.hard),
  _scaledArc(_kaiCommon, 'legendary', 'Barrio Sur: Leyenda', BotDifficulty.hard),
];

// ─────────────────────────────────────────────────────────────────────────────
// MILA (CAPOEIRA) — "Danza en La Ciudadela"
// ─────────────────────────────────────────────────────────────────────────────

final StoryArc _milaCommon = StoryArc(
  heroId: 'mila',
  rarity: 'common',
  title: 'Danza en La Ciudadela',
  stages: [
    _dialogue(0, 'El Puerto de La Ciudadela', [
      _narrator('Lucas llevaba tres meses sin noticias. Llegó a La Ciudadela buscando trabajo y dejó de escribir.'),
      _line('mila', 'Mila', 'Si el Clan lo tiene, lo voy a encontrar. Y si no quiere volver, al menos necesito saber que está bien.', left: false),
    ]),
    _battle(1, 'kai', BotDifficulty.easy,
        'La pandilla que controla el puerto no deja pasar sin pelear. Primera parada en La Ciudadela.'),
    _dialogue(2, 'El Distrito Ninja', [
      _line('kage', 'Kage', 'No vas a encontrarlo solo caminando por los callejones.'),
      _line('mila', 'Mila', '¿Vos lo conocés?', left: false),
      _line('kage', 'Kage', 'Sé quién es. Lidera una célula del Clan en el sector este.'),
      _line('mila', 'Mila', '¿Voluntariamente?', left: false),
      _line('kage', 'Kage', 'Eso es lo que todavía no sé. Hay gente que llega al Clan por deuda. Hay otros porque no tienen otra opción.'),
      _line('mila', 'Mila', '¿Podés llevarme hasta él?', left: false),
      _line('kage', 'Kage', 'Puedo mostrarte el camino. El resto lo tenés que hacer vos.'),
    ]),
    _battle(3, 'kage', BotDifficulty.normal,
        'Los guardias del Clan no dejan pasar a nadie. Demostrá que el camino es tuyo.'),
    _dialogue(4, 'El Almacén del Sector Este', [
      _line('lucas', 'Lucas', 'Mila. ¿Qué hacés acá? Esto es peligroso.'),
      _line('mila', 'Mila', 'Vine por vos.', left: false),
      _line('lucas', 'Lucas', 'No podés estar acá. Si el Clan te ve conmigo...'),
      _line('mila', 'Mila', '¿Por qué seguís acá, Lucas? ¿Te obligaron?', left: false),
      _line('lucas', 'Lucas', 'Debo dinero. Mucho. Si me voy, lo pagan los que quedaron en casa.'),
      _line('mila', 'Mila', 'Entonces encontramos la forma de cancelar esa deuda.', left: false),
    ]),
    _battle(5, 'kage', BotDifficulty.hard,
        'El guardián del Clan tiene los documentos de deuda de Lucas. Si los recuperás, cambia todo.'),
    _dialogue(6, 'El Tejado sobre el Almacén', [
      _line('mila', 'Mila', 'El guardián cayó pero los documentos van a ser reemplazados.', left: false),
      _line('ryoto', 'Ryoto', 'El papel no alcanza. El Clan puede hacer copias.'),
      _line('mila', 'Mila', '¿Entonces qué?', left: false),
      _line('ryoto', 'Ryoto', 'El Arquitecto firma todas las deudas del Clan personalmente. Si cae él, caen todas.'),
      _line('mila', 'Mila', '¿Y eso es posible?', left: false),
      _line('ryoto', 'Ryoto', 'Esta noche, con suerte... sí.'),
    ]),
    _battle(7, 'ryoto', BotDifficulty.hard,
        'Para llegar al Arquitecto hay que pasar por el guardián de la arena. Ryoto te prueba una última vez.'),
    _dialogue(8, 'Frente al Maestro del Clan', [
      _line('lucas', 'Lucas', 'Mila. Me dijeron que te metiste en todo esto por mí. No valía la pena.'),
      _line('mila', 'Mila', 'Vos siempre vas a valer la pena.', left: false),
      _line('lucas', 'Lucas', 'El maestro está adentro. Es el que manejó mi deuda desde el principio.'),
      _line('puo_liu', 'Puo Liu', 'Estoy acá también. El Arquitecto está usando al Clan como escudo. Cuando lo enfrentés, vas a entender todo.'),
      _line('mila', 'Mila', 'Entiendo todo lo que necesito entender.', left: false),
    ]),
    _battle(9, 'puo_liu', BotDifficulty.hard,
        'El maestro del Clan. El que inventó la deuda de Lucas. La danza termina acá.'),
  ],
);

final _milaArcs = [
  _milaCommon,
  _scaledArc(_milaCommon, 'rare',      'La Danza Libre I',       BotDifficulty.normal),
  _scaledArc(_milaCommon, 'epic',      'La Danza Libre II',      BotDifficulty.hard),
  _scaledArc(_milaCommon, 'legendary', 'La Danza Libre: Leyenda', BotDifficulty.hard),
];
