import 'dart:io';

const _width = 390.0;
const _height = 844.0;

class ScreenSpec {
  const ScreenSpec(this.fileName, this.title, this.draw);

  final String fileName;
  final String title;
  final void Function(Canvas c) draw;
}

class Canvas {
  final StringBuffer _out = StringBuffer();

  void rect(
    double x,
    double y,
    double width,
    double height, {
    double radius = 12,
    String fill = '#FFFFFF',
    String stroke = '#1F2937',
    double strokeWidth = 1.5,
    String dash = '',
  }) {
    _out.writeln(
      '<rect x="$x" y="$y" width="$width" height="$height" rx="$radius" '
      'fill="$fill" stroke="$stroke" stroke-width="$strokeWidth"'
      '${dash.isEmpty ? '' : ' stroke-dasharray="$dash"'}/>',
    );
  }

  void line(double x1, double y1, double x2, double y2, {double width = 1.5}) {
    _out.writeln(
      '<line x1="$x1" y1="$y1" x2="$x2" y2="$y2" '
      'stroke="#1F2937" stroke-width="$width" stroke-linecap="round"/>',
    );
  }

  void circle(double cx, double cy, double r, {String fill = '#FFFFFF'}) {
    _out.writeln(
      '<circle cx="$cx" cy="$cy" r="$r" fill="$fill" '
      'stroke="#1F2937" stroke-width="1.5"/>',
    );
  }

  void text(
    String value,
    double x,
    double y, {
    double size = 14,
    int weight = 400,
    String anchor = 'start',
    String fill = '#111827',
  }) {
    _out.writeln(
      '<text x="$x" y="$y" font-family="Inter, Arial, sans-serif" '
      'font-size="$size" font-weight="$weight" text-anchor="$anchor" '
      'fill="$fill">${_escape(value)}</text>',
    );
  }

  void label(String value, double x, double y) =>
      text(value, x, y, size: 11, weight: 600, fill: '#4B5563');

  void title(String value, {double y = 88}) =>
      text(value, 24, y, size: 28, weight: 700);

  void topBar(String value, {bool back = true}) {
    if (back) {
      text('‹', 22, 76, size: 32, weight: 400);
    }
    text(value, back ? 52 : 24, 72, size: 20, weight: 700);
    line(0, 96, _width, 96, width: 1);
  }

  void field(String labelText, double y, {String hint = ''}) {
    label(labelText.toUpperCase(), 24, y);
    rect(24, y + 9, 342, 48, radius: 10, stroke: '#6B7280');
    if (hint.isNotEmpty) text(hint, 38, y + 39, size: 13, fill: '#6B7280');
  }

  void button(
    String value,
    double y, {
    bool primary = true,
    double x = 24,
    double width = 342,
  }) {
    rect(
      x,
      y,
      width,
      48,
      radius: 24,
      fill: primary ? '#1F2937' : '#FFFFFF',
      stroke: '#1F2937',
    );
    text(
      value,
      x + width / 2,
      y + 30,
      size: 14,
      weight: 700,
      anchor: 'middle',
      fill: primary ? '#FFFFFF' : '#111827',
    );
  }

  void card(
    double y,
    double height, {
    double x = 24,
    double width = 342,
    String fill = '#F9FAFB',
  }) {
    rect(x, y, width, height, radius: 16, fill: fill, stroke: '#9CA3AF');
  }

  void image(
    double x,
    double y,
    double width,
    double height, {
    String labelText = 'IMAGE',
  }) {
    rect(x, y, width, height, radius: 12, fill: '#E5E7EB', stroke: '#9CA3AF');
    line(x + 12, y + height - 12, x + width * .42, y + height * .5);
    line(x + width * .42, y + height * .5, x + width * .62, y + height * .7);
    line(x + width * .62, y + height * .7, x + width - 12, y + height * .32);
    text(
      labelText,
      x + width / 2,
      y + height / 2 - 8,
      size: 10,
      weight: 600,
      anchor: 'middle',
      fill: '#6B7280',
    );
  }

