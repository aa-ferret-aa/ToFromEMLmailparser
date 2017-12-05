#! /usr/bin/perl


# original code from: https://www.techrepublic.com/blog/linux-and-open-source/8-ways-to-use-email-header-info-and-how-to-extract-it/ 
# By Marco Fioretti | in Linux and Open Source, January 23, 2012, 3:04 AM PST
# also thanks to: Gabor Szabo - https://perlmaven.com/perl-tutorial, multiple forum items from: http://www.perlmonks.org
# Severly modified by me :) 
# For more information refer to:
# Can I scrape ALL my archived emails to pull out all the "sent to" and "sent from" contacts? | MailStore Home Support Community: https://getsatisfaction.com/email_archiving_software/topics/can-i-scrape-all-my-archived-emails-to-pull-out-all-the-sent-to-and-sent-from-contacts
# 

use strict;
use warnings;

use Email::Simple;
use DateTimeX::Easy;
use File::Find;
use Cwd;
use List::MoreUtils qw(uniq);

# my $EndOfLine = "\r\n";
my $EndOfLine = "\n";
my $QuoteChr = "\x22";

{
my @btime;
sub BEGIN_TIME {
    push @btime, time;
}
sub END_TIME {
    @btime or die "error: END_TIME without BEGIN_TIME";
    my($btime, $etime) = (pop @btime, time);
    warn $QuoteChr,"elapsed time was ", $etime - $btime, " s",$QuoteChr,$EndOfLine;
}
END {
    @btime and warn $QuoteChr,"warning: BEGIN_TIME without END_TIME",$QuoteChr,$EndOfLine;
}
}

sub remainder {
    my ($a, $b) = @_;
    return 0 unless $b && $a;
    return $a / $b - int($a / $b);
}

# my @FilesToRun = ();
my $filePattern = "*.eml" ;
my $currentWorkingDir = getcwd;

# binmode STDOUT, ":raw:eol(CRLF)";
# use PerlIO::eol;

my $raw_email;
my $intMsgCntr = 0;
my $intWhentoRunUnique = 1500;
# my $intWhentoRunUnique = 50;

# Set to 1 to print all headers to the Standard Error Log
my $printAllHeaders = 0;
# my $ToHdrVal 
# my $FromHdrVal

my @ToAddresses;
my @FromAddresses;
my $SrcDir = '';


my $Argcnt = scalar @ARGV;
# print "argument count: $Argcnt $EndOfLine";

if ($Argcnt > 0){
  exit if (($ARGV[0] =~ m/\/dovecot\./) ||
     ($ARGV[0] =~ m/\/dovecot-/)  ||
     ($ARGV[0] =~ m/\/maildirfolder$/)
  );
  $SrcDir = $ARGV[0];
 }

# print "#"x120, "\nFILE:$ARGV[0]\n";
# print "\nFILE:$ARGV[0]\n";

unless (-d $SrcDir){
  $SrcDir = '.\Emails';
  }
print STDERR $QuoteChr,"PATH:,",$QuoteChr,$SrcDir,$QuoteChr,$EndOfLine;

