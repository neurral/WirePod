# WirePod Project Instructions

## Overview

WirePod is a cross-platform software ecosystem for running voice assistant servers on Anki Vector robots. It consists of two main components:

- **wire-pod**: The core server software (chipper) that enables voice commands on Anki Vector 1.0 and 2.0 robots
- **WirePod**: Cross-platform packaging and distribution system that creates user-installable packages of wire-pod for different operating systems

## Architecture

### Core Components

#### 1. Chipper Server (`wire-pod/chipper/`)
- **Purpose**: Main voice processing server that communicates with Vector robots
- **Technology**: Go with gRPC and HTTP APIs
- **Key Features**:
  - Speech-to-Text (STT) processing
  - Intent recognition and processing
  - Knowledge graph integration
  - Weather API support
  - Web-based configuration interface (port 8080)

#### 2. STT Services (`chipper/pkg/wirepod/stt/`)
Supports multiple speech recognition engines:
- **Vosk**: Offline, local STT (default for Android/iOS)
- **Whisper.cpp**: Offline Whisper model implementation
- **Coqui**: Online STT service
- **Houndify**: Cloud-based STT service
- **Leopard**: Picovoice's offline STT

#### 3. Cross-Platform Packaging (`WirePod/`)
Creates installable packages for:
- **Android** (APK with GUI app)
- **Windows** (ZIP installer)
- **macOS** (app bundle)
- **Linux** (direct installation)

### Key Directories Structure

```
wire-pod/                    # Core server code
├── chipper/                # Main server application
│   ├── pkg/
│   │   ├── initwirepod/   # Server initialization
│   │   ├── wirepod/       # Voice processing core
│   │   │   ├── stt/       # STT service implementations
│   │   │   ├── preqs/     # Preprocessing and requests
│   │   │   └── setup/     # Configuration setup
│   │   ├── vars/          # Configuration management
│   │   └── servers/       # gRPC/HTTP servers
│   ├── webroot/           # Web interface files
│   ├── intent-data/       # Intent recognition data
│   └── epod/              # Escape Pod configuration
└── vector-cloud/          # Robot communication layer

WirePod/                    # Packaging and distribution
├── android/               # Android APK builder
├── windows/               # Windows installer builder
├── macos/                 # macOS app builder
├── debian/                # Linux package builder
└── cross/                 # Cross-platform utilities
```

## Configuration System

### Configuration File (`apiConfig.json`)

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
- `STT_SERVICE`: STT provider (vosk, whisper.cpp, coqui, houndify, leopard)
- `STT_LANGUAGE`: Language code for offline STT services
- `WEATHERAPI_ENABLED`: Enable weather features
- `KNOWLEDGE_ENABLED`: Enable AI knowledge features
- `DEBUG_LOGGING`: Enable verbose logging

## Development Workflow

### Building for Different Platforms

#### Android APK
```bash
cd WirePod/android
./build.sh 1.0.0
# Requires: Android SDK, NDK, fyne, signing keystore
```

#### Windows Installer
```bash
cd WirePod/windows
./build.sh
# Builds: wire-pod-win-amd64.zip
```

#### macOS App
```bash
cd WirePod/macos
./build.sh
# Creates: WirePod.app bundle
```

#### Linux (Direct)
```bash
cd wire-pod
# Use setup.sh or manual compilation
```

### Development Setup

1. **Clone repositories**:
   ```bash
   git clone https://github.com/kercre123/wire-pod.git
   git clone https://github.com/neurral/WirePod.git
   ```

2. **Install dependencies**:
   - Go 1.18+
   - Platform-specific toolchains (Android NDK, mingw-w64, etc.)
   - External libraries (Opus, Ogg, Vosk)

3. **Build core server**:
   ```bash
   cd wire-pod/chipper
   go mod download
   go build ./cmd/coqui  # or other STT service
   ```

### Testing

- **Unit tests**: Run `go test` in individual packages
- **Integration testing**: Use the web interface at `http://localhost:8080`
- **Robot testing**: Requires physical Vector robot or simulation environment

## Key Features & Capabilities

### Voice Processing Pipeline
1. **Audio Capture**: Receives audio from robot via gRPC
2. **Speech Recognition**: Converts speech to text using selected STT service
3. **Intent Classification**: Matches text against intent database
4. **Knowledge Processing**: Queries AI services for responses
5. **Text-to-Speech**: Generates audio responses (when enabled)
6. **Response Delivery**: Sends responses back to robot

### Supported Integrations
- **OpenAI**: GPT models for knowledge responses
- **Weather APIs**: OpenWeatherMap, etc.
- **Custom Knowledge Graphs**: Intent-based conversation flows
- **mDNS Discovery**: Automatic robot detection on network

### Security & Networking
- **TLS Encryption**: All communications encrypted
- **Certificate Management**: Auto-generated certificates for robot communication
- **Escape Pod Mode**: Mimics official Anki servers
- **Port Configuration**: Flexible port assignment (443 default for EP mode)

## Common Development Tasks

### Adding New STT Service
1. Create new directory under `chipper/pkg/wirepod/stt/`
2. Implement `STT` interface with `Init()`, `STT()`, `Name()` methods
3. Add service to configuration options
4. Update build tags and dependencies

### Modifying Intent Processing
- Edit intent files in `chipper/intent-data/`
- Modify processing logic in `chipper/pkg/wirepod/preqs/`
- Update web interface for configuration

### Adding New Platform Support
1. Create platform directory under `WirePod/`
2. Implement build scripts for compilation and packaging
3. Add platform-specific dependencies and libraries
4. Update main WirePod build system

## Troubleshooting

### Common Issues
- **STT Service Not Working**: Check language configuration and model files
- **Robot Not Connecting**: Verify certificates and network configuration
- **Web Interface Not Loading**: Check port 8080 availability and firewall settings
- **Build Failures**: Ensure all platform toolchains and dependencies are installed

### Debug Mode
Set `DEBUG_LOGGING=true` for verbose output and detailed error messages.

## Deployment Considerations

### Production Setup
- Use Escape Pod mode for seamless robot integration
- Configure appropriate STT service based on privacy needs
- Set up proper firewall rules for robot communication
- Monitor logs for performance and error tracking

### Resource Requirements
- **Offline STT**: Requires model files (Vosk/Whisper)
- **Online STT**: Requires API keys and internet connectivity
- **AI Features**: Requires API keys for OpenAI or similar services
- **Storage**: ~500MB for models and web assets

## Contributing Guidelines

- Follow Go coding standards and project structure
- Test changes across multiple platforms when possible
- Update documentation for new features
- Maintain backward compatibility with existing configurations
- Use semantic versioning for releases

## Support Resources

- **Official Wiki**: https://github.com/kercre123/wire-pod/wiki
- **Installation Guide**: Comprehensive setup instructions
- **Troubleshooting**: Common issues and solutions
- **Community**: GitHub issues and discussions

This project enables Vector robots to have fully functional voice capabilities without relying on Anki's discontinued cloud services, providing a privacy-focused alternative with extensive customization options.