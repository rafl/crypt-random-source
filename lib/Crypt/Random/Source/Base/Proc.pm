package Crypt::Random::Source::Base::Proc;
# ABSTRACT: Base class for helper processes (e.g. C<openssl>)

use Any::Moose;

extends qw(Crypt::Random::Source::Base::Handle);

use Capture::Tiny qw(capture);
use File::Spec;
use IO::File;

use 5.008;

has command => ( is => "rw", required => 1 );
has search_path => ( is => 'rw', isa => 'Str', lazy_build => 1 );

# This is a scalar so that people can customize it (which they would
# particularly need to do on Windows).
our $TAINT_PATH = 
    '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin';

sub _build_search_path {
    # In taint mode it's not safe to use $ENV{PATH}.
    if (${^TAINT}) {
        return $TAINT_PATH;
    }
    return $ENV{PATH};
}

sub open_handle {
	my $self = shift;

	my $cmd = $self->command;
	my @cmd = ref $cmd ? @$cmd : $cmd;
        my $retval;
        local $ENV{PATH} = $self->search_path;
        my ($stdout, $stderr) = capture { $retval = system(@cmd) };
        chomp($stderr);
        if ($retval) {
            my $err = join(' ', @cmd) . ": $! ($?)";
            if ($stderr) {
                $err .= "\n$stderr";
            }
            die $err;
        }
        warn $stderr if $stderr;

	open(my $fh, '<', \$stdout) || die $!;

	return $fh;
}

1;

=head1 SYNOPSIS

	use Moose;

	extends qw(Crypt::Random::Source::Base::Proc);

	has '+command' => ( default => ... );

=head1 DESCRIPTION

This is a base class for using command line utilities which output random data
on STDOUT as L<Crypt::Random::Source> objects.

=attr command

An array reference or string that is the command to run.

=method open_handle

Opens a pipe for reading using C<command>.

=cut
