# Pelagico

## Overview

Pelagico is a 2D underwater survival / adventure RPG game where you play as a fish, trying to level up and defeat the squid boss! Kill enemies to gain more XP to level up, which gives you higher damage, higher max health, higher speed, lower dash cooldowns, and faster regeneration!

Created by Vincent Chen, Lucas Liu, Justin Yeung, and Jeremy Jiang as Team Node Zero for the Australian STEM Video Game Challenge.

## Installation Instructions

### Windows

Navigate to [https://vincentchen18.itch.io/pelagico](https://vincentchen18.itch.io/pelagico) and download the Windows executable of the version you want to play! Alternatively, you can also download it from the GitHub releases version, which you can find the links to in the bottom section of this README entitled **Versions**.

### Mac

Navigate to [https://vincentchen18.itch.io/pelagico](https://vincentchen18.itch.io/pelagico) and download the Mac executable of the version you want to play! Alternatively, you can also download it from the GitHub releases version, which you can find the links to in the bottom section of this README entitled **Versions**.

### Linux

Navigate to [https://vincentchen18.itch.io/pelagico](https://vincentchen18.itch.io/pelagico) and download the Linux executable of the version you want to play! Alternatively, you can also download it from the GitHub releases version, which you can find the links to in the bottom section of this README entitled **Versions**.

Note: you may need to first run `chmod +x executable.x86_64` before running `./executable.x86_64` to run the binary.

snapcraft installation instructions coming soon

You can also download the project and source code at the Github repository, located at https://github.com/vincentchen18/Pelagico

## How to play

### Controls:

The game uses WASD for movement and turning, as well as F to dash. Alternatively, arrows may also be used for movement. Dashing is the only way to attack enemies and it deals damage to an enemy if you dash through them. Dashing through multiple enemies will gradually cause the enemies to take less damage the later they get hit.

You start off as a weak fish with only 100 health and 20 damage in the shallowest area of the ocean. The map is naturally generated using the Simplex Noise Generation algorithm, with a pseudorandom mechanism to blend naturally between ocean depths. There are four different depths of ocean, characterised by their own features and quirks, as well as many enemies. The further right you swim, the deeper the ocean that you get into.

### Beach Zone

This area is just sand. You can't physically swim onto it.

### Shallow Zone

The shallow zone is the area that you spawn into! This area is very beginner friendly spawning easy-to-defeat enemies such as crabs and scallops.

### Twilight Zone

This area is also relatively peaceful or easy, spawning crabs and scallops, and featuring one new enemy: the sardine, which is a weak fish that swims in schools with up to five other sardines.

### Midnight Zone

The midnight zone is where the difficulty begins to amp up. Your vision decreases as you descend further into the ocean. This area is the home to two new enemies: anglerfish, and a much lower rate of sharks. These enemies deal a lot of damage so you may need to spend some time in the shallow or twilight zone to level up before getting ready to engage in this zone.

### Abyssal Zone

This area is the darkest of them all, and will require you to do a lot of levelling up before you will be ready to engage in this zone. Here, a higher frequency of anglerfish and sharks will spawn, and this zone is also home to the squid boss, which you need to defeat to beat the game.

### Player levels


| Level   | XP Needed From Last Level | Max Health | Damage | Speed | Regeneration (per tick) | Regeneration (cooldown) | Vision Multiplier | Attack Cooldown |
|---------|---------------------------|------------|--------|-------|-------------------------|-------------------------|-------------------|-----------------|
| 1       | 0                         | 100        | 20     | 235   | 8%                      | 5 seconds               | 1.0x              | 1.5 seconds     |
| 2       | 40                        | 200        | 60     | 260   | 10%                     | 4.5 seconds             | 1.2x              | 1.3 seconds     |
| 3       | 200                       | 400        | 110    | 300   | 10%                     | 4 seconds               | 1.3x              | 1 second        |
| 4       | 800                       | 700        | 160    | 350   | 12%                     | 3.7 seconds             | 1.5x              | 0.8 seconds     |
| 5       | 2000                      | 1000       | 250    | 400   | 14%                     | 3.5 seconds             | 1.8x              | 0.6 seconds     |
| 6 (max) | 3000                      | 2000       | 360    | 440   | 16%                     | 3.3 seconds             | 2.0x              | 0.5 seconds     |

Notably, when you reach the last level, killing any pelagic enemies will give you a small heal instead of XP, and reaching level 6 also gives you an arrow that directs you towards the squid boss.

### Enemies

Now, allow me to introduce to you the enemies in our game, and what they can do...

| Name         | Zones              | Health | Damage                          | Speed                   | XP  | Regeneration per tick | Regeneration cooldown | Attack Cooldown                                          | Special Ability / Behaviours                                                                                                                                                                                                       |
|--------------|--------------------|--------|---------------------------------|-------------------------|-----|-----------------------|-----------------------|----------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Crab         | Shallow, Twilight  | 40     | 5                               | 60                      | 6   | 2%                    | 8 seconds             | 1 second                                                 | Only walks side to side (like a real crab)                                                                                                                                                                                         |
| Scallop      | Shallow, Twilight  | 50     | 8                               | 0                       | 9   | 3%                    | 10 seconds            | 2 seconds                                                | Shoots pearl projectiles at you to damage you                                                                                                                                                                                      |
| Sardine      | Twilight, Midnight | 20     | 5                               | 50                      | 2   | 10%                   | 8 seconds             | 0.5 seconds                                              | Swims in schools and runs away from you                                                                                                                                                                                            |
| Anglerfish   | Midnight, Abyssal  | 200    | 30                              | 192                     | 75  | 10%                   | 8 seconds             | 2 seconds                                                | Charges you if you're not looking at it, but has a small chance to be neutral. Emits light and runs if health is low.                                                                                                              |
| Shark        | Midnight, Abyssal  | 400    | 80                              | 215                     | 350 | 3%                    | 10 seconds            | 1 second                                                 | Always aggressive and tries to kill you by chasing you.                                                                                                                                                                            |
| Squid (boss) | Abyssal            | 10000  | 120 but only 80 for projectiles | 180, up to 440 for dash | -   | 1%                    | 25 seconds            | 1 second for melee attacks but 4 seconds for projectiles | Final boss: killing it wins you the game. Shoots squid ink at you that severely hinders your vision if hit. Occasionally dashes at you to attack, and at max level you gain an arrow that always points towards it. Only 1 spawns. |

### Death

Upon death, you do not lose any levels, but you do lose half of your acquired XP in your progression to the next level. For example, if you are at level 3 with 400 XP and die, you will lose 200XP. You will still be at level 3 but with half the XP. You will respawn in the shallow zone where you first spawned. You can also get the option to return back to the main menu but that does mean that you lose your progress and it will start a new instance of the game.

## Versions

### Alpha test: 17/08/2026

- Very few features
- Only enemies: crab and sardines
- Vision reduction for depth zones implemented
- not much else...
https://github.com/vincentchen18/Pelagico/releases/tag/alpha

### Beta test: 25/08/2026

- More enemies added
- added scallops, anglerfish, and sharks
- small difficulty tuning
- music
- main menu :D
https://github.com/vincentchen18/Pelagico/releases/tag/beta

### Competition Release: 31/08/2026

- full release of the game, all mobs and features included as stated in this readme.


## Credits

Vincent Chen - Scripting, Game Mechanics, Documentation, Tutorial, Publication

Lucas Liu - Scripting, Music, Mechanics

Justin Yeung - Environment Art, Menu / Win Screen Art, Mechanics

Jeremy Jiang - Sprite / Character Art, Mechanics

## AI use

AI was not used in any way to create any code, sprites, assets, or audio for this project.


