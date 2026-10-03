class AppConstants {
  // App info
  static const String appName = '𝐇𝐚𝐦𝐨';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.mohammed.store';
  static const String adminUid = 'QHMQtobX65V64nIyxNUkGSybvEB3';
  static const List<String> cashNumbers = ['01153787930', '01070339762'];

  // Firebase collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String reviewsCollection = 'reviews';
  static const String chatsCollection = 'chats';
  static const String messagesSubcollection = 'messages';
  static const String messagesCollection = 'messages';
  static const String verificationsCollection = 'verifications';
  static const String notificationsCollection = 'notifications';

  // Storage paths
  static const String usersStoragePath = 'users';
  static const String productsStoragePath = 'products';
  static const String chatsStoragePath = 'chats';
  static const String verificationsStoragePath = 'verifications';

  // Chapa
  static const String chapaPublicKey =
      'CHAPUBK_TEST-QmCIBhWYIsdp2tgG0sPr67h5fozBbSz3';
  static const String chapaBaseUrl = 'https://api.chapa.co/v1';
  static const String chapaCheckoutBase =
      'https://api.chapa.co/v1/transaction/initialize?';
  static const String chapaCallbackSuccess =
      'mohammedstore://payment-callback/success';
  static const String chapaCallbackCancel =
      'mohammedstore://payment-callback/cancel';
  static const String chapaReturnUrl =
      'mohammedstore://payment-callback/return';

  // Timeouts
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration requestTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxProductImages = 6;

  // Shipping
  static const double defaultShippingFee = 50.0;
  static const double freeShippingThreshold = 1000.0;

  static double getShippingFee(String city) {
    const fees = {
      'Addis Ababa': 50.0,
      'Adama': 80.0,
      'Hawassa': 120.0,
      'Dire Dawa': 150.0,
      'Bahir Dar': 180.0,
      'Gondar': 200.0,
      'Mekelle': 220.0,
      'Jimma': 130.0,
      'Dessie': 170.0,
    };
    return fees[city] ?? 100.0;
  }

  // Product
  static const double lowStockThreshold = 5.0;
  static const int maxReviewImages = 3;

  // Ethiopian cities
  static const List<String> ethiopianCities = [
    'Addis Ababa',
    'Adama',
    'Hawassa',
    'Dire Dawa',
    'Bahir Dar',
    'Gondar',
    'Mekelle',
    'Jimma',
    'Dessie',
    'Harar',
    'Dilla',
    'Shashemene',
    'Arba Minch',
  ];

  // Product categories
  static const List<String> productCategories = [
    'الكل',
    'عروض اتصالات',
    'عروض فودافون',
    'دفع الفواتير',
    'عروض أخرى',
  ];

  static String categoryForQuery(String category) {
    switch (category) {
      case 'عروض اتصالات':
        return 'Etisalat';
      case 'عروض فودافون':
        return 'Vodafone';
      case 'دفع الفواتير':
        return 'Bills';
      case 'عروض أخرى':
        return 'Other';
      default:
        return category;
    }
  }

  static String categoryLabel(String category) {
    switch (category.toLowerCase()) {
      case 'etisalat':
        return 'عروض اتصالات';
      case 'vodafone':
        return 'عروض فودافون';
      case 'bills':
      case 'bill payment':
        return 'دفع الفواتير';
      case 'other':
        return 'عروض أخرى';
      default:
        return category == 'All' ? 'الكل' : category;
    }
  }
}
