#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define PI 3.14159265358979323846

static unsigned char clamp_u8(int v)
{
    if (v < 0)   return 0;
    if (v > 255) return 255;
    return (unsigned char)v;
}

int main(int argc, char **argv)
{
    int N = atoi(argv[1]);

    int u, v, x, y;

    if (argc > 1) {
        N = atoi(argv[1]);
        if (N <= 0) return 1;
    }

    for (v = 0; v < 8; v++) {
        for (u = 0; u < 8; u++) {

            for (y = 0; y < N; y++) {
                for (x = 0; x < N; x++) {

                    /* координаты DCT, масштабированные точно */
                    double cx = cos(((2.0 * x + 1.0) * u * PI) / (2.0 * N));
                    double cy = cos(((2.0 * y + 1.0) * v * PI) / (2.0 * N));

                    double val = cx * cy;      /* [-1 .. +1] */
                    int gray = (int)(val * 127.5 + 128.0);

                    unsigned char out = clamp_u8(gray);
                    fwrite(&out, 1, 1, stdout);
                }
            }
        }
    }

    return 0;
}
