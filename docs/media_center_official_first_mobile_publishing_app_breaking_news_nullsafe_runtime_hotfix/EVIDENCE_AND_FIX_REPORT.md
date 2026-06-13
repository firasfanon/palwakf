
# BreakingNewsSlider Null-safe Runtime Hotfix

## Evidence Intake

The latest runtime log showed that the app launched, Supabase initialized, and then the home page failed while building `BreakingNewsSlider`.

Error:

```text
Unexpected null value.
The relevant error-causing widget was:
BreakingNewsSlider
package:waqf/presentation/widgets/home/breaking_news_slider.dart 89:48
```

## Root Cause

`BreakingNewsSlider` used:

```dart
final settings = settingsState.settings!;
```

while `settingsState.settings` can still be null during initial provider loading. The previous guard only checked:

```dart
settingsState.settings?.enabled == false
```

which does not protect against null before the later forced null-check.

## Fix

Use default safe settings when the provider has not loaded yet:

```dart
final settings =
    settingsState.settings ?? const BreakingNewsSectionSettings();

if (items.isEmpty || !settings.enabled) {
  return const SizedBox.shrink();
}
```

## Changed File

```text
lib/presentation/widgets/home/breaking_news_slider.dart
```

## Scope Boundary

```text
no SQL changes
no public base tables
no service_role
no RLS mutation
no storage mutation
no production approval
```

## Accepted Evidence Before This Hotfix

```text
flutter analyze = No issues found
cms payload tests = All tests passed
SQL mobile publishing workflow = applied
public API edge counts = news 93, announcements 90, activities 93
Chrome runtime = launched but failed on BreakingNewsSlider null-check
```
