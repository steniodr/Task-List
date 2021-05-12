import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _toDoList = []; // lista de tarefas
  final _toDoController = TextEditingController();
  int _indexlastRemoved; // guarda o índice do último registro removido
  Map<String, dynamic> _lastRemoved; // guarda o último registro removido

  // lógica
  @override
  void initState() {
    super.initState();
    _lerDados().then((value) {
      setState(() {
        _toDoList = json.decode(value);
      });
    });
  }

  Future<String> _lerDados() async {
    try {
      final arquivo = await _abreArquivo();
      return arquivo.readAsString();
    } catch (e) {
      return null;
    }
  }

  Future<File> _abreArquivo() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }

  Future<Null> _recarregaLista() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _toDoList.sort((a, b) {
        if (a['realizado'] && !b['realizado']) return 1;
        if (!a['realizado'] && b['realizado']) return -1;
        return 0;
      });
      _salvarDados();
    });
    return null;
  }

  Future<File> _salvarDados() async {
    String dados = json.encode(_toDoList);
    final arquivo = await _abreArquivo();
    return arquivo.writeAsString(dados);
  }

  void _adicionaTarefa() {
    setState(() {
      Map<String, dynamic> novaTarefa = Map();
      novaTarefa['titulo'] = _toDoController.text;
      novaTarefa['realizado'] = false; //(-1)
      _toDoController.text = '';
      _toDoList.add(novaTarefa);
      _salvarDados();
    });
  }

  Widget widgetTarefa(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.85, 0.0),
          child: Icon(
            Icons.delete_sweep_outlined,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd, //direçao do objeto para apagar
      child: CheckboxListTile(
        title: Text(_toDoList[index]["titulo"]),
        value: _toDoList[index]["realizado"],
        secondary: CircleAvatar(
          child: Icon(
            _toDoList[index]["realizado"]
                ? Icons.check
                : Icons.article_outlined,
            color: Theme.of(context).iconTheme.color,
          ),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        onChanged: (value) {
          setState(() {
            _toDoList[index]["realizado"] = value;
            _salvarDados();
          });
        },
        checkColor: Theme.of(context).primaryColor,
        activeColor: Theme.of(context).secondaryHeaderColor,
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved =
              Map.from(_toDoList[index]); // guarda o valor do item da lista
          _indexlastRemoved = index; // guarda o indice da entrada
          _toDoList.removeAt(index);
          _salvarDados();
        });

        final snack = SnackBar(
          content: Text("Tarefa \"${_lastRemoved["titulo"]}\" Apagada!"),
          action: SnackBarAction(
            label: "Desfazer",
            onPressed: () {
              setState(() {
                _toDoList.insert(_indexlastRemoved, _lastRemoved);
                _salvarDados();
              });
            },
          ),
          duration: Duration(seconds: 5),
        );
        // Confugurar: Mostrar/Esconder o desfazer
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(snack);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) => Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: _toDoController,
                    maxLength: 50,
                    decoration: InputDecoration(labelText: "Nova tarefa"),
                  )),
                  Container(
                    height: 45.0,
                    width: 45.0,
                    child: FloatingActionButton(
                      child: Icon(Icons.add),
                      backgroundColor: Colors.red[700],
                      onPressed: () {
                        if (_toDoController.text.isEmpty) {
                          final alerta = SnackBar(
                            content: Text('Não pode ser vazia!'),
                            duration: Duration(seconds: 4),
                            action: SnackBarAction(
                              label: 'Ok',
                              onPressed: () {
                                //Scaffold.of(context).removeCurrentSnackBar();
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar();
                              },
                            ),
                          );

                          //Scaffold.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          //Scaffold.of(context).showSnackBar(alerta);
                          ScaffoldMessenger.of(context).showSnackBar(alerta);
                        } else {
                          _adicionaTarefa();
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
            Padding(padding: (EdgeInsets.only(top: 10.0))),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _recarregaLista,
                child: ListView.builder(
                  itemBuilder: widgetTarefa,
                  itemCount: _toDoList.length,
                  padding: EdgeInsets.only(top: 10.0),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
