// -----------------------------------------------------------------------------
// File: source_registry.dart
// Purpose: Registry resolving appropriate Bible audio data sources per language.
// Author: Agnambie Team
// Creation date: 2026-09-26
// Last modified: 2026-09-26
// -----------------------------------------------------------------------------

import 'bible_audio_source.dart';
import 'bible_brain_source.dart';

/// Maps language ISO codes to their respective [BibleAudioSource].
/// 
/// Currently, all Gabonese languages are served by Bible Brain, but this allows
/// future expansion if a language needs a different audio provider.
class SourceRegistry {
  /// Default backend audio source implementation backed by Bible Brain.
  final BibleBrainSource _bibleBrainSource;

  /// Creates a [SourceRegistry] with an optional injected [BibleBrainSource].
  ///
  /// Falls back to a default [BibleBrainSource] instance if omitted.
  SourceRegistry({BibleBrainSource? bibleBrainSource})
      : _bibleBrainSource = bibleBrainSource ?? BibleBrainSource();

  /// Returns the appropriate source for the given language [iso].
  ///
  /// Dispatches catalog queries to the relevant provider. Currently maps
  /// all languages to Bible Brain.
  BibleAudioSource getSourceForLanguage(String iso) {
    // Currently mapping everything to Bible Brain.
    // If a different API is added later, add the switch logic here.
    return _bibleBrainSource;
  }
}
