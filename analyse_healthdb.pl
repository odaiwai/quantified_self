#!/usr/bin/env perl
use strict;
use warnings;
use DBI;
use Data::Dumper;

# my own library                                                                     
use lib "/Users/odaiwai/src/dob_DBHelper";                                            
use DBHelper;
 
# script to analyse the healthdb
# 20191103 - dave o'brien
my $verbose = 1;
my $firstrun = 1;
# script to parse the fitbit_export file and make a database
my $db = DBI->connect("dbi:SQLite:dbname=health_data.sqlite","","") or die DBI::errstr;

# TODO
#   Get a list of all the tables in the database
#   count the number of rows per table
#   count the number of columns per table
#   Potentially vacuum each table individually
my %table_sizes;
for my $table (array_from_query($db, "Select name from [sqlite_master] where type = 'table';", $verbose)) {
    print "$table:\n" if $verbose;
    my @schema = row_from_query($db, "select sql from [sqlite_master] where name = '$table'", $verbose);
    print "\t$schema[0]\n" if $verbose;
    my @rows = row_from_query($db, "Select count(*) from [$table];", $verbose);
    print "\tRows: $rows[0]\n" if $verbose;
    $table_sizes{$table} = $rows[0];
    #my $result = dbdo($db, "VACUUM [$table] INTO 'healthdb2.sqlite';", $verbose);
    #print "\t$result\n" if $verbose;
    
}

for my $table (sort {$table_sizes{$a} <=> $table_sizes{$b}} keys %table_sizes) {
    print "\t$table: $table_sizes{$table}\n";
}

$db->disconnect;

## subs
sub trim {
    # trim leading and trailing spaces
    my $string = shift;
    $string =~ s/^\s+//g;
    $string =~ s/\s+$//g;
    return $string;
}

sub display_as_hex {
    # display a string as a hexdump'
    my $string = shift;
}

## subroutines
