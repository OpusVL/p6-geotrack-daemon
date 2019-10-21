use OpusVL::Geotrack::Configuration;
use OpusVL::Geotrack::Persistence::PostgreSQL;

use Terminal::ANSIColor;
use XML;

my $configuration-handler = OpusVL::Geotrack::Configuration.new;
my %configuration = $configuration-handler.configuration;

my $psql = OpusVL::Geotrack::Persistence::PostgreSQL.new(:dsn($configuration-handler.generate-dsn));

sub MAIN {
    say DateTime.now ~ " OpusVL::Geotrack is active and monitoring " ~ %configuration<geotrack-filepath> ~ ".";

    react {
        whenever %configuration<geotrack-filepath>.IO.watch -> $event {
            if $event.IO.extension eq "netxml" {
                harvest($event.path) if $event.event ~~ FileChanged and $event.path.IO.e;
            }
        }
    }
}

sub harvest($path) {
    my @wireless-clients = from-xml(slurp($path)).root.elements(:TAG('wireless-client'), :RECURSE);
    parse(@wireless-clients, $path);
    expunge($path);
}

sub parse(@wireless-clients, $path) {
    my $records = @wireless-clients.elems;
    say DateTime.now ~ " Parsing $path. $records total records found.";

    my $get = &value-of-tag.assuming($_);

    for @wireless-clients {
        my %client-data = client => $_.lookfor(:TAG('client-mac'), :SINGLE).firstChild.text,
                          client-manuf => $_.lookfor(:TAG('client-manuf'), :SINGLE).firstChild.text,
                          access-point => %configuration<access-point> || %*ENV<GEOTRACK_ACCESS_POINT>,
                          last-signal-dbm => $_.lookfor(:TAG('last_signal_dbm'), :SINGLE).firstChild.text,
                          last-noise-dbm => $_.lookfor(:TAG('last_noise_dbm'), :SINGLE).firstChild.text,
                          last-signal-rssi => $_.lookfor(:TAG('last_signal_rssi'), :SINGLE).firstChild.text,
                          last-noise-rssi => $_.lookfor(:TAG('last_noise_rssi'), :SINGLE).firstChild.text,
                          min-signal-dbm => $_.lookfor(:TAG('min_signal_dbm'), :SINGLE).firstChild.text,
                          min-noise-dbm => $_.lookfor(:TAG('min_noise_dbm'), :SINGLE).firstChild.text,
                          min-signal-rssi => $_.lookfor(:TAG('min_signal_rssi'), :SINGLE).firstChild.text,
                          min-noise-rssi => $_.lookfor(:TAG('min_noise_rssi'), :SINGLE).firstChild.text,
                          max-signal-dbm => $_.lookfor(:TAG('max_signal_dbm'), :SINGLE).firstChild.text,
                          max-noise-dbm => $_.lookfor(:TAG('max_noise_dbm'), :SINGLE).firstChild.text,
                          max-signal-rssi => $_.lookfor(:TAG('max_signal_rssi'), :SINGLE).firstChild.text,
                          max-noise-rssi => $_.lookfor(:TAG('max_noise_rssi'), :SINGLE).firstChild.text,
                          timestamp => $_<last-time> || DateTime.now
        ;
        reap(%client-data);
    }
}

sub value-of-tag($xml, $tag-name) {
    $xml.lookfor(:TAG($tag-name), :SINGLE).firstChild.text;
}

sub reap(%client-data) {
    $psql.insert-record(%client-data);
}

sub expunge($path) {
    say DateTime.now ~ " Complete, removing $path.";
    unlink($path);
}
