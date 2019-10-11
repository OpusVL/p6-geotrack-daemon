unit class OpusVL::Geotrack::Persistence::PostgreSQL;

use DB::Pg;

has $.dsn is required;
has $!dbi;

submethod TWEAK() {
    $!dbi = DB::Pg.new(:conninfo($!dsn));
}

method insert-record(%client-data) {
    my $query = $!dbi.db.prepare('INSERT INTO "client-data"
                                  VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16);');
    $query.execute(%client-data<client>, %client-data<client-manufacturer>, %client-data<access-point>,
                   %client-data<last-signal-dbm>, %client-data<last-noise-dbm>, %client-data<last-signal-rssi>, %client-data<last-noise-rssi>,
                   %client-data<min-signal-dbm>, %client-data<min-noise-dbm>, %client-data<min-signal-rssi>, %client-data<min-noise-rssi>,
                   %client-data<max-signal-dbm>, %client-data<max-noise-dbm>, %client-data<max-signal-rssi>, %client-data<max-noise-rssi>,
                   %client-data<timestamp>
    );
    $query.finish;
}
