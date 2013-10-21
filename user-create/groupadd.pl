#!/usr/bin/env perl

use OpenOffice::OODoc;
use Lingua::Translit;

my $columns =  6;
my $document = odfDocument(file => 'firstcourse2010.ods');
my $rows = $document->getTableRows('Лист1');
my $table = $document->getTable('Лист1', $columns, $rows);

for ($row = 1; $row < $rows; $row++) {
	my $Initials = "";
	$Initials = $document->getCellValue($table, $row, 1);
	next if !$Initials;
	my $command = 'cl-groupmod -a '.$Initials.' y2010 samba';
	#print $command."\n";
	my $res=qx/$command/;
	print $res;
}

$document->save;
