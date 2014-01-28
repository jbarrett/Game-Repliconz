use strict;
use warnings;

package Game::Repliconz::Bullet;

use v5.10.1;

use parent qw/Game::Repliconz::Thing/;

sub new {
    my ( $class, $opts ) = @_;
    $opts->{lives} //= 1;

    $opts->{field_width} //= 640;
    $opts->{field_height} //= 480;

    $opts->{x} = $opts->{shooter}->{x} + ($opts->{shooter}->{w} / 2);
    $opts->{y} = $opts->{shooter}->{y} + ($opts->{shooter}->{h} / 2);
    $opts->{w} = 6;
    $opts->{h} = 6;

    # normalise vector : guy position -> target position
    $opts->{base_v_y} = $opts->{target_y} - $opts->{y};
    $opts->{base_v_x} = $opts->{target_x} - $opts->{x};
    my $base_v_len = sqrt($opts->{base_v_y} ** 2 + $opts->{base_v_x} ** 2);
    return if $base_v_len == 0;
    $opts->{base_v_y} /= $base_v_len;
    $opts->{base_v_x} /= $base_v_len;

    $opts->{colour} = 0xFFFFFFFF;
    $opts->{velocity} = 70;

    bless $opts, $class;
}

sub move {
    my ( $self, $dt, $app ) = @_;

    $self->dt = $dt;
    $self->v_x = $self->{base_v_x} * $self->{velocity};
    $self->v_y = $self->{base_v_y} * $self->{velocity};

    $self->SUPER::move();
}

sub way_out_there {
    my ( $self, $field_w, $field_h ) = @_;
    my $threshold = 50;

    $field_w //= $self->{field_width};
    $field_h //= $self->{field_height};

    return 1 if ( $self->x < -$threshold || $self->x > $field_w + $threshold ||
                  $self->y < -$threshold || $self->y > $field_h + $threshold );
}

1;

