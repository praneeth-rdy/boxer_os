import '../models/boxing_fact.dart';
import '../utils/date_helpers.dart';

/// Keeps the daily fact and the daily quote from turning over on the same index.
const int _dayOffset = 7;

/// The bundled pieces of boxing history.
const List<BoxingFact> boxingFacts = [
  BoxingFact(
    text:
        'Rocky Marciano retired in 1956 as heavyweight champion with a 49-0 '
        'record, the only heavyweight champion to retire undefeated.',
    subject: 'Rocky Marciano',
  ),
  BoxingFact(
    text:
        'Muhammad Ali won the world heavyweight title three separate times: '
        '1964, 1974 and 1978.',
    subject: 'Muhammad Ali',
  ),
  BoxingFact(
    text:
        'Mike Tyson became the youngest heavyweight champion in history at 20 '
        'years and 4 months when he stopped Trevor Berbick in 1986.',
    subject: 'Mike Tyson',
  ),
  BoxingFact(
    text:
        'George Foreman regained the heavyweight title at 45 in 1994, twenty '
        'years after losing it to Ali, making him the oldest heavyweight '
        'champion ever.',
    subject: 'George Foreman',
  ),
  BoxingFact(
    text:
        'Archie Moore scored more than 130 knockouts in his career, still the '
        'most of any boxer.',
    subject: 'Archie Moore',
  ),
  BoxingFact(
    text:
        'Sugar Ray Robinson went 91 fights without a defeat between 1943 and '
        '1951.',
    subject: 'Sugar Ray Robinson',
  ),
  BoxingFact(
    text:
        'Joe Louis held the heavyweight title for almost 12 years and defended '
        "it 25 times, the longest reign in the division's history.",
    subject: 'Joe Louis',
  ),
  BoxingFact(
    text:
        'Bernard Hopkins won a world title at 49 years old in 2014, the oldest '
        'boxer ever to do so.',
    subject: 'Bernard Hopkins',
  ),
  BoxingFact(
    text: 'Floyd Mayweather Jr. retired with a 50-0 professional record.',
    subject: 'Floyd Mayweather Jr.',
  ),
  BoxingFact(
    text:
        'Manny Pacquiao is the only boxer to win world titles in eight '
        'different weight divisions.',
    subject: 'Manny Pacquiao',
  ),
  BoxingFact(
    text:
        'Julio Cesar Chavez went unbeaten in his first 87 professional fights.',
    subject: 'Julio Cesar Chavez',
  ),
  BoxingFact(
    text:
        'Wilfred Benitez became a world champion at 17, the youngest in boxing '
        'history, in 1976.',
    subject: 'Wilfred Benitez',
  ),
  BoxingFact(
    text:
        'Hagler vs Hearns in 1985 lasted less than eight minutes; its first '
        'round is still called the greatest round in boxing.',
    subject: 'Hagler vs Hearns',
  ),
  BoxingFact(
    text:
        'At the Rumble in the Jungle in 1974, Ali let the previously unbeaten '
        'George Foreman punch himself out on the ropes, then knocked him out '
        'in the eighth round.',
    subject: 'Rumble in the Jungle',
  ),
  BoxingFact(
    text:
        "The Thrilla in Manila in 1975 ended when Joe Frazier's corner stopped "
        'the fight after the 14th round; Ali said it was the closest he had '
        'come to dying.',
    subject: 'Thrilla in Manila',
  ),
  BoxingFact(
    text:
        'Vasiliy Lomachenko won a world title in only his third professional '
        'fight, after an amateur record of 396 wins and 1 loss.',
    subject: 'Vasiliy Lomachenko',
  ),
  BoxingFact(
    text:
        'Oleksandr Usyk became the first undisputed heavyweight champion of '
        'the four-belt era in 2024.',
    subject: 'Oleksandr Usyk',
  ),
  BoxingFact(
    text:
        'Claressa Shields is the first American boxer, man or woman, to win '
        'two Olympic gold medals, in 2012 and 2016.',
    subject: 'Claressa Shields',
  ),
  BoxingFact(
    text:
        "Katie Taylor vs Amanda Serrano in 2022 was the first women's fight to "
        'headline Madison Square Garden.',
    subject: 'Katie Taylor',
  ),
  BoxingFact(
    text:
        'Mary Kom won six World Championship gold medals, the only woman in '
        'boxing history to do so.',
    subject: 'Mary Kom',
  ),
  BoxingFact(
    text:
        "Vijender Singh won India's first Olympic boxing medal, a bronze, at "
        'Beijing 2008.',
    subject: 'Vijender Singh',
  ),
  BoxingFact(
    text:
        'Jack Johnson became the first Black heavyweight champion of the world '
        'in 1908.',
    subject: 'Jack Johnson',
  ),
  BoxingFact(
    text:
        'The Marquess of Queensberry Rules, published in 1867, gave boxing its '
        'gloves and its three-minute rounds.',
    subject: 'Queensberry Rules',
  ),
  BoxingFact(
    text:
        'The longest gloved fight on record, Andy Bowen vs Jack Burke in 1893, '
        'went 110 rounds and more than seven hours before being declared a no '
        'contest.',
    subject: 'Bowen vs Burke',
  ),
];

/// The same fact for the whole of [day], cycling through the list.
BoxingFact factOfTheDay(DateTime day) =>
    boxingFacts[(dayOfYear(day) + _dayOffset) % boxingFacts.length];

/// A stable fact for one session, so the record always shows the same one.
BoxingFact factForSession(String recordId) =>
    boxingFacts[recordId.hashCode.abs() % boxingFacts.length];
