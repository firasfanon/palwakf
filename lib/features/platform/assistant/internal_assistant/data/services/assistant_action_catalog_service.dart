import 'package:flutter/material.dart';

import 'package:waqf/app/routing/app_routes.dart';
import '../models/assistant_action.dart';
import '../models/assistant_context.dart';

class AssistantActionCatalogService {
  const AssistantActionCatalogService();

  List<AssistantAction> actionsFor(AssistantContext context) {
    switch (context.systemKey) {
      case 'mustakshif':
      case 'mustakshif_alwaqf':
        return _orderForRoute(
          context.currentRoute,
          <AssistantAction>[
            AssistantAction(
              id: 'mustakshif-map',
              type: AssistantActionType.openRoute,
              labelAr: context.hasAssetContext
                  ? 'فتح الأصل الوقفي الحالي على الخريطة'
                  : 'فتح الخريطة',
              labelEn: context.hasAssetContext
                  ? 'Open current asset on map'
                  : 'Open map',
              icon: Icons.map_rounded,
              route: _contextualRoute(
                AppRoutes.mustakshif,
                context: context,
                queryParameters: {'panel': 'map'},
              ),
            ),
            AssistantAction(
              id: 'mustakshif-search',
              type: AssistantActionType.searchWaqfAsset,
              labelAr: context.hasAssetContext
                  ? 'متابعة الأصل الوقفي الحالي'
                  : 'البحث عن أصل وقفي',
              labelEn: context.hasAssetContext
                  ? 'Continue current waqf asset'
                  : 'Search waqf asset',
              icon: Icons.search_rounded,
              route: _contextualRoute(
                AppRoutes.mustakshif,
                context: context,
                queryParameters: {
                  'intent': context.hasAssetContext
                      ? 'focus-current-asset'
                      : 'search-waqf-asset',
                },
              ),
              messageAr: context.hasAssetContext
                  ? 'تابع الأصل الوقفي الحالي'
                  : 'ابحث عن أصل وقفي',
              messageEn: context.hasAssetContext
                  ? 'Continue the current waqf asset'
                  : 'Search for a waqf asset',
            ),
            AssistantAction(
              id: 'mustakshif-layers',
              type: AssistantActionType.openSystemModule,
              labelAr: 'الطبقات',
              labelEn: 'Layers',
              icon: Icons.layers_rounded,
              route: _contextualRoute(
                AppRoutes.mustakshif,
                context: context,
                queryParameters: {'panel': 'layers'},
              ),
            ),
            AssistantAction(
              id: 'mustakshif-history',
              type: AssistantActionType.openSystemModule,
              labelAr: 'فتح التاريخ',
              labelEn: 'Open history',
              icon: Icons.history_edu_rounded,
              route: _contextualRoute(
                '/mustakshif/history',
                context: context,
                queryParameters: {'tab': 'timeline'},
              ),
            ),
          ],
          priorities: <String, List<String>>{
            'history': const [
              'mustakshif-history',
              'mustakshif-layers',
              'mustakshif-map',
            ],
            'layers': const [
              'mustakshif-layers',
              'mustakshif-map',
              'mustakshif-history',
            ],
            'map': const [
              'mustakshif-map',
              'mustakshif-search',
              'mustakshif-layers',
            ],
          },
        );
      case 'waqf_cases_system':
        return _orderForRoute(
          context.currentRoute,
          <AssistantAction>[
            AssistantAction(
              id: 'cases-open',
              type: AssistantActionType.openPendingItems,
              labelAr: context.hasUnitContext
                  ? 'القضايا المفتوحة في الوحدة الحالية'
                  : 'القضايا المفتوحة',
              labelEn: context.hasUnitContext
                  ? 'Open cases in current unit'
                  : 'Open cases',
              icon: Icons.gavel_rounded,
              route: _contextualRoute(
                AppRoutes.adminCases,
                context: context,
                queryParameters: {'status': 'open'},
              ),
            ),
            AssistantAction(
              id: 'cases-hearings',
              type: AssistantActionType.openSystemModule,
              labelAr: 'الجلسات القادمة',
              labelEn: 'Upcoming hearings',
              icon: Icons.event_note_rounded,
              route: _contextualRoute(
                AppRoutes.adminCases,
                context: context,
                queryParameters: {'tab': 'hearings', 'status': 'upcoming'},
              ),
            ),
            AssistantAction(
              id: 'cases-related',
              type: AssistantActionType.openRelatedCases,
              labelAr: context.hasAssetContext
                  ? 'القضايا المرتبطة بالأصل الحالي'
                  : 'القضايا المرتبطة بالأصل',
              labelEn: context.hasAssetContext
                  ? 'Cases for current asset'
                  : 'Related asset cases',
              icon: Icons.account_tree_rounded,
              route: _contextualRoute(
                AppRoutes.adminCases,
                context: context,
                queryParameters: {'linkedAsset': 'true'},
              ),
              messageAr: context.hasAssetContext
                  ? 'اعرض قضايا الأصل الوقفي الحالي'
                  : 'اعرض القضايا المرتبطة بالأصل الوقفي',
              messageEn: context.hasAssetContext
                  ? 'Show cases for the current waqf asset'
                  : 'Show cases related to the waqf asset',
            ),
          ],
          priorities: <String, List<String>>{
            'hearing': const ['cases-hearings', 'cases-open', 'cases-related'],
            'session': const ['cases-hearings', 'cases-open', 'cases-related'],
          },
        );
      case 'billing_system':
        return _orderForRoute(
          context.currentRoute,
          <AssistantAction>[
            AssistantAction(
              id: 'billing-contracts',
              type: AssistantActionType.openSystemModule,
              labelAr: context.hasAssetContext ? 'عقود الأصل الحالي' : 'العقود',
              labelEn: context.hasAssetContext
                  ? 'Contracts for current asset'
                  : 'Contracts',
              icon: Icons.description_rounded,
              route: _contextualRoute(
                AppRoutes.billing,
                context: context,
                queryParameters: {'tab': 'contracts'},
              ),
            ),
            AssistantAction(
              id: 'billing-invoices',
              type: AssistantActionType.openInvoices,
              labelAr: context.hasAssetContext
                  ? 'فواتير الأصل الحالي'
                  : 'الفواتير المتأخرة',
              labelEn: context.hasAssetContext
                  ? 'Invoices for current asset'
                  : 'Overdue invoices',
              icon: Icons.receipt_long_rounded,
              route: _contextualRoute(
                AppRoutes.billing,
                context: context,
                queryParameters: {
                  'filter': context.hasAssetContext
                      ? 'asset-current'
                      : 'overdue',
                },
              ),
            ),
            AssistantAction(
              id: 'billing-collections',
              type: AssistantActionType.openPendingItems,
              labelAr: context.hasUnitContext
                  ? 'تحصيل الوحدة الحالية'
                  : 'التحصيل',
              labelEn: context.hasUnitContext
                  ? 'Collections for current unit'
                  : 'Collections',
              icon: Icons.payments_rounded,
              route: _contextualRoute(
                AppRoutes.billing,
                context: context,
                queryParameters: {'tab': 'collections'},
              ),
            ),
          ],
          priorities: <String, List<String>>{
            'invoice': const [
              'billing-invoices',
              'billing-collections',
              'billing-contracts',
            ],
            'arrear': const [
              'billing-invoices',
              'billing-collections',
              'billing-contracts',
            ],
          },
        );
      case 'tasks_system':
        return _orderForRoute(
          context.currentRoute,
          <AssistantAction>[
            AssistantAction(
              id: 'tasks-today',
              type: AssistantActionType.openTasks,
              labelAr: context.hasUnitContext
                  ? 'مهام اليوم للوحدة الحالية'
                  : 'مهامي اليوم',
              labelEn: context.hasUnitContext
                  ? 'Today tasks for current unit'
                  : 'My tasks today',
              icon: Icons.today_rounded,
              route: _contextualRoute(
                AppRoutes.tasks,
                context: context,
                queryParameters: {'filter': 'today'},
              ),
            ),
            AssistantAction(
              id: 'tasks-overdue',
              type: AssistantActionType.openPendingItems,
              labelAr: 'المتأخرات',
              labelEn: 'Overdue tasks',
              icon: Icons.alarm_rounded,
              route: _contextualRoute(
                AppRoutes.tasks,
                context: context,
                queryParameters: {'filter': 'overdue'},
              ),
            ),
            AssistantAction(
              id: 'tasks-asset-linked',
              type: AssistantActionType.openTasks,
              labelAr: context.hasAssetContext
                  ? 'مهام الأصل الحالي'
                  : 'المهام المرتبطة بأصل',
              labelEn: context.hasAssetContext
                  ? 'Tasks for current asset'
                  : 'Asset-linked tasks',
              icon: Icons.place_rounded,
              route: _contextualRoute(
                AppRoutes.tasks,
                context: context,
                queryParameters: {'filter': 'linked-waqf-asset'},
              ),
            ),
          ],
          priorities: <String, List<String>>{
            'overdue': const [
              'tasks-overdue',
              'tasks-today',
              'tasks-asset-linked',
            ],
            'today': const [
              'tasks-today',
              'tasks-overdue',
              'tasks-asset-linked',
            ],
          },
        );
      case 'awqaf_system':
      default:
        final canManageHome = _hasAnyPermission(context, const [
          'manageHome',
          'manageSite',
        ]);
        final canManageUsers = _hasAnyPermission(context, const [
          'manageUsers',
        ]);
        final base = <AssistantAction>[
          AssistantAction(
            id: 'awqaf-endowments',
            type: AssistantActionType.openSystemModule,
            labelAr: context.hasAssetContext
                ? 'فتح الأصل الوقفي الحالي'
                : 'فتح الأوقاف',
            labelEn: context.hasAssetContext
                ? 'Open current waqf asset'
                : 'Open endowments',
            icon: Icons.account_balance_rounded,
            route: _contextualRoute(
              AppRoutes.adminDashboard,
              context: context,
              queryParameters: {
                'focus': context.hasAssetContext ? 'waqf_asset' : 'endowments',
              },
            ),
          ),
          AssistantAction(
            id: 'awqaf-endowers',
            type: AssistantActionType.openSystemModule,
            labelAr: 'مراجعة الواقفين',
            labelEn: 'Review endowers',
            icon: Icons.people_alt_rounded,
            route: _contextualRoute(
              AppRoutes.adminDashboard,
              context: context,
              queryParameters: {'focus': 'endowers'},
            ),
            messageAr: 'مراجعة الواقفين',
            messageEn: 'Review endowers',
          ),
          AssistantAction(
            id: 'awqaf-geography',
            type: AssistantActionType.openSystemModule,
            labelAr: context.hasUnitContext
                ? 'جغرافيا الوحدة الحالية'
                : 'متابعة الجغرافيا السيادية',
            labelEn: context.hasUnitContext
                ? 'Geography for current unit'
                : 'Reference geography',
            icon: Icons.public_rounded,
            route: _contextualRoute(
              AppRoutes.adminOrgUnits,
              context: context,
              queryParameters: {'view': 'reference-geography'},
              includeAsset: false,
            ),
          ),
          if (canManageHome)
            AssistantAction(
              id: 'awqaf-unit-pages',
              type: AssistantActionType.openSystemModule,
              labelAr: context.hasUnitContext
                  ? 'فتح صفحة الوحدة الحالية'
                  : 'فتح unit_pages',
              labelEn: context.hasUnitContext
                  ? 'Open current unit page'
                  : 'Open unit pages',
              icon: Icons.web_rounded,
              route: _contextualRoute(
                AppRoutes.adminHomeManagement,
                context: context,
                queryParameters: {'tab': 'unit_pages'},
                includeAsset: false,
              ),
            ),
          if (canManageUsers)
            AssistantAction(
              id: 'awqaf-users',
              type: AssistantActionType.openSystemModule,
              labelAr: 'إدارة المستخدمين',
              labelEn: 'Manage users',
              icon: Icons.manage_accounts_rounded,
              route: _contextualRoute(
                AppRoutes.adminUsers,
                context: context,
                queryParameters: {'tab': 'roles'},
                includeUnit: false,
                includeAsset: false,
              ),
            ),
        ];
        return _orderForRoute(
          context.currentRoute,
          base,
          priorities: <String, List<String>>{
            'home-management': const [
              'awqaf-unit-pages',
              'awqaf-geography',
              'awqaf-endowments',
            ],
            'org-units': const [
              'awqaf-geography',
              'awqaf-unit-pages',
              'awqaf-endowments',
            ],
            'users': const [
              'awqaf-users',
              'awqaf-endowments',
              'awqaf-geography',
            ],
          },
        );
    }
  }

