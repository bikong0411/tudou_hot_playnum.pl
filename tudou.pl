#!/usr/bin/env perl
use Coro;
use Mojo::UserAgent;
binmode(STDOUT,":utf8");
my $url = 'http://www.tudou.com/top/r%dc0t.html';
my $ua = Mojo::UserAgent->new;
my @async;
#两类不同展示形式
my @lists =(30,22,31,9);
my @olists = (99,29,26,21,15,1,14,10,5,32,34,3,33,25);
open my $fh ,">:utf8", "tudou.log" or die "can't open the file: $!";

foreach my $list (@lists) {
    my $tmp_url = sprintf $url,$list;
	push @async, async {
	   my $tx=$ua->get($_[0]);
	   my $dom = $tx->res->dom;
	   my $tr = $dom->find("div.g-wrap > div.section > div.m > div.top-table > div.b > div.c > table > tr");
	   foreach my $t($tr->each) {
		  my $title = $t->at("td > div.title >a");
		  next unless $title;
		  $title = $title->{"title"};
		  my $score = $t->at("td.digi >a");
		  ($score = $score->text()) =~ s/,//g;
		  print $fh "$title => $score\n";
	   }
	} $tmp_url;
}

foreach my $list(@olists) {
    my $tmp_url = sprintf $url,$list;
    push @async, async {
        my $tx = $ua->get($_[0]);
        my $dom = $tx->res->dom;
        my $sc = $dom->find("div.top-list > div.sc > div.pack_video_brief");
        foreach my $div($sc->each) {
           my $txt = $div->at("div.txt");
           my $title = $txt->h6->a->text;
           my $score = $txt->ul->li->[-1]->span->[0]->text;
           $score =~ s/,//g;
           print  $fh "$title => $score\n";
        }
  
    } $tmp_url;
}

$_->join for(@async);
close $fh;
