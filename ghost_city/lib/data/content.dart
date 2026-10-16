import 'package:latlong2/latlong.dart';

class Story {
  const Story({required this.id, required this.title, required this.year, required this.text, this.premium = false});

  final String id;
  final String title;
  final int year;
  final String text;
  final bool premium;

  /// Rough narration length at a calm reading pace.
  int get minutes => (text.split(' ').length / 140).ceil().clamp(1, 60);
}

class Place {
  const Place({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.year,
    required this.dateLabel,
    required this.image,
    required this.point,
    required this.tagline,
    required this.summary,
    required this.facts,
    required this.stories,
    required this.credit,
  });

  final String id;
  final String name;
  final String city;
  final String country;
  final int year;
  final String dateLabel;
  final String image;
  final LatLng point;
  final String tagline;
  final String summary;
  final List<String> facts;
  final List<Story> stories;
  final String credit;

  int get yearsAgo => DateTime.now().year - year;
  String get location => '$city, $country';
}

class WalkStop {
  const WalkStop({required this.name, this.year, required this.point, required this.narration, this.note});

  final String name;
  final int? year;

  /// Small label shown above the stop name (for example "450 m from the start").
  final String? note;
  final LatLng point;
  final String narration;
}

class Walk {
  const Walk({
    required this.id,
    required this.title,
    required this.city,
    required this.cover,
    required this.minutes,
    required this.distanceKm,
    required this.premium,
    required this.intro,
    required this.stops,
  });

  final String id;
  final String title;
  final String city;
  final String cover;
  final int minutes;
  final double distanceKm;
  final bool premium;
  final String intro;
  final List<WalkStop> stops;
}

class Era {
  const Era(this.label, this.from, this.to);
  final String label;
  final int from;
  final int to;
  bool contains(int year) => year >= from && year <= to;
}

const eras = <Era>[
  Era('All eras', 0, 9999),
  Era('Before 1910', 0, 1909),
  Era('1910s', 1910, 1919),
  Era('1930s', 1930, 1939),
];

