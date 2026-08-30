import '../models/boxing_event.dart';

/// The bundled boxing calendar, in date order from January to December.
const List<BoxingEvent> boxingCalendar = [
  BoxingEvent(
    month: 1,
    day: 10,
    year: 1949,
    title: 'George Foreman born',
    blurb:
        'Houston, Texas. Olympic gold at nineteen, heavyweight champion at '
        'twenty-four and again at forty-five.',
    kind: EventKind.birthday,
    legendId: 'foreman',
  ),
  BoxingEvent(
    month: 1,
    day: 12,
    year: 1944,
    title: 'Joe Frazier born',
    blurb:
        "Beaufort, South Carolina. Smokin' Joe, 1964 Olympic champion and the "
        'first man to beat Muhammad Ali.',
    kind: EventKind.birthday,
    legendId: 'frazier',
  ),
  BoxingEvent(
    month: 1,
    day: 17,
    year: 1942,
    title: 'Muhammad Ali born',
    blurb:
        'Louisville, Kentucky. Cassius Clay, later Muhammad Ali, three times '
        'heavyweight champion of the world.',
    kind: EventKind.birthday,
    legendId: 'ali',
  ),
  BoxingEvent(
    month: 1,
    day: 22,
    year: 1973,
    title: 'Foreman stops Frazier',
    blurb:
        'Kingston, Jamaica. Six knockdowns in two rounds; George Foreman '
        'takes the heavyweight title.',
    kind: EventKind.anniversary,
    legendId: 'foreman',
  ),
  BoxingEvent(
    month: 2,
    day: 11,
    year: 1990,
    title: 'Douglas beats Tyson',
    blurb:
        'Tokyo. Buster Douglas, a 42 to 1 underdog, knocks out Mike Tyson in '
        'the tenth round.',
    kind: EventKind.anniversary,
    legendId: 'tyson',
  ),
  BoxingEvent(
    month: 2,
    day: 14,
    year: 1951,
    title: 'Robinson beats LaMotta',
    blurb:
        'Chicago. Sugar Ray Robinson stops Jake LaMotta in the thirteenth '
        'round of their sixth fight to win the middleweight title.',
    kind: EventKind.anniversary,
    legendId: 'robinson',
  ),
  BoxingEvent(
    month: 2,
    day: 24,
    year: 1977,
    title: 'Floyd Mayweather Jr. born',
    blurb:
        'Grand Rapids, Michigan. Fifty wins, no defeats, titles in five '
        'divisions.',
    kind: EventKind.birthday,
    legendId: 'mayweather',
  ),
  BoxingEvent(
    month: 2,
    day: 25,
    year: 1964,
    title: 'Clay beats Liston',
    blurb:
        'Miami Beach. Twenty-two-year-old Cassius Clay becomes heavyweight '
        'champion when Sonny Liston cannot answer the bell for round seven.',
    kind: EventKind.anniversary,
    legendId: 'ali',
  ),
  BoxingEvent(
    month: 3,
    day: 8,
    year: 1971,
    title: 'The Fight of the Century',
    blurb:
        'Madison Square Garden. Joe Frazier beats Muhammad Ali on points; '
        'both men unbeaten going in.',
    kind: EventKind.anniversary,
    legendId: 'frazier',
  ),
  BoxingEvent(
    month: 3,
    day: 21,
    year: 2025,
    title: 'George Foreman dies',
    blurb:
        'Big George, Olympic champion, two-time heavyweight champion and the '
        'oldest ever at forty-five.',
    kind: EventKind.memorial,
    legendId: 'foreman',
  ),
  BoxingEvent(
    month: 3,
    day: 31,
    year: 1878,
    title: 'Jack Johnson born',
    blurb:
        'Galveston, Texas. The first Black heavyweight champion of the world.',
    kind: EventKind.birthday,
    legendId: 'johnson',
  ),
  BoxingEvent(
    month: 4,
    day: 6,
    title: 'International Day of Sport for Development and Peace',
    blurb:
        'A United Nations day marking the opening of the first modern Olympic '
        'Games in Athens in 1896.',
    kind: EventKind.internationalDay,
  ),
  BoxingEvent(
    month: 4,
    day: 12,
    year: 1981,
    title: 'Joe Louis dies',
    blurb:
        'The Brown Bomber, heavyweight champion for almost twelve years, '
        'buried at Arlington National Cemetery.',
    kind: EventKind.memorial,
    legendId: 'louis',
  ),
  BoxingEvent(
    month: 4,
    day: 15,
    year: 1985,
    title: 'Hagler vs Hearns',
    blurb:
        'Caesars Palace, Las Vegas. Three rounds, eight minutes, and a first '
        'round still called the greatest ever.',
    kind: EventKind.anniversary,
  ),
  BoxingEvent(
    month: 4,
    day: 27,
    year: 1956,
    title: 'Marciano retires undefeated',
    blurb:
        'Rocky Marciano announces his retirement as heavyweight champion with '
        'a record of 49 and 0.',
    kind: EventKind.anniversary,
    legendId: 'marciano',
  ),
  BoxingEvent(
    month: 4,
    day: 28,
    year: 1967,
    title: 'Ali refuses induction',
    blurb:
        'Houston. Muhammad Ali refuses to be drafted; he is stripped of his '
        'title the same day.',
    kind: EventKind.anniversary,
    legendId: 'ali',
  ),
  BoxingEvent(
    month: 4,
    day: 30,
    year: 2022,
    title: 'Taylor vs Serrano',
    blurb:
        'Madison Square Garden. Katie Taylor beats Amanda Serrano in the '
        "first women's fight to headline the Garden.",
    kind: EventKind.anniversary,
    legendId: 'taylor',
  ),
  BoxingEvent(
    month: 5,
    day: 3,
    year: 1921,
    title: 'Sugar Ray Robinson born',
    blurb:
        'Ailey, Georgia. The original pound-for-pound best, five times '
        'middleweight champion.',
    kind: EventKind.birthday,
    legendId: 'robinson',
  ),
  BoxingEvent(
    month: 5,
    day: 13,
    year: 1914,
    title: 'Joe Louis born',
    blurb:
        'LaFayette, Alabama. Heavyweight champion 1937 to 1949, twenty-five '
        'title defences.',
    kind: EventKind.birthday,
    legendId: 'louis',
  ),
  BoxingEvent(
    month: 6,
    day: 3,
    year: 2016,
    title: 'Muhammad Ali dies',
    blurb: 'Scottsdale, Arizona. The Greatest, aged seventy-four.',
    kind: EventKind.memorial,
    legendId: 'ali',
  ),
  BoxingEvent(
    month: 6,
    day: 22,
    year: 1938,
    title: 'Louis vs Schmeling II',
    blurb:
        'Yankee Stadium. Joe Louis knocks out Max Schmeling in two minutes '
        'and four seconds.',
    kind: EventKind.anniversary,
    legendId: 'louis',
  ),
  BoxingEvent(
    month: 6,
    day: 23,
    title: 'Olympic Day',
    blurb:
        'Marks the founding of the International Olympic Committee on 23 June '
        '1894.',
    kind: EventKind.internationalDay,
  ),
  BoxingEvent(
    month: 6,
    day: 30,
    year: 1966,
    title: 'Mike Tyson born',
    blurb: 'Brooklyn, New York. The youngest heavyweight champion in history.',
    kind: EventKind.birthday,
    legendId: 'tyson',
  ),
  BoxingEvent(
    month: 7,
    day: 2,
    year: 1986,
    title: 'Katie Taylor born',
    blurb:
        'Bray, Ireland. Five amateur world titles, Olympic gold and '
        'undisputed lightweight champion.',
    kind: EventKind.birthday,
    legendId: 'taylor',
  ),
  BoxingEvent(
    month: 7,
    day: 4,
    year: 1910,
    title: 'Johnson vs Jeffries',
    blurb:
        'Reno, Nevada. Jack Johnson beats the former champion James Jeffries '
        'in the original Fight of the Century.',
    kind: EventKind.anniversary,
    legendId: 'johnson',
  ),
  BoxingEvent(
    month: 8,
    day: 9,
    year: 2012,
    title: "First women's Olympic boxing golds",
    blurb:
        'London. Nicola Adams and Katie Taylor win gold on the first Olympic '
        "day with women's boxing finals.",
    kind: EventKind.anniversary,
    legendId: 'taylor',
  ),
  BoxingEvent(
    month: 8,
    day: 27,
    title: 'International Boxing Day',
    blurb:
        "The IBA's day for the sport, on the anniversary of the first World "
        'Boxing Championships in Havana in 1974.',
    kind: EventKind.internationalDay,
  ),
  BoxingEvent(
    month: 8,
    day: 31,
    year: 1969,
    title: 'Rocky Marciano dies',
    blurb: 'A plane crash in Iowa the day before his forty-sixth birthday.',
    kind: EventKind.memorial,
    legendId: 'marciano',
  ),
  BoxingEvent(
    month: 9,
    day: 1,
    year: 1923,
    title: 'Rocky Marciano born',
    blurb:
        'Brockton, Massachusetts. The only heavyweight champion to retire '
        'undefeated.',
    kind: EventKind.birthday,
    legendId: 'marciano',
  ),
  BoxingEvent(
    month: 9,
    day: 15,
    year: 1978,
    title: 'Ali wins the title a third time',
    blurb:
        'New Orleans. Muhammad Ali outpoints Leon Spinks to become the first '
        'three-time heavyweight champion.',
    kind: EventKind.anniversary,
    legendId: 'ali',
  ),
  BoxingEvent(
    month: 9,
    day: 23,
    year: 1952,
    title: 'Marciano wins the title',
    blurb:
        'Philadelphia. Down in the first round, Rocky Marciano knocks out '
        'Jersey Joe Walcott in the thirteenth.',
    kind: EventKind.anniversary,
    legendId: 'marciano',
  ),
  BoxingEvent(
    month: 10,
    day: 1,
    year: 1975,
    title: 'The Thrilla in Manila',
    blurb:
        "Quezon City. Ali and Frazier's third fight ends after fourteen "
        "rounds when Frazier's corner stops it.",
    kind: EventKind.anniversary,
    legendId: 'ali',
  ),
  BoxingEvent(
    month: 10,
    day: 30,
    year: 1974,
    title: 'The Rumble in the Jungle',
    blurb:
        'Kinshasa. Muhammad Ali knocks out George Foreman in the eighth round '
        'to regain the heavyweight title.',
    kind: EventKind.anniversary,
    legendId: 'ali',
  ),
  BoxingEvent(
    month: 11,
    day: 5,
    year: 1994,
    title: 'Foreman, champion at forty-five',
    blurb:
        'Las Vegas. George Foreman knocks out Michael Moorer to become the '
        'oldest heavyweight champion.',
    kind: EventKind.anniversary,
    legendId: 'foreman',
  ),
  BoxingEvent(
    month: 11,
    day: 7,
    year: 2011,
    title: 'Joe Frazier dies',
    blurb: "Philadelphia. Smokin' Joe, aged sixty-seven.",
    kind: EventKind.memorial,
    legendId: 'frazier',
  ),
  BoxingEvent(
    month: 11,
    day: 22,
    year: 1986,
    title: 'Tyson, youngest champion',
    blurb:
        'Las Vegas. Mike Tyson stops Trevor Berbick in the second round at '
        'twenty years and four months.',
    kind: EventKind.anniversary,
    legendId: 'tyson',
  ),
  BoxingEvent(
    month: 11,
    day: 24,
    year: 2018,
    title: "Mary Kom's sixth world title",
    blurb:
        'New Delhi. Mary Kom wins a record sixth World Championship gold at '
        'thirty-five.',
    kind: EventKind.anniversary,
    legendId: 'kom',
  ),
  BoxingEvent(
    month: 12,
    day: 17,
    year: 1978,
    title: 'Manny Pacquiao born',
    blurb: 'Kibawe, Philippines. World titles in eight divisions.',
    kind: EventKind.birthday,
    legendId: 'pacquiao',
  ),
  BoxingEvent(
    month: 12,
    day: 26,
    year: 1908,
    title: 'Johnson beats Burns',
    blurb:
        'Sydney. Jack Johnson becomes the first Black heavyweight champion of '
        'the world.',
    kind: EventKind.anniversary,
    legendId: 'johnson',
  ),
];

const List<String> _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// The name of [month], 1 for January.
String monthName(int month) => _monthNames[month - 1];

/// The three-letter form of [month], as shown on a calendar tile.
String monthAbbreviation(int month) => monthName(month).substring(0, 3);

/// The events falling on [day]'s month and day, ordered by kind.
List<BoxingEvent> eventsOn(DateTime day) =>
    boxingCalendar
        .where((event) => event.month == day.month && event.day == day.day)
        .toList()
      ..sort((a, b) => a.kind.index.compareTo(b.kind.index));

/// The next [count] events after [from], wrapping round into the new year.
List<BoxingEvent> nextEvents(DateTime from, {int count = 3}) {
  final start = _dayKey(from.month, from.day);
  final ahead = boxingCalendar.where(
    (event) => _dayKey(event.month, event.day) > start,
  );
  final wrapped = boxingCalendar.where(
    (event) => _dayKey(event.month, event.day) <= start,
  );
  return [...ahead, ...wrapped].take(count).toList();
}

int _dayKey(int month, int day) => month * 100 + day;
