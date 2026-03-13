# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app (Android emulator or connected device)
flutter run

# Run on a specific device
flutter run -d <device-id>

# Build Android APK (debug)
flutter build apk --debug

# Analyze code (lint)
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart
```

## Architecture Overview

This is a Flutter personal finance management app (Vietnamese UI) using Material 3 design and the "6 Jars" budgeting concept.

### Entry & Navigation

- `lib/main.dart` — App entry point. Sets up `MaterialApp` with Nunito font (`google_fonts`), Material 3 theme (seed color `0xFF6200EA`), and named route navigation starting at `/login`.
- `lib/routes.dart` — Central route registry (`AppRoutes`). All screen routes are defined here as string constants and wired to their `WidgetBuilder`s in `define()`.

### Screen Organization

Screens live in `lib/screens/` organized by feature:

| Folder | Contents |
|---|---|
| `dashboard/` | `MainLayout` (bottom nav shell) + `HomeDashboardScreen` |
| `auth/` | Login, Register, Forgot/Change Password |
| `profile/` | View and edit user profile |
| `transaction/` | Add, list, detail, daily-detail views |
| `report/` | Statistics, calendar view, monthly/yearly summary |
| `goal/` | Financial goals list and progress |
| `category/` | Category management |
| `settings/` | Settings and About/Help |

`MainLayout` uses `IndexedStack` with a `NavigationBar` (4 tabs: Home, Transactions, Reports, Settings) and a centered FAB that navigates to `/add-transaction`.

### Data Layer

**Models** (`lib/models/`) all implement `fromJson`/`toJson`:
- `User` — id, fullName, email, phone, createdAt
- `Account` + `Jar` — Account holds total balance and a list of Jars; `Jar.type` is `'SPENDING'` or `'SAVING'`
- `TransactionModel` — amount, type (`'INCOME'`/`'EXPENSE'`), date, optional `Jar` and `Category`
- `Category` — name, type (`'INCOME'`/`'EXPENSE'`), icon, color
- `FinancialGoal` — name, targetAmount, currentAmount, deadline

**Services** (`lib/services/`) — `auth_service.dart`, `finance_service.dart`, `user_service.dart` are scaffolded but currently empty. API integration goes here.

**State Management** (`lib/state_management/`) — `auth_provider.dart` and `finance_provider.dart` are scaffolded but currently empty. No state management package has been added to `pubspec.yaml` yet; screens currently use hardcoded mock data.

### Current State

The UI shell is complete with mock data. The backend integration layer (services + providers) is the main area of active development. When adding state management, update `pubspec.yaml` and wire providers through the widget tree in `main.dart`.
