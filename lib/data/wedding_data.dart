import 'package:flutter/material.dart';

/// All invitation content lives here — edit this file to personalise the site.
class WeddingData {
  static const brideName = 'Martina';
  static const groomName = 'Michael';
  static const monogram = 'M&M';

  static final weddingDate = DateTime(2027, 1, 28, 17, 0);
  static const dateLabel = 'Thursday, 28 January 2027\n5:00 PM';

  static const heroIntro = 'Together with their families';
  static const heroByline = 'invite you to celebrate their wedding';

  static const welcomeTitle = 'Benvenuti';
  static const story =
      'We met on a late summer evening in Florence, sharing a table at a crowded '
      'trattoria. Years of long walks, slow dinners and countless sunsets later, '
      'we are returning to the hills of Tuscany to say "sì" — and we would love '
      'nothing more than to have you there beside us.';

  // location
  static const locationName = 'Villa Le Colline';
  static const locationCity = 'El-Mahalla el-Kubra';
  static const locationCountry = 'Egypt';
  static const mapsQuery =
      'Maryland tourist village, Tanta - Al Mahallah Al Kubra Rd, Egypt';

  // schedule
  static const schedule = <ScheduleItem>[
    ScheduleItem('05:00 PM', 'Thursday, 28 January 2027', Icons.local_bar_outlined),
  ];

  static const initialWishes = <Wish>[
    Wish('Elena', 'Wishing you a lifetime of sunsets as golden as Tuscany. Cin cin!'),
    Wish('Luca', 'Can\'t wait to dance under the pergola with you both.'),
  ];
}

/// Optional media files — see assets/README.md.
class WeddingAssets {
  static const hero = 'assets/images/hero.jpg';
  static const footer = 'assets/images/footer.png';
  static const music = 'assets/audio/music.mp3';
}

class ScheduleItem {
  final String time;
  final String subtitle;
  final IconData icon;
  const ScheduleItem(this.time, this.subtitle, this.icon);
}

class Wish {
  final String name;
  final String message;
  const Wish(this.name, this.message);
}
