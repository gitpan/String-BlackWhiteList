#!/usr/bin/perl

use warnings;
use strict;
use Test::More;
use String::BlackWhiteList;

use constant BLACKLIST => (
    'BOX',
    'POB',
    'POSTBOX',
    'POST',
    'POSTSCHACHTEL',
    'PO',
    'P O',
    'P O BOX',
    'P.O.',
    'P.O.B.',
    'P.O.BOX',
    'P.O. BOX',
    'P. O.',
    'P. O.BOX',
    'P. O. BOX',
    'POBOX',
    'PF',
    'P.F.',
    'POSTFACH',
    'POSTLAGERND',
    'POSTBUS'
);

use constant WHITELIST => (
    'Post Road',
    'Post Rd',
    'Post Street',
    'Post St',
    'Post Avenue',
    'Post Av',
    'Post Alley',
    'Post Drive',
    'Post Grove',
    'Post Walk',
    'Post Parkway',
    'Post Row',
    'Post Lane',
    'Post Bridge',
    'Post Boulevard',
    'Post Square',
    'Post Garden',
    'Post Strasse',
    'Post Allee',
    'Post Gasse',
    'Post Platz',
);

my @ok = (
    'Post Road 123',
    'Post Rd 123',
    'Post Street 123',
    'Post St 123',
    'Post Avenue 123',
    'Post Av 123',
    'Post Alley 123',
    'Post Drive 123',
    'Post Grove 123',
    'Post Walk 123',
    'Post Parkway 123',
    'Post Row 123',
    'Post Lane 123',
    'Post Bridge 123',
    'Post Boulevard 123',
    'Post Square 123',
    'Post Garden 123',
    'Post Strasse 123',
    'Post Allee 123',
    'Post Gasse 123',
    'Post Platz 123',
    'Postsparkassenplatz 1',
    'Postelweg 5',
    'Boxgasse 32',
    'Postfachplatz 11',
    'PFalznerweg 91',
    'aPOSTelweg 12',
    '',
    undef,
    WHITELIST,
);

my @not_ok = (
    'Box 123',
    'Pob',
    'Postbox',
    'Post',
    'Postschachtel',
    'PO 37, Postgasse 5',
    'PF 123',
    'P.F. 37, Post Drive 9',
    'P.O. BOX 37, Post Drive 9',
    'Post Street, P.O.B.',
    'Postfach 41, 1023 Wien',
    'Post Gasse, Postlagernd',
    BLACKLIST,
);

plan tests => @ok + @not_ok;

my $matcher = String::BlackWhiteList->new(
    blacklist => [ BLACKLIST ],
    whitelist => [ WHITELIST ]
)->update;

ok( $matcher->valid($_),
    sprintf "[%s] valid", defined() ? $_ : 'undef')  for @ok;
ok(!$matcher->valid($_), "[$_] invalid") for @not_ok;

