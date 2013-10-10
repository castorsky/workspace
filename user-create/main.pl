#!/usr/bin/env perl

#use Encode;
use OpenOffice::OODoc;
use Lingua::Translit;

my $columns =  5;
my $document = odfDocument(file => 'user-list.ods');
my $rows = $document->getTableRows('userlist');
my $table = $document->getTable('userlist', $columns, $rows);

for ($i = 0; $i < $rows; $i++) {
	my $testcell = $document->getCellValue($table, $i, 0);
	$testcell =~ s/^(\S+)\s+(\S+).*/$2/;
	if ($testcell) { print $testcell."\n"; };
}