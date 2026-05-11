# Project Profile

## Identity

- Project name: esp_loss_power
- Domain: `iot`
- Status: `active`
- Priority: medium

## Repositories

- Repo URL: `git@github.com:mathangspk/ESP32_meter.git`
- Local path (WIN-HYPERV-1): `C:\local\opencode\esp32_loss_power`
- Local path (MAC-TMAS-IMAC-PRO): `/Users/tma/opencode/esp32_loss_power`
- Default branch: `main`

## Delivery context

- Commercial context: ESP32 power meter reading PZEM-004T data via MQTT and exposing analytics via Telegram bot
- Current phase: discovery
- Definition of done: stable power loss detection via CAN bus
- Weekly report day: `Friday`
- Approval sensitivity: `medium`

## Working context

- Current focus: power loss detection via CAN bus
- Known blockers: no ESP32 attached on Windows, firmware work requires macOS with USB serial
- Key risks: Telegram polling timeout from VPS, serial reads reboot ESP32
- Reporting notes:

## Architecture and scope

- Architecture notes: ESP32 firmware (PlatformIO) + Node.js backend + MongoDB + Mosquitto MQTT + Telegram bot
- Important directories: `src/` (firmware), `backend/`, `assistant-bot/`, `infra/mosquitto/`
- Entry points: `src/main.cpp`, `backend/src/index.ts`, `assistant-bot/src/index.ts`
- Critical flows: PZEM read → MQTT publish → backend ingest → Telegram query
- Known fragile areas: OTA firmware updates, VPS network to Telegram API
- Architecture constraints: no npm/docker on Windows, firmware upload requires macOS

## Commands and operations

- Build command: `pio run`
- Upload command: `pio run -t upload --upload-port /dev/cu.SLAB_USBtoUART`
- Deploy command: SSH to VPS, `docker-compose up -d --build`

## OpenCode setup

- OpenCode scaffold copied: yes
- Default primary agent: `orchestrator`
- Default model: `openai/gpt-5.4` with fallback `opencode/big-pickle`
- Agent overrides:
- Team project ref: `projects/iot/esp_loss_power`

## Testing and validation

- Testing strategy: verify via serial monitor + Telegram bot messages
- Acceptance checks: PZEM readings, MQTT publish, OTA success, Telegram response
- QA mode: `iot`
- QA priorities: MQTT connectivity, data accuracy, OTA reliability

## Agent notes

- Review priorities: MQTT/firmware interaction, OTA safety, backend data integrity
- Areas to avoid unless required: OTA force-flash, production firmware upload without verification
- Expected output style: compact, verification evidence included
