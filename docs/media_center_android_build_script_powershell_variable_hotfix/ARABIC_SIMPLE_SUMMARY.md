
# Hotfix سكربت Android PowerShell

## المشكلة

السكربت توقف قبل البناء بسبب صياغة PowerShell:

```powershell
$LASTEXITCODE:
```

## التصحيح

تم استبدالها بـ:

```powershell
$($LASTEXITCODE):
```

## الملف المعدل

```text
scripts/build_media_center_android_debug.ps1
```

## لا يوجد

```text
لا SQL
لا تعديل Gradle جديد
لا public base tables
لا service_role
لا production approval
```
