// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:nubesim/constants/app_colors.dart';
// import 'package:nubesim/modules/shop/model/all_data_packages_model.dart';
// import 'package:nubesim/modules/shop/pages/secure_checkout_screen.dart';
// import 'package:nubesim/ui/input_fields/input_field.dart';
// import 'package:nubesim/utils/extensions/extended_context.dart';
// import 'package:sizer/sizer.dart';

// class PaymentInfoScreen extends StatefulWidget {
//   final PackageList? package;
//   final String name;

//   const PaymentInfoScreen({
//     super.key,
//     required this.package,
//     required this.name,
//   });

//   @override
//   State<PaymentInfoScreen> createState() => _PaymentInfoScreenState();
// }

// class _PaymentInfoScreenState extends State<PaymentInfoScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _cityController = TextEditingController();
//   final _postalCodeController = TextEditingController();
//   final _countryController = TextEditingController();

//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _nameController.dispose();
//     _phoneController.dispose();
//     _addressController.dispose();
//     _cityController.dispose();
//     _postalCodeController.dispose();
//     _countryController.dispose();
//     super.dispose();
//   }

//   void _proceedToPayment() {
//     if (_formKey.currentState!.validate()) {
//       // Navigate to secure checkout with billing information
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => SecureCheckoutScreen(
//             name: widget.name,
//             package: widget.package,
//           ),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Payment Information",
//           style: context.textTheme.bodyMedium?.copyWith(
//             fontWeight: FontWeight.w900,
//             color: Colors.black,
//             fontSize: 19.0,
//             fontFamily: "Inter",
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Package Summary Card
//               Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.all(16.0),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Color(0xffCD57B2),
//                       Color(0xff911b76),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Container(
//                           width: 50,
//                           height: 50,
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(8.0),
//                           ),
//                           child: Icon(
//                             Icons.sim_card,
//                             color: Colors.white,
//                             size: 24,
//                           ),
//                         ),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 widget.package?.name ?? "eSIM Package",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Text(
//                                 "${widget.package?.volume ?? 0} GB • ${widget.package?.duration ?? 0} Days",
//                                 style: TextStyle(
//                                   color: Colors.white.withOpacity(0.8),
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Text(
//                           "\$${(widget.package?.price ?? 0).toStringAsFixed(2)}",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               SizedBox(height: 24),

//               Text(
//                 "Billing Information",
//                 style: context.textTheme.headlineSmall?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),

//               SizedBox(height: 16),

//               // Email
//               InputField(
//                 controller: _emailController,
//                 label: "Enter your email address",
//                 keyboardType: TextInputType.emailAddress,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your email address';
//                   }
//                   if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
//                     return 'Please enter a valid email address';
//                   }
//                   return null;
//                 },
//               ),

//               SizedBox(height: 16),

//               // Full Name
//               InputField(
//                 controller: _nameController,
//                 label: "Enter your full name",
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your full name';
//                   }
//                   return null;
//                 },
//               ),

//               SizedBox(height: 16),

//               // Phone Number
//               InputField(
//                 controller: _phoneController,
//                 label: "Enter your phone number",
//                 keyboardType: TextInputType.phone,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your phone number';
//                   }
//                   return null;
//                 },
//               ),

//               SizedBox(height: 16),

//               // Address
//               InputField(
//                 controller: _addressController,
//                 label: "Enter your billing address",
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your address';
//                   }
//                   return null;
//                 },
//               ),

//               SizedBox(height: 16),

//               // City and Postal Code Row
//               Row(
//                 children: [
//                   Expanded(
//                     child: InputField(
//                       controller: _cityController,
//                       label: "Enter city",
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your city';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                   SizedBox(width: 16),
//                   Expanded(
//                     child: InputField(
//                       controller: _postalCodeController,
//                       label: "Enter postal code",
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your postal code';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                 ],
//               ),

//               SizedBox(height: 16),

//               // Country
//               InputField(
//                 controller: _countryController,
//                 label: "Enter your country",
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your country';
//                   }
//                   return null;
//                 },
//               ),

//               SizedBox(height: 32),

//               // Proceed to Payment Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _proceedToPayment,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primaryColor,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                   ),
//                   child: _isLoading
//                       ? CircularProgressIndicator(color: Colors.white)
//                       : Text(
//                           "Proceed to Payment",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
