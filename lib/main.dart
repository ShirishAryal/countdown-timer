import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Countdown',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textEditingController = TextEditingController();

  //Function to validate user input
  String? validateTimestring(String timestring) {
    // The patterns for valid timestrings.
    List<RegExp> patterns = [
      RegExp(r"^\d+h:\d+m:\d+s$"),
      RegExp(r"^\d+m:\d+s$"),
      RegExp(r"^\d+s$"),
      RegExp(r"^\d+h$"),
      RegExp(r"^\d+m$"),
      RegExp(r"^\d+h:\d+s$"),
      RegExp(r"^\d+h:\d+m$"),
    ];

    // Iterate over the patterns and return null if the timestring matches any of them.
    for (RegExp pattern in patterns) {
      if (pattern.hasMatch(timestring)) {
        return null;
      }
    }

    // The timestring is not valid, so return an error message.
    return "Enter valid time string eg. 2h:32m:2s";
  }

//Convert validated user input to Duration
  Duration parseTimestring(String timestring) {
    List<String> parts = timestring.split(':');
    int hours = 0;
    int minutes = 0;
    int seconds = 0;
    if (parts.length > 3) {
      throw ArgumentError('Invalid time string: $timestring');
    }
    for (String part in parts) {
      if (part.contains('h')) {
        hours = int.parse(part.replaceAll('h', ''));
      } else if (part.contains('m')) {
        minutes = int.parse(part.replaceAll('m', ''));
      } else if (part.contains('s')) {
        seconds = int.parse(part.replaceAll('s', ''));
      }
    }
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Countdown"), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _textEditingController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Please enter timestring";
                    return validateTimestring(value.toLowerCase());
                  },
                  decoration: const InputDecoration(
                    hintText: "Enter count down time(eg. 2h:32m:2s)",
                  ),
                ),
                const SizedBox(height: 24.0),
                TextButton(
                  onPressed: () async {
                    if (!(_formKey.currentState!.validate())) return;
                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return SimpleDialog(
                          alignment: Alignment.center,
                          insetPadding: const EdgeInsets.all(24.0),
                          children: [
                            Center(
                              child: TimerWidget(duration: parseTimestring(_textEditingController.text.trim().toLowerCase())),
                            ),
                            const SizedBox(height: 16.0),
                            Center(
                              child: TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Stop")),
                            )
                          ],
                        );
                      },
                    );
                  },
                  child: const Text("Start Counter"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TimerWidget extends StatefulWidget {
  const TimerWidget({super.key, required this.duration});

  final Duration duration;

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Duration _currentDuration = Duration.zero;
  bool _isComplete = false;
  late Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _currentDuration = widget.duration;
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentDuration.inSeconds > 0) {
          _currentDuration -= const Duration(seconds: 1);
        } else {
          _timer.cancel();
          _isComplete = true;
        }
      });
    });
  }

  void restartTimer() {
    setState(() {
      _currentDuration = widget.duration;
      _isComplete = false;
      startTimer();
    });
  }

  String _currentDurationToString() {
    String twoDigits(int n) => (n >= 10) ? '$n' : '0$n';
    String twoDigitMinutes = twoDigits(_currentDuration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(_currentDuration.inSeconds.remainder(60));
    return '${_currentDuration.inHours}:$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_isComplete) {
      return Column(
        children: [
          Text(_currentDurationToString()),
          const SizedBox(height: 16.0),
          TextButton(
            onPressed: restartTimer,
            child: const Text('Restart'),
          ),
        ],
      );
    } else {
      return Text(_currentDurationToString());
    }
  }
}
