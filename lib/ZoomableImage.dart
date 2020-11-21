import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_editor/image_editor.dart';
//import 'package:image/image.dart' as img;


class ZoomableImage extends StatefulWidget {
  Uint8List imageBytes;
  ImageProvider image;
  final double maxScale;
  final double minScale;
  final GestureTapCallback onTap;
  final Color backgroundColor;
  final Widget placeholder;

  ZoomableImage(
      this.imageBytes,
      {
        Key key,
        @deprecated double scale,

        /// Maximum ratio to blow up image pixels. A value of 2.0 means that the
        /// a single device pixel will be rendered as up to 4 logical pixels.
        this.maxScale = 16.0,
        this.minScale = 0.0,
        this.onTap,
        this.backgroundColor = Colors.black,

        /// Placeholder widget to be used while [image] is being resolved.
        this.placeholder = const Center(child: const CircularProgressIndicator()),
        //}) : super(key: key);
      })
  {
    this.image = MemoryImage(this.imageBytes);
  }

  @override
  _ZoomableImageState createState() => new _ZoomableImageState();
}

// See /flutter/examples/layers/widgets/gestures.dart
class _ZoomableImageState extends State<ZoomableImage> {
  bool editMode = false;
  bool updateMode = false;
  List<List <Offset>> lines = [];

  ImageStream _imageStream;
  ui.Image _image; //, _image2;
  //img.Image _paintingImage;

  Size _imageSize;

  Offset _startingFocalPoint;

  Offset _previousOffset;
  Offset _offset; // where the top left corner of the image is drawn

  double _previousScale;
  double _scale; // multiplier applied to scale the full image

  Orientation _previousOrientation;

  Size _canvasSize;

  //final GlobalKey _globalKey = GlobalKey();

  void _centerAndScaleImage() {
    _imageSize = new Size(
      _image.width.toDouble(),
      _image.height.toDouble(),
    );

    _scale = math.min(
      _canvasSize.width / _imageSize.width,
      _canvasSize.height / _imageSize.height,
    );

    Size fitted = new Size(
      _imageSize.width * _scale,
      _imageSize.height * _scale,
    );

    Offset delta = _canvasSize - fitted;
    _offset = delta / 2.0; // Centers the image

    print('_centerAndScaleImage _imageSize $_imageSize _scale $_scale _canvasSize $_canvasSize fitted $fitted delta $delta');
    print(_scale);
  }

  Function() _handleDoubleTap(BuildContext ctx) {
    return () {
      double newScale = _scale * 2;
      if (newScale > widget.maxScale) {
        _centerAndScaleImage();
        setState(() {});
        return;
      }

      // We want to zoom in on the center of the screen.
      // Since we're zooming by a factor of 2, we want the new offset to be twice
      // as far from the center in both width and height than it is now.
      Offset center = ctx.size.center(Offset.zero);
      Offset newOffset = _offset - (center - _offset);

      setState(() {
        _scale = newScale;
        _offset = newOffset;
      });

      //print('_handleDoubleTap _imageSize $_imageSize _scale $_scale _canvasSize $_canvasSize center $center _offset $_offset');

    };
  }

  void _handleScaleStart(ScaleStartDetails d) {
    //print("starting scale at ${d.focalPoint} from $_offset $_scale");
    _startingFocalPoint = d.focalPoint;
    _previousOffset = _offset;
    _previousScale = _scale;
  }

  void _handleScaleUpdate(ScaleUpdateDetails d) {

    //print('d $d');

    double newScale = _previousScale * d.scale;
    if (newScale > widget.maxScale || newScale < widget.minScale) {
      return;
    }

    // Ensure that item under the focal point stays in the same place despite zooming
    final Offset normalizedOffset =
        (_startingFocalPoint - _previousOffset) / _previousScale;
    final Offset newOffset = d.focalPoint - normalizedOffset * newScale;

    setState(() {
      _scale = newScale;
      _offset = newOffset;
    });
    //print('_handleScaleUpdate _scale $_scale _offset $_offset ');
  }

