#!/usr/bin/perl -w

use strict;
use Test::More tests => 45;
use Date::Simple;
use Date::Range;
use Date::RangeSet;

ok(my $rs = Date::RangeSet->new(),               "new()");

eval { $rs->add() };
ok($@, "Can't add() nothing");

eval { $rs->add('2010-08-19') };
ok($@, "Can't add() a string");

# First, the simplest possible merger.
my $date1 = Date::Simple->new(2010,8,19);
my $date2 = $date1->next;
my $date3 = $date2->next;
my $range1 = Date::Range->new($date1, $date2);
my $range2 = Date::Range->new($date2, $date3);
ok($rs->add($range1),                           "add()");
ok($rs->add($range2),                           "add()");
ok(my @result = $rs->all(),                     "all()");
is(@result, 1,                                  "merged into 1");
is($result[0]->start, "2010-08-19",             "0 start");
is($result[0]->end,   "2010-08-21",             "0 end");

# Now let's add one that should stay separate.
$range1 = Date::Range->new(Date::Simple->new(2010,8,24), Date::Simple->new(2010,8,26));
ok($rs->add($range1),                           "add()");
ok(@result = $rs->all(),                        "all()");
is(@result, 2,                                  "2 separate ones now");
is($result[0]->start, "2010-08-19",             "0 start");
is($result[0]->end,   "2010-08-21",             "0 end");
is($result[1]->start, "2010-08-24",             "1 start");
is($result[1]->end,   "2010-08-26",             "1 end");

# Now let's add one that should merge and join the one we added above, all into a single range
$range1 = Date::Range->new(Date::Simple->new(2010,8,22), Date::Simple->new(2010,8,23));
ok($rs->add($range1),                           "add()");
ok(@result = $rs->all(),                        "all()");
is(@result, 1,                                  "all merged into 1");
is($result[0]->start, "2010-08-19",             "0 start");
is($result[0]->end,   "2010-08-26",             "0 end");

# Let's try this scenario:
# XX
#     XX
#   X
#  XXXX
$rs = Date::RangeSet->new();
$range1 = Date::Range->new(Date::Simple->new(2010,8,19), Date::Simple->new(2010,8,20));
ok($rs->add($range1),                           "add()");
ok(@result = $rs->all(),                        "all()");
is(@result, 1,                                  "first 1");
is($result[0]->start, "2010-08-19",             "0 start");
is($result[0]->end,   "2010-08-20",             "0 end");
$range1 = Date::Range->new(Date::Simple->new(2010,8,23), Date::Simple->new(2010,8,24));
ok($rs->add($range1),                           "add()");
ok(@result = $rs->all(),                        "all()");
is(@result, 2,                                  "now 2");
is($result[0]->start, "2010-08-19",             "0 start");
is($result[0]->end,   "2010-08-20",             "0 end");
is($result[1]->start, "2010-08-23",             "1 start");
is($result[1]->end,   "2010-08-24",             "1 end");
$range1 = Date::Range->new(Date::Simple->new(2010,8,21), Date::Simple->new(2010,8,21));
ok($rs->add($range1),                           "add()");
ok(@result = $rs->all(),                        "all()");
is(@result, 2,                                  "still 2");
is($result[0]->start, "2010-08-19",             "0 start");
is($result[0]->end,   "2010-08-21",             "0 end");
is($result[1]->start, "2010-08-23",             "1 start");
is($result[1]->end,   "2010-08-24",             "1 end");
$range1 = Date::Range->new(Date::Simple->new(2010,8,20), Date::Simple->new(2010,8,23));
ok($rs->add($range1),                           "add()");
ok(@result = $rs->all(),                        "all()");
is(@result, 1,                                  "merged all into 1");
is($result[0]->start, "2010-08-19",             "0 start");
is($result[0]->end,   "2010-08-24",             "0 end");


