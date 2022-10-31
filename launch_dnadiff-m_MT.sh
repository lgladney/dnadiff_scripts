#!/bin/bash -l
#$ -pe smp 1
#$ -q all.q
#$ -cwd -V -j y
#$ -N dnadiffM
#10-29-15 edited from Lee Katz launch_aniM.sh

module load ncbi-blast+/2.2.30
module load MUMmer/3.23

#(for i in fasta/*.fasta; do refname=$(basename $i .fasta); jobname=${refname}; qsub -o DIFF/$jobname.out -N dnadiffM$jobname ~/bin/launch_dnadiff-m_MT.sh DIFF/$jobname.tsv $i fasta/*.fasta; done;)
# Usage: dnadiff-m_MT.pl <reference> <query>
OUT=$1
REF=$2
shift; shift;
QUERY="$@";
script=$(basename $0)

if [ "$QUERY" == "" ]; then
  echo "USAGE: $script out.tsv ref.fasta *.fasta"
  echo "  *.fasta: all the query fasta files to match against ref.fasta"
  exit 1;
fi

# Do the comparison
DIFFSCRIPT="/scicomp/home/hze1/bin/dnadiff-m_MT.pl"
echo -e "REF\tQUERY\tANI\tAlignedBases\tInsertions\tTotalSnps\tTotalIndels" > $OUT
for i in $QUERY; do
  command="$DIFFSCRIPT $REF $i >> $OUT"
  eval $command
  if [ $? -gt 0 ]; then
    echo "ERROR WITH COMMAND"
    echo "  $command"
    exit 1;
  fi
done
