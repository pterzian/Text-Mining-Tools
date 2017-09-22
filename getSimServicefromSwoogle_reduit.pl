#!/usr/bin/env perl

=head1 NAME

getSimServicefromSwoogle

=head1 SYNOPSIS

getSimServicefromSwoogle [--no-verbose] [--separator="\t"] [--no-STS] [--no-ID] [--no-diff] [--no-LineToSkip] [--no-regexp]

=head1 DESCRIPTION

Recovers Semantic Similarity score from Swoogle Web API given a flow of strings on STDIN. Default lines of the flow needs four columns, separated with tabulation, containing the sentences or the words to compare preceded by their identification name as here : [id1]\t[word1]\t[id2]\t[word2]. Default mode only accept identical ids for each columns. Ids can differ when option -diff is on or they can also be omitted as here : [word1]\t[word2] using the option -id which automatically add accession numbers before the score on the output. This option is not compatible with the default line. 

Two methods of semantic similarity can be called to get a similarity score. Default mode only accepts verbs and short nouns but using the -STS option will call the Semantic Textual Similarity comparaison that accepts sentences.
     
NOTE : Written english is the only language processed here.

=head1 OPTIONS

--Help|help|h, produces this help file.

--verbose[no-verbose]|Verbose[no-Verbose]|v[no-v], boolean option to print out warnings during execution. Warnings and errors are redirected to STDERR. Defaults to no-verbose (silent mode)

--STS|sts|s, use the STS service that accept sentences or "bags of words" separated with spaces. Default mode use simple word comparison service.

--Delimiter|delimiter|s=s, define the columns delimiter in the lines given in STDIN and printed in the output. Default is tabulations (-s="\t")

--Identification|id|i, add a column of accession numbers beside the score. With this option you only needs two columns storing your sentences or words to analyse. Default needs an identification column in front of each sentences, so the sentences to compare will be on the second and fourth columns of the line. 

--differentID|diff|di, change the entry specifications to accept unequal identification names in a line. Default will automatically check for identical identification in the first and third column of the line

--regexp|Regexp|r=s, this option give you the hability to exclude lines that contain a specific pattern that is given to this option. The pattern must be given as a perl regular expression. This option can be called several time for the same command.

--SkipLine|skipline|s=s, give a number n to this option to skip n lines given in STDIN. Default will run each line. 

=head1 AUTHORS

Paul TERZIAN
 
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
use HTTP::Status;
use LWP::Simple;
use 5.10.0;

# scalars
my $help; # help flag
my $verbose; # explanation flag
my $debug; # debug purposes only
my $sts; # Use the SEMANTIC TEXTUAL SIMILARITY method
my $identification; # add a number of processing to each line in STDOUT
my $differentID; # check if identification columns have the same name for each rowsl.
my $currentId; # print Identification names or numbers in front of each scores
my $currentId2;
my $url = "http://swoogle.umbc.edu/SimService/GetSimilarity?operation=api";	# Default Semantic Similarity service
my $urlSTS = "http://swoogle.umbc.edu/StsService/GetStsSim?operation=api";	# Semantic Textual Similarity (STS) service
my $delimiter; # contain the column delimiter for a given input and output
my $compteurRegexp; # stock le nombre d'occurence d'expressions régulières passées en paramètres
my $nbLineToSkip; 

# lists
my @regexp;

# hashs

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
		my $filename = basename($0); # $0 variable contient le chemin par lequel a été lancé le script
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

