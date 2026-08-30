# Task 13 - Gym Wall: Moments and Inspiration posters

- **Run:** `.claude/handoffs/2026-08-30-content/`
- **Depends on:** task-12
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
Two photo-led poster kinds join Gym Wall: **Moments**, built from the 34 archive photos in the
legends' galleries (fights, training, winning moments, each with its caption), and
**Inspiration**, 14 new atmosphere photos (ring, gloves, sparring, bags, sweat) with a short
line each. Both bake the credit into the image.

## Context the worker needs
- `Poster`, `PosterKind`, `posters()`, `PosterCanvas`, `GymWallPage` (task-10);
  `Legend.gallery` and `GalleryPhoto` (task-09); `AboutPage` credits.
- New assets in `assets/wall/` (14 JPEGs, long side 2200 px); declare the folder in `pubspec.yaml`.

## Files
- `lib/models/wall_photo.dart` - create - `WallPhoto`.
- `lib/data/wall_photos.dart` - create - the 14 entries.
- `lib/models/poster.dart` - modify - `PosterKind.moment`, `PosterKind.inspiration`, `photo` and `gallery` fields.
- `lib/data/posters.dart` - modify.
- `lib/widgets/poster_canvas.dart` - modify.
- `lib/pages/gym_wall_page.dart` - modify - chips.
- `lib/pages/about_page.dart` - modify - wall photo credits.
- `pubspec.yaml`, `docs/architecture.md` - modify.

## Spec

### `WallPhoto`
`const WallPhoto({required this.id, required this.asset, required this.line, required this.caption, required this.credit})`
(`credit` is a `PhotoCredit`). `const List<WallPhoto> wallPhotos` with exactly:

| id | line | caption | author | license | source |
|---|---|---|---|---|---|
| `ali_liston_win` | The moment. | Ali, seconds after beating Sonny Liston, Miami Beach, 1964. | Bob Bailey, Miami News | Public domain | `https://commons.wikimedia.org/wiki/File:Ali_after_win_vs_Liston_1964_AP_photo.jpg` |
| `sweat` | Between rounds. | Water over the face between rounds. | U.S. Department of Defense Current Photos | Public domain | `https://commons.wikimedia.org/wiki/File:2nd_-_TSgt_Andy_Kin,_USAF_(7)_(14505456882).jpg` |
| `connect` | Land it. | A right hand landing. | U.S. Department of Defense Current Photos | Public domain | `https://commons.wikimedia.org/wiki/File:2nd_-_TSgt_Andy_Kin,_USAF_(8)_(14319943720).jpg` |
| `speedbag_gavilan` | Rhythm. | Kid Gavilan on the speed bag, 1954. | Unknown | Public domain | `https://commons.wikimedia.org/wiki/File:Mundito_Medina_and_Kid_Gavilán_1954.jpg` |
| `speedbag_wright` | Hands up, eyes up. | Chalky Wright on the speed bag, 1942. | Unknown | Public domain | `https://commons.wikimedia.org/wiki/File:Chalky_Wright_speed_bag_1942.jpg` |
| `louis_spar` | Sparring is where it is decided. | Joe Louis sparring, 1945. | Unknown | Public domain | `https://commons.wikimedia.org/wiki/File:Joe_Louis_vs_Gene_Felton_sparring_1945.jpg` |
| `olympic_ring` | Under the lights. | The ring at the London 2012 Olympics. | sachab | CC BY 2.0 | `https://commons.wikimedia.org/wiki/File:Boxing_ring_at_the_2012_Summer_Olympics_(2).jpg` |
| `marine_1964` | Every rep counts. | Olympic training, Tokyo, 1964. | USMC Archives | CC BY 2.0 | `https://commons.wikimedia.org/wiki/File:Marine_Sergeant_Charlie_Brown_Trains_for_Olympics,_1964.jpg` |
| `navy_spar` | Iron sharpens iron. | Navy boxers sparring, 2008. | U.S. Navy photo by Mass Communication Specialist 2nd Class K | Public domain | `https://commons.wikimedia.org/wiki/File:US_Navy_081011-N-5345W-134_Navy_boxers_spar_during_the_All-Navy_Boxing_Team_mini-camp_at_Rockwell_Hall_Gym_at_Naval_Amphibious_Base_Little_Creek.jpg` |
| `navy_mitts` | Listen to your corner. | Mitt work with a coach, 2008. | U.S. Navy photo by Mass Communication Specialist 2nd Class K | Public domain | `https://commons.wikimedia.org/wiki/File:US_Navy_081012-N-5345W-033_Dave_Cruz,_right,_an_assistant_coach_with_757_Boxing_Club_in_Virginia_Beach,_Va.,_gives_his_fighter_pointers_between_rounds_during_a_sparring_session_at_the_All-Navy_Boxing_Team_mini-camp_at_Rockwell.jpg` |
| `heavybag` | The bag never lies. | Heavy bag work. | U.S. Air Force AFCENT by Senior Airman Zachary Foster | Public domain | `https://commons.wikimedia.org/wiki/File:Training_for_Rumble_in_the_Deid_III_begins_(8614354).jpg` |
| `heavybag_2` | One more round. | Heavy bag work. | U.S. Air Force photo by Senior Airman Zachary Foster | Public domain | `https://commons.wikimedia.org/wiki/File:Training_for_Rumble_in_the_Deid_III_begins_(8614366).jpg` |
| `rope` | Footwork first. | Skipping rope. | somewhereto_ somewhereto_ from London, United Kingdom | CC BY-SA 2.0 | `https://commons.wikimedia.org/wiki/File:Somewhereto_practice_boxing_inside_Number_10_Downing_Street_(6211798887).jpg` |
| `gloves` | Gloves up. | Gloves on the bag, Zebra Boxing Club. | Gadlee | CC BY-SA 4.0 | `https://commons.wikimedia.org/wiki/File:Photos_taken_at_Zebra_Boxing_Club_on_20th_September_2025_01.jpg` |

