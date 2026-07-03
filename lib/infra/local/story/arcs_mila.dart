// lib/infra/local/story/arcs_mila.dart
//
// MILA (CAPOEIRA) — Serie "La Danza Libre" en 4 actos.
// Acto I: el Gran Torneo (Lucas). Acto II: el Cobrador del puerto. Acto III:
// la resistencia civil y la confianza en Kage. Acto IV: el Asedio — el
// frente de los rehenes y el cierre emocional de la saga.

import '../../../domain/entities/battle_state.dart' show BotDifficulty;
import '../../../domain/entities/story_arc.dart';
import 'story_helpers.dart';

final List<StoryArc> milaArcs = [
  _actoI,
  _actoII,
  _actoIII,
  _actoIV,
];

// ─── ACTO I (common) — Danza en La Ciudadela ─────────────────────────────────

final StoryArc _actoI = StoryArc(
  heroId: 'mila',
  rarity: 'common',
  title: 'Danza en La Ciudadela',
  coverSubtitle: 'El Gran Torneo — la misma semana, cinco caminos',
  synopsis:
      'Lucas llegó a La Ciudadela buscando trabajo y dejó de escribir hace '
      'tres meses. Mila llega buscándolo a él... y encuentra una ciudad donde '
      'las deudas se firman con sangre y un ninja que también quiere salir '
      'de la sombra.',
  stages: [
    dialogue(0, 'El Puerto de La Ciudadela', locationId: 'puerto', [
      narrator(
          'Lucas llevaba tres meses sin noticias. Llegó a La Ciudadela buscando trabajo y dejó de escribir.'),
      line('mila', 'Mila',
          'Si el Clan lo tiene, lo voy a encontrar. Y si no quiere volver, al menos necesito saber que está bien.',
          left: false, emotion: 'determined'),
    ]),
    battle(1, 'kai', BotDifficulty.easy,
        'La pandilla que controla el puerto no deja pasar sin pelear. Primera parada en La Ciudadela.',
        bossName: 'Pandilla del Puerto', locationId: 'puerto'),
    dialogue(2, 'El Distrito Ninja', locationId: 'ciudadela_calles', [
      line('kage', 'Kage',
          'No vas a encontrarlo solo caminando por los callejones.'),
      line('mila', 'Mila', '¿Vos lo conocés?', left: false),
      line('kage', 'Kage',
          'Sé quién es. Lidera una célula del Clan en el sector este.'),
      line('mila', 'Mila', '¿Voluntariamente?', left: false, emotion: 'shocked'),
      line('kage', 'Kage',
          'Eso es lo que todavía no sé. Hay gente que llega al Clan por deuda. Hay otros porque no tienen otra opción.'),
      line('mila', 'Mila', '¿Podés llevarme hasta él?', left: false),
      line('kage', 'Kage',
          'Puedo mostrarte el camino. El resto lo tenés que hacer vos.'),
    ]),
    battle(3, 'kage', BotDifficulty.normal,
        'Los guardias del Clan no dejan pasar a nadie. Demostrá que el camino es tuyo.',
        bossName: 'Guardias del Clan', locationId: 'ciudadela_calles'),
    dialogue(4, 'El Almacén del Sector Este', locationId: 'puerto', [
      line('lucas', 'Lucas', 'Mila. ¿Qué hacés acá? Esto es peligroso.',
          emotion: 'shocked'),
      line('mila', 'Mila', 'Vine por vos.', left: false),
      line('lucas', 'Lucas',
          'No podés estar acá. Si el Clan te ve conmigo...'),
      line('mila', 'Mila', '¿Por qué seguís acá, Lucas? ¿Te obligaron?',
          left: false),
      line('lucas', 'Lucas',
          'Debo dinero. Mucho. Si me voy, lo pagan los que quedaron en casa.',
          emotion: 'sad'),
      line('mila', 'Mila',
          'Entonces encontramos la forma de cancelar esa deuda.',
          left: false, emotion: 'determined'),
    ]),
    battle(5, 'kage', BotDifficulty.hard,
        'El guardián del Clan tiene los documentos de deuda de Lucas. Si los recuperás, cambia todo.',
        bossName: 'Guardián del Clan', locationId: 'catacumbas'),
    dialogue(6, 'El Tejado sobre el Almacén', locationId: 'puerto', [
      line('mila', 'Mila',
          'El guardián cayó pero los documentos van a ser reemplazados.',
          left: false),
      line('ryoto', 'Ryoto', 'El papel no alcanza. El Clan puede hacer copias.'),
      line('mila', 'Mila', '¿Entonces qué?', left: false),
      line('ryoto', 'Ryoto',
          'El Arquitecto firma todas las deudas del Clan personalmente. Si cae él, caen todas.'),
      line('mila', 'Mila', '¿Y eso es posible?', left: false),
      line('ryoto', 'Ryoto', 'Esta noche, con suerte... sí.'),
    ]),
    battle(7, 'ryoto', BotDifficulty.hard,
        'Para llegar al Arquitecto hay que pasar por el guardián de la arena. Ryoto te prueba una última vez.',
        locationId: 'arena'),
    dialogue(8, 'Frente al Maestro del Clan', locationId: 'catacumbas', [
      line('lucas', 'Lucas',
          'Mila. Me dijeron que te metiste en todo esto por mí. No valía la pena.'),
      line('mila', 'Mila', 'Vos siempre vas a valer la pena.',
          left: false, emotion: 'determined'),
      line('lucas', 'Lucas',
          'El maestro está adentro. Es el que manejó mi deuda desde el principio.'),
      line('puo_liu', 'Puo Liu',
          'Estoy acá también. El Arquitecto está usando al Clan como escudo. Cuando lo enfrentés, vas a entender todo.'),
      line('mila', 'Mila', 'Entiendo todo lo que necesito entender.',
          left: false, sfx: '¡GINGA!'),
    ]),
    battle(9, 'puo_liu', BotDifficulty.hard,
        'El maestro del Clan. El que inventó la deuda de Lucas. La danza termina acá.',
        bossName: 'Maestro del Clan', locationId: 'catacumbas'),
  ],
);

