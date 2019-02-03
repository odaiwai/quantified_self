#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use Data::Dumper;

my $verbose  = 0;
my $firstrun = 1;
my $basedir  = ".";
#my $filename = "fitbit_export_20150131.csv";

# script to parse the fitbit_export file and make a database
my $db = DBI->connect( "dbi:SQLite:dbname=health_data.sqlite", "", "" )
  or die DBI::errstr;

if ($firstrun) {
    my $result = make_db();
}

$db->disconnect;

## subroutines
sub make_db {
    print "making the database: $db\n" if $verbose;
    drop_all_tables($db, "fitbit_");
    my @files = `ls ../fitbit_data/fitbit_export*.csv`;
    foreach my $file (@files) {
        chomp $file;
        build_tables_from_file( $db, "$basedir/$file" );
    }

}

sub drop_all_tables {
    # get a list of table names from $db and drop them all
    my $db = shift;
    my $prefix = shift;
    print "Clearing the database because \$firstrun == $firstrun\n";
    my @tables;
    my $query = querydb( $db,
        "select name from sqlite_master where type='table' and name like '$prefix%' order by name", 1 );

    # we need to extract the list of tables first - sqlite doesn't like
    # multiple queries at the same time.
    while ( my @row = $query->fetchrow_array ) {
        push @tables, $row[0];
    }
    dbdo( $db, "BEGIN", 1 );
    foreach my $table (@tables) {
        dbdo( $db, "DROP TABLE if Exists [$table]", 1 );
    }
    dbdo( $db, "COMMIT", 1 );
    return 1;
}

sub build_tables_from_file {
    my $db       = shift;
    my $filename = shift;
    print "Processing $filename...\n";
    open( my $fh, "<", "$filename" ) or die "Can't open $filename\n";

    # The data is of the form:
    # 1.tablename
    # 2.table headers
    # 3.table data
    # 4.empty line
    while ( my $tablename = <$fh> ) {
        chomp $tablename;
        print "\t$tablename:\n" if $verbose;
        if ( $tablename =~ /Food Log [0-9]+/ ) {
            # This is a food log, and we don't care about them, and the format is flightly different
            #Read to end of file
            while ( my $line = <$fh> ) {
                # chomp $line;
                # ignore all the lines
            }
        }
        else {
            my $new_tablename = "fitbit_$tablename";
            my $headerline = <$fh>;
            chomp $headerline;
            my $startpos  = tell($fh);    #Get the position of the second line
            my $firstline = <$fh>;
            chomp $firstline;

            #$firstline =~ s/\"//g; # strip out the "
            my ( $tabledef, $fieldnames ) =
              tabledef_from_headerline( $headerline, $firstline);
            my $command = "Create Table if not exists [$new_tablename] ($tabledef)";
            my $result = dbdo( $db, $command, $verbose );
            dbdo( $db, "BEGIN", $verbose )
              ;                           # wrap the inserts in a Begin//Commit
            seek( $fh, $startpos, 0 );

            # parse the records and build the database
            my $numrecords       = 0;
            my $section_finished = 0;
            until ($section_finished) {
                my $line = <$fh>;
                chomp $line;
                if ( $line eq "" ) {
                    $section_finished = 1;
                }
                else {
                    #$line =~ s/\"//g;
                    my $values = sanitise_line_for_input($line);
                    my @values = split ",", $values;
                    my $timestamp = timestamp_from_date($values[0]);
                    $command = "Insert or Replace into [$new_tablename] ($fieldnames) Values ($timestamp, $values)";
                    my $result = dbdo( $db, $command, $verbose );
                    if ($result) { $numrecords++; }
                }
            }
            dbdo( $db, "COMMIT", $verbose ); # wrap the inserts in a Begin//Commit
        }
    }
    close $fh;

}

sub dbdo {
    my $db      = shift;
    my $command = shift;
    my $verbose = shift;
    if ( length($command) > 1000000 ) {
        die "$command too long!";
    }
    print "\t$db: " . length($command) . " $command\n" if $verbose;
    my $result = $db->do($command) or die $db->errstr . "\nwith: $command\n";
    return $result;
}

sub querydb {
    # prepare and execute a query
    my $db      = shift;
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
    # remove commas from thousands within quotes.
    $line =~ s/\"([0-9]+?),([0-9][0-9][0-9])\"/"$1$2"/g;
           #print "\t\t$line\n" if $verbose;
    $line =~ s/\"//g;

    #print "\t\t$line\n" if $verbose;
    my @fields = split /,/, $line;
    foreach my $field (@fields) {
        my $type = type_from_data($field);
        if ( $type eq "Text" ) {
            $cleanline .= "\"$field\"";
        }
        else {
            $cleanline .= "$field";
        }
        if ( $index < $#fields ) {
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
    my $firstline  = shift;
    my $values     = sanitise_line_for_input($firstline);
    my @headers    = split /,/, $headerline;
    my @values      = split /,/, $values;
    # Need to add in the timestamp field
    my $timestamp = timestamp_from_date(@values[0]); # The first field is the date
    unshift @headers, "timestamp";
    unshift @values, $timestamp;
    my ( $dbstructure, $fieldnames );
    foreach my $index ( 0 .. ($#headers) ) {
        # do we need to sanitise the header?
        my $header = $headers[$index];
        $header =~ s/ /_/g;
        $header =~ s/[()]+//g;
        my $field = $values[$index];

        # see what the content is to decide the type
        print "\t\t3.$index: $header: \"$field\" " if $verbose;
        my $type = type_from_data($field);
        print ": $type" if $verbose;
        print "\n"      if $verbose;
        $dbstructure .= "$header $type";
        $fieldnames  .= "$header";
        if ( $index == 0 )        { $dbstructure .= " Primary Key"; }
        if ( $index < $#headers ) { $dbstructure .= ", "; }
        if ( $index < $#headers ) { $fieldnames  .= ", "; }
    }
    return ( $dbstructure, $fieldnames );
}

sub type_from_data {

    # take a field and sample data and determine the type
    my $field = shift;
    my $type;
    my $has_text = 0;
    my $has_nums = 0;
    my $has_decs = 0;

    # the decision tree below is a little redundant, might change later
    if ( $field =~ /[A-Za-z()-]+/ ) { $has_text = 1; }
    if ( $field =~ /\// )           { $has_text = 1; }
    if ( $field =~ /\"/ )           { $has_text = 1; }
    if ( $field =~ /\d+/ )          { $has_nums = 1; }
    if ( $field =~ /\./ )           { $has_decs = 1; }
    if ($has_text) {
        $type = "Text";
    }
    elsif ($has_decs) {
        $type = "Real";
    }
    else {
        $type = "Integer";
    }
    return $type;
}
sub timestamp_from_date {
    # sub to return yyyymmdd from "dd/mm/yyyy"
    my $date = shift;
    $date =~ s/\"//g;
    my ($day, $month, $year) = split "/", $date;
    print "$date -> $year.$month.$day\n" if $verbose;
    my $timestamp = sprintf("%04d", $year).sprintf("%02d",$month).sprintf("%02d",$day);
    return $timestamp;
}
