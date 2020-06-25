requires 'perl' => '>= 5.020';

on test => sub{
  requires 'Test2::V0'  => '0';
  requires 'Test::Pod'  => '0';
  requires 'List::Util' => '0';
};
