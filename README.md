# Patron Mobile App

Flutter patron application for the Sapumal Theatre booking system.

## Backend configuration

The shared backend host and service prefixes are defined in
`lib/core/config/api_config.dart`. Change `ApiConfig.baseUrl` when the backend
host changes; feature code must not contain hard-coded service hosts.

The app integrates the backend's Identity, Catalogue, Seat, and Booking
services through a shared Dio client. JWT access tokens are stored using
`flutter_secure_storage` and attached automatically to authenticated requests.

Payments are intentionally simulated. A successful simulation submits the
booking to the Booking service with an opaque simulated payment token.

The current course backend uses HTTP. Android and iOS therefore contain
host-specific cleartext exceptions for the configured EC2 hostname. Remove
those exceptions when HTTPS is available.

## Tests

Widget tests select deterministic local adapters with:

```dart
await configureDependencies(useMockData: true);
```

Normal application startup uses the remote API adapters.

Run verification with:

```sh
flutter analyze
flutter test
```
