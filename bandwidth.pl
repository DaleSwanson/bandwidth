#!/usr/bin/perl
#bandwidth by Dale Swanson Sept 05 2013
#get current bandwidth and send it to an Arduino


use strict;
use warnings;
use autodie;

use Time::HiRes qw(usleep nanosleep);

# Set up the serial port
use Device::SerialPort;
my $port = Device::SerialPort->new("/dev/ttyACM0");

# 19200, 81N on the USB ftdi driver
$port->baudrate(9600); # you may change this value
$port->databits(8); # but not this and the two following
$port->parity("none");
$port->stopbits(1);

# now catch gremlins at start
my $tEnd = time()+2; # 2 seconds in future
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






for (my $i=0; $i<9999; $i++)
{
	print "\n$i";
	$port->write("$i\n");
	usleep(250 * 1000);
}





$port->write("0\n");






print "\nDone\n\n";
