#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use Data::Dumper;
use IO::File;
use XML::Parser;
use XML::Rules;

# Script to parse the Apple Health Export Data XML file
# 20170511 dave o'brien
#

my $verbose  = 1;
my $firstrun = 1;
my $basedir  = "./apple_health_export";
my $filename = "export.xml";

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
    drop_all_tables($db, "HK_"); # Health kit
    my @files = ("export.xml");
    foreach my $file (@files) {
        chomp $file;
        build_tables_from_file( $db, "$basedir", "$file" );
    }

}

sub build_tables_from_file {
    my $db       = shift;
    my $basedir = shift;
    my $filename = shift;
    print "Processing $basedir/$filename...\n";
	my $parser = new XML::Parser ( Handlers => {   # Creates our parser object
			Start   => \&hdl_start,
			End     => \&hdl_end,
			Char    => \&hdl_char,
			Default => \&hdl_def,
			});
	$parser->parsefile($filename);
	#open( my $fh, "<", "$basedir/$filename" ) or die "Can't open $basedir/$filename\n";

    # The data is of the form:
    # line 1: <?xml...
    # line 2: <!DOCTYPE HealthData [...
    # Line n: ]>
    # Line n+1: <HealthData locale="en_HK">
	#	 <ExportDate value="2017-04-20 14:55:46 +0800"/>
	# <Me HKCharacteristicTypeIdentifierDateOfBirth="1967-11-24" HKCharacteristicTypeIdentifierBiologicalSex="HKBiologicalSexMale" HKCharacteristicTypeIdentifierBloodType="HKBloodTypeNotSet" HKCharacteristicTypeIdentifierFitzpatrickSkinType="HKFitzpatrickSkinTypeNotSet"/>
	# Single Entry Record: <Record type="HKQuantityTypeIdentifierDietaryWater" sourceName="Sync Solver" sourceVersion="24" unit="mL" creationDate="2015-10-09 14:20:38 +0800" startDate="2013-11-21 00:00:00 +0800" endDate="2013-11-21 23:59:59 +0800" value="1500"/>
	# Multiple Entry Record:  <Record type="HKCategoryTypeIdentifierSleepAnalysis" sourceName="Clock" sourceVersion="50" device="&lt;&lt;HKDevice: 0x17429a090&gt;, name:iPhone, manufacturer:Apple, model:iPhone, hardware:iPhone7,1, software:10.2&gt;" creationDate="2017-01-13 08:00:28 +0800" startDate="2017-01-13 01:01:00 +0800" endDate="2017-01-13 08:00:28 +0800" value="HKCategoryValueSleepAnalysisInBed">
	#  <MetadataEntry key="_HKPrivateSleepAlarmUserWakeTime" value="2017-01-14 00:00:00 +0000"/>
	#  <MetadataEntry key="_HKPrivateSleepAlarmUserSetBedtime" value="2017-01-12 16:00:00 +0000"/>
	#  <MetadataEntry key="HKTimeZone" value="Asia/Hong_Kong"/>
	# </Record>
    # Workout: <Workout workoutActivityType="HKWorkoutActivityTypeWalking" duration="1.12163333495458" durationUnit="min" totalDistance="0" totalDistanceUnit="km" totalEnergyBurned="6" totalEnergyBurnedUnit="kcal" sourceName="Human" sourceVersion="4709" creationDate="2016-11-26 12:49:43 +0800" startDate="2016-11-26 09:58:33 +0800" endDate="2016-11-26 09:59:40 +0800">
	#  <MetadataEntry key="id" value="ea32e9d9-cd47-41bb-8e38-9c21244d65a6"/>
	#  <MetadataEntry key="mode" value="walking"/>
	# </Workout>
	# Last Line: </HealthData>
	my $parser = XML::Rules->new(
    	stripspaces => 7,
		rules => {
			substrate => sub { 'substrate' => $_[1]->{id}},
			product => sub { '@products' => $_[1]->{id}},
			reaction => sub {
				my %reactions;
				foreach (split / /, $_[1]->{name}) {
					$reactions{$_} = { substrate => $_[1]->{substrate}, products => $_[1]->{products}};
				}
				return '%reactions' => \%reactions;
			},
			graphics => '',
			entry => sub {
				my @reactions = split ' ', (delete $_[1]->{reaction});
				$_[1]->{reactions} = \@reactions if @reactions;
				return '%entries' => {$_[1]->{id} => $_[1]}
			},
			pathway => 'pass'
		});


    print Dumper ($parser->parsefile('ko00010.xml'));  
    
    # The table name comes from the file name, lowercased and underscored.
    my $tablename = "HK_" . lc($filename);
    $tablename =~ s/\s+/_/g;
	
    # read in the first line and parse it for the type def
	my $headerline = <$fh>;
	chomp $headerline;
	my $startpos  = tell($fh);    #Get the position of the second line
	my $firstline = <$fh>;
	chomp $firstline;

	my ( $tabledef, $fieldnames ) = tabledef_from_headerline( $headerline, $firstline);
	my @fields = split " ", $fieldnames;
	my $command = "Create Table if not exists [$tablename] ($tabledef)";
	my $result = dbdo( $db, $command, $verbose );
	dbdo( $db, "BEGIN", $verbose ); # wrap the inserts in a Begin//Commit
	seek( $fh, $startpos, 0 );
	# parse the records and build the database
	my $numrecords       = 0;
	my $section_finished = 0;
	until ($section_finished) {
		my $line = <$fh>;
		if ( !$line) {
			$section_finished = 1;
		} else {
			chomp $line;
			#$line =~ s/\"//g;
			my $values = sanitise_line_for_input($line);
			my @values = split ",", $values;
			my $timestamp = timestamp_from_date($values[0]);
			my $these_fields;
			my $num_values = $#values + 1; # Need to include the timestamp
			print "$#fields, $num_values\n" if $verbose;
			foreach my $fieldnum (0..$num_values) {
				if ($fieldnum > 0) {$these_fields .= ", ";}
				$these_fields .= "$fields[$fieldnum]";
			}
			$these_fields =~ s/,,/,/g;
			$these_fields =~ s/,$//g;
			print "These Fields: $these_fields\n" if $verbose;
			$command = "Insert or Replace into [$tablename] ($these_fields) Values ($timestamp, $values)";
			my $result = dbdo( $db, $command, $verbose );
			if ($result) { $numrecords++; }
		}
	}
	dbdo( $db, "COMMIT", $verbose ); # wrap the inserts in a Begin//Commit
    close $fh;
}

