#!/usr/bin/perl -w
use 5.6.0;

use strict;
use Net::PcapUtils;
use NetPacket::Ethernet qw(:strip);
use NetPacket::IP;
use XtraType;

our %ipTypeTotal = ();
our %ipTypeDesc = (
		0 => 'IP',
		1 => 'ICMP',
		2 => 'IGMP',
		4 => 'IP/IP',
		6 => 'TCP',
		17 => 'UDP',
);

our $numDatagram = 0;
sub gotPacket{
	my $packet = shift;
	my $ipDatagram= NetPacket::IP->decode(NetPacket::Ethernet::eth_strip($packet));
	if(! exists $ipTypeTotal{$ipDatagram->{proto}}){
	$ipTypeTotal{$ipDatagram->{proto}} = 1;
	}else{
	$ipTypeTotal{$ipDatagram->{proto}}++;
	}
	$numDatagram++;
}


sub displayResults{
	print "Number of datagrams Processed = $numDatagram\n\n";
	print "-"x15,"Packet Type Statistics","-"x15,"\n";
	foreach my $ipTypeKey(sort {$a <=> $b}keys %ipTypeTotal){
	printf "%5s\t ->%5d\n",$ipTypeDesc{$ipTypeKey},$ipTypeTotal{$ipTypeKey};
	}
}
my $pktHandle= Net::PcapUtils::open(FILTER =>'ip');
if(!ref($pktHandle)){
		print "Net::PcapUtilis::open retured $pktHandle\n";
		exit;
	}
my $reqTime = 3; #Time to snoop in minutes
my $now = time;
my $finalTime = $now+(60*$reqTime);

while(($now = time) < $finalTime){
		my ($nextPacket, %nextHeader) = Net::PcapUtils::next($pktHandle);
		gotPacket($nextPacket);
}

displayResults;

