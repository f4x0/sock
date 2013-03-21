#!/usr/bin/perl -w
use 5.6.0;

use strict;
use Net::PcapUtils;
use NetPacket::Ethernet qw(:ALL);
use NetPacket::IP;
use XtraType;

our %ttlTotal = ();
our $numDatagram = 0;
sub gotPacket{
	my $packet = shift;
	my $ipDatagram= NetPacket::IP->decode(NetPacket::Ethernet::eth_strip($packet));
	if(! exists $ttlTotal{$ipDatagram->{ttl}}){
	$ttlTotal{$ipDatagram->{ttl}} = 1;
	}else{
	$ttlTotal{$ipDatagram->{ttl}}++;
	}
	$numDatagram++;
}


sub displayResultsTTL{
	print "Number of Datagrams Processed $numDatagram\n";

	my $minttl = 256;
	my $maxttl = 0;
	my $avgttl = 0;
	foreach my $curttl(keys %ttlTotal){
		if($curttl < $minttl){$minttl = $curttl;}
		if($curttl > $maxttl){$maxttl = $curttl;}
		$avgttl = $avgttl + $curttl * $ttlTotal{$curttl};
	}
	$avgttl = $avgttl/$numDatagram;

	print "-"x40,"\n\t\tTTL Statistics\n";
	printf "Maximum TTL Value = %3d\n",$maxttl;
	printf "Minimum TTL Value = %3d\n",$minttl;
	printf "Average TTL Value = %3d\n",$avgttl;
	print "-"x10,"TTL Distribution","-"x10,"\n";
	foreach my $ttlkey(sort {$a <=> $b}keys %ttlTotal){
	printf "TTL Value: %3d\t Freq: %3d\n",$ttlkey,$ttlTotal{$ttlkey};
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

displayResultsTTL;

