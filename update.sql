BEGIN;
UPDATE catalog_relations r SET entity_kind=d.entity_kind, attributes=d.attributes FROM current_version_delta d WHERE r.version=d.version AND r.entity_name=d.entity_name AND d.source~'current';
INSERT INTO catalog_relations SELECT version, entity_name, entity_kind, attributes FROM current_version_delta WHERE source ~ 'current';
DELETE FROM catalog_relations r USING current_version_delta d WHERE r.version = d.version AND r.entity_name = d.entity_name AND d.source ~ 'stored';
COMMIT;
