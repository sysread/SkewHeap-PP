use strict;
use warnings;

use Benchmark qw(:all);
use POSIX qw(floor);
use SkewHeap::PP;
use SkewHeap;

for my $size (50_000, 100_000, 500_000) {
  my $count = floor(10_000_000_000 / $size);
  my $item = floor($size / 2);

  print "\n";
  print "------------------------------------------------------------------------------\n";
  print "- put() and take() 1 item with heap containing $size nodes ($count x times)   \n";
  print "------------------------------------------------------------------------------\n";

  my $pp = skew{ $_[0] <=> $_[1] };
  skew_put($pp, 0..$size);

  my $xs = skewheap{ $a <=> $b };
  $xs->put(0..$size);

  cmpthese $count, {
    'pp' => sub{ skew_put $pp, $item; my $t = skew_take $pp; },
    'xs' => sub{ $xs->put($item); my $t = $xs->take; },
  };
}
