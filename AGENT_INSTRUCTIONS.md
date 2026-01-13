# WirePod Project - Agent Instructions

## Project Overview

WirePod is a sophisticated cross-platform ecosystem designed to enable voice assistant functionality on Anki Vector 1.0 and 2.0 robots. The project consists of two main components:

- **wire-pod**: Core server software (chipper) providing voice processing capabilities
- **WirePod**: Cross-platform packaging system creating user-installable applications

**Key Purpose**: Provide privacy-focused, customizable voice capabilities to Vector robots without reliance on Anki's discontinued cloud services.

## Architecture & Components

### Core Server (wire-pod/chipper/)
- **Location**: `/Users/rxcs/Dev/etal/wire-pod/chipper/`
- **Technology**: Go with gRPC/HTTP APIs
- **Main Functionality**:
  - Speech-to-Text processing
  - Intent recognition and classification
  - Knowledge graph integration (OpenAI, etc.)
  - Weather API integration
  - Web-based configuration interface (port 8080)
  - Robot communication via gRPC

### STT (Speech-to-Text) Services
Multiple STT engines supported in `chipper/pkg/wirepod/stt/`:
- **Vosk**: Offline, local STT (default, recommended)
- **Whisper.cpp**: Offline Whisper models
- **Coqui**: Online STT service
- **Houndify**: Cloud-based STT
- **Leopard**: Picovoice offline STT

### Cross-Platform Packaging (WirePod/)
Creates installable packages for:
- **Android**: APK with GUI app (`WirePod/android/`)
- **Windows**: ZIP installer (`WirePod/windows/`)
- **macOS**: App bundle (`WirePod/macos/`)
- **Linux**: Direct installation (`WirePod/debian/`)

### Vector Cloud Communication Layer
- **Location**: `wire-pod/vector-cloud/`
- **Purpose**: Handles robot communication and cloud service emulation
- **Key Components**:
  - Gateway service for robot connectivity
  - IPC (Inter-Process Communication) management
  - Message handling and routing
  - Certificate management

## Development Environment Setup

### Prerequisites
- **Go**: Version 1.18+ (project uses Go 1.18)
- **Platform Toolchains**:
  - Android: Android SDK, NDK, fyne framework
  - Windows: MinGW-w64 toolchain
  - macOS: Xcode command line tools
- **External Libraries**:
  - Opus audio codec
  - Ogg container format
  - Vosk/STT model files

### Repository Structure
```
WirePod/                    # Cross-platform packaging
├── android/               # Android APK builder
├── windows/               # Windows installer
├── macos/                # macOS app builder
├── debian/               # Linux packages
└── cross/                # Cross-platform utilities

wire-pod/                  # Core server code (submodule)
├── chipper/              # Main server application
│   ├── pkg/
│   │   ├── wirepod/      # Voice processing core
│   │   │   ├── stt/      # STT implementations
│   │   │   ├── preqs/    # Request processing
│   │   │   └── setup/    # Configuration
│   │   ├── vars/         # Global variables
│   │   └── servers/      # gRPC/HTTP servers
│   ├── webroot/          # Web interface
│   ├── intent-data/      # Intent recognition data
│   └── epod/             # Escape Pod certificates
└── vector-cloud/         # Robot communication layer
```

## Key Development Tasks

### 1. Building for Different Platforms

#### Android APK Build
```bash
cd WirePod/android
./build.sh 1.0.0
```
**Requirements**:
- Android SDK/NDK installed
- fyne framework (`go install fyne.io/fyne/v2/cmd/fyne@latest`)
- Signing keystore at `key/ks.jks`
- Password file at `key/passwd`

#### Windows Build
```bash
cd WirePod/windows
./build.sh
```
**Output**: `wire-pod-win-amd64.zip`

#### macOS Build
```bash
cd WirePod/macos
./build.sh
```
**Output**: `WirePod.app` bundle

### 2. Core Server Development

#### Building Chipper Server
```bash
cd wire-pod/chipper
go mod download
# Build specific STT service
go build ./cmd/vosk        # Default recommended
go build ./cmd/coqui       # Alternative
go build ./cmd/leopard     # Picovoice
```

#### Configuration Setup
Key configuration files:
- `apiConfig.json`: Main configuration (weather, knowledge, STT, server settings)
- `source.sh`: Environment variables for STT services
- Certificates: Auto-generated or custom for robot communication

### 3. STT Service Integration

#### Adding New STT Service
1. Create directory under `chipper/pkg/wirepod/stt/`
2. Implement `STT` interface:
   ```go
   type STTService interface {
       Init() error
       STT(audioData []byte) (string, error)
       Name() string
   }
   ```
3. Update build tags and dependencies
4. Add to configuration options

#### Environment Variables for STT
- `STT_SERVICE`: vosk, whisper.cpp, coqui, houndify, leopard
- `STT_LANGUAGE`: Language code (en-US, etc.)
- Service-specific keys (PICOVOICE_APIKEY, etc.)

### 4. Intent Processing

