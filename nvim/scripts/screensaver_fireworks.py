#!/usr/bin/env python3
"""
fireworks — A terminal fireworks show that builds from a single rocket
             to a full grand finale.

Usage:  python3 fireworks.py
Exit:   Press any key or Ctrl-C
"""

import curses
import random
import math
import time
import signal
import sys


# ── Colour pairs ────────────────────────────────────────────────────
C_RED     = 1
C_YELLOW  = 2
C_CYAN    = 3
C_MAGENTA = 4
C_GREEN   = 5
C_WHITE   = 6
C_BLUE    = 7
C_TRAIL   = 8
C_WATER   = 9
C_STAR    = 10
C_GROUND  = 11

ALL_FW_COLORS = [C_RED, C_YELLOW, C_CYAN, C_MAGENTA, C_GREEN, C_WHITE]


def init_colors():
    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(C_RED,     curses.COLOR_RED,     -1)
    curses.init_pair(C_YELLOW,  curses.COLOR_YELLOW,  -1)
    curses.init_pair(C_CYAN,    curses.COLOR_CYAN,    -1)
    curses.init_pair(C_MAGENTA, curses.COLOR_MAGENTA, -1)
    curses.init_pair(C_GREEN,   curses.COLOR_GREEN,   -1)
    curses.init_pair(C_WHITE,   curses.COLOR_WHITE,   -1)
    curses.init_pair(C_BLUE,    curses.COLOR_BLUE,    -1)
    curses.init_pair(C_TRAIL,   curses.COLOR_RED,     -1)
    curses.init_pair(C_WATER,   curses.COLOR_BLUE,    -1)
    curses.init_pair(C_STAR,    curses.COLOR_WHITE,   -1)
    curses.init_pair(C_GROUND,  curses.COLOR_WHITE,   -1)


def safe_put(scr, y, x, ch, attr=0):
    rows, cols = scr.getmaxyx()
    if 0 <= int(y) < rows and 0 <= int(x) < cols:
        try:
            scr.addstr(int(y), int(x), ch, attr)
        except curses.error:
            pass


# ── Particle ────────────────────────────────────────────────────────
class Particle:
    __slots__ = ('x', 'y', 'vx', 'vy', 'life', 'max_life', 'char',
                 'color', 'gravity', 'drag', 'trail')

    def __init__(self, x, y, vx, vy, life, color, char='✦',
                 gravity=0.02, drag=0.99, trail=False):
        self.x = float(x)
        self.y = float(y)
        self.vx = vx
        self.vy = vy
        self.life = life
        self.max_life = life
        self.char = char
        self.color = color
        self.gravity = gravity
        self.drag = drag
        self.trail = trail

    def tick(self):
        self.x += self.vx
        self.y += self.vy
        self.vy += self.gravity
        self.vx *= self.drag
        self.vy *= self.drag
        self.life -= 1

    @property
    def alive(self):
        return self.life > 0

    @property
    def frac(self):
        return self.life / self.max_life


# ── Burst patterns ─────────────────────────────────────────────────
def burst_sphere(x, y, color, n=None):
    """Classic spherical burst."""
    n = n or random.randint(30, 60)
    speed = random.uniform(0.8, 2.0)
    particles = []
    for i in range(n):
        angle = (i / n) * math.tau
        s = speed * random.uniform(0.7, 1.3)
        vx = math.cos(angle) * s
        vy = math.sin(angle) * s * 0.5  # squash vertically for terminal aspect
        life = random.randint(40, 70)
        particles.append(Particle(x, y, vx, vy, life, color))
    return particles


def burst_ring(x, y, color):
    """Tight ring — particles at uniform distance."""
    n = random.randint(24, 40)
    speed = random.uniform(1.2, 2.2)
    particles = []
    for i in range(n):
        angle = (i / n) * math.tau
        vx = math.cos(angle) * speed
        vy = math.sin(angle) * speed * 0.45
        life = random.randint(30, 50)
        particles.append(Particle(x, y, vx, vy, life, color,
                                  char='·', drag=0.99))
    return particles


