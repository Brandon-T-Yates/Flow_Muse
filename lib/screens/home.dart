import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/todo_items.dart';
import '../model/todo.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final todoList = ToDo.todoList();
  List<ToDo> _foundToDo = [];
  final _todoController = TextEditingController();

  @override
  void initState(){
    _foundToDo = todoList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackBlue,
      appBar: _buldAppBar(),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20, 
              vertical: 15),
            child: Column(
              children: [
                searcBox(),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 50, bottom: 20),
                        child: const Text(
                          'ToDos',
                          style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      for ( ToDo toDoo in _foundToDo.reversed)
                        ToDoItem(todo: toDoo,
                        onToDoChanged: _handleToDoChange,
                        onDeleteItem: _deleteToDoItem,
                        ),
                    ],
                  )
                )
              ]
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(
                  bottom: 20,
                  right: 20,
                  left: 20,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [BoxShadow(
                      color: Colors.grey, 
                      offset: Offset(0.0,0.0),
                      blurRadius: 10.0,
                      spreadRadius: 0,
                      ),],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _todoController,
                    decoration: const InputDecoration(
                      hintText: 'Add new todo here',
                      border: InputBorder.none
                    ),)
                )
              ),
              Container(
                margin: const EdgeInsets.only(
                  bottom: 20,
                  right: 20,
                ),
                child: ElevatedButton(
                  child: Text('+',
                  style: TextStyle(fontSize: 40, ),),
                  onPressed: () {
                    _addToDoItem(_todoController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: styleGreen,
                    minimumSize: Size(60, 60),
                    elevation: 10,
                  )
                ),
              )
            ]),
          )
        ],
      ),
    );
  }

  void _handleToDoChange(ToDo todo){
    setState(() {
      todo.isDone = !todo.isDone;
    });
  }

  void _deleteToDoItem(String id){
    setState(() {
      todoList.removeWhere((item) => item.id == id);
    });
  }

  void _addToDoItem(String todo){
    setState(() {
      todoList.add(
      ToDo(id: DateTime.now()
      .millisecondsSinceEpoch.toString(), 
      todoText: todo));
    });
    _todoController.clear();
  }

  void _runFilter(String enteredKeyWord){
    List<ToDo> results = [];
    if( enteredKeyWord.isEmpty){
      results = todoList;
    } 
    else {
      results = todoList.where(
        (item) => item.todoText!.
        toLowerCase().contains(
          enteredKeyWord.toLowerCase()))
          .toList();
    }
    setState(() {
      _foundToDo = results;
    });
  }

  Widget searcBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
       ),
       child: TextField(
        onChanged: (value) => _runFilter(value),
         decoration: const InputDecoration(
           contentPadding: EdgeInsets.all(0),
           prefixIcon: Icon(
             Icons.search,
             color: black,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
           ),
          border: InputBorder.none,
          hintText: 'Search',
           hintStyle: TextStyle(
             color: grey,
          ),
         ),
       ),
    );
  }

  AppBar _buldAppBar() {
    return AppBar(  
      backgroundColor: appBackBlue,
      elevation: 0,
      title:  const Row(
        children: [
          Spacer(), // Add Spacer to push the icon to the right
          Icon(
            Icons.menu,
            color: black,
            size: 30,
          ),
        ],
      ),
    );
  }
}