// Snake's Hustle — secure Twilio SMS backend (Firebase Cloud Functions v2)
// The Twilio Auth Token NEVER lives in the app/repo — it's stored as a Firebase secret
// and only read here, server-side. The app calls this function; it sends the text.

const { onCall, onRequest, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const twilio = require("twilio");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

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

    console.log("sendSms called with data:", JSON.stringify(request.data || {}));
    const to = toE164(request.data && request.data.to);
    console.log("normalized to:", to);
    const body = String((request.data && request.data.body) || "").slice(0, 1500).trim();
    if (!to)   throw new HttpsError("invalid-argument", "Invalid phone number.");
    if (!body) throw new HttpsError("invalid-argument", "Message body is empty.");

    const client = twilio(TWILIO_ACCOUNT_SID.value(), TWILIO_AUTH_TOKEN.value());
    try {
      const msg = await client.messages.create({ to, from: TWILIO_FROM.value(), body });
      console.log("Twilio sent OK:", msg.sid, "to", to);
      return { ok: true, sid: msg.sid, to };
    } catch (e) {
      // Log Twilio's full reason so we can see it, and surface it to the app
      console.error("TWILIO_ERROR code=", e && e.code, "status=", e && e.status, "msg=", e && e.message, "moreInfo=", e && e.moreInfo, "to=", to, "from=", TWILIO_FROM.value());
      throw new HttpsError("failed-precondition", `[${e && e.code}] ${e && e.message}`);
    }
  }
);

// ── Lead Web intake ─────────────────────────────────────────────────────────
// Public webhook any dealership website (or, eventually, an ads platform) can POST
// to. No Firebase Auth here — the caller is an external website, not a signed-in
// user — so this endpoint validates + writes on the account's behalf using the
// Admin SDK. Which account it lands in is decided by `uid` in the payload (each
// Snake's Hustle account gets its own capture link/embed from Settings).
exports.receiveWebLead = onRequest({ region: "us-central1", cors: true }, async (req, res) => {
  if (req.method !== "POST") { res.status(405).send("Use POST"); return; }

  const body = req.body || {};
  const uid = String(body.uid || "").trim();
  const org = String(body.org || "").trim(); // organization (team) inbox — takes priority over uid
  const name = String(body.name || "").trim().slice(0, 120);
  const phoneDigits = String(body.phone || "").replace(/[^0-9]/g, "");
  const email = String(body.email || "").trim().slice(0, 200);
  const message = String(body.message || "").trim().slice(0, 1000);
  const source = String(body.source || "website").trim().slice(0, 40);
  const honeypot = String(body.company || ""); // hidden field — real humans leave it blank

  if (honeypot) { res.json({ ok: true }); return; } // silently drop likely-bot submissions
  if (!uid && !org) { res.status(400).json({ ok: false, error: "Missing uid — this link isn't configured correctly." }); return; }
  if (!name && !phoneDigits && !email) { res.status(400).json({ ok: false, error: "Enter at least a name, phone, or email." }); return; }

  try {
    const target = org
      ? db.collection("orgs").doc(org).collection("webLeads")
      : db.collection("users").doc(uid).collection("webLeads");
    await target.add({
      name, phone: phoneDigits, email, message, source,
      status: "new",
      receivedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    res.json({ ok: true });
  } catch (e) {
    console.error("receiveWebLead error:", e && e.message);
    res.status(500).json({ ok: false, error: "Something went wrong saving your info. Please call the dealership directly." });
  }
});
