# Task 12 - Archive strip bleeds to the screen edge

- **Run:** `.claude/handoffs/2026-08-30-content/`
- **Depends on:** task-09
- **Worker:** developer (Opus)
- **Tests:** yes (developer adjusts `test/widgets/gallery_strip_test.dart` if a finder changes)

## Goal
The FROM THE ARCHIVE strip on the story page sits inside the page's `spaceLg` padding, so
photos are clipped at the left margin while scrolling. It should run edge to edge with the
first and last items aligned to the text column.

## Files
- `lib/widgets/gallery_strip.dart` - modify.
- `lib/pages/legend_story_page.dart` - modify - place the strip outside the padded column.
- `test/widgets/gallery_strip_test.dart` - modify only if needed.

## Spec
`GalleryStrip` takes `double horizontalPadding = AppTheme.spaceLg` and applies it as the
`ListView`'s `padding`, with `spaceMd` between items. The story page renders the eyebrow inside
the padded column as today, then the strip as its own full-width block (no horizontal padding
around it), then continues the padded column. The strip's height is fixed from the item
width (280 dp at 4:3 plus caption and credit lines, computed once as a const, not measured).

## Acceptance criteria
- [ ] Widget test: the strip's `ListView.padding` left equals `spaceLg` and the strip's
      render box is the full width of a 393 dp viewport.
- [ ] `flutter analyze` 0 issues; suite green.
