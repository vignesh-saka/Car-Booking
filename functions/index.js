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

// ============================================================================
// ==================== GOOGLE PLACES API PROXY (WEB CORS FIX) ================
// ============================================================================

const axios = require('axios');
// Use the WEB API Key here (restricted to HTTP referrers in Cloud Console)
const GOOGLE_MAPS_API_KEY = 'AIzaSyCwizUugA6ySbo1PnnuNdPxGDXHPZAWtjY';

/**
 * Validates that the request comes from an authenticated user.
 */
const validateAuth = (context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'The function must be called while authenticated.'
    );
  }
};

exports.getPlacesAutocomplete = functions.https.onCall(async (data, context) => {
  validateAuth(context);

  const input = data.input;
  const sessionToken = data.sessionToken;

  if (!input) {
    throw new functions.https.HttpsError('invalid-argument', 'The function must be called with one argument "input".');
  }

  try {
    const response = await axios.get('https://maps.googleapis.com/maps/api/place/autocomplete/json', {
      params: {
        input: input,
        key: GOOGLE_MAPS_API_KEY,
        types: 'geocode',
        language: 'en',
        components: 'country:in',
        sessiontoken: sessionToken
      }
    });

    return response.data;
  } catch (error) {
    console.error("Error fetching places:", error);
    throw new functions.https.HttpsError('internal', 'Unable to fetch places.');
  }
});

exports.getPlaceDetails = functions.https.onCall(async (data, context) => {
  validateAuth(context);

  const placeId = data.placeId;
  const sessionToken = data.sessionToken;

  if (!placeId) {
    throw new functions.https.HttpsError('invalid-argument', 'The function must be called with one argument "placeId".');
  }

  try {
    const response = await axios.get('https://maps.googleapis.com/maps/api/place/details/json', {
      params: {
        place_id: placeId,
        fields: 'geometry,formatted_address,address_component,place_id',
        key: GOOGLE_MAPS_API_KEY,
        language: 'en',
        sessiontoken: sessionToken
      }
    });

    return response.data;
  } catch (error) {
    console.error("Error fetching place details:", error);
    throw new functions.https.HttpsError('internal', 'Unable to fetch place details.');
  }
});