  @override
  Widget build(BuildContext ctx) {

    Widget paintWidget() {
      return CustomPaint(
        child: Container(color: widget.backgroundColor),
        foregroundPainter: _ZoomableImagePainter(_image, _offset, _scale, lines),
      );
    }

    if (_image == null) {
      return widget.placeholder ?? Center(child: CircularProgressIndicator());
    }

    return new LayoutBuilder(builder: (ctx, constraints) {
      Orientation orientation = MediaQuery.of(ctx).orientation;
      if (orientation != _previousOrientation) {
        _previousOrientation = orientation;
        _canvasSize = constraints.biggest;
        _centerAndScaleImage();
      }

      return Stack(children: [
        editMode?
        GestureDetector(
          child: paintWidget(),
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
        )
            : GestureDetector(
          child: paintWidget(),
          onTap: widget.onTap,
          onDoubleTap: _handleDoubleTap(ctx),
          onScaleStart: _handleScaleStart,
          onScaleUpdate: _handleScaleUpdate,
        ),
        Positioned(
          bottom: 0, right: 0,
          child: Row(
            children: [
              FloatingActionButton(
                heroTag: 'editTag',
                backgroundColor: editMode? Colors.green: Colors.blue,
                child: Icon(Icons.edit),
                onPressed: (){
                  if (!editMode) {
                    setState(() {
                      editMode = true;
                    });
                  } else {
                    if (lines.length > 0){
                      print('need to update img');
                      addLinesToImg();
                    }
                    setState(() {
                      editMode = false;
                    });
                  }
                },
              ),
              SizedBox(width: 16),
              FloatingActionButton(
                heroTag: 'saveTag',
                backgroundColor: editMode? Colors.green: Colors.blue,
                child: Icon(Icons.done),
                onPressed: (){
                  _ok();
                },
              ),
              SizedBox(width: 16),
            ],
          ),
        ),
        updateMode == false? SizedBox()
            : Positioned(
          top: MediaQuery.of(context).size.height/2,
          left: MediaQuery.of(context).size.width/2,
          child: Row(
            children: [
              CircularProgressIndicator(),
            ],
          ),
        ),
      ]);
    });
  }

  _ok() async {
    print('ok.');
    if (lines.length > 0){
      print('need to update img ${lines.length}');
      print(lines);
      await addLinesToImg();
    } else {
      print('all lines is updated.');
    }
    Navigator.pop(context, {'status':'ok', 'bytes': widget.imageBytes});
  }

  @override
  void didChangeDependencies() {
    _resolveImage();
    super.didChangeDependencies();
  }

  @override
  void reassemble() {
    _resolveImage(); // in case the image cache was flushed
    super.reassemble();
  }

  void _resolveImage() {
    _imageStream = widget.image.resolve(createLocalImageConfiguration(context));
    _imageStream.addListener(ImageStreamListener((info, sc){_handleImageLoaded(info,sc);}));
  }

  void _handleImageLoaded(ImageInfo info, bool synchronousCall) {
    print("image loaded: $info");
    setState(() {
      _image = info.image;
    });

    /*
    if (_paintingImage == null) {
      print('create painting layer img');
      _paintingImage = img.Image(_image.width, _image.height);
      decodeImageFromList(img.encodePng(_paintingImage))
      .then((value){
        _image2 = value;
        print('got trans _img2 $_image2');
      });
    }
     */

  }

  @override
  void dispose() {
    _imageStream.removeListener(ImageStreamListener((info, sc){_handleImageLoaded(info,sc);}));
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    print('_onPanStart $details');
    List <Offset> newLine = [];
    Offset pos = (context.findRenderObject() as RenderBox)
        .globalToLocal(details.globalPosition);
    newLine.add(pos);
    lines.add(newLine);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    //print('_onPanUpdate $details');
    Offset pos = (context.findRenderObject() as RenderBox)
        .globalToLocal(details.globalPosition);
    lines.last.add(pos);
    setState((){});
  }

