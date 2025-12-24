use strict;
use GD;
use Math::Trig ':pi';
use File::Slurp;

my @AAN=(1.0,1.387039845,1.306562965,1.175875602,1.0,0.785694958,0.541196100,0.275899379);
my @ALPHA=(1/sqrt(2),1,1,1,1,1,1,1);

my($pic1,$pic2)=@ARGV;
my $output=$ARGV[2];
if(!$pic1 || !$pic2){
die "Usage: ".__FILE__." file1.jpg file2.jpg [output.png]";
}

if(!$output){$output="compare_jpeg_result.png";}

my $mpic=GD::Image->new(790,370,1);
$mpic->saveAlpha(1);
$mpic->alphaBlending(0);
$mpic->filledRectangle(0,0,790,370,0x7F000000);
$mpic->alphaBlending(1);

my @dct=load_dct($pic1);
my @dct2=load_dct($pic2);

sub load_dct{
my $filename=shift;
my $data=`./jpeg_dump_dct "$filename"`;
my @ret=();
while($data=~/([\-\d]+),/g){
push(@ret,$1*1);
}
return(@ret);
}

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
##$val=$cx*$cy*$AAN[$u]*$AAN[$v]* $ALPHA[$u] * $ALPHA[$v];
$val=$cx*$cy*$ALPHA[$u] * $ALPHA[$v]/4;
$p=$q+$w*8;
$sums[$p]+=$val*$coef;
}
}
}
}

for($w=0;$w<8;$w++){
for($q=0;$q<8;$q++){
$p=$q+$w*8;
$val=$sums[$p]+128;
if($val<0){$val=0;}
if($val>255){$val=255;}
$val=$val|($val<<8)|($val<<16);
$pic->setPixel($q,$w,$val);
}
}
return($pic);
}

sub draw_jpeg{
my($ox,$oy,$filename)=@_;
my $pic=GD::Image->newFromJpeg($filename,1);
$mpic->copyResized($pic,$ox,$oy,0,0,80,80,8,8);
draw_grid($ox,$oy,10,8);
$mpic->string(gdTinyFont,$ox+10,$oy+80,"Decoded by GD",0x0);

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
$mpic->string(gdTinyFont,$ox+5,$oy-10,"Decoded by DCT",0x0);

}

sub draw_dct_diff{
my $ox=shift;
my $oy=shift;
my $dct1=shift;
my $dct2=shift;
my($q,$w,$p);
my @dct=();
my @mult=();
for($w=0;$w<8;$w++){
for($q=0;$q<8;$q++){
$p=$q+$w*8;
$dct[$p]=$dct2->[$p]-$dct1->[$p];
$mult[$p]=$dct2->[$p]/$dct1->[$p];
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

#draw mult
$luma=$mult[$q+$w*8]*64+128;
if($luma<0){$luma=0;}
if($luma>255){$luma=255;}
$mpic->filledRectangle(
120+$ox+$q*10,$oy+$w*10-90,
120+$ox+($q+1)*10-1,$oy+($w+1)*10-1-90,
$luma|($luma<<8)|($luma<<16));


}
}

draw_grid($ox+120,$oy-90,10,8);

draw_grid($ox,$oy,32,8);
$mpic->string(gdTinyFont,$ox+130,$oy-10,"Mult matrix",0x0);

}


$mpic->string(gdSmallFont,10,3,$pic1,0x0);
draw_dct(10,110,@dct);
draw_jpeg(95,20,$pic1);

$mpic->string(gdSmallFont,270,3,$pic2,0x0);
draw_dct(270,110,@dct2);
draw_jpeg(355,20,$pic2);
draw_dct_diff(530,110,[@dct],[@dct2]);

write_file($output,$mpic->png(9));




