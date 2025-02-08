import 'package:hymnes/Screens/HomeInput.dart';
import 'package:hymnes/components/Slide.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:flutter/material.dart';
// import 'Accueil.dart';

class IntroScreen extends StatefulWidget {
  IntroScreen({Key? key}) : super(key: key);

  @override
  IntroScreenState createState() => new IntroScreenState();
}

class IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = [];

  @override
  void initState() {
    super.initState();
    slides.add(
      Slide(
        title: "Chantez avec Joie",
        description:
            "Découvrez la beauté des cantiques qui élèvent l'âme et inspirent l'adoration.",
        imagePath: "assets/images/images.jpg",
        backgroundColor: Color(0xFF6A1B9A), // Deep Purple
      ),
    );

    slides.add(
      Slide(
        title: "Cantiques Intemporels",
        description:
            "Redécouvrez les cantiques classiques qui touchent les cœurs depuis des générations.",
        imagePath: "assets/images/images.jpg",
        backgroundColor: Color(0xFF1565C0), // Deep Blue
      ),
    );

    slides.add(
      Slide(
        title: "Votre Compagnon de Louange",
        description:
            "Emportez avec vous une collection de cantiques puissants où que vous soyez.",
        imagePath: "assets/images/images.jpg",
        backgroundColor: Colors.teal, // Teal
      ),
    );
  }

  void onDonePress() {
    print('Go to home screen');
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => HomeInput()));
  }

  @override
  Widget build(BuildContext context) {
    return new IntroSlider(
      // List slides
      listCustomTabs:
          this.slides.map((slide) => slide.toWidget(context)).toList(),
      // // Dot indicator
      // colorDot: Color(0xffffcc5c),
      // sizeDot: 13.0,
      // typeDotAnimation: dotSliderAnimation.SIZE_TRANSITION,
      // // Show or hide status bar
      // shouldHideStatusBar: true,
      onDonePress: this.onDonePress,
      skipButtonStyle: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.white),
      ),
      nextButtonStyle: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.white),
      ),
      doneButtonStyle: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.white),
      ),
    );
  }
}
