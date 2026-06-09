// Snake's Hustle — secure Twilio SMS backend (Firebase Cloud Functions v2)
// The Twilio Auth Token NEVER lives in the app/repo — it's stored as a Firebase secret
// and only read here, server-side. The app calls this function; it sends the text.

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const twilio = require("twilio");

// These are set with: firebase functions:secrets:set NAME  (you type the value, never in code)
const TWILIO_ACCOUNT_SID = defineSecret("TWILIO_ACCOUNT_SID");
const TWILIO_AUTH_TOKEN  = defineSecret("TWILIO_AUTH_TOKEN");
const TWILIO_FROM        = defineSecret("TWILIO_FROM"); // your Twilio number, e.g. +1819...

// Normalize a North-American number to E.164 (+1XXXXXXXXXX)
function toE164(raw) {
  let d = String(raw || "").replace(/[^0-9]/g, "");
  if (d.length === 11 && d[0] === "1") d = d.slice(1);
  if (d.length === 10) return "+1" + d;
  return null;
}

exports.sendSms = onCall(
  { secrets: [TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_FROM], region: "us-central1" },
  async (request) => {
    // Must be signed in (your Google login) to use this
    if (!request.auth) throw new HttpsError("unauthenticated", "Please sign in first.");

    const to = toE164(request.data && request.data.to);
    const body = String((request.data && request.data.body) || "").slice(0, 1500).trim();
    if (!to)   throw new HttpsError("invalid-argument", "Invalid phone number.");
    if (!body) throw new HttpsError("invalid-argument", "Message body is empty.");

    const client = twilio(TWILIO_ACCOUNT_SID.value(), TWILIO_AUTH_TOKEN.value());
    try {
      const msg = await client.messages.create({ to, from: TWILIO_FROM.value(), body });
      return { ok: true, sid: msg.sid, to };
    } catch (e) {
      // Surface Twilio's reason (e.g. "number not verified" on trial) to the app
      throw new HttpsError("failed-precondition", e.message || "Twilio send failed");
    }
  }
);
