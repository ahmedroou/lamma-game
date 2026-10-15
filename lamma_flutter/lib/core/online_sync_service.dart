import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../domain/models/session_state.dart';
import '../domain/models/session_config.dart';
import 'game_catalog.dart';

/// Service that broadcasts the live game state to Cloud Firestore (lamma-live database)
/// so remote spectators can watch in real time via https://lamma-live.web.app/?room=ROOM_ID.
class OnlineSyncService {
  static final OnlineSyncService _instance = OnlineSyncService._internal();
  factory OnlineSyncService() => _instance;
  OnlineSyncService._internal();

  static const String _projectId = 'studio-6591522303-5ceb5';
  static const String _databaseId = 'lamma-live';
  static const String _apiKey = 'AIzaSyBX_FpSflsHNb5vduGvULMgwnVK1p6qGpM';
  static const String webViewerBaseUrl = 'https://lamma-live.web.app';

  SessionConfig? _config;
  String? _roomId;
  String? _hostKey;
  String? _createdAtIso;
  bool _isBroadcasting = false;
  bool _isSyncing = false;
  SessionState? _lastSyncedState;

  bool get isBroadcasting => _isBroadcasting;
  String? get roomId => _roomId;
  String? get shareUrl =>
      _roomId == null ? null : '$webViewerBaseUrl/?room=$_roomId';

  /// Returns the formatted PIN with a space for readability on TV (e.g. "482 190")
  String? get formattedPin {
    if (_roomId == null) return null;
    if (_roomId!.length == 6) {
      return '${_roomId!.substring(0, 3)} ${_roomId!.substring(3)}';
    }
    return _roomId;
  }

  /// Returns direct QR code image URL for instant scanning with smartphone camera
  String? get qrCodeUrl => shareUrl == null
      ? null
      : 'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=${Uri.encodeComponent(shareUrl!)}';

  /// Generates an ultra-easy 6-digit numeric PIN for Smart TV remotes and quick mobile entry
  static String generateRoomCode() {
    final rand = Random.secure();
    // 6 digits PIN (100000 - 999999)
    final pin = (100000 + rand.nextInt(900000)).toString();
    return pin;
  }

