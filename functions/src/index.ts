import * as functions from "firebase-functions";
var serviceAccount = require("../service-account.json");
import admin = require("firebase-admin");
import { firestore } from "firebase-admin";
admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
   });

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//

export const onCompleted = functions.https.onCall(async (data, context) => {
   var uid = context.auth!.uid;
   functions.logger.info(data, {structuredData: true});
   var type = data['type'];
   var obj = data['object'];

   var completeTodo = async function completeTodo(id:string) {
      await admin.firestore().collection("users").doc(uid).collection("todos").doc(id).update({'isDone' : true});
   };

   // Pomodoro session completed, add a new entry.
   if (type == 'Pomodoro') 
   {
      if (data['completeTodo'])
         await completeTodo(obj['todoDocumentId']);
      
      obj['timeStamp'] = admin.firestore.FieldValue.serverTimestamp();
      await admin.firestore().collection("users").doc(uid).collection("pomodoros").add(obj);
   }

   // Todo completed, update the existing entry.
   if (type == "Todo")
      await completeTodo(obj['todoDocumentId']);

   const userRef = admin.firestore().collection("users").doc(uid);
   const todosRef = admin.firestore().collection("users").doc(uid).collection("todos");
   const pomodorosRef = admin.firestore().collection("users").doc(uid).collection("pomodoros");
   const challengesRef = admin.firestore().collection("challenges");

   const [userSnapshot, todosSnapshot, pomodoroSnapshot, challengesSnapshot] = await Promise.all([userRef.get(), todosRef.get(), pomodorosRef.get(), challengesRef.get()]);

   const user = userSnapshot.data();
   const listTodo = todosSnapshot.docs;
   const listPomodoro = pomodoroSnapshot.docs;
   const listChallenges = challengesSnapshot.docs;

   let userCompletedChallenges : Array<string> = [];
   if (user != null)
   userCompletedChallenges = user['challengesCompleted'];

   let newChallengesCompleted : Array<any> = [];
   functions.logger.info(listTodo.length, {structuredData: true});

   if (user!['isGoalActive'])
   {
      var todosWithGoals = listTodo.filter(x => x.data()['goalName'] == user!['goalName']).length;;
      var completedTodosWithGoals = listTodo.filter(x => x.data()['goalName'] == user!['goalName'] && x.data()!['isDone'] == true).length;
      functions.logger.info(todosWithGoals + " - " + completedTodosWithGoals, {structuredData: true});
      if (todosWithGoals == completedTodosWithGoals)
      {
         let signedUrl = await admin.storage()
         .bucket("timemanagement-flutter.appspot.com")
         .file("challenge_goal.png")
         .getSignedUrl({
            version: 'v4',
            action: 'read',
            expires: Date.now() + 15 * 60 * 1000 
         });

         user!['isGoalActive'] = false;
         user!['goalsCompleted']++;
         user!['challengePoints'] += user!['goalsCompleted'] == 0 ? 100 : 50;
         admin.firestore().collection("users").doc(uid).update(user!);

         newChallengesCompleted.push({name: "Goal Completed!", description: user!['goalName'], points: user!['goalsCompleted'] == 0 ? 100 : 50, imageUrl: signedUrl.toString()});
      }
   }

   await Promise.all(listChallenges.map(async (snap) => {
   if (userCompletedChallenges.indexOf(snap.id) < 0)
   {
      var challengeData = snap.data();
      var type = challengeData['Type'];
      var countReq = challengeData['CountRequirement'];

      // Challenge completed
      if ((type == "Pomodoro" && listPomodoro.length >= countReq) || (type == "Todo" && listTodo.filter(x => x.data()['isDone'] == true).length >= countReq))
      {
         admin.firestore().collection("users").doc(uid).update({
            'challengesCompleted' : firestore.FieldValue.arrayUnion(snap.id.toString())
         });

         if (challengeData["ImageName"] != "")
         {
            let signedUrl = await admin.storage()
            .bucket("timemanagement-flutter.appspot.com")
            .file(challengeData["ImageName"])
            .getSignedUrl({
               version: 'v4',
               action: 'read',
               expires: Date.now() + 15 * 60 * 1000 
            });

            newChallengesCompleted.push({name: "Challenge Completed", description: challengeData['Name'], points: challengeData['Points'], imageUrl: signedUrl.toString()});
         }
         else
            newChallengesCompleted.push({name: "Challenge Completed", description: challengeData['Name'], points: challengeData['Points']});
      }
   }
   }));

    return {
       shouldUpdate: true,
       object: newChallengesCompleted
    };
});

export const test = functions.https.onCall(async (data, context) => {
    var uid = context.auth!.uid;

    const userRef = admin.firestore().collection("users").doc(uid);
    const todosRef = admin.firestore().collection("users").doc(uid).collection("todos");
    const pomodorosRef = admin.firestore().collection("users").doc(uid).collection("pomodoros");
    const challengesRef = admin.firestore().collection("challenges");

    const [userSnapshot, todosSnapshot, pomodoroSnapshot, challengesSnapshot] = await Promise.all([userRef.get(), todosRef.get(), pomodorosRef.get(), challengesRef.get()]);

    const user = userSnapshot.data();
    const listTodo = todosSnapshot.docs;
    const listPomodoro = pomodoroSnapshot.docs;
    const listChallenges = challengesSnapshot.docs;

    let userCompletedChallenges : Array<string> = [];
    if (user != null)
      userCompletedChallenges = user['challengesCompleted'];

    let newChallengesCompleted : Array<any> = [];
    functions.logger.info(listTodo.length, {structuredData: true});

    if (user!['isGoalActive'])
    {
      var todosWithGoals = listTodo.filter(x => x.data()['goalName'] == user!['goalName']).length;;
      var completedTodosWithGoals = listTodo.filter(x => x.data()['goalName'] == user!['goalName'] && x.data()!['isDone'] == true).length;
      functions.logger.info(todosWithGoals + " - " + completedTodosWithGoals, {structuredData: true});
      if (todosWithGoals == completedTodosWithGoals)
      {
         user!['isGoalActive'] = false;
         user!['goalsCompleted']++;
         user!['challengePoints'] += user!['goalsCompleted'] == 0 ? 100 : 50;
         admin.firestore().collection("users").doc(uid).update(user!);

         newChallengesCompleted.push({name: "Goal Completed!", points: user!['goalsCompleted'] == 0 ? 100 : 50});
      }
    }

    await Promise.all(listChallenges.map(async (snap) => {
      if (userCompletedChallenges.indexOf(snap.id) < 0)
      {
         var challengeData = snap.data();
         var type = challengeData['Type'];
         var countReq = challengeData['CountRequirement'];

         if ((type == "Pomodoro" && listPomodoro.length >= countReq) || (type == "Todo" && listTodo.length >= countReq))
         {
            if (challengeData["ImageName"] != "")
            {
               let signedUrl = await admin.storage()
               .bucket("timemanagement-flutter.appspot.com")
               .file(challengeData["ImageName"])
               .getSignedUrl({
                  version: 'v4',
                  action: 'read',
                  expires: Date.now() + 15 * 60 * 1000 
               });

               newChallengesCompleted.push({name: challengeData['Name'], points: challengeData['Points'], imageUrl: signedUrl.toString()});
            }
            else
               newChallengesCompleted.push({name: challengeData['Name'], points: challengeData['Points']});
         }
      }
     }));
     
    return {
       shouldUpdate: true,
       object: newChallengesCompleted
    };
 });
