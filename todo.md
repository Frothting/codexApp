Blueprint
1.Environment and tooling
2.Core state machine skeleton
3.Input abstraction (mouse + keyboard)
4.Player entity data model
5.Map loader, scrolling, collision grid
6.Basic click-to-move pathing
7.HUD: HP, MP, XP bars
8.NPC framework: idle sprite + dialog box
9.Quest data model and log UI
10.Inventory data model and UI pane
11.Skill tracker (XP → level)
12.Swordplay combat loop versus dummy enemy
13.Enemy AI stub (wander → aggro)
14.Magic subsystem (mana pool + single spell)
15.Healing subsystem (single heal, undead damage)
16.Fishing mini-game stub
17.Save/load (cartdata, checksum)
18.Screen transition + multi-map world
19.Additional spells, special moves, fishing tiers
20.Full quest types, reward pipelines
21.Dungeon generator + gating to Demon King
22.Final boss fight logic
23.Token pass, compression, polish
24.Release candidate test sweep

Iterative Chunks

Chunk 1 — Project scaffolding

1.1 create repo, cart, CI lint
1.2 build minimal _init, _update, _draw
1.3 inject unit‑test harness macro

Chunk 2 — Movement baseline

2.1 player struct, position update
2.2 collision map bits
2.3 click‑to‑move single‑tile

Chunk 3 — UI baseline

3.1 HUD bars render
3.2 cursor highlight

Chunk 4 — NPC + dialog

4.1 npc struct array
4.2 simple proximity click opens dialog

Chunk 5 — Quest core

5.1 quest struct, enum status
5.2 accept/complete flow

Chunk 6 — Inventory

6.1 item struct, add/remove
6.2 inventory panel

Chunk 7 — Skills

7.1 xp table
7.2 level‑up calc

Chunk 8 — Combat stub

8.1 sword swing cooldown
8.2 dummy enemy hurt/die

Chunk 9 — Enemy AI base

9.1 wander path
9.2 aggro on click

Chunk 10 — Magic + healing

10.1 mana, spell cast
10.2 heal spell

Chunk 11 — Fishing

11.1 water detection
11.2 fishing result table

Chunk 12 — Save/load

12.1 serialize player+quest
12.2 checksum verify

Chunk 13 — World expansion

13.1 screen transition
13.2 multi‑map loader

Chunk 14 — Advanced content

14.1 extra spells, moves
14.2 fishing tiers

Chunk 15 — Dungeons and boss

15.1 dungeon map load
15.2 boss AI and quest gate

Chunk 16 — Polish

16.1 token trim
16.2 final QA

Chunk→Step Decomposition (sample depth until granularity stabilizes)

Chunk 2 Movement baseline
•2.1.1 define player={x,y,spd}
•2.1.2 write update_player()
•2.2.1 encode collision in map flag 0x01
•2.2.2 write is_walkable(tx,ty)
•2.3.1 on mouse click store target tile
•2.3.2 lerp position until target reached
•2.3.3 emit player_arrived event unit‑test

Chunk 5 Quest core
•5.1.1 quest struct {id,type,arg,status}
•5.1.2 global quests={} loader
•5.2.1 accept_quest(id) sets status=1
•5.2.2 complete_quest(id) rewards XP
•5.2.3 unit‑test accept→complete state

Granularity reached: each substep ≤ 20 tokens change, ≥ 1 test, integrates immediately.

Code‑Generation LLM Prompts

Prompt 01 — Project scaffolding

Create PICO‑8 cart `runelite_pico.p8`.
Define empty `_init()`, `_update()`, `_draw()`.
Add Lua table `T={}` reserved for shared helpers.
Add unit‑test macro `assert_eq(a,b,msg)` that prints error then `stop()`.
Write a test block executed when `_update()` detects `btnp(7)`.
Test that `1+1==2`.
Provide full source.

Prompt 02 — Player struct and update

In `runelite_pico.p8`, add global `player={x=64,y=64,spd=1}`.
Implement `update_player()` called from `_update()`.
For now, move with arrow keys; each press changes `x`/`y` by `spd`.
Unit test: simulate four calls with right‑key pressed, assert `player.x==68`.
Keep previous tests passing.

Prompt 03 — Collision helper

Add map flag constant `F_SOLID=1`.
Implement `is_walkable(px,py)` returning false if any map tile under point has flag `F_SOLID`.
Write tests: place map tile 0 at (0,0) with flag set; assert `is_walkable(0,0)==false`.
Ensure existing tests still pass.

