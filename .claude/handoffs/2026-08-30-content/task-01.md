# Task 01 - Quotes and facts 2.0 with per-surface rotation

- **Run:** `.claude/handoffs/2026-08-30-content/`
- **Depends on:** none
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
The owner sees the same quote on Home, Progress and onboarding and only the session card
differs, and the library is too small. After this task: 81 quotes (52 from boxers and boxing
trainers, 29 from other sports), 40 boxing-only facts, and every surface rotates on its own
sequence so no two surfaces show the same quote or fact on the same day. Tapping a quote card
shows another.

## Context the worker needs
- `lib/data/quotes.dart`, `lib/data/boxing_facts.dart`, `lib/models/quote.dart`,
  `lib/models/boxing_fact.dart`, `lib/widgets/quote_card.dart`, `lib/widgets/fact_card.dart`,
  call sites: `home_page.dart`, `progress_page.dart`, `onboarding_page.dart`,
  `session_complete_page.dart`, `services/reminder_scheduler.dart`.
- The lists below are the complete, final sets. Do not add, reword, "fix" or reattribute any
  entry; a wrong attribution is worse than a missing quote. Keep the existing 30 quotes and 24
  facts exactly as they are (they are included below in their original wording); append the
  new ones in the order given. No em-dashes anywhere.

## Files
- `lib/data/quotes.dart` - modify - list, `QuoteSurface`, `quoteFor`, `quoteAfter`.
- `lib/data/boxing_facts.dart` - modify - list, `FactSurface`, `factFor`, `factAfter`.
- `lib/widgets/quote_card.dart` - modify - optional tap to cycle.
- `lib/widgets/fact_card.dart` - modify - optional tap to cycle.
- `lib/pages/home_page.dart`, `lib/pages/progress_page.dart`, `lib/pages/onboarding_page.dart`,
  `lib/pages/session_complete_page.dart`, `lib/services/reminder_scheduler.dart` - modify -
  call sites.
- `docs/architecture.md` - modify - rows.

## Spec

### Rotation
```dart
enum QuoteSurface { home, progress, onboarding, reminder }
Quote quoteFor(QuoteSurface surface, DateTime day);
Quote quoteAfter(Quote current);                 // next in the shuffled order, wraps
Quote quoteForSession(String recordId);          // unchanged
```
Implementation: a fixed, deterministic shuffle of the list at first use (`List.of(quotes)..shuffle(Random(20260830))`),
then `index = (dayOfYear(day) * 7 + offset(surface)) % shuffled.length` with offsets
`home 0, progress 29, onboarding 53, reminder 67` (all distinct modulo 81, so the four surfaces
never coincide on a day; a test proves it for every day of a leap year). Same shape for facts:
`enum FactSurface { home, progress }`, `factFor`, `factAfter`, `factForSession` unchanged,
offsets `home 0, progress 19`, seed `20260831`, list length 40.

### Cards
`QuoteCard` and `FactCard` gain `bool cycles = false`. When true the card is wrapped in a
`StatefulWidget` that holds the current entry, shows a `caption` "Tap for another" at the
bottom right, and on tap replaces the entry with `quoteAfter` / `factAfter` with the existing
`AnimatedSwitcher`-style fade (`AppMotion.base`). Home and Progress pass `cycles: true`;
onboarding and the session sheet do not.

### Call sites
Home: `quoteFor(QuoteSurface.home, now)` and `factFor(FactSurface.home, now)`.
Progress: `quoteFor(QuoteSurface.progress, now)` (empty state) and
`factFor(FactSurface.progress, now)`. Onboarding: `QuoteSurface.onboarding`. Reminder body:
`QuoteSurface.reminder`. Session sheet unchanged.

