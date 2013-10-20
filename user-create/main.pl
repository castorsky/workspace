#!/usr/bin/env perl

use OpenOffice::OODoc;
use Lingua::Translit;

my $columns =  5;
my $document = odfDocument(file => 'user-list.ods');
my $rows = $document->getTableRows('userlist');
my $table = $document->getTable('userlist', $columns, $rows);
$transl = new Lingua::Translit("GOST 7.79 RUS");

for ($row = 1; $row < $rows; $row++) {
	my $FIO = $document->getCellValue($table, $row, 0);
	next if !$FIO;
	$Name = $transl->translit($FIO);
	$Name =~ s/`//g;
	$Name =~ m/^[A-Za-z]+(?=\s.*)/;
	my $LastName = $&;
	$Name =~ m/^[A-Za-z]+\s\K[A-Za-z]+(?=(\s|\.).*)/;
	my $FirstName = $&;
	$Name =~ m/^[A-Za-z]+\s[A-Za-z]+(\s|\.)\s*\K[A-Za-z]+(?=.*)/;
	my $Patronimic = $&;
	
	print $Name."\n".$LastName."\n".$FirstName."\n".$Patronimic."\n";
}