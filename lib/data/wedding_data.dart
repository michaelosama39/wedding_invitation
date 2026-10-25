import 'package:flutter/material.dart';

/// All invitation content lives here — edit this file to personalise the site.
class WeddingData {
  static const brideName = 'Martina';
  static const groomName = 'Michael';
  static const monogram = 'M&M';

  static final weddingDate = DateTime(2027, 1, 28, 17, 0);
  static const dateLabel = 'Thursday, 28 January 2027';
  static const rsvpDeadline = '1 January 2027';

  static const heroIntro = 'Together with their families';
  static const heroByline = 'invite you to celebrate their wedding';

  static const welcomeTitle = 'Benvenuti';
  static const story =
      'We met on a late summer evening in Florence, sharing a table at a crowded '
      'trattoria. Years of long walks, slow dinners and countless sunsets later, '
      'we are returning to the hills of Tuscany to say "sì" — and we would love '
      'nothing more than to have you there beside us.';

  // location
  static const venueName = 'Villa Le Colline';
  static const venueCity = 'El-Mahalla el-Kubra';
  static const venueCountry = 'Egypt';
  static const mapsQuery = 'Villa Le Colline, El-Mahalla el-Kubra, Egypt';

  // schedule
  static const schedule = <ScheduleItem>[
    ScheduleItem('05:00 PM', 'Thursday, 28 January 2027', Icons.local_bar_outlined),
  ];

  // static const dressCodeSubheading = 'What to wear';
  // static const dressCodeHeading = 'Dress Code';
  // static const dressCodeText = 'Summer formal — light linens, soft earth tones and comfortable shoes for the garden.';
  // static const dressCodeNote = 'We kindly ask that you avoid wearing white.';

  // static const giftsSubheading = 'Registry';
  // static const giftsHeading = 'Gifts';
  // static const giftsText =
  //     'Your presence is the greatest gift. Should you wish to honour us further, '
  //     'a contribution to our honeymoon would be warmly appreciated.';
  // static const bankDetails = 'IBAN  IT00 X000 0000 0000 0000 0000 000';

  // Gallery photos are loaded automatically from assets/images/gallery*.jpg|png.

  static const initialWishes = <Wish>[
    Wish('Elena', 'Wishing you a lifetime of sunsets as golden as Tuscany. Cin cin!'),
    Wish('Luca', 'Can\'t wait to dance under the pergola with you both.'),
  ];
}

/// Optional media files — see assets/README.md.
class WeddingAssets {
  static const hero = 'assets/images/hero.jpg';
  static const story = 'assets/images/story.png';
  static const venue = 'assets/images/venue.png';
  static const dressCode = 'assets/images/dresscode.png';
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
