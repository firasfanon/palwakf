
# Hotfix العثور على adb في Windows

## المشكلة

سكريبت UAT توقف عند:

```text
adb.exe was not found
```

مع أن Android SDK غالبًا موجود محليًا، لكن `ANDROID_HOME` أو `ANDROID_SDK_ROOT` أو `PATH` غير مضبوطة.

## التصحيح

تم تعديل:

```text
scripts/uat_media_center_android_runtime.ps1
```

ليبحث تلقائيًا في:

```text
ANDROID_HOME
ANDROID_SDK_ROOT
%LOCALAPPDATA%\Android\Sdk\platform-tools
%USERPROFILE%\AppData\Local\Android\Sdk\platform-tools
PATH
```

## دعم إضافي

أضيف خيار اختيار جهاز محدد:

```powershell
-DeviceSerial <serial>
```

## لا يوجد

```text
لا SQL
لا Flutter change
لا Android build change
لا media_center mutation
لا public mutation
لا service_role
لا production approval
```
