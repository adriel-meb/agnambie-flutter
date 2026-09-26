# Project Structure — Agnambie (Gabon)

Every folder and file in `lib/` explained: what it is responsible for, what it must
**never** contain, and what it depends on. Read alongside [`README.md`](README.md)
(architecture overview) and [`ROADMAP.md`](ROADMAP.md) (build order).

> **General rule:** a file should be explainable in one sentence. If you need "and"
> to describe it, it's doing too much and needs to split.

---

## `lib/main.dart`

**Responsibility:** application entry point — nothing else.

Wraps the app in a `ProviderScope` (Riverpod) and calls `runApp(App())`.
Should stay under ~15 lines. Any initialisation logic (Hive, ApiClient) belongs
in `app.dart` or a dedicated `core/` file.

**Depends on:** `app.dart`

---

## `lib/app.dart`

**Responsibility:** top-level app shell.

Sets up `MaterialApp`, wires `AppTheme.lightTheme` / `AppTheme.darkTheme` from
`core/constants/theme.dart`, and watches `themeModeProvider` for live theme switching.
Individual screens should never reach up into this file.

**Depends on:** `core/constants/theme.dart`, `features/*` screen widgets,
`features/settings/settings_providers.dart`

---

## `lib/core/`

Things every other layer depends on, but that don't themselves depend on anything else
inside the app. **Nothing in `core/` may import from `data/` or `features/`.**

### `core/constants/gabon.dart`

**Responsibility:** single source of truth for "what does this app support."

Contains the `Constants` class with the country flag, name, app title, and supported
language ISO codes. Every other file that needs to know which languages exist reads from
here. Nothing else hardcodes a language code.

**Why separate:** adding or fixing a language is a one-line change here, and the rest of
the codebase picks it up automatically.

**Depends on:** nothing  
**Depended on by:** `data/sources/source_registry.dart`,
`data/repositories/catalog_repository.dart`, `features/home/`, `features/books/`

### `core/constants/colors.dart`

**Responsibility:** the entire app colour palette in one place.

Exposes `AppColors` — all named `static const Color` values for both light and dark
modes (backgrounds, surfaces, text, borders, accent greens). No widget or theme file
should hardcode a hex value; they reference `AppColors` instead.

**Depends on:** nothing  
**Depended on by:** `core/constants/theme.dart`, `core/constants/typography.dart`

### `core/constants/typography.dart`

**Responsibility:** Google Fonts text theme builder.

Exposes `AppTypography.buildTextTheme({primaryText, mutedText})` — a single factory
that returns a fully configured `TextTheme` using Poppins. Called by `AppTheme` for
both light and dark variants.

**Depends on:** `core/constants/colors.dart`, `google_fonts`  
**Depended on by:** `core/constants/theme.dart`

### `core/constants/theme.dart`

**Responsibility:** assembles `ThemeData` for light and dark modes.

`AppTheme.lightTheme` and `AppTheme.darkTheme` are the only two public getters.
Everything they reference comes from `AppColors` and `AppTypography`; no magic
numbers or raw hex values live here.

Also re-exports `AppTheme.playerBackground` for the player screen's dark background.

**Depends on:** `core/constants/colors.dart`, `core/constants/typography.dart`  
**Depended on by:** `app.dart`

### `core/network/api_client.dart`

**Responsibility:** one configured `Dio` instance for the whole app.

Singleton initialised via `ApiClient.init()` (called from `main.dart` before `runApp`).
Base URL points at **the Go backend proxy** — never at `4.dbt.io` directly. Adds
interceptors for: request logging, ETag / `If-None-Match` cache headers, the
`Save-Data: on` low-data header (reads from Hive `settings_bools`), and typed
error transformation.

**Depends on:** `dio`, `dio_cache_interceptor`, `hive`  
**Depended on by:** `data/sources/bible_brain_source.dart`

### `core/network/api_exception.dart`

**Responsibility:** typed error hierarchy so callers can distinguish failure modes.

Defines `ApiException`, `NetworkException`, `ServerException`,
`NoAudioAvailableException`, and `DataParsingException`. Sources throw these;
repositories and UI can catch the specific type they care about, rather than
catching a generic `Exception`.

**Depends on:** nothing  
**Depended on by:** `data/sources/*`, `data/repositories/*`, error-state widgets

### `core/utils/book_names.dart`

**Responsibility:** maps USFM book IDs to human-readable display names.

`BookNames.getBestName(bookId, {apiName})` returns the most appropriate name —
falling back gracefully to the API-provided name if no local mapping exists.
Keeps all name logic out of the UI layer.

**Depends on:** nothing  
**Depended on by:** `features/books/`, `features/player/`, `lib/widgets/`

---

## `lib/data/`

Everything related to fetching, shaping, and persisting data. **No file in `data/`
may import from `features/`** — data flows one direction, outward to the UI.

### `data/models/`

Plain, immutable Dart classes representing the shapes of data the app works with.
Each API model has a `fromJson` factory; `download.dart` mirrors a row in the local
Hive database (not an API model).

| File | What it represents |
|---|---|
| `language.dart` | An ISO language entry (code, English name, native name, fileset list) |
| `bible_edition.dart` | A Bible translation with its audio filesets and abbreviation |
| `book.dart` | A book of the Bible — USFM ID, display name, testament, chapter list |
| `download.dart` | A local download record — file path, size, timestamp |

