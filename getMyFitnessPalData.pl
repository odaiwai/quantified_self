#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use WWW::Mechanize;

# script to retriever MyFitnessPal Data from the website
# will need to login, or have cookies
my $username = "odaiwai";
my $password = "wurble99";
my $siteurl = "https://www.myfitnesspal.com";
my $realm = "MyFitnessPal";
my $loginurl = "$siteurl/account/login";
my $startdate = "2014-08-01";
my $enddate = "2014-12-20";
my $reporturl = "$siteurl/reports/printable_diary/$username\?from=$startdate\&to=$enddate";

my $mech =  WWW::Mechanize->new( autocheck => 1);
#$mech->get($loginurl);
$mech->credentials($siteurl, $realm, $username, $password);


$mech -> get($loginurl); 
my $forms = $mech -> form_id("fancy_login");
$mech -> field ('username' => $username);
$mech -> field ('password' => $password);
$mech -> submit();
$mech -> get($reporturl); 
print $mech->content();
