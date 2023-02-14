import 'dart:async';
import 'package:connection_status_bar/connection_status_bar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:golfguidescorecard/gps/hoyo_V1.dart';
import 'package:golfguidescorecard/gps/hoyo_V2.dart';
import 'package:golfguidescorecard/gps/hoyo_V3.dart';
import 'package:golfguidescorecard/gps/hoyo_V4.dart';
import 'package:golfguidescorecard/gps/hoyo_V5.dart';
import 'package:golfguidescorecard/mod_serv/model.dart';
import 'package:golfguidescorecard/models/postTorneo.dart';
import 'package:golfguidescorecard/scoresCard/agregarJugadoresPractica.dart';
import 'package:golfguidescorecard/scoresCard/practica.dart';
import 'package:golfguidescorecard/scoresCard/tablaResultadosSF.dart';
import 'package:golfguidescorecard/services/db-admin.dart';
import 'package:golfguidescorecard/utilities/display-functions.dart';
import 'package:golfguidescorecard/utilities/global-data.dart';
import 'package:golfguidescorecard/utilities/language/lan.dart';
import 'package:golfguidescorecard/utilities/messages-toast.dart';
import 'package:golfguidescorecard/utilities/user-funtions.dart';
import 'package:page_transition/page_transition.dart';
import 'package:golfguidescorecard/herramientas/bottonNavigator.dart';
import 'package:golfguidescorecard/scoresCard/tablaResultados.dart';

class ScoreCardPractica extends StatefulWidget {
  //PostUser postUser;
  ScoreCardPractica() : super();
  @override
  ScoreCardPracticaState createState() => ScoreCardPracticaState();
}

//class ScoreCardPracticaState extends State<ScoreCardPractica> {
class ScoreCardPracticaState extends State<ScoreCardPractica> with WidgetsBindingObserver {
  bool _controlClickPress=false;
  MessagesToast mToast;
  Lan lan = new Lan();
  AppLifecycleState _notification;
  bool _estadoFrmIsOk = true;
  PostUser postUser;
  PostPractica postPractica;
  ScoreCardPracticaState();
  List<DataJugadorScore> _practicaJugadoresScore = [];
  GlobalKey<ScaffoldState> _scaffoldKey;
  List<TextEditingController> _controllerHoyo = [];
  bool _isupdating;

  int _id_practica = 0;
  int _id_user = 0;
  String _matriculas = '';

