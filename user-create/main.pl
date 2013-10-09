#!/usr/bin/env perl

use OpenOffice::OODoc;

my $document = odfDocument(file => 'user-list.ods');
my $table = $document->getTableList();
my ($lines, $columns) = $document->getTableSize('userlist');
my $rows = $document->getTableRows('userlist');

print $lines.' '.$columns."\n";
print $rows;
