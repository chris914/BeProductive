import 'package:flutter/material.dart';
import 'package:flutter_timemanagement/constants.dart';
import '../util/add_screen_notifier.dart';
import 'package:provider/provider.dart';

class PriorityChooser extends StatefulWidget {
  Priority chosenPriority = Priority.Null;

  @override
  _PriorityChooserState createState() => _PriorityChooserState();
}

class _PriorityChooserState extends State<PriorityChooser> {
  void setChosenPriority(Priority cp)
  {
    setState(() {
      widget.chosenPriority = cp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        var priority = context.read<AddScreenNotifier>().priority;
        widget.chosenPriority = priority;
        return Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 60),
          margin: EdgeInsets.fromLTRB(0, 0, 8, 0),
          child: Row(
              children: [
                Expanded(flex: 1, child: Column(
                  children: [
                    Expanded(flex: 1, child: SizedBox()),
                    Expanded(flex: 6, child: Center(
                      child: RotatedBox(
                          quarterTurns: -1,
                          child: Text("Important")),
                    )),
                    Expanded(flex: 6, child: Center(
                      child: RotatedBox(
                          quarterTurns: -1,
                          child: Text("Not important")),
                    )),
                  ]
                )),
                Expanded(flex: 6, child: Column(
                    children: [
                      Expanded(flex: 1, child: Text("Urgent")),
                      Expanded(child: buildPriorityRectangle(Priority.UrgentImportant), flex: 6),
                      Expanded(child: buildPriorityRectangle(Priority.UrgentNotImportant), flex: 6),
                    ]
                )),
                Expanded(flex: 6, child: Column(
                    children: [
                      Expanded(flex: 1, child: Text("Not urgent")),
                      Expanded(child: buildPriorityRectangle(Priority.NotUrgentImportant), flex: 6),
                      Expanded(child: buildPriorityRectangle(Priority.NotUrgentNotImportant), flex: 6),
                    ]
                )),
                ]
          ),
        );
      }
    );
  }

  Widget buildPriorityRectangle(Priority priority)
  {
    var margin = EdgeInsets.all(2);
    Color selectedColor = getColor(priority);

    return Container(
      color: Colors.black12,
      child: InkWell(
        onTap: () {
          context.read<AddScreenNotifier>().changePriority(priority);
          this.setChosenPriority(priority);
        },
        child: Container(
              margin: margin,
              color: widget.chosenPriority == priority ? selectedColor : Colors.white
          ),
      ),
    );
  }
}

enum Priority
{
  Null,
  UrgentImportant,
  NotUrgentImportant,
  UrgentNotImportant,
  NotUrgentNotImportant
}
