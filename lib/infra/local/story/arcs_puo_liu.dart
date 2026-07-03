// lib/infra/local/story/arcs_puo_liu.dart
//
// PUO LIU (SHAOLIN) — Serie "El Camino del Dragón" en 4 actos.
// Acto I: el Gran Torneo. Acto II: caza al Lugarteniente. Acto III: la
// exposición pública del Nuevo Consejo. Acto IV: el Asedio de La Ciudadela.

import '../../../domain/entities/battle_state.dart' show BotDifficulty;
import '../../../domain/entities/story_arc.dart';
import 'story_helpers.dart';

final List<StoryArc> puoLiuArcs = [
  _actoI,
  _actoII,
  _actoIII,
  _actoIV,
];

// ─── ACTO I (common) — El Gran Torneo ────────────────────────────────────────

final StoryArc _actoI = StoryArc(
  heroId: 'puo_liu',
  rarity: 'common',
  title: 'El Descenso de la Montaña',
  coverSubtitle: 'El Gran Torneo — la misma semana, cinco caminos',
  synopsis:
      'Puo Liu baja de la Montaña Sagrada para representar al Templo en el '
      'Gran Torneo. Pero su maestro desaparece la primera noche, y las pistas '
      'apuntan a una red que nadie quiere nombrar: el Consejo Sombra.',
  stages: [
    dialogue(0, 'La Montaña Sagrada', locationId: 'montana_sagrada', [
      line('maestro_lin', 'Maestro Lin',
          'Puo Liu, hoy bajas de la montaña. No como estudiante. Como representante del Templo.'),
      line('puo_liu', 'Puo Liu', 'Maestro... ¿Estoy listo?',
          left: false, emotion: 'shocked'),
      line('maestro_lin', 'Maestro Lin',
          'Nadie lo está. Pero el torneo no espera. Recuerda: la fuerza sin sabiduría es solo violencia.'),
      line('puo_liu', 'Puo Liu', 'Entiendo, Maestro.', left: false),
      line('maestro_lin', 'Maestro Lin',
          'No entendés. Todavía no. Pero lo harás.'),
    ]),
    battle(1, 'kai', BotDifficulty.easy,
        'Un pendenciero del barrio bajo te bloquea el paso. Tu primer combate en La Ciudadela.',
        bossName: 'Pendenciero del Puerto', locationId: 'ciudadela_calles'),
    dialogue(2, 'Las Calles de La Ciudadela', locationId: 'ciudadela_calles', [
      line('kage', 'Kage', '¿Así que el templo Shaolin manda a un chico?',
          emotion: 'smirk'),
      line('puo_liu', 'Puo Liu', 'Manda a quien es necesario.', left: false),
      line('kage', 'Kage',
          'Tu maestro desapareció anoche. Qué conveniente, justo antes del torneo.'),
      line('puo_liu', 'Puo Liu', '¿Qué sabés de eso?',
          left: false, emotion: 'angry', bubble: BubbleType.shout),
      line('kage', 'Kage',
          'Sé que alguien no quiere que el Templo compita. Y ese alguien no es del Clan.'),
      line('puo_liu', 'Puo Liu', '¿Por qué me contás esto?', left: false),
      line('kage', 'Kage', 'Porque los dos somos peones en el mismo tablero.'),
    ]),
    battle(3, 'kage', BotDifficulty.normal,
        'Kage dice que está de tu lado, pero sus acciones hablan diferente. Demostrá que merecés su respeto.',
        locationId: 'ciudadela_calles'),
    dialogue(4, 'El Mercado Subterráneo', locationId: 'catacumbas', [
      line('puo_liu', 'Puo Liu',
          'Ryoto. Escuché que vos también buscás algo en las sombras de La Ciudadela.',
          left: false),
      line('ryoto', 'Ryoto',
          'Busco al responsable de lo que le pasó a mi sensei. Fue descalificado del torneo hace diez años. Sin razón válida.'),
      line('puo_liu', 'Puo Liu',
          'Mi maestro también desapareció. Alguien los tiene a ambos.',
          left: false),
      line('ryoto', 'Ryoto', 'Entonces tenemos el mismo enemigo.',
          emotion: 'determined'),
      narrator(
          'Los dos guerreros miraron hacia el corazón oscuro de La Ciudadela. El Gran Torneo se acercaba. Y alguien no quería que llegaran a él.'),
    ]),
    battle(5, 'kage', BotDifficulty.hard,
        'El lugarteniente ninja. No va a dejar que sigas avanzando.',
        bossName: 'El Lugarteniente', locationId: 'catacumbas'),
    dialogue(6, 'El Edificio Abandonado', locationId: 'ciudadela_calles', [
      line('ryoto', 'Ryoto', 'Ganaste. Pero el lugarteniente escapó.'),
      line('puo_liu', 'Puo Liu',
          '¿Quién lo financia? ¿Quién mueve estas piezas?', left: false),
      line('ryoto', 'Ryoto',
          'El Consejo Sombra. No son una facción. Son una red. Están en todas las facciones.'),
      line('puo_liu', 'Puo Liu',
          'Entonces cualquiera podría ser uno de ellos.',
          left: false, emotion: 'shocked'),
      line('ryoto', 'Ryoto',
          'Tu maestro lo descubrió. Por eso lo silenciaron.'),
      line('puo_liu', 'Puo Liu',
          'Si llego al final del torneo y lo expongo ante todos...',
          left: false),
      line('ryoto', 'Ryoto', 'No lo van a dejar llegar.'),
    ]),
    battle(7, 'ryoto', BotDifficulty.hard,
        'Ryoto necesita probarte antes de confiar completamente en vos. La alianza se forja en el tatami.',
        locationId: 'dojo'),
    dialogue(8, 'Antesala de la Arena', locationId: 'arena', [
      line('puo_liu', 'Puo Liu', 'Maestro Lin. Estás vivo.',
          left: false, emotion: 'shocked', sfx: '¡!'),
      line('maestro_lin', 'Maestro Lin',
          'Me tenían prisionero. Pero no pudieron callarme para siempre. Kage me encontró.'),
      line('kage', 'Kage',
          'Digamos que yo también tengo cuentas que saldar con el Consejo.',
          left: false),
      line('maestro_lin', 'Maestro Lin',
          'El que te espera al final no es un luchador cualquiera. Es el Arquitecto. Fundó el Consejo hace veinte años.'),
      line('puo_liu', 'Puo Liu', '¿Usted lo conoce?', left: false),
      line('maestro_lin', 'Maestro Lin',
          'Lo conozco. Fui su maestro. Y fue mi mayor fracaso. Ahora es tu turno de corregirlo.',
          emotion: 'sad'),
    ]),
    battle(9, 'kage', BotDifficulty.hard,
        'El Arquitecto. El fundador del Consejo Sombra. Este combate decide el destino del Templo Shaolin y de La Ciudadela.',
        bossName: 'El Arquitecto', locationId: 'arena'),
  ],
);

