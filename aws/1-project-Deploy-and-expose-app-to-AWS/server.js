const express = require("express");
const app = express();
const { resolve } = require("path");
const port = process.env.PORT || 3000;

// Load environment variables
require("dotenv").config();

// Stripe key from env
const api_key = process.env.SECRET_KEY;

if (!api_key) {
  console.error("❌ SECRET_KEY is missing in environment variables");
  process.exit(1);
}

const stripe = require("stripe")(api_key);

// Static folder
app.use(express.static(resolve(__dirname, process.env.STATIC_DIR)));

app.use(express.json());
app.use(express.urlencoded({ extended: false }));

// Routes
app.get("/", (req, res) => {
  const path = resolve(__dirname, process.env.STATIC_DIR + "/index.html");
  res.sendFile(path);
});

app.get("/success", (req, res) => {
  const path = resolve(__dirname, process.env.STATIC_DIR + "/success.html");
  res.sendFile(path);
});

app.get("/cancel", (req, res) => {
  const path = resolve(__dirname, process.env.STATIC_DIR + "/cancel.html");
  res.sendFile(path);
});

// Workshop routes
app.get("/workshop1", (req, res) => {
  const path = resolve(__dirname, process.env.STATIC_DIR + "/workshops/workshop1.html");
  res.sendFile(path);
});

app.get("/workshop2", (req, res) => {
  const path = resolve(__dirname, process.env.STATIC_DIR + "/workshops/workshop2.html");
  res.sendFile(path);
});

app.get("/workshop3", (req, res) => {
  const path = resolve(__dirname, process.env.STATIC_DIR + "/workshops/workshop3.html");
  res.sendFile(path);
});

// Stripe checkout session
const domainURL = process.env.DOMAIN;

app.post("/create-checkout-session/:pid", async (req, res) => {
  try {
    const priceId = req.params.pid;

    const session = await stripe.checkout.sessions.create({
      mode: "payment",
      success_url: `${domainURL}/success?id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${domainURL}/cancel`,
      payment_method_types: ["card"],
      line_items: [
        {
          price: priceId,
          quantity: 1,
        },
      ],
      allow_promotion_codes: true,
    });

    res.json({ id: session.id });

  } catch (error) {
    console.error("Stripe Error:", error);
    res.status(500).json({ error: "Payment session failed" });
  }
});

// Start server
app.listen(port, () => {
  console.log(`Server running on port: ${port}`);
  console.log(`App URL: ${domainURL}`);
});