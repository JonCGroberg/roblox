# Island Tycoon

[![Roblox](https://img.shields.io/badge/Roblox-00A2FF?style=flat\&logo=roblox\&logoColor=white)](https://www.roblox.com)
[![Rojo](https://img.shields.io/badge/Rojo-7.5.1-blue)](https://github.com/rojo-rbx/rojo)
[![Wally](https://img.shields.io/badge/Wally-0.3.2-orange)](https://github.com/UpliftGames/wally)

## Table of Contents

1. [Prerequisites](#⚙️-prerequisites)
2. [Installation](#📥-installation)
3. [Development](#🚀-development)
   * [Running the Project](#running-the-project)
   * [Open in Roblox Studio](#open-in-roblox-studio)
4. [Dependencies](#dependencies)
5. [Contributing](#contributing)
6. [Resources](#resources)
7. [License](#license)


## ⚙️ Prerequisites

Make sure you have:

* [Roblox Studio](https://www.roblox.com/create)
* [Aftman](https://github.com/LPGhatguy/aftman)

## 📥 Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/JonCGroberg/roblox.git
   ```
2. **Enter the project directory**

   ```bash
   cd roblox
   ```
3. **Install development tools**

   ```bash
   aftman install
   ```
4. **Install dependencies**

   ```bash
   wally install
   ```

## 🚀 Development

### Running the Project

You have two ways to develop and sync your project:

#### VS Code Extension (Recommended)
   - Install the Rojo VS Code extension for live syncing between your code editor and Roblox Studio.

#### Rojo CLI

 1. **Build the place file**
  ```bash
  rojo build -o roblox.rbxlx
  ```
 2. **Start the Rojo server**

  ```bash
  rojo serve
  ```

### Open in Roblox Studio

Open `roblox.rbxlx`; Rojo will auto-sync your files live from VsCode to Roblox Studio.


## 🔗 Dependencies

* **Wally** – Lua package manager
* **Rojo** – Build & sync tool
* **Aftman** – Package manager

## 🤝 Contributing

1. Fork the repo
2. Create a feature branch

   ```bash
   git checkout -b feature/name
   ```
3. Commit changes

   ```bash
   git commit -m "Add feature"
   ```
4. Push & open PR

   ```bash
   git push origin feature/name
   ```

## 📚 Resources

* [Rojo Docs](https://rojo.space/docs)
* [Wally](https://github.com/UpliftGames/wally)

## 📝 License

MIT License. See [LICENSE](LICENSE).
