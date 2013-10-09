#!/usr/bin/env perl

use OpenOffice::OODoc;

my $document = odfDocument(file => 'user-list.ods');
my $element = $document->getElement('//text:p', 2);
my $text = $document->getText($element);

print $text;
