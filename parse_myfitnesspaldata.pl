#!/usr/bin/perl
use strict;
use warnings;

# script to parse the myfitnesspal pdf output (converted to txt)
# 20151229 - dave o'brien
my $verbose = 1;

my (@files) = `ls mfp_report*.txt`;
foreach my $file (@files) {
    chomp $file;
    open (my $infh, "<", $file) or die "Can't open $file\n";
    my $date = "";
    my $category = "";
    my $meal = "";
    my $exercise = "";
    while (my $line = <$infh>) {
        chomp $line;
        print "LINE: |$line|\n" if $verbose;
        $line =~ s/[\xa0\xc2\s]/ /g; # gets rid of &nbsp; UTF-8 entities
        #print "$line\n" if $verbose;
        # first, get the date
        if ( $line =~ /[ \t]+([A-Za-z]+)[ \t]+([0-9]+),[ \t]+([0-9]+)/) {
            my $month = $1;
            my $day = $2;
            my $year = $3;
            # get a properly formatted Date object?
            $date = "$day $month $year";
            print "DAY: $date\n" if $verbose;
        }
        # Get the Category
        if ( $line =~ /^([A-Z]+)\s+(.*)/) {
            $category = $1;
            my $data = $2;
            my @data = split '\s+', $data;
            print "CATEGORY: $category\tDATA: @data\n" if $verbose;
        }
        # Next, get the Sub Category (Meals, types of exercise)
        if ( $line =~ /^([A-Z][a-z]+)$/) {
            my $item = $1;
            print "SubCat: $category.$item " if $verbose;
            if ( "$category" eq "FOODS") {
                $meal = $item;
                print "MEAL: $meal\n" if $verbose;
            }
            if ( "$category" eq "EXERCISES") {
                $exercise = $item;
                print "EXER: $exercise\n" if $verbose;
            }
        }
        # Now, get the individual foods and nutrition
        #Burger Edge ­ the Original Edge, 336 g                              573       69g    18g      30g       0mg    2,340mg          9g      0g
        if ( $line =~ /^\s+(.*)            ([0-9 gm,]+)$/ ) {
            my $food = $1;
            my $data = $2;
            $food = trim($food);
            my @data = split '\s+', $data;
            print "FOOD: $food: @data\n" if $verbose;
        }
        if ( $line =~ /TOTAL:\s+([0-9 gm,]+)$/ ) {
            my $data = $1;
            my @data = split '\s+', $data;
            print "FOOD_TOTAL: $date: @data\n" if $verbose;
        }
        # Get the Exercise Totals
        #

        #sleep 1;
    }
}

## Subs
sub trim {
    # trim leading and trailing spaces
    my $string = shift;
    $string =~ s/^\s+//g;
    $string =~ s/\s+$//g;
    return $string;
}
