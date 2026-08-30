# Task 08 - The Corner tab, readable legend cards, calendar detail sheet

- **Run:** `.claude/handoffs/2026-08-30-content/`
- **Depends on:** task-07
- **Worker:** developer (Opus)
- **Tests:** yes (developer updates affected tests; assistant adds page tests)

## Goal
Owner review of run 8: Legends do not belong under Skills; the eyebrow on the photo cards is
unreadable; calendar rows should open detail. So: a fifth tab, "Corner", holds the stories,
the calendar and the quote and fact library; legend cards put their text on a solid block
under the photo; calendar rows open a sheet.

## Context the worker needs
- `AppShell`, `ShellProvider` (tab index), `HomePage`, `SkillsPage`, `LegendsPage`,
  `LegendCard`, `LegendStoryPage`, `CalendarPage`, `EventTile`, `BoxingEvent`, `quotes`,
  `boxingFacts`, `QuoteCard`, `FactCard`, `SkillCard`, `SectionHeader`, `PillButton`.
- Tab order becomes Home 0, Train 1, Skills 2, Corner 3, Progress 4. `showTab(1)` call sites
  stay valid; search for any hard-coded 3 meaning Progress and update.

## Files
- `lib/pages/app_shell.dart` - modify - five destinations.
- `lib/pages/corner_page.dart` - create.
- `lib/pages/quotes_page.dart` - create.
- `lib/pages/facts_page.dart` - create.
- `lib/widgets/legend_card.dart` - modify - text block under the photo.
- `lib/pages/legend_story_page.dart` - modify - hero is photo only; text block below.
- `lib/pages/legends_page.dart` - modify - remove the Calendar card (Corner has it).
- `lib/pages/skills_page.dart` - modify - remove the Legends card (three cards again).
- `lib/pages/home_page.dart` - modify - "All legends" link goes to the Corner tab.
- `lib/models/boxing_event.dart` - modify - `String? legendId`.
- `lib/data/boxing_calendar.dart` - modify - set `legendId` on the entries listed below.
- `lib/widgets/event_tile.dart` - modify - tappable.
- `lib/widgets/event_sheet.dart` - create - `showEventSheet`.
- `lib/pages/calendar_page.dart` - modify - rows open the sheet.
- `docs/architecture.md` - modify - shell, rows, navigation.

## Spec

### Shell
`NavigationBar` destinations: Home `home_rounded`, Train `sports_mma_rounded`, Skills
`bolt_rounded`, Corner `auto_stories_rounded`, Progress `insights_rounded`. Labels always shown;
at five items the label style stays `label` (check it does not wrap on 393 dp).

### `CornerPage`
`ListView` padded `spaceLg`, `SettleIn` blocks:
1. `SectionHeader(title: 'Corner', eyebrow: 'STORIES, DAYS, WORDS')`.
2. Eyebrow "LEGEND OF THE WEEK", `LegendCard(featured: true)` -> story; below it a
   `SkillCard('All legends', 'Twelve fighters and what they teach.', Icons.auto_stories_rounded)` -> `LegendsPage`.
3. Eyebrow "TODAY IN BOXING" when `eventsOn(now)` is non-empty with the event card from Home
   (extract the card into `lib/widgets/event_card.dart` so Home and Corner share it; it opens
   the sheet). Then eyebrow "NEXT UP" with three `EventTile`s from `nextEvents(now)`, and a
   `SkillCard('Calendar', 'Anniversaries, birthdays and boxing days.', Icons.event_rounded)` -> `CalendarPage`.
4. Eyebrow "WORDS": `SkillCard('Quotes', '81 lines from boxers and other athletes.', Icons.format_quote_rounded)` -> `QuotesPage`;
   `SkillCard('Did you know', '40 facts and records from the ring.', Icons.lightbulb_outline_rounded)` -> `FactsPage`.

