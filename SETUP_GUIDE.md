# 🔧 SETUP GUIDE — Clash Of Warriors (iOS)

## Paso 1: Crear proyecto Flutter

```bash
flutter create clash_of_styles --org com.clashofwarriors --platforms ios
cd clash_of_styles
```

> **Nota**: El bundle ID en Firebase es `com.clashofwarriors`, así que usá
> `--org com` y después renombrá. O más fácil: creá el proyecto y después
> cambiá el bundle ID en Xcode a `com.clashofwarriors`.


## Paso 2: Copiar archivos del proyecto

```bash
# Copiar toda la carpeta lib/ (reemplaza la existente)
cp -r arena_project/lib/ clash_of_styles/lib/

# Copiar l10n
cp -r arena_project/l10n/ clash_of_styles/l10n/
cp arena_project/l10n.yaml clash_of_styles/

# Copiar assets
cp -r arena_project/assets/ clash_of_styles/assets/

# Copiar GoogleService-Info.plist
cp arena_project/ios/Runner/GoogleService-Info.plist \
   clash_of_styles/ios/Runner/GoogleService-Info.plist
```


## Paso 3: pubspec.yaml

Reemplazar la sección `dependencies` y agregar `assets`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: any

  # State management
  flutter_riverpod: ^2.6.1

  # Firebase
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.4
  cloud_firestore: ^5.6.0
  firebase_analytics: ^11.3.7

  # Auth providers
  google_sign_in: ^6.2.2
  sign_in_with_apple: ^6.1.4

  # Ads
  google_mobile_ads: ^5.2.0

  # Audio
  audioplayers: ^6.1.0

  # Local storage
  shared_preferences: ^2.3.4

flutter:
  generate: true   # <-- Para l10n
  assets:
    - assets/images/heroes/
    - assets/sounds/
    - assets/fonts/
```


## Paso 4: Info.plist (iOS)

Abrí `ios/Runner/Info.plist` y agregá DENTRO del `<dict>` principal:

```xml
<!-- AdMob App ID -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-9552343552775183~1356877916</string>

<!-- App Tracking (iOS 14+) -->
<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads to you.</string>

<!-- SKAdNetwork (requerido por AdMob) -->
<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cstr6suwn9.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>4fzdc2evr5.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>2fnua5tdw4.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>ydx93a7ass.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>5a6flpkh64.skadnetwork</string>
  </dict>
</array>

<!-- Google Sign-In URL Scheme -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.289945463663-vh5fjuge5ne1qanfbuv2o4a58bnd8adj</string>
    </array>
  </dict>
</array>
```


## Paso 5: Podfile (iOS)

En `ios/Podfile`, asegurate de tener:

```ruby
platform :ios, '14.0'

# Después del target 'Runner':
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    end
  end
end
```


## Paso 6: Instalar dependencias

```bash
flutter pub get
cd ios && pod install && cd ..
flutter gen-l10n
```


## Paso 7: Verificar en Xcode

1. Abrí `ios/Runner.xcworkspace` en Xcode
2. Verificá que `GoogleService-Info.plist` está en el target Runner
3. Bundle Identifier = `com.clashofwarriors`
4. Signing: tu Apple Developer account
5. Deployment Target: 14.0


## Paso 8: Firestore Rules (en Firebase Console)

Andá a Firestore → Rules y pegá:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users: solo el dueño lee/escribe su doc
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    // Leaderboard: todos leen, solo el dueño escribe
    match /leaderboard/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```


## Paso 9: Habilitar Analytics en Firebase Console

1. Firebase Console → Analytics → Enable
2. Firebase Console → Firestore → Create database → production mode
3. Verificar que Auth providers estén habilitados:
   - Email/Password ✅
   - Google ✅
   - Apple ✅
   - Anonymous ✅ (habilitalo también, es para el modo guest)


## Paso 10: Run

```bash
flutter run --debug
```


## Checklist final

- [ ] `GoogleService-Info.plist` en `ios/Runner/`
- [ ] Bundle ID = `com.clashofwarriors` en Xcode
- [ ] `GADApplicationIdentifier` en Info.plist
- [ ] `CFBundleURLSchemes` con el reversed client ID
- [ ] SKAdNetwork items en Info.plist
- [ ] Anonymous auth habilitado en Firebase Console
- [ ] Firestore database creada
- [ ] Firestore rules aplicadas
- [ ] `flutter gen-l10n` ejecutado
- [ ] Rewarded Ad Unit ID pegado en `admob_config.dart`
- [ ] `useTestAds = true` en `admob_config.dart` (hasta que esté en producción)
