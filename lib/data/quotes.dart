import 'dart:math';

import '../models/quote.dart';
import '../utils/date_helpers.dart';

/// The bundled quotations, most of them from boxing, the rest from other sports.
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
  Quote(
    text: 'I am the greatest. I said that even before I knew I was.',
    author: 'Muhammad Ali',
    sport: 'Boxing',
  ),
  Quote(
    text:
        'He who is not courageous enough to take risks will accomplish nothing '
        'in life.',
    author: 'Muhammad Ali',
    sport: 'Boxing',
  ),
  Quote(
    text: 'The man who has no imagination has no wings.',
    author: 'Muhammad Ali',
    sport: 'Boxing',
  ),
  Quote(
    text:
        "Champions aren't made in gyms. Champions are made from something they "
        'have deep inside them: a desire, a dream, a vision.',
    author: 'Muhammad Ali',
    sport: 'Boxing',
  ),
  Quote(
    text:
        "It's the repetition of affirmations that leads to belief. And once "
        'that belief becomes a deep conviction, things begin to happen.',
    author: 'Muhammad Ali',
    sport: 'Boxing',
  ),
  Quote(
    text: 'What keeps me going is goals.',
    author: 'Muhammad Ali',
    sport: 'Boxing',
  ),
  Quote(
    text:
        'A man who views the world the same at fifty as he did at twenty has '
        'wasted thirty years of his life.',
    author: 'Muhammad Ali',
    sport: 'Boxing',
  ),
  Quote(
    text:
        "I know where I'm going and I know the truth, and I don't have to be "
        "what you want me to be. I'm free to be what I want.",
    author: 'Muhammad Ali',
    sport: 'Boxing',
  ),
  Quote(
    text:
        'Age is whatever you think it is. You are as old as you think you are.',
    author: 'Muhammad Ali',
    sport: 'Boxing',
  ),
  Quote(
    text:
        "It's lack of faith that makes people afraid of meeting challenges, "
        'and I believed in myself.',
    author: 'Muhammad Ali',
    sport: 'Boxing',
  ),
  Quote(
    text: 'The will must be stronger than the skill.',
    author: 'Muhammad Ali',
    sport: 'Boxing',
  ),
  Quote(
    text:
        'Only a man who knows what it is like to be defeated can reach down to '
        'the bottom of his soul and come up with the extra ounce of power it '
        'takes to win when the match is even.',
    author: 'Muhammad Ali',
    sport: 'Boxing',
  ),
  Quote(
    text:
        "I don't count my sit-ups. I only start counting when it starts "
        "hurting, because they're the only ones that count.",
    author: 'Muhammad Ali',
    sport: 'Boxing',
  ),
  Quote(
    text: "I've seen George Foreman shadow boxing, and the shadow won.",
    author: 'Muhammad Ali',
    sport: 'Boxing',
  ),
  Quote(
    text:
        "It's just a job. Grass grows, birds fly, waves pound the sand. I beat "
        'people up.',
    author: 'Muhammad Ali',
    sport: 'Boxing',
  ),
  Quote(
    text:
        "I'm so fast that last night I turned off the light switch in my hotel "
        'room and was in bed before the room was dark.',
    author: 'Muhammad Ali',
    sport: 'Boxing',
  ),
  Quote(
    text:
        'Discipline is doing what you hate to do, but nonetheless doing it '
        'like you love it.',
    author: 'Mike Tyson',
    sport: 'Boxing',
  ),
  Quote(
    text:
        "I'm a dreamer. I have to dream and reach for the stars, and if I miss "
        'a star then I grab a handful of clouds.',
    author: 'Mike Tyson',
    sport: 'Boxing',
  ),
  Quote(
    text: 'As long as we persevere and endure, we can get anything we want.',
    author: 'Mike Tyson',
    sport: 'Boxing',
  ),
  Quote(
    text: 'The temptation for greatness is the biggest drug in the world.',
    author: 'Mike Tyson',
    sport: 'Boxing',
  ),
  Quote(
    text: "He can run, but he can't hide.",
    author: 'Joe Louis',
    sport: 'Boxing',
  ),
  Quote(
    text:
        "Once that bell rings you're on your own. It's just you and the other "
        'guy.',
    author: 'Joe Louis',
    sport: 'Boxing',
  ),
  Quote(
    text: 'Everybody wants to go to heaven, but nobody wants to die.',
    author: 'Joe Louis',
    sport: 'Boxing',
  ),
  Quote(
    text:
        'Rhythm is everything in boxing. Every move you make starts with your '
        "heart, and that's in rhythm or you're in trouble.",
    author: 'Sugar Ray Robinson',
    sport: 'Boxing',
  ),
  Quote(
    text:
        'Boxing is like jazz. The better it is, the less people appreciate it.',
    author: 'George Foreman',
    sport: 'Boxing',
  ),
  Quote(
    text:
        'If they cut my bald head open, they will find one big boxing glove. '
        "That's all I am. I live it.",
    author: 'Marvin Hagler',
    sport: 'Boxing',
  ),
  Quote(
    text: "Boxing is not about your feelings. It's about performance.",
    author: 'Manny Pacquiao',
    sport: 'Boxing',
  ),
  Quote(
    text: 'A true champion can adapt to anything.',
    author: 'Floyd Mayweather Jr.',
    sport: 'Boxing',
  ),
  Quote(
    text:
        "There is always space for improvement, no matter how long you've been "
        'in the business.',
    author: 'Oscar De La Hoya',
    sport: 'Boxing',
  ),
  Quote(
    text: 'Stay hungry, stay humble.',
    author: 'Anthony Joshua',
    sport: 'Boxing',
  ),
  Quote(
    text:
        'Do not let anyone tell you that you are weak because you are a woman.',
    author: 'Mary Kom',
    sport: 'Boxing',
  ),
  Quote(
    text:
        'Fear is like fire. It can cook for you. It can heat your house. Or it '
        'can burn you down.',
    author: "Cus D'Amato",
    sport: 'Boxing trainer',
  ),
  Quote(
    text:
        'Boxing is a contest of character and ingenuity. The boxer with more '
        'will, determination, desire and intelligence is always the one who '
        'comes out the victor.',
    author: "Cus D'Amato",
    sport: 'Boxing trainer',
  ),
  Quote(
    text: "Life doesn't run away from nobody. Life runs at people.",
    author: 'Joe Frazier',
    sport: 'Boxing',
  ),
  Quote(
    text:
        "We're all given some sort of skill in life. Mine just happens to be "
        'beating up on people.',
    author: 'Sugar Ray Leonard',
    sport: 'Boxing',
  ),
  Quote(
    text: 'I fought Sugar Ray so often, I almost got diabetes.',
    author: 'Jake LaMotta',
    sport: 'Boxing',
  ),
  Quote(
    text: 'Pressure is a privilege.',
    author: 'Billie Jean King',
    sport: 'Tennis',
  ),
  Quote(
    text:
        "You can't put a limit on anything. The more you dream, the farther "
        'you get.',
    author: 'Michael Phelps',
    sport: 'Swimming',
  ),
  Quote(
    text: "Don't give up. Don't ever give up.",
    author: 'Jim Valvano',
    sport: 'Basketball coach',
  ),
  Quote(
    text: 'Losing is not my enemy. Fear of losing is my enemy.',
    author: 'Rafael Nadal',
    sport: 'Tennis',
  ),
  Quote(
    text:
        "I'd rather regret the risks that didn't work out than the chances I "
        "didn't take at all.",
    author: 'Simone Biles',
    sport: 'Gymnastics',
  ),
  Quote(
    text:
        "Worrying gets you nowhere. If you turn up worrying about how you're "
        "going to perform, you've already lost.",
    author: 'Usain Bolt',
    sport: 'Sprinting',
  ),
  Quote(
    text:
        'Some people want it to happen, some wish it would happen, others make '
        'it happen.',
    author: 'Michael Jordan',
    sport: 'Basketball',
  ),
  Quote(
    text: 'The only place success comes before work is in the dictionary.',
    author: 'Vince Lombardi',
    sport: 'American football',
  ),
  Quote(
    text:
        'Knowing is not enough, we must apply. Willing is not enough, we must '
        'do.',
    author: 'Bruce Lee',
    sport: 'Martial arts',
  ),
  Quote(
    text:
        'Every day you either get better or you get worse. You never stay the '
        'same.',
    author: 'Bo Schembechler',
    sport: 'American football coach',
  ),
  Quote(
    text: "It's better to look ahead and prepare than to look back and regret.",
    author: 'Jackie Joyner-Kersee',
    sport: 'Athletics',
  ),
  Quote(
    text:
        'We all have dreams. But in order to make dreams come into reality, it '
        'takes an awful lot of determination, dedication, self-discipline and '
        'effort.',
    author: 'Jesse Owens',
    sport: 'Athletics',
  ),
  Quote(
    text:
        'Never underestimate the power of dreams and the influence of the '
        'human spirit.',
    author: 'Wilma Rudolph',
    sport: 'Athletics',
  ),
  Quote(
    text:
        'If you want to win something, run 100 metres. If you want to '
        'experience something, run a marathon.',
    author: 'Emil Zatopek',
    sport: 'Athletics',
  ),
  Quote(
    text: 'Every strike brings me closer to the next home run.',
    author: 'Babe Ruth',
    sport: 'Baseball',
  ),
  Quote(
    text:
        'What would be better than walking down any street in any city and '
        'knowing you were the heavyweight champion of the world?',
    author: 'Rocky Marciano',
    sport: 'Boxing',
  ),
  Quote(
    text:
        'I have found no better way of avoiding race prejudice than to act '
        'with people of other races as if prejudice did not exist.',
    author: 'Jack Johnson',
    sport: 'Boxing',
  ),
  Quote(
    text: "I've been dreaming about this since I was a young girl.",
    author: 'Katie Taylor',
    sport: 'Boxing',
  ),
];

