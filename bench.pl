use strict;
use warnings;

use Benchmark qw(:all);
use SkewHeap::PP;
use SkewHeap;

for my $size (50_000, 100_000, 500_000) {
  my $pp = skew{ $_[0] <=> $_[1] };
  skew_put($pp, 0..$size);

  my $xs = skewheap{ $a <=> $b };
  $xs->put(0..$size);

  my $item = $size / 2;

  print "\n";
  print "------------------------------------------------------------------------------\n";
  print "- put() and take() 1 item with skew heap containing $size nodes\n";
  print "------------------------------------------------------------------------------\n";
  cmpthese 100_000, {
    'pp' => sub{ skew_put $pp, $item; my $t = skew_take $pp; },
    'xs' => sub{ SkewHeap::put $xs, $item; my $t = SkewHeap::take $xs; },
  };
}
