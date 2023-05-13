import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';

extension Log on Object{
  void log()=> devtools.log(toString());

}


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage()
    );
  }
}

@immutable
class Person{
  final String name;
  final String age;

  const Person(this.name, this.age);

  Person.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String,
      age = json['age'] as String;
}

Future<Iterable<Person>> getPersons()async{
  final rp = ReceivePort();
  await Isolate.spawn(_getPersons, rp.sendPort);
  return await rp.first;
}

void _getPersons(SendPort sp) async{
    const url = 'http://127.0.0.1:5500/apis/people1.json';
    final persons = await HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((response) => response.transform(utf8.decoder).join())
    .then((jsonString) => json.decode(jsonString) as List<dynamic>)
    .then((json) => json.map((map) => Person.fromJson(map)));

    Isolate.exit(
      sp,
      persons,
    );

        
}


class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: TextButton(
        onPressed: () async{
          final persons = await getPersons();
          persons.log();
        },
        child: const Text('press me'),
      ),
    );
  }
}

