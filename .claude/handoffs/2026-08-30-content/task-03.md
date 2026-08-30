# Task 03 - Legends content and model

- **Run:** `.claude/handoffs/2026-08-30-content/`
- **Depends on:** task-02
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
Twelve boxers' stories as bundled data: who they were, where they came from, what broke them
and what they did about it, what to take from it, with pull quotes from the quote library and a
license-checked photo each. Task-04 builds the screens.

## Context the worker needs
- `lib/models/quote.dart`, `lib/data/quotes.dart` (task-01 numbering: quotes are referenced by
  their 1-based number in that list; store them as `quoteIndexes` 0-based).
- Photos are already at `assets/legends/<id>.jpg`; declare `assets/legends/` in `pubspec.yaml`.
- The text below is final. Type it in exactly (no em-dashes; the copy uses commas and full
  stops on purpose). Do not add facts, dates or adjectives.

## Files
- `lib/models/legend.dart` - create - `Legend`, `StorySection`, `PhotoCredit`.
- `lib/data/legends.dart` - create - `legends`, `findLegend`, `legendOfTheWeek`.
- `pubspec.yaml` - modify - `assets/legends/`.
- `docs/architecture.md` - modify - rows, bundled data line.

## Spec

### Models
```dart
class PhotoCredit { const PhotoCredit({required this.author, required this.license, required this.source}); }
class StorySection { const StorySection({required this.heading, required this.body}); }
class Legend {
  const Legend({required this.id, required this.name, required this.nickname, required this.years,
    required this.country, required this.division, required this.record, required this.hook,
    required this.sections, required this.quoteIndexes, required this.takeaways,
    required this.imageAsset, required this.credit});
}
```
All `const`, all fields `final`. `Legend legendOfTheWeek(DateTime day)` = `legends[weekOfYear % 12]`
where `weekOfYear = (dayOfYear(day) - 1) ~/ 7`. `Legend? findLegend(String id)`.

### Photo credits (from Wikimedia Commons; the `source` is the file page)
| id | author | license | source file |
|---|---|---|---|
| ali | Ira Rosenberg, World Telegram | Public domain | `https://commons.wikimedia.org/wiki/File:Muhammad_Ali_NYWTS.jpg` |
| tyson | Super Festivals | CC BY 2.0 | `https://commons.wikimedia.org/wiki/File:Mike_Tyson_Photo_Op_GalaxyCon_Austin_2023.jpg` |
| frazier | Hans Peters, Anefo, Nationaal Archief | CC BY-SA 3.0 NL | `https://commons.wikimedia.org/wiki/File:Joe_Frazier_reading_newspaper_cropped.jpg` |
| foreman | Bert Verhoeff, Anefo, Nationaal Archief | CC0 | `https://commons.wikimedia.org/wiki/File:George_Foreman_(1973).jpg` |
| marciano | Associated Press | Public domain | `https://commons.wikimedia.org/wiki/File:Rocky_Marciano_(cropped).jpg` |
| robinson | ACME Newspictures | Public domain | `https://commons.wikimedia.org/wiki/File:Sugar_Ray_Robinson_1947.jpg` |
| louis | Carl Van Vechten | Public domain | `https://commons.wikimedia.org/wiki/File:Joe_Louis_by_van_Vechten.jpg` |
| johnson | George Grantham Bain Collection, Library of Congress | Public domain | `https://commons.wikimedia.org/wiki/File:Jack_Johnson,_1915_(edit).jpg` |
| pacquiao | Robert Oswald P. Alfiler, Philippine News Agency | Public domain | `https://commons.wikimedia.org/wiki/File:Former_senator_Manny_Pacquiao_speaks_in_event_(10-01-2025)_(cropped).jpg` |
| mayweather | DeWalt Power Tools Fight Night Club 2010 | CC BY-SA 2.0 | `https://commons.wikimedia.org/wiki/File:Floyd_Mayweather_Jr_2011.jpg` |
| kom | British High Commission, India | OGL v1.0 | `https://commons.wikimedia.org/wiki/File:Mary_Kom_-_British_High_Commission,_Delhi,_27_July_2011.jpg` |
| taylor | cormac70 | CC BY 2.0 | `https://commons.wikimedia.org/wiki/File:Katie_Taylor_2012_(cropped).jpg` |

