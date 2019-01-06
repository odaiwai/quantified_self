#!/usr/bin/perl
use strict;
use warnings;
use XML::Rules;
use DBI;
use Time::Piece;
use DateTime;

# script to parse the Apple Health Export XML file and populate a database
# Dave O'Brien 2017/05

my $firstrun = 1;
my $db = DBI->connect("dbi:SQLite:dbname=health_data.sqlite","","") or die DBI::errstr;

if ($firstrun) {
	my $result = drop_all_tables($db, "apple_xml_");
	$result = make_db($db);
}

my $xml = "apple_health_export/export.xml";
my %dataTypes;
my %sourceNames;
my %units;
my %devices;
my %workoutActivityTypes;
my %correlation_types;
my %activitySummaries;
my %metadata_keys;
my $verbose = 0;


# Setup and run the parser
my @rules = define_xml_rules();
my $parser = XML::Rules->new(rules => \@rules);
dbdo ($db, "BEGIN", $verbose);
$parser->parsefile( $xml);
dbdo ($db, "COMMIT", $verbose);


#foreach my $device (%devices) {
#	if (exists($devices{$device})) {
#		print "Device: $device ($devices{$device})\n";
#	}
#}
foreach my $unit (%units) {
	if (exists($units{$unit})) {
		print "Unit: $unit ($units{$unit})\n";
	}
}

foreach my $dataType (%dataTypes) {
	if (exists($dataTypes{$dataType})) {
		print "dataTypes: $dataType ($dataTypes{$dataType})\n";
	}
}
foreach my $sourceName (%sourceNames) {
	if (exists($sourceNames{$sourceName})) {
		print "sourceNames: $sourceName ($sourceNames{$sourceName})\n";
	}
}
foreach my $workoutActivityType (%workoutActivityTypes) {
	if (exists($workoutActivityTypes{$workoutActivityType})) {
		print "Workouts: $workoutActivityType ($workoutActivityTypes{$workoutActivityType})\n";
	}
}

foreach my $metaDataType (%metadata_keys) {
	if (exists($metadata_keys{$metaDataType})) {
		print "metaDataType: $metaDataType ($metadata_keys{$metaDataType})\n";
	}
}

# Calculate the basalEnergyBurned by day, adjust to the correct numbers
my $command = "create table apple_xml_BasalEnergyBurnedAdj as select timestamp, sum(value) as basalEnergyBurned, sum(duration), sum(value)/(sum(duration)/86400) as basalEnergyBurnedAdj from apple_xml_BasalEnergyBurned where sourcename not like '%Sync Solver%'group by timestamp";
my $result = dbdo($db, $command, $verbose);

$db->disconnect;

