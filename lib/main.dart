import 'package:flutter/material.dart';
import 'package:tarefas_flutter/temas/temas.dart';
import 'package:tarefas_flutter/telas/home.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Lista de tarefas',
    home: Home(),
    themeMode: ThemeMode.system,
    theme: lightTheme(),
    darkTheme: darkTheme(),
  ));
}
