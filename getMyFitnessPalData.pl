#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use WWW::Mechanize;

# script to retrieve MyFitnessPal Data from the website
# will need to login, or have cookies
# 20160317: fixed login and retrieval procedures - dob
# 20170114: got the password out of this file!
my $credentials = `cat ../health_data/credentials.txt | grep mfp`;
chomp $credentials;
my ($service, $username, $password) = split(":", $credentials);
my $siteurl = "https://www.myfitnesspal.com";
my $realm = "MyFitnessPal";
my $loginurl = "$siteurl/account/login";
my $reporturl = "$siteurl/reports/printable_diary/$username";
#\?from=$startdate\&to=$enddate";
my $verbose = 1;
my $getall = 0;

my $agent =  WWW::Mechanize->new( autocheck => 1);
#$agent->get($loginurl);
$agent->credentials($siteurl, $realm, $username, $password);

# Go get the login URL
print "Open the Login Page...\n";
$agent -> get($loginurl);
if ($agent->success) {
    #my @forms = $agent->forms() if $verbose;
    #printall(@forms) if $verbose;
    my @submits = $agent->find_all_submits();
    $agent -> form_id("fancy_login");
    #printall(@submits) if $verbose;
    $agent->set_fields (
        username => $username,
        password => $password);
    #$agent->tick('remember_me', undef, 'true');

    $agent->submit(input => $submits[0]);

}

# Get the  current time - faster than running `date`
my ($sec,$min,$hour,$mday,$tmon,$tyear,$wday,$yday,$isdst) =  localtime(time);
if ( $getall) {
    my $start_year = 2014 ; # normally just do the current month
    my $end_year = $tyear + 1900;
    # reporting on the whole year doesn't work anymore
    # go to monthly reporting
    for my $year ($start_year..$end_year) {
        for my $month (qw/01 02 03 04 05 06 07 08 09 10 11 12/) {
            print "Month: $year-$month\n";
            my $startdate = "$year-$month-01";
            my $lastday = last_day_of_month($year, $month);
            my $enddate = "$year-$month-$lastday";
            my $outfile = "../health_data/myFitnessPal_data/mfp_report_$year$month";
            get_printable_report($agent, $reporturl, $startdate, $enddate, $outfile);
        }
    }
} else {
    my $this_year = $tyear + 1900;
    my $this_month = sprintf("%02d", $tmon + 1);
    
    print "Month: $this_year-$this_month\n";
    my $startdate = "$this_year-$this_month-01";
    my $lastday = last_day_of_month($this_year, $this_month);
    my $enddate = "$this_year-$this_month-$lastday";
    my $outfile = "../health_data/myFitnessPal_data/mfp_report_$this_year$this_month";
    get_printable_report($agent, $reporturl, $startdate, $enddate, $outfile);
}

sub last_day_of_month {
    # Return the last day of the month
    my $year  = shift;
    my $month = shift;
    my @months   = qw/01 02 03 04 05 06 07 08 09 10 11 12/;
    my @lastdays = qw/31 28 31 30 31 30 31 31 30 31 30 31/;
    if ( is_leap_year($year) ) {
        $lastdays[1] = 29;
    }
    my %lastdayofmonth;
    @lastdayofmonth{@months} = @lastdays;
    my $lastday = $lastdayofmonth{$month};
    return $lastday;
}

sub is_leap_year {
    # return 1 for leap year, 0 otherwise
    my $year = shift;
    
    my $leapyear = 0;
    if ( $year %   4 == 0) {$leapyear = 1;}
    if ( $year % 100 == 0) {$leapyear = 0;}
    if ( $year % 400 == 0) {$leapyear = 1;}
    
    return $leapyear;
}

sub get_printable_report {# Go get the report URL
    my $agent = shift;
    my $reporturl = shift;
    my $startdate = shift;
    my $enddate = shift;
    my $outfile = shift;
    print "\tGo to the report URL: $reporturl\n";
    $agent->get($reporturl);
    if ($agent->success) {
        #my @forms = $agent->forms();
        #printall(@forms) if $verbose;
        my @submits = $agent->find_all_submits();
        #printall (@submits) if $verbose;
        $agent->set_fields (
            from => $startdate,
            to => $enddate
        );
        #$agent->tick('show_exercise_notes', undef, 'false');
        #$agent->tick('show_exercise_diary', undef, 'false');
        #$agent->tick('show_food_notes', undef, 'false');
        #$agent->tick('show_food_diary', undef, 'false');
        #$agent->tick('Food Diary', undef, 'false');
        $agent->submit() or die "Can't Open $!";
        print "\tSubmitted changes\n";
        #my @forms = $agent->forms();
        #printall(@forms);
        open (my $fh, ">", "$outfile.html");
        print $fh $agent->content();
        close $outfile;
        # Using wkhtmltopdf on OS X produces PDF files with spacing issues.
        # This doesn't appear to happen under Linux.
        # 20170114 added the --quiet option to tidy up the output
        #my $options ="--disable-javascript --disable-local-file-access --quiet ";
        #$options .= " --orientation portrait --print-media-type";
        #my $result = `wkhtmltopdf $options $outfile.html $outfile.pdf 2>log.out`;
        ## Add -table: adds extra white space and makes sure that things stay on a line if they should
        #$result = `pdftotext -layout -table $outfile.pdf $outfile.txt`;
        # Try using Lynx
        my $result = `lynx -dump -width 512 $outfile.html > $outfile.txt`;
        print "\tSaved file: $outfile.txt\n";
    }
}
sub printall {
    # sub to print all of an array
    while (my $entry = shift) {
        print "$entry\n";
        print Dumper($entry);
    }
    return 1;
}
sub timestamp {
    # sub to convert a date (yyyy-mm-dd) to timestamp (yyyymmdd)
    my $date = shift;
    $date =~ s/-//g;
    return $date;
}
