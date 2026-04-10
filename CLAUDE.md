# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**GSN Control de Proyectos** is a Flutter web application for managing construction and software projects. It supports three roles: **admin**, **staff**, and **client**, each with different access levels and views.

Backend is **Supabase** (PostgreSQL + Auth). Frontend uses **Riverpod** for state management and **Go Router** for navigation.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run in development (Chrome)
flutter run -d chrome

# Build for production
flutter build web

# Lint analysis
flutter analyze

# Clean build artifacts
flutter clean
```

## Architecture

```
lib/
├── main.dart               # Entry point: Supabase init, Material theme, app root
├── models/                 # Plain Dart data classes (no logic)
├── services/               # Supabase API calls — one service per domain entity
├── providers/              # Riverpod providers bridging services → UI
│   ├── auth_provider.dart  # Auth state + current user role
│   ├── providers.dart      # Main FutureProviders for projects, inventory
│   └── services_providers.dart  # Service singletons as providers
├── router/
│   └── app_router.dart     # All routes + role-based redirect logic (GoRouter)
├── screens/                # Full-page UI screens
│   └── widgets/            # Screen-specific sub-widgets
├── widgets/                # Shared/reusable widgets
└── utils/                  # Colors (app_colors.dart), image helpers, RUT validation
```

**Data flow:** `Screen → Riverpod Provider → Service → Supabase`

Providers use `FutureProvider` and `StateNotifier`. After mutations, call `ref.invalidate(...)` on the relevant provider to refresh UI.

## Key Architectural Decisions

- **Supabase credentials** are hardcoded in `lib/main.dart` (lines 15–17). `flutter_dotenv` is imported but `.env` loading is commented out. Do not change this without confirming `.env` file is present at build time.
- **Role-based routing** is enforced in `router/app_router.dart`. The `redirect` callback reads from `authProvider` to gate routes by role (`admin`/`staff`/`client`).
- **Client Portal** (`client_portal_screen.dart`) is a restricted view — clients only see their own projects and can submit quotes.
- **Physical vs Software projects** are modeled as separate detail tables (`project_details_physical`, `project_details_software`) joined to the main `projects` table.
- **Responsive layout** is managed through `widgets/responsive_scaffold.dart`. The breakpoint for mobile is 600px.

## Database

Supabase project: `manvemwmogetigvawrmz.supabase.co`

Migration SQL files are in `docs/` (numbered `01_` through `16_`). Apply in order when setting up a new Supabase instance. The base schema is in `docs/supabase.sql`.

Key tables: `profiles`, `projects`, `project_details_physical`, `project_details_software`, `iterations`, `tasks`, `task_documents`, `project_documents`, `project_inventory`, `project_payments`, `project_members`, `quotes`, `inventory_catalog`, `product_categories`.

## Design System

GSN brand colors are defined in `utils/app_colors.dart`:
- Red: `#F52002`
- Blue: `#01A1DF`
- Dark Blue: `#0B1F38`

Font: Inter (Google Fonts). UI follows Material Design 3. Always use colors from `AppColors` — do not hardcode color values in screens.
