package String::BlackWhiteList;

use warnings;
use strict;

our $VERSION = '0.04';

use base 'Class::Accessor::Complex';

__PACKAGE__
    ->mk_new
    ->mk_scalar_accessors(qw(black_re white_re))
    ->mk_array_accessors(qw(blacklist whitelist));


sub update {
    my $self = shift;

    my @blacklist = $self->blacklist;
    my @whitelist = $self->whitelist;

    my %seen;
    $seen{$_} = 1 for @blacklist;
    for (@whitelist) {
        next unless $seen{$_};
        warn "[$_] is both blacklisted and whitelisted\n";
    }

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

    return 1 unless defined $s && length $s;

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


sub valid_relaxed {
    my ($self, $s) = @_;

    return 1 unless defined $s && length $s;

    my $white_re = $self->white_re;
    my $black_re = $self->black_re;

    return 1 if $s =~ qr/$white_re/i;
    return 0 if $s =~ qr/$black_re/i;
    return 1;
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

String::BlackWhiteList inherits from L<Class::Accessor::Complex>.

The superclass L<Class::Accessor::Complex> defines these methods and
functions:

    carp(), cluck(), croak(), flatten(), mk_abstract_accessors(),
    mk_array_accessors(), mk_boolean_accessors(),
    mk_class_array_accessors(), mk_class_hash_accessors(),
    mk_class_scalar_accessors(), mk_concat_accessors(),
    mk_forward_accessors(), mk_hash_accessors(), mk_integer_accessors(),
    mk_new(), mk_object_accessors(), mk_scalar_accessors(),
    mk_set_accessors(), mk_singleton()

The superclass L<Class::Accessor> defines these methods and functions:

    _carp(), _croak(), _mk_accessors(), accessor_name_for(),
    best_practice_accessor_name_for(), best_practice_mutator_name_for(),
    follow_best_practice(), get(), make_accessor(), make_ro_accessor(),
    make_wo_accessor(), mk_accessors(), mk_ro_accessors(),
    mk_wo_accessors(), mutator_name_for(), set()

The superclass L<Class::Accessor::Installer> defines these methods and
functions:

    install_accessor(), subname()

=head1 METHODS

=over 4

=item new

    my $obj = String::BlackWhiteList->new;
    my $obj = String::BlackWhiteList->new(%args);

Creates and returns a new object. The constructor will accept as arguments a
list of pairs, from component name to initial value. For each pair, the named
component is initialized by calling the method of the same name with the given
value. If called with a single hash reference, it is dereferenced and its
key/value pairs are set as described before.

=item black_re

    my $value = $obj->black_re;
    $obj->black_re($value);

A basic getter/setter method. If called without an argument, it returns the
value. If called with a single argument, it sets the value.

=item black_re_clear

    $obj->black_re_clear;

Clears the value.

=item blacklist

    my @values    = $obj->blacklist;
    my $array_ref = $obj->blacklist;
    $obj->blacklist(@values);
    $obj->blacklist($array_ref);

Get or set the array values. If called without an arguments, it returns the
array in list context, or a reference to the array in scalar context. If
called with arguments, it expands array references found therein and sets the
values.

=item blacklist_clear

    $obj->blacklist_clear;

Deletes all elements from the array.

=item blacklist_count

    my $count = $obj->blacklist_count;

Returns the number of elements in the array.

=item blacklist_index

    my $element   = $obj->blacklist_index(3);
    my @elements  = $obj->blacklist_index(@indices);
    my $array_ref = $obj->blacklist_index(@indices);

Takes a list of indices and returns the elements indicated by those indices.
If only one index is given, the corresponding array element is returned. If
several indices are given, the result is returned as an array in list context
or as an array reference in scalar context.

=item blacklist_pop

    my $value = $obj->blacklist_pop;

Pops the last element off the array, returning it.

=item blacklist_push

    $obj->blacklist_push(@values);

Pushes elements onto the end of the array.

=item blacklist_set

    $obj->blacklist_set(1 => $x, 5 => $y);

Takes a list of index/value pairs and for each pair it sets the array element
at the indicated index to the indicated value. Returns the number of elements
that have been set.

=item blacklist_shift

    my $value = $obj->blacklist_shift;

Shifts the first element off the array, returning it.

=item blacklist_splice

    $obj->blacklist_splice(2, 1, $x, $y);
    $obj->blacklist_splice(-1);
    $obj->blacklist_splice(0, -1);

Takes three arguments: An offset, a length and a list.

Removes the elements designated by the offset and the length from the array,
and replaces them with the elements of the list, if any. In list context,
returns the elements removed from the array. In scalar context, returns the
last element removed, or C<undef> if no elements are removed. The array grows
or shrinks as necessary. If the offset is negative then it starts that far
from the end of the array. If the length is omitted, removes everything from
the offset onward. If the length is negative, removes the elements from the
offset onward except for -length elements at the end of the array. If both the
offset and the length are omitted, removes everything. If the offset is past
the end of the array, it issues a warning, and splices at the end of the
array.

=item blacklist_unshift

    $obj->blacklist_unshift(@values);

Unshifts elements onto the beginning of the array.

=item clear_black_re

    $obj->clear_black_re;

Clears the value.

=item clear_blacklist

    $obj->clear_blacklist;

Deletes all elements from the array.

=item clear_white_re

    $obj->clear_white_re;

Clears the value.

=item clear_whitelist

    $obj->clear_whitelist;

Deletes all elements from the array.

=item count_blacklist

    my $count = $obj->count_blacklist;

Returns the number of elements in the array.

=item count_whitelist

    my $count = $obj->count_whitelist;

Returns the number of elements in the array.

=item index_blacklist

    my $element   = $obj->index_blacklist(3);
    my @elements  = $obj->index_blacklist(@indices);
    my $array_ref = $obj->index_blacklist(@indices);

Takes a list of indices and returns the elements indicated by those indices.
If only one index is given, the corresponding array element is returned. If
several indices are given, the result is returned as an array in list context
or as an array reference in scalar context.

=item index_whitelist

    my $element   = $obj->index_whitelist(3);
    my @elements  = $obj->index_whitelist(@indices);
    my $array_ref = $obj->index_whitelist(@indices);

Takes a list of indices and returns the elements indicated by those indices.
If only one index is given, the corresponding array element is returned. If
several indices are given, the result is returned as an array in list context
or as an array reference in scalar context.

=item pop_blacklist

    my $value = $obj->pop_blacklist;

Pops the last element off the array, returning it.

=item pop_whitelist

    my $value = $obj->pop_whitelist;

Pops the last element off the array, returning it.

=item push_blacklist

    $obj->push_blacklist(@values);

Pushes elements onto the end of the array.

=item push_whitelist

    $obj->push_whitelist(@values);

Pushes elements onto the end of the array.

=item set_blacklist

    $obj->set_blacklist(1 => $x, 5 => $y);

Takes a list of index/value pairs and for each pair it sets the array element
at the indicated index to the indicated value. Returns the number of elements
that have been set.

=item set_whitelist

    $obj->set_whitelist(1 => $x, 5 => $y);

Takes a list of index/value pairs and for each pair it sets the array element
at the indicated index to the indicated value. Returns the number of elements
that have been set.

=item shift_blacklist

    my $value = $obj->shift_blacklist;

Shifts the first element off the array, returning it.

=item shift_whitelist

    my $value = $obj->shift_whitelist;

Shifts the first element off the array, returning it.

=item splice_blacklist

    $obj->splice_blacklist(2, 1, $x, $y);
    $obj->splice_blacklist(-1);
    $obj->splice_blacklist(0, -1);

Takes three arguments: An offset, a length and a list.

Removes the elements designated by the offset and the length from the array,
and replaces them with the elements of the list, if any. In list context,
returns the elements removed from the array. In scalar context, returns the
last element removed, or C<undef> if no elements are removed. The array grows
or shrinks as necessary. If the offset is negative then it starts that far
from the end of the array. If the length is omitted, removes everything from
the offset onward. If the length is negative, removes the elements from the
offset onward except for -length elements at the end of the array. If both the
offset and the length are omitted, removes everything. If the offset is past
the end of the array, it issues a warning, and splices at the end of the
array.

=item splice_whitelist

    $obj->splice_whitelist(2, 1, $x, $y);
    $obj->splice_whitelist(-1);
    $obj->splice_whitelist(0, -1);

Takes three arguments: An offset, a length and a list.

Removes the elements designated by the offset and the length from the array,
and replaces them with the elements of the list, if any. In list context,
returns the elements removed from the array. In scalar context, returns the
last element removed, or C<undef> if no elements are removed. The array grows
or shrinks as necessary. If the offset is negative then it starts that far
from the end of the array. If the length is omitted, removes everything from
the offset onward. If the length is negative, removes the elements from the
offset onward except for -length elements at the end of the array. If both the
offset and the length are omitted, removes everything. If the offset is past
the end of the array, it issues a warning, and splices at the end of the
array.

=item unshift_blacklist

    $obj->unshift_blacklist(@values);

Unshifts elements onto the beginning of the array.

=item unshift_whitelist

    $obj->unshift_whitelist(@values);

Unshifts elements onto the beginning of the array.

=item white_re

    my $value = $obj->white_re;
    $obj->white_re($value);

A basic getter/setter method. If called without an argument, it returns the
value. If called with a single argument, it sets the value.

=item white_re_clear

    $obj->white_re_clear;

Clears the value.

=item whitelist

    my @values    = $obj->whitelist;
    my $array_ref = $obj->whitelist;
    $obj->whitelist(@values);
    $obj->whitelist($array_ref);

Get or set the array values. If called without an arguments, it returns the
array in list context, or a reference to the array in scalar context. If
called with arguments, it expands array references found therein and sets the
values.

=item whitelist_clear

    $obj->whitelist_clear;

Deletes all elements from the array.

=item whitelist_count

    my $count = $obj->whitelist_count;

Returns the number of elements in the array.

=item whitelist_index

    my $element   = $obj->whitelist_index(3);
    my @elements  = $obj->whitelist_index(@indices);
    my $array_ref = $obj->whitelist_index(@indices);

Takes a list of indices and returns the elements indicated by those indices.
If only one index is given, the corresponding array element is returned. If
several indices are given, the result is returned as an array in list context
or as an array reference in scalar context.

=item whitelist_pop

    my $value = $obj->whitelist_pop;

Pops the last element off the array, returning it.

=item whitelist_push

    $obj->whitelist_push(@values);

Pushes elements onto the end of the array.

=item whitelist_set

    $obj->whitelist_set(1 => $x, 5 => $y);

Takes a list of index/value pairs and for each pair it sets the array element
at the indicated index to the indicated value. Returns the number of elements
that have been set.

=item whitelist_shift

    my $value = $obj->whitelist_shift;

Shifts the first element off the array, returning it.

=item whitelist_splice

    $obj->whitelist_splice(2, 1, $x, $y);
    $obj->whitelist_splice(-1);
    $obj->whitelist_splice(0, -1);

Takes three arguments: An offset, a length and a list.

Removes the elements designated by the offset and the length from the array,
and replaces them with the elements of the list, if any. In list context,
returns the elements removed from the array. In scalar context, returns the
last element removed, or C<undef> if no elements are removed. The array grows
or shrinks as necessary. If the offset is negative then it starts that far
from the end of the array. If the length is omitted, removes everything from
the offset onward. If the length is negative, removes the elements from the
offset onward except for -length elements at the end of the array. If both the
offset and the length are omitted, removes everything. If the offset is past
the end of the array, it issues a warning, and splices at the end of the
array.

=item whitelist_unshift

    $obj->whitelist_unshift(@values);

Unshifts elements onto the beginning of the array.

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

Undefined values and empty strings are considered valid. This may seem
strange, but there is no indication that they are invalid and in dubio pro
reo.

=item valid_relaxed

Like valid(), but once a string passes the whitelist, it is not checked
against the blacklist anymore. That is, if a string matches the whitelist, it
is valid. If not, it is checked against the blacklist - if it matches, it is
invalid. If it matches neither whitelist nor blacklist, it is valid.

=back

=head1 TAGS

If you talk about this module in blogs, on del.icio.us or anywhere else,
please use the C<stringblackwhitelist> tag.

=head1 VERSION 
                   
This document describes version 0.04 of L<String::BlackWhiteList>.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<<bug-string-blackwhitelist@rt.cpan.org>>, or through the web interface at
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

Copyright 2005-2007 by Marcel GrE<uuml>nauer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut

