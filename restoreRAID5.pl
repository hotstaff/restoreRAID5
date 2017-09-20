#!/usr/bin/perl
use strict;
# *************************************************************************
# HD-QSSU2/R5 RAID5復旧用スクリプト
# .壊れていないHDDからアレイデータを再構成する
#
# このプログラムが対象としているアレイの構造
# -------------------------
# 4本構成 SATA
# RAID5
# HardRaid
# ストライプサイズ: 1セクタ(512バイト)
# Layout: Left-Asymmetric
# -------------------------
# ＜注意＞構造が違う場合はそのまま実行できません。ソースコードの修正が必要です。
# 参考元1（プログラム）：http://www.maniac.ne.jp/~maniac/weblog/archives/2009/06/raid5.html
# 参考元2（アレイ情報）：http://3309masa.blog130.fc2.com/blog-category-4.html
# *************************************************************************

my @HDD;
#*******************設定*********************
#STEP1 アレイの順番とデバイスを設定
    #復旧に使わないHDDはコメントアウト
    $HDD[0] = "/dev/sda1"; #1番
    $HDD[1] = "/dev/sda1"; #2番
    $HDD[2] = "/dev/sda1"; #3番
    #$HDD[3] = "/dev/sdd"; #4番
    #
#STEP2 出力先設定
    # 1)テスト用の出力ファイル
    my $outdev="./test.dat";
    # 2)デバイスへ出力
    #$outdev="/dev/sdd";
    #
#STEP3 出力するセクタ数
    # 1)テストとして先頭 10000 セクタのみ実行
    my $maxsect = 5000;
    # 2)RAID の１本のディスクのセクタ数
    #my $maxsect = 488397168; #WD5000AAKS 500GBの場合（HDDラベルのLBAの表記数を指定）
    #maxsectで指定した数より前にEOFになった場合はコピーを終了します。
#
#********************************************
#OPTION（通常はそのまま）
#開始するセクタ番号
my $startsect=5000;
#ストライプサイズ
my $stripesize=512; #byte
#****************設定ここまで*****************

#DEVICE
my @dev; #READ DEVICES
my $OUT; #OUTPUT DEVICE

my $brk; #壊れたHDDのアレイ番号
my $cnt=0; #counter of HDD
my $endsect = $startsect + $maxsect - 1; #終了するセクタ番号

#デバイスのOPEN
print "***************Source*****************\n";
for(my $k = 0; $k < 4 ; $k++){
    if(defined $HDD[$k]){
        open($dev[$k], "<" , $HDD[$k]) or die("HDD[$k]: $HDD[$k] could not open.\n");  
        sysseek($dev[$k], $startsect*$stripesize, 0) or die("$HDD[$k] could not seek sector of start: $startsect.\n");
        print "HDD[$k]: $HDD[$k]\n";  
        $cnt++;
    }else{
        $brk = $k;
    }
}
print "***************Output*****************\n";
if($cnt < 3){die "The number of HDD < 3. Exit.\n";}
if($startsect!=0){
    print "[option]Start sector: $startsect\n";
    my $writepos = $startsect*$stripesize*3;
    open($OUT , ">>", $outdev) or die ("$outdev could not open.\n");
    sysseek($OUT, $writepos, 0) or die("Output could not seek sector of start: $startsect.\n");
    print "<CAUTION>\n"; 
    print "  If the output is image file and the start sector $startsect could not seek, the restored data append to end of image file.\n\n";
    print "Output: $outdev (Append copy)\n";
}else{
    open($OUT , ">", $outdev) or die ("$outdev could not open.\n");
    print "Output: $outdev (Full copy: delete and copy)\n";
}
print "Max sector count: $maxsect\n";
print "Copy sector: $startsect to $endsect\n";
print "**************************************\n";


#実行前確認
{
    local( $| ) = ( 1 );
    print "Press <Enter> or <Return> to continue: \n";
    my $resp = <STDIN>;
}

#実行部
my @data;
my $s = $startsect;
COPY: while(1){
    # セクターカウントが上限に達したらループを抜ける
    if($s > $endsect){
        print "\nReached max sector count.\n";
        last COPY;
    }
    # セクタ読み込み
    for(my $j = 0 ; $j < 4; $j++){
        if( $j == $brk ){next;}
        my $length = sysread($dev[$j] , $data[$j] , $stripesize);
        die "\nRead error: $!, Sector $s\n" unless defined $length;
        if ($length == 0){
            print "\nReached EOF at Sector $s.\n";
            last COPY;
        }
    }
        
    # HDD３台から壊れたHDDの部分（XOR）を計算
    $data[$brk] = $data[($brk+1)%4]^$data[($brk+2)%4]^$data[($brk+3)%4];
    
    # パリティは出力に含めない
    my $mod = $s % 4;
    my $parity = 3 - $mod;
    $data[$parity] = "";

    # 出力
    syswrite $OUT, "$data[0]$data[1]$data[2]$data[3]";
    print "Sector $s\r";

    $s++;
}

print "Finished.              \n";

#デバイスのCLOSE
for(my $l = 0; $l < 4; $l++){
    if(defined $HDD[$l]){
        close($dev[$l]);
    }
}
close($OUT);