if (-d $SrcDir){
  BEGIN_TIME;
  # https://stackoverflow.com/questions/3795490/how-can-i-use-filefind-in-perl/380090#3800908

  # add only files of type filePattern recursively from the $SrcDir
  my  @filesToRun; 
  find( sub { push @filesToRun, $File::Find::name  
                                      if ( m/^(.*)$filePattern$/ ) }, $SrcDir) ;

  foreach  my $file ( @filesToRun  ) 
  {
      # print "$file\n" ;   
      # open (MESSAGE, "< $file") || die "Couldn't open email $file$EndOfLine";
      my $message = undef;
      open ($message, "< $file") || die "Couldn't open email $file$EndOfLine";
      undef $/;
      $raw_email = <$message>;
      $intMsgCntr += 1;
      # print STDERR "$raw_email$EndOfLine";
      close $message;
            
      my $mail= Email::Simple->new($raw_email);
      my $from_header     = $mail->header("From");
      my $to_header = $mail->header("To");
      my $date_header     = $mail->header("Date");
      my $cc_header = $mail->header("CC");
      my $bcc_header= $mail->header("BCC");
      my $msgid_header    = $mail->header("Message-ID");
      my $subject_header  = $mail->header("Subject");
      my $inreply_header  = $mail->header("In-Reply-To");
      my @received  = $mail->header("Received");

      my $timestamp     = DateTimeX::Easy->date($mail->header("Date"));
      $timestamp->set_time_zone("GMT");
      $timestamp =~ s/T/ /;

      unless (length $to_header){ 
        $to_header = "MISSING TO HEADER";
        print STDERR $QuoteChr,"MSGID:",$QuoteChr,",",$QuoteChr,"MISSING TO HEADER",$QuoteChr,",",$QuoteChr,"MSGID:",$QuoteChr,",",$QuoteChr,$msgid_header,$QuoteChr,",",$QuoteChr,"FROM:",$QuoteChr,",",$QuoteChr,$from_header,$QuoteChr,",",$QuoteChr,"TO:",$QuoteChr,",",$QuoteChr,$to_header,$QuoteChr,",",$QuoteChr,"DATE:",$QuoteChr,",",$QuoteChr,$date_header,$QuoteChr,",",$QuoteChr,"SUBJ:",$QuoteChr,",",$QuoteChr,$subject_header,$QuoteChr,$EndOfLine;
        }
      if (not length $from_header){ 
        $from_header = "MISSING FROM HEADER";
        print STDERR $QuoteChr,"MSGID:",$QuoteChr,",",$QuoteChr,"MISSING FROM HEADER",$QuoteChr,$QuoteChr,",",$QuoteChr,"MSGID:",$QuoteChr,",",$QuoteChr,$msgid_header,$QuoteChr,",",$QuoteChr,"FROM:",$QuoteChr,",",$QuoteChr,$from_header,$QuoteChr,",",$QuoteChr,"TO:",$QuoteChr,",",$QuoteChr,$to_header,$QuoteChr,",",$QuoteChr,"DATE:",$QuoteChr,",",$QuoteChr,$date_header,$QuoteChr,",",$QuoteChr,"SUBJ:",$QuoteChr,",",$QuoteChr,$subject_header,$QuoteChr,$EndOfLine;
        }
          
      # print "$raw_email$EndOfLine";
      if ($printAllHeaders==1){ print STDERR $QuoteChr,$QuoteChr,",",$QuoteChr,$QuoteChr,",",$QuoteChr,"MSGID:",$QuoteChr,",",$QuoteChr,"$msgid_header",$QuoteChr,",",$QuoteChr,"FROM:",$QuoteChr,",",$QuoteChr,"$from_header",$QuoteChr,",",$QuoteChr,"TO:",$QuoteChr,",",$QuoteChr,"$to_header",$QuoteChr,",",$QuoteChr,"DATE:",$QuoteChr,",",$QuoteChr,"$date_header",$QuoteChr,",",$QuoteChr,"SUBJ:",$QuoteChr,",",$QuoteChr,"$subject_header",$QuoteChr,"$EndOfLine"; }
      
      my @toheaderVals = split(',', $to_header);
      my @fromHeaderVals = split(',', $from_header);
      
      push (@ToAddresses,@toheaderVals);
      push (@FromAddresses,@fromHeaderVals);
      if (remainder($intMsgCntr,$intWhentoRunUnique) == 0){
        @ToAddresses  = uniq  map lc, @ToAddresses;
        @FromAddresses = uniq  map lc, @FromAddresses;
        # print STDERR "Re-uniqing",$intMsgCntr,$EndOfLine;
        print STDERR $QuoteChr,"Re-uniqing: Msgs:",$QuoteChr,",",
                      $QuoteChr,$intMsgCntr,$QuoteChr,",",
                      $QuoteChr,"TO:",$QuoteChr,",",
                      $QuoteChr,scalar(@ToAddresses),$QuoteChr,",",
                      $QuoteChr,"FROM:",$QuoteChr,",",
                      $QuoteChr,scalar(@FromAddresses),$QuoteChr,$EndOfLine;
      }
#       
#       foreach my $ToHdrVal (@toheaderVals) {
#         # Remove whitespace from front and back of string
#         $ToHdrVal =~ s/^\s+|\s+$//g;
#         # print the result
#         # print "TO:,","$ToHdrVal$EndOfLine"
#         print STDOUT "\x22TO:\x22,\x22$ToHdrVal\x22$EndOfLine";
#       }
#       foreach my $FromHdrVal (@fromHeaderVals) {
#         # Remove whitespace from front and back of string
#         $FromHdrVal =~ s/^\s+|\s+$//g;
#         # print the result
#         # print "FROM:,","$FromHdrVal$EndOfLine"
#         print STDOUT "\x22FROM:\x22,\x22$FromHdrVal\x22$EndOfLine";
#       }
# 
  }
  @ToAddresses  = uniq  map lc, @ToAddresses;
  @FromAddresses = uniq  map lc, @FromAddresses;
  my $addr = '_' x 79;
  
  # print STDOUT $addr,$EndOfLine;
  foreach $addr (@ToAddresses){
    $addr =~ s/^\s+|\s+$//g;
    $addr =~ s/\R//g;
    print STDOUT "\x22TO:\x22,\x22$addr\x22$EndOfLine";
  }
  foreach $addr (@FromAddresses){
    $addr =~ s/^\s+|\s+$//g;
    $addr =~ s/\R//g;
    print STDOUT "\x22FROM:\x22,\x22$addr\x22$EndOfLine";
  }
  print STDERR $QuoteChr,$intMsgCntr,$QuoteChr,",",
                $QuoteChr,"Messages Processed.",$QuoteChr,",",
                $QuoteChr,scalar(@ToAddresses),$QuoteChr,",",
                $QuoteChr,"Unique To Addresses Found.",$QuoteChr,",",
                $QuoteChr,scalar(@FromAddresses),$QuoteChr,",",
                $QuoteChr,"Unique From Addresses Found.",$QuoteChr,$EndOfLine;
  END_TIME;
} else {
  print "$SrcDir does not exist.$EndOfLine";
}




