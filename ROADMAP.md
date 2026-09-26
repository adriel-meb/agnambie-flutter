# Roadmap — Agnambie (Gabon)

Each phase ends with something demoable. Don't start a phase until the previous
one's "Done when" is actually true — the point is to catch broken assumptions early
and cheaply, not at the end.

---

## Phase 0 — Backend Connectivity & Validation

**Goal: prove the network chain works before building anything on top of it.**

- [x] Request the Bible Brain API key
- [x] Stand up the Go backend proxy (`agnambie-backend`) with Redis and Gzip support
- [x] Enforce the Gabon-language allowlist inside the proxy itself

**Done when:** ✅ API key active, proxy running, Gabon allowlist enforced server-side.

---

## Phase 1 — Data Layer

**Goal: build the core data layer and prove network connectivity.**

- [x] Project setup and folder structure
- [x] `Language`, `BibleEdition`, `Book`, `Download` models with `fromJson`
- [x] `BibleAudioSource` (abstract interface) and `BibleBrainSource` (implementation)
- [x] `SourceRegistry` mapping Gabon languages to `BibleBrainSource`
- [x] `CatalogRepository` — Gabon scoping + fileset resolution logic
- [x] Riverpod providers for all repositories (`data/repositories/providers.dart`)
- [x] `DownloadRepository` + `HiveDownloadsLocalDataSource`
- [x] `PlayerRepository` backed by `just_audio`
- [x] `AudioHandler` (`audio_service` background playback + lock-screen controls)

**Done when:** ✅ Repository layer fetches and parses real Bible data for Gabon languages.

---

## Phase 2 — Static-Data UI

**Goal: the full non-audio flow, navigable, with live data.**

- [x] Home screen — language list (Fang / Myene / French / …) with skeleton loaders
- [x] Translations screen — Bible editions per language
- [x] Books screen — books with chapter grid expansion
- [x] Full navigation stack: Home → Language → Translations → Books
- [x] Visual design: warm off-white background, forest green accent, Poppins typography
- [x] Error states and empty states on all list screens
- [x] `SkeletonLoader` placeholders during data fetch

**Done when:** ✅ Tap from Home → language → translation → book — all real data, no crashes.

---

## Phase 3 — Playback

**Goal: real audio, start to finish.**

- [x] `just_audio` + `audio_service` integrated
- [x] `PlayerRepository.playChapter()` resolves fileset ID and streams audio
- [x] Full-screen `PlayerScreen` — artwork, seek bar, play/pause, ±10 s skip
- [x] `MiniPlayer` persistent bottom bar shown while a track is active
- [x] `PlayerController` (Riverpod `Notifier`) manages `TrackMetadata` state
- [x] `fileset_utils.dart` extension — OT/NT/Complete fileset resolution, `opus16` preference
- [x] Handle dropped connection mid-stream with a real error state (not a silent stall)
- [ ] Confirm background / lock-screen controls work on physical device

**Done when:** browse to any chapter, hear it play, see lock-screen controls, graceful failure on network drop.

---

## Phase 4 — Offline & Low-Bandwidth

**Goal: the app works with no connection and consumes minimal mobile data.**

- [x] `dio_cache_interceptor` with `HiveCacheStore` — ETag / `If-None-Match` wired in `ApiClient`
- [x] `Save-Data: on` header injected from `ApiClient` when low-data mode is enabled in Hive
- [x] `HiveDownloadsLocalDataSource` — typed `Box<Map<String, dynamic>>` for download records
- [x] `DownloadRepository` — save, list, delete (file *and* DB row together)
- [x] Download bottom sheet (`download_sheet.dart`) — per-book batch download
- [x] Wi-Fi-only gate via `connectivity_plus` in the download flow
- [x] Offline screen — storage usage bar, downloaded list, remove action
- [x] `PlayerRepository` checks local file before streaming
- [ ] Airplane-mode playback test with a previously downloaded chapter

**Done when:** go into airplane mode and play something downloaded earlier; removing a download frees disk space; catalog calls return `304` on repeat fetch.

---

## Phase 5 — Settings & Polish

**Goal: the app feels finished, not just functional.**

- [x] Settings screen — theme toggle, low-data mode, Wi-Fi-only mode, autoplay
- [x] Dark mode (`AppTheme.darkTheme`, `themeModeProvider`)
- [x] Skeleton loaders on all async screens
- [x] Sleep timer
- [x] Error states reviewed end-to-end — no network, no audio for a language,
      server error, download failure, search edge cases

**Done when:** every screen has a real loading state, a real empty state, and a real error state — none of them blank or a raw exception message.

---

## Phase 6 — Harden & Review

**Goal: catch what got skipped while moving fast.**

- [ ] Confirm Gabon allowlist is enforced in the proxy — call the proxy directly with
      a non-Gabonese language code and verify rejection
- [ ] Read every AI-generated file you haven't fully reviewed — bugs compound across
      layers once everything is integrated
- [ ] Test on throttled 3G (network conditioning or a physical low-signal device)
- [ ] Verify fileset licensing flags before assuming every edition is legally downloadable
- [ ] Confirm Myene's real ISO code against a live `/languages?country=GA` call

**Done when:** every screen exercised on a throttled connection; every file in `lib/` read at least once.

---

## Phase 7 — Beta

**Goal: real feedback from real Gabonese users.**

- [ ] TestFlight / internal APK to a small trusted group in Gabon (ideally church-connected,
      not cold downloads)
- [ ] Prioritise feedback on offline flow and low-bandwidth behaviour — these are the
      things your own testing is least likely to catch
- [ ] Decide, based on actual usage data, whether expanding to a second country
      (Cameroon is the natural candidate) is worth the `SourceRegistry` generalisation —
      don't do it speculatively before this point

---

## Pacing

Roughly 6–8 weeks of evenings and weekends across all seven phases. Each phase should
produce something you can actually open and use, even if rough — that's the point of
ending every phase with a "Done when," rather than only feeling progress at the very end.