// ─── ACTO II (rare) — El Cobrador del Puerto ─────────────────────────────────

final StoryArc _actoII = StoryArc(
  heroId: 'mila',
  rarity: 'rare',
  title: 'El Cobrador del Puerto',
  coverSubtitle: 'Acto II — las deudas huérfanas se subastan',
  synopsis:
      'Lucas está libre, pero su deuda era una entre cientos. Con el Consejo '
      'caído, un buitre del puerto — el Cobrador — subasta las deudas '
      'huérfanas al mejor postor. Mila y Kage cazan juntos: ella baila, él '
      'desaparece, y las deudas arden.',
  stages: [
    dialogue(0, 'El Refugio de los Liberados', locationId: 'puerto', [
      narrator(
          'Tres meses después del torneo. Lucas cocinaba para veinte ex-deudores del Clan. La casa era chica. La lista de deudas, enorme.'),
      line('lucas', 'Lucas',
          'Llegó otra familia anoche. El Cobrador les subastó la deuda a una banda del puerto. Triplicó el interés.'),
      line('mila', 'Mila', '¿Quién es ese Cobrador?', left: false),
      line('kage', 'Kage',
          'Un ex-archivista del Consejo. Robó el registro de deudas menores antes de la caída. Ahora las vende como ganado.'),
      line('mila', 'Mila',
          'Entonces bailemos. Vos buscás el registro. Yo distraigo al público.',
          left: false, emotion: 'smirk'),
    ]),
    battle(1, 'kai_rare', BotDifficulty.normal,
        'La banda que compró las deudas de anoche cobra de puerta en puerta. Esta puerta es la equivocada.',
        bossName: 'Banda del Puerto', locationId: 'puerto'),
    dialogue(2, 'La Subasta Nocturna', locationId: 'puerto', [
      line('cobrador', 'El Cobrador',
          '¡Lote catorce! Familia de cuatro, deuda original de doscientos, garantía de trabajo perpetuo. ¿Quién ofrece?'),
      line('mila', 'Mila', 'Yo ofrezco.', left: false),
      line('cobrador', 'El Cobrador', '¿Cuánto, preciosa?'),
      line('mila', 'Mila', 'Una salida por la puerta, caminando.',
          left: false, emotion: 'smirk'),
      line('cobrador', 'El Cobrador',
          '...Sacála del salón.', emotion: 'angry', bubble: BubbleType.shout),
    ]),
    battle(3, 'ryoto_rare', BotDifficulty.normal,
        'El matón de la subasta te invita a salir. La capoeira acepta invitaciones.',
        bossName: 'Matón de la Subasta', locationId: 'puerto'),
    dialogue(4, 'El Tejado de la Lonja', locationId: 'puerto', [
      line('kage', 'Kage',
          'El registro no estaba en la subasta. El Cobrador lo guarda en un barco distinto cada noche.'),
      line('mila', 'Mila', '¿Y cómo sabemos cuál?', left: false),
      line('kage', 'Kage',
          'No lo sabemos. Lo seguimos a él. Pero es paranoico: nunca camina dos veces la misma ruta.'),
      line('mila', 'Mila',
          'Los paranoicos miran las sombras, Kage. Nunca miran a la que baila a plena luz.',
          left: false, emotion: 'smirk'),
      line('kage', 'Kage', '...Empiezo a entender por qué me ganaste aquella vez.'),
    ]),
    battle(5, 'kage_rare', BotDifficulty.hard,
        'La escolta del Cobrador detecta el seguimiento. Plan B: la vía rápida.',
        bossName: 'Escolta del Cobrador', locationId: 'puerto'),
    dialogue(6, 'La Bodega del Barco', locationId: 'catacumbas', [
      narrator(
          'El registro: cuatrocientas deudas menores. Nombres, montos, intereses. Vidas convertidas en renglones.'),
      line('mila', 'Mila',
          'Acá está la de la familia de anoche. Y la del panadero. Y la de la maestra del distrito este...',
          left: false),
      line('kage', 'Kage',
          'Si lo quemamos, el Cobrador pierde todo. Pero los compradores van a reclamar lo suyo.'),
      line('mila', 'Mila',
          'Por eso no lo quemamos acá. Lo quemamos en su subasta. Frente a todos sus clientes.',
          left: false, emotion: 'determined', sfx: '¡FSSSH!'),
    ]),
    battle(7, 'kai_rare', BotDifficulty.hard,
        'Los compradores de deudas no aceptan devoluciones. La bodega se convierte en roda.',
        bossName: 'Compradores de Deudas', locationId: 'catacumbas'),
    dialogue(8, 'La Subasta, última función', locationId: 'puerto', [
      line('cobrador', 'El Cobrador',
          '¡Vos! ¿Sabés cuánto vale ese registro que tenés en la mano?',
          bubble: BubbleType.shout, emotion: 'angry'),
      line('mila', 'Mila',
          'Cuatrocientas vidas. Por eso no tiene precio... y por eso arde gratis.',
          left: false, sfx: '¡FUEGO!'),
      narrator(
          'El registro ardió frente a cuarenta compradores. Y con cada página, una familia del puerto durmió sin deuda por primera vez en años.'),
      line('cobrador', 'El Cobrador', 'Me arruinaste. Te voy a...',
          emotion: 'angry'),
      line('mila', 'Mila', '¿Bailar? Dale. Es lo único que queda en tu salón.',
          left: false, emotion: 'smirk'),
    ]),
    battle(9, 'kage_rare', BotDifficulty.hard,
        'El Cobrador pelea por lo único que le queda: su reputación. La danza se la lleva también.',
        bossName: 'El Cobrador', locationId: 'puerto'),
  ],
);

