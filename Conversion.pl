
#!/usr/local/bin/perl
#
# Change raw timecode data to different format
#
# timecode data event looks like:
# 
# Event: 1
# 00:01:05:23
# 00:01:27:21
# a-2-9
# 
# Event: 2
# 00:01:56:13
# 00:02:03:19
# a-3-9
# 
# ...and so on...
#
# Want to change it to the form:
#
# a-2-9 = 21.93 seconds = 658 frames
# a-3-9 = 7.20 seconds = 216 frames
#

open(FP,"<log.txt");

$first = 1;
$total = 0;

while($line = <FP>) {

    if ($line =~ /^\d\d/ && $first) {
	$in = $line;
	$first = 0;
    } elsif ($line =~ /^\d\d/ && !$first) {
	$out = $line;
	$first = 1;
    } elsif ($line =~ /^\w-/) {
	$shot = $line;
	chop($shot);

	# parse timecodes and
	# translate in and out into seconds
	$in =~ /(\d\d):(\d\d):(\d\d):(\d\d)/;
	$hrs = $1;
	$mns = $2;
	$scs = $3;
	$fms = $4;
	$inSecs = $hrs * 3600 + $mns * 60 + $scs + $fms / 30;

	$out =~ /(\d\d):(\d\d):(\d\d):(\d\d)/;
	$hrs = $1;
	$mns = $2;
	$scs = $3;
	$fms = $4;
	$outSecs = $hrs * 3600 + $mns * 60 + $scs + $fms / 30;

	# calc duration
	$dur = $outSecs - $inSecs;
	$total += $dur;

	# print line
	printf("$shot = %.2f seconds = %d frames\n", $dur, $dur * 30);
    }
}

print "total = ".($total / 60)." mins\n";

close FP;