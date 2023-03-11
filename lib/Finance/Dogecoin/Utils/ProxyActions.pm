# PODNAME: Finance::Dogecoin::Utils::ProxyActions
# ABSTRACT: proxy and enhance RPC made to a Dogecoin Core node
use Object::Pad;

use strict;
use warnings;

class Finance::Dogecoin::Utils::ProxyActions {
    use JSON;
    use Path::Tiny;
    use feature 'say';

    field $rpc          :param;
    field $json         :param;
    field $addresses    :param;
    field $address_file :param;

    sub BUILDARGS( $class, %args ) {
        $args{json} //= JSON->new->utf8(1);
        $args{address_file} = path( $args{address_file} );
        $args{addresses} //= do {
            if ($args{address_file}->exists) {
                $args{json}->decode( $args{address_file}->slurp_utf8 );
            }
            else {
                {}
            }
        };

        return %args;
    }

    method setlabel( $address, $label ) {
        $addresses->{$label} = $address;
        return 1;
    }

    method getreceivedbylabel( $label, @args ) {
        if (my $address = $addresses->{$label}) {
            my $output = $rpc->call_method( getreceivedbyaddress => $address, @args );
            say $json->encode( $output );
        } else {
            warn "No address label '$label' found\n";
            return 0;
        };

        return 1;
    }

    method decodetransaction( $tx_hash ) {
        my $tx = $rpc->call_method( getrawtransaction => "$tx_hash" );
        my $result = $tx->{result};
        if ($result) {
            $tx = $rpc->call_method( decoderawtransaction => $result );
            $result = $tx->{result};
            return $result if $result;
        }

        die $tx->{error};
    }

    method DESTROY {
        return unless $address_file;
        $address_file->spew_utf8( $json->encode( $addresses ) );
        undef $address_file;
    }
}

__END__

=head1 SYNOPSIS

Utilities to proxy RPC to a Dogecoin Core node.

=head1 COPYRIGHT

Copyright (c) 2022-2023 chromatic

=head1 AUTHOR

chromatic

=cut
