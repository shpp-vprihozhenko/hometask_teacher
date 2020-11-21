import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart' as pv2;

class PhotoView extends StatefulWidget {
  final imgWidget;
  PhotoView(this.imgWidget);

  @override
  _PhotoViewState createState() => _PhotoViewState();
}

class _PhotoViewState extends State<PhotoView> {

  @override
  Widget build(BuildContext context) {
    return Container(
        child: GestureDetector(
          child: pv2.PhotoView(imageProvider: widget.imgWidget.image,),
          onTap: (){
            Navigator.pop(context);
          },
        )
    );
  }
}
