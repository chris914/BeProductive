import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timemanagement/api/API.dart';
import 'package:flutter_timemanagement/data/user.dart';
import 'package:flutter_timemanagement/util/authentication_notifier.dart';
import 'package:flutter_timemanagement/util/user_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../styles.dart';

class HomeScreen extends StatelessWidget {
  late User? user;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    const headerHeight = 290.0;

    return FutureBuilder<Map<String, dynamic>>(
        future: API.getUser(),
        builder: (context, snapshot) {
          var completedGoals;
          var maxGoals;

          if (!snapshot.hasData) {
            user = null;
            return Text("Loading...");
          }
          if (snapshot.data != null)
            user = User.fromJson(snapshot.data!, UserManager.uid);

          print(user!.documentId);
          print(user!.goalName);
          print(user!.name);

          return StreamBuilder(
              stream: API.getTodosWithGoals(user!.goalName),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  API.log("API.getTodosWithGoals snapshot error");
                  return Text("Failed to load your To-do items");
                }

                if (!snapshot.hasData) return Text("Loading your items");

                if (snapshot.connectionState == ConnectionState.waiting)
                  return Text("Loading your items");

                var items = API.getTodosFromSnapshotData(snapshot.data!);

                maxGoals = items.length;
                completedGoals = items.where((x) => x.isDone).length;

                print("max" + maxGoals.toString());
                print("comp" + completedGoals.toString());

                return new Container(
                  child: new Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      // linear gradient
                      new Container(
                        height: headerHeight,
                        decoration: new BoxDecoration(
                          gradient: new LinearGradient(
                              stops: [
                                0.1,
                                0.7,
                                1
                              ],
                              colors: [
                                // Colors are easy thanks to Flutter's Colors class.
                                Color.fromRGBO(71, 75, 104, 1),
                                Color.fromRGBO(57, 60, 87, 1),
                                Color.fromRGBO(51, 55, 82, 1)
                              ],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft),
                        ),
                      ),
                      new Padding(
                        padding: new EdgeInsets.only(
                            top: topPadding,
                            left: 15.0,
                            right: 15.0,
                            bottom: 20.0),
                        child: SingleChildScrollView(
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 15.0, top: 15.0),
                                child: _buildTitle(context),
                              ),
                              new Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: _buildAvatar(
                                    user!.name,
                                    user!.level == 1
                                        ? "Beginner"
                                        : "Time-Manager"),
                              ),
                              _buildUserStats(),
                              Padding(
                                  padding: EdgeInsets.only(top: 20.0),
                                  child: _buildGoalCard(
                                      context, completedGoals, maxGoals)),
                              Padding(
                                  padding: EdgeInsets.only(top: 20.0),
                                  child: _buildChallengesCard(context)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        new Text("Profile",
            style: GoogleFonts.robotoMono(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 40.0,
                letterSpacing: 1.0)),
        InkWell(
            onTap: () async {
              API.signOut();
              context.read<AuthenticationNotifier>().changeIsAuthenticated(false);
              UserManager.uid = "";
            },
            child: Icon(Icons.logout, size: 24, color: Colors.white)),
      ],
    );
  }

