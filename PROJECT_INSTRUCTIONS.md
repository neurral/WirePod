# WirePod Project Instructions

## Overview

WirePod is a sophisticated, cross-platform software ecosystem designed to run custom, local voice assistant servers for Anki/Digital Dream Labs Vector 1.0 and 2.0 robots. The project is designed to provide privacy-focused, customizable voice capabilities without relying on discontinued official cloud services.

It consists of two main components:
- **wire-pod**: The core server software (chipper) that provides voice processing capabilities.
- **WirePod**: The cross-platform packaging system that creates user-installable applications for various operating systems.

---

## Architecture & Components

### Core Components

#### 1. Chipper Server (`wire-pod/chipper/`)
- **Purpose**: Main voice processing server that communicates with the Vector robot.
- **Technology**: Go with gRPC and HTTP APIs.
- **Key Features**: Speech-to-Text (STT) processing, intent classification, knowledge graph integration, weather API support, and a web configuration interface.

#### 2. STT Services (`wire-pod/chipper/pkg/wirepod/stt/`)
- **Purpose**: Multiple speech recognition engines implemented under a common interface.
- **Engines**: Vosk (local, default), Whisper, Whisper.cpp, Coqui, Houndify, Leopard (Picovoice).

#### 3. Vector Cloud Communication Layer (`wire-pod/vector-cloud/`)
- **Purpose**: Handles robot communication and Emulation/Escape Pod mode gateway.
- **Key Components**:
  - Gateway service for robot connectivity
  - IPC (Inter-Process Communication) management
  - Message handling and routing
  - Certificate management

