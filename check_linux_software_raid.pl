#!/usr/bin/env perl

# Get status of Linux software RAID for Cloudkick
# Author: Michal Ludvig <michal@logix.cz>
#         http://www.logix.cz/michal/devel/nagios
# Adapted to Cloudkick by Ben Firshman <ben@firshman.co.uk>
# 
# Simple parser for /proc/mdstat that outputs status of all
# or some RAID devices. Possible results are OK and CRITICAL.
# It could eventually be extended to output WARNING result in 
# case the array is being rebuilt or if there are still some 
# spares remaining, but for now leave it as it is.
# 
# To run the script remotely via SNMP daemon (net-snmp) add the
# following line to /etc/snmpd.conf:
# 
# extend raid-md0 /root/parse-mdstat.pl --device=md0
# 
# The script result will be available e.g. with command:
# 
# snmpwalk -v2c -c public localhost .1.3.6.1.4.1.8072.1.3.2

use strict;
use Getopt::Long;

# Sample /proc/mdstat output:
# 
# Personalities : [raid1] [raid5]
# md0 : active (read-only) raid1 sdc1[1]
#       2096384 blocks [2/1] [_U]
# 
# md1 : active raid5 sdb3[2] sdb4[3] sdb2[4](F) sdb1[0] sdb5[5](S)
#       995712 blocks level 5, 64k chunk, algorithm 2 [3/2] [U_U]
#       [=================>...]  recovery = 86.0% (429796/497856) finish=0.0min speed=23877K/sec
# 
# unused devices: <none>

my $file = "/proc/mdstat";
my $device = "all";

# Get command line options.
GetOptions ('file=s' => \$file,
	'device=s' => \$device,
	'help' => sub { &usage() } );

## Strip leading "/dev/" from --device in case it has been given
$device =~ s/^\/dev\///;

## Return codes for Nagios
my %ERRORS=('OK'=>0,'WARNING'=>1,'CRITICAL'=>2,'UNKNOWN'=>3,'DEPENDENT'=>4);

## This is a global return value - set to the worst result we get overall
my $retval = 0;

my (%active_devs, %failed_devs, %spare_devs);

my $status = "ok";
my @status_string = ();

open FILE, "< $file" or die "Can't open $file : $!";
while (<FILE>) {
	next if ! /^(md\d+)+\s*:/;
	next if $device ne "all" and $device ne $1;
	my $dev = $1;

	my @array = split(/ /);
	for $_ (@array) {
		next if ! /(\w+)\[\d+\](\(.\))*/;
		if ($2 eq "(F)") {
			$failed_devs{$dev} .= "$1,";
		}
		elsif ($2 eq "(S)") {
			$spare_devs{$dev} .= "$1,";
		}
		else {
			$active_devs{$dev} .= "$1,";
		}
	}
	if (! defined($active_devs{$dev})) { $active_devs{$dev} = "none"; }
		else { $active_devs{$dev} =~ s/,$//; }
	if (! defined($spare_devs{$dev}))  { $spare_devs{$dev}  = "none"; }
		else { $spare_devs{$dev} =~ s/,$//; }
	if (! defined($failed_devs{$dev})) { $failed_devs{$dev} = "none"; }
		else { $failed_devs{$dev} =~ s/,$//; }
	
	$_ = <FILE>;
	/\[(\d+)\/(\d+)\]\s+\[(.*)\]$/;
	my $devs_total = $1;
	my $devs_up = $2;
	my $stat = $3;
	if ($devs_total > $devs_up or $failed_devs{$dev} ne "none") {
		$status = "err";
		$retval = 1;
	}

	push(@status_string, "$dev [$stat] has $devs_up of $devs_total devices active");
}

print "status $status " . join(", ", @status_string);
print "\n";

close FILE;
exit $retval;

# =====
sub usage()
{
	printf("
Check status of Linux SW RAID

Author: Michal Ludvig <michal\@logix.cz> (c) 2006
        http://www.logix.cz/michal/devel/nagios

Usage: check_linux_software_raid.pl [options]

  --file=<filename>    Name of file to parse. Default is /proc/mdstat
  --device=<device>    Name of MD device, e.g. md0. Default is \"all\"

");
	exit(1);
}



