# 🧪 Průvodce testováním World Traveler Stone

## Příprava

### 1. Nainstalujte Flutter
```bash
# Stáhněte Flutter z https://flutter.dev
# Nebo pomocí brew (macOS):
brew install flutter

# Ověřte instalaci:
flutter doctor
```

### 2. Naklonujte projekt
```bash
cd world_traveler_stone
flutter pub get
```

---

## MOŽNOST A: Testování BEZ Firebase (Mock mode)

Pro rychlé testování UI a základních funkcí bez Firebase:

### Krok 1: Vytvořte mock Firebase konfiguraci

Vytvořte soubor `lib/services/mock_auth_service.dart`:

```dart
// Jednoduchý mock pro testování bez Firebase
class MockAuthService {
  Stream<MockUser?> get authStateChanges => Stream.value(MockUser('test-id', 'test@test.com'));
  MockUser? get currentUser => MockUser('test-id', 'test@test.com');

  Future<void> signIn({required String email, required String password}) async {
    await Future.delayed(Duration(seconds: 1));
  }

  Future<void> signUp({required String email, required String password, required String name}) async {
    await Future.delayed(Duration(seconds: 1));
  }

  Future<void> signOut() async {
    await Future.delayed(Duration(milliseconds: 500));
  }
}

class MockUser {
  final String uid;
  final String email;
  MockUser(this.uid, this.email);
}
```

### Krok 2: Upravte main.dart

Zakomentujte Firebase inicializaci a NotificationService:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Zakomentováno pro testování bez Firebase:
  // await Firebase.initializeApp();
  // await NotificationService().init();

  runApp(const MyApp());
}
```

### Krok 3: Spusťte aplikaci

```bash
# Pro Android
flutter run

# Pro iOS
flutter run -d ios

# Pro web (nejjednodušší pro testování)
flutter run -d chrome
```

### Co můžete testovat v mock módu:
- ✅ UI všech obrazovek
- ✅ Navigaci mezi obrazovkami
- ✅ Layout a design
- ✅ Základní workflow
- ❌ Skutečné přihlášení (pouze simulace)
- ❌ Ukládání dat
- ❌ Mapy (potřebují API klíč)

---

## MOŽNOST B: Testování S Firebase (plná funkcionalita)

### Krok 1: Vytvořte Firebase projekt

1. Jděte na https://console.firebase.google.com
2. Klikněte na "Add project"
3. Pojmenujte projekt (např. "world-traveler-stone-test")
4. Povolte Google Analytics (volitelné)
5. Vytvořte projekt

### Krok 2: Přidejte Android aplikaci

1. V Firebase Console klikněte na Android ikonu
2. Package name: `com.example.world_traveler_stone`
3. Stáhněte `google-services.json`
4. Umístěte ho do `android/app/`

### Krok 3: Přidejte iOS aplikaci (volitelné)

1. V Firebase Console klikněte na iOS ikonu
2. Bundle ID: `com.example.worldTravelerStone`
3. Stáhněte `GoogleService-Info.plist`
4. Umístěte ho do `ios/Runner/`

### Krok 4: Povolte Firebase služby

V Firebase Console povolte:
- **Authentication** → Sign-in method → Email/Password
- **Firestore Database** → Create database (test mode)
- **Storage** → Get started (test mode)
- **Cloud Messaging** → (automaticky povoleno)

### Krok 5: Konfigurace Firebase v aplikaci

```bash
# Nainstalujte FlutterFire CLI
dart pub global activate flutterfire_cli

# Vygenerujte konfiguraci
flutterfire configure
```

### Krok 6: Aktivujte Firebase v main.dart

Odkomentujte:
```dart
await Firebase.initializeApp();
```

### Krok 7: Google Maps API klíč

1. Jděte na https://console.cloud.google.com
2. Povolte Maps SDK for Android/iOS
3. Vytvořte API klíč

#### Android - `android/app/src/main/AndroidManifest.xml`:
```xml
<application>
  <meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="VÁŠ_API_KLÍČ_ZDE"/>
</application>
```

#### iOS - `ios/Runner/AppDelegate.swift`:
```swift
import GoogleMaps

GMSServices.provideAPIKey("VÁŠ_API_KLÍČ_ZDE")
```

### Krok 8: Spusťte aplikaci

```bash
flutter run
```

---

## 🧪 TESTOVACÍ SCÉNÁŘE

### Test 1: Registrace a přihlášení ✅
1. Spusťte aplikaci
2. Klikněte na "Registrujte se"
3. Vyplňte:
   - Jméno: Test User
   - Email: test@example.com
   - Heslo: test123
   - Potvrzení hesla: test123
4. Zaškrtněte GDPR
5. Klikněte "Registrovat se"
6. **Očekávaný výsledek**: Přesměrování na HomeScreen

### Test 2: Vytvoření kamene ✅
```dart
// V Firebase Console → Firestore → Add collection:
Collection: stones
Document ID: (auto)
Fields:
  - id: "test-stone-1"
  - qrCode: "wts://stone/test-stone-1"
  - currentLocation: {latitude: 50.0755, longitude: 14.4378}
  - currentOwnerId: "váš-user-id"
  - previousOwners: ["váš-user-id"]
  - history: []
  - createdAt: (timestamp)
  - isLost: false
