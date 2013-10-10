#!/usr/bin/env perl

#use Encode;
use OpenOffice::OODoc;
use Lingua::Translit;

my $columns =  5;
my $document = odfDocument(file => 'user-list.ods');
my $rows = $document->getTableRows('userlist');
my $table = $document->getTable('userlist', $columns, $rows);

for ($row = 1; $row < $rows; $row++) {
	my $testcell = $document->getCellValue($table, $row, 0);
	$testcell =~ s/^(\S+)\s+(\S+)(\s|\.)(\S+).*/$4/;
	if ($testcell) { print $testcell."\n"; };
}