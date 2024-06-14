const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();
const db = admin.firestore();

const FLW_SECRET_KEY = 'FLWSECK_TEST-2826187567b55edaebbc92c83919a452-X';
const FLW_PUBLIC_KEY = 'FLWPUBK_TEST-14043e04db319cdd35543592e1e5a727-X';

// Initiate Payment Function
exports.initiatePayment = functions.https.onCall(async (data, context) => {
  const { amount, currency, email } = data;
  try {
    const response = await axios.post('https://api.flutterwave.com/v3/payments', {
      tx_ref: `tx-${Date.now()}`,
      amount,
      currency,
      redirect_url: 'https://your-redirect-url.com',
      customer: {
        email,
      },
    }, {
      headers: {
        Authorization: `Bearer ${FLW_SECRET_KEY}`,
      },
    });
    return response.data;
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// Webhook Endpoint
exports.handleWebhook = functions.https.onRequest(async (req, res) => {
  const hash = req.headers['verif-hash'];
  if (!hash) {
    return res.status(400).send('Missing verification hash');
  }

  if (hash !== FLW_SECRET_KEY) {
    return res.status(400).send('Invalid verification hash');
  }

  const payload = req.body;
  // Handle payment verification here, e.g., update Firestore with payment status
  await db.collection('payments').doc(payload.tx_ref).set(payload, { merge: true });

  res.status(200).send('Webhook received');
});
