import 'package:google_maps_flutter/google_maps_flutter.dart';

class PostHoyoGMap {
  int hoyoNro;
  int par;
  int hcp;
  int yardas;
  LatLng point1;
  LatLng point2;
  LatLng point3;
  double bearing;
  double zoom;
  LatLng northeast;
  LatLng southwest;

  PostHoyoGMap({int hoyoNro, int par, int handicap,
      int yardas, LatLng point1, LatLng point2, LatLng point3, double bearing,  double zoom, int nroPointNorthEast}) {

    this.hoyoNro = hoyoNro;
    this.par = par;
    this.point1= point1;
    this.point2= point2;
    this.point3= point3;
    this.hcp =handicap;
    this.yardas =yardas;
    this.bearing=bearing;
    this.zoom=zoom;
    if (nroPointNorthEast==1){
      northeast=this.point1;
      southwest=this.point3;
    }else{
      northeast=this.point3;
      southwest=this.point1;
    }
  }
}