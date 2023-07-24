import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(GameApp());
}

class GameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Joguinho',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int _score = 0;
  int _targetNumber;
  bool _gameOver = false;
  int _secondsRemaining = 10;
  Timer _timer;

  final Map<String, dynamic> _difficultyLevels = {
    'easy': {
      'range': [1, 10],
      'attempts': 5
    },
    'medium': {
      'range': [1, 50],
      'attempts': 8
    },
    'hard': {
      'range': [1, 100],
      'attempts': 10
    },
  };

  String _currentLevel = 'easy';
  List<Map<String, dynamic>> _highScores = [];

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _gameOver = false;
      _targetNumber = Random().nextInt(_difficultyLevels[_currentLevel]['range']
                  [1] -
              _difficultyLevels[_currentLevel]['range'][0] +
              1) +
          _difficultyLevels[_currentLevel]['range'][0];
      _secondsRemaining = 10;
      _timer.cancel();
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _timer.cancel();
            _gameOver = true;
          }
        });
      });
    });
  }

  void _checkGuess(int number) {
    if (!_gameOver) {
      if (number == _targetNumber) {
        setState(() {
          _score++;
          _targetNumber = Random().nextInt(_difficultyLevels[_currentLevel]
                      ['range'][1] -
                  _difficultyLevels[_currentLevel]['range'][0] +
                  1) +
              _difficultyLevels[_currentLevel]['range'][0];
        });
        _showSuccessDialog();
        _playSound('success.mp3');
      } else {
        if (_score > 0) {
          _score--;
        }
        _showErrorDialog();
        _playSound('error.mp3');
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Acertou!'),
          content: Icon(
            Icons.check_circle,
            size: 50,
            color: Colors.green,
          ),
          actions: [
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startGame();
              },
              child: Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Errou!'),
          content: Icon(
            Icons.cancel,
            size: 50,
            color: Colors.red,
          ),
          actions: [
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _gameOver = true;
                });
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _playSound(String sound) {
    // Implement your sound playing logic here
  }

  void _updateHighScores() {
    _highScores.add({
      'level': _currentLevel,
      'score': _score,
    });
    _highScores.sort((a, b) => b['score'].compareTo(a['score']));
    if (_highScores.length > 5) {
      _highScores = _highScores.sublist(0, 5);
    }
  }

  void _shareScore() {
    String message = 'Minha pontuação no Joguinho foi: $_score';
    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Joguinho'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Adivinhe o número!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              'Tempo restante: $_secondsRemaining segundos',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Pontuação: $_score',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            if (_gameOver)
              Text(
                'Game Over!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 20),
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: _gameOver ? 200 : 0,
              child: Icon(
                Icons.cancel,
                size: 100,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 20),
            if (_gameOver)
              RaisedButton(
                onPressed: _startGame,
                child: Text('Jogar Novamente'),
              ),
            for (int i = _difficultyLevels[_currentLevel]['range'][0];
                i <= _difficultyLevels[_currentLevel]['range'][1];
                i++)
              RaisedButton(
                onPressed: _gameOver ? null : () => _checkGuess(i),
                child: Text('$i'),
              ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: _currentLevel,
              onChanged: (String value) {
                setState(() {
                  _currentLevel = value;
                });
                _startGame();
              },
              items: _difficultyLevels.keys.map((String level) {
                return DropdownMenuItem<String>(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            RaisedButton(
              onPressed: _gameOver ? null : _shareScore,
              child: Text('Compartilhar Pontuação'),
            ),
          ],
        ),
      ),
    );
  }
}
