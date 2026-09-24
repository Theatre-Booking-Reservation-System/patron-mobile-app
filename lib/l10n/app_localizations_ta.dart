// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => 'சபுமல் அரங்கம்';

  @override
  String get home => 'முகப்பு';

  @override
  String get shows => 'நிகழ்ச்சிகள்';

  @override
  String get bookings => 'முன்பதிவுகள்';

  @override
  String get profile => 'சுயவிவரம்';

  @override
  String get more => 'மேலும்';

  @override
  String get bookTickets => 'டிக்கெட் முன்பதிவு';

  @override
  String get heroTitle => 'கலையின் அனுபவத்தை உணருங்கள்';

  @override
  String get heroSubtitle =>
      'உங்கள் விருப்பமான நிகழ்ச்சிகளை எப்போது வேண்டுமானாலும் முன்பதிவு செய்யுங்கள்.';

  @override
  String get upcoming => 'வரவிருக்கும்';

  @override
  String get all => 'அனைத்தும்';

  @override
  String get sinhala => 'சிங்களம்';

  @override
  String get tamil => 'தமிழ்';

  @override
  String get english => 'ஆங்கிலம்';

  @override
  String get thisWeek => 'இந்த வாரம்';

  @override
  String fromPrice(String price) {
    return '$price முதல்';
  }

  @override
  String get productionDetails => 'நிகழ்ச்சி விவரங்கள்';

  @override
  String get selectPerformance => 'காட்சியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get selectSeats => 'இருக்கைகளைத் தேர்ந்தெடுக்கவும்';

  @override
  String get matinee => 'பகல் காட்சி';

  @override
  String get evening => 'மாலை காட்சி';

  @override
  String get poyaDay => 'போயா நாள் - மூடப்பட்டுள்ளது';

  @override
  String get earlyAccess =>
      'உறுப்பினர்கள் ஏழு நாட்களுக்கு முன் முன்பதிவு செய்யலாம்.';

  @override
  String get loyaltyOnly =>
      'இந்த காட்சி தற்போது உறுப்பினர்களுக்கு மட்டும் கிடைக்கும்.';

  @override
  String get venue => 'சபுமல் அரங்கம் - கொழும்பு 07';

  @override
  String get readMore => 'மேலும் வாசிக்க';

  @override
  String get seatSelection => 'இருக்கைகளைத் தேர்ந்தெடுக்கவும்';

  @override
  String get stalls => 'கீழ் இருக்கைகள்';

  @override
  String get circle => 'நடுப் பால்கனி';

  @override
  String get upperCircle => 'மேல் பால்கனி';

  @override
  String get stage => 'மேடை';

  @override
  String get available => 'கிடைக்கிறது';

  @override
  String get selected => 'தேர்ந்தெடுக்கப்பட்டது';

  @override
  String get booked => 'முன்பதிவு செய்யப்பட்டது';

  @override
  String get held => 'தற்காலிகமாக ஒதுக்கப்பட்டது';

  @override
  String get unavailable => 'கிடைக்கவில்லை';

  @override
  String get accessibleSeat => 'அணுகக்கூடிய இருக்கை';

  @override
  String seatsSelected(int count) {
    return '$count இருக்கைகள் தேர்வு';
  }

  @override
  String get continueLabel => 'தொடரவும்';

  @override
  String holdTime(String time) {
    return 'ஒதுக்கீடு $time இல் முடியும்';
  }

  @override
  String get passengerDetails => 'பயணி விவரங்கள்';

  @override
  String get contactInfo => 'தொடர்பு தகவல்';

  @override
  String get fullName => 'முழுப் பெயர்';

  @override
  String get email => 'மின்னஞ்சல்';

  @override
  String get phone => 'தொலைபேசி எண்';

  @override
  String get concessionOptional => 'சலுகை (விருப்பம்)';

  @override
  String get concessionType => 'சலுகை வகை';

  @override
  String get none => 'இல்லை';

  @override
  String get under16 => '16 வயதுக்குக் கீழ்';

  @override
  String get over70 => '70 வயதுக்கு மேல்';

  @override
  String get largeParty => 'பெரிய குழு (11+)';

  @override
  String get identityNumber => 'NIC / கடவுச்சீட்டு எண்';

  @override
  String get verificationNotice =>
      'நிகழ்ச்சி நாளில் தகுதி டிக்கெட் கவுன்டரில் சரிபார்க்கப்படும்.';

  @override
  String get continueSummary => 'சுருக்கத்திற்குச் செல்லவும்';

  @override
  String get bookingSummary => 'முன்பதிவு சுருக்கம்';

  @override
  String get ticketTotal => 'டிக்கெட் மொத்தம்';

  @override
  String get discounts => 'தள்ளுபடிகள்';

  @override
  String get loyaltyDiscount => 'உறுப்பினர் தள்ளுபடி (10%)';

  @override
  String vat(int rate) {
    return 'VAT ($rate%)';
  }

  @override
  String get totalPayable => 'செலுத்த வேண்டிய மொத்தம்';

  @override
  String get termsConsent =>
      'விதிமுறைகளை ஏற்று தனியுரிமை அறிவிப்பை ஒப்புக்கொள்கிறேன்.';

  @override
  String get proceedCheckout => 'கட்டணத்திற்குச் செல்லவும்';

  @override
  String get payment => 'கட்டணம்';

  @override
  String get amountToPay => 'செலுத்த வேண்டிய தொகை';

  @override
  String get cardPayment => 'அட்டை கட்டணம்';

  @override
  String get mobilePayment => 'மொபைல் கட்டணம்';

  @override
  String get internetBanking => 'இணைய வங்கி';

  @override
  String get mockPaymentNotice =>
      'இது மாதிரி கட்டணம். உண்மையான அட்டை விவரங்களை உள்ளிட வேண்டாம்.';

  @override
  String get payNow => 'இப்போது செலுத்தவும்';

  @override
  String get simulateFailure => 'தோல்வியடைந்த கட்டணத்தைச் சோதிக்கவும்';

  @override
  String get paymentFailed =>
      'கட்டணம் மறுக்கப்பட்டது. இருக்கைகள் மேலும் ஐந்து நிமிடங்கள் ஒதுக்கப்படும்.';

  @override
  String get retry => 'மீண்டும் முயற்சி';

  @override
  String get bookingConfirmed => 'முன்பதிவு உறுதி!';

  @override
  String get confirmationMessage =>
      'உங்கள் டிக்கெட்டுகள் வெற்றிகரமாக முன்பதிவு செய்யப்பட்டன.';

  @override
  String get bookingReference => 'முன்பதிவு குறிப்பு';

  @override
  String get viewBookings => 'என் முன்பதிவுகள்';

  @override
  String get backHome => 'முகப்புக்குத் திரும்பவும்';

  @override
  String get upcomingTab => 'வரவிருக்கும்';

  @override
  String get pastTab => 'கடந்தவை';

  @override
  String get noBookings => 'முன்பதிவுகள் இல்லை';

  @override
  String get lookupBooking => 'முன்பதிவைத் தேடவும்';

  @override
  String get reference => 'முன்பதிவு குறிப்பு';

  @override
  String get search => 'தேடவும்';

  @override
  String get notFound => 'பொருந்தும் முன்பதிவு கிடைக்கவில்லை.';

  @override
  String get myProfile => 'என் சுயவிவரம்';

  @override
  String get loyaltyCard => 'உறுப்பினர் அட்டை';

  @override
  String get theme => 'தீம்';

  @override
  String get loyaltyMember => 'உறுப்பினர்';

  @override
  String get paymentMethods => 'கட்டண முறைகள்';

  @override
  String get helpSupport => 'உதவி மற்றும் ஆதரவு';

  @override
  String get settings => 'அமைப்புகள்';

  @override
  String get aboutUs => 'எங்களைப் பற்றி';

  @override
  String get logout => 'வெளியேறு';

  @override
  String get login => 'உள்நுழைவு';

  @override
  String get register => 'கணக்கை உருவாக்கவும்';

  @override
  String get createAccount => 'கணக்கு உருவாக்கு';

  @override
  String get invalidCredentials =>
      'செல்லுபடியாகும் மின்னஞ்சல் மற்றும் பெரிய/சிறிய எழுத்து, எண், சிறப்பு குறியீடு கொண்ட 12+ எழுத்து கடவுச்சொல்லைப் பயன்படுத்தவும்.';

  @override
  String get accountLocked =>
      'ஐந்து தோல்விகளுக்குப் பிறகு இந்த மாதிரி கணக்கு பூட்டப்பட்டுள்ளது.';

  @override
  String get loyaltyLinked => 'மாதிரி உறுப்பினர் அட்டை இணைக்கப்பட்டது.';

  @override
  String get password => 'கடவுச்சொல்';

  @override
  String get signIn => 'உள்நுழையவும்';

  @override
  String get demoCredentials =>
      'மாதிரி நிலையில் செல்லுபடியாகும் மின்னஞ்சல் மற்றும் 12 எழுத்து கடவுச்சொல்லைப் பயன்படுத்தவும்.';

  @override
  String get themeMode => 'ஒளிர்வு';

  @override
  String get colourPalette => 'நிறத் தீம்';

  @override
  String get burgundy => 'பர்கண்டி';

  @override
  String get midnight => 'நள்ளிரவு';

  @override
  String get emerald => 'மரகதம்';

  @override
  String get light => 'ஒளி';

  @override
  String get dark => 'இருள்';

  @override
  String get language => 'மொழி';

  @override
  String get privacyPolicy => 'தனியுரிமைக் கொள்கை';

  @override
  String get terms => 'விதிமுறைகள்';

  @override
  String get manageData => 'என் தரவை நிர்வகிக்கவும்';

  @override
  String get loading => 'ஏற்றுகிறது...';

  @override
  String get error => 'ஏதோ தவறு ஏற்பட்டது.';

  @override
  String get noProductions => 'வரவிருக்கும் நிகழ்ச்சிகள் இல்லை.';

  @override
  String get favourite => 'விருப்பம்';

  @override
  String get bookNow => 'இப்போது முன்பதிவு';

  @override
  String get mockConfigNote =>
      'VAT மற்றும் சலுகை மதிப்புகள் பின்தள உறுதிப்படுத்தலுக்காக காத்திருக்கும் மாதிரி மதிப்புகள்.';

  @override
  String get flagged =>
      'இந்த முன்பதிவு கவுன்டர் சரிபார்ப்புக்காக குறிக்கப்பட்டுள்ளது.';

  @override
  String get requiredField => 'இந்தப் புலம் தேவை.';

  @override
  String get invalidEmail => 'செல்லுபடியாகும் மின்னஞ்சலை உள்ளிடவும்.';

  @override
  String get invalidIdentity =>
      'செல்லுபடியாகும் NIC அல்லது கடவுச்சீட்டு எண்ணை உள்ளிடவும்.';

  @override
  String get seatHoldExpired =>
      'இருக்கை ஒதுக்கீடு முடிந்தது. மீண்டும் தேர்ந்தெடுக்கவும்.';

  @override
  String get prototypeContent =>
      'அங்கீகரிக்கப்பட்ட உள்ளடக்கம் வரும் வரை மாதிரி உரை';

  @override
  String get invalidLargeParty =>
      'பெரிய குழு சலுகைக்கு குறைந்தது 11 இருக்கைகள் தேவை.';
}
