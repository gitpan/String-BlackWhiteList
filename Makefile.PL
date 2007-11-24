use inc::Module::Install;
include 'Module::AutoInstall';

name 'String-BlackWhiteList';
all_from 'lib/String/BlackWhiteList.pm';
perl_version '5.006';

requires 'Class::Accessor::Complex' => '0.12';

build_requires 'Test::More' => '0.70';

process_templates(
    first_year => 2005,
    rest_from  => "$ENV{HOME}/.mitlib/standard_pod",
    start_tag  => '{%',
    end_tag    => '%}',
);

use_standard_tests(without => 'pod_coverage');
auto_install;
auto_include;
WriteAll;