```

### Test 3: QR kód skenování ✅
1. Vygenerujte QR kód z textu: `wts://stone/test-stone-1`
   - Použijte https://www.qr-code-generator.com
2. V aplikaci klikněte na FAB (QR scanner icon)
3. Naskenujte QR kód
4. **Očekávaný výsledek**: Zobrazení detailu kamene

### Test 4: Mapa ✅
1. Přejděte na tab "Mapa"
2. Počkejte na načtení markerů
3. Klikněte na marker
4. **Očekávaný výsledek**: Bottom sheet s informacemi o kameni

### Test 5: Přemístění kamene ✅
1. Otevřete detail kamene
2. Klikněte "Přemístit kámen"
3. Klikněte "Získat moji polohu"
4. Povolte GPS přístup
5. Napište příběh (volitelné)
6. Přidejte fotku (volitelné)
7. Klikněte "Potvrdit přemístění"
8. **Očekávaný výsledek**:
   - Úspěšné přemístění
   - Získání 100 💎
   - Možné bonusy za příběh/fotku/mezinárodní přesun

### Test 6: Profil a diamanty ✅
1. Přejděte na tab "Profil"
2. **Očekávaný výsledek**: Zobrazení počtu diamantů

---

## 🐛 DEBUGGING

### Časté problémy a řešení

#### 1. "Firebase not initialized"
```dart
// Zkontrolujte main.dart:
await Firebase.initializeApp();
```

#### 2. "No Firebase options file found"
```bash
# Spusťte:
flutterfire configure
```

#### 3. "Google Maps not showing"
- Zkontrolujte API klíč v AndroidManifest.xml
- Povolte Maps SDK v Google Cloud Console

#### 4. "GPS permission denied"
- Povolte location permissions v nastavení telefonu

#### 5. "Camera not working"
- Povolte camera permissions
- Zkontrolujte AndroidManifest.xml / Info.plist

### Zobrazení logů

```bash
# Real-time logs
flutter logs

# Verbose mode
flutter run -v
```

### Debug mode

```bash
# Build v debug módu
flutter build apk --debug

# Profiling
flutter run --profile
```

---

## 📊 TESTOVACÍ CHECKLIST

### Základní funkce:
- [ ] Registrace nového uživatele
- [ ] Přihlášení existujícího uživatele
- [ ] Odhlášení

### QR systém:
- [ ] Skenování QR kódu
- [ ] Zobrazení detailu kamene
- [ ] Zobrazení historie kamene

### GPS a lokalizace:
- [ ] Získání aktuální polohy
- [ ] Zobrazení adresy
- [ ] Validace minimální vzdálenosti (5km)
- [ ] Validace časového intervalu (24h)

### Mapa:
- [ ] Zobrazení markerů
- [ ] Kliknutí na marker
- [ ] Filtrace kamenů
- [ ] Zobrazení polyline trasy
- [ ] Centrace na uživatele

### Přemístění:
- [ ] Získání GPS polohy
- [ ] Přidání příběhu
- [ ] Přidání fotky
- [ ] Úspěšné přemístění
- [ ] Získání diamantů

### Diamanty:
- [ ] Zobrazení balancu
- [ ] Přidělení za přemístění
- [ ] Bonus za mezinárodní přesun
- [ ] Bonus za příběh s fotkou

### Profil:
- [ ] Zobrazení informací
- [ ] Zobrazení diamantů
- [ ] Odhlášení

---

## 🚀 TESTOVÁNÍ NA SKUTEČNÝCH ZAŘÍZENÍCH

### Android

```bash
# Připojte Android telefon přes USB
# Povolte Developer Options a USB Debugging

# Zkontrolujte připojení:
flutter devices

# Spusťte na zařízení:
flutter run
```

### iOS (pouze macOS)

```bash
# Připojte iPhone
flutter devices
flutter run
```

### Testování na emulátoru

```bash
# Android
flutter emulators
flutter emulators --launch <emulator_id>
flutter run

# iOS (pouze macOS)
open -a Simulator
flutter run
```

---

## 📝 TESTOVACÍ DATA

### Testovací uživatelé:
```
Email: test1@example.com
Heslo: test123

Email: test2@example.com
Heslo: test123
```

### Testovací kameny v Praze:
```javascript
// Firestore collection: stones
{
  id: "stone-prague-1",
  qrCode: "wts://stone/stone-prague-1",
  currentLocation: new GeoPoint(50.0755, 14.4378), // Praha
  currentOwnerId: "test-user-1",
  previousOwners: ["test-user-1"],
  history: [
    {
      location: new GeoPoint(50.0755, 14.4378),
      ownerId: "test-user-1",
      timestamp: new Date(),
      story: "První kámen v Praze!",
      photoUrl: null
    }
  ],
  createdAt: new Date(),
  isLost: false
}
```

### Testovací kameny v jiných městech:
- Londýn: `51.5074, -0.1278`
- New York: `40.7128, -74.0060`
- Tokio: `35.6762, 139.6503`

---

## ✅ HOTOVO!

Po dokončení všech testů by aplikace měla být plně funkční a připravená k nasazení!

Pro otázky nebo problémy vytvořte issue na GitHubu.
