// lib/infra/local/story/arcs_ryoto.dart
//
// RYOTO (JUDOKA) — Serie "Honor en el Tatami" en 4 actos.
// Acto I: el Gran Torneo (el expediente). Acto II: la Inspectora corrupta.
// Acto III: el soborno perfecto. Acto IV: el Asedio — el frente institucional.

import '../../../domain/entities/battle_state.dart' show BotDifficulty;
import '../../../domain/entities/story_arc.dart';
import 'story_helpers.dart';

final List<StoryArc> ryotoArcs = [
  _actoI,
  _actoII,
  _actoIII,
  _actoIV,
];

// ─── ACTO I (common) — El Tatami de la Ciudad ────────────────────────────────

final StoryArc _actoI = StoryArc(
  heroId: 'ryoto',
  rarity: 'common',
  title: 'El Tatami de la Ciudad',
  coverSubtitle: 'El Gran Torneo — la misma semana, cinco caminos',
  synopsis:
      'Hace diez años, el Sensei Hiroshi fue descalificado sin razón válida y '
      'el Dojo Mushin perdió su nombre. Ryoto entra al Gran Torneo con un '
      'objetivo: ganar, restaurar el honor del dojo... y descubrir quién '
      'firmó la mentira.',
  stages: [
    dialogue(0, 'La Entrada a La Ciudadela', locationId: 'ciudadela_calles', [
      narrator(
          'Diez años. El Sensei Hiroshi fue descalificado sin razón válida. Nadie hizo nada.'),
      line('ryoto', 'Ryoto',
          'El Gran Torneo me da una oportunidad. Gano el torneo, restauro el nombre del dojo.',
          left: false, emotion: 'determined'),
      narrator('Nada era simple en La Ciudadela.'),
    ]),
    battle(1, 'kai', BotDifficulty.easy,
        'Un boxeador ocupa ilegalmente el dojo de tu sensei. Primer paso para recuperar lo que es tuyo.',
        locationId: 'dojo'),
    dialogue(2, 'La Sede de la Federación', locationId: 'ciudadela_calles', [
      line('oficial', 'Oficial',
          'La inscripción del Dojo Mushin fue rechazada. Irregularidades administrativas.'),
      line('ryoto', 'Ryoto',
          '¿Qué irregularidades? El dojo cumple todos los requisitos.',
          left: false, emotion: 'angry'),
      line('oficial', 'Oficial', 'Eso no es de mi competencia.'),
      line('ryoto', 'Ryoto', '¿De quién es?', left: false),
      line('oficial', 'Oficial',
          'Le sugiero que se retire antes de que esto se complique más.'),
      line('ryoto', 'Ryoto', 'Ya está complicado. Desde hace diez años.',
          left: false),
      narrator(
          'La Guardiana de la Federación le bloqueó la entrada al archivo. Sin '
          'autorización firmada, ningún judoka pasa de ese pasillo.'),
    ]),
    battle(3, 'mila', BotDifficulty.normal,
        'Un inspector corrupto mandó una guardiana capoeirista para intimidarte. No vas a detenerte acá.',
        bossName: 'Guardiana de la Federación', locationId: 'ciudadela_calles'),
    dialogue(4, 'La Sala de Archivos', locationId: 'catacumbas', [
      line('ryoto', 'Ryoto',
          'Acá está. El expediente de mi sensei. Manipulado. Las firmas no coinciden.',
          left: false, sfx: '¡!'),
      line('kai', 'Kai', 'Eso es corrupción.'),
      line('ryoto', 'Ryoto', '¿Kai? ¿Qué hacés acá?',
          left: false, emotion: 'shocked'),
      line('kai', 'Kai',
          'Lo mismo que vos. Buscar evidencia. Al promotor del torneo también lo manipularon.'),
      line('ryoto', 'Ryoto', '¿El promotor y la Federación trabajan juntos?',
          left: false),
      line('kai', 'Kai',
          'Para lo mismo. Alguien muy poderoso quiere controlar quién llega a la final.'),
      line('ryoto', 'Ryoto', 'El Consejo Sombra.', left: false),
      narrator(
          'La Guardiana de la Federación volvió, esta vez con la orden de que '
          'Ryoto no saliera con una sola hoja encima.'),
    ]),
    battle(5, 'mila', BotDifficulty.hard,
        'La guardiana regresó con refuerzos. Esta vez no hay margen para errores.',
        bossName: 'Guardiana de la Federación', locationId: 'ciudadela_calles'),
    dialogue(6, 'Los Pasillos de la Arena', locationId: 'arena', [
      line('kage', 'Kage',
          '¿Los dos con evidencia y sin saber qué hacer con ella? Qué amateur.',
          emotion: 'smirk'),
      line('ryoto', 'Ryoto', 'El ninja. El "mercenario" que me contrató el Clan para frenarlo... y que me ganó limpio.',
          left: false),
      line('kage', 'Kage',
          'Tengo el nombre del Arquitecto y su ubicación. Pero necesito que lleguen a la final.'),
      line('ryoto', 'Ryoto', '¿Por qué?', left: false),
      line('kage', 'Kage',
          'Porque la final es el único momento en que baja la guardia. Nadie mira hacia arriba.'),
      line('ryoto', 'Ryoto', '¿Qué hay arriba?', left: false),
      line('kage', 'Kage', 'Él.', bubble: BubbleType.whisper),
    ]),
    battle(7, 'kage', BotDifficulty.hard,
        'Kage necesita saber que podés llegar hasta el final. Una prueba en el piso de la arena.',
        locationId: 'arena'),
    dialogue(8, 'El Tatami de los Campeones', locationId: 'dojo', [
      line('sensei_hiroshi', 'Sensei Hiroshi', 'Ryoto. Viniste.'),
      line('ryoto', 'Ryoto', 'Sensei. ¿Estás bien?',
          left: false, emotion: 'shocked'),
      line('sensei_hiroshi', 'Sensei Hiroshi',
          'Estoy aquí. Eso es suficiente. ¿Sabés lo que te espera?'),
      line('ryoto', 'Ryoto',
          'El Arquitecto. El hombre que destruyó tu carrera.', left: false),
      line('sensei_hiroshi', 'Sensei Hiroshi',
          'Y las de otros doce maestros. Llevás diez años preparándote para esto.'),
      line('ryoto', 'Ryoto', 'No fui perfecto.', left: false, emotion: 'sad'),
      line('sensei_hiroshi', 'Sensei Hiroshi',
          'Nadie lo es. Pero nunca dejaste de levantarte. Eso es el Judo.'),
    ]),
    battle(9, 'puo_liu', BotDifficulty.hard,
        'El Arquitecto. El hombre que destruyó al Sensei Hiroshi. Hoy rendís cuentas en el tatami.',
        bossName: 'El Arquitecto', locationId: 'arena'),
  ],
);

