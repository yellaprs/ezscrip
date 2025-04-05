import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:ezscrip/applicationexception.dart';
import 'package:ezscrip/infrastructure/db/encryptedCodec.dart';
import 'package:ezscrip/infrastructure/services/securestorage_service.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/utils/sembast_import_export.dart';
import 'package:ezscrip/util/constants.dart';

class AppDatabase {
  // Singleton instance
  static final AppDatabase _singleton = AppDatabase._();

  // Singleton accessor
  static AppDatabase get instance => _singleton;

  // Completer is used for transforming synchronous code into asynchronous code.
  Completer<Database>? _dbOpenCompleter;

  // A private constructor. Allows us to create instances of AppDatabase
  // only from within the AppDatabase class itself.
  AppDatabase._();

  // Sembast database object
  late Database _database;

  late String secret;

  Future<File> createDB(String dbFilePath) async {
    return await File(dbFilePath).create(recursive: true);
  }

  Future<bool> setDocumentStoragePin(String pin) {
    return SecureStorageService.store("storagePin", pin);
  }

  Future<String> getDocumentStoragePin() async {
    return (await SecureStorageService.get("storagePin") as String);
  }

  Future<bool> refreshDB() async {
    final cacheDir = await getTemporaryDirectory();
    final appDir = await getApplicationSupportDirectory();
    late File dbFile;

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }

    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
    }

    bool isDatabaseDeleted = true;
    String dbFilePath =
        File((await getApplicationSupportDirectory()).path + dbName).path;
    if (File(dbFilePath).existsSync()) {
      isDatabaseDeleted = await AppDatabase.instance.deleteDatabase(dbFilePath);
    }

    if (isDatabaseDeleted) dbFile = await createDB(dbFilePath);

    return (isDatabaseDeleted && await dbFile.exists());
  }

  String get dbName => GlobalConfiguration().getString(C.DB_NAME);

  // Database object accessor
  Future<Database> get database async {
    try {
      // If completer is null, AppDatabaseClass is ly instantiated, so database is not yet opened
      if (_dbOpenCompleter == null) {
        _dbOpenCompleter = Completer();
        // Calling _openDatabase will also complete the completer with database instance
        _openDatabase((await getApplicationSupportDirectory()).path,
            await getDocumentStoragePin());
      }
      // If the database is already opened, awaiting the future will happen instantly.
      // Otherwise, awaiting the returned future will take some time - until complete() is called
      // on the Completer in _openDatabase() below.
      return _dbOpenCompleter!.future;
    } on ApplicationException catch (exception) {
      throw exception;
    }
  }

  Future<bool> deleteDatabase(String documentDir) async {
    String dbName = GlobalConfiguration().getString(C.DB_NAME);
    final dbPath = join(documentDir, dbName);

    try {
      await databaseFactoryIo.deleteDatabase(dbPath);
    } on DatabaseException catch (exception) {
      throw ApplicationException(exception.code.toString(), exception.message);
    }
    return (database != null) ? true : false;
  }

  Uint8List _generateEncryptPassword(String password) {
    var blob = Uint8List.fromList(md5.convert(utf8.encode(password)).bytes);
    assert(blob.length == 16);
    return blob;
  }

  SembastCodec _getEncryptSembastCodec({required String password}) =>
      SembastCodec(
          signature: "_encryptCodecSignature",
          codec: EncryptCodec(_generateEncryptPassword(password)));

  Future _openDatabase(String documentDir, String secretPin) async {
    String dbName = GlobalConfiguration().get(C.DB_NAME) as String;
    final dbPath = join(documentDir, dbName);
    try {
      var codec = _getEncryptSembastCodec(password: secretPin);
      final database =
          await databaseFactoryIo.openDatabase(dbPath, codec: codec);
      _database = database;
      _dbOpenCompleter!.complete(database);
    } on DatabaseException catch (exception) {
      throw ApplicationException(exception.code.toString(), exception.message);
    }
  }

  Future<Map<String, Object?>> exportDB() async {
    return await exportDatabase(_database);
  }
}
