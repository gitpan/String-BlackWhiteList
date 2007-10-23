package String::BlackWhiteList;

use warnings;
use strict;

our $VERSION = '0.01';

use base 'Class::Accessor::Complex';

__PACKAGE__
    ->mk_new
    ->mk_scalar_accessors(qw(black_re white_re))
    ->mk_array_accessors(qw(blacklist whitelist));


sub update {
    my $self = shift;

   my $black_re =  
        sprintf '\b(%s)(\b|\s|$)',
        join '|',
        $self->blacklist;
    $self->black_re(qr/$black_re/i);

    my $white_re =
        sprintf '\b(%s)(\b|\s|$)',
        join '|',
        $self->whitelist;
    $self->white_re(qr/$white_re/i);

    $self;
}


sub valid {
    my ($self, $s) = @_;

    my $white_re = $self->white_re;
    my $black_re = $self->black_re;

    if ($s =~ s/$white_re//gi) {

        # If part of the string matches the whitelist, but another part of it
        # matches the blacklist, it is still considered invalid. So we deleted
        # the part that matched the whitelist and examine the remainder.
        #
        # This is necessary because the blacklist can be more general than the
        # whitelist. For example, you are testing whether a street address
        # string is a pobox, and you put 'Post' and 'P.O. BOX' in the
        # blacklist, but put 'Post Street' in the blacklist. Now it's clear
        # why we had to delete the part that matched the whitelist. Also
        # consider the case of 'P.O. BOX 37, Post Street 9'.

        return $s !~ qr/$black_re/i;
    } elsif ($s =~ qr/$black_re/i) {
        return 0;
    } else {
        return 1;
    }
}


1;


__END__

=head1 NAME

String::BlackWhiteList - match a string against a blacklist and a whitelist

=head1 SYNOPSIS

    use String::BlackWhiteList;

    use constant BLACKLIST => (
        'POST',
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
    );

    my @ok = (
        'Post Road 123',
        'Post Rd 123',
        'Post Street 123',
        'Post St 123',
        'Post Avenue 123',
    );

    my @not_ok = (
        'Post',
        'P.O. BOX 37',
        'P.O. BOX 37, Post Drive 9',
        'Post Street, P.O.B.',
    );

    plan tests => @ok + @not_ok;

    my $matcher = String::BlackWhiteList->new(
        blacklist => [ BLACKLIST ],
        whitelist => [ WHITELIST ]
    )->update;

    ok( $matcher->valid($_), "[$_] valid")   for @ok;
    ok(!$matcher->valid($_), "[$_] invalid") for @not_ok;

=head1 DESCRIPTION

Using this class you can match strings against a blacklist and a whitelist.
The matching algorithm is explained in the C<valid()> method's documentation.

=head1 METHODS

=over 4

=item new

Constructs a matcher object.

=item blacklist

Is an array accessor per C<Class::Accessor::Complex>. Use it to maintain the
list of (sub-)strings you consider blacklisted.

=item whitelist

Is an array accessor per C<Class::Accessor::Complex>. Use it to maintain the
list of (sub-)strings you consider whitelisted.

=item black_re

The actual regular expression (preferably created by C<qr//>) used for
blacklist testing.

=item white_re

The actual regular expression (preferably created by C<qr//>) used for
whitelist testing.

=item update

Takes the blacklist from C<blacklist()>, generates a regular expression that
matches any string in the blacklist and sets the regular expression on
C<black_re()>.

Also takes the whitelist from C<whitelist()>, generates a regular expression
that matches any string in the whitelist and sets the regular expression on
C<white_re()>.

If you set a C<black_re()> and a C<white_re()> yourself, you shouldn't use
<C<update()>, of course.

=item valid

Takes a string and tries to determine whether it is valid according to the
blacklist and the whitelist. This is the algorithm used to determine validity:

If the string matches the whitelist, then the part of the string that didn't
match the whitelist is checked against the blacklist. If the remainder matches
the blacklist, the string is still considered invalid. If not, it is
considered valid.

Consider the example of C<P.O. BOX 37, Post Drive 9> in the L</SYNOPSIS>. The
C<Post Drive> matches the whitelist, but the C<P.O. BOX> matches the
blacklist, so the string is still considered invalid.

If the string doesn't match the whitelist, but it matches the blacklist, then
it is considered invalid.

If the string matches neither the whitelist nor the blacklist, it is
considered valid.

=back

=head1 TAGS

If you talk about this module in blogs, on del.icio.us or anywhere else,
please use the C<stringblackwhitelist> tag.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-string-blackwhitelist@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 INSTALLATION

See perlmodinstall for information and options on installing Perl modules.

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit <http://www.perl.com/CPAN/> to find a CPAN
site near you. Or see <http://www.perl.com/CPAN/authors/id/M/MA/MARCEL/>.

=head1 AUTHOR

Marcel GrE<uuml>nauer, C<< <marcel@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright 2007 by Marcel GrE<uuml>nauer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