def burst_double(x, y, color):
    """Two concentric rings, different colours."""
    c2 = random.choice([c for c in ALL_FW_COLORS if c != color])
    inner = burst_ring(x, y, color)
    outer = burst_sphere(x, y, c2, n=random.randint(20, 35))
    # Make outer bigger
    for p in outer:
        p.vx *= 1.5
        p.vy *= 1.5
    return inner + outer


def burst_willow(x, y, color):
    """Droopy willow tendrils that hang and fade long."""
    n = random.randint(30, 50)
    particles = []
    for i in range(n):
        angle = (i / n) * math.tau
        speed = random.uniform(0.6, 1.5)
        vx = math.cos(angle) * speed
        vy = math.sin(angle) * speed * 0.4
        life = random.randint(40, 80)
        particles.append(Particle(x, y, vx, vy, life, color,
                                  char=':', gravity=0.03, drag=0.99,
                                  trail=True))
    return particles


def burst_crackle(x, y, color):
    """Random chaotic burst with secondary pops."""
    particles = []
    n = random.randint(10, 18)
    for _ in range(n):
        angle = random.uniform(0, math.tau)
        speed = random.uniform(0.5, 2.5)
        vx = math.cos(angle) * speed
        vy = math.sin(angle) * speed * 0.5
        life = random.randint(20, 40)
        particles.append(Particle(x, y, vx, vy, life, color, char='*'))
    return particles


def burst_palm(x, y, color):
    """Palm tree shape — several streaks going up then curving down."""
    particles = []
    arms = random.randint(5, 9)
    for a in range(arms):
        angle = (a / arms) * math.tau
        n = random.randint(6, 12)
        for i in range(n):
            t = (i + 1) / n
            speed = 1.0 + t * 1.2
            vx = math.cos(angle) * speed * random.uniform(0.9, 1.1)
            vy = math.sin(angle) * speed * 0.5 * random.uniform(0.9, 1.1)
            life = int(30 + t * 20)
            particles.append(Particle(x, y, vx, vy, life, color,
                                      char='✦', gravity=0.03, drag=0.99,
                                      trail=True))
    return particles


def burst_crossette(x, y, color):
    """Cross pattern — 4 streaks at 90° angles."""
    particles = []
    for angle_deg in [0, 90, 180, 270]:
        angle = math.radians(angle_deg + random.uniform(-10, 10))
        for i in range(8):
            speed = 0.8 + i * 0.2
            vx = math.cos(angle) * speed
            vy = math.sin(angle) * speed * 0.5
            life = random.randint(12, 22)
            particles.append(Particle(x, y, vx, vy, life, color,
                                      char='+', drag=0.99))
    return particles


BURST_TYPES = [burst_sphere, burst_ring, burst_double, burst_willow,
               burst_crackle, burst_palm, burst_crossette]


