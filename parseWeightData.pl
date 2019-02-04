#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

my $verbose = 1;
my $inputFile = "../health_data/misc_data/weightData.dat";

# read in the input file
# make a table of weights/calories per day
open (my $inputfh, "<", $inputFile);
my @data; # start array of arrays
while (my $line = <$inputfh>) {
    chomp $line;
    $line =~ s/,//g;
    if ( !($line =~ /^#.*$/)) {
        my @parts = split /;/, $line;
        my $datum = weightData->new(@parts);
        push @data, $datum;
        # just check we're doing the right thing:
        #print "#Date   Calories    Carbs   Fat Protein Cholest Sodium  Sugars  Fiber   Exercise    BMR TDEE    MFPTarget   Cals/TDEE   .Wt Average DyWeight\n" if $verbose;
        #print "@parts\n" if $verbose;
        #print Dumper($datum) if $verbose;
        print "$datum->{date} - $datum->{calories} calories, $datum->{dyweight} kg\n" if $verbose;
    }
}
close $inputfh;
#exit;
# we have some models:
# - Weight day n = (a.Cin[n-1] - Cout[n-1]) / (kcal/kg) ## i.e. uncertainty in Cin
my $alpha1 = &calculate_alpha(1.00);
# - Weight day n = (Cin[n-1] - a.Cout[n-1]) / (kcal/kg) ## i.e. uncertainty in COut
my $alpha2 = &calculate_alpha(2.00);

#$error = &process_weight_data($alpha1, $model, 1, @data);
print "Result - Model 1: " . sprintf("%.5f", $alpha1) . "\n" if $verbose;
print "Result - Model 2: " . sprintf("%.5f", $alpha2) . "\n" if $verbose;


sub calculate_alpha {
    # given a factor, calculate the sqrt(error^2) total
    my $model = shift;
    my $alpha = 1.000;
    my $delta = 0.500;
    my $error = 0;
    my $notfinished = 1;
    while ($notfinished) {
        print "Testing ". sprintf("%.4f", ($alpha )) . " +/- ". sprintf("%.4f", ($delta )) . ":";
        my $lobound = &process_weight_data(($alpha - $delta), $model, 0, @data);
        print " low: ". sprintf("%.4f", ($alpha - $delta)) . "(" . sprintf("%.2f", $lobound) . ")";
        $error = &process_weight_data($alpha, $model, 0, @data);
        print " mid: ". sprintf("%.4f", ($alpha )) . "(" . sprintf("%.2f", $error) . ")";
        my $hibound = &process_weight_data(($alpha + $delta), $model, 0, @data);
        print " hi: ". sprintf("%.4f", ($alpha + $delta)) . "(" . sprintf("%.2f", $hibound) . ")";
        print "\n";
        # find the lowest of the three and set the new alpha to that, then shrink the delta range
        if ( $error > $hibound) { $alpha += $delta;}
        if ( $error > $lobound) { $alpha -= $delta;}
        $delta = $delta/2;
        if ($delta < 0.0001) {$notfinished = 0;}
        #print "Result: $alpha, $delta, $lobound, $error, $hibound\n" if $verbose;
    }
    return $alpha;
}

## subs
sub process_weight_data  {
    # sub to do to hard work
    my ($alpha, $model, $verbose, @data) = @_;
    my $sumerror = 0;
    my $startday = 0;
    my $kcalPerkg = 7700; # kCal per kg
    my $weightn = $data[$startday]->{dyweight};
    while ($weightn eq "#N/A") {
        $startday += 1;
        $weightn = $data[$startday]->{dyweight};
    }
    print "Starting Weight: $weightn\n" if $verbose;
    foreach my $day ($startday..$#data) {
        print "day $day: " . sprintf("%6.2f", $weightn) . " kg " if $verbose;
        # yesterdays calories...
        my $cals_in = eval($data[$day-1]->{calories}); # MFP cals in
        my $cals_out = eval($data[$day-1]->{fitbitcals}) ; # fitbit data only
        my $dWeight = 0;
        if ( $model == 1.0 ) { $dWeight = ($alpha * $cals_in - $cals_out) / $kcalPerkg};
        if ( $model == 2.0 ) { $dWeight = ($cals_in - $alpha * $cals_out) / $kcalPerkg};
        if ( $model == 3.0 ) { $dWeight = $alpha * ($cals_in - $cals_out) / $kcalPerkg};
        $weightn += $dWeight;
        print "Cin $cals_in, vs Cout $cals_out = dW " . sprintf("%5.2f", $dWeight) . " -> " . sprintf("%.2f", $weightn) if $verbose;
        my $error = 0;
        if ($data[$day]->{dyweight} ne "#N/A") {
            my $obsweight = eval($data[$day]->{dyweight});
            $error = ($obsweight - $weightn)**2;
            print " Obs: $obsweight Error: " . sprintf("%.2f", $error) . "\n" if $verbose;
        } else {
            print " Obs: no observation\n" if $verbose;
        }
        $sumerror += $error;
    }
    my $sqrterror = sqrt($sumerror);
    return $sqrterror;
}
# Objects
package weightData;
sub new {
    my $class = shift;
    my $self = {
        date => shift,
        calories => shift,
        carbs => shift,
        fat => shift,
        protein => shift,
        cholest => shift,
        sodium => shift,
        sugars => shift,
        fiber => shift,
        fitbitextcals => shift,
        fitbitcals => shift,
        fitbitbmr => shift,
        overage => shift,
        cico_3days => shift,
        calD_7days => shift,
        carbs_7days => shift,
        weight_7days => shift,
        availwt => shift,
        maybewt => shift,
        dyweight => shift
    };
    if ($self->{dyweight} eq "#DIV/0!") { $self->{dyweight} = "#N/A";}
    bless $self, $class;
    return $self;
}
