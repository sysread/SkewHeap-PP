use strict;
use warnings;

use Benchmark qw(:all);
use SkewHeap::PP;
use SkewHeap qw();

print "- Building list of elements to insert\n";
my $count = 1_000_000;
my @insert = 1..$count;

print "- Building skew heaps with 50k, 100k, and 500k elements already inserted\n";
my $s_1 = skew{ $_[0] <=> $_[1] };
my $s_2 = skew{ $_[0] <=> $_[1] };
my $s_3 = skew{ $_[0] <=> $_[1] };

my $xs_1 = SkewHeap::skewheap{ $a <=> $b };
my $xs_2 = SkewHeap::skewheap{ $a <=> $b };
my $xs_3 = SkewHeap::skewheap{ $a <=> $b };

skew_put $s_1, $insert[$_] for 0..50_000;
skew_put $s_2, $insert[$_] for 0..100_000;
skew_put $s_3, $insert[$_] for 0..500_000;

SkewHeap::put $xs_1, $insert[$_] for 0..50_000;
SkewHeap::put $xs_2, $insert[$_] for 0..100_000;
SkewHeap::put $xs_3, $insert[$_] for 0..500_000;

print "\n";
print "------------------------------------------------------------------------------\n";
print "- put() and take() 1 item with skew heap containing 50,000 nodes\n";
print "------------------------------------------------------------------------------\n";
cmpthese 50_000, {
  'pp' => sub{ skew_put $s_1, 25_000; my $t = skew_take $s_1; },
  'xs' => sub{ SkewHeap::put $xs_1, 25_000; my $t = SkewHeap::take $xs_1; },
};

print "\n";
print "------------------------------------------------------------------------------\n";
print "- put() and take() 1 item with skew heap containing 100,000 nodes\n";
print "------------------------------------------------------------------------------\n";
cmpthese 50_000, {
  'pp' => sub{ skew_put $s_2, 50_000; my $t = skew_take $s_2; },
  'xs' => sub{ SkewHeap::put $xs_2, 50_000; my $t = SkewHeap::take $xs_2; },
};

print "\n";
print "------------------------------------------------------------------------------\n";
print "- put() and take() 1 item with skew heap containing 500,000 nodes\n";
print "------------------------------------------------------------------------------\n";
cmpthese 50_000, {
  'pp' => sub{ skew_put $s_3, 250_000; my $t = skew_take $s_3; },
  'xs' => sub{ SkewHeap::put $xs_3, 250_000; my $t = SkewHeap::take $xs_3; },
};
