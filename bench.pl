use strict;
use warnings;

use Benchmark qw(:all);
use List::Util qw(shuffle);
use POSIX qw(floor);
use SkewHeap::PP;
use SkewHeap;

for my $size (50_000, 100_000, 500_000) {
  my $count = floor(10_000_000_000 / $size);
  my $inserts = 100;
  my $batch = $size / $inserts;
  my $item = floor($batch / 2);
  my @items = shuffle(0..$batch);

  my $pp = skew{ $_[0] <=> $_[1] };
  my $xs = skewheap{ $a <=> $b };

  print "\n";
  print "------------------------------------------------------------------------------\n";
  print "- put() $batch items ($batch items * $inserts trials = $size items)           \n";
  print "------------------------------------------------------------------------------\n";

  cmpthese $inserts, {
    "pp - put $batch" => sub{ skew_put($pp, @items) },
    "xs - put $batch" => sub{ $xs->put(0..@items) },
  };

  print "\n";
  print "------------------------------------------------------------------------------\n";
  print "- put() and take() 1 item with heap containing $size nodes ($count x times)   \n";
  print "------------------------------------------------------------------------------\n";

  cmpthese $count, {
    'pp - put+take 1' => sub{ skew_put $pp, $item; my $t = skew_take $pp; },
    'xs - put+take 1' => sub{ $xs->put($item); my $t = $xs->take; },
  };
}
