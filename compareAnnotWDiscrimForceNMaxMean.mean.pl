#!/usr/bin/env perl

=head1 NAME


=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 OPTIONS

--Help|help|h, produces this help file.

--verbose[no-verbose]|Verbose[no-Verbose]|v[no-v], boolean option to print out warnings during execution. Warnings and errors are redirected to STDERR. Defaults to no-verbose (silent mode).

--List|list|d=s, takes two files containing a list of word with either its Maximum Meaning value and Discrimination Force (both value are between 0 and 1).

--Product|product|p!, use the product calcul version of calculateSemanticWeight, default mode will calculate the mean of every word weight instead of the product of it.

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
use Statistics::Basic qw(:all);
use 5.10.0;

# scalars
my $help;
my $verbose;
my $debug;		# debug purposes only
my $product;	# product option(instead of mean)		
my $median;		# median option(...) 
my $sum;		# sum option(...)
my $diff;		# diff option(...)
my $variance;	# variance option(...)
my $header;     # word carry its meaning


# lists
my @wordList;
my @AllSemWeight2008;
my @AllSemWeight2016;

# hashs
my %WordSemWeight1;
my %WordSemWeight2;



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



sub calculateSemanticWeightMean($){
	my $annot = shift;
	my $AnnotWeight = 0;
	my @ValueDiscrim = ();
	my @ValueMaxMean = ();
	my @CombineValues = ();
	
	$annot =~ s/-/ /g;## sépare les mots composés en deux
	$annot =~ s/\s+$//g;## suprime les espaces à la fin des mots
	
	my @currentWordregex = split('\s+', $annot); 	
	foreach my $k(@currentWordregex){
		$k =~ s/\s+//g;
	}

	foreach my $k(@currentWordregex){
		if (defined($WordSemWeight1{$k})) { push(@ValueDiscrim, $WordSemWeight1{$k}); } else { push(@ValueDiscrim, 1); } 
		if (defined($WordSemWeight2{$k})) { push(@ValueMaxMean, $WordSemWeight2{$k}); } else { push(@ValueMaxMean, 1); }	
	}
	
	
	for (my $word=0; $word < scalar(@ValueDiscrim); $word++){	$AnnotWeight += $ValueDiscrim[$word] * $ValueMaxMean[$word];	}
	$AnnotWeight = $AnnotWeight / scalar(@ValueDiscrim);
	
	return $AnnotWeight;

}

sub calculateSemanticWeightVariance($){
	my $annot = shift;
	my $AnnotWeight = 0;
	my @ValueDiscrim = ();
	my @ValueMaxMean = ();
	my @CombineValues = ();
	my @arrayForVariance= ();
	
	$annot =~ s/-/ /g;## sépare les mots composés en deux
	$annot =~ s/\s+$//g;## suprime les espaces à la fin des mots
	
	my @currentWordregex = split('\s+', $annot); 	
	foreach my $k(@currentWordregex){
		$k =~ s/\s+//g;
	}

	foreach my $k(@currentWordregex){
		if (defined($WordSemWeight1{$k})) { push(@ValueDiscrim, $WordSemWeight1{$k}); } else { push(@ValueDiscrim, 1); } 
		if (defined($WordSemWeight2{$k})) { push(@ValueMaxMean, $WordSemWeight2{$k}); } else { push(@ValueMaxMean, 1); }	
	}
	
	
	for (my $word=0; $word < scalar(@ValueDiscrim); $word++){	push(@arrayForVariance, ($ValueDiscrim[$word] * $ValueMaxMean[$word]));	}
	$AnnotWeight = variance(@arrayForVariance);
	
	return $AnnotWeight;

}	

