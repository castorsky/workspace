#!/usr/bin/perl

use Net::Ping;

$test_server="8.8.8.8";

$message1 = "No echo replies from $test_server. Trying to restart connection.";
$message2 = "Echo replies were received from $test_server. Restart isn't required.";
$message3 = "PPP have not been enabled in rc.conf. Script won't check connection.";

# Does this script have to check connection
# By default ENABLE = 0. If PPP is enabled in rc.conf, then ENABLE = 1
$enable = "0";
$debug = "0";

sub brevno {
    qx{/usr/bin/logger -t pppoe_test "@_"};
}

chomp($enable = qx{cat /etc/rc.conf | grep -ic 'ppp_enable="YES"'}) if (-e "/etc/rc.conf");
if ($enable == "1") {
    $counter = 0;
    $probe = Net::Ping->new('icmp', 1);
    for ($x = 0; $x < 3; $x++) {
        $counter++ if $probe->ping($test_server);
    }
    $probe->close();
    if ($counter == 0) {
        brevno($message1);
        qx{killall -9 ppp};
        qx{sleep 2};
        qx{/usr/sbin/ppp -quiet -ddial WELLNET};
    } else {
        brevno($message2) if ($debug == 1);
    }
}
else {
    brevno($message3) if ($debug == 1);
}
