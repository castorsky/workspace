#!/usr/bin/env perl

use OpenOffice::OODoc;
use Lingua::Translit;

my $columns =  6;
my $document = odfDocument(file => 'user-list.ods');
my $rows = $document->getTableRows('userlist');
my $table = $document->getTable('userlist', $columns, $rows);
$transl = new Lingua::Translit("GOST 7.79 RUS");

sub generatePassword {
# Sub was taken at http://perl.about.com/od/perltutorials/a/genpassword.htm
# Slightly modified - $password is local variable now.
   $length = shift;
   my $possible = 'abcdefghijkmnpqrstuvwxyz23456789';
   my $password = ''; 
   while (length($password) < $length) {
     $password .= substr($possible, (int(rand(length($possible)))), 1);
   }
   return $password
 } 

for ($row = 1; $row < $rows; $row++) {
	my $FIO = "";
	my $Initials = "";
	my $tempPassword = "";
	$FIO = $document->getCellValue($table, $row, 0);
	next if !$FIO;
	$Name = $transl->translit($FIO);
	# Some cyrillic letters appears as ` or y'
	$Name =~ s/[`']//g;
	$Name =~ m/^[A-Za-z]+(?=\s.*)/;
	my $LastName = $&;
	$Name =~ m/^[A-Za-z]+\s*\K[A-Z](?=[a-z]*(\s|\.).*)/;
	my $FirstName = $&;
	$Name =~ m/^[A-Za-z]+\s*[A-Za-z]+(\s|\.)\s*\K[A-Z](?=[a-z]*.*)/;
	my $Patronimic = $&;
	$Initials = $LastName.$FirstName.$Patronimic;
	$tempPasswd = generatePassword(8);
	$document->cellValueType($table, $row, 1, 'string');
	$document->cellValue($table, $row, 1, $Initials);
	$document->cellValueType($table, $row, 2, 'string');
	$document->cellValue($table, $row, 2, $tempPasswd);
	my $groupList = $document->getCellValue($table, $row, 3);
	my $command = 'cl-useradd -c "'.$FIO.'" -g users -G "'.$groupList.'" -P	'.$Initials.' samba <<< "'.$tempPasswd.'"';
	# print $Initials." - ".$tempPasswd." - ".$groupList."\n";
	my $res=qx/$command/;
	print $res."\n";
}

$document->save;
