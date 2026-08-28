# Pelagico

## Overview

Pelagico is a 2D underwater survival / adventure RPG game where you play as a fish, trying to level up and defeat the squid boss! Kill enemies to gain more XP to level up, which gives you higher damage, higher max health, higher speed, lower dash cooldowns, and faster regeneration!

Created by Vincent Chen, Lucas Liu, Justin Yeung, and Jeremy Jiang as Team Node Zero for the Australian STEM Video Game Challenge.

## Installation Instructions

### Windows

Navigate to [https://vincentchen18.itch.io/pelagico](https://vincentchen18.itch.io/pelagico) and download the Windows executable of the version you want to play!

github releases page coming soon

### Mac

Navigate to [https://vincentchen18.itch.io/pelagico](https://vincentchen18.itch.io/pelagico) and download the Mac executable of the version you want to play!

github releases page coming soon

### Linux

Navigate to [https://vincentchen18.itch.io/pelagico](https://vincentchen18.itch.io/pelagico) and download the Linux executable of the version you want to play!

Note: you may need to first run `chmod +x executable.x86_64` before running `./executable.x86_64` to run the binary.

github releases page coming soon

snapcraft installation instructions coming soon

## How to play

You start off as a weak fish with only 100 health and 20 damage in the shallowest area of the ocean. The map is naturally generated using the Simplex Noise Generation algorithm, with a pseudorandom mechanism to blend naturally between ocean depths. There are four different depths of ocean, characterised by their own features and quirks, as well as many enemies.

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

Notably, when you reach the last level, killing any pelagic enemies will give you a small heal instead of XP.

### Enemies

Now, allow me to introduce to you the enemies in our game, and what they can do...

| Name    | Zones             | Health | Damage | Regeneration per tick | Regeneration cooldown | Attack Cooldown | Special Ability                            |
|---------|-------------------|--------|--------|-----------------------|-----------------------|-----------------|--------------------------------------------|
| Crab    | Shallow, Twilight | 40     | 5      | 2%                    | 8 seconds             | 1 second        | Only walks side to side (like a real crab) |
| Scallop | Shallow, Twilight | 50     | 8      | 3%                    | 10 seconds            | 2 seconds       | Only walks side to side (like a real crab) |


