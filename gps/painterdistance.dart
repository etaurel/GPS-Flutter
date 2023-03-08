import 'package:flutter/material.dart';

class Paintermarker extends CustomPainter {
  final String label;
  Paintermarker(this.label);
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint=Paint();
   final rect=Rect.fromLTWH(0,0,size.width,size.height);
   final RRect rRect=RRect.fromRectAndRadius(rect, Radius.circular(10));
  paint.color=Colors.transparent;
   canvas.drawRRect(rRect, paint);
  final textPainter=TextPainter(
    textScaleFactor: 1,
    text:TextSpan(
      text:this.label,
      style: TextStyle(fontSize: 130,color:Colors.white, fontWeight: FontWeight.bold,
      shadows: [
      Shadow(
        offset: Offset(5.0, 5.0),
        blurRadius: 4.0,
        color: Colors.black,
      )
    ],),
    ),     
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center
  );
  textPainter.layout(minWidth: 0,maxWidth: size.width);
  textPainter.paint(canvas,Offset(10,size.height/2-textPainter.size.height/2));
  }
  


  @override
  bool shouldRepaint(Paintermarker oldDelegate) => false;
   
  @override
  bool shouldRebuildSemantics(Paintermarker oldDelegate) => false;
}