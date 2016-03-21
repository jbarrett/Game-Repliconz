package Game::Repliconz::NamedAccessors;

use Method::Generate::Accessor;

sub new {
	my ( $class, $name, $opts ) = @_;
	eval "{ package $name; use Moo;	}";
	my $o = $name->new;
	my $g = Method::Generate::Accessor->new;
	$g->generate_method( $name => $_ => { is => 'rw' } )
		for @{ $opts->{accessors} };
	return $o;
}

1;
