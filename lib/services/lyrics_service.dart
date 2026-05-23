import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ── Ayah model ───────────────────────────────────────────────────────────────
class Ayah {
  final int number;
  final int numberInSurah;
  final String text;
  final bool isIntro;

  const Ayah({
    required this.number,
    required this.numberInSurah,
    required this.text,
    this.isIntro = false,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      number: json['number'] ?? 0,
      numberInSurah: json['numberInSurah'] ?? 0,
      text: (json['text'] ?? '').toString().trim(),
    );
  }
}

// ── Timed word ──────────────────────────────────────────────────────────────
class TimedWord {
  final String word;
  final Duration startTime;
  final Duration endTime;

  const TimedWord({
    required this.word,
    required this.startTime,
    required this.endTime,
  });
}

// ── Timed ayah ──────────────────────────────────────────────────────────────
class TimedAyah {
  final Ayah ayah;
  final Duration startTime;
  final Duration endTime;
  final List<TimedWord> words;

  const TimedAyah({
    required this.ayah,
    required this.startTime,
    required this.endTime,
    required this.words,
  });

  int getActiveWordIndex(Duration position) {
    // Add a slight 250ms lead so words highlight slightly faster/ahead of the audio
    final adjustedPos = position + const Duration(milliseconds: 250);

    for (int i = 0; i < words.length; i++) {
      if (adjustedPos >= words[i].startTime && adjustedPos < words[i].endTime) {
        return i;
      }
    }
    if (adjustedPos >= endTime && words.isNotEmpty) return words.length - 1;
    return 0;
  }
}

// ── Service ─────────────────────────────────────────────────────────────────
class LyricsService {
  static final Map<String, List<Ayah>> _cache = {};
  static final Map<String, List<double>> _durCache = {};

  static const Duration _interAyahGap = Duration(milliseconds: 400);

  // ── Word Weight & Clean Helpers ──────────────────────────────────────────
  static String _cleanArabic(String text) {
    return text
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        .replaceAll('ٱ', 'ا')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ی', 'ي')
        .replaceAll('ـ', '')
        .trim();
  }

  static double _getWordWeight(String rawWord) {
    final clean = _cleanArabic(rawWord);
    
    // Only boost الٓمٓ / الم so it takes a lot of time, all other words are standard
    if (clean == 'الم') {
      return 15.0;
    }

    return 1.0; // Standard word weight
  }

  // ignore: unused_element
  static String _stripIntros(String text) {
    var words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    var normalized = _cleanArabic(text);

    // Check for Istiadha (5 words)
    if (normalized.startsWith('اعوذ بالله من الشيطان الرجيم')) {
      if (words.length > 5) {
        words = words.sublist(5);
        normalized = _cleanArabic(words.join(' '));
      } else {
        words = [];
        normalized = '';
      }
    }

    // Check for Bismillah (4 words)
    if (normalized.startsWith('بسم الله الرحمن الرحيم')) {
      if (words.length > 4) {
        words = words.sublist(4);
      } else {
        words = [];
      }
    }

    return words.join(' ');
  }