// ─── ACTO II (rare) — Las Cenizas del Consejo ────────────────────────────────

final StoryArc _actoII = StoryArc(
  heroId: 'puo_liu',
  rarity: 'rare',
  title: 'Las Cenizas del Consejo',
  coverSubtitle: 'Acto II — la red se fragmenta',
  synopsis:
      'El Arquitecto cayó en la Arena... pero escapó en el caos, y su red '
      'sobrevive. El Lugarteniente que huyó durante el torneo ahora roba los '
      'archivos secretos del Templo. Puo Liu baja de la montaña otra vez — '
      'esta vez, como cazador.',
  stages: [
    dialogue(0, 'La Montaña Sagrada', locationId: 'montana_sagrada', [
      narrator(
          'Tres meses después del Gran Torneo. El Consejo Sombra perdió su cabeza, pero el cuerpo sigue moviéndose.'),
      line('maestro_lin', 'Maestro Lin',
          'Anoche entraron a la biblioteca del Templo. Se llevaron los archivos del Consejo... los que yo había escondido.'),
      line('puo_liu', 'Puo Liu', '¿Quién puede escalar la Montaña Sagrada sin ser visto?',
          left: false),
      line('maestro_lin', 'Maestro Lin',
          'Solo un ninja. Y solo uno tiene razones: el Lugarteniente que escapó del torneo.'),
      line('puo_liu', 'Puo Liu', 'Entonces lo voy a encontrar.',
          left: false, emotion: 'determined'),
    ]),
    battle(1, 'kage_rare', BotDifficulty.normal,
        'Un sicario del Clan vigila el único descenso de la montaña. El Lugarteniente sabe que vas tras él.',
        bossName: 'Sicario del Clan', locationId: 'montana_sagrada'),
    dialogue(2, 'Las Calles de La Ciudadela', locationId: 'ciudadela_calles', [
      line('kage', 'Kage', 'Escuché que buscás a mi antiguo colega.'),
      line('puo_liu', 'Puo Liu', 'Robó los archivos del Templo. ¿Vas a ayudarme o a estorbar?',
          left: false),
      line('kage', 'Kage',
          'Ninguna de las dos. Te voy a decir dónde vende la información. El resto es tuyo.',
          emotion: 'smirk'),
      line('puo_liu', 'Puo Liu', '¿Por qué no lo cazás vos?', left: false),
      line('kage', 'Kage',
          'Porque yo estoy cazando algo más grande. Y si te digo qué es, no me lo vas a creer.'),
    ]),
    battle(3, 'mila_rare', BotDifficulty.normal,
        'La compradora de los archivos manda a su guardaespaldas. La subasta no se detiene por un monje.',
        bossName: 'Guardaespaldas del Mercado', locationId: 'catacumbas'),
    dialogue(4, 'El Mercado Subterráneo', locationId: 'catacumbas', [
      narrator('Los archivos ya no estaban. Pero el vendedor dejó un rastro.'),
      line('puo_liu', 'Puo Liu',
          'El Lugarteniente no vende los archivos por dinero. Busca los nombres... está reconstruyendo la lista de miembros del Consejo.',
          left: false),
      line('ryoto', 'Ryoto',
          'Si esa lista se completa, alguien puede rearmar la red entera.'),
      line('puo_liu', 'Puo Liu', '¿Ryoto? ¿Vos también seguís este rastro?',
          left: false, emotion: 'shocked'),
      line('ryoto', 'Ryoto',
          'La Federación tiene sus propias ratas. Todos los caminos salen de la misma cueva.'),
    ]),
    battle(5, 'kage_rare', BotDifficulty.hard,
        'El taller de falsificación del Lugarteniente está protegido. Nadie entra. Vos entrás.',
        bossName: 'El Falsificador', locationId: 'catacumbas'),
    dialogue(6, 'El Puerto de La Ciudadela', locationId: 'puerto', [
      line('puo_liu', 'Puo Liu',
          'El Lugarteniente embarca esta noche. Con los archivos y la lista.',
          left: false),
      line('kage', 'Kage',
          'Si ese barco zarpa, el Consejo renace en otra ciudad. Y todo lo del torneo fue en vano.'),
      line('puo_liu', 'Puo Liu',
          'El Maestro Lin me enseñó que la fuerza sin sabiduría es violencia. Hoy entiendo la otra mitad.',
          left: false),
      line('kage', 'Kage', '¿Cuál es la otra mitad?'),
      line('puo_liu', 'Puo Liu',
          'Que la sabiduría sin acción es cobardía.',
          left: false, emotion: 'determined'),
    ]),
    battle(7, 'ryoto_rare', BotDifficulty.hard,
        'Los estibadores del Clan defienden el muelle. Entre vos y el barco hay una pared de músculos.',
        bossName: 'Capataz del Muelle', locationId: 'puerto'),
    dialogue(8, 'La Cubierta del Barco', locationId: 'puerto', [
      line('lugarteniente', 'El Lugarteniente',
          'El monje del torneo. El Arquitecto me habló de vos.'),
      line('puo_liu', 'Puo Liu', 'El Arquitecto cayó.', left: false),
      line('lugarteniente', 'El Lugarteniente',
          '¿Caer? Los hombres como él no caen. Se hunden... y esperan.',
          bubble: BubbleType.whisper),
      line('puo_liu', 'Puo Liu', '¿Qué querés decir?',
          left: false, emotion: 'shocked'),
      line('lugarteniente', 'El Lugarteniente',
          'Que esta lista no es para mí, chico. Es un encargo. Y el que encarga... paga bien.',
          sfx: '¡FIUUM!'),
    ]),
    battle(9, 'kage_rare', BotDifficulty.hard,
        'El Lugarteniente. El último eslabón libre del viejo Consejo. Los archivos del Templo vuelven a casa esta noche.',
        bossName: 'El Lugarteniente', locationId: 'puerto'),
  ],
);