**Depends on:** nothing (pure Dart)  
**Depended on by:** everything downstream

### `data/sources/`

The layer that knows how to talk to specific external APIs. Built as a plugin point
from day one — today there is one source; the seam exists for a second.

| File | Responsibility |
|---|---|
| `bible_audio_source.dart` | Abstract interface: `getLanguages()`, `getBiblesForLanguage()`, `getBooks()`, `getChapterAudioUrl()` |
| `bible_brain_source.dart` | Concrete Bible Brain implementation. Unwraps the `{data, meta}` envelope; knows nothing about Gabon |
| `source_registry.dart` | Maps each ISO language code to the responsible `BibleAudioSource`. The only file that changes when a new API provider is added |

**Depends on:** `data/models/`, `core/network/`  
**Depended on by:** `data/repositories/catalog_repository.dart` only — screens never call a source directly

### `data/repositories/`

Where app-specific policy lives — rules that are true for *this app*, not for the API generally.

| File | Responsibility |
|---|---|
| `catalog_repository.dart` | What screens call. Asks the registry for the right source; applies Gabon-specific filtering |
| `download_repository.dart` | Local download management: save, list, delete (both DB row *and* file — not just one) |
| `player_repository.dart` | Wraps `just_audio` player; resolves whether to stream or play a local file |
| `audio_handler.dart` | `audio_service` background handler for lock-screen and notification controls |
| `providers.dart` | Global Riverpod providers for all repositories |

**Depends on:** `data/sources/` (catalog), `data/datasources/` (downloads), `data/models/`  
**Depended on by:** Riverpod providers in `features/*`

### `data/datasources/downloads_local.dart`

**Responsibility:** raw Hive database operations for the downloads table.

`HiveDownloadsLocalDataSource` implements `DownloadsLocalDataSource`. Only
`download_repository.dart` imports this file. If a screen ever needs to import it
directly, that's a sign a repository method is missing.

**Depends on:** `hive`, `data/models/download.dart`  
**Depended on by:** `data/repositories/download_repository.dart` only

---

## `lib/features/`

One folder per screen. Each folder contains the screen widget, its Riverpod providers,
and any widgets used **only** on that screen. A widget used on two or more screens
belongs in `lib/widgets/` instead.

### Standard folder layout

```
features/home/
├── home_screen.dart        the ConsumerWidget screen
├── home_providers.dart     Riverpod providers scoped to this screen
└── widgets/                widgets used only here
```

### Screens

| Folder | Screen purpose |
|---|---|
| `home/` | Featured section (À LA UNE) and language list (Fang / Myene / French / …) |
| `translations/` | Bible editions available for the selected language |
| `books/` | Books of the chosen Bible with chapter expansion and download affordance |
| `player/` | Full-screen audio player: artwork, seek bar, play/pause, skip |
| `offline/` | Downloaded content library, storage usage bar, Wi-Fi-only setting |
| `settings/` | Theme toggle, autoplay, low-data mode |

### `features/books/utils/fileset_utils.dart`

**Responsibility:** resolves the best audio fileset ID for a given book and testament.

Exposed as a Dart extension `BibleEditionFileset` on `BibleEdition`. The `O/N/C`
portion code logic lives here, not scattered across UI files. Prefers `opus16` formats
when available.

### `features/books/widgets/`

| File | Responsibility |
|---|---|
| `bible_header.dart` | Flag, language label, and Bible edition title banner |
| `book_row.dart` | Expandable row for a single book; owns the `_playChapter` logic |
| `chapter_grid.dart` | 6-column grid of chapter number tiles for multi-chapter books |

### `features/player/widgets/`

| File | Responsibility |
|---|---|
| `track_info.dart` | Gradient artwork card and track metadata (title, chapter, language) |
| `seek_bar.dart` | Slider + time labels; owns the `positionStream` `StreamBuilder` |
| `playback_controls.dart` | Play/pause (with buffering spinner), ±10 s skip buttons |

---

## `lib/widgets/`

**Responsibility:** shared widgets used on more than one screen.

| File | Responsibility |
|---|---|
| `app_error_view.dart` | Standardized user-facing error state with French text and retry button (`AppErrorView`) |
| `bible_row.dart` | Bible edition card used on the translations list |
| `language_card.dart` | Language entry card used on the home screen |
| `nav_bar.dart` | Bottom navigation bar |
| `skeleton.dart` | Loading skeleton placeholder (`SkeletonLoader`) |

**Depends on:** `core/constants/`, `data/models/`  
**Depended on by:** `features/*`

---

## Quick Reference — "Where does this go?"

| If you're adding… | It goes in… |
|---|---|
| A new Gabonese language | `core/constants/gabon.dart` (one line) |
| A second Bible-audio API | New file in `data/sources/`, one line in `source_registry.dart` |
| A new field on a Bible edition | `data/models/bible_edition.dart` |
| Business logic about which Bibles count | `data/repositories/catalog_repository.dart` |
| A new colour | `core/constants/colors.dart` |
| A font or text style change | `core/constants/typography.dart` |
| A new screen | New folder in `features/` |
| A widget used on 2+ screens | `lib/widgets/` |
| Download / offline logic | `data/repositories/download_repository.dart` + `data/datasources/downloads_local.dart` |
| A new player UI sub-widget | `features/player/widgets/` |
