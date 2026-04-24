const express = require("express");
const axios = require("axios");
const bodyParser = require("body-parser");
const cors = require("cors");

const app = express();
app.use(bodyParser.json());
app.use(cors());

const consumerKey = "uHXFyeqAvsOuqZGzF91p55k53D5OIqiiSGPqqHXwyutkF4sa";
const consumerSecret = "AYA4aV7DcAxW1K2kflQVJCKgksxQYgzDkv7J4XH2rytv79KG7tdmJhAACWXcAhGp";
const businessShortCode = "174379";
const passkey = "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919";

// ✅ Normalize any Kenyan phone number → 2547XXXXXXXX or 2541XXXXXXXX
function normalizeKenyanPhone(raw) {
  let phone = raw.toString().replace(/[\s\-().]/g, "");
  if (phone.startsWith("+")) phone = phone.substring(1);

  // 07XX or 01XX → 254XX
  if (/^0[17]\d{8}$/.test(phone)) {
    phone = "254" + phone.substring(1);
  }

  if (!/^254[17]\d{8}$/.test(phone)) {
    throw new Error(
      "Invalid phone number: " + raw +
      ". Use formats like 0712345678, 01XXXXXXXX, +254712345678, or 254112345678"
    );
  }
  return phone;
}

function getTimestamp() {
  const pad = (n) => (n < 10 ? "0" + n : n);
  const now = new Date();
  return (
    now.getFullYear().toString() +
    pad(now.getMonth() + 1) +
    pad(now.getDate()) +
    pad(now.getHours()) +
    pad(now.getMinutes()) +
    pad(now.getSeconds())
  );
}

app.get("/", (req, res) => {
  res.json({ status: "Duka Letu M-Pesa backend running 🚀", acceptedPrefixes: ["2547", "2541", "07", "01", "+2547", "+2541"] });
});

app.post("/stkpush", async (req, res) => {
  const { phone, amount } = req.body;

  if (!phone || !amount) {
    return res.status(400).json({ error: "Missing phone or amount" });
  }

  let normalizedPhone;
  try {
    normalizedPhone = normalizeKenyanPhone(phone);
  } catch (e) {
    return res.status(400).json({ success: false, error: e.message });
  }

  try {
    const tokenResponse = await axios.get(
      "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials",
      {
        headers: {
          Authorization: "Basic " + Buffer.from(`${consumerKey}:${consumerSecret}`).toString("base64"),
        },
      }
    );

    const accessToken = tokenResponse.data.access_token;
    const timestamp = getTimestamp();
    const password = Buffer.from(businessShortCode + passkey + timestamp).toString("base64");

    const callbackUrl = process.env.CALLBACK_URL || "https://your-ngrok-url.ngrok-free.app/callback";

    const stkPushResponse = await axios.post(
      "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest",
      {
        BusinessShortCode: businessShortCode,
        Password: password,
        Timestamp: timestamp,
        TransactionType: "CustomerPayBillOnline",
        Amount: Math.ceil(Number(amount)),
        PartyA: normalizedPhone,
        PartyB: businessShortCode,
        PhoneNumber: normalizedPhone,
        CallBackURL: callbackUrl,
        AccountReference: "DukaLetu",
        TransactionDesc: "Payment for Duka Letu Order",
      },
      { headers: { Authorization: `Bearer ${accessToken}` } }
    );

    res.json({
      success: true,
      message: "STK Push initiated! Check your phone.",
      normalizedPhone,
      data: stkPushResponse.data,
    });
  } catch (error) {
    console.error("❌ STK Push Error:", error.response ? error.response.data : error.message);
    res.status(500).json({
      success: false,
      message: "STK Push failed",
      error: error.response ? error.response.data : error.message,
    });
  }
});

app.post("/callback", (req, res) => {
  console.log("📩 M-Pesa Callback:", JSON.stringify(req.body, null, 2));
  res.json({ ResultCode: 0, ResultDesc: "Accepted" });
});

const PORT = process.env.PORT || 5001;
app.listen(PORT, () => console.log(`🚀 Duka Letu M-Pesa server running on port ${PORT}`));