# Civil War Battlefield ⚔️

A real-time tactical battle game built with Godot 4.4. Command Union forces against Confederate AI in strategic warfare.

**[🎮 Play Now on GitHub Pages](https://locutusaibot-blip.github.io/civil-war-battlefield/)**

---

## 🎬 Gameplay

Take control of a three-unit Union army and defeat the Confederate forces:
- **Cavalry** charges from the front lines
- **Infantry** holds the center
- **Artillery** provides ranged support from the rear

Master the rock-paper-scissors unit counter system and use terrain to your advantage.

---

## 🎮 Controls

| Key | Action |
|-----|--------|
| **WASD / Arrows** | Move selected unit |
| **1** | Select Infantry |
| **2** | Select Cavalry |
| **3** | Select Artillery |
| **Tab** | Cycle through units |
| **Esc** | Pause/Resume |
| **Space / Enter** | Restart (after battle ends) |

---

## ⚔️ Unit Types

| Unit | HP | Speed | Strength | Special |
|------|-----|-------|----------|---------|
| **Infantry** | 100 | Medium | Strong vs Artillery | Balanced fighter |
| **Cavalry** | 80 | Fast | Strong vs Infantry | Charge attack (20 dmg, 3s cooldown) |
| **Artillery** | 60 | Slow | Strong vs Cavalry | Ranged cannonballs (400px range) |

**Counter Bonus:** Attacking your counter unit deals 1.5× damage!

---

## 🏞️ Terrain Features

- **Hills:** Units on hills take 25% less damage
- **Formation matters:** Position your units strategically

---

## 🖥️ System Requirements

- **Web:** Any modern browser with WebGL support
- **Desktop:** Godot 4.4+ (Windows, macOS, Linux)

---

## 🛠️ Development

Built with **Godot Engine 4.4**

### Project Structure
```
civil-war-battlefield/
├── scenes/
│   ├── units/          # Unit types (BaseUnit, Infantry, Cavalry, Artillery)
│   ├── ai/             # Enemy AI controller
│   ├── ui/             # HUD and interface
│   ├── battlefield/    # Terrain and battlefield logic
│   └── main.tscn       # Main game scene
├── scripts/
│   └── game_manager.gd # Game state management
└── project.godot       # Godot project file
```

### Running Locally

1. Clone the repository:
   ```bash
   git clone https://github.com/freaxnx01/civil-war-battlefield.git
   ```

2. Open in Godot 4.4+

3. Press F5 to run

---

## 🌐 Web Build

This game is exported for web using Godot's HTML5 export and hosted on **GitHub Pages**.

---

## 📜 License

MIT License — feel free to use, modify, and distribute!

---

## 🙏 Credits

- Game Design & Development: freaxnx01
- Engine: [Godot Engine](https://godotengine.org/)

---

*"War is never pretty, but this pixel battlefield sure is fun!"* 🎖️