# ── Firework (rocket + burst) ──────────────────────────────────────
class Firework:
    def __init__(self, cols, ground_y):
        self.x = random.randint(5, cols - 5)
        self.y = float(ground_y)
        self.target_y = random.randint(3, ground_y // 2)
        self.speed = random.uniform(0.8, 1.6)
        self.color = random.choice(ALL_FW_COLORS)
        self.phase = 'launch'
        self.particles = []
        self.sparks = []  # launch trail sparks
        self.burst_fn = random.choice(BURST_TYPES)
        self.secondary_timer = -1  # for crackle secondary pops

    def tick(self):
        if self.phase == 'launch':
            # Launch trail sparks
            if random.random() < 0.6:
                self.sparks.append(Particle(
                    self.x + random.uniform(-0.3, 0.3),
                    self.y,
                    random.uniform(-0.2, 0.2),
                    random.uniform(0.1, 0.4),
                    random.randint(3, 8),
                    C_TRAIL, char='·', gravity=0.02, drag=0.95
                ))
            self.y -= self.speed
            if self.y <= self.target_y:
                self.phase = 'burst'
                self.particles = self.burst_fn(self.x, self.y, self.color)
                if self.burst_fn == burst_crackle:
                    self.secondary_timer = 8

        elif self.phase == 'burst':
            # Secondary crackle pops
            if self.secondary_timer > 0:
                self.secondary_timer -= 1
                if self.secondary_timer == 0:
                    for p in list(self.particles):
                        if p.alive and random.random() < 0.4:
                            c2 = random.choice(ALL_FW_COLORS)
                            extras = burst_sphere(p.x, p.y, c2, n=6)
                            for e in extras:
                                e.vx *= 0.4
                                e.vy *= 0.4
                                e.life = random.randint(6, 12)
                            self.particles.extend(extras)

            for p in self.particles:
                p.tick()
            self.particles = [p for p in self.particles if p.alive]

            for s in self.sparks:
                s.tick()
            self.sparks = [s for s in self.sparks if s.alive]

            if not self.particles and not self.sparks:
                self.phase = 'done'

    def draw(self, scr, water_y):
        if self.phase == 'launch':
            attr = curses.color_pair(self.color) | curses.A_BOLD
            safe_put(scr, int(self.y), self.x, '✦', attr)
            # Trail
            for s in self.sparks:
                s.tick()
                a = curses.color_pair(C_TRAIL) | (curses.A_DIM if s.frac < 0.5 else 0)
                safe_put(scr, int(s.y), int(s.x), s.char, a)
            self.sparks = [s for s in self.sparks if s.alive]

        elif self.phase == 'burst':
            for p in self.particles:
                frac = p.frac
                if frac > 0.6:
                    ch = p.char
                    a = curses.color_pair(p.color) | curses.A_BOLD
                elif frac > 0.3:
                    ch = '·' if p.char not in (':', '+') else p.char
                    a = curses.color_pair(p.color)
                else:
                    ch = '.'
                    a = curses.color_pair(p.color) | curses.A_DIM

                safe_put(scr, int(p.y), int(p.x), ch, a)

                # Draw trail for willow/palm types
                if p.trail and frac > 0.3:
                    prev_y = p.y - p.vy
                    prev_x = p.x - p.vx
                    safe_put(scr, int(prev_y), int(prev_x), '.',
                             curses.color_pair(p.color) | curses.A_DIM)

                # Water reflection (faint, jittered)
                if water_y is not None:
                    ref_y = water_y + (water_y - int(p.y))
                    if frac > 0.4 and random.random() < 0.25:
                        ref_x = int(p.x) + random.choice([-1, 0, 0, 1])
                        safe_put(scr, ref_y, ref_x, '~',
                                 curses.color_pair(p.color) | curses.A_DIM)

            # Remaining launch sparks
            for s in self.sparks:
                a = curses.color_pair(C_TRAIL) | curses.A_DIM
                safe_put(scr, int(s.y), int(s.x), s.char, a)


# ── Scenery ─────────────────────────────────────────────────────────
def draw_skyline(scr, ground_y, cols):
    """Simple dark building silhouettes along the bottom."""
    attr = curses.color_pair(C_GROUND) | curses.A_DIM
    x = 0
    random.seed(42)  # consistent skyline
    while x < cols:
        w = random.randint(3, 8)
        h = random.randint(2, 7)
        for bx in range(x, min(x + w, cols)):
            for by in range(ground_y - h, ground_y + 1):
                safe_put(scr, by, bx, '▒', attr)
            # Occasional tiny lit window
            if random.random() < 0.3 and h > 2:
                wy = ground_y - random.randint(1, h - 1)
                safe_put(scr, wy, bx, '▪',
                         curses.color_pair(C_YELLOW) | curses.A_DIM)
        x += w + random.randint(1, 4)
    random.seed()  # re-randomise


def draw_water(scr, water_y, rows, cols, tick):
    """Gentle water surface."""
    attr = curses.color_pair(C_WATER) | curses.A_DIM
    for wy in range(water_y, min(water_y + 3, rows)):
        for x in range(cols):
            wave = math.sin(x * 0.15 + tick * 0.06 + wy * 0.8)
            if wave > 0.2:
                ch = '~' if wave > 0.6 else '≈'
                safe_put(scr, wy, x, ch, attr)


def draw_stars(scr, stars, tick, alpha):
    for y, x, rate in stars:
        if random.random() > alpha:
            continue
        bright = math.sin(tick * rate + x) > 0.1
        ch = '·' if bright else '.'
        a = curses.color_pair(C_STAR) | (curses.A_BOLD if bright else curses.A_DIM)
        safe_put(scr, y, x, ch, a)


# ── Main ────────────────────────────────────────────────────────────
def main(scr):
    curses.curs_set(0)
    scr.nodelay(True)
    scr.timeout(33)
    init_colors()

    rows, cols = scr.getmaxyx()
    ground_y = rows - 8
    water_y = ground_y + 2

    # Pre-generate star positions
    bg_stars = []
    for _ in range(int(rows * cols * 0.004)):
        sy = random.randint(0, ground_y - 8)
        sx = random.randint(0, cols - 1)
        bg_stars.append((sy, sx, random.uniform(0.005, 0.03)))

    fireworks = []
    tick = 0
    start = time.monotonic()

    while True:
        ch = scr.getch()
        if ch != -1:
            break

        new_rows, new_cols = scr.getmaxyx()
        if new_rows != rows or new_cols != cols:
            rows, cols = new_rows, new_cols
            ground_y = rows - 8
            water_y = ground_y + 2

        elapsed = time.monotonic() - start
        scr.erase()

        # star_alpha = min(1, elapsed / 8)
        star_alpha = 1
        draw_stars(scr, bg_stars, tick, star_alpha)

        draw_skyline(scr, ground_y, cols)

        draw_water(scr, water_y, rows, cols, tick)

        # ── Launch rate ramps up over time ──────────────────────────
        #   0-5s:   nothing (anticipation)
        #   5-15s:  occasional single rockets
        #  15-30s:  steady flow
        #  30-50s:  busy
        #  50s+:    grand finale, rapid fire
        cycle_duration = 70  # seconds per cycle
        t = elapsed % cycle_duration

        if t < 5:
            launch_prob = 0.04
        elif t < 20:
            launch_prob = 0.04
        elif t < 50:
            launch_prob = 0.04
        elif t < 60:
            launch_prob = 0.10
        else:
            # Grand finale: bursts come in waves
            wave = (math.sin(elapsed * 0.3) + 1) / 2
            launch_prob = 0.06 + wave * 0.12

        # Multiple rockets can launch per frame at high intensity
        launches = 1 if launch_prob < 0.06 else random.randint(1, 3)
        for _ in range(launches):
            if random.random() < launch_prob:
                fireworks.append(Firework(cols, ground_y))

        # ── Update & draw fireworks ─────────────────────────────────
        alive = []
        for fw in fireworks:
            fw.tick()
            fw.draw(scr, water_y if elapsed > 5 else None)
            if fw.phase != 'done':
                alive.append(fw)
        fireworks = alive

        # ── Ground line ─────────────────────────────────────────────
        g_attr = curses.color_pair(C_GROUND) | curses.A_DIM
        for x in range(cols):
            safe_put(scr, ground_y + 1, x, '▔', g_attr)

        scr.refresh()
        tick += 1


def run():
    signal.signal(signal.SIGINT, lambda *_: sys.exit(0))
    curses.wrapper(main)


if __name__ == '__main__':
    run()

