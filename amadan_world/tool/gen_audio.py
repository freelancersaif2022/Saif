"""Procedural audio asset generator for Amadan World.

Synthesizes every sound effect and music loop as 16-bit mono WAV.
Run from the project root:
    python3 tool/gen_audio.py
"""
import os
import sys
import wave

import numpy as np

ROOT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), '..')
OUT = os.path.join(ROOT, 'assets', 'audio')
SR = 22050
rng = np.random.default_rng(99)


def save(name, x, peak=0.9):
    x = np.asarray(x, dtype=float)
    m = np.max(np.abs(x)) + 1e-9
    x = x / m * peak
    data = (np.clip(x, -1, 1) * 32767).astype('<i2')
    os.makedirs(OUT, exist_ok=True)
    with wave.open(os.path.join(OUT, name), 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data.tobytes())


def t_axis(dur):
    return np.arange(int(dur * SR)) / SR


def noise(dur):
    return rng.uniform(-1, 1, int(dur * SR))


def fft_filter(x, lo=None, hi=None, slope=2.0):
    n = len(x)
    X = np.fft.rfft(x)
    f = np.fft.rfftfreq(n, 1 / SR)
    g = np.ones_like(f)
    if hi is not None:
        g *= 1 / (1 + (f / hi) ** (2 * slope))
    if lo is not None:
        g *= 1 / (1 + (lo / np.maximum(f, 1e-3)) ** (2 * slope))
    return np.fft.irfft(X * g, n)


def env_exp(dur, decay, attack=0.002):
    t = t_axis(dur)
    a = np.clip(t / attack, 0, 1)
    return a * np.exp(-t / decay)


def sweep(dur, f0, f1, curve=4.0):
    t = t_axis(dur)
    f = f1 + (f0 - f1) * np.exp(-t * curve)
    ph = 2 * np.pi * np.cumsum(f) / SR
    return np.sin(ph)


def reverb(x, dur=0.6, mix=0.25, damp=3000):
    ir = noise(dur) * np.exp(-t_axis(dur) / (dur / 5))
    ir = fft_filter(ir, hi=damp)
    n = len(x) + len(ir)
    y = np.fft.irfft(np.fft.rfft(x, n) * np.fft.rfft(ir, n), n)
    y = y / (np.max(np.abs(y)) + 1e-9) * np.max(np.abs(x))
    out = np.zeros(n)
    out[:len(x)] += x
    out += y * mix
    return out


def pad(x, dur):
    n = int(dur * SR)
    if len(x) >= n:
        return x[:n]
    return np.concatenate([x, np.zeros(n - len(x))])


def gunshot(dur, crack_hi, body_lo, decay, thump_f, thump_amt, tail, damp):
    crack = fft_filter(noise(dur), lo=600, hi=crack_hi) * env_exp(dur, decay * 0.35, 0.0005)
    body = fft_filter(noise(dur), hi=body_lo) * env_exp(dur, decay, 0.001)
    thump = sweep(dur, thump_f * 2.2, thump_f, 25) * env_exp(dur, decay * 1.4, 0.001) * thump_amt
    x = crack * 0.8 + body * 1.2 + thump
    x = np.tanh(x * 2.2)
    return reverb(x, tail, 0.35, damp)


def click(dur=0.03, hi=6000, f=2500):
    t = t_axis(dur)
    return (fft_filter(noise(dur), lo=1500, hi=hi) + np.sin(2 * np.pi * f * t) * 0.4) * env_exp(dur, 0.006, 0.0003)


def place(buf, snd, at):
    i = int(at * SR)
    j = min(len(buf), i + len(snd))
    buf[i:j] += snd[: j - i]


def voice(dur, f0, f1, formants, rough=0.3):
    t = t_axis(dur)
    f = np.linspace(f0, f1, len(t)) * (1 + 0.03 * np.sin(2 * np.pi * 7 * t))
    ph = 2 * np.pi * np.cumsum(f) / SR
    saw = 2 * ((ph / (2 * np.pi)) % 1.0) - 1
    x = saw + noise(dur) * rough
    y = np.zeros_like(x)
    for fc, amp in formants:
        y += fft_filter(x, lo=fc * 0.8, hi=fc * 1.25, slope=2) * amp
    e = np.clip(t / 0.03, 0, 1) * np.clip((dur - t) / 0.12, 0, 1)
    return np.tanh(y * e * 3)


def explosion(dur=2.2):
    t = t_axis(dur)
    rumble = fft_filter(noise(dur), hi=180) * np.exp(-t / 0.7)
    blast = fft_filter(noise(dur), hi=1800) * env_exp(dur, 0.18, 0.002)
    thump = sweep(dur, 120, 32, 6) * np.exp(-t / 0.4)
    debris = np.zeros_like(t)
    for _ in range(30):
        place(debris, click(0.02, 4000, rng.uniform(800, 2400)) * rng.uniform(0.1, 0.3), rng.uniform(0.2, 1.4))
    x = np.tanh((rumble * 3 + blast * 1.4 + thump * 1.6) * 1.8) + debris
    return reverb(x, 1.0, 0.3, 1500)


