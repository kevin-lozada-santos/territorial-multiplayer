# Territorial Multiplayer

A browser-based real-time multiplayer strategy prototype focused on **authoritative turn state, peer-to-peer synchronization, matchmaking, and scalable signaling**.

The project started as a playable territorial control game and evolved into a networking experiment: keeping two players synchronized while supporting fallback infrastructure and a path from simple hosting to more scalable session coordination.

## What it demonstrates

- **WebRTC DataChannel** peer-to-peer gameplay synchronization
- **Firebase / Firestore fallback** for matchmaking and shared state
- **Private battle IDs** with deterministic Player 1 / Player 2 assignment
- **Turn authority** so only the active local player can act
- **Live board-state replication** after placement and turn actions
- **Cloudflare Workers / Durable Objects signaling path** for higher-scale matchmaking
- **Browser-first delivery** with no local install required for the normal player flow

## Architecture

```text
Player A ───── WebRTC DataChannel ───── Player B
   │                                      │
   └──── matchmaking / fallback state ────┘
                    │
             Firebase / Firestore
                    │
          optional signaling service
                    │
       Cloudflare Workers + Durable Objects
```

The active quick-match path prefers peer-to-peer communication. Firebase remains available for matchmaking/signaling fallback, while `signaling-worker.js` and `wrangler.toml` provide a path to a dedicated WebSocket signaling layer.

## Multiplayer behavior

The current build includes:

- host assigned as **Player 1** and guest as **Player 2**
- active-player enforcement for placement, drawing, rotation, recycling, and ending turns
- synchronized board, mana, hand, and turn state
- live state publication after local actions
- WebRTC-first search-game flow with Firebase fallback

## Run it

For the normal player-facing build on Windows:

```text
USER_BUILD.bat
```

For the developer build:

```text
RUN_GAME.bat
```

The launcher opens the hosted HTTPS build; the normal flow does not require Python or a local server.

## Optional signaling deployment

The repository includes a Cloudflare Worker signaling implementation.

After deploying it, configure the browser once:

```js
localStorage.setItem(
  'territorial.signalingUrl',
  'wss://YOUR-WORKER.YOUR-SUBDOMAIN.workers.dev'
)
```

Then reload the game. Search Game will prefer the configured WebSocket signaling service.

## Why this project matters

This repository is useful as a systems project more than as a polished game release. It touches several failure-prone areas at once: distributed state, player authority, real-time transport, fallback behavior, deployment boundaries, and keeping a browser game usable while networking changes underneath it.

## Selected related work

- **[Brain Scanner walkthrough](https://github.com/kevin-lozada-santos/brain-scanner-walkthrough)** — hosted MCP developer tooling and project-graph workflows for coding agents.
- **[Project PSY](https://github.com/kevin-lozada-santos/Project-PSY)** — Unity XR hand-tracking and physics interaction.
- **[Codex Timer Skill](https://github.com/kevin-lozada-santos/codex-timer-skill)** — execution contracts for time-bounded AI coding-agent work.

---

Built by **Kevin Lozada Santos**.