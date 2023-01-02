import 'package:flutter/material.dart';
import 'package:flutter_timemanagement/api/API.dart';
import 'package:flutter_timemanagement/data/todo.dart';
import 'package:flutter_timemanagement/constants.dart';
import 'package:flutter_timemanagement/screen/add_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.lightBlueAccent,
        margin: EdgeInsets.only(top: 25, bottom: 50),
        child: Center(child: _buildCalendar()));
  }

  Widget _buildCalendar() {
    return Container(
      child: StreamBuilder(
          stream: API.getTodos(),
          builder: (context, snapshot) {
            return SfCalendar(
              view: CalendarView.week,
              cellBorderColor: Colors.blueGrey,
              todayHighlightColor: Colors.red,
              allowViewNavigation: true,
              showDatePickerButton: true,
              allowedViews: <CalendarView>[
                CalendarView.day,
                CalendarView.week,
                CalendarView.workWeek,
                CalendarView.month,
                CalendarView.timelineMonth,
                CalendarView.schedule
              ],
              monthViewSettings: MonthViewSettings(
                showAgenda: true,
              ),
              dataSource: _getCalendarDataSource(snapshot),
              viewHeaderStyle: ViewHeaderStyle(
                  backgroundColor: Color.fromRGBO(0, 0, 255, 0.65),
                  dayTextStyle: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFff5eaea),
                      fontWeight: FontWeight.w500),
                  dateTextStyle: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFff5eaea),
                      letterSpacing: 2,
                      fontWeight: FontWeight.w500)),
              onTap: (CalendarTapDetails details) {
                if (details.targetElement == CalendarElement.appointment)
                  _calendarTap(details);
              },
            );
          }),
    );
  }

  /// Constructs and returns the data source for the Calendar widget.
  _AppointmentDataSource _getCalendarDataSource(
      AsyncSnapshot snapshot) {
    List<TodoAppointment> appointments = <TodoAppointment>[];
    if (snapshot.data == null) return _AppointmentDataSource(appointments);

    final items = API.getTodosFromSnapshotData(snapshot.data!);
    items.forEach((element) {
      var todo = element;
      if (todo.timestamp != null) {
        var appointment = _createTodoAppointment(todo);
        appointments.add(appointment);
      }
    });

    return _AppointmentDataSource(appointments);
  }

  /// Creates a TodoAppointment object from a To-do model object.
  TodoAppointment _createTodoAppointment(Todo todo) {
    var date = todo.timestamp!.toDate();
    return TodoAppointment(
      todo,
      startTime: DateTime(date.year, date.month, date.day, date.hour),
      isAllDay: false,
      endTime: DateTime(date.year, date.month, date.day, date.hour + 2),
      subject: todo.title,
      color: getColor(todo.priority),
      startTimeZone: '',
      endTimeZone: '',
    );
  }

  /// Handles the calendar tap event. If the tap was on an appointment this function will navigate to the To-Do.
  void _calendarTap(CalendarTapDetails details) {
    if (details.appointments == null) return;

    if (details.appointments!.length != 1) return;

    var first = details.appointments!.first;
    if (!(first is TodoAppointment)) return;

    var todo = first.todo;
    pushNewScreen(
      context,
      screen: AddScreen(todo: todo),
      withNavBar: true,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<TodoAppointment> source) {
    appointments = source;
  }
}

class TodoAppointment extends Appointment {
  final Todo todo;

  TodoAppointment(this.todo,
      {required DateTime startTime,
      required bool isAllDay,
      required DateTime endTime,
      required String subject,
      required Color color,
      required String startTimeZone,
      required String endTimeZone})
      : super(
            startTime: startTime,
            endTime: endTime,
            isAllDay: isAllDay,
            subject: subject,
            color: color,
            startTimeZone: startTimeZone,
            endTimeZone: endTimeZone);
}
