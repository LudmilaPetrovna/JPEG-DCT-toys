#!/bin/bash

convert ref/R0.png -quality 100 R0.jpg
gcc jpeg_dump_dct.c -ljpeg -o jpeg_dump_dct && ./jpeg_dump_dct R0.jpg
