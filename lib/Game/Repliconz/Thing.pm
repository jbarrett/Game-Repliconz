use strict;
use warnings;

package Game::Repliconz::Thing;

use feature "state";
use v5.10.1;

use SDL::Video;

use Game::Repliconz::Bullet;
use Carp;

use Class::XSAccessor {
    lvalue_accessors => [
        'last_x',   'last_y', 'last_dt', 'last_v_x',
        'last_v_y', 'x',      'y',       'w',
        'h',        'v_x',    'v_y',     'dt'
    ],
};

use Collision::2D ':all';

sub move {
    my ($self) = @_;
    $self->last_x   = $self->x;
    $self->last_y   = $self->y;
    $self->last_dt  = $self->dt;
    $self->last_v_x = $self->v_x;
    $self->last_v_y = $self->v_y;
    $self->x += $self->v_x * $self->dt;
    $self->y += $self->v_y * $self->dt;
}

sub collision {
    my ( $self, $thing ) = @_;
    return 0 if ( !$self->alive || !$thing->alive );
    my @rect = map {
        hash2rect(
            {
                x  => $_->last_x,
                y  => $_->last_y,
                h  => $_->h,
                w  => $_->w,
                xv => $_->last_v_x,
                yv => $_->last_v_y,
            }
          )
    } ( $self, $thing );
    return dynamic_collision( $rect[0], $rect[1], interval => $self->last_dt );
}

sub check_collides_with {
    my ( $self, $things ) = @_;
    my $check_distance = 50;

    for my $thing ( @{$things} ) {
        next
          if ( abs( $self->x - $thing->x > $check_distance )
            || abs( $self->y - $thing->y > $check_distance ) );
        if ( $self->collision($thing) ) {
            $thing->hit;
            $self->hit;
            return 1;
        }
    }
}

sub draw {
    my ( $self, $app ) = @_;
    $app->draw_rect( [ $self->x, $self->y, $self->w, $self->h ],
        $self->{colour} );
}

sub shoot {
    my ( $self, $dt, $target_x, $target_y, $initial_total_dt ) = @_;
    state $total_dt = $initial_total_dt // 0;
    $total_dt += $dt;
    return unless ( $total_dt >= $self->{cooling_time} );
    $total_dt -= $self->{cooling_time};

    SDL::Mixer::Channels::play_channel( $self->{shoot_channel},
        $self->{shoot_noise}, 0 )
      if $self->{audio};

    @{ $self->{bullets} } =
      grep { $_->alive && !$_->way_out_there; } @{ $self->{bullets} };

    push @{ $self->{bullets} },
      Game::Repliconz::Bullet->new(
        {
            shooter  => $self,
            target_x => $target_x,
            target_y => $target_y
        }
      );
}

sub respawn {
}

sub hit {
    my ($self) = @_;
    $self->{lives}--;
    $self->respawn if $self->alive;
}

sub alive {
    my ($self) = @_;
    return ( $self->{lives} >= 0 ) ? 1 : 0;
}

sub constrain_velocity_xy {
    my ( $self, $v_x, $v_y ) = @_;

    ( $v_y > 0 ) && ( $v_y = 1 );
    ( $v_y < 0 ) && ( $v_y = -1 );
    ( $v_x > 0 ) && ( $v_x = 1 );
    ( $v_x < 0 ) && ( $v_x = -1 );

    # Moving diagonally, moderate eventual velocity
    if ( $v_y != 0 && $v_x != 0 ) {
        $v_y *= 0.707;    # sin(45 degrees)
        $v_x *= 0.707;
    }

    return ( $v_x, $v_y );
}

1;