### Posters
`PosterKind { tagline, legend, moment, inspiration, quote }` (chip labels: Taglines, Legends,
Moments, Inspiration, Quotes; `All` first). `Poster` gains `GalleryPhoto? gallery` (with the
owning `Legend`) and `WallPhoto? photo`. `posters()` order: 4 taglines, 12 legends, 34 moments
(in legends order, then gallery order), 14 inspiration, 84 quotes = 148. Moment id
`moment_<legendId>_<n>`, inspiration id `wall_<photo.id>`.

### Canvas
Moment and inspiration posters: the photo full-bleed (`BoxFit.cover`, `Alignment.center`,
`FilterQuality.high`) with a gradient from transparent at 45 percent height to `ink` at 0.92
alpha at the bottom; the corner mark top-left as on other posters. Moment: the legend's name in
`label` uppercase, the caption in `displayMedium` sized from width (`size.width * 0.11`),
credit in `caption` at the bottom: "{author}, {license}". Inspiration: the `line` in
`displayLarge` (`size.width * 0.16`, max 3 lines), caption in `bodyMuted`, credit line likewise.
Landscape photos crop to the poster's portrait frame; that is intended.

### About
CREDITS gains one line per wall photo: "Gym Wall, {id}: {author}, {license}", tappable to the source.

## Acceptance criteria
- [ ] `posters().length == 148` with the kind counts above; every moment and inspiration
      poster's credit text contains author and license; all assets exist.
- [ ] `PosterCanvas` renders a moment and an inspiration poster at 360 x 780 without overflow.
- [ ] Gym Wall shows six chips and filters correctly.
- [ ] `flutter analyze` 0 issues.

## Verification
- Assistant tests: extend `test/data/posters_test.dart`, `test/widgets/poster_canvas_test.dart`,
  `test/pages/gym_wall_page_test.dart`; new `test/data/wall_photos_test.dart`.
