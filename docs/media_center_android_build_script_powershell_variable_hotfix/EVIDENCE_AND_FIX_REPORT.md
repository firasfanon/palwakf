
# Media Center Android Build Script PowerShell Variable Hotfix

## Evidence

PowerShell failed before running the build:

```text
Variable reference is not valid. ':' was not followed by a valid variable name character.
```

The invalid line was caused by:

```powershell
$LASTEXITCODE:
```

inside a double-quoted string.

## Fix

Changed it to:

```powershell
$($LASTEXITCODE):
```

## Changed file

```text
scripts/build_media_center_android_debug.ps1
```

## Scope

```text
no SQL
no Android Gradle change
no public base tables
no service_role
no production approval
```

## Retest

```powershell
.\scripts\build_media_center_android_debug.ps1
```
