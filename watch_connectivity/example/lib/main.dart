import 'package:flutter/material.dart';

import 'package:watch_connectivity/watch_connectivity.dart';
import 'package:watch_connectivity_garmin/watch_connectivity_garmin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final WatchConnectivity _watch;

  var _count = 0;

  var _supported = false;
  var _paired = false;
  var _reachable = false;
  var _context = <String, dynamic>{};
  var _receivedContexts = <Map<String, dynamic>>[];
  final _log = <String>[];

  @override
  void initState() {
    super.initState();
    // Change this to the WatchType you want to use
    createPlugin(WatchType.base);
  }

  void createPlugin(WatchType type) async {
    _watch = WatchConnectivity(type: type);
    switch (type) {
      case WatchType.base:
        break;
      case WatchType.garmin:
        await _watch.initialize(
          GarminInitializationOptions(
            applicationId: 'daed64bf-ecee-4b75-b736-f0f834801d6a',
          ),
        );
        break;
    }

    _watch.messageStream
        .listen((e) => setState(() => _log.add('Received message: $e')));
    _watch.contextStream
        .listen((e) => setState(() => _log.add('Received context: $e')));

    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void initPlatformState() async {
    _supported = await _watch.isSupported;
    _paired = await _watch.isPaired;
    _reachable = await _watch.isReachable;
    if (_watch.type != WatchType.garmin) {
      _context = await _watch.applicationContext;
      _receivedContexts = await _watch.receivedApplicationContexts;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Watch type: ${_watch.type.name}'),
                  Text('Supported: $_supported'),
                  Text('Paired: $_paired'),
                  Text('Reachable: $_reachable'),
                  if (_watch.type != WatchType.garmin) ...[
                    Text('Context: $_context'),
                    Text('Received contexts: $_receivedContexts'),
                  ],
                  TextButton(
                    onPressed: initPlatformState,
                    child: const Text('Refresh'),
                  ),
                  const SizedBox(height: 8),
                  const Text('Send'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        child: const Text('Message'),
                        onPressed: () {
                          final message = {'data': 'Hello'};
                          _watch.sendMessage(message);
                          setState(() => _log.add('Sent message: $message'));
                        },
                      ),
                      if (_watch.type != WatchType.garmin) ...[
                        const SizedBox(width: 8),
                        TextButton(
                          child: const Text('Context'),
                          onPressed: () {
                            _count++;
                            final context = {'data': _count};
                            _watch.updateApplicationContext(context);
                            setState(() => _log.add('Sent context: $context'));
                          },
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(width: 8),
                  const Text('Log'),
                  ..._log.reversed.map((e) => Text(e)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
