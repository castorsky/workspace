#!/usr/bin/env perl

package Uploader;
use HTTP::DAV;
use Exporter 'import';
@EXPORT_OK = qw(upload);

$serv = HTTP::DAV->new();
$url = "https://webdav.yandex.ru/";
$serv->credentials(
	-user => "siblux.net",
	-pass => "IAmTheR00t",
	-url => $url,
	-realm => "Yandex.Disk"
);

sub upload {
	$serv->open( -url => $url )
		or die("Couldn't open $url: ".$serv->message."\n");

	$serv->lock(
		-url => "$url/Backup",
		-timeout => "10m"
	) or die ("Won't put unless I can lock for 10 minutes.\n");

	if ( $serv->put( -local => "@_", -url => "$url/Backup") ) {
		print "Successfully uploaded.";
	} else {
		print "Upload failed: ".$serv->message."\n";
	}

	$serv->unlock( -url => $url );
}
