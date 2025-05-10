# Roblox Project

[![Roblox](https://img.shields.io/badge/Roblox-00A2FF?style=flat&logo=roblox&logoColor=white)](https://www.roblox.com)
[![Rojo](https://img.shields.io/badge/Rojo-7.5.1-blue)](https://github.com/rojo-rbx/rojo)
[![Wally](https://img.shields.io/badge/Wally-0.3.2-orange)](https://github.com/UpliftGames/wally)

A Roblox project using modern development tools and practices.

## Prerequisites

Before you begin, ensure you have the following installed:

- [Roblox Studio](https://www.roblox.com/create)
- [Rust](https://rustup.rs/) (for Selene)
- [Aftman](https://github.com/LPGhatguy/aftman) (Package Manager)

## Installation

1. **Install Aftman** (if not already installed)
   Follow the installation instructions at [github.com/LPGhatguy/aftman](https://github.com/LPGhatguy/aftman)

2. **Setup Project**
   ```bash
   # Clone the repository
   git clone https://github.com/JonCGroberg/roblox.git
   cd roblox

   # Install development tools (Wally, StyLua, etc.)
   aftman install

   # Install dependencies
   wally install

   # Install Selene (Lua Linter) - Optional
   cargo install selene
   ```

## Development

### Running the Project

1. **Build and Run**
   ```bash
   # Build the place file
   rojo build -o "roblox.rbxlx"

   # Start the Rojo server
   rojo serve
   ```

2. **Open in Roblox Studio**
   - Open `roblox.rbxlx` in Roblox Studio
   - The Rojo plugin will automatically sync your local files

### Testing

1. **Enable Testing**
   Add to your Roblox Studio `ClientAppSettings.json`:
   ```json
   {
       "FFlagEnableLoadModule": true
   }
   ```

2. **Configure Jest**
   Create `jest.config.lua` in your source directory:
   ```lua
   return {
       testMatch = { "**/*.spec" }
   }
   ```

3. **Run Tests**
   Use the provided test runner script.

## Dependencies

This project uses [Wally](https://github.com/UpliftGames/wally) for package management:

- Jest (v3.10.0)
- JestGlobals (v3.10.0)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Resources

- [Rojo Documentation](https://rojo.space/docs)
- [Jest Lua Documentation](https://jsdotlua.github.io/jest-lua/)
- [Wally Documentation](https://github.com/UpliftGames/wally)
- [Selene Documentation](https://kampfkarren.github.io/selene/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
