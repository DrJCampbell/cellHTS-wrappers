#!/usr/bin/perl

use strict;
use warnings;
use CGI qw( :standard );
use Template;

# print an http header
print "Content-type: text/html\n\n";

my $q = new CGI;

my $test_message = "this is a test";


my $vars = {
	'test_message' => $test_message,
};

#my $template = Template->new({
#	INCLUDE_PATH => ${} . './lib',
#	PRE_PROCESS => 'config',
#});

my $template = Template->new();

$template->process($tt_test_html, $vars) || die $template->error();







