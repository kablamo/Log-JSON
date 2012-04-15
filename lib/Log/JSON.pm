package Log::JSON;
use Moose;
use MooseX::Types::Path::Class;

use Carp;
use English;
use JSON;
use Path::Class::File;

our $VERSION = '0.03';

=head1 NAME

Log::JSON

=head1 SYNOPSIS

    use Log::JSON;
    my $logger = Log::JSON->new(file => '/path/errorlog.json');
    $logger->log(a => 1, b => 2);
    # '/path/errorlog.json' now contains: 
    # {"__date":"2010-03-28T23:15:52Z","a":1,"b":1}

=head1 DESCRIPTION

This module logs a hash to a file as JSON.  

If you aren't familiar with the format of the log file, its sometimes difficult
to decipher what all the data means -- especially if each row contains many
columns. Using JSON means the information is labeled and the log file is more
human readable.

Having a log file with JSON formatted text also means its easy to parse and use
the data structure in the log file -- very similar to using L<Storable>.  In
fact Storable is a good alternative for creating log files.  The advantage of
this module is that Storable adds some version numbers and other data which
make it slightly less friendly to humans reading the raw file.

=head1 METHODS

=cut

has 'remove_newlines' => ( is => 'ro', isa => 'Bool', default => 1 );
has 'date'            => ( is => 'ro', isa => 'Bool', default => 1 );

has 'file' => (
    is      => 'ro',
    isa     => 'Path::Class::File',
    required => 1,
    coerce  => 1,
);

sub BUILD {
    my $self = shift;
    $self->file->dir->mkpath;
    $self->file->touch;
}

sub log {
    my $self = shift;
    my %data = @_;

    $data{__date} = DateTime->now . ""
        if $self->date;

    #                     sort keys
    my $json = JSON->new->canonical->encode( \%data );

    if ( $self->remove_newlines ) {
        $json =~ s/\n//g;
        $json =~ s/\r//g;
    }

    my $fh = $self->file->open('>>');
    print $fh $json . "\n";
    $fh->close;
}

=head1 BUGS

This should probably become a Log::Dispatch plugin.

=head1 AUTHOR

Eric Johnson

=cut

1;