sub calculateSemanticWeightSum($){
	my $annot = shift;
	my $AnnotWeight = 0;
	my @ValueDiscrim = ();
	my @ValueMaxMean = ();
	my @CombineValues = ();
	
	$annot =~ s/-/ /g;## sépare les mots composés en deux
	$annot =~ s/\s+$//g;## suprime les espaces à la fin des mots
	
	my @currentWordregex = split('\s+', $annot); 	
	foreach my $k(@currentWordregex){
		$k =~ s/\s+//g;
	}

	foreach my $k(@currentWordregex){
		if (defined($WordSemWeight1{$k})) { push(@ValueDiscrim, $WordSemWeight1{$k}); } else { push(@ValueDiscrim, 1); } 
		if (defined($WordSemWeight2{$k})) { push(@ValueMaxMean, $WordSemWeight2{$k}); } else { push(@ValueMaxMean, 1); }	
	}
	
	
	for (my $word=0; $word < scalar(@ValueDiscrim); $word++){	$AnnotWeight += $ValueDiscrim[$word] * $ValueMaxMean[$word];	}
	
	return $AnnotWeight;

}

sub calculateSemanticWeightProduct($){
	my $annot = shift;
	my $AnnotWeight = 1;
	my @ValueDiscrim = ();
	my @ValueMaxMean = ();
	my @CombineValues = ();
	
	$annot =~ s/-/ /g;## sépare les mots composés en deux
	$annot =~ s/\s+$//g;## suprime les espaces à la fin des mots
	
	my @currentWordregex = split('\s+', $annot); 	
	foreach my $k(@currentWordregex){
		$k =~ s/\s+//g;
	}

	foreach my $k(@currentWordregex){
		if (defined($WordSemWeight1{$k})) { push(@ValueDiscrim, $WordSemWeight1{$k}); } else { push(@ValueDiscrim, 1); } 
		if (defined($WordSemWeight2{$k})) { push(@ValueMaxMean, $WordSemWeight2{$k}); } else { push(@ValueMaxMean, 1); }	
	}
	
	
	for (my $word=0; $word < scalar(@ValueDiscrim); $word++){	$AnnotWeight *= $ValueDiscrim[$word] * $ValueMaxMean[$word];	}
	$AnnotWeight = $AnnotWeight / scalar(@ValueDiscrim);
	
	return $AnnotWeight;

}

sub calculateSemanticWeightMedian($){
	my $annot = shift;
	my $AnnotWeight = 1;
	my @ValueDiscrim = ();
	my @ValueMaxMean = ();
	my @CombineValues = ();
	my @arrayForMedian = ();
	
	$annot =~ s/-/ /g;## sépare les mots composés en deux
	$annot =~ s/\s+$//g;## suprime les espaces à la fin des mots
	
	my @currentWordregex = split('\s+', $annot); 	
	foreach my $k(@currentWordregex){
		$k =~ s/\s+//g;
	}

	foreach my $k(@currentWordregex){
		if (defined($WordSemWeight1{$k})) { push(@ValueDiscrim, $WordSemWeight1{$k}); } else { push(@ValueDiscrim, 1); } 
		if (defined($WordSemWeight2{$k})) { push(@ValueMaxMean, $WordSemWeight2{$k}); } else { push(@ValueMaxMean, 1); }	
	}
	
	
	for (my $word=0; $word < scalar(@ValueDiscrim); $word++){	push(@arrayForMedian, ($ValueDiscrim[$word] * $ValueMaxMean[$word]));	}
	$AnnotWeight = median(@arrayForMedian);
	
	return $AnnotWeight;

}

