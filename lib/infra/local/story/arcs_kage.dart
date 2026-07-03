// lib/infra/local/story/arcs_kage.dart
//
// KAGE (NINJA) — Serie "La Sombra" en 4 actos.
// Acto I: el Gran Torneo (la deserción). Acto II: el Maestro del Clan cobra
// las deudas huérfanas. Acto III: infiltración en el Nuevo Consejo. Acto IV:
// el Asedio — el frente de las sombras.

import '../../../domain/entities/battle_state.dart' show BotDifficulty;
import '../../../domain/entities/story_arc.dart';
import 'story_helpers.dart';

final List<StoryArc> kageArcs = [
  _actoI,
  _actoII,
  _actoIII,
  _actoIV,
];

// ─── ACTO I (common) — La Sombra Tiene Nombre ────────────────────────────────

final StoryArc _actoI = StoryArc(
  heroId: 'kage',
  rarity: 'common',
  title: 'La Sombra Tiene Nombre',
  coverSubtitle: 'El Gran Torneo — la misma semana, cinco caminos',
  synopsis:
      'El Clan le ordena a Kage eliminar a un monje Shaolin antes del Gran '
      'Torneo. Pero Kage pregunta lo que un ninja nunca pregunta: por qué. '
      'La respuesta tiene nombre — el Consejo Sombra — y esa noche una sombra '
      'elige, por primera vez, su propia razón.',
  stages: [
    dialogue(0, 'Los Tejados de La Ciudadela', locationId: 'ciudadela_calles', [
      line('maestro_clan', 'Maestro del Clan',
          'El objetivo entra al torneo esta semana. Un luchador Shaolin. Viejo. Fácil.'),
      line('kage', 'Kage', '¿Cuál es el crimen?', left: false),
      line('maestro_clan', 'Maestro del Clan',
          'Los que mandan no explican. Ni nosotros preguntamos.'),
      line('kage', 'Kage', 'Entendido.', left: false),
      narrator(
          'Pero Kage sí preguntó. En silencio. Y lo que encontró cambió todo.'),
    ]),
    battle(1, 'mila', BotDifficulty.easy,
        'Una capoeirista cruzó tu camino antes de que puedas investigar. Resolvé esto rápido.',
        locationId: 'puerto'),
    dialogue(2, 'La Biblioteca del Templo', locationId: 'montana_sagrada', [
      line('kage', 'Kage',
          'El monje al que debo eliminar está investigando al Consejo Sombra.',
          left: false, bubble: BubbleType.thought),
      line('kage', 'Kage',
          'Alguien dentro del Clan lo contrató para silenciarlo. Alguien que pertenece al Consejo.',
          left: false, bubble: BubbleType.thought),
      line('mila', 'Mila',
          '¿Hablás solo entre los tejados o tenés la costumbre de pensar en voz alta?',
          emotion: 'smirk'),
      line('kage', 'Kage', 'Seguirme fue un error.', left: false),
      line('mila', 'Mila',
          'Quizás. O quizás soy la única que puede ayudarte a salir de este lío.'),
    ]),
    battle(3, 'puo_liu', BotDifficulty.normal,
        'El monje Shaolin te confundió con un asesino. Tenés que detenerlo sin lastimarle.',
        locationId: 'montana_sagrada'),
    dialogue(4, 'Las Catacumbas', locationId: 'catacumbas', [
      line('kage', 'Kage',
          'El Clan sabe que no cumplí la misión. Ya hay sicarios tras mis pasos.',
          left: false),
      line('mila', 'Mila', 'Bienvenido a mi mundo. Llevo años siendo perseguida.'),
      line('kage', 'Kage', '¿Por qué me ayudás? No me conocés.', left: false),
      line('mila', 'Mila',
          'Conozco el tipo de decisión que tomaste. Es la única que importa.'),
      line('kage', 'Kage',
          'El que me manda desde el Clan se llama El Arquitecto.', left: false),
      line('mila', 'Mila', '¿El fundador del Consejo Sombra?',
          emotion: 'shocked'),
      line('kage', 'Kage', 'Y alguien tiene que detenerlo. Hoy.',
          left: false, emotion: 'determined'),
    ]),
    battle(5, 'ryoto', BotDifficulty.hard,
        'Un mercenario contratado por el Clan. Bloquea el único camino hacia el Arquitecto.',
        bossName: 'Mercenario del Clan', locationId: 'catacumbas'),
    dialogue(6, 'El Puente Roto', locationId: 'puerto', [
      line('kage', 'Kage',
          'Lo que queda del Clan lo sé. Me entrenaron para esto.', left: false),
      line('mila', 'Mila', '¿Y si dentro del torneo hay más del Consejo?'),
      line('kage', 'Kage',
          'Los hay. El torneo es su trampa perfecta. Todos los guerreros en un lugar, sin sospechar nada.',
          left: false),
      line('mila', 'Mila', '¿Y el monje Shaolin?'),
      line('kage', 'Kage', 'Está vivo. Lo mantengo vivo.', left: false),
      line('mila', 'Mila', 'Eso tiene que contar para algo.'),
      line('kage', 'Kage', 'Tiene que contar para todo.', left: false),
    ]),
    battle(7, 'kai', BotDifficulty.hard,
        'Kai te confundió con un agente del Consejo. Un malentendido que se resuelve en el ring.',
        locationId: 'barrio_sur'),
    dialogue(8, 'El Corazón de la Arena', locationId: 'arena', [
      line('puo_liu', 'Puo Liu',
          'Así que eras vos quien cuidaba a mi maestro.'),
      line('kage', 'Kage', 'Guardalo entre nosotros.', left: false),
      line('puo_liu', 'Puo Liu',
          'El Arquitecto está esperando en la cima de la Arena. Sabe que venís.'),
      line('kage', 'Kage', 'Bien. Que me espere.',
          left: false, emotion: 'determined'),
      line('mila', 'Mila', 'Kage. Si no volvés...', emotion: 'sad'),
      line('kage', 'Kage',
          'Siempre vuelvo. Soy una sombra. Las sombras no mueren.',
          left: false, sfx: 'FIUUM'),
    ]),
    battle(9, 'puo_liu', BotDifficulty.hard,
        'El Arquitecto. El cerebro detrás del Consejo Sombra. Este es el combate más importante de tu vida.',
        bossName: 'El Arquitecto', locationId: 'arena'),
  ],
);

