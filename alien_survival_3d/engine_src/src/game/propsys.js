// Gameplay for world props: spike traps damage anything standing on them,
// landmines arm and detonate, explosive barrels chain-react, crates break
// (and may drop supplies), barricades and logs are solid cover.
import * as THREE from 'three';

const _v = new THREE.Vector3();

export class PropSystem {
  constructor(game) {
    this.game = game;
    this.pending = []; // delayed barrel detonations
  }

  damage(prop, amount, point) {
    if (!prop.alive) return;
    const g = this.game;
    if (prop.type === 'crate') {
      prop.hp -= amount;
      if (prop.hp <= 0) this.breakCrate(prop);
    } else if (prop.type === 'barrel') {
      prop.hp -= amount;
      if (prop.hp <= 0) this.detonateBarrel(prop, 0.05);
      else g.fx.smoke(_v.set(prop.x, prop.y + 1.2, prop.z), 0.5);
    }
  }

  breakCrate(prop) {
    const g = this.game;
    g.world.destroyProp(prop);
    const c = _v.set(prop.x, prop.y + 0.6, prop.z);
    g.fx.impact(c, new THREE.Vector3(0, 1, 0), 'wood');
    g.fx.impact(c, new THREE.Vector3(1, 0.3, 0), 'wood');
    g.fx.impact(c, new THREE.Vector3(-1, 0.3, 0), 'wood');
    g.fx.dust(c, 3, [0.5, 0.36, 0.22]);
    g.sfx('crate_break', c, 1);
    const r = Math.random();
    const loot = r < 0.3 ? 'ammo' : r < 0.45 ? 'health' : r < 0.55 ? 'grenade' : r < 0.62 ? 'armor' : r < 0.66 ? 'upgrade' : null;
    if (loot) g.pickups.drop(loot, new THREE.Vector3(prop.x, prop.y, prop.z));
    g.pickups.drop('coin', new THREE.Vector3(prop.x + 0.4, prop.y, prop.z), { value: 2 });
    g.stats.cratesBroken++;
  }

  detonateBarrel(prop, delay) {
    if (!prop.alive || prop.pendingBoom) return;
    prop.pendingBoom = true;
    this.pending.push({ prop, t: delay });
  }

  explosion(pos, radius, damage) {
    for (const p of this.game.world.props) {
      if (!p.alive) continue;
      const d = Math.hypot(p.x - pos.x, p.z - pos.z);
      if (d > radius + 0.5) continue;
      if (p.type === 'barrel') this.detonateBarrel(p, 0.12 + Math.random() * 0.15);
      else if (p.type === 'crate') this.damage(p, damage, pos);
      else if (p.type === 'mine' && p.armed) { p.armed = false; p.fuse = 0.1 + Math.random() * 0.1; }
    }
  }

  // Nearest crate the player can kick open with the interact button.
  nearestCrate(pos) {
    let best = null, bd = 2.3;
    for (const p of this.game.world.props) {
      if (!p.alive || p.type !== 'crate') continue;
      const d = Math.hypot(p.x - pos.x, p.z - pos.z);
      if (d < bd) { bd = d; best = p; }
    }
    return best;
  }

  update(dt) {
    const g = this.game, P = g.player;
    for (let i = this.pending.length - 1; i >= 0; i--) {
      const b = this.pending[i];
      b.t -= dt;
      if (b.t <= 0) {
        this.pending.splice(i, 1);
        const p = b.prop;
        if (!p.alive) continue;
        g.world.destroyProp(p);
        g.combat.explode(new THREE.Vector3(p.x, p.y + 0.6, p.z), 6.5, 150, 'world');
        g.stats.barrels++;
      }
    }
    for (const p of g.world.props) {
      if (!p.alive) continue;
      const dxp = P.pos.x - p.x, dzp = P.pos.z - p.z;
      if (dxp * dxp + dzp * dzp > 3600) continue;
      if (p.type === 'spikes') {
        p.tick -= dt;
        if (p.tick > 0) continue;
        let hitAny = false;
        if (P.alive && Math.hypot(dxp, dzp) < p.radius && P.pos.y - p.y < 0.9) {
          P.takeDamage(12, _v.set(p.x, p.y, p.z), 'trap');
          hitAny = true;
        }
        for (const e of g.enemies.active) {
          if (!e.alive || e.def.behavior === 'flyer') continue;
          if (Math.hypot(e.pos.x - p.x, e.pos.z - p.z) < p.radius + e.def.radius * 0.5) {
            e.damage(35, _v.set(e.pos.x, e.pos.y + 0.3, e.pos.z), new THREE.Vector3(0, 1, 0), 'limb', { explosive: true, weapon: 'spikes' });
            hitAny = true;
          }
        }
        if (hitAny) { p.tick = 0.6; g.sfx('spike_hit', _v.set(p.x, p.y, p.z), 1); }
      } else if (p.type === 'mine') {
        const light = p.obj.getObjectByName('light');
        if (light) light.visible = p.armed ? Math.sin(g.time * 6 + p.x) > 0 : Math.sin(g.time * 40) > 0;
        if (p.armed) {
          let trig = P.alive && Math.hypot(dxp, dzp) < p.radius && P.pos.y - p.y < 1;
          if (!trig) {
            for (const e of g.enemies.active) {
              if (e.alive && e.def.behavior !== 'flyer' && Math.hypot(e.pos.x - p.x, e.pos.z - p.z) < p.radius + 0.3) { trig = true; break; }
            }
          }
          if (trig) { p.armed = false; p.fuse = 0.35; g.sfx('mine_beep', _v.set(p.x, p.y, p.z), 1); }
        } else if (p.fuse >= 0) {
          p.fuse -= dt;
          if (p.fuse < 0) {
            g.world.destroyProp(p);
            g.combat.explode(new THREE.Vector3(p.x, p.y + 0.3, p.z), 5.5, 120, 'world');
            g.stats.mines++;
          }
        }
      }
    }
  }
}
