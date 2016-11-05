CREATE OR REPLACE VIEW current_version_relation AS
SELECT
    -- This will create an error for a non-numeric version (like a beta), which is what we want
    regexp_replace(current_setting('server_version'), '\.[0-9]+$', '')::numeric AS version

    , relname::text AS entity_name
    , CASE relkind WHEN 'r' THEN 'Table' WHEN 'v' THEN 'View' END::entity_kind AS entity_kind

    , array(
      SELECT
          row(
            attname
            , column_type
          )::attribute
        FROM _cat_tools.column cc
        WHERE cc.reloid = c.reloid
          AND ( attnum>0 OR attname = 'oid' )
          AND NOT attisdropped -- Be paranoid...
        ORDER BY attnum
      ) AS attributes

  FROM _cat_tools.pg_class_v c
  WHERE
    relname = 'pg_stat_statements'
    OR (relschema='pg_catalog' AND relkind IN ('r', 'v'))
;

-- vi: expandtab ts=2 sw=2
