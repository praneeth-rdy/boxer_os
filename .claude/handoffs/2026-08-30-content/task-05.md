# Task 05 - Boxing calendar: data, page, Home card, reminder

- **Run:** `.claude/handoffs/2026-08-30-content/`
- **Depends on:** task-04
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
A calendar of boxing anniversaries, birthdays and international sport days, kept as bundled
data. On a matching date Home shows a "TODAY IN BOXING" card; a Calendar page (reached from
Legends and from the Home card) lists the year month by month with the next date highlighted;
a Settings switch sends a 9:00 notification on event days.

## Context the worker needs
- `date_helpers.dart`, `NotificationService` (`scheduleOnce`), `ReminderScheduler`,
  `SettingsProvider` keys pattern, `LegendsPage` (task-04) for the entry point,
  `HomePage`, `SettingsPage` REMINDERS section.
- The dates below are verified. Type them exactly; do not add entries.

## Files
- `lib/models/boxing_event.dart` - create - `BoxingEvent`, `EventKind`.
- `lib/data/boxing_calendar.dart` - create - `boxingCalendar`, `eventsOn`, `nextEvents`.
- `lib/pages/calendar_page.dart` - create.
- `lib/widgets/event_tile.dart` - create.
- `lib/pages/home_page.dart` - modify - TODAY IN BOXING card.
- `lib/pages/legends_page.dart` - modify - "Calendar" `SkillCard` at the top of the list.
- `lib/providers/settings_provider.dart` - modify - `eventRemindersEnabled` key `event_reminders_enabled` (bool, false).
- `lib/services/reminder_scheduler.dart` - modify - id 3 schedule.
- `lib/services/notification_service.dart` - modify - `static const int eventReminderId = 3`.
- `lib/pages/settings_page.dart` - modify - third `_PermissionSwitch` "Boxing days".
- `docs/architecture.md` - modify - rows, key.

## Spec

### Model and data
```dart
enum EventKind { anniversary, birthday, memorial, internationalDay }
class BoxingEvent { const BoxingEvent({required this.month, required this.day, this.year, required this.title, required this.blurb, required this.kind}); }
List<BoxingEvent> eventsOn(DateTime day);                 // month and day match, sorted by kind order above
List<BoxingEvent> nextEvents(DateTime from, {int count = 3}); // upcoming from tomorrow, wrapping the year
```
`EventKind.label`: "Anniversary", "Born", "Remembered", "International day".

Entries (month/day, year, kind, title, blurb):
1. 1/10, 1949, birthday, "George Foreman born", "Houston, Texas. Olympic gold at nineteen, heavyweight champion at twenty-four and again at forty-five."
2. 1/12, 1944, birthday, "Joe Frazier born", "Beaufort, South Carolina. Smokin' Joe, 1964 Olympic champion and the first man to beat Muhammad Ali."
3. 1/17, 1942, birthday, "Muhammad Ali born", "Louisville, Kentucky. Cassius Clay, later Muhammad Ali, three times heavyweight champion of the world."
4. 1/22, 1973, anniversary, "Foreman stops Frazier", "Kingston, Jamaica. Six knockdowns in two rounds; George Foreman takes the heavyweight title."
5. 2/11, 1990, anniversary, "Douglas beats Tyson", "Tokyo. Buster Douglas, a 42 to 1 underdog, knocks out Mike Tyson in the tenth round."
6. 2/14, 1951, anniversary, "Robinson beats LaMotta", "Chicago. Sugar Ray Robinson stops Jake LaMotta in the thirteenth round of their sixth fight to win the middleweight title."
7. 2/24, 1977, birthday, "Floyd Mayweather Jr. born", "Grand Rapids, Michigan. Fifty wins, no defeats, titles in five divisions."
8. 2/25, 1964, anniversary, "Clay beats Liston", "Miami Beach. Twenty-two-year-old Cassius Clay becomes heavyweight champion when Sonny Liston cannot answer the bell for round seven."
9. 3/8, 1971, anniversary, "The Fight of the Century", "Madison Square Garden. Joe Frazier beats Muhammad Ali on points; both men unbeaten going in."
10. 3/21, 2025, memorial, "George Foreman dies", "Big George, Olympic champion, two-time heavyweight champion and the oldest ever at forty-five."
11. 3/31, 1878, birthday, "Jack Johnson born", "Galveston, Texas. The first Black heavyweight champion of the world."
12. 4/6, null, internationalDay, "International Day of Sport for Development and Peace", "A United Nations day marking the opening of the first modern Olympic Games in Athens in 1896."
13. 4/12, 1981, memorial, "Joe Louis dies", "The Brown Bomber, heavyweight champion for almost twelve years, buried at Arlington National Cemetery."
14. 4/15, 1985, anniversary, "Hagler vs Hearns", "Caesars Palace, Las Vegas. Three rounds, eight minutes, and a first round still called the greatest ever."
15. 4/27, 1956, anniversary, "Marciano retires undefeated", "Rocky Marciano announces his retirement as heavyweight champion with a record of 49 and 0."
16. 4/28, 1967, anniversary, "Ali refuses induction", "Houston. Muhammad Ali refuses to be drafted; he is stripped of his title the same day."
17. 4/30, 2022, anniversary, "Taylor vs Serrano", "Madison Square Garden. Katie Taylor beats Amanda Serrano in the first women's fight to headline the Garden."
18. 5/3, 1921, birthday, "Sugar Ray Robinson born", "Ailey, Georgia. The original pound-for-pound best, five times middleweight champion."
19. 5/13, 1914, birthday, "Joe Louis born", "LaFayette, Alabama. Heavyweight champion 1937 to 1949, twenty-five title defences."
20. 6/3, 2016, memorial, "Muhammad Ali dies", "Scottsdale, Arizona. The Greatest, aged seventy-four."
21. 6/22, 1938, anniversary, "Louis vs Schmeling II", "Yankee Stadium. Joe Louis knocks out Max Schmeling in two minutes and four seconds."
22. 6/23, null, internationalDay, "Olympic Day", "Marks the founding of the International Olympic Committee on 23 June 1894."
23. 6/30, 1966, birthday, "Mike Tyson born", "Brooklyn, New York. The youngest heavyweight champion in history."
24. 7/2, 1986, birthday, "Katie Taylor born", "Bray, Ireland. Five amateur world titles, Olympic gold and undisputed lightweight champion."
25. 7/4, 1910, anniversary, "Johnson vs Jeffries", "Reno, Nevada. Jack Johnson beats the former champion James Jeffries in the original Fight of the Century."
26. 8/9, 2012, anniversary, "First women's Olympic boxing golds", "London. Nicola Adams and Katie Taylor win gold on the first Olympic day with women's boxing finals."
27. 8/27, null, internationalDay, "International Boxing Day", "The IBA's day for the sport, on the anniversary of the first World Boxing Championships in Havana in 1974."
28. 8/31, 1969, memorial, "Rocky Marciano dies", "A plane crash in Iowa the day before his forty-sixth birthday."
29. 9/1, 1923, birthday, "Rocky Marciano born", "Brockton, Massachusetts. The only heavyweight champion to retire undefeated."
30. 9/15, 1978, anniversary, "Ali wins the title a third time", "New Orleans. Muhammad Ali outpoints Leon Spinks to become the first three-time heavyweight champion."
31. 9/23, 1952, anniversary, "Marciano wins the title", "Philadelphia. Down in the first round, Rocky Marciano knocks out Jersey Joe Walcott in the thirteenth."
32. 10/1, 1975, anniversary, "The Thrilla in Manila", "Quezon City. Ali and Frazier's third fight ends after fourteen rounds when Frazier's corner stops it."
33. 10/30, 1974, anniversary, "The Rumble in the Jungle", "Kinshasa. Muhammad Ali knocks out George Foreman in the eighth round to regain the heavyweight title."
34. 11/5, 1994, anniversary, "Foreman, champion at forty-five", "Las Vegas. George Foreman knocks out Michael Moorer to become the oldest heavyweight champion."
35. 11/7, 2011, memorial, "Joe Frazier dies", "Philadelphia. Smokin' Joe, aged sixty-seven."
36. 11/22, 1986, anniversary, "Tyson, youngest champion", "Las Vegas. Mike Tyson stops Trevor Berbick in the second round at twenty years and four months."
37. 11/24, 2018, anniversary, "Mary Kom's sixth world title", "New Delhi. Mary Kom wins a record sixth World Championship gold at thirty-five."
38. 12/17, 1978, birthday, "Manny Pacquiao born", "Kibawe, Philippines. World titles in eight divisions."
39. 12/26, 1908, anniversary, "Johnson beats Burns", "Sydney. Jack Johnson becomes the first Black heavyweight champion of the world."

