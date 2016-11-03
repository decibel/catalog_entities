CREATE OR REPLACE VIEW current_version_delta AS
SELECT * FROM (
  -- Add extra line to help break up output
  SELECT E'stored\n'::text AS source, *
    FROM (
      SELECT * FROM catalog_relations WHERE version = (SELECT min(version) FROM current_version_relation)
      EXCEPT ALL
      SELECT * FROM current_version_relation
    ) s
  UNION ALL
  SELECT 'current', *
    FROM (
      SELECT * FROM current_version_relation
      EXCEPT ALL
      -- Change min to max to hopefully make it obvious if that somehow broke...
      SELECT * FROM catalog_relations WHERE version = (SELECT max(version) FROM current_version_relation)
    ) c
  ) d
  ORDER BY version, entity_name, source

;

-- vi: expandtab ts=2 sw=2

