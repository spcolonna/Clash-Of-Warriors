// lib/infra/local/story/arcs_kai.dart
//
// KAI (BOXER) — Serie "Barrio Sur" en 4 actos.
// Acto I: el Gran Torneo (el gimnasio). Acto II: el circuito clandestino de
// Vespa. Acto III: el contrato caballo de Troya. Acto IV: el Asedio — el
// frente de la gente.

import '../../../domain/entities/battle_state.dart' show BotDifficulty;
import '../../../domain/entities/story_arc.dart';
import 'story_helpers.dart';

final List<StoryArc> kaiArcs = [
  _actoI,
  _actoII,
  _actoIII,
  _actoIV,
];

// ─── ACTO I (common) — El Barrio Contra el Mundo ─────────────────────────────

final StoryArc _actoI = StoryArc(
  heroId: 'kai',
  rarity: 'common',
  title: 'El Barrio Contra el Mundo',
  coverSubtitle: 'El Gran Torneo — la misma semana, cinco caminos',
  synopsis:
      'El gimnasio del Barrio Sur tiene 30 días antes de la demolición. El '
      'Gran Torneo tiene un premio que lo salva. Entre Kai y la final hay un '
      'promotor corrupto, una oferta sucia y todos los que dicen que los del '
      'Barrio Sur nunca llegan.',
  stages: [
    dialogue(0, 'El Gimnasio del Barrio Sur', locationId: 'barrio_sur', [
      line('entrenador', 'Entrenador',
          'Kai. Llegó la notificación. Si no pagan en 30 días, el gimnasio se demuele.'),
      line('kai', 'Kai', '¿Cuánto?', left: false),
      line('entrenador', 'Entrenador',
          'Más de lo que tenemos. Mucho más.', emotion: 'sad'),
      line('kai', 'Kai', 'El Gran Torneo tiene premio. Si llego a la final...',
          left: false),
      line('entrenador', 'Entrenador',
          'Los equipos del Barrio Sur nunca llegan a la final.'),
      line('kai', 'Kai', 'Yo no soy un equipo.',
          left: false, emotion: 'determined', sfx: '¡PAF!'),
    ]),
    battle(1, 'ryoto', BotDifficulty.easy,
        'Clasificatorio del torneo. El primer rival no te conoce. Todavía.',
        locationId: 'arena'),
    dialogue(2, 'La Oficina del Promotor', locationId: 'ciudadela_calles', [
      line('promotor', 'Promotor Vespa',
          'Kai. Qué sorpresa llegar hasta acá. Tenés talento.'),
      line('kai', 'Kai', 'Vine por el gimnasio.', left: false),
      line('promotor', 'Promotor Vespa',
          'Podrías tener un futuro en este negocio. Bajo mis condiciones.'),
      line('kai', 'Kai', '¿Qué condiciones?', left: false),
      line('promotor', 'Promotor Vespa',
          'Llegás a la final. Perdés. Hacemos que parezca real. El gimnasio queda pagado.',
          bubble: BubbleType.whisper),
      line('kai', 'Kai', 'No.',
          left: false, emotion: 'angry', bubble: BubbleType.shout),
      line('promotor', 'Promotor Vespa',
          'Pensalo bien. La alternativa es peor.'),
    ]),
    battle(3, 'puo_liu', BotDifficulty.normal,
        'El campeón del torneo fue enviado a intimidarte. Le vas a demostrar que no te van a parar.',
        locationId: 'arena'),
    dialogue(4, 'La Calle Trasera del Gimnasio', locationId: 'barrio_sur', [
      line('entrenador', 'Entrenador',
          'Kai. Alguien me amenazó. Si seguís en el torneo...'),
      line('kai', 'Kai', '¿Qué querés que haga?', left: false),
      line('entrenador', 'Entrenador',
          'Lo que debés hacer. Pero quiero que sepas el costo.'),
      line('kai', 'Kai',
          'El costo de no rendirse es más alto que el de rendirse. Pero es el único que vale la pena pagar.',
          left: false, emotion: 'determined'),
      narrator(
          'El costo llegó esa misma noche, en la calle trasera del gimnasio: los Matones de Vespa vinieron a cobrarle la respuesta antes de que la diera en público.'),
    ]),
    battle(5, 'kage', BotDifficulty.hard,
        'Los matones del promotor. No van a detenerte. Nadie va a detenerte.',
        bossName: 'Matones de Vespa', locationId: 'barrio_sur'),
    dialogue(6, 'Los Vestuarios de la Arena', locationId: 'arena', [
      line('ryoto', 'Ryoto',
          'Vi lo que le hicieron a tu entrenador. Eso no tiene nada que ver con el deporte.'),
      line('kai', 'Kai', 'Lo sé.', left: false),
      line('ryoto', 'Ryoto',
          'Tengo evidencia de la corrupción. Suficiente para exponer al promotor.'),
      line('kai', 'Kai',
          'Evidencia no alcanza si los jueces son parte del sistema.',
          left: false),
      line('ryoto', 'Ryoto',
          'Hay alguien por encima de los jueces. Si lo exponemos...'),
      line('kai', 'Kai', 'Primero tengo que llegar. Un round a la vez.',
          left: false),
      line('ryoto', 'Ryoto', 'Un round a la vez.'),
    ]),
    battle(7, 'mila', BotDifficulty.hard,
        'Semifinal del torneo. Mila también está en su propio camino. Solo uno sigue.',
        locationId: 'arena'),
    dialogue(8, 'El Ring de la Final', locationId: 'arena', [
      line('mila', 'Mila',
          'Kai. El promotor acaba de salir del edificio. Cuando terminés esto, ya no va a tener poder.'),
      line('kai', 'Kai', '¿Cómo?', left: false),
      line('mila', 'Mila',
          'Kage se encargó. El Consejo Sombra cayó esta noche.'),
      line('kai', 'Kai', '¿Y el que me espera en el ring?', left: false),
      line('mila', 'Mila',
          'El último de pie. El campeón que usaban para controlar el resultado.'),
      line('kai', 'Kai',
          'Entonces lo derroto en el ring. Justo. Como siempre debió haber sido.',
          left: false, emotion: 'determined', sfx: '¡DING!'),
      narrator(
          'La campana sonó y del otro lado del ring no había un rival: había El '
          'Campeón Comprado, con las órdenes ya cobradas y el resultado ya '
          'escrito.'),
    ]),
    battle(9, 'ryoto', BotDifficulty.hard,
        'La final del torneo. Sin trampas. Sin sobornos. Solo dos peleadores y la verdad del ring.',
        bossName: 'El Campeón Comprado', locationId: 'arena'),
  ],
);

