# ABSTRACT: Log data to a file as JSON
package Log::JSON;
use Moose;
use MooseX::Types::Path::Class;

use Carp;
use English;
use JSON;
use Path::Class::File;

=head1 SYNOPSIS

    use Log::JSON;
    my $logger = Log::JSON->new(
        file            => '/path/errorlog.json', # required
        date            => 1, # optional
        remove_newlines => 1, # optional
    );
    $logger->log(a => 1, b => 2);
    # '/path/errorlog.json' now contains: 
    # {"__date":"2010-03-28T23:15:52Z","a":1,"b":1}

=head1 DESCRIPTION

This module logs a hash to a file as JSON.  The keys are printed in sorted order.  

Often log files have lots of raw numbers and strings whose meaning is not
immediately obvious.  With JSON formatted text your log files, a human can open
the file and quickly decipher the content because each piece of information is
labeled.

Using JSON also means log files are easy to parse and the data structures can
be easily revived.

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

=head1 METHODS

=cut

=head2 new(%hash)

Returns a Log::JSON object.


=cut

=head2 log(%hash)

Appends %hash to a file as JSON.  The keys are sorted when the hash is converted to JSON.

=cut

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

This should probably should have been a Log::Dispatch plugin.

=head1 SEE ALSO


=cut

1;
