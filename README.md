# DeepSeek Chat UI on Railway

Deploy the **official open-source DeepSeek chat client** ([deepseek-ai/chat-demo](https://github.com/deepseek-ai/chat-demo), MIT) as a single static Railway service. The browser talks to the DeepSeek API directly — there is no application backend, no database, and **your API key never leaves your browser**.

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new/github_url=https://github.com/lNamelessl/deepseek-chat)

## What it is

The official client for DeepSeek's new App API (built around the `deepseek-flash` model), rendering the full feature set in a clean React UI:

| Feature | What you get |
|---|---|
| Server-side web search | DeepSeek runs the search and returns source cards with citations — no SERP keys, no scraping, no SearXNG |
| Deep thinking | Expandable reasoning panel; thinking + search combine into deep search |
| Citations | Inline citation links and hover cards on search-backed answers |
| File upload | Paste, drag, or pick attachments (server-side OCR/validation) |
| Voice I/O | Voice input (ASR) and read-aloud replies (TTS) with a live audio spectrum |
| Markdown stack | Syntax highlighting, KaTeX math, Mermaid diagrams |
| History | Multiple conversations, branching, edit/regenerate, ZIP import/export |
| i18n + themes | Simplified Chinese and English; light and dark themes; mobile layout |

## Your key never leaves your browser

There is nothing to configure at deploy time — the template ships **zero variables**. After deploying:

1. Open your app URL.
2. Go to **Settings → API Key** and paste a key from [platform.deepseek.com](https://platform.deepseek.com).
3. Chat.

The key is stored in your browser's localStorage and sent directly to `https://api.deepseek.com`; chat history lives in your browser's IndexedDB. The server hosting this page holds no credentials and no state — clearing your browser data clears your history, and Settings → Data → Delete all chats wipes conversations on demand. Export/import via built-in ZIP archives (keys and settings are excluded from exports).

## Costs

Railway bills you for hosting a tiny static site (a pure Caddy container serving files — a few MB of RAM). **API usage is billed to your own DeepSeek account** at DeepSeek's published rates (e.g. `deepseek-flash` roughly $0.15–0.30/M input and $0.60–1.20/M output tokens; server-side search/fetch $0.75 per 1k uses; off-peak discounts apply). Voice features bill per audio-hour (ASR) and per 10k characters (TTS). Check [DeepSeek's pricing page](https://api-docs.deepseek.com/quick_start/pricing) for current numbers.

## Notes and limitations

- **Upstream churn disclosure:** the DeepSeek App API and this client are both days old (client repo created 2026-11-12). This template pins upstream at commit `5d5dd754ebc1948e977ddb880a9eb5aa25f37b4c` (v0.1.1) and the build digests; re-pinning is deliberate. Features may change upstream without notice.
- Voice input requires microphone permission in your browser.
- The API origin is baked at build time (`https://api.deepseek.com` default) — the CORS-open endpoint is a DeepSeek-side property; if you self-proxy the origin, title/search/files/TTS extensions degrade.
- Server-side web search and thinking are toggled per conversation in the UI (Settings → thinking / search toggles).

## Repo layout

This repo adds a serving layer around the official client — the client itself is cloned from upstream at the pinned SHA during the image build:

- `Dockerfile` — `node:22-alpine` build stage (pnpm 12.6.0, pinned upstream SHA) → pure `caddy:2-alpine` runtime with the built `dist/`
- `Caddyfile` — `/health` healthcheck route, SPA fallback, zstd/gzip encoding, security headers (CSP allows the DeepSeek API origin and citation images only)

License: MIT (the client is MIT; see [upstream LICENSE](https://github.com/deepseek-ai/chat-demo/blob/main/LICENSE), which is also bundled in the served bundle).
