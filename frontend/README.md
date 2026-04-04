# Synaxis — Flutter client

Mobile-first client for the Synaxis game platform. See repo docs: `docs/synaxis_frontend_dds.md`, `docs/synaxis_frontend_master_build_plan.md`.

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable), Dart SDK as bundled.

## Run locally

```bash
cd frontend
flutter pub get
flutter run
```

## CI checks (run before pushing / opening a PR)

From the `frontend` directory (mirrors **FE-001.5** / GitHub Actions):

**Bash**

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

**PowerShell (Windows)**

```powershell
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

The same steps run in GitHub Actions (`.github/workflows/flutter_ci.yml`) when `frontend/**` or the workflow file changes.

## Configuration

- REST / WebSocket base URLs: `lib/core/config/app_config.dart` (defaults for Android emulator). Override at build time, e.g.  
  `--dart-define=SYNAXIS_BASE_URL=http://192.168.1.10:8080 --dart-define=SYNAXIS_WS_URL=ws://192.168.1.10:8080/ws`

## Getting started with Flutter

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Flutter documentation](https://docs.flutter.dev/)