### `quotes` (81; sport values as given)
Existing 1 to 30, unchanged, then:
31. "I am the greatest. I said that even before I knew I was." Muhammad Ali, Boxing
32. "He who is not courageous enough to take risks will accomplish nothing in life." Muhammad Ali, Boxing
33. "The man who has no imagination has no wings." Muhammad Ali, Boxing
34. "Champions aren't made in gyms. Champions are made from something they have deep inside them: a desire, a dream, a vision." Muhammad Ali, Boxing
35. "It's the repetition of affirmations that leads to belief. And once that belief becomes a deep conviction, things begin to happen." Muhammad Ali, Boxing
36. "What keeps me going is goals." Muhammad Ali, Boxing
37. "A man who views the world the same at fifty as he did at twenty has wasted thirty years of his life." Muhammad Ali, Boxing
38. "I know where I'm going and I know the truth, and I don't have to be what you want me to be. I'm free to be what I want." Muhammad Ali, Boxing
39. "Age is whatever you think it is. You are as old as you think you are." Muhammad Ali, Boxing
40. "It's lack of faith that makes people afraid of meeting challenges, and I believed in myself." Muhammad Ali, Boxing
41. "The will must be stronger than the skill." Muhammad Ali, Boxing
42. "Only a man who knows what it is like to be defeated can reach down to the bottom of his soul and come up with the extra ounce of power it takes to win when the match is even." Muhammad Ali, Boxing
43. "I don't count my sit-ups. I only start counting when it starts hurting, because they're the only ones that count." Muhammad Ali, Boxing
44. "I've seen George Foreman shadow boxing, and the shadow won." Muhammad Ali, Boxing
45. "It's just a job. Grass grows, birds fly, waves pound the sand. I beat people up." Muhammad Ali, Boxing
46. "I'm so fast that last night I turned off the light switch in my hotel room and was in bed before the room was dark." Muhammad Ali, Boxing
47. "Discipline is doing what you hate to do, but nonetheless doing it like you love it." Mike Tyson, Boxing
48. "I'm a dreamer. I have to dream and reach for the stars, and if I miss a star then I grab a handful of clouds." Mike Tyson, Boxing
49. "As long as we persevere and endure, we can get anything we want." Mike Tyson, Boxing
50. "The temptation for greatness is the biggest drug in the world." Mike Tyson, Boxing
51. "He can run, but he can't hide." Joe Louis, Boxing
52. "Once that bell rings you're on your own. It's just you and the other guy." Joe Louis, Boxing
53. "Everybody wants to go to heaven, but nobody wants to die." Joe Louis, Boxing
54. "Rhythm is everything in boxing. Every move you make starts with your heart, and that's in rhythm or you're in trouble." Sugar Ray Robinson, Boxing
55. "Boxing is like jazz. The better it is, the less people appreciate it." George Foreman, Boxing
56. "If they cut my bald head open, they will find one big boxing glove. That's all I am. I live it." Marvin Hagler, Boxing
57. "Boxing is not about your feelings. It's about performance." Manny Pacquiao, Boxing
58. "A true champion can adapt to anything." Floyd Mayweather Jr., Boxing
59. "There is always space for improvement, no matter how long you've been in the business." Oscar De La Hoya, Boxing
60. "Stay hungry, stay humble." Anthony Joshua, Boxing
61. "Do not let anyone tell you that you are weak because you are a woman." Mary Kom, Boxing
62. "Fear is like fire. It can cook for you. It can heat your house. Or it can burn you down." Cus D'Amato, Boxing trainer
63. "Boxing is a contest of character and ingenuity. The boxer with more will, determination, desire and intelligence is always the one who comes out the victor." Cus D'Amato, Boxing trainer
64. "Life doesn't run away from nobody. Life runs at people." Joe Frazier, Boxing
65. "We're all given some sort of skill in life. Mine just happens to be beating up on people." Sugar Ray Leonard, Boxing
66. "I fought Sugar Ray so often, I almost got diabetes." Jake LaMotta, Boxing
67. "Pressure is a privilege." Billie Jean King, Tennis
68. "You can't put a limit on anything. The more you dream, the farther you get." Michael Phelps, Swimming
69. "Don't give up. Don't ever give up." Jim Valvano, Basketball coach
70. "Losing is not my enemy. Fear of losing is my enemy." Rafael Nadal, Tennis
71. "I'd rather regret the risks that didn't work out than the chances I didn't take at all." Simone Biles, Gymnastics
72. "Worrying gets you nowhere. If you turn up worrying about how you're going to perform, you've already lost." Usain Bolt, Sprinting
73. "Some people want it to happen, some wish it would happen, others make it happen." Michael Jordan, Basketball
74. "The only place success comes before work is in the dictionary." Vince Lombardi, American football
75. "Knowing is not enough, we must apply. Willing is not enough, we must do." Bruce Lee, Martial arts
76. "Every day you either get better or you get worse. You never stay the same." Bo Schembechler, American football coach
77. "It's better to look ahead and prepare than to look back and regret." Jackie Joyner-Kersee, Athletics
78. "We all have dreams. But in order to make dreams come into reality, it takes an awful lot of determination, dedication, self-discipline and effort." Jesse Owens, Athletics
79. "Never underestimate the power of dreams and the influence of the human spirit." Wilma Rudolph, Athletics
80. "If you want to win something, run 100 metres. If you want to experience something, run a marathon." Emil Zatopek, Athletics
81. "Every strike brings me closer to the next home run." Babe Ruth, Baseball

