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
            , CASE
              WHEN column_type IN ( 'name', 'anyarray' ) THEN 'text'
              ELSE column_type
            END
          )::attribute
        FROM _cat_tools.column cc
        WHERE cc.reloid = c.reloid
          AND ( attnum>0 OR attname IN( 'xmin', 'oid' ) )
          AND NOT attisdropped -- Be paranoid...
        ORDER BY attnum
      ) AS attributes

  FROM _cat_tools.pg_class_v c
  WHERE
    relname = 'pg_stat_statements'
    OR (relschema='pg_catalog' AND relkind IN ('r', 'v'))
    /*
        AND (
            ( relkind = 'r' )--AND relname !~ '^pg_(authid|statistic)' )
            OR ( relkind = 'v' AND (
                  relname = 'pg_stat_user_functions' 
                  OR ( relname ~ '^pg_stat' AND relname !~ '_(user|sys|xact)_' AND relname != 'pg_stats' )
                  OR relname !~ '^pg_(group|indexes|matviews|policies|shadow|stat|tables|user|views)'
            ) )
        )
      )
      */
;

-- vi: expandtab ts=2 sw=2
