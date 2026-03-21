enum SubscriptionPlanType {
  free,
  basic,
  plus,
  pro;

  String get apiValue {
    switch (this) {
      case SubscriptionPlanType.free:
        return 'FREE';
      case SubscriptionPlanType.basic:
        return 'BASIC';
      case SubscriptionPlanType.plus:
        return 'PLUS';
      case SubscriptionPlanType.pro:
        return 'PRO';
    }
  }

  String get code => apiValue;

  String get title {
    switch (this) {
      case SubscriptionPlanType.free:
        return 'OTOPORT FREE';
      case SubscriptionPlanType.basic:
        return 'OTOPORT BASIC';
      case SubscriptionPlanType.plus:
        return 'OTOPORT PLUS';
      case SubscriptionPlanType.pro:
        return 'OTOPORT PRO';
    }
  }

  String get displayName {
    switch (this) {
      case SubscriptionPlanType.free:
        return 'Ücretsiz';
      case SubscriptionPlanType.basic:
        return 'Basic';
      case SubscriptionPlanType.plus:
        return 'Plus';
      case SubscriptionPlanType.pro:
        return 'Pro';
    }
  }

  int get listingLimit {
    switch (this) {
      case SubscriptionPlanType.free:
        return 10;
      case SubscriptionPlanType.basic:
        return 20;
      case SubscriptionPlanType.plus:
        return 40;
      case SubscriptionPlanType.pro:
        return 80;
    }
  }

  int get featuredLimit {
    switch (this) {
      case SubscriptionPlanType.free:
        return 0;
      case SubscriptionPlanType.basic:
        return 0;
      case SubscriptionPlanType.plus:
        return 1;
      case SubscriptionPlanType.pro:
        return 1;
    }
  }

  int get weight {
    switch (this) {
      case SubscriptionPlanType.free:
        return 0;
      case SubscriptionPlanType.basic:
        return 1;
      case SubscriptionPlanType.plus:
        return 2;
      case SubscriptionPlanType.pro:
        return 3;
    }
  }

  String get oldPriceText {
    switch (this) {
      case SubscriptionPlanType.free:
        return '';
      case SubscriptionPlanType.basic:
        return '2000 TL';
      case SubscriptionPlanType.plus:
        return '5000 TL';
      case SubscriptionPlanType.pro:
        return '10000 TL';
    }
  }

  String get newPriceText {
    switch (this) {
      case SubscriptionPlanType.free:
        return 'Ücretsiz';
      case SubscriptionPlanType.basic:
        return '1000 TL';
      case SubscriptionPlanType.plus:
        return '2000 TL';
      case SubscriptionPlanType.pro:
        return '5000 TL';
    }
  }

  String get metaText {
    switch (this) {
      case SubscriptionPlanType.free:
        return 'Aylık 10 ilan hakkı';
      case SubscriptionPlanType.basic:
        return 'Aylık 20 ilan hakkı';
      case SubscriptionPlanType.plus:
        return 'Aylık 40 ilan + Orta Vitrin';
      case SubscriptionPlanType.pro:
        return 'Aylık 80 ilan + En Üst Vitrin';
    }
  }

  String get description {
    switch (this) {
      case SubscriptionPlanType.free:
        return 'Hızlı başla, mağazanı risksiz şekilde büyütmeye ilk adımı at.';
      case SubscriptionPlanType.basic:
        return 'Daha fazla ürün, daha fazla görünürlük, daha fazla satış fırsatı.';
      case SubscriptionPlanType.plus:
        return 'İlanlarını öne çıkar, rakiplerinin önüne geç, dikkatleri üzerine topla.';
      case SubscriptionPlanType.pro:
        return 'Zirvede yerini al, maksimum görünürlükle satış potansiyelini katla.';
    }
  }

  static SubscriptionPlanType fromString(String? value) {
    final v = (value ?? '').trim().toUpperCase();

    switch (v) {
      case 'FREE':
        return SubscriptionPlanType.free;
      case 'BASIC':
        return SubscriptionPlanType.basic;
      case 'PLUS':
        return SubscriptionPlanType.plus;
      case 'PRO':
        return SubscriptionPlanType.pro;
      default:
        return SubscriptionPlanType.free;
    }
  }
}