  /// Generates a secure random 24-char host key
  static String generateHostKey() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    final key = List.generate(
      24,
      (index) => chars[rand.nextInt(chars.length)],
    ).join();
    return 'host-$key';
  }

  /// Starts broadcasting the session online
  Future<bool> startBroadcasting({
    required SessionConfig config,
    required SessionState state,
    String? preferredRoomCode,
  }) async {
    _config = config;
    _roomId = (preferredRoomCode ?? generateRoomCode()).toUpperCase();
    _hostKey = generateHostKey();
    _createdAtIso = DateTime.now().toUtc().toIso8601String();
    _isBroadcasting = true;

    final success = await _pushState(state, isInitialCreate: true);
    if (!success) {
      _isBroadcasting = false;
      _config = null;
      _roomId = null;
      _hostKey = null;
      return false;
    }
    return true;
  }

  /// Stops broadcasting and marks the room as finished
  Future<void> stopBroadcasting() async {
    if (!_isBroadcasting || _roomId == null || _hostKey == null) return;
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$_projectId/databases/$_databaseId/documents/rooms/$_roomId?key=$_apiKey',
      );
      final body = jsonEncode({
        'fields': {
          'status': {'stringValue': 'finished'},
          'updatedAt': {'timestampValue': now},
        },
      });
      // Fire and forget finish update with mask
      await http.patch(
        Uri.parse(
          '$url&updateMask.fieldPaths=status&updateMask.fieldPaths=updatedAt',
        ),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
    } catch (e) {
      debugPrint('OnlineSyncService: stopBroadcasting error: $e');
    } finally {
      _isBroadcasting = false;
      _config = null;
      _roomId = null;
      _hostKey = null;
      _lastSyncedState = null;
    }
  }

  /// Broadcasts an updated game state
  void syncState(SessionState state) {
    if (!_isBroadcasting || _roomId == null || _hostKey == null) return;
    _schedulePush(state);
  }

  void _schedulePush(SessionState state) {
    _lastSyncedState = state;
    if (_isSyncing) return;
    _processNextPush();
  }

  Future<void> _processNextPush() async {
    if (!_isBroadcasting || _lastSyncedState == null) return;
    _isSyncing = true;
    final stateToSync = _lastSyncedState!;
    try {
      await _pushState(stateToSync, isInitialCreate: false);
    } catch (e) {
      debugPrint('OnlineSyncService push error: $e');
    } finally {
      _isSyncing = false;
      // If state changed while we were sending, push the newest state
      if (_lastSyncedState != null && _lastSyncedState != stateToSync) {
        _processNextPush();
      }
    }
  }

  Future<bool> _pushState(
    SessionState state, {
    required bool isInitialCreate,
  }) async {
    if (_roomId == null || _hostKey == null) return false;

    final nowIso = DateTime.now().toUtc().toIso8601String();
    final createdAt = _createdAtIso ?? nowIso;

    // Convert teams
    final teamsValues = state.teams.map((t) {
      return {
        'mapValue': {
          'fields': {
            'id': {'stringValue': t.id},
            'name': {'stringValue': t.name},
            'score': {'integerValue': t.score},
          },
        },
      };
    }).toList();

    // Mask the answer strictly when not in answer or results phase
    final isAnswerPhase =
        state.phase == SessionPhase.answer ||
        state.phase == SessionPhase.results;
    final question = state.question;
    final categoryName = question == null
        ? null
        : (gameCategories
                  .where((c) => c.id == question.categoryId)
                  .map((c) => c.title)
                  .firstOrNull ??
              question.categoryId);

    final fields = <String, dynamic>{
      'roomId': {'stringValue': _roomId!},
      'hostKey': {'stringValue': _hostKey!},
      'status': {'stringValue': 'active'},
      'phase': {'stringValue': state.phase.name},
      'activeTeamId': {'stringValue': state.activeTeam.id},
      'turn': {'integerValue': state.turn},
      'revealedCards': {'integerValue': state.revealedCards},
      'createdAt': {'timestampValue': createdAt},
      'updatedAt': {'timestampValue': nowIso},
      'timer': {
        'mapValue': {
          'fields': {
            'secondsRemaining': {'integerValue': state.clockSeconds},
            'running': {
              'booleanValue': !state.isPaused && state.clockSeconds > 0,
            },
          },
        },
      },
      'teams': {
        'arrayValue': {'values': teamsValues},
      },
    };

    // Serialize categories state for board screen
    if (_config != null) {
      final catList = <Map<String, dynamic>>[];
      for (final catId in _config!.boardCategoryIds) {
        final cat = gameCategories.where((c) => c.id == catId).firstOrNull;
        final title = cat?.title ??
            (catId == GameRules.abilitiesCategoryId
                ? 'المفاجآت والقدرات'
                : catId);
        final usedCount = state.history
            .where((r) => r.question.categoryId == catId)
            .length;
        final remaining =
            (GameRules.questionsPerCategory - usedCount).clamp(
              0,
              GameRules.questionsPerCategory,
            );

        final cards = [100, 200, 300, 400, 400].asMap().entries.map((entry) {
          final idx = entry.key;
          final pts = entry.value;
          return {
            'mapValue': {
              'fields': {
                'value': {'integerValue': pts},
                'used': {'booleanValue': idx < usedCount},
              },
            },
          };
        }).toList();

        catList.add({
          'mapValue': {
            'fields': {
              'id': {'stringValue': catId},
              'name': {'stringValue': title},
              'remaining': {'integerValue': remaining},
              'cards': {
                'arrayValue': {'values': cards},
              },
            },
          },
        });
      }
      if (catList.isNotEmpty) {
        fields['categoriesState'] = {
          'arrayValue': {'values': catList},
        };
      }
    }

    if (categoryName != null && question != null) {
      fields['category'] = {
        'mapValue': {
          'fields': {
            'id': {'stringValue': question.categoryId},
            'name': {'stringValue': categoryName},
          },
        },
      };
    }

    if (question != null && state.revealedCards == 3) {
      final qFields = <String, dynamic>{
        'id': {'stringValue': question.id},
        'categoryId': {'stringValue': question.categoryId},
        'text': {'stringValue': question.text},
        'points': {'integerValue': state.availablePoints},
        'difficulty': {'stringValue': question.difficulty.name},
      };

      if (question.clues.isNotEmpty) {
        qFields['clues'] = {
          'arrayValue': {
            'values': question.clues
                .take(state.identityCluesRevealed)
                .map((c) => {'stringValue': c})
                .toList(),
          },
        };
      }

      // STRICT PRIVACY: Only send answer and explanation during answer or results phase!
      if (isAnswerPhase) {
        qFields['answer'] = {'stringValue': question.answer};
        if (question.explanation.isNotEmpty) {
          qFields['explanation'] = {'stringValue': question.explanation};
        }
      }

      fields['question'] = {
        'mapValue': {'fields': qFields},
      };
    }

    // Additional round context (3 cards state, surprise, opponent, options, presentation)
    final roundDataMap = <String, dynamic>{
      'revealedCards': {'integerValue': state.revealedCards},
      'availablePoints': {'integerValue': state.availablePoints},
      'clockSeconds': {'integerValue': state.clockSeconds},
    };

    if (state.opponentTeamId != null) {
      roundDataMap['opponentTeamId'] = {'stringValue': state.opponentTeamId!};
    }
    if (state.isOpponentWindow) {
      roundDataMap['isOpponentWindow'] = {'booleanValue': true};
    }
    if (state.surpriseCard != null) {
      roundDataMap['surpriseTitle'] = {'stringValue': state.surpriseCard!.text};
      roundDataMap['surpriseEffect'] = {
        'stringValue': state.surpriseCard!.effect.name,
      };
    }
    if (state.plankRunning) {
      roundDataMap['plankRunning'] = {'booleanValue': true};
      roundDataMap['plankSeconds'] = {'integerValue': state.plankSeconds};
    }
    if (state.hintRevealed && question != null && question.hint.isNotEmpty) {
      roundDataMap['hint'] = {'stringValue': question.hint};
    }
    if (state.visibleOptions.isNotEmpty) {
      roundDataMap['options'] = {
        'arrayValue': {
          'values': state.visibleOptions
              .map((o) => {
                    'mapValue': {
                      'fields': {
                        'id': {'stringValue': o.id},
                        'text': {'stringValue': o.text},
                      },
                    },
                  })
              .toList(),
        },
      };
    }

    // Structured Question Presentation (when cards are revealed)
    if (question != null &&
        state.revealedCards == 3 &&
        question.presentation != null) {
      final pres = question.presentation!;
      roundDataMap['presentationType'] = {'stringValue': pres.type.name};

      final sectionsValues = pres.sections.map((sec) {
        final itemsValues = sec.items.map((it) {
          return {
            'mapValue': {
              'fields': {
                'id': {'stringValue': it.id},
                'text': {'stringValue': it.text},
                'missing': {'booleanValue': it.missing},
              },
            },
          };
        }).toList();

        return {
          'mapValue': {
            'fields': {
              'id': {'stringValue': sec.id},
              'title': {'stringValue': sec.title},
              'items': {
                'arrayValue': {'values': itemsValues},
              },
            },
          },
        };
      }).toList();

      roundDataMap['presentationSections'] = {
        'arrayValue': {'values': sectionsValues},
      };
    }

    if (roundDataMap.isNotEmpty) {
      fields['roundData'] = {
        'mapValue': {'fields': roundDataMap},
      };
    }

    final url = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/$_databaseId/documents/rooms/$_roomId?key=$_apiKey',
    );

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fields': fields}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        debugPrint(
          'OnlineSyncService: HTTP error ${response.statusCode}: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('OnlineSyncService: Network error: $e');
      return false;
    }
  }
}