// ─── ACTO II (rare) — El Circuito Clandestino ────────────────────────────────

final StoryArc _actoII = StoryArc(
  heroId: 'kai',
  rarity: 'rare',
  title: 'El Circuito Clandestino',
  coverSubtitle: 'Acto II — Vespa vuelve a las sombras',
  synopsis:
      'Vespa perdió el torneo, pero no el negocio: montó un circuito '
      'clandestino de apuestas que devora a los pibes del Barrio Sur, uno '
      'por uno. Kai lo va a desmontar de la única manera que conoce: '
      'subiéndose a cada ring hasta llegar al dueño.',
  stages: [
    dialogue(0, 'El Gimnasio del Barrio Sur', locationId: 'barrio_sur', [
      narrator(
          'El gimnasio estaba pagado. El barrio, de fiesta. Hasta que los pibes empezaron a faltar a entrenar.'),
      line('entrenador', 'Entrenador',
          'Tres de los juveniles pelean de noche en el circuito de Vespa. Sin guantes, sin médico, con apuestas.'),
      line('kai', 'Kai', '¿Vespa? ¿No estaba terminado?',
          left: false, emotion: 'angry'),
      line('entrenador', 'Entrenador',
          'Los tipos como Vespa no terminan. Mutan. Ahora paga en efectivo y cobra en futuros.'),
      line('kai', 'Kai', 'Entonces le voy a cortar la caja. Pelea por pelea.',
          left: false, emotion: 'determined', sfx: '¡PAF!'),
      narrator(
          'Al gimnasio ya no se entraba gratis. El Portero del Circuito se '
          'plantó en la puerta: sin la firma de Vespa, nadie usa ese ring.'),
    ]),
    battle(1, 'ryoto_rare', BotDifficulty.normal,
        'Para entrar al circuito hay que pelear. Primera regla: acá no hay reglas. Segunda: la casa siempre gana. Vas a romper las dos.',
        bossName: 'Portero del Circuito', locationId: 'catacumbas'),
    dialogue(2, 'El Sótano de las Apuestas', locationId: 'catacumbas', [
      line('kai', 'Kai',
          'Teo. Tenés dieciséis años. ¿Qué hacés peleando por plata acá abajo?',
          left: false),
      line('lucas', 'Teo del Barrio',
          'Kai... la beca del gimnasio no alcanza para mi vieja. Vespa paga por noche lo que vos pagás por mes.'),
      line('kai', 'Kai',
          'Vespa te paga con tu propia carrera. Cada pelea acá te roba diez allá arriba.',
          left: false),
      line('lucas', 'Teo del Barrio', '¿Y qué opción tengo?', emotion: 'sad'),
      line('kai', 'Kai',
          'Yo. Esta noche peleo en tu lugar. Y mañana el circuito no existe más.',
          left: false, emotion: 'determined'),
      narrator(
          'El sótano de las apuestas tenía su propio rey. El Invicto del Sótano '
          'llevaba cuarenta peleas sin perder, y ninguna arriba de un ring '
          'legal.'),
    ]),
    battle(3, 'kage_rare', BotDifficulty.normal,
        'El campeón nocturno del sótano. Invicto en 40 peleas arregladas. Esta no está arreglada.',
        bossName: 'El Invicto del Sótano', locationId: 'catacumbas'),
    dialogue(4, 'La Barbería de la Esquina', locationId: 'barrio_sur', [
      line('mila', 'Mila',
          'Vespa lava el dinero de las apuestas con ayuda del viejo Clan. Los liberados de Kage lo confirmaron.'),
      line('kai', 'Kai', '¿El Clan? ¿No lo habíamos hundido ya?',
          left: false, emotion: 'shocked'),
      line('mila', 'Mila',
          'Lo que queda de él busca caja. Vespa la tiene. Se encontraron solos, como el agua y la mugre.'),
      line('kai', 'Kai',
          'Entonces al cortarle la caja a Vespa, se la corto al Clan también. Dos pájaros.',
          left: false, emotion: 'smirk'),
      narrator(
          'La caja de Vespa no estaba en un banco: estaba en la trastienda de la barbería, y el Guardaespaldas de la Caja no se movía de la puerta ni para comer.'),
    ]),
    battle(5, 'mila_rare', BotDifficulty.hard,
        'La contadora del circuito viaja con guardaespaldas. La caja viaja con ella.',
        bossName: 'Guardaespaldas de la Caja', locationId: 'puerto'),
    dialogue(6, 'El Muelle de Cargas', locationId: 'puerto', [
      narrator(
          'La caja del circuito: tres meses de apuestas, deudas firmadas y la lista de todos los pibes que Vespa tenía agarrados.'),
      line('kai', 'Kai',
          'Cuarenta nombres. Cuarenta pibes del barrio hipotecados a un sótano.',
          left: false, emotion: 'angry'),
      line('entrenador', 'Entrenador',
          'Si esa lista desaparece, Vespa pierde su ganado. Va a venir por vos con todo.'),
      line('kai', 'Kai',
          'Que venga. Le guardo el mejor asiento: la primera fila del ring.',
          left: false, sfx: '¡CRACK!'),
      narrator(
          'Vespa no vino solo: mandó por delante al Seguro del Clan, la póliza que contrata cuando el negocio se le va de las manos.'),
    ]),
    battle(7, 'kage_rare', BotDifficulty.hard,
        'Vespa contrató sombras del viejo Clan como seguro. El seguro vence esta noche.',
        bossName: 'Seguro del Clan', locationId: 'puerto'),
    dialogue(8, 'El Ring del Sótano', locationId: 'catacumbas', [
      line('promotor', 'Promotor Vespa',
          'Kai, Kai, Kai... Te ofrecí la puerta grande y elegiste romper la mía.'),
      line('kai', 'Kai',
          'Tu puerta grande era una jaula con luces. La rompí porque adentro estaban mis pibes.',
          left: false),
      line('promotor', 'Promotor Vespa',
          '¿Sabés cuánta gente poderosa pierde plata si esta noche cerrás el circuito?',
          bubble: BubbleType.shout),
      line('kai', 'Kai', 'Contá conmigo para presentarles la factura.',
          left: false, emotion: 'determined', sfx: '¡DING DING!'),
    ]),
    battle(9, 'kai_rare', BotDifficulty.hard,
        'Vespa se guardó un último as: él mismo. Boxeador antes que buitre. El circuito muere con su dueño en la lona.',
        bossName: 'Promotor Vespa', locationId: 'catacumbas'),
  ],
);

