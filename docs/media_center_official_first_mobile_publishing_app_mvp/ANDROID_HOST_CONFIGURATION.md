
# Android Host Configuration

## Updated

```text
android/app/src/main/AndroidManifest.xml
android/app/src/main/res/values/strings.xml
```

## Added permissions

```text
INTERNET
CAMERA
READ_MEDIA_IMAGES
READ_EXTERNAL_STORAGE for SDK <= 32
```

## App label

```text
PalWakf Media
```

## Deep link

```text
palwakf://official-media
```

This is a host-level placeholder for future mobile deep linking.  
The official public link remains the web route:

```text
/official/media/:family/:id
```
