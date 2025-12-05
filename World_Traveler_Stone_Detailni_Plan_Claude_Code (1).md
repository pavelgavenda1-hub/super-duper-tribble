# 🗺️ Detailní plán pro Claude Code - World Traveler Stone

## 📌 O tomto plánu
Tento plán rozděluje celý vývoj aplikace na velmi malé, zvládnutelné kroky pro Claude Code. Každý krok je nezávislý a má jasné vstupy/výstupy.

---

## 🎯 FÁZE 0: Přípravné kroky (Foundation)

### Krok 0.1: Vytvoření základní projektové struktury
**Co udělat:** Vytvořit Flutter projekt a základní adresářovou strukturu
```bash
flutter create world_traveler_stone
cd world_traveler_stone
```
**Výstup:** Fungující prázdná Flutter aplikace

### Krok 0.2: Nastavení Git repositáře
**Co udělat:** Inicializovat git a vytvořit .gitignore
```bash
git init
git add .
git commit -m "Initial commit"
```
**Výstup:** Git repositář připravený k práci

### Krok 0.3: Vytvoření základních složek
**Co udělat:** Vytvořit adresářovou strukturu projektu
```
lib/
  ├── models/          # Datové modely
  ├── services/        # API, Firebase, GPS služby
  ├── screens/         # Obrazovky aplikace
  ├── widgets/         # Znovupoužitelné komponenty
  ├── utils/           # Pomocné funkce
  └── config/          # Konfigurace (API klíče, konstanty)
```
**Výstup:** Připravená struktura pro vývoj

