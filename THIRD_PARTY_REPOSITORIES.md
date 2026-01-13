# WirePod Third-Party Repositories

## Overview

This document summarizes all external GitHub repositories that have been cloned locally to create a self-contained WirePod project without external dependencies.

## Cloned Repositories

All repositories have been cloned to `/Users/rxcs/Dev/etal/WirePod/third-party/github.com/` with their original GitHub structure preserved.

### Go Import Dependencies

| Original Repository | Local Path | Purpose | Status |
|---------------------|------------|---------|--------|
| `github.com/digital-dream-labs/api` | `third-party/github.com/digital-dream-labs/api/` | Chipper protocol buffers | ✅ Cloned |
| `github.com/fforchino/vector-go-sdk` | `third-party/github.com/fforchino/vector-go-sdk/` | Vector robot SDK | ✅ Cloned |
| `github.com/sashabaranov/go-openai` | `third-party/github.com/sashabaranov/go-openai/` | OpenAI client library | ✅ Cloned |
| `github.com/bramvdbogaerde/go-scp` | `third-party/github.com/bramvdbogaerde/go-scp/` | SCP client for robot deployment | ✅ Cloned |
| `github.com/pkg/errors` | `third-party/github.com/pkg/errors/` | Error handling utilities | ✅ Cloned |
| `github.com/soundhound/houndify-sdk-go` | `third-party/github.com/soundhound/houndify-sdk-go/` | Houndify STT service | ✅ Cloned |
| `github.com/vadv/gopher-lua-libs` | `third-party/github.com/vadv/gopher-lua-libs/` | Lua scripting libraries | ✅ Cloned |
| `github.com/yuin/gopher-lua` | `third-party/github.com/yuin/gopher-lua/` | Lua runtime for Go | ✅ Cloned |
| `github.com/wlynxg/anet` | `third-party/github.com/wlynxg/anet/` | Network utilities (Android) | ✅ Cloned |

### Build Script Dependencies

| Original Repository | Local Path | Purpose | Status |
|---------------------|------------|---------|--------|
| `github.com/alphacep/vosk-api` | `third-party/github.com/alphacep/vosk-api/` | Vosk STT API and models | ✅ Cloned |
| `github.com/ggerganov/whisper.cpp` | `third-party/github.com/ggerganov/whisper.cpp/` | Whisper.cpp STT implementation | ✅ Cloned |
| `github.com/coqui-ai/STT` | `third-party/github.com/coqui-ai/STT/` | Coqui STT framework | ✅ Cloned |
| `github.com/asticode/go-asticoqui` | `third-party/github.com/asticode/go-asticoqui/` | Go bindings for Coqui | ✅ Cloned |
| `github.com/xiph/ogg` | `third-party/github.com/xiph/ogg/` | Ogg container format | ✅ Cloned |
| `github.com/xiph/opus` | `third-party/github.com/xiph/opus/` | Opus audio codec | ✅ Cloned |

## Next Steps

### 1. Update Go Import Paths

The following files need their import paths updated to point to local repositories:

#### WirePod (packaging) - go.mod
- `github.com/digital-dream-labs/api v0.0.0-20210824232136-8cc90c1bb12c`
- `github.com/digital-dream-labs/hugh v0.0.0-20210210154335-f4159b9fcd5f`
- `github.com/fforchino/vector-go-sdk v0.0.0-20231108155304-62168f3595d6`
- `github.com/go-ole/go-ole v1.3.0`
- `github.com/soheilhy/cmux v0.1.5`
- `github.com/wlynxg/anet v0.0.1`

#### WirePod Android - android/main.go
- `github.com/wlynxg/anet`

### 2. Update WirePod Go Imports

#### wire-pod/chipper/pkg/wirepod/ttr/matchIntentSend.go
- `pb "github.com/digital-dream-labs/api/go/chipperpb"`

#### wire-pod/chipper/pkg/wirepod/ttr/kgsim_cmds.go
- `github.com/fforchino/vector-go-sdk/pkg/vector`
- `github.com/fforchino/vector-go-sdk/pkg/vectorpb`
- `github.com/sashabaranov/go-openai`

#### wire-pod/chipper/pkg/wirepod/ttr/kgsim.go
- `github.com/fforchino/vector-go-sdk/pkg/vector`
- `github.com/fforchino/vector-go-sdk/pkg/vectorpb`
- `github.com/sashabaranov/go-openai`

