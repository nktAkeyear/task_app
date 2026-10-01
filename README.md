# Tas

Tas is an offline-first personal task app. One Flutter codebase targets Android and Windows. Linux is included so the UI can be run and tested on a Linux host. The app stores everything in a local SQLite database and does not need an account, a server, or a network.

The interface is Japanese. Code, identifiers, and this README are English.

## What it does

- Smart lists: 受信箱, 今日, 近日 (7 days), カレンダー, 完了, plus user lists (color, sort, archive, delete).
- Quick add with simple Japanese date phrases (今日, 明日, 来週, weekdays, times).
- Task detail: notes, due date and time, four priority levels, tags, checklist, recurrence (毎日 / 毎週 / 毎月 / 平日), reminder.
- Reorder, complete with undo, swipe on narrow layouts, desktop keyboard shortcuts.
- Search across title and notes.
- Create form (title, notes, due date and time, priority, list). Quick add still parses a title; the + action opens the form.
- Phone back follows the in-app stack (lists, today, calendar, tools, and the create form) and leaves the app only when that stack is empty.
- Offline tools, kept off the main three tabs: ポモドーロ (focus, short break, and long break minutes, optional task, finished-session count, remaining time on other screens), Eisenhower matrix (重要×緊急), daily habits (check, streak, last 7 days, color, archive, optional reminder), and one diary entry per day. They live in the same SQLite file and are not part of sync.
- Settings store the accent color, language (日本語, English, 한국어), home tab (default 今日), and pomodoro durations. On launch, and from settings, the app checks GitHub for a newer release when online and asks before downloading an APK.
- Light, dark, and system themes.
- In-app reminders. OS local notifications are attempted on Android and Windows when the plugin initializes.
- JSON export and import for a local backup.
- Optional batch sync. With no sync URL the app stays fully local and never errors on sync.

## Requirements

- Flutter 3.47 or newer (this tree was built with Flutter 3.47.5 / Dart 3.13).
- Android: Android SDK (the app module uses Flutter's default compileSdk). Release builds currently sign with the debug keystore; replace that before publishing.
- Windows: Visual Studio with the "Desktop development with C++" workload.
- Linux (dev): clang, cmake, ninja, gtk-3, sqlite3, and a CJK font such as Noto Sans CJK JP.

## Run

```bash
flutter pub get
dart run build_runner build
flutter run -d android
flutter run -d windows
flutter run -d linux
```

`build_runner` regenerates `lib/data/tas_database.g.dart` after schema changes. The generated file is committed, so a normal run does not need it.

Release builds:

```bash
flutter build apk
flutter build windows
flutter build linux
```

The Android Gradle wrapper is ignored by the Flutter template. `flutter build apk` / `flutter run -d android` recreates it.

## Data

SQLite via drift, file `tas.sqlite` in the application support directory. Every edit is written locally before any sync attempt.

## Optional sync

The phone or desktop app does not start the server and does not require it. Settings can set or clear a base URL. An empty URL keeps the outbox on device and shows a local-only message.

```bash
dart run bin/tas_sync_server.dart --host 127.0.0.1 --port 8787 --data tas-sync.json
```

Health check: `GET /health`. Sync: `POST /v1/sync` with `{deviceId, cursor, ops}` and a response `{cursor, acked, ops}`. There is no authentication. Bind it to localhost unless you trust the network.

Conflict policy, applied per entity:

- Each field carries a hybrid logical clock `(physical, logical, deviceId)`.
- Non-overlapping fields merge.
- For two updates of the same field, the higher clock wins: physical time, then the logical counter, then device id.
- A delete is a tombstone and does not discard field values. A field edit does not clear the tombstone or resurrect the entity. The entity is deleted whenever `deletedHlc` is set.
- A restore is explicit. It clears the tombstone only when its restore clock is strictly newer than the delete, using the same clock order. An ordinary field edit is not a restore. Undo after delete writes that restore and syncs it.
- Two delete clocks, or two restore clocks, keep the higher clock.
- Push the outbox and pull changes since a cursor. Operations are idempotent and safe to retry.

## Tests

```bash
flutter analyze
flutter test
```

## Notifications

The in-app scheduler polls while Tas is running and shows a banner. `flutter_local_notifications` also calls `show` at that moment, and on Android and Windows it attempts `zonedSchedule` when the local IANA timezone name resolves. Delivery after the process has exited was not verified in this environment. Linux uses the in-app banner only.

## Android に入れる

1. `tas-release.apk` をダウンロードする。
2. ブラウザからのインストールを許可する。
3. Tas を開く。
4. アプリ一覧で Tas を長押しし、ホーム画面に追加する。

この APK はデバッグキーストアで署名してある。同じ鍵の新しいビルドを入れると、今のインストールを上書きする。

## Not verified on the Linux VM that produced this tree

- `flutter build windows` (no Windows toolchain).
- OS notification delivery on Android and Windows, including alarms after the process exits.
