# گل یا پوچ — GolYaPoch
**Royal Noir | شب شاهانه**

An offline Persian Flutter companion/referee for real-world گل یا پوچ. Two physical teams play with a real گل; this Android app manages scores, card inventory, match settings, timer, and match history.

## Three distinct game modes
- **نبرد گل:** our original ruleset: five collectible attack powers, two nullifiers per team, double-edged prediction, one-shot hourglass, hunter, phoenix, poison-hand bonus empty, and the **بهای تاج** finale.
- **فیلیمو:** assisted scorekeeper with optional scoring cube and the verified 3-empty/first-strike scoring basics. The first failed crown attempt carries a 3-point penalty and a repeated failure requests an in-person duel result. Full physical card effects still require official rules confirmation and are intentionally not fabricated.
- **شاه‌گل اصلی:** assisted referee for the physical game, with non-removable cube and میلی theme. Original physical cards are illustrated; unverified effects are recorded manually rather than simulated incorrectly.

All modes permit a target of **8–31** points and optional crown phase at target minus one. Crown off: reaching target wins directly. Rule systems are isolated.

## Visual identity
Dark charcoal, champagne gold, burgundy (original mode), emerald (board-game mode) and midnight blue (Filimo mode). The repository contains over twenty original vector card and cube illustrations, a custom crown renderer, and a card gallery. All artwork is newly made for this app; no official logos, brand artwork or music are copied.

## Technology
Flutter, Material 3, Persian RTL, feature-first MVVM/Cubit, SharedPreferences (offline autosave + recent 50 results). No backend or login.

## Run
Requires a recent Flutter stable SDK and Android build environment with JDK 17.

```sh
git clone https://github.com/MahdiFarahani1/GolYaPoch.git
cd GolYaPoch
flutter create --platforms=android --project-name golyapooch --org com.mahdi .
flutter pub get
flutter test
flutter run
```

A GitHub Actions workflow analyzes, tests, and builds an Android APK on pushes to `main`. Release builds currently use debug signing, **not appropriate for distribution**. Set up a production keystore and release signing before publishing.

## Tests and status
See [docs/STATE_OF_PROJECT.md](docs/STATE_OF_PROJECT.md). The app is an evolving playable referee implementation, not an officially licensed Filimo/Shah-Gol game. The original custom mode is substantially automated. The two other modes do not yet have complete automatic official-card engines.

## Rules and attribution
The traditional game is played physically; gameplay ideas are inspired by public descriptions of Persian گل یا پوچ. Filimo and ShahGol are mentioned to explain rule variants, not to assert affiliation or endorsement.
