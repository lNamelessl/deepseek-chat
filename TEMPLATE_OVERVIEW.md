[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/deepseek-chat-official-ui-with-web-searc)

## DeepSeek Chat — Official UI with Web Search, Thinking & Voice

Deploy the **official open-source DeepSeek chat client** ([deepseek-ai/chat-demo](https://github.com/deepseek-ai/chat-demo), MIT) as one static Railway service. It renders DeepSeek's full App API feature set — server-side web search with citations, the deep-thinking panel, file upload, and voice input/read-aloud — in a React UI with Chinese and English localization and light/dark themes.

**Your API key never leaves your browser.** The service is a pure static file server (Caddy): no backend, no database, zero variables, nothing stored server-side. Your key lives in your browser's localStorage and goes straight to `https://api.deepseek.com`; conversation history lives in your browser's IndexedDB.

| Feature | What you get |
|---|---|
| Server-side web search | DeepSeek runs the search for you — result cards with titles, snippets and page ages, no SERP keys or scraping infra |
| Deep thinking | Expandable reasoning panel; thinking + search combine into deep search |
| Citations | Inline citation links and hover cards on search-backed answers |
| Files | Paste, drag, or pick attachments; server-side OCR and validation |
| Voice | Voice input (ASR) and read-aloud replies (TTS) with live audio spectrum |
| Markdown stack | Syntax highlighting, KaTeX math, Mermaid diagrams, code blocks |
| History | Multiple conversations, branching, edit/regenerate, ZIP import/export |
| zh/en + themes | Simplified Chinese and English UI; light and dark; mobile layout |

Note: other Railway listings named DeepSeek Harness deploy the DeepSeek coding agent behind a login — a different product. This template deploys the official chat client itself.

## After deploying

1. Open your app URL.
2. Settings → API Key: paste a key from [platform.deepseek.com](https://platform.deepseek.com).
3. Chat. Toggle thinking and search in the UI when you want them.

Hosting cost on Railway is a few MB of RAM for a static container. API usage is billed to your own DeepSeek account at DeepSeek's published rates (flash model roughly 0.15–0.30 dollars per million input tokens; search/fetch 0.75 dollars per 1,000 uses; off-peak discounts). See the [DeepSeek pricing page](https://api-docs.deepseek.com/quick_start/pricing).

**Churn disclosure:** the DeepSeek App API and this client are both days old (client repo created 2026-11-12). This template pins upstream at commit `5d5dd754ebc1948e977ddb880a9eb5aa25f37b4c` (v0.1.1); upstream will move, and re-pinning is deliberate.

# Deploy and Host

## About Hosting

This template provisions exactly one service: a digest-pinned `caddy:2-alpine` container serving the official client's fully static build. The Dockerfile clones [deepseek-ai/chat-demo](https://github.com/deepseek-ai/chat-demo) at the pinned commit SHA, builds it with pnpm 12.6.0 and rspack on `node:22-alpine`, and copies the resulting `dist/` into a pure Caddy runtime — there is no Node process, no database, and no volume. Caddy serves the SPA with a fallback to `index.html`, zstd/gzip encoding, and security headers; the healthcheck probes the real `/health` route (200, unauthenticated, dotless). Deployments restart on failure up to 10 times. Since there is no server-side state, redeploys and restarts are free of migration or seeding concerns — all user state is in the visitor's browser (localStorage for the key and settings, IndexedDB for history and attachments).

## Why Deploy

- **Official client, zero maintenance surface:** you host a static site; the browser talks directly to the DeepSeek API. Nothing of yours ever sees an API key or a conversation.
- **Privacy pitch that is verifiable:** the container contains nothing but static files. There are no variables, no volumes, no credentials, no logs of your chats — your key and history stay in your browser (clearing browser data clears history; export/import via built-in ZIP).
- **The whole new App API feature set out of the box:** server-side web search with citations, deep thinking, file upload with OCR, voice input and read-aloud — features generic OpenAI-compatible chat UIs on Railway cannot render because they proxy the API themselves and skip DeepSeek's extensions.
- **Cheapest possible hosting:** a pure Caddy static container is the smallest service shape on Railway, and API costs flow to your own DeepSeek account with off-peak discounts and cache pricing.

## Common Use Cases

- A personal DeepSeek chat UI on your own domain with web search, citations, and the thinking panel.
- A private, key-your-own-device team portal: every teammate pastes their own key, keys and histories never leave their browsers, and the shared server holds nothing sensitive.
- A mobile-friendly voice assistant: talk to DeepSeek, hear replies read aloud, and attach photos for OCR.
- A research scratchpad: deep search answers with cited sources, Mermaid/KaTeX rendering, and ZIP history export for archiving.

## Dependencies for

### Deployment Dependencies

- None at deploy time: the template has zero variables, zero plugins, and zero volumes. One static service, one auto-provisioned domain.
- A DeepSeek API key from [platform.deepseek.com](https://platform.deepseek.com), entered in the app's Settings after deploy (stored only in your browser). API usage is billed to your own DeepSeek account, not to Railway.
- A modern browser: Chrome or Edge 105+, Firefox 110+, or Safari 16+ (per the client's own targets). Voice input additionally requires microphone permission.
