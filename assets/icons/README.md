# Icons Folder

Put your app icons in **`assets/icons/`**.

## Quick setup
1. Copy your PNG/SVG icon files into `assets/icons/`.
2. Add/update each icon path in `lib/app_icons.dart`.
3. Make sure the folder is listed in `pubspec.yaml` under:
   ```yaml
   flutter:
     assets:
       - assets/icons/
   ```

## Current project mapping
This project currently points to icons in `lib/icons/` (legacy icon pack).
If you want to use your own icons in `assets/icons/`, just change the constants
inside `lib/app_icons.dart` to `assets/icons/<your-file>.png`.
