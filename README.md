# Ansible playbooks and configs for csfun and csmatch servers at PolyLAN Zurich


**Important:**
* Maps at csfun\csgo\maps need to be downloaded from: [polybox.ethz.ch](https://polybox.ethz.ch/index.php/s/tjCQPKYIl03q7Rj)
* FastDL files are here: [polybox.ethz.ch](https://polybox.ethz.ch/index.php/s/0WncJV1E3MAFgPw)


Sources of plugins used in csfun:

| Plugin | version / commit | source |
| ------ | ------ | ------ |
| MetaMod | 1.10 - build 968 | [sourcemm.net](https://www.sourcemm.net/downloads.php/?branch=stable) |
| SourceMod | 1.9 - build 6275 | [sourcemod.net](https://www.sourcemod.net/downloads.php?branch=stable) |
| UMC | 3.6.2 - d05adbe (clone)| [github.com](https://github.com/Silenci0/UMC) |
| ServerAdvertisements 3 | f27fdfc (fork) | [github.com](https://github.com/Bara/ServerAdvertisement3) |
| QuakeSounds v3  | 3.5.0 (patched) | [alliedmods.net](https://forums.alliedmods.net/showpost.php?p=2644440&postcount=431) |
| multi-1v1  | 1.1.9 | [github.com](https://github.com/splewis/csgo-multi-1v1) |
| 1v1-Headshot  | c6159c0 | [github.com](https://github.com/Franc1sco/1v1-onlyhs) |
| 1v1-Dodgeball  | baba597 | [github.com](https://github.com/Franc1sco/1v1-Dodgeball) |
| 1v1-RandomDrugRounds  | 27da513 | [github.com](https://github.com/IT-KiLLER/CSGO-RDR-Random-Drug-Round) |
| 1v1-Noscope-Only  | 4639fee | [github.com](https://github.com/Cruze03/CSGO-Multi1v1-Noscope-Only) |
| 1v1-HeGrenades  | 3869c15 | [github.com](https://github.com/Franc1sco/1v1-HeGrenades) |
| 1v1-MeleeWeapons  | c6159c0 | [github.com](https://github.com/Franc1sco/1v1-MeleeWeapons) |
| 1v1-Challenge  | v1.1.5 | [github.com](https://github.com/Headline/Challenge) |
| retakes  | v0.3.4 | [github.com](https://github.com/splewis/csgo-retakes) |
| retakes - MyWeaponAllocator  | c192c5e | [github.com](https://github.com/shanapu/MyWeaponAllocator) |
| retakes - MyWeaponAllocator  | c192c5e | [github.com](https://github.com/shanapu/MyWeaponAllocator) |
| retakes-instadefuse  | c192c5e(not builded) | [github.com](https://github.com/b3none/retakes-instadefuse) |
| retakes-hud  | 9512df9(not builded)| [github.com](https://github.com/b3none/retakes-hud) |
| retakes-autoplant  | 9751a69 | [github.com](https://github.com/b3none/retakes-autoplant) |
| GhostStrike  | 1.3.0 (from AlliedModders) | [github.com](https://github.com/kinsi55/CSGO-GhostStrike) |
| executes  | #42 from jenkins | [github.com](https://github.com/splewis/csgo-executes) |
| executes-spawns  | 7cb7d70 | [github.com](https://github.com/timche/csgo-executes-spawns) |
| DangerZoneMenu  | -(not builded)  | [alliedmods.net](https://forums.alliedmods.net/showpost.php?p=2630896&postcount=6) |
| Paintball  |  2.3.7  | [alliedmods.net](https://forums.alliedmods.net/showthread.php?t=287879) |


### additional remarks
- We ran into trouble with the default volume caching settings of ProxMox VMs(ram and swap would be eaten up). It can be fixed by using writethrough as the cache setting.
