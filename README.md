# Agnambie — Gabon

An offline-friendly audio Bible app for Gabon, built on top of the
[Bible Brain](https://www.faithcomesbyhearing.com/bible-brain/api-reference) API (Digital Bible Platform v4).
Users browse by language — Fang, Myene, French, and more — pick a translation, then stream
or download audio chapters for listening without a reliable connection.

This is not a general-purpose Bible app. It is deliberately scoped to Gabon: one country,
a fixed set of languages, and a UI that never asks the user to think about anywhere else.
That scoping is enforced in the code, not just the design — see
[Why Gabon-only](#why-gabon-only-and-why-its-enforced-in-code) below.

> **Performance first.** The app is built for African networks — low bandwidth, intermittent
> connectivity, and shared mobile data plans. Every architectural decision reflects this.

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [How it Works — End-to-End Flow](#how-it-works--end-to-end-flow)
3. [Tech Stack](#tech-stack)
4. [Architecture](#architecture)
5. [Why Gabon-only](#why-gabon-only-and-why-its-enforced-in-code)
6. [Backend Proxy & Low-Bandwidth Optimisations](#backend-proxy--low-bandwidth-optimisations)
7. [Adding a Second API](#adding-a-second-api-for-additional-languages)
8. [Open Questions](#open-questions)

---

## Getting Started

### Prerequisites

| Tool | Version |
|---|---|
| Flutter | 3.32+ (`flutter --version`) |
| Dart | 3.13+ (included with Flutter) |
| Xcode | 16+ (for iOS) |
| Android Studio / SDK | API 21+ target |
| Go backend | Running locally on port `8080` — see [`agnambie-backend/README.md`](../agnambie-backend/README.md) |

### 1 — Start the backend

The Flutter app talks to a local Go proxy, **not** to Bible Brain directly. The backend must
be running before the app can fetch any data.

```bash
cd ../agnambie-backend
make run          # starts on http://localhost:8080
```

See [`agnambie-backend/README.md`](../agnambie-backend/README.md) for full setup including
Redis and the required `BIBLE_BRAIN_API_KEY` environment variable.

### 2 — Install Flutter dependencies

```bash
cd agnambie
flutter pub get
```

### 3 — Run the app

```bash
# iOS Simulator (backend at localhost:8080)
flutter run

# Android Emulator (backend reachable at 10.0.2.2:8080 — handled automatically in api_client.dart)
flutter run

# Specific device
flutter run -d <device-id>
```

> **Backend URL resolution:** `ApiClient` in `lib/core/network/api_client.dart` resolves
> the base URL in the following priority order:
> 1. `--dart-define=API_BASE_URL=https://api.yourdomain.com` (Production cloud backend)
> 2. Android Emulator fallback → `http://10.0.2.2:8080`
> 3. iOS Simulator / desktop fallback → `http://localhost:8080`

### 4 — Building for Android Release

```bash
# Direct APK (for testing, distribution via website, or offline Xender/Bluetooth sharing)
flutter build apk --release --dart-define=API_BASE_URL=https://api.yourdomain.com

# Android App Bundle (for Google Play submission)
flutter build appbundle --release --dart-define=API_BASE_URL=https://api.yourdomain.com
```

#### Release Keystore Signing
To sign release builds:
1. Generate an upload keystore:
   ```bash
   keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Copy `android/key.properties.example` to `android/key.properties` and fill in your passwords and file path.
3. If `key.properties` is omitted, release builds automatically fall back to debug signing for testing.

### Environment

The `.env` file in this folder is **not used by Flutter at runtime** — Dart does not load
`.env` files automatically. It exists as a local note for development references. All runtime
configuration for the app is either hardcoded constants (`core/constants/`) or Hive-persisted
user settings (`features/settings/`).

---

## How it Works — End-to-End Flow

This traces exactly what happens when a user opens the app and plays a Bible chapter.

### App startup (`main.dart`)

```
1. WidgetsFlutterBinding.ensureInitialized()
2. Hive.initFlutter()              → opens local storage for settings + download records
3. ApiClient.init()                → configures Dio with base URL, ETag cache, Save-Data header
4. AudioService.init(AppAudioHandler) → registers background audio + lock-screen controls
5. runApp(ProviderScope(...))      → boots Riverpod dependency injection
```

### Browsing to a chapter

```
HomeScreen
  └─ watches languagesProvider (FutureProvider)
       └─ calls CatalogRepository.getLanguages()
            └─ calls SourceRegistry.sourceFor(iso)   → returns BibleBrainSource
                 └─ calls BibleBrainSource.getLanguages()
                      └─ GET /api/languages  →  agnambie-backend  →  Bible Brain API
                           └─ returns List<Language>

User taps a language  →  TranslationsScreen(language)
  └─ watches biblesProvider(language.code)
       └─ calls CatalogRepository.getBiblesForLanguage(iso)
            └─ GET /api/bibles?language_code=FAN  →  backend  →  Bible Brain

User taps a Bible  →  BooksScreen(bible)
  └─ watches booksProvider(BooksRequest)
       └─ calls CatalogRepository.getBooks(bibleId)
            └─ GET /api/books?bible_id=FANBSG  →  backend  →  Bible Brain
```

### Playing a chapter

```
User taps a chapter in BooksScreen
  └─ BookRow._playChapter(context, ref, chapter)
       1. BibleEditionFileset.getBestFilesetId(book)
          → Scans bible.filesets, matches OT/NT/Complete (O/N/C at index 5 of fileset ID)
          → Prefers opus16 format if available
          → Returns the best fileset ID string (e.g., "FANBSGN2DA")

       2. PlayerController.playChapter(languageIso, bibleId, filesetId, bookId, chapter)
          → Updates TrackMetadata state immediately (MiniPlayer appears at once)
          → Calls PlayerRepository.playChapter(...)
               └─ GET /api/audio?fileset_id=FANBSGN2DA&book=MAT&chapter=1
                    └─ backend returns { data: [{ path: "https://cdn.../file.mp3" }] }
               └─ AudioPlayer.setUrl(path)  →  just_audio begins buffering
               └─ AudioPlayer.play()

       3. Navigator.push(PlayerScreen)  →  full-screen player opens
```

### What the player displays

```
PlayerScreen
  ├─ TrackInfo      → reads TrackMetadata from playerControllerProvider
  ├─ SeekBar        → StreamBuilder on player.positionStream
  └─ PlaybackControls → StreamBuilder on player.playerStateStream
```

### Downloading a chapter

```
User taps ↓ download icon on a BookRow
  └─ showDownloadSheet(context, bible, book, filesetId)
       └─ User taps "Télécharger tout le livre"
            1. Checks wifiOnlyModeProvider → if enabled, checks ConnectivityResult.wifi
            2. For each chapter:
                 a. CatalogRepository.getChapterAudioUrl(...)  → CDN URL
                 b. DownloadRepository.downloadChapter(url, bibleId, bookId, chapter)
                      → Downloads .mp3 to app documents directory via Dio
                      → Saves Download record to Hive box "downloads"
```

---

## Tech Stack

| Concern | Package | Why |
|---|---|---|
| State management | `flutter_riverpod` | Testable outside widgets; no `BuildContext` needed in repositories |
| Networking | `dio` + `dio_cache_interceptor` | Interceptors, ETag caching, typed errors, easy to mock |
| Audio playback | `just_audio` + `audio_service` | Single API for streamed and downloaded playback; background & lock-screen controls |
| Offline storage | `hive` | Tracks downloaded chapters and user settings |
| File storage | `path_provider` | Resolves platform-correct paths for downloaded audio files |
| Connectivity | `connectivity_plus` | Enforces the Wi-Fi-only download setting |

---

## Architecture

Screens never talk to the network directly. They ask a **repository** for data. The repository
asks a **source** (an implementation of `BibleAudioSource`) to actually fetch it, and a
**registry** decides which source handles which language. Right now there is exactly one
source — Bible Brain — but the seam exists on day one so that adding a second provider for a
language Bible Brain doesn't cover is a new file, not a rewrite.

```
Screen (widget)
   ↓  watches a Riverpod provider
CatalogRepository       ← app-specific rules (Gabon scoping, fileset resolution)
   ↓  asks
SourceRegistry          ← "which API handles this language?"
   ↓  routes to
BibleAudioSource        ← abstract interface
   ↓  implemented by
BibleBrainSource        ← knows nothing except "call this URL, parse this JSON"
   ↓  calls
agnambie-backend        ← Go proxy; holds the API key, never shipped in the app
   ↓  calls
Bible Brain API (4.dbt.io)
```

For a full breakdown of every folder and file — what each is responsible for, what it must
never contain, and what it depends on — see [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md).

---

## Why Gabon-only, and why it's enforced in code

Bible Brain has no concept of "this Bible belongs to this country." A French Bible is just
tagged as French — shared by half of Central Africa. Scoping to Gabon is a decision this app
makes and enforces itself, in exactly one place: [`core/constants/gabon.dart`](lib/core/constants/gabon.dart).

Every other file that touches "which languages exist" reads from that one list. This means:

- Adding a language is a one-line change to `gabon.dart`.
- The scoping can't silently drift out of sync between the UI and the data layer, because
  there is only one list to drift from.

The Go backend also enforces the allowlist server-side, preventing modified clients from
downloading out-of-scope content.

---

## Backend Proxy & Low-Bandwidth Optimisations

The Bible Brain API key is **never shipped inside the Flutter app**. A Go backend proxy
(`agnambie-backend`) holds the key and safely re-exposes the necessary routes.

The proxy is also purpose-built for low-bandwidth Africa:

| Optimisation | How it works |
|---|---|
| **ETag / 304 caching** | Catalog responses include an `ETag`. The app sends `If-None-Match` on repeat calls; a `304 Not Modified` saves 100% of payload bandwidth when nothing changed. Handled automatically by `dio_cache_interceptor` in `ApiClient`. |
| **Opus16 (data saver)** | When the user enables Low Data Mode, Hive persists the setting. `ApiClient` reads it and sends `Save-Data: on`. The backend automatically selects the smallest `opus16` fileset for audio. |
| **Gzip compression** | All JSON responses are gzip-compressed (~70–80% size reduction). Dio accepts gzip by default. |
| **Offline downloads** | CDN audio URLs are temporary. The app downloads the actual `.mp3`/`.opus` file to device storage via `path_provider` and tracks it in Hive box `"downloads"`. Never cache the URL itself. |

---

## Adding a Second API for Additional Languages

If a language needs audio from somewhere other than Bible Brain:

1. Create `data/sources/<provider>_source.dart` implementing `BibleAudioSource`.
2. Register it for the relevant language(s) in `source_registry.dart`.
3. Nothing else changes — `CatalogRepository`, every screen, and every widget continue calling
   the same methods. They have no idea a second API exists.

See [`source_registry.dart`](lib/data/sources/source_registry.dart) for the exact pattern.

---

## Open Questions

| Question | Status |
|---|---|
| Myene's exact ISO code on Bible Brain (`mnb` used as placeholder) | Needs confirming against a live `/languages?country=GA` call once the API key is approved |
| Whether Myene has any audio fileset at all | Minority-language coverage on Bible Brain is uneven; the app needs a real empty state, not a silent failure |
| Fileset licensing per edition | Some Bible editions restrict offline caching; check `fileset.type` restriction flags before assuming every book is downloadable |

See [ROADMAP.md](ROADMAP.md) for the build order.
