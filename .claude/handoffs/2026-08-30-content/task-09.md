# Task 09 - Legend photos: crops, galleries, own quotes only, icons

- **Run:** `.claude/handoffs/2026-08-30-content/`
- **Depends on:** task-08
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
Owner review: Ali, Frazier and Mayweather are clipped on the cards; the story page needs
archive photos (fights, training, press); only the legend's own quotes belong in their story;
the book icon on the Corner tab and the All-legends card looks wrong.

## Context the worker needs
- `Legend`, `legends`, `LegendCard`, `LegendPhoto`, `LegendStoryPage`, `CornerPage`,
  `AppShell`, `quotes` (task-01 numbering), `PhotoCredit`.
- New assets already in the repo: `assets/legends/gallery/*.jpg` (34 files, 5.8 MB), declare
  the folder in `pubspec.yaml`.

## Files
- `lib/models/legend.dart` - modify - `photoFocus`, `gallery`, `GalleryPhoto`.
- `lib/data/legends.dart` - modify - focal points, galleries, quote indexes.
- `lib/data/quotes.dart` - modify - three quotes appended (82 to 84).
- `lib/widgets/legend_card.dart` - modify - ratios and focus.
- `lib/pages/legend_story_page.dart` - modify - hero focus, gallery section.
- `lib/widgets/gallery_strip.dart` - create.
- `lib/pages/app_shell.dart`, `lib/pages/corner_page.dart` - modify - icons.
- `lib/pages/about_page.dart` - modify - gallery credits in CREDITS.
- `pubspec.yaml` - modify - `assets/legends/gallery/`.
- `docs/architecture.md` - modify.

## Spec

### Quotes appended (keep 1 to 81 unchanged)
82. "What would be better than walking down any street in any city and knowing you were the heavyweight champion of the world?" Rocky Marciano, Boxing
83. "I have found no better way of avoiding race prejudice than to act with people of other races as if prejudice did not exist." Jack Johnson, Boxing
84. "I've been dreaming about this since I was a young girl." Katie Taylor, Boxing
Rotation offsets stay valid (distinct modulo 84); update the count assertions.

### Own quotes only
`quoteIndexes` become (0-based into the 84 list): ali [0, 4, 40]; tyson [5, 46]; frazier
[9, 63]; foreman [14, 54]; marciano [81]; robinson [7, 53]; louis [50, 51, 52]; johnson [82];
pacquiao [56]; mayweather [13, 57]; kom [60]; taylor [83]. The story page places quote 1 after
section 1, quote 2 (if any) after section 3, quote 3 (if any) after section 4; a legend with
one quote shows it after section 2.

### Crops
`Legend.photoFocus` (`Alignment`, default `Alignment(0, -0.8)`): marciano `(0, -1)`, foreman
`(0, -1)`, johnson `(0, -0.7)`, taylor `Alignment.center`, others default. `LegendCard` list ratio
becomes 1:1 and featured 4:3; `LegendPhoto` uses `alignment: legend.photoFocus`; the story
hero uses the same focus. Verify by rendering all twelve cards in a widget test at 393 dp:
no exceptions, and an assertion that the `Image` widget's `alignment` equals `photoFocus`.


### Primary photo swaps (HD re-export, 2026-08-30)
All primaries were re-exported at up to 2000 px from the Commons originals. Four were swapped
for sharper license-clean sources; update `credit` (and the About page credit lines) for:
| id | new file | author | license |
|---|---|---|---|
| tyson | `Mike_Tyson_Early_Portrait_high_res.jpg` | Unknown (promotional portrait) | Public domain |
| robinson | `Sugar_Ray_Robinson_1950.jpg` | Unknown | Public domain |
| mayweather | `Floyd_Mayweather,_Jr._2011.jpg` | Chamber of Fear | CC BY-SA 2.0 |
| taylor | `Katie_Taylor_2012_(2).jpg` | cormac70 | CC BY 2.0 |
The `source` is `https://commons.wikimedia.org/wiki/File:<new file>`. Taylor's new photo is
landscape (1600 x 1042): `photoFocus` `Alignment.center` and, on the story hero, `BoxFit.cover`
still applies. Johnson (1089 x 1383) and Pacquiao (746 x 984) have no larger clean portrait on
Commons; keep them.