const places = <Place>[
  Place(
    id: 'moulin-rouge',
    name: 'Moulin Rouge',
    city: 'Paris',
    country: 'France',
    year: 1914,
    dateLabel: 'c. 1914',
    image: 'assets/photos/moulin_rouge_1914.jpg',
    point: LatLng(48.8841, 2.3322),
    tagline: 'The red windmill of Montmartre, a year before the fire.',
    summary:
        'Opened in October 1889 on the Boulevard de Clichy, the Moulin Rouge turned the foot of Montmartre into the loudest '
        'night in Europe. This colour photograph was made with the autochrome process, the first practical colour photography, '
        'only a few years after the Lumière brothers released it. Within months the hall would burn; it reopened in 1921.',
    facts: [
      'Founded in 1889 by Joseph Oller and Charles Zidler.',
      'Toulouse-Lautrec’s posters made its dancers famous.',
      'A fire destroyed the building in 1915.',
      'Rebuilt and reopened in 1921.',
    ],
    stories: [
      Story(
        id: 'mr-1',
        title: 'The windmill that never ground flour',
        year: 1889,
        text:
            'The sails on the roof never turned a millstone. They were a sign, painted red so you could find them from the far end of '
            'the boulevard. In 1889 Paris was celebrating its Universal Exposition and the brand new Eiffel Tower, and two showmen, '
            'Joseph Oller and Charles Zidler, wanted a hall where workers from Montmartre and bankers from the grand boulevards would '
            'sit side by side. They built a dance floor surrounded by mirrors, a garden behind it, and in that garden a giant plaster '
            'elephant. Inside the elephant, for one franc, a small orchestra played for men only. Out front, under the windmill, the '
            'quadrille dancers kicked so high the whole room could see their petticoats. Visitors called it the can-can. '
            'Stand where the photographer stood and look up: the windmill is still there, rebuilt, still turning for no one.',
      ),
      Story(
        id: 'mr-2',
        title: 'A painter at the corner table',
        year: 1891,
        text:
            'Henri de Toulouse-Lautrec lived a few streets up the hill and drank here most nights. He sat close to the floor with a '
            'sketchbook and drew the dancers as they really looked: tired, sweating, laughing, sharp-elbowed. In 1891 the owners asked '
            'him for a poster. He gave them La Goulue, the star of the quadrille, in a swirl of white skirts with a dark, shadowed '
            'partner in front of her. The poster was pasted across Paris and the city had never seen anything like it. Collectors '
            'peeled them off walls while the glue was still wet. Today those posters hang in museums, and the room that inspired '
            'them is right behind this facade.',
      ),
      Story(
        id: 'mr-3',
        title: 'The night of the fire',
        year: 1915,
        premium: true,
        text:
            'In February 1915, with France at war and most of its young men at the front, fire broke out in the hall. The wooden '
            'interior and the painted sails went up quickly. Neighbours in Montmartre came out in the cold to watch the red windmill '
            'burn red for real. The building you see in this photograph, with its theatre posters and its tower and its little '
            'turret, was lost. It took six years, and the end of the war, before the Moulin Rouge reopened in 1921 with a new '
            'windmill on the roof. The photograph in your lens is one of the last colour images of the original.',
      ),
    ],
    credit: 'Autochrome photograph, c. 1914. Public domain.',
  ),
  Place(
    id: 'detroit-campus-martius',
    name: 'Campus Martius',
    city: 'Detroit',
    country: 'USA',
    year: 1915,
    dateLabel: 'c. 1915',
    image: 'assets/photos/detroit_1915.jpg',
    point: LatLng(42.3317, -83.0466),
    tagline: 'The heart of a city that was about to double in size.',
    summary:
        'Around 1915 Detroit was the fastest-growing big city in America. Ford’s moving assembly line had started in 1913, and '
        'in 1914 Ford announced the five-dollar day. Streetcars and the first automobiles crossed Campus Martius, the central '
        'square where the city’s main avenues meet.',
    facts: [
      'Detroit’s population grew from about 466,000 in 1910 to about 994,000 in 1920.',
      'Ford’s moving assembly line began at Highland Park in 1913.',
      'The old City Hall on the square stood from 1871 to 1961.',
    ],
    stories: [
      Story(
        id: 'det-1',
        title: 'Five dollars a day',
        year: 1914,
        text:
            'On a January morning in 1914, word spread through the city that Henry Ford would pay five dollars for an eight-hour day, '
            'roughly double the going wage. The next day thousands of men lined up in the snow outside the Highland Park plant. '
            'They came from the farms of Michigan, from the American South, from Poland, Italy, Hungary and Lebanon. Many of them '
            'stepped off streetcars right here, in the square in front of you, before heading north up Woodward Avenue. Within a few '
            'years the crowds in this photograph were people who had not lived in Detroit at all when the picture was planned.',
      ),
      Story(
        id: 'det-2',
        title: 'Horses, streetcars and the first traffic',
        year: 1915,
        premium: true,
        text:
            'Look closely at the street in the photograph: horse carriages, open-top automobiles and streetcars share the same '
            'pavement with no lanes and no signals. Detroit would soon be among the first cities to experiment with traffic control, '
            'because nowhere else had so many new cars so quickly. Police officers stood in the middle of intersections waving their '
            'arms, and the city tried painted lines and signal towers. The square you are standing in was one of the busiest '
            'crossings in the Midwest.',
      ),
    ],
    credit: 'Detroit Publishing Co. photograph, c. 1915. Public domain.',
  ),
  Place(
    id: 'buffalo-erie-bank',
    name: 'Erie County Savings Bank',
    city: 'Buffalo',
    country: 'USA',
    year: 1908,
    dateLabel: 'c. 1908',
    image: 'assets/photos/buffalo_1908.jpg',
    point: LatLng(42.8835, -78.8770),
    tagline: 'A granite castle on Niagara Street, built for a boom town.',
    summary:
        'Completed in 1893 to a design by George B. Post, the Erie County Savings Bank looked more like a medieval fortress than a '
        'bank. In 1900 Buffalo was the eighth-largest city in the United States, powered by the Erie Canal, the Great Lakes and '
        'electricity from Niagara Falls. The bank was demolished in 1968.',
    facts: [
      'Designed by architect George B. Post, completed 1893.',
      'Buffalo hosted the Pan-American Exposition in 1901.',
      'The building was demolished in 1968.',
    ],
    stories: [
      Story(
        id: 'buf-1',
        title: 'The city of light',
        year: 1901,
        text:
            'In 1901 Buffalo invited the world to the Pan-American Exposition. Its buildings were covered in thousands of electric '
            'bulbs fed by power from Niagara Falls, and at dusk they switched on together, a sight many visitors had never seen. '
            'It was also at that exposition, in September 1901, that President William McKinley was shot. He died eight days later in '
            'the city. For a few years Buffalo felt like the centre of modern America, and buildings like this granite bank were its '
            'proof.',
      ),
    ],
    credit: 'Detroit Publishing Co. photograph, c. 1908. Public domain.',
  ),
  Place(
    id: 'saratoga-broadway',
    name: 'Broadway & the United States Hotel',
    city: 'Saratoga Springs',
    country: 'USA',
    year: 1905,
    dateLabel: 'c. 1900–1915',
    image: 'assets/photos/saratoga_1905.jpg',
    point: LatLng(43.0798, -73.7857),
    tagline: 'Elm trees, mineral springs and the summer crowd of the Gilded Age.',
    summary:
        'Every summer, wealthy families came to Saratoga Springs for the mineral waters and the horse races. They promenaded under '
        'the elms of Broadway past the United States Hotel, one of the largest hotels in the world, with a long piazza where guests '
        'sat and watched the street. The hotel was demolished in 1946.',
    facts: [
      'Saratoga Race Course opened in 1863.',
      'The United States Hotel was rebuilt in 1874 after a fire.',
      'The hotel was demolished in 1946.',
    ],
    stories: [
      Story(
        id: 'sar-1',
        title: 'Sitting on the piazza',
        year: 1905,
        text:
            'The most popular entertainment at the United States Hotel was simply sitting. Its piazza was lined with rocking chairs, '
            'and guests spent long afternoons watching carriages pass under the elms on Broadway. In the morning they walked to the '
            'springs to drink the mineral water, which tasted of iron and salt and was believed to cure almost anything. In the '
            'afternoon they went to the races. In the evening they dressed for dinner and the grand ballroom. The street in this '
            'photograph is the stage they were all performing on.',
      ),
    ],
    credit: 'Detroit Publishing Co. photograph, c. 1900–1915. Public domain.',
  ),
  Place(
    id: 'new-york-riverfront',
    name: 'Manhattan Riverfront',
    city: 'New York',
    country: 'USA',
    year: 1931,
    dateLabel: 'December 15, 1931',
    image: 'assets/photos/new_york_1931.jpg',
    point: LatLng(40.7440, -73.9710),
    tagline: 'A new skyline rising in the middle of the Depression.',
    summary:
        'By the end of 1931 Manhattan had finished an astonishing building race. The Chrysler Building opened in 1930, the Empire '
        'State Building in May 1931, and the George Washington Bridge that October, all while the Great Depression emptied offices '
        'and closed banks.',
    facts: [
      'The Empire State Building opened on May 1, 1931.',
      'The George Washington Bridge opened on October 25, 1931.',
      'The Chrysler Building opened in 1930.',
    ],
    stories: [
      Story(
        id: 'ny-1',
        title: 'Towers in hard times',
        year: 1931,
        text:
            'The skyline in this photograph was planned in the boom of the late 1920s and finished in the bust that followed. When '
            'the Empire State Building opened in 1931, so much of it stood empty that New Yorkers nicknamed it the Empty State '
            'Building. Down on the waterfront, piers that had been crowded with cargo grew quiet, and men looking for work waited for '
            'a day’s pay unloading ships. Yet the towers kept going up. For many people in the city, the skyline became a promise '
            'that better years would come.',
      ),
    ],
    credit: 'Photograph, December 15, 1931. Public domain.',
  ),
];