// ─── ACTO II (rare) — Las Deudas Huérfanas ───────────────────────────────────

final StoryArc _actoII = StoryArc(
  heroId: 'kage',
  rarity: 'rare',
  title: 'Las Deudas Huérfanas',
  coverSubtitle: 'Acto II — el Clan busca un nuevo amo',
  synopsis:
      'Con el Arquitecto caído, las deudas que firmaba quedaron huérfanas... '
      'y el Maestro del Clan, el antiguo mentor de Kage, las reclama como '
      'propias. Un desertor no puede volver al Clan. Pero puede vaciarlo, '
      'deuda por deuda, persona por persona.',
  stages: [
    dialogue(0, 'Los Tejados del Distrito Ninja', locationId: 'ciudadela_calles', [
      narrator(
          'Tres meses después del torneo. El Clan sin el Consejo era un cuerpo sin cabeza. Hasta que la vieja cabeza volvió a hablar.'),
      line('kage', 'Kage',
          'El Maestro del Clan está cobrando las deudas del Arquitecto. Como si las hubiera heredado.',
          left: false, bubble: BubbleType.thought),
      line('mila', 'Mila',
          'Los papeles de Lucas quedaron cancelados cuando cayó el Consejo. Eso es un precedente. Si liberamos uno, liberamos a todos.'),
      line('kage', 'Kage',
          'Entonces empecemos por los que no pueden pelear por sí mismos.',
          left: false, emotion: 'determined'),
    ]),
    battle(1, 'mila_rare', BotDifficulty.normal,
        'El cobrador del distrito este visita a una familia endeudada. Llegaste primero.',
        bossName: 'Cobrador del Distrito', locationId: 'ciudadela_calles'),
    dialogue(2, 'El Dojo Abandonado', locationId: 'dojo', [
      line('maestro_clan', 'Maestro del Clan',
          'Kage. Mi mejor sombra. Volvés a casa... ¿o venís a robarme?'),
      line('kage', 'Kage',
          'Esas deudas nunca fueron tuyas. Eran del Arquitecto. Y el Arquitecto cayó.',
          left: false),
      line('maestro_clan', 'Maestro del Clan',
          'Los contratos no mueren con los hombres, muchacho. Yo te enseñé eso.'),
      line('kage', 'Kage', 'Me enseñaste a obedecer. Aprendí a elegir.',
          left: false, emotion: 'angry'),
      line('maestro_clan', 'Maestro del Clan',
          'Entonces elegiste morir como un traidor.', bubble: BubbleType.shout),
    ]),
    battle(3, 'kage_rare', BotDifficulty.normal,
        'Las sombras que entrenaron con vos ahora te cazan. Conocen tus trucos. Vos conocés los suyos.',
        bossName: 'Sombra del Clan', locationId: 'catacumbas'),
    dialogue(4, 'El Refugio de los Liberados', locationId: 'puerto', [
      line('lucas', 'Lucas',
          'Ya somos veinte los que salimos del Clan gracias a ustedes. La gente pregunta quién es el ninja que rompe contratos.'),
      line('kage', 'Kage', 'Que sigan preguntando.', left: false),
      line('mila', 'Mila',
          'Veinte de cientos, Kage. Y el Maestro reescribe las deudas más rápido de lo que las quemamos.'),
      line('kage', 'Kage',
          'Porque atacamos las hojas. Hay que cortar la raíz: el libro maestro de contratos. Lo guarda con su vida.',
          left: false),
      line('mila', 'Mila', 'Entonces vamos por su vida... digo, por el libro.',
          emotion: 'smirk'),
    ]),
    battle(5, 'ryoto_rare', BotDifficulty.hard,
        'El guardián del archivo del Clan no duerme. Hoy va a desear haber dormido.',
        bossName: 'Guardián del Archivo', locationId: 'catacumbas'),
    dialogue(6, 'La Cámara de los Contratos', locationId: 'catacumbas', [
      narrator(
          'El libro maestro: trescientos nombres, trescientas vidas hipotecadas con la firma del Arquitecto.'),
      line('kage', 'Kage',
          'Cada página es una familia. El Maestro no cobra dinero... cobra obediencia.',
          left: false),
      line('mila', 'Mila', '¿Lo quemamos?'),
      line('kage', 'Kage',
          'No. Lo publicamos. Que toda La Ciudadela vea cómo se construye un clan de sombras.',
          left: false, emotion: 'determined'),
      line('mila', 'Mila', 'Empezás a pensar como una persona libre.',
          emotion: 'smirk'),
    ]),
    battle(7, 'kai_rare', BotDifficulty.hard,
        'El matón de confianza del Maestro custodia la salida. Grande, lento, y muy enojado.',
        bossName: 'El Puño del Clan', locationId: 'catacumbas'),
    dialogue(8, 'El Techo del Mundo', locationId: 'ciudadela_calles', [
      line('maestro_clan', 'Maestro del Clan',
          'Trescientos contratos, Kage. ¿Sabés cuánto vale eso?'),
      line('kage', 'Kage', 'Sé exactamente cuánto vale. Nada. Desde esta noche.',
          left: false),
      line('maestro_clan', 'Maestro del Clan',
          'Te di un nombre. Te di un techo. Te di un arte.',
          emotion: 'angry'),
      line('kage', 'Kage',
          'Me diste una jaula con vista. La diferencia la aprendí afuera.',
          left: false, sfx: '¡FIUUM!'),
    ]),
    battle(9, 'mila_rare', BotDifficulty.hard,
        'El Maestro del Clan. Tu mentor, tu carcelero, tu pasado. Las deudas huérfanas mueren con su imperio.',
        bossName: 'Maestro del Clan', locationId: 'ciudadela_calles'),
  ],
);