# open (MESSAGE, "< $ARGV[0]") || die "Couldn't open email $ARGV[0]\n";
# undef $/;
# $raw_email = <>;
# close MESSAGE;
# 
# my $mail= Email::Simple->new($raw_email);
# my $from_header     = $mail->header("From");
# my $to_header = $mail->header("To");
# my $date_header     = $mail->header("Date");
# my $cc_header = $mail->header("CC");
# my $bcc_header= $mail->header("BCC");
# my $msgid_header    = $mail->header("Message-ID");
# my $subject_header  = $mail->header("Subject");
# my $inreply_header  = $mail->header("In-Reply-To");
# my @received  = $mail->header("Received");
# 
# my $timestamp     = DateTimeX::Easy->date($mail->header("Date"));
# $timestamp->set_time_zone("GMT");
# $timestamp =~ s/T/ /;
# 
# my @toheaderVals = split(',', $to_header);
# my @fromHeaderVals = split(',', $from_header);
# 
# print STDERR "MSGID: $msgid_header, FROM: $from_header, TO: $to_header, DATE: $date_header, SUBJ: $subject_header$EndOfLine";
# 
# foreach my $ToHdrVal (@toheaderVals) {
#   # Remove whitespace from front and back of string
#   $ToHdrVal =~ s/^\s+|\s+$//g;
#   # print the result
#   # print "TO:,","$ToHdrVal$EndOfLine"
#   print STDOUT "\x22TO:\x22,\x22$ToHdrVal\x22$EndOfLine"
# }
# foreach my $FromHdrVal (@fromHeaderVals) {
#   # Remove whitespace from front and back of string
#   $FromHdrVal =~ s/^\s+|\s+$//g;
#   # print the result
#   # print "FROM:,","$FromHdrVal$EndOfLine"
#   print STDOUT "\x22FROM:\x22,\x22$FromHdrVal\x22$EndOfLine"
# }


# SUBJECT:   $subject_header
# FROM:$from_header
# TO:  $to_header
# CC:  $cc_header
# BCC: $bcc_header
# DATE:$date_header
# TIMESTAMP: $timestamp
# MSGID:     $msgid_header
# INREPLY:   $inreply_header

# FROM:,TO:,CC:,BCC:,INREPLY:
# $from_header,$to_header,$cc_header,$bcc_header,$inreply_header
# 
# MailStore Home Support Community: 
# https://getsatisfaction.com/email_archiving_software/topics/can-i-scrape-all-my-archived-emails-to-pull-out-all-the-sent-to-and-sent-from-contacts
# Can I scrape ALL my archived emails to pull out all the "sent to" and "sent from" contacts?
#   Pulling them into a text file would be perfect, and with contact names attached to them even better, 
#   but the best would be if any duplicates would also be deleted. 
#   Does MailStore Home have a neat way of doing this, or are there any handy workarounds out there?


# print<<END;
# "FROM:","$from_header"
# "TO:","$to_header"
# END
exit;