<p align="center">
  <img src="http://i.imgur.com/IgJIz9V.png"><br>
  <img height=300 src="http://i.imgur.com/XSVEcTt.pngg">
</p>


The Lovely Tactics Hex project is a framework for development of tactical role-playing games (TRPG), built using the LÖVE2D engine.
The main games used as inspiration for this project are Final Fantasy Tactics Advance (for GBA), Jeanne D'arc, and Trails in the Sky (both for PSP).
The "Hex" in the name is because the battle grid is hexagonal. I plan, though, to adapt it to orthogonal and isometric grids someday.

Project's repository: https://github.com/GloamingCat/Lovely-Tactics-Hex

<p align="center">
<img width=400 src="https://66.media.tumblr.com/939e12a4f0b1fb41464b8389c2e7cbf8/tumblr_pvkjjmKqRP1x9yfk6o4_1280.png">
<img width=400 src="https://66.media.tumblr.com/ffde850fb9b1e15a786228f0baaaf132/tumblr_pvkjjmKqRP1x9yfk6o5_1280.png">
<img width=400 src="https://66.media.tumblr.com/162763f7aa323d9e6dd1944d1066e145/tumblr_pvkjjmKqRP1x9yfk6o1_1280.png">
<img width=400 src="https://66.media.tumblr.com/0ec170b34248f5c96146cf3d2475f26a/tumblr_pvkjjmKqRP1x9yfk6o3_1280.png">
<img width=400 src="https://66.media.tumblr.com/b25c4d6440d58030a88dda099696fa54/tumblr_pvkjjmKqRP1x9yfk6o6_1280.png">
<img width=400 src="https://66.media.tumblr.com/de6f15c8791b79b562776773c0d4dea8/tumblr_pvkjjmKqRP1x9yfk6o2_1280.png">
</p>

## Installation

To run this project, you need to first install LÖVE2D. Follow steps here: https://love2d.org/.
Once the engine is properly installed, all you have to do is run the project folder as any other game made in the engine.

### Windows
For Windows users who are new to LÖVE2D, here is a simple step-by-step to run the project:
1) Download this project as a zip, in the green button at the top of this page;
2) Download LÖVE2D zip from the site above, according to your platform (32-bit should work);
3) Extract LÖVE2D files into a new empty folder;
4) Extract the project's root folder into the same newly created folder. The project's root folder, that cointans the main.lua file inside, should be in the same folder as "love.exe" file;
5) Drag the project's root folder and drop over "love.exe" file. This should run the game.

### Linux

For Linux users,
1) Download this project as a zip, in the green button at the top of this page;
2) Download LÖVE2D package from the site above and install it;
3) Extract the project's root folder to any folder;
4) Enter the project's root folder (the one containing "main.lua" file), open the terminal and type
```
love ./
```
This should run the game.

## Demo Game

For Windows users that do not use git, I created zip files for each demo game containing all necessary files to test it. Just download, extract and run it.
* v0.1: https://www.dropbox.com/s/rlqlq2yj152bxg1/Demo%20v0.1.zip?dl=0
* v0.2: https://www.dropbox.com/s/lvfjrzogphr1zqc/Demo%20v0.2.zip?dl=0
* v0.3: https://www.dropbox.com/s/6scayhln8r0hcjg/Demo%20v0.3.zip?dl=0
* v0.4: https://www.dropbox.com/s/07su2r8b7e7o0if/Demo%20v0.4.zip?dl=0
* v0.5: https://www.dropbox.com/s/17i1ek9adaw745s/Demo%20v0.5.zip?dl=0
  * This one includes the first version of the database editor!

## How to Play

* Use arrow keys or mouse to navigate around the field or GUI;
* Press shift to walk faster;
* Press Z/Enter/Space to confirm a GUI selection or interact with NPCs;
* Press X/Backspace/ESC to cancel a GUI selection;
* Press a cancel button in field to show the Field Menu;
* Collide with green jellies to start a battle;
* For debugging:
  * When the game starts, keep holding a cancel button and then start a new game to skip the intro scene;
  * Press F1 to quick-save and F5 to quick-load (does not work during battle);
  * Hold K to kill all enemies in the next turn;
  * Hold L to kill all allies in the next turn.

## Editor

I am also working on a complementary project, which is an editor for the json files - database, settings and fields. It's still in a very early stage, but it can be already found here: https://github.com/GloamingCat/LTH-Editor.

<p align="center">
  <img height=220 src="https://66.media.tumblr.com/eaac8ab6d9f2f4be8dae3abbaaa44c65/tumblr_pkuy0poEfV1x9yfk6o1_1280.jpg">
  <img height=220 src="https://66.media.tumblr.com/7ae1a235c4b3fe02e50e139bb4eab1c3/tumblr_pf5hy6Jwxw1x9yfk6o2_1280.jpg">
</p>

## Documentation and API

Since this project is still under development, its design and features may change a lot, so I'll write a proper documentation when it gets more stable.

## To-do list

* Text and dialogue:
  * Optimize dialogue text rendering by not redrawing full lines;
  * Draw sprites in the middle of text;
  * Dialogue text commands: 
    * Wait for number of frames;
    * Wait for player input;
    * Ignore player input and close automatically.
* Additional plugins:
  * ClassEquip: restrict equipment items per battler class;
  * FormationEditor: edit party formation in-game;
  * TerrainDuration: set life time of terrain (snow, fire, magical, etc);
  * PartyRegions: set party escape tiles using regions. 
* Editor:
  * Fix tab flickering on Windows;
  * Optimize field editor (I have no idea how to do this).

## Credits

Thanks to the following people for source code:
* Luke Perkin, for the ProFi module: https://gist.github.com/perky/2838755;
* Robin Wellner and Florian Fischer, for the code used as base for the rich text, found in: https://github.com/gvx/richtext;
* David Heiko Kolf, for the json parser: http://dkolf.de/src/dkjson-lua.fsl/;
* kevinclancy, for class module: https://bitbucket.org/kevinclancy/basic-class-system/wiki/Home.

Thanks to the following people for general art/audio resources used in the project:
* GameAudio for sound effects: https://freesound.org/people/GameAudio/packs/13940/;
* CGEffex for sound effects: https://freesound.org/people/CGEffex/;
* artisticdude for sound effects: https://opengameart.org/content/rpg-sound-pack;
* ViRiX Dreamcore (David Mckee) for sound effects: https://opengameart.org/content/magic-sfx-sample;
* Kenney for sound effects: www.kenney.nl;
* Tuomo Untinen for sound effects: https://opengameart.org/content/rpg-sound-package;
* Aaron Krogh for BGM: https://soundcloud.com/aaron-anderson-11;
* David Vitas for BGM: http://www.davidvitas.com/portfolio/2016/5/12/rpg-music-pack;
* Gyrowolf for BGM: https://gyrowolf.com/resources/;
* Mr. Bubble for the battle animations: https://mrbubblewand.wordpress.com/download/;
* Alex dos Ventos for the scenery art: http://diabraar.tumblr.com/.

## License

For now, this work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/4.0/. It may have a commercial license in the future, maybe when it's finished.
Also, please check the LÖVE2D license here: https://love2d.org/wiki/License.

## Contact

My e-mail is nightlywhiskers (at) gmail.com. You may also find me in DeviantArt, Instagram and some random art/gamedev forums, as GloamingCat.
