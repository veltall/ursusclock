import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ursusclock/models/clock_view.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var formattedTime = DateFormat('HH:mm').format(now).toString();
    var formattedDate = DateFormat('EEE, d MMM').format(now).toString();
    var tzString = now.timeZoneOffset.toString().split('.').first;
    var offsetSign = (tzString.startsWith('-')) ? '' : '+';

    return Scaffold(
      backgroundColor: const Color(0xFF2D2F41),
      body: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildMenuButton('Clock', 'clock_icon.png'),
              buildMenuButton('Alarm', 'alarm_icon.png'),
              buildMenuButton('Timer', 'timer_icon.png'),
              buildMenuButton('Stopwatch', 'stopwatch_icon.png'),
            ],
          ),
          const VerticalDivider(
            color: Colors.white54,
            width: 10,
            thickness: 1,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Text(
                      'Clock',
                      style: TextStyle(
                        fontFamily: 'avenir',
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    flex: 2,
                    child: Column(
                      children: [
                        Text(
                          formattedTime,
                          style: const TextStyle(
                            fontFamily: 'avenir',
                            color: Colors.white,
                            fontSize: 64,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontFamily: 'avenir',
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Flexible(
                    flex: 4,
                    fit: FlexFit.tight,
                    child: Align(
                      alignment: Alignment.center,
                      child: ClockView(
                        size: 250,
                      ),
                    ),
                  ),
                  Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Timezone',
                            style: TextStyle(
                              fontFamily: 'avenir',
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(
                                Icons.language,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'UTC$offsetSign$tzString',
                                style: const TextStyle(
                                  fontFamily: 'avenir',
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding buildMenuButton(String title, String image) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: TextButton(
        onPressed: () {},
        child: Column(
          children: [
            Image.asset(
              '../assets/$image',
              scale: 1.5,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'avenir',
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
