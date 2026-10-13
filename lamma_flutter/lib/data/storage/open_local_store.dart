import '../repositories/local_game_repository.dart';
import 'open_local_store_stub.dart'
    if (dart.library.io) 'open_local_store_io.dart'
    if (dart.library.js_interop) 'open_local_store_web.dart'
    as platform;

Future<LocalGameRepository> openLocalStore() => platform.openLocalStore();
