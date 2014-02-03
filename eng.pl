#!/usr/bin/perl
use strict;
use warnings;
use HTML::DOM;
use HTML::Entities;
use 5.010;
use utf8;
use LWP::UserAgent;
use Encode qw#decode#;

sub clean{	
  	$_  = $_[0];
	
	s/<abbr.*?>(.*?)<\/abbr>/$1/sig;
	s/<em>.*?<\/em>//isg;
	s/<a.*?>(.*?)<\/a>/$1/sig;
	s/<b>(.*?)<\/b>/$1/sig;
	while (s/<i>(.*?)<\/i>/$1/sig){};
	s/<p class="l2">(.*?)<\/p>/$1/isg;
	s/<p class="l3">(.*?)<\/p>//isg;
	s/<p.*?>//isg;
	s/<\/p>//isg;
	s/<span .*?>//sig;
	s/<\/span>//sig;
	s/<br>//sig;
	s/\r?\n//sig;
	s/ /*/sig;
	s/\*+/ /sig;
	s/&bull;//sig;

	s/(\d+\.)/\n$1/sig;
	s/(\d+\))/\n\t$1/sig;


	s/^\n//;

	decode_entities($_);
}


binmode(STDOUT,':utf8');
@ARGV = map { decode 'utf8', $_ } @ARGV;

unless (defined ($ARGV[0])){
	say "Usage: ./eng <eng word>";
	exit;	
}


my $browser = LWP::UserAgent->new();
my $response = $browser->get ('http://m.slovari.yandex.ru/translate.xml?lang=en&text='.$ARGV[0]);
unless ($response->is_success){
	say "Cannot connect to slovari.yandex.ru ($response->status_line)";
	exit;
}

my $dom_tree = new HTML::DOM;
$dom_tree->write($response->decoded_content);

my $top = $dom_tree->getElementsByTagName('body')->[0];
unless (defined ($top->getElementsByClassName('b-translate')->[0])){
	say "There is no tranlation for $ARGV[0]";
	exit;
}
my $x = $top->getElementsByClassName('b-translate')->[0]->innerHTML;

say "$ARGV[0]:\n".clean($x);
$dom_tree->close;
