-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider
# Keep Stripe classes
-keep class com.stripe.** { *; }

# --- Razorpay + missing annotation fixes ---
# Some SDKs reference proguard annotations at runtime (only used for shrinking hints).
# Suppress R8 missing-class errors for annotation package and keep Razorpay classes.
-dontwarn proguard.annotation.**
-keep class proguard.annotation.** { *; }

# Keep Razorpay SDK to avoid being stripped by R8
-keep class com.razorpay.** { *; }
-keep class com.razorpay.checkout.** { *; }

# (Optional) Lifecycle used by some payment SDK components
-keep class androidx.lifecycle.** { *; }

# --- Google Pay (R8 suggestion from missing_rules.txt) ---
# Suppress warnings for Google Pay in-app client API classes referenced indirectly by Razorpay merged GPay code.
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.PaymentsClient
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.Wallet
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.WalletUtils
