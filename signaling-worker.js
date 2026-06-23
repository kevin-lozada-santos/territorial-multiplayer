export class Matchmaker {
  constructor(state) {
    this.state = state;
    this.waiting = null;
    this.clients = new Map();
    this.rooms = new Map();
  }

  async fetch(request) {
    if (request.headers.get('Upgrade') !== 'websocket') {
      return new Response('Territorial signaling service', { status: 200 });
    }

    const pair = new WebSocketPair();
    const [client, server] = Object.values(pair);
    const connectionId = crypto.randomUUID();
    const record = { id: connectionId, socket: server, uid: '', roomId: '', role: '' };
    this.clients.set(connectionId, record);

    server.accept();
    server.addEventListener('message', event => this.handleMessage(record, event));
    server.addEventListener('close', () => this.closeClient(record));
    server.addEventListener('error', () => this.closeClient(record));

    return new Response(null, { status: 101, webSocket: client });
  }

  send(record, message) {
    if (!record?.socket || record.socket.readyState !== WebSocket.OPEN) return false;
    record.socket.send(JSON.stringify(message));
    return true;
  }

  handleMessage(record, event) {
    let message = null;
    try {
      message = JSON.parse(String(event.data || '{}'));
    } catch (_) {
      this.send(record, { type: 'error', message: 'Invalid JSON.' });
      return;
    }

    if (message.type === 'find') {
      this.findMatch(record, message);
      return;
    }

    if (message.type === 'signal') {
      this.relaySignal(record, message);
      return;
    }

    if (message.type === 'complete') {
      this.completeRoom(record, message);
      return;
    }

    if (message.type === 'leave') {
      this.closeClient(record);
    }
  }

  findMatch(record, message) {
    record.uid = String(message.uid || record.id);

    if (this.waiting && this.waiting.id !== record.id && this.waiting.socket.readyState === WebSocket.OPEN) {
      const host = this.waiting;
      const guest = record;
      this.waiting = null;

      const roomId = `S${crypto.randomUUID().replace(/-/g, '').slice(0, 10).toUpperCase()}`;
      host.roomId = roomId;
      host.role = 'host';
      guest.roomId = roomId;
      guest.role = 'guest';
      this.rooms.set(roomId, { hostId: host.id, guestId: guest.id, createdAt: Date.now() });

      const payload = {
        type: 'matched',
        roomId,
        player1Uid: host.uid,
        player2Uid: guest.uid
      };
      this.send(host, { ...payload, role: 'host' });
      this.send(guest, { ...payload, role: 'guest' });
      return;
    }

    this.waiting = record;
    this.send(record, { type: 'waiting' });
  }

  relaySignal(record, message) {
    const roomId = String(message.roomId || record.roomId || '');
    const room = this.rooms.get(roomId);
    if (!room) {
      this.send(record, { type: 'error', message: 'Room not found.' });
      return;
    }

    const targetId = record.id === room.hostId ? room.guestId : room.hostId;
    const target = this.clients.get(targetId);
    if (!target) {
      this.send(record, { type: 'error', message: 'Peer disconnected.' });
      return;
    }

    this.send(target, {
      type: 'signal',
      roomId,
      fromRole: record.role,
      payload: message.payload || null
    });
  }

  completeRoom(record, message) {
    const roomId = String(message.roomId || record.roomId || '');
    const room = this.rooms.get(roomId);
    if (!room) return;

    const host = this.clients.get(room.hostId);
    const guest = this.clients.get(room.guestId);
    this.send(host, { type: 'complete', roomId });
    this.send(guest, { type: 'complete', roomId });
    this.rooms.delete(roomId);
    if (host) host.roomId = '';
    if (guest) guest.roomId = '';
  }

  closeClient(record) {
    if (!record) return;
    if (this.waiting?.id === record.id) this.waiting = null;

    if (record.roomId) {
      const room = this.rooms.get(record.roomId);
      if (room) {
        const otherId = record.id === room.hostId ? room.guestId : room.hostId;
        const other = this.clients.get(otherId);
        this.send(other, { type: 'peer-left', roomId: record.roomId });
        this.rooms.delete(record.roomId);
      }
    }

    this.clients.delete(record.id);
    try { record.socket.close(1000, 'closed'); } catch (_) {}
  }
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname === '/health') return new Response('ok');
    const id = env.MATCHMAKER.idFromName('global');
    return env.MATCHMAKER.get(id).fetch(request);
  }
};
