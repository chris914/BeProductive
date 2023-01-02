import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timemanagement/api/API.dart';
import 'package:flutter_timemanagement/data/todo.dart';
import 'package:flutter_timemanagement/screen/add_screen.dart';
import 'package:flutter_timemanagement/util/functions.dart';
import 'package:flutter_timemanagement/widgets/priority_chooser.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
          margin: EdgeInsets.only(bottom: 50, top: 0), // this was 40 beware!
          child: StreamBuilder(
              stream: API.getTodos(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Error"));

                if (!snapshot.hasData) return _buildProgressbar(context);

                if (snapshot.connectionState == ConnectionState.waiting)
                  return _buildProgressbar(context);
                print(snapshot);
                final items = API.getTodosFromSnapshotData(snapshot.data!);

                if (items.isEmpty)
                  return Center(child: Text("Your task list is empty :)"));

                var value = items.where((x) => (x as Todo).isDone).length /
                    items.length;

                return Column(children: [
                  Container(
                    height: 200,
                    child: Stack(
                      children: [
                        _buildImage(context),
                        Positioned(
                            left: 25,
                            top: 25,
                            child: Text("All\nTasks",
                                style: GoogleFonts.roboto(
                                    fontSize: 40, color: Colors.white))),
                        Positioned(
                            right: 25,
                            bottom: 25,
                            child: Row(
                              children: [
                                Container(
                                    margin: EdgeInsets.only(right: 10),
                                    width: 25,
                                    height: 25,
                                    child: CircularProgressIndicator(
                                        value: value,
                                        backgroundColor: Colors.blueGrey,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.lightBlueAccent))),
                                Text((value * 100).toString() + "% done",
                                    style: GoogleFonts.robotoMono(
                                        color: Colors.grey, fontSize: 14)),
                              ],
                            ))
                      ],
                    ),
                  ),
                  Expanded(child: _buildList(context, items))
                ]);
              })),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Image.network(
        "https://img.freepik.com/free-photo/blurred-abstract-natural-background-with-caucasus-mountains-morning-blue-mist_88775-1619.jpg?size=626&ext=jpg",
        fit: BoxFit.fitWidth,
        width: double.infinity,
        height: 200);
  }

  Widget _buildProgressbar(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Loading your items..."),
        CircularProgressIndicator(),
      ],
    ));
  }

  Widget _buildHeaderWidget(String title, int count) {
    return Container(
        margin: EdgeInsets.only(left: 20),
        child: Row(children: [
          Text(title,
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          Container(
            margin: EdgeInsets.only(left: 8, right: 8),
            child: Material(
              shape: CircleBorder(),
              color: Colors.grey,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(count.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 15)),
              ),
            ),
          )
        ]));
  }

  Widget _buildList(BuildContext context, List<dynamic> items) {
    var listItems = _createListItems(items);

    return ListView.separated(
      itemCount: listItems.length,
      itemBuilder: (context, index) {
        if (listItems[index]['isHeader']) return listItems[index]['widget'];

        return _createTodoWidget(context, listItems[index]['todo']);
      },
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsets.fromLTRB(22.0, 4, 22, 4),
        child: Container(height: 1, color: Colors.black12),
      ),
    );
  }

  Widget _createTodoWidget(BuildContext context, Todo todo) {
    return GestureDetector(
        onTap: () {
          pushNewScreen(
            context,
            screen: AddScreen(todo: todo),
            withNavBar: false, // OPTIONAL VALUE. True by default.
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
        child: TodoItem(
          todo,
          () async {
            await completeTodo(context, todo.documentId);
          },
        ));
  }

  /// Creates a list of To-Do's, grouped by their completeness state.
  /// Also includes header items for each group.
  List<Map<String, dynamic>> _createListItems(List<dynamic> items) {
    var pending = items
        .where((x) => x.isDone == false)
        .map((x) => {'isHeader': false, 'todo': x})
        .toList();
    var completed = items
        .where((x) => x.isDone == true)
        .map((x) => {'isHeader': false, 'todo': x})
        .toList();
    Map<String, dynamic> headerPending = {
      'isHeader': true,
      'widget': _buildHeaderWidget("Pending", pending.length)
    };
    Map<String, dynamic> headerCompleted = {
      'isHeader': true,
      'widget': _buildHeaderWidget("Completed", completed.length)
    };

    var listItems = [headerPending];
    listItems.addAll(pending);
    listItems.add(headerCompleted);
    listItems.addAll(completed);

    return listItems;
  }
}

class TodoItem extends StatefulWidget {
  final bool inDropDown;
  final Todo todo;
  final VoidCallback onCircleTap;

  TodoItem(this.todo, this.onCircleTap, {this.inDropDown = false});

  @override
  _TodoItemState createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  //#region Build

  @override
  Widget build(BuildContext context) {
    var urgent = false;
    var important = false;
    if (widget.todo.priority == Priority.UrgentImportant) {
      urgent = true;
      important = true;
    }
    if (widget.todo.priority == Priority.UrgentNotImportant) {
      urgent = true;
      important = false;
    }
    if (widget.todo.priority == Priority.NotUrgentImportant) {
      urgent = false;
      important = true;
    }

    var textWidget = Text(widget.todo.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: widget.todo.isDone
            ? TextStyle(decoration: TextDecoration.lineThrough, fontSize: 16)
            : TextStyle(
                fontSize: 16,
                color: widget.inDropDown ? Colors.white : Colors.black));

    var titleWidget;

    if (!urgent && !important)
      titleWidget = Container(child: textWidget);
    else
      titleWidget = Expanded(flex: 4, child: textWidget);

    if (widget.inDropDown) {
      titleWidget = Expanded(flex: 4, child: textWidget);

      return _buildDropdownListItem(context, titleWidget, urgent, important);
    }

    return _buildListTile(context, titleWidget, urgent, important);
  }

  //#endregion

  //#region Widgets

  Widget _buildDropdownListItem(
      BuildContext context, Widget titleWidget, bool urgent, bool important) {
    var leadingWidget = buildLeadingIcon();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(margin: EdgeInsets.only(right: 12), child: leadingWidget),
        titleWidget,
        !urgent && !important
            ? Container()
            : Expanded(
                flex: 1,
                child: Row(
                  children: [
                    !urgent
                        ? Container()
                        : buildGradientIcon(
                            20,
                            Icon(Icons.local_fire_department,
                                size: 20, color: Colors.white),
                            LinearGradient(
                                colors: [Colors.red, Colors.orangeAccent])),
                    !important
                        ? Container()
                        : buildGradientIcon(
                            20,
                            Icon(Icons.label_important,
                                size: 20, color: Colors.white),
                            LinearGradient(
                                colors: [Colors.red, Colors.orangeAccent]))
                  ],
                )),
      ],
    );
  }

  Widget _buildListTile(
      BuildContext context, Widget titleWidget, bool urgent, bool important) {
    return ListTile(
      horizontalTitleGap: 4,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          titleWidget,
          !urgent && !important
              ? Container()
              : Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      !urgent
                          ? Container()
                          : buildGradientIcon(
                              20,
                              Icon(Icons.local_fire_department,
                                  size: 20, color: Colors.white),
                              LinearGradient(
                                  colors: [Colors.red, Colors.orangeAccent])),
                      !important
                          ? Container()
                          : buildGradientIcon(
                              20,
                              Icon(Icons.label_important,
                                  size: 20, color: Colors.white),
                              LinearGradient(
                                  colors: [Colors.red, Colors.orangeAccent]))
                    ],
                  )),
        ],
      ),
      leading: buildLeadingIcon(),
      subtitle: Container(
          margin: EdgeInsets.only(top: 4), child: Text(widget.todo.content)),
    );
  }

  Widget buildGradientIcon(double size, Widget widget, Gradient gradient) {
    return ShaderMask(
      child: SizedBox(width: size * 1.2, height: size * 1.2, child: widget),
      shaderCallback: (Rect bounds) {
        final Rect rect = Rect.fromLTRB(0, 0, size, size);
        return gradient.createShader(rect);
      },
    );
  }

  Widget buildLeadingIcon() {
    if (widget.inDropDown)
      return Icon(widget.todo.iconData, size: 16, color: Colors.white);

    return RawMaterialButton(
        onPressed: () {
          widget.onCircleTap();
        },
        elevation: 2.0,
        fillColor: Colors.white,
        padding: EdgeInsets.all(widget.inDropDown ? 0 : 15),
        shape: CircleBorder(),
        child: buildGradientIcon(
            widget.inDropDown ? 16 : 25,
            Icon(
              widget.todo.isDone ? Icons.check : (widget.todo.iconData),
              size: widget.inDropDown ? 16 : 25,
              color: Colors.white,
            ),
            LinearGradient(colors: [Colors.blue, Colors.indigo[800]!])));
  }

//#endregion
}
