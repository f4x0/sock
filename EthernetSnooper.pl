#!/usr/bin/perl -w
use 5.6.0;

use strict;
use Net::PcapUtils;
use NetPacket::Ethernet qw(:ALL);

use XtraType;

our %typeTotals = ();
our %typeDesc = (
			0x0800 => 'IPv4',
			0x0806 => 'ARP',
			0x809B => 'AppleTalk',
			0x814C => 'SNMP',
			0x86DD => 'IPv6',
			0x880B => 'PPP',
			0x8137 => 'NOVELL1',
			0x8138 => 'NOVELL2',
			0x8035 => 'RARP',
			0x876B => 'TCP/IPc',
			);
our $numPackets = 0;
foreach my $etype(keys %typeDesc){$typeTotals{$etype}=0;}

sub gotPacket{
	my ($userArg, $header, $packet) = @_;
	my $frame = NetPacket::Ethernet->decode($packet);
	if($frame->{type}<1501){$typeTotals{1500}++;}
	else{$typeTotals{$frame->{type}}++;}
	#foreach (keys %{$frame}){print;}	
	#print $frame->{src_mac};
	$numPackets++;
}

sub displayResults{
	print "-"x10,"$numPackets frames processed","-"x10,"\n";
	
	foreach my $etype (sort keys %typeDesc){
	printf "%10s generated ", $typeDesc{$etype};
	printf "%5d packets \n",$typeTotals{$etype};
	}

	printf "\nNon Ethernet II(DIX) frames generated %3d packets\n",$typeTotals{1500};
	#print "\n","-"x10,"Raw Statistics","-"x10,"\n";
	#print "frameType\tFrequency\n\n";
	#foreach my $eTotal (sort keys %typeTotals)
	#{printf "%5lx\t\t%5d\n",$eTotal,$typeTotals{$eTotal};}
}
my $status = Net::PcapUtils::loop(
					\&gotPacket,
					NUMPACKETS => 1000,
					);
if( $status){
	print "Net::PcapUtils::loop retured $status \n";
}
else{
	displayResults;
}

