# Lamma app icon

Approved implementation request: 14 October 2026. Replace the Flutter launcher
artwork with an original generated three-card mark in the existing app palette:
lime `#D5F85A`, lavender `#B5A0FF`, sky blue `#8FD6F5`, charcoal `#101215`.
The front card carries an Arabic question mark. Generation and background
extraction used the built-in image generation tool, without an API key.

- `generated-icon.png`: original opaque generated artwork.
- `generated-foreground.png`: generated transparent cutout for adaptive icons.
- `lamma-icon-1024.png`: opaque square master, also suitable for iOS marketing.
- `play-store-icon-512.png`: opaque store artwork; no platform mask baked in.
- `launcher-preview.png`: manually inspected original, Android circular mask,
  and small sizes. This is a visual preview, not an automated test.
- `PROMPTS.md`: exact generation and edit prompts.

Run `./scripts/generate-app-icons.ps1` from the Flutter directory to resize
these saved sources. The script uses Windows System.Drawing and adds no Flutter
dependencies. It does not generate new art or touch question banks.

Installed outputs replace the existing Android density PNGs, all entries already
listed in the iOS AppIcon catalog, web/PWA icons, favicon and Apple touch icon.
Android 8+ uses foreground/background layers from
`android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`. The foreground has
padding to preserve the mark under launcher masks, following the
[Android adaptive icon documentation](https://developer.android.com/develop/ui/compose/system/icon_design_adaptive).
The web maskable version also has additional breathing room.

These design sources and previews are outside Flutter's declared asset folders,
so they are not bundled into the running application. Only the platform-specific
icon sizes ship. No Dart code, dependencies, signing keys or application ID changed.

The source assets are ready for the next app build. This change did not build,
publish, install or overwrite an Android release, and did not run automated tests.
Existing installations receive the new launcher icon after installing an updated
build; a hot reload does not replace native launcher resources.
