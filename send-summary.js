// send-summary.js

const admin = require("firebase-admin");
const sgMail = require("@sendgrid/mail");

// Initialize Firebase Admin using a service account.
// You can load the service account JSON from an environment variable.
const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
const db = admin.firestore();

// Set SendGrid API key.
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

function getTomorrowRange() {
  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  tomorrow.setHours(0, 0, 0, 0);
  const tomorrowEnd = new Date(tomorrow);
  tomorrowEnd.setHours(23, 59, 59, 999);
  return { start: tomorrow, end: tomorrowEnd };
}

async function sendExpirySummary() {
  const { start, end } = getTomorrowRange();
  const usersSnapshot = await db.collection("users").get();

  for (const userDoc of usersSnapshot.docs) {
    const userData = userDoc.data();
    const email = userData.email;
    if (!email) continue;

    const inventoryRef = db
      .collection("users")
      .doc(userDoc.id)
      .collection("inventory");
    const querySnapshot = await inventoryRef
      .where("reminderDate", ">=", admin.firestore.Timestamp.fromDate(start))
      .where("reminderDate", "<=", admin.firestore.Timestamp.fromDate(end))
      .get();

    if (querySnapshot.empty) {
      console.log(`No expiring items for user ${email} tomorrow.`);
      continue;
    }

    const expiringItems = [];
    querySnapshot.forEach((doc) => {
      const data = doc.data();
      expiringItems.push(data.itemName);
    });

    const messageBody = `Hello,\n\nYou have ${
      expiringItems.length
    } item(s) expiring tomorrow: ${expiringItems.join(
      ", "
    )}.\n\nRegards,\nWasteNot Team`;
    const msg = {
      to: email,
      from: process.env.SENDER_EMAIL, // Must be a verified sender with SendGrid.
      subject: "Items Expiring Tomorrow",
      text: messageBody,
    };

    try {
      await sgMail.send(msg);
      console.log(`Email sent to ${email}`);
    } catch (error) {
      console.error(`Error sending email to ${email}:`, error);
    }
  }
}

sendExpirySummary()
  .then(() => {
    console.log("Summary job complete.");
    process.exit(0);
  })
  .catch((error) => {
    console.error("Error in summary job:", error);
    process.exit(1);
  });