#### wire-pod/chipper/pkg/wirepod/setup/ssh.go
- `scp "github.com/bramvdbogaerde/go-scp"`

#### wire-pod/chipper/pkg/wirepod/sdkapp/server.go
- `github.com/fforchino/vector-go-sdk/pkg/vectorpb`

#### wire-pod/chipper/pkg/wirepod/preqs/knowledgegraph.go
- `pb "github.com/digital-dream-labs/api/go/chipperpb"`
- `github.com/pkg/errors`
- `github.com/soundhound/houndify-sdk-go`

#### wire-pod/chipper/pkg/scripting/scripting.go
- `github.com/fforchino/vector-go-sdk/pkg/vector`
- `github.com/fforchino/vector-go-sdk/pkg/vectorpb`
- `lualibs "github.com/vadv/gopher-lua-libs"`
- `lua "github.com/yuin/gopher-lua"`

### 3. Update Build Scripts

#### wire-pod/setup.sh
- Line 212: `https://github.com/alphacep/vosk-api/releases/download/v${VOSK_VER}/${VOSK_ARCHIVE}`
- Line 234: `git clone https://github.com/ggerganov/whisper.cpp.git`
- Lines 280, 285, 289: `https://github.com/coqui-ai/STT/releases/download/v1.3.0/...`
- Lines 297-298: `github.com/asticode/go-asticoqui/...`

#### WirePod/windows/build.sh
- Line 35: `git clone https://github.com/xiph/ogg --depth=1`
- Line 47: `git clone https://github.com/xiph/opus --depth=1`
- Line 59: `https://github.com/alphacep/vosk-api/releases/download/v0.3.45/vosk-win64-0.3.45.zip`

#### WirePod/macos/build.sh
- Line 43: `git clone https://github.com/xiph/opus --depth=1`
- Line 78: `https://github.com/alphacep/vosk-api/releases/download/v0.3.42/vosk-osx-0.3.42.zip`

#### WirePod/android/build.sh (Dockerfile)
- Line 74: `https://github.com/alphacep/vosk-api/releases/download/v${VOSK_VERSION}/${VOSK_PKG}`

### 4. Update go.mod Files

#### WirePod/go.mod
Update to use local replace directives:
```
replace github.com/digital-dream-labs/api => ./third-party/github.com/digital-dream-labs/api
replace github.com/fforchino/vector-go-sdk => ./third-party/github.com/fforchino/vector-go-sdk
replace github.com/sashabaranov/go-openai => ./third-party/github.com/sashabaranov/go-openai
# ... etc for all dependencies
```

#### wire-pod/chipper/go.mod
Similar replace directives needed for the core server.

## Directory Structure

```
WirePod/third-party/github.com/
├── alphacep/vosk-api/          # Vosk STT API
├── asticode/go-asticoqui/      # Coqui Go bindings
├── bramvdbogaerde/go-scp/      # SCP client
├── coqui-ai/STT/               # Coqui STT framework
├── digital-dream-labs/api/     # Chipper API definitions
├── fforchino/vector-go-sdk/    # Vector robot SDK
├── ggerganov/whisper.cpp/      # Whisper.cpp STT
├── pkg/errors/                 # Error handling
├── sashabaranov/go-openai/     # OpenAI client
├── soundhound/houndify-sdk-go/ # Houndify STT
├── vadv/gopher-lua-libs/       # Lua libraries
├── wlynxg/anet/                # Network utilities
├── xiph/ogg/                   # Ogg container
├── xiph/opus/                  # Opus codec
└── yuin/gopher-lua/            # Lua runtime
```

## Implementation Notes

1. **Repository Versions**: All repositories were cloned at their current HEAD. For production use, specific tagged versions should be used.

2. **Local Path Strategy**: Using relative paths (`./third-party/github.com/...`) in go.mod replace directives to maintain portability.

3. **Build Scripts**: Scripts currently download releases/binaries. These need to be updated to use local builds from the cloned repositories.

4. **Testing**: After updating paths, all components should be tested to ensure functionality is preserved.

5. **Maintenance**: When updating dependencies, the local repositories should be updated and tested before deployment.

## Status

- ✅ All external repositories cloned
- ⏳ Go import paths need updating
- ⏳ Build scripts need updating
- ⏳ go.mod files need replace directives
- ⏳ Testing and validation needed