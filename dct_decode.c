#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

/* ===================== ZIGZAG ===================== */

static const int zigzag[64] = {
     0,  1,  5,  6, 14, 15, 27, 28,
     2,  4,  7, 13, 16, 26, 29, 42,
     3,  8, 12, 17, 25, 30, 41, 43,
     9, 11, 18, 24, 31, 40, 44, 53,
    10, 19, 23, 32, 39, 45, 52, 54,
    20, 22, 33, 38, 46, 51, 55, 60,
    21, 34, 37, 47, 50, 56, 59, 61,
    35, 36, 48, 49, 57, 58, 62, 63
};

/* ===================== BITSTREAM ===================== */

static FILE *f;
static int bit_buf = 0;
static int bit_cnt = 0;

static int read_entropy_byte(void)
{
    int c = fgetc(f);
    if (c == EOF) {
        fprintf(stderr, "Unexpected EOF\n");
        exit(1);
    }
    if (c == 0xFF) {
        int n = fgetc(f);
        if (n != 0x00) {
            fprintf(stderr, "Unexpected marker in entropy stream\n");
            exit(1);
        }
    }
    return c;
}

static int get_bit(void)
{
    if (bit_cnt == 0) {
        bit_buf = read_entropy_byte();
        bit_cnt = 8;
    }
    bit_cnt--;
    return (bit_buf >> bit_cnt) & 1;
}

static int get_bits(int n)
{
    int v = 0;
    while (n--)
        v = (v << 1) | get_bit();
    return v;
}

/* ===================== HUFFMAN ===================== */

typedef struct {
    uint8_t bits[16];
    uint8_t vals[256];
    int32_t min_code[17];
    int32_t max_code[17];
    int32_t val_ptr[17];
} Huffman;

static void huffman_build(Huffman *h)
{
    int code = 0;
    int k = 0;
    int i;

    for (i = 1; i <= 16; i++) {
        if (h->bits[i - 1] == 0) {
            h->min_code[i] = -1;
            h->max_code[i] = -1;
        } else {
            h->min_code[i] = code;
            h->val_ptr[i] = k;
            code += h->bits[i - 1] - 1;
            h->max_code[i] = code;
            k += h->bits[i - 1];
        }
        code <<= 1;
    }
}

static int huff_decode(Huffman *h)
{
    int code = 0;
    int len;

    for (len = 1; len <= 16; len++) {
        code = (code << 1) | get_bit();

        if (h->min_code[len] >= 0 &&
            code >= h->min_code[len] &&
            code <= h->max_code[len]) {

            int idx = h->val_ptr[len] + (code - h->min_code[len]);
            return h->vals[idx];
        }
    }

    fprintf(stderr, "Huffman decode error\n");
    exit(1);
}

/* ===================== JPEG HELPERS ===================== */

static int read_marker(FILE *f)
{
    int c;
    do {
        c = fgetc(f);
        if (c == EOF) return -1;
    } while (c != 0xFF);

    do {
        c = fgetc(f);
        if (c == EOF) return -1;
    } while (c == 0xFF);

    return c;
}

static int extend(int v, int t)
{
    int vt = 1 << (t - 1);
    if (v < vt)
        v -= (1 << t) - 1;
    return v;
}

/* ===================== MAIN ===================== */

int main(void)
{
    uint8_t qtable[64] = {0};
    Huffman dc = {{0}}, ac = {{0}};
    int16_t block[64] = {0};

    int marker;
    int i;

    f = fopen("R1.jpg", "rb");
    if (!f) {
        perror("test.jpg");
        return 1;
    }

    /* SOI */
    marker = read_marker(f);
    if (marker != 0xD8) {
        fprintf(stderr, "Not a JPEG file\n");
        return 1;
    }

    /* Parse segments */
    for (;;) {
        marker = read_marker(f);
        if (marker < 0) {
            fprintf(stderr, "Unexpected EOF\n");
            return 1;
        }

        if (marker == 0xDA) /* SOS */
            break;

        if (marker == 0xD9) /* EOI */
            return 0;

        uint16_t len = (fgetc(f) << 8) | fgetc(f);
        len -= 2;

        if (marker == 0xDB) { /* DQT */
            fgetc(f); /* Pq/Tq */
            for (i = 0; i < 64; i++)
                qtable[zigzag[i]] = fgetc(f);
            len -= 65;
        }
        else if (marker == 0xC4) { /* DHT */
            int tc_th = fgetc(f);
            Huffman *h = (tc_th >> 4) ? &ac : &dc;

            for (i = 0; i < 16; i++)
                h->bits[i] = fgetc(f);

            int total = 0;
            for (i = 0; i < 16; i++)
                total += h->bits[i];

            fread(h->vals, 1, total, f);
            huffman_build(h);
            len -= 17 + total;
        }

        if (len > 0)
            fseek(f, len, SEEK_CUR);
    }

    /* Skip SOS header */
    fgetc(f); fgetc(f); /* length */
    fgetc(f);           /* components */
    fgetc(f); fgetc(f); /* comp + tables */
    fgetc(f); fgetc(f); fgetc(f); /* Ss Se AhAl */

    /* ===================== DC ===================== */

    int t = huff_decode(&dc);
    int diff = t ? extend(get_bits(t), t) : 0;
    block[0] = diff * qtable[0];

    /* ===================== AC ===================== */

    int k = 1;
    while (k < 64) {
        int rs = huff_decode(&ac);
        if (rs == 0)
            break;

        int r = rs >> 4;
        int s = rs & 15;

        k += r;
        int v = extend(get_bits(s), s);
        block[zigzag[k]] = v * qtable[zigzag[k]];
        k++;
    }

    /* ===================== OUTPUT ===================== */

    printf("DCT coefficients (u,v order):\n");
    for (i = 0; i < 64; i++) {
        printf("%6d ", block[i]);
        if ((i & 7) == 7) printf("\n");
    }

    printf("\nDCT coefficients (zig-zag order):\n");
    for (i = 0; i < 64; i++)
        printf("%6d ", block[zigzag[i]]);
    printf("\n");

    fclose(f);
    return 0;
}
