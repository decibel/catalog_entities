psql -c "\copy (SELECT * FROM catalog_relations ORDER BY version, entity_type, entity_name) TO 'data.tsv' (FORMAT csv, HEADER true)" $@
