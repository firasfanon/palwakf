import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/pwf_zakat_i18n.dart';
import 'package:waqf/features/platform/home/presentation/widgets/pwf_internal_public_page_contract_widgets.dart';
import 'package:intl/intl.dart';

import '../../domain/pwf_zakat_models.dart';
import '../../domain/pwf_zakat_official_config_contract.dart';
import '../providers/pwf_zakat_calculator_provider.dart';
import '../providers/pwf_zakat_official_config_provider.dart';
import '../services/pwf_print_service.dart';
import '../widgets/pwf_max_width.dart';
import '../widgets/pwf_zakat_calculator_card.dart';
import '../widgets/pwf_zakat_donation_section.dart';
import '../widgets/pwf_zakat_hero.dart';
import '../widgets/pwf_zakat_info_section.dart';
import '../widgets/pwf_zakat_results_section.dart';
import '../widgets/pwf_zakat_theme.dart';
import 'package:waqf/features/platform/home/presentation/screens/pages/pwf_public_content_shared.dart';
import 'package:waqf/features/platform/home/presentation/theme/pwf_home_palette.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';

class PwfZakatCalculatorScreen extends ConsumerStatefulWidget {
  const PwfZakatCalculatorScreen({
    super.key,
    this.embedInPublicShell = false,
    this.showEmbeddedIntro = true,
    this.unitSlug = 'home',
  });

  final bool embedInPublicShell;
  final bool showEmbeddedIntro;
  final String unitSlug;

  @override
  ConsumerState<PwfZakatCalculatorScreen> createState() =>
      _PwfZakatCalculatorScreenState();
}

