import 'dart:convert';
import 'dart:typed_data';

import 'package:golfguidescorecard/mod_serv/model.dart';
import 'package:golfguidescorecard/models/postTorneo.dart';
import 'package:golfguidescorecard/utilities/fecha.dart';
import 'package:golfguidescorecard/utilities/user-funtions.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DBLocal {
  static final DBLocal _instance = DBLocal.internal();
  DBLocal.internal();
  factory DBLocal() => _instance;
  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDB();
    return _db;
  }

  Future<Database> initDB() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'scgg.db');
    Database db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate
    );
//    _dropTabletorneos(db);
//    _dropTableTarjetaJugadores(db);
//    _dropTableTarjetaJugadoresHoyos(db);
//    _dropTableTarjetaJugadoresTee(db);
//    _dropTableClubesCanchasTees(db);
//    _dropTableClubes(db);

    // await _createTableUser(db, 1);
    // await _createTableTorneo(db);
    // await _createTableTarjetaJugadores(db);
    // await _createTableTarjetaJugadoresHoyos(db);
    // await _createTableTarjetaJugadoresTee(db);
    // await _createTableClubesCanchasTees(db);
    // await _createTableClubes(db);
    

    print('[DBLocal] initDB: Success');

    return db;
  }

  void _onCreate(Database db, int version) async {
    await _createTableUser(db, 1);
    await _createTableTorneo(db);
    await _createTableTarjetaJugadores(db);
    await _createTableTarjetaJugadoresHoyos(db);
    await _createTableTarjetaJugadoresTee(db);
    await _createTableClubesCanchasTees(db);
    await _createTableClubes(db);
  }

  void clearDB() async {
    var dbClient = await db;
    await _deleteTableUser(dbClient);
    await _deleteTableTorneos(dbClient);
    await _deleteTableTarjetaJugadores(dbClient);
    await _deleteTableTarjetaJugadoresHoyos(dbClient);
    await _deleteTableTarjetaJugadoresTee(dbClient);
    await _deleteTableClubes(dbClient);
    await _deleteTableClubesCanchasTees(dbClient);

    // await dbUserDropTable();
    // await _dropTabletorneos(dbClient);
    // await _dropTableTarjetaJugadores(dbClient);
    // await _dropTableTarjetaJugadoresHoyos(dbClient);
    // await _dropTableTarjetaJugadoresTee(dbClient);
    // await _dropTableClubes(dbClient);
    // await _dropTableClubesCanchasTees(dbClient);
  }


  Future<int> _deleteTableUser(Database db) async {
    try {
      return await db.delete('user');
    } on DatabaseException catch (e) {
      print('Exception _deleteTableUser $e');
      return 0;
    }
  }

  Future<int> _deleteTableTorneos(Database db) async {
    try {
      return await db.delete('torneos');
    } on DatabaseException catch (e) {
      print('Exception _deleteTableTorneos $e');
      return 0;
    }
  }

  Future<int> _deleteTableTarjetaJugadores(Database db) async {
    try {
      return await db.delete('tarjeta_jugadores');
    } on DatabaseException catch (e) {
      print('Exception _deleteTableTarjetaJugadores $e');
      return 0;
    }
  }

  Future<int> _deleteTableTarjetaJugadoresHoyos(Database db) async {
    try {
      return await db.delete('tarjeta_jugadores_hoyos');
    } on DatabaseException catch (e) {
      print('Exception _deleteTableTarjetaJugadoresHoyos $e');
      return 0;
    }
  }

  Future<int> _deleteTableTarjetaJugadoresTee(Database db) async {
    try {
      return await db.delete('tarjeta_jugadores_tee');
    } on DatabaseException catch (e) {
      print('Exception _deleteTableTarjetaJugadoresTee $e');
      return 0;
    }
  }

  Future<int> _deleteTableClubes(Database db) async {
    try {
      return await db.delete('clubes');
    } on DatabaseException catch (e) {
      print('Exception _deleteTableClubes $e');
      return 0;
    }
  }

  Future<int> _deleteTableClubesCanchasTees(Database db) async {
    try {
      return await db.delete('clubes_canchas_tees');
    } on DatabaseException catch (e) {
      print('Exception _deleteTableClubesCanchasTees $e');
      return 0;
    }
  }

  Future<void> _createTableUser(Database db, int version) async {
    try {
      await db.execute(
        'CREATE TABLE  IF NOT EXISTS user(id INTEGER PRIMARY KEY AUTOINCREMENT,' +
            ' idjuga_arg TEXT, matricula TEXT, nombre_juga TEXT, hcp TEXT, hcp3 TEXT,celular TEXT, ' +
            ' email TEXT,idclub TEXT,sexo TEXT, images TEXT, pais_juga TEXT, level_security INTEGER, token TEXT)',
      );
      print('[DBLocal] _createTableUser: Success');
      return;
    } catch (e) {
      print('///////////////////   error en creacion de la tabla usuario $e');
    }
  }

  Future<void> _dropTabletorneos(Database db) async {
    await db.execute(
      'DROP TABLE torneos',
    );
    return;
  }

  Future<void> _createTableTorneo(Database db) async {
    await db.execute(
      "CREATE TABLE  IF NOT EXISTS  torneos (id INTEGER PRIMARY KEY AUTOINCREMENT, id_torneo INTEGER ,id_club INTEGER ,id_club_cancha INTEGER ,"
      " id_user INTEGER ,codigo_torneo TEXT,id_origen INTEGER ,title TEXT,sub_title TEXT,game_mode INTEGER ,batches_count INTEGER ,"
      " batches_holes INTEGER ,difficulty_day NUMERIC ,start_date TEXT,game_started INTEGER ,closed_time TEXT,id_torneo_federacion INTEGER ,"
      " alta_time TEXT,alta_user INTEGER,mod_time TEXT,mod_user INTEGER ,modalidad TEXT,club TEXT,cancha TEXT,geolocalizacion TEXT)",
    );
    print('[DBLocal] _createTableTorneo: Success');
    return;
  }

