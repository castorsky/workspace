#!/usr/bin/env perl

use File::Find;
use File::Copy;
use Time::Local;
use Time::Piece;
use Getopt::Long;

# Check for parameters. $Dir and $PartialName are mandatory
$Dir = "";
$PartialName = "";
$ConfigFile = "";
my $UsageMessage = "\nUsage: script.pl --dir <directory_name> --name <archive_name>\n";
GetOptions ("dir=s", =>  \$Dir,
        "name=s", => \$PartialName)
        or die "Invalid set of arguments.$UsageMessage";
die "Missing directory name.$UsageMessage" unless $Dir;
die "Missing archive name.$UsageMessage" unless $PartialName;
$Dir =~ s/\/+$//;

# Set of subdirectories for backup storage
$Current="$Dir/current";
$Previous="$Dir/previous";
$Old="$Dir/old";

$Cmd = "/usr/bin/dar -Q -B $Dir/$PartialName.dcf";

# Remove old archives after N days
$Rotate = 13*86400;

$Day = localtime->mday;
$Day =~ s/(^[0-9]$)/0$1/;
$Month = localtime->mon;
$Month =~ s/(^[0-9]$)/0$1/;
$Year = localtime->year;
$WeekNumber = localtime->week;  # Number of current week
$WeekDay = localtime->_wday; # Day of week (Sunday = 0)

# Converts date's part of filename into UNIX-like timestamp 
sub TimestampFromFilename {
	my $var = shift;
	
	# Searching for date substring (8 digits)
	$var =~ m/[0-9]{8}/;
	
	# Redefine variable with digits-only
	$var = $&;
	
	# Split date string into partial elements
	my $Year = substr $var, 0, 4;
	my $Month = substr $var, 4, 2;
	my $Day = substr $var, 6, 2;
	
	# Convert human-readable date to UNIX format
	my $timestamp = timelocal(0, 0, 0, $Day, $Month-1, $Year-1900);
	return $timestamp;
}

# Returns reference to %HASH, be careful.
# Function has 2 mandatory arguments: directory (relative to
# global $Dir) and archive type (which can be "full" or "diff").
sub ListDirectory {
	my $Directory = $_[0];
	
	# Second argument. Variable is defined as LOCAL
	# for inner subroutine visibility.
	local $TypeOfArchive = $_[1];
	
	# Hash variable is also LOCAL by the same reason
	local %hash;
	find(\&executor, "$Dir/$Directory");
	sub executor() {
		# Compare filenames with regexp. Searching
		# for desired type of archive
		if (m/($TypeOfArchive)_[0-9]{8}.*\.dar$/i) {
       		$hash{$_} = TimestampFromFilename($_);
		}
	}
	return \%hash;
}

###############################################################################
# First check if it's time to create new full archive (full archive have to be
# created every odd week at Sunday).
# If it is then move old full archive from PREVIOUS directory to OLD,
# clean PREVIOUS and move all files from CURRENT to PREVIOUS. Create new
# full archive in CURRENT.
# If not then create new diff for existent full backup and delete the oldest
# diff in PREVIOUS directory.
###############################################################################
foreach ($Current, $Previous, $Old) {
    if (!-d $_) { `mkdir -p $_`; }
}
if (($WeekDay == 0) && ($WeekNumber%2)) {
	# Find full backup in PREVIOUS and move it to directory OLD.
	my $list = ListDirectory("previous", "${PartialName}_full");
	foreach my $name (keys %$list){
		move("$Previous/$name","$Old/$name");
	}
	# Other archives in PREVIOUS have to be deleted (except hidden files).
	opendir(my $dh, "$Previous/") or warn "Can't open the directory: $dh";
	@filelist = readdir($dh);
	foreach my $file (@filelist) {
		$_ = $file;
		if (!m/(^\.)/ && m/${PartialName}/)
		{
			unlink "$Previous/$_" or warn "Could not unlink $_: $!";
		}
	}
	closedir $dh;
	# Move all files from CURRENT to PREVIOUS (except hidden files)
	opendir ($dh1, "$Current") or warn "Can't open the directory: $dh1";
	@filelist = readdir($dh1);
	foreach my $file (@filelist) {
		$_ = $file;
		if (!m/(^\.)/ && m/${PartialName}/) {
			move("$Current/$_", "$Previous/$file") or warn "Could not move $_: $!";
		}
	}
	closedir $dh1;
	
	# Create new full backup
	`$Cmd -c $Current/${PartialName}_full_$Year$Month$Day`;
} else {
	# Create new diff at CURRENT and delete the oldest diff at PREVIOUS
	# Find full backup at CURRENT directory
	my $list = ListDirectory("current", "${PartialName}_full");
	my @keys = keys %$list;
	my $fname = pop @keys;
	
	# Throw away DAR suffix
	$fname =~ s/(.*[0-9]{8}).*/$1/;

	# If there are no full backup then create it.
	if ($fname eq "") {
		`$Cmd -c $Current/${PartialName}_full_$Year$Month$Day`;
	} else {
		`$Cmd -c $Current/${PartialName}_diff_$Year$Month$Day -A $Current/$fname`;
	}
	
	# Calculate current timestamp
	my $timestamp = timelocal(0, 0, 0, $Day, $Month-1, $Year-1900);
	
	# Find all diff backups in PREVIOUS directory and compare timestamps with 
	# the current one. Files with timestamps older then "$Rotate" seconds
	# are to be deleted.
	$list = ListDirectory("previous","${PartialName}_diff");
	if (%$list) {
		while (($name, $t_stamp) = each(%$list)) {
			if (($timestamp - $t_stamp) >= $Rotate) {
				unlink "$Previous/$name" or warn "Could not unlink $name: $!";
			}
		}
	}
}

