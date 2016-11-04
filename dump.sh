psql -X -c "\copy (SELECT * FROM catalog_relations ORDER BY version, entity_kind, entity_name) TO 'data.csv' (FORMAT csv, HEADER true)" $@ || exit 1
