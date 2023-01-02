import 'package:flutter/material.dart';
import 'package:flutter_timemanagement/api/API.dart';
import 'package:flutter_timemanagement/data/todo.dart';
import 'package:flutter_timemanagement/screen/todo_screen.dart';
import 'package:flutter_timemanagement/util/functions.dart';
import 'package:flutter_timemanagement/util/navigation_notifier.dart';
import 'package:flutter_timemanagement/util/pomodoro_notifier.dart';
import 'package:flutter_timemanagement/widgets/circular_countdown_timer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../styles.dart';

class PomodoroContent extends StatefulWidget {
  final VoidCallback? onPomodoroStart;
  final VoidCallback? onPomodoroEnd;

  const PomodoroContent({Key? key, this.onPomodoroStart, this.onPomodoroEnd})
      : super(key: key);

  @override
  _PomodoroContentState createState() => _PomodoroContentState();
}

class _PomodoroContentState extends State<PomodoroContent> {
  CountDownController _controller = CountDownController();
  _DropDownButtonItem? dropDownValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 15),
        StreamBuilder(
            stream: API.getInProgressTodos(),
            builder: (context, snapshot) {
              _DropDownButtonItem? placeHolderItem;
              _DropDownButtonItem blankItem = _DropDownButtonItem(true, "");
              List<_DropDownButtonItem>? items;

              if (snapshot.hasError)
                placeHolderItem = _DropDownButtonItem(
                    false, "Failed to load your To-do items");

              if (!snapshot.hasData)
                placeHolderItem =
                    _DropDownButtonItem(false, "Loading your items");

              if (snapshot.connectionState == ConnectionState.waiting)
                placeHolderItem =
                    _DropDownButtonItem(false, "Loading your items");

              if (snapshot.hasData &&
                  snapshot.connectionState != ConnectionState.waiting) {

                final todos = API.getTodosFromSnapshotData(snapshot.data!);

                items = todos.map((e) => _DropDownButtonItem(false, "",
                        todo: e))
                    .toList();

                if (items.isEmpty)
                  placeHolderItem =
                      _DropDownButtonItem(false, "Your task list is empty");

                List<_DropDownButtonItem> dropdownItems = [blankItem];
                placeHolderItem == null
                    ? dropdownItems.addAll(items)
                    : dropdownItems.add(placeHolderItem);

                var isUpdateRequired =
                    context.watch<NavigationNotifier>().isUpdateRequired;
                if (isUpdateRequired) {
                  var todo =
                      context.read<NavigationNotifier>().consumeData() as Todo;
                  _selectDropdownValue(todo);
                  return _buildDropDown(context, dropdownItems);
                } else
                  return _buildDropDown(context, dropdownItems);
              }

              return DropdownButton<String>(
                  items: [DropdownMenuItem(child: Text(""))]);
            }),
        _buildCircularTimer(context),
        _buildStartStopButton(context)
      ],
    );
  }

  Widget _buildDropDown(BuildContext context, List<_DropDownButtonItem> items) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      child: DropdownButton<_DropDownButtonItem>(
        menuMaxHeight: MediaQuery.of(context).size.height / 2,
        value: dropDownValue,
        dropdownColor: Color.fromRGBO(61, 65, 92, 1),
        isExpanded: true,
        hint: Container(
            margin: EdgeInsets.all(4),
            child: Text("Select a task or leave it blank",
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey))),
        elevation: 16,
        style: lightRegularText,
        onChanged: (_DropDownButtonItem? newValue) {
          setState(() {
            if (newValue!.errorText == "" || newValue.isBlankPlaceHolder) {
              dropDownValue = newValue;
            }
          });
        },
        items: items.map<DropdownMenuItem<_DropDownButtonItem>>(
            (_DropDownButtonItem value) {
          if (value.todo != null) {
            var item = DropdownMenuItem<_DropDownButtonItem>(
                value: value,
                child: TodoItem(
                  value.todo!,
                  () {},
                  inDropDown: true,
                ));

            return item;
          }
          if (value.isBlankPlaceHolder) {
            return DropdownMenuItem<_DropDownButtonItem>(
                value: value,
                child: Text(
                    "Select a task from your to-do list or leave it blank"));
          }
          if (value.errorText != "") {
            return DropdownMenuItem<_DropDownButtonItem>(
                value: value,
                child: Text(value.errorText,
                    style: TextStyle(color: Colors.grey)));
          } else
            return DropdownMenuItem<_DropDownButtonItem>(
                value: value, child: Center());
        }).toList(),
      ),
    );
  }

  Widget _buildCircularTimer(BuildContext context) {
    return Container(
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(Color.fromRGBO(61, 65, 92, 1)),
            shadowColor: MaterialStateProperty.all(Colors.black),
            elevation: MaterialStateProperty.all(22),
            shape: MaterialStateProperty.all<CircleBorder>(CircleBorder())),
        onPressed: () {},
        child: Padding(
          padding: EdgeInsets.all(26),
          child: CircularCountDownTimer(
            duration: 25,
            initialDuration: 0,
            everStarted: context.read<PomodoroNotifier>().isRunning,
            controller: _controller,
            width: MediaQuery.of(context).size.width / 2.2,
            height: MediaQuery.of(context).size.height / 2.2,
            ringColor: Color.fromRGBO(70, 80, 104, 1),
            ringGradient: null,
            fillColor: Colors.blueAccent,
            fillGradient: countDownTimerGradient,
            backgroundColor: Colors.transparent,
            backgroundGradient: null,
            strokeWidth: 5.0,
            strokeCap: StrokeCap.round,
            textStyle:
                GoogleFonts.robotoMono(fontSize: 28.0, color: Colors.white),
            textFormat: CountdownTextFormat.MM_SS,
            isReverse: true,
            isReverseAnimation: false,
            isTimerTextShown: true,
            autoStart: false,
            onStart: () {
              if (dropDownValue != null && dropDownValue!.todo != null)
                API.log("Pomodoro Countdown Started with Todo");
              else
                API.log("Pomodoro Countdown Started");

            },
            onComplete: () async {
              _onCountDownCompleted();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStartStopButton(BuildContext context) {
    return Container(
      height: 40,
      child: Builder(builder: (context) {
        var isRunning = context.watch<PomodoroNotifier>().isRunning;
        print("rebuild");
        return ElevatedButton(
            onPressed: () {
              if (!isRunning) {
                if (widget.onPomodoroStart != null) widget.onPomodoroStart!();

                _controller.start();
                context.read<PomodoroNotifier>().changeIsRunning(true);
              } else {
                if (widget.onPomodoroEnd != null) widget.onPomodoroEnd!();
                API.logEvent("pomodoro_stopped", data: { "timeLeft" : _controller.getTime() });
                API.log("Pomodoro Countdown Stopped");
                _controller.stop();
                context.read<PomodoroNotifier>().changeIsRunning(false);
              }
            },
            child: isRunning ? Icon(Icons.stop) : Icon(Icons.play_arrow),
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Color.fromRGBO(69, 76, 107, 1)),
                //Background Color
                elevation: MaterialStateProperty.all(8),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ))));
      }),
    );
  }

  /// Handles the event when the countdown completes.
  /// Adds a new Pomodoro entry, and if there was a To-Do selected the user can choose
  /// whether it should be marked completed or not.
  ///
  /// CALLS FIREBASE CLOUD FUNCTIONS
  void _onCountDownCompleted() async {
    if (dropDownValue != null) {
      if (dropDownValue!.todo != null) {
        context.read<PomodoroNotifier>().changeIsRunning(false);

        var todo = dropDownValue!.todo!;
        _showDialogForResult(context, () async {
          todo.isDone = !todo.isDone;
          dropDownValue = null;
          Navigator.of(context, rootNavigator: true).pop();

          await addPomodoroEntry(context,
              todoDocumentId: todo.documentId, completeTodo: true);
        }, () async {
          await addPomodoroEntry(context, todoDocumentId: todo.documentId);
          Navigator.of(context, rootNavigator: true).pop();
        });
      } else // Pomodoro done, no active task selected
        await addPomodoroEntry(context);
    } else // Pomodoro done, no active selection (i.e. dropdown is empty)
      await addPomodoroEntry(context);

    context.read<PomodoroNotifier>().changeIsRunning(false);
  }

  /// Shows a dialog with a simple text and a Yes/No button.
  /// Callbacks are used for each button.
  void _showDialogForResult(
      BuildContext context, VoidCallback onPositive, VoidCallback onNegative) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
                title: Text("Did you finish the task?"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "By choosing Yes the task will be marked complete in your To-Do list.",
                        style: TextStyle(fontSize: 12)),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () async {
                      onPositive();
                    },
                    child: Text("Yes"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      onNegative();
                    },
                    child: Text("No"),
                  )
                ]),
        barrierDismissible: true);
  }

  void _selectDropdownValue(Todo todo) {
    dropDownValue = _DropDownButtonItem(false, "", todo: todo);
  }
}

class PomodoroScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PomodoroScreenState();
}

class PomodoroScreenState extends State<PomodoroScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: pomodoroScreenGradient),
      child: Center(
          child: Column(
        children: [
          SizedBox(height: 65),
          Container(
            margin: EdgeInsets.all(8),
            child: Text(
              "Pomodoro",
              style: headerText,
              textAlign: TextAlign.center,
            ),
          ),
          PomodoroContent()
        ],
      )),
    );
  }
}

/// Helper class for the creation of DropDownButton items.
/// Can be either a placeholder, can hold an error text, or a To-Do.
class _DropDownButtonItem {
  bool isBlankPlaceHolder;
  String errorText;
  Todo? todo;

  _DropDownButtonItem(this.isBlankPlaceHolder, this.errorText, {this.todo});

  @override
  bool operator ==(Object other) {
    if (other is _DropDownButtonItem) {
      if (other.todo != null && todo != null)
        return other.todo!.documentId == todo!.documentId;
      else
        return other.isBlankPlaceHolder == isBlankPlaceHolder &&
            other.errorText == errorText;
    }

    return false;
  }

  @override
  int get hashCode => super.hashCode;
}
