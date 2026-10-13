"""Procedural audio generator for Dragon Land.

Synthesizes every sound effect and both music loops as 16-bit mono WAV files.
All audio is original. Run from the project root:

    python3 tool/gen_audio.py
"""
import os
import sys
import wave

import numpy as np

ROOT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), '..')
OUT = os.path.join(ROOT, 'assets', 'audio')
SR = 22050
rng = np.random.default_rng(7)


def save(name, x, peak=0.85):
    x = np.asarray(x, dtype=float)
    m = np.max(np.abs(x)) + 1e-9
    x = x / m * peak
    # 4 ms fade in/out to avoid clicks
    f = min(len(x) // 4, int(0.004 * SR))
    if f > 0:
        x[:f] *= np.linspace(0, 1, f)
        x[-f:] *= np.linspace(1, 0, f)
    data = (np.clip(x, -1, 1) * 32767).astype('<i2')
    os.makedirs(OUT, exist_ok=True)
    with wave.open(os.path.join(OUT, name), 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data.tobytes())
    print('wrote', name, f'{len(x) / SR:.2f}s')


def t_axis(dur):
    return np.arange(int(dur * SR)) / SR


def env(t, a, d, s=0.0, r=0.0, dur=None):
    dur = t[-1] if dur is None else dur
    e = np.ones_like(t)
    e = np.where(t < a, t / max(a, 1e-6), e)
    dec = (t >= a) & (t < a + d)
    e = np.where(dec, 1 - (1 - s) * (t - a) / max(d, 1e-6), e)
    e = np.where(t >= a + d, s, e)
    if r > 0:
        e = np.where(t > dur - r, e * np.clip((dur - t) / r, 0, 1), e)
    return e


def exp_env(t, k):
    return np.exp(-t * k)


def sine(f, t):
    if np.isscalar(f):
        return np.sin(2 * np.pi * f * t)
    ph = np.cumsum(f) / SR
    return np.sin(2 * np.pi * ph)


def square(f, t, duty=0.5):
    if np.isscalar(f):
        ph = (f * t) % 1.0
    else:
        ph = (np.cumsum(f) / SR) % 1.0
    return np.where(ph < duty, 1.0, -1.0)


def tri(f, t):
    ph = (np.cumsum(np.full_like(t, f) if np.isscalar(f) else f) / SR) % 1.0
    return 4 * np.abs(ph - 0.5) - 1


def noise(n):
    return rng.uniform(-1, 1, n)


def lowpass(x, cutoff):
    """One-pole low-pass; cutoff may be an array."""
    cutoff = np.broadcast_to(cutoff, x.shape)
    y = np.zeros_like(x)
    acc = 0.0
    for i in range(len(x)):
        a = 1 - np.exp(-2 * np.pi * cutoff[i] / SR)
        acc += a * (x[i] - acc)
        y[i] = acc
    return y


def highpass(x, cutoff):
    return x - lowpass(x, cutoff)


def sweep(f0, f1, t, curve=1.0):
    u = t / t[-1]
    return f0 + (f1 - f0) * u ** curve


# ------------------------------------------------------------------ effects
def coin():
    t = t_axis(0.22)
    f = np.where(t < 0.06, 988, 1319)
    x = square(f, t, 0.25) * 0.4 + sine(f * 2, t) * 0.3
    save('coin.wav', x * exp_env(t, 14), 0.6)


def gem():
    t = t_axis(0.5)
    x = np.zeros_like(t)
    for i, f in enumerate([1047, 1319, 1568, 2093]):
        tt = np.clip(t - i * 0.06, 0, None)
        x += sine(f, tt) * exp_env(tt, 7) * (tt > 0)
    save('gem.wav', x, 0.6)


def jump():
    t = t_axis(0.22)
    f = sweep(260, 620, t, 0.6)
    x = square(f, t, 0.3) * 0.5 + sine(f, t) * 0.5
    save('jump.wav', x * env(t, 0.005, 0.2, 0.0), 0.55)


def land():
    t = t_axis(0.16)
    x = lowpass(noise(len(t)), 600) * exp_env(t, 30) + sine(sweep(120, 60, t), t) * exp_env(t, 25)
    save('land.wav', x, 0.6)


def flap():
    t = t_axis(0.25)
    n = lowpass(noise(len(t)), sweep(1800, 400, t))
    e = np.exp(-((t - 0.07) / 0.05) ** 2)
    save('flap.wav', n * e, 0.6)


def fly_start():
    t = t_axis(0.6)
    x = np.zeros_like(t)
    for k in range(3):
        tt = t - k * 0.16
        e = np.exp(-((tt - 0.07) / 0.05) ** 2)
        x += lowpass(noise(len(t)), 1200) * e
    x += sine(sweep(300, 700, t), t) * 0.2 * env(t, 0.1, 0.5)
    save('fly.wav', x, 0.6)


def sprint():
    t = t_axis(0.5)
    n = noise(len(t))
    x = lowpass(n, sweep(300, 3000, t, 0.7)) - lowpass(n, 200)
    save('sprint.wav', x * env(t, 0.05, 0.45, 0.0), 0.5)


def fire():
    t = t_axis(0.55)
    n = noise(len(t))
    x = lowpass(n, sweep(2600, 500, t)) * env(t, 0.01, 0.54, 0.0)
    x += sine(sweep(180, 90, t), t) * 0.4 * exp_env(t, 5)
    save('fire.wav', x, 0.7)


def water():
    t = t_axis(0.45)
    x = np.zeros_like(t)
    for k in range(7):
        st = k * 0.045 + rng.uniform(0, 0.02)
        tt = np.clip(t - st, 0, None)
        f = sweep(500 + 120 * k, 1400 + 150 * k, t)
        x += sine(f, tt) * exp_env(tt, 30) * (t > st)
    x += lowpass(noise(len(t)), 1500) * 0.3 * exp_env(t, 6)
    save('water.wav', x, 0.6)


def shadow():
    t = t_axis(0.6)
    f = sweep(600, 120, t, 0.5)
    x = sine(f, t) * 0.6 + square(f * 0.5, t, 0.5) * 0.15
    x += lowpass(noise(len(t)), 900) * 0.3
    save('shadow.wav', x * env(t, 0.02, 0.58, 0.0), 0.6)


def leaf():
    t = t_axis(0.4)
    n = noise(len(t))
    x = highpass(lowpass(n, 5000), 1500) * env(t, 0.02, 0.38)
    x += sine(sweep(700, 1100, t), t) * 0.3 * exp_env(t, 6)
    save('leaf.wav', x, 0.55)


def solar():
    t = t_axis(0.8)
    x = np.zeros_like(t)
    for f in [330, 495, 660, 990]:
        x += sine(f * (1 + 0.004 * sine(6, t)), t)
    x *= env(t, 0.05, 0.75, 0.0)
    x += lowpass(noise(len(t)), sweep(4000, 600, t)) * 0.4 * exp_env(t, 3)
    save('solar.wav', x, 0.6)


def special():
    t = t_axis(0.9)
    f = sweep(220, 880, t, 0.5)
    x = sine(f, t) + 0.5 * sine(f * 1.5, t) + 0.3 * square(f * 0.5, t, 0.2)
    x *= env(t, 0.03, 0.8, 0.0)
    x += lowpass(noise(len(t)), 2000) * 0.3 * exp_env(t, 4)
    save('special.wav', x, 0.6)


def shield():
    t = t_axis(0.6)
    x = sine(523 * (1 + 0.02 * sine(9, t)), t) + 0.6 * sine(784, t) + 0.3 * sine(1046, t)
    save('shield.wav', x * env(t, 0.03, 0.55, 0.0), 0.5)


def hit_enemy():
    t = t_axis(0.18)
    x = lowpass(noise(len(t)), 2500) * exp_env(t, 25) + square(sweep(300, 120, t), t) * 0.4 * exp_env(t, 20)
    save('hit.wav', x, 0.6)


def enemy_defeat():
    t = t_axis(0.45)
    f = sweep(700, 150, t)
    x = square(f, t, 0.4) * 0.4 * exp_env(t, 5) + lowpass(noise(len(t)), 1800) * 0.5 * exp_env(t, 10)
    save('defeat.wav', x, 0.6)


def damage():
    t = t_axis(0.4)
    f = sweep(420, 140, t)
    x = square(f, t, 0.5) * 0.5 + sine(f * 0.5, t) * 0.5
    x *= env(t, 0.005, 0.39, 0.0)
    x += lowpass(noise(len(t)), 1200) * 0.4 * exp_env(t, 15)
    save('damage.wav', x, 0.7)


def break_sfx():
    t = t_axis(0.5)
    x = np.zeros_like(t)
    for k in range(9):
        st = rng.uniform(0, 0.2)
        tt = np.clip(t - st, 0, None)
        x += sine(rng.uniform(1800, 4200), tt) * exp_env(tt, 35) * (t > st) * 0.5
    x += lowpass(noise(len(t)), 3000) * exp_env(t, 12)
    save('break.wav', x, 0.6)


def chest():
    t = t_axis(1.0)
    x = lowpass(noise(len(t)), 800) * exp_env(t, 20) * 0.6
    for i, f in enumerate([784, 988, 1175, 1568, 1976]):
        tt = np.clip(t - 0.12 - i * 0.07, 0, None)
        x += sine(f, tt) * exp_env(tt, 5) * (tt > 0) * 0.6
    save('chest.wav', x, 0.6)


def unlock():
    t = t_axis(1.3)
    x = np.zeros_like(t)
    notes = [523, 659, 784, 1047, 784, 1047, 1319]
    for i, f in enumerate(notes):
        st = i * 0.11
        tt = np.clip(t - st, 0, None)
        x += (sine(f, tt) + 0.3 * square(f, tt, 0.25)) * exp_env(tt, 4) * (t > st)
    save('unlock.wav', x, 0.6)


def button():
    t = t_axis(0.09)
    x = sine(sweep(900, 1300, t), t) * exp_env(t, 40)
    save('button.wav', x, 0.5)


def powerup():
    t = t_axis(0.6)
    x = np.zeros_like(t)
    for i, f in enumerate([523, 659, 784, 1047, 1319, 1568]):
        st = i * 0.06
        tt = np.clip(t - st, 0, None)
        x += square(f, tt, 0.3) * exp_env(tt, 10) * (t > st) * 0.5
    save('powerup.wav', x, 0.55)


def game_over():
    t = t_axis(1.8)
    x = np.zeros_like(t)
    for i, f in enumerate([392, 349, 311, 262]):
        st = i * 0.32
        tt = np.clip(t - st, 0, None)
        dur = 0.6 if i == 3 else 0.32
        x += (tri(f, tt) * 0.6 + sine(f / 2, tt) * 0.4) * np.exp(-tt * (2 if i == 3 else 5)) * (t > st) * (tt < dur + 0.4)
    save('game_over.wav', x, 0.6)


def boss_roar():
    t = t_axis(1.2)
    f = 90 + 30 * sine(7, t) + sweep(40, -20, t)
    x = square(f, t, 0.35) * 0.4 + lowpass(noise(len(t)), 700) * 0.6
    save('boss_roar.wav', x * env(t, 0.08, 1.1, 0.0), 0.7)


def boss_slam():
    t = t_axis(0.7)
    x = sine(sweep(90, 35, t), t) * exp_env(t, 5) + lowpass(noise(len(t)), 500) * exp_env(t, 8)
    save('slam.wav', x, 0.8)


def purchase():
    t = t_axis(0.8)
    x = np.zeros_like(t)
    for i, f in enumerate([1047, 1319, 1568, 2093]):
        st = i * 0.08
        tt = np.clip(t - st, 0, None)
        x += (sine(f, tt) + 0.2 * sine(f * 2, tt)) * exp_env(tt, 6) * (t > st)
    save('purchase.wav', x, 0.55)


# -------------------------------------------------------------------- music
NOTE = {n: i for i, n in enumerate(['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'])}


def midi(name):
    n, o = name[:-1], int(name[-1])
    return 12 * (o + 1) + NOTE[n]


def freq(m):
    return 440.0 * 2 ** ((m - 69) / 12)


def render_track(bpm, bars, chords, melody, bass_pattern, drums=True, lead='square', pad_level=0.18):
    beat = 60.0 / bpm
    total = bars * 4 * beat
    n = int(total * SR)
    t = np.arange(n) / SR
    out = np.zeros(n)

    def add_note(m, start, dur, kind, vol):
        i0 = int(start * SR)
        i1 = min(n, int((start + dur) * SR))
        if i0 >= n:
            return
        tt = np.arange(i1 - i0) / SR
        f = freq(m)
        if kind == 'square':
            w = square(f, tt, 0.25) * 0.5 + sine(f, tt) * 0.5
        elif kind == 'tri':
            w = tri(f, tt)
        elif kind == 'pluck':
            w = sine(f, tt) * 0.7 + sine(2 * f, tt) * 0.2 + sine(3 * f, tt) * 0.1
        else:
            w = sine(f, tt)
        e = np.minimum(1, tt / 0.01) * np.exp(-tt * (3.0 if kind != 'pad' else 0.4))
        if kind == 'pad':
            e = np.minimum(1, tt / 0.15) * np.minimum(1, (dur - tt) / 0.2)
        out[i0:i1] += w * e * vol

    # chords (pads + arpeggio)
    for bar in range(bars):
        ch = chords[bar % len(chords)]
        for m in ch:
            add_note(midi(m), bar * 4 * beat, 4 * beat, 'pad', pad_level)
        for k in range(8):
            m = midi(ch[k % len(ch)]) + 12
            add_note(m, bar * 4 * beat + k * beat / 2, beat / 2, 'pluck', 0.12)
        for k, step in enumerate(bass_pattern):
            if step is None:
                continue
            m = midi(ch[0]) - 12 + step
            add_note(m, bar * 4 * beat + k * beat / 2, beat / 2 * 0.9, 'tri', 0.35)
    # melody: list of (note or None, beats)
    pos = 0.0
    for m, b in melody:
        if m is not None:
            add_note(midi(m), pos * beat, b * beat * 0.95, lead, 0.32)
        pos += b
    if drums:
        for k in range(bars * 8):
            st = k * beat / 2
            i0 = int(st * SR)
            if k % 4 == 0:
                tt = np.arange(int(0.15 * SR)) / SR
                kick = sine(sweep(150, 45, tt), tt) * np.exp(-tt * 18)
                out[i0:i0 + len(kick)] += kick[:max(0, min(len(kick), n - i0))] * 0.6
            if k % 4 == 2:
                tt = np.arange(int(0.12 * SR)) / SR
                sn = noise(len(tt)) * np.exp(-tt * 25) * 0.35 + sine(190, tt) * np.exp(-tt * 30) * 0.2
                out[i0:i0 + len(sn)] += sn[:max(0, min(len(sn), n - i0))]
            tt = np.arange(int(0.04 * SR)) / SR
            hh = highpass(noise(len(tt)), 6000) * np.exp(-tt * 80) * 0.12
            out[i0:i0 + len(hh)] += hh[:max(0, min(len(hh), n - i0))]
    return out


def music():
    chords = [['C4', 'E4', 'G4'], ['A3', 'C4', 'E4'], ['F3', 'A3', 'C4'], ['G3', 'B3', 'D4']]
    mel = []
    phrase1 = [('E5', 1), ('G5', 0.5), ('E5', 0.5), ('D5', 1), ('C5', 1),
               ('E5', 1), ('C5', 0.5), ('A4', 0.5), ('C5', 2),
               ('F5', 1), ('E5', 0.5), ('D5', 0.5), ('C5', 1), ('A4', 1),
               ('B4', 1), ('D5', 1), ('G5', 2)]
    phrase2 = [('G5', 0.5), ('A5', 0.5), ('G5', 0.5), ('E5', 0.5), ('C5', 1), ('E5', 1),
               ('A5', 1), ('G5', 0.5), ('E5', 0.5), ('C5', 2),
               ('F5', 0.5), ('G5', 0.5), ('A5', 1), ('G5', 1), ('F5', 1),
               ('D5', 1), ('B4', 1), ('C5', 2)]
    mel = phrase1 + phrase2
    bass = [0, None, 7, None, 12, None, 7, None]
    x = render_track(128, 8, chords, mel, bass, drums=True, lead='square')
    save('music_game.wav', x, 0.7)

    chords2 = [['F3', 'A3', 'C4'], ['C4', 'E4', 'G4'], ['D4', 'F4', 'A4'], ['A#3', 'D4', 'F4']]
    mel2 = [('A4', 1.5), ('C5', 0.5), ('F5', 2), ('E5', 1.5), ('D5', 0.5), ('C5', 2),
            ('D5', 1.5), ('F5', 0.5), ('A5', 2), ('G5', 1), ('F5', 1), ('D5', 2),
            ('A4', 1.5), ('C5', 0.5), ('F5', 2), ('G5', 1.5), ('A5', 0.5), ('G5', 2),
            ('F5', 1), ('D5', 1), ('C5', 1), ('A#4', 1), ('A4', 4)]
    bass2 = [0, None, None, None, 7, None, None, None]
    y = render_track(96, 8, chords2, mel2, bass2, drums=False, lead='pluck', pad_level=0.22)
    save('music_lobby.wav', y, 0.65)


if __name__ == '__main__':
    coin()
    gem()
    jump()
    land()
    flap()
    fly_start()
    sprint()
    fire()
    water()
    shadow()
    leaf()
    solar()
    special()
    shield()
    hit_enemy()
    enemy_defeat()
    damage()
    break_sfx()
    chest()
    unlock()
    button()
    powerup()
    game_over()
    boss_roar()
    boss_slam()
    purchase()
    music()