### Gallery
`class GalleryPhoto { const GalleryPhoto({required this.asset, required this.caption, required this.credit}); }`
(`credit` is a `PhotoCredit`). `Legend.gallery` (`List<GalleryPhoto>`, const). Story page: a
section "FROM THE ARCHIVE" between the last story section and the takeaways: a horizontal
`GalleryStrip` of the photos (each 280 dp wide, `radiusMd`, `BoxFit.cover` at 4:3 with
`Alignment.center`, caption in `caption` under the image, two lines, and a `chalkFaint`
credit line "{author}, {license}" that opens the source). Tapping a photo opens a
full-screen viewer (`showDialog` with a black barrier, `InteractiveViewer`, caption at the
bottom, close on tap outside). About page CREDITS lists gallery photos too (one line per photo:
"{legend name}, archive {n}: {author}, {license}").

Gallery data (asset, caption, author, license, source):

| legend | asset | caption | author | license | source |
|---|---|---|---|---|---|
| ali | `ali_1.jpg` | Backing Sonny Liston into the ropes, Miami Beach, 25 February 1964. | Associated Press | Public domain | `https://commons.wikimedia.org/wiki/File:Ali_punches_Liston_1964_AP_photo.jpg` |
| ali | `ali_2.jpg` | In Amsterdam, 1966, at the height of his speed. | Anefo | CC0 | `https://commons.wikimedia.org/wiki/File:Bokser_Cassius_Clay_(USA_(1966)_(Mohammed_Ali),_Bestanddeelnr_924-3060.jpg` |
| ali | `ali_3.jpg` | On the cover of El Grafico, March 1964, a week after beating Liston. | El Gráfico | Public domain | `https://commons.wikimedia.org/wiki/File:Cassius_Clay_-_El_Gráfico_2317.jpg` |
| tyson | `tyson_1.jpg` | The night he became champion: hitting Trevor Berbick, 22 November 1986. | Douglas C. Pizac | Public domain | `https://commons.wikimedia.org/wiki/File:Mike_Tyson_hitting_Trevor_Berbick(cropped).jpg` |
| tyson | `tyson_2.jpg` | February 1986, nineteen years old and eighteen fights in. | Unknown | Public domain | `https://commons.wikimedia.org/wiki/File:Mike_Tyson_in_February_1986.jpg` |
| tyson | `tyson_3.jpg` | Against Jesse Ferguson, 1986. | Unknown | Public domain | `https://commons.wikimedia.org/wiki/File:Mike_Tyson_vs_Jesse_Ferguson.jpg` |
| frazier | `frazier_1.jpg` | Arriving at Amsterdam Schiphol, 1971. | Hans Peters for Anefo | CC0 | `https://commons.wikimedia.org/wiki/File:Aankomst_van_Joe_Frazier_op_Schiphol,_Bestanddeelnr_924-5567.jpg` |
| frazier | `frazier_2.jpg` | On stage with his band in the Netherlands, 1971. Frazier sang between fights. | W. Punt for Anefo | CC0 | `https://commons.wikimedia.org/wiki/File:Joe_Frazier_en_zijn_groep_tijdens_het_concert,_Bestanddeelnr_924-5576.jpg` |
| foreman | `foreman_1.jpg` | At Schiphol in 1973, the year he took the title from Frazier. | Bert Verhoeff / Anefo | CC0 | `https://commons.wikimedia.org/wiki/File:Bokskampioen_Georg_Foreman_op_Schiphol,_Georg_Foreman_met_Romeo_Ommel,_Bestanddeelnr_926-2855.jpg` |
| foreman | `foreman_2.jpg` | Commemorated on a 1968 stamp after his Olympic gold in Mexico City. | Government of Sharjah | Public domain | `https://commons.wikimedia.org/wiki/File:Boxing---George-Foreman.jpg` |
| marciano | `marciano_1.jpg` | The right hand that knocked out Jersey Joe Walcott in the thirteenth round, Philadelphia, 23 September 1952. | Herb Scharfman | Public domain | `https://commons.wikimedia.org/wiki/File:Rocky_Marciano_knocks_out_Jersey_Joe_Walcott,_1952.jpg` |
| marciano | `marciano_2.jpg` | Training before the Walcott fight, 1952. | United Press International | Public domain | `https://commons.wikimedia.org/wiki/File:Rocky_Marciano_and_Jersey_Joe_Walcott_training_1952_press_photo.jpg` |
| marciano | `marciano_3.jpg` | Walcott down in the first round of the rematch, Chicago, 1953. | Unknown | Public domain | `https://commons.wikimedia.org/wiki/File:Jersey_Joe_Walcott_hits_the_deck_1953.jpg` |
| robinson | `robinson_1.jpg` | Blocking Jake LaMotta in their sixth fight, Chicago, 14 February 1951. | Unknown | Public domain | `https://commons.wikimedia.org/wiki/File:Sugar_Ray_Robinson_vs_Jake_LaMotta_1951_(1).jpg` |
| robinson | `robinson_2.jpg` | The referee raises his hand: middleweight champion, 1951. | Unknown | Public domain | `https://commons.wikimedia.org/wiki/File:Sugar_Ray_Robinson_vs_Jake_LaMotta_1951_(2).jpg` |
| robinson | `robinson_3.jpg` | With Kid Gavilan, 1949. | Unknown | Public domain | `https://commons.wikimedia.org/wiki/File:Kid_Gavilán_and_Sugar_Ray_Robinson_1949.jpg` |
| louis | `louis_1.jpg` | The rematch: Schmeling down at Yankee Stadium, 22 June 1938. | Associated Press | Public domain | `https://commons.wikimedia.org/wiki/File:Joe_Louis_knocks_out_Max_Schmeling.jpg` |
| louis | `louis_2.jpg` | Standing over Schmeling, 1938. | Associated Press | Public domain | `https://commons.wikimedia.org/wiki/File:Joe_Louis_standing_over_Max_Schmeling_1938.jpg` |
| louis | `louis_3.jpg` | Harlem celebrates the night of the rematch, June 1938. | Unknown | Public domain | `https://commons.wikimedia.org/wiki/File:Celebrations_in_Harlem_after_Joe_Louis_knocked_out_Max_Schmeling_(5).jpg` |
| johnson | `johnson_1.jpg` | The Fight of the Century against James Jeffries, Reno, 4 July 1910. | AnonymousUnknown author | Public domain | `https://commons.wikimedia.org/wiki/File:Johnson-Jeffries_Prize_Fight,_4_July_1910.jpg` |
| johnson | `johnson_2.jpg` | The fight poster, 1910. | Unknown | Public domain | `https://commons.wikimedia.org/wiki/File:Jack_Johnson_vs_Jim_Jeffries_-_4_July_1910_World_Heavyweight_Boxing_poster.jpg` |
| johnson | `johnson_3.jpg` | Crowds outside Times Tower in New York waiting for news of the fight. | The Pictorial News Company | Public domain | `https://commons.wikimedia.org/wiki/File:Crowd_awaits_news_of_Jeffries_-_Johnson.JPG` |
| pacquiao | `pacquiao_1.jpg` | In the ring, 2008. | Shubert Ciencia from Nueva Ecija, Philippines | CC BY 2.0 | `https://commons.wikimedia.org/wiki/File:I_Am_Manny_Pacquiao_(2409886528).jpg` |
| pacquiao | `pacquiao_2.jpg` | The ring before Pacquiao vs Hatton, Las Vegas, 2009. | Jamie Davies | CC BY 2.0 | `https://commons.wikimedia.org/wiki/File:MGM_Pacquiao_vs._Hatton_pre-fight_ring.jpg` |
| pacquiao | `pacquiao_3.jpg` | MGM Grand Garden Arena before Pacquiao vs Thurman, 2019. | Toohool | CC BY-SA 4.0 | `https://commons.wikimedia.org/wiki/File:Pacquiao_vs._Thurman_arena.jpg` |
| mayweather | `mayweather_1.jpg` | At a press conference, 2011. | Chamber of Fear | CC BY-SA 2.0 | `https://commons.wikimedia.org/wiki/File:Floyd_Mayweather,_Jr._2011.jpg` |
| mayweather | `mayweather_2.jpg` | The MGM Grand billboard for Mayweather vs Pacquiao, May 2015. | Jimmy Harris | CC BY 2.0 | `https://commons.wikimedia.org/wiki/File:MGM_Mayweather_Pacquiao.jpg` |
| mayweather | `mayweather_3.jpg` | Working the pads at a DeWalt event, 2011. | DEWALT POWER TOOLS FIGHT NIGHT CLUB 2010 | CC BY-SA 2.0 | `https://commons.wikimedia.org/wiki/File:Floyd_Mayweather,_Jr._at_DeWalt_event_(5888721735).jpg` |
| kom | `kom_1.jpg` | Honoured by the Prime Minister after the London 2012 bronze, New Delhi. | Prime Minister's Office
 | GODL-India | `https://commons.wikimedia.org/wiki/File:Manmohan_Singh_honours_Smt._Mary_Kom,_the_London_Olympic_Bronze_Medal_winner,_at_the_All_India_Conference_of_Directors_GeneralInspectors_General_of_Police_-2012,_in_New_Delhi._The_Union_Home_Minister.jpg` |
