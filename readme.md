# Deeptris

#### [Download for Linux](https://dibidabidab.github.io/ldjam-48-48/game-linux.zip)
#### [Download for Windows](https://dibidabidab.github.io/ldjam-48-48/game-windows.zip)
#### [Play game in browser (CHROME RECOMMENDED *)](https://dibidabidab.github.io/ldjam-48-48/game.html)
<sup>*the WebGL implementation of Firefox is slow, use Chrome instead, or download the native desktop version if you have low FPS.</sup>

[![Build & deploy to gh-pages](https://github.com/dibidabidab/ldjam-48-48/actions/workflows/build_and_deploy.yml/badge.svg)](https://github.com/dibidabidab/ldjam-48-48/actions/workflows/build_and_deploy.yml)

A tetris inspired game for the 48th Ludum Dare 48.

Theme: Deeper and deeper

## Tools used
- Blender 2.79
- [Blender to .ubj exporter](https://github.com/dibidabidab/blender_UBJSON_exporter)
- Audacity
- beepbox.co [for my awful attempt at music](https://www.beepbox.co/#8n31s1kbl00e07t2nm2a7g0fj07i0r1o3210T0v1L1ue2q3d5f7y3z8C0w5c2h2T1v1L4ue0q3d5fay3z8C0c0A1F4B3VbQ217cPe433E0a81T1v1L4ue3q3d6f8y5z1C0c0AbF8B5VaQ024bPa871E0002T3v1L4uf5q1d5f7y1z6C1S1jsSIzsSrIAASJJb000i0000000N4h840000014h4h4000004h4h8w00000p21IBWqDm5Kcmj5F5jnZQi_b5GcmImAnbEBWrzZweD1jnWNHQngdbdvPsLPa2-kKjq-QPzY---Dp-t_A6K4Ljq_1HISLRNvdtdvRJlBU2suCXY00)
- Aseprite
- G++/MVC++/Emscripten
- CLion (any other C++ editor will do too)

## Usage

Make sure you have [Git LFS](https://git-lfs.github.com/) installed, then clone this repo.

Do `git submodule update --init --recursive` to clone submodules


##### Note for windows:
After compiling, make sure you move `OpenAL32.dll` to the working directory (the game might not launch without). 

You can find it somewhere in `desktop/out/Release/bin/....` or in a similar directory (I hope Windows has a proper search function). 

### Open in CLion
- open `desktop/CMakeLists.txt`
- change the project root from `./desktop` to `./`
- in your debug configuration, set the working directory to `./` as well, otherwise the assets cannot be found

### Compile for Desktop

`cd desktop`

`cmake .` (or `cmake . -DCMAKE_BUILD_TYPE=Release`)

`make -j8` (or `cmake --build . -j8 --config Release`)

`cd ..`

`./desktop/out/game` (or `./desktop/out/Release/game.exe`)

### Compile for HTML/Web

**NOTE**: [install Emscripten first](https://emscripten.org/docs/getting_started/downloads.html)

`cd html`

`emconfigure cmake .` (only the first time, and everytime you add new files)

`make -j8`

`emrun out/game.html`

### Configure GitHub build & deploy automation

This repository contains a Github Workflow which automates the building and deploying of the game to GitHub Pages.
The workflow will generate the following files:
- `game.html` and asset files (directly playable in browser)
- `game-linux.zip`
- `game-windows.zip`

This workflow can be found in `.github/workflows/` and in the Actions tab on GitHub.

This workflow will require a secret access token in order to deploy the game to GitHub pages.

#### Steps to add the secret access token:

- Go to your account settings on GitHub
- Go to 'Developer settings' -> 'Personal access tokens'
- Click 'Generate new token'
- Create a token with the 'repo' scope
- Copy the access token
- Go to 'Secrets' in your repository's settings
- Add a new secret with the name 'ACCESS_TOKEN' and paste the token in the text field
- Trigger the workflow (by commiting something for example) and the game should appear on `https://*your-username*.github.io/*your-repo-name*/game.html`

