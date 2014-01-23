use strict;
use warnings;

package Game::Repliconz;

use v5.10.1;
use SDL;
use SDL::Mixer;
use SDL::Mixer::Channels;
use SDL::Mixer::Samples;
use SDL::Mouse;
use SDL::Event;
use SDL::Video;

use SDLx::App;

use Game::Repliconz::Guy;

use Carp;

sub new {
    my ( $class, $opts ) = @_;
    ($opts->{working_dir}) or croak("I don't know where I am");

    $opts->{w} //= 640;
    $opts->{h} //= 480;

    $opts->{mouse}->{x} = $opts->{w} / 2;
    $opts->{mouse}->{y} = $opts->{h} / 2;

    $opts->{controls}->{keyboard}->{u} //= [SDLK_w, SDLK_UP];
    $opts->{controls}->{keyboard}->{d} //= [SDLK_s, SDLK_DOWN];
    $opts->{controls}->{keyboard}->{l} //= [SDLK_a, SDLK_LEFT];
    $opts->{controls}->{keyboard}->{r} //= [SDLK_d, SDLK_RIGHT];
    $opts->{controls}->{keyboard}->{b} //= [SDLK_SPACE];

    _init_audio($opts);
    _new_app($opts);
    bless $opts, $class;
}

sub play_sample {
    my ( $self, $sample ) = @_;
    return 0 if !$self->{audio};
    SDL::Mixer::Channels::play_channel(-1, $sample, 0);
}

sub _new_app {
    my ( $opts ) = @_;
    SDL::init(SDL_INIT_VIDEO);
    SDL::Events::enable_key_repeat( 100, 30 );
    $opts->{app} = SDLx::App->new(
        title => "Repliconz!",
        width => $opts->{w},
        height => $opts->{h},
        delay => 20
    );
}

sub _init_audio {
    my ( $opts ) = @_;

    SDL::init(SDL_INIT_AUDIO);

    if ( SDL::Mixer::open_audio( 44100, SDL::Constants::AUDIO_S16, 2, 4096) == 0 ) {
        $opts->{audio} = 1;
    }
    else {
        $opts->{audio} = 0;
        carp "Audio disabled : " . SDL::get_error();
        return 0;
    }
    # Channels : bullets, explosions, game events (new life, level up), enemy chatter?
    # Or just send it all to -1 and come what may?
    SDL::Mixer::Channels::allocate_channels(4);
    @{$opts->{samples}}{ qw/
        bonus_sweeps
        laser
        explosion
    / } = (
        SDL::Mixer::Samples::load_WAV("$opts->{working_dir}/sound/bonus_sweeps.wav"),
        SDL::Mixer::Samples::load_WAV("$opts->{working_dir}/sound/laser.wav"),
        SDL::Mixer::Samples::load_WAV("$opts->{working_dir}/sound/explosion.wav"),
    )
}

sub events {
    my ( $self, $event, $app ) = @_;
    return $app->stop if $event->type == SDL_QUIT;

    if ($event->type == SDL_KEYDOWN) {
        $self->{keys}->{$event->key_sym} = 1;
    }
    if ($event->type == SDL_KEYUP) {
        $self->{keys}->{$event->key_sym} = 0;
    }

    if ($event->type == SDL_MOUSEMOTION) {
        $self->{mouse}->{x} = $event->motion_x;
        $self->{mouse}->{y} = $event->motion_y;
    }

    if ($event->type == SDL_MOUSEBUTTONDOWN && $event->button_button == SDL_BUTTON_LEFT) {
            $self->{mouse}->{firing} = 1;
    }
    if ($event->type == SDL_MOUSEBUTTONUP && $event->button_button == SDL_BUTTON_LEFT) {
            $self->{mouse}->{firing} = 0;
    }
}

sub show {
    my ( $self, $dt, $app ) = @_;
    SDL::Video::fill_rect( $app, SDL::Rect->new(0, 0, $app->w, $app->h), 0 );

    $self->{hero}->draw($app);
    for my $bullet (@{$self->{hero}->{bullets}}) { $bullet->draw($app) }

    $app->update();
}

sub move {
    my ( $self, $dt, $app, $t ) = @_;
    my $v_x = 0;
    my $v_y = 0;
    my $bomb = 0;

    for (grep { $self->{keys}->{$_} } keys %{$self->{keys}}) {
        when ($self->{controls}->{keyboard}->{u}) { $v_y += -1 }
        when ($self->{controls}->{keyboard}->{d}) { $v_y += 1 }
        when ($self->{controls}->{keyboard}->{l}) { $v_x += -1 }
        when ($self->{controls}->{keyboard}->{r}) { $v_x += 1 }
        when ($self->{controls}->{keyboard}->{b}) { $bomb = 1 }
    }

    $self->{hero}->move( $v_x, $v_y, $dt, $app );

    $self->{hero}->self_destruct if ($bomb);

    $self->{hero}->shoot( $dt, $self->{mouse}->{x}, $self->{mouse}->{y} ) if ($self->{mouse}->{firing});

    for my $bullet (@{$self->{hero}->{bullets}}) { $bullet->move( $dt, $app ) }
}

sub play {
    my ( $self ) = @_;
    $self->{hero} = Game::Repliconz::Guy->new( {
        field_width  => $self->{w},
        field_height => $self->{h},
    } );
    @{$self->{baddies}} = ();
    @{$self->{superbaddies}} = ();

    $self->{app}->add_event_handler( sub { $self->events(@_) } );
    $self->{app}->add_show_handler( sub { $self->show(@_) } );
    $self->{app}->add_move_handler( sub { $self->move(@_) } );

    #$self->{app}->fullscreen;
    $self->{app}->run;
}

1;