# The Handlers
sub hdl_start{
	my ($p, $elt, %atts) = @_;
	return unless $elt eq 'Record';  # Only bother with Messages
	$atts{'_str'} = '';
	$message = \%atts; 
}

sub hdl_end{
	my ($p, $elt) = @_;
	format_message($message) if $elt eq 'message' && $message && $message->{'_str'} =~ /\S/;
}

sub hdl_char {
	my ($p, $str) = @_;
	$message->{'_str'} .= $str;
}

sub hdl_def { }  # We just throw everything else

sub format_message { # Helper sub to nicely format what we got from the XML
	my $atts = shift;
	$atts->{'_str'} =~ s/\n//g;

	my ($y,$m,$d,$h,$n,$s) = $atts->{'time'} =~ m/^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})$/;

	# Handles the /me
	$atts->{'_str'} = $atts->{'_str'} =~ s/^\/me// ?
	"$atts->{'author'} $atts->{'_str'}"   :
	"<$atts->{'author'}>: $atts->{'_str'}";
	$atts->{'_str'} = "$h:$n " . $atts->{'_str'};
	print "$atts->{'_str'}\n";
	undef $message;
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
    print "@headers\n@values\n" if $verbose;
    # The headers also include the units like: "Basal Body Temperature (degC)"
    my @new_headers;
    my @units;
    foreach my $header_unit (@headers) {
    	$header_unit =~ s/\(Systolic\)/Systolic/g;
    	$header_unit =~ s/\(Diastolic\)/Diastolic/g;
    	my ($header, $units);
    	if ($header_unit =~ /\(.*\)/) {
			($header, $units)= split "[\(]", $header_unit;
			$header =~ s/_$//g;
			$units =~ s/[\)]//g;
		} else {
	    	($header, $units) = ($header_unit, "");
	    }
		$header =~ s/ /_/g;
		$header =~ s/_$//g;
		push @new_headers, $header;
		push @units, $units;
    }
    print "@new_headers\n@units\n@values\n" if $verbose;
    # Need to add in the timestamp field
    my $timestamp = timestamp_from_date($values[0]); # The first field is the start date
    unshift @new_headers, "timestamp";
    unshift @values, $timestamp;
    my ( $dbstructure, $fieldnames );
    foreach my $index ( 0 .. ($#new_headers) ) {
        # do we need to sanitise the header?
        my $header = $new_headers[$index];
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
        if ( $index < $#new_headers ) { $dbstructure .= ", "; }
        if ( $index < $#new_headers ) { $fieldnames  .= ", "; }
    }
    print "$dbstructure, $fieldnames\n" if $verbose;
    #sleep 30;
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
    # sub to return yyyymmdd from "dd-mmm-yyyy hh:mm"
    my $date = shift;
    $date =~ s/\"//g;
	my %months=("Jan"=>"01", "Feb"=>"02", "Mar"=>"03", "Apr"=>"04", "May"=>"05", "Jun"=>"06",
				"Jul"=>"07", "Aug"=>"08", "Sep"=>"09", "Oct"=>"10", "Nov"=>"11", "Dec"=>"12");
	#my $date1 = split " ", $date;
    my ($day, $month, $year, $hours, $minutes) = split "[- :]", $date;
    print "$date -> $year.$month.$day.$hours.$minutes\n" if $verbose;
    my $mnum = $months{$month};
    my $timestamp = sprintf("%04d", $year).$mnum.sprintf("%02d",$day).sprintf("%02d",$hours).sprintf("%02d",$minutes);
    return $timestamp;
}
