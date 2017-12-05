# ToFromEMLmailparser
Extract TO &amp; From Addresses from .EML files 

What you will need: 
  1- Strawberry perl: http://strawberryperl.com/ I used: http://strawberryperl.com/download/5.26.1.1/strawberry-perl-5.26.1.1-64bit-portable.zip
      If your not sure what to use then use: http://strawberryperl.com/download/5.26.1.1/strawberry-perl-5.26.1.1-32bit-portable.zip
  2- USeful but not necessary: 4- Tail utility to monitor progress I use 
      Bare Metal Software > BareTail - Free tail for Windows: https://www.baremetalsoft.com/baretail/

1- Download Strawberry perl, install to path C:\perl  (If you want to usea different path thats ok but you will need to edit do-mailparser-csv.cmd update "Set PtblPerl=")
2- Download Script
2- Extract script into a folder 
3- Run portableshell.bat in C:\perl
4- Configure firewall to allow C:\perl\perl\bin\perl.exe access to the internet on ports 80,443
5- In the shell type the following commands to load up ther required modules:
    i- cpan Log::Log4perl
        If the above command fails with an error use: cpan -fi Log::Log4perl
   ii- cpan DateTimeX::Easy
  iii- cpan Email::Simple
   iv- cpan File::Find
    v- cpan List::MoreUtils
   vi- run the script "do-mailparser-csv.cmd"
  vii- wait for it to complete.  open "Addresses-list.txt.csv"
   
   
   
Thanks to: 

Marco Fioretti for his code here: https://www.techrepublic.com/blog/linux-and-open-source/8-ways-to-use-email-header-info-and-how-to-extract-it/ 
which I leveraged to create the Perl script and also thanks goes to:
Gabor Szabo - https://perlmaven.com/perl-tutorial
multiple forum items from: http://www.perlmonks.org