  bool _hasAnyPermission(AssistantContext context, List<String> keys) {
    if (context.permissions.isEmpty) return true;
    return context.permissions.any((permission) => keys.contains(permission));
  }

  List<AssistantAction> _orderForRoute(
    String currentRoute,
    List<AssistantAction> actions, {
    required Map<String, List<String>> priorities,
  }) {
    final lower = currentRoute.toLowerCase();
    for (final entry in priorities.entries) {
      if (!lower.contains(entry.key)) continue;
      final priorityIds = entry.value;
      final ordered = <AssistantAction>[];
      for (final id in priorityIds) {
        final match = actions.where((action) => action.id == id);
        ordered.addAll(match);
      }
      for (final action in actions) {
        if (!ordered.any((item) => item.id == action.id)) {
          ordered.add(action);
        }
      }
      return ordered;
    }
    return actions;
  }

  String _contextualRoute(
    String path, {
    required AssistantContext context,
    required Map<String, String> queryParameters,
    bool includeUnit = true,
    bool includeAsset = true,
  }) {
    final params = <String, String>{...queryParameters};
    if (includeUnit) {
      final unitValue = (context.unitSlug ?? context.unitId ?? '').trim();
      if (unitValue.isNotEmpty) params['unit'] = unitValue;
    }
    if (includeAsset) {
      final assetId = (context.waqfAssetId ?? '').trim();
      final nationalCode = (context.nationalAssetCode ?? '').trim();
      if (assetId.isNotEmpty) {
        params['waqf_asset_id'] = assetId;
      } else if (nationalCode.isNotEmpty) {
        params['national_asset_code'] = nationalCode;
      }
    }
    return Uri(
      path: path,
      queryParameters: params.isEmpty ? null : params,
    ).toString();
  }
}
