use strict;
use GD;
use Math::Trig ':pi';
use File::Slurp;

my $mpic=GD::Image->new(790,360,1);
$mpic->saveAlpha(1);
$mpic->alphaBlending(0);
$mpic->filledRectangle(0,0,790,360,0x7F000000);
$mpic->alphaBlending(1);

my @dct=(
   442,   -237,    215,     17,    191,    318,    187,    213,
  -195,    -79,    113,     64,     50,     35,     -5,     24,
    83,     69,    -45,    -55,     35,    -24,   -109,    -46,
  -100,    -83,     86,     74,    -88,     59,    142,    -64,
   -64,   -105,    167,    262,   -191,   -163,     69,   -124,
  -175,    -64,    128,     59,     18,     54,    -18,    -83,
    35,      4,     19,      7,    -83,     34,     45,   -144,
    53,     24,    -87,    -35,     75,    -64,    -26,    206,
);

my @dct2=(
   442,    237,    215,    -17,    191,   -318,    187,   -213,
  -195,     79,    113,    -64,     50,    -35,     -5,    -24,
    83,    -69,    -45,     55,     35,     24,   -109,     46,
  -100,     83,     86,    -74,    -88,    -59,    142,     64,
   -64,    105,    167,   -262,   -191,    163,     69,    124,
  -175,     64,    128,    -59,     18,    -54,    -18,     83,
    35,     -4,     19,     -7,    -83,    -34,     45,    144,
    53,    -24,    -87,     35,     75,     64,    -26,   -206,
);

sub decode_dct{
my @dct=@_;
my @sums=();
my($u,$v,$q,$w,$coef,$cx,$cy,$p,$val,$pic);
my $pic=GD::Image->new(8,8,1);
for($v=0;$v<8;$v++){
for($u=0;$u<8;$u++){
$coef=$dct[$u+$v*8];
for($w=0;$w<8;$w++){
for($q=0;$q<8;$q++){
$cx=cos(((2.0*$q+1.0)*$u*pi)/(2.0*8));
$cy=cos(((2.0*$w+1.0)*$v*pi)/(2.0*8));
$val=$cx*$cy;
$p=$q+$w*8;
$sums[$p]+=$val*$coef;
}
}
}
}

for($w=0;$w<8;$w++){
for($q=0;$q<8;$q++){
$p=$q+$w*8;
$val=$sums[$p]/4+128;
if($val<0){$val=0;}
if($val>255){$val=255;}
$val=$val|($val<<8)|($val<<16);
$pic->setPixel($q,$w,$val);
}
}
return($pic);
}

sub draw_grid{
my($ox,$oy,$cell_width,$cell_count)=@_;
my($q,$w,$e);
my $s=$cell_width*$cell_count+1;
my $o=GD::Image->new($s,$s,1);
my $l=int($cell_width*1);
if($l<4){$l=4;}

$o->alphaBlending(0);
$o->filledRectangle(0,0,$s,$s,0x7F000000);
$o->alphaBlending(1);
for($w=0;$w<$cell_count;$w++){
for($q=0;$q<$cell_count;$q++){
for($e=0;$e<$l;$e++){
$o->setPixel($q*$cell_width+$e,$w*$cell_width,0x50BBBB00);
$o->setPixel($q*$cell_width,$w*$cell_width+$e,0x50BBBB00);
$o->setPixel(($q+1)*$cell_width-$e-1,($w+1)*$cell_width-1,0x70AAAA00);
$o->setPixel(($q+1)*$cell_width-1,($w+1)*$cell_width-$e-1,0x70AAAA00);
}
}
}
$mpic->copy($o,$ox,$oy,0,0,$s,$s);
}

sub draw_dct{
my $ox=shift;
my $oy=shift;
my @dct=@_;
my($q,$w,$e);
my $cell_width=32;

for($w=0;$w<8;$w++){
for($q=0;$q<8;$q++){
my $luma=$dct[$q+$w*8]/2+128;
if($luma<0){$luma=0;}
if($luma>255){$luma=255;}
$mpic->filledRectangle(
$ox+$q*$cell_width,$oy+$w*$cell_width,
$ox+($q+1)*$cell_width-1,$oy+($w+1)*$cell_width-1,
$luma|($luma<<8)|($luma<<16));

$mpic->string(gdSmallFont,$ox+$q*$cell_width+5,$oy+$w*$cell_width+10,$dct[$q+$w*8],$luma>128?0x005500:0x00FF00);

}
}
draw_grid($ox,$oy,32,8);

my $pic=decode_dct(@dct);
$mpic->copyResized($pic,$ox,$oy-90,0,0,80,80,8,8);
draw_grid($ox,$oy-90,10,8);

}

sub draw_dct_diff{
my $ox=shift;
my $oy=shift;
my $dct1=shift;
my $dct2=shift;
my($q,$w,$p);
my @dct=();
for($w=0;$w<8;$w++){
for($q=0;$q<8;$q++){
$p=$q+$w*8;
$dct[$p]=$dct2->[$p]-$dct1->[$p];
}
}
draw_dct($ox,$oy,@dct);

my $cell_width=32;
for($w=0;$w<8;$w++){
for($q=0;$q<8;$q++){
my $luma=$dct[$q+$w*8]/2+128;
if($luma<0){$luma=0;}
if($luma>255){$luma=255;}
$mpic->filledRectangle(
$ox+$q*$cell_width,$oy+$w*$cell_width,
$ox+($q+1)*$cell_width-1,$oy+($w+1)*$cell_width-1,
$luma|($luma<<8)|($luma<<16));

$mpic->string(gdSmallFont,$ox+$q*$cell_width+5,$oy+$w*$cell_width+1,$dct1->[$q+$w*8],$luma>128?0x550000:0xFF0000);
$mpic->string(gdSmallFont,$ox+$q*$cell_width+5,$oy+$w*$cell_width+10,$dct2->[$q+$w*8],$luma>128?0x005500:0x00FF00);
$mpic->string(gdSmallFont,$ox+$q*$cell_width+5,$oy+$w*$cell_width+19,$dct[$q+$w*8],$luma>128?0x005555:0x00FFFF);

}
}


draw_grid($ox,$oy,32,8);

}



draw_dct(10,100,@dct);
draw_dct(270,100,@dct2);
draw_dct_diff(530,100,[@dct],[@dct2]);

write_file("test.png",$mpic->png(9));




