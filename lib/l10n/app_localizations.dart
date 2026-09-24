import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Sapumal Theatre'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @shows.
  ///
  /// In en, this message translates to:
  /// **'Shows'**
  String get shows;

  /// No description provided for @bookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @bookTickets.
  ///
  /// In en, this message translates to:
  /// **'Book Tickets'**
  String get bookTickets;

  /// No description provided for @heroTitle.
  ///
  /// In en, this message translates to:
  /// **'Experience the Art of Performance'**
  String get heroTitle;

  /// No description provided for @heroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Book your favourite shows anytime, anywhere.'**
  String get heroSubtitle;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @sinhala.
  ///
  /// In en, this message translates to:
  /// **'Sinhala'**
  String get sinhala;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'Tamil'**
  String get tamil;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @fromPrice.
  ///
  /// In en, this message translates to:
  /// **'From {price}'**
  String fromPrice(String price);

  /// No description provided for @productionDetails.
  ///
  /// In en, this message translates to:
  /// **'Production details'**
  String get productionDetails;

  /// No description provided for @selectPerformance.
  ///
  /// In en, this message translates to:
  /// **'Select a performance'**
  String get selectPerformance;

  /// No description provided for @selectSeats.
  ///
  /// In en, this message translates to:
  /// **'Select Seats'**
  String get selectSeats;

  /// No description provided for @matinee.
  ///
  /// In en, this message translates to:
  /// **'Matinee'**
  String get matinee;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @poyaDay.
  ///
  /// In en, this message translates to:
  /// **'Poya day - closed'**
  String get poyaDay;

  /// No description provided for @earlyAccess.
  ///
  /// In en, this message translates to:
  /// **'Loyalty members can book seven days early.'**
  String get earlyAccess;

  /// No description provided for @loyaltyOnly.
  ///
  /// In en, this message translates to:
  /// **'This performance is currently available to loyalty members only.'**
  String get loyaltyOnly;

  /// No description provided for @venue.
  ///
  /// In en, this message translates to:
  /// **'Sapumal Theatre - Colombo 07'**
  String get venue;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @seatSelection.
  ///
  /// In en, this message translates to:
  /// **'Select Seats'**
  String get seatSelection;

  /// No description provided for @stalls.
  ///
  /// In en, this message translates to:
  /// **'Stalls'**
  String get stalls;

  /// No description provided for @circle.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get circle;

  /// No description provided for @upperCircle.
  ///
  /// In en, this message translates to:
  /// **'Upper Circle'**
  String get upperCircle;

  /// No description provided for @stage.
  ///
  /// In en, this message translates to:
  /// **'STAGE'**
  String get stage;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @booked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get booked;

  /// No description provided for @held.
  ///
  /// In en, this message translates to:
  /// **'Held'**
  String get held;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @accessibleSeat.
  ///
  /// In en, this message translates to:
  /// **'Accessible seat'**
  String get accessibleSeat;

  /// No description provided for @seatsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} seats selected'**
  String seatsSelected(int count);

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @holdTime.
  ///
  /// In en, this message translates to:
  /// **'Hold expires in {time}'**
  String holdTime(String time);

  /// No description provided for @passengerDetails.
  ///
  /// In en, this message translates to:
  /// **'Passenger Details'**
  String get passengerDetails;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact information'**
  String get contactInfo;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phone;

  /// No description provided for @concessionOptional.
  ///
  /// In en, this message translates to:
  /// **'Concession (optional)'**
  String get concessionOptional;

  /// No description provided for @concessionType.
  ///
  /// In en, this message translates to:
  /// **'Concession type'**
  String get concessionType;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @under16.
  ///
  /// In en, this message translates to:
  /// **'Under 16'**
  String get under16;

  /// No description provided for @over70.
  ///
  /// In en, this message translates to:
  /// **'Over 70'**
  String get over70;

  /// No description provided for @largeParty.
  ///
  /// In en, this message translates to:
  /// **'Large party (11+)'**
  String get largeParty;

  /// No description provided for @identityNumber.
  ///
  /// In en, this message translates to:
  /// **'NIC / passport number'**
  String get identityNumber;

  /// No description provided for @verificationNotice.
  ///
  /// In en, this message translates to:
  /// **'Identity and eligibility will be verified at the box office on the performance day.'**
  String get verificationNotice;

  /// No description provided for @continueSummary.
  ///
  /// In en, this message translates to:
  /// **'Continue to Summary'**
  String get continueSummary;

  /// No description provided for @bookingSummary.
  ///
  /// In en, this message translates to:
  /// **'Booking Summary'**
  String get bookingSummary;

  /// No description provided for @ticketTotal.
  ///
  /// In en, this message translates to:
  /// **'Ticket total'**
  String get ticketTotal;

  /// No description provided for @discounts.
  ///
  /// In en, this message translates to:
  /// **'Discounts'**
  String get discounts;

  /// No description provided for @loyaltyDiscount.
  ///
  /// In en, this message translates to:
  /// **'Loyalty discount (10%)'**
  String get loyaltyDiscount;

  /// No description provided for @vat.
  ///
  /// In en, this message translates to:
  /// **'VAT ({rate}%)'**
  String vat(int rate);

  /// No description provided for @totalPayable.
  ///
  /// In en, this message translates to:
  /// **'Total payable'**
  String get totalPayable;

  /// No description provided for @termsConsent.
  ///
  /// In en, this message translates to:
  /// **'I accept the Terms and Conditions and acknowledge the Privacy Notice.'**
  String get termsConsent;

  /// No description provided for @proceedCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get proceedCheckout;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @amountToPay.
  ///
  /// In en, this message translates to:
  /// **'Amount to pay'**
  String get amountToPay;

  /// No description provided for @cardPayment.
  ///
  /// In en, this message translates to:
  /// **'Card payment'**
  String get cardPayment;

  /// No description provided for @mobilePayment.
  ///
  /// In en, this message translates to:
  /// **'Mobile payment'**
  String get mobilePayment;

  /// No description provided for @internetBanking.
  ///
  /// In en, this message translates to:
  /// **'Internet banking'**
  String get internetBanking;

  /// No description provided for @mockPaymentNotice.
  ///
  /// In en, this message translates to:
  /// **'Prototype payment only. Do not enter real card details.'**
  String get mockPaymentNotice;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @simulateFailure.
  ///
  /// In en, this message translates to:
  /// **'Simulate declined payment'**
  String get simulateFailure;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment was declined. Your seats remain held for five minutes.'**
  String get paymentFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @bookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed!'**
  String get bookingConfirmed;

  /// No description provided for @confirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Your tickets have been booked successfully.'**
  String get confirmationMessage;

  /// No description provided for @bookingReference.
  ///
  /// In en, this message translates to:
  /// **'Booking reference'**
  String get bookingReference;

  /// No description provided for @viewBookings.
  ///
  /// In en, this message translates to:
  /// **'View My Bookings'**
  String get viewBookings;

  /// No description provided for @backHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backHome;

  /// No description provided for @upcomingTab.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcomingTab;

  /// No description provided for @pastTab.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get pastTab;

  /// No description provided for @noBookings.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get noBookings;

  /// No description provided for @lookupBooking.
  ///
  /// In en, this message translates to:
  /// **'Find a booking'**
  String get lookupBooking;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Booking reference'**
  String get reference;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'No matching booking was found.'**
  String get notFound;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @loyaltyCard.
  ///
  /// In en, this message translates to:
  /// **'Loyalty Card'**
  String get loyaltyCard;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @loyaltyMember.
  ///
  /// In en, this message translates to:
  /// **'Loyalty member'**
  String get loyaltyMember;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get register;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Use a valid email and a 12+ character password with upper-case, lower-case, number, and special characters.'**
  String get invalidCredentials;

  /// No description provided for @accountLocked.
  ///
  /// In en, this message translates to:
  /// **'This mock account is locked after five failed attempts.'**
  String get accountLocked;

  /// No description provided for @loyaltyLinked.
  ///
  /// In en, this message translates to:
  /// **'Mock loyalty membership linked.'**
  String get loyaltyLinked;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @demoCredentials.
  ///
  /// In en, this message translates to:
  /// **'Use any valid email and a 12-character password in mock mode.'**
  String get demoCredentials;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get themeMode;

  /// No description provided for @colourPalette.
  ///
  /// In en, this message translates to:
  /// **'Brand colour palette'**
  String get colourPalette;

  /// No description provided for @burgundy.
  ///
  /// In en, this message translates to:
  /// **'Burgundy'**
  String get burgundy;

  /// No description provided for @midnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get midnight;

  /// No description provided for @emerald.
  ///
  /// In en, this message translates to:
  /// **'Emerald'**
  String get emerald;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get terms;

  /// No description provided for @manageData.
  ///
  /// In en, this message translates to:
  /// **'Manage my data'**
  String get manageData;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get error;

  /// No description provided for @noProductions.
  ///
  /// In en, this message translates to:
  /// **'No upcoming productions are currently scheduled.'**
  String get noProductions;

  /// No description provided for @favourite.
  ///
  /// In en, this message translates to:
  /// **'Favourite'**
  String get favourite;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book now'**
  String get bookNow;

  /// No description provided for @mockConfigNote.
  ///
  /// In en, this message translates to:
  /// **'VAT and concession values are prototype configuration pending backend confirmation.'**
  String get mockConfigNote;

  /// No description provided for @flagged.
  ///
  /// In en, this message translates to:
  /// **'This booking is flagged for box-office verification.'**
  String get flagged;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get invalidEmail;

  /// No description provided for @invalidIdentity.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid NIC or passport number.'**
  String get invalidIdentity;

  /// No description provided for @seatHoldExpired.
  ///
  /// In en, this message translates to:
  /// **'Your seat hold expired. Please select seats again.'**
  String get seatHoldExpired;

  /// No description provided for @prototypeContent.
  ///
  /// In en, this message translates to:
  /// **'Prototype content - pending approved copy'**
  String get prototypeContent;

  /// No description provided for @invalidLargeParty.
  ///
  /// In en, this message translates to:
  /// **'Large-party concessions require at least 11 selected seats.'**
  String get invalidLargeParty;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
