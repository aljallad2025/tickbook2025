class AppUrls {
  AppUrls._();

  static const String _apiBase = 'https://tick-book.com';
  static const String pgwBaseUrl = String.fromEnvironment(
    'PGW_BASE_URL',
    defaultValue: '$_apiBase/pgw',
  );
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '$_apiBase/api',
  );

  // Endpoints
  static const String home = '$_baseUrl/home';  // ✅ Clear and explicit
  static const String events = '$_baseUrl/events';
  static String eventDetails(int id) =>
      '$_baseUrl/events/details/?event_id=$id';
  static String seatDetails({
    required int eventId,
    required int ticketId,
    required int slotUniqueId,
  }) =>
      '$_baseUrl/events/slot/seat-details?event_id=$eventId&ticket_id=$ticketId&slot_unique_id=$slotUniqueId';
  static const String login = '$_baseUrl/customer/login/submit';
  static const String signup = '$_baseUrl/customer/signup/submit';
  static const String organizers = '$_baseUrl/organizers';
  static String organizerDetails(int id, {required bool isAdmin}) =>
      '$_baseUrl/organizers/details/$id?${isAdmin ? 'admin=true' : 'organizer=true'}';
  static const String dashboard = '$_baseUrl/customers/dashboard';
  static const String bookings = '$_baseUrl/customers/bookings';
  static String bookingDetails(int id) =>
      '$_baseUrl/customers/booking/details/?booking_id=$id';
  static const String eventBooking = '$_baseUrl/event-booking';
  static const String eventCheckoutVerify = '$_baseUrl/event/checkout-verify';
  // Verify payable amount with the backend before hitting PGW
  static const String eventVerifyPayment = '$_baseUrl/event/verify-payment';
  // Finalize/submit payment + booking (alias to eventBooking for this app)
  static const String paymentProcessUrl = eventBooking;
  // Apply coupon to event booking (assumed endpoint naming)
  static const String eventCouponApply = '$_baseUrl/event/apply-coupon';

  // Payment gateway helpers (non-API helpers hosted on same host)
  static const String stripeCreatePaymentIntent =
      '$_apiBase/pgw/create-payment-intent.php';
  static const String flutterwaveCreatePayment =
      '$_apiBase/pgw/flutterwave-create-payment.php';
  static const String flutterwaveVerifyPayment =
      '$_apiBase/pgw/flutterwave-verify-payment.php';
  static const String wishlists = '$_baseUrl/customers/wishlists';
  static const String wishlistsStore = '$_baseUrl/customers/wishlists/store';
  static const String wishlistsDelete = '$_baseUrl/customers/wishlists/delete';
  static const String supportTickets = '$_baseUrl/customers/support-tickets';
  static const String supportTicketStore =
      '$_baseUrl/customers/support-ticket/store';
  static String supportTicketDetails(int id) =>
      '$_baseUrl/customers/support-ticket/details/?ticket_id=$id';
  static const String supportTicketReply =
      '$_baseUrl/customers/support-ticket/reply';
  static const String updateProfile = '$_baseUrl/customers/update/profile';
  static const String updatePassword = '$_baseUrl/customers/update/password';
  static const String forgetPassword = '$_baseUrl/customer/forget-password';
  static const String resetPasswordUpdate =
      '$_baseUrl/customer/reset-password-update';

  static String getLangUrl(String languageCode) =>
      '$_baseUrl/get-lang/$languageCode';

  // Basic app info including languages list
  static const String basic = '$_baseUrl/get-basic';

  static String get sendEmailToOrganizerUrl =>
      '$_baseUrl/organizers/contact-mail';

  // Web push subscription storage endpoint
  static const String pushNotificationStoreEndpoint =
      '$_baseUrl/push-notification-store-endpoint';

  // Save FCM token to server
  static const String saveFcmToken = '$_baseUrl/save-fcm-token';

  // Fetch existing notifications for a user (expects query params user_id, fcm_token)
  static const String getNotifications = '$_baseUrl/get-notifications';

  // Unified verification URL (POST JSON). Kept as a helper for callers.
  static String verifyPaymentUrl({
    required String amount,
    required String gateway,
  }) => eventVerifyPayment;
}