  Widget _buildAvatar(String name, String level) {
    final mainTextStyle = GoogleFonts.robotoMono(
        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20.0);
    final subTextStyle = GoogleFonts.robotoMono(
        fontSize: 16.0, color: Colors.white70, fontWeight: FontWeight.w700);

    return new Row(
      children: <Widget>[
        new Container(
          width: 70.0,
          height: 60.0,
          decoration: new BoxDecoration(
            borderRadius: new BorderRadius.all(new Radius.circular(20.0)),
            boxShadow: <BoxShadow>[
              new BoxShadow(
                  color: Colors.black26, blurRadius: 5.0, spreadRadius: 1.0),
            ],
          ),
        ),
        new Padding(padding: const EdgeInsets.only(right: 20.0)),
        new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(name, style: mainTextStyle),
            new Text(level, style: subTextStyle),
          ],
        ),
      ],
    );
  }

  Widget _buildUserStats() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildLabel("Goals Completed", user!.goalsCompleted.toString()),
        _buildVerticalDivider(),
        _buildLabel("Challenge Points", user!.challengePoints.toString()),
      ],
    );
  }

  Widget _buildLabel(String title, String value) {
    final titleStyle =
        GoogleFonts.robotoMono(fontSize: 16.0, color: Colors.white);
    final valueStyle = GoogleFonts.robotoMono(
        fontSize: 18.0, fontWeight: FontWeight.w700, color: Colors.white);
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Text(title, style: titleStyle),
        new Text(value, style: valueStyle),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return new Container(
      height: 30.0,
      width: 1.0,
      color: Colors.white30,
      margin: const EdgeInsets.only(left: 10.0, right: 10.0),
    );
  }

  Widget _buildChallengesCard(BuildContext context) {
    return StreamBuilder(
        stream: API.getChallenges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text('Please wait its loading...'));
          } else {
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
          }

          var challenges = API.getChallengesFromSnapshotData(snapshot.data!);
          print(challenges.length);
          return Container(
            constraints: BoxConstraints(
                minHeight: 0, minWidth: double.infinity, maxHeight: 200),
            child: Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Color.fromRGBO(44, 50, 72, 1),
                  width: 0.7,
                ),
                borderRadius: BorderRadius.circular(15.0),
              ),
              color: Color.fromRGBO(61, 65, 92, 1),
              elevation: 4.0,
              child: _buildGoalListView(context, challenges),
            ),
          );
        });
  }

  Widget _buildGoalListView(
      BuildContext context, List<Map<String, dynamic>> challenges) {
    var challengesCompleted =
        user!.challengesCompleted.map((x) => x as String).toList();
    print(challengesCompleted);
    print(challenges);
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            trailing: InkWell(
                child: Icon(Icons.info_outline, color: Colors.blue, size: 20),
                onTap: () {
                  showInfoDialog(context, "Challenges");
                }),
            title: Text("Challenges", style: TextStyle(color: Colors.white)),
          ),
          Container(height: 2, color: Colors.black12),
          MediaQuery.removePadding(
            // Listview had it's own padding. Wasted 2 hours for trying everything to remove it..
            context: context,
            removeTop: true,
            child: ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: challenges.length,
              itemBuilder: (context, index) => FutureBuilder<String>(
                  future: API.getImageUrl(challenges[index]['ImageName']!),
                  builder: (context, imgSnapshot) {
                    if (imgSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: Container(color: Colors.yellow));
                    } else {
                      if (imgSnapshot.hasError)
                        return Center(child: Container(color: Colors.yellow));
                    }

                    var imageUrl = imgSnapshot.data!;
                    var listTile = ListTile(
                        title: Text(challenges[index]['Name']!,
                            style: TextStyle(
                                fontSize: 15, color: Colors.deepOrange)),
                        leading: imageUrl != ""
                            ? Image.network(imageUrl, width: 40, height: 40)
                            : Container());
                    return !challengesCompleted
                            .contains(challenges[index]['id'])
                        ? Container(
                            foregroundDecoration: BoxDecoration(
                              color: Colors.grey,
                              backgroundBlendMode: BlendMode.saturation,
                            ),
                            child: listTile)
                        : Container(child: listTile);
                  }),
              separatorBuilder: (context, index) =>
                  Container(height: 2, color: Colors.black12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(
      BuildContext context, int completedGoals, int maxGoals) {
    return Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Color.fromRGBO(44, 50, 72, 1),
            width: 0.7,
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Color.fromRGBO(61, 65, 92, 1),
        elevation: 4.0,
        child: Column(
          children: [
            user != null && user!.goalName == ""
                ? Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: Center(
                        child: Text("No goal set for now!",
                            style: GoogleFonts.robotoCondensed(
                                color: Colors.white, fontSize: 18))),
                  )
                : _buildGoalListTile(
                    context, user!.goalName, completedGoals, maxGoals),
            ButtonBar(
              children: [
                Visibility(
                  visible: (user != null && user!.goalName != ""),
                  child: TextButton(
                    child: const Text('REMOVE GOAL',
                        style: TextStyle(color: Colors.red)),
                    onPressed: () {
                      _removeGoal();
                    },
                  ),
                ),
                TextButton(
                  child: const Text('ADD NEW GOAL',
                      style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    _showAddNewGoalDialog(context);
                  },
                )
              ],
            )
          ],
        ));
  }

  void _removeGoal() {
    // Set goal to empty string, unlink to-dos.
  }

  void _showAddNewGoalDialog(BuildContext context) {
    var controller = TextEditingController();
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
                title: Text("Name your goal",
                    style: GoogleFonts.robotoCondensed()),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Visibility(
                        visible: user!.goalName != "",
                        child: Text("This will replace your current goal!",
                            style: TextStyle(color: Colors.red))),
                    Text("Tasks in the To-Do list can be linked to the goal.",
                        style: GoogleFonts.robotoCondensed()),
                    TextField(controller: controller),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () async {
                      // Log an event.
                      API.logEvent("new_goal_added",
                          data: {"goalNameLength": controller.text.length});

                      user!.goalName = controller.text;
                      user!.isGoalActive = true;
                      await API.updateUser(UserManager.uid, user!.toJson());
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: Text("Add"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: Text("Cancel"),
                  )
                ]),
        barrierDismissible: true);
  }

  Widget _buildGoalListTile(
      BuildContext context, String goalName, int completedGoals, int maxGoals) {
    return ListTile(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              child: Text(goalName, style: TextStyle(color: Colors.white)),
              margin: EdgeInsets.only(top: 2.0)),
          Container(
              child: Text("Current Goal",
                  style: TextStyle(color: Colors.white, fontSize: 14)),
              margin: EdgeInsets.only(top: 2.0)),
        ],
      ),
      subtitle: Container(
        margin: EdgeInsets.only(top: 8.0, left: 0.0),
        child: LinearPercentIndicator(
          width: MediaQuery.of(context).size.width / 1.3,
          animation: true,
          lineHeight: 20.0,
          animationDuration: 2500,
          percent: maxGoals > 0 ? (completedGoals / maxGoals) : 0,
          center: Text(
              maxGoals > 0
                  ? (completedGoals.toString() + " / " + maxGoals.toString())
                  : "No tasks linked to goal yet",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          linearStrokeCap: LinearStrokeCap.butt,
          progressColor: Colors.green,
        ),
      ),
    );
  }
}