### The twelve legends (in this order)

**ali** Muhammad Ali, "The Greatest", 1942 to 2016, United States, Heavyweight, record "56 wins, 5 losses".
hook: "Three times heavyweight champion, and the only one who gave up the title on principle."
Sections:
1. "The stolen bicycle": "Cassius Clay was twelve when his bicycle was stolen in Louisville, Kentucky. He told a policeman named Joe Martin he wanted to whip whoever took it. Martin ran a boxing gym and suggested he learn how first. Six years later Clay won the light heavyweight gold medal at the 1960 Rome Olympics, and in February 1964, at twenty-two, he beat Sonny Liston for the heavyweight title. He announced his new name, Muhammad Ali, days later."
2. "Three years taken": "In April 1967 Ali refused induction into the United States Army on religious grounds. He was stripped of his title within hours, banned from boxing in every state and faced prison. He did not fight for more than three years, the years a heavyweight is usually at his best. The Supreme Court overturned his conviction in 1971. By then he had lost his speed, and he would have to become a different fighter."
3. "The rope and the jungle": "Ali lost the Fight of the Century to Joe Frazier in March 1971, the first defeat of his career. In October 1974 in Kinshasa he faced George Foreman, unbeaten and feared, and did what nobody expected: he leaned on the ropes, covered up and let Foreman punch himself tired, then knocked him out in the eighth round. A year later in Manila he and Frazier fought fourteen rounds of the most brutal boxing ever filmed."
4. "After the lights": "Ali won the title a third time in 1978. Parkinson's disease slowed his speech and movement through the 1980s, and in 1996 the world watched his shaking hands light the Olympic flame in Atlanta. He died in June 2016. He had said the fight is won long before the dance under the lights; his life was the proof."
quoteIndexes: [0, 4, 40]
takeaways: ["A principle can cost you your best years. Decide in advance what you would pay for yours.", "When the speed goes, the mind has to carry the fight. Ali rebuilt his style at thirty-two.", "Talk is a tool. Ali used words to make opponents fight his fight before the first bell."]

**tyson** Mike Tyson, "Iron Mike", born 1966, United States, Heavyweight, record "50 wins, 6 losses".
hook: "The youngest heavyweight champion ever, built by one old man in the Catskills."
Sections:
1. "Brownsville": "Mike Tyson grew up in Brownsville, Brooklyn, with a stammer, a fear of bullies and a police record before he was a teenager. At a juvenile facility upstate a counsellor and former boxer, Bobby Stewart, saw something and took him to a seventy-year-old trainer named Cus D'Amato. D'Amato watched him spar and said he had just met the future heavyweight champion of the world. He became Tyson's legal guardian."
2. "Fear as fuel": "D'Amato taught the peek-a-boo style, head moving, gloves high, punches thrown in quick clusters from underneath. He also taught something harder: that fear is natural, that the hero and the coward feel the same thing, and that the difference is what you do with it. D'Amato died in November 1985. A year later, on 22 November 1986, Tyson stopped Trevor Berbick and became champion at twenty years and four months."
3. "The fall in Tokyo": "By 1988 Tyson was undisputed champion and looked unbeatable. Then the structure around him came apart: the trainers who knew him were pushed out, the discipline went, and in February 1990 in Tokyo an unfancied Buster Douglas knocked him out. Prison followed in 1992. He came back, lost twice to Evander Holyfield, and was disqualified in the second fight for biting."
4. "Living with it": "Tyson retired in 2005 and spent years saying, in public and in detail, what the fame had done to him and what he had done with it. The lesson he keeps returning to is D'Amato's: discipline is doing what you hate to do as if you loved it."
quoteIndexes: [5, 46, 61]
takeaways: ["Find the person who will hold you to a standard, and stay close to them.", "Talent without structure does not last. Tyson's decline began when the structure went.", "Fear does not go away. Train with it in the room."]

