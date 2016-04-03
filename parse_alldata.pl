#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use Data::Dumper;

# script to parse all the fitness pdf output (converted to txt)
# 20151229 - dave o'brien
my $verbose = 0;
my $firstrun = 1;
# script to parse the fitbit_export file and make a database
my $db = DBI->connect("dbi:SQLite:dbname=fitnessdata.sqlite","","") or die DBI::errstr;

if ($firstrun) {
    my $result = make_db();
}

# build a table of

$db->disconnect;
## subs
sub build_mfp_tables_from_files {
    my $db = shift;
    my (@files) = `ls mfp_report*.txt`;
    foreach my $file (@files) {
        chomp $file;
        open (my $infh, "<", $file) or die "Can't open $file\n";
        my $date = "";
        my $category = "";
        my $meal = "";
        my $exercise = "";
        dbdo($db, "BEGIN", $verbose);
        while (my $line = <$infh>) {
            chomp $line;
            #print "LINE: |$line|\n" if $verbose;
            $line =~ s/[\xa0\xc2\xad]/ /g; # gets rid of &nbsp; UTF-8 entities
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
                #print "CATEGORY: $category\tDATA: @data\n" if $verbose;
            }
            # Next, get the Sub Category (Meals, types of exercise)
            if ( $line =~ /^([A-Z][a-z]+)$/) {
                my $item = $1;
                print "SubCat: $category.$item " if $verbose;
                if ( "$category" eq "FOODS") {
                    $meal = $item;
                    #print "MEAL: $meal\n" if $verbose;
                }
                if ( "$category" eq "EXERCISES") {
                    $exercise = $item;
                    #print "EXER: $exercise\n" if $verbose;
                }
            }
            # Now, get the individual foods and nutrition
            #Burger Edge ­ the Original Edge, 336 g                              573       69g    18g      30g       0mg    2,340mg          9g      0g
            if ( $line =~ /^\s+(.*)\s+([0-9,]+)\s+([0-9,]+)g\s+([0-9,]+)g\s+([0-9,]+)g\s+([0-9,]+)mg\s+([0-9,]+)mg\s+([0-9,]+)g\s+([0-9,]+)g$/ ) {
                my $food = $1;
                my @data = ($2, $3, $4, $5, $6, $7, $8, $9);
                $food = trim($food);
                $food =~ s/\s+/ /g;
                $food = sanitise($food);
                my ($tablename, $keys, $values);
                if ($food =~ /TOTAL/) {
                    #print "DATE: $date: TOTAL: @data\n" if $verbose;
                    $keys = "Date, Calories, Carbs, Fat, Protein, Cholesterol, Sodium, Sugars, Fiber";
                    $tablename = "daily_summary";
                    $values = "\"$date\"; ";
                } else {
                    #print "DATE: $date MEAL: $meal FOOD: $food: @data\n" if $verbose;
                    $keys = "Date, Meal, Food, Calories, Carbs, Fat, Protein, Cholesterol, Sodium, Sugars, Fiber";
                    $values = "\"$date\"; \"$meal\"; \"$food\"; ";
                    $tablename = "all_foods";
                }
                $values .= join("; ", @data);
                $values =~ s/,//g;
                $values =~ s/;/,/g;
                my $command = "Insert or replace into [$tablename] ($keys) Values ($values)";
                dbdo($db, $command, $verbose)
            }
            #  Fitbit calorie adjustment                                                                   443           1                                
            if ( $line =~ /Fitbit  calorie  adjustment\s+([0-9,]+)\s+([0-9]+)/) {
                my $calories = $1;
                my $minutes = $2;
                $calories =~ s/,//g;
                #print "DATE: $date Calories Burned: $calories\n" if $verbose;
                my $command = "Insert or replace into [calories_burned] (Date, Calories) Values (\"$date\", $calories)";
                dbdo($db, $command, $verbose)
            }
            # Get the Exercise Totals
            #

            #sleep 1;
        }
        dbdo($db, "COMMIT", $verbose);
    }
}
sub build_fb_tables_from_files {
    my $db = shift;
    my $filename = shift;
    my $outfilename = shift;
    print "Processing $filename...\n";
    open (my $fh, "<", "$filename") or die "Can't open $filename\n";
    open (my $outfh, ">", "$outfilename") or die "Can't open $outfilename\n";
    # The data is of the form:
    # Date: January 4, 2015;Total steps: 14028;Floors climbed: ; Calories burned: 2947; Elevation gained: ,meters; Traveled: 8.42, kilometers; Sedentary minutes: 1015; Lightly active minutes: 237; Fairly active minutes: 150; Very active minutes: 38;
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
            my $command = "Insert or Replace into [fitbit_data] ($keys) Values ($values)";
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
sub build_body_measurement_tables{
    # build the tables of body measurements
    my $db = shift;
    my $filename = "body_measurements.dat";
    print "Processing $filename\n" if $verbose;
    open (my $fh, "<", $filename) or die "Can't Open $filename!\n";
    my $keys = "DateTime, Name, Height, Age, Weight, BodyFat, BodyFatPercent, BodyWaterPercent, BoneMassPercent, Systolic, Diastolic, Pulse, RHR";
    dbdo($db, "BEGIN", $verbose);
    while (my $line = <$fh>) {
        chomp $line;
        $line =~ s/\%//g;
        # the -1 in split produces as many fields as possible
        my @data = split(/;{1}/, $line, -1);
        #my @data = $line =~ /;/g;
        #print "\t|$line|\n\t|@data|\n";
        my @clean_data;
        foreach my $data (@data) {
            # check the data for nulls, replace with zero
            if (length($data) == 0) {
                $data = 0;
            }
            # stringify the first two items
            if ($data =~ /[A-Za-z: -]+/ ) {
                $data = "\"$data\"";
            }
            push @clean_data, $data;
        }
        #print "\t|@clean_data|\n";
        my $values = join ", ", @clean_data;
        my $command = "Insert or Replace into [body_measurements] ($keys) Values ($values)";
        print "\t$command\n" if $verbose;
        my $result = dbdo($db, $command, $verbose);
    }
    dbdo($db, "COMMIT", $verbose);
}
sub split_line {
    my $line = shift;
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

sub trim {
    # trim leading and trailing spaces
    my $string = shift;
    $string =~ s/^\s+//g;
    $string =~ s/\s+$//g;
    return $string;
}
## Generic Database Utilities
sub make_db {
    print "making the database: $db\n" if $verbose;
    drop_all_tables($db);
    my %tables = (
        "all_foods"=>"date TEXT PRIMARY KEY, meal TEXT, food TEXT, Calories INTEGER, Carbs INTEGER,Fat Integer, Protein Integer, Cholesterol Integer, Sodium Integer, Sugars Integer, Fiber Integer",
        "calories_burned"=>"date TEXT, calories INTEGER",
        "daily_summary"=>"date TEXT PRIMARY KEY, Calories Integer, Carbs INTEGER,Fat Integer, Protein Integer, Cholesterol Integer, Sodium Integer, Sugars Integer, Fiber Integer",
        "fitbit_data"=>"Date TEXT PRIMARY KEY, Total_steps INTEGER, Floors_climbed INTEGER, Calories_burned INTEGER, Elevation_gained INTEGER, Traveled REAL, Sedentary INTEGER, Lightly_active INTEGER, Fairly_active INTEGER, Very_active INTEGER",
        "body_measurements"=>"DateTime Text, Name Text, Height Real, Age Real, Weight Real, BodyFat Real, BodyFatPercent Real, BodyWaterPercent Real, BoneMassPercent Real, Systolic Integer, Diastolic Integer, Pulse Integer, RHR Integer");
    foreach my $tablename (%tables) {
        if (exists $tables{$tablename} ) {
            my $command = "Create Table if not exists [$tablename] ($tables{$tablename})";
            my $result = dbdo($db, $command, $verbose);
        }
    }
    build_mfp_tables_from_files($db);
    my $filename = "/home/odaiwai/Dropbox/ifttt/Fitbit/fitbit_data.txt";
    my $outfilename = "./fitbit_data.csv";
    build_fb_tables_from_files($db, $filename, $outfilename);
    build_body_measurement_tables($db);
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
sub sanitise {
    # some simple substitutions to sanitise a string
    my $string = shift;
    print "sanitise: $string:" if $verbose;
    $string =~ s/\"/inch/g;
    print "$string\n" if $verbose;
    return $string;
}
