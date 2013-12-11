#!/usr/bin/perl

my @results ;
my $gindx = 0 ;

sub find_a9_avg_time
{
	my $num_threads = $_[0] ;
	my $num_runs = $_[1] ;
	my $total_time = 0 ;
	my $cur_runs = $num_runs ;
	for($i=0 ; $i<$num_runs ; $i++) {
		my @time = `sudo ./app -l $num_threads` ;
		my $length = @time ;
		my $time_str= $time[$length-1] ;
		chomp($time_str) ;
		my $cur_time = 0 ;
		if($time_str =~ m/^Time[\s\S]+\d+\.\d+\,(\d+\.\d+)\,\d+\.\d+\,\d+\.\d+\,\d+\.\d+\,\d+\.\d+\>$/) {
			$cur_time = $1 ;
		}
		if($cur_time > 16.5) {
			$cur_runs = $cur_runs - 1 ;
		        print "cur_runs = $cur_runs\n" ;
		} else {
		       $total_time += $cur_time ;
		       print "cur_time = $cur_time\n" ;
		}
		sleep(3) ;
	}
	my $avg_time = $total_time/$cur_runs ;
	print "Average time with #threads=$num_threads : $avg_time\n" ;
}

sub find_avg_time
{
	#my $num_threads = $_[0] ;
	#my $num_runs = $_[1] ;
	my $size_m3 = $_[0] ;
	my $size_dsp = $_[1] ;
	my $num_runs = $_[2] ;
	my $total_time = 0 ;
	my $cur_runs = $num_runs ;
	for($i=0 ; $i<$num_runs ; $i++) {
		#my @time = `sudo ./app -l $num_threads` ;
		#my @time = `sudo ./app -r sysm3=512` ;
		#my @time = `sudo ./app -r dsp=512` ;
		#my @time = `sudo ./app -r dsp=4096` ;
		my $time_threshold ;
		my @time ;
		if($size_m3 > 0 and $size_dsp > 0) {
			print "sudo ./app -l 2 -r sysm3=$size_m3,dsp=$size_dsp\n" ;
			@time = `sudo ./app -l 2 -r dsp=$size_dsp,sysm3=$size_m3` ;
			$time_threshold = 10.5 ;
		} elsif($size_m3 > 0) {
			if($size_m3 == 4194304) {
				print "sudo ./app -r sysm3=$size_m3\n" ;
				@time = `sudo ./app -r sysm3=$size_m3` ;
			} else {
				print "sudo ./app -l 2 -r sysm3=$size_m3\n" ;
				@time = `sudo ./app -l 2 -r sysm3=$size_m3` ;
			}
			$time_threshold = 51.0 ;
		} elsif($size_dsp > 0) {
			if($size_dsp == 4194304) {
				print "sudo ./app -r dsp=$size_dsp\n" ;
				@time = `sudo ./app -r dsp=$size_dsp` ;
			} else {
				print "sudo ./app -l 2 -r dsp=$size_dsp\n" ;
				@time = `sudo ./app -l 2 -r dsp=$size_dsp` ;
			}
			$time_threshold = 55.0 ;
		} else {
			print "sudo ./app -l 2\n" ;
			@time = `sudo ./app -l 2` ;
			$time_threshold = 18.0 ;
		}
		#my @time = `sudo ./app -l 2` ;
		my $length = @time ;
		my $time_str= $time[$length-1] ;
		chomp($time_str) ;
		my $cur_time = 0 ;
		if($time_str =~ m/^Time[\s\S]+\d+\.\d+\,(\d+\.\d+)\,\d+\.\d+\,\d+\.\d+\,\d+\.\d+\,\d+\.\d+\>$/) {
			$cur_time = $1 ;
		}
		#if($cur_time > $time_threshold) {
		#	$cur_runs = $cur_runs - 1 ;
		#        print "cur_runs = $cur_runs\n" ;
		#} else {
		       $total_time += $cur_time ;
		       print "cur_time = $cur_time\n" ;
		#}
		sleep(3) ;
	}
	if($cur_runs > 0) {
		my $avg_time = $total_time/$cur_runs ;
		print "Average time : m3=$size_m3,dsp=$size_dsp : $avg_time\n" ;
		$results[$gindx] = "Average time : m3=$size_m3,dsp=$size_dsp : $avg_time" ;
		$gindx = $gindx+1 ;
	} else {
		print "Number of valid runs equal to zero\n" ;
	}
}

#find_avg_time(0, 0, 10) ;
#find_avg_time(0, 4194304, 10) ;
#find_avg_time(4194304, 0, 10) ;
#find_avg_time(655360, 720896, 10) ;
#find_avg_time(782336, 811008, 10) ;

#find_avg_time(589824, 720896, 5) ;
#find_avg_time(655360, 786432, 5) ;
#find_avg_time(589824, 655360, 5) ;
#find_avg_time(524288, 786432, 5) ;
#find_avg_time(655360, 720896, 5) ;
#find_avg_time(720896, 655360, 5) ;
#find_avg_time(720896, 720896, 5) ;

#find_avg_time(524288, 720896, 5) ;
#find_avg_time(655360, 589824, 5) ;
#find_avg_time(655360, 655360, 5) ;
#find_avg_time(720896, 589824, 5) ;
#find_avg_time(720896, 720896, 5) ;
#find_avg_time(720896, 786432, 5) ;
#find_avg_time(0, 0, 10) ;
#find_avg_time(0, 4194304, 10) ;
#find_avg_time(4194304, 0, 10) ;
#find_avg_time(4, 44, 10) ;
#find_avg_time(0, 128, 10) ;
#find_avg_time(128, 0, 10) ;
#find_a9_avg_time(2, 10) ;
for($indx1=352; $indx1<=416; $indx1+=32) {
	for($indx2=352; $indx2<=416 ; $indx2+=32) {
		if($indx2 <= $indx1) {
			my $block_size = 2048 ;
			my $m3_size = $indx1 * $block_size ;
			my $dsp_size = $indx2 * $block_size ;
			find_avg_time($m3_size, $dsp_size, 1) ;
		}
	}
}

foreach $item (@results) {
	print "$item\n" ;
}