// ─── ACTO II (rare) — El Expediente Kuro ─────────────────────────────────────

final StoryArc _actoII = StoryArc(
  heroId: 'ryoto',
  rarity: 'rare',
  title: 'El Expediente Kuro',
  coverSubtitle: 'Acto II — limpiar la casa',
  synopsis:
      'El Consejo cayó, pero sus firmas siguen en los archivos de la '
      'Federación. La Inspectora Kuro — la mano que manipuló el expediente '
      'del Sensei Hiroshi hace diez años — sigue en su despacho, borrando '
      'pruebas. Ryoto va a limpiar la casa. Tatami por tatami.',
  stages: [
    dialogue(0, 'El Dojo Mushin', locationId: 'dojo', [
      narrator(
          'El dojo reabrió sus puertas tras el torneo. Pero el nombre del Sensei seguía manchado en los registros oficiales.'),
      line('sensei_hiroshi', 'Sensei Hiroshi',
          'Ganaste el torneo, Ryoto. Para el mundo alcanza. Para los archivos, no: mi expediente sigue diciendo "tramposo".'),
      line('ryoto', 'Ryoto',
          '¿Quién firmó la manipulación original? El Arquitecto ordenaba... pero alguien ejecutaba.',
          left: false),
      line('sensei_hiroshi', 'Sensei Hiroshi',
          'La Inspectora Kuro. Y todavía sella documentos en el tercer piso de la Federación.'),
      line('ryoto', 'Ryoto', 'Entonces mañana pido una audiencia.',
          left: false, emotion: 'determined'),
      narrator(
          'La Seguridad de la Federación llegó al Dojo Mushin antes que la '
          'citación: venían a cerrarlo por "irregularidades" y a asegurarse de '
          'que nadie discutiera.'),
    ]),
    battle(1, 'kai_rare', BotDifficulty.normal,
        'La "seguridad privada" de la Federación no deja pasar a ex-campeones incómodos. Audiencia denegada. Entrada: ganada.',
        bossName: 'Seguridad de la Federación', locationId: 'ciudadela_calles'),
    dialogue(2, 'El Tercer Piso de la Federación', locationId: 'ciudadela_calles', [
      line('inspectora_kuro', 'Inspectora Kuro',
          'Ryoto del Dojo Mushin. El campeón del pueblo. ¿Viene a pedir un autógrafo?'),
      line('ryoto', 'Ryoto',
          'Vengo por una firma. La suya. En el expediente de mi sensei, hace diez años.',
          left: false),
      line('inspectora_kuro', 'Inspectora Kuro',
          'Los archivos de esa década se incineraron. Qué tragedia administrativa.',
          emotion: 'smirk'),
      line('ryoto', 'Ryoto',
          'Los originales sí. Pero usted guarda copias de todo. Es su seguro de vida contra el Consejo.',
          left: false),
      line('inspectora_kuro', 'Inspectora Kuro', '...¿Quién le dijo eso?',
          emotion: 'shocked', bubble: BubbleType.shout),
      narrator(
          'En el tercer piso lo interceptó la Escolta de Kuro: la inspectora no '
          'recibe a nadie que no haya sido revisado primero.'),
    ]),
    battle(3, 'mila_rare', BotDifficulty.normal,
        'La escolta personal de Kuro te "acompaña" a la salida. El Judo tiene otra idea de cortesía.',
        bossName: 'Escolta de Kuro', locationId: 'ciudadela_calles'),
    dialogue(4, 'El Café de los Jueces', locationId: 'ciudadela_calles', [
      line('kage', 'Kage',
          'Kuro tiene una bóveda personal en el sótano de la vieja aduana. Copias de cada favor que el Consejo compró.'),
      line('ryoto', 'Ryoto', '¿Y me lo decís gratis?', left: false),
      line('kage', 'Kage',
          'Digamos que estoy rompiendo contratos este mes. El tuyo es de los que me caen bien.',
          emotion: 'smirk'),
      line('ryoto', 'Ryoto',
          'Si esa bóveda existe, adentro está la absolución de doce maestros. No solo la de Hiroshi.',
          left: false, emotion: 'determined'),
      narrator(
          'El Custodio de la Aduana bebía en la mesa del fondo del café. Los '
          'papeles que Ryoto buscaba pasaban todos por sus manos, y él lo '
          'sabía.'),
    ]),
    battle(5, 'kage_rare', BotDifficulty.hard,
        'La vieja aduana está custodiada por sombras a sueldo de Kuro. El camino a la bóveda se gana.',
        bossName: 'Custodio de la Aduana', locationId: 'puerto'),
    dialogue(6, 'La Bóveda de la Aduana', locationId: 'catacumbas', [
      narrator(
          'Doce expedientes manipulados. Doce carreras destruidas. Todas con la misma firma elegante: Kuro.'),
      line('ryoto', 'Ryoto',
          'Sensei Takeda. Maestra Oyuki. El viejo Ferreira... los descalificó a todos. Una década de tatamis vaciados a pedido.',
          left: false),
      line('kai', 'Kai',
          '¿Doce maestros? Esto es más grande que tu dojo, Ryoto.'),
      line('ryoto', 'Ryoto',
          'Siempre lo fue. Por eso no alcanza con ganarle. Hay que juzgarla en su propio tribunal.',
          left: false),
      narrator(
          'En la bóveda de la Aduana ya había alguien contando: El Cobrador de '
          'Favores, el que ejecuta lo que la Dama firma.'),
    ]),
    battle(7, 'kai_rare', BotDifficulty.hard,
        'El matón favorito de Kuro llega tarde a la bóveda... pero justo a tiempo para vos.',
        bossName: 'El Cobrador de Favores', locationId: 'catacumbas'),
    dialogue(8, 'El Tribunal de la Federación', locationId: 'dojo', [
      narrator(
          'Ryoto presentó los doce expedientes ante el tribunal en pleno. Kuro exigió resolverlo "a la manera antigua": en el tatami.'),
      line('inspectora_kuro', 'Inspectora Kuro',
          'Cinturón negro, tercer dan, antes de dedicarme a los papeles. ¿Creíste que solo sabía firmar?'),
      line('ryoto', 'Ryoto',
          'Mejor. Que la Federación entera vea caer a su inspectora con las reglas que ella misma traicionó.',
          left: false, emotion: 'determined', sfx: '¡TATAKI!'),
    ]),
    battle(9, 'ryoto_rare', BotDifficulty.hard,
        'La Inspectora Kuro. Cinturón negro antes que burócrata. La firma detrás de doce carreras destruidas se defiende en el tatami.',
        bossName: 'Inspectora Kuro', locationId: 'dojo'),
  ],
);

