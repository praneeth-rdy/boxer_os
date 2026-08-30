import 'package:flutter/material.dart';

import '../models/legend.dart';
import '../utils/date_helpers.dart';

/// The bundled boxing legends, one story each.
const List<Legend> legends = [
  Legend(
    id: 'ali',
    name: 'Muhammad Ali',
    nickname: 'The Greatest',
    years: '1942 to 2016',
    country: 'United States',
    division: 'Heavyweight',
    record: '56 wins, 5 losses',
    hook:
        'Three times heavyweight champion, and the only one who gave up '
        'the title on principle.',
    sections: [
      StorySection(
        heading: 'The stolen bicycle',
        body:
            'Cassius Clay was twelve when his bicycle was stolen in '
            'Louisville, Kentucky. He told a policeman named Joe Martin he '
            'wanted to whip whoever took it. Martin ran a boxing gym and '
            'suggested he learn how first. Six years later Clay won the '
            'light heavyweight gold medal at the 1960 Rome Olympics, and in '
            'February 1964, at twenty-two, he beat Sonny Liston for the '
            'heavyweight title. He announced his new name, Muhammad Ali, '
            'days later.',
      ),
      StorySection(
        heading: 'Three years taken',
        body:
            'In April 1967 Ali refused induction into the United States '
            'Army on religious grounds. He was stripped of his title within '
            'hours, banned from boxing in every state and faced prison. He '
            'did not fight for more than three years, the years a '
            'heavyweight is usually at his best. The Supreme Court '
            'overturned his conviction in 1971. By then he had lost his '
            'speed, and he would have to become a different fighter.',
      ),
      StorySection(
        heading: 'The rope and the jungle',
        body:
            'Ali lost the Fight of the Century to Joe Frazier in March '
            '1971, the first defeat of his career. In October 1974 in '
            'Kinshasa he faced George Foreman, unbeaten and feared, and did '
            'what nobody expected: he leaned on the ropes, covered up and '
            'let Foreman punch himself tired, then knocked him out in the '
            'eighth round. A year later in Manila he and Frazier fought '
            'fourteen rounds of the most brutal boxing ever filmed.',
      ),
      StorySection(
        heading: 'After the lights',
        body:
            "Ali won the title a third time in 1978. Parkinson's disease "
            'slowed his speech and movement through the 1980s, and in 1996 '
            'the world watched his shaking hands light the Olympic flame in '
            'Atlanta. He died in June 2016. He had said the fight is won '
            'long before the dance under the lights; his life was the '
            'proof.',
      ),
    ],
    quoteIndexes: [0, 4, 40],
    takeaways: [
      'A principle can cost you your best years. Decide in advance '
          'what you would pay for yours.',
      'When the speed goes, the mind has to carry the fight. Ali '
          'rebuilt his style at thirty-two.',
      'Talk is a tool. Ali used words to make opponents fight his '
          'fight before the first bell.',
    ],
    imageAsset: 'assets/legends/ali.jpg',
    credit: PhotoCredit(
      author: 'Ira Rosenberg, World Telegram',
      license: 'Public domain',
      source: 'https://commons.wikimedia.org/wiki/File:Muhammad_Ali_NYWTS.jpg',
    ),
    gallery: [
      GalleryPhoto(
        asset: 'assets/legends/gallery/ali_1.jpg',
        caption:
            'Backing Sonny Liston into the ropes, Miami Beach, 25 February '
            '1964.',
        credit: PhotoCredit(
          author: 'Associated Press',
          license: 'Public domain',
          source:
              'https://commons.wikimedia.org/wiki/File:Ali_punches_Liston_1964_AP_photo.jpg',
        ),
      ),
      GalleryPhoto(
        asset: 'assets/legends/gallery/ali_2.jpg',
        caption: 'In Amsterdam, 1966, at the height of his speed.',
        credit: PhotoCredit(
          author: 'Anefo',
          license: 'CC0',
          source:
              'https://commons.wikimedia.org/wiki/File:Bokser_Cassius_Clay_(USA_(1966)_(Mohammed_Ali),_Bestanddeelnr_924-3060.jpg',
        ),
      ),
      GalleryPhoto(
        asset: 'assets/legends/gallery/ali_3.jpg',
        caption:
            'On the cover of El Grafico, March 1964, a week after beating '
            'Liston.',
        credit: PhotoCredit(
          author: 'El Gráfico',
          license: 'Public domain',
          source:
              'https://commons.wikimedia.org/wiki/File:Cassius_Clay_-_El_Gráfico_2317.jpg',
        ),
      ),
    ],
  ),
  Legend(
    id: 'tyson',
    name: 'Mike Tyson',
    nickname: 'Iron Mike',
    years: 'born 1966',
    country: 'United States',
    division: 'Heavyweight',
    record: '50 wins, 6 losses',
    hook:
        'The youngest heavyweight champion ever, built by one old man '
        'in the Catskills.',
    sections: [
      StorySection(
        heading: 'Brownsville',
        body:
            'Mike Tyson grew up in Brownsville, Brooklyn, with a stammer, a '
            'fear of bullies and a police record before he was a teenager. '
            'At a juvenile facility upstate a counsellor and former boxer, '
            'Bobby Stewart, saw something and took him to a '
            "seventy-year-old trainer named Cus D'Amato. D'Amato watched "
            'him spar and said he had just met the future heavyweight '
            "champion of the world. He became Tyson's legal guardian.",
      ),
      StorySection(
        heading: 'Fear as fuel',
        body:
            "D'Amato taught the peek-a-boo style, head moving, gloves high, "
            'punches thrown in quick clusters from underneath. He also '
            'taught something harder: that fear is natural, that the hero '
            'and the coward feel the same thing, and that the difference is '
            "what you do with it. D'Amato died in November 1985. A year "
            'later, on 22 November 1986, Tyson stopped Trevor Berbick and '
            'became champion at twenty years and four months.',
      ),
      StorySection(
        heading: 'The fall in Tokyo',
        body:
            'By 1988 Tyson was undisputed champion and looked unbeatable. '
            'Then the structure around him came apart: the trainers who '
            'knew him were pushed out, the discipline went, and in February '
            '1990 in Tokyo an unfancied Buster Douglas knocked him out. '
            'Prison followed in 1992. He came back, lost twice to Evander '
            'Holyfield, and was disqualified in the second fight for '
            'biting.',
      ),
      StorySection(
        heading: 'Living with it',
        body:
            'Tyson retired in 2005 and spent years saying, in public and in '
            'detail, what the fame had done to him and what he had done '
            "with it. The lesson he keeps returning to is D'Amato's: "
            'discipline is doing what you hate to do as if you loved it.',
      ),
    ],
    quoteIndexes: [5, 46],
    takeaways: [
      'Find the person who will hold you to a standard, and stay '
          'close to them.',
      "Talent without structure does not last. Tyson's decline "
          'began when the structure went.',
      'Fear does not go away. Train with it in the room.',
    ],
    imageAsset: 'assets/legends/tyson.jpg',
    credit: PhotoCredit(
      author: 'Unknown (promotional portrait)',
      license: 'Public domain',
      source:
          'https://commons.wikimedia.org/wiki/File:Mike_Tyson_Early_Portrait_high_res.jpg',
    ),
    gallery: [
      GalleryPhoto(
        asset: 'assets/legends/gallery/tyson_1.jpg',
        caption:
            'The night he became champion: hitting Trevor Berbick, 22 '
            'November 1986.',
        credit: PhotoCredit(
          author: 'Douglas C. Pizac',
          license: 'Public domain',
          source:
              'https://commons.wikimedia.org/wiki/File:Mike_Tyson_hitting_Trevor_Berbick(cropped).jpg',
        ),
      ),
      GalleryPhoto(
        asset: 'assets/legends/gallery/tyson_2.jpg',
        caption: 'February 1986, nineteen years old and eighteen fights in.',
        credit: PhotoCredit(
          author: 'Unknown',
          license: 'Public domain',
          source:
              'https://commons.wikimedia.org/wiki/File:Mike_Tyson_in_February_1986.jpg',
        ),
      ),
      GalleryPhoto(
        asset: 'assets/legends/gallery/tyson_3.jpg',
        caption: 'Against Jesse Ferguson, 1986.',
        credit: PhotoCredit(
          author: 'Unknown',
          license: 'Public domain',
          source:
              'https://commons.wikimedia.org/wiki/File:Mike_Tyson_vs_Jesse_Ferguson.jpg',
        ),
      ),
    ],
  ),
  Legend(
    id: 'frazier',
    name: 'Joe Frazier',
    nickname: "Smokin' Joe",
    years: '1944 to 2011',
    country: 'United States',
    division: 'Heavyweight',
    record: '32 wins, 4 losses, 1 draw',
    hook:
        'The pressure fighter who beat Ali first, and never stopped '
        'coming forward.',
    sections: [
      StorySection(
        heading: 'Beaufort to Philadelphia',
        body:
            'Joe Frazier was one of thirteen children on a farm near '
            'Beaufort, South Carolina. He left for New York and then '
            'Philadelphia as a teenager and took a job in a slaughterhouse, '
            'where he hit sides of beef for practice. He won the 1964 '
            'Olympic heavyweight gold medal in Tokyo, fighting the final '
            'with a broken thumb.',
      ),
      StorySection(
        heading: 'The left hook',
        body:
            "Frazier's style was one idea repeated until it broke you: bob, "
            'weave, keep moving forward, and throw the left hook. Trainers '
            "called the head movement smokin'. On 8 March 1971 at Madison "
            'Square Garden, in the Fight of the Century, he dropped '
            'Muhammad Ali in the fifteenth round and won the decision, the '
            "first loss of Ali's career.",
      ),
      StorySection(
        heading: 'Kingston and Manila',
        body:
            'In January 1973 George Foreman knocked Frazier down six times '
            'in two rounds and took the title. Frazier lost the rematch to '
            'Ali in 1974 and then, in October 1975 in Manila, fought Ali '
            'for fourteen rounds in heat above thirty degrees. His eyes '
            'were swollen shut when his trainer, Eddie Futch, stopped it '
            'before the fifteenth. Ali said afterwards it was the closest '
            'thing to dying he had known.',
      ),
      StorySection(
        heading: 'Roadwork',
        body:
            "Frazier's most repeated advice was about the mornings: that a "
            'fight plan falls apart under the lights and what is left is '
            'your training, and that if you cheated on the roadwork in the '
            'dark, you would be found out. He died in November 2011.',
      ),
    ],
    quoteIndexes: [9, 63],
    takeaways: [
      "One weapon mastered beats six half-learned. Frazier's hook "
          'was enough.',
      'Pressure is a style, and it has a cost. Decide if you can '
          'pay it.',
      'What you do at 5 a.m. shows up in round fourteen.',
    ],
    imageAsset: 'assets/legends/frazier.jpg',
    credit: PhotoCredit(
      author: 'Hans Peters, Anefo, Nationaal Archief',
      license: 'CC BY-SA 3.0 NL',
      source:
          'https://commons.wikimedia.org/wiki/File:Joe_Frazier_reading_newspaper_cropped.jpg',
    ),
    gallery: [
      GalleryPhoto(
        asset: 'assets/legends/gallery/frazier_1.jpg',
        caption: 'Arriving at Amsterdam Schiphol, 1971.',
        credit: PhotoCredit(
          author: 'Hans Peters for Anefo',
          license: 'CC0',
          source:
              'https://commons.wikimedia.org/wiki/File:Aankomst_van_Joe_Frazier_op_Schiphol,_Bestanddeelnr_924-5567.jpg',
        ),
      ),
      GalleryPhoto(
        asset: 'assets/legends/gallery/frazier_2.jpg',
        caption:
            'On stage with his band in the Netherlands, 1971. Frazier sang '
            'between fights.',
        credit: PhotoCredit(
          author: 'W. Punt for Anefo',
          license: 'CC0',
          source:
              'https://commons.wikimedia.org/wiki/File:Joe_Frazier_en_zijn_groep_tijdens_het_concert,_Bestanddeelnr_924-5576.jpg',
        ),
      ),
    ],
  ),
  Legend(
    id: 'foreman',
    name: 'George Foreman',
    nickname: 'Big George',
    years: '1949 to 2025',
    country: 'United States',
    division: 'Heavyweight',
    record: '76 wins, 5 losses',
    hook:
        'Champion at twenty-four, champion again at forty-five, and a '
        'different man each time.',
    sections: [
      StorySection(
        heading: 'Fifth Ward',
        body:
            "George Foreman grew up in Houston's Fifth Ward, dropped out of "
            'school and was mugging people by his mid-teens. The Job Corps, '
            'a government programme, took him in and a counsellor there put '
            'him in a boxing gym. Two years later, at nineteen, he won the '
            '1968 Olympic heavyweight gold medal in Mexico City and waved a '
            'small American flag in the ring.',
      ),
      StorySection(
        heading: 'The most feared man in boxing',
        body:
            'Foreman hit harder than anyone of his era. In January 1973 he '
            'knocked Joe Frazier down six times in two rounds to take the '
            'title. He was unbeaten in forty fights when he met Muhammad '
            'Ali in Kinshasa in October 1974, and he lost, exhausted, in '
            'the eighth round. Three years later, after a loss to Jimmy '
            'Young, he had what he described as a religious experience in '
            'the dressing room and walked away from boxing to preach.',
      ),
      StorySection(
        heading: 'The comeback',
        body:
            'Ten years later, heavier, bald and smiling, Foreman came back '
            'at thirty-eight to fund a youth centre. Nobody took it '
            'seriously until he started winning. On 5 November 1994, at '
            'forty-five, he knocked out Michael Moorer with a right hand '
            'and became the oldest heavyweight champion in history, wearing '
            'the same red trunks he had worn against Ali.',
      ),
      StorySection(
        heading: 'The second act',
        body:
            'Foreman made more money from the grill that carried his name '
            'than from any fight, and said so cheerfully. He died in March '
            '2025. The scowling champion of 1973 and the grinning one of '
            '1994 were the same man who had decided to change.',
      ),
    ],
    quoteIndexes: [14, 54],
    takeaways: [
      'It is never too late to come back, but the second time you '
          'have to fight differently.',
      'Losing to Ali ended one career and started a better one. A '
          'loss can be a door.',
      'Do not let one version of yourself be the last one.',
    ],
    imageAsset: 'assets/legends/foreman.jpg',
    credit: PhotoCredit(
      author: 'Bert Verhoeff, Anefo, Nationaal Archief',
      license: 'CC0',
      source:
          'https://commons.wikimedia.org/wiki/File:George_Foreman_(1973).jpg',
    ),
    gallery: [
      GalleryPhoto(
        asset: 'assets/legends/gallery/foreman_1.jpg',
        caption:
            'At Schiphol in 1973, the year he took the title from Frazier.',
        credit: PhotoCredit(
          author: 'Bert Verhoeff / Anefo',
          license: 'CC0',
          source:
              'https://commons.wikimedia.org/wiki/File:Bokskampioen_Georg_Foreman_op_Schiphol,_Georg_Foreman_met_Romeo_Ommel,_Bestanddeelnr_926-2855.jpg',
        ),
      ),
      GalleryPhoto(
        asset: 'assets/legends/gallery/foreman_2.jpg',
        caption:
            'Commemorated on a 1968 stamp after his Olympic gold in Mexico '
            'City.',
        credit: PhotoCredit(
          author: 'Government of Sharjah',
          license: 'Public domain',
          source:
              'https://commons.wikimedia.org/wiki/File:Boxing---George-Foreman.jpg',
        ),
      ),
    ],
    photoFocus: Alignment(0, -1),
  ),
  Legend(
    id: 'marciano',
    name: 'Rocky Marciano',
    nickname: 'The Brockton Blockbuster',
    years: '1923 to 1969',
    country: 'United States',
    division: 'Heavyweight',
    record: '49 wins, 0 losses',
    hook:
        'The only heavyweight champion to retire undefeated, and the '
        'least gifted of the great ones.',
    sections: [
      StorySection(
        heading: 'Brockton',
        body:
            'Rocco Marchegiano was born in Brockton, Massachusetts, a shoe '
            'factory town, and wanted to be a baseball catcher. He learned '
            'to box in the Army during the Second World War and turned '
            'professional at twenty-three, late for a boxer. He was short '
            'for a heavyweight and had the shortest reach of any champion '
            'in the division.',
      ),
      StorySection(
        heading: 'Outwork everyone',
        body:
            'Marciano could not outbox anyone, so he decided to outlast '
            'them. He ran further than his opponents, sparred more rounds '
            'and threw more punches per round than any heavyweight before '
            'him. In September 1952 Jersey Joe Walcott knocked him down in '
            'the first round; Marciano got up and knocked Walcott out in '
            'the thirteenth with one right hand to take the title.',
      ),
      StorySection(
        heading: 'Beating a hero',
        body:
            'In October 1951 he stopped Joe Louis, the champion he had '
            'grown up admiring, and wept in the dressing room afterwards. '
            'He defended the title six times. On 27 April 1956, at '
            'thirty-two, he retired with forty-nine wins and no defeats, '
            'and refused every offer to come back.',
      ),
      StorySection(
        heading: 'Gone early',
        body:
            'Marciano died in a small plane crash in August 1969, the day '
            'before his forty-sixth birthday. His record has never been '
            'matched by a heavyweight champion.',
      ),
    ],
    quoteIndexes: [81],
    takeaways: [
      'If you are not the most gifted, be the best conditioned. It '
          'is the one thing fully in your control.',
      'Get up. Marciano was down in round one and won in round '
          'thirteen.',
      'Leave on your own terms and do not look back.',
    ],
    imageAsset: 'assets/legends/marciano.jpg',
    credit: PhotoCredit(
      author: 'Associated Press',
      license: 'Public domain',
      source:
          'https://commons.wikimedia.org/wiki/File:Rocky_Marciano_(cropped).jpg',
    ),
    gallery: [
      GalleryPhoto(
        asset: 'assets/legends/gallery/marciano_1.jpg',
        caption:
            'The right hand that knocked out Jersey Joe Walcott in the '
            'thirteenth round, Philadelphia, 23 September 1952.',
        credit: PhotoCredit(
          author: 'Herb Scharfman',
          license: 'Public domain',
          source:
              'https://commons.wikimedia.org/wiki/File:Rocky_Marciano_knocks_out_Jersey_Joe_Walcott,_1952.jpg',
        ),
      ),
      GalleryPhoto(
        asset: 'assets/legends/gallery/marciano_2.jpg',
        caption: 'Training before the Walcott fight, 1952.',
        credit: PhotoCredit(
          author: 'United Press International',
          license: 'Public domain',
          source:
              'https://commons.wikimedia.org/wiki/File:Rocky_Marciano_and_Jersey_Joe_Walcott_training_1952_press_photo.jpg',
        ),
      ),
      GalleryPhoto(
        asset: 'assets/legends/gallery/marciano_3.jpg',
        caption:
            'Walcott down in the first round of the rematch, Chicago, 1953.',
        credit: PhotoCredit(
          author: 'Unknown',
          license: 'Public domain',
          source:
              'https://commons.wikimedia.org/wiki/File:Jersey_Joe_Walcott_hits_the_deck_1953.jpg',
        ),
      ),
    ],
    photoFocus: Alignment(0, -1),
  ),
  Legend(
    id: 'robinson',
    name: 'Sugar Ray Robinson',
    nickname: 'Sugar',
    years: '1921 to 1989',
    country: 'United States',
    division: 'Welterweight and Middleweight',
    record: 'More than 170 wins',
    hook: 'The reason the phrase pound for pound exists.',
    sections: [
      StorySection(
        heading: 'Borrowed name',
        body:
            'Walker Smith Jr. was born in Georgia and raised in Detroit and '
            "Harlem. As a teenager he borrowed another boxer's amateur card "
            'to enter a tournament, and the name on it, Ray Robinson, '
            'stuck. A sportswriter said his style was sweet as sugar. He '
            'turned professional in 1940 and did not lose for the first '
            'forty fights.',
      ),
      StorySection(
        heading: 'Ninety-one in a row',
        body:
            'Between 1943 and 1951 Robinson went ninety-one fights without '
            'a defeat. He won the welterweight title in 1946 and the '
            'middleweight title in 1951, beating Jake LaMotta in the sixth '
            "of their six fights on Saint Valentine's Day. He would win the "
            'middleweight championship five separate times.',
      ),
      StorySection(
        heading: 'The night the heat won',
        body:
            'In June 1952 Robinson moved up to challenge Joey Maxim for the '
            'light heavyweight title in New York in temperatures above '
            'forty degrees. He was far ahead on the cards when the heat '
            'beat him: the referee had already been replaced, and Robinson '
            'could not come out for the fourteenth round. It was the only '
            'stoppage loss of his career.',
      ),
      StorySection(
        heading: 'Rhythm',
        body:
            'Robinson danced professionally during a two-year retirement '
            'and said every move in the ring starts with the heart, in '
            'rhythm. Writers invented the pound-for-pound ranking to '
            'explain that the best fighter alive was not a heavyweight. He '
            'died in 1989.',
      ),
    ],
    quoteIndexes: [7, 53],
    takeaways: [
      'Style is rhythm. Train to a beat and the punches arrange '
          'themselves.',
      'Even the best have limits; know the conditions you can and '
          'cannot fight in.',
      'Longevity comes from craft. Robinson won titles across two '
          'decades.',
    ],
    imageAsset: 'assets/legends/robinson.jpg',
    credit: PhotoCredit(
      author: 'Unknown',
      license: 'Public domain',
      source:
          'https://commons.wikimedia.org/wiki/File:Sugar_Ray_Robinson_1950.jpg',
    ),
    gallery: [
      GalleryPhoto(
        asset: 'assets/legends/gallery/robinson_1.jpg',
        caption:
            'Blocking Jake LaMotta in their sixth fight, Chicago, 14 February '
            '1951.',
        credit: PhotoCredit(
          author: 'Unknown',
          license: 'Public domain',
          source:
              'https://commons.wikimedia.org/wiki/File:Sugar_Ray_Robinson_vs_Jake_LaMotta_1951_(1).jpg',
        ),
      ),
      GalleryPhoto(
        asset: 'assets/legends/gallery/robinson_2.jpg',
        caption: 'The referee raises his hand: middleweight champion, 1951.',
        credit: PhotoCredit(
          author: 'Unknown',
          license: 'Public domain',
          source:
              'https://commons.wikimedia.org/wiki/File:Sugar_Ray_Robinson_vs_Jake_LaMotta_1951_(2).jpg',
        ),
      ),
      GalleryPhoto(
        asset: 'assets/legends/gallery/robinson_3.jpg',
        caption: 'With Kid Gavilan, 1949.',
        credit: PhotoCredit(
          author: 'Unknown',
          license: 'Public domain',
          source:
              'https://commons.wikimedia.org/wiki/File:Kid_Gavilán_and_Sugar_Ray_Robinson_1949.jpg',
        ),
      ),
    ],
  ),
  Legend(
    id: 'louis',
    name: 'Joe Louis',
    nickname: 'The Brown Bomber',
    years: '1914 to 1981',
    country: 'United States',
    division: 'Heavyweight',
    record: '66 wins, 3 losses',
    hook:
        'Twelve years as champion, twenty-five defences, and one fight '
        'that carried a country.',
    sections: [
      StorySection(
        heading: 'Alabama to Detroit',
        body:
            'Joseph Louis Barrow was born to sharecroppers in Alabama and '
            'grew up in Detroit, where he spent violin lesson money on a '
            'locker at a boxing gym. He turned professional in 1934 and '
            'went unbeaten for three years until Max Schmeling, a German '
            'veteran, studied his habits and knocked him out in twelve '
            'rounds in June 1936.',
      ),
      StorySection(
        heading: 'One hundred and twenty-four seconds',
        body:
            'Louis won the title from James Braddock in 1937 but said he '
            'would not call himself champion until he beat Schmeling. The '
            'rematch on 22 June 1938 at Yankee Stadium was framed as '
            'democracy against Nazi Germany. Louis knocked Schmeling out in '
            'two minutes and four seconds of the first round.',
      ),
      StorySection(
        heading: 'The long reign',
        body:
            'Louis held the heavyweight title for almost twelve years and '
            'defended it twenty-five times, records that still stand. '
            'During the Second World War he enlisted, fought exhibitions '
            'for troops and donated purses to the Army and Navy relief '
            'funds. He fought on too long to pay tax debts and lost to '
            'Rocky Marciano in 1951.',
      ),
      StorySection(
        heading: 'Calm',
        body:
            'Louis said little in the ring or out of it. He is remembered '
            'for one line about an opponent who planned to keep moving: he '
            "can run, but he can't hide. He died in 1981 and was buried at "
            'Arlington National Cemetery.',
      ),
    ],
    quoteIndexes: [50, 51, 52],
    takeaways: [
      'Study your losses. Louis lost to Schmeling once because '
          'Schmeling had studied him.',
      'Preparation makes you calm. Calm makes you accurate.',
      'Money earned in the ring needs the same discipline as the '
          'ring.',
    ],
    imageAsset: 'assets/legends/louis.jpg',
    credit: PhotoCredit(
      author: 'Carl Van Vechten',
      license: 'Public domain',
      source:
          'https://commons.wikimedia.org/wiki/File:Joe_Louis_by_van_Vechten.jpg',
    ),
    gallery: [
      GalleryPhoto(
        asset: 'assets/legends/gallery/louis_1.jpg',
        caption: 'The rematch: Schmeling down at Yankee Stadium, 22 June 1938.',
        credit: PhotoCredit(
          author: 'Associated Press',
          license: 'Public domain',
          source:
              'https://commons.wikimedia.org/wiki/File:Joe_Louis_knocks_out_Max_Schmeling.jpg',
        ),
      ),
      GalleryPhoto(
        asset: 'assets/legends/gallery/louis_2.jpg',
        caption: 'Standing over Schmeling, 1938.',
        credit: PhotoCredit(
          author: 'Associated Press',
          license: 'Public domain',
          source:
              'https://commons.wikimedia.org/wiki/File:Joe_Louis_standing_over_Max_Schmeling_1938.jpg',
        ),
      ),
      GalleryPhoto(
        asset: 'assets/legends/gallery/louis_3.jpg',
        caption: 'Harlem celebrates the night of the rematch, June 1938.',
        credit: PhotoCredit(
          author: 'Unknown',
          license: 'Public domain',
          source:
              'https://commons.wikimedia.org/wiki/File:Celebrations_in_Harlem_after_Joe_Louis_knocked_out_Max_Schmeling_(5).jpg',
        ),
      ),
    ],
  ),
  Legend(
    id: 'johnson',
    name: 'Jack Johnson',
    nickname: 'The Galveston Giant',
    years: '1878 to 1946',
    country: 'United States',
    division: 'Heavyweight',
    record: 'Champion 1908 to 1915',
    hook:
        'The first Black heavyweight champion, decades ahead of the '
        'sport and of his country.',
    sections: [
      StorySection(
        heading: 'Galveston',
        body:
            'Jack Johnson was born in Galveston, Texas, to parents who had '
            'been enslaved. He learned to fight on the docks and developed '
            'a style built on defence, counterpunching and patience, at a '
            'time when heavyweights mostly stood and traded. For years the '
            'white champions refused to fight him.',
      ),
      StorySection(
        heading: 'Sydney, 1908',
        body:
            'Johnson followed the champion Tommy Burns across the world '
            'until Burns agreed to fight in Sydney on 26 December 1908. '
            'Johnson dominated for fourteen rounds until police stopped it. '
            'He was heavyweight champion of the world, and much of the '
            'American press began searching for a white challenger to take '
            'it back.',
      ),
      StorySection(
        heading: 'The Fight of the Century',
        body:
            'The former champion James Jeffries came out of retirement to '
            'face Johnson in Reno on 4 July 1910. Johnson beat him easily. '
            'Riots followed in cities across the country. Johnson lived as '
            'he pleased, drove fast cars and married white women, and in '
            '1913 was convicted under a law used to punish exactly that. He '
            'fled abroad and lost the title in Havana in 1915.',
      ),
      StorySection(
        heading: 'The long arc',
        body:
            'Johnson died in a car crash in 1946. His defensive style is '
            'now the foundation of modern boxing, and in 2018 he received a '
            'posthumous presidential pardon. He had fought the sport and '
            'the century at the same time.',
      ),
    ],
    quoteIndexes: [82],
    takeaways: [
      'Defence is not passive. Johnson won by making opponents miss '
          'and pay.',
      'Patience gets the fight. Johnson chased his title across '
          'three continents.',
      'Doing the right thing can still cost everything. History '
          'catches up slowly.',
    ],
    imageAsset: 'assets/legends/johnson.jpg',
    credit: PhotoCredit(
      author: 'George Grantham Bain Collection, Library of Congress',
      license: 'Public domain',
      source:
          'https://commons.wikimedia.org/wiki/File:Jack_Johnson,_1915_(edit).jpg',
    ),
    gallery: [
      GalleryPhoto(
        asset: 'assets/legends/gallery/johnson_1.jpg',
        caption:
            'The Fight of the Century against James Jeffries, Reno, 4 July '
            '1910.',
        credit: PhotoCredit(
          author: 'Unknown',
          license: 'Public domain',
          source:
              'https://commons.wikimedia.org/wiki/File:Johnson-Jeffries_Prize_Fight,_4_July_1910.jpg',
        ),
      ),
      GalleryPhoto(
        asset: 'assets/legends/gallery/johnson_2.jpg',
        caption: 'The fight poster, 1910.',
        credit: PhotoCredit(
          author: 'Unknown',
          license: 'Public domain',
          source:
              'https://commons.wikimedia.org/wiki/File:Jack_Johnson_vs_Jim_Jeffries_-_4_July_1910_World_Heavyweight_Boxing_poster.jpg',
        ),
      ),
      GalleryPhoto(
        asset: 'assets/legends/gallery/johnson_3.jpg',
        caption:
            'Crowds outside Times Tower in New York waiting for news of the '
            'fight.',
        credit: PhotoCredit(
          author: 'The Pictorial News Company',
          license: 'Public domain',
          source:
              'https://commons.wikimedia.org/wiki/File:Crowd_awaits_news_of_Jeffries_-_Johnson.JPG',
        ),
      ),
    ],
    photoFocus: Alignment(0, -0.7),
  ),
  Legend(
    id: 'pacquiao',
    name: 'Manny Pacquiao',
    nickname: 'Pac-Man',
    years: 'born 1978',
    country: 'Philippines',
    division: 'Flyweight to Super Welterweight',
    record: 'Titles in eight divisions',
    hook:
        'From selling bread in General Santos City to world titles in '
        'eight weight classes.',
    sections: [
      StorySection(
        heading: 'One hundred and six pounds',
        body:
            'Manny Pacquiao grew up poor in the southern Philippines, left '
            'home as a teenager and sold bread and doughnuts to eat. He '
            'turned professional at sixteen weighing one hundred and six '
            'pounds, sometimes putting weights in his pockets to make the '
            'minimum. He won his first world title, at flyweight, in 1998.',
      ),
      StorySection(
        heading: 'The speed',
        body:
            'Pacquiao fought with a left hand that arrived before opponents '
            'saw it and a rhythm that never let them settle. In 2003 he '
            'stopped the Mexican great Marco Antonio Barrera. In 2008 he '
            'beat Oscar De La Hoya so thoroughly that De La Hoya retired. '
            'In 2009 he stopped Miguel Cotto to win the welterweight title, '
            'seven divisions above where he started.',
      ),
      StorySection(
        heading: 'A nation stops',
        body:
            'During his fights the Philippines came to a standstill; police '
            'reported that crime fell to nothing for the hours he was in '
            'the ring. He lost the richest fight in history to Floyd '
            'Mayweather in 2015, was elected to the Senate in 2016, and in '
            '2019, at forty, beat the unbeaten Keith Thurman for a '
            'welterweight title.',
      ),
      StorySection(
        heading: 'Work',
        body:
            'Pacquiao says boxing is not about feelings but about '
            'performance, and his training camps, long runs at dawn and '
            'rounds of sparring into his forties, were the performance '
            'before the performance.',
      ),
    ],
    quoteIndexes: [56],
    takeaways: [
      'Start where you are, however small. A flyweight became a '
          'welterweight champion.',
      'Speed and volume beat size when the conditioning is there.',
      "Carrying other people's hopes can be fuel instead of weight.",
    ],
    imageAsset: 'assets/legends/pacquiao.jpg',
    credit: PhotoCredit(
      author: 'Robert Oswald P. Alfiler, Philippine News Agency',
      license: 'Public domain',
      source:
          'https://commons.wikimedia.org/wiki/File:Former_senator_Manny_Pacquiao_speaks_in_event_(10-01-2025)_(cropped).jpg',
    ),
    gallery: [
      GalleryPhoto(
        asset: 'assets/legends/gallery/pacquiao_1.jpg',
        caption: 'In the ring, 2008.',
        credit: PhotoCredit(
          author: 'Shubert Ciencia from Nueva Ecija, Philippines',
          license: 'CC BY 2.0',
          source:
              'https://commons.wikimedia.org/wiki/File:I_Am_Manny_Pacquiao_(2409886528).jpg',
        ),
      ),
      GalleryPhoto(
        asset: 'assets/legends/gallery/pacquiao_2.jpg',
        caption: 'The ring before Pacquiao vs Hatton, Las Vegas, 2009.',
        credit: PhotoCredit(
          author: 'Jamie Davies',
          license: 'CC BY 2.0',
          source:
              'https://commons.wikimedia.org/wiki/File:MGM_Pacquiao_vs._Hatton_pre-fight_ring.jpg',
        ),
      ),
      GalleryPhoto(
        asset: 'assets/legends/gallery/pacquiao_3.jpg',
        caption: 'MGM Grand Garden Arena before Pacquiao vs Thurman, 2019.',
        credit: PhotoCredit(
          author: 'Toohool',
          license: 'CC BY-SA 4.0',
          source:
              'https://commons.wikimedia.org/wiki/File:Pacquiao_vs._Thurman_arena.jpg',
        ),
      ),
    ],
  ),
  Legend(
    id: 'mayweather',
    name: 'Floyd Mayweather Jr.',
    nickname: 'Money',
    years: 'born 1977',
    country: 'United States',
    division: 'Super Featherweight to Super Welterweight',
    record: '50 wins, 0 losses',
    hook:
        'Fifty fights, no defeats, and a defence so good opponents '
        'stopped trying.',
    sections: [
      StorySection(
        heading: 'A boxing family',
        body:
            'Floyd Mayweather Jr. was born in Grand Rapids, Michigan, into '
            'a family of boxers. His father, Floyd Sr., was a welterweight '
            'contender who went to prison when Floyd was a teenager, and '
            'his uncle Roger, a two-division world champion, took over his '
            'training. He won a bronze medal at the 1996 Olympics in a '
            'decision so contested that officials later apologised.',
      ),
      StorySection(
        heading: 'The shoulder roll',
        body:
            "Mayweather's defence was the old Michigan style, the lead "
            'shoulder raised to catch punches, the head rolling away, the '
            'counter arriving before the opponent had reset. He won his '
            'first world title at super featherweight in 1998 and moved up '
            'through five divisions without a loss.',
      ),
      StorySection(
        heading: 'The business',
        body:
            'Mayweather promoted himself, negotiated his own purses and '
            'became the highest-paid athlete in the world. In May 2015 he '
            'beat Manny Pacquiao in the richest fight ever staged. His '
            'fiftieth win, over Conor McGregor in 2017, took his record one '
            "past Rocky Marciano's.",
      ),
      StorySection(
        heading: 'Behind the show',
        body:
            'The bravado hid a training regime that his rivals admitted was '
            'the hardest in the sport: midnight runs, marathon pad '
            'sessions, no missed days. He said a true champion can adapt to '
            'anything; the adapting was done in the gym.',
      ),
    ],
    quoteIndexes: [13, 57],
    takeaways: [
      'Not getting hit is a skill. Train defence as hard as '
          'offence.',
      'Own your career. Mayweather controlled his fights, his '
          'purses and his story.',
      'The show is the last part. The work is not optional.',
    ],
    imageAsset: 'assets/legends/mayweather.jpg',
    credit: PhotoCredit(
      author: 'Chamber of Fear',
      license: 'CC BY-SA 2.0',
      source:
          'https://commons.wikimedia.org/wiki/File:Floyd_Mayweather,_Jr._2011.jpg',
    ),
    gallery: [
      GalleryPhoto(
        asset: 'assets/legends/gallery/mayweather_1.jpg',
        caption: 'At a press conference, 2011.',
        credit: PhotoCredit(
          author: 'Chamber of Fear',
          license: 'CC BY-SA 2.0',
          source:
              'https://commons.wikimedia.org/wiki/File:Floyd_Mayweather,_Jr._2011.jpg',
        ),
      ),
      GalleryPhoto(
        asset: 'assets/legends/gallery/mayweather_2.jpg',
        caption:
            'The MGM Grand billboard for Mayweather vs Pacquiao, May 2015.',
        credit: PhotoCredit(
          author: 'Jimmy Harris',
          license: 'CC BY 2.0',
          source:
              'https://commons.wikimedia.org/wiki/File:MGM_Mayweather_Pacquiao.jpg',
        ),
      ),
      GalleryPhoto(
        asset: 'assets/legends/gallery/mayweather_3.jpg',
        caption: 'Working the pads at a DeWalt event, 2011.',
        credit: PhotoCredit(
          author: 'DEWALT POWER TOOLS FIGHT NIGHT CLUB 2010',
          license: 'CC BY-SA 2.0',
          source:
              'https://commons.wikimedia.org/wiki/File:Floyd_Mayweather,_Jr._at_DeWalt_event_(5888721735).jpg',
        ),
      ),
    ],
  ),
  Legend(
    id: 'kom',
    name: 'Mary Kom',
    nickname: 'Magnificent Mary',
    years: 'born 1982',
    country: 'India',
    division: 'Flyweight and Light Flyweight',
    record: 'Six world titles, Olympic bronze',
    hook:
        "A farmer's daughter from Manipur who hid her boxing from her "
        'parents and became the most decorated boxer in World '
        'Championship history.',
    sections: [
      StorySection(
        heading: 'Kangathei',
        body:
            'Mangte Chungneijang Mary Kom grew up in a village in Manipur, '
            'in the far north-east of India, helping her parents in the '
            'fields. In 1998 a boxer from her state, Dingko Singh, won '
            'Asian Games gold, and she went to a gym in Imphal to learn. '
            'She did not tell her parents. They found out when her '
            'photograph appeared in a newspaper after she won a state '
            'championship.',
      ),
      StorySection(
        heading: 'Six times',
        body:
            'Kom won her first World Championship in 2002 and her sixth in '
            '2018 in New Delhi, at thirty-five, more than any boxer, man or '
            "woman, in the tournament's history. In between she won gold at "
            'the 2014 Asian Games and a bronze medal at the 2012 London '
            "Olympics, the first Games to include women's boxing.",
      ),
      StorySection(
        heading: 'Twins',
        body:
            'In 2007 she gave birth to twin sons and stepped away. Many '
            'assumed she was finished. She returned the next year and won '
            'the 2008 World Championship. Later she was nominated to the '
            "upper house of India's parliament and kept training between "
            'sessions.',
      ),
      StorySection(
        heading: 'Weak',
        body:
            'Her most quoted line is a refusal: do not let anyone tell you '
            'that you are weak because you are a woman. She said it to '
            'girls in Manipur first.',
      ),
    ],
    quoteIndexes: [60],
    takeaways: [
      'Start before permission. Kom trained in secret until the '
          'results spoke.',
      'Coming back is a decision, not a feeling. She won a world '
          'title a year after having twins.',
      'Represent where you come from. Kom put Manipur on every '
          'podium she stood on.',
    ],
    imageAsset: 'assets/legends/kom.jpg',
    credit: PhotoCredit(
      author: 'British High Commission, India',
      license: 'OGL v1.0',
      source:
          'https://commons.wikimedia.org/wiki/File:Mary_Kom_-_British_High_Commission,_Delhi,_27_July_2011.jpg',
    ),
    gallery: [
      GalleryPhoto(
        asset: 'assets/legends/gallery/kom_1.jpg',
        caption:
            'Honoured by the Prime Minister after the London 2012 bronze, New '
            'Delhi.',
        credit: PhotoCredit(
          author: "Prime Minister's Office",
          license: 'GODL-India',
          source:
              'https://commons.wikimedia.org/wiki/File:Manmohan_Singh_honours_Smt._Mary_Kom,_the_London_Olympic_Bronze_Medal_winner,_at_the_All_India_Conference_of_Directors_GeneralInspectors_General_of_Police_-2012,_in_New_Delhi._The_Union_Home_Minister.jpg',
        ),
      ),
      GalleryPhoto(
        asset: 'assets/legends/gallery/kom_2.jpg',
        caption: 'With the President of India.',
        credit: PhotoCredit(
          author: "President's Secretariat",
          license: 'GODL-India',
          source:
              'https://commons.wikimedia.org/wiki/File:Mary_Kom_with_Pranab.jpg',
        ),
      ),
      GalleryPhoto(
        asset: 'assets/legends/gallery/kom_3.jpg',
        caption: 'With the London 2012 medal winners, New Delhi, August 2012.',
        credit: PhotoCredit(
          author: 'Ministry of Youth Affairs and Sports',
          license: 'GODL-India',
          source:
              'https://commons.wikimedia.org/wiki/File:Ajay_Maken_with_the_Medal_Winners_of_London_Olympics_2012,_at_the_felicitation_function,_organised_by_the_Ministry_of_Youth_Affairs_&_Sports,_at_Major_Dhyan_Chand_National_Stadium,_in_New_Delhi_on_August_16,_2012.jpg',
        ),
      ),
    ],
  ),
  Legend(
    id: 'taylor',
    name: 'Katie Taylor',
    nickname: 'KT',
    years: 'born 1986',
    country: 'Ireland',
    division: 'Lightweight',
    record: 'Undisputed lightweight champion',
    hook:
        "Five amateur world titles, Olympic gold, and the first women's "
        'fight to headline Madison Square Garden.',
    sections: [
      StorySection(
        heading: 'Bray',
        body:
            'Katie Taylor grew up in Bray, County Wicklow, boxing in a gym '
            "run by her father Pete. Girls' boxing was not sanctioned in "
            'Ireland, so as a child she sometimes fought with her hair '
            'hidden under her headguard. In 2001 she boxed in the first '
            "officially sanctioned women's bout in the country. She also "
            'played football for Ireland.',
      ),
      StorySection(
        heading: 'London 2012',
        body:
            'Taylor won five consecutive amateur World Championships '
            'between 2006 and 2014. At the 2012 London Olympics, the first '
            "Games with women's boxing, she won the lightweight gold medal "
            'in front of a crowd that the arena announcer asked to quieten '
            'more than once.',
      ),
      StorySection(
        heading: 'Rio and after',
        body:
            'In 2016 she lost early at the Rio Olympics after a difficult '
            'year that included a split with her father as trainer. Weeks '
            'later she turned professional. By June 2019 she was the '
            'undisputed lightweight champion, holding all four world '
            'titles.',
      ),
      StorySection(
        heading: 'The Garden',
        body:
            'On 30 April 2022 Taylor beat Amanda Serrano in the first '
            "women's fight to headline Madison Square Garden, a fight many "
            'called the best of the year in any division. She has rarely '
            'raised her voice in public; the record does it for her.',
      ),
    ],
    quoteIndexes: [83],
    takeaways: [
      'Do the work before the sport is ready for you. Taylor boxed '
          'before girls were allowed to.',
      'A bad year is not a verdict. Taylor turned professional '
          'weeks after Rio and became undisputed.',
      'Quiet is a style. Let the record talk.',
    ],
    imageAsset: 'assets/legends/taylor.jpg',
    credit: PhotoCredit(
      author: 'cormac70',
      license: 'CC BY 2.0',
      source:
          'https://commons.wikimedia.org/wiki/File:Katie_Taylor_2012_(2).jpg',
    ),
    gallery: [
      GalleryPhoto(
        asset: 'assets/legends/gallery/taylor_1.jpg',
        caption: 'Boxing at the London 2012 Olympics.',
        credit: PhotoCredit(
          author: 'cormac70',
          license: 'CC BY 2.0',
          source:
              'https://commons.wikimedia.org/wiki/File:2012_Summer_Olympics_Katie_Taylor_2.jpg',
        ),
      ),
      GalleryPhoto(
        asset: 'assets/legends/gallery/taylor_2.jpg',
        caption: 'The moment it was over, London 2012.',
        credit: PhotoCredit(
          author: 'cormac70',
          license: 'CC BY 2.0',
          source:
              "https://commons.wikimedia.org/wiki/File:Katie_Taylor_2012_Summer_Olympics_It's_All_Over.jpg",
        ),
      ),
      GalleryPhoto(
        asset: 'assets/legends/gallery/taylor_3.jpg',
        caption: 'Walking to the ring in London, 2012.',
        credit: PhotoCredit(
          author: 'cormac70',
          license: 'CC BY 2.0',
          source:
              'https://commons.wikimedia.org/wiki/File:Katie_Taylor_Enters_2012_Summer_Olympics.jpg',
        ),
      ),
    ],
    photoFocus: Alignment.center,
  ),
];

/// The legend with [id], or null when no legend has it.
Legend? findLegend(String id) {
  for (final legend in legends) {
    if (legend.id == id) return legend;
  }
  return null;
}

/// The legend featured for the week [day] falls in, cycling through the list.
Legend legendOfTheWeek(DateTime day) {
  final weekOfYear = (dayOfYear(day) - 1) ~/ 7;
  return legends[weekOfYear % legends.length];
}
