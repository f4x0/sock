#!/usr/bin/perl -w
use 5.6.0;

use strict;
use Net::PcapUtils;
use NetPacket::Ethernet qw(:ALL);
use NetPacket::IP;
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
our %srce = ();
our %dest = ();
our %e2ip = ();

foreach my $etype(keys %typeDesc){$typeTotals{$etype}=0;}
my $ipType = 0;
sub gotPacket{
	my ($userArg, $header, $packet) = @_;
	my $frame = NetPacket::Ethernet->decode($packet);
	if($frame->{type}<1501){$typeTotals{1500}++;}
	else{$typeTotals{$frame->{type}}++;}
	$srce{$frame->{src_mac}}++;
	$dest{$frame->{dest_mac}}++;
	#foreach (keys %{$frame}){print;}	
	#print $frame->{src_mac};
	$numPackets++;
	if($frame->{type} == NetPacket::Ethernet::ETH_TYPE_IP){
		my $ipDatagram = NetPacket::IP->decode(NetPacket::Ethernet::eth_strip($packet));
		$e2ip{$frame->{src_mac}} = $ipDatagram->{src_ip};
		$e2ip{$frame->{dest_mac}} = $ipDatagram->{dest_ip};
		$ipType++;
	}
	else {
	$e2ip{$frame->{src_mac}} = 'NO_IP';
	$e2ip{$frame->{dest_mac}}='NO_IP';}

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

	printf "\n\n---------------------Route Statistics---------------\n";
	printf "-----------------------Source generated--------------\n";
	foreach my $maddr (sort keys %srce)
	{
		printf "$maddr, %-18s ->  %5d\n",($e2ip{$maddr}),$srce{$maddr};
	}
	printf "---------------------Destination Generated-----------\n";
	foreach my $maddr (sort keys %dest)
	{
		printf "$maddr, %-18s ->  %5d\n",$e2ip{$maddr},$dest{$maddr};
	}
	printf "\n------------------IP Type Packets -> $ipType-------\n";
	#foreach my $maddr (sort keys %e2ip){print "$maddr -> $e2ip{$maddr}\n";}
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

