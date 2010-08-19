package Date::RangeSet;

=head1 NAME

Date::RangeSet - Merge Date::Range objects down to as few as possible

=head1 SYNOPSIS

  use Date::RangeSet;

  my $rangeset = Date::RangeSet->new();

  $rangeset->add($range1);
  $rangeset->add($range2);
  $rangeset->add($range3);

  foreach my $range ($rangeset->all) {
     printf("%s through %s\n", $range->start, $range->end);
  }

=head1 DESCRIPTION

Date::RangeSet is convenient for merging many Date::Range objects,
each of which may or may not overlap with other Date::Range objects, 
into the simplest possible set of Date::Range objects.

If you add 100 Date::Range objects that all overlap, then all() returns
just a single Date::Range object spanning all the dates. If your ranges
partially overlap, all() may return you 10 Date::Range objects. If your
input ranges don't overlap at all then all() returns the 100 original 
Date::Range objects, unmodified. 

=cut

use strict;
use Carp;


=head1 METHODS

=head2 new()

  my $rangeset = Date::RangeSet->new();

=cut

sub new {
  my $that = shift;
  my $class = ref($that) || $that;
  my $self = bless {
    _ranges => [ ],
  }, $class;
  return $self;
}

=head2 add

  $rangeset->add($range1);

Add a Date::Range object. If all the dates in $range1 are already represented by ranges
in $rangeset, then add() does nothing ($range1 is redundant). If $range1 overlaps with
known ranges in $rangeset then those ranges are expanded to also include the dates in 
$range1. If $range1 does not overlap with any ranges in $rangeset, then it is simply 
added to the set for possible later merger with future calls to add().

=cut

sub add {
   my ($self, $new_range) = @_;
   unless ($new_range && ref($new_range) eq "Date::Range") {
      die "You can only add() a Date::Range object";
   }
  
   my $added;
   my @new_ranges;
   if (@{$self->{_ranges}}) {
      foreach my $range (@{$self->{_ranges}}) {
         #print join "|", $new_range->start, $new_range->end, $range->start, $range->end;
         #print "\n";
         if ($range->overlaps($new_range) || $range->abuts($new_range)) {
            #print "overlap or abut!\n";
            # Whack the one we overlap with
            @new_ranges = grep { $_ ne $range && $_ ne $new_range } @new_ranges;
            # Add the new range (both combined)
            my @dates = sort { $a <=> $b } $range->start, $range->end,
                                           $new_range->start, $new_range->end;
            my $r = Date::Range->new(@dates[0,3]);
            $new_range = $r;
            $added = 1;
            push @new_ranges, $r;
         } else {
            #print "Not a match. Keep\n";
            push @new_ranges, $range;
         }
      }
   } else { 
      # First range. 
      #print "first range!\n";
      $added = 1;
      push @new_ranges, $new_range;
   }
   unless ($added) {
      #print "No matches. Add it.\n";
      push @new_ranges, $new_range;
   }
   $self->{_ranges} = [ @new_ranges ];
}

=head2 all

  $rangeset->all();

Returns all Date::Range objects.

=cut

sub all {
   my ($self) = @_;
   return @{$self->{_ranges}};
}

1;


