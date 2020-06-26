requires 'perl' => '>= 5.020';

requires 'Exporter' => '0';

on test => sub{
  requires 'FindBin'    => '0';
  requires 'List::Util' => '0';
  requires 'Test2::V0'  => '0';
  requires 'Test::Pod'  => '0';
  requires 'standard'   => '0';
};