// ─── ACTO III (epic) — El Infiltrado ─────────────────────────────────────────

final StoryArc _actoIII = StoryArc(
  heroId: 'kage',
  rarity: 'epic',
  title: 'El Infiltrado',
  coverSubtitle: 'Acto III — volver a ser sombra para seguir libre',
  synopsis:
      'Un "Nuevo Consejo" con cara legal recluta a los restos del Clan. Kage '
      'descubre la verdad que nadie quiere creer — el Arquitecto está vivo — '
      'y para probarlo debe hacer lo impensable: volver a ponerse la máscara '
      'ante los ojos de Mila.',
  stages: [
    dialogue(0, 'El Refugio de los Liberados', locationId: 'puerto', [
      line('kage', 'Kage',
          'El Nuevo Consejo recluta sombras. Pagan el doble y no preguntan pasado.',
          left: false),
      line('mila', 'Mila', 'Sombras sin Clan buscando amo. Qué oportuno.'),
      line('kage', 'Kage',
          'Demasiado oportuno. La estructura, los contratos, los códigos... es la misma mano. Lo conozco.',
          left: false, bubble: BubbleType.thought),
      line('mila', 'Mila', 'El Arquitecto cayó, Kage. Lo vimos caer.',
          emotion: 'shocked'),
      line('kage', 'Kage',
          'Vimos caer a un hombre. Yo necesito ver el cuerpo del sistema. Y para eso... tengo que entrar.',
          left: false),
    ]),
    battle(1, 'kage_epic', BotDifficulty.hard,
        'La prueba de ingreso del Nuevo Consejo: derrotar a su mejor recluta. Sin nombre, sin preguntas.',
        bossName: 'Recluta de Élite', locationId: 'catacumbas'),
    dialogue(2, 'La Sede del Nuevo Consejo', locationId: 'ciudadela_calles', [
      line('dama_contratos', 'La Dama de los Contratos',
          'Bienvenido, sombra. Tu reputación te precede: el ninja que traicionó al Clan.'),
      line('kage', 'Kage', 'El Clan me traicionó primero. Yo solo cobré.',
          left: false),
      line('dama_contratos', 'La Dama de los Contratos',
          'Perfecto. Los rencorosos son los empleados más leales. Firmá acá.'),
      narrator(
          'Kage firmó con tinta que reconocería cualquier archivista del viejo Consejo. El anzuelo estaba puesto... en ambas direcciones.'),
    ]),
    battle(3, 'ryoto_epic', BotDifficulty.hard,
        'Tu primera "misión" para el Nuevo Consejo: interceptar a un investigador de la Federación. Fingir lealtad tiene un precio.',
        bossName: 'Investigador Federal', locationId: 'dojo'),
    dialogue(4, 'El Tejado del Refugio', locationId: 'puerto', [
      line('mila', 'Mila',
          'Te vieron con la Dama de los Contratos. Con la máscara puesta. ¿Es cierto?',
          emotion: 'angry'),
      line('kage', 'Kage', 'Es cierto.', left: false),
      line('mila', 'Mila',
          '¿Y esperás que crea que es un plan y no una recaída?',
          bubble: BubbleType.shout),
      line('kage', 'Kage',
          'Espero que recuerdes quién elegí ser cuando nadie me obligaba. Es todo lo que tengo para ofrecer.',
          left: false, emotion: 'sad'),
      line('mila', 'Mila',
          '...Volvé con la prueba, Kage. Y con la máscara rota.',
          emotion: 'determined'),
    ]),
    battle(5, 'kai_epic', BotDifficulty.hard,
        'El Nuevo Consejo sospecha. Su verificador de lealtades te pone a prueba con un combate sin reglas.',
        bossName: 'El Verificador', locationId: 'catacumbas'),
    dialogue(6, 'El Despacho Prohibido', locationId: 'catacumbas', [
      narrator(
          'En el último piso de la sede, detrás de tres puertas sin cerradura — porque nadie se atrevía a abrirlas — Kage encontró la firma.'),
      line('kage', 'Kage',
          'Contratos nuevos. Tinta fresca. Y la misma letra que me daba órdenes en el Clan.',
          left: false, bubble: BubbleType.thought),
      line('arquitecto', 'El Arquitecto',
          'Una sombra en mi despacho. Qué nostálgico... ¿viniste a pedir trabajo, Kage? Ya trabajás para mí.',
          bubble: BubbleType.whisper, sfx: '¡!'),
      line('kage', 'Kage', 'Vine a confirmar un rumor. Gracias por el autógrafo.',
          left: false, emotion: 'smirk'),
    ]),
    battle(7, 'mila_epic', BotDifficulty.hard,
        'La Dama de los Contratos sella la sede. Nadie sale con lo que vos sabés. Nadie salió nunca.',
        bossName: 'La Dama de los Contratos', locationId: 'catacumbas'),
    dialogue(8, 'El Refugio, al amanecer', locationId: 'puerto', [
      line('kage', 'Kage',
          'Está vivo. Firmó doscientos contratos este mes. El Nuevo Consejo es el viejo, con abogados.',
          left: false),
      line('mila', 'Mila', '¿Y la máscara?'),
      line('kage', 'Kage', 'Rota. Como prometí.',
          left: false, sfx: 'CRACK'),
      line('mila', 'Mila',
          'Entonces llevemos la prueba a los demás. Puo Liu tiene una ceremonia que arruinar.',
          emotion: 'determined'),
      line('kage', 'Kage',
          'Queda un cabo suelto: el Verdugo sabe mi cara. Si llega a la sede antes que nosotros...',
          left: false),
    ]),
    battle(9, 'ryoto_epic', BotDifficulty.hard,
        'El Verdugo del Consejo, en el único puente de salida. La prueba viaja con vos o no viaja.',
        bossName: 'El Verdugo del Consejo', locationId: 'puerto'),
  ],
);

