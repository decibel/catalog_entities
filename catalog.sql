BEGIN;

CREATE TYPE attribute AS (
	attribute_name text,
	attribute_type text
);

CREATE TYPE entity_kind AS ENUM (
  'Table'
  , 'View'
);

CREATE TYPE entity_type AS ENUM (
    'Catalog',
    'Stats File',
    'Other Status'
);

CREATE TABLE catalog_relations (
    version numeric NOT NULL
    , entity_name text NOT NULL
    , entity_kind entity_kind --NOT NULL
    , attributes attribute[] NOT NULL
    , system_attributes attribute[]
);

\COPY catalog_relations (version, entity_name, entity_kind, attributes, system_attributes) FROM 'data.csv' (FORMAT csv, HEADER true)

ALTER TABLE ONLY catalog_relations
    ADD CONSTRAINT entity_pkey PRIMARY KEY (version, entity_name);


/*
 * VIEWS
 */

\i views/current_version_relation.sql

-- Depends on current_version_relation
\i views/current_version_delta.sql

CREATE VIEW latest AS
  SELECT *
    FROM catalog_relations
    WHERE version = (
      SELECT max(version) FROM catalog_relations)
;
COMMIT;

-- vi: expandtab sw=2 ts=2
