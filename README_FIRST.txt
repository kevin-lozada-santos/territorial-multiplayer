Territorial - Realtime P1/P2 Sync Build
Build: STABLE-LOCALHOST-8000-USER-TEXT-CLEANUP

Use USER_BUILD.bat for the normal player-facing build.
Use RUN_GAME.bat for the developer suite.

Launcher notes:
- The BAT files open the public HTTPS build from GitHub Pages.
- No local server, scripting-policy change, Python, or install step is required.
- If Windows Security blocked an older ZIP, download the latest repo ZIP after this change.

Fixes in this build:
- Host is Player 1 and guest is Player 2 in private Battle ID matches.
- Only the active local player can place/draw/rotate/recycle/end turn.
- Battle state is published live after local actions, including shape placement.
- Firestore snapshots now apply live board/turn/mana/hand state.
- State is serialized with boardRows strings instead of nested arrays, so Firestore accepts it.

Firebase checklist:
- Authentication > Sign-in method > Anonymous must be enabled.
- Firestore rules must allow authenticated read/write for battleRooms and matches.

Find Match Hooked patch: Quick Match now uses battleRooms, assigns P1/P2, listens live, and shows detailed Firebase errors.

Patch: USER_BUILD hides internal/dev text, user-facing vault helper text, battle music hint, status toast, and Edit/Delete Card buttons. Developer build keeps them.

Scalable Search Game:
- Active quick-match gameplay uses WebRTC DataChannel peer-to-peer.
- Firebase remains the automatic fallback for matchmaking/signaling.
- For higher scale, deploy signaling-worker.js with wrangler.toml to Cloudflare Workers Durable Objects.
- Then set this in the browser console once:
  localStorage.setItem('territorial.signalingUrl', 'wss://YOUR-WORKER.YOUR-SUBDOMAIN.workers.dev')
- Reload the game. Search Game will use the WebSocket signaling service first and Firebase only if no signaling URL is configured.
