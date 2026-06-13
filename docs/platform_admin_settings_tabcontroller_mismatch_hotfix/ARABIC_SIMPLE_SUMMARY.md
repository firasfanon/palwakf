# Platform Admin Settings — TabController Mismatch Hotfix

## الدليل الحالي

في `/admin/platform/technical-services` ظهر أن:

```text
rpc_platform_technical_services_dashboard_v1
Status 200
```

وهذا يعني أن Backend/RPC يعمل.

لكن Console أظهر:

```text
Controller's length property (8) does not match the number of children (9) present in TabBarView's children property
```

## السبب

`SettingsScreen` كان يستخدم:

```dart
DefaultTabController(length: AdminPanelRegistry.tabs.length)
```

بينما `TabBarView` يعرض:

```dart
AdminPanelRegistry.orderedGroups
```

عدد `tabs` = 8  
عدد `orderedGroups` = 9

لذلك حدث mismatch.

## التصحيح

تم جعل `SettingsScreen` يبني التبويبات من نفس مصدر `orderedGroups`:

- `DefaultTabController.length = groups.length`
- `TabBar.tabs = groups.map(_tabForGroup)`
- `TabBarView.children = groups.map(_GatewayTab)`

مع fallback تلقائي لأي group لا يملك tab entry صريح.

## ما لم يتغير

- لا SQL.
- لا RLS.
- لا service_role.
- لا تغيير في RPC.
- لا تغيير في مسارات الخدمات التقنية.
