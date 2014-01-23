use strict;
use warnings;

package Game::Repliconz::Bullet;

use parent qw/Game::Repliconz::Thing/;

sub new {
    my ( $class, $opts ) = @_;

    $opts->{x} = $opts->{guy}->{x} + ($opts->{guy}->{w} / 2);
    $opts->{y} = $opts->{guy}->{y} + ($opts->{guy}->{h} / 2);
    $opts->{w} = 4;
    $opts->{h} = 4;

    # normalise vector : guy position -> target position
    $opts->{v_y} = $opts->{target_y} - $opts->{y};
    $opts->{v_x} = $opts->{target_x} - $opts->{x};
    my $v_len = sqrt(abs( $opts->{v_y} ** 2 + $opts->{v_x} ** 2 ));
    $opts->{v_y} /= $v_len;
    $opts->{v_x} /= $v_len;

    $opts->{colour} = 0xFFFFFFFF;
    $opts->{velocity} = 70;

    bless $opts, $class;
}

sub move {
    my ( $self, $dt, $app ) = @_;

    $self->{x} += $self->{v_x} * $self->{velocity} * $dt;
    $self->{y} += $self->{v_y} * $self->{velocity} * $dt;
}

1;

