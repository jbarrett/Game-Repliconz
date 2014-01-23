use strict;
use warnings;

package Game::Repliconz::Thing;

use SDL::Video;

use Carp;

sub draw {
    my ( $self, $app ) = @_;
    $app->draw_rect( [ $self->{x}, $self->{y}, $self->{w}, $self->{h} ], $self->{colour} );
}

1;

