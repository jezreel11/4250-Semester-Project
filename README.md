# MTD — Minority Tower Defense

**Team Members:** Jezreel Rodriguez, Dennis Tate, DeShaun Acklin, Jr Mayorga, Nathan Esch, Mason Booker

---

## What is MTD?

MTD (Minority Tower Defense) is a 2D top-down tower defense game built in Godot 4. Players defend a base from waves of enemies by strategically placing towers on designated grass zones along a winding path. Towers either shoot projectiles at enemies or spawn friendly units that march toward the enemy spawn point. Enemies drop gold when defeated, which is used to purchase more towers.

---

## Vision

MTD aims to deliver a fast, fun, and replayable tower defense experience inspired by games like Bloons TD and Clash Royale. The focus is on quick decision-making, strategic tower placement, and satisfying wave-based combat. The game is designed to be approachable for casual players while offering enough depth to reward strategic thinking.

---

## Features

- Four tower types: Cannon, Archer, Barracks, and Monastery
- Four enemy types: Pawn, Lancer, Archer, and Warrior — each with unique stats
- Six escalating waves of enemies with an intermission between each wave
- Friendly unit spawning from Archer, Barracks, and Monastery towers
- Gold reward system — enemies drop gold on defeat
- Tower health and damage system — enemies attack towers in range
- Main base health bar — game ends when the base is destroyed
- Placement restriction zones — towers can only be placed on grass
- Pause menu
- Main menu

---

## Project Links

- **GitHub Repo:** https://github.com/jezreel11/4250-Semester-Project
- **Trello Board:** https://trello.com/b/MTD (see board for sprint backlog and task tracking)

---

## Current Progress

Sprint 3 complete. The game features a fully functional wave system, tower placement with currency, enemy pathfinding and attack behavior, friendly unit spawning, and a working HUD with gold and base health display.

---

## Tech Stack

- **Engine:** Godot 4 (GDScript)
- **Version Control:** GitHub
- **Project Management:** Trello
- **Art Assets:** Sprout Lands tileset (licensed), custom unit sprites

---

## Developers' manual

### Quick Start
```bash
git clone https://github.com/jezreel11/4250-Semester-Project.git
cd 4250-Semester-Project
# Open in Godot 4 and press F5
```

### Project Structure
```
res://scenes/        # Game scenes (main, menu, towers, enemies, units)
res://scripts/       # GDScript code organized by system
res://assets/        # Sprites, tilesets, audio
```

### Main Systems
- **tower_manager.gd** — Place/remove towers, handle attacks
- **enemy_manager.gd** — Spawn enemies, damage, drops
- **wave_manager.gd** — Control wave progression
- **currency_manager.gd** — Track gold

### Code Style
```gdscript
func place_tower(tower_type: String, position: Vector2) -> bool:
    # Use type hints, snake_case for functions
    pass

const TOWER_COST = 100  # UPPER_CASE for constants
signal tower_placed     # Use signals for events
```

### Adding Features
**New Tower:** Duplicate a tower scene → Adjust stats in Inspector → Register in tower_manager  
**New Enemy:** Create enemy scene → Add to wave_manager wave data → Test

### Git Workflow
```bash
git checkout -b feature/your-feature
git commit -m "Clear description of change"
git push origin feature/your-feature
# Create Pull Request on GitHub
```

### Debug
```gdscript
print("Debug message")           # View in Output panel
# Set breakpoint: Click line number → F5 → Step through code
```

### Performance
Target 60 FPS. Use Area2D for range checks, cache get_node() results, call queue_free() on destroyed objects.

### Resources
- [Godot Docs](https://docs.godotengine.org/)
- [GitHub Repo](https://github.com/jezreel11/4250-Semester-Project)
- [Trello Board](https://trello.com/b/MTD)

