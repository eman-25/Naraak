# Naraak

Naraak is a Flutter primary healthcare portal demo for Bahrain. It includes a complete mobile/web-ready shell, profile onboarding, appointments, service routing, mock data providers, Arabic/English localization, and light/dark themes.

## Run

```bash
flutter pub get
flutter run
```

For a browser demo:

```bash
flutter run -d chrome
```

Validate the project with:

```bash
flutter analyze
flutter test
```

## Demo flow

1. Enter any CPR number with at least nine digits on the demo login screen.
2. Complete the profile form.
3. Explore the dashboard, services, appointments, and profile tabs.
4. Use Profile to switch between light/dark mode or English/Arabic.
5. API-dependent services expose a working `Start Service` action and explain that an external API connection is required.

## Architecture

- `lib/screens`: feature screens and service routes
- `lib/widgets`: reusable cards, buttons, empty states, status badges, and API notices
- `lib/models`: API-shaped domain models
- `lib/providers`: session and feature state using Provider
- `lib/services_mock`: replaceable mock service implementations
- `lib/theme`: shared design tokens and light/dark themes
- `lib/localization`: maintainable English and Arabic string tables
- `lib/routes`: named service routes

The mock services intentionally keep the UI runnable without credentials or a backend. Replace the implementations under `lib/services_mock` with repository/API clients when the production contracts are available.
