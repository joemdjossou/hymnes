import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:hymnes/Screens/UniqueOne.dart';
class HomeInput extends StatefulWidget {
  @override
  _HomeInputState createState() => _HomeInputState();
}

class _HomeInputState extends State<HomeInput> {
  bool favoris = false;
  final controller = TextEditingController();
  final items = List<String>.generate(20, (i) => "Item $i");

  Widget _cell(String title) {
    return (Card(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UniqueOne(
                  numero: 1,
                ),
              ));
        },
        child: Container(
            height: 60.0,
            child: Row(
              children: [
                Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: new BoxDecoration(
                      color: Colors.green.shade200,
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  child: Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: new BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    child: Center(
                      child: Text('565'),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0,right: 10,top: 5.0, bottom: 2.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // titre de l'hymne
                        Text('Ah qu il est beau de voir !',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w900,
                          fontSize: 16.0,
                        ),),
                        // ligne pour les soustitres
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            
                            Text('Arsene Touck',style: TextStyle(
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.w500,
                            ),),
                            Text('Andante',style: TextStyle(
                              fontFamily: 'Raleway',
                            ),),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            )),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new PreferredSize(
        child: new Container(
          padding: new EdgeInsets.only(
              // top: MediaQuery.of(context).padding.top
              ),
          child: new Padding(
            padding: const EdgeInsets.only(
                // left: 30.0,
                // top: 20.0,
                // bottom: 20.0
                ),
            child: Center(
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: Text(
                      "Accueil",
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.short_text,
                      size: 32.0,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      print('object');
                    },
                  ),
                ],
              ),
            ),
          ),
          decoration: new BoxDecoration(
              // gradient: new LinearGradient(
              //   colors: [
              //     Colors.green,
              //     Colors.green
              //   ]
              // ),
              color: const Color(0xff066610),
              borderRadius: new BorderRadius.only(
                bottomLeft: const Radius.circular(100.0),
                // bottomRight: const  Radius.circular(40.0)
              ),
              boxShadow: [
                new BoxShadow(
                  color: Colors.grey[500],
                  blurRadius: 20.0,
                  spreadRadius: 1.0,
                )
              ]),
        ),
        preferredSize: new Size(MediaQuery.of(context).size.width, 80.0),
      ),
      body: CustomPaint(
        painter: MyPainter(),
        child: Container(
          child: Column(
            children: [
              Center(
                child: Container(
                  margin:
                      EdgeInsets.only(left: 50, top: 50, right: 50, bottom: 20),
                  // width: 350.0,
                  decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.only(
                      bottomLeft: const Radius.circular(15.0),
                      topLeft: const Radius.circular(15.0),
                    ),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 7,
                        offset: Offset(0, 1), // changes position of shadow
                      ),
                    ],
                  ),
                  child: new ListTile(
                    leading: FractionallySizedBox(
                      // widthFactor: 0.5,
                      heightFactor: 1,
                      child: Container(
                        width: 50.0,
                        decoration: new BoxDecoration(
                          color: const Color(0xff066610),
                        ),
                        child: new IconButton(
                          icon: favoris
                              ? Icon(
                                  Icons.sort_by_alpha,
                                  color: Colors.white,
                                )
                              : Icon(
                                  Icons.exposure_plus_1,
                                  color: Colors.white,
                                ),
                          onPressed: () {
                            // brain.setHymneFavoris(widget.numero);
                            setState(() {
                              favoris = !favoris;
                            });
                            print('voici le favori $favoris');
                            controller.clear();
                          },
                        ),
                      ),
                    ),
                    title: new TextField(
                      controller: controller,
                      decoration: new InputDecoration(
                          hintText: 'Search', border: InputBorder.none),
                      // onChanged: onSearchTextChanged,
                    ),
                    trailing: new IconButton(
                      icon: new Icon(Icons.cancel),
                      onPressed: () {
                        controller.clear();
                        // onSearchTextChanged('');
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _cell(items[index]);
                    // return ListTile(
                    //   title: Text('${items[index]}'),
                    // );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // final height = size.height;
    // final width = size.width;
    Paint paint = Paint();

    // Path mainBackground = Path();
    // mainBackground.addRect(Rect.fromLTRB(0, 0, width, height));
    // paint.color = Colors.blue.shade700;
    // canvas.drawPath(mainBackground, paint);

    Path ovalPath = Path();
    ovalPath.moveTo(0, size.height);
    ovalPath.cubicTo(size.width / 3, size.height / 1.5, size.width, size.height,
        size.width, size.height / 2);
    ovalPath.lineTo(size.width, size.height);
    // // Start paint from 20% height to the left
    // ovalPath.moveTo(0, height * 0.2);

    // // paint a curve from current position to middle of the screen
    // ovalPath.quadraticBezierTo(
    //     width * 0.45, height * 0.25, width * 0.51, height * 0.5);

    // // Paint a curve from current position to bottom left of screen at width * 0.1
    // ovalPath.quadraticBezierTo(width * 0.58, height * 0.8, width * 0.1, height);

    // // draw remaining line to bottom left side
    // ovalPath.lineTo(0, height);

    // Close line to reset it back
    ovalPath.close();

    paint.color = Colors.green.shade200;
    canvas.drawPath(ovalPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