//  void _createTableTorneoJugadores(Database db) async {
//    await db.execute(
//      'CREATE TABLE  IF NOT EXISTS torneo_jugadores(id INTEGER PRIMARY KEY AUTOINCREMENT,' +
//          'id_torneo INTEGER, id_user INTEGER, idjuga_arg TEXT, matricula TEXT, nombre_juga TEXT, hcp TEXT, hcp3 TEXT,celular TEXT, ' +
//          ' email TEXT,idclub TEXT,sexo TEXT, images TEXT, pais_juga TEXT, level_security INTEGER, hcp_torneo TEXT)',
//    );
//    print('[DBLocal] _createTableTorneo: Success');
//  }

  Future<void> _dropTableTarjetaJugadores(Database db) async {
    await db.execute(
      'DROP TABLE tarjeta_jugadores',
    );
    return;
  }

  Future<void> _createTableTarjetaJugadores(Database db) async {
    await db.execute(
      'CREATE TABLE  IF NOT EXISTS tarjeta_jugadores(id INTEGER PRIMARY KEY AUTOINCREMENT,' +
          ' id_torneo INTEGER, id_club_cancha_tee INTEGER, id_user INTEGER, fecha TEXT,  matricula TEXT, nombre_juga TEXT, hcp_index TEXT, hcp_torneo TEXT, path_tee_color TEXT, ' +
          ' images TEXT, ida INTEGER , vuelta INTEGER, gross INTEGER, neto INTEGER, neto_al_par INTEGER,  stableford INTEGER, '
              ' stableford_ida INTEGER, stableford_vuelta INTEGER, sexo TEXT, role INTEGER, firma_user_image BLOB , firma_marcador_matricula TEXT, firma_marcador_image BLOB)',
    );
    print('[DBLocal] _createTableTarjetaJugadores: Success');
    return;
  }

  Future<void> _dropTableTarjetaJugadoresTee(Database db) async {
    await db.execute(
      'DROP TABLE tarjeta_jugadores_tee',
    );
  }

  Future<void> _createTableTarjetaJugadoresTee(Database db) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS tarjeta_jugadores_tee (id INTEGER PRIMARY KEY AUTOINCREMENT, id_torneo INTEGER, id_user INTEGER, fecha TEXT'
        ',  matricula TEXT, id_club_cancha_tee INTEGER,id_club_cancha INTEGER,start INTEGER,tee TEXT,category INTEGER,'
        'ida_9h_course_rating TEXT,ida_9h_slope INTEGER,vta_9h_course_rating TEXT,vta_9h_slope INTEGER,course_rating TEXT,slope INTEGER,'
        'yards INTEGER,par INTEGER,p1 INTEGER,p2 INTEGER,p3 INTEGER,p4 INTEGER,p5 INTEGER,p6 INTEGER,p7 INTEGER,p8 INTEGER,p9 INTEGER,'
        'p10 INTEGER,p11 INTEGER,p12 INTEGER,p13 INTEGER,p14 INTEGER,p15 INTEGER,p16 INTEGER,p17 INTEGER,p18 INTEGER,'
        'd1 INTEGER,d2 INTEGER,d3 INTEGER,d4 INTEGER,d5 INTEGER,d6 INTEGER,d7 INTEGER,d8 INTEGER,d9 INTEGER,'
        'd10 INTEGER,d11 INTEGER,d12 INTEGER,d13 INTEGER,d14 INTEGER,d15 INTEGER,d16 INTEGER,d17 INTEGER,d18 INTEGER,'
        'h1 INTEGER,h2 INTEGER,h3 INTEGER,h4 INTEGER,h5 INTEGER,h6 INTEGER,h7 INTEGER,h8 INTEGER,h9 INTEGER,'
        'h10 INTEGER,h11 INTEGER,h12 INTEGER,h13 INTEGER,h14 INTEGER,h15 INTEGER,h16 INTEGER,h17 INTEGER,h18 INTEGER)');
    print('[DBLocal] _createTableTarjetaJugadoresTee: Success');
    return;
  }

  Future<void> _dropTableTarjetaJugadoresHoyos(Database db) async {
    await db.execute(
      'DROP TABLE tarjeta_jugadores_hoyos',
    );
    return;
  }

  Future<void> _createTableTarjetaJugadoresHoyos(Database db) async {
    await db.execute(
      'CREATE TABLE  IF NOT EXISTS tarjeta_jugadores_hoyos(id INTEGER PRIMARY KEY AUTOINCREMENT,' +
          ' id_torneo INTEGER, id_user INTEGER,  matricula TEXT, ' +
          ' hoyoNro INTEGER, distancia INTEGER, par INTEGER, handicap INTEGER, golpesHcp INTEGER, score INTEGER, score_state INTEGER, ' +
          ' score_ctrol INTEGER, neto INTEGER, stableford INTEGER)',
    );
    print('[DBLocal] _createTableTarjetaJugadoresHoyos: Success');
    return;
  }

  Future<void> _dropTableClubesCanchasTees(Database db) async {
    await db.execute(
      'DROP TABLE clubes_canchas_tees',
    );
    return;
  }

  Future<void> _createTableClubesCanchasTees(Database db) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS clubes_canchas_tees (id INTEGER PRIMARY KEY AUTOINCREMENT,  id_club_cancha_tee INTEGER,id_club_cancha INTEGER,start INTEGER,tee TEXT,category INTEGER,'
        'ida_9h_course_rating TEXT,ida_9h_slope INTEGER,vta_9h_course_rating TEXT,vta_9h_slope INTEGER,course_rating TEXT,slope INTEGER,'
        'yards INTEGER,par INTEGER,p1 INTEGER,p2 INTEGER,p3 INTEGER,p4 INTEGER,p5 INTEGER,p6 INTEGER,p7 INTEGER,p8 INTEGER,p9 INTEGER,'
        'p10 INTEGER,p11 INTEGER,p12 INTEGER,p13 INTEGER,p14 INTEGER,p15 INTEGER,p16 INTEGER,p17 INTEGER,p18 INTEGER,'
        'd1 INTEGER,d2 INTEGER,d3 INTEGER,d4 INTEGER,d5 INTEGER,d6 INTEGER,d7 INTEGER,d8 INTEGER,d9 INTEGER,'
        'd10 INTEGER,d11 INTEGER,d12 INTEGER,d13 INTEGER,d14 INTEGER,d15 INTEGER,d16 INTEGER,d17 INTEGER,d18 INTEGER,'
        'h1 INTEGER,h2 INTEGER,h3 INTEGER,h4 INTEGER,h5 INTEGER,h6 INTEGER,h7 INTEGER,h8 INTEGER,h9 INTEGER,'
        'h10 INTEGER,h11 INTEGER,h12 INTEGER,h13 INTEGER,h14 INTEGER,h15 INTEGER,h16 INTEGER,h17 INTEGER,h18 INTEGER)');
    print('[DBLocal] _createTableClubesCanchasTees: Success');
    return;
  }

  Future<void> _dropTableClubes(Database db) async {
    await db.execute(
      'DROP TABLE clubes',
    );
    return;
  }

  Future<void> _createTableClubes(Database db) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS clubes (id INTEGER PRIMARY KEY AUTOINCREMENT,'
        ' par TEXT , slope TEXT, course_rating TEXT, nombre TEXT, id_localidad TEXT, id_provincia TEXT, id_pais TEXT, imagen TEXT, '
        ' logo TEXT, id_club TEXT, id_club_cancha TEXT, nombre_club TEXT, telefono TEXT, dir_calle TEXT, dir_numero TEXT, dir_cp TEXT, geolocalizacion TEXT)');
    print('[DBLocal] _createTableClubes: Success');
    return;
  }

  void dbUserInsert(PostUser postUser) async {
    var dbClient = await db;
    await dbClient.transaction((trans) async {
      return await trans.rawInsert(
        'INSERT INTO user(idjuga_arg, matricula , nombre_juga , hcp , hcp3 ,celular , email ,idclub , sexo, images, pais_juga, level_security, token) ' +
            ' VALUES(\' ${postUser.idjuga_arg}\', \' ${postUser.matricula}\', \' ${postUser.nombre_juga}\', \' ${postUser.hcp}\', \' ${postUser.hcp3}\', \' ${postUser.celular}\', \' ${postUser.email}\', \' ${postUser.idclub}\', \' ${postUser.sexo}\', \' ${postUser.images}\', \' ${postUser.pais_juga}\', \' ${postUser.level_security}\', \' ${postUser.token}\')',
      );
    });
    print('[DBLocal] saveUser: Success | ${postUser.nombre_juga}');
  }

  Future<void> dbUserDropTable() async {
    var dbClient = await db;
    await dbClient.execute(
      'DROP TABLE user',
    );

//    await dbClient.transaction((trans) async {
//      var vRet = await trans.delete('user', where: 'id>=?', whereArgs: [0]);
//    });
    print('[DBLocal] Truncate: Success OTRO');
  }

  void dbUserTrubate() async {
    var dbClient = await db;
    await dbClient.transaction((trans) async {
      var vRet = await trans.delete('user', where: 'id>=?', whereArgs: [0]);
    });
    print('[DBLocal] Truncate: Success ');
  }

  void dbUserTruncate() async {
    var dbClient = await db;
    await _deleteTableUser(dbClient);
    print('[DBLocal] Truncate: Success ');
  }

  Future<PostUser> dbUserGetN() async {
    var dbClient = await db;
    PostUser postUser = null;

    List<Map<String, dynamic>> queryList = await dbClient.rawQuery(
      'SELECT * FROM user limit 1 ',
    );

    //List<Map> queryList = await dbClient.rawQuery('SELECT * FROM user limit 1 ', );

    print('[DBLocal] getUser: ${queryList.length} users');
    if (queryList != null && queryList.length > 0) {
      //print(queryList);
      List<PostUser> postUsers = (queryList.cast<Map<String, dynamic>>())
          .map<PostUser>((queryList) => PostUser.fromJson(queryList))
          .toList();
      postUser = postUsers[0];
      print('[DBLocal] getUser: ${postUser.nombre_juga}');
      return postUser;
    } else {
      print('[DBLocal] getUser: User is null');
      return postUser;
    }
  }

  Future<PostUser> dbUserGet() async {
    var dbClient = await db;
    PostUser postUser = null;
    List<Map> queryList = await dbClient.rawQuery(
      'SELECT * FROM user limit 1 ',
    );
    //print(queryList);
    print('[DBLocal] getUser: ${queryList.length} users');
    if (queryList != null && queryList.length > 0) {
      for (int i = 0; i < queryList.length; i++) {
        postUser = new PostUser(
          idjuga_arg: queryList[i]['idjuga_arg'].toString().trim(),
          matricula: queryList[i]['matricula'].toString().trim(),
          nombre_juga: queryList[i]['nombre_juga'].toString().trim(),
          hcp: queryList[i]['hcp'].toString().trim(),
          hcp3: queryList[i]['hcp3'].toString().trim(),
          celular: queryList[i]['celular'].toString().trim(),
          email: queryList[i]['email'].toString().trim(),
          idclub: queryList[i]['idclub'].toString().trim(),
          sexo: queryList[i]['sexo'].toString().trim(),
          images: UserFunctions.IsDamaImage(
              queryList[i]['images'].toString().trim(),
              queryList[i]['sexo'].toString().trim()),
          pais_juga: queryList[i]['pais_juga'].toString().trim(),
          level_security:
              int.parse(queryList[i]['level_security'].toString().trim()),
          token: queryList[i]['token'].toString().trim(),
        );
      }
      print('[DBLocal] getUser: ${postUser.nombre_juga}');
      return postUser;
    } else {
      print('[DBLocal] getUser: User is null');
      return postUser;
    }
  }

  void dbTorneoTruncate() async {
    var dbClient = await db;
    //_dropTabletorneos(dbClient);
    await dbClient.transaction((trans) async {
      var vRet = await trans.delete('torneos', where: 'id>=?', whereArgs: [0]);
    });
    print('[DBLocal] Torneo Truncate: Success ');
  }

  void dbTorneoInsert(PostTorneo postTorneo) async {
    var dbClient = await db;
    await dbClient.transaction((trans) async {
      return await trans.rawInsert(
        "INSERT INTO torneos(id_torneo ,id_club ,id_club_cancha , id_user ,codigo_torneo ,id_origen ,title, sub_title ,game_mode  ,batches_count ,"
        " batches_holes ,difficulty_day, start_date ,game_started ,closed_time ,id_torneo_federacion ,"
        " alta_time ,alta_user ,mod_time ,mod_user ,modalidad ,club ,cancha ,geolocalizacion ) "
        " VALUES('${postTorneo.id_torneo}', '${postTorneo.id_club}', '${postTorneo.id_club_cancha}', '${postTorneo.id_user}', '${postTorneo.codigo_torneo}', '${postTorneo.id_origen}', '${postTorneo.title}', '${postTorneo.sub_title}', '${postTorneo.game_mode}', '${postTorneo.batches_count}',"
        " '${postTorneo.batches_holes}', '${postTorneo.difficulty_day}', '${postTorneo.start_date}', '${postTorneo.game_started}', '${postTorneo.closed_time}', '${postTorneo.id_torneo_federacion}',"
        " '${postTorneo.alta_time}', '${postTorneo.alta_user}', '${postTorneo.mod_time}', '${postTorneo.mod_user}', '${postTorneo.modalidad}', '${postTorneo.club}', '${postTorneo.cancha}', '${postTorneo.geolocalizacion}')",
      );
    });
    print('[DBLocal] saveUser: Success | ${postTorneo.codigo_torneo}');
  }

  Future<PostTorneo> dbTorneoGet(int idTorneo) async {
    var dbClient = await db;
    PostTorneo postTorneo = null;
    List<Map<String, dynamic>> queryList = await dbClient.rawQuery(
      "SELECT * FROM torneos where id_torneo='" +
          idTorneo.toString() +
          "' limit 1 ",
    );
    print('[DBLocal] dbTorneoGet: ${queryList.length} Torneos');
    if (queryList != null && queryList.length > 0) {
      List<PostTorneo> postTorneos =
          queryList.map((c) => PostTorneo.fromJson2(c)).toList();
      postTorneo = postTorneos[0];
      List<Map<String, dynamic>> queryListPTees = await dbClient.rawQuery(
        "SELECT * FROM clubes_canchas_tees where id_club_cancha='" +
            postTorneo.id_club_cancha.toString() +
            "'  ",
      );
      List<Map<String, dynamic>> queryListPgeo = await dbClient.rawQuery(
        "SELECT * FROM clubes_canchas_geo where id_club_cancha='" +
            postTorneo.id_club_cancha.toString() +
            "'  ",
      );
      print('[DBLocal] dbTorneoGet: ${queryListPTees.length} queryListPTees');
      if (queryListPTees != null && queryListPTees.length > 0) {
        postTorneo.tees =
            queryListPTees.map((c) => PostTee.fromJson(c)).toList();
      }
      List<Map<String, dynamic>> queryListPClub = await dbClient.rawQuery(
        "SELECT * FROM clubes where id_club_cancha='" +
            postTorneo.id_club_cancha.toString() +
            "'  ",
      );
      print('[DBLocal] dbTorneoGet: ${queryListPClub.length} queryListPClub');
      if (queryListPClub != null && queryListPClub.length > 0) {
        List<PostClub> postClubes =
            queryListPClub.map((c) => PostClub.fromJson(c)).toList();
        postTorneo.postClub = postClubes[0];
      }

      return postTorneo;
    } else {
      print('[DBLocal] dbTorneoGet: User is null');
      return postTorneo;
    }
  }

  void dbTarjetaInsert(
      List<DataJugadorScore> jugadoresScore, int idTorneo, int idUser) async {
    var dbClient = await db;
    var vRet = dbClient.transaction((txn) async {
      Batch batch = txn.batch();
      for (DataJugadorScore juT in jugadoresScore) {
        Map<String, dynamic> row = {
          'id_torneo': idTorneo,
          'id_club_cancha_tee': juT.postTee.id_club_cancha_tee,
          'id_user': idUser,
          'fecha': Fecha.fechaHoyAnsiSql,
          'matricula': juT.matricula,
          'nombre_juga': juT.nombre_juga,
          'hcp_index': juT.hcpIndex,
          'images': juT.images,
          'hcp_torneo': juT.hcpTorneo,
          'path_tee_color': juT.pathTeeColor,
          'ida': juT.ida,
          'vuelta': juT.vuelta,
          'gross': juT.gross,
          'neto': juT.neto,
          'neto_al_par': juT.netoAlPar,
          'stableford': juT.stableford,
          'stableford_ida': juT.stablefordIda,
          'stableford_vuelta': juT.stablefordVuelta,
          'sexo': juT.sexo,
          'role': juT.role,
          'firma_user_image': base64.encode(juT.firmaUserImage),
          'firma_marcador_matricula': juT.firmaMarcadorMatricula,
          'firma_marcador_image': base64.encode(juT.firmaMarcadorImage)
        };
        batch.insert('tarjeta_jugadores', row);

        Map<String, dynamic> rowTee = {
          'id_torneo': idTorneo,
          'id_user': idUser,
          'fecha': Fecha.fechaHoyAnsiSql,
          'matricula': juT.matricula,
          'id_club_cancha_tee': juT.postTee.id_club_cancha_tee,
          'id_club_cancha': juT.postTee.id_club_cancha,
          'start': juT.postTee.start,
          'tee': juT.postTee.tee,
          'category': juT.postTee.category,
          'ida_9h_course_rating': juT.postTee.ida_9h_course_rating,
          'ida_9h_slope': juT.postTee.ida_9h_slope,
          'vta_9h_course_rating': juT.postTee.vta_9h_course_rating,
          'vta_9h_slope': juT.postTee.vta_9h_slope,
          'course_rating': juT.postTee.course_rating,
          'slope': juT.postTee.slope,
          'yards': juT.postTee.yards,
          'par': juT.postTee.par,
          'p1': juT.postTee.p1,
          'p2': juT.postTee.p2,
          'p3': juT.postTee.p3,
          'p4': juT.postTee.p4,
          'p5': juT.postTee.p5,
          'p6': juT.postTee.p6,
          'p7': juT.postTee.p7,
          'p8': juT.postTee.p8,
          'p9': juT.postTee.p9,
          'p10': juT.postTee.p10,
          'p11': juT.postTee.p11,
          'p12': juT.postTee.p12,
          'p13': juT.postTee.p13,
          'p14': juT.postTee.p14,
          'p15': juT.postTee.p15,
          'p16': juT.postTee.p16,
          'p17': juT.postTee.p17,
          'p18': juT.postTee.p18,
          'd1': juT.postTee.d1,
          'd2': juT.postTee.d2,
          'd3': juT.postTee.d3,
          'd4': juT.postTee.d4,
          'd5': juT.postTee.d5,
          'd6': juT.postTee.d6,
          'd7': juT.postTee.d7,
          'd8': juT.postTee.d8,
          'd9': juT.postTee.d9,
          'd10': juT.postTee.d10,
          'd11': juT.postTee.d11,
          'd12': juT.postTee.d12,
          'd13': juT.postTee.d13,
          'd14': juT.postTee.d14,
          'd15': juT.postTee.d15,
          'd16': juT.postTee.d16,
          'd17': juT.postTee.d17,
          'd18': juT.postTee.d18,
          'h1': juT.postTee.h1,
          'h2': juT.postTee.h2,
          'h3': juT.postTee.h3,
          'h4': juT.postTee.h4,
          'h5': juT.postTee.h5,
          'h6': juT.postTee.h6,
          'h7': juT.postTee.h7,
          'h8': juT.postTee.h8,
          'h9': juT.postTee.h9,
          'h10': juT.postTee.h10,
          'h11': juT.postTee.h11,
          'h12': juT.postTee.h12,
          'h13': juT.postTee.h13,
          'h14': juT.postTee.h14,
          'h15': juT.postTee.h15,
          'h16': juT.postTee.h16,
          'h17': juT.postTee.h17,
          'h18': juT.postTee.h18,
        };
        batch.insert('tarjeta_jugadores_tee', rowTee);

        List<DataHoyoJuego> postHoyos = juT.hoyos;
        for (DataHoyoJuego juH in postHoyos) {
          Map<String, dynamic> rowHoyo = {
            'id_torneo': idTorneo,
            'id_user': idUser,
            'matricula': juT.matricula,
            'hoyoNro': juH.hoyoNro,
            'distancia': juH.distancia,
            'par': juH.par,
            'handicap': juH.handicap,
            'golpesHcp': juH.golpesHcp,
            'score': juH.score,
            'score_state': juH.scoreState,
            'score_ctrol': juH.scoreCtrol,
            'neto': juH.neto,
            'stableford': juH.stableford,
          };
          batch.insert('tarjeta_jugadores_hoyos', rowHoyo);
        }
      }
      batch.commit();
    });
  }

  void dbTarjetaTruncate() async {
    var dbClient = await db;
    await dbClient.transaction((trans) async {
      Batch batch = trans.batch();
      var vRet =
          batch.delete('tarjeta_jugadores', where: 'id>=?', whereArgs: [0]);
      var vRet2 = batch
          .delete('tarjeta_jugadores_hoyos', where: 'id>=?', whereArgs: [0]);
      var vRet3 =
          batch.delete('tarjeta_jugadores_tee', where: 'id>=?', whereArgs: [0]);
      var vRet4 = batch.delete('clubes', where: 'id>=?', whereArgs: [0]);
      var vRet5 =
          batch.delete('clubes_canchas_tees', where: 'id>=?', whereArgs: [0]);
      batch.commit();
    });
    print('[DBLocal] Truncate Tarjetas++: Success ');
  }

  void dbTarjetaUpdateScore(
      String id_torneo,
      String idjuga_arg,
      String matricula,
      int hoyoNro,
      int score,
      int scoreState,
      int scoreCtrol,
      int neto,
      int stableford) async {
    var dbClient = await db;
    await dbClient.transaction((trans) async {
      Batch batch = trans.batch();

      Map<String, dynamic> row = {
        'score': score,
        'score_state': scoreState,
        'score_ctrol': scoreCtrol,
        'neto': neto,
        'stableford': stableford
      };

      batch.update('tarjeta_jugadores_hoyos', row,
          where:
              'id_torneo = ? and id_user = ? and matricula = ? and hoyoNro = ? ',
          whereArgs: [id_torneo, idjuga_arg, matricula, hoyoNro]);

      batch.commit();
    });
    print('[DBLocal] dbTarjetaUpdateScore: Success ');
  }

  Future<List<DataJugadorScore>> dbGetTarjetasScore(
      String matricula, DateTime fechaHoy) async {
    var dbClient = await db;
    List<DataJugadorScore> dataJugadoresScore = null;
    List<Map<String, dynamic>> queryListTJ = await dbClient.rawQuery(
      "SELECT * FROM tarjeta_jugadores where id_user='" +
          matricula +
          "' and fecha='" +
          Fecha.toAnsiSql(fechaHoy) +
          "' order by id ",
    );
    print('[DBLocal] getTarjetaScore: ${queryListTJ.length} ');
    if (queryListTJ != null && queryListTJ.length > 0) {
      List<DataJugadorScore> dataJugadoresScore =
          queryListTJ.map((c) => DataJugadorScore.fromJson2(c)).toList();

      for (int idx = 0; idx < dataJugadoresScore.length; idx++) {
        var idTorneo = dataJugadoresScore[idx].idTorneo;
        var matricula = dataJugadoresScore[idx].matricula;
        //traer el tee
        List<Map<String, dynamic>> queryListTJT = await dbClient.rawQuery(
          "SELECT * FROM tarjeta_jugadores_tee where id_torneo='" +
              idTorneo.toString() +
              "' and matricula='" +
              matricula +
              "' and fecha='" +
              Fecha.toAnsiSql(fechaHoy) +
              "' limit 1 ",
        );
        if (queryListTJT != null && queryListTJT.length > 0) {
          List<PostTee> postTees =
              queryListTJT.map((c) => PostTee.fromJson(c)).toList();
          dataJugadoresScore[idx].postTee = postTees[0];
        }

        dataJugadoresScore[idx].addHoyos(dataJugadoresScore[idx]);

        //traer los scores

        List<Map> queryListSC = await dbClient.rawQuery(
          "SELECT * FROM tarjeta_jugadores_hoyos where id_torneo='" +
              idTorneo.toString() +
              "' and matricula='" +
              matricula +
              "' ",
        );

        if (queryListSC != null && queryListSC.length > 0) {
          for (int i = 0; i < queryListSC.length; i++) {
            //DataHoyoJuego dataHoyoJuego
            dataJugadoresScore[idx].setScoreNotDB(
                int.parse(queryListSC[i]['hoyoNro'].toString()),
                int.parse(queryListSC[i]['score'].toString()));
          }
        }
      }

      return dataJugadoresScore;
    } else {
      print('[DBLocal] getTarjetaScore: getTarjetaScore is null');
      return dataJugadoresScore;
    }
  }

  void dbClubInsert(PostClub postClub) {}
  void dbClubTeesInsert(List<PostTee> postTees) {}
  void dbClubAndTeesInsert(PostClub postClub, List<PostTee> postTees) async {
    var dbClient = await db;
    var vRet = dbClient.transaction((txn) async {
      Batch batch = txn.batch();

      batch.delete('clubes', where: 'id>=?', whereArgs: [0]);
      batch.delete('clubes_canchas_tees', where: 'id>=?', whereArgs: [0]);

      Map<String, dynamic> row = {
        'par': postClub.par,
        'slope': postClub.slope,
        'course_rating': postClub.course_rating,
        'nombre': postClub.nombre,
        'id_localidad': postClub.id_localidad,
        'id_provincia': postClub.id_provincia,
        'id_pais': postClub.id_pais,
        'imagen': postClub.imagen,
        'logo': postClub.logo,
        'id_club': postClub.id_club,
        'id_club_cancha': postClub.id_club_cancha,
        'nombre_club': postClub.nombre_club,
        'telefono': postClub.telefono,
        'dir_calle': postClub.dir_calle,
        'dir_numero': postClub.dir_numero,
        'dir_cp': postClub.dir_cp,
        'geolocalizacion': postClub.geolocalizacion,
      };
      batch.insert('clubes', row);

      for (PostTee postTee in postTees) {
        Map<String, dynamic> rowTee = {
          'id_club_cancha_tee': postTee.id_club_cancha_tee,
          'id_club_cancha': postTee.id_club_cancha,
          'start': postTee.start,
          'tee': postTee.tee,
          'category': postTee.category,
          'ida_9h_course_rating': postTee.ida_9h_course_rating,
          'ida_9h_slope': postTee.ida_9h_slope,
          'vta_9h_course_rating': postTee.vta_9h_course_rating,
          'vta_9h_slope': postTee.vta_9h_slope,
          'course_rating': postTee.course_rating,
          'slope': postTee.slope,
          'yards': postTee.yards,
          'par': postTee.par,
          'p1': postTee.p1,
          'p2': postTee.p2,
          'p3': postTee.p3,
          'p4': postTee.p4,
          'p5': postTee.p5,
          'p6': postTee.p6,
          'p7': postTee.p7,
          'p8': postTee.p8,
          'p9': postTee.p9,
          'p10': postTee.p10,
          'p11': postTee.p11,
          'p12': postTee.p12,
          'p13': postTee.p13,
          'p14': postTee.p14,
          'p15': postTee.p15,
          'p16': postTee.p16,
          'p17': postTee.p17,
          'p18': postTee.p18,
          'd1': postTee.d1,
          'd2': postTee.d2,
          'd3': postTee.d3,
          'd4': postTee.d4,
          'd5': postTee.d5,
          'd6': postTee.d6,
          'd7': postTee.d7,
          'd8': postTee.d8,
          'd9': postTee.d9,
          'd10': postTee.d10,
          'd11': postTee.d11,
          'd12': postTee.d12,
          'd13': postTee.d13,
          'd14': postTee.d14,
          'd15': postTee.d15,
          'd16': postTee.d16,
          'd17': postTee.d17,
          'd18': postTee.d18,
          'h1': postTee.h1,
          'h2': postTee.h2,
          'h3': postTee.h3,
          'h4': postTee.h4,
          'h5': postTee.h5,
          'h6': postTee.h6,
          'h7': postTee.h7,
          'h8': postTee.h8,
          'h9': postTee.h9,
          'h10': postTee.h10,
          'h11': postTee.h11,
          'h12': postTee.h12,
          'h13': postTee.h13,
          'h14': postTee.h14,
          'h15': postTee.h15,
          'h16': postTee.h16,
          'h17': postTee.h17,
          'h18': postTee.h18,
        };
        batch.insert('clubes_canchas_tees', rowTee);
      }
      batch.commit();
    });
  }

  void closeDB() async {
    var dbClient = await db;
    await clearDB();
    await dbClient.close();
    _db = null;
  }

  void saveImageFirma(Uint8List firma, int idTorneo, int idUser,
      String matricula, String matriculas) async {
    var dbClient = await db;
    await dbClient.transaction((trans) async {
      Batch batch = trans.batch();

      Map<String, dynamic> rowT = {
        'firma_user_image': base64.encode(firma),
      };
      batch.update('tarjeta_jugadores', rowT,
          where:
              'id_torneo = ? and matricula = ? ', //'id_torneo = ? and id_user = ? and matricula = ? ',
          whereArgs: [idTorneo, matricula]);
      if (matriculas.length >= 1) {
        Map<String, dynamic> row = {
          'firma_marcador_image': base64.encode(firma),
          'firma_marcador_matricula': matricula
        };
        //id_torneo = ? and id_user = ? and matricula in (
        batch.update('tarjeta_jugadores', row,
            where: 'id_torneo = ? and matricula in (' +
                matriculas +
                ') ',
            whereArgs: [idTorneo, idUser]);
      }
      batch.commit();
    });
    print('[DBLocal] dbTarjetaUpdateFirmas: Success ');
  }
}
