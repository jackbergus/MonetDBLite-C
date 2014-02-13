SELECT qname, flag, rname, pos, mapq, cigar, rnext, pnext, tlen, seq, qual
FROM bam.alignments_i
WHERE bam_flag(flag, 'seco_alig') = False
ORDER BY qname;
