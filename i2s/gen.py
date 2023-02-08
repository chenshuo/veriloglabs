from math import cos, sin, pi

for i in range(48):
    rad = 2 * pi / 48 * (i + 0.5)
    v = sin(rad)
    d = int (0x800000 * v) * 256 & 0xffffffff

    print("%08x // %6.3f" % (d, v))

