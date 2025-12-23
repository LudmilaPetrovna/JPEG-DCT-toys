use strict;
use GD;
use File::Slurp;

my $symbol=$ARGV[0];
if(length($symbol)!=1){
die "Usage: ".__FILE__." <LETTER>\n\n";
}

my $pic=GD::Image->new(8,8,1);
$pic->saveAlpha(0);
$pic->alphaBlending(0);
$pic->filledRectangle(0,0,8,8,0xFFFFFF);
$pic->alphaBlending(1);

my $output;
$pic->stringFT(0x0,"/usr/share/fonts/truetype/Fifaks10Dev1.ttf",9,0,1,10,$symbol);
treshold();
$output="ref/".$symbol."0.png";
write_file($output,$pic->png(9));
`optipng -O7 "$output"`;

$pic->line(7,0,7,7,0x0);
treshold();
$output="ref/".$symbol."1.png";
write_file($output,$pic->png(9));
`optipng -O7 "$output"`;


sub treshold{
my($q,$w);
for($w=0;$w<8;$w++){
for($q=0;$q<8;$q++){
$pic->setPixel($q,$w,$pic->getPixel($q,$w)&0xFF>127?0xFFFFFF:0x0);
}
}
}