use strict;
use warnings;

package Game::Repliconz::Thing;

use feature "state";

use SDL::Video;

use Game::Repliconz::Bullet;
use Carp;

use Class::XSAccessor {
    accessors   => [ 'x', 'y', 'w', 'h' ],
};

use Collision::Util ':std';

sub draw {
    my ( $self, $app ) = @_;
    $app->draw_rect( [ $self->{x}, $self->{y}, $self->{w}, $self->{h} ], $self->{colour} );
}

sub shoot {
    my ( $self, $dt, $target_x, $target_y, $initial_total_dt ) = @_;
    state $total_dt = $initial_total_dt // 0;
    $total_dt += $dt;
    return unless ($total_dt >= $self->{cooling_time});
    $total_dt -= $self->{cooling_time};

    push @{$self->{bullets}}, Game::Repliconz::Bullet->new( {
        guy => $self,
        target_x => $target_x,
        target_y => $target_y
    });

    shift @{$self->{bullets}} if (scalar @{$self->{bullets}} > $self->{max_bullets});
}

sub respawn {
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

sub constrain_velocity_xy {
    my ( $self, $v_x, $v_y ) = @_;

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


1;

