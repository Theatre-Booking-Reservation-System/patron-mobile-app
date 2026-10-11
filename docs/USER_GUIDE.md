# Sapumal Theatre — Patron Mobile App User Guide

**Edition:** Current prototype · **Updated:** 1 October 2026  
**Audience:** Patrons browsing theatre productions and trying the ticket booking journey.

## 1. Before you begin

Sapumal Theatre lets you explore productions, choose a performance and seats, complete a demonstration booking, and view booking references. This guide uses the English screen labels. The app also supports Sinhala and Tamil, although some screens still contain English text.

Open the app installed or provided by your project or theatre representative. This guide starts from the welcome screen; it does not assume an App Store or Google Play release.

**This version is a prototype.** Accounts, loyalty linking, seat availability, and payments are simulated. A booking confirmation demonstrates the journey and is not a real theatre ticket. Do not enter real card details. For demonstrations, use fictional contact and identity details. Verification emails are not sent in this version.

## 2. Quick start

1. Open the app and tap **Get started**.
2. Sign in, or tap **Continue as guest** to explore first.
3. Open **Shows**, find a production, and tap it.
4. Choose a performance. Sign in if prompted, then reopen the production and choose the performance again.
5. Select available seats and tap **Continue**.
6. Complete **Passenger Details** and tap **Continue to Summary**.
7. Review the booking, tick the consent box, and tap **Proceed to Checkout**.
8. Enter the card details and tap **Pay Now**.
9. Save the displayed booking reference and tap **View My Bookings**.

## 3. Accessing the app

### Browse as a guest

From the welcome screen, tap **Get started** or **I already have an account** to open the sign-in screen. Tap **Continue as guest**.

Guests can explore Home, Shows, production details, and the seat map. Tapping a seat asks you to sign in before a seat can be reserved. The app does not automatically resume the selected performance after sign-in; navigate back to it.

In the guest **Profile** screen, choose **Create Account**, **Login**, or **Continue browsing**. **End guest session** returns you to the welcome screen.

### Create an account

1. On the sign-in screen, tap **Create an account**.
2. Enter your full name, email address, and phone number.
3. Tap **Date of birth** and select your date. On an iOS date picker, tap **Done** to confirm.
4. Enter your NIC or passport number.
5. Tap **Continue**.
6. Enter and confirm a password containing at least **12 characters**, including an uppercase letter, a lowercase letter, a number, and a special character.
7. Tick both **I accept the Terms & Conditions** and **I acknowledge the Privacy Notice**.
8. Tap **Create account**.
9. When **Account created** appears, tap **Return to login** and sign in.

Correct any message displayed under a field before continuing. The eye icon beside a password shows or hides what you typed.

Registration is a demonstration. It does not create a backend account or send an email. The current sign-in accepts any correctly formatted email address and a password meeting the rules above. For example, `patron@example.com` and `TheatreDemo1!` can be used for a demonstration; do not reuse that example password for a real account.

### Sign in and sign out

Enter your email and password, then tap **Sign in**. A successful sign-in opens Home. The app attempts to remember your signed-in session when you reopen it. To sign out, open **Profile** and tap **Logout**.

## 4. Finding your way around

Tap a bottom navigation item, or swipe horizontally between the four main pages.

| Page | What you can do |
|---|---|
| **Home** | Explore featured productions and today's shows, and use shortcuts to Shows, Bookings, and Profile. |
| **Shows** | Search productions and filter by production language or performance date. |
| **Bookings** | View demonstration bookings and find one using its reference and contact email. |
| **Profile** | View your displayed identity, link demo loyalty membership, change language or appearance, and log out. |

On booking and settings screens, use the back arrow or your device's back control to return to the previous screen.

## 5. Finding a production and performance

1. Open **Shows**.
2. Type in **Search productions** to narrow the list. Use the clear icon to remove your search text.
3. Choose **All**, **Sinhala**, **Tamil**, or **English** to filter productions. This changes the programme results, not the app's interface language.
4. Tap **Date** or the calendar icon to choose a performance date. Confirm the selection in the date picker.
5. Tap a production card to open its details.
6. Read the description and review the listed performance dates, times, and sessions.
7. Tap the performance you want to attend.

If no productions match, tap **Clear filters** to reset the search and filters. You can also open productions from Home. A **Book Tickets** action on Home leads into the production's details, where you choose a performance.

Performances marked **Poya day - closed** cannot be selected. Some performances are available only to loyalty members during early access. If the app displays a loyalty-only message, open Profile to view loyalty options or choose another performance. Early access is presented as seven days earlier for loyalty members in this prototype.

## 6. Selecting seats

1. On **Select Seats**, choose **Stalls**, **Circle**, or **Upper Circle**.
2. Use the **STAGE** marker to orient yourself on the seating plan.
3. Tap an available seat to select it. Tap it again to remove it.
4. Repeat for everyone in your party. You can change sections while choosing seats.
5. Check the selected-seat count, displayed amount, and hold countdown.
6. Tap **Continue** when you have selected at least one seat.

Use the on-screen legend to identify seat states rather than relying on colour alone.

| Seat indicator | Meaning |
|---|---|
| **Available** | You can select this seat. |
| **Selected** | You have chosen this seat. Tap it again to deselect it. |
| **Booked** | The seat cannot be selected. |
| **Held** | The seat is temporarily held and cannot be selected. |
| **Unavailable** | The seat cannot be selected. |
| **Accessible seat** | The seat is marked as accessible. Its availability state still determines whether you can select it. |

