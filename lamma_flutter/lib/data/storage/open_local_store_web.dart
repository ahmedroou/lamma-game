import 'package:sembast_web/sembast_web.dart';
import '../repositories/local_game_repository.dart';

Future<LocalGameRepository> openLocalStore() async => SembastGameRepository(
  await databaseFactoryWeb.openDatabase('lamma-local-v1'),
);
