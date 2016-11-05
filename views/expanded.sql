CREATE VIEW expanded AS
  SELECT c.version, c.entity_name, a.*
    FROM latest c,
      LATERAL (
        SELECT attribute_name, attribute_type
            , ordinality - max(ordinality) OVER() - 1 AS ordinality
          FROM unnest(c.system_attributes) WITH ORDINALITY
        UNION ALL
        SELECT * FROM unnest(c.attributes) WITH ORDINALITY
    ) a
;

CREATE VIEW latest_expanded AS
  SELECT c.version, c.entity_name, a.*
    FROM latest c,
      LATERAL (
        SELECT attribute_name, attribute_type
            , ordinality - max(ordinality) OVER() - 1 AS ordinality
          FROM unnest(c.system_attributes) WITH ORDINALITY
        UNION ALL
        SELECT * FROM unnest(c.attributes) WITH ORDINALITY
    ) a
;

-- vi: expandtab ts=2 sw=2
