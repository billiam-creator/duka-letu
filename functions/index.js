// functions/index.js
const functions = require("firebase-functions");
const axios = require("axios");

// v1 HTTPS Function
exports.initiateMpesaStkPush = functions.https.onRequest(async (request, response) => {
  if (request.method !== "POST" || !request.body.phone || !request.body.amount) {
    return response.status(400).send("Bad Request. Missing phone or amount.");
  }

  // 🔑 Get from Firebase config (run `firebase functions:config:set` to set these)
  const consumerKey = functions.config().mpesa.consumer_key;
  const consumerSecret = functions.config().mpesa.consumer_secret;
  const businessShortCode = functions.config().mpesa.shortcode;
  const passkey = functions.config().mpesa.passkey;

  // 🕒 Timestamp YYYYMMDDHHMMSS
  const pad = (n) => (n < 10 ? "0" + n : n);
  const now = new Date();
  const timestamp =
    now.getFullYear().toString() +
    pad(now.getMonth() + 1) +
    pad(now.getDate()) +
    pad(now.getHours()) +
    pad(now.getMinutes()) +
    pad(now.getSeconds());

  const password = Buffer.from(businessShortCode + passkey + timestamp).toString("base64");

  const tokenUrl = "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials";
  const stkPushUrl = "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest";

  const authHeader = "Basic " + Buffer.from(consumerKey + ":" + consumerSecret).toString("base64");

  try {
    // 1️⃣ Get access token
    const tokenResponse = await axios.get(tokenUrl, {
      headers: { Authorization: authHeader },
    });
    const accessToken = tokenResponse.data.access_token;

    // 2️⃣ Send STK Push
    const requestPayload = {
      BusinessShortCode: businessShortCode,
      Password: password,
      Timestamp: timestamp,
      TransactionType: "CustomerPayBillOnline",
      Amount: request.body.amount,
      PartyA: request.body.phone,
      PartyB: businessShortCode,
      PhoneNumber: request.body.phone,
      CallBackURL: "https://YOUR_NGROK_URL/callback", // replace with ngrok
      AccountReference: "DukaLetu E-Commerce",
      TransactionDesc: "Payment for Duka Letu",
    };

    const stkPushResponse = await axios.post(stkPushUrl, requestPayload, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });

    response.status(200).send({
      success: true,
      message: "STK Push initiated successfully!",
      data: stkPushResponse.data,
    });
  } catch (error) {
    console.error("❌ Error:", error.response ? error.response.data : error.message);
    response.status(500).send({
      success: false,
      message: "Failed to initiate STK Push.",
      error: error.response ? error.response.data : error.message,
    });
  }
});
