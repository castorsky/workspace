#!/usr/bin/env perl

use OpenOffice::OODoc;
use Lingua::Translit;

my $columns =  6;
my $document = odfDocument(file => 'user-list.ods');
my $rows = $document->getTableRows('userlist');
my $table = $document->getTable('userlist', $columns, $rows);

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
	my $Initials = "";
	my $tempPassword = "";
	$Initials = $document->getCellValue($table, $row, 1);
	next if !$Initials;
	$tempPasswd = generatePassword(6);
	$document->cellValueType($table, $row, 2, 'string');
	$document->cellValue($table, $row, 2, $tempPasswd);
	my $command = 'cl-usermod -P '.$Initials.' samba <<< "'.$tempPasswd.'"';
	my $res=qx/$command/;
	print $Initials."\n".$res;
}

$document->save;
