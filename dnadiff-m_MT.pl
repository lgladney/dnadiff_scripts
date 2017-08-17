#!/usr/bin/env perl  
#Lori Gladney 10-29-2015 
#Objective: Run MUMmer dnadiff script between two genomes 
#Run script from current directory with genome assemblies

use strict;
use warnings; 
use File::Temp qw/ tempfile tempdir /;
use File::Basename qw/fileparse basename dirname/;
#use File::Spec;

my $template = "ani-m.XXXXXX";
my $tempdir = tempdir($template, CLEANUP => 1, TMPDIR=>1); #makes a temp directory using template and deletes the directory
#print "$tempdir\n" ;  #sanity checks

#Reading in fasta files (assemblies) from the command line into variables $reference and $query
#$ARGV[0] is the first file, $ARGV[1] is the second file 
my $reference= $ARGV[0] or die "Cannot locate the reference sequence\nUsage: ani-m.pl <reference> <query> 
This script outputs the reference genome, the query genome and the Average nucleotide identity";
my $query= $ARGV[1] or die "Cannot locate the query sequence\nUsage: ani-m.pl <reference> <query>
This script outputs the reference genome, the query genome and the Average nucleotide identity";

my $refname=basename($reference);
my $queryname=basename($query);
my $prefix="$tempdir/".$refname."_".$queryname;

#Make system call to run the dnadiff script and output any STDERR/STDOUT to dev/null
system ("dnadiff $reference $query -p $prefix 2>/dev/null");
 die "Error: Problem with dnadiff: $!\n  dnadiff $reference $query -p $prefix\n" if $?;
 
 
#Objective: parse output from MUMmer script dnadiff e.g. out.report

#Reading data from an input file
#The filename containing the data
my $filename= "$prefix.report";

#First we open the file containing the data and associate it with file handle FILE
open (FILE, $filename) or die "Cannot locate dnadiff 'out.report' file. Please make sure the file is in the current directory.\n";

#We store the the data into the variable @report (associated with <FILE>) , which is where it is read from. 
my @report= <FILE>;

# Close the file - we've read all the data into @report now.
close FILE;

my @ani;
my @identity; 
my @aligned;
my @alignedbases;
my @insertionsvalue;
my @totalsnps;
my @totalindels;
my @insertions;
my @indels;
my @snps;
  

#Loop through each line in the report, pulling out lines that match AvgIdentity. 
foreach (@report) {
	
		
	if (/^AvgIdentity/) {
	
	#Split matching lines on whitespace and place into new array @identity
	@identity= split(/\s+/,$_);
	
	#print "$identity[1]\n";  #sanity check
	#print " @identity[0..10] @identity[11..50] \n";  #sanity check
	
	#Place the second column value [REF column] of the first line with AvgIdentity into array @ani
	#This is the line from the 1:1 alignments 
	push (@ani, $identity[1]); 
	
    #print "@ani \n";     #sanity check
  
      }
    
	if (/^AlignedBases/) {
	
	#Split matching lines on whitespace and place into new array @aligned
	@aligned= split(/\s+/,$_);
	
	#Place the second column value [Query column] of the first line with AlignedBases into array @alignedbases
		push (@alignedbases, $aligned[2]); 
	
      
      }
	  
	 	  
	if (/^Insertions/) {
	#insertions occurring in the query when compared to the reference
	@insertionsvalue= split(/\s+/, $_);
	
	push (@insertions, $insertionsvalue[2]);
	
	}
	
	if (/^TotalSNPs/) {
	
	@totalsnps= split (/\s+/, $_);
	
	push (@snps, $totalsnps[2]);
	
	}
	
	if (/^TotalIndels/) {
	
	@totalindels= split (/\s+/, $_);
	
	push (@indels, $totalindels[2]);
	
	} 
	
   }   
   
 
   #Print the Reference Query AlignedBases %ANI
   print join ("\t",$refname ,$queryname,$ani[0],$alignedbases[0],"$insertions[0]","$snps[0]","$indels[0]")."\n"; 
    
 exit;    
