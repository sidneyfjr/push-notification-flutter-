import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

Future<void> onBackgroundMessage(RemoteMessage message) async {
  print(message.data);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    initializeFcm();
  }

  initializeFcm() async {

    // Obtenho o token que será único para esse aplicativo.
    final token = await messaging.getToken();
    print(token);

    // Aqui inscrevo este usuário em um tópico. Quando uma notificação com este
    // tópico for criada no firebase todos os usuários inscritos neste tópico
    // a receberão.
    messaging.subscribeToTopic('fortaleza');

    // Aqui trato as mensagens em foreground, ou seja, com
    // o aplicativo aberto.
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        Flushbar(
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
          title: message.notification!.title,
          message: message.notification!.body,
          duration: const Duration(seconds: 3),
          onTap: (_) {
            print('Toque em foreground: ${message.data}');
            // Poderia redirecionar para uma página definida na mensagem
            //Navigator.of(context).pushNamed(message.data['route']);
          },
        ).show(context);
      }
    });

    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

    // Aqui trato as mensagens em background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Toque em background: ${message.notification?.title}');
    });

    // Aqui trato as mensagens em terminated, ou seja com o aplicativo fechado.
    final RemoteMessage? message = await messaging.getInitialMessage();
    if (message != null) {
      print('Toque em terminated: ${message.notification?.title}');
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