| kom | `kom_2.jpg` | With the President of India. | President's Secretariat | GODL-India | `https://commons.wikimedia.org/wiki/File:Mary_Kom_with_Pranab.jpg` |
| kom | `kom_3.jpg` | With the London 2012 medal winners, New Delhi, August 2012. | Ministry of Youth Affairs and Sports
 | GODL-India | `https://commons.wikimedia.org/wiki/File:Ajay_Maken_with_the_Medal_Winners_of_London_Olympics_2012,_at_the_felicitation_function,_organised_by_the_Ministry_of_Youth_Affairs_&_Sports,_at_Major_Dhyan_Chand_National_Stadium,_in_New_Delhi_on_August_16,_2012.jpg` |
| taylor | `taylor_1.jpg` | Boxing at the London 2012 Olympics. | cormac70 | CC BY 2.0 | `https://commons.wikimedia.org/wiki/File:2012_Summer_Olympics_Katie_Taylor_2.jpg` |
| taylor | `taylor_2.jpg` | The moment it was over, London 2012. | cormac70 | CC BY 2.0 | `https://commons.wikimedia.org/wiki/File:Katie_Taylor_2012_Summer_Olympics_It's_All_Over.jpg` |
| taylor | `taylor_3.jpg` | Walking to the ring in London, 2012. | cormac70 | CC BY 2.0 | `https://commons.wikimedia.org/wiki/File:Katie_Taylor_Enters_2012_Summer_Olympics.jpg` |

### Icons
Corner tab: `Icons.newspaper_rounded`. All-legends card on Corner: `Icons.emoji_events_rounded`.
The Legends page header keeps no icon.

## Acceptance criteria
- [ ] `quotes.length == 84`; every legend's quotes are by that legend (author starts with the
      legend's surname or name); marciano, johnson, taylor each show one quote.
- [ ] All twelve cards render without clipping exceptions; `photoFocus` reaches the `Image`.
- [ ] Each legend has 2 or 3 gallery photos whose assets exist; captions non-empty; credits
      complete; the story page shows the strip; the viewer opens.
- [ ] Icons replaced; `flutter analyze` 0 issues.

## Verification
- Assistant tests: extend `test/data/legends_test.dart`, `test/data/quotes_test.dart`,
  `test/widgets/legend_card_test.dart`, `test/pages/legend_story_page_test.dart`; new
  `test/widgets/gallery_strip_test.dart`.
