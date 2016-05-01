#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use Data::Dumper;

# script to parse the myfitnesspal pdf output (converted to txt)
# 20151229 - dave o'brien
my $verbose = 1;
<<<<<<< HEAD
my $firstrun = 1;
=======
my $firstrun = 0;
>>>>>>> unified_parsing
# script to parse the fitbit_export file and make a database
my $db = DBI->connect("dbi:SQLite:dbname=myfitnesspal.sqlite","","") or die DBI::errstr;

if ($firstrun) {
    my $result = make_db();
<<<<<<< HEAD
}


=======
} else {
	build_tables_from_files($db);
}

## TODO
# Need to calculate calories from Alcohol as well
# Need to calculate quantities of Caffeine/Alcohol
# Need to build data panels for statistical analysis
>>>>>>> unified_parsing

$db->disconnect;
## subs
sub build_tables_from_files {
    my $db = shift;
<<<<<<< HEAD
    my (@files) = `ls mfp_report*.txt`;
    foreach my $file (@files) {
        chomp $file;
=======
    my (@files) = `ls myFitnessPal_data/mfp_report_????.txt`;
    foreach my $file (@files) {
        chomp $file;
        print "Processing file: $file\n";
>>>>>>> unified_parsing
        open (my $infh, "<", $file) or die "Can't open $file\n";
        my $date = "";
        my $category = "";
        my $meal = "";
        my $exercise = "";
<<<<<<< HEAD
        dbdo($db, "BEGIN", 1);
=======
        my $daily_item = 0;
        my $timestamp = "";
        my %meals;
        my %exercises;
        dbdo($db, "BEGIN", 1);
        my %months = ("January"=>1, "February"=>2, "March"=>3, "April"=>4, "May"=>5, "June"=>6, "July"=>7, "August"=>8, "September"=>9, "October"=>10, "November"=>11, "December"=>12);
        #print Dumper(%months);
        #exit;
>>>>>>> unified_parsing
        while (my $line = <$infh>) {
            chomp $line;
            #print "LINE: |$line|\n" if $verbose;
            $line =~ s/[\xa0\xc2\xad]/ /g; # gets rid of &nbsp; UTF-8 entities
            #print "$line\n" if $verbose;
            # first, get the date
<<<<<<< HEAD
            if ( $line =~ /[ \t]+([A-Za-z]+)[ \t]+([0-9]+),[ \t]+([0-9]+)/) {
=======
            if ( $line =~ /[ \t]*([A-Za-z]+)[ \t]+([0-9]+),[ \t]+([0-9]+)/) {
>>>>>>> unified_parsing
                my $month = $1;
                my $day = $2;
                my $year = $3;
                # get a properly formatted Date object?
<<<<<<< HEAD
                $date = "$day $month $year";
                print "DAY: $date\n" if $verbose;
=======
                my $mnum = $months{$month};
                $date = "$day $month $year";
                $timestamp = sprintf("%04d", $year).sprintf("%02d", $mnum).sprintf("%02d", $day);
                $daily_item = 0;
                #print "DAY: $date ($timestamp)\n" if $verbose;
>>>>>>> unified_parsing
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
<<<<<<< HEAD
                print "SubCat: $category.$item " if $verbose;
                if ( "$category" eq "FOODS") {
                    $meal = $item;
=======
                #print "SubCat: $category.$item " if $verbose;
                if ( "$category" eq "FOODS") {
                    $meal = $item;
                    $meals{$meal}++;
>>>>>>> unified_parsing
                    #print "MEAL: $meal\n" if $verbose;
                }
                if ( "$category" eq "EXERCISES") {
                    $exercise = $item;
<<<<<<< HEAD
=======
                    $exercises{$exercise}++;
>>>>>>> unified_parsing
                    #print "EXER: $exercise\n" if $verbose;
                }
            }
            # Now, get the individual foods and nutrition
            #Burger Edge ­ the Original Edge, 336 g                              573       69g    18g      30g       0mg    2,340mg          9g      0g
<<<<<<< HEAD
            if ( $line =~ /^\s+(.*)\s+([0-9,]+)\s+([0-9,]+)g\s+([0-9,]+)g\s+([0-9,]+)g\s+([0-9,]+)mg\s+([0-9,]+)mg\s+([0-9,]+)g\s+([0-9,]+)g$/ ) {
=======
            if ( $line =~ /^\s*(.*)\s+([0-9,]+)\s+([0-9,]+)g\s+([0-9,]+)g\s+([0-9,]+)g\s+([0-9,]+)mg\s+([0-9,]+)mg\s+([0-9,]+)g\s+([0-9,]+)g$/ ) {
>>>>>>> unified_parsing
                my $food = $1;
                my @data = ($2, $3, $4, $5, $6, $7, $8, $9);
                $food = trim($food);
                $food =~ s/\s+/ /g;
                $food = sanitise($food);
                my ($tablename, $keys, $values);
                if ($food =~ /TOTAL/) {
                    print "DATE: $date: TOTAL: @data\n" if $verbose;
<<<<<<< HEAD
                    $keys = "Date, Calories_in, Carbs, Fat, Protein, Cholesterol, Sodium, Sugars, Fiber";
                    $tablename = "daily_summary";
                    $values = "\"$date\"; ";
                } else {
                    print "DATE: $date MEAL: $meal FOOD: $food: @data\n" if $verbose;
                    $keys = "Date, Meal, Food, Calories, Carbs, Fat, Protein, Cholesterol, Sodium, Sugars, Fiber";
                    $values = "\"$date\"; \"$meal\"; \"$food\"; ";
                    $tablename = "all_foods";
=======
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
>>>>>>> unified_parsing
                }
                $values .= join("; ", @data);
                $values =~ s/,//g;
                $values =~ s/;/,/g;
                my $command = "Insert or replace into [$tablename] ($keys) Values ($values)";
                dbdo($db, $command, 1)
            }
            #  Fitbit calorie adjustment                                                                   443           1                                
<<<<<<< HEAD
            if ( $line =~ /Fitbit  calorie  adjustment\s+([0-9,]+)\s+([0-9]+)/) {
=======
            if ( $line =~ /Fitbit calorie adjustment\s+([0-9,]+)\s+([0-9]+)/) {
>>>>>>> unified_parsing
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
<<<<<<< HEAD
        "all_foods"=>"date TEXT PRIMARY KEY, meal TEXT, food TEXT, Calories INTEGER, Carbs INTEGER,Fat Integer, Protein Integer, Cholesterol Integer, Sodium Integer, Sugars Integer, Fiber Integer",
=======
        "all_foods"=>"UUID Text PRIMARY Key, date TEXT, meal TEXT, food TEXT, Calories INTEGER, Carbs INTEGER,Fat Integer, Protein Integer, Cholesterol Integer, Sodium Integer, Sugars Integer, Fiber Integer",
>>>>>>> unified_parsing
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
<<<<<<< HEAD
    print "\t$db: ".length($command)." $command\n" if $verbose;
=======
    #print "\t$db: ".length($command)." $command\n" if $verbose;
>>>>>>> unified_parsing
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
<<<<<<< HEAD
=======
    my $verbose = 0;
>>>>>>> unified_parsing
    my $string = shift;
    print "sanitise: $string:" if $verbose;
    $string =~ s/\"/inch/g;
    print "$string\n" if $verbose;
    return $string;
}
