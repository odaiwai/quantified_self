#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use Data::Dumper;

# script to parse the myfitnesspal pdf output (converted to txt)
# 20151229 - dave o'brien
my $verbose = 0;
my $firstrun = 1;
# script to parse the fitbit_export file and make a database
my $db = DBI->connect("dbi:SQLite:dbname=health_data.sqlite","","") or die DBI::errstr;

if ($firstrun) {
    my $result = make_db();
} else {
	build_tables_from_files($db);
}

## TODO
# Add a Timestamp
# Need to calculate calories from Alcohol as well
# Need to calculate quantities of Caffeine/Alcohol
# Need to build data panels for statistical analysis

$db->disconnect;
## subs
sub build_tables_from_files {
    my $db = shift;
    my (@files) = `ls ../health_data/myFitnessPal_data/mfp_report_????.txt`;
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
        my $months = "(January|February|March|April|May|June|July|August|September|October|November|December)";
        #print Dumper(%months);
        #exit;
        while (my $line = <$infh>) {
            chomp $line;
            #print "LINE: |$line|\n" if $verbose;
            $line =~ s/[\xa0\xc2\xad]/ /g; # gets rid of &nbsp; UTF-8 entities
            #print "$line\n" if $verbose;
            # first, get the date
            if ( $line =~ /[ \t]*([$months]+)[ \t]*([0-9]{1,2}),[ \t]*([0-9]{4})$/) {
                my $month = $1;
                my $day = $2;
                my $year = $3;
                #print "DATE: $month, $day, $year\n";
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
                    print "DATE: [$timestamp] $date: TOTAL: @data\n" if $verbose;
                    $keys = "timestamp, Date, Calories, Carbs, Fat, Protein, Cholesterol, Sodium, Sugars, Fiber";
                    $tablename = "mfp_daily_summary";
                    $values = "$timestamp; \"$date\"; ";
                } else {
                    my $uuid = "$timestamp.".sprintf("%03d", $daily_item);
                    #print "UUID: $uuid: DATE: $date MEAL: $meal FOOD: $food: @data\n" if $verbose;
                    $keys = "UUID, Date, Meal, Food, Calories, Carbs, Fat, Protein, Cholesterol, Sodium, Sugars, Fiber";
                    $values = "\"$uuid\"; \"$date\"; \"$meal\"; \"$food\"; ";
                    $tablename = "mfp_all_foods";
                    $daily_item++;
                }
                $values .= join("; ", @data);
                $values =~ s/,//g;
                $values =~ s/;/,/g;
                my $command = "Insert or replace into [$tablename] ($keys) Values ($values)";
                dbdo($db, $command, 1)
            }
            #Alternative Split line style from Lynx -dump
            #Coffee - Aeropress, 1 with 40ml Milk
            #30                                                  0g       0g    0g  0mg     0mg     0g      0g

            #  Fitbit calorie adjustment                                                                   443           1                                
            if ( $line =~ /Fitbit[ ]*calorie[ ]*adjustment\s+([0-9,]+)\s+([0-9]+)/) {
                my $calories = $1;
                my $minutes = $2;
                $calories =~ s/,//g;
                print "DATE: [$timestamp] $date Calories Burned: $calories\n" if $verbose;
                my $command = "Insert or replace into [mfp_calories_burned] (Timestamp, Date, Calories) Values ($timestamp, \"$date\", $calories)";
                dbdo($db, $command, 1)
            }
            #  Fitbit calorie adjustment on split lines
            if ( $line =~ /\s+Fitbit calorie adjustment$/) {
                #print "DATE: [$timestamp] $line\n" if $verbose;
                my $next_line = <$infh>;
                chomp $next_line;
                #print "DATE: [$timestamp] $next_line\n" if $verbose;
                if ($next_line =~ /([0-9,]+)\s+([0-9]+)/) {
                    my $calories = $1;
                    my $minutes = $2;
                    $calories =~ s/,//g;
                    print "DATE: [$timestamp] $date Calories Burned: $calories\n" if $verbose;
                    my $command = "Insert or replace into [mfp_calories_burned] (Timestamp, Date, Calories) Values ($timestamp, \"$date\", $calories)";
                    dbdo($db, $command, 1);
                }
            }
            #  MFP iOS calorie adjustment on split lines - Can have multiple entries
            if ( $line =~ /\s+MFP iOS calorie adjustment$/) {
                #print "DATE: [$timestamp] $line\n" if $verbose;
                my $next_line = <$infh>;
                chomp $next_line;
                #print "DATE: [$timestamp] $next_line\n" if $verbose;
                if ($next_line =~ /([0-9,]+)\s+([0-9]+)/) {
                    my $calories = $1;
                    my $minutes = $2;
                    $calories =~ s/,//g;
                    print "DATE: [$timestamp] $date Calories Burned: $calories\n" if $verbose;
                    #my $command = "Insert or replace into [mfp_calories_burned] (Timestamp, Date, Calories) Values ($timestamp, \"$date\", $calories)";
                    #dbdo($db, $command, 1);
                }
            }
            #  Exercise calorie adjustment on split lines - Can have multiple entries
            if ( $line =~ /\s+Walking.*$/) {
                #print "DATE: [$timestamp] $line\n" if $verbose;
                my $next_line = <$infh>;
                chomp $next_line;
                #print "DATE: [$timestamp] $next_line\n" if $verbose;
                if ($next_line =~ /([0-9,]+)\s+([0-9]+)/) {
                    my $calories = $1;
                    my $minutes = $2;
                    $calories =~ s/,//g;
                    print "DATE: [$timestamp] $date Calories Burned: $calories\n" if $verbose;
                    #my $command = "Insert or replace into [mfp_calories_burned] (Timestamp, Date, Calories) Values ($timestamp, \"$date\", $calories)";
                    #dbdo($db, $command, 1);
                }
            }
            # Get the Exercise Totals - Cals, Minutes, sets, Reps, Weight
            if ( $line =~ /\s+TOTALS:\s+([0-9,]+)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+)$/) {
                my $calories = $1;
                my $minutes = $2;
                my $sets = $3;
                my $reps = $4;
                my $weight = $5;
                $calories =~ s/,//g;
                print "DATE: [$timestamp] $date Calories Burned: $calories\n" if $verbose;
                my $command = "Insert or replace into [mfp_calories_burned] (Timestamp, Date, Calories) Values ($timestamp, \"$date\", $calories)";
                dbdo($db, $command, 1)
            }
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
    drop_all_tables($db, "mfp_");
    my %tables = (
        "mfp_all_foods"=>"UUID Text PRIMARY Key, date TEXT, meal TEXT, food TEXT, Calories INTEGER, Carbs INTEGER,Fat Integer, Protein Integer, Cholesterol Integer, Sodium Integer, Sugars Integer, Fiber Integer",
        "mfp_calories_burned"=>"timestamp INTEGER PRIMARY KEY, date TEXT, calories INTEGER",
        "mfp_daily_summary"=>"timestamp INTEGER PRIMARY KEY, date TEXT, Calories Integer, Carbs INTEGER,Fat Integer, Protein Integer, Cholesterol Integer, Sodium Integer, Sugars Integer, Fiber Integer");
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
