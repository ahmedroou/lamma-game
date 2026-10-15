import 'package:flutter/foundation.dart';

@immutable
final class QuestionAudio {
  const QuestionAudio({
    required this.assetPath,
    required this.durationMs,
    this.attribution = '',
    this.sourceUrl = '',
    this.license = '',
    this.reviewStatus = 'unverified',
    this.speaker = '',
    this.recordingId = '',
    this.licenseUrl = '',
    this.sourceStartMs = 0,
    this.sourceEndMs = 0,
    this.transcript = '',
    this.listeningStatus = 'pending',
    this.reviewedBy = '',
    this.reviewedAt = '',
    this.reviewMethod = 'humanListening',
    this.contentSha256 = '',
    this.transcriptionModel = '',
    this.reviewEvidenceId = '',
  });

  final String assetPath;
  final int durationMs;
  final String attribution;
  final String sourceUrl;
  final String license;
  final String reviewStatus, speaker, recordingId, licenseUrl, transcript;
  final int sourceStartMs, sourceEndMs;
  final String listeningStatus, reviewedBy, reviewedAt;
  final String reviewMethod,
      contentSha256,
      transcriptionModel,
      reviewEvidenceId;

  bool get isMachineReviewed =>
      reviewMethod == 'sourceTranscript' &&
      listeningStatus == 'machineTranscribed' &&
      RegExp(r'^[a-f0-9]{64}$').hasMatch(contentSha256) &&
      transcriptionModel == 'faster-whisper-tiny.en,faster-whisper-small.en' &&
      reviewEvidenceId.trim().isNotEmpty;

  /// Legacy metadata and source-only research never authorize playback.
  /// Approval records the actual method used for the final extracted clip.
  /// Machine transcription is never recorded as human listening.
  bool get isApproved =>
      reviewStatus == 'approved' &&
      ((reviewMethod == 'humanListening' && listeningStatus == 'listened') ||
          isMachineReviewed) &&
      reviewedBy.trim().isNotEmpty &&
      DateTime.tryParse(reviewedAt) != null &&
      RegExp(
        r'^assets/question_audio/[a-zA-Z0-9_-]+\.mp3$',
      ).hasMatch(assetPath) &&
      durationMs > 0 &&
      speaker.trim().isNotEmpty &&
      recordingId.trim().isNotEmpty &&
      transcript.trim().isNotEmpty &&
      attribution.trim().isNotEmpty &&
      license.trim().isNotEmpty &&
      _httpsUrl(sourceUrl) &&
      _httpsUrl(licenseUrl) &&
      sourceStartMs >= 0 &&
      sourceEndMs > sourceStartMs;

  static bool _httpsUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty;
  }

  factory QuestionAudio.fromJson(Map<String, dynamic> json) {
    if (json case {
      'assetPath': String assetPath,
      'durationMs': int durationMs,
    } when assetPath.trim().isNotEmpty && durationMs > 0) {
      return QuestionAudio(
        assetPath: assetPath.trim(),
        durationMs: durationMs,
        attribution: (json['attribution'] as String?)?.trim() ?? '',
        sourceUrl: (json['sourceUrl'] as String?)?.trim() ?? '',
        license: (json['license'] as String?)?.trim() ?? '',
        reviewStatus: (json['reviewStatus'] as String?)?.trim() ?? 'unverified',
        speaker: (json['speaker'] as String?)?.trim() ?? '',
        recordingId: (json['recordingId'] as String?)?.trim() ?? '',
        licenseUrl: (json['licenseUrl'] as String?)?.trim() ?? '',
        sourceStartMs: json['sourceStartMs'] as int? ?? 0,
        sourceEndMs: json['sourceEndMs'] as int? ?? 0,
        transcript: (json['transcript'] as String?)?.trim() ?? '',
        listeningStatus:
            (json['listeningStatus'] as String?)?.trim() ?? 'pending',
        reviewedBy: (json['reviewedBy'] as String?)?.trim() ?? '',
        reviewedAt: (json['reviewedAt'] as String?)?.trim() ?? '',
        reviewMethod:
            (json['reviewMethod'] as String?)?.trim() ?? 'humanListening',
        contentSha256: (json['contentSha256'] as String?)?.trim() ?? '',
        transcriptionModel:
            (json['transcriptionModel'] as String?)?.trim() ?? '',
        reviewEvidenceId: (json['reviewEvidenceId'] as String?)?.trim() ?? '',
      );
    }
    throw const FormatException(
      'QuestionAudio requires a non-empty assetPath and positive durationMs.',
    );
  }

  Map<String, dynamic> toJson() => {
    'assetPath': assetPath,
    'durationMs': durationMs,
    if (attribution.isNotEmpty) 'attribution': attribution,
    if (sourceUrl.isNotEmpty) 'sourceUrl': sourceUrl,
    if (license.isNotEmpty) 'license': license,
    'reviewStatus': reviewStatus,
    if (speaker.isNotEmpty) 'speaker': speaker,
    if (recordingId.isNotEmpty) 'recordingId': recordingId,
    if (licenseUrl.isNotEmpty) 'licenseUrl': licenseUrl,
    'sourceStartMs': sourceStartMs,
    'sourceEndMs': sourceEndMs,
    if (transcript.isNotEmpty) 'transcript': transcript,
    'listeningStatus': listeningStatus,
    if (reviewedBy.isNotEmpty) 'reviewedBy': reviewedBy,
    if (reviewedAt.isNotEmpty) 'reviewedAt': reviewedAt,
    'reviewMethod': reviewMethod,
    if (contentSha256.isNotEmpty) 'contentSha256': contentSha256,
    if (transcriptionModel.isNotEmpty) 'transcriptionModel': transcriptionModel,
    if (reviewEvidenceId.isNotEmpty) 'reviewEvidenceId': reviewEvidenceId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionAudio &&
          runtimeType == other.runtimeType &&
          assetPath == other.assetPath &&
          durationMs == other.durationMs &&
          attribution == other.attribution &&
          sourceUrl == other.sourceUrl &&
          license == other.license &&
          reviewStatus == other.reviewStatus &&
          speaker == other.speaker &&
          recordingId == other.recordingId &&
          licenseUrl == other.licenseUrl &&
          sourceStartMs == other.sourceStartMs &&
          sourceEndMs == other.sourceEndMs &&
          transcript == other.transcript &&
          listeningStatus == other.listeningStatus &&
          reviewedBy == other.reviewedBy &&
          reviewedAt == other.reviewedAt &&
          reviewMethod == other.reviewMethod &&
          contentSha256 == other.contentSha256 &&
          transcriptionModel == other.transcriptionModel &&
          reviewEvidenceId == other.reviewEvidenceId;

  @override
  int get hashCode => Object.hashAll([
    assetPath,
    durationMs,
    attribution,
    sourceUrl,
    license,
    reviewStatus,
    speaker,
    recordingId,
    licenseUrl,
    sourceStartMs,
    sourceEndMs,
    transcript,
    listeningStatus,
    reviewedBy,
    reviewedAt,
    reviewMethod,
    contentSha256,
    transcriptionModel,
    reviewEvidenceId,
  ]);
}
