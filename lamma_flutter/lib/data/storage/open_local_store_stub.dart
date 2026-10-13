import '../repositories/local_game_repository.dart';

Future<LocalGameRepository> openLocalStore() => Future.error(
  UnsupportedError('Local storage is not available on this platform.'),
);
