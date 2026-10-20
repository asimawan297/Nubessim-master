# Forgot Password Flow Implementation

This document describes the implementation of the forgot password flow for the NubESim app.

## Overview

The forgot password flow consists of 4 screens that guide users through the process of resetting their password:

1. **Forgot Password Screen** - User enters their email address
2. **Email Verification Screen** - User enters a 4-digit verification code sent to their email
3. **Reset Password Screen** - User enters and confirms their new password
4. **Success Screen** - Confirmation that password was successfully reset

## Screen Details

### 1. Forgot Password Screen (`forgot_password_screen.dart`)
- **Purpose**: Collect user's email address to initiate password reset
- **Features**:
  - Email input field with validation
  - Continue button with gradient design
  - Back button for navigation
  - Loading state during API call
- **Navigation**: Proceeds to Email Verification Screen

### 2. Email Verification Screen (`email_verification_screen.dart`)
- **Purpose**: Verify user's email with a 4-digit code
- **Features**:
  - 4 separate input fields for verification code
  - Auto-focus navigation between fields
  - Resend code functionality
  - Continue button with gradient design
  - Back button for navigation
- **Navigation**: Proceeds to Reset Password Screen

### 3. Reset Password Screen (`reset_password_screen.dart`)
- **Purpose**: Allow user to set a new password
- **Features**:
  - New password input field with visibility toggle
  - Confirm password input field with validation
  - Password strength validation
  - Continue button with gradient design
  - Back button for navigation
- **Navigation**: Proceeds to Success Screen

### 4. Success Screen (`password_reset_success_screen.dart`)
- **Purpose**: Confirm successful password reset
- **Features**:
  - Success checkmark icon
  - Success message
  - Sign In button to return to login
- **Navigation**: Returns to Auth Page with success message

## Integration

### Accessing the Flow
The forgot password flow can be accessed from the login tab via the "Forgot your password?" link.

### API Integration Points
Each screen has TODO comments indicating where API calls should be implemented:

1. **Forgot Password Screen**: Send email to user with verification code
2. **Email Verification Screen**: Verify the 4-digit code
3. **Email Verification Screen**: Resend verification code
4. **Reset Password Screen**: Update user's password

### Navigation Flow
```
Login Tab → Forgot Password Screen → Email Verification Screen → Reset Password Screen → Success Screen → Auth Page
```

## Design Features

### Consistent Design Language
- All screens use the same color scheme (purple to pink gradient)
- Consistent typography (Inter font family)
- Uniform button styling with gradient backgrounds
- Consistent spacing and padding

### User Experience
- Loading states for all async operations
- Form validation with helpful error messages
- Smooth navigation with back buttons
- Auto-focus in verification code fields
- Password visibility toggles

### Accessibility
- Proper contrast ratios
- Clear error messages
- Logical tab order
- Appropriate touch targets

## Customization

### Colors
The screens use colors from `AppColors`:
- Primary gradient: `AppColors.purple` to `AppColors.primaryColor`
- Text colors: `AppColors.black`, `AppColors.greyColor`
- Background: `Colors.white`

### Icons
- Forgot Password: Lock open icon
- Email Verification: Phone icon
- Reset Password: Lock with key icon
- Success: Checkmark icon

### Validation
- Email validation using `Validators.email`
- Password validation using `Validators.password`
- Custom confirm password validation

## Testing

To test the flow:
1. Navigate to the login screen
2. Tap "Forgot your password?"
3. Enter an email address
4. Enter a 4-digit verification code (any 4 digits for testing)
5. Enter and confirm a new password
6. Verify the success screen appears
7. Tap "Sign In" to return to login

## Future Enhancements

- Add rate limiting for verification code requests
- Implement proper email templates
- Add biometric authentication options
- Add password strength indicator
- Implement account recovery options 