  void pill(
    String value,
    double x,
    double y,
    double width, {
    bool selected = false,
  }) {
    rect(
      x,
      y,
      width,
      32,
      radius: 16,
      fill: selected ? '#D1D5DB' : '#FFFFFF',
      stroke: '#6B7280',
    );
    text(value, x + width / 2, y + 21, size: 11, weight: 600, anchor: 'middle');
  }

  void listTile(
    String titleText,
    String subtitle,
    double y, {
    String icon = '○',
    bool chevron = true,
  }) {
    card(y, 62);
    text(icon, 42, y + 37, size: 20, weight: 600, anchor: 'middle');
    text(titleText, 65, y + 25, size: 14, weight: 600);
    if (subtitle.isNotEmpty)
      text(subtitle, 65, y + 45, size: 11, fill: '#6B7280');
    if (chevron) text('›', 344, y + 39, size: 24, fill: '#6B7280');
  }

  void checkbox(String value, double y, {bool checked = false}) {
    rect(24, y, 20, 20, radius: 4, fill: checked ? '#1F2937' : '#FFFFFF');
    if (checked)
      text('✓', 34, y + 15, size: 13, anchor: 'middle', fill: '#FFFFFF');
    text(value, 54, y + 15, size: 12);
  }

  void divider(double y) => line(24, y, 366, y, width: 1);

  void nav(int selected) {
    rect(16, 756, 358, 70, radius: 28, fill: '#F3F4F6', stroke: '#9CA3AF');
    const labels = ['Home', 'Shows', 'Bookings', 'Profile'];
    const icons = ['⌂', '◈', '▱', '♙'];
    for (var i = 0; i < labels.length; i++) {
      final x = 22 + i * 88.5;
      if (i == selected)
        rect(x, 763, 80, 56, radius: 22, fill: '#D1D5DB', stroke: '#9CA3AF');
      text(icons[i], x + 40, 787, size: 19, weight: 600, anchor: 'middle');
      text(
        labels[i],
        x + 40,
        808,
        size: 10,
        weight: i == selected ? 700 : 500,
        anchor: 'middle',
      );
    }
  }

  void statusBar() {
    text('9:41', 24, 29, size: 12, weight: 700);
    text('● )))  ▰', 362, 29, size: 10, anchor: 'end');
  }

  String get content => _out.toString();
}

String _escape(String input) => input
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

String _screenSvg(ScreenSpec spec) {
  final c = Canvas()..statusBar();
  spec.draw(c);
  return '''<svg xmlns="http://www.w3.org/2000/svg" width="390" height="844" viewBox="0 0 390 844">
<rect width="390" height="844" fill="#FFFFFF"/>
${c.content}</svg>
''';
}

void main() {
  final output = Directory('design/wireframes')..createSync(recursive: true);
  for (final spec in screens) {
    File(
      '${output.path}/${spec.fileName}.svg',
    ).writeAsStringSync(_screenSvg(spec));
  }
  File(
    '${output.path}/wireframes-overview.svg',
  ).writeAsStringSync(_overviewSvg());
}

String _overviewSvg() {
  const columns = 4;
  const scale = .42;
  const cellWidth = 190.0;
  const cellHeight = 390.0;
  final rows = (screens.length / columns).ceil();
  final out = StringBuffer()
    ..writeln(
      '<svg xmlns="http://www.w3.org/2000/svg" width="${columns * cellWidth}" height="${rows * cellHeight}" viewBox="0 0 ${columns * cellWidth} ${rows * cellHeight}">',
    )
    ..writeln('<rect width="100%" height="100%" fill="#E5E7EB"/>');
  for (var i = 0; i < screens.length; i++) {
    final spec = screens[i];
    final col = i % columns;
    final row = i ~/ columns;
    final x = col * cellWidth + 13;
    final y = row * cellHeight + 30;
    final c = Canvas()..statusBar();
    spec.draw(c);
    out
      ..writeln(
        '<text x="${col * cellWidth + 10}" y="${row * cellHeight + 20}" font-family="Inter, Arial" font-size="12" font-weight="700" fill="#111827">${i + 1}. ${_escape(spec.title)}</text>',
      )
      ..writeln('<g transform="translate($x $y) scale($scale)">')
      ..writeln(
        '<rect width="390" height="844" rx="22" fill="#FFFFFF" stroke="#111827" stroke-width="2"/>',
      )
      ..writeln(c.content)
      ..writeln('</g>');
  }
  out.writeln('</svg>');
  return out.toString();
}

