#!/Strawberry/perl/bin/perl.exe

use strict;
use warnings;

use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);



# NOTE: if LWP::Simple module is NOT available within your Perl distribution,
#       install with:
#       perl -MCPAN -e "install LWP::Simple"


use strict;
use warnings;
use LWP::Simple;


# Starts the CGI session
my $q = new CGI;

# Checks form input
my $genomesInput = $q->param('question');
my @elementInput = $q->param('rGroup');

# Converts elements input into appropriate text within a hash
my @elementCode = qw/1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16/;
my @elementMeaning = ("LOCUS     ","DEFINITION","ACCESSION ","VERSION   ","KEYWORDS  ","SOURCE    ","  ORGANISM","REFERENCE ","  AUTHORS ","  TITLE   ","  JOURNAL ","   MEDLINE","FEATURES  ","BASE COUNT","ORIGIN    ","ALL");
my %elementHash;
@elementHash{@elementCode}=@elementMeaning;


# Converts the input into the actual file name
my $filename = (split("/",$genomesInput))[1];


# If not already downloaded, downloads the file
my $page;
if(!(-f $filename)) {
   $page = get("ftp://ftp.ncbi.nih.gov/genomes/Viruses/$genomesInput");
   die "Error retrieving GenBank file from NCBI..." unless defined($page);
   open(FD, "> $filename") || die("Error opening file... $!\n");
   print FD "$page";
   close(FD);
}
else{
$/ = undef;   # default record separator is undefined
open(FD, "< $filename") || die("Error opening file: '$filename'\n $!\n");
$page = <FD>; # file slurp (reads the entire file into a scalar)
close(FD);
$/ = "\n";    # resets the default record back to newline
}



sub regPrintGB(@){
	
	if(@_[-1]==16){
		print $page;
		exit;
	}

	
	
	
	foreach my $element (@_){
		
		my @lines = split('\n', $page);
		my $stopPrint= my $okToPrint = 0;
		
		# For all the ones that are directly succeded by the next element and occur exactly once.
		if($element ~~ [1,2,3,4,5,7]){
			my $okToPrint = my $stopPrint = 0;
			foreach(@lines){
				$okToPrint = 1 if($_ =~ m/^$elementHash{$element}/);
				$stopPrint = 1 if($_ =~ m/^$elementHash{($element+1)}/);
				if($okToPrint  == 1 && $stopPrint == 0) {
					print "$_\n";
				}
				last if($stopPrint == 1);
			}
		}
		# Source has to skip organism segment
		if($element == 6){
			foreach(@lines){
				$okToPrint = 1 if($_ =~ m/^$elementHash{$element}/);
				$stopPrint = 1 if($_ =~ m/^$elementHash{($element+2)}/);
				if($okToPrint  == 1 && $stopPrint == 0) {
					print "$_\n";
				}
				last if($stopPrint == 1);
			}
		}
		# Multiple references, lasts until comment
		if($element == 8){
			foreach(@lines){
				$okToPrint = 1 if($_ =~ m/^$elementHash{$element}/);
				$stopPrint = 1 if($_ =~ m/^COMMENT   /);
				if($okToPrint  == 1 && $stopPrint == 0) {
					print "$_\n";
				}
				last if($stopPrint == 1);
			}
		}
		# Authors, Title and Journal are not one long stretch.
		if($element ~~ [9,10]){
			foreach(@lines){
				$okToPrint = 1 if($_ =~ m/^$elementHash{$element}/);
				$stopPrint = 1, $okToPrint = 0 if($_ =~ m/^$elementHash{($element+1)}/);
				$okToPrint = 1, $stopPrint=0 if($_ =~ m/^$elementHash{$element}/);
				if($okToPrint  == 1 && $stopPrint == 0) {
					print "$_\n";
				}
			}
		}
		# Journal / Medline. Very specific
		if($element~~[11,12]){
			my $prevLinePrinted = 0;	
			foreach(@lines){
				if($_ =~ m/^$elementHash{$element}/){
					$okToPrint = 1;
					$stopPrint=0;
				}
				elsif($prevLinePrinted==1){
					if($_ =~ m/^          /){
						$stopPrint = 0;
						$okToPrint = 1; 
					}
					else{
						$stopPrint = 1;
						$okToPrint = 0; 
					}
				}
				if($okToPrint  == 1 && $stopPrint == 0) {
					print "$_\n";
					$prevLinePrinted=1;
				}
				else{
					$prevLinePrinted=0;
				}
			}
		}
		# Features
		if($element==13){
			foreach(@lines){
				$okToPrint = 1 if($_ =~ m/^$elementHash{$element}/);
				$stopPrint = 1 if($_ =~ m/^$elementHash{($element+2)}/);
				if($okToPrint  == 1 && $stopPrint == 0) {
					print "$_\n";
				}
				last if($stopPrint == 1);
			}
		}
		
		# Origin
		if($element==15){
			foreach(@lines){
				$okToPrint = 1 if($_ =~ m/^$elementHash{$element}/);
				if($okToPrint  == 1){
					print "$_\n";
				}
			}
		}
		
		# Base Count
		if($element==14){
			my $adenine=0;
			my $cytosine=0;
			
			my $thymine=0;
			
			my $guanine=0;
			
			my @origin;
			
			foreach(@lines){
				$okToPrint = 1 if($_ =~ m/^$elementHash{($element+1)}/);
				if($okToPrint  == 1){					
					push(@origin,$_);
				}
			}
			
			foreach(@origin){
				substr($_,0,10,"");
				
				my @line = split("",$_);
				
				foreach my $char (@line){
					$adenine++ if($char eq "a");
					$cytosine++ if($char eq "c");
					$guanine++ if($char eq "g");
					$thymine++ if($char eq "t");
				}
			}
			print "BASE COUNT      $adenine A    $cytosine C     $guanine G     $thymine T\n";
		}
	}
}






print $q->header();
print $q->start_html;


print "<pre>";

print $q->h1("Hello World");

regPrintGB(@elementInput);

print "</pre>";

print $q->end_html;




