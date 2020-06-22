use Test2::V0;
use List::Util qw(shuffle);
use SkewHeap::PP;

my $count    = 10_000;
my @ordered  = 1..$count;
my @shuffled = shuffle @ordered;

subtest 'default interface' => sub{
  ok my $s = skew{ $_[0] <=> $_[1] }, 'skew';
  is skew_count $s, 0, 'skew_count: initially 0';
  ok skew_is_empty $s, 'skew_is_empty: initially true';

  my $new_size = skew_put $s, @shuffled;
  is $new_size, $count, 'skew_put: expected size';
  ok !skew_is_empty $s, 'skew_is_empty: false after put';
  is skew_count $s, $count, 'skew_count: expected size after put';

  my @taken = skew_take $s, $count + 10;
  is scalar(@taken), $count, 'skew_take: expected number of results, even with ask > count';
  is skew_count $s, 0, 'skew_count: 0 after take';
  ok skew_is_empty $s, 'skew_is_empty: true after take';
  is @taken, @ordered, 'skew_take: results in expected order';

  ok skew_put($s, 42), 'skew_put: single item';
  is skew_take($s), 42, 'skew_take: single item';
};

subtest 'object interface' => sub{
  ok my $s = SkewHeap::PP->new(sub{ $_[0] <=> $_[1] }), 'skew';
  is $s->count, 0, 'count: initially 0';
  ok $s->is_empty, 'is_empty: initially true';

  my $new_size = $s->put(@shuffled);
  is $new_size, $count, 'put: expected size';
  ok !$s->is_empty, 'is_empty: false after put';
  is $s->count, $count, 'count: expected size after put';

  my @taken = $s->take($count + 10);
  is scalar(@taken), $count, 'take: expected number of results, even with ask > count';
  is $s->count, 0, 'count: 0 after take';
  ok $s->is_empty, 'is_empty: true after take';
  is @taken, @ordered, 'take: results in expected order';

  ok $s->put(42), 'put: single item';
  is $s->take, 42, 'take: single item';
};

done_testing;
