import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';

/// Languages the invitation is available in.
const supportedLocales = [Locale('en'), Locale('ar')];

/// A piece of text in every supported language.
///
/// Call it with a [BuildContext] to get the text for the current locale:
/// `S.gallery(context)`.
class Tr {
  final String en;
  final String ar;
  const Tr(this.en, this.ar);

  String call(BuildContext context) => isArabic(context) ? ar : en;
}

bool isArabic(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ar';

/// Holds the current app language. Starts from the device language.
class LocaleController extends ValueNotifier<Locale> {
  LocaleController() : super(_initial());

  static Locale _initial() =>
      PlatformDispatcher.instance.locale.languageCode == 'ar'
      ? const Locale('ar')
      : const Locale('en');

  bool get isArabic => value.languageCode == 'ar';

  void toggle() => value = isArabic ? const Locale('en') : const Locale('ar');
}

final appLocale = LocaleController();

/// UI strings. Invitation content (names, dates, venue) is in WeddingData.
class S {
  static const appTitle = Tr(
    'Michael & Martina — Engagement',
    'مايكل & مارتينا — حفل الخطوبة',
  );
  static const switchLanguage = Tr('عربي', 'English');
  static const changeLanguage = Tr('Change language', 'تغيير اللغة');

  // Envelope
  static const youAreInvited = Tr('You are invited', 'أنتم مدعوون');
  static const saveTheDate = Tr('SAVE THE DATE', 'احفظوا الموعد');
  static const tapSeal = Tr('Tap the seal to open', 'اضغط على الختم للفتح');

  // Hero
  static const leaveMessageButton = Tr('LEAVE A MESSAGE', 'اترك رسالة');
  static const scroll = Tr('SCROLL', 'مرّر للأسفل');

  // Countdown
  static const countingDays = Tr('Counting the days', 'نعدّ الأيام');
  static const days = Tr('DAYS', 'يوم');
  static const hours = Tr('HOURS', 'ساعة');
  static const mins = Tr('MINS', 'دقيقة');
  static const secs = Tr('SECS', 'ثانية');

  // Sections
  static const theDay = Tr('The Day', 'اليوم الموعود');
  static const gallery = Tr('Gallery', 'معرض الصور');
  static const location = Tr('Location', 'المكان');
  static const getDirections = Tr('Get directions', 'الاتجاهات');

  // Message form
  static const saySomethingSweet = Tr('Say something sweet', 'قل كلمة جميلة');
  static const leaveMessage = Tr('Leave a Message', 'اترك رسالة');
  static const shareWishes = Tr(
    'Share your wishes and love for the couple',
    'شاركونا أمنياتكم ومحبتكم للعروسين',
  );
  static const thankYou = Tr('Thank you', 'شكرًا لك');
  static String thankYouName(BuildContext context, String name) =>
      isArabic(context) ? 'شكرًا لك، $name' : 'Thank you, $name';
  static const messageMeansWorld = Tr(
    'Your message means the world to us.',
    'رسالتك تعني لنا الكثير.',
  );
  static const writeAnother = Tr('Write another', 'اكتب رسالة أخرى');
  static const yourNameOptional = Tr('Your name (optional)', 'اسمك (اختياري)');
  static const nameTooLong = Tr(
    'Please use 60 characters or fewer',
    'يرجى استخدام 60 حرفًا أو أقل',
  );
  static const yourMessage = Tr('Your message', 'رسالتك');
  static const pleaseWriteMessage = Tr(
    'Please write a message',
    'يرجى كتابة رسالة',
  );
  static const sending = Tr('Sending…', 'جارٍ الإرسال…');
  static const sendMessage = Tr('Send Message', 'إرسال الرسالة');
  static const sendFailed = Tr(
    'Sorry, your message could not be sent. Please try again.',
    'عذرًا، تعذّر إرسال رسالتك. يرجى المحاولة مرة أخرى.',
  );

  // Wishes
  static const fromOurGuests = Tr('From our guests', 'من ضيوفنا');
  static const wishes = Tr('Wishes', 'الأمنيات');
  static const aGuest = Tr('A GUEST', 'ضيف');
  static const noWishesYet = Tr('No wishes yet', 'لا توجد أمنيات بعد');
  static const beFirst = Tr(
    'Be the first to leave a message for the couple.',
    'كن أول من يترك رسالة للعروسين.',
  );
  static String quote(BuildContext context, String text) =>
      isArabic(context) ? '«$text»' : '“$text”';

  // Footer
  static const withAllMyLove = Tr('With all my love', 'مع كل الحب');

  // Music
  static const pauseMusic = Tr('Pause music', 'إيقاف الموسيقى');
  static const playMusic = Tr('Play music', 'تشغيل الموسيقى');
}