**frazier** Joe Frazier, "Smokin' Joe", 1944 to 2011, United States, Heavyweight, record "32 wins, 4 losses, 1 draw".
hook: "The pressure fighter who beat Ali first, and never stopped coming forward."
Sections:
1. "Beaufort to Philadelphia": "Joe Frazier was one of thirteen children on a farm near Beaufort, South Carolina. He left for New York and then Philadelphia as a teenager and took a job in a slaughterhouse, where he hit sides of beef for practice. He won the 1964 Olympic heavyweight gold medal in Tokyo, fighting the final with a broken thumb."
2. "The left hook": "Frazier's style was one idea repeated until it broke you: bob, weave, keep moving forward, and throw the left hook. Trainers called the head movement smokin'. On 8 March 1971 at Madison Square Garden, in the Fight of the Century, he dropped Muhammad Ali in the fifteenth round and won the decision, the first loss of Ali's career."
3. "Kingston and Manila": "In January 1973 George Foreman knocked Frazier down six times in two rounds and took the title. Frazier lost the rematch to Ali in 1974 and then, in October 1975 in Manila, fought Ali for fourteen rounds in heat above thirty degrees. His eyes were swollen shut when his trainer, Eddie Futch, stopped it before the fifteenth. Ali said afterwards it was the closest thing to dying he had known."
4. "Roadwork": "Frazier's most repeated advice was about the mornings: that a fight plan falls apart under the lights and what is left is your training, and that if you cheated on the roadwork in the dark, you would be found out. He died in November 2011."
quoteIndexes: [9, 63]
takeaways: ["One weapon mastered beats six half-learned. Frazier's hook was enough.", "Pressure is a style, and it has a cost. Decide if you can pay it.", "What you do at 5 a.m. shows up in round fourteen."]

**foreman** George Foreman, "Big George", 1949 to 2025, United States, Heavyweight, record "76 wins, 5 losses".
hook: "Champion at twenty-four, champion again at forty-five, and a different man each time."
Sections:
1. "Fifth Ward": "George Foreman grew up in Houston's Fifth Ward, dropped out of school and was mugging people by his mid-teens. The Job Corps, a government programme, took him in and a counsellor there put him in a boxing gym. Two years later, at nineteen, he won the 1968 Olympic heavyweight gold medal in Mexico City and waved a small American flag in the ring."
2. "The most feared man in boxing": "Foreman hit harder than anyone of his era. In January 1973 he knocked Joe Frazier down six times in two rounds to take the title. He was unbeaten in forty fights when he met Muhammad Ali in Kinshasa in October 1974, and he lost, exhausted, in the eighth round. Three years later, after a loss to Jimmy Young, he had what he described as a religious experience in the dressing room and walked away from boxing to preach."
3. "The comeback": "Ten years later, heavier, bald and smiling, Foreman came back at thirty-eight to fund a youth centre. Nobody took it seriously until he started winning. On 5 November 1994, at forty-five, he knocked out Michael Moorer with a right hand and became the oldest heavyweight champion in history, wearing the same red trunks he had worn against Ali."
4. "The second act": "Foreman made more money from the grill that carried his name than from any fight, and said so cheerfully. He died in March 2025. The scowling champion of 1973 and the grinning one of 1994 were the same man who had decided to change."
quoteIndexes: [14, 54]
takeaways: ["It is never too late to come back, but the second time you have to fight differently.", "Losing to Ali ended one career and started a better one. A loss can be a door.", "Do not let one version of yourself be the last one."]

**marciano** Rocky Marciano, "The Brockton Blockbuster", 1923 to 1969, United States, Heavyweight, record "49 wins, 0 losses".
hook: "The only heavyweight champion to retire undefeated, and the least gifted of the great ones."
Sections:
1. "Brockton": "Rocco Marchegiano was born in Brockton, Massachusetts, a shoe factory town, and wanted to be a baseball catcher. He learned to box in the Army during the Second World War and turned professional at twenty-three, late for a boxer. He was short for a heavyweight and had the shortest reach of any champion in the division."
2. "Outwork everyone": "Marciano could not outbox anyone, so he decided to outlast them. He ran further than his opponents, sparred more rounds and threw more punches per round than any heavyweight before him. In September 1952 Jersey Joe Walcott knocked him down in the first round; Marciano got up and knocked Walcott out in the thirteenth with one right hand to take the title."
3. "Beating a hero": "In October 1951 he stopped Joe Louis, the champion he had grown up admiring, and wept in the dressing room afterwards. He defended the title six times. On 27 April 1956, at thirty-two, he retired with forty-nine wins and no defeats, and refused every offer to come back."
4. "Gone early": "Marciano died in a small plane crash in August 1969, the day before his forty-sixth birthday. His record has never been matched by a heavyweight champion."
quoteIndexes: [10, 42]
takeaways: ["If you are not the most gifted, be the best conditioned. It is the one thing fully in your control.", "Get up. Marciano was down in round one and won in round thirteen.", "Leave on your own terms and do not look back."]