// ─── ACTO III (epic) — La Red de los Libres ──────────────────────────────────

final StoryArc _actoIII = StoryArc(
  heroId: 'mila',
  rarity: 'epic',
  title: 'La Red de los Libres',
  coverSubtitle: 'Acto III — confiar en una sombra',
  synopsis:
      'El "Nuevo Consejo" recluta y Kage desaparece detrás de una máscara '
      'que juró romper. Mientras la ciudad celebra a sus filántropos de '
      'traje, Mila convierte a los liberados en una red de resistencia '
      'civil... y decide cuánto vale la palabra de una sombra.',
  stages: [
    dialogue(0, 'El Refugio de los Liberados', locationId: 'puerto', [
      line('lucas', 'Lucas',
          'Los del distrito este vieron a Kage entrando a la Torre del Nuevo Consejo. Con la máscara puesta, Mila.'),
      line('mila', 'Mila', 'Lo sé. Me lo dijo antes de entrar.',
          left: false, emotion: 'sad'),
      line('lucas', 'Lucas', '¿Y le creés?'),
      line('mila', 'Mila',
          'Le creo a lo que eligió cuando nadie lo obligaba. Pero igual me duele verlo con esa cosa puesta.',
          left: false),
      narrator(
          'La red de los libres tenía doscientos ojos en la ciudad. Esa semana, todos miraban la Torre.'),
    ]),
    battle(1, 'kage_epic', BotDifficulty.hard,
        'El Nuevo Consejo "censa" a los liberados para volver a endeudarlos. El censista trae guardaespaldas.',
        bossName: 'Censista del Consejo', locationId: 'puerto'),
    dialogue(2, 'El Mercado del Distrito Este', locationId: 'ciudadela_calles', [
      line('dama_contratos', 'La Dama de los Contratos',
          'Mila, ¿verdad? La bailarina que quema registros. El Nuevo Consejo quiere ofrecerte un empleo: coordinadora social.'),
      line('mila', 'Mila', '¿Coordinar qué?', left: false),
      line('dama_contratos', 'La Dama de los Contratos',
          'A tu gente. Los liberados confían en vos. Nosotros pagamos esa confianza. Muy bien.'),
      line('mila', 'Mila',
          'Mi gente no se coordina. Se libera. Son verbos distintos, señora.',
          left: false, emotion: 'determined'),
      line('dama_contratos', 'La Dama de los Contratos',
          'Qué lástima. Los verbos incorrectos tienen consecuencias.',
          bubble: BubbleType.whisper),
    ]),
    battle(3, 'mila_epic', BotDifficulty.hard,
        'Las "consecuencias" llegan al mercado esa misma tarde. La roda las recibe.',
        bossName: 'Las Consecuencias', locationId: 'ciudadela_calles'),
    dialogue(4, 'El Tejado del Refugio', locationId: 'puerto', [
      line('kage', 'Kage',
          'Te vieron con la Dama. Rechazaste su oferta. Ahora sos objetivo.',
          bubble: BubbleType.whisper),
      line('mila', 'Mila', '¿Viniste con la máscara a decirme eso?',
          left: false, emotion: 'angry'),
      line('kage', 'Kage', '...'),
      line('mila', 'Mila',
          'Volvé con la prueba, Kage. Y con la máscara rota. Hasta entonces, la red no te conoce.',
          left: false, emotion: 'sad'),
      narrator('Fue la conversación más corta y más cara de la saga.'),
    ]),
    battle(5, 'ryoto_epic', BotDifficulty.hard,
        'El Verificador del Consejo viene a comprobar si la red de los libres tiene líder. La respuesta duele.',
        bossName: 'El Verificador', locationId: 'puerto'),
    dialogue(6, 'La Torre, ala de servicio', locationId: 'catacumbas', [
      narrator(
          'La red descubrió el plan: el censo del Consejo terminaba en contratos nuevos. Cuatrocientas familias, otra vez en la lista.'),
      line('lucas', 'Lucas',
          'Tienen las direcciones de todos los refugios. Firman los contratos mañana... por "adhesión voluntaria".'),
      line('mila', 'Mila',
          'Entonces esta noche mudamos doscientas personas sin que la Torre vea un solo movimiento.',
          left: false),
      line('lucas', 'Lucas', '¿Cómo se mueve tanta gente sin ser vista?'),
      line('mila', 'Mila',
          'Como en Salvador: con música. Cuando la ciudad mira la roda... nadie cuenta cuántos entran y cuántos salen.',
          left: false, emotion: 'smirk', sfx: '♪ GINGA ♪'),
    ]),
    battle(7, 'kai_epic', BotDifficulty.hard,
        'La Dama manda a su cobradora a interrumpir la roda. El público hace ronda. La danza decide.',
        bossName: 'Cobradora del Consejo', locationId: 'ciudadela_calles'),
    dialogue(8, 'El Refugio, al amanecer', locationId: 'puerto', [
      line('kage', 'Kage',
          'Está vivo. El Arquitecto firmó doscientos contratos este mes. Acá está la prueba.'),
      line('mila', 'Mila', '¿Y la máscara?', left: false),
      line('kage', 'Kage', 'Rota. Como prometí.', sfx: 'CRACK'),
      line('mila', 'Mila',
          'Doscientas personas durmieron a salvo anoche gracias a la red. Y una sombra volvió a casa. Buena noche para los libres.',
          left: false, emotion: 'determined'),
      line('kage', 'Kage',
          'Mañana Puo Liu rompe la máscara del Consejo ante toda la ciudad. ¿La red va a estar?'),
      line('mila', 'Mila', 'La red ES la ciudad, Kage. Vamos todos.',
          left: false),
    ]),
    battle(9, 'kai_epic', BotDifficulty.hard,
        'La Dama de los Contratos, sin censo y sin red que atrapar, apuesta todo a una última pelea. La roda la espera.',
        bossName: 'La Dama de los Contratos', locationId: 'ciudadela_calles'),
  ],
);

