import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:lyricyst_app/controllers/PredictionController.dart';

class PredictionPage extends StatefulWidget {
  PredictionPage({
    Key key,
    this.predictionController,
    this.onChipPressed,
    this.onCloseRequested,
  }) : super(key: key);

  final predictionController;
  final Function onChipPressed;
  final Function onCloseRequested;

  @override
  PredictionPageState createState() {
    var logr = Logger();
    logr.d('In createState(), predDem: ' +
        predictionController.predictionDemanded.toString());
    return PredictionPageState(
      predictionController: predictionController,
      onChipPressed: onChipPressed,
      onCloseRequested: onCloseRequested,
    );
  }
}

class PredictionPageState extends State<PredictionPage> {
  PredictionController predictionController;
  List<String> predictions;
  Function onChipPressed;
  Function onCloseRequested;

  PredictionPageState({
    this.predictionController,
    this.onChipPressed,
    this.onCloseRequested,
  });

  Future<void> getPredictions() async {
    try {
      if (predictionController.predictionDemanded &&
          predictionController.newPredsNeeded) {
        predictions = await predictionController.getPredictionsFromServer();
        predictionController.newPredsNeeded = false;
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(
        msg: "Sorry, couldn't get predictions!",
        backgroundColor: Color.fromRGBO(150, 62, 84, 1),
        textColor: Colors.white,
      );
      Fluttertoast.showToast(
        msg: "Check connection and try again!",
        backgroundColor: Color.fromRGBO(150, 62, 84, 1),
        textColor: Colors.white,
      );

      setState(() {
        predictionController.predictionDemanded = false;
      });
    }
  }

  String getPredictionsCompiled() {
    String out = '';

    for (String pred in predictions) {
      out += ' ' + (pred == '(newline)' ? '\n' : pred);
    }
    return out;
  }

  Widget getWidgetForMoreWords() {
    return Text(
      getPredictionsCompiled(),
      style: TextStyle(fontFamily: 'RhodiumLibre', fontSize: 12),
    );
  }

  Widget getWidgetForLessWords() {
    return Wrap(
      children: predictions.map<Padding>((str) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: RaisedButton(
            textColor: Colors.white,
            child: Text(str),
            color: Color.fromRGBO(191, 23, 87, 1),
            elevation: 3,
            onPressed: () {
              onChipPressed(' ' + str);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget innerChildNoPrediction = Text(predictionController.noPredText);

    var loggr = Logger();
    loggr.d(predictionController.seedController.text +
        " " +
        predictionController.artistName +
        " " +
        predictionController.nWords.toString() +
        " " +
        predictionController.temperature.toString());

    Widget innerChildWithPrediction = predictionController.predictionDemanded
        ? FutureBuilder(
            future: getPredictions(),
            builder: (context, snapshot) {
              print(snapshot.connectionState);
              if (snapshot.connectionState == ConnectionState.done &&
                  predictionController.nWords < 51) {
                return getWidgetForLessWords();
              } else if (snapshot.connectionState == ConnectionState.done &&
                  predictionController.nWords >= 51) {
                return getWidgetForMoreWords();
              } else {
                return Padding(
                  padding: EdgeInsets.all(5),
                  child: CircularProgressIndicator(),
                );
              }
            },
          )
        : null;

    Widget innerChild = predictionController.predictionDemanded
        ? innerChildWithPrediction
        : innerChildNoPrediction;

    var logger = Logger();
    logger.d(predictionController.predictionDemanded);

    return Container(
      height: predictionController.predictionDemanded
          ? MediaQuery.of(context).size.height / (2.7)
          : 1,
      width: double.infinity,
      //color: Colors.white, //.fromRGBO(125, 12, 44, 1),

      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 254, 235, 1),
        border: Border(
          top: BorderSide(color: Color.fromRGBO(199, 197, 175, 1), width: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(199, 197, 175, 1),
            spreadRadius: 1,
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                RaisedButton(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.close, color: Colors.white),
                      ],
                    ),
                    color: Colors.black87,
                    shape: CircleBorder(
                      side: BorderSide(width: 2),
                    ),
                    //borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                    onPressed: onCloseRequested),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Wrap(
                    children: <Widget>[
                      innerChild,
                    ],
                  ),
                ),
              ),
            ),
          ),
          51 >= 51
              ? Align(
                  alignment: Alignment.bottomRight,
                  child: RaisedButton(
                    textColor: Colors.white,
                    color: Colors.deepPurple,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.add, color: Colors.white),
                        Text('Add all this'),
                      ],
                    ),
                    onPressed: () {
                      onChipPressed(getPredictionsCompiled());
                    },
                  ),
                )
              : Text('')
        ],
      ),
    );
  }
}
