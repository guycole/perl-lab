#!/usr/local/bin/perl -w
#
# Title:mailfilt2.pl
#
# Description:
#   fetchmail does not understand mailing lists.  
#   Parse the file w/bounced email and process accordingly.
#
# Development Environment:
#   Linux 2.2.5-15 (Red Hat 6.0)
#   PERL 5.005_03
#
# Author:
#   G.S. Cole (gsc@acm.org)
#
# Maintenance History:
#   $Id: mailfilt2.pl,v 1.1 1999-10-30 07:04:10 gsc Exp $
#
#   $Log: mailfilt2.pl,v $
#   Revision 1.1  1999-10-30 07:04:10  gsc
#   Initial Check In
#
#

%gMailOrigins = (
  'gimp-developer-return',                      'GIMP_DEVELOPER_RETURN',
  'gimp-developer-owner@scam.xcf.berkeley.edu', 'GIMP_DEVELOPER_OWNER',
  'linux-security-request@redhat.com',          'LINUX_SECURITY',
  'owner-netdev@athena.nuclecu.unam.mx',        'NET_DEV',
  'owner-ase-linux-list@isug.com',              'LINUX_SYBASE',
  'bounces@developer.netbeans.com',             'NETBEANS',
  'owner-tkined@ibr.cs.tu-bs.de',               'TKINED',
  'root@tco_name1.digiburo.com',                'TCO_NET',
  'OTNNEWS@US.oracle.com',                      'ORACLE_TECH_NEWS',
  'owner-alphaflash@MAIL.SOFTWARE.IBM.CO',      'IBM_NEWS',
  'owner-dialogic_linuxtelephony@ded-tscs.InnovSoftD.com', 'LINUX_TELEPHONY',
  'ucd-snmp-announce-request@ucd-snmp.ucdavis.edu', 'UCD_ANNOUNCE',
  'nobody@java.sun.com',                        'JDC_TECH_TIPS',
  'support-announce--argo',                     'ARGO_SUPPORT',
  'sunnews@coopermktg.com',                     'SUN_NEWS'
);

%gMailDestinations = (
  'ARGO_SUPPORT',          'gsc',
  'GIMP_DEVELOPER_OWNER',  'gimp',
  'GIMP_DEVELOPER_RETURN', 'gimp',
  'IBM_NEWS',              'gsc',
  'JDC_TECH_TIPS',         'gsc',
  'LINUX_SECURITY',        'gsc',
  'LINUX_SYBASE',          'bitbucket',
  'LINUX_TELEPHONY',       'gsc',
  'NET_DEV',               'gsc',
  'NETBEANS',              'gsc',
  'ORACLE_TECH_NEWS',      'gsc',
  'SUN_NEWS',              'gsc',
  'TCO_NET',               'gsc',
  'TKINED',                'gsc',
  'UCD_ANNOUNCE',          'gsc',
);
  


$opt_f = "mailbox";

open(SOURCE, $opt_f);
while (<SOURCE>) {
    chop;
    push(@gRawTxt, $_);
}
close(SOURCE);

$parsing = 0;
$processed = 0;
$abandoned = 0;
$temp_filename = "/tmp/mailfilt.out";

for ($ii = 0; $ii < $#gRawTxt; $ii++) {
    if ($parsing > 0) {
	printf(OUTFILE "%s\n", $gRawTxt[$ii]);
    }

    if (length($gRawTxt[$ii]) < 2) {
	if (($gRawTxt[$ii+1] =~ /^From /) && ($gRawTxt[$ii+2] =~ /^Return-Path: /)) {
	    if ($parsing > 0) {
		$processed++;
		close(OUTFILE);
		unlink($temp_filename);
	    }

	    open(OUTFILE, "> $temp_filename") || die("Unable to open temp file");
	    $parsing = 1;

	    $match_noted = 0;
	    while (($key, $value) = each(%gMailOrigins)) {
		if ($gRawTxt[$ii+1] =~ /$key/) {
#		    printf("match:%s\n", $value);
		    $match_noted = 1;
		    $destination_value = $value;
		}
	    }

	    if ($match_noted < 1) {
		$abandoned++;
		$destination = 'bitbucket';
		printf("1::%s\n", $gRawTxt[$ii+1]);
		printf("2::%s\n", $gRawTxt[$ii+2]);
	    } else {
		$destination = $gMailDestinations{$destination_value};
	    }
	    printf("dest:%s\n", $destination);
	}
    }
}

#;;; Local Variables: ***
#;;; mode:perl ***
#;;; End: ***

