const express = require('express');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ status: 'OK', message: 'Stripe backend server is running' });
});

// Create Payment Intent
app.post('/api/create-payment-intent', async (req, res) => {
    try {
        const { amount, currency, customerId, description } = req.body;

        console.log('Creating payment intent:', { amount, currency, customerId, description });

        const paymentIntent = await stripe.paymentIntents.create({
            amount: parseInt(amount), // Amount in cents
            currency: currency || 'usd',
            customer: customerId || undefined,
            description: description || 'eSIM Package Purchase',
            automatic_payment_methods: {
                enabled: true,
            },
            metadata: {
                source: 'nubesim_app',
            },
        });

        console.log('Payment intent created:', paymentIntent.id);

        res.json({
            clientSecret: paymentIntent.client_secret,
            paymentIntentId: paymentIntent.id,
            status: paymentIntent.status,
        });
    } catch (error) {
        console.error('Error creating payment intent:', error);
        res.status(400).json({
            error: error.message,
            code: error.code
        });
    }
});

// Create Customer
app.post('/api/create-customer', async (req, res) => {
    try {
        const { email, name, phone, address } = req.body;

        console.log('Creating customer:', { email, name });

        const customerData = {
            email: email,
            name: name,
        };

        if (phone) customerData.phone = phone;
        if (address) customerData.address = address;

        const customer = await stripe.customers.create(customerData);

        console.log('Customer created:', customer.id);

        res.json({
            customerId: customer.id,
            email: customer.email,
            name: customer.name,
        });
    } catch (error) {
        console.error('Error creating customer:', error);
        res.status(400).json({
            error: error.message,
            code: error.code
        });
    }
});

// Get Payment Intent Status
app.get('/api/payment-intent/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const paymentIntent = await stripe.paymentIntents.retrieve(id);

        res.json({
            id: paymentIntent.id,
            status: paymentIntent.status,
            amount: paymentIntent.amount,
            currency: paymentIntent.currency,
            customer: paymentIntent.customer,
        });
    } catch (error) {
        console.error('Error retrieving payment intent:', error);
        res.status(400).json({
            error: error.message,
            code: error.code
        });
    }
});

// Webhook endpoint for payment events (optional)
app.post('/webhook', express.raw({ type: 'application/json' }), async (req, res) => {
    const sig = req.headers['stripe-signature'];
    const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;

    let event;

    try {
        event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
    } catch (err) {
        console.error('Webhook signature verification failed:', err.message);
        return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    // Handle the event
    switch (event.type) {
        case 'payment_intent.succeeded':
            const paymentIntent = event.data.object;
            console.log('Payment succeeded:', paymentIntent.id);
            // Handle successful payment (e.g., send confirmation email, update database)
            break;
        case 'payment_intent.payment_failed':
            const failedPayment = event.data.object;
            console.log('Payment failed:', failedPayment.id);
            // Handle failed payment
            break;
        default:
            console.log(`Unhandled event type ${event.type}`);
    }

    res.json({ received: true });
});

// Error handling middleware
app.use((error, req, res, next) => {
    console.error('Server error:', error);
    res.status(500).json({
        error: 'Internal server error',
        message: error.message
    });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🚀 Stripe backend server running on port ${PORT}`);
    console.log(`📊 Health check: http://localhost:${PORT}/health`);
    console.log(`💳 Payment endpoint: http://localhost:${PORT}/api/create-payment-intent`);
});

module.exports = app;
