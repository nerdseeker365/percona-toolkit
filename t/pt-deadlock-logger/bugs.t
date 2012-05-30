#!/usr/bin/env perl

BEGIN {
   die "The PERCONA_TOOLKIT_BRANCH environment variable is not set.\n"
      unless $ENV{PERCONA_TOOLKIT_BRANCH} && -d $ENV{PERCONA_TOOLKIT_BRANCH};
   unshift @INC, "$ENV{PERCONA_TOOLKIT_BRANCH}/lib";
};

use strict;
use warnings FATAL => 'all';
use English qw(-no_match_vars);
use Test::More tests => 1;

use PerconaTest;
use Sandbox;
require "$trunk/bin/pt-deadlock-logger";

# #############################################################################
# https://bugs.launchpad.net/percona-toolkit/+bug/903443
# pt-deadlock-logger crashes on MySQL 5.5
# #############################################################################

my $innodb_status_sample = load_file("t/pt-deadlock-logger/samples/bug_903443.txt");

is_deeply(
   pt_deadlock_logger::parse_deadlocks($innodb_status_sample),
   {
      '1' => {
          db => '',
          hostname => 'localhost',
          id => 1,
          idx => '',
          ip => '',
          lock_mode => '',
          lock_type => '',
          query => 'update a set movie_id=96 where id =2',
          server => '',
          tbl => '',
          thread => '19',
          ts => '2011-12-12T22:52:42',
          txn_id => 0,
          txn_time => '161',
          user => 'root',
          victim => 0,
          wait_hold => 'w'
      },
      '2' => {
          db => '',
          hostname => 'localhost',
          id => 2,
          idx => '',
          ip => '',
          lock_mode => '',
          lock_type => '',
          query => 'update a set movie_id=98 where id =4',
          server => '',
          tbl => '',
          thread => '18',
          ts => '2011-12-12T22:52:42',
          txn_id => 0,
          txn_time => '1026',
          user => 'root',
          victim => 1,
          wait_hold => 'w'
      }
   },
   "Bug 903443: pt-deadlock-logger parses the thread id incorrectly for MySQL 5.5",
);

# #############################################################################
# Done.
# #############################################################################
exit;