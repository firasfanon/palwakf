
# Android Runtime UAT Device Availability Gate Hotfix

## Evidence

The UAT script found `adb.exe`, then failed during install:

```text
adb.exe: no devices/emulators found
```

## Root Cause

`adb` is available, but no Android device or emulator is currently in `device` state.

This is not an APK, Flutter, SQL, or Supabase issue. It is a UAT environment/device availability gate.

## Fix

Updated:

```text
scripts/uat_media_center_android_runtime.ps1
```

New behavior:

```text
1. Resolve adb.
2. Resolve emulator.
3. List adb devices.
4. Stop before install if no ready device exists.
5. Print device/emulator setup instructions.
6. Support -EmulatorName <AVD_NAME>.
7. Support -DeviceSerial <serial>.
8. Support -ListOnly.
```

Added helper script:

```text
scripts/list_android_devices_and_emulators.ps1
```

## Retest Options

List devices and emulators:

```powershell
.\scripts\list_android_devices_and_emulators.ps1
```

Run UAT after opening an emulator/device manually:

```powershell
.\scripts\uat_media_center_android_runtime.ps1 -SkipBuild
```

Start emulator by name and run UAT:

```powershell
.\scripts\uat_media_center_android_runtime.ps1 -SkipBuild -EmulatorName <AVD_NAME>
```

Run against a specific device:

```powershell
.\scripts\uat_media_center_android_runtime.ps1 -SkipBuild -DeviceSerial <serial>
```

## Boundaries

```text
no SQL
no Flutter change
no Android build change
no media_center mutation
no public mutation
no public base tables
no service_role
no production approval
```
