import 'dart:async';
//import 'dart:html';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:golfguidescorecard/scoresCard/scoreCard.dart';
import 'package:golfguidescorecard/scoresCard/scoreCardPractica.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:golfguidescorecard/gps/painterdistance.dart';
import 'package:maps_curved_line/maps_curved_line.dart';
import 'math.dart';
import 'modelMaps.dart';

class HoyoV1 extends StatelessWidget {
  int _idHoyo = 0;
  HoyoV1(int pIdHoyo) {
    _idHoyo = pIdHoyo;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Maps Curved Lines Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapsPageV1(_idHoyo),
    );
  }
}

class MapsPageV1 extends StatefulWidget {
  int _idHoyo = 0;
  MapsPageV1(int pIdHoyo) {
    _idHoyo = pIdHoyo;
  }
  @override
  _MapsPagebStateV2 createState() => _MapsPagebStateV2(_idHoyo);
}

class _MapsPagebStateV2 extends State<MapsPageV1> {

  String _sIdPoint1='punto1';
  String _sIdPoint2='punto2';


  List<PostHoyoGMap> _postHoyosGMap = new List(18);
  int _idHoyo = 0;
  LatLng _point1; // = LatLng(-34.524853326989415, -59.03608537554212);
  LatLng _point2; // = LatLng(-34.523129649952544, -59.03590298532911);
  LatLng _point3; // = LatLng(-34.52145013545259, -59.03616047739454);
  LatLng
      _northeast; // LatLng(-34.52145013545259, -59.03616047739454), ///point3
  LatLng
      _southwest; // LatLng(-34.524853326989415, -59.03608537554212), ///point1

  double _bearing = -2;
  double _zoom = 17.8;
  int _hoyoPar;
  int _hoyoHcp;
  int _hoyoYardas;

  StreamSubscription<Position> _positionStreamSubscription;

  _MapsPagebStateV2(int pIdHoyo) {
    estableceArray();
    _idHoyo = pIdHoyo;
    _establecerDatosMaps();
  }

  void initlocation() {
    if (_positionStreamSubscription == null) {
      // const LocationOptions locationOptions =
      //     LocationOptions( accuracy: LocationAccuracy.best, distanceFilter: 2);
      final Stream<Position> positionStream =  getPositionStream(desiredAccuracy:LocationAccuracy.best, distanceFilter: 2);
      _positionStreamSubscription = positionStream.listen((Position position) =>
          setState(
                  () => MovimientoJugador(position)));
      _positionStreamSubscription.pause();
    }

    setState(() {
      if (_positionStreamSubscription.isPaused) {
        _positionStreamSubscription.resume();
      } else {
        _positionStreamSubscription.pause();
      }
    });
  }

  LatLng MovimientoJugador(Position position)
  {
    _point1 = LatLng(position.latitude, position.longitude);
    calcularcentro();
  }

  @override
  void dispose() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription.cancel();
      _positionStreamSubscription = null;
    }

    super.dispose();
  }

  Future<Uint8List> _paintermarker(String label) async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    Paintermarker paintermarker = Paintermarker(label);
    paintermarker.paint(canvas, Size(300, 150));
    final ui.Image image = await recorder.endRecording().toImage(300, 150);
    final ByteData byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData.buffer.asUint8List();
    // calcularcentro(); //TODO con esto activado se va la memoria y se cierra app
  }

  Completer<GoogleMapController> _controller = Completer();
  final Set<Polyline> _polylines = Set();
  final Set<Marker> _markers = Set();
  final Set<Circle> _circles = Set();