final screens = <ScreenSpec>[
  ScreenSpec('01-welcome', 'Welcome', (c) {
    c.text('THEATRE', 195, 76, size: 14, weight: 800, anchor: 'middle');
    c.image(32, 105, 326, 290, labelText: 'ONBOARDING ARTWORK');
    c.text('Discover remarkable theatre.', 24, 445, size: 25, weight: 700);
    c.text(
      'Browse productions, choose your seats and',
      24,
      478,
      size: 13,
      fill: '#4B5563',
    );
    c.text(
      'keep every ticket close at hand.',
      24,
      499,
      size: 13,
      fill: '#4B5563',
    );
    c.text('●  ○  ○', 195, 545, size: 16, anchor: 'middle');
    c.button('Get started', 606);
    c.button('I already have an account', 668, primary: false);
  }),
  ScreenSpec('02-login', 'Login', (c) {
    c.topBar('Sign in');
    c.text('Welcome back', 24, 142, size: 28, weight: 700);
    c.text(
      'Sign in to manage bookings and tickets.',
      24,
      168,
      size: 13,
      fill: '#4B5563',
    );
    c.field('Email', 205, hint: 'name@example.com');
    c.field('Password', 286, hint: '••••••••');
    c.text('Forgot password?', 366, 372, size: 12, weight: 600, anchor: 'end');
    c.button('Sign in', 410);
    c.button('Create an account', 472, primary: false);
    c.text(
      '────────  OR  ────────',
      195,
      556,
      size: 11,
      anchor: 'middle',
      fill: '#6B7280',
    );
    c.button('Continue as guest', 586, primary: false);
    c.text(
      'Guest access includes shows and seat availability.',
      195,
      660,
      size: 11,
      anchor: 'middle',
      fill: '#6B7280',
    );
  }),
  ScreenSpec('03-registration', 'Registration', (c) {
    c.topBar('Create account');
    c.text('Your details', 24, 128, size: 21, weight: 700);
    c.field('Full name', 150, hint: 'Name as shown on ID');
    c.field('Date of birth', 221, hint: 'DD / MM / YYYY');
    c.field('NIC / Passport', 292, hint: 'Identity number');
    c.field('Email', 363, hint: 'name@example.com');
    c.field('Mobile number', 434, hint: '+94');
    c.field('Password', 505, hint: 'Minimum 8 characters');
    c.checkbox('I accept the Terms & Conditions.', 588, checked: true);
    c.checkbox('I acknowledge the Privacy Notice.', 620, checked: true);
    c.button('Create account', 666);
    c.text(
      'Already registered? Sign in',
      195,
      744,
      size: 12,
      weight: 600,
      anchor: 'middle',
    );
  }),
  ScreenSpec('04-registration-success', 'Registration success', (c) {
    c.circle(195, 245, 58, fill: '#F3F4F6');
    c.text('✓', 195, 266, size: 56, weight: 700, anchor: 'middle');
    c.text(
      'Account created',
      195,
      346,
      size: 28,
      weight: 700,
      anchor: 'middle',
    );
    c.text(
      'Your theatre account is ready.',
      195,
      377,
      size: 14,
      anchor: 'middle',
      fill: '#4B5563',
    );
    c.text(
      'Sign in to continue.',
      195,
      399,
      size: 14,
      anchor: 'middle',
      fill: '#4B5563',
    );
    c.button('Return to login', 474);
  }),
  ScreenSpec('05-home', 'Home dashboard', (c) {
    c.text('Good evening, Haritha', 24, 72, size: 20, weight: 700);
    c.pill('LOYALTY', 280, 50, 86, selected: true);
    c.card(104, 225, fill: '#F3F4F6');
    c.image(38, 120, 112, 150, labelText: 'POSTER');
    c.pill('FEATURED', 168, 122, 82);
    c.text('Hamlet', 168, 172, size: 25, weight: 700);
    c.text('Tonight · 7:30 PM', 168, 200, size: 13);
    c.text('From LKR 1,350', 168, 226, size: 13, weight: 600);
    c.button('Book tickets', 268, x: 164, width: 176);
    c.text("Today's shows", 24, 372, size: 20, weight: 700);
    c.card(390, 76, x: 24, width: 164);
    c.card(390, 76, x: 202, width: 164);
    c.text('10:00 AM', 38, 418, size: 13, weight: 700);
    c.text('Production title', 38, 443, size: 11);
    c.text('7:30 PM', 216, 418, size: 13, weight: 700);
    c.text('Production title', 216, 443, size: 11);
    c.text('Quick access', 24, 507, size: 20, weight: 700);
    c.listTile(
      'Browse upcoming shows',
      'Find your next performance',
      524,
      icon: '◈',
    );
    c.text('Coming up', 24, 626, size: 20, weight: 700);
    c.card(644, 82);
    c.text('28 SEP', 42, 674, size: 11, weight: 700);
    c.text('Next performance title', 104, 674, size: 14, weight: 600);
    c.text('Matinee · 10:00 AM', 104, 698, size: 11, fill: '#6B7280');
    c.nav(0);
  }),
  ScreenSpec('06-shows', 'Shows / productions', (c) {
    c.title('Shows', y: 92);
    c.rect(24, 116, 342, 50, radius: 25, fill: '#F3F4F6', stroke: '#9CA3AF');
    c.text('⌕', 45, 149, size: 24);
    c.text('Search productions', 76, 147, size: 14, fill: '#6B7280');
    c.pill('All', 24, 184, 58, selected: true);
    c.pill('Sinhala', 91, 184, 75);
    c.pill('Tamil', 175, 184, 66);
    c.pill('English', 250, 184, 76);
    c.text('Upcoming productions', 24, 253, size: 20, weight: 700);
    c.text('7 found', 366, 251, size: 12, anchor: 'end', fill: '#6B7280');
    for (var i = 0; i < 3; i++) {
      final y = 272.0 + i * 146;
      c.card(y, 128);
      c.image(36, y + 12, 88, 104, labelText: 'POSTER');
      c.pill(i == 0 ? 'ENGLISH' : 'TAMIL', 140, y + 14, 76);
      c.text('Production title', 140, y + 63, size: 16, weight: 700);
      c.text('${27 + i}/09/2026 · 7:30 PM', 140, y + 88, size: 12);
      c.text('From LKR 1,350   →', 140, y + 110, size: 12, weight: 600);
    }
    c.nav(1);
  }),
  ScreenSpec('07-production-details', 'Production details', (c) {
    c.image(0, 42, 390, 250, labelText: 'PRODUCTION HERO');
    c.circle(34, 72, 18, fill: '#FFFFFF');
    c.text('‹', 34, 82, size: 28, anchor: 'middle');
    c.pill('ENGLISH', 24, 314, 82);
    c.pill('TRAGEDY', 114, 314, 80);
    c.text('Hamlet', 24, 382, size: 30, weight: 700);
    c.text(
      'A compelling production presented on the main',
      24,
      412,
      size: 13,
      fill: '#4B5563',
    );
    c.text(
      'stage. Full synopsis continues here…',
      24,
      432,
      size: 13,
      fill: '#4B5563',
    );
    c.card(456, 80);
    c.text('EARLY ACCESS', 40, 482, size: 11, weight: 700);
    c.text(
      'Tickets available from the production release date.',
      40,
      509,
      size: 12,
    );
    c.text('Performances', 24, 580, size: 20, weight: 700);
    c.card(598, 72);
    c.text('SUN 27 SEP', 40, 627, size: 12, weight: 700);
    c.text('7:30 PM · Evening', 40, 650, size: 12);
    c.button('Select seats', 606, x: 238, width: 112);
    c.card(684, 54);
    c.text(
      'MON 28 SEP   ·   10:00 AM   ·   Matinee',
      40,
      716,
      size: 12,
      weight: 600,
    );
    c.button('Choose performance', 768);
  }),
  ScreenSpec('08-seat-selection', 'Seat selection', (c) {
    c.topBar('Select seats');
    c.text('Hamlet · Sun 27 Sep · 7:30 PM', 24, 126, size: 13, weight: 600);
    c.pill('Stalls', 24, 150, 96, selected: true);
    c.pill('Circle', 128, 150, 96);
    c.pill('Upper circle', 232, 150, 120);
    c.rect(60, 210, 270, 28, radius: 14, fill: '#E5E7EB', stroke: '#6B7280');
    c.text('STAGE', 195, 229, size: 11, weight: 700, anchor: 'middle');
    for (var row = 0; row < 7; row++) {
      c.text(
        String.fromCharCode(65 + row),
        32,
        278 + row * 42,
        size: 11,
        weight: 700,
      );
      for (var seat = 0; seat < 8; seat++) {
        final selected = row == 2 && (seat == 3 || seat == 4);
        final unavailable = (row + seat) % 7 == 0;
        c.rect(
          56 + seat * 37,
          260 + row * 42,
          26,
          26,
          radius: 7,
          fill: selected
              ? '#4B5563'
              : unavailable
              ? '#D1D5DB'
              : '#FFFFFF',
          stroke: '#6B7280',
        );
      }
    }
    c.circle(55, 584, 7);
    c.text('Available', 69, 589, size: 10);
    c.circle(145, 584, 7, fill: '#4B5563');
    c.text('Selected', 159, 589, size: 10);
    c.circle(235, 584, 7, fill: '#D1D5DB');
    c.text('Unavailable', 249, 589, size: 10);
    c.card(620, 116);
    c.text('2 seats selected', 40, 648, size: 15, weight: 700);
    c.text('C4, C5 · Circle Mid', 40, 675, size: 12);
    c.text('LKR 2,700', 350, 675, size: 14, weight: 700, anchor: 'end');
    c.button('Continue', 686, x: 222, width: 128);
  }),
  ScreenSpec('09-passenger-details', 'Patron details', (c) {
    c.topBar('Your details');
    c.text('Who is this booking for?', 24, 132, size: 20, weight: 700);
    c.text(
      'We use these details for the ticket and receipt.',
      24,
      156,
      size: 12,
      fill: '#4B5563',
    );
    c.field('Full name', 186, hint: 'Haritha');
    c.field('Email', 266, hint: 'name@example.com');
    c.field('Mobile number', 346, hint: '+94 7X XXX XXXX');
    c.field(
      'Concession',
      426,
      hint: 'None                                      ▾',
    );
    c.card(520, 82, fill: '#F3F4F6');
    c.text('ⓘ', 44, 555, size: 20, anchor: 'middle');
    c.text(
      'Concession eligibility may be checked',
      68,
      548,
      size: 12,
      weight: 600,
    );
    c.text('at the theatre entrance.', 68, 571, size: 12);
    c.button('Continue to summary', 640);
  }),
  ScreenSpec('10-booking-summary', 'Booking summary', (c) {
    c.topBar('Booking summary');
    c.card(116, 86);
    c.text('Hamlet', 40, 143, size: 17, weight: 700);
    c.text('Sun 27 Sep 2026 · 7:30 PM', 40, 169, size: 12);
    c.text('2 tickets', 350, 169, size: 12, anchor: 'end');
    c.text('Seats', 24, 240, size: 18, weight: 700);
    c.listTile(
      'C4 · Circle Mid',
      'Regular ticket',
      256,
      icon: '▱',
      chevron: false,
    );
    c.listTile(
      'C5 · Circle Mid',
      'Regular ticket',
      328,
      icon: '▱',
      chevron: false,
    );
    c.card(420, 150);
    c.text('Subtotal', 40, 449, size: 13);
    c.text('LKR 2,288', 350, 449, size: 13, anchor: 'end');
    c.text('VAT', 40, 480, size: 13);
    c.text('LKR 412', 350, 480, size: 13, anchor: 'end');
    c.divider(500);
    c.text('Total', 40, 535, size: 16, weight: 700);
    c.text('LKR 2,700', 350, 535, size: 16, weight: 700, anchor: 'end');
    c.checkbox(
      'I accept the booking terms and conditions.',
      606,
      checked: true,
    );
    c.button('Proceed to payment', 662);
  }),
  ScreenSpec('11-payment', 'Payment', (c) {
    c.topBar('Payment');
    c.text('Amount to pay', 24, 140, size: 13, fill: '#4B5563');
    c.text('LKR 2,700', 24, 178, size: 30, weight: 700);
    c.card(216, 186);
    c.text('●', 46, 253, size: 14);
    c.text('Card payment', 72, 253, size: 14, weight: 600);
    c.text('▰', 344, 253, size: 18, anchor: 'middle');
    c.divider(278);
    c.text('○', 46, 316, size: 14, fill: '#9CA3AF');
    c.text('Mobile payment', 72, 316, size: 14, fill: '#9CA3AF');
    c.divider(340);
    c.text('○', 46, 378, size: 14, fill: '#9CA3AF');
    c.text('Internet banking', 72, 378, size: 14, fill: '#9CA3AF');
    c.card(428, 90, fill: '#F3F4F6');
    c.text('⌾', 46, 467, size: 19, anchor: 'middle');
    c.text('Simulated payment', 72, 457, size: 13, weight: 700);
    c.text('No real card will be charged.', 72, 482, size: 12);
    c.text('Simulate payment failure', 24, 568, size: 13, weight: 600);
    c.rect(310, 548, 52, 30, radius: 15, fill: '#E5E7EB', stroke: '#9CA3AF');
    c.circle(326, 563, 11, fill: '#FFFFFF');
    c.button('Pay now', 632);
  }),
  ScreenSpec('12-booking-confirmation', 'Booking confirmation', (c) {
    c.circle(195, 112, 34, fill: '#F3F4F6');
    c.text('✓', 195, 126, size: 36, weight: 700, anchor: 'middle');
    c.text(
      'Booking confirmed',
      195,
      177,
      size: 25,
      weight: 700,
      anchor: 'middle',
    );
    c.text(
      'Your ticket is ready.',
      195,
      205,
      size: 13,
      anchor: 'middle',
      fill: '#4B5563',
    );
    c.rect(
      105,
      230,
      180,
      180,
      radius: 12,
      fill: '#FFFFFF',
      stroke: '#6B7280',
      dash: '5 4',
    );
    c.text('QR CODE', 195, 328, size: 15, weight: 700, anchor: 'middle');
    c.text(
      'Show this code at the theatre entrance.',
      195,
      439,
      size: 11,
      anchor: 'middle',
    );
    c.card(468, 156);
    c.label('BOOKING REFERENCE', 40, 494);
    c.text('STB-20260927-65044', 40, 520, size: 16, weight: 700);
    c.text('Hamlet · Sun 27 Sep · 7:30 PM', 40, 555, size: 12);
    c.text('Seats C4, C5', 40, 580, size: 12);
    c.text('Paid with card ending 1111', 40, 605, size: 12);
    c.button('View bookings', 654);
    c.button('Back to home', 714, primary: false);
  }),
  ScreenSpec('13-bookings', 'Bookings', (c) {
    c.title('Bookings', y: 84);
    c.pill('Upcoming', 24, 112, 102, selected: true);
    c.pill('Past', 134, 112, 76);
    c.pill('Cancelled', 218, 112, 100);
    for (var i = 0; i < 2; i++) {
      final y = 168.0 + i * 230;
      c.card(y, 206);
      c.rect(
        38,
        y + 20,
        84,
        84,
        radius: 8,
        fill: '#FFFFFF',
        stroke: '#6B7280',
        dash: '4 3',
      );
      c.text('QR', 80, y + 69, size: 14, weight: 700, anchor: 'middle');
      c.pill('CONFIRMED', 140, y + 20, 100, selected: true);
      c.text('Hamlet', 140, y + 72, size: 19, weight: 700);
      c.text('27 Sep 2026 · 7:30 PM', 140, y + 98, size: 12);
      c.divider(y + 124);
      c.label('BOOKING REF', 40, y + 150);
      c.text('STB-20260927-65044', 40, y + 175, size: 12, weight: 600);
      c.text(
        'LKR 2,700  ›',
        350,
        y + 175,
        size: 12,
        weight: 700,
        anchor: 'end',
      );
    }
    c.nav(2);
  }),
  ScreenSpec('14-booking-details', 'Ticket details', (c) {
    c.topBar('Ticket details');
    c.rect(
      105,
      118,
      180,
      180,
      radius: 12,
      fill: '#FFFFFF',
      stroke: '#6B7280',
      dash: '5 4',
    );
    c.text('QR CODE', 195, 217, size: 15, weight: 700, anchor: 'middle');
    c.text(
      'Show this code at the entrance.',
      195,
      324,
      size: 11,
      anchor: 'middle',
    );
    c.card(352, 142);
    c.text('Hamlet', 40, 382, size: 20, weight: 700);
    c.text('Sun 27 Sep 2026 · 7:30 PM', 40, 409, size: 12);
    c.label('BOOKING REFERENCE', 40, 443);
    c.text('STB-20260927-65044', 40, 470, size: 14, weight: 700);
    c.text('Seats', 24, 535, size: 18, weight: 700);
    c.listTile(
      'C4, C5',
      'Circle Mid · 2 tickets',
      550,
      icon: '▱',
      chevron: false,
    );
    c.text('Total paid', 24, 658, size: 13);
    c.text('LKR 2,700', 366, 658, size: 16, weight: 700, anchor: 'end');
    c.text('Card ending 1111', 24, 684, size: 12, fill: '#4B5563');
    c.button('Cancel booking', 722, primary: false);
  }),
  ScreenSpec('15-profile', 'Profile', (c) {
    c.title('Profile', y: 84);
    c.card(110, 120);
    c.circle(68, 162, 30, fill: '#E5E7EB');
    c.text('H', 68, 171, size: 24, weight: 700, anchor: 'middle');
    c.text('Haritha', 116, 151, size: 19, weight: 700);
    c.text('name@example.com', 116, 176, size: 12, fill: '#4B5563');
    c.pill('LOYALTY MEMBER', 116, 190, 118, selected: true);
    c.text('Membership', 24, 273, size: 13, weight: 700, fill: '#4B5563');
    c.listTile('Loyalty membership', 'Active · View benefits', 288, icon: '★');
    c.text('Preferences', 24, 385, size: 13, weight: 700, fill: '#4B5563');
    c.listTile('Theme', 'System default', 400, icon: '◐');
    c.listTile('Language', 'English', 472, icon: 'A');
    c.listTile('More', 'Privacy, terms and support', 544, icon: '⋯');
    c.button('Sign out', 650, primary: false);
    c.nav(3);
  }),
  ScreenSpec('16-loyalty', 'Loyalty membership', (c) {
    c.topBar('Loyalty membership');
    c.card(118, 150, fill: '#F3F4F6');
    c.text('★', 48, 158, size: 30, anchor: 'middle');
    c.text('Theatre Loyalty', 78, 152, size: 20, weight: 700);
    c.pill('NOT ENROLLED', 78, 170, 108);
    c.text('Join to unlock member pricing and', 40, 222, size: 12);
    c.text('priority access to new productions.', 40, 243, size: 12);
    c.text('Member benefits', 24, 314, size: 20, weight: 700);
    c.listTile(
      '10% off every ticket',
      'Applied automatically at checkout',
      334,
      icon: '%',
      chevron: false,
    );
    c.listTile(
      'Seven-day early access',
      'Book before general release',
      408,
      icon: '◷',
      chevron: false,
    );
    c.listTile(
      'Membership badge',
      'Visible on your dashboard',
      482,
      icon: '★',
      chevron: false,
    );
    c.button('Enroll as a loyalty member', 604);
    c.text(
      'Enrollment will be available soon.',
      195,
      676,
      size: 11,
      anchor: 'middle',
      fill: '#6B7280',
    );
  }),
  ScreenSpec('17-theme', 'Theme settings', (c) {
    c.topBar('Theme');
    c.card(120, 154);
    c.text('Theme mode', 40, 153, size: 15, weight: 700);
    c.text('Follow system appearance', 40, 178, size: 12, fill: '#4B5563');
    c.rect(294, 137, 54, 30, radius: 15, fill: '#D1D5DB', stroke: '#9CA3AF');
    c.circle(331, 152, 11, fill: '#FFFFFF');
    c.divider(202);
    c.text('Colour palette', 40, 236, size: 15, weight: 700);
    c.text('Theatre rose', 40, 259, size: 12, fill: '#4B5563');
    c.text('›', 338, 247, size: 24, fill: '#6B7280');
    c.text('Preview', 24, 326, size: 18, weight: 700);
    c.card(348, 190, fill: '#F3F4F6');
    c.text('Sample production', 42, 385, size: 18, weight: 700);
    c.text('This card previews your selected theme.', 42, 412, size: 12);
    c.button('Primary action', 456, x: 42, width: 160);
    c.button('Secondary', 456, primary: false, x: 214, width: 132);
  }),
  ScreenSpec('18-language', 'Language settings', (c) {
    c.topBar('Language');
    c.card(120, 220);
    c.text('App language', 40, 153, size: 16, weight: 700);
    c.text('●', 48, 205, size: 14);
    c.text('English', 76, 205, size: 14, weight: 600);
    c.divider(226);
    c.text('○', 48, 267, size: 14);
    c.text('සිංහල', 76, 267, size: 14, weight: 600);
    c.divider(288);
    c.text('○', 48, 329, size: 14);
    c.text('தமிழ்', 76, 329, size: 14, weight: 600);
    c.text(
      'The interface updates immediately when you',
      24,
      388,
      size: 12,
      fill: '#4B5563',
    );
    c.text('select a language.', 24, 410, size: 12, fill: '#4B5563');
  }),
  ScreenSpec('19-more', 'More', (c) {
    c.topBar('More');
    c.listTile(
      'Privacy policy',
      'Read how your information is handled',
      120,
      icon: '◉',
    );
    c.listTile(
      'Terms & conditions',
      'Review the platform terms',
      194,
      icon: '≡',
    );
    c.listTile(
      'Manage my data',
      'Account and privacy controls',
      268,
      icon: '⌘',
    );
    c.listTile('Help & support', 'Get assistance', 342, icon: '?');
    c.listTile('About us', 'Theatre platform information', 416, icon: 'i');
    c.text(
      'App version 1.0.0',
      195,
      538,
      size: 11,
      anchor: 'middle',
      fill: '#6B7280',
    );
  }),
];