const walks = <Walk>[
  Walk(
    id: 'montmartre',
    title: 'Montmartre After Dark',
    city: 'Paris',
    cover: 'assets/photos/moulin_rouge_1914.jpg',
    minutes: 45,
    distanceKm: 1.6,
    premium: false,
    intro: 'Climb from the cabaret lights of the Boulevard de Clichy to the white domes on the hill, through the streets where '
        'modern art was born.',
    stops: [
      WalkStop(
        name: 'Moulin Rouge',
        year: 1889,
        point: LatLng(48.8841, 2.3322),
        narration:
            'Begin under the red windmill. When it opened in 1889, Montmartre was still half village, with vineyards and real '
            'windmills on the hill above you. The cabaret brought the whole city to its doorstep.',
      ),
      WalkStop(
        name: 'Le Bateau-Lavoir',
        year: 1907,
        point: LatLng(48.8866, 2.3380),
        narration:
            'This shabby wooden building of studios, nicknamed the laundry boat, was home to poor young artists. Here, in 1907, '
            'Pablo Picasso painted Les Demoiselles d’Avignon, the picture that opened the door to Cubism.',
      ),
      WalkStop(
        name: 'Au Lapin Agile',
        year: 1880,
        point: LatLng(48.8885, 2.3404),
        narration:
            'A small pink cabaret on the north slope of the hill. Its name comes from a painted sign of a rabbit jumping out of a '
            'pan, by the caricaturist André Gill. Painters and poets sang here for the price of a drink.',
      ),
      WalkStop(
        name: 'Sacré-Cœur',
        year: 1914,
        point: LatLng(48.8867, 2.3431),
        narration:
            'Finish at the top. The basilica took almost forty years to build, from 1875 to 1914, and because of the war it was '
            'only consecrated in 1919. Turn around: all of Paris lies below you.',
      ),
    ],
  ),
  Walk(
    id: 'motor-city',
    title: 'Motor City Rising',
    city: 'Detroit',
    cover: 'assets/photos/detroit_1915.jpg',
    minutes: 70,
    distanceKm: 3.4,
    premium: true,
    intro: 'Walk the downtown that cars built, from the old central square to a railway palace and a tower of the Jazz Age.',
    stops: [
      WalkStop(
        name: 'Campus Martius',
        year: 1915,
        point: LatLng(42.3317, -83.0466),
        narration:
            'Start in the square from the photograph. Around 1915 this was where streetcars, carriages and the new automobiles all '
            'crossed, in a city that was doubling in size within a decade.',
      ),
      WalkStop(
        name: 'Guardian Building',
        year: 1929,
        point: LatLng(42.3297, -83.0459),
        narration:
            'Finished in 1929, just before the crash, this orange-brick skyscraper is covered inside with tiles and mosaics. People '
            'called it the Cathedral of Finance.',
      ),
      WalkStop(
        name: 'Michigan Central Station',
        year: 1913,
        point: LatLng(42.3290, -83.0776),
        narration:
            'Opened in 1913, this grand station welcomed many of the workers who came for jobs in the car plants. It closed in '
            '1988 and stood empty for decades before its restoration.',
      ),
    ],
  ),
  Walk(
    id: 'skyline-1931',
    title: 'The Skyline of 1931',
    city: 'New York',
    cover: 'assets/photos/new_york_1931.jpg',
    minutes: 110,
    distanceKm: 5.8,
    premium: true,
    intro: 'Cross Lower Manhattan to Midtown and see how New York kept building straight up through the Great Depression.',
    stops: [
      WalkStop(
        name: 'Brooklyn Bridge',
        year: 1883,
        point: LatLng(40.7061, -73.9969),
        narration:
            'When it opened in 1883 this was the longest suspension bridge in the world, and its stone towers were taller than '
            'almost everything in the city.',
      ),
      WalkStop(
        name: 'Woolworth Building',
        year: 1913,
        point: LatLng(40.7124, -74.0081),
        narration:
            'Paid for in cash by the five-and-dime king Frank Woolworth, this Gothic tower was the tallest building in the world '
            'from 1913 until 1930.',
      ),
      WalkStop(
        name: 'Empire State Building',
        year: 1931,
        point: LatLng(40.7484, -73.9857),
        narration:
            'Built in about thirteen months and opened in May 1931, it would stay the tallest building in the world for nearly '
            'forty years.',
      ),
    ],
  ),
];

Place placeById(String id) => places.firstWhere((p) => p.id == id, orElse: () => places.first);
