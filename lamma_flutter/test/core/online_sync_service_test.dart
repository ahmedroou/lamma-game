import 'package:flutter_test/flutter_test.dart';
import 'package:lamma/core/online_sync_service.dart';

void main() {
  group('OnlineSyncService', () {
    test('generateRoomCode produces 6-digit numeric PIN codes for TV remotes', () {
      final code = OnlineSyncService.generateRoomCode();
      expect(code.length, 6);
      expect(RegExp(r'^[0-9]{6}$').hasMatch(code), isTrue);
    });

    test('generateHostKey produces strong secret key with host- prefix', () {
      final key = OnlineSyncService.generateHostKey();
      expect(key.startsWith('host-'), isTrue);
      expect(key.length, greaterThanOrEqualTo(24));
    });

    test('shareUrl, formattedPin and qrCodeUrl are null when not broadcasting', () {
      final service = OnlineSyncService();
      expect(service.isBroadcasting, isFalse);
      expect(service.roomId, isNull);
      expect(service.shareUrl, isNull);
      expect(service.formattedPin, isNull);
      expect(service.qrCodeUrl, isNull);
    });
  });
}