Prompt 04 — Click‑to‑move target logic

Read mouse with `stat(32..34)`.
On left click store target tile coordinates `tx,ty`.
Implement simple path: if current tile != target, move one pixel toward target each frame respecting `is_walkable`.
Stop when arrived.
Test: set player(0,0), target(8,0) on empty map, simulate 8 frames, assert player.x==8 and arrived flag true.

Prompt 05 — HUD bars

Implement `draw_bar(x,y,w,h,val,max,col_full,col_empty)`.
Render HP, MP, XP using sample values in `_draw()`.
No new tests needed.

Prompt 06 — NPC struct and dialog

Define `npcs={{x=32,y=32,id=1,dialog="hello"}}`.
On click within 8px of npc, open modal dialog box with text.
Close on second click.
Write test: call `open_dialog(npcs[1])`, assert `game_state=="dialog"`.

Prompt 07 — Quest core implementation

Create `quests={}` and enum `Q_NONE=0,Q_ACTIVE=1,Q_DONE=2`.
Function `accept_quest(q)` sets status.
Function `complete_quest(q)` rewards `player.xp+=q.reward_xp` and sets `status=Q_DONE`.
Unit tests: accept then complete sample quest; assert xp increased and status updated.

Prompt 08 — Inventory model

Add `inventory={}`.
Functions `add_item(id,qty)` and `remove_item(id,qty)`.
Each item stored as `{id,qty}` unique id.
Tests: add id=1 qty=3 then remove 2, assert remaining 1.

Prompt 09 — Skill tracker

Define `skills={sword={lvl=1,xp=0}}`.
Function `gain_xp(skill,amt)`; on reaching `lvl^2*10` xp, increment lvl and reset xp.
Test: give 10 xp to level‑1 sword, assert lvl==2 and xp==0.

Prompt 10 — Sword combat loop

Add `attack_cooldown=0`.
On click enemy while cooldown==0, subtract damage=skills.sword.lvl from enemy.hp, set cooldown=15 frames.
Enemy struct `{x,y,hp}`.
Test: enemy hp 5, sword lvl 2, simulate attack, assert hp==3 and cooldown set.

Prompt 11 — Enemy AI

Implement simple `update_enemy(e)` that wanders randomly until player within 32px then chases.
Test: set distance 16px, call update 1 frame, assert enemy.vel toward player.

Prompt 12 — Magic subsystem

Add `player.mana=10,player.max_mana=10`.
Spell struct `{id="fire",cost=3,damage=4}`.
Cast on enemy if mana>=cost.
Tests: cast spell, assert mana reduced, enemy hp reduced.

Prompt 13 — Healing spell

Add spell `{id="heal",cost=2,heal=5}`.
Cast on player; hp clamped to max.
Test: player hp 3/10, cast, assert hp==8 mana==8.

Prompt 14 — Fishing stub

Detect map flag `F_WATER=2`.
On click water tile start timer 60 frames; after timer resolve catch with 50% success add item fish id=100.
Test: mock water click, simulate 60 frames, assert inventory contains fish OR none but no crash.

Prompt 15 — Save/load

Serialize player position, inventory, quests into string, write with `cartdata()`, key "save".
Add checksum byte xor of payload.
On load validate checksum else discard.
Tests: save then load, assert structures identical.

Prompt 16 — Screen transition

Load maps by id into room struct; when player crosses boundary, swap current room and update player position.
Test: move right off screen, assert room id incremented, player.x wrapped.

Prompt 17 — Boss gate

Add boss room locked flag requiring quest id 99 done.
If not completed, collision blocks entrance.
Test: without quest done expect blocked==true; with quest done blocked==false.

Prompt 18 — Token optimization pass

Refactor duplicate code into helpers, inline constants where safe.
Maintain test suite green.
Provide token count in comment at top.

Prompt 19 — Final QA checklist

Run full automated tests plus manual checklist script that iterates test scenarios above.
Produce summary printout.

# todo.md — RuneLite‑PICO Implementation Checklist

## 1  Scaffolding
- [x] Initialize git repository and remote
- [x] Create cart `runelite_pico.p8`
- [x] Add CI lint + token‑count script
- [x] Define empty `_init()`, `_update()`, `_draw()`
- [x] Add shared helper table `T={}`
- [x] Implement `assert_eq(a,b,msg)` macro
- [x] Inject test trigger on `btnp(7)`
- [x] Unit test: `1+1==2` passes

