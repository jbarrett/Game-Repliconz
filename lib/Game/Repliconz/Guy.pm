use strict;
use warnings;

package Game::Repliconz::Guy;

use parent qw/Game::Repliconz::Thing/;

sub new {
    my ( $class, $opts ) = @_;
    $opts->{lives} //= 3;

    $opts->{field_width} //= 640;
    $opts->{field_height} //= 480;

    $opts->{w} = 15;
    $opts->{h} = 20;

    $opts->{x} = $opts->{initial_x} = ($opts->{field_width} - $opts->{w}) / 2;
    $opts->{y} = $opts->{initial_y} = ($opts->{field_height} - $opts->{h}) / 2;

    $opts->{colour} = 0xFF0000FF;
    $opts->{velocity} = 30;
    $opts->{cooling_time} = 1;

    $opts->{max_bullets} = 20; # consider cooling time and bullet travel time

    bless $opts, $class;
}

sub respawn {
    my ( $self ) = @_;
    $self->{x} = rand($self->{field_width});
    $self->{y} = rand($self->{field_height});
}

sub self_destruct {
    # BOOM, take some of them to hell with you
}

sub move {
    my ( $self, $v_x, $v_y, $dt, $app ) = @_;

    ($v_x, $v_y) = $self->constrain_velocity_xy($v_x, $v_y);

    $self->{x} += $v_x * $self->{velocity} * $dt;
    $self->{y} += $v_y * $self->{velocity} * $dt;

    ($self->{x} < 0) && ($self->{x} = 0);
    ($self->{x} > ($app->w - $self->{w})) && ($self->{x} = $app->w - $self->{w});
    ($self->{y} < 0) && ($self->{y} = 0);
    ($self->{y} > ($app->h - $self->{h})) && ($self->{y} = $app->h - $self->{h});
}

1;

