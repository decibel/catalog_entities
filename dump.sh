psql -c "\copy (SELECT * FROM catalog_relations ORDER BY version, entity_kind, entity_name) TO 'data.tsv' (FORMAT csv, HEADER true)" $@ || exit 1