## 2  Movement baseline
- [x] Define `player={x,y,spd}`
    - [x] Position defaults `(64,64)`
    - [x] Speed default `1`
- [x] Implement `update_player()`
    - [x] Arrow‑key movement
    - [x] Event `player_arrived`
- [x] Encode solid tiles with flag `0x01`
- [x] Implement `is_walkable(tx,ty)`
- [x] Mouse click stores target tile
- [x] Linear move toward target each frame
- [x] Unit test: move right four frames → `x==68`

## 3  UI baseline
- [x] Implement `draw_bar(x,y,w,h,val,max,col_full,col_empty)`
- [x] Render HP, MP, XP bars
- [x] Draw cursor highlight over clickable tiles

## 4  NPC + dialog
- [ ] Define `npcs[]` with `x,y,id,dialog`
- [ ] Click within 8 px opens dialog modal
- [ ] Second click closes dialog
- [ ] Unit test: `open_dialog` sets `game_state=="dialog"`

## 5  Quest core
- [ ] Define enums `Q_NONE=0,Q_ACTIVE=1,Q_DONE=2`
- [ ] Quest struct `{id,type,arg,status,reward_xp}`
- [ ] `accept_quest(id)` sets status active
- [ ] `complete_quest(id)` grants reward, sets done
- [ ] Unit test: accept → complete updates XP and status

## 6  Inventory
- [ ] `inventory={}` array of `{id,qty}`
- [ ] Implement `add_item(id,qty)`
- [ ] Implement `remove_item(id,qty)`
- [ ] Inventory panel toggle
- [ ] Unit test: add 3, remove 2 → remaining 1

## 7  Skills
- [ ] `skills={sword={lvl=1,xp=0},magic={...},heal={...},fish={...}}`
- [ ] XP table function `xp_to_level(lvl)`
- [ ] `gain_xp(skill,amt)` handles level‑up
- [ ] Unit test: give 10  xp at level 1 → level 2

## 8  Combat stub
- [ ] Define `attack_cooldown`
- [ ] Enemy struct `{x,y,hp}`
- [ ] Click enemy when cooldown 0 → damage equals sword level
- [ ] Cooldown reset (15 frames)
- [ ] Unit test: enemy hp reduces correctly

## 9  Enemy AI base
- [ ] Implement `update_enemy(e)`
    - [ ] Random wander
    - [ ] Chase if player within 32  px
- [ ] Unit test: within range sets velocity toward player

## 10  Magic + healing
- [ ] Add `player.mana, player.max_mana`
- [ ] Spell list with `cost,damage/heal`
- [ ] Cast spell on enemy or player
- [ ] Unit tests:
    - [ ] Fire spell reduces mana and enemy hp
    - [ ] Heal spell restores hp, clamps at max

## 11  Fishing
- [ ] Map flag `0x02` for water
- [ ] On water click start 60 -frame timer
- [ ] 50 %  success → `add_item(fish_id,1)`
- [ ] Unit test: simulate timer, verify no crash, conditional catch

## 12  Save/load
- [ ] Serialize player pos, skills, inventory, quests
- [ ] Compute checksum (byte XOR)
- [ ] Save to `cartdata("save")`
- [ ] Load validates checksum before apply
- [ ] Unit test: round‑trip integrity

## 13  World expansion
- [ ] Room struct loader by id
- [ ] Screen edge detection swaps room
- [ ] Update player wrap position
- [ ] Unit test: right edge transition increments room id

## 14  Advanced content
- [ ] Implement additional sword specials
- [ ] Add magic spell tiers
- [ ] Introduce fishing tiers by biome
- [ ] Update quest rewards for new skills

## 15  Dungeons and boss
- [ ] Dungeon map loader
- [ ] Gate requires quest 99 completion
- [ ] Demon King enemy struct and AI
- [ ] Final quest completion triggers win state
- [ ] Unit tests:
    - [ ] Gate blocks without quest
    - [ ] Gate opens with quest done

## 16  Polish and optimization
- [ ] Refactor duplicate helpers
- [ ] Inline constants where safe
- [ ] Token count audit, target ≤ 8192 tokens
- [ ] Full automated test suite pass
- [ ] Manual checklist pass:
    - [ ] Movement and transition
    - [ ] Combat, spells, healing
    - [ ] Fishing outcomes
    - [ ] Quest flow
    - [ ] Save/resume
    - [ ] Final boss defeat