  @override
  void dispose() {
    Practica.practicaJugadoresScore = _practicaJugadoresScore;

    print('lost focus in dispose');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

//  @override
//  void deactivate() {
//    print('---- deactivate ');
//    super.deactivate();
//  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:

        print("------------------------------------app in resumed");
        break;
      case AppLifecycleState.inactive:

        print("----------------------------------------------app in inactive");
        break;
      case AppLifecycleState.paused:
        print("------------------------------------------------app in paused");
        break;
      case AppLifecycleState.detached:
        print("----------------------------------------------app in detached");
        break;
    }
    setState(() {
      _notification = state;
    });
  }

  @override
  Future<void> initState() {
    super.initState();

    this.postUser = GlobalData.postUser;
    postPractica = Practica.postPracticaJuego;

    /// VERIFICAR SI HAY TARJETAS ACTIVAS
    ///
    if (Practica.practicaJugadoresScore == null) {
      print('VOLVER NO HAY Jugadores');
      Navigator.of(context).pop();
    } else {
      _practicaJugadoresScore = Practica.practicaJugadoresScore;
      _practicaJugadoresScore.forEach((jugador) {
        _controllerHoyo.add(TextEditingController());
        _controllerHoyo[_controllerHoyo.length - 1].text = '';
      });

    }
    _id_practica = int.parse(Practica.postPracticaJuego.id_torneo);
    _id_user = int.parse(postUser.matricula);
    _practicaJugadoresScore.forEach((dJS) {
      if (_matriculas.length > 1) {
        _matriculas = _matriculas + ', ';
      }
      _matriculas = _matriculas + ' ' + dJS.matricula.trim();
    });

    _isupdating = false;
    //_scaffoldKey = RCKeys.rcKeyScoreCardPractica; // GlobalKey(); // key to get the context to show a SnackBar


    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    mToast = MessagesToast(context: context);
    var _marcadorData = {
      'ida': '',
      'vuelta': '',
      'gross': '',
      'hcp': '',
      'netoAlPar': ''
    };
    if (_practicaJugadoresScore.length > 1) {
      _marcadorData = {
        'ida': _practicaJugadoresScore[1].ida.toString(),
        'vuelta': _practicaJugadoresScore[1].vuelta.toString(),
        'gross': _practicaJugadoresScore[1].gross.toString(),
        'hcp': _practicaJugadoresScore[1].hcpTorneo.toString(),
        'netoAlPar':
            UserFunctions.scoreZeroToParE(_practicaJugadoresScore[1].netoAlPar)
      };
    }
    print('<<<<<<<<<<<<<<<<< score card Practica >>>>>>>>>>>>>>>>>>>');
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Color(0xFFE1E1E1),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Stack(
                  children: [
                    stackImage(
                        clubImage: Practica.postPracticaJuego.postClub.imagen,
                        clubLogo: Practica.postPracticaJuego.postClub.logo,
                        assetImage: 'assets/clubes/logocolor.png'),
                    Align(
                      alignment: Alignment.topCenter,
                      child: ConnectionStatusBar(),
                    ),
                  ],
                ),

                Container(
                  color: Color(0xFFDDDDDD),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        height: 20,
                        width: 160,
                        color: Colors.black54,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'JUGADOR',
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(),
                      ),
                      Container(
                        height: 20,
                        width: 160,
                        color: Colors.black45,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'MARCADOR',
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ), // NOMBRE JyM
                Container(
                  color: Color(0xFFE1E2E2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        height: 25,
                        width: 30,
                        color: Color(0xFF3C3C3C),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'IDA',
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 25,
                        width: 30,
                        color: Colors.black,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'VTA',
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 25,
                        width: 35,
                        color: Color(0xFF3C3C3C),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'GRS',
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 25,
                        width: 30,
                        color: Colors.black,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'HCP',
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 25,
                        width: 35,
                        color: Colors.black,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'TOT',
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(),
                      ),
                      Container(
                        height: 25,
                        width: 30,
                        color: Color(0xFF3C3C3C),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'IDA',
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 25,
                        width: 30,
                        color: Colors.black,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'VTA',
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 25,
                        width: 35,
                        color: Color(0xFF3C3C3C),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'GRS',
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 25,
                        width: 30,
                        color: Colors.black,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'HCP',
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 25,
                        width: 35,
                        color: Colors.black,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'TOT',
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ), // IDA VTA
                Container(
                  color: Color(0xFFEAEBEB),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        height: 30,
                        width: 30,
                        color: Colors.black12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              _practicaJugadoresScore[0].ida.toString(),
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 30,
                        color: Colors.black26,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              _practicaJugadoresScore[0].vuelta.toString(),
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 35,
                        color: Colors.black38,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              _practicaJugadoresScore[0].gross.toString(),
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 30,
                        color: Color(0xFFEAEBEB),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "${(double.parse(_practicaJugadoresScore[0].hcpTorneo.toString() ?? '')).toStringAsFixed(0)}",
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 35,
                        color: Colors.black,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              UserFunctions.scoreZeroToParE(
                                  _practicaJugadoresScore[0].netoAlPar),
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(),
                      ),
                      Container(
                        height: 30,
                        width: 30,
                        color: Colors.black12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              //UserFunctions.miif(_practicaJugadoresScore.length>1, _practicaJugadoresScore[(_practicaJugadoresScore.length-1)].ida, '')??'',
                              _marcadorData['ida'].toString() ?? '',
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 30,
                        color: Colors.black26,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              //_practicaJugadoresScore[1].vuelta.toString()??'',
                              _marcadorData['vuelta'].toString() ?? '',
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 35,
                        color: Colors.black38,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              //_practicaJugadoresScore[1].gross.toString()??'',
                              _marcadorData['gross'].toString() ?? '',
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 30,
                        color: Color(0xFFEAEBEB),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              //"${(double.parse(_practicaJugadoresScore[1].hcpTorneo.toString() ?? '')).toStringAsFixed(0)}",
                              _marcadorData['hcp'].toString() ?? '',
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 35,
                        color: Colors.black,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              //UserFunctions.scoreZeroToParE(_practicaJugadoresScore[1].netoAlPar),
                              _marcadorData['netoAlPar'] ?? '',
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ), // NUMEROS
                Container(
                  child: Row(
                    children: <Widget>[
                      /// Datos Matricula
                      DataTable(
                        columnSpacing: 30,
                        horizontalMargin: 10,
                        headingRowHeight: 110,
                        // headingRowHeight: 82,
                        dataRowHeight: 100,
                        columns: [
                          DataColumn(
                            label: Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 8),
                              child: Container(
                                width: 150,
                                alignment: Alignment.center,
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      alignment: Alignment.center,
                                      height: 24,
                                      // child: Text(
                                      //   'Haga Click en el Jugador',
                                      //   textScaleFactor: 1,
                                      //   textAlign: TextAlign.center,
                                      //   style: TextStyle(
                                      //       fontFamily: 'DIN Condensed',
                                      //       fontSize: 17,
                                      //       fontWeight: FontWeight.w700,
                                      //       color: Colors.black),
                                      // ),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
//                                    color: Colors.white,
                                      height: 20,
                                      width: 200,
                                      // child: Text(
                                      //   'para ver su ScoreCard',
                                      //   textScaleFactor: 1,
                                      //   textAlign: TextAlign.center,
                                      //   style: TextStyle(
                                      //       fontFamily: 'DIN Condensed',
                                      //       fontSize: 17,
                                      //       fontWeight: FontWeight.w700,
                                      //       color: Colors.black),
                                      // ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Lets add one more column to show a delete button
                        ],
                        rows: _practicaJugadoresScore
                            .map(
                              (jugador) => DataRow(cells: [
                                DataCell(
                                  Container(
                                      height: 70,
                                      width: 155,
                                      decoration: BoxDecoration(
//                                    color: Colors.black38,
                                        borderRadius: BorderRadius.circular(10),

                                      ),
//                                  padding: EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            height: 100,
                                            width: 8,
                                            decoration: BoxDecoration(
                                              color: UserFunctions
                                                  .resolverColorTee(
                                                      jugador.postTee.tee),
                                              //Colors.amber,
                                              border: Border.all(
                                                  color: Colors.black,
                                                  width: 0.5),
                                            ),
                                          ),
                                          Container(
                                            width: 3,
                                          ),
                                          CircleAvatar(
                                            radius: 25,
                                            backgroundImage: NetworkImage(
                                                jugador.images.trim() ?? ''),
                                            backgroundColor: Colors.black,
                                          ),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.only(left: 3),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  width: 90,
                                                  height: 20,
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    jugador.nombre_juga
                                                            .trim()??
                                                        '',
                                                    textScaleFactor: 1,
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'DIN Condensed',
                                                        fontSize: 19,
                                                        color: Colors.black),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ),
                                                Container(
                                                  width: 90,
                                                  height: 32,
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    jugador.matricula,
                                                    textScaleFactor: 1,
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'DIN Condensed',
                                                        fontSize: 35,
                                                        color: Colors.black),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                  onTap: () {
                                    _llamandoResultado(jugador, context);
                                  },
                                ),
                              ]),
                            )
                            .toList(),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Container(
                            child: _dataBody(),
                            width: MediaQuery.of(context).size.width - 175,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
//                Container(
//                  padding: EdgeInsets.only(left: 10, top: 5),
//                  height: 30,
//                  child: Row(
//                    children: <Widget>[
//                      Container(
//                        decoration: BoxDecoration(
//                          borderRadius: BorderRadius.circular(20),
//                          color: UserFunctions
//                              .colorCirculoScoreCardPendiente, //  Colors.amberAccent,
//                          border: Border.all(color: Colors.black, width: 0.3),
//                        ),
//                        height: 15,
//                        width: 15,
//                      ),
//                      Container(
//                        padding: EdgeInsets.only(left: 5, right: 5),
//                        child: Text(
//                          'Falta Score',
//                          style: TextStyle(fontSize: 12),
//                          textScaleFactor: 1,
//                        ),
//                      ),
//                      Container(
//                        decoration: BoxDecoration(
//                          borderRadius: BorderRadius.circular(20),
//                          color: UserFunctions
//                              .colorCirculoScoreCardDiferencia, //  Colors.greenAccent,
//                          border: Border.all(color: Colors.black, width: 0.3),
//                        ),
//                        height: 15,
//                        width: 15,
//                      ),
//                      Container(
//                        padding: EdgeInsets.only(left: 5, right: 5),
//                        child: Text(
//                          'Diferencia Score',
//                          style: TextStyle(fontSize: 12),
//                          textScaleFactor: 1,
//                        ),
//                      )
//                    ],
//                  ),
//                ),
              Container(
                height: 20,
              ),

                Container(
                  width: MediaQuery.of(context).size.width - 50,
                  child: Text('Para ver las Tarjetas completas, hacer click en el Nombre de cada Jugador',
                    textScaleFactor: 1,
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black),
                    textAlign: TextAlign.center,),
                ),

                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 150,
                  color: Colors.transparent,
                  child: Image.network(
                      'http://scoring.com.ar/app/images/publi/scoringpro/logo_ScoreCard.png',
                      fit: BoxFit.fitHeight),
                ),
                Container(
                  height: 50,
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: SpeedDial(
          marginBottom: 50,
          elevation: 5,
          animatedIconTheme: IconThemeData(size: 30),
          animatedIcon: AnimatedIcons.menu_close,
          onOpen: () => print('Open'),
          onClose: () {
            print('Close ddd');

          },
          visible: true,
          overlayColor: Colors.black54,
          backgroundColor: Colors.black,
//        foregroundColor: Colors.black,
          curve: Curves.elasticInOut,
          children: [
            SpeedDialChild(
              child: Icon(Icons.add, color: Color(0xFFFF0030), size: 30,),
              backgroundColor: Colors.white,
              onTap: () {

                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: AgregaJugaPract(
                      postPractica: postPractica,
                    ),
                  ),
                );
              },
              label: 'AGREGAR | CAMBIAR JUGADOR',
              labelStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
              labelBackgroundColor: Colors.black45,
            ),

            SpeedDialChild(
              child: Icon(Icons.person, color: Colors.black),
              backgroundColor: Colors.greenAccent,
              onTap: () {

                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: BottonNav(),
                  ),
                );
              },
              label: 'Menú Principal',
              labelStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
              labelBackgroundColor: Colors.black45,
            ),
          ],
        ),
        bottomNavigationBar: CurvedNavigationBar(
          index: 0,
          height: 60.0,
          items: <Widget>[
            Builder(builder: (context) {
              return IconButton(
                icon: Icon(Icons.golf_course, size: 30, color: Colors.white),
              );
            }),
          ],
          color: Color(0xFF1f2f50),
//        color: Color(0xFFFF0030),
          buttonBackgroundColor: Color(0xFF1f2f50),
//        buttonBackgroundColor: Color(0xFFFF0030),
          backgroundColor: Colors.transparent,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 600),
        ),
      ),
      onWillPop: () {
        return new Future(() => false);
        //Navigator.of(context).pop();
      },
    );
  }

  void _llamandoResultado(DataJugadorScore jugador, BuildContext context) async {
    if (_controlClickPress==true){
      print('locked _controlClickPress');
      return;
    }
    _controlClickPress=true;
    int indiceJuga=_practicaJugadoresScore
        .indexWhere((juga) => juga.matricula
        .contains(jugador.matricula));

    DataJugadorScore dSCJugador =
        _practicaJugadoresScore[indiceJuga];



    /// verificar si hay firma de su marcador
    String matricula_marcador = '';
    if (_practicaJugadoresScore.length > 1) {
      matricula_marcador =
          _practicaJugadoresScore[1].matricula;
    }
//    await DBAdmin.getFirmaMarcador(
//        dSCJugador,
//        dSCJugador.idTorneo,
//        int.parse(
//            GlobalData.postUser.idjuga_arg),
//        matricula_marcador);
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: ResultadosSF(dataSCJugadores:  _practicaJugadoresScore,
          logo: Practica.postPracticaJuego.postClub.logo,
          image: Practica.postPracticaJuego.postClub.imagen,
          indiceJuga: indiceJuga,
        ),
      ),
    );
    _controlClickPress=false;
  }

  /// HOYOS *****************************************************
  DataTable _dataTable(int hoyoNro) {
    return DataTable(
      columnSpacing: 30,
      horizontalMargin: 10,
      headingRowHeight: 110,
      // headingRowHeight: 82,
      dataRowHeight: 100,
      columns: [
        DataColumn(
          label: Padding(
            padding:
                const EdgeInsets.only(top: 8.0, right: 8, bottom: 8, left: 16),
            child: Container(
              width: 65,
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [ /// CON O SIN GPS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.gps_fixed, size: 20, color: Colors.black),
                              Text(
                                ' GPS ',
                                textScaleFactor: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                          Text(
                            'H' + hoyoNro.toString(),
                            textScaleFactor: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.red),
                          ),
                          Container(
                            alignment: Alignment.center,
                            color: Color(0xFFDDDDDD),
                            height: 20,
                            width: 65,
                            child: Text(
                              "Par ${(_practicaJugadoresScore[0].hoyos[hoyoNro - 1].par.toString())}",
                              textScaleFactor: 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            color: Color(0xFFDDDDDD),
                            height: 20,
                            width: 65,
                            child: Text(
                              "HCP ${(_practicaJugadoresScore[0].hoyos[hoyoNro - 1].handicap.toString())}",
                              textScaleFactor: 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      // _timer.cancel();
                      // TODO ------------------------------------------------------------
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          // child: dialogGPS(context, hoyoNro), ///GPS LINK
                          child:MapsPageV1(hoyoNro), ///GPS LINK
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      rows: _practicaJugadoresScore
          .map(
            (jugador) => DataRow(cells: [
              DataCell(
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Container(
                    alignment: Alignment.center,
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                        color: UserFunctions.resolverColorCirculoScore(
                            jugador.hoyos[hoyoNro - 1].scoreState,
                            _practicaJugadoresScore.indexOf(jugador)),
                        // Color(0xFFFF0030),
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black45.withOpacity(.6),
                              blurRadius: 6,
                              offset: Offset(2, 2)),
                        ]),
                    padding: EdgeInsets.all(10),
                    child: Text(
                      UserFunctions.scoreZeroToEmpty(
                          jugador.hoyos[hoyoNro - 1].score),
                      textScaleFactor: 1,
                      //style: TextStyle(fontSize: 45, color: Colors.white),
                      style: TextStyle(
                          fontSize: 45,
                          color: UserFunctions.resolverColorFontCirculoScore(
                              jugador.hoyos[hoyoNro - 1].scoreState,
                              _practicaJugadoresScore.indexOf(jugador))),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                onTap: () {
                  //createAlertDialogGral(
                  dialogScoreHoyo(context, hoyoNro);
                  //colorCirculoScoreCard=colorCirculoScoreCardDiferencia;
                  setState(() {
                    _isupdating = true;
                  });
                },
              ),
            ]),
          )
          .toList(),
    );
  }

  /// TODOS LOS DATOS
  SingleChildScrollView _dataBody() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      /// HOYO 1
                      _dataTable(1),
                      _dataTable(2),
                      _dataTable(3),
                      _dataTable(4),
                      _dataTable(5),
                      _dataTable(6),
                      _dataTable(7),
                      _dataTable(8),
                      _dataTable(9),
                      Container(
                        width: 1,
                        height: 230,
                        color: Colors.black,
                        child: SizedBox(),
                      ),
                      DataTable(
                        columnSpacing: 30,
                        horizontalMargin: 10,
                        headingRowHeight: 110,
                        // headingRowHeight: 82,
                        dataRowHeight: 100,
                        columns: [
                          DataColumn(
                            label: Padding(
                              padding: const EdgeInsets.only(
                                  top: 8.0, right: 8, bottom: 8, left: 8),
                              child: Container(
                                width: 65,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      alignment: Alignment.center,
                                      height: 24,
                                      child: Text(
                                        'IDA',
                                        textScaleFactor: 1,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black),
                                      ),
                                    ),
//                                    Container(
//                                      alignment: Alignment.center ,
//                                      color: Color(0xFFDDDDDD) ,
//                                      height: 20 ,
//                                      width: 65 ,
//                                      child: Text(
//                                        'PAR' ,
//                                        textScaleFactor: 1 ,
//                                        textAlign: TextAlign.center ,
//                                        style: TextStyle(
//                                            fontSize: 14 ,
//                                            color: Colors.black) ,
//                                      ) ,
//                                    ) ,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Lets add one more column to show a delete button
                        ],
                        rows: _practicaJugadoresScore
                            .map(
                              (jugador) => DataRow(cells: [
                                DataCell(
                                  Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 80,
                                      width: 80,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(60),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black45
                                                    .withOpacity(.6),
                                                blurRadius: 6,
                                                offset: Offset(2, 2)),
                                          ]),
                                      padding: EdgeInsets.all(10),
                                      child: Text(
                                        //"${(int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? ''))}",
                                        UserFunctions.scoreZeroToEmpty(
                                            jugador.ida),
                                        textScaleFactor: 1,
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black
//                                      color: Color(0xFFFF0030)
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            )
                            .toList(),
                      ), // IDA
                      Container(
                        width: 1,
                        height: 230,
                        color: Colors.black,
                        child: SizedBox(),
                      ),
                      _dataTable(10),
                      _dataTable(11),
                      _dataTable(12),
                      _dataTable(13),
                      _dataTable(14),
                      _dataTable(15),
                      _dataTable(16),
                      _dataTable(17),
                      _dataTable(18),
                      Container(
                        width: 1,
                        height: 230,
                        color: Colors.black,
                        child: SizedBox(),
                      ),
                      DataTable(
                        columnSpacing: 30,
                        horizontalMargin: 10,
                        headingRowHeight: 110,
                        // headingRowHeight: 82,
                        dataRowHeight: 100,
                        columns: [
                          DataColumn(
                            label: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 84,
                                alignment: Alignment.center,
                                child: Text(
                                  'VUELTA',
                                  textScaleFactor: 1,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          // Lets add one more column to show a delete button
                        ],
                        rows: _practicaJugadoresScore
                            .map(
                              (jugador) => DataRow(cells: [
                                DataCell(
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 80,
                                      width: 80,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(60),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black45
                                                    .withOpacity(.6),
                                                blurRadius: 6,
                                                offset: Offset(2, 2)),
                                          ]),
                                      padding: EdgeInsets.all(10),
                                      child: Text(
                                        UserFunctions.scoreZeroToEmpty(
                                            jugador.vuelta),
                                        textScaleFactor: 1,
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black
//                                      color: Color(0xFFFF0030)
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            )
                            .toList(),
                      ), // VUELTA
                      Container(
                        width: 1,
                        height: 230,
                        color: Colors.black,
                        child: SizedBox(),
                      ),
                      DataTable(
                        columnSpacing: 30,
                        horizontalMargin: 10,
                        headingRowHeight: 110,
                        // headingRowHeight: 82,
                        dataRowHeight: 100,
                        columns: [
                          DataColumn(
                            label: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 84,
                                alignment: Alignment.center,
                                child: Text(
                                  'GROSS',
                                  textScaleFactor: 1,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          // Lets add one more column to show a delete button
                        ],
                        rows: _practicaJugadoresScore
                            .map(
                              (jugador) => DataRow(cells: [
                                DataCell(
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 80,
                                      width: 80,
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black45
                                                    .withOpacity(.6),
                                                blurRadius: 6,
                                                offset: Offset(2, 2)),
                                          ]),
                                      padding: EdgeInsets.all(10),
                                      child: Text(
                                        //"${(int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? ''))}",
                                        UserFunctions.scoreZeroToEmpty(
                                            jugador.gross),
                                        textScaleFactor: 1,
                                        style: TextStyle(
                                            fontSize: 27,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white
//                                      color: Color(0xFFFF0030)
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            )
                            .toList(),
                      ), // GROSS
                      Container(
                        width: 3,
                        height: 230,
                        color: Colors.black,
                        child: SizedBox(),
                      ),
                      DataTable(
                        columnSpacing: 30,
                        horizontalMargin: 10,
                        headingRowHeight: 110,
                        // headingRowHeight: 82,
                        dataRowHeight: 100,
                        columns: [
                          DataColumn(
                            label: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 84,
                                alignment: Alignment.center,
                                child: Text(
                                  'TOTAL',
                                  textScaleFactor: 1,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          // Lets add one more column to show a delete button
                        ],
                        rows: _practicaJugadoresScore
                            .map(
                              (jugador) => DataRow(cells: [
                                DataCell(
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 80,
                                      width: 80,
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black45
                                                    .withOpacity(.6),
                                                blurRadius: 6,
                                                offset: Offset(2, 2)),
                                          ]),
                                      padding: EdgeInsets.all(10),
                                      child: Text(
                                        //"${(int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? '')) + (int.parse(jugador.hcp ?? ''))}",
                                        UserFunctions.scoreZeroToEmpty(
                                            (int.parse(jugador.postTee.par) +
                                                jugador.netoAlPar)),
                                        textScaleFactor: 1,
                                        style: TextStyle(
                                            fontSize: 27,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white
//                                      color: Color(0xFFFF0030)
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            )
                            .toList(),
                      ), // TOTAL
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Crear Alerta GPS SELECT CANCHA
  dialogGPS(BuildContext context, int _nroHoyo) async {
    _practicaJugadoresScore[0].nombre_juga;
    //int idxController=0;
    _practicaJugadoresScore.forEach((jugadorItem) {
      String valorH = jugadorItem.hoyos[_nroHoyo - 1].score.toString();
      if (jugadorItem.hoyos[_nroHoyo - 1].score == 0) {
        valorH = '';
      }
      _controllerHoyo[_practicaJugadoresScore.indexOf(jugadorItem)].text = valorH;
    });

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: Container(
              height: 250,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding:
                      EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
                      color: Colors.black54,
                      child: Text('GPS | Hoyo $_nroHoyo',
                          style: TextStyle(color: Colors.white, fontSize: 35),
                          textScaleFactor: 1,
                          textAlign: TextAlign.center),
                    ),
                    Container(
                      height: 8,
                      child: SizedBox(),
                    ),
                    GestureDetector(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding:
                        EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
                        color: Colors.black,
                        child: Text('Vieja | Agua',
                            style: TextStyle(color: Colors.white, fontSize: 25),
                            textScaleFactor: 1,
                            textAlign: TextAlign.center),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child:MapsPageV2(_nroHoyo), ///GPS LINK
                          ),
                        );
                      },
                    ),
                    Container(
                      height: 8,
                      child: SizedBox(),
                    ),
                    GestureDetector(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding:
                        EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
                        color: Colors.black,
                        child: Text('Agua | Larga',
                            style: TextStyle(color: Colors.white, fontSize: 25),
                            textScaleFactor: 1,
                            textAlign: TextAlign.center),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child:MapsPageV3(_nroHoyo), ///GPS LINK
                          ),
                        );
                      },
                    ),
                    Container(
                      height: 8,
                      child: SizedBox(),
                    ),
                    GestureDetector(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding:
                        EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
                        color: Colors.black,
                        child: Text('Larga | Vieja',
                            style: TextStyle(color: Colors.white, fontSize: 25),
                            textScaleFactor: 1,
                            textAlign: TextAlign.center),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child:MapsPageV4(_nroHoyo), ///GPS LINK
                          ),
                        );
                      },
                    ),
                    Container(
                      height: 8,
                      child: SizedBox(),
                    ),
                    GestureDetector(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding:
                        EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
                        color: Colors.black,
                        child: Text('Campeonato',
                            style: TextStyle(color: Colors.white, fontSize: 25),
                            textScaleFactor: 1,
                            textAlign: TextAlign.center),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child:MapsPageV5(_nroHoyo), ///GPS LINK
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }


  // Crear Alerta
  dialogScoreHoyo(BuildContext context, int _nroHoyo) async {
    _practicaJugadoresScore[0].nombre_juga;
    //int idxController=0;
    _practicaJugadoresScore.forEach((jugadorItem) {
      String valorH = jugadorItem.hoyos[_nroHoyo - 1].score.toString();
      if (jugadorItem.hoyos[_nroHoyo - 1].score == 0) {
        valorH = '0';
      }
      _controllerHoyo[_practicaJugadoresScore.indexOf(jugadorItem)].text = valorH;
    });


    void _selectText(TextEditingController controller) {
      controller.selection = TextSelection(
          baseOffset: 0, extentOffset: controller.text.length);
    }

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: Container(
              height: 340,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding:
                          EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
                      color: Colors.black54,
                      child: Text('Hoyo $_nroHoyo',
                          style: TextStyle(color: Colors.white, fontSize: 45),
                          textScaleFactor: 1,
                          textAlign: TextAlign.center),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding:
                          EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
                      color: Colors.white70,
                      child: Text(
                          "Par ${(_practicaJugadoresScore[0].hoyos[_nroHoyo - 1].par.toString())} • ${(_practicaJugadoresScore[0].hoyos[_nroHoyo - 1].distancia.toString())} Yardas | Hcp ${(_practicaJugadoresScore[0].hoyos[_nroHoyo - 1].handicap.toString())}",
                          style: TextStyle(color: Colors.black, fontSize: 13),
                          textScaleFactor: 1,
                          textAlign: TextAlign.center),
                    ),
//                    Container(
//                      padding:
//                          EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
//                      child: Text(
//                        '| Ingrese Scores |',
//                        textScaleFactor: 1,
//                        style: TextStyle(
//                            fontSize: 16,
//                            color: Colors.black,
//                            fontWeight: FontWeight.bold),
//                        textAlign: TextAlign.center,
//                      ),
//                    ),
                    _isupdating
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
//                          width: 400,
                          child: FlatButton(
                            color: Colors.black,
                            child: Text(
                              'GUARDAR SCORE',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              textScaleFactor: 1,
                            ),
                            onPressed: () {
                              //_dataJugadoresScore
                              okInputScore(_nroHoyo, context);
                            },
                          ),
                        ),

//                        FlatButton(
//                          color: Colors.black,
//                          child: Text(
//                            'OK',
//                            style: TextStyle(color: Colors.white),
//                          ),
//                          onPressed: () {
//                            //_practicaJugadoresScore
//                            okInputScore(_nroHoyo, context);
//                          },
//                        ),
                      ],
                    )
                        : Container(),

                    ///*****************************
                    DataTable(
                      columnSpacing: 0,
                      horizontalMargin: 10,
                      headingRowHeight: 5,
                      dataRowHeight: 80,
                      columns: [
                        DataColumn(
                          label: Text(''),
                        ),
                        // Lets add one more column to show a delete button
                      ],
                      rows: _practicaJugadoresScore
                          .map(
                            (jugadorItem) => DataRow(cells: [
                              DataCell(
                                Container(
                                    height: 70,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundImage: NetworkImage(
                                              jugadorItem.images.trim() ?? ''),
                                          backgroundColor: Colors.black,
                                        ),
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          padding: EdgeInsets.only(left: 5),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                width: 70,
                                                height: 17,
//                                            alignment: Alignment.centerLeft,
                                                child: Text(
                                                  jugadorItem.nombre_juga.trim() ?? '',
                                                  textAlign: TextAlign.left,
                                                  textScaleFactor: 1,
                                                  overflow: TextOverflow.clip,
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontFamily:
                                                          'DIN Condensed',
                                                      color: Colors.black),
                                                ),
                                              ),
                                              Container(
                                                width: 70,
                                                height: 25,
                                                child: Text(
                                                  jugadorItem.matricula
                                                          .trim() ??
                                                      '',
                                                  textAlign: TextAlign.left,
                                                  textScaleFactor: 1,
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'DIN Condensed',
                                                      fontSize: 23,
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 65,
                                          height: 65,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: UserFunctions
                                                  .resolverColorCirculoScore(
                                                      0,
                                                      _practicaJugadoresScore
                                                          .indexOf(
                                                              jugadorItem)),
                                              //Color(0xFFFF0030),
                                              borderRadius:
                                                  BorderRadius.circular(60),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black45
                                                        .withOpacity(.6),
                                                    blurRadius: 6,
                                                    offset: Offset(3, 3)),
                                              ]),
                                          padding: EdgeInsets.only(
                                              left: 5, right: 5),
                                          child: TextField(
                                            autofocus: true,
                                            onTap: () => _selectText(_controllerHoyo[_practicaJugadoresScore.indexOf(jugadorItem)]),
                                            controller: _controllerHoyo[
                                                _practicaJugadoresScore
                                                    .indexOf(jugadorItem)],
//                                            maxLength: 2,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 30,
                                                color: UserFunctions
                                                    .resolverColorFontCirculoScore(
                                                        0,
                                                        _practicaJugadoresScore
                                                            .indexOf(
                                                                jugadorItem))),
                                            decoration:
                                                InputDecoration.collapsed(
                                                    hintText: ' ',
                                                    hintStyle: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white)),
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            ]),
                          )
                          .toList(),
                    ),

                    Container(
                      height: 8,
                      child: SizedBox(),
                    ),
                    Text('Si un jugador no termina el hoyo, ingresar "0"', style: TextStyle(fontSize: 13), textAlign: TextAlign.center, textScaleFactor: 1),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void okInputScore(int _nroHoyo, BuildContext context) {
    bool _isValido = true;
    _practicaJugadoresScore.forEach((jugadorItem) {
      var datoN = int.parse(_controllerHoyo[
              _practicaJugadoresScore
                  .indexOf(jugadorItem)]
          .text);
      if (datoN > 36) {
        _isValido = false;
      } else {
        jugadorItem.setScoreNotDB(
            _nroHoyo,
            int.parse(_controllerHoyo[
                    _practicaJugadoresScore
                        .indexOf(jugadorItem)]
                .text));
       }
    });
    if (_isValido == true) {
      Navigator.of(context).pop();
    }
  }

  // Crear Alerta Hoyo GPS
  createAlertDialogGPS(BuildContext context, _nroHoyo) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.black54,
            content: Container(
              alignment: Alignment.center,
              height: 500,
              width: MediaQuery.of(context).size.width,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding:
                        EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
                    color: Colors.black,
                    child: Text('Hoyo $_nroHoyo',
                        style: TextStyle(color: Colors.white, fontSize: 45),
                        textScaleFactor: 1,
                        textAlign: TextAlign.center),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding:
                        EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
                    color: Colors.white70,
                    child: Text(
                        "Par ${(_practicaJugadoresScore[0].hoyos[_nroHoyo - 1].par.toString())} • ${(_practicaJugadoresScore[0].hoyos[_nroHoyo - 1].distancia.toString())} Yardas | Hcp ${(_practicaJugadoresScore[0].hoyos[_nroHoyo - 1].handicap.toString())}",
                        style: TextStyle(color: Colors.black, fontSize: 13),
                        textScaleFactor: 1,
                        textAlign: TextAlign.center),
                  ),
                  Container(
                    height: 405,
                    child: Image.network(
                        'http://scoring.com.ar/app/images/gps/prueba/H01d.png',
                        fit: BoxFit.fitHeight),
                  ),
                ],
              ),
            ),
          );
        });
  }

}