def heartbeat():
    dur = 0.7
    x = np.zeros(int(dur * SR))
    beat = sweep(0.18, 90, 45, 18) * env_exp(0.18, 0.05, 0.004)
    place(x, beat, 0.0)
    place(x, beat * 0.7, 0.22)
    return fft_filter(x, hi=400)


# ---------------------------------------------------------------- music
def note_freq(n):
    return 440.0 * 2 ** ((n - 69) / 12)


def saw_wave(freq, t, detune=0.0):
    ph = (freq * (1 + detune)) * t
    return 2 * (ph % 1.0) - 1


def pad_chord(notes, dur, level=0.2):
    t = t_axis(dur)
    x = np.zeros_like(t)
    for n in notes:
        f = note_freq(n)
        for d in (-0.004, 0.0, 0.005):
            x += saw_wave(f, t, d)
    x = fft_filter(x, hi=900)
    a = np.clip(t / 1.2, 0, 1) * np.clip((dur - t) / 1.2, 0, 1)
    return x * a * level / len(notes)


def kick(level=1.0):
    d = 0.35
    return (sweep(d, 150, 45, 22) * env_exp(d, 0.12, 0.002) + fft_filter(noise(d), hi=3000) * env_exp(d, 0.008) * 0.3) * level


def tom(f=110, level=0.8):
    d = 0.45
    return (sweep(d, f * 1.6, f, 12) * env_exp(d, 0.16, 0.002) + fft_filter(noise(d), hi=1200) * env_exp(d, 0.03) * 0.3) * level


def snare(level=0.5):
    d = 0.3
    return (fft_filter(noise(d), lo=800, hi=7000) * env_exp(d, 0.07) + np.sin(2 * np.pi * 190 * t_axis(d)) * env_exp(d, 0.05) * 0.5) * level


def hat(level=0.15):
    d = 0.08
    return fft_filter(noise(d), lo=6000) * env_exp(d, 0.015) * level


def make_loop(x, dur):
    """Wraps everything past [dur] back onto the start so the loop is seamless."""
    n = int(dur * SR)
    y = np.zeros(n)
    y[: min(n, len(x))] = x[:n]
    over = x[n:]
    while len(over) > 0:
        k = min(n, len(over))
        y[:k] += over[:k]
        over = over[k:]
    return y


def music_menu():
    dur = 24.0
    x = np.zeros(int(dur * SR) + SR * 2)
    chords = [(38, 45, 50, 53), (34, 41, 46, 50), (36, 43, 48, 51), (33, 40, 45, 49)]
    for i, ch in enumerate(chords):
        place(x, pad_chord(ch, 7.2, 0.5), i * 6.0)
    for i in range(12):
        place(x, tom(70, 0.9 if i % 4 == 0 else 0.5), i * 2.0)
    t = t_axis(len(x) / SR)
    drone = np.sin(2 * np.pi * note_freq(26) * t) * 0.25 + np.sin(2 * np.pi * note_freq(38) * t) * 0.08
    x += drone[: len(x)]
    bell = np.zeros_like(x)
    seq = [62, 65, 69, 67, 65, 62, 60, 62]
    for i, n in enumerate(seq):
        d = 2.5
        tt = t_axis(d)
        b = (np.sin(2 * np.pi * note_freq(n) * tt) + 0.3 * np.sin(2 * np.pi * note_freq(n) * 2.01 * tt)) * np.exp(-tt / 0.9) * 0.12
        place(bell, b, 1.0 + i * 3.0)
    x += reverb(bell, 1.5, 0.6, 3000)[: len(x)]
    x = make_loop(x, dur)
    save('music_menu.wav', x, 0.8)


def music_battle():
    bpm = 120
    beat = 60 / bpm
    bars = 16
    dur = bars * 4 * beat
    x = np.zeros(int((dur + 1.0) * SR))
    roots = [38, 38, 34, 36] * 4
    for bar in range(bars):
        t0 = bar * 4 * beat
        r = roots[bar]
        for b in range(4):
            place(x, kick(0.9), t0 + b * beat)
            if b in (1, 3):
                place(x, snare(0.45), t0 + b * beat)
            for h in range(2):
                place(x, hat(0.12 if h else 0.18), t0 + b * beat + h * beat / 2)
        if bar % 2 == 1:
            place(x, tom(90, 0.6), t0 + 3.5 * beat)
            place(x, tom(70, 0.6), t0 + 3.75 * beat)
        for s in range(8):
            d = beat / 2 * 0.95
            tt = t_axis(d)
            n = r + (12 if s in (3, 6) else 0)
            b_ = saw_wave(note_freq(n), tt) + saw_wave(note_freq(n), tt, 0.006)
            b_ = fft_filter(b_, hi=500) * np.exp(-tt / 0.18) * 0.32
            place(x, b_, t0 + s * beat / 2)
        place(x, pad_chord((r + 12, r + 19, r + 24, r + 27), 4 * beat + 0.6, 0.3), t0)
    x = make_loop(x, dur)
    save('music_battle.wav', x, 0.8)


