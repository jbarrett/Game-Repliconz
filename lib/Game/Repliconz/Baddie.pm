use strict;
use warnings;

package Game::Repliconz::Baddie;

use v5.10.1;

use parent qw/Game::Repliconz::Thing/;

sub new {
    my ( $class, $opts ) = @_;
    $opts->{lives} //= 1;

    $opts->{field_width} //= 640;
    $opts->{field_height} //= 480;

    $opts->{w} = 15;
    $opts->{h} = 15;

    $opts->{x} = $opts->{y} = rand;
    for ((qw/t l b r/)[int(rand(4))]) {
        when ('t') { $opts->{x} *= $opts->{field_width} ; $opts->{y} = -$opts->{h} }
        when ('b') { $opts->{x} *= $opts->{field_width} ; $opts->{y} = $opts->{field_height} + $opts->{h} }
        when ('l') { $opts->{y} *= $opts->{field_height} ; $opts->{x} = -$opts->{w} }
        when ('r') { $opts->{y} *= $opts->{field_height} ; $opts->{x} = $opts->{field_width} + $opts->{w} }
    }

    $opts->{colour} = 0x00FF00FF;
    $opts->{velocity} = 10;
    $opts->{cooling_time} = 10;
    $opts->{max_bullets} = 3;
    $opts->{on_screen} = 0;

    bless $opts, $class;
}

sub move {
    my ( $self, $target_x, $target_y, $dt, $app ) = @_;

    my $v_y = $target_y - $self->{y};
    my $v_x = $target_x - $self->{x};

    ($v_x, $v_y) = $self->constrain_velocity_xy($v_x, $v_y);

    $self->dt = $dt;
    $self->v_x = $v_x * $self->{velocity};
    $self->v_y = $v_y * $self->{velocity};

    $self->SUPER::move();

    ($self->{x} > 0 || $self->{x} < ($app->w - $self->{w})) &&
    ($self->{y} > 0 || $self->{y} < ($app->h - $self->{h})) &&
    ($self->{on_screen} = 1);
}

1;

