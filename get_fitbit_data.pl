#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use WWW::Mechanize;
use feature qw {say};

# script to retrieve Fitbit Historic from the website
say "Starting...";
## Lessons learned: I had a username instead of an email address, and the
# password was an old one.  Special Snowflake login problems solved
# by supplying the right credentials!
my $credentials = `cat ../health_data/credentials.txt | grep fitbit`;
chomp $credentials;
my ($service,$username, $password) = split(":", $credentials);
my $datadir="..health_data/fitbit_data/";
my $outfile = "$datadir/fitbit_export.html";
#https://www.fitbit.com/export/user/data

# 
my $siteurl = "https://www.fitbit.com";
my $realm = "fitbit";
my $loginurl = "$siteurl/login";
my $startdate = "2013-10-01";
my $enddate = "2016-03-31";
my $reporturl = "$siteurl/export/user/data";

say "create an instance...";
my $agent =  WWW::Mechanize->new( autocheck => 1, agent=> 'Mozilla/5.0 (compatible)' );
$agent->max_redirect(300);
$agent->default_header(
  "Connection" => "keep-alive",
  "Keep-Alive" => "300");

#$agent->get($loginurl);
#$agent->credentials($siteurl, $realm, $username, $password);


open (my $fh, ">", $outfile);
# login and get our cookie
say "Go to the Login URL: $loginurl ...";
$agent -> get($loginurl);
if ($agent->success) {
    #printall ($agent->forms());
    #printall ($agent->find_all_links());
    say "find all submits";
    my @submits = $agent->find_all_submits();
    printall (@submits); # only one, so can just invoke it by object
    say "Submit the login...";
    $agent->form_id('loginForm');
    $agent->set_fields(
        email => $username,
        password => $password #,
    );
    $agent->tick('rememberMe', 'true', 'true');
    my $result = $agent->click_button( input => $submits[0]);
    if ($agent->success) {
        say "login Success!";
    }
} else {
    print "login failed\n";
}

say "Go to the report URL: $reporturl ...";
$agent -> get($reporturl);
if ($agent->success) {
    #print $fh $agent->content();
    #printall ($agent->forms());

    $agent->form_id('dataExportForm');
    $agent->tick('dataExportType', 'BODY', 'true');
    $agent->tick('dataExportType', 'FOODS', 'true');
    $agent->tick('dataExportType', 'ACTIVITIES', 'true');
    $agent->tick('dataExportType', 'SLEEP', 'true');
    $agent->set_visible(['dataPeriod.periodType' => 'CUSTOM']);
    $agent->field('startDate', '2013-10-01');
    $agent->field('endDate', '2013-10-31');
    my @submits = $agent->find_all_submits();
    #printall (@submits);
    printall($agent->links());
    $agent->submit( id => 'download_button');
    # go to the data export and start dumping out months
    # Where is the link to the download?  It all seems to be handled by the javascript
    # quicker to just download each month manually!
    print $fh $agent->content();
}

#close $outfile;


sub printall {
    # sub to print all of an array
    while (my $entry = shift) {
        print "$entry\n";
        print Dumper($entry);
    }
    return 1;
}
