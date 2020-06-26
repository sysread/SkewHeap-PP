use standard;
use Test2::V0;
use Guacamole;
use FindBin qw($Bin);
use Path::Tiny qw(path);

my $file    = "$Bin/../lib/SkewHeap/PP.pm";
my $content = path($file)->slurp();

$content =~ s/^__DATA__\n.*//xms;
$content =~ s/^__END__\n.*//xms;

my @lines = split /\n/, $content;
my $in_pod;
for my $line (@lines) {
  if ($line =~ /^=(?!cut)/) {
    $in_pod = 1;
  }

  next unless $in_pod;

  $line =~ s/^/#/;

  if ($line =~ /^#=cut\s*$/) {
    $in_pod = 0;
  }
}

$content = join "\n", @lines;

try_ok(sub{ Guacamole->parse($content) }, "passes Standard Perl");

done_testing();
