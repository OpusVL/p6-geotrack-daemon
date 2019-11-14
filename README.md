# p6-geotrack-daemon
Perl 6 daemon to slurp netXML files and parse the data into a PostgreSQL database.

## Dependencies

- Rakudo 2019.03 (Perl 6.d)
- libpq-dev

### Zef modules

```
zef install XML DB::Pg JSON::Fast Terminal::ANSIColor
```

## Configuration

## Preparing a PostgreSQL database
To prepare your PostgreSQL database, use the provided example [`database-tables.sql`](https://github.com/OpusVL/p6-geotrack-daemon/blob/master/database-tables.sql) file to create the two required tables. I've personally been testing with the [`mdillon/postgis`](https://hub.docker.com/r/mdillon/postgis) Dockerfile which gives us a not-so unreasonable PostgreSQL 11.2 to work with.
```sql
CREATE DATABASE geotrack;
CREATE EXTENSION postgis;

CREATE TABLE "access-points" (
    name text NOT NULL,
    description text,
    location geography(POINT),
    PRIMARY KEY (name, location)
);

CREATE TABLE "client-data" (
    client text NOT NULL,
    "client-manufacturer" text DEFAULT NULL,
    "access-point" text NOT NULL,
    "last-signal-dbm" int,
    "last-noise-dbm" int,
    "last-signal-rssi" int,
    "last-noise-rssi" int,
    "min-signal-dbm" int,
    "min-noise-dbm" int,
    "min-signal-rssi" int,
    "min-noise-rssi" int,
    "max-signal-dbm" int,
    "max-noise-dbm" int,
    "max-signal-rssi" int,
    "max-noise-rssi" int,
    timestamp timestamptz NOT NULL,
    FOREIGN KEY ("access-point") REFERENCES "access-points"(name)
);
```
### Access Points

For each wireless basestation, you'll need to do some manual SQL queries to add a new 'access point' to the `access-points` table. This involves first discovering the coordinates of the physical location and using the PostGIS extension to convert that data into a `geography(POINT)`.
```sql
geotrack=# SELECT ST_GeometryFromText('POINT(52.3710507 -1.264331)', 4326);
                st_geometryfromtext                 
----------------------------------------------------
 0101000020E610000036D4DE967E2F4A40871A8524B33AF4BF
(1 row)
```
With this information, we can now add our new access point.
```sql
INSERT INTO "access-points" VALUES ('opusvlwifi', 'OpusVL Office Wifi', '0101000020E610000036D4DE967E2F4A40871A8524B33AF4BF');
```