// ─── ACTO IV (legendary) — El Asedio: Las Sombras ────────────────────────────

final StoryArc _actoIV = StoryArc(
  heroId: 'kage',
  rarity: 'legendary',
  title: 'La Última Sombra',
  coverSubtitle: 'Acto IV — el Asedio de La Ciudadela',
  synopsis:
      'La noche del Asedio, el Arquitecto suelta a todos los sicarios que le '
      'quedan sobre La Ciudadela. Kage toma el frente de las sombras: apagar '
      'la red de asesinos y llegar al techo de la Arena. Una sombra contra '
      'todas las sombras.',
  stages: [
    dialogue(0, 'Los Tejados, medianoche', locationId: 'ciudadela_calles', [
      narrator(
          'La noche del Asedio. Cada tejado de La Ciudadela tenía una sombra. Ninguna era amiga.'),
      line('kage', 'Kage',
          'Doce células de sicarios activas. Órdenes selladas. Objetivos: los cuatro que me importan.',
          left: false, bubble: BubbleType.thought),
      line('mila', 'Mila',
          'Yo libero los rehenes de la Arena. Vos apagá las sombras. Y Kage... esta vez sí volvé.'),
      line('kage', 'Kage', 'Esta vez vuelvo con el amanecer.',
          left: false, emotion: 'determined'),
    ]),
    battle(1, 'kage_legendary', BotDifficulty.hard,
        'La primera célula acecha el hospital del Barrio Sur. Se apaga en silencio, antes de que nadie sepa que existió.',
        bossName: 'Célula Nocturna', locationId: 'barrio_sur'),
    dialogue(2, 'El Campanario', locationId: 'ciudadela_calles', [
      line('kage', 'Kage',
          'Ocho células menos. El Arquitecto va a notar el silencio.',
          left: false, bubble: BubbleType.thought),
      line('lucas', 'Lucas',
          '¡Kage! Los liberados tomaron el distrito este. Doscientos ex-Clan pelean por la ciudad esta noche.'),
      line('kage', 'Kage', '¿Quién los organizó?', left: false,
          emotion: 'shocked'),
      line('lucas', 'Lucas',
          'Vos. Cada contrato que rompiste esta noche pelea de vuelta.',
          emotion: 'determined'),
    ]),
    battle(3, 'puo_liu_legendary', BotDifficulty.hard,
        'El asesino personal del Arquitecto espera en el campanario. El duelo que el Clan siempre quiso ver.',
        bossName: 'El Primer Cuchillo', locationId: 'ciudadela_calles'),
    dialogue(4, 'Las Alcantarillas de la Arena', locationId: 'catacumbas', [
      line('kage', 'Kage',
          'La red de túneles está minada de trampas. Diseño del Clan. Diseño mío, en realidad.',
          left: false),
      line('mila', 'Mila', '¿Diseñaste las trampas que nos van a matar?',
          emotion: 'shocked'),
      line('kage', 'Kage',
          'Diseñé las trampas. Por eso sé exactamente dónde no pisar. Seguime.',
          left: false, emotion: 'smirk'),
      narrator('Y por primera vez en su vida, Kage guio a alguien hacia la luz.'),
    ]),
    battle(5, 'mila_legendary', BotDifficulty.hard,
        'La guardiana de los túneles: la única sombra que el Clan consideraba superior a Kage. Hasta hoy.',
        bossName: 'La Guardiana', locationId: 'catacumbas'),
    dialogue(6, 'El Techo de la Arena', locationId: 'arena', [
      narrator(
          'Sobre la Arena tomada, el viento. Abajo, el falso torneo del Arquitecto. Kage llegó por donde nadie mira: arriba.'),
      line('arquitecto', 'El Arquitecto',
          'Mi sombra favorita. ¿Sabés por qué nunca mandé matarte, Kage?'),
      line('kage', 'Kage', 'Porque no encontraste a nadie capaz.',
          left: false, emotion: 'smirk'),
      line('arquitecto', 'El Arquitecto',
          'Porque sos mi obra maestra. Todo lo que sabés, te lo di yo.',
          bubble: BubbleType.whisper),
      line('kage', 'Kage',
          'Todo lo que soy lo elegí yo. Esa es la parte que nunca vas a entender.',
          left: false, emotion: 'determined', sfx: '¡FIUUM!'),
    ]),
    battle(7, 'kai_legendary', BotDifficulty.hard,
        'El último escudo del Arquitecto: el campeón comprado del falso torneo. Entre la sombra y su objetivo.',
        bossName: 'Campeón del Último Torneo', locationId: 'arena'),
    dialogue(8, 'La Cima de la Arena', locationId: 'arena', [
      line('arquitecto', 'El Arquitecto',
          'Si me derrotás, otra sombra tomará mi lugar. Siempre hay otra sombra.'),
      line('kage', 'Kage',
          'Es cierto. Siempre hay otra sombra. Esta noche, todas son mías.',
          left: false),
      narrator(
          'Y sobre los tejados de La Ciudadela, doscientas sombras libres encendieron sus antorchas a la vez.',
          panel: 2),
      line('arquitecto', 'El Arquitecto', '...¿Qué hiciste?',
          emotion: 'shocked', bubble: BubbleType.shout, panel: 3),
      line('kage', 'Kage', 'Elegir. Deberías probarlo.',
          left: false, panel: 3, sfx: '¡RUMBLE!'),
    ]),
    battle(9, 'puo_liu_legendary', BotDifficulty.hard,
        'El Arquitecto, cara a cara con su obra maestra. La sombra que eligió su propia razón termina esto.',
        bossName: 'El Arquitecto', locationId: 'arena'),
  ],
);
