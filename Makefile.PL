use inc::Module::Install;
include 'Module::AutoInstall';

name 'String-BlackWhiteList';
all_from 'lib/String/BlackWhiteList.pm';
perl_version '5.006';

requires 'Class::Accessor::Complex' => '0.12';

recommends 'Test::Pod';
recommends 'Test::Pod::Coverage';

test_requires 'Test::More' => '0.70';
test_requires 'Test::Compile';

auto_install;
auto_include;
WriteAll;
