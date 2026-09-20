// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sinhala Sinhalese (`si`).
class AppLocalizationsSi extends AppLocalizations {
  AppLocalizationsSi([String locale = 'si']) : super(locale);

  @override
  String get appName => 'සපුමල් රඟහල';

  @override
  String get home => 'මුල් පිටුව';

  @override
  String get shows => 'නාට්‍ය';

  @override
  String get bookings => 'වෙන්කිරීම්';

  @override
  String get profile => 'ගිණුම';

  @override
  String get more => 'තවත්';

  @override
  String get bookTickets => 'ටිකට් වෙන්කරන්න';

  @override
  String get heroTitle => 'රංග කලාවේ අත්දැකීම විඳින්න';

  @override
  String get heroSubtitle => 'ඔබගේ ප්‍රියතම නාට්‍ය ඕනෑම වේලාවක වෙන්කරන්න.';

  @override
  String get upcoming => 'ඉදිරියට';

  @override
  String get all => 'සියල්ල';

  @override
  String get sinhala => 'සිංහල';

  @override
  String get tamil => 'දෙමළ';

  @override
  String get english => 'ඉංග්‍රීසි';

  @override
  String get thisWeek => 'මෙම සතිය';

  @override
  String fromPrice(String price) {
    return '$price සිට';
  }

  @override
  String get productionDetails => 'නාට්‍ය විස්තර';

  @override
  String get selectPerformance => 'දර්ශනයක් තෝරන්න';

  @override
  String get selectSeats => 'ආසන තෝරන්න';

  @override
  String get matinee => 'දිවා දර්ශනය';

  @override
  String get evening => 'සන්ධ්‍යා දර්ශනය';

  @override
  String get poyaDay => 'පෝය දිනය - වසා ඇත';

  @override
  String get earlyAccess => 'සාමාජිකයින්ට දින හතකට පෙර වෙන්කර ගත හැක.';

  @override
  String get loyaltyOnly => 'මෙම දර්ශනය දැනට සාමාජිකයින් සඳහා පමණි.';

  @override
  String get venue => 'සපුමල් රඟහල - කොළඹ 07';

  @override
  String get readMore => 'තවත් කියවන්න';

  @override
  String get seatSelection => 'ආසන තෝරන්න';

  @override
  String get stalls => 'පහළ ආසන';

  @override
  String get circle => 'මැද බැල්කනිය';

  @override
  String get upperCircle => 'ඉහළ බැල්කනිය';

  @override
  String get stage => 'වේදිකාව';

  @override
  String get available => 'ලබා ගත හැක';

  @override
  String get selected => 'තෝරා ඇත';

  @override
  String get booked => 'වෙන් කර ඇත';

  @override
  String get held => 'තාවකාලිකව රඳවා ඇත';

  @override
  String get unavailable => 'ලබා ගත නොහැක';

  @override
  String get accessibleSeat => 'ප්‍රවේශ පහසු ආසනය';

  @override
  String seatsSelected(int count) {
    return 'ආසන $count ක් තෝරා ඇත';
  }

  @override
  String get continueLabel => 'ඉදිරියට';

  @override
  String holdTime(String time) {
    return 'රඳවා තැබීම අවසන් වන්නේ $time කින්';
  }

  @override
  String get passengerDetails => 'මගී විස්තර';

  @override
  String get contactInfo => 'සම්බන්ධතා තොරතුරු';

  @override
  String get fullName => 'සම්පූර්ණ නම';

  @override
  String get email => 'විද්‍යුත් තැපෑල';

  @override
  String get phone => 'දුරකථන අංකය';

  @override
  String get concessionOptional => 'සහන (විකල්ප)';

  @override
  String get concessionType => 'සහන වර්ගය';

  @override
  String get none => 'නැත';

  @override
  String get under16 => 'වයස 16 ට අඩු';

  @override
  String get over70 => 'වයස 70 ට වැඩි';

  @override
  String get largeParty => 'විශාල කණ්ඩායම (11+)';

  @override
  String get identityNumber => 'හැඳුනුම්පත් / ගමන් බලපත්‍ර අංකය';

  @override
  String get verificationNotice =>
      'දර්ශන දිනයේදී සුදුසුකම ප්‍රවේශපත් කවුළුවේදී තහවුරු කෙරේ.';

  @override
  String get continueSummary => 'සාරාංශයට යන්න';

  @override
  String get bookingSummary => 'වෙන්කිරීමේ සාරාංශය';

  @override
  String get ticketTotal => 'ටිකට් එකතුව';

  @override
  String get discounts => 'වට්ටම්';

  @override
  String get loyaltyDiscount => 'සාමාජික වට්ටම (10%)';

  @override
  String vat(int rate) {
    return 'වැට් ($rate%)';
  }

  @override
  String get totalPayable => 'ගෙවිය යුතු එකතුව';

  @override
  String get termsConsent =>
      'මම නියමයන් පිළිගෙන පෞද්ගලිකත්ව දැන්වීම පිළිගනිමි.';

  @override
  String get proceedCheckout => 'ගෙවීමට යන්න';

  @override
  String get payment => 'ගෙවීම';

  @override
  String get amountToPay => 'ගෙවිය යුතු මුදල';

  @override
  String get cardPayment => 'කාඩ් ගෙවීම';

  @override
  String get mobilePayment => 'ජංගම ගෙවීම';

  @override
  String get internetBanking => 'අන්තර්ජාල බැංකුකරණය';

  @override
  String get mockPaymentNotice =>
      'මෙය ආදර්ශ ගෙවීමකි. සැබෑ කාඩ් තොරතුරු ඇතුළත් නොකරන්න.';

