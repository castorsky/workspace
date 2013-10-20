#!/usr/bin/env perl

use OpenOffice::OODoc;
use Lingua::Translit;

my $columns =  6;
my $document = odfDocument(file => 'user-list.ods');
my $rows = $document->getTableRows('userlist');
my $table = $document->getTable('userlist', $columns, $rows);
$transl = new Lingua::Translit("GOST 7.79 RUS");

# Sub was taken at http://perl.about.com/od/perltutorials/a/genpassword.htm
# Slightly modified - $password is local variable now.
sub generatePassword {
   $length = shift;
   my $possible = 'abcdefghijkmnpqrstuvwxyz23456789';
   my $password = ''; 
   while (length($password) < $length) {
     $password .= substr($possible, (int(rand(length($possible)))), 1);
   }
   return $password
 } 

print $rows."\n";

for ($row = 1; $row < $rows; $row++) {
	print $document->getCellValue($table, $row, 3)."\n";
}

#for ($row = 1; $row < $rows; $row++) {
#	my $FIO = $document->getCellValue($table, $row, 0);
#	my $groupList = $document->getCellValue($table, $row, 3);
#	next if !$FIO;
#	$Name = $transl->translit($FIO);
#	$Name =~ s/`//g;
#	$Name =~ m/^[A-Za-z]+(?=\s.*)/;
#	my $LastName = $&;
#	$Name =~ m/^[A-Za-z]+\s\K[A-Z](?=[a-z]*(\s|\.).*)/;
#	my $FirstName = $&;
#	$Name =~ m/^[A-Za-z]+\s[A-Za-z]+(\s|\.)\s*\K[A-Z](?=[a-z]*.*)/;
#	my $Patronimic = $&;
#	my $Initials = $LastName.$FirstName.$Patronimic;
#	$tempPasswd = generatePassword(8);
#	print $Initials." - ".$tempPasswd."\n".$groupList."\n";
#}