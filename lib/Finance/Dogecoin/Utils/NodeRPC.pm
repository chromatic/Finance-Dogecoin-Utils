# PODNAME: Finance::Dogecoin::Utils::NodeRPC
# ABSTRACT: make authenticated RPC to a Dogecoin Core node

use Object::Pad;

use strict;
use warnings;

class Finance::Dogecoin::Utils::NodeRPC {
    use Mojo::UserAgent;
    use Mojo::JSON 'decode_json';

    field $ua   :param;
    field $auth :param;

    sub BUILDARGS( $class, %args ) {
        $args{ua} //= Mojo::UserAgent->new;
        unless ($args{auth}) {
            if ($args{user} && $args{password}) {
                $args{auth} = "$args{user}:$args{password}";
            } elsif ($args{user} && $args{auth_file}) {
                my $auth = decode_json( $args{auth_file}->slurp_utf8 );
                $args{password} = $auth->{$args{user}} if exists $auth->{$args{user}};
            }
        }

        $args{auth} = "$args{user}:$args{password}";

        return %args;
    }

    method call_method( $method, @params ) {
        my $res = $ua->post(
            Mojo::URL->new('http://localhost:22555')->userinfo( $auth ),
            json => { jsonrpc => '1.0', id => 'Perl RPCAuth', method => $method, params => \@params }
        )->res;

        return $res->json if $res->is_success;

        if (! defined $res->is_error) {
            warn "RPC server not available\n";
        } elsif ($res->code == 403) {
            warn "Auth to Dogecoin RPC failed\n";
        } else {
            warn "Something went wrong with Dogecoin RPC: " . $res->code . "\n";
        }

        return {};
    }
}

=head1 SYNOPSIS

Class representing a Dogecoin Core node on which to perform RPC.

=head1 COPYRIGHT

Copyright (c) 2022 chromatic

=head1 AUTHOR

chromatic

=cut