/// A surface that shows the quote of the day, each on its own sequence.
enum QuoteSurface { home, progress, onboarding, reminder }

/// Distinct starting points, so no two surfaces land on the same quote.
const Map<QuoteSurface, int> _surfaceOffsets = {
  QuoteSurface.home: 0,
  QuoteSurface.progress: 29,
  QuoteSurface.onboarding: 53,
  QuoteSurface.reminder: 67,
};

const int _shuffleSeed = 20260830;

/// Days move several places along the rotation, so a run reads less alike.
const int _dayStride = 7;

/// The list read in a fixed shuffled order, so neighbours are not all one author.
final List<Quote> _rotation = List.of(quotes)..shuffle(Random(_shuffleSeed));

/// The same quote for the whole of [day] on [surface], cycling through the list.
Quote quoteFor(QuoteSurface surface, DateTime day) {
  final step = dayOfYear(day) * _dayStride + _surfaceOffsets[surface]!;
  return _rotation[step % _rotation.length];
}

/// The quote after [current] in the rotation, wrapping at the end.
Quote quoteAfter(Quote current) {
  final index = _rotation.indexOf(current);
  return _rotation[(index + 1) % _rotation.length];
}

/// A stable quote for one session, so the record always shows the same one.
Quote quoteForSession(String recordId) =>
    quotes[recordId.hashCode.abs() % quotes.length];
