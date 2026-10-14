// Enemy navigation: a flow field over a local obstacle grid centred on the
// player. One Dijkstra pass (Dial's bucket queue, 8-connected) gives every
// alien in range a shortest-path direction around trees, rocks, crates, logs
// and cave walls. Rebuilt a few times per second.

const N = 72; // cells per side
const CELL = 1.5; // metres
const INF = 0xffff;

export class FlowField {
  constructor(world) {
    this.world = world;
    this.blocked = new Uint8Array(N * N);
    this.dist = new Uint16Array(N * N);
    this.ox = 0; this.oz = 0; // world position of cell (0,0) corner
    this.valid = false;
    this.timer = 0;
    this.buckets = Array.from({ length: 16 }, () => []);
    this.lastX = 1e9; this.lastZ = 1e9;
  }

  update(dt, px, pz) {
    this.timer -= dt;
    const moved = Math.hypot(px - this.lastX, pz - this.lastZ);
    if (this.timer > 0 && moved < CELL) return;
    this.timer = 0.35;
    this.lastX = px; this.lastZ = pz;
    this.build(px, pz);
  }

  build(px, pz) {
    const half = (N * CELL) / 2;
    this.ox = Math.floor((px - half) / CELL) * CELL;
    this.oz = Math.floor((pz - half) / CELL) * CELL;
    const bl = this.blocked;
    bl.fill(0);
    const agentR = 0.45;
    const cx = this.ox + half, cz = this.oz + half;
    this.world.colliders.query(cx, cz, half + 2, (c) => {
      if (c.kind === 'rail') return;
      const r = c.r + agentR;
      const i0 = Math.max(0, Math.floor((c.x - r - this.ox) / CELL)), i1 = Math.min(N - 1, Math.floor((c.x + r - this.ox) / CELL));
      const j0 = Math.max(0, Math.floor((c.z - r - this.oz) / CELL)), j1 = Math.min(N - 1, Math.floor((c.z + r - this.oz) / CELL));
      for (let j = j0; j <= j1; j++) {
        for (let i = i0; i <= i1; i++) {
          const wx = this.ox + (i + 0.5) * CELL - c.x, wz = this.oz + (j + 0.5) * CELL - c.z;
          if (wx * wx + wz * wz < r * r) bl[j * N + i] = 1;
        }
      }
    });
    // Dijkstra from the player's cell.
    const d = this.dist;
    d.fill(INF);
    const si = Math.floor((px - this.ox) / CELL), sj = Math.floor((pz - this.oz) / CELL);
    if (si < 0 || sj < 0 || si >= N || sj >= N) { this.valid = false; return; }
    const B = this.buckets;
    for (const b of B) b.length = 0;
    const start = sj * N + si;
    d[start] = 0;
    bl[start] = 0;
    B[0].push(start);
    let cur = 0, pending = 1;
    const ORTH = 10, DIAG = 14;
    while (pending > 0) {
      const bucket = B[cur % 16];
      if (bucket.length === 0) { cur++; continue; }
      const idx = bucket.pop();
      pending--;
      if (d[idx] !== cur) continue;
      const i = idx % N, j = (idx / N) | 0;
      for (let dj = -1; dj <= 1; dj++) {
        const nj = j + dj;
        if (nj < 0 || nj >= N) continue;
        for (let di = -1; di <= 1; di++) {
          if (!di && !dj) continue;
          const ni = i + di;
          if (ni < 0 || ni >= N) continue;
          const nidx = nj * N + ni;
          if (bl[nidx]) continue;
          // no corner cutting
          if (di && dj && (bl[j * N + ni] || bl[nj * N + i])) continue;
          const nd = cur + (di && dj ? DIAG : ORTH);
          if (nd < d[nidx]) {
            d[nidx] = nd;
            B[nd % 16].push(nidx);
            pending++;
          }
        }
      }
    }
    this.valid = true;
  }

  // Writes the flow direction at (x,z) into out (x,z) and returns true when the
  // position is inside the field and has a route.
  direction(x, z, out) {
    if (!this.valid) return false;
    const i = Math.floor((x - this.ox) / CELL), j = Math.floor((z - this.oz) / CELL);
    if (i < 1 || j < 1 || i >= N - 1 || j >= N - 1) return false;
    const d = this.dist;
    const here = d[j * N + i];
    let best = here, bx = 0, bz = 0;
    for (let dj = -1; dj <= 1; dj++) {
      for (let di = -1; di <= 1; di++) {
        if (!di && !dj) continue;
        const v = d[(j + dj) * N + (i + di)];
        if (v < best) { best = v; bx = di; bz = dj; }
      }
    }
    if (best === INF || (bx === 0 && bz === 0)) return false;
    // Steer toward the centre of the best neighbour (smooths diagonal moves).
    const tx = this.ox + (i + bx + 0.5) * CELL - x, tz = this.oz + (j + bz + 0.5) * CELL - z;
    const l = Math.hypot(tx, tz) || 1;
    out.x = tx / l; out.z = tz / l;
    return true;
  }

  isBlocked(x, z) {
    const i = Math.floor((x - this.ox) / CELL), j = Math.floor((z - this.oz) / CELL);
    if (i < 0 || j < 0 || i >= N || j >= N) return false;
    return this.blocked[j * N + i] === 1;
  }

  reachable(x, z) {
    if (!this.valid) return true;
    const i = Math.floor((x - this.ox) / CELL), j = Math.floor((z - this.oz) / CELL);
    if (i < 0 || j < 0 || i >= N || j >= N) return true;
    return this.dist[j * N + i] !== INF;
  }
}

export const FLOW_RADIUS = (N * CELL) / 2;
