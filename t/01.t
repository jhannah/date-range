#!/usr/bin/perl -w

use strict;
use Test::More tests => 57;
use Date::Simple;
use Date::Range;

my $date1 = Date::Simple->new(2000,12,31);
my $date2 = $date1->next;
my $date3 = $date2->next;

eval { my $range = Date::Range->new() };
ok($@, "Can't create a range with no dates");

eval { my $range = Date::Range->new($date1) };
ok($@, "Can't create a range with one date");

eval { my $range = Date::Range->new($date1, $date2, $date3) };
ok($@, "Can't create a range with three dates");

eval { my $range = Date::Range->new("2001-01-01", "2001-02-02") };
ok($@, "Can't create a range with strings");

{
  ok(my $range = Date::Range->new($date1, $date1), "Create an single day range");
  is($range->start, $range->end, "Start and end on same date");
  is($range->length, 1, "1 day long");
  is($range->dates, 1, "So 1 date in 'dates'");
}

ok(my $range1 = Date::Range->new($date1, $date2), "Create a range");
is($range1->start, $date1, "Starts OK");
is($range1->end, $date2, "Starts OK");
is($range1->length, 2, "2 days long");
my @dates = $range1->dates;
is(@dates, 2, "So 2 date in 'dates'");
is($dates[0], $range1->start, "Starts at start");
is($dates[1], $range1->end, "And ends at end");

ok(my $range2 = Date::Range->new($date2, $date1), "Create a range in wrong order");
is($range2->start, $date1, "Starts OK");
is($range2->end, $date2, "Starts OK");
is($range2->length, 2, "1 days long");
ok($range1->equals($range2), "Range 1 and 2 are equal");

ok(my $range3 = Date::Range->new($date1, $date3), "Longer Range");
is($range3->length, 3, "3 days long");

ok(!$range3->includes($date1 - 1), "Range doesn't include early day");
ok($range3->includes($date1), "Range includes first day");
ok($range3->includes($date2), "Range includes middle day");
ok($range3->includes($date3), "Range includes last day");
ok(!$range3->includes($date3 + 1), "Range doesn't includes later day");
ok($range3->includes($range1), "Range includes first range");
ok($range3->includes($range2), "Range includes second range");
ok($range3->includes($range3), "Range includes itself");

#-------------------------------------------------------------------------
# Test overlaps
#-------------------------------------------------------------------------

{ 
  my $range = Date::Range->new($date3, $date2);
  ok($range->overlaps($range1), "The ranges overlap the other way");
  ok(my $overlap = $range->overlap($range1), "Get that overlap");
  is($overlap->start, $date2, "Starts on day2");
  is($overlap->end, $date2, "Ends on day2");
}

{ 
  my $range = Date::Range->new($date2, $date3);
  ok($range->overlaps($range3), "The ranges overlap");
  ok(my $overlap = $range->overlap($range3), "Get that overlap");
  is($overlap->start, $date2, "Starts on day2");
  is($overlap->end, $date3, "Ends on day3");
}

{ # ranges overlap
	my $planrange = Date::Range->new(map Date::Simple->new($_), '2003-03-08', '2003-07-15');
	my $billrange = Date::Range->new(map Date::Simple->new($_), '2003-03-21', '2003-04-20');

	ok $billrange->overlaps($planrange), "Overlaps one way";
	ok $planrange->overlaps($billrange), "and the other...";
}

#-------------------------------------------------------------------------
# Test Gap / abuts
#-------------------------------------------------------------------------

{

	my $jan = Date::Range->new(
		map Date::Simple->new($_), '2004-01-01', '2004-01-31'
	);

	my $mar = Date::Range->new(
		map Date::Simple->new($_), '2004-03-01', '2004-03-31'
	);

	my $feb = $jan->gap($mar) or die "Can't get gap";
	isa_ok $feb => 'Date::Range';
	is $feb->start, "2004-02-01", "Starts start Feb";
	is $feb->end, "2004-02-29", "Ends end Feb";

	my $feb2 = $mar->gap($jan);
	ok $feb2->equals($feb), "Gap works either way around";

	my $fj = $jan->gap($feb);
	ok !$jan->gap($feb), "Jan has no gap to Feb";
	ok !$feb->gap($mar), "Feb has no gap to Mar";

	ok !$jan->abuts($jan), "Abuts J/J - no";
	ok $jan->abuts($feb), "Abuts J/F - yes";
	ok !$jan->abuts($mar), "Abuts J/M - no";

	ok $feb->abuts($jan), "Abuts F/J - yes";
	ok !$feb->abuts($feb), "Abuts F/F - no";
	ok $feb->abuts($mar), "Abuts F/M - yes";

	ok !$mar->abuts($jan), "Abuts M/J - no";
	ok $mar->abuts($feb), "Abuts M/F - yes";
	ok !$mar->abuts($mar), "Abuts M/M - no";


	my $r1 = Date::Range->new(
		map Date::Simple->new($_), '2010-08-19', '2010-08-21'
	);
	my $r2 = Date::Range->new(
		map Date::Simple->new($_), '2010-08-23', '2010-08-24'
	);
        # gap bug
        ok(my $r3 = $r1->gap($r2),   "gap()");
        # leads to abuts bug
        ok !$r1->abuts($r2),         "Abuts r1/r2 - no";
}