  @override
  String get payNow => 'දැන් ගෙවන්න';

  @override
  String get simulateFailure => 'අසාර්ථක ගෙවීමක් අත්හදා බලන්න';

  @override
  String get paymentFailed =>
      'ගෙවීම ප්‍රතික්ෂේප විය. ආසන තවත් මිනිත්තු පහක් රඳවා ඇත.';

  @override
  String get retry => 'නැවත උත්සාහ කරන්න';

  @override
  String get bookingConfirmed => 'වෙන්කිරීම තහවුරුයි!';

  @override
  String get confirmationMessage => 'ඔබගේ ටිකට් සාර්ථකව වෙන්කර ඇත.';

  @override
  String get bookingReference => 'වෙන්කිරීමේ යොමුව';

  @override
  String get viewBookings => 'මගේ වෙන්කිරීම් බලන්න';

  @override
  String get backHome => 'මුල් පිටුවට';

  @override
  String get upcomingTab => 'ඉදිරියට';

  @override
  String get pastTab => 'පසුගිය';

  @override
  String get noBookings => 'වෙන්කිරීම් නොමැත';

  @override
  String get lookupBooking => 'වෙන්කිරීමක් සොයන්න';

  @override
  String get reference => 'වෙන්කිරීමේ යොමුව';

  @override
  String get search => 'සොයන්න';

  @override
  String get notFound => 'ගැළපෙන වෙන්කිරීමක් හමු නොවීය.';

  @override
  String get myProfile => 'මගේ ගිණුම';

  @override
  String get loyaltyCard => 'සාමාජික කාඩ්පත';

  @override
  String get loyaltyMember => 'සාමාජික';

  @override
  String get paymentMethods => 'ගෙවීම් ක්‍රම';

  @override
  String get helpSupport => 'උදව් සහ සහාය';

  @override
  String get settings => 'සැකසුම්';

  @override
  String get aboutUs => 'අප ගැන';

  @override
  String get logout => 'ඉවත් වන්න';

  @override
  String get login => 'පිවිසෙන්න';

  @override
  String get register => 'ගිණුමක් සාදන්න';

  @override
  String get createAccount => 'ගිණුම සාදන්න';

  @override
  String get invalidCredentials =>
      'වලංගු විද්‍යුත් තැපෑලක් සහ ඉහළ/පහළ අකුරු, අංක හා විශේෂ ලකුණක් සහිත අක්ෂර 12කට වැඩි මුරපදයක් භාවිත කරන්න.';

  @override
  String get accountLocked =>
      'අසාර්ථක උත්සාහ පහකට පසු මෙම ආදර්ශ ගිණුම අගුළු දමා ඇත.';

  @override
  String get loyaltyLinked => 'ආදර්ශ සාමාජිකත්වය සම්බන්ධ කරන ලදී.';

  @override
  String get password => 'මුරපදය';

  @override
  String get signIn => 'පිවිසෙන්න';

  @override
  String get demoCredentials =>
      'ආදර්ශයේ වලංගු විද්‍යුත් තැපෑලක් සහ අක්ෂර 12ක මුරපදයක් භාවිත කරන්න.';

  @override
  String get themeMode => 'දීප්තිය';

  @override
  String get colourPalette => 'වර්ණ තේමාව';

  @override
  String get burgundy => 'බර්ගන්ඩි';

  @override
  String get midnight => 'මධ්‍යම රාත්‍රී';

  @override
  String get emerald => 'මරකත';

  @override
  String get light => 'ආලෝක';

  @override
  String get dark => 'අඳුරු';

  @override
  String get language => 'භාෂාව';

  @override
  String get privacyPolicy => 'පෞද්ගලිකත්ව ප්‍රතිපත්තිය';

  @override
  String get terms => 'නියමයන් සහ කොන්දේසි';

  @override
  String get manageData => 'මගේ දත්ත කළමනාකරණය';

  @override
  String get loading => 'පූරණය වෙමින්...';

  @override
  String get error => 'යම් දෝෂයක් ඇති විය.';

  @override
  String get noProductions => 'ඉදිරි නාට්‍ය නොමැත.';

  @override
  String get favourite => 'ප්‍රියතම';

  @override
  String get bookNow => 'දැන් වෙන්කරන්න';

  @override
  String get mockConfigNote =>
      'වැට් සහ සහන අගයන් පසු සේවා තහවුරු කිරීම බලාපොරොත්තු වන ආදර්ශ අගයන් වේ.';

  @override
  String get flagged => 'මෙම වෙන්කිරීම කවුළුවේ තහවුරු කිරීම සඳහා සලකුණු කර ඇත.';

  @override
  String get requiredField => 'මෙම ක්ෂේත්‍රය අවශ්‍යයි.';

  @override
  String get invalidEmail => 'වලංගු විද්‍යුත් තැපෑලක් ඇතුළත් කරන්න.';

  @override
  String get invalidIdentity =>
      'වලංගු හැඳුනුම්පත් හෝ ගමන් බලපත්‍ර අංකයක් ඇතුළත් කරන්න.';

  @override
  String get seatHoldExpired => 'ආසන රඳවා තැබීම අවසන් විය. නැවත ආසන තෝරන්න.';

  @override
  String get prototypeContent => 'අනුමත අන්තර්ගතය ලැබෙන තුරු ආදර්ශ පාඨයකි';

  @override
  String get invalidLargeParty =>
      'විශාල කණ්ඩායම් සහනය සඳහා අවම වශයෙන් ආසන 11ක් අවශ්‍යයි.';
}
