import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../components/td_app_bar.dart';
import '../components/search_box.dart';
import '../components/todo_item.dart';
import '../models/todo_model.dart';
import '../resources/app_color.dart';
import '../services/local/shared_prefs.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  final _addController = TextEditingController();
  final _addFocus = FocusNode();
  bool _showAddBox = false;
  int _selectedIndex = 0;

  final SharedPrefs _prefs = SharedPrefs();
  List<TodoModel> _todos = [];
  List<TodoModel> _searches = [];

  @override
  void initState() {
    super.initState();
    _getTodos();
  }

  _getTodos() {
    _prefs.getTodos().then((value) {
      _todos = value ?? todosInit;
      _searches = [..._todos];
      setState(() {});
    });
  }

  _searchTodos(String searchText) {
    searchText = searchText.toLowerCase();
    // _searches.clear();
    // for (var element in _todos) {
    //   if ((element.text ?? '').toLowerCase().contains(searchText)) {
    //     _searches.add(element);
    //   }
    // }
    if (_selectedIndex == 0) {
      _searches = _todos
          .where((element) =>
              (element.text ?? '').toLowerCase().contains(searchText) &&
              ((element.inRecycle ?? false) == false)) 
          .toList();
    } else if (_selectedIndex == 1) {
      _searches = _todos
          .where((element) =>
              (element.text ?? '').toLowerCase().contains(searchText) &&
              !(element.isDone ?? false) &&
              ((element.inRecycle ?? false) == false))
          .toList();
    } else if (_selectedIndex == 2) {
      _searches = _todos
          .where((element) =>
              (element.text ?? '').toLowerCase().contains(searchText) &&
              (element.isDone ?? false) &&
              ((element.inRecycle ?? false) == false))
          .toList();
    } else {
      _searches = _todos
          .where((element) =>
              (element.text ?? '').toLowerCase().contains(searchText) &&
              (element.inRecycle ?? false)) 
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      appBar: TdAppBar(
          rightPressed: () async {
            bool? status = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('😍'),
                content: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Do you want to logout?',
                        style: TextStyle(fontSize: 22.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            if (status ?? false) {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            }
          },
          title: widget.title),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0)
                    .copyWith(top: 12.0, bottom: 92.0),
                child: Column(
                  children: [
                    SearchBox(
                        onChanged: (value) =>
                            setState(() => _searchTodos(value)),
                        controller: _searchController),
                    const Divider(
                        height: 32.6, thickness: 1.36, color: AppColor.grey),
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _searches.length,
                      itemBuilder: (context, index) {
                        TodoModel todo = _searches.reversed.toList()[index];
                        if (_selectedIndex == 3) {
                          return TodoItem(
                            onTap: () async {
                              bool? status = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('😍'),
                                  content: const Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Do you want to save this todo?',
                                          style: TextStyle(fontSize: 22.0),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                              if (status ?? false) {
                                setState(() {
                                todo.inRecycle = false;
                                _searches.remove(todo);
                                _prefs.addTodos(_todos);
                              });
                              }
                            },
                            onDeleted: () async {
                              bool? status = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('😍'),
                                  content: const Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Do you want to remove the todo?',
                                          style: TextStyle(fontSize: 22.0),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                              if (status ?? false) {
                                setState(() {
                                  _todos.remove(todo);
                                  _searches.remove(todo);
                                  _prefs.addTodos(_todos);
                                });
                              }
                            },
                            text: todo.text ?? '-:-',
                            isDone: todo.isDone ?? false,
                          );
                        }
                        
                        return TodoItem(
                          onTap: () {
                            setState(() {
                              todo.isDone = !(todo.isDone ?? false);
                              _prefs.addTodos(_todos);
                            });
                          },
                          onDeleted: () {
                            setState(() {
                              todo.inRecycle = true;
                              _searches.remove(todo);
                              _prefs.addTodos(_todos);
                            });
                          },
                          text: todo.text ?? '-:-',
                          isDone: todo.isDone ?? false,
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16.8),
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20.0,
            right: 20.0,
            bottom: 14.6,
            child: Row(
              children: [
                Expanded(
                  child: Visibility(
                    visible: _showAddBox,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 5.6),
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        border: Border.all(color: AppColor.blue),
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColor.shadow,
                            offset: Offset(0.0, 3.0),
                            blurRadius: 10.0,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _addController,
                        focusNode: _addFocus,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Add a new todo item',
                          hintStyle: TextStyle(color: AppColor.grey),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18.0),
                GestureDetector(
                  onTap: () {
                    _showAddBox = !_showAddBox;

                    if (_showAddBox) {
                      setState(() {});
                      _addFocus.requestFocus();
                      return;
                    }

                    String text = _addController.text.trim();
                    if (text.isEmpty) {
                      setState(() {});
                      FocusScope.of(context).unfocus();
                      return;
                    }

                    int id = 1;
                    if (_todos.isNotEmpty) {
                      id = (_todos.last.id ?? 0) + 1;
                    }

                    TodoModel todo = TodoModel()
                      ..id = id
                      ..text = text;

                    if (_selectedIndex == 2) todo.isDone = true;

                    _todos.add(todo);
                    _prefs.addTodos(_todos);
                    _addController.clear();
                    _searchController.clear();
                    _searchTodos('');
                    setState(() {});
                    FocusScope.of(context).unfocus();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14.6),
                    decoration: BoxDecoration(
                      color: AppColor.black,
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColor.shadow,
                          offset: Offset(0.0, 3.0),
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add,
                        size: 32.0, color: AppColor.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: GNav(
        tabBackgroundColor: Colors.grey.shade800,
        gap: 8.0,
        onTabChange: (index) {
          setState(() {
            _selectedIndex = index;
            setState(() => _searchTodos(_searchController.text));
          });
        },
        tabs: const [
          GButton(
            icon: Icons.home,
            text: 'Home',
            iconColor: AppColor.white,
          ),
          GButton(
            icon: Icons.local_laundry_service_rounded,
            text: 'Doing',
            iconColor: AppColor.white,
          ),
          GButton(
            icon: Icons.downhill_skiing_outlined,
            text: 'Done',
            iconColor: AppColor.white,
          ),
          GButton(
            icon: Icons.recycling,
            text: 'Recycle',
            iconColor: AppColor.white,
          )
        ],
        backgroundColor: AppColor.black,
        activeColor: AppColor.pink,
      ),
    );
  }
}
