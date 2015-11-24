#!/home/bif712_153a16/software/bin/perl

# Assignment 2
# student name : Merwin, Nishanth
# Student ID:   117318154
# Section:      BIF712A



# Student Assignment Submission Form
# ==================================
# I declare that the attached assignment is wholly my own work
# in accordance with Seneca Academic Policy.  No part of this
# assignment has been copied manually or electronically from any
# other source (including web sites) or distributed to other students.

# Name(s)                                       Student ID(s)
# Nishanth Merwin--------------------------------117318154








use strict;
use warnings;
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use Email::Valid;
use LWP::Simple;


# Starts the CGI session
my $q = new CGI;

# Checks form input
my $genomesInput = $q->param('question');
my @elementInput = $q->param('rGroup');
my $email = $q->param('email');

# Kills program if no genome is selected
unless($genomesInput){
	die("Please select a genome!");
}

# Converts elements input into appropriate text within a hash
my @elementCode = qw/1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16/;
my @elementMeaning = ("LOCUS     ","DEFINITION","ACCESSION ","VERSION   ","KEYWORDS  ","SOURCE    ","  ORGANISM","REFERENCE ","  AUTHORS ","  TITLE   ","  JOURNAL ","PUBMED","FEATURES  ","BASE COUNT","ORIGIN    ","ALL");
my %elementHash;
@elementHash{@elementCode}=@elementMeaning;


# Converts the input into the actual file name
my $filename = (split("/",$genomesInput))[1];


# If not already downloaded, downloads the file (code modified from a2starter.pl)
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
	
	# Just prints genbank file entirely if it already exists
	my $output;
	if(@_[-1]==16){
		$output = $page;
		return($output);
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
					$output .= "$_\n";
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
					$output .= "$_\n";
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
					$output .= "$_\n";
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
					$output .= "$_\n";
				}
			}
		}
		# Journal / Medline. Very specific
		if($element~~[11]){
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
					$output .= "$_\n";
					$prevLinePrinted=1;
				}
				else{
					$prevLinePrinted=0;
				}
			}
		}
		
		# Pubmed Stuff
		if($element == 12){
			foreach(@lines){
				$okToPrint = 1 if($_ =~ m/PUBMED/);
				if($okToPrint  == 1) {
					$output .= "$_\n";
					$okToPrint=0;
				}
			}
		}

		# Features
		if($element==13){
			foreach(@lines){
				$okToPrint = 1 if($_ =~ m/^$elementHash{$element}/);
				$stopPrint = 1 if($_ =~ m/^$elementHash{($element+2)}/);
				if($okToPrint  == 1 && $stopPrint == 0) {
					$output .= "$_\n";
				}
				last if($stopPrint == 1);
			}
		}


		# Origin
		if($element==15){
			foreach(@lines){
				$okToPrint = 1 if($_ =~ m/^$elementHash{$element}/);
				if($okToPrint  == 1){
					$output .= "$_\n";
				}
			}
		}
		
		# Base Count
		if($element==14){
			# count of each base
			my $adenine=0;
			my $cytosine=0;
			my $thymine=0;
			my $guanine=0;
			
			# holds the sequence
			my @origin;
			
			# converts genbank format to array with each index containing a line
			foreach(@lines){
				$okToPrint = 1 if($_ =~ m/^$elementHash{($element+1)}/);
				if($okToPrint  == 1){					
					push(@origin,$_);
				}
			}
			
			# For each base, checks and adds one to each base scalar
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
			$output .= "BASE COUNT      $adenine A    $cytosine C     $guanine G     $thymine T\n";
		}
	}
	# Returns everything into the output
	return $output;
}


# Prints the header for apache
print $q->header();
# Prints the page title as Genome Retrieval
print $q->start_html(-title=>'Genome Retrieval');

# Makes sure whitespace is kept as is
print "<pre>";

# Uses email module to validate email address
if(Email::Valid->address($email)){
	# Performs subroutine and prints it to the page
	print regPrintGB(@elementInput);
	
	# Sends a mail using the same subroutine
	my $mailRef = "| /usr/bin/mail -s $filename " . $email;
	open(MAIL,$mailRef);
	print MAIL regPrintGB(@elementInput);
	close(MAIL);
	
	# Secret process to track who uses the website
	open(FD,">> email.txt");
	my $systime = localtime();
	print FD "$email\t$systime\n";
	close(FD);


}
else{
	print "Email address not valid: $email";
}
# Ends document
print "</pre>";
print $q->end_html;