MAIN: {
	GetOptions(	"help|Help|h"								=> \$help,
				"verbose|Verbose|v!"						=> \$verbose,
				"List|list|d=s"								=> \@wordList,
				"Product|product|p!" 						=> \$product,
				"Median|median|m!"							=> \$median,
				"Sum|sum|s!"								=> \$sum,
				"Diff|diff|di!"								=> \$diff,
				"Header|header|head!"						=> \$header,
				"Variance|variance|var!"					=> \$variance
				);
	if ($help) {
		pod2usage(-verbose => 2, -noperldoc => 1);
	exit;
	}


	if(@wordList){
		#Basically store words in hashes as key and their Semantic Weight as values  
		#get Discrim FORCE or MAX Meaning
		open(LIST, "<",$wordList[0]) or die ("Can't open file : $wordList[0]");
		while (my $line = <LIST>){
				chomp($line);
				my @currentWord = split("\t", $line);
				if (length($currentWord[0])>2) { $WordSemWeight1{$currentWord[0]} = $currentWord[1]; }				
		}
		close(LIST);
		
		#get the values of left file
		open(LIST, "<", $wordList[1]) or die ("Can't open file : $wordList[1]");
		while (my $line = <LIST>){
				chomp($line);
				my @currentWord = split("\t", $line);
				if (length($currentWord[0])>2) { $WordSemWeight2{$currentWord[0]} = $currentWord[1]; }				
		}
		close(LIST);		  		
	}
	
	if($header){	
		print STDOUT "IDTRANSCRIPT\t2016VALUE\tV3VALUE";
		if ($diff){ print STDOUT "\tDIFF\(2016-V3\)" }
		print STDOUT "\n\n";
	}	
	
	warning("Processing table from STDIN...");
	while ( my $line = <STDIN> ) { 
		chomp $line;
		my $V2016weight;
		my $V3weight;
		my $weightDiff;
				
		my @currentAnnots = split("\t",$line);
		my $trID = $currentAnnots[0]; 
		my $Annot1 = $currentAnnots[1];
		my $Annot2 = $currentAnnots[2];
		
		print STDOUT $trID;
		
		if($product){
			$V2016weight = calculateSemanticWeightProduct($Annot1);
			$V3weight = calculateSemanticWeightProduct($Annot2);
			print STDOUT "\t".$V2016weight."\t".$V3weight;
			push(@AllSemWeight2016, $V2016weight);
			push(@AllSemWeight2008, $V3weight);
		}
		elsif($median){
			$V2016weight = calculateSemanticWeightMedian($Annot1);
			$V3weight = calculateSemanticWeightMedian($Annot2);
			print STDOUT "\t".$V2016weight."\t".$V3weight;	
			push(@AllSemWeight2016, $V2016weight);
			push(@AllSemWeight2008, $V3weight);				
		}
		elsif($sum){
			$V2016weight = calculateSemanticWeightSum($Annot1);
			$V3weight = calculateSemanticWeightSum($Annot2);
			print STDOUT "\t".$V2016weight."\t".$V3weight;
			push(@AllSemWeight2016, $V2016weight);
			push(@AllSemWeight2008, $V3weight);					
		}
		elsif($variance){
			$V2016weight = calculateSemanticWeightVariance($Annot1);
			$V3weight = calculateSemanticWeightVariance($Annot2);
			print STDOUT "\t".$V2016weight."\t".$V3weight;
			push(@AllSemWeight2016, $V2016weight);
			push(@AllSemWeight2008, $V3weight);			
		}			
		else { # will calculate the mean of each annotation 
			$V2016weight = calculateSemanticWeightMean($Annot1);
			$V3weight = calculateSemanticWeightMean($Annot2);
			print STDOUT "\t".$V2016weight."\t".$V3weight;
			push(@AllSemWeight2016, $V2016weight);
			push(@AllSemWeight2008, $V3weight);
		}
		
		if($diff){
			$weightDiff = $V2016weight - $V3weight;		
			print STDOUT "\t".$weightDiff; 			
		}		
		
		print STDOUT "\n";
	}
	
	#if($TotalSemWeight){
			print STDOUT "Total Weight 2016 :"." ".sum(@AllSemWeight2016)."\t"."Total Weight 2008 :"." ".sum(@AllSemWeight2008)."\n";
	#}	
	
	
	warning("...finished");
	
	

}	# end of MAIN




#cat Annot_More0Less1.19889.tsv | ../../../../scripts/compareAnnotWDiscrimForceNMaxMean.mean.pl -d=WordwDiscrimValues.tsv -d=wordMaximumMeaning.tsv -var -head -diff | head -50
#../R/to_process/results/CalcDiscrim_MaxMean/uniq_annot_processed.word.only.txt

#  sur 72960 :  Total Weight 2016 : 12555.3764986206	Total Weight 2008 : 18710.8309980831
# sur 19889 : Total Weight 2016 : 3129.48186347018	Total Weight 2008 : 2018.37408645792
