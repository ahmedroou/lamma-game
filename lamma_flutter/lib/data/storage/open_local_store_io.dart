import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import '../repositories/local_game_repository.dart';

Future<LocalGameRepository> openLocalStore() async {
  final directory = await getApplicationSupportDirectory();
  await directory.create(recursive: true);
  final database = await databaseFactoryIo.openDatabase(
    path.join(directory.path, 'lamma-local-v1.db'),
  );
  return SembastGameRepository(database);
}