### Krok 0.4: Přidání základních závislostí do pubspec.yaml
**Co udělat:** Přidat první sadu balíčků
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
```
**Výstup:** Základní dependencies nainstalované

---

## 🎯 FÁZE 1: Autentizace a registrace

### Krok 1.1: Vytvoření User modelu
**Soubor:** `lib/models/user_model.dart`
**Co vytvořit:**
- Třída UserModel s poli: id, email, name, diamonds
- Metoda toJson()
- Factory metoda fromJson()

**Výstup:** Model pro reprezentaci uživatele

### Krok 1.2: Vytvoření AuthService - základní kostra
**Soubor:** `lib/services/auth_service.dart`
**Co vytvořit:**
- Třída AuthService
- Prázdné metody: signUp(), signIn(), signOut()
- Stream authStateChanges

**Výstup:** Service vrstva pro autentizaci (zatím prázdné metody)

### Krok 1.3: Implementace Firebase Auth - signUp
**Soubor:** `lib/services/auth_service.dart`
**Co implementovat:**
- Vyplnit metodu signUp()
- Použít FirebaseAuth.createUserWithEmailAndPassword()
- Uložit dodatečná data do Firestore

**Výstup:** Funkční registrace

### Krok 1.4: Implementace Firebase Auth - signIn
**Soubor:** `lib/services/auth_service.dart`
**Co implementovat:**
- Vyplnit metodu signIn()
- Použít FirebaseAuth.signInWithEmailAndPassword()

**Výstup:** Funkční přihlášení

### Krok 1.5: Implementace Firebase Auth - signOut
**Soubor:** `lib/services/auth_service.dart`
**Co implementovat:**
- Vyplnit metodu signOut()
- Zavolat FirebaseAuth.signOut()

**Výstup:** Funkční odhlášení

### Krok 1.6: Vytvoření LoginScreen UI
**Soubor:** `lib/screens/auth/login_screen.dart`
**Co vytvořit:**
- StatefulWidget LoginScreen
- TextField pro email
- TextField pro heslo (obscureText: true)
- ElevatedButton "Přihlásit se"
- TextButton "Registrujte se"

**Výstup:** UI obrazovka pro přihlášení (zatím nefunkční)

### Krok 1.7: Propojení LoginScreen s AuthService
**Soubor:** `lib/screens/auth/login_screen.dart`
**Co implementovat:**
- Přidat TextEditingController pro email a heslo
- onPressed pro button zavolá authService.signIn()
- Zobrazit CircularProgressIndicator během operace
- Zobrazit SnackBar s chybou při selhání

**Výstup:** Funkční přihlašovací obrazovka

### Krok 1.8: Vytvoření RegisterScreen UI
**Soubor:** `lib/screens/auth/register_screen.dart`
**Co vytvořit:**
- StatefulWidget RegisterScreen
- TextField pro jméno, email, heslo, potvrzení hesla
- Checkbox pro GDPR souhlas
- ElevatedButton "Registrovat se"

**Výstup:** UI obrazovka pro registraci (zatím nefunkční)

### Krok 1.9: Propojení RegisterScreen s AuthService
**Soubor:** `lib/screens/auth/register_screen.dart`
**Co implementovat:**
- Validace (hesla se shodují, GDPR je zaškrtnutý)
- onPressed zavolá authService.signUp()
- Loading indicator
- Error handling

**Výstup:** Funkční registrační obrazovka

### Krok 1.10: Vytvoření AuthWrapper
**Soubor:** `lib/screens/auth/auth_wrapper.dart`
**Co vytvořit:**
- StreamBuilder poslouchající authStateChanges
- Když user != null → HomeScreen
- Když user == null → LoginScreen

**Výstup:** Automatické přepínání mezi auth/main obrazovkami

---

## 🎯 FÁZE 2: QR kód systém

### Krok 2.1: Přidání QR závislostí
**Soubor:** `pubspec.yaml`
**Co přidat:**
```yaml
qr_flutter: ^4.1.0
mobile_scanner: ^3.5.2
```
**Výstup:** Závislosti pro práci s QR kódy

### Krok 2.2: Vytvoření Stone modelu
**Soubor:** `lib/models/stone_model.dart`
**Co vytvořit:**
- Třída StoneModel s poli: id, qrCode, currentOwnerId, currentLocation, previousOwners, history, createdAt, isLost
- Třída LocationHistory s poli: location, ownerId, timestamp, story, photoUrl
- Metody toJson() a fromJson()

**Výstup:** Model pro reprezentaci kamene

### Krok 2.3: Vytvoření QRService - základní kostra
**Soubor:** `lib/services/qr_service.dart`
**Co vytvořit:**
- Třída QRService
- Prázdné metody: generateQRCode(), validateQRCode(), scanQRCode()

**Výstup:** Service vrstva pro QR operace

### Krok 2.4: Implementace generateQRCode
**Soubor:** `lib/services/qr_service.dart`
**Co implementovat:**
- Vrátit string ve formátu: "wts://stone/{stoneId}"

**Výstup:** Funkční generování QR kódů

### Krok 2.5: Implementace validateQRCode
**Soubor:** `lib/services/qr_service.dart`
**Co implementovat:**
- Parsovat QR kód
- Načíst kámen z Firestore podle stoneId
- Vrátit StoneModel nebo null

**Výstup:** Validace a načtení kamene z QR kódu

### Krok 2.6: Vytvoření QRScannerScreen UI
**Soubor:** `lib/screens/qr/qr_scanner_screen.dart`
**Co vytvořit:**
- StatefulWidget QRScannerScreen
- MobileScanner widget
- Overlay s rámečkem pro QR
- AppBar s tlačítkem "Zrušit"

**Výstup:** UI pro skenování QR (zatím nefunkční)

### Krok 2.7: Implementace QR skeneru
**Soubor:** `lib/screens/qr/qr_scanner_screen.dart`
**Co implementovat:**
- onDetect callback pro MobileScanner
- Zavolat qrService.validateQRCode()
- Pokud je kámen validní → navigace na StoneDetailScreen

**Výstup:** Funkční skenování QR kódů

### Krok 2.8: Vytvoření StoneDetailScreen UI
**Soubor:** `lib/screens/stone/stone_detail_screen.dart`
**Co vytvořit:**
- StatefulWidget StoneDetailScreen
- Zobrazení ID kamene
- Placeholder pro mapu
- ListView pro historii
- ElevatedButton "Přemístit kámen"

**Výstup:** Základní UI pro detail kamene

### Krok 2.9: Načítání dat kamene do StoneDetailScreen
**Soubor:** `lib/screens/stone/stone_detail_screen.dart`
**Co implementovat:**
- StreamBuilder pro Firestore stream
- Zobrazení reálných dat kamene
- Formátování historie

**Výstup:** Reálná data v detail screenu

---

## 🎯 FÁZE 3: GPS a lokalizace

### Krok 3.1: Přidání GPS závislostí
**Soubor:** `pubspec.yaml`
**Co přidat:**
```yaml
geolocator: ^10.1.0
geocoding: ^2.1.1
permission_handler: ^11.1.0
```
**Výstup:** Závislosti pro GPS

### Krok 3.2: Vytvoření LocationService - základní kostra
**Soubor:** `lib/services/location_service.dart`
**Co vytvořit:**
- Třída LocationService
- Prázdné metody: getCurrentLocation(), requestLocationPermission(), calculateDistance()
- Stream locationStream

**Výstup:** Service vrstva pro GPS

### Krok 3.3: Implementace requestLocationPermission
**Soubor:** `lib/services/location_service.dart`
**Co implementovat:**
- Zkontrolovat permission pomocí Geolocator.checkPermission()
- Pokud není → požádat pomocí Geolocator.requestPermission()
- Vrátit bool zda je povoleno

**Výstup:** Funkční žádání o GPS oprávnění

### Krok 3.4: Implementace getCurrentLocation
**Soubor:** `lib/services/location_service.dart`
**Co implementovat:**
- Zavolat requestLocationPermission()
- Pokud ano → Geolocator.getCurrentPosition()
- Vrátit Position nebo null

**Výstup:** Získání aktuální polohy

### Krok 3.5: Implementace calculateDistance
**Soubor:** `lib/services/location_service.dart`
**Co implementovat:**
- Použít Geolocator.distanceBetween()
- Převést na kilometry (/ 1000)

**Výstup:** Výpočet vzdálenosti mezi body

### Krok 3.6: Vytvoření validační logiky pro přemístění
**Soubor:** `lib/utils/stone_validation_util.dart`
**Co vytvořit:**
- Třída StoneValidationUtil
- Statická metoda validateStoneMove()
- Kontrola minimální vzdálenosti (5 km)
- Kontrola časového intervalu (24 hodin)
- Vrátit ValidationResult

**Výstup:** Kompletní validace přesunu kamene

### Krok 3.7: Vytvoření MoveStoneScreen UI
**Soubor:** `lib/screens/stone/move_stone_screen.dart`
**Co vytvořit:**
- StatefulWidget MoveStoneScreen
- Container s náhledem mapy (placeholder)
- ElevatedButton "Získat moji polohu"
- TextField pro příběh
- ImagePicker widget
- ElevatedButton "Potvrdit přemístění"

**Výstup:** UI pro přemístění kamene

### Krok 3.8: Propojení MoveStoneScreen s LocationService
**Soubor:** `lib/screens/stone/move_stone_screen.dart`
**Co implementovat:**
- onPressed pro "Získat polohu" zavolá locationService.getCurrentLocation()
- Uložit Position do state
- Zobrazit na mapě (placeholder)

**Výstup:** Zobrazení aktuální polohy

### Krok 3.9: Vytvoření StoneService
**Soubor:** `lib/services/stone_service.dart`
**Co vytvořit:**
- Třída StoneService
- Metoda moveStone() s parametry: stoneId, newPosition, story, photoUrl
- Načíst kámen z Firestore
- Validovat pomocí StoneValidationUtil
- Uložit přesun do Firestore
- Vrátit MoveResult

**Výstup:** Funkční přemístění kamene s validací

### Krok 3.10: Vytvoření StorageService pro upload fotek
**Soubor:** `lib/services/storage_service.dart`
**Co vytvořit:**
- Třída StorageService
- Metoda uploadStonePhoto()
- Upload do Firebase Storage
- Vrátit download URL

**Výstup:** Upload fotky do Firebase Storage

---

## 🎯 FÁZE 4: Interaktivní mapa

### Krok 4.1: Přidání mapových závislostí
**Soubor:** `pubspec.yaml`
**Co přidat:**
```yaml
google_maps_flutter: ^2.5.0
```
**Výstup:** Závislosti pro mapy

### Krok 4.2: Vytvoření MapScreen UI - základní
**Soubor:** `lib/screens/map/map_screen.dart`
**Co vytvořit:**
- StatefulWidget MapScreen
- GoogleMap widget
- Inicializace GoogleMapController
- Základní CameraPosition

**Výstup:** Základní mapa bez markerů

### Krok 4.3: Načítání kamenů z Firestore pro mapu
**Soubor:** `lib/screens/map/map_screen.dart`
**Co implementovat:**
- StreamBuilder pro collection 'stones'
- Filtr where('isLost', isEqualTo: false)
- Mapování na List<StoneModel>

**Výstup:** Real-time načítání kamenů

### Krok 4.4: Zobrazení markerů na mapě
**Soubor:** `lib/screens/map/map_screen.dart`
**Co implementovat:**
- Metoda _createMarkers() vrací Set<Marker>
- Pro každý kámen vytvořit Marker
- Různé barvy pro aktivní/ztracené kameny
- onTap callback

**Výstup:** Zobrazení kamenů jako markerů

### Krok 4.5: Bottom sheet při kliknutí na marker
**Soubor:** `lib/widgets/stone_bottom_sheet.dart`
**Co vytvořit:**
- StatelessWidget StoneBottomSheet
- Zobrazení základních info o kameni
- Button "Zobrazit detail"
- Button "Navigovat"

**Výstup:** Interaktivní bottom sheet

### Krok 4.6: Filtrace kamenů - UI tlačítka
**Soubor:** `lib/screens/map/map_screen.dart`
**Co přidat:**
- Enum StoneFilter
- FloatingActionButton s PopupMenuButton
- MenuItem pro každý typ filtru

**Výstup:** UI pro výběr filtru

### Krok 4.7: Filtrace kamenů - implementace logiky
**Soubor:** `lib/screens/map/map_screen.dart`
**Co implementovat:**
- Metoda _getStonesQuery() vrací Query podle filtru
- Switch case pro jednotlivé filtry
- Update StreamBuilder

**Výstup:** Funkční filtrování kamenů

### Krok 4.8: Zobrazení historie trasy kamene - polyline
**Soubor:** `lib/widgets/stone_route_polyline.dart`
**Co vytvořit:**
- Třída StoneRoutePolyline
- Statická metoda createRoutePolyline()
- Z history kamene vytvořit List<LatLng>
- Vrátit Polyline

**Výstup:** Vizualizace trasy kamene

### Krok 4.9: Přidání polyline do mapy
**Soubor:** `lib/screens/map/map_screen.dart`
**Co implementovat:**
- Set<Polyline> _polylines v state
- Po kliknutí na marker přidat polyline
- Update GoogleMap s polylines parametrem

**Výstup:** Zobrazení historie pohybu

### Krok 4.10: Centrace mapy na uživatele
**Soubor:** `lib/screens/map/map_screen.dart`
**Co přidat:**
- FloatingActionButton "Moje poloha"
- onPressed zavolá locationService.getCurrentLocation()
- Použít _mapController.animateCamera()

**Výstup:** Rychlá navigace na aktuální polohu

---

## 🎯 FÁZE 5: Geofencing a notifikace

### Krok 5.1: Přidání závislostí
**Soubor:** `pubspec.yaml`
**Co přidat:**
```yaml
geofence_service: ^5.1.0
flutter_local_notifications: ^16.2.0
firebase_messaging: ^14.7.0
```
**Výstup:** Závislosti pro notifikace

### Krok 5.2: Vytvoření NotificationService
**Soubor:** `lib/services/notification_service.dart`
**Co vytvořit:**
- Třída NotificationService
- Metoda init() - inicializace FlutterLocalNotificationsPlugin
- Metoda showNotification() s parametry title, body, payload

**Výstup:** Základní notification service

### Krok 5.3: Vytvoření GeofenceService
**Soubor:** `lib/services/geofence_service.dart`
**Co vytvořit:**
- Třída GeofenceService
- Metoda addGeofencesForStones()
- Metoda startListening()
- Callback _onGeofenceStatusChanged()
- Při vstupu do geofence zobrazit notifikaci

**Výstup:** Funkční geofencing pro kameny

### Krok 5.4: Propojení geofencingu s MapScreen
**Soubor:** `lib/screens/map/map_screen.dart`
**Co implementovat:**
- V initState() poslouchat stream kamenů
- Zavolat geofenceService.addGeofencesForStones()
- Zavolat geofenceService.startListening()

**Výstup:** Automatické notifikace při blízkosti

### Krok 5.5: Handling kliknutí na notifikaci
**Soubor:** `lib/services/notification_service.dart`
**Co implementovat:**
- onDidReceiveNotificationResponse callback
- Navigace na detail kamene podle payload

**Výstup:** Navigace z notifikace

### Krok 5.6: FCM Service setup
**Soubor:** `lib/services/fcm_service.dart`
**Co vytvořit:**
- Třída FCMService
- Metoda init() - request permission, get token
- Uložit token do Firestore
- Listen na foreground messages
- Handle background messages

**Výstup:** Kompletní FCM service

### Krok 5.7: Notifikace při nálezu kamene
**Soubor:** `lib/services/stone_service.dart`
**Co implementovat:**
- V metodě moveStone() po úspěšném přesunu
- Získat previousOwners kamene
- Pro každého načíst FCM token
- Odeslat notifikaci

**Výstup:** Notifikace pro předchozí majitele

---

## 🎯 FÁZE 6: Bodový systém (Diamanty)

### Krok 6.1: Rozšíření User modelu
**Soubor:** `lib/models/user_model.dart`
**Co přidat:**
- Field diamonds: int
- Field diamondHistory: List<DiamondTransaction>
- Třída DiamondTransaction s poli: amount, reason, timestamp, relatedStoneId

**Výstup:** Rozšířený model pro diamanty

### Krok 6.2: Vytvoření DiamondService
**Soubor:** `lib/services/diamond_service.dart`
**Co vytvořit:**
- Třída DiamondService
- Metoda awardDiamonds() - přičte diamanty a uloží do historie
- Metoda getDiamondsBalance() - vrátí aktuální stav

**Výstup:** Service pro správu diamantů

### Krok 6.3: Diamanty za nalezení kamene
**Soubor:** `lib/services/qr_service.dart`
**Co implementovat:**
- V validateQRCode() po validaci
- Zkontrolovat, jestli už uživatel kámen nenašel
- Pokud ne → awardDiamonds(50, 'Nalezení kamene')

**Výstup:** Automatické přidělení za nalezení

### Krok 6.4: Diamanty za přemístění
**Soubor:** `lib/services/stone_service.dart`
**Co implementovat:**
- V moveStone() po úspěšném přesunu
- awardDiamonds(100, 'Přemístění kamene')

**Výstup:** Diamanty za přesun

### Krok 6.5: Detekce země z GPS
**Soubor:** `lib/services/location_service.dart`
**Co přidat:**
- Metoda getCountryFromLocation()
- Použít placemarkFromCoordinates()
- Vrátit isoCountryCode

**Výstup:** Detekce země z GPS

### Krok 6.6: Diamanty za mezinárodní přesun
**Soubor:** `lib/services/stone_service.dart`
**Co implementovat:**
- V moveStone() získat newCountry a lastCountry
- Pokud se liší → awardDiamonds(300, 'Přesun do jiné země')

**Výstup:** Bonusové diamanty za mezinárodní přesun

### Krok 6.7: Speciální odměna - nový kámen
**Soubor:** `lib/services/stone_service.dart`
**Co vytvořit:**
- Metoda _checkInternationalFind()
- Zkontrolovat poslední 2 přesuny
- Pokud je nová země a >24h → awardDiamonds(500) + _createNewStoneForUser()

**Výstup:** Automatická odměna za mezinárodní nález

### Krok 6.8: Diamanty za sdílení příběhu
**Soubor:** `lib/services/stone_service.dart`
**Co implementovat:**
- V moveStone() pokud story != null && photoUrl != null
- awardDiamonds(50, 'Sdílení příběhu')

**Výstup:** Motivace ke sdílení

### Krok 6.9: Diamanty za nalezení ztraceného kamene
**Soubor:** `lib/services/qr_service.dart`
**Co implementovat:**
- V validateQRCode() pokud stone.isLost
- awardDiamonds(500, 'Nalezení ztraceného kamene')
- Update isLost = false

**Výstup:** Extra odměna za ztracené kameny

### Krok 6.10: Zobrazení diamantů v UI
**Soubor:** `lib/widgets/diamond_display_widget.dart`
**Co vytvořit:**
- StatelessWidget DiamondDisplayWidget
- StreamBuilder na users/{userId}
- Zobrazit Icon + Text s počtem diamantů

**Výstup:** Widget pro zobrazení diamantů

---

## 🎯 FÁZE 7: Statistiky

### Krok 7.1: Vytvoření Statistics modelů
**Soubor:** `lib/models/statistics_model.dart`
**Co vytvořit:**
- Třída StoneStatistics s poli: totalDistance, countriesVisited, totalOwners, atd.
- Třída UserStatistics s poli: stonesFound, stonesMoved, totalDistanceMoved, atd.

**Výstup:** Modely pro statistiky

### Krok 7.2: StatisticsService - kameny
**Soubor:** `lib/services/statistics_service.dart`
**Co vytvořit:**
- Třída StatisticsService
- Metoda calculateStoneStatistics()
- Vypočítat celkovou vzdálenost z history
- Získat seznam navštívených zemí
- Najít nejdelší pobyt

**Výstup:** Výpočet statistik kamene

### Krok 7.3: StatisticsService - uživatelé
**Soubor:** `lib/services/statistics_service.dart`
**Co přidat:**
- Metoda calculateUserStatistics()
- Najít všechny kameny uživatele
- Vypočítat celkové přesuny a vzdálenosti
- Získat navštívené země

**Výstup:** Výpočet statistik uživatele

### Krok 7.4: StoneStatisticsScreen UI
**Soubor:** `lib/screens/statistics/stone_statistics_screen.dart`
**Co vytvořit:**
- StatelessWidget StoneStatisticsScreen
- FutureBuilder s calculateStoneStatistics()
- ListView s kartami statistik

**Výstup:** UI se statistikami kamene

### Krok 7.5: UserStatisticsScreen UI
**Soubor:** `lib/screens/statistics/user_statistics_screen.dart`
**Co vytvořit:**
- StatelessWidget UserStatisticsScreen
- FutureBuilder s calculateUserStatistics()
- ListView s kartami osobních statistik

**Výstup:** UI s osobními statistikami

### Krok 7.6: Leaderboard model
**Soubor:** `lib/models/leaderboard_model.dart`
**Co vytvořit:**
- Třída LeaderboardEntry s poli: userId, userName, value, rank
- Enum LeaderboardType

**Výstup:** Model pro žebříčky

### Krok 7.7: Leaderboard výpočet
**Soubor:** `lib/services/statistics_service.dart`
**Co přidat:**
- Metoda getLeaderboard()
- Načíst všechny uživatele
- Vypočítat hodnoty podle typu
- Seřadit a přiřadit ranky

**Výstup:** Funkční žebříček

### Krok 7.8: LeaderboardScreen UI
**Soubor:** `lib/screens/statistics/leaderboard_screen.dart`
**Co vytvořit:**
- StatefulWidget LeaderboardScreen
- PopupMenuButton pro výběr typu
- FutureBuilder s getLeaderboard()
- ListView s položkami žebříčku

**Výstup:** Interaktivní žebříček

---

## 🎯 FÁZE 8: Kolo štěstí a odměny

### Krok 8.1: Reward model
**Soubor:** `lib/models/reward_model.dart`
**Co vytvořit:**
- Třída Reward s poli: id, title, description, diamondCost, type, imageUrl
- Enum RewardType

**Výstup:** Model pro odměny

### Krok 8.2: RewardService
**Soubor:** `lib/services/reward_service.dart`
**Co vytvořit:**
- Třída RewardService
- Metoda getAvailableRewards()
- Metoda purchaseReward()
- Metoda _processReward()

**Výstup:** Service pro správu odměn

### Krok 8.3: RewardsScreen UI
**Soubor:** `lib/screens/rewards/rewards_screen.dart`
**Co vytvořit:**
- StatelessWidget RewardsScreen
- FutureBuilder s getAvailableRewards()
- GridView s RewardCard widgety
- Dialog pro potvrzení výměny

**Výstup:** Obchod s odměnami

### Krok 8.4: WheelPrize model
**Soubor:** `lib/models/wheel_prize_model.dart`
**Co vytvořit:**
- Třída WheelPrize s poli: id, title, probability, type, color

**Výstup:** Model pro výhry v kole

### Krok 8.5: WheelService
**Soubor:** `lib/services/wheel_service.dart`
**Co vytvořit:**
- Třída WheelService
- Konstanta SPIN_COST
- Metoda canSpin()
- Metoda spin() - losování výhry
- Metoda _selectPrize()
- Metoda _processWin()

**Výstup:** Kompletní logika kola štěstí

### Krok 8.6: WheelOfFortuneScreen UI
**Soubor:** `lib/screens/wheel/wheel_of_fortune_screen.dart`
**Co vytvořit:**
- StatefulWidget WheelOfFortuneScreen
- AnimationController pro rotaci
- Stack s kolem a pointerem
- ElevatedButton "ROZTOČIT"
- Dialog s výhrou

**Výstup:** Interaktivní kolo štěstí

---

## 🎯 FÁZE 9: E-shop integrace a dokončení

### Krok 9.1: ShoptetService
**Soubor:** `lib/services/shoptet_service.dart`
**Co vytvořit:**
- Třída ShoptetService
- Konstanty API_URL, API_TOKEN
- Metoda getProducts()
- Metoda createOrder()
- Metoda generateDiscountCode()

**Výstup:** Service pro Shoptet API

### Krok 9.2: ShopScreen UI
**Soubor:** `lib/screens/shop/shop_screen.dart`
**Co vytvořit:**
- StatelessWidget ShopScreen
- FutureBuilder s getProducts()
- ListView s ProductCard widgety
- Dialog pro výběr dobročinného projektu

**Výstup:** UI obchodu

### Krok 9.3: HomeScreen - hlavní navigace
**Soubor:** `lib/screens/home/home_screen.dart`
**Co vytvořit:**
- StatefulWidget HomeScreen
- BottomNavigationBar s 5 položkami
- PageView nebo IndexedStack pro obrazovky
- Tlačítka: Mapa, Skenovat, Statistiky, Odměny, Profil

**Výstup:** Hlavní navigace aplikace

### Krok 9.4: ProfileScreen
**Soubor:** `lib/screens/profile/profile_screen.dart`
**Co vytvořit:**
- StatelessWidget ProfileScreen
- Zobrazení jména, emailu, avataru
- Tlačítko "Moje statistiky"
- Tlačítko "Nastavení"
- Tlačítko "Odhlásit se"

**Výstup:** Profilová obrazovka

### Krok 9.5: Onboarding tutorial
**Soubor:** `lib/screens/onboarding/onboarding_screen.dart`
**Co vytvořit:**
- StatefulWidget OnboardingScreen
- PageView s 3-4 slidy
- Vysvětlení jak aplikace funguje
- Tlačítko "Začít"

**Výstup:** Úvodní tutorial

### Krok 9.6: Testování a ladění
**Co udělat:**
- Otestovat všechny hlavní flow
- Zkontrolovat validace
- Otestovat offline režim
- Otestovat notifikace
- Vyladit UX

**Výstup:** Otestovaná aplikace

### Krok 9.7: Ikona a splash screen
**Co udělat:**
- Vytvořit ikonu aplikace
- Nastavit splash screen
- Přidat do pubspec.yaml

**Výstup:** Profesionální vzhled

### Krok 9.8: Build a deploy
**Co udělat:**
- flutter build apk (Android)
- flutter build ipa (iOS)
- Nahrát do obchodů

**Výstup:** Publikovaná aplikace

---

## 📝 Poznámky pro Claude Code

- Každý krok je nezávislý - můžeš začít kdekoli
- Vždy si nejdřív přečti kontext (modely, services které už existují)
- Testuj každý krok samostatně
- Commit po každém dokončeném kroku
- Pokud něco nefunguje, vrať se o krok zpět

