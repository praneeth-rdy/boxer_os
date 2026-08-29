# Task 04 - Onboarding, quotes, facts and empty states

- **Run:** `.claude/handoffs/2026-08-29-experience/`
- **Depends on:** task-03
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
First launch greets the boxer by name and sets stance and level in three taps. Home, Progress
and Journal never look blank: every empty state has a designed message and a way forward.
Real, attributed quotes from boxers and other athletes appear on Home (quote of the day), on
the session-complete screen, and in the Progress empty state.

## Context the worker needs
- Run 3 pages: `home_page.dart`, `progress_page.dart`, `journal_page.dart`,
  `session_complete_page.dart`, `settings_page.dart`; `SettingsProvider`; `AppShell`.
- `.claude/CLAUDE.md`: no em-dashes anywhere, including quote text (use a comma).
- Quotes are short quotations with attribution; do not add, alter or "improve" any. The list
  below is the full set.

## Files
- `lib/models/quote.dart` - create - `Quote`.
- `lib/data/quotes.dart` - create - `quotes`, `quoteOfTheDay`, `quoteForSession`.
- `lib/widgets/quote_card.dart` - create - `QuoteCard`.
- `lib/models/boxing_fact.dart` - create - `BoxingFact`.
- `lib/data/boxing_facts.dart` - create - `boxingFacts`, `factOfTheDay`, `factForSession`.
- `lib/widgets/fact_card.dart` - create - `FactCard`.
- `lib/widgets/empty_state.dart` - create - `EmptyState`.
- `lib/providers/shell_provider.dart` - create - `ShellProvider` (active tab).
- `lib/pages/app_shell.dart` - modify - drive the tab from `ShellProvider`.
- `lib/pages/onboarding_page.dart` - create.
- `lib/providers/settings_provider.dart` - modify - `fighterName`, `onboardingDone`.
- `lib/main.dart` - modify - `ShellProvider`; `home` chooses onboarding or the shell.
- `lib/pages/home_page.dart`, `lib/pages/progress_page.dart`, `lib/pages/journal_page.dart`,
  `lib/pages/session_complete_page.dart`, `lib/pages/settings_page.dart` - modify.
- `docs/architecture.md` - modify - rows, prefs keys, navigation.

## Spec

### Settings
Keys `fighterNameKey = 'fighter_name'` (String, default ''), `onboardingDoneKey = 'onboarding_done'`
(bool, default false); getters, `setFighterName(String)` (trimmed, max 24 chars),
`setOnboardingDone(bool)`.

