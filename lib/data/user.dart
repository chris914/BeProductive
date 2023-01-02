

class User{

  final String documentId;
  final String type;
  String name;
  String goalName;
  int goalsCompleted;
  bool isGoalActive;
  int challengePoints;
  int level;
  List<dynamic> challengesCompleted;

  User(this.documentId, this.type, this.name, this.goalName, this.goalsCompleted, this.isGoalActive, this.challengePoints, this.level, this.challengesCompleted);

  static User fromJson(Map<String, dynamic> json, String documentId){
    print(json);
    var type = json["type"];
    var name = json.containsKey('name') ? json["name"] : "";
    var goalName = "";
    if (json.containsKey("goalName"))
      goalName = json["goalName"];

    var isGoalActive = json['isGoalActive'];
    var goalsCompleted = json['goalsCompleted'];
    var challengePoints = json['challengePoints'];
    var level = json['level'];
    var cc = json['challengesCompleted'];

    return User(documentId, type, name, goalName, goalsCompleted, isGoalActive, challengePoints, level, cc);
  }

  Map<String, dynamic> toJson() {
    var json = Map<String, dynamic>();
    json['documentId'] = documentId; // safe id
    json['type'] = type;
    json['name'] = name;
    json['goalName'] = goalName;
    json['goalsCompleted'] = goalsCompleted;
    json['isGoalActive'] = isGoalActive;
    json['challengePoints'] = challengePoints;
    json['level'] = level;
    json['challengesCompleted'] = challengesCompleted;

    return json;
  }
}