use Test2::V0;
use Guacamole;
use FindBin qw($Bin);
use standard qw();

my $file    = "$Bin/../lib/SkewHeap/PP.pm";
my $content = do{ local $/; open my $fh, '<', $file or die $!; <$fh>; };

standard::strip_terminators(\$content);
standard::strip_pods(\$content);

try_ok(sub{ Guacamole->parse($content) }, "passes Standard Perl");

done_testing();