// ─── ACTO III (epic) — La Carta del Maestro ──────────────────────────────────

final StoryArc _actoIII = StoryArc(
  heroId: 'puo_liu',
  rarity: 'epic',
  title: 'La Carta del Maestro',
  coverSubtitle: 'Acto III — el regreso del Arquitecto',
  synopsis:
      'El Lugarteniente confesó: la lista era un encargo. El Arquitecto está '
      'vivo y construye un "Nuevo Consejo" con cara legal — Federación, '
      'promotores y Clan bajo una misma fachada. El Maestro Lin le confía a '
      'Puo Liu su arma más antigua: la verdad.',
  stages: [
    dialogue(0, 'El Templo Shaolin', locationId: 'montana_sagrada', [
      line('maestro_lin', 'Maestro Lin',
          'Hay algo que nunca te conté sobre el Arquitecto. Su nombre era Wen. Fue mi mejor discípulo.'),
      line('puo_liu', 'Puo Liu', 'Maestro...', left: false),
      line('maestro_lin', 'Maestro Lin',
          'Cuando dejó el Templo le escribí una carta. Nunca la envié. Es la prueba de quién era... y de quién eligió ser.'),
      line('puo_liu', 'Puo Liu', '¿Por qué me la da a mí?', left: false),
      line('maestro_lin', 'Maestro Lin',
          'Porque el Nuevo Consejo se presenta mañana en La Ciudadela. Con traje, con sonrisa y con papeles limpios. Y solo la verdad rompe una máscara.',
          emotion: 'sad'),
    ]),
    battle(1, 'kage_epic', BotDifficulty.hard,
        'Los "asesores de seguridad" del Nuevo Consejo patrullan el camino a la ciudad. Legales por fuera, Clan por dentro.',
        bossName: 'Asesor de Seguridad', locationId: 'ciudadela_calles'),
    dialogue(2, 'La Plaza de la Arena', locationId: 'arena', [
      narrator(
          'El Nuevo Consejo presentó su fundación benéfica ante toda La Ciudadela. Aplausos. Cámaras. Y detrás del telón, la misma sombra.'),
      line('puo_liu', 'Puo Liu',
          'Compraron la Federación, los promotores y media prensa. ¿Quién va a creerle a un monje?',
          left: false),
      line('kage', 'Kage',
          'Nadie. Por eso no vas a hablar vos. Va a hablar su propia letra. ¿La carta menciona el sello del Consejo?'),
      line('puo_liu', 'Puo Liu',
          'Menciona algo mejor: el nombre del hombre que diseñó el sello.',
          left: false, emotion: 'smirk'),
    ]),
    battle(3, 'ryoto_epic', BotDifficulty.hard,
        'El Verdugo del Consejo intercepta a los testigos antes de que hablen. Hoy te toca a vos.',
        bossName: 'El Verdugo del Consejo', locationId: 'ciudadela_calles'),
    dialogue(4, 'La Imprenta Clandestina', locationId: 'catacumbas', [
      line('falsario', 'El Falsario',
          'Así que vos sos el famoso monje. Yo fabrico realidades, ¿sabés? Escrituras, títulos, historias.'),
      line('puo_liu', 'Puo Liu', 'Vos fabricaste la fachada del Nuevo Consejo.',
          left: false),
      line('falsario', 'El Falsario',
          'Fabricé una obra de arte. Cada papel del Nuevo Consejo es perfecto. Excepto uno que no escribí yo...',
          bubble: BubbleType.whisper),
      line('puo_liu', 'Puo Liu', 'La carta del Maestro.', left: false),
      line('falsario', 'El Falsario',
          'El Arquitecto la busca hace veinte años. Si la tenés... ya estás muerto.',
          sfx: '¡CRACK!'),
    ]),
    battle(5, 'kage_epic', BotDifficulty.hard,
        'El Falsario no puede dejar que salgas con lo que sabés. Su taller es su trampa.',
        bossName: 'El Falsario', locationId: 'catacumbas'),
    dialogue(6, 'El Tejado de la Federación', locationId: 'ciudadela_calles', [
      line('kage', 'Kage',
          'Mañana el Nuevo Consejo firma el control del Gran Torneo. Todos los ojos de La Ciudadela van a estar en esa ceremonia.'),
      line('puo_liu', 'Puo Liu', 'Entonces ahí hablamos.', left: false),
      line('kage', 'Kage',
          'Te van a dejar subir al estrado porque creen que tienen comprado el silencio de todos. No compraron el tuyo.'),
      line('puo_liu', 'Puo Liu',
          'El Templo no vende. El Templo recuerda.',
          left: false, emotion: 'determined'),
    ]),
    battle(7, 'kai_epic', BotDifficulty.hard,
        'El campeón fabricado del Consejo custodia el estrado. Un espectáculo antes del verdadero espectáculo.',
        bossName: 'El Campeón de Cristal', locationId: 'arena'),
    dialogue(8, 'El Estrado de la Ceremonia', locationId: 'arena', [
      narrator(
          'Ante toda La Ciudadela, Puo Liu leyó la carta del Maestro Lin. El nombre. Las fechas. El sello. La máscara del Nuevo Consejo se quebró en directo.'),
      line('puo_liu', 'Puo Liu',
          '¡Este hombre no es un filántropo! ¡Es el Arquitecto del Consejo Sombra, y su maestro lo sabía antes que nadie!',
          left: false, bubble: BubbleType.shout, sfx: '¡BOOM!'),
      line('arquitecto', 'El Arquitecto',
          'Puo Liu. El pequeño discípulo del viejo Lin... Me hiciste el favor de reunir a toda la ciudad para verme.',
          bubble: BubbleType.whisper),
      line('puo_liu', 'Puo Liu', '¿Verte caer? Sí. Todos vinieron a eso.',
          left: false, emotion: 'angry'),
    ]),
    battle(9, 'kage_epic', BotDifficulty.hard,
        'El Arquitecto, expuesto ante La Ciudadela, ya no tiene nada que fingir. Guardián del Templo: cumplí tu deber.',
        bossName: 'El Arquitecto', locationId: 'arena'),
  ],
);

