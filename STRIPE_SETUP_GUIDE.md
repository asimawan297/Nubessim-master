# Stripe Payment Setup Guide

## Current Issue
Your app is currently using an expired Stripe API key directly in the client-side code, which is both insecure and causing the "Expired API Key" error.

## Solution: Secure Backend Implementation

### 1. Backend Server Requirements

You need to create a backend server (Node.js, Python, PHP, etc.) that will handle Stripe operations securely. Here's a Node.js example:

#### Install Dependencies
```bash
npm init -y
npm install express stripe cors dotenv
```

#### Server Code (server.js)
```javascript
const express = require('express');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// Create Payment Intent
app.post('/api/create-payment-intent', async (req, res) => {
  try {
    const { amount, currency, customerId } = req.body;
    
    const paymentIntent = await stripe.paymentIntents.create({
      amount: parseInt(amount),
      currency: currency || 'usd',
      customer: customerId,
      automatic_payment_methods: {
        enabled: true,
      },
    });

    res.json({
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Create Customer
app.post('/api/create-customer', async (req, res) => {
  try {
    const { email, name } = req.body;
    
    const customer = await stripe.customers.create({
      email: email,
      name: name,
    });

    res.json({ customerId: customer.id });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

#### Environment Variables (.env)
```
STRIPE_SECRET_KEY=sk_test_your_new_secret_key_here
STRIPE_PUBLISHABLE_KEY=pk_test_your_new_publishable_key_here
```

### 2. Update Your Flutter App

#### A. Get New Stripe Keys
1. Go to [Stripe Dashboard](https://dashboard.stripe.com/)
2. Navigate to Developers > API Keys
3. Generate new test keys
4. Update your backend server with the new secret key

#### B. Update Flutter Configuration
In your `main.dart`, initialize Stripe with the publishable key:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Stripe with your publishable key
  Stripe.publishableKey = 'pk_test_your_new_publishable_key_here';
  
  runApp(MyApp());
}
```

#### C. Update API Endpoints
Make sure your `DioClient` points to your backend server:

```dart
// In lib/core/network/dio_client.dart
class DioClient {
  DioClient({required Environment environment}) {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://your-backend-server.com', // Update this
      // ... other options
    ));
  }
}
```

### 3. Payment Flow

The new payment flow works as follows:

1. **User clicks "Buy Now"** → Navigates to `PaymentInfoScreen`
2. **User fills billing information** → Validates and proceeds to `SecureCheckoutScreen`
3. **User clicks "Complete Order"** → 
   - Creates payment intent via backend
   - Initializes Stripe PaymentSheet
   - User enters card details securely
   - Payment is processed
   - Order is placed only after successful payment

### 4. Security Benefits

- ✅ Stripe secret key never exposed in client code
- ✅ All sensitive operations handled server-side
- ✅ Proper error handling and validation
- ✅ PCI compliance maintained
- ✅ No expired API key issues

### 5. Testing

Use Stripe's test card numbers:
- **Success**: `4242 4242 4242 4242`
- **Decline**: `4000 0000 0000 0002`
- **Expired**: `4000 0000 0000 0069`

### 6. Production Deployment

1. Switch to live Stripe keys
2. Deploy backend server to production
3. Update Flutter app with production publishable key
4. Test thoroughly with small amounts

## Files Modified

1. `lib/modules/shop/pages/payment_info_screen.dart` - New billing info collection screen
2. `lib/modules/shop/widgets/eSIM_package_tile.dart` - Updated navigation flow
3. `lib/modules/shop/repository/stripe_payment_repository.dart` - Updated to use backend
4. `lib/core/di/service_locator.dart` - Updated dependency injection
5. `lib/core/network/stripe_dio_client.dart` - Marked for removal (insecure)

## Next Steps

1. Set up your backend server
2. Get new Stripe API keys
3. Update the configuration
4. Test the payment flow
5. Deploy to production

This approach ensures your Stripe integration is secure, maintainable, and follows best practices.