// ─── ACTO III (epic) — El Contrato de Cristal ────────────────────────────────

final StoryArc _actoIII = StoryArc(
  heroId: 'kai',
  rarity: 'epic',
  title: 'El Contrato de Cristal',
  coverSubtitle: 'Acto III — el caballo de Troya del Barrio Sur',
  synopsis:
      'El "Nuevo Consejo" le ofrece a Kai el contrato del siglo: campeón '
      'oficial, imagen de La Ciudadela, cifras obscenas. Kai firma... porque '
      'un contrato es la mejor entrada al edificio que Ryoto necesita '
      'auditar. El plan: ser el caballo de Troya con guantes.',
  stages: [
    dialogue(0, 'El Gimnasio del Barrio Sur', locationId: 'barrio_sur', [
      line('tesorero', 'El Tesorero',
          'Campeón. La fundación quiere hacer historia: el primer contrato vitalicio del boxeo de La Ciudadela. Usted pone la cara. Nosotros, los ceros.'),
      line('kai', 'Kai', '¿Y el Barrio Sur qué pone?', left: false),
      line('tesorero', 'El Tesorero',
          'El Barrio Sur recibe un polideportivo. Con su nombre, por supuesto.'),
      line('kai', 'Kai', 'Déjeme el contrato. Lo leo con mi... asesor.',
          left: false, emotion: 'smirk'),
      narrator(
          'El asesor se llamaba Ryoto. Y no iba a leer el contrato: iba a rastrear cada firma.'),
      line('tesorero', 'El Tesorero',
          'Una cosa más. Para la foto necesitamos que pelees con un Rival de Gala. Elegido por nosotros, claro.',
          emotion: 'smirk'),
      line('kai', 'Kai',
          'Un rival de vitrina. Bueno: que se ponga los guantes igual.',
          left: false),
    ]),
    battle(1, 'puo_liu_epic', BotDifficulty.hard,
        'La presentación oficial exige una exhibición. El rival de gala pelea mejor de lo que sonríe.',
        bossName: 'Rival de Gala', locationId: 'arena'),
    dialogue(2, 'La Torre del Nuevo Consejo', locationId: 'ciudadela_calles', [
      line('campeon_cristal', 'El Campeón de Cristal',
          'Así que vos sos el nuevo juguete. Yo fui el campeón de ellos durante tres años.'),
      line('kai', 'Kai', '¿Y ahora?', left: false),
      line('campeon_cristal', 'El Campeón de Cristal',
          'Ahora soy el sparring de tu presentación. Cuando dejás de servir, te reciclan.',
          emotion: 'sad'),
      line('kai', 'Kai',
          '¿Cuántas peleas tuyas fueron reales?', left: false),
      line('campeon_cristal', 'El Campeón de Cristal',
          '...Ninguna. Por eso me dicen de cristal: nunca me dejaron probar si era de acero.',
          bubble: BubbleType.whisper),
    ]),
    battle(3, 'kai_epic', BotDifficulty.hard,
        'El Campeón de Cristal pide una pelea real. La primera de su vida. Se la vas a dar. Completa.',
        bossName: 'El Campeón de Cristal', locationId: 'arena'),
    dialogue(4, 'Los Pasillos de la Torre', locationId: 'ciudadela_calles', [
      line('ryoto', 'Ryoto',
          'Tu contrato me abrió los archivos. Los números cierran con lo que encontré en la fundación: todo baja de la cuenta A-741.'),
      line('kai', 'Kai', '¿La cuenta del Arquitecto?',
          left: false, emotion: 'shocked'),
      line('ryoto', 'Ryoto',
          'La misma. Tu cara iba a ser la garantía pública de su lavadero.'),
      line('kai', 'Kai',
          'Entonces sigamos el plan: sonrío para las cámaras hasta la ceremonia... y ahí rompemos todo.',
          left: false, emotion: 'determined'),
      narrator(
          'Pero alguien leyó la sonrisa al revés. El Jefe de Seguridad de la torre los cruzó en el pasillo: si el campeón estaba curioseando pisos que no le tocaban, había que acompañarlo hasta la salida.'),
    ]),
    battle(5, 'kage_epic', BotDifficulty.hard,
        'El jefe de seguridad de la Torre sospecha del "asesor" de Kai. Hay que borrarle la sospecha. A la antigua.',
        bossName: 'Jefe de Seguridad', locationId: 'ciudadela_calles'),
    dialogue(6, 'El Polideportivo en Obra', locationId: 'barrio_sur', [
      line('entrenador', 'Entrenador',
          'El barrio te vio firmar con esa gente, Kai. Hay pintadas en el gimnasio. Dicen que te vendiste.'),
      line('kai', 'Kai', 'Lo sé. Y no puedo explicar nada todavía.',
          left: false, emotion: 'sad'),
      line('entrenador', 'Entrenador',
          '¿Sabés lo que me costó defenderte sin saber si tenía razón?'),
      line('kai', 'Kai',
          'Dame una semana. Si en una semana no entendés todo... yo mismo pinto la pared.',
          left: false, emotion: 'determined'),
      narrator(
          'No le dieron la semana. La Cobradora del Consejo apareció entre los andamios del polideportivo: si el barrio no pagaba con silencio, iba a pagar con la obra.'),
    ]),
    battle(7, 'mila_epic', BotDifficulty.hard,
        'La Dama de los Contratos huele la traición y manda a su mejor cobradora. El contrato de cristal empieza a rajarse.',
        bossName: 'Cobradora del Consejo', locationId: 'barrio_sur'),
    dialogue(8, 'La Plaza de la Arena', locationId: 'arena', [
      narrator(
          'El día de la ceremonia, Puo Liu leyó la carta. Ryoto mostró los libros. Y Kai subió al estrado con su contrato vitalicio... y lo rompió frente a las cámaras.'),
      line('kai', 'Kai',
          '¡Este contrato lo firma la misma cuenta que compraba peleas, jueces y expedientes! ¡El Barrio Sur no se alquila!',
          left: false, bubble: BubbleType.shout, sfx: '¡RAAAS!'),
      line('arquitecto', 'El Arquitecto',
          'El boxeador analfabeto... Rompiste un contrato de ocho cifras.',
          bubble: BubbleType.whisper),
      line('kai', 'Kai',
          'Aprendí a pelear antes que a leer. Pero leer... también aprendí.',
          left: false, emotion: 'smirk'),
    ]),
    battle(9, 'puo_liu_epic', BotDifficulty.hard,
        'El Arquitecto, triplemente expuesto. El campeón del pueblo cierra la ceremonia con el único idioma que nunca aprendió a fingir.',
        bossName: 'El Arquitecto', locationId: 'arena'),
  ],
);

