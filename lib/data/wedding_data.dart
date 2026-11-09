import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

/// All invitation content lives here — edit this file to personalise the site.
/// Text shown to guests is given in English and Arabic: Tr('English', 'عربي').
class WeddingData {
  static const brideName = Tr('Martina', 'مارتينا');
  static const groomName = Tr('Michael', 'مايكل');
  static const monogram = 'M&M';

  static final weddingDate = DateTime(2027, 1, 28, 17, 0);
  static const dateLabel = Tr(
    'Thursday, 28 January 2027\n5:00 PM',
    'الخميس، 28 يناير 2027\n5:00 مساءً',
  );

  static const heroIntro = Tr('Together with their families', 'مع عائلتيهما');
  static const heroByline = Tr(
    'invite you to celebrate their engagement',
    'يتشرفان بدعوتكم لمشاركتهما فرحة الخطوبة',
  );

  /// "Michael & Martina" in the current language.
  static String couple(BuildContext context) =>
      '${groomName(context)} & ${brideName(context)}';

  // location
  static const locationName = Tr('Villa Le Colline', 'فيلا لي كولين');
  static const locationCity = Tr('El-Mahalla el-Kubra', 'المحلة الكبرى');
  static const locationCountry = Tr('Egypt', 'مصر');
  static const mapsQuery =
      'Maryland tourist village, Tanta - Al Mahallah Al Kubra Rd, Egypt';

  // schedule
  static const schedule = <ScheduleItem>[
    ScheduleItem(
      Tr('05:00 PM', '5:00 مساءً'),
      Tr('Thursday, 28 January 2027', 'الخميس، 28 يناير 2027'),
      Icons.local_bar_outlined,
    ),
  ];

  static const initialWishes = <Wish>[];
}

/// Optional media files — see assets/README.md.
class WeddingAssets {
  static const hero = 'assets/images/hero.jpg';
  static const footer = 'assets/images/footer.png';
  static const music = 'assets/audio/music.mp3';
}

class ScheduleItem {
  final Tr time;
  final Tr subtitle;
  final IconData icon;
  const ScheduleItem(this.time, this.subtitle, this.icon);
}

class Wish {
  final String name;
  final String message;
  const Wish(this.name, this.message);
}
