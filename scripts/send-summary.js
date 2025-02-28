// send-summary.js

const admin = require("firebase-admin");
const sgMail = require("@sendgrid/mail");

// Initialize Firebase Admin using a service account.
const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
const db = admin.firestore();

// Set SendGrid API key.
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

// Compute today's date range: start (00:00:00) to end (23:59:59.999)
function getTodayRange() {
  const today = new Date();
  const start = new Date(today);
  start.setHours(0, 0, 0, 0);
  const end = new Date(today);
  end.setHours(23, 59, 59, 999);
  return { start, end };
}

async function sendExpirySummary() {
  const { start, end } = getTodayRange();
  console.log(`Querying for reminderDate between ${start} and ${end}`);

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
      console.log(`No expiring items for user ${email} today.`);
      continue;
    }

    const expiringItems = [];
    querySnapshot.forEach((doc) => {
      const data = doc.data();
      expiringItems.push(data.itemName);
    });

    const messageBody = `Hello,\n\nYou have ${
      expiringItems.length
    } item(s) expiring today: ${expiringItems.join(
      ", "
    )}.\n\nRegards,\nWasteNot Team`;
    const msg = {
      to: email,
      from: process.env.SENDER_EMAIL, // Must be a verified sender with SendGrid.
      subject: "Today's Expiring Items",
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
