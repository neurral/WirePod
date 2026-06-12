# WirePod

Cross-platform code, resources, and builds for [wire-pod](https://github.com/kercre123/wire-pod).

-  wire-pod = actual server code
-  WirePod = code to create user-installable packages of wire-pod

## Support

- Installation instructions are found in the [wire-pod wiki](https://github.com/kercre123/wire-pod/wiki/Installation).

-  macOS (arm64, amd64)
-  Windows 10/11 (amd64)
-  Android 4.3 and above
-  For Linux, use the instructions in wire-pod's wiki.

## Local LLM Integration (LM Studio & Ollama Setup)

If you are using a local LLM server to power the **Knowledge Graph** (such as LM Studio or Ollama), pay attention to these three configuration items to ensure Vector speaks naturally without pronouncing code markup, template tags, or formatting characters:

### 1. Structured Output (Not Required)
* **How to configure:** You **do not need** to prepare or enable JSON schema, Structured Output, or Function Calling in your LLM runner.
* **Why:** WirePod sends prompts expecting standard text completions. Even if you enable **LLM Commands** (animations/actions), WirePod parses them out using plain-text format matchers (`{{command||parameter}}`). Keep Structured Output **disabled** in LM Studio.

### 2. Prompt Template (Instruct Presets)
* **How to configure:** You **must** select the correct Prompt Template preset in your LLM runner corresponding to the loaded model.
* **Why:** If the prompt template configuration is incorrect or omitted, the LLM will output raw chat template delimiters (like `<|im_start|>`, `<|start_header_id|>`, or assistant header markers) directly in the text stream, which Vector will read aloud literally.
* **Working Example (LM Studio Presets):**
  - In the right-hand panel of LM Studio, under **Prompt Template**, select the preset matching your GGUF model (e.g., **Llama 3** for `Llama-3-8B-Instruct` or **ChatML** for Qwen/Liquid LFM models).
* **Custom Template Settings (If auto-detection fails):**
  If you need to enter the prompt format manually, copy and paste the raw template structures below into LM Studio's Custom Template input:
  
  **For Llama 3 Instruct:**
  ```text
  <|start_header_id|>system<|end_header_id|>

  {system_prompt}<|eot_id|><|start_header_id|>user<|end_header_id|>

  {user_message}<|eot_id|><|start_header_id|>assistant<|end_header_id|>
  ```
  
  **For ChatML (Qwen, Liquid LFM, etc.):**
  ```text
  <|im_start|>system
  {system_prompt}<|im_end|>
  <|im_start|>user
  {user_message}<|im_end|>
  <|im_start|>assistant
  ```

### 3. System Prompt & Formatting Controls
* **How to configure:** You do not need to hardcode the System Prompt in LM Studio. Instead, configure a formatting constraint directly in the **LLM Prompt** input box on the WirePod web settings page (`http://localhost:8080`).
* **Why:** Vector's Text-to-Speech (TTS) engine will read out markdown formatting characters (like asterisks, backticks, or hashes) literally. A strict prompt constraint stops the model from emitting formatting symbols.
* **Working Example (Paste into the "LLM Prompt" field in the WirePod web UI):**
  ```text
  You are a small, animated companion robot named Vector. Answer questions in a brief, friendly manner (maximum 2 sentences). Speak in plain English. Under no circumstances use Markdown formatting (no asterisks, no double asterisks, no hashes, no backticks, no bold text), emojis, bulleted lists, numbered lists, or code blocks.
  ```

## Vosk Speech-to-Text Model Selection & Accuracy

The default Speech-to-Text (STT) model downloaded automatically during setup is the **128MB lgraph English model**. This provides a great balance of excellent accuracy and low resource usage.

If you want to manually change or upgrade your Vosk model, you can choose from these options:

### Model Options
*   **Vosk 128MB Model (Default/Recommended):** [vosk-model-en-us-0.22-lgraph.zip](https://alphacephei.com/vosk/models/vosk-model-en-us-0.22-lgraph.zip) — Excellent accuracy with low memory footprint.
*   **Vosk 1.8GB Model (Highest Accuracy):** [vosk-model-en-us-0.22.zip](https://alphacephei.com/vosk/models/vosk-model-en-us-0.22.zip) — Highest possible accuracy, recommended if your host machine has 4GB+ of free RAM.
*   **Vosk 40MB Model (Lightweight):** [vosk-model-small-en-us-0.15.zip](https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip) — Extremely fast, but lower accuracy.

### Manual Installation Instructions
1. Download one of the zip files from the links above.
2. Extract/unzip the contents of the download.
3. Open your user configuration directory depending on your OS:
    *   **macOS:** `/Users/<your-username>/Library/Application Support/wire-pod/vosk/models/en-US/model/`
    *   **Windows:** `%USERPROFILE%\AppData\Local\wire-pod\vosk\models\en-US\model\`
    *   **Linux/Raspberry Pi:** `~/.config/wire-pod/vosk/models/en-US/model/`
4. Delete all existing files in that directory.
5. Copy the extracted files/folders directly into that `model/` directory (ensure the `am/`, `conf/`, and `graph/` folders are directly inside the `model/` folder).
6. Restart WirePod.


