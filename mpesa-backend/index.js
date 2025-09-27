const express = require("express");
const axios = require("axios");
const bodyParser = require("body-parser");
const cors = require("cors");

const app = express();
app.use(bodyParser.json());
app.use(cors());


const consumerKey = "uHXFyeqAvsOuqZGzF91p55k53D5OIqiiSGPqqHXwyutkF4sa";
const consumerSecret = "AYA4aV7DcAxW1K2kflQVJCKgksxQYgzDkv7J4XH2rytv79KG7tdmJhAACWXcAhGp";
const businessShortCode = "174379"; // usually 174379 for Paybill in sandbox
const passkey = "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919";

// Generate timestamp
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

// Endpoint to trigger STK Push
app.post("/stkpush", async (req, res) => {
  const { phone, amount } = req.body;

  if (!phone || !amount) {
    return res.status(400).json({ error: "Missing phone or amount" });
  }

  try {
    // 1️⃣ Get Access Token
    const tokenResponse = await axios.get(
      "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials",
      {
        headers: {
          Authorization:
            "Basic " +
            Buffer.from(`${consumerKey}:${consumerSecret}`).toString("base64"),
        },
      }
    );

    const accessToken = tokenResponse.data.access_token;

    // 2️⃣ Prepare STK Push request
    const timestamp = getTimestamp();
    const password = Buffer.from(
      businessShortCode + passkey + timestamp
    ).toString("base64");

    const stkPushResponse = await axios.post(
      "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest",
      {
        BusinessShortCode: businessShortCode,
        Password: password,
        Timestamp: timestamp,
        TransactionType: "CustomerPayBillOnline",
        Amount: amount,
        PartyA: phone,
        PartyB: businessShortCode,
        PhoneNumber: phone,
        CallBackURL: "https://79025e3fe1a1.ngrok-free.app/callback",
 // placeholder
        AccountReference: "DukaLetu",
        TransactionDesc: "Payment for Duka Letu",
      },
      {
        headers: { Authorization: `Bearer ${accessToken}` },
      }
    );

    res.json({
      success: true,
      message: "STK Push initiated!",
      data: stkPushResponse.data,
    });
  } catch (error) {
    console.error(
      "❌ Error:",
      error.response ? error.response.data : error.message
    );
    res.status(500).json({
      success: false,
      message: "STK Push failed",
      error: error.response ? error.response.data : error.message,
    });
  }
});

// Start server
const PORT = 5001;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
