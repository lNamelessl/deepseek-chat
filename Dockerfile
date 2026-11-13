# Multi-stage, digest-pinned. Build stage clones the official deepseek-ai/chat-demo
# client (MIT) at a pinned commit SHA, builds the fully static dist/ with pnpm + rspack;
# the runtime is pure Caddy serving those static files — no Node at runtime.
#
# Upstream is days old and moves fast: the SHA pin is deliberate. Re-pin consciously
# (check https://github.com/deepseek-ai/chat-demo/commits), never leave it floating.

# Digest pinned (verified 2026-11-13 via Docker Hub registry API; re-pin on updates).
FROM node:22-alpine@sha256:1314fb30ec37592d5845e5a160d522c0e680972aa534549940b8d73bde88481a AS build

WORKDIR /app

# git is needed to clone upstream at the pinned SHA; pnpm version matches the
# upstream CI pin (pnpm 12.6.0 in .github/workflows/pages.yml).
RUN apk add --no-cache git \
 && npm install -g pnpm@12.6.0

# Upstream pin: the full commit SHA is the source of truth for this image.
ARG CHAT_DEMO_SHA=5d5dd754ebc1948e977ddb880a9eb5aa25f37b4c
RUN git clone https://github.com/deepseek-ai/chat-demo.git . \
 && git checkout --detach "$CHAT_DEMO_SHA" \
 && echo "chat-demo pinned at $CHAT_DEMO_SHA"

# __API_ORIGIN__ keeps its build-time default https://api.deepseek.com:
# the browser talks to the DeepSeek API directly (CORS is open), and proxying the
# origin would degrade title generation, server-side search, files and TTS.
RUN pnpm install --frozen-lockfile \
 && pnpm build

# Digest pinned (verified 2026-11-13 via Docker Hub registry API; re-pin on updates).
FROM caddy:2-alpine@sha256:003a97808e781aa9f7e75cc2f43d34d461099031faf5e20faefb9f61126836f0

COPY Caddyfile /etc/caddy/Caddyfile
COPY --from=build /app/dist /srv

EXPOSE 8080
# The stock caddy image CMD runs `caddy run --config /etc/caddy/Caddyfile` —
# the Caddyfile binds to Railway's runtime-injected $PORT (default 8080 locally).
