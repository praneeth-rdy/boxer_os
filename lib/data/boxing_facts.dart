import 'dart:math';

import '../models/boxing_fact.dart';
import '../utils/date_helpers.dart';

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
  BoxingFact(
    text:
        'A championship fight is twelve rounds. It was fifteen until the '
        'mid-1980s, when the death of Duk-koo Kim in 1982 pushed the '
        'sanctioning bodies to shorten it.',
    subject: 'Twelve rounds',
  ),
  BoxingFact(
    text:
        'Muhammad Ali refused induction into the US Army in 1967, was stripped '
        'of his title and could not box for more than three years at the peak '
        'of his career.',
    subject: 'Muhammad Ali',
  ),
  BoxingFact(
    text:
        "Mike Tyson's 1990 loss to Buster Douglas in Tokyo is still called the "
        'biggest upset in boxing history. Douglas was a 42 to 1 underdog.',
    subject: 'Buster Douglas',
  ),
  BoxingFact(
    text:
        'Joe Louis knocked out Max Schmeling in 124 seconds in their 1938 '
        'rematch at Yankee Stadium.',
    subject: 'Louis vs Schmeling',
  ),
  BoxingFact(
    text:
        'Sugar Ray Leonard won world titles in five weight divisions, from '
        'welterweight to light heavyweight.',
    subject: 'Sugar Ray Leonard',
  ),
  BoxingFact(
    text:
        'Marvin Hagler legally changed his name to Marvelous Marvin Hagler in '
        '1982.',
    subject: 'Marvin Hagler',
  ),
  BoxingFact(
    text:
        'Lennox Lewis retired as heavyweight champion in 2004 having avenged '
        'both of his professional defeats.',
    subject: 'Lennox Lewis',
  ),
  BoxingFact(
    text:
        "Nicola Adams won the first women's Olympic boxing gold medal at "
        "London 2012, the first Games to include women's boxing.",
    subject: 'Nicola Adams',
  ),
  BoxingFact(
    text: 'Boxing joined the Olympic Games in 1904 in St. Louis.',
    subject: 'Olympic boxing',
  ),
  BoxingFact(
    text:
        'Sugar Ray Robinson won the world middleweight title five separate '
        'times.',
    subject: 'Sugar Ray Robinson',
  ),
  BoxingFact(
    text:
        'Professional fights use 8 ounce or 10 ounce gloves depending on the '
        'weight class.',
    subject: 'Gloves',
  ),
  BoxingFact(
    text:
        "Jack Dempsey against Georges Carpentier in 1921 was boxing's first "
        'million-dollar gate.',
    subject: 'Jack Dempsey',
  ),
  BoxingFact(
    text:
        'Teofilo Stevenson won three Olympic heavyweight gold medals for Cuba, '
        'in 1972, 1976 and 1980, and never turned professional.',
    subject: 'Teofilo Stevenson',
  ),
  BoxingFact(
    text:
        'Manny Pacquiao was elected to the Philippine Senate in 2016 while '
        'still a reigning world champion.',
    subject: 'Manny Pacquiao',
  ),
  BoxingFact(
    text:
        'Mary Kom gave birth to twins in 2007 and won the World Championship '
        'again in 2008.',
    subject: 'Mary Kom',
  ),
  BoxingFact(
    text:
        'Evander Holyfield is the only boxer to have won the world heavyweight '
        'title four times.',
    subject: 'Evander Holyfield',
  ),
];

/// A surface that shows the fact of the day, each on its own sequence.
enum FactSurface { home, progress }

/// Distinct starting points, so the two surfaces never land on the same fact.
const Map<FactSurface, int> _surfaceOffsets = {
  FactSurface.home: 0,
  FactSurface.progress: 19,
};

const int _shuffleSeed = 20260831;

/// Days move several places along the rotation, so a run reads less alike.
const int _dayStride = 7;

/// The list read in a fixed shuffled order, so neighbours are not all one era.
final List<BoxingFact> _rotation = List.of(boxingFacts)
  ..shuffle(Random(_shuffleSeed));

/// The same fact for the whole of [day] on [surface], cycling through the list.
BoxingFact factFor(FactSurface surface, DateTime day) {
  final step = dayOfYear(day) * _dayStride + _surfaceOffsets[surface]!;
  return _rotation[step % _rotation.length];
}

/// The fact after [current] in the rotation, wrapping at the end.
BoxingFact factAfter(BoxingFact current) {
  final index = _rotation.indexOf(current);
  return _rotation[(index + 1) % _rotation.length];
}

/// A stable fact for one session, so the record always shows the same one.
BoxingFact factForSession(String recordId) =>
    boxingFacts[recordId.hashCode.abs() % boxingFacts.length];
