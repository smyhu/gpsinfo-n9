# Sky plot background (460x460) for dark and light theme + north marker. Own drawing.
# usage: python3 radar.py outdir
from PIL import Image, ImageDraw, ImageFont
import math, sys, os
out = sys.argv[1]; K = 4; S = 460 * K; C = S // 2; R = 210 * K
try:
    font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 15 * K)
    bold = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 22 * K)
except Exception:
    font = bold = ImageFont.load_default()
def radar(bg, disc, ring, faint, label, name, labels=True):
    im = Image.new('RGB', (S, S), bg); d = ImageDraw.Draw(im)
    d.ellipse((C-R, C-R, C+R, C+R), fill=disc)
    for i, el in enumerate((0, 30, 60)):
        r = R * (90 - el) // 90
        d.ellipse((C-r, C-r, C+r, C+r), outline=ring if el == 0 else faint, width=(3 if el == 0 else 2) * K // 2)
    for az in range(0, 360, 30):
        a = math.radians(az)
        r0 = 0 if az % 90 == 0 else R * 60 // 90
        d.line((C + r0*math.sin(a), C - r0*math.cos(a), C + R*math.sin(a), C - R*math.cos(a)),
               fill=faint, width=K)
    d.ellipse((C-4*K, C-4*K, C+4*K, C+4*K), fill=ring)
    for el in ((30, 60) if labels else ()):
        r = R * (90 - el) // 90
        d.text((C + 6*K, C - r + 2*K), "%d°" % el, font=font, fill=label)
    im.resize((460, 460), Image.LANCZOS).save(os.path.join(out, name))
radar((0, 0, 0), (8, 18, 6), (90, 150, 60), (40, 75, 30), (95, 130, 80), 'radar-dark.png')
radar((255, 255, 255), (241, 248, 236), (95, 150, 70), (180, 205, 165), (110, 140, 95), 'radar-light.png')
radar((0, 0, 0), (8, 18, 6), (90, 150, 60), (40, 75, 30), (95, 130, 80), 'plot-dark.png', False)
radar((255, 255, 255), (241, 248, 236), (95, 150, 70), (180, 205, 165), (110, 140, 95), 'plot-light.png', False)
# north marker 40x40: light green disc with dark N
n = Image.new('RGBA', (40*K, 40*K), (0, 0, 0, 0)); d = ImageDraw.Draw(n)
d.ellipse((2*K, 2*K, 38*K, 38*K), fill=(231, 255, 205, 255), outline=(45, 119, 7, 255), width=2*K)
w = d.textbbox((0, 0), "N", font=bold)
d.text((20*K - (w[2]+w[0])/2, 20*K - (w[3]+w[1])/2), "N", font=bold, fill=(30, 70, 10, 255))
n.resize((40, 40), Image.LANCZOS).save(os.path.join(out, 'north.png'))
