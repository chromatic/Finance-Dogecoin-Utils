package Finance::Dogecoin::Utils;
# ABSTRACT: Libraries and Utilities to work with Dogecoin

use strict;
use warnings;

use File::HomeDir;
use Path::Tiny;

use Exporter::Shiny our @EXPORT = qw( get_conf_dir get_auth_file get_dogecoin_conf_dir );

sub get_conf_dir {
    return path(File::HomeDir->my_data)->child('dogeutils')->mkdir;
}

sub get_auth_file {
    return get_conf_dir()->child( 'auth.json' );
}

sub get_dogecoin_conf_dir {
    return path(File::HomeDir->my_home)->child('.dogecoin')->child('backups');
}

1;

__END__

=head1 SYNOPSIS

See L<dogeutils>

=head1 COPYRIGHT

Copyright (c) 2022 chromatic

=head1 AUTHOR

chromatic

=cut
