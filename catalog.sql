CREATE TYPE attribute AS (
	attribute_name text,
	attribute_type regtype
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
);

\COPY catalog_relations (version, entity_name, entity_kind, attributes) FROM 'data.tsv' (FORMAT csv, HEADER true)

ALTER TABLE ONLY catalog_relations
    ADD CONSTRAINT entity_pkey PRIMARY KEY (version, entity_name);


/*
 * VIEWS
 */
CREATE VIEW changed AS
 SELECT a.version,
    a.entity_name,
    a.entity_kind,
    a.attributes,
    a.previous_attributes
   FROM ( SELECT e.version,
            e.entity_name,
            e.entity_kind,
            e.attributes,
            ( SELECT e2.attributes
                   FROM catalog_relations e2
                  WHERE ((e2.entity_name = e.entity_name) AND (e2.version < e.version))
                  ORDER BY e2.version DESC
                 LIMIT 1) AS previous_attributes
           FROM catalog_relations e
          WHERE (e.version > ( SELECT min(catalog_relations.version) AS min
                   FROM catalog_relations))
          ORDER BY e.version, e.entity_name) a
  WHERE (a.attributes IS DISTINCT FROM a.previous_attributes);


CREATE VIEW latest AS
 SELECT catalog_relations.version,
    catalog_relations.entity_name,
    catalog_relations.entity_kind,
    catalog_relations.attributes
   FROM catalog_relations
  WHERE (catalog_relations.version = ( SELECT max(catalog_relations_1.version) AS max
           FROM catalog_relations catalog_relations_1));


CREATE VIEW latest_expanded AS
 SELECT c.version,
    c.entity_name,
    a.attribute_name,
    a.attribute_type,
    a.ordinality
   FROM latest c,
    LATERAL unnest(c.attributes) WITH ORDINALITY a(attribute_name, attribute_type, ordinality);


CREATE VIEW expanded AS
 SELECT e.version,
    e.entity_name,
    a.attribute_name,
    a.attribute_type,
    a.ordinality
   FROM catalog_relations e,
    LATERAL unnest(e.attributes) WITH ORDINALITY a(attribute_name, attribute_type, ordinality);

-- vi: expandtab sw=2 ts=2
