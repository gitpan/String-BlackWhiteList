use inc::Module::Install;
name 'String-BlackWhiteList';
all_from 'lib/String/BlackWhiteList.pm';
perl_version '5.006';

requires 'Class::Accessor::Complex';

build_requires 'Test::More' => '0.70';

use_standard_tests(without => 'pod_coverage');
auto_include;
WriteAll;