// ─── ACTO III (epic) — El Soborno Perfecto ───────────────────────────────────

final StoryArc _actoIII = StoryArc(
  heroId: 'ryoto',
  rarity: 'epic',
  title: 'El Soborno Perfecto',
  coverSubtitle: 'Acto III — la silla del presidente',
  synopsis:
      'El "Nuevo Consejo" no compra jueces: compra presidencias. Y su '
      'oferta para Ryoto es perfecta — presidir la Federación que una vez lo '
      'expulsó. Todo hombre tiene un precio. El de Ryoto es descubrir quién '
      'paga... y hacerlo caer desde adentro.',
  stages: [
    dialogue(0, 'El Dojo Mushin', locationId: 'dojo', [
      line('tesorero', 'El Tesorero',
          'La nueva fundación admira su historia, señor Ryoto. Queremos proponerle presidir la Federación reformada.'),
      line('ryoto', 'Ryoto', '¿Y qué esperan a cambio?', left: false),
      line('tesorero', 'El Tesorero',
          'Nada. Solo su nombre. Su cara. Su... credibilidad.'),
      line('ryoto', 'Ryoto',
          'Mi credibilidad no está en venta. Pero decile a tu jefe que lo voy a pensar.',
          left: false, bubble: BubbleType.whisper),
      narrator(
          'Ryoto no iba a pensarlo. Iba a rastrear cada billete de esa fundación hasta su origen.'),
      narrator(
          'La Fundación mandó a un Sparring de la Fundación al Dojo Mushin. Le '
          'dijeron que era un entrenamiento; era una advertencia.'),
    ]),
    battle(1, 'kai_epic', BotDifficulty.hard,
        'Un "sparring de cortesía" organizado por la fundación. Miden tu obediencia. Medí su paciencia.',
        bossName: 'Sparring de la Fundación', locationId: 'dojo'),
    dialogue(2, 'El Gimnasio del Barrio Sur', locationId: 'barrio_sur', [
      line('kai', 'Kai',
          '¿A vos también? A mí me ofrecieron un contrato histórico. Cifras ridículas.'),
      line('ryoto', 'Ryoto',
          'A mí, la presidencia de la Federación. El Nuevo Consejo compra fachadas de gente honesta.',
          left: false),
      line('kai', 'Kai', '¿Y si les seguimos el juego?', emotion: 'smirk'),
      line('ryoto', 'Ryoto',
          'Exacto. Vos aceptá tu contrato. Yo sigo el dinero. Nos vemos en la cima... con las pruebas.',
          left: false, emotion: 'determined'),
      narrator(
          'La Contadora del Consejo lo estaba esperando en el gimnasio: la '
          'única que sabe de memoria a dónde fue cada peso, y a quién le '
          'conviene que siga en silencio.'),
    ]),
    battle(3, 'mila_epic', BotDifficulty.hard,
        'El Tesorero sospecha del rastreo. Su contadora de confianza pelea mejor de lo que suma.',
        bossName: 'La Contadora', locationId: 'ciudadela_calles'),
    dialogue(4, 'Los Libros de la Fundación', locationId: 'catacumbas', [
      narrator(
          'Tres noches de números. Y al final de cada columna, siempre el mismo pozo sin nombre.'),
      line('ryoto', 'Ryoto',
          'Los fondos entran por el puerto, giran por seis empresas y mueren en una cuenta sellada. Firmada con una inicial: A.',
          left: false),
      line('kage', 'Kage',
          'A de Arquitecto. Te lo dije: está vivo. ¿Ahora me creés?'),
      line('ryoto', 'Ryoto',
          'Ahora tengo los números que lo prueban. Tu palabra más mis libros: eso ya es un caso.',
          left: false),
      narrator(
          'Los libros de la Fundación tenían perro. El Guardián de la Cuenta '
          'durmió nueve meses en ese pasillo para que nadie los abriera.'),
    ]),
    battle(5, 'kage_epic', BotDifficulty.hard,
        'Los guardias de la cuenta sellada no preguntan. Vos tampoco. El tatami decide.',
        bossName: 'Guardián de la Cuenta', locationId: 'puerto'),
    dialogue(6, 'La Antesala de la Presidencia', locationId: 'ciudadela_calles', [
      line('tesorero', 'El Tesorero',
          '¿Entonces? La silla lo espera, presidente Ryoto. Solo falta una firma.'),
      line('ryoto', 'Ryoto', 'Una pregunta antes. ¿Quién firma arriba mío?',
          left: false),
      line('tesorero', 'El Tesorero', 'Arriba suyo no hay nadie, presidente.'),
      line('ryoto', 'Ryoto',
          'Curioso. Porque la cuenta A-741 firma arriba de todos ustedes.',
          left: false, sfx: '¡!'),
      line('tesorero', 'El Tesorero', '...¿Cómo conoce esa cuenta?',
          emotion: 'shocked', bubble: BubbleType.shout),
    ]),
    battle(7, 'kai_epic', BotDifficulty.hard,
        'El Tesorero llama a su cobrador de deudas incobrables. Sos la próxima deuda.',
        bossName: 'El Tesorero', locationId: 'ciudadela_calles'),
    dialogue(8, 'La Plaza de la Arena', locationId: 'arena', [
      narrator(
          'Mientras Puo Liu leía la carta del Maestro Lin ante la multitud, Ryoto subió al estrado con los libros contables. La letra y los números. La máscara cayó dos veces.'),
      line('ryoto', 'Ryoto',
          'Cada moneda del "Nuevo Consejo" sale de la misma cuenta que compró doce expedientes hace una década. ¡Acá están los libros!',
          left: false, bubble: BubbleType.shout, sfx: '¡BOOM!'),
      line('arquitecto', 'El Arquitecto',
          'El judoka incorruptible... Debí comprar tu dojo cuando valía barato.',
          bubble: BubbleType.whisper),
      line('ryoto', 'Ryoto',
          'El Dojo Mushin nunca estuvo en venta. Ese fue siempre tu error de cálculo.',
          left: false, emotion: 'determined'),
    ]),
    battle(9, 'puo_liu_epic', BotDifficulty.hard,
        'El Arquitecto, expuesto por la carta y por los números. El Incorruptible cierra el caso en el tatami.',
        bossName: 'El Arquitecto', locationId: 'arena'),
  ],
);