**robinson** Sugar Ray Robinson, "Sugar", 1921 to 1989, United States, Welterweight and Middleweight, record "More than 170 wins".
hook: "The reason the phrase pound for pound exists."
Sections:
1. "Borrowed name": "Walker Smith Jr. was born in Georgia and raised in Detroit and Harlem. As a teenager he borrowed another boxer's amateur card to enter a tournament, and the name on it, Ray Robinson, stuck. A sportswriter said his style was sweet as sugar. He turned professional in 1940 and did not lose for the first forty fights."
2. "Ninety-one in a row": "Between 1943 and 1951 Robinson went ninety-one fights without a defeat. He won the welterweight title in 1946 and the middleweight title in 1951, beating Jake LaMotta in the sixth of their six fights on Saint Valentine's Day. He would win the middleweight championship five separate times."
3. "The night the heat won": "In June 1952 Robinson moved up to challenge Joey Maxim for the light heavyweight title in New York in temperatures above forty degrees. He was far ahead on the cards when the heat beat him: the referee had already been replaced, and Robinson could not come out for the fourteenth round. It was the only stoppage loss of his career."
4. "Rhythm": "Robinson danced professionally during a two-year retirement and said every move in the ring starts with the heart, in rhythm. Writers invented the pound-for-pound ranking to explain that the best fighter alive was not a heavyweight. He died in 1989."
quoteIndexes: [7, 53]
takeaways: ["Style is rhythm. Train to a beat and the punches arrange themselves.", "Even the best have limits; know the conditions you can and cannot fight in.", "Longevity comes from craft. Robinson won titles across two decades."]

**louis** Joe Louis, "The Brown Bomber", 1914 to 1981, United States, Heavyweight, record "66 wins, 3 losses".
hook: "Twelve years as champion, twenty-five defences, and one fight that carried a country."
Sections:
1. "Alabama to Detroit": "Joseph Louis Barrow was born to sharecroppers in Alabama and grew up in Detroit, where he spent violin lesson money on a locker at a boxing gym. He turned professional in 1934 and went unbeaten for three years until Max Schmeling, a German veteran, studied his habits and knocked him out in twelve rounds in June 1936."
2. "One hundred and twenty-four seconds": "Louis won the title from James Braddock in 1937 but said he would not call himself champion until he beat Schmeling. The rematch on 22 June 1938 at Yankee Stadium was framed as democracy against Nazi Germany. Louis knocked Schmeling out in two minutes and four seconds of the first round."
3. "The long reign": "Louis held the heavyweight title for almost twelve years and defended it twenty-five times, records that still stand. During the Second World War he enlisted, fought exhibitions for troops and donated purses to the Army and Navy relief funds. He fought on too long to pay tax debts and lost to Rocky Marciano in 1951."
4. "Calm": "Louis said little in the ring or out of it. He is remembered for one line about an opponent who planned to keep moving: he can run, but he can't hide. He died in 1981 and was buried at Arlington National Cemetery."
quoteIndexes: [50, 51, 52]
takeaways: ["Study your losses. Louis lost to Schmeling once because Schmeling had studied him.", "Preparation makes you calm. Calm makes you accurate.", "Money earned in the ring needs the same discipline as the ring."]

