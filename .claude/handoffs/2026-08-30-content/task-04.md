# Task 04 - Legends screens and entry points

- **Run:** `.claude/handoffs/2026-08-30-content/`
- **Depends on:** task-03
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
"Legends": a list of the twelve boxers as photo cover cards and a story page that reads like
a short magazine feature: photo hero, facts strip, sections, pull quotes between sections,
takeaways, photo credit. Entry points: a "LEGEND OF THE WEEK" card on Home and a Legends card
on the Skills hub.

## Context the worker needs
- `legends`, `legendOfTheWeek`, `Legend` (task-03); `quotes` for pull quotes; `QuoteCard`;
  `SkillCard`; `SectionHeader`; `AppTheme`; `AppMotion`; `SettleIn`.
- Editorial, not dashboard: generous spacing, display type for the name, body copy at
  `AppTheme.body` with `height: 1.5`, max line length about 60 characters (the phone width
  with `spaceLg` padding gives that).

## Files
- `lib/widgets/legend_card.dart` - create - `LegendCard`.
- `lib/pages/legends_page.dart` - create.
- `lib/pages/legend_story_page.dart` - create.
- `lib/pages/home_page.dart` - modify - legend of the week card after the quote card.
- `lib/pages/skills_page.dart` - modify - fourth card.
- `docs/architecture.md` - modify - rows and navigation.

## Spec

### `LegendCard`
`const LegendCard({required Legend legend, required VoidCallback onTap, bool featured = false})`.
A `surface` card, `radiusLg`, clipped: the photo (`Image.asset`, `BoxFit.cover`, 4:3 for the
list, 16:10 when `featured`) with a bottom gradient from transparent to `ink` at 0.92 alpha,
and over it: eyebrow (`label`) "{country} · {division}", name in `displayMedium` (featured:
`displayLarge`), `hook` in `bodyMuted` (2 lines, ellipsis). Tap ripple over the whole card.
Photos are portraits of varying aspect; `alignment: Alignment.topCenter` keeps faces in frame.

### `LegendsPage`
Transparent `AppBar` (back). `ListView` padded `spaceLg`: `SectionHeader(title: 'Legends',
eyebrow: 'STORIES FROM THE RING')`, a `bodyMuted` line "Twelve fighters, what they went
through, and what it teaches.", then a `LegendCard` per legend separated by `spaceMd`, wrapped
in `SettleIn` with ascending indexes. Tap pushes `LegendStoryPage(legend)`.

### `LegendStoryPage`
`CustomScrollView`:
1. `SliverAppBar` with `expandedHeight` 360, `pinned`, transparent when expanded, `ink` when
   collapsed; `flexibleSpace` shows the photo with the same bottom gradient; title (collapsed)
   is the name in `title` style.
2. Body (`SliverPadding` `spaceLg`, then a `SliverList`):
   - eyebrow "{nickname.toUpperCase()} · {years}", name in `displayLarge`, `hook` in `bodyMuted`.
   - A facts strip: three `StatTile`-like cells using `StatTile.text` (country, division,
     record) in a `Row`.
   - For each section in order: heading in `displaySmall`, body in `body` with `height: 1.5`
     (`AppTheme.body.copyWith(height: 1.5)`), `spaceLg` after. After section 1 and after
     section 3 (or 2 if only two quotes), a `QuoteCard(quote: quotes[quoteIndexes[i]])`
     (the legend's quotes, in order; a third quote, if any, goes after section 4).
   - "WHAT TO TAKE FROM IT" eyebrow and the takeaways as a numbered list: the number in
     `displaySmall` `accent` in a 40 dp column, the text in `body`.
   - "PHOTO" eyebrow with `caption`: "{credit.author}. {credit.license}. Wikimedia Commons."
     The caption is a `GestureDetector` that opens `credit.source` (task-07 adds
     `url_launcher`; in this task call a top-level `openExternal(String url)` placed in
     `lib/utils/external_links.dart` that task-07 implements; create the file now with a body
     that returns `Future<bool>.value(false)` and a one-line comment saying task-07 wires it).
   - Bottom `spaceXxl`.
3. Every block wrapped in `SettleIn` with ascending index (cap applies).

### Home
After the quote card: eyebrow "LEGEND OF THE WEEK" and `LegendCard(legend:
legendOfTheWeek(now), featured: true)` pushing `LegendStoryPage`; below it a ghost
`TextButton` "All legends" underlined like "See details", pushing `LegendsPage`.

### Skills hub
Fourth `SkillCard`: "Legends", "Stories of the greats and what to learn from them.",
`Icons.auto_stories_rounded`, pushes `LegendsPage`.

## Out of scope
- Bookmarks or read-state for stories. Sharing.

## Acceptance criteria
- [ ] Legends page lists 12 cards with photos; tapping opens the story with hero, four sections,
      the legend's quotes between sections, three takeaways and the credit line.
- [ ] Home shows the featured card and it matches `legendOfTheWeek(now)`; Skills hub has the
      fourth card.
- [ ] No overflow on a 393 x 873 dp viewport; the collapsed app bar shows the name.
- [ ] `flutter analyze` 0 issues.

## Verification
- Assistant tests: `test/pages/legends_page_test.dart`, `test/pages/legend_story_page_test.dart`
  (asset images: use `precacheImage`-free assertions, find by type), extend `home_page_test.dart`
  and `skills_page_test.dart`.