Counts to assert: 81 total; authors with sport "Boxing" or "Boxing trainer": 52 (64 percent).

### `boxingFacts` (40)
Existing 1 to 24, unchanged, then:
25. "A championship fight is twelve rounds. It was fifteen until the mid-1980s, when the death of Duk-koo Kim in 1982 pushed the sanctioning bodies to shorten it." subject "Twelve rounds"
26. "Muhammad Ali refused induction into the US Army in 1967, was stripped of his title and could not box for more than three years at the peak of his career." subject "Muhammad Ali"
27. "Mike Tyson's 1990 loss to Buster Douglas in Tokyo is still called the biggest upset in boxing history. Douglas was a 42 to 1 underdog." subject "Buster Douglas"
28. "Joe Louis knocked out Max Schmeling in 124 seconds in their 1938 rematch at Yankee Stadium." subject "Louis vs Schmeling"
29. "Sugar Ray Leonard won world titles in five weight divisions, from welterweight to light heavyweight." subject "Sugar Ray Leonard"
30. "Marvin Hagler legally changed his name to Marvelous Marvin Hagler in 1982." subject "Marvin Hagler"
31. "Lennox Lewis retired as heavyweight champion in 2004 having avenged both of his professional defeats." subject "Lennox Lewis"
32. "Nicola Adams won the first women's Olympic boxing gold medal at London 2012, the first Games to include women's boxing." subject "Nicola Adams"
33. "Boxing joined the Olympic Games in 1904 in St. Louis." subject "Olympic boxing"
34. "Sugar Ray Robinson won the world middleweight title five separate times." subject "Sugar Ray Robinson"
35. "Professional fights use 8 ounce or 10 ounce gloves depending on the weight class." subject "Gloves"
36. "Jack Dempsey against Georges Carpentier in 1921 was boxing's first million-dollar gate." subject "Jack Dempsey"
37. "Teofilo Stevenson won three Olympic heavyweight gold medals for Cuba, in 1972, 1976 and 1980, and never turned professional." subject "Teofilo Stevenson"
38. "Manny Pacquiao was elected to the Philippine Senate in 2016 while still a reigning world champion." subject "Manny Pacquiao"
39. "Mary Kom gave birth to twins in 2007 and won the World Championship again in 2008." subject "Mary Kom"
40. "Evander Holyfield is the only boxer to have won the world heavyweight title four times." subject "Evander Holyfield"

## Out of scope
- Any other content change; the Legends stories quote from this list by index in task-03.

## Acceptance criteria
- [ ] `quotes.length == 81`, boxing share >= 0.6, no duplicate text, no em-dash, every entry has
      author and sport; `boxingFacts.length == 40`, all subjects non-empty.
- [ ] For every day of 2024 (leap year), `quoteFor` returns four different quotes for the four
      surfaces, and `factFor` two different facts; the same day always returns the same entry.
- [ ] `quoteAfter` walks the whole list and wraps; `factAfter` likewise.
- [ ] Home shows a quote and fact different from Progress on the same day; tapping the Home
      quote card changes the quote.
- [ ] `flutter analyze` 0 issues.

## Verification
- Assistant tests: extend `test/data/quotes_test.dart`, `test/data/boxing_facts_test.dart`;
  add `test/widgets/quote_card_test.dart`; extend `home_page_test.dart`.
