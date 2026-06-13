
# Hotfix بوابة توفر جهاز Android

## المشكلة

`adb` أصبح معروفًا، لكن لا يوجد جهاز أو Emulator متصل:

```text
adb.exe: no devices/emulators found
```

## التصحيح

تم تعديل سكربت UAT ليعمل كبوابة واضحة:

```text
1. يفحص الأجهزة قبل install.
2. يعرض تعليمات تشغيل Emulator أو توصيل هاتف.
3. يدعم تشغيل Emulator بالاسم.
4. يدعم اختيار جهاز عند وجود أكثر من جهاز.
```

## أوامر مفيدة

عرض الأجهزة والـ emulators:

```powershell
.\scripts\list_android_devices_and_emulators.ps1
```

تشغيل UAT مع Emulator باسم محدد:

```powershell
.\scripts\uat_media_center_android_runtime.ps1 -SkipBuild -EmulatorName <AVD_NAME>
```

تشغيل UAT مع هاتف/جهاز محدد:

```powershell
.\scripts\uat_media_center_android_runtime.ps1 -SkipBuild -DeviceSerial <serial>
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