// ─── ACTO IV (legendary) — El Asedio: El Templo y la Verdad ──────────────────

final StoryArc _actoIV = StoryArc(
  heroId: 'puo_liu',
  rarity: 'legendary',
  title: 'El Último Torneo',
  coverSubtitle: 'Acto IV — el Asedio de La Ciudadela',
  synopsis:
      'Expuesto y sin máscara, el Arquitecto juega su última carta: toma la '
      'Arena con lo que queda de su red y fuerza "El Último Torneo" con La '
      'Ciudadela como rehén. Cinco héroes, cinco frentes, una noche. Puo Liu '
      'defiende el frente de la verdad: el Templo y su Maestro.',
  stages: [
    dialogue(0, 'La Montaña Sagrada, de noche', locationId: 'montana_sagrada', [
      narrator(
          'La noche del Asedio. La Arena tomada. Y en la montaña, fuegos que no encendió el Templo.'),
      line('maestro_lin', 'Maestro Lin',
          'Vino por mí, Puo Liu. Quiere terminar lo que empezó hace veinte años: borrar al testigo de quién fue.'),
      line('puo_liu', 'Puo Liu',
          'Entonces vamos juntos a la Arena. Esta vez no lo enfrenta usted solo.',
          left: false, emotion: 'determined'),
      line('maestro_lin', 'Maestro Lin',
          'Kage limpia las sombras. Ryoto sostiene las instituciones. Kai levanta a la gente. Mila libera a los rehenes. Y vos...'),
      line('puo_liu', 'Puo Liu', 'Yo llevo la verdad hasta el centro del ring.',
          left: false),
    ]),
    battle(1, 'kage_legendary', BotDifficulty.hard,
        'La vanguardia del Asedio bloquea el descenso. El camino a la Arena se abre a golpes.',
        bossName: 'Vanguardia del Asedio', locationId: 'montana_sagrada'),
    dialogue(2, 'Las Calles en Llamas', locationId: 'ciudadela_calles', [
      line('kai', 'Kai', '¡Puo Liu! El Barrio Sur aguanta. ¿La montaña?'),
      line('puo_liu', 'Puo Liu', 'En pie. ¿La Arena?', left: false),
      line('kai', 'Kai',
          'Tomada. Tiene rehenes en las gradas y un micrófono. Dice que el "Último Torneo" empieza a medianoche... y que el premio es la ciudad.',
          emotion: 'angry'),
      line('puo_liu', 'Puo Liu',
          'Entonces a medianoche tendrá su torneo. Pero no el que planeó.',
          left: false, sfx: '¡TUMP!'),
    ]),
    battle(3, 'ryoto_legendary', BotDifficulty.hard,
        'El Verdugo del Consejo volvió a las calles. Esta vez sin disfraz legal.',
        bossName: 'El Verdugo', locationId: 'ciudadela_calles'),
    dialogue(4, 'Las Puertas de la Arena', locationId: 'arena', [
      line('mila', 'Mila',
          'Los rehenes del ala este ya están fuera. Kage está en el techo. Faltás vos.'),
      line('puo_liu', 'Puo Liu', '¿Y el Maestro?', left: false),
      line('mila', 'Mila',
          'Entró solo. Dijo que tenía una conversación pendiente de veinte años.',
          emotion: 'shocked'),
      line('puo_liu', 'Puo Liu', 'No... esa conversación es una trampa.',
          left: false, emotion: 'angry', bubble: BubbleType.shout),
    ]),
    battle(5, 'kage_legendary', BotDifficulty.hard,
        'La guardia personal del Arquitecto custodia el túnel al ring. Son los últimos. Y lo saben.',
        bossName: 'Guardia del Arquitecto', locationId: 'arena'),
    dialogue(6, 'El Corazón de la Arena', locationId: 'arena', [
      line('arquitecto', 'El Arquitecto',
          'Maestro Lin. Veinte años esperé esta clase final.'),
      line('maestro_lin', 'Maestro Lin',
          'Wen. La clase terminó el día que elegiste el miedo como arma.'),
      line('puo_liu', 'Puo Liu', '¡Maestro! ¡Apártese de él!',
          left: false, bubble: BubbleType.shout, sfx: '¡CRASH!'),
      line('arquitecto', 'El Arquitecto',
          'Ah. El nuevo discípulo. Perfecto: el viejo verá cuál de los dos fue su verdadero fracaso.',
          bubble: BubbleType.whisper),
    ]),
    battle(7, 'ryoto_legendary', BotDifficulty.hard,
        'El Arquitecto pelea primero a través de su campeón final. El ring es suyo. Todavía.',
        bossName: 'Campeón del Último Torneo', locationId: 'arena'),
    dialogue(8, 'El Centro del Ring', locationId: 'arena', [
      narrator(
          'Los frentes cayeron uno a uno. Las sombras, limpias. Las instituciones, en pie. La gente, de pie. Los rehenes, libres. Quedaba un hombre. Y un discípulo.'),
      line('arquitecto', 'El Arquitecto',
          'Todo lo que hice fue orden, Puo Liu. La Ciudadela es caos sin una mano que apriete.'),
      line('puo_liu', 'Puo Liu',
          'La fuerza sin sabiduría es solo violencia. Mi Maestro me lo dijo el primer día. A vos también, ¿no?',
          left: false, emotion: 'determined'),
      line('arquitecto', 'El Arquitecto', '...El viejo y sus frases.',
          emotion: 'angry'),
      line('puo_liu', 'Puo Liu', 'No son frases. Son la lección. Y hoy la aprendés.',
          left: false, sfx: '¡RUMBLE!'),
    ]),
    battle(9, 'kage_legendary', BotDifficulty.hard,
        'El Arquitecto. Sin red, sin máscara, sin ciudad. El Camino del Dragón termina donde empezó: maestro contra discípulo.',
        bossName: 'El Arquitecto', locationId: 'arena'),
  ],
);
