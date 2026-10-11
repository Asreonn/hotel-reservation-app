# Hotel reservation app (StayBook)

A Flutter hotel booking app with demo data: browse hotels, compare room types and manage your reservations. Coursework / example project; the UI is in Turkish.

> **Status:** Archived. Example project, first files from December 2024, finished April 2026. About 4k lines of Dart, with a widget test.

<p>
  <img src="reports/Screenshot%20From%202026-04-15%2022-56-11.png" width="240" alt="Hotel list">
  <img src="reports/Screenshot%20From%202026-04-15%2022-56-18.png" width="240" alt="Hotel detail and rooms">
</p>

## Features

- Hotel list with search and filters, ratings and review counts.
- Hotel detail with photos, location tags and room variants (standard, deluxe, club) showing size, capacity and price.
- Booking flow (dates, guests, room choice) and a "My reservations" tab.
- State with `provider`; reservations persist locally with `shared_preferences`.
- Demo content in `lib/data/demo_content.dart` (no backend).

## Tech stack

Flutter (Dart), provider, shared_preferences.

## Run

```bash
flutter pub get
flutter run          # Android, iOS, Linux, macOS or web
flutter test
```

The project report (Turkish, LaTeX + PDF) is in `reports/`.