#############
# Subroutines
#############
sub define_xml_rules {
	# The XML processing Rules: http://search.cpan.org/~jenda/XML-Rules-1.16/lib/XML/Rules.pm
	my @rules = (
		_default => sub {$_[0] => $_[1]->{_content}},
		# by default I'm only interested in the content of the tag, not the attributes
		bogus => undef,
		# let's ignore this tag and all inner ones as well
		# Record tags - start with the components, then when the container is reached do something with it.
		# sub is passed: sub { my ($tagname, $attrHash, $contexArray, $parentDataArray, $parser) = @_; ...}
		locale => sub {$_[0] => $_[1]->{_content}},
		HKCharacteristicTypeIdentifierDateOfBirth => sub {$_[0] => $_[1]->{_content}},
		HKCharacteristicTypeIdentifierBiologicalSex => sub {$_[0] => $_[1]->{_content}},
		HKCharacteristicTypeIdentifierBloodType => sub {$_[0] => $_[1]->{_content}},
		HKCharacteristicTypeIdentifierFitzpatrickSkinType => sub {$_[0] => $_[1]->{_content}},
		type => sub {$_[0] => $_[1]->{_content}},
		unit => sub {$_[0] => $_[1]->{_content}},
		value => sub {$_[0] => $_[1]->{_content}},
		sourceName => sub {$_[0] => $_[1]->{_content}},
		sourceVersion => sub {$_[0] => $_[1]->{_content}},
		device => sub {$_[0] => $_[1]->{_content}},
		creationDate => sub {$_[0] => $_[1]->{_content}},
		StartDate => sub {$_[0] => $_[1]->{_content}},
		endDate => sub {$_[0] => $_[1]->{_content}},
		workoutActivityType => sub {$_[0] => $_[1]->{_content}},
		duration => sub {$_[0] => $_[1]->{_content}},
		durationUnit => sub {$_[0] => $_[1]->{_content}},
		totalDistance => sub {$_[0] => $_[1]->{_content}},
		totalDistanceUnit => sub {$_[0] => $_[1]->{_content}},
		totalEnergyBurned => sub {$_[0] => $_[1]->{_content}},
		totalEnergyBurnedUnit => sub {$_[0] => $_[1]->{_content}},
		dateComponents => sub {$_[0] => $_[1]->{_content}},
		activeEnergyBurned => sub {$_[0] => $_[1]->{_content}},
		activeEnergyBurnedUnit => sub {$_[0] => $_[1]->{_content}},
		activeEnergyBurnedGoal => sub {$_[0] => $_[1]->{_content}},
		appleExerciseTime => sub {$_[0] => $_[1]->{_content}},
		appleExerciseTimeGoal => sub {$_[0] => $_[1]->{_content}},
		appleStandHours => sub {$_[0] => $_[1]->{_content}},
		appleStandHoursGoal => sub {$_[0] => $_[1]->{_content}},
		key => sub {$_[0] => $_[1]->{_content}},
		# Handle the Elements
		#HealthData => {},
		ExportDate => sub {
			print "Export Date: $_[1]->{value}\n";
		},
		Me => sub {
			my $dateOfBirth = $_[1]->{HKCharacteristicTypeIdentifierDateOfBirth};
			my $bioSex = $_[1]->{HKCharacteristicTypeIdentifierBiologicalSex};
			my $bloodType = $_[1]->{HKCharacteristicTypeIdentifierBloodType};
			my $skinType = $_[1]->{HKCharacteristicTypeIdentifierFitzpatrickSkinType};
		},
		Record => sub { # lets print the values, all the data is readily available in the attributes
			# Required: type, sourceName, startDate, endDate
			# Implied: unit, value, sourceVersion, device, creationDate
			print "Data: $_[1]->{type}, $_[1]->{unit}, $_[1]->{value}\n" if $verbose;
			$_[1]->{sourceName} = clean_wide_char($_[1]->{sourceName});
			$_[1]->{device} = clean_wide_char($_[1]->{device}) if $_[1]->{device};
			print "Source: $_[1]->{sourceName}" if $verbose;
			print ", $_[1]->{sourceVersion}" if ($_[1]->{sourceVersion} and $verbose);
			print ", $_[1]->{device}" if ($_[1]->{device} and $verbose);
			print "\n" if $verbose;
			print "Date: $_[1]->{creationDate}\n" if $verbose;
			print "From: $_[1]->{startDate} to $_[1]->{endDate}\n" if ($verbose);
			my $fields = "timestamp, startDate, endDate, sourceName";
			my ($timestamp, $recordTime, $recordTZ) = split " ", $_[1]->{startDate};
			$timestamp =~ s/\-//g;
			my $values = "\"$timestamp\", \"$_[1]->{startDate}\", \"$_[1]->{endDate}\", \"$_[1]->{sourceName}\"";
			$sourceNames{$_[1]->{sourceName}}++;
			$dataTypes{$_[1]->{type}}++;
			if ($_[1]->{unit}) {
				$units{$_[1]->{unit}}++;
				$fields .= ", units";
				$values .= ", \"$_[1]->{unit}\"";
			}
			if ($_[1]->{value}) {
				$fields .= ", valueFlag, value";
				if ($_[1]->{value} =~ /[A-Za-z]/) {
					#'value' is something like "isAsleep"
					$values .= ", \"$_[1]->{value}\", 0";
				} else {
					$values .= ", \"\", $_[1]->{value}";
				}
			}
			if ($_[1]->{device}) {
				$devices{$_[1]->{device}}++;
				$fields .= ", device";
				$values .= ", \"$_[1]->{device}\"";
			}
			if ($_[1]->{sourceVersion}) {
				$fields .= ", sourceVersion";
				$values .= ", \"$_[1]->{sourceVersion}\"";
			}
			if ($_[1]->{creationDate}) {
				$fields .= ", creationDate";
				$values .= ", \"$_[1]->{creationDate}\"";
			}
			# Determine the duration in fractions of a day
			my $startDate = Time::Piece->strptime($_[1]->{startDate}, "%Y-%m-%d %H:%M:%S %z");
			my $endDate = Time::Piece->strptime($_[1]->{endDate}, "%Y-%m-%d %H:%M:%S %z");
			my $duration = ($endDate->epoch - $startDate->epoch);#/(60*60*24); duration in s
			$fields .= ", duration";
			$values .= ", $duration";
			my $tablename = datatype_from_healthkit($_[1]->{type});
			my $command = "create table if not exists [$tablename] (timestamp Text, startDate TEXT PRIMARY KEY, endDate TEXT, sourceName Text, units Text, valueFlag TEXT, value REAL, sourceVersion TEXT, device TEXT, creationDate TEXT, duration REAL)";
			dbdo($db, $command, $verbose);
			$command = "insert or replace into [$tablename] ($fields) Values ($values)";
			dbdo($db, $command, $verbose);
			return; 
		},
		Correlation => sub {
			# Required: type, sourceName, startDate, endDate 
			# Implied: sourceVersion, device, creationDate
			$correlation_types{$_[1]->{type}}++;
			$_[1]->{sourceName} = clean_wide_char($_[1]->{sourceName});
			$sourceNames{$_[1]->{sourceName}}++;
			my $fields = "timestamp, startDate, endDate, sourceName";
			my ($timestamp, $recordTime, $recordTZ) = split " ", $_[1]->{startDate};
			$timestamp =~ s/\-//g;
			my $values = "\"$timestamp\", \"$_[1]->{startDate}\", \"$_[1]->{endDate}\", \"$_[1]->{sourceName}\"";
			if ($_[1]->{device}) {
				$devices{$_[1]->{device}}++;
				$fields .= ", device";
				$values .= ", \"$_[1]->{device}\"";
			}
			if ($_[1]->{sourceVersion}) {
				$fields .= ", sourceVersion";
				$values .= ", \"$_[1]->{sourceVersion}\"";
			}
			if ($_[1]->{creationDate}) {
				$fields .= ", creationDate";
				$values .= ", \"$_[1]->{creationDate}\"";
			}
			my $tablename = datatype_from_healthkit($_[1]->{type});
			my $command = "create table if not exists [$tablename] (timestamp Text, sourceName Text, startDate TEXT PRIMARY KEY, endDate TEXT, sourceVersion TEXT, device TEXT, creationDate TEXT)";
			dbdo($db, $command, $verbose);
			$command = "insert or replace into [$tablename] ($fields) Values ($values)";
			dbdo($db, $command, $verbose);
		},
		Workout => sub{
			# Required: workoutActivityType, sourceName, startDate, endDate
			# Implied: duration, durationUnit, totalDistance, totalDistanceUnit, totalEnergyBurned, totalEnergyBurnedUnit, sourceVersion, device, creationDate
			# This one has WorkoutEvent subtags
			$workoutActivityTypes{$_[1]->{workoutActivityType}}++;
			$_[1]->{sourceName} = clean_wide_char($_[1]->{sourceName});
			$_[1]->{device} = clean_wide_char($_[1]->{device}) if $_[1]->{device};
			$sourceNames{$_[1]->{sourceName}}++; # REQUIRED
			$devices{$_[1]->{device}}++ if $_[1]->{device};
			MetadataEntry => sub{
				# Required: key, value
				$metadata_keys{$_[1]->{type}}++;
			},
		},
		WorkoutEvent => sub{
			# REQUIRED: type, date
			$dataTypes{$_[1]->{type}}++;
		},
		ActivitySummary => sub{
			# Required: none
			# Implied: dateComponents, activeEnergyBurned, activeEnergyBurnedGoal, activeEnergyBurnedUnit, appleExerciseTime, appleExerciseTimeGoal, appleStandHours, appleStandHoursGoal
			my $command = "insert or replace into [apple_activity_summary] (timestamp, date, activeCalories, activeCaloriesGoal, exerciseTime, exerciseTimeGoal, standHours, standHoursGoal) Values (";
			my $date = $_[1]->{dateComponents};
			my $timestamp = $date;
			$timestamp =~ s/\-//g;
			$activitySummaries{$date}++;
			print "Summary: $date: $_[1]->{activeEnergyBurned}/$_[1]->{activeEnergyBurnedGoal} ($_[1]->{activeEnergyBurnedUnit})";# if $verbose;
			print ", $_[1]->{appleExerciseTime}/$_[1]->{appleExerciseTimeGoal} Active Minutes, $_[1]->{appleStandHours}/$_[1]->{appleStandHoursGoal} Stand Hours\n"; # if $verbose;
			$command .="$timestamp, \"$date\", $_[1]->{activeEnergyBurned}, $_[1]->{activeEnergyBurnedGoal}, $_[1]->{appleExerciseTime}, $_[1]->{appleExerciseTimeGoal}, $_[1]->{appleStandHours}, $_[1]->{appleStandHoursGoal})";
			dbdo($db, $command, $verbose);
		},
		#MetadataEntry => sub{
		#	# Required: key, value
		#	$metadata_keys{$_[1]->{type}}++;
		#},
	);
	return (@rules);
}

