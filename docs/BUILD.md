# Android build

Recommended: Flutter stable (3.47+), JDK 17, Android SDK.

The Flutter-generated platform wrapper artifacts are not committed. One time after cloning:
```sh
flutter create --platforms=android --project-name golyapooch --org com.mahdi .
flutter pub get
flutter test
flutter analyze
flutter run
```

GitHub Actions uses the same platform bootstrap before building an APK.
The checked-in Android release config signs with the *debug* key for local use only. A proper signing key is required for Play/Bazaar releases.
