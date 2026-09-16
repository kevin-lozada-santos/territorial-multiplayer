# Territorial Multiplayer

Browser-based real-time multiplayer strategy prototype using WebRTC for peer-to-peer gameplay synchronization with Firebase fallback and an optional Cloudflare signaling layer.

## Features

- WebRTC DataChannel gameplay synchronization
- Firebase / Firestore matchmaking and fallback state
- Private battle IDs with Player 1 / Player 2 assignment
- Active-player authority for turn actions
- Live synchronization of board, mana, hand, and turn state
- Optional WebSocket signaling through Cloudflare Workers and Durable Objects
- Hosted browser build with no local server required for normal play

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

Quick Match prefers WebRTC for active gameplay synchronization. Firebase remains available for matchmaking and fallback state. The repository also includes `signaling-worker.js` and `wrangler.toml` for deploying a dedicated WebSocket signaling service.

## Run

Player-facing Windows launcher:

```text
USER_BUILD.bat
```

Developer launcher:

```text
RUN_GAME.bat
```

The launcher opens the hosted HTTPS build. The standard player flow does not require Python or a local server.

## Optional signaling deployment

After deploying the included Cloudflare Worker, configure the signaling endpoint in the browser:

```js
localStorage.setItem(
  'territorial.signalingUrl',
  'wss://YOUR-WORKER.YOUR-SUBDOMAIN.workers.dev'
)
```

Reload the game after setting the endpoint. Search Game will use the configured signaling service when available.
