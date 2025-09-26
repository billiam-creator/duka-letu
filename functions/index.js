// This is the correct, full code for a v2 function with secrets.
// Make sure your file matches this exactly.

const functions = require('firebase-functions');
const axios = require('axios');

// V2 functions use this 'onRequest' import
const { onRequest } = require('firebase-functions/v2/https');

// Define your function and list the secrets it needs access to.
exports.initiateMpesaStkPush = onRequest(
  {
    secrets: ["MPESA_CONSUMER_KEY", "MPESA_CONSUMER_SECRET", "MPESA_BUSINESS_SHORTCODE", "MPESA_PASSKEY"],
  },
  async (request, response) => {
    // Check if it's a POST request and if the required data is present
    if (request.method !== 'POST' || !request.body.phone || !request.body.amount) {
      return response.status(400).send('Bad Request. Missing required data.');
    }

    // Access secrets via process.env
    const consumerKey = process.env.MPESA_CONSUMER_KEY;
    const consumerSecret = process.env.MPESA_CONSUMER_SECRET;
    const businessShortCode = process.env.MPESA_BUSINESS_SHORTCODE;
    const passkey = process.env.MPESA_PASSKEY;
    
    // Generate a Timestamp and Password for authentication
    const timestamp = new Date().toISOString().replace(/[^0-9]/g, '').slice(0, -3);
    const password = Buffer.from(businessShortCode + passkey + timestamp).toString('base64');
    
    // M-Pesa STK Push API endpoint for the sandbox environment
    const stkPushUrl = 'https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest';

    // Get the OAuth token (access token)
    const tokenUrl = 'https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials';
    const authHeader = 'Basic ' + Buffer.from(consumerKey + ':' + consumerSecret).toString('base64');

    try {
      // Step 1: Get Access Token
      const tokenResponse = await axios.get(tokenUrl, {
        headers: {
          Authorization: authHeader,
        },
      });
      const accessToken = tokenResponse.data.access_token;

      // Step 2: Initiate STK Push
      const requestPayload = {
        BusinessShortCode: businessShortCode,
        Password: password,
        Timestamp: timestamp,
        TransactionType: 'CustomerPayBillOnline',
        Amount: request.body.amount,
        PartyA: request.body.phone,
        PartyB: businessShortCode,
        PhoneNumber: request.body.phone,
        CallBackURL: 'https://f0f609912206.ngrok-free.app/duka-letu-01-61a86/us-central1/initiateMpesaStkPush',
        AccountReference: 'DukaLetu E-Commerce',
        TransactionDesc: 'Payment for Duka Letu',
      };

      const stkPushResponse = await axios.post(stkPushUrl, requestPayload, {
        headers: {
          Authorization: `Bearer ${accessToken}`,
        },
      });

      // Send a success response back to the Flutter app
      response.status(200).send({
        success: true,
        message: 'STK Push initiated successfully!',
        data: stkPushResponse.data,
      });

    } catch (error) {
      console.error('Error initiating STK Push:', error.response ? error.response.data : error.message);
      response.status(500).send({
        success: false,
        message: 'Failed to initiate STK Push.',
        error: error.response ? error.response.data : error.message,
      });
    }
  }
);