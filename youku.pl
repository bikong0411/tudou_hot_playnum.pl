#!/usr/bin/env perl
use warnings;
use strict;
use LWP::UserAgent;
use Mojo::DOM;
use POSIX qw/strftime/;
open my $fh,"/usr/bin/zkname xxxx.com|" or  die "can't open zkname command!";
my $res = <$fh>;
my ($host,$port) = split /\s+/, $res;
close $fh;
my $date = strftime("%Y%m%d",localtime(time()-86400));

open $fh,">youku.log.$date" or die "can't open file:$!";

my @list = (97, 96, 85, 100, 95, 87, 84);
my @olist = (91,86, 92, 98, 104, 105, 99,103, 89, 88,90,94);
my %hash = (
   "97" => '电视剧',
   "96" => '电影',
   "85" => '综艺',
   "100" => '动漫',
   "95" => '音乐',
   "87" => '教育',
   "84" => '纪录片',
   "91" => '资讯',
   "86" => '娱乐',
   "92" => '原创',
   "98" => '体育',
   "104" => '汽车',
   "105" => '科技',
   "99" => '游戏',
   "103" => '生活',
   "89" => '时尚',
   "88" => '旅游',
   "90" => '母婴',
   "94" => '搞笑'
);
my $url = "http://www.youku.com/v_olist/c_%d_a__s__g__r__lg__im__st__mt__tg__d_1_et_0_ag_0_fv_0_fl__fc__fe__o_7_p_%d.html";
my $ua = LWP::UserAgent->new;
$ua->agent("Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1667.0 Safari/537.36");
$ua->timeout(100);
$ua->proxy('http',"http://$host:$port/");
for my $item (@list) {
    print $fh $hash{$item} . "\n";
    for my $i(1..10) {
        my $tmp_url = sprintf $url,($item,$i);
        my $response = $ua->get($tmp_url);
        my $body = $response->content if $response->is_success;

        my $dom = Mojo::DOM->new($body);
        for my $e ($dom->find("ul.pv")->each) {
            my $title = $e->li->[0]->a->attr('title');
            my $play_num = $e->li->[-1]->span->text;
            $play_num =~ s/,//g;
            print $fh  "$title => $play_num\n";
        }
    }
}

for my $item (@olist) {
   print $fh $hash{$item} . "\n";
   for my $i(1..10) {
       my $tmp_url = "http://www.youku.com/v_showlist/t2c".$item."g0d1p".$i;
       my $response = $ua->get($tmp_url);
       my $body = $response->content if $response->is_success;

       my $dom = Mojo::DOM->new($body);
       for my $e ($dom->find("ul.v")->each) {
           my $title = $e->at("li.v_title")->a->attr('title');
           my $play_num = $e->li->[-1]->span->text;
           $play_num =~ s/,//g;
           print $fh  "$title => $play_num\n";
       }
   }
}
close $fh;

my $awk = 'awk -F "=>" \'{total+=$NF}/=>/{sum+=$NF;next}{if(NR!=1)print sum;print $1;sum=0}END{print sum;print "Total:\n"total}\' youku.log.'.$date;
open $fh, ">youku_count_$date.log";
open AWK, "$awk|" or die "Can't open AWK: $!";
print $fh <AWK>;
close $fh;
