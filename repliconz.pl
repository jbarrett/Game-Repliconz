#!/usr/bin/env perl

use FindBin;
use lib "$FindBin::Bin/lib";

use Game::Repliconz;

Game::Repliconz->new( { working_dir => $FindBin::Bin } )->play();

