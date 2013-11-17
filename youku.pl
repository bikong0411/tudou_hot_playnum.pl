#!/usr/bin/env perl
use warnings;
use strict;
use LWP::UserAgent;
use Mojo::DOM;
open my $fh,">youku.log" or die "can't open file:$!";
my @list = (97, 96, 85, 100, 95, 87, 84, 91,86, 92, 98, 104, 105, 99,103, 89, 88,90,94);
my $url = "http://www.youku.com/v_olist/c_%d_a__s__g__r__lg__im__st__mt__tg__d_1_et_0_ag_0_fv_0_fl__fc__fe__o_7_p_%d.html";
my $ua = LWP::UserAgent->new;
$ua->agent("Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1667.0 Safari/537.36");
$ua->timeout(100);
for my $item (@list) {
    for my $i(1..10) {
        my $tmp_url = sprintf $url,($item,$i);
        my $response = $ua->get($tmp_url);
        my $body = $response->content if $response->is_success;

        my $dom = Mojo::DOM->new($body);
        for my $e ($dom->find("ul.pv")->each) {
            my $title = $e->li->[0]->a->attr('title');
            my $play_num = $e->li->[-1]->span->text;
            $play_num =~ s/,//g;
            print $fh  $title, "=>", $play_num,"\n";
        }   
    }   
}
close $fh;