// ─── ACTO IV (legendary) — El Asedio: La Gente ───────────────────────────────

final StoryArc _actoIV = StoryArc(
  heroId: 'kai',
  rarity: 'legendary',
  title: 'La Leyenda del Sur',
  coverSubtitle: 'Acto IV — el Asedio de La Ciudadela',
  synopsis:
      'La noche del Asedio, el Arquitecto apuesta a que la gente se esconda. '
      'No conoce al Barrio Sur. Kai toma el frente de la calle: organizar a '
      'los barrios, sostener la moral y pelear la final del "Último Torneo" '
      'ante el único juez que nunca se pudo comprar — el público.',
  stages: [
    dialogue(0, 'El Gimnasio, medianoche', locationId: 'barrio_sur', [
      narrator(
          'La noche del Asedio. La Arena tomada, la ciudad a oscuras. Y en el Barrio Sur, un gimnasio con las luces prendidas.'),
      line('entrenador', 'Entrenador',
          'El Arquitecto cerró los accesos. Dice que a medianoche empieza su "Último Torneo" y que la ciudad es el premio.'),
      line('kai', 'Kai',
          'La ciudad no es de nadie que haya que ganarla. Es de los que la laburan.',
          left: false, emotion: 'determined'),
      line('entrenador', 'Entrenador', '¿Qué hacemos?'),
      line('kai', 'Kai',
          'Lo que hace el barrio cuando hay lío: abrimos las puertas. Todas.',
          left: false, sfx: '¡PAF!'),
      narrator(
          'Las puertas abiertas también dejan entrar. Los Saqueadores del Consejo llegaron con el Asedio, buscando el único lugar que el Barrio Sur nunca deja caer: el gimnasio.'),
    ]),
    battle(1, 'ryoto_legendary', BotDifficulty.hard,
        'Los cobradores del Consejo intentan saquear el mercado del barrio. El barrio responde. Vos primero.',
        bossName: 'Saqueadores del Consejo', locationId: 'barrio_sur'),
    dialogue(2, 'La Avenida Central', locationId: 'ciudadela_calles', [
      line('lucas', 'Teo del Barrio',
          '¡Kai! Los del mercado están con nosotros. Y los pesqueros del puerto. Y las barberías. ¡Todos salieron!'),
      line('kai', 'Kai', '¿Quién los convocó?', left: false,
          emotion: 'shocked'),
      line('lucas', 'Teo del Barrio',
          'Nadie. Vieron la luz del gimnasio prendida. Con eso alcanzó.',
          emotion: 'determined'),
      narrator(
          'Y por las avenidas de La Ciudadela, la gente marchó hacia la Arena. Sin armas. Con antorchas.'),
      narrator(
          'La Avenida Central estaba tomada. Los Mercenarios de la Avenida '
          'cobraban por cuadra, y el camino al centro pasaba justo por la suya.'),
    ]),
    battle(3, 'kage_legendary', BotDifficulty.hard,
        'La caballería a sueldo del Arquitecto corta la avenida. La marcha no retrocede. Vos tampoco.',
        bossName: 'Mercenarios de la Avenida', locationId: 'ciudadela_calles'),
    dialogue(4, 'Las Puertas de la Arena', locationId: 'arena', [
      line('mila', 'Mila',
          'Los rehenes están saliendo por los túneles. Pero el Arquitecto tiene un plan B: si pierde la Arena, la vuela.'),
      line('kai', 'Kai', '¿La vuela? ¿Con qué?',
          left: false, emotion: 'angry'),
      line('mila', 'Mila',
          'Cargas en los cimientos. Kage las está desactivando. Necesita tiempo.'),
      line('kai', 'Kai',
          'Tiempo es lo que mejor sé comprar: arriba del ring, round a round.',
          left: false, emotion: 'determined'),
      narrator(
          'El primer round se lo cobró la Campeona de la Guardia, plantada en las puertas de la Arena. Cada minuto que aguantara con ella era un minuto más para Kage y los cimientos.'),
    ]),
    battle(5, 'mila_legendary', BotDifficulty.hard,
        'La campeona de la guardia del Arquitecto sale a limpiar la entrada. El público de la marcha mira. Ganás para ellos.',
        bossName: 'Campeona de la Guardia', locationId: 'arena'),
    dialogue(6, 'El Ring del Último Torneo', locationId: 'arena', [
      line('arquitecto', 'El Arquitecto',
          'El pueblo en las gradas, el boxeador en mi ring. ¿Viniste a darles un espectáculo antes de la derrota?'),
      line('kai', 'Kai',
          'Vine a hacer tiempo, a llenar tus gradas de testigos y a bajarte del micrófono. En ese orden.',
          left: false, emotion: 'smirk', sfx: '¡DING!'),
      line('arquitecto', 'El Arquitecto',
          'Sinceridad. Qué novedad en este ring.', bubble: BubbleType.whisper),
      line('kai', 'Kai', 'Es lo único que traigo. Eso y las manos.',
          left: false),
      narrator(
          'En el ring del Último Torneo lo esperaba el Campeón del Último '
          'Torneo: el último producto que el Arquitecto pudo comprar antes de '
          'quedarse solo.'),
    ]),
    battle(7, 'puo_liu_legendary', BotDifficulty.hard,
        'El campeón final del Arquitecto: su última apuesta deportiva. Las gradas, llenas de tu gente, cuentan cada golpe.',
        bossName: 'Campeón del Último Torneo', locationId: 'arena'),
    dialogue(8, 'El Centro del Ring', locationId: 'arena', [
      narrator(
          'Las cargas: desactivadas. Los rehenes: libres. Las instituciones: en pie. Y en el ring, el dueño de la noche se quedó sin noche.'),
      line('arquitecto', 'El Arquitecto',
          '¿Sabés cuál fue siempre mi ventaja, Kai? La gente se vende. Toda. Solo hay que encontrar el precio.'),
      line('kai', 'Kai',
          'Mirá las gradas. Veinte mil personas que vinieron gratis, de noche, con miedo. Encontrá el precio de eso.',
          left: false, emotion: 'determined'),
      line('arquitecto', 'El Arquitecto', '...', emotion: 'shocked'),
      line('kai', 'Kai', 'Round final. El barrio cuenta hasta diez.',
          left: false, sfx: '¡DING DING!'),
    ]),
    battle(9, 'puo_liu_legendary', BotDifficulty.hard,
        'El Arquitecto, en el ring, ante veinte mil testigos que no pudo comprar. La Leyenda del Sur termina la pelea del siglo.',
        bossName: 'El Arquitecto', locationId: 'arena'),
  ],
);
