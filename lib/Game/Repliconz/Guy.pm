use strict;
use warnings;

package Game::Repliconz::Guy;

use parent qw/Game::Repliconz::Thing/;

use Game::Repliconz::Bullet;

use feature "state";


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

sub shoot {
    my ( $self, $dt, $mouse_x, $mouse_y ) = @_;
    state $total_dt = 0;
    $total_dt += $dt;
    return unless ($total_dt >= $self->{cooling_time});
    $total_dt -= $self->{cooling_time};

    push @{$self->{bullets}}, Game::Repliconz::Bullet->new( {
        guy => $self,
        target_x => $mouse_x,
        target_y => $mouse_y
    });

    shift @{$self->{bullets}} if (scalar @{$self->{bullets}} > $self->{max_bullets});
}

sub respawn {
    # Respawn in initial_x/y unless occupied... maybe move enemies out of the way?
}

sub self_destruct {
    # BOOM, take some of them to hell with you
}

sub constrain_velocity_xy {
    my ( $v_x, $v_y ) = @_;

    ($v_y > 0) && ($v_y = 1);
    ($v_y < 0) && ($v_y = -1);
    ($v_x > 0) && ($v_x = 1);
    ($v_x < 0) && ($v_x = -1);

    # Moving diagonally, moderate eventual velocity
    if ( $v_y != 0 && $v_x != 0 ) {
        $v_y *= 0.707; # sin(45 degrees)
        $v_x *= 0.707;
    }

    return ($v_x, $v_y);
}

sub draw {
    my ( $self, $app ) = @_;
    $app->draw_rect( [ $self->{x}, $self->{y}, $self->{w}, $self->{h} ], $self->{colour} );
}

sub move {
    my ( $self, $v_x, $v_y, $dt, $app ) = @_;

    ($v_x, $v_y) = constrain_velocity_xy($v_x, $v_y);

    $self->{x} += $v_x * $self->{velocity} * $dt;
    $self->{y} += $v_y * $self->{velocity} * $dt;

    ($self->{x} < 0) && ($self->{x} = 0);
    ($self->{x} > ($app->w - $self->{w})) && ($self->{x} = $app->w - $self->{w});
    ($self->{y} < 0) && ($self->{y} = 0);
    ($self->{y} > ($app->h - $self->{h})) && ($self->{y} = $app->h - $self->{h});
}

sub hit {
    my ( $self ) = @_;
    $self->{lives} --;
    $self->respawn if $self->alive;
}

sub alive {
    my ( $self ) = @_;
    return ( $self->{lives} >= 0 ) ? 1 : 0;
}

1;