sub clean_wide_char {
	# sub to clean wide chars from a string
	my $string = shift;
	if ( $string =~ /([^\x00-\xFF])/) {
		# the wide char is the typographer's single quote (’)
		# let's replace it with an ascii char.
		my $wide_char = $1;
		$string =~ s/$1/'/g;
	}
	return $string;
}
sub make_db {
	Make the Database Structure
    print "making the database: $db\n" if $verbose;
    my %tables = (
        "apple_xml_activity_summary"=>"timestamp Integer, date TEXT PRIMARY KEY, activeCalories REAL, activeCaloriesGoal REAL, exerciseTime REAL, exerciseTimeGoal REAL, standHours REAL, standHoursGoal REAL",
		"apple_xml_health_records"=>"date text PRIMARY KEY, DietaryVitaminC Integer, AppleExerciseTime Integer, BloodPressureSystolic Integer, SleepAnalysis Integer, DietarySodium Integer, DistanceWalkingRunning Integer, DietarySugar Integer, AppleStandHour Integer, StepCount Integer, DietaryCalcium Integer, MindfulSession Integer, BloodAlcoholContent Integer, BodyMass Integer, DietaryCaffeine Integer, BodyMassIndex Integer, FlightsClimbed Integer, BasalEnergyBurned Integer, DietaryFatMonounsaturated Integer, DietaryFiber Integer, Height Integer, HeartRate Integer, WorkoutPause Integer, WorkoutResume Integer, ActiveEnergyBurned Integer, WorkoutMarker Integer, DietaryCholesterol Integer, BodyFatPercentage Integer, DistanceCycling Integer, DietaryWater Integer, DietaryCarbohydrates Integer, DietaryEnergyConsumed Integer, DietaryFatSaturated Integer, DietaryPotassium Integer, BloodPressureDiastolic Integer, DietaryIron Integer, DietaryFatTotal Integer, DietaryFatPolyunsaturated Integer, DietaryProtein Integer");
    foreach my $tablename (%tables) {
        if (exists $tables{$tablename} ) {
            my $command = "Create Table if not exists [$tablename] ($tables{$tablename})";
            my $result = dbdo($db, $command, $verbose);
        }
    }
    #build_tables_from_files($db);
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
sub datatype_from_healthkit {
	my $datatype = shift;
	my $prefix = "apple_xml_";
	$datatype =~ s/HKQuantityTypeIdentifier/$prefix/;
	$datatype =~ s/HKCategoryTypeIdentifier/$prefix/;
	$datatype =~ s/HKCorrelationTypeIdentifier/$prefix/;
	$datatype =~ s/HKCategoryValue/$prefix/;
	$datatype =~ s/HKWorkoutEventType/$prefix\_Workout/;
	return $datatype;
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
