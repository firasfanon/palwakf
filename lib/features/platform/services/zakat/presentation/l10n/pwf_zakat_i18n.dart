import 'package:flutter/widgets.dart';

/// Lightweight i18n for Zakat feature.
///
/// Rationale: the platform project may not use flutter_gen (gen-l10n).
/// This keeps the feature compiling without touching platform i18n.
class PwfZakatI18n {
  const PwfZakatI18n._(this._isArabic);

  final bool _isArabic;
  bool get isArabic => _isArabic;

  static PwfZakatI18n of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return PwfZakatI18n._(code == 'ar' || code.startsWith('ar'));
  }

  static const Map<String, String> _ar = <String, String>{
    'zakatAgriInfoBody': '''نصاب الزراعة: 5 أوسق = {nisabKg} كجم تقريباً
نسبة الزكاة: 10% للبعلية، 5% للمروية
ملاحظة: لا زكاة في الزراعة إلا بعد بلوغ النصاب''',
    'zakatAgriInfoTitle': 'معلومات هامة',
    'zakatAgriPriceHint': 'سعر الكيلوجرام',
    'zakatAgriPriceLabel': 'سعر الكيلوجرام ({currency})',
    'zakatAgriQuantityHint': 'كمية المحصول بالكيلوجرام',
    'zakatAgriQuantityLabel': 'كمية المحصول (كجم)',
    'zakatAgriTypeIrrigated': 'زراعة مروية (تسقى بمكائن)',
    'zakatAgriTypeLabel': 'نوع الزراعة',
    'zakatAgriTypeRain': 'زراعة بعلية (تعتمد على المطر)',
    'zakatAmountDueTitle': 'مقدار الزكاة الواجب إخراجه',
    'zakatBtnDonateNow': 'تبرع الآن',
    'zakatBtnNewCalculation': 'حساب جديد',
    'zakatBtnPrint': 'طباعة',
    'zakatCalculateAgriculture': 'احسب زكاة الزراعة',
    'zakatCalculateCash': 'احسب زكاة النقود',
    'zakatCalculateTrade': 'احسب زكاة التجارة',
    'zakatCashAmountHint': 'أدخل المبلغ الإجمالي',
    'zakatCashAmountLabel': 'المبلغ الإجمالي ({currency})',
    'zakatCashDebtsHint': 'أدخل قيمة الديون',
    'zakatCashDebtsLabel': 'الديون المستحقة عليك ({currency})',
    'zakatCashPeriodFullYear': 'سنة كاملة (365 يوم)',
    'zakatCashPeriodHalfYear': 'نصف سنة (180 يوم)',
    'zakatCashPeriodQuarterYear': 'ربع سنة (90 يوم)',
    'zakatCashPeriodLabel': 'فترة الحول',
    'zakatCurrencyIls': 'شيكل',
    'zakatDaysValue': '{days} يوم',
    'zakatDialogOk': 'حسنًا',
    'zakatDonationDialogTitle': 'تأكيد التبرع',
    'zakatDonationDialogBody':
        '''سيتم توجيه زكاتك البالغة {amount} إلى: {option}

سيتم فتح صفحة الدفع الإلكتروني...''',
    'zakatDonationMosquesTitle': 'صيانة المساجد',
    'zakatDonationMosquesDesc': 'ترميم وصيانة المساجد والمقدسات',
    'zakatDonationOrphansTitle': 'رعاية الأيتام',
    'zakatDonationOrphansDesc': 'كفالة ورعاية الأيتام في فلسطين',
    'zakatDonationPoorTitle': 'الفقراء والمساكين',
    'zakatDonationPoorDesc': 'توزيع مباشر على الأسر الفقيرة في فلسطين',
    'zakatDonationStudentsTitle': 'طلاب العلم',
    'zakatDonationStudentsDesc': 'منح دراسية ومساعدة طلاب العلم الشرعي',
    'zakatDonationProceed': 'المتابعة للتبرع',
    'zakatDonationTitle': 'التبرع بالزكاة عبر المنصة',
    'zakatDonationSubtitle':
        'يمكنك إخراج زكاتك عبر منصة وزارة الأوقاف لضمان وصولها لمستحقيها',
    'zakatErrorBelowNisab': 'المبلغ لا يبلغ النصاب ({nisab} {currency})',
    'zakatErrorBelowNisabKg': 'كمية المحصول لا تبلغ النصاب ({nisabKg} كجم)',
    'zakatErrorEnterValidAmount': 'يرجى إدخال مبلغ صحيح',
    'zakatErrorEnterValidValues': 'يرجى إدخال قيم صحيحة',
    'zakatErrorPleaseCalculateFirst': 'يرجى حساب الزكاة أولاً',
    'zakatErrorSelectDonationOption': 'يرجى اختيار خيار التبرع',
    'zakatHeroTitle': 'حاسبة الزكاة الإلكترونية',
    'zakatHeroSubtitle':
        'احسب زكاتك بكل دقة وسهولة لأنواع المال المختلفة وفقاً للشريعة الإسلامية',
    'zakatInfoSectionTitle': 'معلومات هامة عن الزكاة',
    'zakatInfoConditionsTitle': 'شروط وجوب الزكاة',
    'zakatInfoConditionsBody': '''1. الإسلام
2. الحرية
3. ملك النصاب
4. مضي الحول (لسنة كاملة)
5. عدم وجود دين يستغرق النصاب''',
    'zakatInfoNoZakatTitle': 'لا تجب الزكاة في',
    'zakatInfoNoZakatBody': '''• المسكن الذي تسكنه
• الملابس والأثاث الشخصي
• وسائل النقل الشخصية
• الديون التي لا يُرجى سدادها
• ما دون النصاب''',
    'zakatInfoRecipientsTitle': 'مصارف الزكاة',
    'zakatInfoRecipientsBody':
        'الفقراء - المساكين - العاملين عليها - المؤلفة قلوبهم - في الرقاب - الغارمين - في سبيل الله - ابن السبيل (كما في سورة التوبة: 60)',
    'zakatItemAgriNisab': 'النصاب الشرعي',
    'zakatItemAgriPrice': 'سعر الكيلوجرام',
    'zakatItemAgriQuantity': 'كمية المحصول',
    'zakatItemAgriTotalValue': 'القيمة الإجمالية',
    'zakatItemAgriType': 'نوع الزراعة',
    'zakatItemDebts': 'الديون المستحقة',
    'zakatItemNetAmount': 'المبلغ الصافي',
    'zakatItemNisab': 'النصاب الشرعي',
    'zakatItemPeriodDays': 'فترة الحول',
    'zakatItemRate': 'نسبة الزكاة',
    'zakatItemTotalAmount': 'المبلغ الإجمالي',
    'zakatItemTradeCash': 'النقد في الصندوق',
    'zakatItemTradeGoods': 'قيمة البضاعة',
    'zakatItemTradeNetAssets': 'القيمة الصافية',
    'zakatItemTradePayables': 'الديون المستحقة',
    'zakatItemTradeReceivables': 'ديون العملاء',
    'zakatItemTradeTotalAssets': 'إجمالي الأصول',
    'zakatKgValue': '{kg} كجم',
    'zakatPercentValue': '{p}%',
    'zakatNisabTitle': 'هل بلغ المال النصاب؟',
    'zakatNisabBody':
        '''نصاب زكاة النقود: ما يعادل {grams} جراماً من الذهب عيار 24
سعر الجرام اليوم: {price} {currency} (تقريباً)
النصاب بال{currency}: {nisab}''',
    'zakatPrintNotSupported': 'الطباعة غير مدعومة على هذا الجهاز',
    'zakatResultsCashTitle': 'زكاة النقود والعملات',
    'zakatResultsTradeTitle': 'زكاة عروض التجارة',
    'zakatResultsAgricultureTitle': 'زكاة الزراعة والمحاصيل',
    'zakatResultsSubtitle': 'تاريخ الحساب: {date}',
    'zakatTabCash': 'النقود والعملات',
    'zakatTabTrade': 'عروض التجارة',
    'zakatTabAgriculture': 'الزراعة والمحاصيل',
    'zakatTradeCashHint': 'أدخل النقد المتوفر',
    'zakatTradeCashLabel': 'النقد المتوفر ({currency})',
    'zakatTradeGoodsHint': 'أدخل قيمة البضاعة',
    'zakatTradeGoodsLabel': 'قيمة البضاعة ({currency})',
    'zakatTradePayablesHint': 'أدخل ديون الموردين',
    'zakatTradePayablesLabel': 'الديون المستحقة عليك ({currency})',
    'zakatTradeReceivablesHint': 'أدخل ديون العملاء',
    'zakatTradeReceivablesLabel': 'الديون المستحقة لك ({currency})',
  };

  static const Map<String, String> _en = <String, String>{
    'zakatAgriInfoBody': '''Agriculture nisab: ~{nisabKg} kg
Zakat rate: 10% rain-fed, 5% irrigated
Note: No zakat until nisab is reached''',
    'zakatAgriInfoTitle': 'Important info',
    'zakatAgriPriceHint': 'Price per kilogram',
    'zakatAgriPriceLabel': 'Price per kg ({currency})',
    'zakatAgriQuantityHint': 'Quantity in kilograms',
    'zakatAgriQuantityLabel': 'Harvest quantity (kg)',
    'zakatAgriTypeIrrigated': 'Irrigated (machines)',
    'zakatAgriTypeLabel': 'Farming type',
    'zakatAgriTypeRain': 'Rain-fed',
    'zakatAmountDueTitle': 'Zakat amount due',
    'zakatBtnDonateNow': 'Donate now',
    'zakatBtnNewCalculation': 'New calculation',
    'zakatBtnPrint': 'Print',
    'zakatCalculateAgriculture': 'Calculate Agriculture Zakat',
    'zakatCalculateCash': 'Calculate Cash Zakat',
    'zakatCalculateTrade': 'Calculate Trade Zakat',
    'zakatCashAmountHint': 'Enter the total amount',
    'zakatCashAmountLabel': 'Total Amount ({currency})',
    'zakatCashDebtsHint': 'Enter debts value',
    'zakatCashDebtsLabel': 'Debts Owed ({currency})',
    'zakatCashPeriodFullYear': 'Full year (365 days)',
    'zakatCashPeriodHalfYear': 'Half year (180 days)',
    'zakatCashPeriodQuarterYear': 'Quarter year (90 days)',
    'zakatCashPeriodLabel': 'Hawl Period',
    'zakatCurrencyIls': 'ILS',
    'zakatDaysValue': '{days} days',
    'zakatDialogOk': 'OK',
    'zakatDonationDialogTitle': 'Donation confirmation',
    'zakatDonationDialogBody':
        '''Your zakat amount {amount} will be directed to: {option}

The payment page will open...''',
    'zakatDonationMosquesTitle': 'Mosque maintenance',
    'zakatDonationMosquesDesc': 'Repair and maintenance of mosques',
    'zakatDonationOrphansTitle': 'Orphans care',
    'zakatDonationOrphansDesc': 'Sponsorship and care for orphans',
    'zakatDonationPoorTitle': 'Poor & Needy',
    'zakatDonationPoorDesc': 'Direct distribution to families in Palestine',
    'zakatDonationStudentsTitle': 'Students of knowledge',
    'zakatDonationStudentsDesc': 'Scholarships and support for students',
    'zakatDonationProceed': 'Proceed to donate',
    'zakatDonationTitle': 'Donate zakat via the platform',
    'zakatDonationSubtitle':
        'Donate through the Ministry platform to ensure it reaches eligible recipients',
    'zakatErrorBelowNisab': 'Amount is below nisab ({nisab} {currency})',
    'zakatErrorBelowNisabKg': 'Quantity is below nisab ({nisabKg} kg)',
    'zakatErrorEnterValidAmount': 'Please enter a valid amount',
    'zakatErrorEnterValidValues': 'Please enter valid values',
    'zakatErrorPleaseCalculateFirst': 'Please calculate zakat first',
    'zakatErrorSelectDonationOption': 'Please select a donation option',
    'zakatHeroTitle': 'Electronic Zakat Calculator',
    'zakatHeroSubtitle':
        'Calculate your zakat accurately and easily for different wealth types according to Islamic law.',
    'zakatInfoSectionTitle': 'Important information about zakat',
    'zakatInfoConditionsTitle': 'Conditions',
    'zakatInfoConditionsBody': '''1. Islam
2. Freedom
3. Owning nisab
4. One full hawl
5. No debt consuming nisab''',
    'zakatInfoNoZakatTitle': 'No zakat on',
    'zakatInfoNoZakatBody': '''• Primary residence
• Personal clothing & furniture
• Personal transportation
• Unrecoverable debts
• Below nisab''',
    'zakatInfoRecipientsTitle': 'Recipients',
    'zakatInfoRecipientsBody':
        'Poor, needy, zakat workers, those whose hearts are reconciled, freeing captives, debtors, in the cause of Allah, traveler (At-Tawbah: 60)',
    'zakatItemAgriNisab': 'Nisab',
    'zakatItemAgriPrice': 'Price per kg',
    'zakatItemAgriQuantity': 'Quantity',
    'zakatItemAgriTotalValue': 'Total value',
    'zakatItemAgriType': 'Farming type',
    'zakatItemDebts': 'Debts',
    'zakatItemNetAmount': 'Net amount',
    'zakatItemNisab': 'Nisab',
    'zakatItemPeriodDays': 'Hawl period',
    'zakatItemRate': 'Zakat rate',
    'zakatItemTotalAmount': 'Total amount',
    'zakatItemTradeCash': 'Cash in hand',
    'zakatItemTradeGoods': 'Goods value',
    'zakatItemTradeNetAssets': 'Net assets',
    'zakatItemTradePayables': 'Payables',
    'zakatItemTradeReceivables': 'Receivables',
    'zakatItemTradeTotalAssets': 'Total assets',
    'zakatKgValue': '{kg} kg',
    'zakatPercentValue': '{p}%',
    'zakatNisabTitle': 'Has it reached Nisab?',
    'zakatNisabBody': '''Cash nisab: equivalent to {grams} grams of 24K gold
Gold price today: {price} {currency} (approx.)
Nisab in {currency}: {nisab}''',
    'zakatPrintNotSupported': 'Printing is not supported on this device',
    'zakatResultsCashTitle': 'Cash & Currency Zakat',
    'zakatResultsTradeTitle': 'Trade Zakat',
    'zakatResultsAgricultureTitle': 'Agriculture Zakat',
    'zakatResultsSubtitle': 'Calculation date: {date}',
    'zakatTabCash': 'Cash & Currency',
    'zakatTabTrade': 'Trade Goods',
    'zakatTabAgriculture': 'Agriculture',
    'zakatTradeCashHint': 'Enter cash amount',
    'zakatTradeCashLabel': 'Cash in hand ({currency})',
    'zakatTradeGoodsHint': 'Enter goods value',
    'zakatTradeGoodsLabel': 'Goods value ({currency})',
    'zakatTradePayablesHint': 'Enter payables',
    'zakatTradePayablesLabel': 'Payables ({currency})',
    'zakatTradeReceivablesHint': 'Enter receivables',
    'zakatTradeReceivablesLabel': 'Receivables ({currency})',
  };

  String _raw(String key) {
    final map = _isArabic ? _ar : _en;
    return map[key] ?? _en[key] ?? key;
  }

  String _fmt(String key, Map<String, String> args) {
    var s = _raw(key);
    args.forEach((k, v) {
      s = s.replaceAll('{$k}', v);
    });
    return s;
  }

  // --- accessors used by UI ---
  String zakatAgriInfoBody(String nisabKg) =>
      _fmt('zakatAgriInfoBody', <String, String>{'nisabKg': nisabKg});
  String get zakatAgriInfoTitle => _raw('zakatAgriInfoTitle');
  String get zakatAgriPriceHint => _raw('zakatAgriPriceHint');
  String zakatAgriPriceLabel(String currency) =>
      _fmt('zakatAgriPriceLabel', <String, String>{'currency': currency});
  String get zakatAgriQuantityHint => _raw('zakatAgriQuantityHint');
  String get zakatAgriQuantityLabel => _raw('zakatAgriQuantityLabel');
  String get zakatAgriTypeIrrigated => _raw('zakatAgriTypeIrrigated');
  String get zakatAgriTypeLabel => _raw('zakatAgriTypeLabel');
  String get zakatAgriTypeRain => _raw('zakatAgriTypeRain');

  String get zakatAmountDueTitle => _raw('zakatAmountDueTitle');
  String get zakatBtnDonateNow => _raw('zakatBtnDonateNow');
  String get zakatBtnNewCalculation => _raw('zakatBtnNewCalculation');
  String get zakatBtnPrint => _raw('zakatBtnPrint');

  String get zakatCalculateAgriculture => _raw('zakatCalculateAgriculture');
  String get zakatCalculateCash => _raw('zakatCalculateCash');
  String get zakatCalculateTrade => _raw('zakatCalculateTrade');

  String get zakatCashAmountHint => _raw('zakatCashAmountHint');
  String zakatCashAmountLabel(String currency) =>
      _fmt('zakatCashAmountLabel', <String, String>{'currency': currency});
  String get zakatCashDebtsHint => _raw('zakatCashDebtsHint');
  String zakatCashDebtsLabel(String currency) =>
      _fmt('zakatCashDebtsLabel', <String, String>{'currency': currency});
  String get zakatCashPeriodFullYear => _raw('zakatCashPeriodFullYear');
  String get zakatCashPeriodHalfYear => _raw('zakatCashPeriodHalfYear');
  String get zakatCashPeriodQuarterYear => _raw('zakatCashPeriodQuarterYear');
  String get zakatCashPeriodLabel => _raw('zakatCashPeriodLabel');

  String get zakatCurrencyIls => _raw('zakatCurrencyIls');
  String zakatDaysValue(String days) =>
      _fmt('zakatDaysValue', <String, String>{'days': days});
  String get zakatDialogOk => _raw('zakatDialogOk');

  String get zakatDonationDialogTitle => _raw('zakatDonationDialogTitle');
  String zakatDonationDialogBody(String amount, String option) => _fmt(
    'zakatDonationDialogBody',
    <String, String>{'amount': amount, 'option': option},
  );

  String get zakatDonationMosquesTitle => _raw('zakatDonationMosquesTitle');
  String get zakatDonationMosquesDesc => _raw('zakatDonationMosquesDesc');
  String get zakatDonationOrphansTitle => _raw('zakatDonationOrphansTitle');
  String get zakatDonationOrphansDesc => _raw('zakatDonationOrphansDesc');
  String get zakatDonationPoorTitle => _raw('zakatDonationPoorTitle');
  String get zakatDonationPoorDesc => _raw('zakatDonationPoorDesc');
  String get zakatDonationStudentsTitle => _raw('zakatDonationStudentsTitle');
  String get zakatDonationStudentsDesc => _raw('zakatDonationStudentsDesc');
  String get zakatDonationProceed => _raw('zakatDonationProceed');
  String get zakatDonationTitle => _raw('zakatDonationTitle');
  String get zakatDonationSubtitle => _raw('zakatDonationSubtitle');

  String zakatErrorBelowNisab(String nisab, String currency) => _fmt(
    'zakatErrorBelowNisab',
    <String, String>{'nisab': nisab, 'currency': currency},
  );
  String zakatErrorBelowNisabKg(String nisabKg) =>
      _fmt('zakatErrorBelowNisabKg', <String, String>{'nisabKg': nisabKg});
  String get zakatErrorEnterValidAmount => _raw('zakatErrorEnterValidAmount');
  String get zakatErrorEnterValidValues => _raw('zakatErrorEnterValidValues');
  String get zakatErrorPleaseCalculateFirst =>
      _raw('zakatErrorPleaseCalculateFirst');
  String get zakatErrorSelectDonationOption =>
      _raw('zakatErrorSelectDonationOption');

  String get zakatHeroTitle => _raw('zakatHeroTitle');
  String get zakatHeroSubtitle => _raw('zakatHeroSubtitle');

  String get zakatInfoSectionTitle => _raw('zakatInfoSectionTitle');
  String get zakatInfoConditionsTitle => _raw('zakatInfoConditionsTitle');
  String get zakatInfoConditionsBody => _raw('zakatInfoConditionsBody');
  String get zakatInfoNoZakatTitle => _raw('zakatInfoNoZakatTitle');
  String get zakatInfoNoZakatBody => _raw('zakatInfoNoZakatBody');
  String get zakatInfoRecipientsTitle => _raw('zakatInfoRecipientsTitle');
  String get zakatInfoRecipientsBody => _raw('zakatInfoRecipientsBody');

  String get zakatItemAgriNisab => _raw('zakatItemAgriNisab');
  String get zakatItemAgriPrice => _raw('zakatItemAgriPrice');
  String get zakatItemAgriQuantity => _raw('zakatItemAgriQuantity');
  String get zakatItemAgriTotalValue => _raw('zakatItemAgriTotalValue');
  String get zakatItemAgriType => _raw('zakatItemAgriType');
  String get zakatItemDebts => _raw('zakatItemDebts');
  String get zakatItemNetAmount => _raw('zakatItemNetAmount');
  String get zakatItemNisab => _raw('zakatItemNisab');
  String get zakatItemPeriodDays => _raw('zakatItemPeriodDays');
  String get zakatItemRate => _raw('zakatItemRate');
  String get zakatItemTotalAmount => _raw('zakatItemTotalAmount');
  String get zakatItemTradeCash => _raw('zakatItemTradeCash');
  String get zakatItemTradeGoods => _raw('zakatItemTradeGoods');
  String get zakatItemTradeNetAssets => _raw('zakatItemTradeNetAssets');
  String get zakatItemTradePayables => _raw('zakatItemTradePayables');
  String get zakatItemTradeReceivables => _raw('zakatItemTradeReceivables');
  String get zakatItemTradeTotalAssets => _raw('zakatItemTradeTotalAssets');

  String zakatKgValue(String kg) =>
      _fmt('zakatKgValue', <String, String>{'kg': kg});
  String zakatPercentValue(String p) =>
      _fmt('zakatPercentValue', <String, String>{'p': p});

  String get zakatNisabTitle => _raw('zakatNisabTitle');
  String zakatNisabBody(
    String grams,
    String price,
    String currency,
    String nisab,
  ) => _fmt('zakatNisabBody', <String, String>{
    'grams': grams,
    'price': price,
    'currency': currency,
    'nisab': nisab,
  });

  String get zakatPrintNotSupported => _raw('zakatPrintNotSupported');

  String get zakatResultsCashTitle => _raw('zakatResultsCashTitle');
  String get zakatResultsTradeTitle => _raw('zakatResultsTradeTitle');
  String get zakatResultsAgricultureTitle =>
      _raw('zakatResultsAgricultureTitle');
  String zakatResultsSubtitle(String date) =>
      _fmt('zakatResultsSubtitle', <String, String>{'date': date});

  String get zakatTabCash => _raw('zakatTabCash');
  String get zakatTabTrade => _raw('zakatTabTrade');
  String get zakatTabAgriculture => _raw('zakatTabAgriculture');

  String get zakatTradeCashHint => _raw('zakatTradeCashHint');
  String zakatTradeCashLabel(String currency) =>
      _fmt('zakatTradeCashLabel', <String, String>{'currency': currency});
  String get zakatTradeGoodsHint => _raw('zakatTradeGoodsHint');
  String zakatTradeGoodsLabel(String currency) =>
      _fmt('zakatTradeGoodsLabel', <String, String>{'currency': currency});
  String get zakatTradePayablesHint => _raw('zakatTradePayablesHint');
  String zakatTradePayablesLabel(String currency) =>
      _fmt('zakatTradePayablesLabel', <String, String>{'currency': currency});
  String get zakatTradeReceivablesHint => _raw('zakatTradeReceivablesHint');
  String zakatTradeReceivablesLabel(String currency) => _fmt(
    'zakatTradeReceivablesLabel',
    <String, String>{'currency': currency},
  );

  String get zakatDonationNameLabel =>
      isArabic ? 'الاسم (اختياري)' : 'Name (optional)';
  String get zakatDonationPhoneLabel => isArabic ? 'رقم الهاتف *' : 'Phone *';
  String get zakatDonationNoteLabel =>
      isArabic ? 'ملاحظات (اختياري)' : 'Notes (optional)';
  String get zakatDonationSend => isArabic ? 'إرسال الطلب' : 'Send request';
  String get zakatDialogCancel => isArabic ? 'إلغاء' : 'Cancel';

  String get zakatDonationSentSuccess => isArabic
      ? 'تم إرسال طلب التبرع بنجاح. سنقوم بالتواصل معك قريبًا.'
      : 'Donation request sent successfully. We will contact you soon.';
  String get zakatDonationSendFailed =>
      isArabic ? 'فشل إرسال طلب التبرع' : 'Failed to send donation request';

  String get zakatErrorEnterPhone =>
      isArabic ? 'الرجاء إدخال رقم الهاتف' : 'Please enter your phone number';
}
