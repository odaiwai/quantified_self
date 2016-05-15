#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use WWW::Mechanize;

# script to retrieve MyFitnessPal Data from the website
# will need to login, or have cookies
# 20160317: fixed login and retrieval procedures - dob
my $username = "odaiwai";
my $password = "wurble99";
my $siteurl = "https://www.myfitnesspal.com";
my $realm = "MyFitnessPal";
my $loginurl = "$siteurl/account/login";
my $reporturl = "$siteurl/reports/printable_diary/$username";
#\?from=$startdate\&to=$enddate";

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
my $start_year = 2016;
my $end_year = `date +%Y`;
for my $year ($start_year..$end_year) {
    print "Year: $year\n";
    my $startdate = "$year-01-01";
    my $enddate = "$year-12-31";
    my $outfile = "myFitnessPal_data/mfp_report_$year";
    get_printable_report($agent, $reporturl, $startdate, $enddate, $outfile);
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
        #my @submits = $agent->find_all_submits();
        #printall (@submits) if $verbose;
        $agent->set_fields (
            from => $startdate,
            to => $enddate
        );
        #$agent->tick('show exercise notes', undef, 'true');
        #$agent->tick('show exercise diary', undef, 'true');
        $agent->submit();
        print "\tSubmitted changes\n";
        #my @forms = $agent->forms();
        #printall(@forms);
        open (my $fh, ">", "$outfile.html");
        print $fh $agent->content();
        close $outfile;
        my $result = `wkhtmltopdf --disable-javascript --disable-local-file-access $outfile.html $outfile.pdf`;
        $result = `pdftotext -layout $outfile.pdf`;
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
