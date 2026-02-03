/* ===================== PUSH NOTIFICATIONS BACKEND ===================== */

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/* ===================== SEND PUSH TO ALL ===================== */
exports.sendPushToAll = functions.https.onRequest(async (req, res) => {
  const { title, body } = req.body;

  if (!title || !body) {
    return res.status(400).json({
      success: false,
      message: "title et body sont requis",
    });
  }

  const message = {
    notification: {
      title: title,
      body: body,
    },
    topic: "all",
  };

  try {
    await admin.messaging().send(message);
    return res.json({
      success: true,
      message: "Notification envoyée à tous les utilisateurs",
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});
