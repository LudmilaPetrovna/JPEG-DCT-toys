#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <jpeglib.h>
static const double aanscale[8] = {
    1.0,
    1.387039845,
    1.306562965,
    1.175875602,
    1.0,
    0.785694958,
    0.541196100,
    0.275899379
};

int main(int argc, char **argv)
{
    struct jpeg_decompress_struct cinfo;
    struct jpeg_error_mgr jerr;

    FILE *infile;
    jvirt_barray_ptr *coeffs;
    JBLOCKARRAY block_array;
    JCOEFPTR block;

    int i, j;

    if (argc != 2) {
        fprintf(stderr, "usage: %s image.jpg\n", argv[0]);
        return 1;
    }

    infile = fopen(argv[1], "rb");
    if (!infile) {
        perror(argv[1]);
        return 1;
    }

    cinfo.err = jpeg_std_error(&jerr);
    jpeg_create_decompress(&cinfo);
    jpeg_stdio_src(&cinfo, infile);

    jpeg_read_header(&cinfo, TRUE);

    /* <<< КЛЮЧЕВОЙ ВЫЗОВ >>> */
    coeffs = jpeg_read_coefficients(&cinfo);

    /* Только 1 компонент (grayscale) */
    if (cinfo.num_components != 1) {
        fprintf(stderr, "Not a grayscale JPEG\n");
        return 1;
    }

  /* предполагаем 1 компонент (grayscale) */
    jpeg_component_info *comp = &cinfo.comp_info[0];
    int qno = comp->quant_tbl_no;
    JQUANT_TBL *qt = cinfo.quant_tbl_ptrs[qno];

    if (!qt) {
        fprintf(stderr, "No quantization table\n");
        return 1;
    }

    /* Берём первый (и единственный) блок */
    block_array =
        cinfo.mem->access_virt_barray(
            (j_common_ptr)&cinfo,
            coeffs[0],
            0, 1,
            FALSE
        );

    block = block_array[0][0];

    printf("%s: DCT coefficients (natural order 8x8 after zigzag):\n",argv[1]);
    for (i = 0; i < 8; i++) {
        for (j = 0; j < 8; j++){
double val_d=(double)block[i * 8 + j]*(double)qt->quantval[i*8+j];
int val=(int)(val_d+.5);

//            printf("%6d*%d, ",val,qt->quantval[i*8+j]);
            printf("%6d, ",val);
}
        printf("\n");
}


    printf("\n");

    jpeg_finish_decompress(&cinfo);
    jpeg_destroy_decompress(&cinfo);
    fclose(infile);

    return 0;
}
