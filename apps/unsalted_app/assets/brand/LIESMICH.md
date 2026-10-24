# unsalted – App-Symbol und Startbild (Teil 1.4, N4/N5)

Quelle: Figma-Bibliothek `5er28Cr7EMMcPzvusWjNyR`, Seite **Marke** (`Brand/Symbol` 275:34, Rahmen siehe unten).
Farben nur aus `tokens.json`: Papier `#F9F7F1` (neutral-50), Tinte `#141925` (neutral-900),
Marker hell `#FEE545` (marker-400), Marker dunkel `#EDD13D` (marker-500), Weiß `#FFFFFF` (neutral-0).

## Gestaltung (Entwurf, abgeleitet)

Logo „Name auf dem Markerstrich“: `unsalted` klein in Atkinson Hyperlegible Next 700 auf einer Markerfläche
(wie `Highlight`). Das App-Symbol nimmt daraus den Anfangsbuchstaben **u** auf dem Markerstrich
(Seitenverhältnis 660 : 420, Radius 1/12 der Höhe): Der volle Name wäre bei 29 × 29 pt nicht lesbar
(Vorgabe in `03-markenelemente.md`). Papier bzw. Tinte als Grund, genau ein Markerelement, keine Illustration.

## Dateien

| Datei | Größe | Verwendung |
|---|---|---|
| `app-symbol/app-symbol-master-1024.png` | 1024², deckend | Master; iOS hell; Quelle für alle Größen |
| `app-symbol/ios/app-symbol-ios-hell-1024.png` | 1024², deckend, ohne Alpha | iOS „Any Appearance“ |
| `app-symbol/ios/app-symbol-ios-dunkel-1024.png` | 1024², Grund Tinte | iOS „Dark“ (deckend) |
| `app-symbol/ios/app-symbol-ios-dunkel-transparent-1024.png` | 1024², transparent | iOS „Dark“ ohne Grund (System legt den dunklen Verlauf darunter) |
| `app-symbol/ios/app-symbol-ios-getoent-1024.png` | 1024², weiß, „u“ ausgespart | iOS „Tinted“ (Graustufe) |
| `app-symbol/android/app-symbol-android-vordergrund-1024.png` | 108 dp, transparent | adaptive Vordergrundebene, Symbol in der Schutzzone 66 dp |
| `app-symbol/android/app-symbol-android-hintergrund-1024.png` | 108 dp, Papier | adaptive Hintergrundebene (oder Farbe `#F9F7F1`) |
| `app-symbol/android/app-symbol-android-einfarbig-1024.png` | 108 dp, weiß, transparent | einfarbiges (themed) Symbol ab Android 13 |
| `app-symbol/play-store-512.png` | 512², deckend | Store-Eintrag Google Play |
| `app-symbol/*.svg` | Vektor | Master und Symbol (farbig, dunkel, einfarbig) |
| `startbild/startbild-symbol-hell.png` / `-dunkel.png` | 640 × 408 (160 × 102 dp/pt @4x), transparent | Startbild iOS und Android bis 11 |
| `startbild/startbild-android12-hell.png` / `-dunkel.png` | 1152² (288 dp @4x), transparent, Symbol im Kreis 768 px | Startbild Android 12+ (SplashScreen-API) |
| `startbild/vorschau-startbild-*-1170x2532.png` | Vorschau @3x | nur zur Ansicht |

Startbild: zentriertes Symbol (160 dp breit) auf Papier bzw. Tinte. Kein Punktraster – die
SplashScreen-API ab Android 12 kennt nur Farbe plus Symbol, und iOS soll gleich aussehen.

## Einbau (Vorschlag für Claude Code)

`pubspec.yaml` (Pakete `flutter_launcher_icons`, `flutter_native_splash`; Schlüssel je nach Paketversion prüfen):

```yaml
flutter_launcher_icons:
  image_path: "assets/brand/app-symbol/app-symbol-master-1024.png"
  android: true
  ios: true
  remove_alpha_ios: true
  adaptive_icon_background: "#F9F7F1"
  adaptive_icon_foreground: "assets/brand/app-symbol/android/app-symbol-android-vordergrund-1024.png"
  adaptive_icon_monochrome: "assets/brand/app-symbol/android/app-symbol-android-einfarbig-1024.png"
  image_path_ios_dark_transparent: "assets/brand/app-symbol/ios/app-symbol-ios-dunkel-transparent-1024.png"
  image_path_ios_tinted_grayscale: "assets/brand/app-symbol/ios/app-symbol-ios-getoent-1024.png"

flutter_native_splash:
  color: "#F9F7F1"
  image: assets/brand/startbild/startbild-symbol-hell.png
  color_dark: "#141925"
  image_dark: assets/brand/startbild/startbild-symbol-dunkel.png
  android_12:
    color: "#F9F7F1"
    image: assets/brand/startbild/startbild-android12-hell.png
    color_dark: "#141925"
    image_dark: assets/brand/startbild/startbild-android12-dunkel.png
```

## Figma-Knoten (Bibliothek, Seite Marke)

- `Brand/Logo` 275:18 · `Brand/Symbol` 275:34 (style=color 275:21, style=mono 275:26)
- App-Symbol: Master 275:35 · iOS hell 275:39 · iOS dunkel 275:43 · iOS getönt 275:47 ·
  Android Vordergrund 275:50 · Hintergrund 275:54 · einfarbig 275:55 · Schutzzone 275:58 (nicht exportieren)
- Startbild: hell 275:75 · dunkel 275:79 · Symbol hell 275:83 · dunkel 275:87 ·
  Android 12 hell 275:91 · dunkel 275:95 · Kreis 192 dp 275:99 (nicht exportieren)
