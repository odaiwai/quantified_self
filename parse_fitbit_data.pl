#!/usr/bin/env perl
use strict;
use warnings;
use DBI;
use Data::Dumper;

my $verbose = 0;
my $firstrun = 1;
my $basedir = ".";
my $filename;
my $system = `uname`;
chomp $system;
if ($system eq "Darwin") {
    $filename = "/Users/odaiwai/Dropbox/ifttt/Fitbit/fitbit_data.txt";
} elsif ($system eq "Linux") {
    $filename = "/home/odaiwai/Dropbox/ifttt/Fitbit/fitbit_data.txt";
} else {
    die "What system is this? |$system|\n";
}
my $outfilename = "../health_data/fitbit_data/fitbit_data.csv";
# script to parse the fitbit_export file and make a database
my $db = DBI->connect("dbi:SQLite:dbname=health_data.sqlite","","") or die DBI::errstr;

if ($firstrun) {
    my $result = make_db();
}



$db->disconnect;

## subroutines
sub make_db {
    print "making the database: $db\n" if $verbose;
    drop_all_tables($db, "fitbit_data");
    build_tables_from_file($db, "$filename", "$outfilename");
}
sub drop_all_tables {
    # get a list of table names from $db and drop them all
    my $db = shift;
    my $prefix = shift;
    print "Clearing the database because \$firstrun == $firstrun\n";
    my @tables;
    my $query = querydb($db, "select name from sqlite_master where type='table' and name like '$prefix%' order by name", 1);
    # we need to extract the list of tables first - sqlite doesn't like
    # multiple queries at the same time.
    while (my @row = $query->fetchrow_array) {
        push @tables, $row[0];
    }
    dbdo ($db, "BEGIN", 1);
    foreach my $table (@tables) {
        dbdo ($db, "DROP TABLE if Exists [$table]", 1);
    }
    dbdo ($db, "COMMIT", 1);
    return 1;
}
sub build_tables_from_file {
    my $db = shift;
    my $filename = shift;
    my $outfilename = shift;
    print "Processing $filename...\n";
    open (my $fh, "<", "$filename") or die "Can't open $filename\n";
    open (my $outfh, ">", "$outfilename") or die "Can't open $outfilename\n";
    # The data is of the form:
    # Date: January 4, 2015;Total steps: 14028;Floors climbed: ; Calories burned: 2947; Elevation gained: ,meters; Traveled: 8.42, kilometers; Sedentary minutes: 1015; Lightly active minutes: 237; Fairly active minutes: 150; Very active minutes: 38;
    my $tablename = "fitbit_data";
    my $tabledef = "timestamp INTEGER PRIMARY KEY, Date TEXT, Total_steps INTEGER, Floors_climbed INTEGER";
    $tabledef .= ", Calories_burned INTEGER";
    $tabledef .= ", Elevation_gained INTEGER, Traveled REAL";
    $tabledef .= ", Sedentary INTEGER, Lightly_active INTEGER";
    $tabledef .= ", Fairly_active INTEGER, Very_active INTEGER";
    my $command = "Create Table if not exists [$tablename] ($tabledef)";
    my $result = dbdo($db, $command, $verbose);
    dbdo($db, "BEGIN", $verbose); # wrap the inserts in a Begin//Commit
    my $numrecords = 0;
    # parse the file
    while (my $line = <$fh>) {
        chomp $line;
        #print "\tLINE:\"$line\"\n" if $verbose;
        $line =~ s/; $//;
        my @data = split ";", $line;
        my $keys = "timestamp, ";
        my $tableheader = "";
        my $valueline = "";
        my $values;
        if ($#data>0) {
            foreach my $kvpair (@data) {
                my ($key, $value) = split ":", $kvpair;
                my $clean_key = normalise_key($key);
                my $clean_value = normalise_value($value);
                $keys .= "$clean_key, ";
                $tableheader .= "$clean_key;";
                if ($clean_key eq "Date") {
                    my $timestamp = timestamp_from_date($clean_value);
                    $values .= "$timestamp, \"$clean_value\", ";
                } else {
                    $values .= "$clean_value, ";
                }
                $valueline .="$clean_value;";
            }
            #print "\tKEYS:$keys\n" if $verbose;
            #print "\tVALUES:$values\n" if $verbose;
            $keys =~ s/, $//;
            $values =~ s/, $//;
            $tableheader =~ s/;$//;
            $valueline =~ s/;$//;
            $command = "Insert or Replace into [$tablename] ($keys) Values ($values)";
            print "\t$command\n" if $verbose;
            print $outfh "$tableheader\n" if ($numrecords == 0);
            print $outfh "$valueline\n";
            my $result = dbdo($db, $command, $verbose);
            if ($result) { $numrecords++;}
        }
    }
    dbdo($db, "COMMIT", $verbose); # wrap the inserts in a Begin//Commit
    close $fh;
    close $outfh;
}
sub normalise_value {
    my $input = shift;
    $input =~ s/, kilometers//;
    $input =~ s/ kilometers//;
    $input =~ s/,meters//;
    $input =~ s/ meters//;
    if ($input eq " ") {$input = 0;}
    return $input;
}

