#!/usr/bin/perl
#
# Routine to get system property settings from default java installation
# and return the value of java.home (for setting JAVA_HOME environment
# variable).
# 20 March 2015, A.C.Raugh
# Found online at http://sbndev.astro.umd.edu/wiki/Finding_and_Setting_JAVA_HOME
#

open (INP, "java -XshowSettings:properties 2>&1 |") ||
   die "Could not open input pipe to get Java settings, ";

 while ($line = <INP>)
   { if ($line =~ /java\.home./)
       { chomp $line;
         $line =~ s/^\s*java\.home\s*=\s*//;
         print ($line,$/);
         close(INP);
         last;
       }
   }
 exit;
