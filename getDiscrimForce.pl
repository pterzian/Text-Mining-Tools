#!/usr/bin/env perl

=head1 NAME


=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 OPTIONS

--Help|help|h, produces this help file.

--verbose[no-verbose]|Verbose[no-Verbose]|v[no-v], boolean option to print out warnings during execution. Warnings and errors are redirected to STDERR. Defaults to no-verbose (silent mode).

=head1 AUTHORS


=head1 VERSION

1.00

=head1 DATE

xx/xx/2016

=cut

# libraries
use warnings;
use strict;
use Pod::Usage;
use Getopt::Long;
use File::Basename;
use Data::Dumper;
use List::Util qw< sum >;
use 5.10.0;

# scalars
my $help;
my $verbose;
my $debug;					# debug purposes only
my $wordList;
my $nbTranscrit;
my $abundanceThreshold;

# lists
my @currentWordregex;

# hashs
my %wordList;


# functions
sub error ($) {
	# management of error messages and help page layout, will stop execution
	# local arguments passed:	 1st, error message to output
	my $error = shift;
	my $filename = basename($0);
	pod2usage(-message => "$filename (error): $error Execution halted.", -verbose => 1, -noperldoc => 1);
	exit(2);
}

sub warning ($) {
	# management of warnings and execution carry on
	# local arguments passed:	 1st, warning message to output
	if ($verbose) {
		my $message = shift;
		my $filename = basename($0);
		warn("$filename (info): ".$message."\n");
	}
}

sub debug ($) {
	# management of debugging messages
	# local arguments passed:	 1st, warning message to output
	# no return value
	if ($debug) {
		my $message = shift;
		warn(Dumper($message));
	}
}


MAIN: {
	GetOptions(	"help|Help|h"								=> \$help,
				"verbose|Verbose|v!"						=> \$verbose,
				"List|list|l=s"								=> \$wordList,
				"abundanceThreshold|AbundanceThreshold|t=i"	=> \$abundanceThreshold
				);
	if ($help) {
		pod2usage(-verbose => 2, -noperldoc => 1);
	exit;
	}


	if($wordList){
		open(LIST, "<", "$wordList") or die ("Can't open file : $wordList");
		while (my $line = <LIST>){
				chomp($line);
				if (length($line)>2) { $wordList{$line} = 0; }				
		}
		close(LIST);	  		
	}
	
	if (! $abundanceThreshold) {
		$abundanceThreshold = 6;
	}
	
	#my $nb = keys(%wordList);
	#print "$nb";	

	warning("Processing table from STDIN...");
	while ( my $line = <STDIN> ) { 
		chomp $line;
		$line =~ s/-/ /g;## remplace les points, tiré et virgule par un espace
		#print "$line\n"; 
		@currentWordregex = split(" ",$line);
		foreach my $key (@currentWordregex){
				#print "$currentWordregex[$key]\n";
				if (defined($wordList{$key})) { $wordList{$key} += 1; }	
		}
		
		$nbTranscrit++;			
		
	}
	
	warning("Processing data");
		
	
	foreach my $key(keys %wordList){
		if ($wordList{$key} != 0){
			my $discriminateValue = 1 - ($wordList{$key} / $nbTranscrit);
			print $key."\t".$discriminateValue."\n";
		}	
	}	 
	
	warning("...finished");
	
	

}	# end of MAIN





#../R/to_process/results/CalcDiscrim_MaxMean/uniq_annot_processed.word.only.txt
