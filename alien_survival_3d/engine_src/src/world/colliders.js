// Static collision world: vertical cylinders (tree trunks, rocks, crates, tower
// legs, log segments) in a spatial hash, plus walkable decks (bridges). Used for
// character push-out, camera collision, ray casts and enemy flow-field
// obstacles.
import { rayCylinder } from '../core/math.js';

const CELL = 4;
const key = (cx, cz) => (cx + 32768) * 65536 + (cz + 32768);

export class CollisionWorld {
  constructor() {
    this.cells = new Map();
    this.decks = new Set();
    this._stamp = 0;
    this._nextId = 1;
  }

  add(c) {
    c.id = this._nextId++;
    c._stamp = 0;
    const x0 = Math.floor((c.x - c.r) / CELL), x1 = Math.floor((c.x + c.r) / CELL);
    const z0 = Math.floor((c.z - c.r) / CELL), z1 = Math.floor((c.z + c.r) / CELL);
    c._cells = [];
    for (let cx = x0; cx <= x1; cx++) {
      for (let cz = z0; cz <= z1; cz++) {
        const k = key(cx, cz);
        let arr = this.cells.get(k);
        if (!arr) { arr = []; this.cells.set(k, arr); }
        arr.push(c);
        c._cells.push(k);
      }
    }
    return c;
  }

  remove(c) {
    if (!c._cells) return;
    for (const k of c._cells) {
      const arr = this.cells.get(k);
      if (!arr) continue;
      const i = arr.indexOf(c);
      if (i >= 0) { arr[i] = arr[arr.length - 1]; arr.pop(); }
      if (arr.length === 0) this.cells.delete(k);
    }
    c._cells = null;
  }

  // Calls fn(collider) once for each collider whose cell overlaps the circle.
  query(x, z, radius, fn) {
    const stamp = ++this._stamp;
    const x0 = Math.floor((x - radius) / CELL), x1 = Math.floor((x + radius) / CELL);
    const z0 = Math.floor((z - radius) / CELL), z1 = Math.floor((z + radius) / CELL);
    for (let cx = x0; cx <= x1; cx++) {
      for (let cz = z0; cz <= z1; cz++) {
        const arr = this.cells.get(key(cx, cz));
        if (!arr) continue;
        for (let i = 0; i < arr.length; i++) {
          const c = arr[i];
          if (c._stamp === stamp) continue;
          c._stamp = stamp;
          if (fn(c) === false) return;
        }
      }
    }
  }

  // Pushes a circle of `radius` at pos (Vector3-like, feet at pos.y, `height`
  // tall) out of every overlapping collider. Returns true if it collided.
  resolve(pos, radius, height = 1.8) {
    let hit = false;
    this.query(pos.x, pos.z, radius + 2, (c) => {
      if (pos.y + height < c.y0 || pos.y > c.y1 - 0.05) return;
      const dx = pos.x - c.x, dz = pos.z - c.z;
      const min = radius + c.r;
      const d2 = dx * dx + dz * dz;
      if (d2 < min * min) {
        const d = Math.sqrt(d2) || 0.0001;
        const push = min - d;
        pos.x += (dx / d) * push;
        pos.z += (dz / d) * push;
        hit = true;
      }
    });
    return hit;
  }

  blocked(x, z, radius) {
    let b = false;
    this.query(x, z, radius + 2, (c) => {
      const dx = x - c.x, dz = z - c.z, m = radius + c.r;
      if (dx * dx + dz * dz < m * m) { b = true; return false; }
    });
    return b;
  }

  // Ray against all cylinders along the ray. Walks the hash cells covered by
  // the ray with a DDA. Returns {t, collider} or null.
  raycast(ox, oy, oz, dx, dy, dz, maxDist, filter) {
    let best = maxDist, bestC = null;
    const stamp = ++this._stamp;
    let cx = Math.floor(ox / CELL), cz = Math.floor(oz / CELL);
    const stepX = dx > 0 ? 1 : -1, stepZ = dz > 0 ? 1 : -1;
    const tDeltaX = Math.abs(dx) > 1e-9 ? CELL / Math.abs(dx) : Infinity;
    const tDeltaZ = Math.abs(dz) > 1e-9 ? CELL / Math.abs(dz) : Infinity;
    let tMaxX = Math.abs(dx) > 1e-9 ? ((dx > 0 ? (cx + 1) * CELL - ox : ox - cx * CELL) / Math.abs(dx)) : Infinity;
    let tMaxZ = Math.abs(dz) > 1e-9 ? ((dz > 0 ? (cz + 1) * CELL - oz : oz - cz * CELL) / Math.abs(dz)) : Infinity;
    let tCell = 0;
    for (let guard = 0; guard < 512 && tCell <= best + CELL * 1.5; guard++) {
      // Colliders can overlap neighbouring cells; check a 3x3 neighbourhood.
      for (let ix = -1; ix <= 1; ix++) {
        for (let iz = -1; iz <= 1; iz++) {
          const arr = this.cells.get(key(cx + ix, cz + iz));
          if (!arr) continue;
          for (let i = 0; i < arr.length; i++) {
            const c = arr[i];
            if (c._stamp === stamp) continue;
            c._stamp = stamp;
            if (filter && !filter(c)) continue;
            const t = rayCylinder(ox, oy, oz, dx, dy, dz, c.x, c.z, c.r, c.y0, c.y1);
            if (t >= 0 && t < best) { best = t; bestC = c; }
          }
        }
      }
      if (tMaxX < tMaxZ) { tCell = tMaxX; tMaxX += tDeltaX; cx += stepX; }
      else { tCell = tMaxZ; tMaxZ += tDeltaZ; cz += stepZ; }
    }
    return bestC ? { t: best, collider: bestC } : null;
  }

  addDeck(deck) { this.decks.add(deck); return deck; }
  removeDeck(deck) { this.decks.delete(deck); }

  // Highest walkable deck under (x,z) that is not far above `y`.
  deckHeight(x, z, y) {
    let best = -Infinity;
    for (const d of this.decks) {
      const rx = x - d.x, rz = z - d.z;
      const along = rx * d.dirX + rz * d.dirZ;
      const side = -rx * d.dirZ + rz * d.dirX;
      if (Math.abs(along) <= d.halfLen && Math.abs(side) <= d.halfWidth) {
        if (d.y <= y + 0.9 && d.y > best) best = d.y;
      }
    }
    return best;
  }
}