sub normalise_key {
    my $input = shift;
    $input =~ s/minutes//g;
    $input =~ s/ /_/g;
    $input =~ s/^_+//g;
    $input =~ s/_+$//g;
    $input =~ s/,//g;
    return $input;
}

sub dbdo {
    my $db = shift;
    my $command = shift;
    my $verbose = shift;
    if (length($command) > 1000000) {
        die "$command too long!";
    }
    print "\t$db: ".length($command)." $command\n" if $verbose;
    my $result = $db->do($command) or die $db->errstr . "\nwith: $command\n";
    return $result;
}
sub querydb {
    # prepare and execute a query
    my $db = shift;
    my $command = shift;
    my $verbose = shift;
    print "\tQUERYDB: $db: $command\n" if $verbose;
    my $query = $db->prepare($command) or die $db->errstr;
    $query->execute or die $query->errstr;
    return $query;
}
sub sanitise_line_for_input {
	#take a line like:
	# 80000009499,NOUSUALRESIDENCE,89999949999,8949999,899999499,89499,No usual address (ACT),89999,Special Purpose Codes SA3 (ACT),899,Special Purpose Codes SA4 (ACT),89499,No usual address (ACT),8,Australian Capital Territory
	#and Return:
	# 80000009499, \"NOUSUALRESIDENCE\",89999949999,8949999,899999499,89499,\"No usual address (ACT)\",89999,\Special Purpose Codes SA3 (ACT)\",899,\"Special Purpose Codes SA4 (ACT)\",89499,\"No usual address (ACT)\",8,\"Australian Capital Territory\"
	my $line = shift;
	my $cleanline;
	my $index = 0;
	#print "\t\t$line\n" if $verbose;
	$line =~ s/\"([0-9]+?),([0-9][0-9][0-9])\"/"$1$2"/g; # remove commas from thousands within quotes.
	#print "\t\t$line\n" if $verbose;
	$line =~ s/\"//g;
	#print "\t\t$line\n" if $verbose;
	my @fields = split /,/, $line;
	foreach my $field (@fields) {
		my $type = type_from_data($field);
		if ( $type eq "Text") {
			$cleanline .= "\"$field\"";
		} else {
			$cleanline .= "$field";
		}
		if ($index < $#fields) {
			$cleanline .= ",";
		}
		$index++;
	}
	#$cleanline =~ s/,$//;
	return $cleanline;
}
sub tabledef_from_headerline {
    # take the header line, and a data line and figure out the DB Structure
    my $headerline = shift;
    my $firstline = shift;
    my $values = sanitise_line_for_input($firstline);
    my @headers = split /,/, $headerline;
    my @first = split /,/, $values;
    my ($dbstructure, $fieldnames);
    foreach my $index (0..($#headers)) {
        # do we need to sanitise the header?
        my $header = $headers[$index];
        $header =~ s/ /_/g;
        $header =~ s/[()]+//g;
        my $field = $first[$index];
        # see what the content is to decide the type
        print "\t\t3.$index: $header: \"$field\" " if $verbose;
        my $type = type_from_data($field);
        print ": $type" if $verbose;
        print "\n" if $verbose;
        $dbstructure .= "$header $type";
        $fieldnames .= "$header";
        if ( $index == 0) { $dbstructure .= " Primary Key"; }
        if ( $index < $#headers ) { $dbstructure .= ", "; }
        if ( $index < $#headers ) { $fieldnames .= ", "; }
    }
    return ($dbstructure, $fieldnames);
}

sub type_from_data {
    # take a field and sample data and determine the type
    my $field = shift;
    my $type;
    my $has_text = 0;
    my $has_nums = 0;
    my $has_decs = 0;
    # the decision tree below is a little redundant, might change later
    if ( $field =~ /[A-Za-z()-]+/) { $has_text = 1; }
    if ( $field =~ /\//) { $has_text = 1;   }
    if ( $field =~ /\d+/) { $has_nums = 1;  }
    if ( $field =~ /\./) { $has_decs = 1; }
    if ( $has_text ) {
        $type = "Text";
    } elsif ( $has_decs ) {
        $type = "Real";
    } else {
        $type = "Integer";
    }
    return $type;
}
sub timestamp_from_date {
    # sub to return yyyymmdd from "January 15, 2015"
    my $date = shift;
    my ($month, $day, $year) = split " ", $date;
    $day =~ s/,//g;
    my %months=("January"=>"01", "February"=>"02", "March"=>"03", "April"=>"04",
                "May"=>"05", "June"=>"06", "July"=>"07", "August"=>"08",
                "September"=>"09", "October"=>"10", "November"=>"11",
                "December"=>"12");
    my $timestamp = "$year".$months{$month}.sprintf("%02d",$day);
    return $timestamp;
}