sub urlConstructor($){ 
	# prend en paramètre une ligne composée de deux identifiants identiques et de deux phrases différentes.
	# intègre les deux annotations dans l'URL correspondante et renvois l'annotation
	my @annot = split($delimiter,shift);
	my $currentUrl;
	if (!$identification){
		if (scalar(@annot) != 4) {	error("The number of columns in your line doesn't feet in this mode, number needed in default mode is 4, check your columns or delimiter");	}
		if ($differentID){
			$currentId = $annot[0];
			$currentId2 = $annot[2];
			if (!$sts){	$currentUrl = $url."&phrase1=$annot[1]&phrase2=$annot[3]";	}
			else { $currentUrl = $urlSTS."&phrase1=$annot[1]&phrase2=$annot[3]";	}
		}
		else{
			if ($annot[0] ne $annot[2]){
				error("Ids given in the first and third column don't match");
			}
			$currentId = $annot[0];
			$currentId2 = $annot[2];
			if (!$sts){	$currentUrl = $url."&phrase1=$annot[1]&phrase2=$annot[3]";	}
			else { $currentUrl = $urlSTS."&phrase1=$annot[1]&phrase2=$annot[3]";	}
		}
	}
	else{
		$currentId++;
		$currentId2++;
		if (scalar(@annot) != 2) {	error("Number of columns needed with the option -id is 2, check for you columns or delimiter");	}
		if (!$sts){ $currentUrl = $url."&phrase1=$annot[0]&phrase2=$annot[1]"; 	}
		else {	$currentUrl = $urlSTS."&phrase1=$annot[0]&phrase2=$annot[1]";	}
				
	}
	return($currentUrl, $currentId, $currentId2);
}

sub handleRegexpOption(@){
	# test la présence d'expréssions régulière présente de le tableau passée en argument de la fonction
	my $currentLine = shift;
	my $currentCompteur=0; # déclaré à 0 pour éviter le warning "uninitialised..."
	foreach my $i(@regexp){
		if ($currentLine =~ m/$i/){
			$currentCompteur++;
		}
		else{
			last;
		}
	}
	return $currentCompteur;
}	



MAIN: {
	GetOptions(	"help|Help|h"	=> \$help,
							"verbose|Verbose|v!"	=> \$verbose,
							"STS|sts|s!"	=> \$sts,
							"delimiter|Delimiter|d=s"	=> \$delimiter,
							"identification|ID|id|i!" => \$identification,
							"differentId|diff|di!" => \$differentID,
							"regexp|Regexp|r=s" => \@regexp,
							"SkipLine|skipline|s=s" => \$nbLineToSkip
				);

	if ($help) {
		pod2usage(-verbose => 2, -noperldoc => 1);
	exit;
	}

	if (!$delimiter){
		$delimiter = "\t";
	}
	else {
		warning("Delimiter used on output will be '$delimiter'");
	}
	
	warning("Processing table from STDIN...");

	if($sts){	warning("You choosed to use the STS service");	}

	if($identification) {	warning("you choosed to omitt the ID columns, -id option will add ids for you")	}
	
	
	my $urlRequest;
	my $nbline;
	while ( my $line = <STDIN> ) { 
		chomp $line;
		if ($nbLineToSkip){ # bloc dédié a l'évitement de $nbLineToSkip
			$nbline++;
			if ($nbline <= $nbLineToSkip){
				next();
			}
			else{
				$nbLineToSkip = undef; # undef pour éviter de repasser à ce bloc après les n lignes évitée
			}
		}
		if (@regexp){ # bloc dédié à la prise en compte d'expressions régulière passée en paramètre
			$compteurRegexp = handleRegexpOption($line);	
			if($compteurRegexp == scalar(@regexp)){
				next();
			}
		}
		
		# Options have been taken on board, we can now build en submit the url request :
		($urlRequest, $currentId) = urlConstructor($line); # Build the request and get IDs for the output line
		open(my $f1,">errors_file.txt");		
		print $currentId.$delimiter.$currentId2.$delimiter;  # --> output.
		
		while (is_error(getprint($urlRequest))){ #tant que getprint($urlRequest) est faux, attend 60scd, sinon print le score
			sleep(60);
		}
		#print "\n";	 
		#my $score = `wget -q -O - \'$urlRequest\'`; # get swoogle services sending us back a score
		#my $score = get($urlRequest);
		
		
	}
	
	
	warning("...finished");
	
}	# end of MAIN





