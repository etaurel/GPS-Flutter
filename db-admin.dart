import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/src/widgets/editable_text.dart';
import 'package:golfguidescorecard/models/model.dart';
import 'package:golfguidescorecard/models/postTorneo.dart';
import 'package:golfguidescorecard/scoresCard/torneo.dart';
import 'package:golfguidescorecard/services/api-cfg.dart';
import 'package:golfguidescorecard/services/db-api.dart';
import 'package:golfguidescorecard/services/service.dart';
import 'package:golfguidescorecard/utilities/fecha.dart';
import 'package:golfguidescorecard/utilities/functions.dart';
import 'package:golfguidescorecard/utilities/global-data.dart';

class DBAdmin {
  static void dbTarjetaInitialize(List<DataJugadorScore> dataJugadoresScore,
      int idTorneo, int idUser) async {
    /// BORRAR TODAS LA TARJETAS DEL USUARIO LOCALMENTE
    /// db local

    GlobalData.dbConn.dbTarjetaTruncate();
    try {
      await GlobalData.dbConn.dbTarjetaInsert(dataJugadoresScore, idTorneo, idUser);
    } on Exception catch (e, s) {
//      print('--------------------yyyyyyyyyyyyyyyyy--------------------------------------------');
      throw s;

    }

    /// BORRAR TODAS LA TARJETAS QUE EL USUARIO DIO DE ALTA
    /// db mysql

    print('<<<<<<<<<<<<<<<<<db mysql>>>>>>>>>>>>>>>>>>>>');
    try {
      await DBApi.TarjetaInitialize(dataJugadoresScore, idTorneo, idUser);
    } on Exception catch (e, s) {
//      print('--------------------yyyyyyyyyyyyyyyyy--------------------------------------------');
//      print(s);
      throw s;
    }
  }

  static void TarjetaUpdateScore(
      String id_torneo,
      String idjuga_arg,
      String matricula,
      int hoyoNro,
      int score,
      int scoreState,
      int scoreCtrol,
      int neto,
      int stableford) {

    GlobalData.dbConn.dbTarjetaUpdateScore(id_torneo, idjuga_arg, matricula,
        hoyoNro, score, scoreState, scoreCtrol, neto, stableford);

    DBApi.TarjetaUpdateScore(id_torneo, idjuga_arg, matricula,
        hoyoNro, score, scoreState, scoreCtrol, neto, stableford);

  }

  static Future<List<DataJugadorScore>>  getTarjetaJuego(String matricula, DateTime fechaHoy) async {

    return await GlobalData.dbConn.dbGetTarjetasScore(matricula, fechaHoy);

  }
  static Future<PostTorneo> dbTorneoGet(int idTorneo) async {
    return await GlobalData.dbConn.dbTorneoGet(idTorneo);
  }

  static Future<void> dbTorneoInsert(PostTorneo postTorneo) async {

    GlobalData.dbConn.dbTorneoInsert(postTorneo);
    // Torneo.dataJugadoresScore = dataJugadoresScore;
    Torneo.dataJugadoresScore = await DBApi.getTarjetasScorexFecha(GlobalData.postUser.idjuga_arg, Fecha.fechaHoy);

  }

  static void saveImageFirma(Uint8List firma, int idTorneo, int idUser, String matricula, String matriculas) {
    GlobalData.dbConn.saveImageFirma(firma, idTorneo, idUser, matricula, matriculas);
    DBApi.saveImageFirma(firma, idTorneo, idUser, matricula, matriculas);

  }

  static Future<void> getFirmaMarcador(DataJugadorScore dSCJugador, int idTorneo, int idUser, String matricula_marcador) async {

    // TODO TRATAR DE UTILIZAR PRIMERO LA DB LOCAL
    Map<String, dynamic> rowData= await DBApi.getFirmaMarcador(idTorneo, idUser, matricula_marcador);

    if (rowData==null){
      return;
    }else {
      print(dSCJugador.role);
      if (dSCJugador.role==1) {
        dSCJugador.firmaMarcadorImage =
            base64.decode(rowData['firma_marcador_image']);
        dSCJugador.firmaMarcadorMatricula = rowData['firma_marcador_matricula'];
      }else{
        dSCJugador.firmaUserImage =
            base64.decode(rowData['firma_marcador_image']);

      }
    }
  }

  static Future<void> userUpdateCelEmail(TextEditingController controllerNombre, TextEditingController controllerSexo, TextEditingController controllerHcp, TextEditingController controllerCelular, TextEditingController controllerEmail, String matricula) async {
    await DBApi.userUpdateCelEmail(matricula, controllerNombre.text, controllerSexo.text, controllerHcp.text, controllerCelular.text, controllerEmail.text);
    GlobalData.postUser.nombre_juga=controllerNombre.text;
    GlobalData.postUser.sexo=controllerSexo.text;
    GlobalData.postUser.hcp=controllerHcp.text;
    GlobalData.postUser.celular=controllerCelular.text;
    GlobalData.postUser.email=controllerEmail.text;
    GlobalData.dbConn.dbUserTrubate();
    GlobalData.dbConn.dbUserInsert(GlobalData.postUser);

  }
  static Future<void> userUpdatePass(TextEditingController controllerPass, String matricula, String email) async {
    String pass_m=generateMd5(matricula.trim().toUpperCase()+controllerPass.text.trim());
    String pass_e=generateMd5(email.trim().toUpperCase()+controllerPass.text.trim());
    await DBApi.userUpdatePass(matricula, pass_m, pass_e);
  }
}


// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:flutter/src/widgets/editable_text.dart';
// import 'package:golfguidescorecard/models/model.dart';
// import 'package:golfguidescorecard/models/postTorneo.dart';
// import 'package:golfguidescorecard/scoresCard/torneo.dart';
// import 'package:golfguidescorecard/services/api-cfg.dart';
// import 'package:golfguidescorecard/services/db-api.dart';
// import 'package:golfguidescorecard/services/service.dart';
// import 'package:golfguidescorecard/utilities/fecha.dart';
// import 'package:golfguidescorecard/utilities/functions.dart';
// import 'package:golfguidescorecard/utilities/global-data.dart';
//
// class DBAdmin {
//   static void dbTarjetaInitialize(List<DataJugadorScore> dataJugadoresScore,
//       int idTorneo, int idUser) async {
//     /// BORRAR TODAS LA TARJETAS DEL USUARIO LOCALMENTE
//     /// db local
//
//     GlobalData.dbConn.dbTarjetaTruncate();
//     try {
//       await GlobalData.dbConn.dbTarjetaInsert(dataJugadoresScore, idTorneo, idUser);
//     } on Exception catch (e, s) {
// //      print('--------------------yyyyyyyyyyyyyyyyy--------------------------------------------');
//       throw s;
//
//     }
//
//     /// BORRAR TODAS LA TARJETAS QUE EL USUARIO DIO DE ALTA
//     /// db mysql
//
//     print('<<<<<<<<<<<<<<<<<db mysql>>>>>>>>>>>>>>>>>>>>');
//     try {
//       await DBApi.TarjetaInitialize(dataJugadoresScore, idTorneo, idUser);
//     } on Exception catch (e, s) {
// //      print('--------------------yyyyyyyyyyyyyyyyy--------------------------------------------');
// //      print(s);
//       throw s;
//     }
//   }
//
//   static void TarjetaUpdateScore(
//       String id_torneo,
//       String idjuga_arg,
//       String matricula,
//       int hoyoNro,
//       int score,
//       int scoreState,
//       int scoreCtrol,
//       int neto,
//       int stableford) {
//
//     GlobalData.dbConn.dbTarjetaUpdateScore(id_torneo, idjuga_arg, matricula,
//         hoyoNro, score, scoreState, scoreCtrol, neto, stableford);
//
//     DBApi.TarjetaUpdateScore(id_torneo, idjuga_arg, matricula,
//         hoyoNro, score, scoreState, scoreCtrol, neto, stableford);
//
//   }
//
//   static Future<List<DataJugadorScore>>  getTarjetaJuego(String matricula, DateTime fechaHoy) async {
//
//     return await GlobalData.dbConn.dbGetTarjetasScore(matricula, fechaHoy);
//
//   }
//   static Future<PostTorneo> dbTorneoGet(int idTorneo) async {
//     return await GlobalData.dbConn.dbTorneoGet(idTorneo);
//   }
//
//   static Future<void> dbTorneoInsert(PostTorneo postTorneo) async {
//
//     GlobalData.dbConn.dbTorneoInsert(postTorneo);
//     // Torneo.dataJugadoresScore = dataJugadoresScore;
//     Torneo.dataJugadoresScore = await DBApi.getTarjetasScorexFecha(GlobalData.postUser.idjuga_arg, Fecha.fechaHoy);
//
//   }
//
//   static void saveImageFirma(Uint8List firma, int idTorneo, int idUser, String matricula, String matriculas) {
//     GlobalData.dbConn.saveImageFirma(firma, idTorneo, idUser, matricula, matriculas);
//     DBApi.saveImageFirma(firma, idTorneo, idUser, matricula, matriculas);
//
//   }
//
//   static Future<void> getFirmaMarcador(DataJugadorScore dSCJugador, int idTorneo, int idUser, String matricula_marcador) async {
//
//     // TODO TRATAR DE UTILIZAR PRIMERO LA DB LOCAL
//     Map<String, dynamic> rowData= await DBApi.getFirmaMarcador(idTorneo, idUser, matricula_marcador);
//
//     if (rowData==null){
//       return;
//     }else {
//       print(dSCJugador.role);
//       if (dSCJugador.role==1) {
//         dSCJugador.firmaMarcadorImage =
//             base64.decode(rowData['firma_marcador_image']);
//         dSCJugador.firmaMarcadorMatricula = rowData['firma_marcador_matricula'];
//       }else{
//         dSCJugador.firmaUserImage =
//             base64.decode(rowData['firma_marcador_image']);
//
//       }
//     }
//   }
//
//   static Future<void> userUpdateCelEmail(TextEditingController controllerCelular, TextEditingController controllerEmail, String matricula) async {
//     await DBApi.userUpdateCelEmail(matricula, controllerCelular.text, controllerEmail.text);
//     GlobalData.postUser.celular=controllerCelular.text;
//     GlobalData.postUser.email=controllerEmail.text;
//     GlobalData.dbConn.dbUserTrubate();
//     GlobalData.dbConn.dbUserInsert(GlobalData.postUser);
//
//   }
//   static Future<void> userUpdatePass(TextEditingController controllerPass, String matricula, String email) async {
//     String pass_m=generateMd5(matricula.trim().toUpperCase()+controllerPass.text.trim());
//     String pass_e=generateMd5(email.trim().toUpperCase()+controllerPass.text.trim());
//     await DBApi.userUpdatePass(matricula, pass_m, pass_e);
//   }
// }
