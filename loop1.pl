#!/usr/bin/perl -w
use strict;
use Net::PcapUtils;
$| = 1;
sub gotPacket{
	my ($userArg, $header, $packet) = @_;
	print "Got a packet!\n";
	print "User argument		$userArg\n";
	print "The Header data is 	$header\n";
	foreach my $name (sort keys %{$header})
	{
		print "$name -> $header->{$name}\n";
	}
	print "The Packet Data is 	$packet\n","--"x10,"\n";
}

my $status = Net::PcapUtils::loop(
		\&gotPacket,
		NUMPACKETS => 10,
		FILTER => 'ip',);

if($status){
	print "Net::PcapUtils::loop returned $status\n";
}
