# SPARC IDE: The AI-Native Development Environment  
**Build your own intelligent IDE powered by Roo Code and the SPARC methodology**  

SPARC IDE is a customizable, open-source distribution of VSCode built for agentic software development. Inspired by tools like Windsurf and Cursor, it integrates Roo Code to enable prompt-driven development, autonomous agent workflows, and AI-native collaboration.

This project is designed for developers who want total control over their toolchain—whether you're coding, testing, or deploying intelligent systems.

---

## ✨ Key Features

- 🧠 Built-in support for **Roo Code**, enabling multi-model AI assistance  
- 🔁 Agentic workflows aligned with the **SPARC methodology** (Specification, Pseudocode, Architecture, Refinement, Completion)  
- ⚡ Pre-optimized for **OpenRouter**, **Claude**, **GPT-4**, and **Gemini**  
- 🎨 Fully customizable UI/UX for AI-native coding sessions  
- 📦 Cross-platform builds (Linux, macOS, Windows)  
- 🔐 MIT-licensed and telemetry-free via VSCodium  

---

## 🚀 Getting Started  

### 1. Clone and Build VSCodium

```bash
git clone https://github.com/VSCodium/vscodium.git
cd vscodium
yarn && yarn gulp vscode-linux-x64
````

Refer to [VSCodium Docs](https://vscodium.com) for Windows/macOS builds.

### 2. Modify Branding

Edit `product.json`:

```json
{
  "nameShort": "SPARC IDE",
  "nameLong": "SPARC IDE: AI-Powered Development Environment",
  "extensionsGallery": {
    "serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery",
    "cacheUrl": "https://vscode.blob.core.windows.net/gallery/index",
    "itemUrl": "https://marketplace.visualstudio.com/items"
  }
}
```

---

## 🤖 Roo Code Integration

### 1. Pre-install Roo Code

```bash
mkdir -p extensions
curl -L https://marketplace.visualstudio.com/_apis/public/gallery/publishers/RooVeterinaryInc/vsextensions/roo-cline/3.2.0/vspackage > extensions/roo-code.vsix
```

### 2. Configure Default AI Settings

Add to `settings.json`:

```json
"roo-code.apiKey": "YOUR_OPENROUTER_KEY",
"roo-code.defaultModel": "sonnet",
"roo-code.customModes": {
  "QA Engineer": {
    "prompt": "You are a QA engineer... detect edge cases and write tests",
    "tools": ["readFile", "writeFile", "runCommand"]
  }
}
```

---

## 🧩 AI-Centric UI Layout

### Recommended Themes

* Dracula Pro
* Material Theme

### Suggested Keybindings

```json
{
  "key": "ctrl+shift+a",
  "command": "roo-code.chat",
  "when": "editorTextFocus"
}
```

### Panel Setup

* Left: File Explorer + Roo Code
* Bottom: Terminal + Action Logs
* Right: Extensions (GitLens, Prettier)

---

## 🛠️ Building & Packaging

### Build Commands

```bash
yarn gulp vscode-linux-x64
yarn gulp vscode-win32-x64
yarn gulp vscode-darwin-x64
```

### Packaging

* Linux:

  ```bash
  sudo yarn run gulp vscode-linux-x64-build-deb
  ```

* Windows: Use NSIS / WiX Toolset

* macOS: Use `.dmg` bundler with custom icon

---

## ✅ Testing

* Validate Roo Code chat, tools, and prompt injection
* Test multi-model switching (GPT-4, Claude, Gemini)
* Run compatibility checks for GitLens, ESLint, Prettier

---

## 📦 Publish & Distribute

### GitHub Setup

1. Fork and push SPARC IDE codebase
2. Document install and build instructions

### GitHub Actions CI

```yaml
name: Build SPARC IDE  
on: [push]  
jobs:  
  build:  
    runs-on: ubuntu-latest  
    steps:  
      - uses: actions/checkout@v4  
      - name: Install dependencies  
        run: yarn install  
      - name: Build Linux  
        run: yarn gulp vscode-linux-x64  
      - name: Upload artifacts  
        uses: actions/upload-artifact@v3  
        with:  
          name: SPARC-IDE-linux  
          path: out/vscode-linux-x64  
```

---

## 🔧 Advanced Features

* **Custom LLM endpoints** via Hugging Face or OpenRouter
* **Multi-agent workflows** for parallel reasoning
* **Browser automation** for end-to-end testing
* **Minimal mode** for distraction-free prompt engineering

---

## 📚 Resources & Docs

* [Roo Code on GitHub](https://github.com/qpd-v/Roo-Code)
* [VSCodium](https://vscodium.com)
* [SPARC Methodology](https://github.com/ruvnet/sparc)
* [OpenRouter](https://openrouter.ai)

---

## 🤝 Contributing

We welcome community contributions and extensions! Fork the repo, make your improvements, and open a PR.

---

## 🧠 Why SPARC IDE?

SPARC IDE doesn’t just integrate AI—it evolves with it. You’re not just coding. You’re collaborating with intelligent agents, accelerating the build-test-reflect cycle, and optimizing your own workflows. It’s the first IDE designed for recursive, autonomous software development, entirely on your terms.

---

## 📢 License

MIT License — free to use, modify, and distribute.

---

Built by [rUv](https://github.com/ruvnet) • Powered by Roo Code • Made for agentic engineers.
  