### `QuotesPage` and `FactsPage`
Transparent app bar. Quotes: `SectionHeader(title: 'Quotes', eyebrow: 'WORDS TO TRAIN BY')`, a
`FilterChipRow<String>` of sports (All, Boxing, then the rest alphabetically; "Boxing trainer"
counts as Boxing), then `QuoteCard(compact: true)` per quote in list order. Facts:
`SectionHeader(title: 'Did you know', eyebrow: 'FROM THE RING')`, `FactCard` per fact.
Both lists lazy (`ListView.builder`).

### `LegendCard` redesign
Column inside a clipped `surface` card, `radiusLg`: the photo at 4:3 (`featured`: 16:10),
`BoxFit.cover`, `Alignment.topCenter`, no gradient and no text on it; then a text block padded
`spaceMd` (`spaceLg` when featured): eyebrow `label` "{country} · {division}", name in
`displayMedium` (`displayLarge` featured), hook in `bodyMuted`, 2 lines. Remove `LegendPhoto`'s
gradient parameter if it becomes unused; keep the widget for the story hero.

### `LegendStoryPage`
The `SliverAppBar` shows the photo only (still pinned with the name when collapsed). The
eyebrow, name and hook move into the first body block, on the `ink` ground, directly under
the hero. The facts strip (R8-02) becomes two rows of `StatTile.text` when any value is longer
than 18 characters: record and division on the first row full width each stacked, country on
the second, or simpler: a `Wrap` of three `surface` chips with `label` eyebrow and `body` value
that grow to their content. Use the `Wrap`.

### Calendar detail
`BoxingEvent.legendId` (nullable) set as: 1 foreman, 2 frazier, 3 ali, 4 foreman, 5 tyson,
6 robinson, 7 mayweather, 8 ali, 9 frazier, 10 foreman, 11 johnson, 13 louis, 15 marciano,
16 ali, 17 taylor, 18 robinson, 19 louis, 20 ali, 21 louis, 23 tyson, 24 taylor, 25 johnson,
26 taylor, 28 marciano, 29 marciano, 30 ali, 31 marciano, 32 ali, 33 ali, 34 foreman,
35 frazier, 36 tyson, 37 kom, 38 pacquiao, 39 johnson (numbers are the entry numbers in
task-05; entries 12, 14, 22, 27 have none).
`showEventSheet(BuildContext, BoxingEvent)`: `showModalBottomSheet` on `surfaceRaised`,
`radiusLg` top, drag handle: date line in `label` ("30 OCTOBER 1974" or "27 AUGUST, EVERY
YEAR" for entries without a year), `kind.label` chip, title in `displayLarge` (`FittedBox`),
blurb in `body` with `height: 1.5`, then, when `legendId` resolves, `PillButton('Read the
legend', filled, 56)` that pops the sheet and pushes `LegendStoryPage`. `EventTile` gains
`onTap`; `CalendarPage` and the Corner "Next up" rows open the sheet; the Home/Corner event
card opens the sheet too.

### Home and Skills
Home: keep the Legend-of-the-week card and the Today-in-boxing card; the "All legends" link
becomes "More in Corner" and calls `shell.showTab(3)`. Skills: back to Combos, Reaction,
Footwork.

## Acceptance criteria
- [ ] Five tabs in order; Corner shows the four sections; Skills has three cards; Legends
      page has no Calendar card.
- [ ] Legend cards show no text over the photo; the story page hero is photo only with the
      title block below; the facts strip never scales text below `body` size.
- [ ] Tapping a calendar row or the Today card opens the sheet; "Read the legend" appears for
      an event with `legendId` and opens the right story; entries 12, 14, 22, 27 show no button.
- [ ] Quotes page filters by sport; Facts page lists 40.
- [ ] `flutter analyze` 0 issues; suite green (update `app_shell_test`, `home_page_test`,
      `skills_page_test`, `legends_page_test`, `calendar_page_test`, `legend_story_page_test` as needed).

## Verification
- Developer: run the full suite. Assistant afterwards: `test/pages/corner_page_test.dart`,
  `test/pages/quotes_page_test.dart`, `test/pages/facts_page_test.dart`, `test/widgets/event_sheet_test.dart`.
