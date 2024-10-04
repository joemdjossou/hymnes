import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage(String s, {Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Accueil')),
        elevation: 10.0,
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Text('Noter !'),
                ),
                PopupMenuItem(
                  child: Text('Partager'),
                ),
              ];
            },
          )
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Card(
                    color: Colors.blue,
                    child: TextButton(
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width / 4,
                          height: MediaQuery.of(context).size.width / 4,
                          child: Icon(
                            Icons.star,
                            color: Colors.white,
                            size: MediaQuery.of(context).size.width / 4,
                          )),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/Favoris');
                      },
                    ),
                  ),
                  Card(
                    color: Colors.blue,
                    child: TextButton(
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width / 4,
                          height: MediaQuery.of(context).size.width / 4,
                          child: Icon(
                            Icons.format_list_numbered,
                            color: Colors.white,
                            size: MediaQuery.of(context).size.width / 4,
                          )),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/numeric');
                      },
                    ),
                  )
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Card(
                    color: Colors.blue,
                    child: TextButton(
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width / 4,
                          height: MediaQuery.of(context).size.width / 4,
                          child: Icon(
                            Icons.sort_by_alpha,
                            color: Colors.white,
                            size: MediaQuery.of(context).size.width / 4,
                          )),
                      onPressed: () {
                        print('Alphabetical clicked !');
                      },
                    ),
                  ),
                  Card(
                    color: Colors.blue,
                    child: TextButton(
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width / 4,
                          height: MediaQuery.of(context).size.width / 4,
                          child: Icon(
                            Icons.search,
                            color: Colors.white,
                            size: MediaQuery.of(context).size.width / 4,
                          )),
                      onPressed: () {
                        print('Search clicked');
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