// ─── ACTO IV (legendary) — El Asedio: Los Rehenes ────────────────────────────

final StoryArc _actoIV = StoryArc(
  heroId: 'mila',
  rarity: 'legendary',
  title: 'La Última Danza',
  coverSubtitle: 'Acto IV — el Asedio de La Ciudadela',
  synopsis:
      'La noche del Asedio, el Arquitecto llena las gradas de la Arena con '
      'rehenes: su seguro contra los héroes. Mila toma el frente que nadie '
      'más puede tomar — sacarlos a todos — y llega al Arquitecto la última, '
      'cuando ya no le queda nada. El cierre de la saga es suyo.',
  stages: [
    dialogue(0, 'El Refugio, medianoche', locationId: 'puerto', [
      narrator(
          'La noche del Asedio. En las gradas de la Arena, tres mil personas. El Arquitecto las llamaba "mi público". Eran su escudo.'),
      line('mila', 'Mila',
          'Puo Liu va al centro. Kage al techo. Ryoto a la Federación. Kai a la calle. Y yo... yo voy por las gradas.',
          left: false, emotion: 'determined'),
      line('lucas', 'Lucas', '¿Tres mil personas? ¿Cómo?'),
      line('mila', 'Mila',
          'Con la red. Doscientos libres conocen cada túnel de esa Arena. Esta noche devolvemos el favor.',
          left: false),
    ]),
    battle(1, 'puo_liu_legendary', BotDifficulty.hard,
        'Los carceleros de las gradas norte descubren la primera evacuación. No va a haber segunda advertencia.',
        bossName: 'Carceleros del Norte', locationId: 'arena'),
    dialogue(2, 'Los Túneles de la Arena', locationId: 'catacumbas', [
      line('kage', 'Kage',
          'Las cargas de los cimientos están desactivadas. Pero el ala sur sigue sellada: doscientos rehenes detrás de una puerta de hierro.'),
      line('mila', 'Mila', '¿Quién tiene la llave?', left: false),
      line('kage', 'Kage', 'La Guardiana. La única sombra que me superaba en el Clan.'),
      line('mila', 'Mila', '¿Y quién te supera a vos ahora?',
          left: false, emotion: 'smirk'),
      line('kage', 'Kage', '...Andá a buscar tu llave, bailarina.'),
    ]),
    battle(3, 'kage_legendary', BotDifficulty.hard,
        'La Guardiana del ala sur. La llave cuelga de su cuello. La danza nunca tuvo mejor motivo.',
        bossName: 'La Guardiana', locationId: 'catacumbas'),
    dialogue(4, 'El Ala Sur, puertas abiertas', locationId: 'arena', [
      narrator(
          'Doscientos rehenes salieron por los túneles guiados por los libres. Afuera, la marcha de Kai los recibió con mantas y antorchas.'),
      line('lucas', 'Lucas',
          '¡Quedan las gradas del palco! Familias de la Federación, jueces, hasta el Oficial que echó a Ryoto.'),
      line('mila', 'Mila',
          'También salen. Todos salen. Hoy no se elige a quién se salva.',
          left: false, emotion: 'determined'),
    ]),
    battle(5, 'ryoto_legendary', BotDifficulty.hard,
        'El jefe de carceleros bloquea el palco con lo último de su orgullo. El orgullo pesa. La danza no.',
        bossName: 'Jefe de Carceleros', locationId: 'arena'),
    dialogue(6, 'Las Gradas Vacías', locationId: 'arena', [
      line('arquitecto', 'El Arquitecto',
          '¿Dónde... dónde está mi público?', emotion: 'shocked',
          bubble: BubbleType.shout),
      line('mila', 'Mila',
          'Camino a casa. Tu escudo tenía piernas, Arquitecto. Solo había que recordárselo.',
          left: false, emotion: 'smirk', sfx: '¡TA-DÁ!'),
      line('arquitecto', 'El Arquitecto',
          'Tres mil rehenes... ¿los sacaste bailando?', bubble: BubbleType.whisper),
      line('mila', 'Mila',
          'Los saqué en silencio. El baile es esto que viene ahora.',
          left: false),
    ]),
    battle(7, 'kai_legendary', BotDifficulty.hard,
        'La última guardia personal del Arquitecto forma un círculo. Un círculo. Qué gentileza: una roda.',
        bossName: 'Guardia Personal', locationId: 'arena'),
    dialogue(8, 'El Centro de la Arena, amanecer', locationId: 'arena', [
      narrator(
          'Los frentes cayeron todos. Y cuando los héroes rodearon el ring, fue Mila la que dio el paso al frente. La saga había empezado con una deuda ajena. Iba a terminar con la libertad de todos.'),
      line('arquitecto', 'El Arquitecto',
          'La bailarina del puerto. Viniste por una deuda de doscientos... y me costaste una ciudad.'),
      line('mila', 'Mila',
          'No vine por una deuda. Vine por mi hermano. Lo demás lo hiciste vos solo, al pensar que la gente era tuya.',
          left: false, emotion: 'determined'),
      line('arquitecto', 'El Arquitecto', '¿Y ahora qué? ¿Me vas a liberar a mí también?',
          bubble: BubbleType.whisper),
      line('mila', 'Mila', 'Sí. De la única cosa que te queda: el poder.',
          left: false, sfx: '♪ GINGA ♪'),
    ]),
    battle(9, 'puo_liu_legendary', BotDifficulty.hard,
        'El Arquitecto, al amanecer, sin red, sin rehenes, sin ciudad. La Última Danza cierra la saga de La Ciudadela.',
        bossName: 'El Arquitecto', locationId: 'arena'),
  ],
);