//  static final CameraPosition _initialPosition = CameraPosition(
//    //TODO Point2 Rotacion y Zoom
////    target: LatLng(-34.48005933472226, -58.900073716216305),
////    bearing: 148,
////    zoom: 18.5,
//    target: _point1, // LatLng(-34.45014991034369, -58.61454601568922),
//    bearing: -120,
//    zoom: 19.2,
////    tilt: 75.0,
//  );

  BitmapDescriptor _markerIcon;
  void _setMarkerIcon() async {
    _markerIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/circulo5.png');
  }

  BitmapDescriptor _markerIcon3;
  void _setMarkerIcon3() async {
    _markerIcon3 = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/flag.png');
  }

  void prepareMarkers() {
    _markers.add(Marker(
      markerId: MarkerId(_point1.toString()),
    ));
    _markerPoint2();
    _markers.add(Marker(
        markerId: MarkerId(_point3.toString()),
        draggable: true,
        position: _point3,
        infoWindow: InfoWindow(title: ''),
        icon: _markerIcon3,
//        icon: BitmapDescriptor.defaultMarker,
        onDragEnd: ((value) {
          Marker marker = _markers.firstWhere(
              (p) => p.markerId == MarkerId(_point3.toString()),
              orElse: () => null);
          _markers.remove(marker);
          _point3 = LatLng(value.latitude, value.longitude);
          print(value.latitude);
          print(value.longitude);
          _markers.clear();
          _polylines.clear();
          _circles.clear();
          calcularcentro();
        })));

//    _markers.add(Marker(
//      markerId: MarkerId(_point3.toString()),
//    ));
  }

  void _markerPoint2() {
    _markers.add(Marker(
        markerId: MarkerId(_sIdPoint2),
        draggable: true,
        position: _point2,
        infoWindow: InfoWindow(title: 'Presione y Mueva'),
        icon: _markerIcon,
    //        icon: BitmapDescriptor.defaultMarker,
        onDragEnd: ((value) {
          Marker marker = _markers.firstWhere(
              (p) => p.markerId == MarkerId(_sIdPoint2),
              orElse: () => null);
          _markers.remove(marker);
          _point2 = LatLng(value.latitude, value.longitude);
          print(value.latitude);
          print(value.longitude);
          _markers.clear();
          _polylines.clear();
          _circles.clear();
          calcularcentro();
        })));
  }

  void prepareCircles() {
//    _circles.add( Circle(
//        circleId: CircleId(_point1.toString()),
//        radius: 1,
//        zIndex: 1,
//        consumeTapEvents: true,
//        visible: true,
//        strokeColor: Colors.blueAccent,
//        center: _point1,
//        fillColor: Colors.blueAccent,
//        onTap: (){}
//    ) );
    _circles.add(Circle(
        circleId: CircleId(_sIdPoint2),
        radius: 5,
        zIndex: 1,
        consumeTapEvents: true,
        visible: true,
        strokeColor: Colors.black38,
        center: _point2,
        fillColor: Colors.white54,
        onTap: () {}));
    _circles.add(Circle(
        circleId: CircleId(_point3.toString()),
        radius: 0,
        zIndex: 1,
        consumeTapEvents: true,
        visible: true,
        strokeColor: Colors.white54,
        center: _point3,
        fillColor: Colors.transparent,
        onTap: () {}));
  }

  void prepareCurvedPolylines() {
    _polylines.add(Polyline(
      polylineId: PolylineId("line 1"),
      visible: true,
      width: 3,
      patterns: [PatternItem.dash(30), PatternItem.gap(10)],
      points: MapsCurvedLines.getPointsOnCurve(_point1, _point2),
      color: Colors.white,
    ));
    _polylines.add(Polyline(
      polylineId: PolylineId("line 2"),
      visible: true,
      width: 3,
      patterns: [PatternItem.dash(30), PatternItem.gap(10)],
      points: MapsCurvedLines.getPointsOnCurve(_point2, _point3),
      color: Colors.white,
    ));
  }

  void calcularcentro() async {
    // centro de las 2 distancias 1 a 2
    String distance = Calculations().distance(_point1.latitude,
        _point1.longitude, _point2.latitude, _point2.longitude);
    final bytes = await _paintermarker(distance);
    _markers.add(Marker(
        markerId: MarkerId("distancia1a2"),
        position: Calculations().coordinatecenter(_point1.latitude,
            _point1.longitude, _point2.latitude, _point2.longitude),
        icon: BitmapDescriptor.fromBytes(bytes)));
    //
    // centro de las 2 distancias de 2 a 3
    String distance2 = Calculations().distance(_point2.latitude,
        _point2.longitude, _point3.latitude, _point3.longitude);
    final bytes2 = await _paintermarker(distance2);
    _markers.add(Marker(
        markerId: MarkerId("distancia2a3"),
        position: Calculations().coordinatecenter(_point2.latitude,
            _point2.longitude, _point3.latitude, _point3.longitude),
        icon: BitmapDescriptor.fromBytes(bytes2)));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initlocation();
    calcularcentro();
    _setMarkerIcon();
    _setMarkerIcon3();
  }

  Widget build(BuildContext context) {
    prepareMarkers();
    prepareCurvedPolylines();
    prepareCircles();
    return new Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.satellite,
            //_initialPosition
            initialCameraPosition: CameraPosition(
              target: _point2,
              bearing: _bearing,
              zoom:_zoom,
              //tilt: 75.0,
            ),
            polylines: _polylines,
            circles: _circles,
            markers: _markers,
            compassEnabled: false,
            rotateGesturesEnabled: false,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
//            minMaxZoomPreference: MinMaxZoomPreference(17.5, 25),
            minMaxZoomPreference: MinMaxZoomPreference(15, 25),
            // cameraTargetBounds: CameraTargetBounds(
            //   LatLngBounds(
            //     northeast: _northeast, // LatLng(
            //     //-34.4499810004915, -58.614170506427136), //TODO point1
            //     southwest: _southwest, // LatLng(
            //     //-34.45030005214774, -58.61485715193495), //TODO point3
            //   ),
            // ),
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: false,
            // TODO agregado para presionar en un lugar del mapa y mover el punto2
            onTap: (latlang) {
              newPosPoint2(latlang);
            },
            // TODO fin agregado para presionar en un lugar del mapa y mover el punto2

            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Container(
            alignment: Alignment.bottomLeft,
            child: Image.asset('assets/fondo2.png'),
          ),
          Container(
            alignment: Alignment.bottomRight,
            child: Image.asset('assets/fondo3.png'),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 120,
            color: Colors.black87,
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: Text(
                    'Hoyo '+_idHoyo.toString(),
                    style: TextStyle(color: Colors.lightGreenAccent, fontSize: 40),
                    textScaleFactor: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
                // Container(
                //   height: 30,
                //   width: MediaQuery.of(context).size.width,
                //   color: Colors.white54,
                //   alignment: Alignment.center,
                //   child: Text(
                //     'Par '+_hoyoPar.toString()+' | Hcp '+_hoyoHcp.toString()+' | Yardas '+_hoyoYardas.toString(),
                //
                //     style: TextStyle(
                //         color: Colors.black,
                //         fontSize: 16,
                //         fontWeight: FontWeight.bold),
                //     textScaleFactor: 1,
                //     textAlign: TextAlign.center,
                //   ),
                // ),
                Container(
                  height: 30,
                  alignment: Alignment.center,
                  color: Colors.lightGreenAccent,
                  child: Text(
                    'Haga Click en el mapa para calcular la distancia',
                    style: TextStyle(fontSize: 15, color: Colors.black),
                    textScaleFactor: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Container(
          height: 35,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, size: 30, color: Colors.lightGreenAccent),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              IconButton(
                icon: Icon(Icons.arrow_back_ios, size: 30, color: Colors.lightGreenAccent),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void estableceArray() {

    _postHoyosGMap[0]=new PostHoyoGMap( hoyoNro :	1	, point1:LatLng(	-34.421287, -58.829244	), point2:LatLng(	-34.419494, -58.830537	), point3:LatLng(	-34.418602, -58.831565	), bearing:	-35	, zoom :	17.0	, nroPointNorthEast:	1	);
    _postHoyosGMap[1]=new PostHoyoGMap( hoyoNro :	2	, point1:LatLng(	-34.417854, -58.831163	), point2:LatLng(	-34.415909, -58.832030	), point3:LatLng(	-34.414696, -58.832283	), bearing:	-15	, zoom :	17.0	, nroPointNorthEast:	1	);
    _postHoyosGMap[2]=new PostHoyoGMap( hoyoNro :	3	, point1:LatLng(	-34.414601, -58.831711	), point2:LatLng(	-34.416204, -58.830504	), point3:LatLng(	-34.417371, -58.829641	), bearing:	145	, zoom :	17.1	, nroPointNorthEast:	3	);
    _postHoyosGMap[3]=new PostHoyoGMap( hoyoNro :	4	, point1:LatLng(	-34.417296, -58.830184	), point2:LatLng(	-34.419435, -58.828460	), point3:LatLng(	-34.420672, -58.827408	), bearing:	145	, zoom :	16.8	, nroPointNorthEast:	3	);
    _postHoyosGMap[4]=new PostHoyoGMap( hoyoNro :	5	, point1:LatLng(	-34.421106, -58.826929	), point2:LatLng(	-34.421948, -58.828382	), point3:LatLng(	-34.421948, -58.828382	), bearing:	-120	, zoom :	18.6	, nroPointNorthEast:	1	);
    _postHoyosGMap[5]=new PostHoyoGMap( hoyoNro :	6	, point1:LatLng(	-34.422407, -58.828846	), point2:LatLng(	-34.424562, -58.828743	), point3:LatLng(	-34.425698, -58.828557	), bearing:	180	, zoom :	17.1	, nroPointNorthEast:	1	);
    _postHoyosGMap[6]=new PostHoyoGMap( hoyoNro :	7	, point1:LatLng(	-34.425762, -58.828171	), point2:LatLng(	-34.427560, -58.827598	), point3:LatLng(	-34.428434, -58.827488	), bearing:	180	, zoom :	17.3	, nroPointNorthEast:	3	);
    _postHoyosGMap[7]=new PostHoyoGMap( hoyoNro :	8	, point1:LatLng(	-34.428531, -58.827827	), point2:LatLng(	-34.426024, -58.829065	), point3:LatLng(	-34.424385, -58.829408	), bearing:	-20	, zoom :	16.5	, nroPointNorthEast:	3	);
    _postHoyosGMap[8]=new PostHoyoGMap( hoyoNro :	9	, point1:LatLng(	-34.424050, -58.829483	), point2:LatLng(	-34.422725, -58.829590	), point3:LatLng(	-34.422725, -58.829590	), bearing:	0	, zoom :	18.6	, nroPointNorthEast:	3	);
    _postHoyosGMap[9]=new PostHoyoGMap( hoyoNro :	10	, point1:LatLng(	-34.421277, -58.830136	), point2:LatLng(	-34.420809, -58.832694	), point3:LatLng(	-34.420836, -58.833957	), bearing:	-90	, zoom :	17.1	, nroPointNorthEast:	3	);
    _postHoyosGMap[10]=new PostHoyoGMap( hoyoNro :	11	, point1:LatLng(	-34.420898, -58.834278	), point2:LatLng(	-34.421481, -58.836066	), point3:LatLng(	-34.421481, -58.836066	), bearing:	-110	, zoom :	18.6	, nroPointNorthEast:	3	);
    _postHoyosGMap[11]=new PostHoyoGMap( hoyoNro :	12	, point1:LatLng(	-34.421463, -58.836505	), point2:LatLng(	-34.419644, -58.836973	), point3:LatLng(	-34.419644, -58.836973	), bearing:	0	, zoom :	18.6	, nroPointNorthEast:	3	);
    _postHoyosGMap[12]=new PostHoyoGMap( hoyoNro :	13	, point1:LatLng(	-34.419397, -58.837529	), point2:LatLng(	-34.418461, -58.835517	), point3:LatLng(	-34.418222, -58.834607	), bearing:	70	, zoom :	17.2	, nroPointNorthEast:	1	);
    _postHoyosGMap[13]=new PostHoyoGMap( hoyoNro :	14	, point1:LatLng(	-34.417949, -58.834521	), point2:LatLng(	-34.418699, -58.833312	), point3:LatLng(	-34.418699, -58.833312	), bearing:	130	, zoom :	18.6	, nroPointNorthEast:	1	);
    _postHoyosGMap[14]=new PostHoyoGMap( hoyoNro :	15	, point1:LatLng(	-34.418487, -58.833922	), point2:LatLng(	-34.419441, -58.835699	), point3:LatLng(	-34.420571, -58.836106	), bearing:	-130	, zoom :	17.3	, nroPointNorthEast:	3	);
    _postHoyosGMap[15]=new PostHoyoGMap( hoyoNro :	16	, point1:LatLng(	-34.421004, -58.836234	), point2:LatLng(	-34.419220, -58.833569	), point3:LatLng(	-34.419052, -58.831952	), bearing:	60	, zoom :	16.8	, nroPointNorthEast:	1	);
    _postHoyosGMap[16]=new PostHoyoGMap( hoyoNro :	17	, point1:LatLng(	-34.419405, -58.831792	), point2:LatLng(	-34.420130, -58.834211	), point3:LatLng(	-34.420836, -58.835442	), bearing:	-120	, zoom :	17.1	, nroPointNorthEast:	3	);
    _postHoyosGMap[17]=new PostHoyoGMap( hoyoNro :	18	, point1:LatLng(	-34.420783, -58.834778	), point2:LatLng(	-34.420165, -58.831621	), point3:LatLng(	-34.420942, -58.830101	), bearing:	90	, zoom :	16.8	, nroPointNorthEast:	1	);
  }

  void _establecerDatosMaps() {
    print('_idHoyo ' + _idHoyo.toString());
    print('zoom ' + _postHoyosGMap[0].zoom.toString());
    print('bearing ' + _postHoyosGMap[0].bearing.toString());

    _point1 = _postHoyosGMap[_idHoyo - 1].point1;
    _point2 = _postHoyosGMap[_idHoyo - 1].point2;
    _point3 = _postHoyosGMap[_idHoyo - 1].point3;
    _northeast = _postHoyosGMap[_idHoyo - 1].northeast;
    _southwest = _postHoyosGMap[_idHoyo - 1].southwest;
    _bearing = _postHoyosGMap[_idHoyo - 1].bearing;
    _zoom = _postHoyosGMap[_idHoyo - 1].zoom;
    _hoyoPar=_postHoyosGMap[_idHoyo - 1].par;
    _hoyoHcp=_postHoyosGMap[_idHoyo - 1].hcp;
    _hoyoYardas=_postHoyosGMap[_idHoyo - 1].yardas;

    print('point1 --- ' + _postHoyosGMap[0].point1.latitude.toString());
    print('point2 --- ' + _postHoyosGMap[0].point2.toString());

    print('_point1 --- ' + _point1.latitude.toString());
    print('_point2 --- ' + _sIdPoint2);
  }
  Future<void> newPosPoint2(LatLng latlang) async {
    if (_markers.length >= 1) {
      // mover el punto medio
      var preId=_sIdPoint2;
      _point2 = latlang;
      print(_sIdPoint2);

      Marker marker = _markers.firstWhere(
              (p) => p.markerId == MarkerId(preId),
          orElse: () => null);
      _markers.remove(marker);
      //await markersAdd('point2', _point2, _markerIcon,true);
      await _markerPoint2();
      print('onTap---- point2'+ _sIdPoint2);

      await prepareCurvedPolylines();
      await prepareCircles();
      await calcularcentro();
      setState(() {

      });

    }
  }
}
