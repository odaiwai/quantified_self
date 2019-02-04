#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use Data::Dumper;

# script to parse the myfitnesspal pdf output (converted to txt)
# 20151229 - dave o'brien
# 20160403 - combined the fitbit and MyFitnessPal data parsing to a single
#          file.
my $verbose = 1;
my $firstrun = 0;
# script to parse the fitbit_export file and make a database
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
my $outfilename = "./fitbit_data.csv";

my $db = DBI->connect("dbi:SQLite:dbname=fitness_data.sqlite","","") or die DBI::errstr;



if ($firstrun) {
    my $result = make_db();
} else {
	build_mfp_tables_from_files($db);
	build_fb_tables_from_file($db, "$filename", "$outfilename");
}

## TODO
# Need to calculate calories from Alcohol as well
# Need to calculate quantities of Caffeine/Alcohol
# Need to build data panels for statistical analysis

$db->disconnect;
## subs
sub build_mfp_tables_from_files {
    my $db = shift;
    my @files = (`ls ../health_data/myFitnessPal_data/mfp_report_????.txt`);
    foreach my $file (@files) {
        chomp $file;
        print "Processing file: $file\n";
        open (my $infh, "<", $file) or die "Can't open $file\n";
        my $date = "";
        my $category = "";
        my $meal = "";
        my $exercise = "";
        my $daily_item = 0;
        my $timestamp = "";
        my %meals;
        my %exercises;
        dbdo($db, "BEGIN", 1);
        my %months = ("January"=>1, "February"=>2, "March"=>3, "April"=>4, "May"=>5, "June"=>6, "July"=>7, "August"=>8, "September"=>9, "October"=>10, "November"=>11, "December"=>12);
        #print Dumper(%months);
        #exit;
        while (my $line = <$infh>) {
            chomp $line;
            #print "LINE: |$line|\n" if $verbose;
            $line =~ s/[\xa0\xc2\xad]/ /g; # gets rid of &nbsp; UTF-8 entities
            #print "$line\n" if $verbose;
            # first, get the date
            if ( $line =~ /[ \t]*([A-Za-z]+)[ \t]+([0-9]+),[ \t]+([0-9]+)/) {
                my $month = $1;
                my $day = $2;
                my $year = $3;
                # get a properly formatted Date object?
                my $mnum = $months{$month};
                $date = "$day $month $year";
                $timestamp = sprintf("%04d", $year).sprintf("%02d", $mnum).sprintf("%02d", $day);
                $daily_item = 0;
                #print "DAY: $date ($timestamp)\n" if $verbose;
            }
            # Get the Category
            if ( $line =~ /^([A-Z]+)\s+(.*)/) {
                $category = $1;
                my $data = $2;
                my @data = split '\s+', $data;
                #print "CATEGORY: $category\tDATA: @data\n" if $verbose;
            }
            # Next, get the Sub Category (Meals, types of exercise)
            if ( $line =~ /^([A-Z][a-z]+)$/) {
                my $item = $1;
                #print "SubCat: $category.$item " if $verbose;
                if ( "$category" eq "FOODS") {
                    $meal = $item;
                    $meals{$meal}++;
                    #print "MEAL: $meal\n" if $verbose;
                }
                if ( "$category" eq "EXERCISES") {
                    $exercise = $item;
                    $exercises{$exercise}++;
                    #print "EXER: $exercise\n" if $verbose;
                }
            }
            # Now, get the individual foods and nutrition
            #Burger Edge ­ the Original Edge, 336 g                              573       69g    18g      30g       0mg    2,340mg          9g      0g
            if ( $line =~ /^\s*(.*)\s+([0-9,]+)\s+([0-9,]+)g\s+([0-9,]+)g\s+([0-9,]+)g\s+([0-9,]+)mg\s+([0-9,]+)mg\s+([0-9,]+)g\s+([0-9,]+)g$/ ) {
                my $food = $1;
                my @data = ($2, $3, $4, $5, $6, $7, $8, $9);
                $food = trim($food);
                $food =~ s/\s+/ /g;
                $food = sanitise($food);
                my ($tablename, $keys, $values);
                if ($food =~ /TOTAL/) {
                    print "DATE: $date: TOTAL: @data\n" if $verbose;
                    $keys = "Date, Calories, Carbs, Fat, Protein, Cholesterol, Sodium, Sugars, Fiber";
                    $tablename = "daily_summary";
                    $values = "\"$date\"; ";
                } else {
                    my $uuid = "$timestamp.".sprintf("%03d", $daily_item);
                    #print "UUID: $uuid: DATE: $date MEAL: $meal FOOD: $food: @data\n" if $verbose;
                    $keys = "UUID, Date, Meal, Food, Calories, Carbs, Fat, Protein, Cholesterol, Sodium, Sugars, Fiber";
                    $values = "\"$uuid\"; \"$date\"; \"$meal\"; \"$food\"; ";
                    $tablename = "all_foods";
                    $daily_item++;
                }
                $values .= join("; ", @data);
                $values =~ s/,//g;
                $values =~ s/;/,/g;
                my $command = "Insert or replace into [$tablename] ($keys) Values ($values)";
                dbdo($db, $command, 1)
            }
            #  Fitbit calorie adjustment                                                                   443           1                                
            if ( $line =~ /Fitbit calorie adjustment\s+([0-9,]+)\s+([0-9]+)/) {
                my $calories = $1;
                my $minutes = $2;
                $calories =~ s/,//g;
                print "DATE: $date Calories Burned: $calories\n" if $verbose;
                my $command = "Insert or replace into [calories_burned] (Date, Calories) Values (\"$date\", $calories)";
                dbdo($db, $command, 1)
            }
            # Get the Exercise Totals
            #

            #sleep 1;
        }
        dbdo($db, "COMMIT", 1);
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

sub display_as_hex {
    # display a string as a hexdump'
    my $string = shift;
}

## subroutines
sub make_db {
    print "making the database: $db\n" if $verbose;
    drop_all_tables($db);
    my %tables = (
        "all_foods"=>"UUID Text PRIMARY Key, date TEXT, meal TEXT, food TEXT, Calories INTEGER, Carbs INTEGER,Fat Integer, Protein Integer, Cholesterol Integer, Sodium Integer, Sugars Integer, Fiber Integer",
        "calories_burned"=>"date TEXT, calories INTEGER",
        "daily_summary"=>"date TEXT PRIMARY KEY, Calories Integer, Carbs INTEGER,Fat Integer, Protein Integer, Cholesterol Integer, Sodium Integer, Sugars Integer, Fiber Integer");
    foreach my $tablename (%tables) {
        if (exists $tables{$tablename} ) {
            my $command = "Create Table if not exists [$tablename] ($tables{$tablename})";
            my $result = dbdo($db, $command, $verbose);
        }
    }
    build_tables_from_files($db);
}
sub drop_all_tables {
    # get a list of table names from $db and drop them all
    my $db = shift;
    print "Clearing the database because \$firstrun == $firstrun\n";
    my @tables;
    my $query = querydb($db, "select name from sqlite_master where type='table' order by name", 1);
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
sub dbdo {
    my $db = shift;
    my $command = shift;
    my $verbose = shift;
    if (length($command) > 1000000) {
        die "$command too long!";
    }
    #print "\t$db: ".length($command)." $command\n" if $verbose;
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
sub sanitise {
    # some simple substitutions to sanitise a string
    my $verbose = 0;
    my $string = shift;
    print "sanitise: $string:" if $verbose;
    $string =~ s/\"/inch/g;
    print "$string\n" if $verbose;
    return $string;
}



## subroutines
sub make_db {
    print "making the database: $db\n" if $verbose;
    drop_all_tables($db);
}
sub drop_all_tables {
    # get a list of table names from $db and drop them all
    my $db = shift;
    print "Clearing the database because \$firstrun == $firstrun\n";
    my @tables;
    my $query = querydb($db, "select name from sqlite_master where type='table' order by name", 1);
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
sub build_fb_tables_from_file {
    my $db = shift;
    my $filename = shift;
    my $outfilename = shift;
    print "Processing $filename...\n";
    open (my $fh, "<", "$filename") or die "Can't open $filename\n";
    open (my $outfh, ">", "$outfilename") or die "Can't open $outfilename\n";
    # The data is of the form:
    # Date: January 4, 2015;Total steps: 14028;Floors climbed: ; Calories burned: 2947; Elevation gained: ,meters; Traveled: 8.42, kilometers; Sedentary minutes: 1015; Lightly active minutes: 237; Fairly active minutes: 150; Very active minutes: 38;
    my $tablename = "fitbit_data";
    my $tabledef = "Date TEXT PRIMARY KEY, Total_steps INTEGER, Floors_climbed INTEGER";
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
        my $keys;
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
                    $values .= "\"$clean_value\", ";
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
            my $result = dbdo($db, $command, 1);
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
