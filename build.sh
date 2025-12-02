rm -f dct.pgm luma.pgm canvas0.bmp canvas.bmp
gcc nanojpeg.c && ./a.out pano_4k.png.jpg test.ppm
montage -geometry 160x80+0+0 -tile 1x dct.pgm luma.pgm canvas0.bmp
md5sum canvas0.bmp dct.pgm luma.pgm
convert canvas0.bmp -normalize -interpolate nearest -interpolative-resize 500% canvas.bmp