### `Quote` and `quotes`
`const Quote({required String text, required String author, required String sport})`.
`const List<Quote> quotes` with exactly these 30 (sport values: "Boxing", "Boxing trainer",
"Basketball", "American football", "Tennis", "Ice hockey", "Marathon", "Football", "Martial arts",
"MMA", "Sprinting"):
1. "Float like a butterfly, sting like a bee." Muhammad Ali, Boxing
2. "I hated every minute of training, but I said, don't quit. Suffer now and live the rest of your life as a champion." Muhammad Ali, Boxing
3. "It isn't the mountains ahead to climb that wear you out; it's the pebble in your shoe." Muhammad Ali, Boxing
4. "Don't count the days; make the days count." Muhammad Ali, Boxing
5. "The fight is won or lost far away from witnesses, behind the lines, in the gym, and out there on the road, long before I dance under those lights." Muhammad Ali, Boxing
6. "Everyone has a plan until they get punched in the mouth." Mike Tyson, Boxing
7. "A champion is someone who gets up when he can't." Jack Dempsey, Boxing
8. "To be a champ you have to believe in yourself when no one else will." Sugar Ray Robinson, Boxing
9. "It is not the size of a man but the size of his heart that matters." Evander Holyfield, Boxing
10. "If you cheated on that in the dark of the morning, well, you're going to get found out now, under the bright lights." Joe Frazier, Boxing
11. "It's tough to get out of bed to do roadwork at 5 a.m. when you've been sleeping in silk pajamas." Marvin Hagler, Boxing
12. "You have to know you can win. You have to think you can win. You have to feel you can win." Sugar Ray Leonard, Boxing
13. "Boxing is the ultimate challenge. There's nothing that can compare to testing yourself the way you do every time you step in the ring." Sugar Ray Leonard, Boxing
14. "Hard work. Dedication." Floyd Mayweather Jr., Boxing
15. "Sure the fight was fixed. I fixed it with a right hand." George Foreman, Boxing
16. "The hero and the coward both feel the same thing, but the hero uses his fear, projects it onto his opponent, while the coward runs." Cus D'Amato, Boxing trainer
17. "I've failed over and over and over again in my life. And that is why I succeed." Michael Jordan, Basketball
18. "I can accept failure, everyone fails at something. But I can't accept not trying." Michael Jordan, Basketball
19. "Everything negative, pressure, challenges, is all an opportunity for me to rise." Kobe Bryant, Basketball
20. "It's not whether you get knocked down; it's whether you get up." Vince Lombardi, American football
21. "A champion is defined not by their wins but by how they can recover when they fall." Serena Williams, Tennis
22. "Champions keep playing until they get it right." Billie Jean King, Tennis
23. "Start where you are. Use what you have. Do what you can." Arthur Ashe, Tennis
24. "You miss 100 percent of the shots you don't take." Wayne Gretzky, Ice hockey
25. "No human is limited." Eliud Kipchoge, Marathon
26. "Celebrate what you've accomplished, but raise the bar a little higher each time you succeed." Mia Hamm, Football
27. "Success is no accident. It is hard work, perseverance, learning, studying, sacrifice and most of all, love of what you are doing." Pele, Football
28. "I fear not the man who has practiced 10,000 kicks once, but I fear the man who has practiced one kick 10,000 times." Bruce Lee, Martial arts
29. "There's no talent here, this is hard work. This is an obsession." Conor McGregor, MMA
30. "Don't think about the start of the race, think about the ending." Usain Bolt, Sprinting

`Quote quoteOfTheDay(DateTime day)` = `quotes[dayOfYear % quotes.length]`;
`Quote quoteForSession(String recordId)` = `quotes[recordId.hashCode.abs() % quotes.length]`.