// ─── ACTO IV (legendary) — El Asedio: Las Instituciones ──────────────────────

final StoryArc _actoIV = StoryArc(
  heroId: 'ryoto',
  rarity: 'legendary',
  title: 'El Último Ippon',
  coverSubtitle: 'Acto IV — el Asedio de La Ciudadela',
  synopsis:
      'La noche del Asedio, el Arquitecto no solo toma la Arena: activa cada '
      'juez, oficial y funcionario que aún le debe algo. Ryoto toma el frente '
      'institucional — mantener la Federación en pie mientras la ciudad arde — '
      'y termina la pelea donde empezó todo: el tatami central.',
  stages: [
    dialogue(0, 'El Dojo Mushin, medianoche', locationId: 'dojo', [
      narrator(
          'La noche del Asedio. Las sirenas. Y en la puerta del dojo, veinte alumnos esperando órdenes.'),
      line('sensei_hiroshi', 'Sensei Hiroshi',
          'La Federación es el único edificio con autoridad legal para desalojar la Arena. Si cae, el "Último Torneo" se vuelve legítimo.'),
      line('ryoto', 'Ryoto',
          'Entonces la Federación no cae. Sensei: el dojo queda a su cargo. Yo llevo el tatami a la calle.',
          left: false, emotion: 'determined'),
      narrator(
          'La Cabecilla de la Turba trajo al Dojo Mushin a todos los que el '
          'Consejo pudo asustar esa noche. Contra el dojo, no contra el '
          'Consejo.'),
    ]),
    battle(1, 'kai_legendary', BotDifficulty.hard,
        'La turba pagada del Consejo intenta incendiar la sede de la Federación. La primera línea sos vos.',
        bossName: 'Cabecilla de la Turba', locationId: 'ciudadela_calles'),
    dialogue(2, 'La Sede de la Federación', locationId: 'ciudadela_calles', [
      line('oficial', 'Oficial',
          'Ryoto... hace un año te eché de este edificio. Hoy sos lo único que lo mantiene en pie.'),
      line('ryoto', 'Ryoto', 'El edificio no importa. Importa lo que firma.',
          left: false),
      line('oficial', 'Oficial',
          'La orden de desalojo de la Arena está lista. Pero nadie puede llevarla: los túneles están tomados.'),
      line('ryoto', 'Ryoto', 'Yo puedo. Deme la orden.',
          left: false, sfx: '¡ZAS!'),
      narrator(
          'En la sede lo esperaba la Campeona Clandestina: la que pelea en los '
          'circuitos que la Federación jura que no existen.'),
    ]),
    battle(3, 'mila_legendary', BotDifficulty.hard,
        'Los túneles hacia la Arena tienen un peaje: la campeona clandestina del Consejo. Se paga en ippons.',
        bossName: 'Campeona Clandestina', locationId: 'catacumbas'),
    dialogue(4, 'Los Túneles de la Arena', locationId: 'catacumbas', [
      line('kage', 'Kage', '¿Una orden de desalojo? ¿En serio traés papeles a una guerra?',
          emotion: 'smirk'),
      line('ryoto', 'Ryoto',
          'Los papeles son la guerra, Kage. Sin esta orden, mañana el Arquitecto es el dueño legal del torneo... y de la ciudad.',
          left: false),
      line('kage', 'Kage',
          'Por eso me caés bien, judoka. Peleás con reglas en un mundo sin reglas. Y ganás igual.'),
      line('ryoto', 'Ryoto', 'Las reglas son mías. El mundo, que se adapte.',
          left: false, emotion: 'determined'),
      narrator(
          'En los túneles de la Arena apareció la Escolta de Élite del '
          'Arquitecto: los que quedan cuando ya no queda nadie más.'),
    ]),
    battle(5, 'kage_legendary', BotDifficulty.hard,
        'La escolta de élite del Arquitecto custodia la entrada del tatami central. Última aduana antes de la verdad.',
        bossName: 'Escolta de Élite', locationId: 'arena'),
    dialogue(6, 'El Tatami Central de la Arena', locationId: 'arena', [
      narrator(
          'En el centro de la Arena tomada, sobre el tatami donde empezó su leyenda, Ryoto clavó la orden de desalojo en el poste del ring.'),
      line('arquitecto', 'El Arquitecto',
          '¿Un papel, Ryoto? ¿Diez años de camino para traerme un papel?'),
      line('ryoto', 'Ryoto',
          'Este papel dice que todo lo que construiste esta noche es ilegal. Lo que sigue después del papel... es el Judo.',
          left: false, sfx: '¡TUMP!'),
      line('arquitecto', 'El Arquitecto', 'Entonces mostrame el Judo.',
          bubble: BubbleType.whisper),
      narrator(
          'Sobre el tatami central esperaba el Campeón del Último Torneo. Al '
          'Arquitecto no se llega entero: se llega después de él.'),
    ]),
    battle(7, 'puo_liu_legendary', BotDifficulty.hard,
        'El campeón final del Arquitecto sale al tatami. La Arena entera contiene la respiración.',
        bossName: 'Campeón del Último Torneo', locationId: 'arena'),
    dialogue(8, 'El Centro del Tatami', locationId: 'arena', [
      line('arquitecto', 'El Arquitecto',
          'Doce maestros cayeron con una firma. ¿Sabés lo fácil que fue? El honor es la debilidad más barata de comprar.'),
      line('ryoto', 'Ryoto',
          'Y sin embargo acá estoy. Sin comprar. Diez años después. El honor no es debilidad: es memoria.',
          left: false, emotion: 'determined'),
      narrator(
          'El Sensei Hiroshi miraba desde la primera fila. Esta vez, nadie iba a manipular el resultado.'),
      line('ryoto', 'Ryoto', 'Por los doce. Y por el que me enseñó a caer.',
          left: false, sfx: '¡IPPON!'),
    ]),
    battle(9, 'puo_liu_legendary', BotDifficulty.hard,
        'El Arquitecto en el tatami central. Sin jueces comprados, sin firmas falsas. Solo Judo. El último ippon de la saga.',
        bossName: 'El Arquitecto', locationId: 'arena'),
  ],
);
