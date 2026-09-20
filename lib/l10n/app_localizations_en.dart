// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Sapumal Theatre';

  @override
  String get home => 'Home';

  @override
  String get shows => 'Shows';

  @override
  String get bookings => 'Bookings';

  @override
  String get profile => 'Profile';

  @override
  String get more => 'More';

  @override
  String get bookTickets => 'Book Tickets';

  @override
  String get heroTitle => 'Experience the Art of Performance';

  @override
  String get heroSubtitle => 'Book your favourite shows anytime, anywhere.';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get all => 'All';

  @override
  String get sinhala => 'Sinhala';

  @override
  String get tamil => 'Tamil';

  @override
  String get english => 'English';

  @override
  String get thisWeek => 'This Week';

  @override
  String fromPrice(String price) {
    return 'From $price';
  }

  @override
  String get productionDetails => 'Production details';

  @override
  String get selectPerformance => 'Select a performance';

  @override
  String get selectSeats => 'Select Seats';

  @override
  String get matinee => 'Matinee';

  @override
  String get evening => 'Evening';

  @override
  String get poyaDay => 'Poya day - closed';

  @override
  String get earlyAccess => 'Loyalty members can book seven days early.';

  @override
  String get loyaltyOnly =>
      'This performance is currently available to loyalty members only.';

  @override
  String get venue => 'Sapumal Theatre - Colombo 07';

  @override
  String get readMore => 'Read more';

  @override
  String get seatSelection => 'Select Seats';

  @override
  String get stalls => 'Stalls';

  @override
  String get circle => 'Circle';

  @override
  String get upperCircle => 'Upper Circle';

  @override
  String get stage => 'STAGE';

  @override
  String get available => 'Available';

  @override
  String get selected => 'Selected';

  @override
  String get booked => 'Booked';

  @override
  String get held => 'Held';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get accessibleSeat => 'Accessible seat';

  @override
  String seatsSelected(int count) {
    return '$count seats selected';
  }

  @override
  String get continueLabel => 'Continue';

  @override
  String holdTime(String time) {
    return 'Hold expires in $time';
  }

  @override
  String get passengerDetails => 'Passenger Details';

  @override
  String get contactInfo => 'Contact information';

  @override
  String get fullName => 'Full name';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone number';

  @override
  String get concessionOptional => 'Concession (optional)';

  @override
  String get concessionType => 'Concession type';

  @override
  String get none => 'None';

  @override
  String get under16 => 'Under 16';

  @override
  String get over70 => 'Over 70';

  @override
  String get largeParty => 'Large party (11+)';

  @override
  String get identityNumber => 'NIC / passport number';

  @override
  String get verificationNotice =>
      'Identity and eligibility will be verified at the box office on the performance day.';

  @override
  String get continueSummary => 'Continue to Summary';

  @override
  String get bookingSummary => 'Booking Summary';

  @override
  String get ticketTotal => 'Ticket total';

  @override
  String get discounts => 'Discounts';

  @override
  String get loyaltyDiscount => 'Loyalty discount (10%)';

  @override
  String vat(int rate) {
    return 'VAT ($rate%)';
  }

  @override
  String get totalPayable => 'Total payable';

  @override
  String get termsConsent =>
      'I accept the Terms and Conditions and acknowledge the Privacy Notice.';

  @override
  String get proceedCheckout => 'Proceed to Checkout';

  @override
  String get payment => 'Payment';

  @override
  String get amountToPay => 'Amount to pay';

  @override
  String get cardPayment => 'Card payment';

  @override
  String get mobilePayment => 'Mobile payment';

  @override
  String get internetBanking => 'Internet banking';

  @override
  String get mockPaymentNotice =>
      'Prototype payment only. Do not enter real card details.';

  @override
  String get payNow => 'Pay Now';

  @override
  String get simulateFailure => 'Simulate declined payment';

  @override
  String get paymentFailed =>
      'Payment was declined. Your seats remain held for five minutes.';

  @override
  String get retry => 'Retry';

  @override
  String get bookingConfirmed => 'Booking Confirmed!';

  @override
  String get confirmationMessage =>
      'Your tickets have been booked successfully.';

  @override
  String get bookingReference => 'Booking reference';

  @override
  String get viewBookings => 'View My Bookings';

  @override
  String get backHome => 'Back to Home';

  @override
  String get upcomingTab => 'Upcoming';

  @override
  String get pastTab => 'Past';

  @override
  String get noBookings => 'No bookings yet';

  @override
  String get lookupBooking => 'Find a booking';

  @override
  String get reference => 'Booking reference';

  @override
  String get search => 'Search';

  @override
  String get notFound => 'No matching booking was found.';

  @override
  String get myProfile => 'My Profile';

  @override
  String get loyaltyCard => 'Loyalty Card';

  @override
  String get loyaltyMember => 'Loyalty member';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get settings => 'Settings';

  @override
  String get aboutUs => 'About Us';

  @override
  String get logout => 'Logout';

  @override
  String get login => 'Login';

  @override
  String get register => 'Create an account';

  @override
  String get createAccount => 'Create Account';

  @override
  String get invalidCredentials =>
      'Use a valid email and a 12+ character password with upper-case, lower-case, number, and special characters.';

  @override
  String get accountLocked =>
      'This mock account is locked after five failed attempts.';

  @override
  String get loyaltyLinked => 'Mock loyalty membership linked.';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get demoCredentials =>
      'Use any valid email and a 12-character password in mock mode.';

  @override
  String get themeMode => 'Brightness';

  @override
  String get colourPalette => 'Brand colour palette';

  @override
  String get burgundy => 'Burgundy';

  @override
  String get midnight => 'Midnight';

  @override
  String get emerald => 'Emerald';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get terms => 'Terms and Conditions';

  @override
  String get manageData => 'Manage my data';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Something went wrong.';

  @override
  String get noProductions =>
      'No upcoming productions are currently scheduled.';

  @override
  String get favourite => 'Favourite';

  @override
  String get bookNow => 'Book now';

  @override
  String get mockConfigNote =>
      'VAT and concession values are prototype configuration pending backend confirmation.';

  @override
  String get flagged => 'This booking is flagged for box-office verification.';

  @override
  String get requiredField => 'This field is required.';

  @override
  String get invalidEmail => 'Enter a valid email address.';

  @override
  String get invalidIdentity => 'Enter a valid NIC or passport number.';

  @override
  String get seatHoldExpired =>
      'Your seat hold expired. Please select seats again.';

  @override
  String get prototypeContent => 'Prototype content - pending approved copy';

  @override
  String get invalidLargeParty =>
      'Large-party concessions require at least 11 selected seats.';
}
