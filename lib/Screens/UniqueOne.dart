import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:hymnes/components/MarqueeWidget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../HymnesBrain.dart';

const _PANEL_HEADER_HEIGHT = 40.0;

class UniqueOne extends StatefulWidget {
  final int? numero;
  UniqueOne({this.numero});
  @override
  _UniqueOneState createState() => _UniqueOneState();
}

class _UniqueOneState extends State<UniqueOne>
    with SingleTickerProviderStateMixin {
  static AudioPlayer player = AudioPlayer();

  Future<void> playAudio(String path) async {
    try {
      await player.play(AssetSource(path),
          volume: 8); // Use AssetSource for local files
      await player.resume(); // Play the audio
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  // HymnesBrain brain = HymnesBrain();
  String voix = 'soprano';
  AnimationController? _controller;
  bool favoris = false;
  bool playing = false;
  bool stopped = true;
  bool paused = false;
  // fontScaling property
  double _fontSize = 16;
  final double _baseFontSize = 16;
  double _fontScale = 1;
  double _baseFontScale = 1;
  late List<String> favorisListCustom;

  @override
  void initState() {
    super.initState();
    _initializeFavorites(); // Call the async method
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      value: 0.0,
      vsync: this,
    );
  }

  void _initializeFavorites() async {
    await HymnesBrain().addAllTheFavorites();
    favorisListCustom = await HymnesBrain().addAllTheFavorites() ?? ['null'];
    print('voici la liste $favorisListCustom');
    // print('Into the hymnal screen');
  }

  void addOrRemoveFavorite(int hymneNumber) async {
    // Convert hymneNumber to string for comparison
    String hymneStr = hymneNumber.toString();
    // Remove any existing occurrences of hymneNumber to avoid duplicates
    if (favorisListCustom.contains(hymneStr)) {
      favorisListCustom.remove(hymneStr);
    } else {
      favorisListCustom.add(hymneStr);
    }
  }

  @override
  void dispose() {
    // player.dispose(); // Properly dispose of the player
    _controller?.dispose();
    super.dispose();
  }

  bool get _isPanelVisible {
    final AnimationStatus status = _controller!.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  String retourProchain(String voix) {
    switch (voix) {
      case 'soprano':
        return 'alto';
      case 'alto':
        return 'tenor';
      case 'tenor':
        return 'basse';
      case 'basse':
        return 'soprano';
      default:
        return 'basse';
    }
  }

  String correctVoice(String voix) {
    switch (voix) {
      case 'soprano':
        return 'S';
      case 'alto':
        return 'A';
      case 'tenor':
        return 'T';
      case 'basse':
        return 'B';
      default:
        return 'B';
    }
  }

  double fontReturn(double data) {
    if (data <= 16) return 16;
    if (data >= 32) return 32;
    return data;
  }

  void rightNavigate(HymnesBrain brain, int nume) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UniqueOne(
            numero: int.parse(brain.getHymneNumber(nume - 1)),
          ),
        ));
  }

  void leftNavigate(HymnesBrain brain, int nume) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UniqueOne(
            numero: int.parse(brain.getHymneNumber(nume + 1)),
          ),
        ));
  }

  Widget _myCustomDropDown() {
    return (new GestureDetector(
        onTap: () {
          setState(() {
            voix = retourProchain(voix);
            playing = false;
            stopped = true;
            paused = false;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 2.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
            ),
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
          child: Text(correctVoice(voix)),
        )));
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    final Animation<RelativeRect> animation = _getPanelAnimation(constraints);
    Theme.of(context);
    return Consumer<HymnesBrain>(builder: (context, brain, child) {
      return (new Container(
        color: Colors.lime[100],
        height: MediaQuery.of(context).size.height - 20.0,
        child: new Stack(
          children: <Widget>[
            GestureDetector(
              onScaleStart: (ScaleStartDetails scaleStartDetails) {
                _baseFontScale = _fontScale;
              },
              onScaleUpdate: (ScaleUpdateDetails scaleUpdateDetails) {
                setState(() {
                  _fontScale =
                      (_baseFontScale * scaleUpdateDetails.scale).clamp(0.5, 5);
                  _fontSize = fontReturn(_fontScale * _baseFontSize);
                });
              },
              onHorizontalDragUpdate: (details) {
                // Right Swipe
                if (details.delta.dx > 0) {
                  if (widget.numero! > 1) {
                    // Prevent accessing negative index
                    print('Right Swipe');
                    rightNavigate(brain, widget.numero! - 1);
                  } else {
                    print('Swipe Blocked at Index 0');
                  }
                }
                // Left Swipe
                else if (details.delta.dx < 0) {
                  if (widget.numero! < 655) {
                    // Prevent out-of-range access
                    print('Left Swipe');
                    leftNavigate(brain, widget.numero! - 1);
                  } else {
                    print('Swipe Blocked at Last Index');
                  }
                }
              },
              child: SingleChildScrollView(
                child: new Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 40.0),
                    child: Column(
                      children: [
                        new Text(
                          brain.getHymneChant(widget.numero! - 1),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: _fontSize,
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        new Text(
                          brain.getHymneAuteur(widget.numero! - 1),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: _fontSize,
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            new PositionedTransition(
              rect: animation,
              child: new Material(
                borderRadius: const BorderRadius.only(
                    topLeft: const Radius.circular(16.0),
                    topRight: const Radius.circular(16.0)),
                elevation: 12.0,
                child: new Column(children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      _controller!
                          .fling(velocity: _isPanelVisible ? -1.0 : 1.0);
                    },
                    child: new Container(
                      height: _PANEL_HEADER_HEIGHT,
                      child: Row(children: <Widget>[
                        Expanded(
                          flex: 7,
                          child: Center(
                            child: new Text(
                              "Histoire",
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: new IconButton(
                              onPressed: () {
                                _controller!.fling(
                                    velocity: _isPanelVisible ? -1.0 : 1.0);
                              },
                              icon: new AnimatedIcon(
                                icon: AnimatedIcons.menu_arrow,
                                progress: _controller!.view,
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  new Expanded(
                      child: SingleChildScrollView(
                    child: new Center(
                        child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          new Text(
                            brain.getHymneAuteur(widget.numero! - 1),
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          new Text(
                            brain.getHymneStyle(widget.numero! - 1),
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          new Text(
                            brain.getHymneHistoire(widget.numero! - 1),
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ))
                ]),
              ),
            )
          ],
        ),
      ));
    });
  }

  Animation<RelativeRect> _getPanelAnimation(BoxConstraints constraints) {
    final double height = constraints.biggest.height;
    final double top = height - _PANEL_HEADER_HEIGHT;
    final double bottom = -_PANEL_HEADER_HEIGHT;
    return new RelativeRectTween(
      begin: new RelativeRect.fromLTRB(0.0, top, 0.0, bottom),
      end: new RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(new CurvedAnimation(parent: _controller!, curve: Curves.linear));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HymnesBrain>(builder: (context, brain, child) {
      return (new Scaffold(
        appBar: new AppBar(
          elevation: 0.0,
          title: MarqueeWidget(
            direction: Axis.horizontal,
            child: Row(
              children: [
                new Text(
                  brain.getHymneNumber(widget.numero! - 1),
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w800,
                    fontSize: 25.0,
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                new Text(
                  brain.getHymneTitre(widget.numero! - 1),
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Center(child: _myCustomDropDown()),
            IconButton(
              icon: playing
                  ? Icon(Icons.pause_circle_filled)
                  : Icon(Icons.play_circle_filled),
              onPressed: () async {
                if (playing) {
                  setState(() {
                    playing = false;
                    paused = true;
                    stopped = false;
                  });
                  print('Pausing $voix');
                  await player.pause();
                } else {
                  setState(() {
                    playing = true;
                    paused = false;
                    stopped = false;
                  });
                  print('Playing $voix');
                  String audioPath = 'audio/' +
                      brain.getHymneAudio(widget.numero! - 1, voix) +
                      '.mp3';
                  print('Attempting to play audio at: $audioPath');
                  await playAudio(audioPath);
                }
              },
            ),
            playing
                ? IconButton(
                    icon: Icon(Icons.stop_circle_outlined),
                    onPressed: () async {
                      setState(() {
                        stopped = true;
                        playing = false;
                        paused = false;
                      });
                      await player.stop();
                    },
                  )
                : Container(),
            PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    onTap: () {
                      brain.setHymneFavoris(widget.numero!);
                      addOrRemoveFavorite(widget.numero!);
                      print('chanson bien ajoute aux favoris ');
                      print('Log: is favoris ${brain.favoris ?? null}');
                      print(
                          'Log: is favoris ${favorisListCustom.contains(widget.numero.toString())}');
                    },
                    child: Row(
                      children: [
                        Icon(
                          (favorisListCustom.contains(widget.numero.toString()))
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.teal[800],
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text('Aimer'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
          backgroundColor: Colors.green,
          leading: null,
        ),
        body: new LayoutBuilder(
          builder: _buildStack,
        ),
      ));
    });
  }
}
