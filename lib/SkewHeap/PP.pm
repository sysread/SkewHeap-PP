package SkewHeap::PP;
# ABSTRACT: a fast and flexible heap structure

=head1 SYNOPSIS

=head1 DESCRIPTION

A skew heap is a memory efficient, self-adjusting heap with an amortized
performance of O(log n) or better. C<SkewHeap:PP> is implemented in pure perl,
yet performs comparably to L<SkewHeap>.

The key feature of a skew heap is the ability to quickly and efficiently merge
two heaps together.

=head2 skew

Creates a new skew heap. Requires a single argument, a code block that knows how
to prioritize the values to be stored in the heap.

  my $heap = skew{ $_[0] <=> $_[1] };

=head2 skew_count

Returns the number of elements in the heap.

=head2 skew_is_empty

Returns true if the heap is empty.

=head2 skew_peek

Returns the top element in the heap without removing it from the heap.

=head2 skew_take

Removes and returns the top element from the heap.

  my $item = skew_take $heap;

Optionally, multiple elements may be returned from the heap by passing the
desired number of elements, in which case a list is returned, rather than a
single, scalar element. If there are fewer elements available than requested,
as many as a immediately available are returned.

  # Get 10 elements
  my @items = skew_take $heap, 10;

=head2 skew_put

Adds one or more items to the heap.

  skew_put $s, 42;
  skew_put $s, 42, 6, 8;

=head2 skew_merge

Merges any number of heaps into the first argument I<destructively>. After
merging, the first heap passed in will contain all of the items in the heaps
passed in subsequent arguments. After merging, the subsequent heaps will be
empty. The comparison function used for ordering is that of the first heap
passed in. The return value is the first heap into which the other heaps were
merged.

  skew_merge $x, $y, $z; # $x contains all elements of $x, $y, and $z;
                         # $y and $z are now empty.

=head2 skew_explain

Prints out a representation of the internal tree structure for debugging.

=head1 OBJECT INTERFACE

An object interface is provided that maps directly to the similarly named
C<skew_*> routines.

=over

=item new - SEE L</skew>

=item count - SEE L</skew_count>

=item is_empty - SEE L</skew_is_empty>

=item peek - SEE L</skew_peek>

=item take - SEE L</skew_take>

=item put - SEE L</skew_put>

=item merge - SEE L</skew_merge>

=item explain = SEE L</skew_explain>

=back

=cut

use strict;
use warnings;

use constant KEY   => 0;
use constant LEFT  => 1;
use constant RIGHT => 2;

use constant CMP   => 0;
use constant SIZE  => 1;
use constant ROOT  => 2;

use parent 'Exporter';
our @EXPORT = qw(
  skew
  skew_count
  skew_is_empty
  skew_peek
  skew_put
  skew_take
  skew_merge
  skew_explain
);

sub skew (&) {
  my $cmp = shift;
  return [$cmp, 0, undef];
}

sub node_explain {
  my $node = shift;
  my $indent_size = shift || 0;
  my $indent = '   ' x $indent_size;
  print $indent.'- Node: '.$node->[KEY]."\n";
  node_explain($node->[LEFT], $indent_size + 1) if $node->[LEFT];
  node_explain($node->[RIGHT], $indent_size + 1) if $node->[RIGHT];
}

sub skew_explain ($) {
  my $s = shift;
  my $n = skew_count($s);
  print "SkewHeap<size=$n>\n";
  node_explain($s->[ROOT], 1);
}

sub merge_nodes ($$$) {
  #-----------------------------------------------------------------------------
  # Note: it is slightly faster to use `defined ||` and direct arg stack
  # access, which shows up as a significant gain for large, deep merges.
  #-----------------------------------------------------------------------------
  $_[1] || return $_[2];
  $_[2] || return $_[1];

  my $cmp = shift;
  my @subtrees;

  #-----------------------------------------------------------------------------
  # Clip off the right child of each node down each right path of the tree.
  #
  # Note: Working with the nodes to merge on the arg stack is significantly
  # faster than shifting them off and then pushing them back onto a newly
  # allocated list.
  #-----------------------------------------------------------------------------
  while (my $node = shift) {
    if ($node->[RIGHT]) {
      push @_, $node->[RIGHT];
      undef $node->[RIGHT];
    }

    push @subtrees, $node;
  }

  # Sort the collected subtrees in ascending order
  @subtrees = sort{ $cmp->($a->[KEY], $b->[KEY]) } @subtrees;

  #-----------------------------------------------------------------------------
  # Walk backwards down the list of sorted subtrees, moving the penultimate
  # node's left child (if any) to the right side and making the left side the
  # ultimate node.
  #-----------------------------------------------------------------------------
  while (@subtrees > 1) {
    my $i = $#subtrees - 1;
    $subtrees[$i][RIGHT] = $subtrees[$i][LEFT];
    $subtrees[$i][LEFT] = pop(@subtrees);
  }

  #-----------------------------------------------------------------------------
  # The only remaining value on the stack is the result of merging the rest of
  # the subtrees.
  #-----------------------------------------------------------------------------
  shift @subtrees;
}

sub skew_count ($) {
  my $skew = shift;
  return $skew->[SIZE];
}

sub skew_is_empty ($) {
  my $skew = shift;
  return $skew->[SIZE] == 0;
}

sub skew_peek ($) {
  my $skew = shift;
  return $skew->[ROOT][KEY] unless skew_is_empty $skew;
  return;
}

sub skew_take ($;$) {
  my $skew = shift;
  my $want = shift;

  my @taken;
  while (($want || 1) > @taken && $skew->[SIZE] > 0) {
    push @taken, $skew->[ROOT][KEY];
    $skew->[ROOT] = merge_nodes $skew->[CMP], $skew->[ROOT][LEFT], $skew->[ROOT][RIGHT];
    --$skew->[SIZE];
  }

  return defined $want ? @taken : $taken[0];
}

sub skew_put ($;@) {
  my $skew = shift;

  for (@_) {
    $skew->[ROOT] = merge_nodes $skew->[CMP], $skew->[ROOT], [$_, undef, undef];
    ++$skew->[SIZE];
  }

  return $skew->[SIZE];
}

sub skew_merge ($;@) {
  my $skew = shift;

  for (@_) {
    $skew->[ROOT] = merge_nodes $skew->[CMP], $skew->[ROOT], $_->[ROOT];
    $_->[ROOT] = undef;
    $_->[SIZE] = 0;
  }

  return $skew;
}

sub new {
  my ($class, $cmp) = @_;
  my $skew = skew \&$cmp;
  bless $skew, $class;
}

sub count    { goto \&skew_count    }
sub is_empty { goto \&skew_is_empty }
sub peek     { goto \&skew_peek     }
sub put      { goto \&skew_put      }
sub take     { goto \&skew_take     }
sub merge    { goto \&skew_merge    }
sub explain  { goto \&skew_explain  }

1;