### `BoxingFact` and `boxingFacts`
`const BoxingFact({required String text, required String subject})` (`subject` is the boxer
or event named, shown as the card's eyebrow). `const List<BoxingFact> boxingFacts` with
exactly these 24, in this order. Do not add, embellish or round differently.
1. "Rocky Marciano retired in 1956 as heavyweight champion with a 49-0 record, the only heavyweight champion to retire undefeated." subject "Rocky Marciano"
2. "Muhammad Ali won the world heavyweight title three separate times: 1964, 1974 and 1978." subject "Muhammad Ali"
3. "Mike Tyson became the youngest heavyweight champion in history at 20 years and 4 months when he stopped Trevor Berbick in 1986." subject "Mike Tyson"
4. "George Foreman regained the heavyweight title at 45 in 1994, twenty years after losing it to Ali, making him the oldest heavyweight champion ever." subject "George Foreman"
5. "Archie Moore scored more than 130 knockouts in his career, still the most of any boxer." subject "Archie Moore"
6. "Sugar Ray Robinson went 91 fights without a defeat between 1943 and 1951." subject "Sugar Ray Robinson"
7. "Joe Louis held the heavyweight title for almost 12 years and defended it 25 times, the longest reign in the division's history." subject "Joe Louis"
8. "Bernard Hopkins won a world title at 49 years old in 2014, the oldest boxer ever to do so." subject "Bernard Hopkins"
9. "Floyd Mayweather Jr. retired with a 50-0 professional record." subject "Floyd Mayweather Jr."
10. "Manny Pacquiao is the only boxer to win world titles in eight different weight divisions." subject "Manny Pacquiao"
11. "Julio Cesar Chavez went unbeaten in his first 87 professional fights." subject "Julio Cesar Chavez"
12. "Wilfred Benitez became a world champion at 17, the youngest in boxing history, in 1976." subject "Wilfred Benitez"
13. "Hagler vs Hearns in 1985 lasted less than eight minutes; its first round is still called the greatest round in boxing." subject "Hagler vs Hearns"
14. "At the Rumble in the Jungle in 1974, Ali let the previously unbeaten George Foreman punch himself out on the ropes, then knocked him out in the eighth round." subject "Rumble in the Jungle"
15. "The Thrilla in Manila in 1975 ended when Joe Frazier's corner stopped the fight after the 14th round; Ali said it was the closest he had come to dying." subject "Thrilla in Manila"
16. "Vasiliy Lomachenko won a world title in only his third professional fight, after an amateur record of 396 wins and 1 loss." subject "Vasiliy Lomachenko"
17. "Oleksandr Usyk became the first undisputed heavyweight champion of the four-belt era in 2024." subject "Oleksandr Usyk"
18. "Claressa Shields is the first American boxer, man or woman, to win two Olympic gold medals, in 2012 and 2016." subject "Claressa Shields"
19. "Katie Taylor vs Amanda Serrano in 2022 was the first women's fight to headline Madison Square Garden." subject "Katie Taylor"
20. "Mary Kom won six World Championship gold medals, the only woman in boxing history to do so." subject "Mary Kom"
21. "Vijender Singh won India's first Olympic boxing medal, a bronze, at Beijing 2008." subject "Vijender Singh"
22. "Jack Johnson became the first Black heavyweight champion of the world in 1908." subject "Jack Johnson"
23. "The Marquess of Queensberry Rules, published in 1867, gave boxing its gloves and its three-minute rounds." subject "Queensberry Rules"
24. "The longest gloved fight on record, Andy Bowen vs Jack Burke in 1893, went 110 rounds and more than seven hours before being declared a no contest." subject "Bowen vs Burke"

`BoxingFact factOfTheDay(DateTime day)` = `boxingFacts[(dayOfYear + 7) % length]` (offset so
the quote and the fact do not both change rhythm on the same index);
`BoxingFact factForSession(String recordId)` like `quoteForSession`.

### `FactCard`
`const FactCard({required BoxingFact fact})`: `surfaceRaised` card, `radiusLg`, padding
`spaceLg`; eyebrow "DID YOU KNOW" with the subject after a middle dot ("DID YOU KNOW · MARY
KOM"), text in `body`. No accent bar (that is the quote's mark).

### `QuoteCard`
`const QuoteCard({required Quote quote, bool compact = false})`: `surface` card, `radiusLg`,
padding `spaceLg`; a 3 dp `accent` bar on the left edge (the one place a bar is allowed:
it marks quotation, not decoration), quote text in `titleLarge` (compact: `title`), then
"{author}" in `bodyStrong` and "{sport}" in `caption` on one line separated by `spaceSm`.

### `EmptyState`
`const EmptyState({required String eyebrow, required String title, required String body, String? actionLabel, VoidCallback? onAction, Widget? extra})`:
eyebrow `label`, title `displayMedium` (2 lines, `text-wrap` by `softWrap`), body `bodyMuted`
(max 60 characters per line, so constrain width), optional `PillButton` (filled, 56) and
`extra` beneath (used for a `QuoteCard`). Left-aligned, generous `spaceXl` gaps.

### `ShellProvider`
`ChangeNotifier` with `int tabIndex` and `void showTab(int)`. `AppShell` reads it with
`context.watch` and calls `showTab` from the `NavigationBar`. Provided in `main`.

### `OnboardingPage`
Shown as `home` when `!settings.onboardingDone`; on finish `setOnboardingDone(true)` and
`Navigator.pushReplacement` to `AppShell`. A `PageView` with three steps and a `PillButton`
row at the bottom (Back ghost, Next filled; last step "Start training"):
1. Wordmark "BOXER OS" in `displayLarge` (with the tagline eyebrow above), a `QuoteCard`
   (`quoteOfTheDay`), then `JournalField('What do we call you?', hint: 'Fighter name, optional', maxLines: 1)`.
2. "Your stance" eyebrow, `displayMedium` "Which foot is forward?", two tall `surface` cards
   (Orthodox: "Left foot forward. Jab with the left.", Southpaw: "Right foot forward. Jab with
   the right.") with the selected one bordered `accent`; sets `setStance`.
3. "Your level" eyebrow, three cards (Beginner "New to boxing or under a year in.",
   Intermediate "Comfortable with the basics, sparring sometimes.", Advanced "Competing or
   coaching-level fundamentals."); sets `setDifficulty`.
Skippable: a ghost "Skip" text button top-right on step 1 finishes with defaults.
Settings gets a "Fighter name" `JournalField` (single line) in the FIGHTER PROFILE section and
a ghost `PillButton('Show onboarding again')` in DATA that sets `onboardingDone` false and pushes
the page.

### Home changes
- Streak strip becomes two rows (review finding R3-01): row 1 the flame icon and the message
  (`title` when there is a streak, `bodyMuted` otherwise); row 2, `spaceSm` below, the caption
  "{weekRounds} rounds · {weekMinutes} min this week" left-aligned. Nothing wraps beside anything.
- Greeting uses the name: "Morning, {name}" or "Morning, fighter".
- After the streak strip: `QuoteCard(quoteOfTheDay(now), compact: true)`.
- After the quick actions: `FactCard(factOfTheDay(now))`.
- No history: the "Today's session" card's eyebrow reads "YOUR FIRST SESSION" and a `bodyMuted`
  line above the Start button says "Ten minutes is enough to start a streak. The bell does the
  rest."; the streak strip reads "No streak yet. Today is a good day." (already) with the
  right side "0 rounds this week".

### Progress empty state
Replace the run 3 "No sessions yet" card with
`EmptyState(eyebrow: 'YOUR RECORD STARTS HERE', title: 'Round one is waiting.', body: 'Finish one session and this page fills with rounds, minutes, your streak and the badges you earn.', actionLabel: 'Start a session', onAction: () => shell.showTab(1), extra: QuoteCard(...))`
followed by the milestones row (all unachieved) as today. Non-empty Progress ends with
`FactCard(factOfTheDay(now))` after the ALL TIME tiles.

### Journal empty state
`EmptyState(eyebrow: 'NOTHING LOGGED YET', title: 'Your first entry writes itself.', body: 'Every finished session lands here with your rating and notes. Sparring days get opponent notes too.', actionLabel: 'Go to Train', onAction: pop then shell.showTab(1))`.

### Session complete
Under the stat cells (above the journal fields): `QuoteCard(quoteForSession(record.id), compact: true)`;
after the journal fields, above Save: `FactCard(factForSession(record.id))`.

## Out of scope
- Animations (task-06). Reminders (task-05). Editing quotes.

## Acceptance criteria
- [ ] `quotes.length == 30`, every quote has text, author and sport, none contains an em-dash;
      `quoteOfTheDay` is stable within a day and cycles. `boxingFacts.length == 24`, same checks.
- [ ] Fresh prefs -> onboarding shows; finishing it sets `onboarding_done`, the name, stance and
      level; next launch goes straight to the shell.
- [ ] Home greets by name after onboarding and shows the quote card; empty Progress shows the
      empty state whose action switches the shell to Train; empty Journal shows its empty state.
- [ ] `flutter analyze` 0 issues.

## Verification
- Assistant tests: `test/data/quotes_test.dart`, `test/data/boxing_facts_test.dart`, `test/pages/onboarding_page_test.dart`,
  `test/providers/shell_provider_test.dart`, extend `home_page_test.dart`,
  `progress_page_test.dart`, `journal_page_test.dart`.
