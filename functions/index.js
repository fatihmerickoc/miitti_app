const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();


exports.sendNotificationTo =
    functions.https.
        onCall(async (data) => {
          const notification = {
            "token": data.receiver,
            "notification": {
              "body": data.message,
              "title": data.title,
            },
            "data": {
              "type": data.type,
              "myData": data.myData,
            },
          };

          try {
            const response = await admin.messaging().send(notification);
            return response;
          } catch (error) {
            console.error("Error sending notification:", error);
            throw new functions.https.
                HttpsError("internal", "Error sending notification");
          }
        });
