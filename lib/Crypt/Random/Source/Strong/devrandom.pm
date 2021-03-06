package Crypt::Random::Source::Strong::devrandom;
# ABSTRACT: A strong random data source using F</dev/random>

use Any::Moose;

extends qw(
	Crypt::Random::Source::Strong
	Crypt::Random::Source::Base::RandomDevice
);


sub default_path { "/dev/random" }

1;

=head1 SYNOPSIS

	use Crypt::Random::Source::Strong::devrandom;

=cut
