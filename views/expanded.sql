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