The seat-selection screen starts with a **15-minute** demonstration countdown when seats are selected; changing the selection resets it. If the hold expires on this screen, the app clears your selection and asks you to select seats again. The displayed hold is a prototype timer and does not reserve inventory in a live theatre system.

Seat prices vary by production, section, seat zone, and performance session. Review **Total payable** on the summary before proceeding.

## 7. Completing your booking

### Enter contact and concession details

The **Passenger Details** screen collects the booking contact's information; it does not ask for a separate passenger form for every seat.

1. Check **Full name**, **Email**, and **Phone number**. Replace any demonstration or prefilled values as needed.
2. Choose a concession if applicable: **None**, **Under 16**, **Over 70**, or **Large party (11+)**.
3. If you choose a concession, enter a NIC or passport number in the additional field. This field requires at least eight characters in the current prototype.
4. For **Large party (11+)**, select at least 11 seats before continuing.
5. Tap **Continue to Summary**.

Concession bookings are flagged for identity and eligibility checks at the box office on the performance day. The displayed VAT and concession settings are prototype values pending backend confirmation.

### Review the summary

Check the production, performance date and time, seat numbers and zones, individual ticket amounts, loyalty discount, VAT, and **Total payable**. Use the back control to correct contact or seat choices before paying.

Tick **I accept the Terms and Conditions and acknowledge the Privacy Notice** to enable **Proceed to Checkout**, then tap it.

### Make a demonstration payment

The Payment screen displays **Amount to pay**, **Card payment**, and the card detail fields. **Mobile payment** and **Internet banking** are disabled. Do not enter real card details.

Enter the card details and tap **Pay Now**. Wait for **Booking Confirmed!**.

### Save the confirmation

The confirmation shows your booking reference, production, seats, and total. Select or copy the reference for later lookup. If a verification flag appears, review the concession verification notice.

Tap **View My Bookings** to open the booking list, or **Back to Home** to continue exploring. This version does not provide downloadable tickets, QR codes, or emailed receipts.

## 8. Viewing and finding bookings

Open **Bookings** and choose **Upcoming** or **Past**. Each booking card shows the production, performance date and time, seats, reference, and confirmation status.

In this prototype, confirmed bookings appear under Upcoming. The Past list uses booking status rather than automatically moving bookings when their performance date passes.

To find a booking:

1. Tap **Find a booking**.
2. Enter the booking reference and the email used in **Passenger Details**.
3. Tap **Search**.
4. A matching production title appears in the dialog. If there is no match, check both values and search again.

Bookings are kept only for the current app run and may disappear after the app restarts. They are demonstration records and are not isolated by signed-in account. This version does not provide booking cancellation, seat changes after confirmation, or refunds.

## 9. Loyalty, language, and appearance

### Demo loyalty membership

Sign in, open **Profile**, and tap **Loyalty Card**. The app displays **Mock loyalty membership linked** and marks your profile as a loyalty member. This is a demo action; it does not validate a real card or ask for a card number.

Linked membership enables loyalty-only performances and a 10% loyalty discount in the prototype pricing flow. Link membership before starting your booking, then check the applied discount in Booking Summary.

### Interface language

Open **Profile → Language** and select English, Sinhala, or Tamil. The choice is saved on your device. Some prototype text remains in English. Use the production-language filters in Shows separately when looking for performances in a particular language.

### Theme

Open **Profile → Theme**. Toggle **Brightness** between Light and Dark. Tap **Brand colour palette** to cycle through Burgundy, Midnight, and Emerald. Your appearance choices are saved on the device.

## 10. Troubleshooting and current limits

| What you see | What to do |
|---|---|
| A sign-in or registration field error | Correct the highlighted field. Check the email format and all password requirements. |
| Registration will not continue | Complete the date of birth and required identity details; on the security step, confirm the password and tick both consent boxes. |
| No matching shows | Clear the search and filters, or choose another date or production language. |
| A loyalty-only message | Link demo loyalty membership in Profile before booking, or choose another performance. |
| A seat cannot be selected | Use a seat marked Available; Booked, Held, and Unavailable seats cannot be chosen. |
| Continue is disabled on seat selection | Select at least one available seat. |
| Your seat hold expired | Select your seats again. |
| Large-party concession error | Select at least 11 seats or choose another concession. |
| Proceed to Checkout is disabled | Tick the Terms and Conditions / Privacy Notice consent box. |
| Payment was declined | Check the card details and tap Retry. |
| No matching booking was found | Check the reference and booking contact email. A previous app run's booking may no longer exist. |
| Shows or Home displays a loading error | Use Retry where shown. If using a connected build, check your connection. |

Some visible controls are placeholders. **My Profile**, **Payment Methods**, and **Help & Support** in Profile do not yet open working management or support screens. **About Us** opens a screen with Sapumal Theatre's published story, mission, stage figures, and values. Notification and favourite controls also have no implemented action. Share on a production asks for contacts access, then sends a screenshot of the production details to a contact by message or email. The back, share, and favourite buttons are left out of that screenshot. Legal and information content is marked as prototype copy where presented. Password recovery, real loyalty validation, real payments, and a live support contact are not provided by this version.

For help with a demonstration build, contact the person or team who supplied it. Keep your booking reference and a description of the screen or message available when reporting a problem.