**johnson** Jack Johnson, "The Galveston Giant", 1878 to 1946, United States, Heavyweight, record "Champion 1908 to 1915".
hook: "The first Black heavyweight champion, decades ahead of the sport and of his country."
Sections:
1. "Galveston": "Jack Johnson was born in Galveston, Texas, to parents who had been enslaved. He learned to fight on the docks and developed a style built on defence, counterpunching and patience, at a time when heavyweights mostly stood and traded. For years the white champions refused to fight him."
2. "Sydney, 1908": "Johnson followed the champion Tommy Burns across the world until Burns agreed to fight in Sydney on 26 December 1908. Johnson dominated for fourteen rounds until police stopped it. He was heavyweight champion of the world, and much of the American press began searching for a white challenger to take it back."
3. "The Fight of the Century": "The former champion James Jeffries came out of retirement to face Johnson in Reno on 4 July 1910. Johnson beat him easily. Riots followed in cities across the country. Johnson lived as he pleased, drove fast cars and married white women, and in 1913 was convicted under a law used to punish exactly that. He fled abroad and lost the title in Havana in 1915."
4. "The long arc": "Johnson died in a car crash in 1946. His defensive style is now the foundation of modern boxing, and in 2018 he received a posthumous presidential pardon. He had fought the sport and the century at the same time."
quoteIndexes: [31, 37]
takeaways: ["Defence is not passive. Johnson won by making opponents miss and pay.", "Patience gets the fight. Johnson chased his title across three continents.", "Doing the right thing can still cost everything. History catches up slowly."]

**pacquiao** Manny Pacquiao, "Pac-Man", born 1978, Philippines, Flyweight to Super Welterweight, record "Titles in eight divisions".
hook: "From selling bread in General Santos City to world titles in eight weight classes."
Sections:
1. "One hundred and six pounds": "Manny Pacquiao grew up poor in the southern Philippines, left home as a teenager and sold bread and doughnuts to eat. He turned professional at sixteen weighing one hundred and six pounds, sometimes putting weights in his pockets to make the minimum. He won his first world title, at flyweight, in 1998."
2. "The speed": "Pacquiao fought with a left hand that arrived before opponents saw it and a rhythm that never let them settle. In 2003 he stopped the Mexican great Marco Antonio Barrera. In 2008 he beat Oscar De La Hoya so thoroughly that De La Hoya retired. In 2009 he stopped Miguel Cotto to win the welterweight title, seven divisions above where he started."
3. "A nation stops": "During his fights the Philippines came to a standstill; police reported that crime fell to nothing for the hours he was in the ring. He lost the richest fight in history to Floyd Mayweather in 2015, was elected to the Senate in 2016, and in 2019, at forty, beat the unbeaten Keith Thurman for a welterweight title."
4. "Work": "Pacquiao says boxing is not about feelings but about performance, and his training camps, long runs at dawn and rounds of sparring into his forties, were the performance before the performance."
quoteIndexes: [56, 26]
takeaways: ["Start where you are, however small. A flyweight became a welterweight champion.", "Speed and volume beat size when the conditioning is there.", "Carrying other people's hopes can be fuel instead of weight."]

**mayweather** Floyd Mayweather Jr., "Money", born 1977, United States, Super Featherweight to Super Welterweight, record "50 wins, 0 losses".
hook: "Fifty fights, no defeats, and a defence so good opponents stopped trying."
Sections:
1. "A boxing family": "Floyd Mayweather Jr. was born in Grand Rapids, Michigan, into a family of boxers. His father, Floyd Sr., was a welterweight contender who went to prison when Floyd was a teenager, and his uncle Roger, a two-division world champion, took over his training. He won a bronze medal at the 1996 Olympics in a decision so contested that officials later apologised."
2. "The shoulder roll": "Mayweather's defence was the old Michigan style, the lead shoulder raised to catch punches, the head rolling away, the counter arriving before the opponent had reset. He won his first world title at super featherweight in 1998 and moved up through five divisions without a loss."
3. "The business": "Mayweather promoted himself, negotiated his own purses and became the highest-paid athlete in the world. In May 2015 he beat Manny Pacquiao in the richest fight ever staged. His fiftieth win, over Conor McGregor in 2017, took his record one past Rocky Marciano's."
4. "Behind the show": "The bravado hid a training regime that his rivals admitted was the hardest in the sport: midnight runs, marathon pad sessions, no missed days. He said a true champion can adapt to anything; the adapting was done in the gym."
quoteIndexes: [13, 57]
takeaways: ["Not getting hit is a skill. Train defence as hard as offence.", "Own your career. Mayweather controlled his fights, his purses and his story.", "The show is the last part. The work is not optional."]