#### Modifying Intent Recognition
- **Location**: `chipper/intent-data/` - JSON files for different languages
- **Processing Logic**: `chipper/pkg/wirepod/preqs/`
- **Web Interface**: Update configuration UI in `webroot/`

#### Custom Intent Format
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

### 5. Web Interface Development

#### File Locations
- **Frontend**: `chipper/webroot/`
- **Assets**: `webroot/assets/` (GIFs, CSS, JS)
- **Configuration Pages**: `webroot/setup.html`, `webroot/initial.html`

#### Development Server
- Runs on port 8080
- Provides robot setup and configuration interface
- SDK app available at `webroot/sdkapp/`

### 6. Vector Cloud Integration

#### Robot Communication
- **IPC Manager**: `vector-cloud/gateway/ipc_manager.go`
- **Message Handler**: `vector-cloud/gateway/message_handler.go`
- **Certificate Management**: Auto-generated certificates for secure communication

#### Escape Pod Mode
- **Purpose**: Mimics official Anki servers for seamless robot integration
- **Certificates**: Pre-configured at `chipper/epod/`
- **Configuration**: Set `epconfig: true` in server config

### 7. Cross-Platform Utilities

#### Common Build Tasks
- **Location**: `WirePod/cross/`
- **Purpose**: Shared utilities for different platform builds
- **Components**:
  - `all/all.go`: Cross-platform functions
  - Platform-specific helpers (`mac/`, `win/`, `podapp/`)

## Configuration Management

### apiConfig.json Structure
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
- `DEBUG_LOGGING=true`: Enable verbose logging
- `WEATHERAPI_ENABLED`: Enable weather features
- `KNOWLEDGE_ENABLED`: Enable AI knowledge features
- `STT_SERVICE`: STT provider selection

## Testing & Deployment

### Local Development Testing
1. **Unit Tests**: `go test` in individual packages
2. **Web Interface**: Access `http://localhost:8080`
3. **Robot Testing**: Requires physical Vector robot or simulation

### Platform-Specific Testing
- **Android**: Test APK on Android device
- **Windows**: Test installer on Windows VM
- **macOS**: Test app bundle on macOS system
- **Linux**: Test direct installation

### Deployment Checklist
- [ ] All dependencies installed
- [ ] STT service configured and tested
- [ ] Certificates generated/configured
- [ ] Web interface accessible
- [ ] Robot communication working
- [ ] Cross-platform builds successful

## Common Development Patterns

### 1. Adding New Features
1. Identify component location (chipper pkg, webroot, vector-cloud)
2. Implement feature following existing patterns
3. Update configuration if needed
4. Test across platforms
5. Update documentation

### 2. Modifying STT Processing
1. Review existing STT implementations
2. Add new service or modify existing
3. Update build tags and dependencies
4. Test audio processing pipeline
5. Update web configuration UI

### 3. Robot Communication Changes
1. Review vector-cloud code structure
2. Understand IPC/message flow
3. Implement changes in appropriate component
4. Test with robot (if available)
5. Update certificates if needed

### 4. Web Interface Updates
1. Modify HTML/CSS/JS in `webroot/`
2. Update Go handlers if needed
3. Test responsive design
4. Verify mobile compatibility
5. Update setup/configuration flows

## Troubleshooting Guide

### Build Issues
- **Missing dependencies**: Run `./setup.sh` in wire-pod directory
- **Go module issues**: `go mod download` and `go mod tidy`
- **Platform toolchains**: Verify Android NDK, MinGW, etc. are installed
- **STT model files**: Check model downloads and paths

### Runtime Issues
- **STT not working**: Verify language configuration and model files
- **Robot not connecting**: Check certificates and network configuration
- **Web interface not loading**: Verify port 8080 availability
- **Audio issues**: Check Opus codec and audio pipeline

### Debug Mode
Set `DEBUG_LOGGING=true` for detailed error messages and verbose output.

## Best Practices

### Code Organization
- Follow Go project structure conventions
- Maintain separation between chipper, vector-cloud, and packaging
- Use consistent error handling patterns
- Document public APIs and interfaces

### Testing
- Test builds across all supported platforms
- Verify STT accuracy with various audio inputs
- Test robot communication when possible
- Validate web interface on multiple devices

### Security
- Keep API keys secure (environment variables, not committed)
- Use proper TLS certificates for robot communication
- Validate all external API inputs
- Follow principle of least privilege

### Performance
- Optimize STT processing for target hardware
- Minimize memory usage on resource-constrained devices
- Profile Go applications for bottlenecks
- Cache frequently used data

## Support Resources

- **Official Wiki**: https://github.com/kercre123/wire-pod/wiki
- **Installation Guide**: Comprehensive setup instructions
- **Community**: GitHub issues and discussions
- **Project Structure**: Refer to PROJECT_INSTRUCTIONS.md for detailed architecture

This project represents a sophisticated robotics and AI integration effort. Changes should be made carefully with consideration for the multi-platform nature and robot hardware constraints.