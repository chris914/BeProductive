import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timemanagement/api/API.dart';
import 'package:flutter_timemanagement/constants.dart';
import 'package:flutter_timemanagement/data/todo.dart';
import 'package:flutter_timemanagement/styles.dart';
import 'package:flutter_timemanagement/util/navigation_helper.dart';
import 'package:flutter_timemanagement/util/navigation_notifier.dart';
import 'package:flutter_timemanagement/widgets/clear_supported_textfield.dart';
import '../util/add_screen_notifier.dart';
import 'package:flutter_timemanagement/widgets/priority_chooser.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddScreen extends StatefulWidget {
  final Todo? todo;

  const AddScreen({Key? key, this.todo}) : super(key: key);

  @override
  AddScreenState createState() => AddScreenState(todo);
}

class AddScreenState extends State<AddScreen> {

  bool pcShown = false;
  bool scheduleShown = false;
  AddScreenNotifier notifier = AddScreenNotifier();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  String title = "";
  String description = "";
  String goalName = "";

  DateTime? date;
  TimeOfDay? time;
  IconData? icon;

  AddScreenState(Todo? todo) {
    if (todo != null) {
      title = todo.title;
      notifier.changePriority(todo.priority);
      icon = todo.iconData;
      goalName = todo.goalName;
      description = todo.content;
      if (todo.timestamp != null) {
        scheduleShown = true;
        var dateTime = todo.timestamp!.toDate();
        this.date = DateTime(dateTime.year, dateTime.month, dateTime.day);
        this.time = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
        dateController.text = _getDateText(this.date!);
        timeController.text = _getTimeText(this.time!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: notifier,
      child: Material(
        child: Stack(children: [
          Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 0, 15, 50),
                child: Visibility(
                  visible: !pcShown,
                  child: Builder(builder: (context) {
                    return FloatingActionButton(
                      elevation: 10.0,
                      onPressed: () {
                        _confirmAddOrUpdate(
                            context.read<AddScreenNotifier>().priority);
                      },
                      splashColor: Colors.green,
                      child:
                          Icon(widget.todo == null ? Icons.add : Icons.check),
                    );
                  }),
                ),
              )),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                  child: ClearSupportedTextField("Title", 1, _setTitle, title)),
              Padding(
                  padding: EdgeInsets.fromLTRB(8, 12, 8, 0),
                  child: ClearSupportedTextField(
                      "Description", 3, _setDescription, description)),
              SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.fromLTRB(8, 12, 8, 0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildScheduleWidget(context),
                        _buildStartPomodoroWidget(context),
                      ],
                    ),
                    Visibility(
                      visible: scheduleShown,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildDateWidget(context),
                            ),
                            SizedBox(width: 40),
                            Expanded(
                              flex: 2,
                              child: _buildTimeWidget(context),
                            ),
                          ]),
                    ),
                  ],
                ),
              ),
              Container(
                  color: Colors.white,
                  child: Divider(
                    color: Colors.black,
                    thickness: 2,
                  )),
              Expanded(
                  child: Column(children: [
                _buildPriorityWidget(context),
                _buildIconWidget(context),
                _buildLinkedToGoalWidget(context),
                Visibility(
                  child: Expanded(child: PriorityChooser()),
                  visible: pcShown,
                )
              ]))
            ],
          ),
        ]),
      ),
    );
  }

  Widget _buildScheduleWidget(BuildContext context) {
    return Row(children: [
      SizedBox(
        width: 24,
        height: 24,
        child: Checkbox(
            value: scheduleShown,
            onChanged: (val) {
              scheduleShown = val!;
              setState(() {});
            }),
      ),
      Container(
          child: InkWell(
            child: Text("Schedule task"),
            onTap: () {
              scheduleShown = !scheduleShown;
              setState(() {});
            },
          ),
          margin: EdgeInsets.only(left: 6))
    ]);
  }

  Widget _buildStartPomodoroWidget(BuildContext context) {
    return Visibility(
      visible: widget.todo != null && !widget.todo!.isDone,
      child: Container(
          child: InkWell(
            child: Row(children: [
              Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(CupertinoIcons.circle_grid_hex_fill,
                      color: Colors.blue)),
              Text("Start Pomodoro",
                  style: TextStyle(fontSize: 16, color: Colors.blue))
            ]),
            onTap: () {
              context
                  .read<NavigationNotifier>()
                  .sendData("PomodoroScreen", widget.todo!);
              NavigationHelper.jumpToPomodoroScreen(widget.todo!);
            },
          ),
          margin: EdgeInsets.only(left: 6)),
    );
  }

  Widget _buildDateWidget(BuildContext context) {
    var onDatePickerShow = () async {
      API.log("Todo Schedule Date");
      FocusScope.of(context).requestFocus(new FocusNode());
      var date = (await showDatePicker(
          context: context,
          initialDate: this.date != null ? this.date! : DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100)))!;
      this.date = date;
      dateController.text = _getDateText(date);
    };

    return TextField(
        controller: dateController,
        cursorColor: Colors.white,
        onTap: () async {
          await onDatePickerShow();
        },
        decoration: HintInputDecoration(
            "Date", Icons.calendar_today, onDatePickerShow));
  }

  Widget _buildTimeWidget(BuildContext context) {
    var onTimePickerShow = () async {
      API.log("Todo Schedule Time");
      FocusScope.of(context).requestFocus(new FocusNode());
      var time = (await showTimePicker(
          context: context,
          initialTime: this.time != null ? this.time! : TimeOfDay.now()))!;
      this.time = time;
      timeController.text = _getTimeText(time);
    };

    return TextField(
        controller: timeController,
        cursorColor: Colors.white,
        onTap: () async {
          await onTimePickerShow();
        },
        decoration: HintInputDecoration(
            "Time", Icons.access_time_outlined, onTimePickerShow));
  }

  Widget _buildPriorityWidget(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Stack(children: [
          Align(
              alignment: Alignment.topLeft,
              child: Row(children: [
                Text("Priority: ", style: TextStyle(fontSize: 16)),
                Builder(builder: (context) {
                  var priority = context.watch<AddScreenNotifier>().priority;
                  return Text(_getPriorityText(priority),
                      style: TextStyle(
                          decoration: priority != Priority.Null
                              ? TextDecoration.underline
                              : null,
                          decorationColor: getColor(priority),
                          fontSize: 16,
                          color: Colors.blueGrey));
                }),
              ])),
          Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {
                  _setPcShown(!pcShown);
                },
                child: Text(pcShown ? "Collapse" : "Set Priority",
                    style: TextStyle(fontSize: 16, color: Colors.blue)),
              )),
        ]));
  }

  Widget _buildIconWidget(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Stack(children: [
          Align(
              alignment: Alignment.topLeft,
              child: Row(children: [
                Text("Icon: ", style: TextStyle(fontSize: 16)),
                Builder(builder: (context) {
                  if (icon != null) return Icon(this.icon, size: 24);

                  return Text("Not set",
                      style: TextStyle(fontSize: 16, color: Colors.blueGrey));
                })
              ])),
          Builder(builder: (context) {
            var widget;
            if (icon == null)
              widget = _buildSetIcon();
            else {
              widget = Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                  margin: EdgeInsets.only(right: 10),
                  child: InkWell(
                    onTap: () {
                      this.icon = null;
                      setState(() {});
                    },
                    child: Text("Clear Icon",
                        style: TextStyle(fontSize: 16, color: Colors.blue)),
                  ),
                ),
                _buildSetIcon(),
              ]);
            }

            return Align(alignment: Alignment.topRight, child: widget);
          }),
        ]));
  }

  Widget _buildLinkedToGoalWidget(BuildContext context) {
    return Visibility(
        visible: widget.todo != null && !pcShown,
        child: FutureBuilder<Map<String, dynamic>>(
            future: API.getUser(),
            builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: Text('Please wait its loading...'));
              } else {
                if (snapshot.hasError)
                  return Center(child: Text('Error: ${snapshot.error}'));
              }

              var goal = snapshot.data!['goalName'];

              return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Stack(children: [
                    Align(
                        alignment: Alignment.topLeft,
                        child: Row(children: [
                          Text("Linked to current goal: ",
                              style: TextStyle(fontSize: 16)),
                          Builder(builder: (context) {
                            var isLinked = widget.todo!.goalName == goal;
                            return snapshot.data!['isGoalActive']
                                ? Text(isLinked ? "Yes" : "No",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.blueGrey))
                                : Flexible(
                                    child: Text("No active goal found",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.blueGrey)),
                                  );
                          })
                        ])),
                    Visibility(
                      visible: snapshot.data!['isGoalActive'],
                      child: Builder(builder: (context) {
                        var w = Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 10),
                                child: InkWell(
                                  onTap: () {
                                    API.log("Link Todo to Goal");

                                    var gn = snapshot.data!['goalName'];
                                    if (widget.todo!.goalName != "") gn = "";

                                    setState(() {
                                      widget.todo!.goalName = gn;
                                      goalName = gn;
                                    });
                                  },
                                  child: Text(
                                    widget.todo!.goalName == goal
                                        ? "Unlink"
                                        : "Link",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.blue),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ),
                            ]);

                        return Align(alignment: Alignment.topRight, child: w);
                      }),
                    )
                  ]));
            }));
  }

  Widget _buildSetIcon() {
    return InkWell(
      child:
          Text("Set Icon", style: TextStyle(fontSize: 16, color: Colors.blue)),
      onTap: _showIconPicker,
    );
  }

  Widget _buildIconButton(IconData data) {
    return ElevatedButton(
        onPressed: () {
          this.icon = data;
          Navigator.of(context, rootNavigator: true).pop();
          setState(() {});
        },
        child: Icon(data));
  }

  void _setPcShown(bool val) {
    setState(() {
      this.pcShown = val;
    });
  }

  String _getPriorityText(Priority priority) {
    var text = "Not set";
    if (priority == Priority.UrgentImportant) text = "Urgent & Important";
    if (priority == Priority.UrgentNotImportant)
      text = "Urgent & Not important";
    if (priority == Priority.NotUrgentImportant)
      text = "Not urgent & Important";
    if (priority == Priority.NotUrgentNotImportant)
      text = "Not urgent & Not important";

    return text;
  }

  String _getDateText(DateTime d) {
    return '${d.year} - ${d.month < 10 ? '0' + d.month.toString() : d.month} - ${d.day < 10 ? '0' + d.day.toString() : d.day}';
  }

  String _getTimeText(TimeOfDay t) {
    return '${t.hour < 10 ? '0' + t.hour.toString() : t.hour} : ${t.minute < 10 ? '0' + t.minute.toString() : t.minute}';
  }

  void _confirmAddOrUpdate(Priority priority) async {
    API.log("ConfirmAddOrUpdate");

    var timeStamp;

    if (scheduleShown && date != null && time != null) {
      DateTime d = DateTime(
          date!.year, date!.month, date!.day, time!.hour, time!.minute);
      timeStamp = Timestamp.fromDate(d);
    }

    final newTodo = Todo(Uuid().v4(), title, description, false, timeStamp,
            priority, icon, goalName)
        .toJson();
    print("GoalName " + goalName);
    if (widget.todo == null) {
      var ref = await API.addTodo(newTodo);
      final snackBar = SnackBar(content: Text('Succesful adding!'));

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      newTodo['documentId'] = widget.todo!.documentId;
      await API.updateTodo(widget.todo!.documentId, newTodo);

      Navigator.pop(context);
    }
  }

  void _setTitle(String title) {
    this.title = title;
  }

  void _setDescription(String description) {
    this.description = description;
  }

  void _showIconPicker() async {
    API.log("IconPicker Chosen");

    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
              title: Text("Challenges", style: GoogleFonts.robotoCondensed()),
              content: Wrap(children: [
                _buildIconButton(Icons.school),
                _buildIconButton(Icons.work_outlined),
                _buildIconButton(Icons.directions_run),
              ]),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text("Close"),
                )
              ]);
        });
  }
}