  void _onPanEnd(DragEndDetails details) {
    //print('_onPanEnd $details');
    //print('got line data to draw ${lines.last}');
    setState((){});
  }

  Future <void> addLinesToImg() async {

//    RenderRepaintBoundary boundary =
//    _globalKey.currentContext.findRenderObject();
//
//    print('got boundary $boundary');
//
//    var image = await boundary.toImage();
//    ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
//    Image newImg = Image.memory(byteData.buffer.asUint8List());

    setState(() {
      updateMode = true;
    });

    final opt = ImageEditorOption();

    print('start add lines to layer');
    lines.forEach((line){
      if (line.length < 2) {
        return;
      }
      for (int i=0; i<line.length-1; i++) {
        Offset _start = (-_offset + line[i]) / _scale;
        Offset _fin = (-_offset + line[i+1]) / _scale;

        //img.drawLine(_paintingImage, _start.dx.toInt(), _start.dy.toInt(), _fin.dx.toInt(), _fin.dy.toInt(), img.getColor(255, 0, 0), thickness: 5);

        addLineOpt(_start, _fin, opt);
      }
      line.clear();
    });
    print('end add lines to layer');

    /*
    List<int> _png = img.encodePng(_paintingImage);
    print('got png');
    _image2 = await decodeImageFromList(_png);
     */

    widget.imageBytes = await ImageEditor.editImage(image: widget.imageBytes, imageEditorOption: opt);
    widget.image = MemoryImage(widget.imageBytes);
    _image = await decodeImageFromList(widget.imageBytes);

    //_resolveImage();
    print('step 4');

    lines.clear();

    setState(() {
      updateMode = false;
    });
  }

  addLineOpt(from, to, opt) {
    var item = LineDrawPart(
      start: from,
      end: to,
      paint: DrawPaint(
          lineWeight: 5,
          paintingStyle: PaintingStyle.stroke,
          color: Colors.red),
    );
    opt.outputFormat = OutputFormat.png(100);
    opt.addOption(
      DrawOption()..addDrawPart(item),
    );
  }
}

Future<Uint8List> loadFromAsset(String key) async {
  final ByteData byteData = await rootBundle.load(key);
  return byteData.buffer.asUint8List();
}

class _ZoomableImagePainter extends CustomPainter {
  final ui.Image image;
  final Offset offset;
  final double scale;
  List<List <Offset>> lines;
  //final ui.Image image2;

  _ZoomableImagePainter(this.image, this.offset, this.scale, this.lines);


  @override
  void paint(Canvas canvas, Size canvasSize) {
    Size imageSize = new Size(image.width.toDouble(), image.height.toDouble());
    Size targetSize = imageSize * scale;

    paintImage(
      canvas: canvas,
      rect: offset & targetSize,
      image: image,
      fit: BoxFit.fill,
    );

    /*
    if (image2 != null) {
      paintImage(
        canvas: canvas,
        rect: offset & targetSize,
        image: image2,
        fit: BoxFit.fill,
      );
    }
     */

    Paint p = Paint();
    p.color = Colors.green;
    p.strokeWidth = 5;

    lines.forEach((line){
      if (line.length < 2) {
        return;
      }
      for (int i=0; i<line.length-1; i++) {
        Offset startPoint = line[i];
        Offset endPoint = line[i+1];
        canvas.drawLine(startPoint, endPoint, p);
      }
      /*
      Offset startPoint = line.first;
      Offset endPoint = line.last;
      canvas.drawLine(startPoint, endPoint, p);
       */
    });

  }

  @override
  bool shouldRepaint(_ZoomableImagePainter old) {
    return old.image != image || old.offset != offset || old.scale != scale;
  }

}
