#!/usr/bin/perl
#bandwidth by Dale Swanson Sept 05 2013
#get current bandwidth and send it to an Arduino


use strict;
use warnings;
use autodie;

use Time::HiRes qw(usleep nanosleep);


my $interface = 'eth0';
my $delay = 1000; #ms
my $delayscale = 1000; #ms / sec
my $bandscale = 1000; #multiply kbyte/sec by this for display
my $debug = 0;
my $prevrx = 0;
my $prevtx = 0;
my $currrx;
my $currtx;
my $bandrx;
my $bandtx;
my $port;

if (!$debug)
{
	# Set up the serial port
	use Device::SerialPort;
	$port = Device::SerialPort->new("/dev/ttyACM0"); #enter your port here

	# 19200, 81N on the USB ftdi driver
	$port->baudrate(9600); # you may change this value
	$port->databits(8); # but not this and the two following
	$port->parity("none");
	$port->stopbits(1);

	# now catch gremlins at start
	my $tEnd = time()+1; # 1 second in future
	while (time()< $tEnd) { # end latest after 2 seconds
		my $c = $port->lookfor(); # char or nothing
		next if $c eq ""; # restart if noting
		print $c; # uncomment if you want to see the gremlin
		last;
	}
	while (1) { # and all the rest of the gremlins as they come in one piece
		my $c = $port->lookfor(); # get the next one
		last if $c eq ""; # or we're done
		print $c; # uncomment if you want to see the gremlin
	}
	$port->write("0\n");
}

while (1)
{#loop forever
	my $result = `ifconfig $interface`; #get bandwidth data
	#RX bytes:3361794444 (3.3 GB)  TX bytes:2723988656 (2.7 GB)
	$result =~ m/RX bytes:(\d+).+TX bytes:(\d+)/; #parse out RX and TX bytes
	$currrx = $1;
	$currtx = $2;
	
	$bandrx = ($currrx - $prevrx) / ($delay*$delayscale) * $bandscale; #convert to kbyte/sec
	$bandtx = ($currtx - $prevtx) / ($delay*$delayscale) * $bandscale;
	$bandrx = int($bandrx+0.5);
	$bandtx = int($bandtx+0.5);
	
	$prevrx = $currrx;
	$prevtx = $currtx;
	
	print "\nRX: $bandrx TX: $bandtx";
	if (!$debug) {$port->write("$bandrx, $bandtx\n");}
	
	
	usleep($delay * $delayscale); #bandwidth only updates once per second
}


if (!$debug) {$port->write("0\n");}


print "\nDone\n\n";