### `EventTile`
`const EventTile({required BoxingEvent event, bool isToday = false, bool isNext = false})`:
a row with a 56 dp date column (day in `displayMedium`, month abbreviation in `label`;
`accent` when `isToday`, `rest` when `isNext`), then title in `title`, blurb in `bodyMuted`
(3 lines), and a `caption` "{kind.label}{year != null ? ' · $year' : ''}".

### `CalendarPage`
Transparent app bar; `SectionHeader(title: 'Calendar', eyebrow: 'DAYS THAT MATTER')`; a
`bodyMuted` line "Anniversaries, birthdays and the sport's international days."; then twelve
month groups (`label` uppercase month name) each with its `EventTile`s; the page scrolls to
today's month on open (`ScrollController` + `GlobalKey`s or a computed offset; either).
Entry: a `SkillCard` "Calendar" ("Days that matter in boxing", `Icons.event_rounded`) at the
top of `LegendsPage`.

### Home card
If `eventsOn(now)` is non-empty: eyebrow "TODAY IN BOXING" after the streak strip and before
the quote, and a `surfaceRaised` card with the first event's title in `displayMedium`, blurb in
`body`, year and kind in `caption`; tap pushes `CalendarPage`. Otherwise nothing (no "next
event" line on Home; the page has it).

### Reminder
Settings key `event_reminders_enabled` (default false); `SettingsProvider.setEventRemindersEnabled`.
`ReminderScheduler.sync()` gains: if enabled, `scheduleOnce(id: 3, at: next event date at
09:00 local (today if before 09:00 and today has an event), title: event.title, body:
event.blurb)`; disabled -> `cancel(3)`. Settings: a third `_PermissionSwitch` "Boxing days"
(subtitle "A morning note on anniversaries and boxing days").

## Acceptance criteria
- [ ] `boxingCalendar.length == 39`, sorted by month then day, no duplicate month/day/title;
      `eventsOn(2026-10-30)` returns the Rumble; `nextEvents(2026-12-27)` wraps to 10 January.
- [ ] Home shows the card on 30 October and not on 29 October (fake `now` via the test's
      `DateTime`; `HomePage` takes an optional `DateTime Function() clock` for tests, default
      `DateTime.now`).
- [ ] Calendar page lists all months; the reminder schedules id 3 for the next event at 09:00.
- [ ] `flutter analyze` 0 issues.

## Verification
- Assistant tests: `test/data/boxing_calendar_test.dart`, `test/pages/calendar_page_test.dart`,
  extend `reminder_scheduler_test.dart`, `home_page_test.dart`, `settings_page_test.dart`.