class _PwfZakatCalculatorScreenState
    extends ConsumerState<PwfZakatCalculatorScreen> {
  final ScrollController _scroll = ScrollController();

  final GlobalKey _resultsKey = GlobalKey();
  final GlobalKey _donationKey = GlobalKey();

  // Cash
  final TextEditingController _cashAmount = TextEditingController();
  final TextEditingController _cashDebts = TextEditingController(text: '0');
  int _cashPeriodDays = 365;

  // Trade
  final TextEditingController _tradeGoods = TextEditingController();
  final TextEditingController _tradeCash = TextEditingController();
  final TextEditingController _tradeReceivables = TextEditingController();
  final TextEditingController _tradePayables = TextEditingController(text: '0');

  // Agriculture
  PwfAgricultureType _agriType = PwfAgricultureType.irrigated;
  final TextEditingController _agriQty = TextEditingController();
  final TextEditingController _agriPrice = TextEditingController();

  @override
  void dispose() {
    _scroll.dispose();

    _cashAmount.dispose();
    _cashDebts.dispose();

    _tradeGoods.dispose();
    _tradeCash.dispose();
    _tradeReceivables.dispose();
    _tradePayables.dispose();

    _agriQty.dispose();
    _agriPrice.dispose();

    super.dispose();
  }

  double _toDouble(TextEditingController c) =>
      double.tryParse(c.text.trim()) ?? 0;

  String _fmtNumber(BuildContext context, double v) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return NumberFormat.decimalPattern(locale).format(v);
  }

  void _snack(BuildContext context, String text, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError
            ? PwfZakatPalette.royalRed
            : PwfZakatPalette.primary2,
      ),
    );
  }

  Future<void> _openDonationSubmitDialog({
    required BuildContext context,
    required String optionName,
    required String optionKey,
    required double amountIls,
    required PwfZakatI18n l10n,
  }) async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    bool loading = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: !loading,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            Future<void> submit() async {
              final phone = phoneCtrl.text.trim();
              if (phone.isEmpty) {
                _snack(context, l10n.zakatErrorEnterPhone);
                return;
              }

              setLocal(() => loading = true);
              try {
                await _submitDonationRequest(
                  optionKey: optionKey,
                  amountIls: amountIls,
                  donorName: nameCtrl.text.trim().isEmpty
                      ? null
                      : nameCtrl.text.trim(),
                  donorPhone: phone,
                  note: noteCtrl.text.trim().isEmpty
                      ? null
                      : noteCtrl.text.trim(),
                );

                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();

                _snack(context, l10n.zakatDonationSentSuccess, isError: false);
              } catch (e) {
                setLocal(() => loading = false);
                _snack(context, l10n.zakatDonationSendFailed);
              }
            }

            final amountLabel =
                '${_fmtNumber(context, amountIls)} ${l10n.zakatCurrencyIls}';

            return AlertDialog(
              title: Text(l10n.zakatDonationDialogTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        l10n.zakatDonationDialogBody(amountLabel, optionName),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.zakatDonationNameLabel,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: l10n.zakatDonationPhoneLabel,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: noteCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: l10n.zakatDonationNoteLabel,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: loading ? null : () => Navigator.of(ctx).pop(),
                  child: Text(l10n.zakatDialogCancel),
                ),
                FilledButton.icon(
                  onPressed: loading ? null : submit,
                  icon: loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(l10n.zakatDonationSend),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitDonationRequest({
    required String optionKey,
    required double amountIls,
    String? donorName,
    required String donorPhone,
    String? note,
  }) async {
    final client = Supabase.instance.client;

    // Resolve "home" unit id safely (if RPC exists), otherwise fall back to known HOME slug lookup via org_units view.
    String? unitId;
    try {
      final res = await client.rpc('pwf_require_home_unit_id');
      if (res != null) unitId = res.toString();
    } catch (_) {
      // ignore
    }

    if (unitId == null) {
      try {
        final row = await PwfDatabaseOwnerSurfaces.fromOwnerSchema(
          client,
          PwfDatabaseOwnerSurfaces.orgUnits,
        ).select('id').eq('slug', 'home').maybeSingle();
        unitId = row?['id']?.toString();
      } catch (_) {
        // ignore
      }
    }

    // Last resort: use platform global unit if present.
    unitId ??= '11111111-1111-1111-1111-111111111111';

    await client.from(PwfDatabaseOwnerSurfaces.zakatDonationRequests).insert({
      'unit_id': unitId,
      'donation_option': optionKey,
      'amount': double.parse(amountIls.toStringAsFixed(2)),
      'currency': 'ILS',
      'donor_name': donorName,
      'donor_phone': donorPhone,
      'note': note,
      'created_by': client.auth.currentUser?.id,
    });
  }

  Future<void> _scrollTo(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      alignment: 0.08,
    );
  }

  String _outcomeMessage(BuildContext context, PwfZakatCalcError err) {
    final l10n = PwfZakatI18n.of(context);

    switch (err.code) {
      case PwfZakatCalcErrorCode.invalidAmount:
        return l10n.zakatErrorEnterValidAmount;
      case PwfZakatCalcErrorCode.invalidValues:
        return l10n.zakatErrorEnterValidValues;
      case PwfZakatCalcErrorCode.belowNisabCash:
        final nisab = (err.args['nisab'] as num?)?.toDouble() ?? 0;
        return l10n.zakatErrorBelowNisab(
          _fmtNumber(context, nisab),
          l10n.zakatCurrencyIls,
        );
      case PwfZakatCalcErrorCode.belowNisabTrade:
        final nisab = (err.args['nisab'] as num?)?.toDouble() ?? 0;
        return l10n.zakatErrorBelowNisab(
          _fmtNumber(context, nisab),
          l10n.zakatCurrencyIls,
        );
      case PwfZakatCalcErrorCode.belowNisabAgriculture:
        final nisabKg = (err.args['nisabKg'] as num?)?.toDouble() ?? 0;
        return l10n.zakatErrorBelowNisabKg(_fmtNumber(context, nisabKg));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = PwfZakatI18n.of(context);

    final state = ref.watch(pwfZakatCalculatorProvider);
    final notifier = ref.read(pwfZakatCalculatorProvider.notifier);
    final configState = ref.watch(pwfZakatPublicConfigProvider);

    ref.listen<AsyncValue<PwfZakatPublicConfig>>(pwfZakatPublicConfigProvider, (
      previous,
      next,
    ) {
      next.whenData((config) {
        ref
            .read(pwfZakatCalculatorProvider.notifier)
            .updateReference(config.toReference());
      });
    });

    final tabs = <PwfZakatTabSpec>[
      PwfZakatTabSpec(
        tab: PwfZakatTab.cash,
        label: l10n.zakatTabCash,
        icon: Icons.attach_money,
      ),
      PwfZakatTabSpec(
        tab: PwfZakatTab.trade,
        label: l10n.zakatTabTrade,
        icon: Icons.store,
      ),
      PwfZakatTabSpec(
        tab: PwfZakatTab.agriculture,
        label: l10n.zakatTabAgriculture,
        icon: Icons.agriculture,
      ),
    ];

    final calc = state.calculation;

    final sections = <Widget>[
      if (!widget.embedInPublicShell)
        PwfZakatHero(
          title: l10n.zakatHeroTitle,
          subtitle: l10n.zakatHeroSubtitle,
          imageUrl:
              'https://images.unsplash.com/photo-1587614382346-4ec70e388b28?auto=format&fit=crop&w=1470&q=80',
        ),
      if (widget.embedInPublicShell && widget.showEmbeddedIntro)
        PwfInternalPublicPageIntro(
          specKey: 'zakat',
          unitSlug: widget.unitSlug,
          verticalPadding: 0,
          subtitle:
              'واجهة عامة لحساب الزكاة، وشرح مصارفها، ومتابعة التبرع أو الإحالة إلى المسارات المرتبطة بها.',
        ),
      SizedBox(height: widget.embedInPublicShell ? 18 : 24),
      if (widget.embedInPublicShell) ...[
        PwfMaxWidth(
          child: _ZakatOfficialConfigStrip(
            reference: state.reference,
            configState: configState,
          ),
        ),
        const SizedBox(height: 16),
      ],
      PwfMaxWidth(
        child: PwfZakatCalculatorCard(
          tabs: tabs,
          activeTab: state.tab,
          onTabSelected: notifier.selectTab,
          body: _buildTabBody(context, state.tab, state.reference, notifier),
        ),
      ),
      const SizedBox(height: 24),
      KeyedSubtree(
        key: _resultsKey,
        child: PwfMaxWidth(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: calc == null
                ? const SizedBox.shrink()
                : PwfZakatResultsSection(
                    title: _calcTitle(context, calc),
                    subtitle: l10n.zakatResultsSubtitle(
                      DateFormat.yMMMMd(
                        Localizations.localeOf(context).toLanguageTag(),
                      ).format(calc.calculatedAt),
                    ),
                    items: _calcItems(context, calc),
                    totalLabel: l10n.zakatAmountDueTitle,
                    totalValue:
                        '${_fmtNumber(context, calc.zakatAmount)} ${l10n.zakatCurrencyIls}',
                    printLabel: l10n.zakatBtnPrint,
                    donateNowLabel: l10n.zakatBtnDonateNow,
                    newCalculationLabel: l10n.zakatBtnNewCalculation,
                    onPrint: () {
                      final ok = PwfPrintService.printPage();
                      if (!ok)
                        _snack(
                          context,
                          l10n.zakatPrintNotSupported,
                          isError: false,
                        );
                    },
                    onDonateNow: () async {
                      if (state.calculation == null) {
                        _snack(context, l10n.zakatErrorPleaseCalculateFirst);
                        return;
                      }
                      await _scrollTo(_donationKey);
                    },
                    onNewCalculation: () {
                      notifier.reset();
                      _clearInputs();
                    },
                  ),
          ),
        ),
      ),
      const SizedBox(height: 24),
      PwfMaxWidth(
        child: PwfZakatInfoSection(
          title: l10n.zakatInfoSectionTitle,
          cards: <PwfZakatInfoCardData>[
            PwfZakatInfoCardData(
              icon: Icons.balance,
              title: l10n.zakatInfoConditionsTitle,
              body: l10n.zakatInfoConditionsBody,
            ),
            PwfZakatInfoCardData(
              icon: Icons.groups,
              title: l10n.zakatInfoRecipientsTitle,
              body: l10n.zakatInfoRecipientsBody,
            ),
            PwfZakatInfoCardData(
              icon: Icons.warning_amber,
              title: l10n.zakatInfoNoZakatTitle,
              body: l10n.zakatInfoNoZakatBody,
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      KeyedSubtree(
        key: _donationKey,
        child: PwfMaxWidth(
          child: PwfZakatDonationSection(
            title: l10n.zakatDonationTitle,
            subtitle: l10n.zakatDonationSubtitle,
            selected: state.selectedDonationOption,
            onSelect: notifier.selectDonationOption,
            proceedLabel: l10n.zakatDonationProceed,
            onProceed: () {
              if (state.calculation == null) {
                _snack(context, l10n.zakatErrorPleaseCalculateFirst);
                return;
              }
              if (state.selectedDonationOption == null) {
                _snack(context, l10n.zakatErrorSelectDonationOption);
                return;
              }

              final optionName = _donationOptionName(
                context,
                state.selectedDonationOption!,
              );

              _openDonationSubmitDialog(
                context: context,
                optionName: optionName,
                optionKey: state.selectedDonationOption!.name,
                amountIls: state.calculation!.zakatAmount,
                l10n: l10n,
              );
            },
            options: <PwfZakatDonationOptionSpec>[
              PwfZakatDonationOptionSpec(
                option: PwfZakatDonationOption.poor,
                icon: Icons.volunteer_activism,
                title: l10n.zakatDonationPoorTitle,
                description: l10n.zakatDonationPoorDesc,
              ),
              PwfZakatDonationOptionSpec(
                option: PwfZakatDonationOption.students,
                icon: Icons.school,
                title: l10n.zakatDonationStudentsTitle,
                description: l10n.zakatDonationStudentsDesc,
              ),
              PwfZakatDonationOptionSpec(
                option: PwfZakatDonationOption.mosques,
                icon: Icons.mosque,
                title: l10n.zakatDonationMosquesTitle,
                description: l10n.zakatDonationMosquesDesc,
              ),
              PwfZakatDonationOptionSpec(
                option: PwfZakatDonationOption.orphans,
                icon: Icons.child_care,
                title: l10n.zakatDonationOrphansTitle,
                description: l10n.zakatDonationOrphansDesc,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 40),
    ];

    final embeddedBody = Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: sections,
      ),
    );

    return Directionality(
      textDirection: l10n.isArabic
          ? ui.TextDirection.rtl
          : ui.TextDirection.ltr,
      child: widget.embedInPublicShell
          ? embeddedBody
          : Scaffold(
              backgroundColor: PwfZakatPalette.bg,
              body: CustomScrollView(
                controller: _scroll,
                slivers: sections
                    .map((section) => SliverToBoxAdapter(child: section))
                    .toList(growable: false),
              ),
            ),
    );
  }

  Widget _buildTabBody(
    BuildContext context,
    PwfZakatTab tab,
    PwfZakatReference refData,
    dynamic notifier, // PwfZakatCalculatorNotifier
  ) {
    final l10n = PwfZakatI18n.of(context);

    switch (tab) {
      case PwfZakatTab.cash:
        final nisab = refData.cashNisabIls;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _ResponsiveFormGrid(
              children: <Widget>[
                _NumberField(
                  label: l10n.zakatCashAmountLabel(l10n.zakatCurrencyIls),
                  hint: l10n.zakatCashAmountHint,
                  controller: _cashAmount,
                  icon: Icons.account_balance_wallet,
                ),
                _NumberField(
                  label: l10n.zakatCashDebtsLabel(l10n.zakatCurrencyIls),
                  hint: l10n.zakatCashDebtsHint,
                  controller: _cashDebts,
                  icon: Icons.handshake,
                ),
                _DropdownField<int>(
                  label: l10n.zakatCashPeriodLabel,
                  icon: Icons.calendar_month,
                  value: _cashPeriodDays,
                  items: <DropdownMenuItem<int>>[
                    DropdownMenuItem(
                      value: 365,
                      child: Text(l10n.zakatCashPeriodFullYear),
                    ),
                    DropdownMenuItem(
                      value: 180,
                      child: Text(l10n.zakatCashPeriodHalfYear),
                    ),
                    DropdownMenuItem(
                      value: 90,
                      child: Text(l10n.zakatCashPeriodQuarterYear),
                    ),
                  ],
                  onChanged: (v) => setState(() => _cashPeriodDays = v ?? 365),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoBox(
              title: l10n.zakatNisabTitle,
              body: l10n.zakatNisabBody(
                _fmtNumber(context, refData.cashNisabGoldGrams),
                _fmtNumber(context, refData.goldGramPriceIls),
                _fmtNumber(context, nisab),
                l10n.zakatCurrencyIls,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final out = notifier.calculateCash(
                  amount: _toDouble(_cashAmount),
                  debts: _toDouble(_cashDebts),
                  periodDays: _cashPeriodDays,
                );

                if (out is PwfZakatCalcError) {
                  _snack(context, _outcomeMessage(context, out));
                  return;
                }
                await _scrollTo(_resultsKey);
              },
              icon: const Icon(Icons.calculate),
              label: Text(l10n.zakatCalculateCash),
              style: ElevatedButton.styleFrom(
                backgroundColor: PwfZakatPalette.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        );

      case PwfZakatTab.trade:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _ResponsiveFormGrid(
              children: <Widget>[
                _NumberField(
                  label: l10n.zakatTradeGoodsLabel(l10n.zakatCurrencyIls),
                  hint: l10n.zakatTradeGoodsHint,
                  controller: _tradeGoods,
                  icon: Icons.inventory_2,
                ),
                _NumberField(
                  label: l10n.zakatTradeCashLabel(l10n.zakatCurrencyIls),
                  hint: l10n.zakatTradeCashHint,
                  controller: _tradeCash,
                  icon: Icons.payments,
                ),
                _NumberField(
                  label: l10n.zakatTradeReceivablesLabel(l10n.zakatCurrencyIls),
                  hint: l10n.zakatTradeReceivablesHint,
                  controller: _tradeReceivables,
                  icon: Icons.receipt_long,
                ),
                _NumberField(
                  label: l10n.zakatTradePayablesLabel(l10n.zakatCurrencyIls),
                  hint: l10n.zakatTradePayablesHint,
                  controller: _tradePayables,
                  icon: Icons.request_quote,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final out = notifier.calculateTrade(
                  goodsValue: _toDouble(_tradeGoods),
                  cashInHand: _toDouble(_tradeCash),
                  receivables: _toDouble(_tradeReceivables),
                  payables: _toDouble(_tradePayables),
                );

                if (out is PwfZakatCalcError) {
                  _snack(context, _outcomeMessage(context, out));
                  return;
                }
                await _scrollTo(_resultsKey);
              },
              icon: const Icon(Icons.calculate),
              label: Text(l10n.zakatCalculateTrade),
              style: ElevatedButton.styleFrom(
                backgroundColor: PwfZakatPalette.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        );

      case PwfZakatTab.agriculture:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _ResponsiveFormGrid(
              children: <Widget>[
                _DropdownField<PwfAgricultureType>(
                  label: l10n.zakatAgriTypeLabel,
                  icon: Icons.agriculture,
                  value: _agriType,
                  items: <DropdownMenuItem<PwfAgricultureType>>[
                    DropdownMenuItem(
                      value: PwfAgricultureType.irrigated,
                      child: Text(l10n.zakatAgriTypeIrrigated),
                    ),
                    DropdownMenuItem(
                      value: PwfAgricultureType.rain,
                      child: Text(l10n.zakatAgriTypeRain),
                    ),
                  ],
                  onChanged: (v) => setState(
                    () => _agriType = v ?? PwfAgricultureType.irrigated,
                  ),
                ),
                _NumberField(
                  label: l10n.zakatAgriQuantityLabel,
                  hint: l10n.zakatAgriQuantityHint,
                  controller: _agriQty,
                  icon: Icons.scale,
                ),
                _NumberField(
                  label: l10n.zakatAgriPriceLabel(l10n.zakatCurrencyIls),
                  hint: l10n.zakatAgriPriceHint,
                  controller: _agriPrice,
                  icon: Icons.sell,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoBox(
              title: l10n.zakatAgriInfoTitle,
              body: l10n.zakatAgriInfoBody(
                _fmtNumber(context, refData.agricultureNisabKg),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final out = notifier.calculateAgriculture(
                  type: _agriType,
                  quantityKg: _toDouble(_agriQty),
                  pricePerKg: _toDouble(_agriPrice),
                );

                if (out is PwfZakatCalcError) {
                  _snack(context, _outcomeMessage(context, out));
                  return;
                }
                await _scrollTo(_resultsKey);
              },
              icon: const Icon(Icons.calculate),
              label: Text(l10n.zakatCalculateAgriculture),
              style: ElevatedButton.styleFrom(
                backgroundColor: PwfZakatPalette.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        );
    }
  }

  void _clearInputs() {
    _cashAmount.clear();
    _cashDebts.text = '0';

    _tradeGoods.clear();
    _tradeCash.clear();
    _tradeReceivables.clear();
    _tradePayables.text = '0';

    _agriQty.clear();
    _agriPrice.clear();
    _agriType = PwfAgricultureType.irrigated;

    setState(() {});
  }

  String _calcTitle(BuildContext context, PwfZakatCalculation calc) {
    final l10n = PwfZakatI18n.of(context);
    switch (calc.tab) {
      case PwfZakatTab.cash:
        return l10n.zakatResultsCashTitle;
      case PwfZakatTab.trade:
        return l10n.zakatResultsTradeTitle;
      case PwfZakatTab.agriculture:
        return l10n.zakatResultsAgricultureTitle;
    }
  }

  List<PwfResultItem> _calcItems(
    BuildContext context,
    PwfZakatCalculation calc,
  ) {
    final l10n = PwfZakatI18n.of(context);

    if (calc is PwfCashZakatCalculation) {
      return <PwfResultItem>[
        PwfResultItem(
          label: l10n.zakatItemTotalAmount,
          value: '${_fmtNumber(context, calc.amount)} ${l10n.zakatCurrencyIls}',
        ),
        PwfResultItem(
          label: l10n.zakatItemDebts,
          value: '${_fmtNumber(context, calc.debts)} ${l10n.zakatCurrencyIls}',
        ),
        PwfResultItem(
          label: l10n.zakatItemNetAmount,
          value:
              '${_fmtNumber(context, calc.netAmount)} ${l10n.zakatCurrencyIls}',
        ),
        PwfResultItem(
          label: l10n.zakatItemNisab,
          value:
              '${_fmtNumber(context, calc.nisabIls)} ${l10n.zakatCurrencyIls}',
        ),
        PwfResultItem(
          label: l10n.zakatItemPeriodDays,
          value: l10n.zakatDaysValue(calc.periodDays.toString()),
        ),
        PwfResultItem(
          label: l10n.zakatItemRate,
          value: l10n.zakatPercentValue(
            (calc.zakatPercentage * 100).toStringAsFixed(2),
          ),
        ),
      ];
    }

    if (calc is PwfTradeZakatCalculation) {
      return <PwfResultItem>[
        PwfResultItem(
          label: l10n.zakatItemTradeGoods,
          value:
              '${_fmtNumber(context, calc.goodsValue)} ${l10n.zakatCurrencyIls}',
        ),
        PwfResultItem(
          label: l10n.zakatItemTradeCash,
          value:
              '${_fmtNumber(context, calc.cashInHand)} ${l10n.zakatCurrencyIls}',
        ),
        PwfResultItem(
          label: l10n.zakatItemTradeReceivables,
          value:
              '${_fmtNumber(context, calc.receivables)} ${l10n.zakatCurrencyIls}',
        ),
        PwfResultItem(
          label: l10n.zakatItemTradeTotalAssets,
          value:
              '${_fmtNumber(context, calc.totalAssets)} ${l10n.zakatCurrencyIls}',
        ),
        PwfResultItem(
          label: l10n.zakatItemTradePayables,
          value:
              '${_fmtNumber(context, calc.payables)} ${l10n.zakatCurrencyIls}',
        ),
        PwfResultItem(
          label: l10n.zakatItemTradeNetAssets,
          value:
              '${_fmtNumber(context, calc.netAssets)} ${l10n.zakatCurrencyIls}',
        ),
      ];
    }

    final a = calc as PwfAgricultureZakatCalculation;
    return <PwfResultItem>[
      PwfResultItem(
        label: l10n.zakatItemAgriType,
        value: a.type == PwfAgricultureType.rain
            ? l10n.zakatAgriTypeRain
            : l10n.zakatAgriTypeIrrigated,
      ),
      PwfResultItem(
        label: l10n.zakatItemAgriQuantity,
        value: l10n.zakatKgValue(_fmtNumber(context, a.quantityKg)),
      ),
      PwfResultItem(
        label: l10n.zakatItemAgriPrice,
        value: '${_fmtNumber(context, a.pricePerKg)} ${l10n.zakatCurrencyIls}',
      ),
      PwfResultItem(
        label: l10n.zakatItemAgriTotalValue,
        value: '${_fmtNumber(context, a.totalValue)} ${l10n.zakatCurrencyIls}',
      ),
      PwfResultItem(
        label: l10n.zakatItemAgriNisab,
        value: l10n.zakatKgValue(_fmtNumber(context, a.nisabKg)),
      ),
      PwfResultItem(
        label: l10n.zakatItemRate,
        value: l10n.zakatPercentValue((a.zakatRate * 100).toStringAsFixed(0)),
      ),
    ];
  }

  String _donationOptionName(BuildContext context, PwfZakatDonationOption opt) {
    final l10n = PwfZakatI18n.of(context);
    switch (opt) {
      case PwfZakatDonationOption.poor:
        return l10n.zakatDonationPoorTitle;
      case PwfZakatDonationOption.students:
        return l10n.zakatDonationStudentsTitle;
      case PwfZakatDonationOption.mosques:
        return l10n.zakatDonationMosquesTitle;
      case PwfZakatDonationOption.orphans:
        return l10n.zakatDonationOrphansTitle;
    }
  }
}

class _ZakatOfficialConfigStrip extends StatelessWidget {
  const _ZakatOfficialConfigStrip({
    required this.reference,
    required this.configState,
  });

  final PwfZakatReference reference;
  final AsyncValue<PwfZakatPublicConfig> configState;

  @override
  Widget build(BuildContext context) {
    return PwfSurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const PwfMetaBadge(
                label: 'أداة حساب إرشادية',
                icon: Icons.verified_outlined,
                color: PwfHomePalette.primary,
              ),
              PwfMetaBadge(
                label: reference.isOfficialRuntimeSource
                    ? 'إعدادات منشورة'
                    : 'إعدادات تقديرية',
                icon: reference.isOfficialRuntimeSource
                    ? Icons.verified_user_outlined
                    : Icons.info_outline,
                color: reference.isOfficialRuntimeSource
                    ? const Color(0xFF15803D)
                    : PwfHomePalette.secondary,
              ),
              PwfMetaBadge(
                label:
                    'نصاب الذهب ${reference.cashNisabGoldGrams.toStringAsFixed(0)} غرام',
                icon: Icons.scale_outlined,
                color: PwfHomePalette.secondary,
                backgroundColor: PwfHomePalette.secondary.withAlpha(31),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            configState.when(
              data: (config) {
                final publicNotes = pwfPublicCopyOrFallback(
                  config.notesAr ?? '',
                  '',
                );
                return reference.isOfficialRuntimeSource
                    ? 'تعتمد الحاسبة على إعدادات منشورة لاحتساب تقدير أولي للزكاة.${publicNotes.isEmpty ? '' : ' $publicNotes'}'
                    : 'تستخدم الحاسبة إعدادات تقديرية واضحة للجمهور إلى حين اكتمال ربط الإعدادات المنشورة.';
              },
              loading: () => 'جاري تجهيز إعدادات الحاسبة...',
              error: (_, __) =>
                  'تعذر تحميل الإعدادات المنشورة؛ يمكنك استخدام القيم التقديرية الظاهرة في الصفحة.',
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: PwfHomePalette.textSecondary,
              height: 1.7,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveFormGrid extends StatelessWidget {
  const _ResponsiveFormGrid({required this.children});
  final List<Widget> children;

  int _colsForWidth(double w) {
    final int c = (w / 360).floor();
    return c.clamp(1, 3);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = _colsForWidth(c.maxWidth);
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: c.maxWidth < 640 ? 2.05 : 2.55,
          children: children,
        );
      },
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      label: label,
      icon: icon,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      label: label,
      icon: icon,
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

class _FieldShell extends StatelessWidget {
  const _FieldShell({
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icon, size: 18, color: PwfZakatPalette.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: PwfZakatPalette.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(child: child),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PwfZakatPalette.primary.withValues(alpha: 13),
        borderRadius: PwfZakatDecorations.br,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.info_outline, color: PwfZakatPalette.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.w800,
                    color: PwfZakatPalette.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: PwfZakatPalette.gray,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
