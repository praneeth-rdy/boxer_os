import '../models/quote.dart';
import '../utils/date_helpers.dart';

/// The bundled quotations, boxing first and other sports after.
const List<Quote> quotes = [
  Quote(
    text: 'Float like a butterfly, sting like a bee.',
    author: 'Muhammad Ali',
    sport: 'Boxing',
  ),
  Quote(
    text:
        "I hated every minute of training, but I said, don't quit. Suffer now "
        'and live the rest of your life as a champion.',
    author: 'Muhammad Ali',
    sport: 'Boxing',
  ),
  Quote(
    text:
        "It isn't the mountains ahead to climb that wear you out; it's the "
        'pebble in your shoe.',
    author: 'Muhammad Ali',
    sport: 'Boxing',
  ),
  Quote(
    text: "Don't count the days; make the days count.",
    author: 'Muhammad Ali',
    sport: 'Boxing',
  ),
  Quote(
    text:
        'The fight is won or lost far away from witnesses, behind the lines, '
        'in the gym, and out there on the road, long before I dance under '
        'those lights.',
    author: 'Muhammad Ali',
    sport: 'Boxing',
  ),
  Quote(
    text: 'Everyone has a plan until they get punched in the mouth.',
    author: 'Mike Tyson',
    sport: 'Boxing',
  ),
  Quote(
    text: "A champion is someone who gets up when he can't.",
    author: 'Jack Dempsey',
    sport: 'Boxing',
  ),
  Quote(
    text:
        'To be a champ you have to believe in yourself when no one else will.',
    author: 'Sugar Ray Robinson',
    sport: 'Boxing',
  ),
  Quote(
    text: 'It is not the size of a man but the size of his heart that matters.',
    author: 'Evander Holyfield',
    sport: 'Boxing',
  ),
  Quote(
    text:
        "If you cheated on that in the dark of the morning, well, you're going "
        'to get found out now, under the bright lights.',
    author: 'Joe Frazier',
    sport: 'Boxing',
  ),
  Quote(
    text:
        "It's tough to get out of bed to do roadwork at 5 a.m. when you've "
        'been sleeping in silk pajamas.',
    author: 'Marvin Hagler',
    sport: 'Boxing',
  ),
  Quote(
    text:
        'You have to know you can win. You have to think you can win. You have '
        'to feel you can win.',
    author: 'Sugar Ray Leonard',
    sport: 'Boxing',
  ),
  Quote(
    text:
        "Boxing is the ultimate challenge. There's nothing that can compare to "
        'testing yourself the way you do every time you step in the ring.',
    author: 'Sugar Ray Leonard',
    sport: 'Boxing',
  ),
  Quote(
    text: 'Hard work. Dedication.',
    author: 'Floyd Mayweather Jr.',
    sport: 'Boxing',
  ),
  Quote(
    text: 'Sure the fight was fixed. I fixed it with a right hand.',
    author: 'George Foreman',
    sport: 'Boxing',
  ),
  Quote(
    text:
        'The hero and the coward both feel the same thing, but the hero uses '
        'his fear, projects it onto his opponent, while the coward runs.',
    author: "Cus D'Amato",
    sport: 'Boxing trainer',
  ),
  Quote(
    text:
        "I've failed over and over and over again in my life. And that is why "
        'I succeed.',
    author: 'Michael Jordan',
    sport: 'Basketball',
  ),
  Quote(
    text:
        "I can accept failure, everyone fails at something. But I can't accept "
        'not trying.',
    author: 'Michael Jordan',
    sport: 'Basketball',
  ),
  Quote(
    text:
        'Everything negative, pressure, challenges, is all an opportunity for '
        'me to rise.',
    author: 'Kobe Bryant',
    sport: 'Basketball',
  ),
  Quote(
    text: "It's not whether you get knocked down; it's whether you get up.",
    author: 'Vince Lombardi',
    sport: 'American football',
  ),
  Quote(
    text:
        'A champion is defined not by their wins but by how they can recover '
        'when they fall.',
    author: 'Serena Williams',
    sport: 'Tennis',
  ),
  Quote(
    text: 'Champions keep playing until they get it right.',
    author: 'Billie Jean King',
    sport: 'Tennis',
  ),
  Quote(
    text: 'Start where you are. Use what you have. Do what you can.',
    author: 'Arthur Ashe',
    sport: 'Tennis',
  ),
  Quote(
    text: "You miss 100 percent of the shots you don't take.",
    author: 'Wayne Gretzky',
    sport: 'Ice hockey',
  ),
  Quote(
    text: 'No human is limited.',
    author: 'Eliud Kipchoge',
    sport: 'Marathon',
  ),
  Quote(
    text:
        "Celebrate what you've accomplished, but raise the bar a little higher "
        'each time you succeed.',
    author: 'Mia Hamm',
    sport: 'Football',
  ),
  Quote(
    text:
        'Success is no accident. It is hard work, perseverance, learning, '
        'studying, sacrifice and most of all, love of what you are doing.',
    author: 'Pele',
    sport: 'Football',
  ),
  Quote(
    text:
        'I fear not the man who has practiced 10,000 kicks once, but I fear '
        'the man who has practiced one kick 10,000 times.',
    author: 'Bruce Lee',
    sport: 'Martial arts',
  ),
  Quote(
    text: "There's no talent here, this is hard work. This is an obsession.",
    author: 'Conor McGregor',
    sport: 'MMA',
  ),
  Quote(
    text: "Don't think about the start of the race, think about the ending.",
    author: 'Usain Bolt',
    sport: 'Sprinting',
  ),
];

/// The same quote for the whole of [day], cycling through the list.
Quote quoteOfTheDay(DateTime day) => quotes[dayOfYear(day) % quotes.length];

/// A stable quote for one session, so the record always shows the same one.
Quote quoteForSession(String recordId) =>
    quotes[recordId.hashCode.abs() % quotes.length];
