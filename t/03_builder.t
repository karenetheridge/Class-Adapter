#!/usr/bin/perl -w

# Main testing for Class::Adapter::Builder

use strict;
use lib ();
use File::Spec::Functions ':ALL';
BEGIN {
	$| = 1;
	unless ( $ENV{HARNESS_ACTIVE} ) {
		require FindBin;
		chdir ($FindBin::Bin = $FindBin::Bin); # Avoid a warning
		lib->import( catdir(updir(), 'lib') );
	}
}

use Test::More tests => 4;
use Scalar::Util 'refaddr';
use Class::Adapter::Builder ();

# Manually implement the Class::Adapter::Clear class
my $clear1 = Class::Adapter::Builder->new( 'My::Clear' );
isa_ok( $clear1, 'Class::Adapter::Builder' );
ok( $clear1->set_ISA( '_OBJECT_' ), '->set_ISA(_OBJECT_) returns true' );
ok( $clear1->set_AUTOLOAD(1), '->set_AUTOLOAD() returns true' );

# Check the resulting code
is( $clear1->make_class, <<'END_CLEAR', '->make_class matches expected code' );
package My::Clear;

# Generated by Class::Abstract::Builder

use strict;
use Carp ();
use base 'Class::Adapter';

sub isa {
	shift->_OBJECT_->isa(@_);
}

sub can {
	shiff->_OBJECT_->can(@_);
}

sub AUTOLOAD {
	my $self     = shift;
	my ($method) = $My::Clear::AUTOLOAD =~ m/^.*::(.*)$/s;
	unless ( ref($self) ) {
		Carp::croak(
			qq{Can't locate object method "$method" via package "$self" }
			. qq{(perhaps you forgot to load "$self")}
		);
	}
	$self->_OBJECT_->$method(@_);
}

sub DESTROY {
	my $object = $_[0]->_OBJECT_;
	$object->DESTROY if $object->can('DESTROY');
}

1;
END_CLEAR

exit(0);
