const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

/**
 * Triggers when a new document is created in the 'notifications' collection.
 * Sends a Push Notification to the target user.
 */
exports.sendPushNotification = functions.firestore
  .document("notifications/{notificationId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const userId = data.userId;
    const title = data.title;
    const body = data.body;
    const type = data.type; // 'ride_published', 'booking_request', etc.

    if (!userId || !title || !body) {
      console.log("Missing required fields for notification.");
      return;
    }

    try {
      // 1. Get the user's FCM token from the 'users' collection
      const userDoc = await admin.firestore().collection("users").doc(userId).get();
      
      if (!userDoc.exists) {
        console.log(`User ${userId} does not exist.`);
        return;
      }

      const userData = userDoc.data();
      const fcmToken = userData.fcmToken;

      if (!fcmToken) {
        console.log(`No FCM token found for user ${userId}.`);
        return;
      }

      // 2. Construct the message
      const message = {
        token: fcmToken,
        notification: {
            title: title,
            body: body,
        },
        data: {
            type: type || 'general',
            click_action: 'FLUTTER_NOTIFICATION_CLICK'
        },
        android: {
            priority: 'high',
            notification: {
                clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                channelId: 'high_importance_channel'
            }
        },
        apns: {
            payload: {
                aps: {
                  badge: 1,
                  sound: 'default'
                }
            }
        }
      };

      // 3. Send the message
      const response = await admin.messaging().send(message);
      console.log("Successfully sent message:", response);

    } catch (error) {
      console.error("Error sending push notification:", error);
    }
  });