#### 4. Cross-Platform Packaging (`WirePod/`)
- **Purpose**: Creates installer packages for:
  - **Android**: APK with GUI interface ([WirePod/android/](file:///Volumes/Dev/etal/Vector/WirePod/android/))
  - **Windows**: ZIP installer ([WirePod/windows/](file:///Volumes/Dev/etal/Vector/WirePod/windows/))
  - **macOS**: App bundle ([WirePod/macos/](file:///Volumes/Dev/etal/Vector/WirePod/macos/))
  - **Linux/Debian**: Debian packages and script installation ([WirePod/debian/](file:///Volumes/Dev/etal/Vector/WirePod/debian/))
  - **Cross Utilities**: Shared cross-platform packaging logic ([WirePod/cross/](file:///Volumes/Dev/etal/Vector/WirePod/cross/))

### Directory Structure

```
WirePod/                    # Packaging and distribution
├── android/                # Android APK builder
├── windows/                # Windows installer builder
├── macos/                  # macOS app builder
├── debian/                 # Linux package builder
├── cross/                  # Cross-platform packaging utilities
└── third-party/            # Vendored third-party dependencies

wire-pod/                   # Core server code (Git submodule)
├── chipper/                # Main chipper server application
│   ├── cmd/                # Build targets (vosk, coqui, leopard, experimental)
│   ├── intent-data/        # Intent classification database
│   ├── webroot/            # Web interface files (port 8080)
│   ├── epod/               # Escape Pod certificate templates
│   ├── jdocs/              # Robot JDOCS storage
│   ├── plugins/            # Plugin system
│   └── pkg/
│       ├── initwirepod/    # Server initialization & web config
│       ├── scripting/      # Lua scripting integration
│       └── wirepod/        # Voice processing core
│           ├── config-ws/  # Configuration websocket
│           ├── localization/ # Localization support
│           ├── preqs/      # Preprocessing and intent requests
│           ├── sdkapp/     # Embedded Vector SDK application
│           ├── setup/      # Configuration setup
│           ├── speechrequest/ # Speech request handling
│           ├── stt/        # STT engine implementations
│           └── ttr/        # Text-to-response (knowledge graph, commands)
└── vector-cloud/           # Robot communication/gateway layer
```

---

## Development Setup

### Prerequisites
- **Go**: Version 1.18+ (project uses Go 1.21/1.18 compatibility features).
- **Platform Toolchains**:
  - Android: Android SDK/NDK, `fyne` package (`go install fyne.io/fyne/v2/cmd/fyne@latest`).
  - Windows: MinGW-w64 toolchain.
  - macOS: Xcode command line tools.
- **External Dependencies**: Opus audio codec, Ogg container format, STT models (Vosk/Whisper). All dependencies should be resolved locally (see [THIRD_PARTY_REPOSITORIES.md](file:///Volumes/Dev/etal/Vector/WirePod/THIRD_PARTY_REPOSITORIES.md) for local replacements in `go.mod`).

### Development Setup
1. **Clone the repositories**:
   ```bash
   git clone https://github.com/kercre123/wire-pod.git
   git clone https://github.com/neurral/WirePod.git
   ```
2. **Install dependencies**:
   Run `./setup.sh` in the `wire-pod` directory to set up local STT models and compile any system dependencies.
3. **Build Core Chipper Server**:
   ```bash
   cd wire-pod/chipper
   go mod download
   # Build the server with specific STT tags (Vosk is default)
   go build ./cmd/vosk
   ```

---

## Development Workflow & Platform Builds

### Android APK Build
```bash
cd WirePod/android
./build.sh 1.0.0
```
- **Requirements**:
  - NDK/SDK paths configured.
  - Android signing keystore located at `key/ks.jks` and password file at `key/passwd`.

### Windows Build
```bash
cd WirePod/windows
./build.sh
```
- **Output**: `wire-pod-win-amd64.zip`
- **Requirements**: MinGW cross-compiler installed.

### macOS Build
```bash
cd WirePod/macos
./build.sh
```
- **Output**: `WirePod.app` bundle.

### Linux (Direct Installation)
Refer to `./setup.sh` or compile/run the Go target directly from the `wire-pod` folder.

---

## Configuration System

### `apiConfig.json` Structure
The server configuration is stored in `apiConfig.json`. Example structure:
```json
{
  "weather": {
    "enable": false,
    "provider": "openweathermap",
    "key": "your-api-key",
    "unit": "metric"
  },
  "knowledge": {
    "enable": true,
    "provider": "openai",
    "key": "your-openai-key",
    "model": "gpt-4",
    "intentgraph": true,
    "robotName": "Vector",
    "openai_prompt": "You are Vector...",
    "save_chat": false,
    "commands_enable": true
  },
  "STT": {
    "provider": "vosk",
    "language": "en-US"
  },
  "server": {
    "epconfig": true,
    "port": "443"
  }
}
```

### Environment Variables
- `DEBUG_LOGGING=true`: Enable verbose logging.
- `WEATHERAPI_ENABLED`: Enable/disable weather checks.
- `KNOWLEDGE_ENABLED`: Enable/disable OpenAI/Knowledge checks.
- `STT_SERVICE`: Selected STT provider (`vosk`, `whisper.cpp`, `coqui`, `houndify`, `leopard`).
- `STT_LANGUAGE`: Selected language (e.g. `en-US`).

---

## Common Development Tasks

### 1. Adding a New STT Service
1. Create a subpackage under `wire-pod/chipper/pkg/wirepod/stt/` (e.g., `stt/mynewstt/`).
2. Follow the pattern of existing STT implementations (e.g., `stt/vosk/` or `stt/whisper.cpp/`). Each STT engine is a standalone package with build-tag-guarded compilation.
3. Create a corresponding build target under `wire-pod/chipper/cmd/` for standalone builds.
4. Update build tags in Go files, register the service in the initialization flow, and add it as an option in the web UI config.

### 2. Modifying Intent Processing
- UTTERANCES are registered in language JSON files in `wire-pod/chipper/intent-data/`.
- Intent parsing and match handlers are located in `wire-pod/chipper/pkg/wirepod/preqs/`.
- Custom Intents can be registered following this schema:
  ```json
  {
    "intents": [
      {
        "name": "custom_intent",
        "utterances": ["custom phrase"],
        "handler": "custom_handler"
      }
    ]
  }
  ```

### 3. Web Interface Development
- **Assets & Static Pages**: Located under `wire-pod/chipper/webroot/`.
- **Pages**: `index.html` (landing page), `setup.html` (initial robot configuration), `initial.html` (main management dashboard), and `sdkapp/` (embedded Vector SDK application).
- The web configuration interface runs on port `8080` by default.
- The Escape Pod / robot communication gateway runs on port `443` (TLS) — these are separate services.

### 4. Vector Cloud & Robot Gateway
- Gateway and Inter-Process Communication (IPC) logic is located in `wire-pod/vector-cloud/`.
- Configured via IPC and gateway message handlers. Emulates official Anki servers securely by serving TLS certificates located under `wire-pod/chipper/epod/`.

---

## Testing & Deployment

### Testing Guidelines
- **Unit Tests**: Run `go test ./...` in `wire-pod/chipper/` to test logic.
- **Integration/Web**: Run the server locally, visit `http://localhost:8080` and verify configuration screens.
- **Robot Interaction**: Connect a physical Vector robot configured to point to your development server. Ensure TLS certificates and ports (port 443 / Escape Pod emulation) are aligned.

### Deployment Checklist
- [ ] Local third-party dependencies resolved (e.g., `go.mod` replace directives pointing to local clones).
- [ ] STT engine and matching model downloaded/active.
- [ ] Certs generated under `/epod/` if running in Escape Pod mode.
- [ ] Port `443` (for Escape Pod) or target port open in firewall.
- [ ] Build compiled for the target platform.

---

## Best Practices

### Code & Structure
- Keep `wire-pod` core voice logic separate from platform packaging files under `WirePod/`.
- Keep environment configurations out of code; utilize `apiConfig.json` and environmental variables.
- Maintain backward compatibility with existing robot endpoints.

### Performance
- Optimize speech processing pipelines for resource-constrained systems (Vosk models, local memory usage).
- Cache intent resolution patterns and recurring weather/API calls.

---

## Support Resources
- **Wiki**: https://github.com/kercre123/wire-pod/wiki
- **Original Source**: https://github.com/kercre123/wire-pod