def ambient():
    dur = 16.0
    t = t_axis(dur + 1.0)
    wind = fft_filter(noise(dur + 1.0), lo=80, hi=500) * (0.6 + 0.4 * np.sin(2 * np.pi * 0.11 * t + 1.0)) * 0.5
    x = wind.copy()
    for at in (2.3, 9.1, 13.4):
        e = explosion(2.0)
        e = fft_filter(e, hi=500) * 0.35
        place(x, e, at)
    for burst_at in (4.5, 7.8, 11.2, 14.6):
        for k in range(int(rng.integers(4, 9))):
            g = gunshot(0.3, 2500, 800, 0.03, 90, 0.3, 0.4, 1200)
            g = fft_filter(g, hi=900) * 0.12
            place(x, g, burst_at + k * rng.uniform(0.09, 0.14))
    x = make_loop(x, dur)
    save('ambient_battle.wav', x, 0.7)


def main():
    save('shot_ar.wav', gunshot(0.6, 7000, 1500, 0.05, 90, 0.9, 0.5, 2500))
    save('shot_smg.wav', gunshot(0.45, 8000, 2000, 0.035, 120, 0.6, 0.35, 3000))
    save('shot_shotgun.wav', gunshot(0.9, 5000, 900, 0.09, 65, 1.4, 0.7, 1800))
    save('shot_sniper.wav', gunshot(1.4, 9000, 1200, 0.07, 55, 1.6, 1.2, 2200))
    save('enemy_shot.wav', fft_filter(gunshot(0.5, 4000, 1000, 0.045, 100, 0.6, 0.45, 1500), hi=2500), 0.7)
    save('boss_shot.wav', gunshot(0.9, 4000, 700, 0.1, 50, 1.8, 0.8, 1200))
    rl = np.zeros(int(1.3 * SR))
    place(rl, click(0.04, 5000, 1800), 0.05)
    place(rl, fft_filter(noise(0.12), lo=300, hi=2000) * env_exp(0.12, 0.04) * 0.6, 0.3)
    place(rl, click(0.05, 4500, 1400) * 1.2, 0.8)
    place(rl, click(0.03, 6000, 2600), 1.05)
    place(rl, click(0.04, 6000, 2200) * 1.1, 1.15)
    save('reload.wav', rl, 0.8)
    save('empty.wav', pad(click(0.05, 7000, 3200), 0.12), 0.6)
    save('impact.wav', pad(fft_filter(noise(0.15), lo=1500, hi=8000) * env_exp(0.15, 0.02) + sweep(0.15, 3200, 1800, 10) * env_exp(0.15, 0.04) * 0.3, 0.2), 0.6)
    hit = sweep(0.2, 160, 60, 20) * env_exp(0.2, 0.05) + fft_filter(noise(0.2), hi=1500) * env_exp(0.2, 0.02) * 0.6
    save('hit.wav', hit, 0.8)
    save('enemy_alert.wav', voice(0.45, 140, 110, [(600, 1.0), (1100, 0.6), (2400, 0.2)]), 0.6)
    save('enemy_death.wav', reverb(voice(0.8, 150, 80, [(500, 1.0), (900, 0.7), (2300, 0.2)], 0.4), 0.5, 0.3, 2000), 0.7)
    hurt = voice(0.35, 180, 130, [(700, 1.0), (1200, 0.6), (2600, 0.2)], 0.5)
    save('player_hurt.wav', hurt + pad(hit, 0.35) * 0.5, 0.75)
    pd = np.zeros(int(2.2 * SR))
    place(pd, voice(1.0, 170, 70, [(600, 1.0), (1000, 0.6), (2500, 0.2)], 0.5), 0.0)
    place(pd, heartbeat(), 0.9)
    place(pd, heartbeat() * 0.5, 1.5)
    save('player_death.wav', reverb(pd, 0.8, 0.35, 1500), 0.8)
    roar = voice(1.8, 75, 55, [(300, 1.0), (700, 0.8), (1500, 0.3)], 0.8)
    roar *= 0.7 + 0.3 * np.sin(2 * np.pi * 9 * t_axis(1.8))
    save('boss_roar.wav', reverb(np.tanh(roar * 2), 1.0, 0.4, 1200), 0.9)
    save('explosion.wav', explosion(), 0.95)
    save('heartbeat.wav', heartbeat(), 0.8)
    save('ui_click.wav', pad(click(0.03, 9000, 2000) + np.sin(2 * np.pi * 1200 * t_axis(0.03)) * env_exp(0.03, 0.01) * 0.5, 0.08), 0.5)
    sel = np.zeros(int(0.25 * SR))
    for i, f in enumerate((660, 990)):
        tt = t_axis(0.1)
        place(sel, np.sin(2 * np.pi * f * tt) * env_exp(0.1, 0.035), i * 0.08)
    place(sel, click(0.04, 5000, 1500) * 0.6, 0.0)
    save('ui_select.wav', sel, 0.5)
    music_menu()
    music_battle()
    ambient()


if __name__ == '__main__':
    main()
