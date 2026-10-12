ONScripter-RU-W
(Winther's Variation)
=============

[![Build Status](https://travis-ci.com/umineko-project/onscripter-ru.svg?branch=master)](https://travis-ci.com/umineko-project/onscripter-ru)

This is a variation of the visual novel engine empowering [Umineko Project port](https://umineko-project.org) of Umineko no Naku Koro ni from PlayStation 3. Albeit the engine being one of the most powerful publicly available engines for creating visual novels, it contains numerous hacks specific to it's needs, lacks API documentation, and may not be suitable for your needs.

For the list of available platforms and compilation instructions please proceed to [Compilation.md](https://github.com/umineko-project/onscripter-ru/blob/master/Resources/Docs/Compilation.md) document.

## Fork Details
This is the engine empowring the [Umineko Concerto](https://discord.gg/DQaBb3RFh7) mod for Umineko Project.
Various modifications made to the original engine:

* Added the ability to pause and resume the playback of videos using the commands pausevideo and resumevideo.
* Added a new formatting rule to adjust the vertical margin of each line of text (similar to line spacing).
* Added the capability to dynamically obtain the length of a scrollable sprite through getspritesize.
* Added support for a greater number of fonts than the original.
* Integrated compatibility with Discord thanks to the permission and support of [m3t4f1v3](https://github.com/m3t4f1v3).
* Added the ability to include images in addition to text associated with each item in a tree read from a scrollable sprite.

## Saved games on Windows

Starting with the 64-bit builds, saves are stored per user, with one folder per script:

```text
%APPDATA%\Umineko-Project\UminekoPS3ficationEn\   (English)
%APPDATA%\Umineko-Project\UminekoPS3ficationWh\   (Witch Hunt)
%APPDATA%\Umineko-Project\UminekoPS3ficationRu\   (Russian)
...
```

Older builds saved to `C:\ProgramData\ONScripter-RU\`, or to `iCloudDrive\ONScripter-RU\` whenever
iCloud for Windows was installed. iCloud is now used only with `enable-icloud` in `ons.cfg` (or `--enable-icloud`).

**Moving your old saves.** When a script starts with an empty save folder, the game looks for saves
from older builds and offers to copy them. The old files are never changed, so older builds keep working.

* Each script is offered its saves **the first time you start that script** in this version. If you switch to
  Witch Hunt weeks later, the question appears then.
* Saves from umineko-project builds use an older save format. You can convert them (each save is converted
  when you first load it, the original is kept as `saveN.upstream.dat`) or load them in legacy mode.
* Builds by JuliusWinther kept the saves of all scripts in one folder (`UminekoPS3fication`). Copy those only
  into the script that made them.
* Settings travel with the saves. If a copied script is unexpectedly silent, the old installation had the
  sound muted: press **Alt+M**.
* Missed the question, or played a script before migrating? Start the game once with `--migrate-saves`.

32-bit and 64-bit builds share the same save folders and can read each other's saves.

#### Credits
- Ogapee
- "Uncle" Mion Sonozaki
- Umineko Project
- All third-party library authors
