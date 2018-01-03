## Lovely Tactics Hex

The Lovely Tactics Hex project is a framework for development of tactical role-playing games (TRPG), built using the LÖVE2D engine.
The main games used as inspiration for this project are Final Fantasy Tactics Advance (for GBA), Jeanne D'arc, and Trails in the Sky (both for PSP).
The "Hex" in the name is because the battle grid is hexagonal. I plan, though, to adapt it to orthogonal and isometric grids someday.

## Motivation

I started this project as just a TRPG that I wanted to make, then I realized that the code could be generalized enough to be turned into an engine.

## Documentation and API

Since this project is still under development, its design and features may change a lot, so I'll write a proper documentation when it gets more stable.

## Installation

To run this project, you need to first install LÖVE2D. Follow steps here: https://love2d.org/.
Once the engine is properly installed, all you have to do is run the project folder as any other game made in the engine.

For Windows users who are new to LÖVE2D, here is a simple step-by-step to run the project:
1) Download this project as a zip, in the green button at the top of this page;
2) Download LÖVE2D zip from the site above, according to your platform (32-bit should work);
3) Extract LÖVE2D files into a new empty folder;
4) Extract the project's root folder into the same newly created folder. The project's root folder, that cointans the main.lua file inside, should be in the same folder as "love.exe" file;
5) Drag the project's root folder and drop over "love.exe" file. This should run the game.

For Linux users,
1) Download this project as a zip, in the green button at the top of this page;
2) Download LÖVE2D package from the site above and install it;
3) Extract the project's root folder to any folder;
4) Enter the project's root folder (the one containing "main.lua" file), open the terminal and type
```
love ./
```
This should run the game.

## Credits

Thanks to the following people for source code:
* Luke Perkin, for the ProFi module: https://gist.github.com/perky/2838755;
* Robin Wellner and Florian Fischer, for the code used as base for the rich text, found in: https://github.com/gvx/richtext;
* David Heiko Kolf, for the json parser: http://dkolf.de/src/dkjson-lua.fsl/;
* kevinclancy, for class module: https://bitbucket.org/kevinclancy/basic-class-system/wiki/Home.

Thanks to the following people for general art resources used in the project:
* GameAudio for the sound effects: https://freesound.org/people/GameAudio/packs/13940/;
* Mr. Bubble for the battle animations: https://mrbubblewand.wordpress.com/;
* Alex dos Ventos for the scenery art.

Also, check the project that my mate Felipe Tavares is working on, a GUI to edit the game's database files: https://github.com/felipetavares/lovely-tactics-gui

## License

For now, this work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/4.0/. It may have a commercial license in the future, maybe when it's finished.
Also, please check the LÖVE2D license here: https://love2d.org/wiki/License.

## To-do list

* Multi-layered fields;
* Field/Main GUI, with all other sub-GUI (items, skills, etc);
* Save/Load GUI;
* Shop GUI;
* Mouse interaction;
* Isometric and orthogonal grid cells.

## Contact

My e-mail is nightlywhiskers (at) gmail.com. You may also find me in DeviantArt, Instagram and some random art/gamedev forums, as GloamingCat.