# use this file to seed the master database server which all access points will write to

CREATE DATABASE geotrack;
CREATE EXTENSION postgis;

CREATE TABLE "access-points" (
    id serial,
    name text,
    location geography(POINT),
    PRIMARY KEY (id)
);

CREATE TABLE "client-data" (
    client text NOT NULL,
    "client-manufacturer" text DEFAULT NULL,
    "access-point" int NOT NULL,
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
    FOREIGN KEY ("access-point") REFERENCES "access-points"(id)
);