**kom** Mary Kom, "Magnificent Mary", born 1982, India, Flyweight and Light Flyweight, record "Six world titles, Olympic bronze".
hook: "A farmer's daughter from Manipur who hid her boxing from her parents and became the most decorated boxer in World Championship history."
Sections:
1. "Kangathei": "Mangte Chungneijang Mary Kom grew up in a village in Manipur, in the far north-east of India, helping her parents in the fields. In 1998 a boxer from her state, Dingko Singh, won Asian Games gold, and she went to a gym in Imphal to learn. She did not tell her parents. They found out when her photograph appeared in a newspaper after she won a state championship."
2. "Six times": "Kom won her first World Championship in 2002 and her sixth in 2018 in New Delhi, at thirty-five, more than any boxer, man or woman, in the tournament's history. In between she won gold at the 2014 Asian Games and a bronze medal at the 2012 London Olympics, the first Games to include women's boxing."
3. "Twins": "In 2007 she gave birth to twin sons and stepped away. Many assumed she was finished. She returned the next year and won the 2008 World Championship. Later she was nominated to the upper house of India's parliament and kept training between sessions."
4. "Weak": "Her most quoted line is a refusal: do not let anyone tell you that you are weak because you are a woman. She said it to girls in Manipur first."
quoteIndexes: [60, 20]
takeaways: ["Start before permission. Kom trained in secret until the results spoke.", "Coming back is a decision, not a feeling. She won a world title a year after having twins.", "Represent where you come from. Kom put Manipur on every podium she stood on."]

**taylor** Katie Taylor, "KT", born 1986, Ireland, Lightweight, record "Undisputed lightweight champion".
hook: "Five amateur world titles, Olympic gold, and the first women's fight to headline Madison Square Garden."
Sections:
1. "Bray": "Katie Taylor grew up in Bray, County Wicklow, boxing in a gym run by her father Pete. Girls' boxing was not sanctioned in Ireland, so as a child she sometimes fought with her hair hidden under her headguard. In 2001 she boxed in the first officially sanctioned women's bout in the country. She also played football for Ireland."
2. "London 2012": "Taylor won five consecutive amateur World Championships between 2006 and 2014. At the 2012 London Olympics, the first Games with women's boxing, she won the lightweight gold medal in front of a crowd that the arena announcer asked to quieten more than once."
3. "Rio and after": "In 2016 she lost early at the Rio Olympics after a difficult year that included a split with her father as trainer. Weeks later she turned professional. By June 2019 she was the undisputed lightweight champion, holding all four world titles."
4. "The Garden": "On 30 April 2022 Taylor beat Amanda Serrano in the first women's fight to headline Madison Square Garden, a fight many called the best of the year in any division. She has rarely raised her voice in public; the record does it for her."
quoteIndexes: [21, 66]
takeaways: ["Do the work before the sport is ready for you. Taylor boxed before girls were allowed to.", "A bad year is not a verdict. Taylor turned professional weeks after Rio and became undisputed.", "Quiet is a style. Let the record talk."]

## Out of scope
- Screens (task-04). Photo changes. Any edit to the quote list.

## Acceptance criteria
- [ ] `legends.length == 12`, ids unique, every legend has 4 sections, 2 or 3 `quoteIndexes`
      within range whose quote author matches the legend's name or is Cus D'Amato for Tyson
      and Ali for Foreman's shadow line (test by listing the expected author per index), 3
      takeaways, an existing `imageAsset`, a credit with non-empty author, license and source.
- [ ] `legendOfTheWeek` covers all twelve across a year and is stable within a week.
- [ ] No em-dash in any string; every section body is between 300 and 700 characters.
- [ ] `flutter analyze` 0 issues.

## Verification
- Assistant tests: `test/data/legends_test.dart` (the invariants above; the asset existence
  check reads `pubspec.yaml` for the `assets/legends/` entry and `File(...).existsSync()` on
  each `imageAsset`).