  // ── Fetch ayah text ───────────────────────────────────────────────────────
  static Future<List<Ayah>> fetchAyahs(String surahNumber) async {
    if (_cache.containsKey(surahNumber)) return _cache[surahNumber]!;

    try {
      final url = Uri.parse('https://api.alquran.cloud/v1/surah/$surahNumber');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List ayahsJson = data['data']['ayahs'] ?? [];
        final apiAyahs = ayahsJson.map((a) => Ayah.fromJson(a)).toList();

        if ((surahNumber == '2' || surahNumber == '3') && apiAyahs.isNotEmpty) {
          final first = apiAyahs.first;
          apiAyahs[0] = Ayah(
            number: first.number,
            numberInSurah: first.numberInSurah,
            text: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ الم',
            isIntro: first.isIntro,
          );
        } else if (surahNumber == '1' && apiAyahs.isNotEmpty) {
          final first = apiAyahs.first;
          apiAyahs[0] = Ayah(
            number: first.number,
            numberInSurah: first.numberInSurah,
            text: 'أَعُوذُ بِٱللَّهِ مِنَ ٱلشَّيْطَانِ ٱلرَّجِيمِ ${first.text}',
            isIntro: first.isIntro,
          );
        }

        _cache[surahNumber] = apiAyahs;
        return apiAyahs;
      }
    } catch (e) {
      debugPrint('Lyrics fetch error: $e');
    }
    return [];
  }

  static double _fallbackAyahWeight(String text) {
    final words = _splitWords(text);
    if (words.isEmpty) return 1.0;
    final double rawWeight =
        words.fold<double>(0.0, (sum, w) => sum + _getWordWeight(w)) * 0.8;
    return rawWeight > 0 ? rawWeight : 1.0;
  }

  static Future<List<double>> fetchAyahWeights(String surahNumber) async {
    if (_durCache.containsKey(surahNumber)) return _durCache[surahNumber]!;

    try {
      final url = Uri.parse(
          'https://api.alquran.cloud/v1/surah/$surahNumber/ar.alafasy');
      final resp = await http.get(url);
      if (resp.statusCode != 200) return [];

      final data = json.decode(resp.body);
      final List ayahs = data['data']['ayahs'] ?? [];

      // Fetch audio sizes in chunks of 15 to avoid choking the network stack
      const int maxConcurrency = 15;
      final List<double> weights = List.filled(ayahs.length, 1.0);

      for (int i = 0; i < ayahs.length; i += maxConcurrency) {
        final chunkEnd = (i + maxConcurrency < ayahs.length)
            ? i + maxConcurrency
            : ayahs.length;

        final List<Future<void>> chunkFutures = [];

        for (int j = i; j < chunkEnd; j++) {
          final index = j;
          final audioUrl = ayahs[index]['audio'] as String?;
          final text = ayahs[index]['text'] as String? ?? '';
          if (audioUrl != null) {
            chunkFutures.add(() async {
              try {
                final head = await http.head(
                  Uri.parse(audioUrl),
                  headers: {'Accept-Encoding': 'identity'},
                ).timeout(const Duration(seconds: 3));
                final size =
                    int.tryParse(head.headers['content-length'] ?? '') ?? 0;
                double w = size > 0 ? size / 16000.0 : _fallbackAyahWeight(text);
                if (surahNumber == '1' && index == 0) {
                  // Boost Bismillah (approx 9.2s) by 1.3 to get ~11.9s, matching the 11-12s recited Istiadha + Bismillah.
                  w = size > 0 ? (size / 16000.0) * 1.3 : 12.0;
                }
                if (surahNumber == '2' && index == 0) {
                  w = w < 14.0 ? 14.0 : w;
                }
                if (surahNumber == '3' && index == 0) {
                  w = 12.0;
                }
                weights[index] = w;
              } catch (_) {
                double w = _fallbackAyahWeight(text);
                if (surahNumber == '1' && index == 0) {
                  w = 12.0;
                }
                if (surahNumber == '2' && index == 0) {
                  w = 14.0;
                }
                if (surahNumber == '3' && index == 0) {
                  w = 12.0;
                }
                weights[index] = w;
              }
            }());
          } else {
            double w = _fallbackAyahWeight(text);
            if (surahNumber == '1' && index == 0) {
              w = 12.0;
            }
            if (surahNumber == '2' && index == 0) {
              w = 14.0;
            }
            if (surahNumber == '3' && index == 0) {
              w = 12.0;
            }
            weights[index] = w;
          }
        }
        await Future.wait(chunkFutures);
      }

      _durCache[surahNumber] = weights;
      return weights;
    } catch (e) {
      debugPrint('Ayah weights fetch error: $e');
    }
    return [];
  }

  // ── Create timed ayahs ────────────────────────────────────────────────────
  static List<TimedAyah> createTimedAyahs(
    List<Ayah> ayahs,
    Duration totalDuration, {
    List<double> audioWeights = const [],
    String surahNumber = '',
  }) {
    if (ayahs.isEmpty || totalDuration.inMilliseconds <= 0) return [];

    final gapCount = ayahs.length - 1;
    final totalGapMs = gapCount * _interAyahGap.inMilliseconds;

    final availableMs = totalDuration.inMilliseconds - totalGapMs;
    if (availableMs <= 0) {
      return _fallbackEvenSplit(ayahs, totalDuration);
    }

    // Choose weights: audio-based (accurate) or word-count (fallback)
    List<double> weights;
    if (audioWeights.isNotEmpty && audioWeights.length == ayahs.length) {
      weights = audioWeights;
    } else {
      weights = ayahs
          .map((a) => _splitWords(a.text)
              .fold<double>(0.0, (sum, w) => sum + _getWordWeight(w)))
          .toList();
    }

    final totalWeight = weights.fold<double>(0, (sum, w) => sum + w);
    if (totalWeight == 0) return [];

    final List<TimedAyah> timed = [];
    Duration cursor = Duration.zero;

    // Check if we have Surah 2 or 3 Ayah 1 (starts with Bismillah and الم)
    final hasSurah2FirstAyah = ayahs.isNotEmpty &&
        ayahs[0].text == 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ الم' &&
        surahNumber == '2';
    final hasSurah3FirstAyah = ayahs.isNotEmpty &&
        ayahs[0].text == 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ الم' &&
        surahNumber == '3';

    for (int i = 0; i < ayahs.length; i++) {
      int ayahMs;
      if (hasSurah2FirstAyah && i == 0) {
        ayahMs = 14000;
      } else if (hasSurah3FirstAyah && i == 0) {
        ayahMs = 12000;
      } else {
        double currentWeight = weights[i];
        double remainingWeight = 0;
        for (int k = i; k < ayahs.length; k++) {
          remainingWeight += weights[k];
        }
        final double remainingAvailableMs = (totalDuration.inMilliseconds -
                cursor.inMilliseconds -
                (ayahs.length - 1 - i) * _interAyahGap.inMilliseconds)
            .toDouble();
        if (remainingWeight > 0 && remainingAvailableMs > 0) {
          ayahMs =
              (remainingAvailableMs * (currentWeight / remainingWeight)).round();
        } else {
          ayahMs = 1000; // safe fallback
        }
      }

      final ayahStart = cursor;
      final ayahEnd = i == ayahs.length - 1
          ? totalDuration
          : cursor + Duration(milliseconds: ayahMs);

      final words = _splitWords(ayahs[i].text);
      timed.add(TimedAyah(
        ayah: ayahs[i],
        startTime: ayahStart,
        endTime: ayahEnd,
        words: _distributeWords(words, ayahStart, ayahEnd),
      ));

      cursor = ayahEnd;
      if (i < ayahs.length - 1) {
        cursor = cursor + _interAyahGap;
      }
    }
    return timed;
  }

  // ── Fallback even split ───────────────────────────────────────────────────
  static List<TimedAyah> _fallbackEvenSplit(
      List<Ayah> ayahs, Duration total) {
    final perAyah =
        Duration(milliseconds: total.inMilliseconds ~/ ayahs.length);
    final List<TimedAyah> timed = [];
    Duration cursor = Duration.zero;
    for (int i = 0; i < ayahs.length; i++) {
      final end =
          i == ayahs.length - 1 ? total : cursor + perAyah;
      timed.add(TimedAyah(
        ayah: ayahs[i],
        startTime: cursor,
        endTime: end,
        words: _distributeWords(_splitWords(ayahs[i].text), cursor, end),
      ));
      cursor = end;
    }
    return timed;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  static List<String> _splitWords(String text) =>
      text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

  static List<TimedWord> _distributeWords(
      List<String> words, Duration start, Duration end) {
    if (words.isEmpty) return [];

    final totalMs = end.inMilliseconds - start.inMilliseconds;

    // Special handling for Surah 2 Ayah 1: "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ الم"
    // where we want "الم" (الٓمٓ) to take exactly 8 seconds (8000 ms).
    if (words.length == 5 && _cleanArabic(words.last) == 'الم' && totalMs > 8000) {
      final bismillahMs = totalMs - 8000;
      final List<String> bismillahWords = words.sublist(0, 4);
      final List<double> bismillahWeights = bismillahWords.map((w) => w.length.toDouble()).toList();
      final totalBismillahWeight = bismillahWeights.fold<double>(0.0, (sum, w) => sum + w);

      final List<TimedWord> result = [];
      Duration wCursor = start;

      for (int i = 0; i < 4; i++) {
        final proportion = bismillahWeights[i] / totalBismillahWeight;
        final wEnd = wCursor + Duration(milliseconds: (bismillahMs * proportion).round());
        result.add(TimedWord(word: words[i], startTime: wCursor, endTime: wEnd));
        wCursor = wEnd;
      }

      // Add "الم" for the remaining 8 seconds
      result.add(TimedWord(word: words[4], startTime: wCursor, endTime: end));
      return result;
    }

    // Calculate custom weights for each word
    final List<double> wordWeights = words.map((w) {
      return w.length * _getWordWeight(w);
    }).toList();

    final totalWeight = wordWeights.fold<double>(0.0, (sum, w) => sum + w);
    if (totalWeight == 0) return [];

    final List<TimedWord> result = [];
    Duration wCursor = start;

    for (int i = 0; i < words.length; i++) {
      final proportion = wordWeights[i] / totalWeight;
      final wEnd = i == words.length - 1
          ? end
          : wCursor + Duration(milliseconds: (totalMs * proportion).round());
      result.add(TimedWord(word: words[i], startTime: wCursor, endTime: wEnd));
      wCursor = wEnd;
    }
    return result;
  }
}
