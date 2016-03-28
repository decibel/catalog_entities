--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6devel
-- Dumped by pg_dump version 9.6devel

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: attribute; Type: TYPE; Schema: public; Owner: decibel
--

CREATE TYPE attribute AS (
	attribute_name text,
	attribute_type regtype
);


ALTER TYPE attribute OWNER TO decibel;

--
-- Name: entity_type; Type: TYPE; Schema: public; Owner: decibel
--

CREATE TYPE entity_type AS ENUM (
    'Catalog',
    'Stats File',
    'Other Status'
);


ALTER TYPE entity_type OWNER TO decibel;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: catalog_relations; Type: TABLE; Schema: public; Owner: decibel
--

CREATE TABLE catalog_relations (
    version numeric NOT NULL,
    entity_name text NOT NULL,
    entity_type entity_type NOT NULL,
    attributes attribute[] NOT NULL
);


ALTER TABLE catalog_relations OWNER TO decibel;

--
-- Name: changed; Type: VIEW; Schema: public; Owner: decibel
--

CREATE VIEW changed AS
 SELECT a.version,
    a.entity_name,
    a.entity_type,
    a.attributes,
    a.previous_attributes
   FROM ( SELECT e.version,
            e.entity_name,
            e.entity_type,
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


ALTER TABLE changed OWNER TO decibel;

--
-- Name: current; Type: VIEW; Schema: public; Owner: decibel
--

CREATE VIEW current AS
 SELECT catalog_relations.version,
    catalog_relations.entity_name,
    catalog_relations.entity_type,
    catalog_relations.attributes
   FROM catalog_relations
  WHERE (catalog_relations.version = ( SELECT max(catalog_relations_1.version) AS max
           FROM catalog_relations catalog_relations_1));


ALTER TABLE current OWNER TO decibel;

--
-- Name: current_expanded; Type: VIEW; Schema: public; Owner: decibel
--

CREATE VIEW current_expanded AS
 SELECT c.version,
    c.entity_name,
    a.attribute_name,
    a.attribute_type,
    a.ordinality
   FROM current c,
    LATERAL unnest(c.attributes) WITH ORDINALITY a(attribute_name, attribute_type, ordinality);


ALTER TABLE current_expanded OWNER TO decibel;

--
-- Name: expanded; Type: VIEW; Schema: public; Owner: decibel
--

CREATE VIEW expanded AS
 SELECT e.version,
    e.entity_name,
    a.attribute_name,
    a.attribute_type,
    a.ordinality
   FROM catalog_relations e,
    LATERAL unnest(e.attributes) WITH ORDINALITY a(attribute_name, attribute_type, ordinality);


ALTER TABLE expanded OWNER TO decibel;

--
-- Data for Name: catalog_relations; Type: TABLE DATA; Schema: public; Owner: decibel
--

COPY catalog_relations (version, entity_name, entity_type, attributes) FROM stdin;
9.6	pg_aggregate	Catalog	{"(xmin,xid)","(aggfnoid,regproc)","(aggkind,\\"\\"\\"char\\"\\"\\")","(aggnumdirectargs,smallint)","(aggtransfn,regproc)","(aggfinalfn,regproc)","(aggcombinefn,regproc)","(aggmtransfn,regproc)","(aggminvtransfn,regproc)","(aggmfinalfn,regproc)","(aggfinalextra,boolean)","(aggmfinalextra,boolean)","(aggsortop,oid)","(aggtranstype,oid)","(aggtransspace,integer)","(aggmtranstype,oid)","(aggmtransspace,integer)","(agginitval,text)","(aggminitval,text)"}
9.6	pg_am	Catalog	{"(xmin,xid)","(oid,oid)","(amname,text)","(amhandler,regproc)"}
9.6	pg_amop	Catalog	{"(xmin,xid)","(oid,oid)","(amopfamily,oid)","(amoplefttype,oid)","(amoprighttype,oid)","(amopstrategy,smallint)","(amoppurpose,\\"\\"\\"char\\"\\"\\")","(amopopr,oid)","(amopmethod,oid)","(amopsortfamily,oid)"}
9.6	pg_amproc	Catalog	{"(xmin,xid)","(oid,oid)","(amprocfamily,oid)","(amproclefttype,oid)","(amprocrighttype,oid)","(amprocnum,smallint)","(amproc,regproc)"}
9.6	pg_attrdef	Catalog	{"(xmin,xid)","(oid,oid)","(adrelid,oid)","(adnum,smallint)","(adbin,pg_node_tree)","(adsrc,text)"}
9.6	pg_attribute	Catalog	{"(xmin,xid)","(attrelid,oid)","(attname,text)","(atttypid,oid)","(attstattarget,integer)","(attlen,smallint)","(attnum,smallint)","(attndims,integer)","(attcacheoff,integer)","(atttypmod,integer)","(attbyval,boolean)","(attstorage,\\"\\"\\"char\\"\\"\\")","(attalign,\\"\\"\\"char\\"\\"\\")","(attnotnull,boolean)","(atthasdef,boolean)","(attisdropped,boolean)","(attislocal,boolean)","(attinhcount,integer)","(attcollation,oid)","(attacl,aclitem[])","(attoptions,text[])","(attfdwoptions,text[])"}
9.6	pg_auth_members	Catalog	{"(xmin,xid)","(roleid,oid)","(member,oid)","(grantor,oid)","(admin_option,boolean)"}
9.6	pg_available_extension_versions	Other Status	{"(name,text)","(version,text)","(installed,boolean)","(superuser,boolean)","(relocatable,boolean)","(schema,text)","(requires,name[])","(comment,text)"}
9.6	pg_available_extensions	Other Status	{"(name,text)","(default_version,text)","(installed_version,text)","(comment,text)"}
9.6	pg_cast	Catalog	{"(xmin,xid)","(oid,oid)","(castsource,oid)","(casttarget,oid)","(castfunc,oid)","(castcontext,\\"\\"\\"char\\"\\"\\")","(castmethod,\\"\\"\\"char\\"\\"\\")"}
9.6	pg_class	Catalog	{"(xmin,xid)","(oid,oid)","(relname,text)","(relnamespace,oid)","(reltype,oid)","(reloftype,oid)","(relowner,oid)","(relam,oid)","(relfilenode,oid)","(reltablespace,oid)","(relpages,integer)","(reltuples,real)","(relallvisible,integer)","(reltoastrelid,oid)","(relhasindex,boolean)","(relisshared,boolean)","(relpersistence,\\"\\"\\"char\\"\\"\\")","(relkind,\\"\\"\\"char\\"\\"\\")","(relnatts,smallint)","(relchecks,smallint)","(relhasoids,boolean)","(relhaspkey,boolean)","(relhasrules,boolean)","(relhastriggers,boolean)","(relhassubclass,boolean)","(relrowsecurity,boolean)","(relforcerowsecurity,boolean)","(relispopulated,boolean)","(relreplident,\\"\\"\\"char\\"\\"\\")","(relfrozenxid,xid)","(relminmxid,xid)","(relacl,aclitem[])","(reloptions,text[])"}
9.6	pg_collation	Catalog	{"(xmin,xid)","(oid,oid)","(collname,text)","(collnamespace,oid)","(collowner,oid)","(collencoding,integer)","(collcollate,text)","(collctype,text)"}
9.6	pg_config	Other Status	{"(name,text)","(setting,text)"}
9.6	pg_constraint	Catalog	{"(xmin,xid)","(oid,oid)","(conname,text)","(connamespace,oid)","(contype,\\"\\"\\"char\\"\\"\\")","(condeferrable,boolean)","(condeferred,boolean)","(convalidated,boolean)","(conrelid,oid)","(contypid,oid)","(conindid,oid)","(confrelid,oid)","(confupdtype,\\"\\"\\"char\\"\\"\\")","(confdeltype,\\"\\"\\"char\\"\\"\\")","(confmatchtype,\\"\\"\\"char\\"\\"\\")","(conislocal,boolean)","(coninhcount,integer)","(connoinherit,boolean)","(conkey,smallint[])","(confkey,smallint[])","(conpfeqop,oid[])","(conppeqop,oid[])","(conffeqop,oid[])","(conexclop,oid[])","(conbin,pg_node_tree)","(consrc,text)"}
9.6	pg_seclabel	Catalog	{"(xmin,xid)","(objoid,oid)","(classoid,oid)","(objsubid,integer)","(provider,text)","(label,text)"}
9.6	pg_conversion	Catalog	{"(xmin,xid)","(oid,oid)","(conname,text)","(connamespace,oid)","(conowner,oid)","(conforencoding,integer)","(contoencoding,integer)","(conproc,regproc)","(condefault,boolean)"}
9.6	pg_cursors	Other Status	{"(name,text)","(statement,text)","(is_holdable,boolean)","(is_binary,boolean)","(is_scrollable,boolean)","(creation_time,\\"timestamp with time zone\\")"}
9.6	pg_database	Catalog	{"(xmin,xid)","(oid,oid)","(datname,text)","(datdba,oid)","(encoding,integer)","(datcollate,text)","(datctype,text)","(datistemplate,boolean)","(datallowconn,boolean)","(datconnlimit,integer)","(datlastsysoid,oid)","(datfrozenxid,xid)","(datminmxid,xid)","(dattablespace,oid)","(datacl,aclitem[])"}
9.6	pg_db_role_setting	Catalog	{"(xmin,xid)","(setdatabase,oid)","(setrole,oid)","(setconfig,text[])"}
9.6	pg_default_acl	Catalog	{"(xmin,xid)","(oid,oid)","(defaclrole,oid)","(defaclnamespace,oid)","(defaclobjtype,\\"\\"\\"char\\"\\"\\")","(defaclacl,aclitem[])"}
9.6	pg_depend	Catalog	{"(xmin,xid)","(classid,oid)","(objid,oid)","(objsubid,integer)","(refclassid,oid)","(refobjid,oid)","(refobjsubid,integer)","(deptype,\\"\\"\\"char\\"\\"\\")"}
9.6	pg_description	Catalog	{"(xmin,xid)","(objoid,oid)","(classoid,oid)","(objsubid,integer)","(description,text)"}
9.6	pg_enum	Catalog	{"(xmin,xid)","(oid,oid)","(enumtypid,oid)","(enumsortorder,real)","(enumlabel,text)"}
9.6	pg_event_trigger	Catalog	{"(xmin,xid)","(oid,oid)","(evtname,text)","(evtevent,text)","(evtowner,oid)","(evtfoid,oid)","(evtenabled,\\"\\"\\"char\\"\\"\\")","(evttags,text[])"}
9.6	pg_extension	Catalog	{"(xmin,xid)","(oid,oid)","(extname,text)","(extowner,oid)","(extnamespace,oid)","(extrelocatable,boolean)","(extversion,text)","(extconfig,oid[])","(extcondition,text[])"}
9.6	pg_file_settings	Other Status	{"(sourcefile,text)","(sourceline,integer)","(seqno,integer)","(name,text)","(setting,text)","(applied,boolean)","(error,text)"}
9.6	pg_foreign_data_wrapper	Catalog	{"(xmin,xid)","(oid,oid)","(fdwname,text)","(fdwowner,oid)","(fdwhandler,oid)","(fdwvalidator,oid)","(fdwacl,aclitem[])","(fdwoptions,text[])"}
9.6	pg_foreign_server	Catalog	{"(xmin,xid)","(oid,oid)","(srvname,text)","(srvowner,oid)","(srvfdw,oid)","(srvtype,text)","(srvversion,text)","(srvacl,aclitem[])","(srvoptions,text[])"}
9.6	pg_foreign_table	Catalog	{"(xmin,xid)","(ftrelid,oid)","(ftserver,oid)","(ftoptions,text[])"}
9.6	pg_index	Catalog	{"(xmin,xid)","(indexrelid,oid)","(indrelid,oid)","(indnatts,smallint)","(indisunique,boolean)","(indisprimary,boolean)","(indisexclusion,boolean)","(indimmediate,boolean)","(indisclustered,boolean)","(indisvalid,boolean)","(indcheckxmin,boolean)","(indisready,boolean)","(indislive,boolean)","(indisreplident,boolean)","(indkey,int2vector)","(indcollation,oidvector)","(indclass,oidvector)","(indoption,int2vector)","(indexprs,pg_node_tree)","(indpred,pg_node_tree)"}
9.6	pg_inherits	Catalog	{"(xmin,xid)","(inhrelid,oid)","(inhparent,oid)","(inhseqno,integer)"}
9.6	pg_language	Catalog	{"(xmin,xid)","(oid,oid)","(lanname,text)","(lanowner,oid)","(lanispl,boolean)","(lanpltrusted,boolean)","(lanplcallfoid,oid)","(laninline,oid)","(lanvalidator,oid)","(lanacl,aclitem[])"}
9.6	pg_largeobject	Catalog	{"(xmin,xid)","(loid,oid)","(pageno,integer)","(data,bytea)"}
9.6	pg_largeobject_metadata	Catalog	{"(xmin,xid)","(oid,oid)","(lomowner,oid)","(lomacl,aclitem[])"}
9.6	pg_roles	Other Status	{"(rolname,text)","(rolsuper,boolean)","(rolinherit,boolean)","(rolcreaterole,boolean)","(rolcreatedb,boolean)","(rolcanlogin,boolean)","(rolreplication,boolean)","(rolconnlimit,integer)","(rolpassword,text)","(rolvaliduntil,\\"timestamp with time zone\\")","(rolbypassrls,boolean)","(rolconfig,text[])","(oid,oid)"}
9.6	pg_locks	Other Status	{"(locktype,text)","(database,oid)","(relation,oid)","(page,integer)","(tuple,smallint)","(virtualxid,text)","(transactionid,xid)","(classid,oid)","(objid,oid)","(objsubid,smallint)","(virtualtransaction,text)","(pid,integer)","(mode,text)","(granted,boolean)","(fastpath,boolean)"}
9.6	pg_matviews	Other Status	{"(schemaname,text)","(matviewname,text)","(matviewowner,text)","(tablespace,text)","(hasindexes,boolean)","(ispopulated,boolean)","(definition,text)"}
9.6	pg_namespace	Catalog	{"(xmin,xid)","(oid,oid)","(nspname,text)","(nspowner,oid)","(nspacl,aclitem[])"}
9.6	pg_opclass	Catalog	{"(xmin,xid)","(oid,oid)","(opcmethod,oid)","(opcname,text)","(opcnamespace,oid)","(opcowner,oid)","(opcfamily,oid)","(opcintype,oid)","(opcdefault,boolean)","(opckeytype,oid)"}
9.6	pg_operator	Catalog	{"(xmin,xid)","(oid,oid)","(oprname,text)","(oprnamespace,oid)","(oprowner,oid)","(oprkind,\\"\\"\\"char\\"\\"\\")","(oprcanmerge,boolean)","(oprcanhash,boolean)","(oprleft,oid)","(oprright,oid)","(oprresult,oid)","(oprcom,oid)","(oprnegate,oid)","(oprcode,regproc)","(oprrest,regproc)","(oprjoin,regproc)"}
9.6	pg_opfamily	Catalog	{"(xmin,xid)","(oid,oid)","(opfmethod,oid)","(opfname,text)","(opfnamespace,oid)","(opfowner,oid)"}
9.6	pg_pltemplate	Catalog	{"(xmin,xid)","(tmplname,text)","(tmpltrusted,boolean)","(tmpldbacreate,boolean)","(tmplhandler,text)","(tmplinline,text)","(tmplvalidator,text)","(tmpllibrary,text)","(tmplacl,aclitem[])"}
9.6	pg_policies	Other Status	{"(schemaname,text)","(tablename,text)","(policyname,text)","(roles,name[])","(cmd,text)","(qual,text)","(with_check,text)"}
9.6	pg_policy	Catalog	{"(xmin,xid)","(oid,oid)","(polname,text)","(polrelid,oid)","(polcmd,\\"\\"\\"char\\"\\"\\")","(polroles,oid[])","(polqual,pg_node_tree)","(polwithcheck,pg_node_tree)"}
9.6	pg_prepared_statements	Other Status	{"(name,text)","(statement,text)","(prepare_time,\\"timestamp with time zone\\")","(parameter_types,regtype[])","(from_sql,boolean)"}
9.6	pg_prepared_xacts	Other Status	{"(transaction,xid)","(gid,text)","(prepared,\\"timestamp with time zone\\")","(owner,text)","(database,text)"}
9.6	pg_proc	Catalog	{"(xmin,xid)","(oid,oid)","(proname,text)","(pronamespace,oid)","(proowner,oid)","(prolang,oid)","(procost,real)","(prorows,real)","(provariadic,oid)","(protransform,regproc)","(proisagg,boolean)","(proiswindow,boolean)","(prosecdef,boolean)","(proleakproof,boolean)","(proisstrict,boolean)","(proretset,boolean)","(provolatile,\\"\\"\\"char\\"\\"\\")","(proparallel,\\"\\"\\"char\\"\\"\\")","(pronargs,smallint)","(pronargdefaults,smallint)","(prorettype,oid)","(proargtypes,oidvector)","(proallargtypes,oid[])","(proargmodes,\\"\\"\\"char\\"\\"[]\\")","(proargnames,text[])","(proargdefaults,pg_node_tree)","(protrftypes,oid[])","(prosrc,text)","(probin,text)","(proconfig,text[])","(proacl,aclitem[])"}
9.6	pg_range	Catalog	{"(xmin,xid)","(rngtypid,oid)","(rngsubtype,oid)","(rngcollation,oid)","(rngsubopc,oid)","(rngcanonical,regproc)","(rngsubdiff,regproc)"}
9.6	pg_replication_origin	Catalog	{"(xmin,xid)","(roident,oid)","(roname,text)"}
9.6	pg_replication_origin_status	Stats File	{"(local_id,oid)","(external_id,text)","(remote_lsn,pg_lsn)","(local_lsn,pg_lsn)"}
9.6	pg_replication_slots	Stats File	{"(slot_name,text)","(plugin,text)","(slot_type,text)","(datoid,oid)","(database,text)","(active,boolean)","(active_pid,integer)","(xmin,xid)","(catalog_xmin,xid)","(restart_lsn,pg_lsn)","(confirmed_flush_lsn,pg_lsn)"}
9.6	pg_rewrite	Catalog	{"(xmin,xid)","(oid,oid)","(rulename,text)","(ev_class,oid)","(ev_type,\\"\\"\\"char\\"\\"\\")","(ev_enabled,\\"\\"\\"char\\"\\"\\")","(is_instead,boolean)","(ev_qual,pg_node_tree)","(ev_action,pg_node_tree)"}
9.6	pg_rules	Other Status	{"(schemaname,text)","(tablename,text)","(rulename,text)","(definition,text)"}
9.6	pg_seclabels	Other Status	{"(objoid,oid)","(classoid,oid)","(objsubid,integer)","(objtype,text)","(objnamespace,oid)","(objname,text)","(provider,text)","(label,text)"}
9.6	pg_settings	Other Status	{"(name,text)","(setting,text)","(unit,text)","(category,text)","(short_desc,text)","(extra_desc,text)","(context,text)","(vartype,text)","(source,text)","(min_val,text)","(max_val,text)","(enumvals,text[])","(boot_val,text)","(reset_val,text)","(sourcefile,text)","(sourceline,integer)","(pending_restart,boolean)"}
9.6	pg_shdepend	Catalog	{"(xmin,xid)","(dbid,oid)","(classid,oid)","(objid,oid)","(objsubid,integer)","(refclassid,oid)","(refobjid,oid)","(deptype,\\"\\"\\"char\\"\\"\\")"}
9.6	pg_shdescription	Catalog	{"(xmin,xid)","(objoid,oid)","(classoid,oid)","(description,text)"}
9.6	pg_shseclabel	Catalog	{"(xmin,xid)","(objoid,oid)","(classoid,oid)","(provider,text)","(label,text)"}
9.6	pg_stat_activity	Stats File	{"(datid,oid)","(datname,text)","(pid,integer)","(usesysid,oid)","(usename,text)","(application_name,text)","(client_addr,inet)","(client_hostname,text)","(client_port,integer)","(backend_start,\\"timestamp with time zone\\")","(xact_start,\\"timestamp with time zone\\")","(query_start,\\"timestamp with time zone\\")","(state_change,\\"timestamp with time zone\\")","(wait_event_type,text)","(wait_event,text)","(state,text)","(backend_xid,xid)","(backend_xmin,xid)","(query,text)"}
9.6	pg_stat_all_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_scan,bigint)","(idx_tup_read,bigint)","(idx_tup_fetch,bigint)"}
9.6	pg_stat_all_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)","(n_live_tup,bigint)","(n_dead_tup,bigint)","(n_mod_since_analyze,bigint)","(last_vacuum,\\"timestamp with time zone\\")","(last_autovacuum,\\"timestamp with time zone\\")","(last_analyze,\\"timestamp with time zone\\")","(last_autoanalyze,\\"timestamp with time zone\\")","(vacuum_count,bigint)","(autovacuum_count,bigint)","(analyze_count,bigint)","(autoanalyze_count,bigint)"}
9.6	pg_stat_archiver	Stats File	{"(archived_count,bigint)","(last_archived_wal,text)","(last_archived_time,\\"timestamp with time zone\\")","(failed_count,bigint)","(last_failed_wal,text)","(last_failed_time,\\"timestamp with time zone\\")","(stats_reset,\\"timestamp with time zone\\")"}
9.6	pg_stat_bgwriter	Stats File	{"(checkpoints_timed,bigint)","(checkpoints_req,bigint)","(checkpoint_write_time,\\"double precision\\")","(checkpoint_sync_time,\\"double precision\\")","(buffers_checkpoint,bigint)","(buffers_clean,bigint)","(maxwritten_clean,bigint)","(buffers_backend,bigint)","(buffers_backend_fsync,bigint)","(buffers_alloc,bigint)","(stats_reset,\\"timestamp with time zone\\")"}
9.6	pg_stat_database	Stats File	{"(datid,oid)","(datname,text)","(numbackends,integer)","(xact_commit,bigint)","(xact_rollback,bigint)","(blks_read,bigint)","(blks_hit,bigint)","(tup_returned,bigint)","(tup_fetched,bigint)","(tup_inserted,bigint)","(tup_updated,bigint)","(tup_deleted,bigint)","(conflicts,bigint)","(temp_files,bigint)","(temp_bytes,bigint)","(deadlocks,bigint)","(blk_read_time,\\"double precision\\")","(blk_write_time,\\"double precision\\")","(stats_reset,\\"timestamp with time zone\\")"}
9.6	pg_statio_user_sequences	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(blks_read,bigint)","(blks_hit,bigint)"}
9.6	pg_stat_database_conflicts	Stats File	{"(datid,oid)","(datname,text)","(confl_tablespace,bigint)","(confl_lock,bigint)","(confl_snapshot,bigint)","(confl_bufferpin,bigint)","(confl_deadlock,bigint)"}
9.6	pg_stat_progress_vacuum	Stats File	{"(pid,integer)","(datid,oid)","(datname,text)","(relid,oid)","(phase,text)","(heap_blks_total,bigint)","(heap_blks_scanned,bigint)","(heap_blks_vacuumed,bigint)","(index_vacuum_count,bigint)","(max_dead_tuples,bigint)","(num_dead_tuples,bigint)"}
9.6	pg_stat_replication	Stats File	{"(pid,integer)","(usesysid,oid)","(usename,text)","(application_name,text)","(client_addr,inet)","(client_hostname,text)","(client_port,integer)","(backend_start,\\"timestamp with time zone\\")","(backend_xmin,xid)","(state,text)","(sent_location,pg_lsn)","(write_location,pg_lsn)","(flush_location,pg_lsn)","(replay_location,pg_lsn)","(sync_priority,integer)","(sync_state,text)"}
9.6	pg_stat_ssl	Stats File	{"(pid,integer)","(ssl,boolean)","(version,text)","(cipher,text)","(bits,integer)","(compression,boolean)","(clientdn,text)"}
9.6	pg_stat_statements	Stats File	{"(userid,oid)","(dbid,oid)","(queryid,bigint)","(query,text)","(calls,bigint)","(total_time,\\"double precision\\")","(min_time,\\"double precision\\")","(max_time,\\"double precision\\")","(mean_time,\\"double precision\\")","(stddev_time,\\"double precision\\")","(rows,bigint)","(shared_blks_hit,bigint)","(shared_blks_read,bigint)","(shared_blks_dirtied,bigint)","(shared_blks_written,bigint)","(local_blks_hit,bigint)","(local_blks_read,bigint)","(local_blks_dirtied,bigint)","(local_blks_written,bigint)","(temp_blks_read,bigint)","(temp_blks_written,bigint)","(blk_read_time,\\"double precision\\")","(blk_write_time,\\"double precision\\")"}
9.6	pg_stat_sys_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_scan,bigint)","(idx_tup_read,bigint)","(idx_tup_fetch,bigint)"}
9.6	pg_stat_sys_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)","(n_live_tup,bigint)","(n_dead_tup,bigint)","(n_mod_since_analyze,bigint)","(last_vacuum,\\"timestamp with time zone\\")","(last_autovacuum,\\"timestamp with time zone\\")","(last_analyze,\\"timestamp with time zone\\")","(last_autoanalyze,\\"timestamp with time zone\\")","(vacuum_count,bigint)","(autovacuum_count,bigint)","(analyze_count,bigint)","(autoanalyze_count,bigint)"}
9.6	pg_stat_user_functions	Stats File	{"(funcid,oid)","(schemaname,text)","(funcname,text)","(calls,bigint)","(total_time,\\"double precision\\")","(self_time,\\"double precision\\")"}
9.6	pg_stat_user_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_scan,bigint)","(idx_tup_read,bigint)","(idx_tup_fetch,bigint)"}
9.6	pg_statio_sys_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(heap_blks_read,bigint)","(heap_blks_hit,bigint)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)","(toast_blks_read,bigint)","(toast_blks_hit,bigint)","(tidx_blks_read,bigint)","(tidx_blks_hit,bigint)"}
9.6	pg_stat_user_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)","(n_live_tup,bigint)","(n_dead_tup,bigint)","(n_mod_since_analyze,bigint)","(last_vacuum,\\"timestamp with time zone\\")","(last_autovacuum,\\"timestamp with time zone\\")","(last_analyze,\\"timestamp with time zone\\")","(last_autoanalyze,\\"timestamp with time zone\\")","(vacuum_count,bigint)","(autovacuum_count,bigint)","(analyze_count,bigint)","(autoanalyze_count,bigint)"}
9.6	pg_stat_wal_receiver	Stats File	{"(pid,integer)","(status,text)","(receive_start_lsn,pg_lsn)","(receive_start_tli,integer)","(received_lsn,pg_lsn)","(received_tli,integer)","(last_msg_send_time,\\"timestamp with time zone\\")","(last_msg_receipt_time,\\"timestamp with time zone\\")","(latest_end_lsn,pg_lsn)","(latest_end_time,\\"timestamp with time zone\\")","(slot_name,text)"}
9.6	pg_stat_xact_all_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)"}
9.6	pg_stat_xact_sys_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)"}
9.6	pg_stat_xact_user_functions	Stats File	{"(funcid,oid)","(schemaname,text)","(funcname,text)","(calls,bigint)","(total_time,\\"double precision\\")","(self_time,\\"double precision\\")"}
9.6	pg_stat_xact_user_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)"}
9.6	pg_statio_all_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)"}
9.6	pg_statio_all_sequences	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(blks_read,bigint)","(blks_hit,bigint)"}
9.6	pg_statio_all_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(heap_blks_read,bigint)","(heap_blks_hit,bigint)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)","(toast_blks_read,bigint)","(toast_blks_hit,bigint)","(tidx_blks_read,bigint)","(tidx_blks_hit,bigint)"}
9.6	pg_statio_sys_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)"}
9.6	pg_statio_sys_sequences	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(blks_read,bigint)","(blks_hit,bigint)"}
9.6	pg_statio_user_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)"}
9.6	pg_statio_user_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(heap_blks_read,bigint)","(heap_blks_hit,bigint)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)","(toast_blks_read,bigint)","(toast_blks_hit,bigint)","(tidx_blks_read,bigint)","(tidx_blks_hit,bigint)"}
9.6	pg_stats	Stats File	{"(schemaname,text)","(tablename,text)","(attname,text)","(inherited,boolean)","(null_frac,real)","(avg_width,integer)","(n_distinct,real)","(most_common_vals,text)","(most_common_freqs,real[])","(histogram_bounds,text)","(correlation,real)","(most_common_elems,text)","(most_common_elem_freqs,real[])","(elem_count_histogram,real[])"}
9.6	pg_tablespace	Catalog	{"(xmin,xid)","(oid,oid)","(spcname,text)","(spcowner,oid)","(spcacl,aclitem[])","(spcoptions,text[])"}
9.6	pg_timezone_abbrevs	Other Status	{"(abbrev,text)","(utc_offset,interval)","(is_dst,boolean)"}
9.6	pg_timezone_names	Other Status	{"(name,text)","(abbrev,text)","(utc_offset,interval)","(is_dst,boolean)"}
9.6	pg_transform	Catalog	{"(xmin,xid)","(oid,oid)","(trftype,oid)","(trflang,oid)","(trffromsql,regproc)","(trftosql,regproc)"}
9.6	pg_trigger	Catalog	{"(xmin,xid)","(oid,oid)","(tgrelid,oid)","(tgname,text)","(tgfoid,oid)","(tgtype,smallint)","(tgenabled,\\"\\"\\"char\\"\\"\\")","(tgisinternal,boolean)","(tgconstrrelid,oid)","(tgconstrindid,oid)","(tgconstraint,oid)","(tgdeferrable,boolean)","(tginitdeferred,boolean)","(tgnargs,smallint)","(tgattr,int2vector)","(tgargs,bytea)","(tgqual,pg_node_tree)"}
9.6	pg_ts_config	Catalog	{"(xmin,xid)","(oid,oid)","(cfgname,text)","(cfgnamespace,oid)","(cfgowner,oid)","(cfgparser,oid)"}
9.6	pg_ts_config_map	Catalog	{"(xmin,xid)","(mapcfg,oid)","(maptokentype,integer)","(mapseqno,integer)","(mapdict,oid)"}
9.6	pg_ts_dict	Catalog	{"(xmin,xid)","(oid,oid)","(dictname,text)","(dictnamespace,oid)","(dictowner,oid)","(dicttemplate,oid)","(dictinitoption,text)"}
9.6	pg_ts_parser	Catalog	{"(xmin,xid)","(oid,oid)","(prsname,text)","(prsnamespace,oid)","(prsstart,regproc)","(prstoken,regproc)","(prsend,regproc)","(prsheadline,regproc)","(prslextype,regproc)"}
9.6	pg_ts_template	Catalog	{"(xmin,xid)","(oid,oid)","(tmplname,text)","(tmplnamespace,oid)","(tmplinit,regproc)","(tmpllexize,regproc)"}
9.6	pg_type	Catalog	{"(xmin,xid)","(oid,oid)","(typname,text)","(typnamespace,oid)","(typowner,oid)","(typlen,smallint)","(typbyval,boolean)","(typtype,\\"\\"\\"char\\"\\"\\")","(typcategory,\\"\\"\\"char\\"\\"\\")","(typispreferred,boolean)","(typisdefined,boolean)","(typdelim,\\"\\"\\"char\\"\\"\\")","(typrelid,oid)","(typelem,oid)","(typarray,oid)","(typinput,regproc)","(typoutput,regproc)","(typreceive,regproc)","(typsend,regproc)","(typmodin,regproc)","(typmodout,regproc)","(typanalyze,regproc)","(typalign,\\"\\"\\"char\\"\\"\\")","(typstorage,\\"\\"\\"char\\"\\"\\")","(typnotnull,boolean)","(typbasetype,oid)","(typtypmod,integer)","(typndims,integer)","(typcollation,oid)","(typdefaultbin,pg_node_tree)","(typdefault,text)","(typacl,aclitem[])"}
9.6	pg_user_mapping	Catalog	{"(xmin,xid)","(oid,oid)","(umuser,oid)","(umserver,oid)","(umoptions,text[])"}
9.1	pg_aggregate	Catalog	{"(xmin,xid)","(aggfnoid,regproc)","(aggtransfn,regproc)","(aggfinalfn,regproc)","(aggsortop,oid)","(aggtranstype,oid)","(agginitval,text)"}
9.1	pg_cursors	Other Status	{"(name,text)","(statement,text)","(is_holdable,boolean)","(is_binary,boolean)","(is_scrollable,boolean)","(creation_time,\\"timestamp with time zone\\")"}
9.1	pg_opfamily	Catalog	{"(xmin,xid)","(oid,oid)","(opfmethod,oid)","(opfname,text)","(opfnamespace,oid)","(opfowner,oid)"}
9.2	pg_enum	Catalog	{"(xmin,xid)","(oid,oid)","(enumtypid,oid)","(enumsortorder,real)","(enumlabel,text)"}
9.1	pg_am	Catalog	{"(xmin,xid)","(oid,oid)","(amname,text)","(amstrategies,smallint)","(amsupport,smallint)","(amcanorder,boolean)","(amcanorderbyop,boolean)","(amcanbackward,boolean)","(amcanunique,boolean)","(amcanmulticol,boolean)","(amoptionalkey,boolean)","(amsearchnulls,boolean)","(amstorage,boolean)","(amclusterable,boolean)","(ampredlocks,boolean)","(amkeytype,oid)","(aminsert,regproc)","(ambeginscan,regproc)","(amgettuple,regproc)","(amgetbitmap,regproc)","(amrescan,regproc)","(amendscan,regproc)","(ammarkpos,regproc)","(amrestrpos,regproc)","(ambuild,regproc)","(ambuildempty,regproc)","(ambulkdelete,regproc)","(amvacuumcleanup,regproc)","(amcostestimate,regproc)","(amoptions,regproc)"}
9.1	pg_amop	Catalog	{"(xmin,xid)","(oid,oid)","(amopfamily,oid)","(amoplefttype,oid)","(amoprighttype,oid)","(amopstrategy,smallint)","(amoppurpose,\\"\\"\\"char\\"\\"\\")","(amopopr,oid)","(amopmethod,oid)","(amopsortfamily,oid)"}
9.1	pg_amproc	Catalog	{"(xmin,xid)","(oid,oid)","(amprocfamily,oid)","(amproclefttype,oid)","(amprocrighttype,oid)","(amprocnum,smallint)","(amproc,regproc)"}
9.1	pg_attrdef	Catalog	{"(xmin,xid)","(oid,oid)","(adrelid,oid)","(adnum,smallint)","(adbin,pg_node_tree)","(adsrc,text)"}
9.1	pg_attribute	Catalog	{"(xmin,xid)","(attrelid,oid)","(attname,text)","(atttypid,oid)","(attstattarget,integer)","(attlen,smallint)","(attnum,smallint)","(attndims,integer)","(attcacheoff,integer)","(atttypmod,integer)","(attbyval,boolean)","(attstorage,\\"\\"\\"char\\"\\"\\")","(attalign,\\"\\"\\"char\\"\\"\\")","(attnotnull,boolean)","(atthasdef,boolean)","(attisdropped,boolean)","(attislocal,boolean)","(attinhcount,integer)","(attcollation,oid)","(attacl,aclitem[])","(attoptions,text[])"}
9.1	pg_auth_members	Catalog	{"(xmin,xid)","(roleid,oid)","(member,oid)","(grantor,oid)","(admin_option,boolean)"}
9.1	pg_available_extension_versions	Other Status	{"(name,text)","(version,text)","(installed,boolean)","(superuser,boolean)","(relocatable,boolean)","(schema,text)","(requires,name[])","(comment,text)"}
9.1	pg_available_extensions	Other Status	{"(name,text)","(default_version,text)","(installed_version,text)","(comment,text)"}
9.1	pg_cast	Catalog	{"(xmin,xid)","(oid,oid)","(castsource,oid)","(casttarget,oid)","(castfunc,oid)","(castcontext,\\"\\"\\"char\\"\\"\\")","(castmethod,\\"\\"\\"char\\"\\"\\")"}
9.1	pg_class	Catalog	{"(xmin,xid)","(oid,oid)","(relname,text)","(relnamespace,oid)","(reltype,oid)","(reloftype,oid)","(relowner,oid)","(relam,oid)","(relfilenode,oid)","(reltablespace,oid)","(relpages,integer)","(reltuples,real)","(reltoastrelid,oid)","(reltoastidxid,oid)","(relhasindex,boolean)","(relisshared,boolean)","(relpersistence,\\"\\"\\"char\\"\\"\\")","(relkind,\\"\\"\\"char\\"\\"\\")","(relnatts,smallint)","(relchecks,smallint)","(relhasoids,boolean)","(relhaspkey,boolean)","(relhasrules,boolean)","(relhastriggers,boolean)","(relhassubclass,boolean)","(relfrozenxid,xid)","(relacl,aclitem[])","(reloptions,text[])"}
9.1	pg_collation	Catalog	{"(xmin,xid)","(oid,oid)","(collname,text)","(collnamespace,oid)","(collowner,oid)","(collencoding,integer)","(collcollate,text)","(collctype,text)"}
9.1	pg_constraint	Catalog	{"(xmin,xid)","(oid,oid)","(conname,text)","(connamespace,oid)","(contype,\\"\\"\\"char\\"\\"\\")","(condeferrable,boolean)","(condeferred,boolean)","(convalidated,boolean)","(conrelid,oid)","(contypid,oid)","(conindid,oid)","(confrelid,oid)","(confupdtype,\\"\\"\\"char\\"\\"\\")","(confdeltype,\\"\\"\\"char\\"\\"\\")","(confmatchtype,\\"\\"\\"char\\"\\"\\")","(conislocal,boolean)","(coninhcount,integer)","(conkey,smallint[])","(confkey,smallint[])","(conpfeqop,oid[])","(conppeqop,oid[])","(conffeqop,oid[])","(conexclop,oid[])","(conbin,pg_node_tree)","(consrc,text)"}
9.1	pg_conversion	Catalog	{"(xmin,xid)","(oid,oid)","(conname,text)","(connamespace,oid)","(conowner,oid)","(conforencoding,integer)","(contoencoding,integer)","(conproc,regproc)","(condefault,boolean)"}
9.1	pg_database	Catalog	{"(xmin,xid)","(oid,oid)","(datname,text)","(datdba,oid)","(encoding,integer)","(datcollate,text)","(datctype,text)","(datistemplate,boolean)","(datallowconn,boolean)","(datconnlimit,integer)","(datlastsysoid,oid)","(datfrozenxid,xid)","(dattablespace,oid)","(datacl,aclitem[])"}
9.1	pg_db_role_setting	Catalog	{"(xmin,xid)","(setdatabase,oid)","(setrole,oid)","(setconfig,text[])"}
9.1	pg_default_acl	Catalog	{"(xmin,xid)","(oid,oid)","(defaclrole,oid)","(defaclnamespace,oid)","(defaclobjtype,\\"\\"\\"char\\"\\"\\")","(defaclacl,aclitem[])"}
9.1	pg_depend	Catalog	{"(xmin,xid)","(classid,oid)","(objid,oid)","(objsubid,integer)","(refclassid,oid)","(refobjid,oid)","(refobjsubid,integer)","(deptype,\\"\\"\\"char\\"\\"\\")"}
9.1	pg_description	Catalog	{"(xmin,xid)","(objoid,oid)","(classoid,oid)","(objsubid,integer)","(description,text)"}
9.1	pg_enum	Catalog	{"(xmin,xid)","(oid,oid)","(enumtypid,oid)","(enumsortorder,real)","(enumlabel,text)"}
9.1	pg_extension	Catalog	{"(xmin,xid)","(oid,oid)","(extname,text)","(extowner,oid)","(extnamespace,oid)","(extrelocatable,boolean)","(extversion,text)","(extconfig,oid[])","(extcondition,text[])"}
9.1	pg_foreign_data_wrapper	Catalog	{"(xmin,xid)","(oid,oid)","(fdwname,text)","(fdwowner,oid)","(fdwhandler,oid)","(fdwvalidator,oid)","(fdwacl,aclitem[])","(fdwoptions,text[])"}
9.1	pg_foreign_server	Catalog	{"(xmin,xid)","(oid,oid)","(srvname,text)","(srvowner,oid)","(srvfdw,oid)","(srvtype,text)","(srvversion,text)","(srvacl,aclitem[])","(srvoptions,text[])"}
9.1	pg_foreign_table	Catalog	{"(xmin,xid)","(ftrelid,oid)","(ftserver,oid)","(ftoptions,text[])"}
9.1	pg_index	Catalog	{"(xmin,xid)","(indexrelid,oid)","(indrelid,oid)","(indnatts,smallint)","(indisunique,boolean)","(indisprimary,boolean)","(indisexclusion,boolean)","(indimmediate,boolean)","(indisclustered,boolean)","(indisvalid,boolean)","(indcheckxmin,boolean)","(indisready,boolean)","(indkey,int2vector)","(indcollation,oidvector)","(indclass,oidvector)","(indoption,int2vector)","(indexprs,pg_node_tree)","(indpred,pg_node_tree)"}
9.1	pg_inherits	Catalog	{"(xmin,xid)","(inhrelid,oid)","(inhparent,oid)","(inhseqno,integer)"}
9.1	pg_language	Catalog	{"(xmin,xid)","(oid,oid)","(lanname,text)","(lanowner,oid)","(lanispl,boolean)","(lanpltrusted,boolean)","(lanplcallfoid,oid)","(laninline,oid)","(lanvalidator,oid)","(lanacl,aclitem[])"}
9.1	pg_largeobject	Catalog	{"(xmin,xid)","(loid,oid)","(pageno,integer)","(data,bytea)"}
9.1	pg_largeobject_metadata	Catalog	{"(xmin,xid)","(oid,oid)","(lomowner,oid)","(lomacl,aclitem[])"}
9.1	pg_locks	Other Status	{"(locktype,text)","(database,oid)","(relation,oid)","(page,integer)","(tuple,smallint)","(virtualxid,text)","(transactionid,xid)","(classid,oid)","(objid,oid)","(objsubid,smallint)","(virtualtransaction,text)","(pid,integer)","(mode,text)","(granted,boolean)"}
9.1	pg_namespace	Catalog	{"(xmin,xid)","(oid,oid)","(nspname,text)","(nspowner,oid)","(nspacl,aclitem[])"}
9.1	pg_opclass	Catalog	{"(xmin,xid)","(oid,oid)","(opcmethod,oid)","(opcname,text)","(opcnamespace,oid)","(opcowner,oid)","(opcfamily,oid)","(opcintype,oid)","(opcdefault,boolean)","(opckeytype,oid)"}
9.1	pg_operator	Catalog	{"(xmin,xid)","(oid,oid)","(oprname,text)","(oprnamespace,oid)","(oprowner,oid)","(oprkind,\\"\\"\\"char\\"\\"\\")","(oprcanmerge,boolean)","(oprcanhash,boolean)","(oprleft,oid)","(oprright,oid)","(oprresult,oid)","(oprcom,oid)","(oprnegate,oid)","(oprcode,regproc)","(oprrest,regproc)","(oprjoin,regproc)"}
9.1	pg_pltemplate	Catalog	{"(xmin,xid)","(tmplname,text)","(tmpltrusted,boolean)","(tmpldbacreate,boolean)","(tmplhandler,text)","(tmplinline,text)","(tmplvalidator,text)","(tmpllibrary,text)","(tmplacl,aclitem[])"}
9.1	pg_prepared_statements	Other Status	{"(name,text)","(statement,text)","(prepare_time,\\"timestamp with time zone\\")","(parameter_types,regtype[])","(from_sql,boolean)"}
9.1	pg_prepared_xacts	Other Status	{"(transaction,xid)","(gid,text)","(prepared,\\"timestamp with time zone\\")","(owner,text)","(database,text)"}
9.1	pg_proc	Catalog	{"(xmin,xid)","(oid,oid)","(proname,text)","(pronamespace,oid)","(proowner,oid)","(prolang,oid)","(procost,real)","(prorows,real)","(provariadic,oid)","(proisagg,boolean)","(proiswindow,boolean)","(prosecdef,boolean)","(proisstrict,boolean)","(proretset,boolean)","(provolatile,\\"\\"\\"char\\"\\"\\")","(pronargs,smallint)","(pronargdefaults,smallint)","(prorettype,oid)","(proargtypes,oidvector)","(proallargtypes,oid[])","(proargmodes,\\"\\"\\"char\\"\\"[]\\")","(proargnames,text[])","(proargdefaults,pg_node_tree)","(prosrc,text)","(probin,text)","(proconfig,text[])","(proacl,aclitem[])"}
9.1	pg_rewrite	Catalog	{"(xmin,xid)","(oid,oid)","(rulename,text)","(ev_class,oid)","(ev_attr,smallint)","(ev_type,\\"\\"\\"char\\"\\"\\")","(ev_enabled,\\"\\"\\"char\\"\\"\\")","(is_instead,boolean)","(ev_qual,pg_node_tree)","(ev_action,pg_node_tree)"}
9.1	pg_roles	Other Status	{"(rolname,text)","(rolsuper,boolean)","(rolinherit,boolean)","(rolcreaterole,boolean)","(rolcreatedb,boolean)","(rolcatupdate,boolean)","(rolcanlogin,boolean)","(rolreplication,boolean)","(rolconnlimit,integer)","(rolpassword,text)","(rolvaliduntil,\\"timestamp with time zone\\")","(rolconfig,text[])","(oid,oid)"}
9.1	pg_rules	Other Status	{"(schemaname,text)","(tablename,text)","(rulename,text)","(definition,text)"}
9.1	pg_seclabel	Catalog	{"(xmin,xid)","(objoid,oid)","(classoid,oid)","(objsubid,integer)","(provider,text)","(label,text)"}
9.1	pg_seclabels	Other Status	{"(objoid,oid)","(classoid,oid)","(objsubid,integer)","(objtype,text)","(objnamespace,oid)","(objname,text)","(provider,text)","(label,text)"}
9.1	pg_settings	Other Status	{"(name,text)","(setting,text)","(unit,text)","(category,text)","(short_desc,text)","(extra_desc,text)","(context,text)","(vartype,text)","(source,text)","(min_val,text)","(max_val,text)","(enumvals,text[])","(boot_val,text)","(reset_val,text)","(sourcefile,text)","(sourceline,integer)"}
9.1	pg_shdepend	Catalog	{"(xmin,xid)","(dbid,oid)","(classid,oid)","(objid,oid)","(objsubid,integer)","(refclassid,oid)","(refobjid,oid)","(deptype,\\"\\"\\"char\\"\\"\\")"}
9.1	pg_shdescription	Catalog	{"(xmin,xid)","(objoid,oid)","(classoid,oid)","(description,text)"}
9.1	pg_stat_activity	Stats File	{"(datid,oid)","(datname,text)","(procpid,integer)","(usesysid,oid)","(usename,text)","(application_name,text)","(client_addr,inet)","(client_hostname,text)","(client_port,integer)","(backend_start,\\"timestamp with time zone\\")","(xact_start,\\"timestamp with time zone\\")","(query_start,\\"timestamp with time zone\\")","(waiting,boolean)","(current_query,text)"}
9.1	pg_stat_all_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_scan,bigint)","(idx_tup_read,bigint)","(idx_tup_fetch,bigint)"}
9.1	pg_statio_user_sequences	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(blks_read,bigint)","(blks_hit,bigint)"}
9.1	pg_statio_user_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(heap_blks_read,bigint)","(heap_blks_hit,bigint)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)","(toast_blks_read,bigint)","(toast_blks_hit,bigint)","(tidx_blks_read,bigint)","(tidx_blks_hit,bigint)"}
9.1	pg_stat_all_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)","(n_live_tup,bigint)","(n_dead_tup,bigint)","(last_vacuum,\\"timestamp with time zone\\")","(last_autovacuum,\\"timestamp with time zone\\")","(last_analyze,\\"timestamp with time zone\\")","(last_autoanalyze,\\"timestamp with time zone\\")","(vacuum_count,bigint)","(autovacuum_count,bigint)","(analyze_count,bigint)","(autoanalyze_count,bigint)"}
9.1	pg_stat_bgwriter	Stats File	{"(checkpoints_timed,bigint)","(checkpoints_req,bigint)","(buffers_checkpoint,bigint)","(buffers_clean,bigint)","(maxwritten_clean,bigint)","(buffers_backend,bigint)","(buffers_backend_fsync,bigint)","(buffers_alloc,bigint)","(stats_reset,\\"timestamp with time zone\\")"}
9.1	pg_stat_database	Stats File	{"(datid,oid)","(datname,text)","(numbackends,integer)","(xact_commit,bigint)","(xact_rollback,bigint)","(blks_read,bigint)","(blks_hit,bigint)","(tup_returned,bigint)","(tup_fetched,bigint)","(tup_inserted,bigint)","(tup_updated,bigint)","(tup_deleted,bigint)","(conflicts,bigint)","(stats_reset,\\"timestamp with time zone\\")"}
9.1	pg_stat_database_conflicts	Stats File	{"(datid,oid)","(datname,text)","(confl_tablespace,bigint)","(confl_lock,bigint)","(confl_snapshot,bigint)","(confl_bufferpin,bigint)","(confl_deadlock,bigint)"}
9.1	pg_stat_replication	Stats File	{"(procpid,integer)","(usesysid,oid)","(usename,text)","(application_name,text)","(client_addr,inet)","(client_hostname,text)","(client_port,integer)","(backend_start,\\"timestamp with time zone\\")","(state,text)","(sent_location,text)","(write_location,text)","(flush_location,text)","(replay_location,text)","(sync_priority,integer)","(sync_state,text)"}
9.1	pg_stat_sys_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_scan,bigint)","(idx_tup_read,bigint)","(idx_tup_fetch,bigint)"}
9.1	pg_stat_sys_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)","(n_live_tup,bigint)","(n_dead_tup,bigint)","(last_vacuum,\\"timestamp with time zone\\")","(last_autovacuum,\\"timestamp with time zone\\")","(last_analyze,\\"timestamp with time zone\\")","(last_autoanalyze,\\"timestamp with time zone\\")","(vacuum_count,bigint)","(autovacuum_count,bigint)","(analyze_count,bigint)","(autoanalyze_count,bigint)"}
9.1	pg_stat_user_functions	Stats File	{"(funcid,oid)","(schemaname,text)","(funcname,text)","(calls,bigint)","(total_time,bigint)","(self_time,bigint)"}
9.1	pg_stat_user_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_scan,bigint)","(idx_tup_read,bigint)","(idx_tup_fetch,bigint)"}
9.1	pg_stats	Stats File	{"(schemaname,text)","(tablename,text)","(attname,text)","(inherited,boolean)","(null_frac,real)","(avg_width,integer)","(n_distinct,real)","(most_common_vals,text)","(most_common_freqs,real[])","(histogram_bounds,text)","(correlation,real)"}
9.4	pg_attrdef	Catalog	{"(xmin,xid)","(oid,oid)","(adrelid,oid)","(adnum,smallint)","(adbin,pg_node_tree)","(adsrc,text)"}
9.1	pg_stat_user_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)","(n_live_tup,bigint)","(n_dead_tup,bigint)","(last_vacuum,\\"timestamp with time zone\\")","(last_autovacuum,\\"timestamp with time zone\\")","(last_analyze,\\"timestamp with time zone\\")","(last_autoanalyze,\\"timestamp with time zone\\")","(vacuum_count,bigint)","(autovacuum_count,bigint)","(analyze_count,bigint)","(autoanalyze_count,bigint)"}
9.1	pg_stat_xact_all_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)"}
9.1	pg_stat_xact_sys_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)"}
9.1	pg_stat_xact_user_functions	Stats File	{"(funcid,oid)","(schemaname,text)","(funcname,text)","(calls,bigint)","(total_time,bigint)","(self_time,bigint)"}
9.1	pg_stat_xact_user_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)"}
9.1	pg_statio_all_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)"}
9.1	pg_statio_all_sequences	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(blks_read,bigint)","(blks_hit,bigint)"}
9.1	pg_statio_all_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(heap_blks_read,bigint)","(heap_blks_hit,bigint)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)","(toast_blks_read,bigint)","(toast_blks_hit,bigint)","(tidx_blks_read,bigint)","(tidx_blks_hit,bigint)"}
9.1	pg_statio_sys_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)"}
9.1	pg_statio_sys_sequences	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(blks_read,bigint)","(blks_hit,bigint)"}
9.1	pg_statio_sys_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(heap_blks_read,bigint)","(heap_blks_hit,bigint)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)","(toast_blks_read,bigint)","(toast_blks_hit,bigint)","(tidx_blks_read,bigint)","(tidx_blks_hit,bigint)"}
9.1	pg_statio_user_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)"}
9.1	pg_tablespace	Catalog	{"(xmin,xid)","(oid,oid)","(spcname,text)","(spcowner,oid)","(spclocation,text)","(spcacl,aclitem[])","(spcoptions,text[])"}
9.1	pg_timezone_abbrevs	Other Status	{"(abbrev,text)","(utc_offset,interval)","(is_dst,boolean)"}
9.1	pg_timezone_names	Other Status	{"(name,text)","(abbrev,text)","(utc_offset,interval)","(is_dst,boolean)"}
9.1	pg_trigger	Catalog	{"(xmin,xid)","(oid,oid)","(tgrelid,oid)","(tgname,text)","(tgfoid,oid)","(tgtype,smallint)","(tgenabled,\\"\\"\\"char\\"\\"\\")","(tgisinternal,boolean)","(tgconstrrelid,oid)","(tgconstrindid,oid)","(tgconstraint,oid)","(tgdeferrable,boolean)","(tginitdeferred,boolean)","(tgnargs,smallint)","(tgattr,int2vector)","(tgargs,bytea)","(tgqual,pg_node_tree)"}
9.1	pg_ts_config	Catalog	{"(xmin,xid)","(oid,oid)","(cfgname,text)","(cfgnamespace,oid)","(cfgowner,oid)","(cfgparser,oid)"}
9.1	pg_ts_config_map	Catalog	{"(xmin,xid)","(mapcfg,oid)","(maptokentype,integer)","(mapseqno,integer)","(mapdict,oid)"}
9.1	pg_ts_dict	Catalog	{"(xmin,xid)","(oid,oid)","(dictname,text)","(dictnamespace,oid)","(dictowner,oid)","(dicttemplate,oid)","(dictinitoption,text)"}
9.1	pg_ts_parser	Catalog	{"(xmin,xid)","(oid,oid)","(prsname,text)","(prsnamespace,oid)","(prsstart,regproc)","(prstoken,regproc)","(prsend,regproc)","(prsheadline,regproc)","(prslextype,regproc)"}
9.1	pg_ts_template	Catalog	{"(xmin,xid)","(oid,oid)","(tmplname,text)","(tmplnamespace,oid)","(tmplinit,regproc)","(tmpllexize,regproc)"}
9.1	pg_type	Catalog	{"(xmin,xid)","(oid,oid)","(typname,text)","(typnamespace,oid)","(typowner,oid)","(typlen,smallint)","(typbyval,boolean)","(typtype,\\"\\"\\"char\\"\\"\\")","(typcategory,\\"\\"\\"char\\"\\"\\")","(typispreferred,boolean)","(typisdefined,boolean)","(typdelim,\\"\\"\\"char\\"\\"\\")","(typrelid,oid)","(typelem,oid)","(typarray,oid)","(typinput,regproc)","(typoutput,regproc)","(typreceive,regproc)","(typsend,regproc)","(typmodin,regproc)","(typmodout,regproc)","(typanalyze,regproc)","(typalign,\\"\\"\\"char\\"\\"\\")","(typstorage,\\"\\"\\"char\\"\\"\\")","(typnotnull,boolean)","(typbasetype,oid)","(typtypmod,integer)","(typndims,integer)","(typcollation,oid)","(typdefaultbin,pg_node_tree)","(typdefault,text)"}
9.1	pg_user_mapping	Catalog	{"(xmin,xid)","(oid,oid)","(umuser,oid)","(umserver,oid)","(umoptions,text[])"}
9.2	pg_aggregate	Catalog	{"(xmin,xid)","(aggfnoid,regproc)","(aggtransfn,regproc)","(aggfinalfn,regproc)","(aggsortop,oid)","(aggtranstype,oid)","(agginitval,text)"}
9.2	pg_am	Catalog	{"(xmin,xid)","(oid,oid)","(amname,text)","(amstrategies,smallint)","(amsupport,smallint)","(amcanorder,boolean)","(amcanorderbyop,boolean)","(amcanbackward,boolean)","(amcanunique,boolean)","(amcanmulticol,boolean)","(amoptionalkey,boolean)","(amsearcharray,boolean)","(amsearchnulls,boolean)","(amstorage,boolean)","(amclusterable,boolean)","(ampredlocks,boolean)","(amkeytype,oid)","(aminsert,regproc)","(ambeginscan,regproc)","(amgettuple,regproc)","(amgetbitmap,regproc)","(amrescan,regproc)","(amendscan,regproc)","(ammarkpos,regproc)","(amrestrpos,regproc)","(ambuild,regproc)","(ambuildempty,regproc)","(ambulkdelete,regproc)","(amvacuumcleanup,regproc)","(amcanreturn,regproc)","(amcostestimate,regproc)","(amoptions,regproc)"}
9.2	pg_amop	Catalog	{"(xmin,xid)","(oid,oid)","(amopfamily,oid)","(amoplefttype,oid)","(amoprighttype,oid)","(amopstrategy,smallint)","(amoppurpose,\\"\\"\\"char\\"\\"\\")","(amopopr,oid)","(amopmethod,oid)","(amopsortfamily,oid)"}
9.2	pg_amproc	Catalog	{"(xmin,xid)","(oid,oid)","(amprocfamily,oid)","(amproclefttype,oid)","(amprocrighttype,oid)","(amprocnum,smallint)","(amproc,regproc)"}
9.2	pg_attrdef	Catalog	{"(xmin,xid)","(oid,oid)","(adrelid,oid)","(adnum,smallint)","(adbin,pg_node_tree)","(adsrc,text)"}
9.2	pg_attribute	Catalog	{"(xmin,xid)","(attrelid,oid)","(attname,text)","(atttypid,oid)","(attstattarget,integer)","(attlen,smallint)","(attnum,smallint)","(attndims,integer)","(attcacheoff,integer)","(atttypmod,integer)","(attbyval,boolean)","(attstorage,\\"\\"\\"char\\"\\"\\")","(attalign,\\"\\"\\"char\\"\\"\\")","(attnotnull,boolean)","(atthasdef,boolean)","(attisdropped,boolean)","(attislocal,boolean)","(attinhcount,integer)","(attcollation,oid)","(attacl,aclitem[])","(attoptions,text[])","(attfdwoptions,text[])"}
9.2	pg_auth_members	Catalog	{"(xmin,xid)","(roleid,oid)","(member,oid)","(grantor,oid)","(admin_option,boolean)"}
9.2	pg_available_extension_versions	Other Status	{"(name,text)","(version,text)","(installed,boolean)","(superuser,boolean)","(relocatable,boolean)","(schema,text)","(requires,name[])","(comment,text)"}
9.2	pg_available_extensions	Other Status	{"(name,text)","(default_version,text)","(installed_version,text)","(comment,text)"}
9.2	pg_cast	Catalog	{"(xmin,xid)","(oid,oid)","(castsource,oid)","(casttarget,oid)","(castfunc,oid)","(castcontext,\\"\\"\\"char\\"\\"\\")","(castmethod,\\"\\"\\"char\\"\\"\\")"}
9.2	pg_class	Catalog	{"(xmin,xid)","(oid,oid)","(relname,text)","(relnamespace,oid)","(reltype,oid)","(reloftype,oid)","(relowner,oid)","(relam,oid)","(relfilenode,oid)","(reltablespace,oid)","(relpages,integer)","(reltuples,real)","(relallvisible,integer)","(reltoastrelid,oid)","(reltoastidxid,oid)","(relhasindex,boolean)","(relisshared,boolean)","(relpersistence,\\"\\"\\"char\\"\\"\\")","(relkind,\\"\\"\\"char\\"\\"\\")","(relnatts,smallint)","(relchecks,smallint)","(relhasoids,boolean)","(relhaspkey,boolean)","(relhasrules,boolean)","(relhastriggers,boolean)","(relhassubclass,boolean)","(relfrozenxid,xid)","(relacl,aclitem[])","(reloptions,text[])"}
9.2	pg_collation	Catalog	{"(xmin,xid)","(oid,oid)","(collname,text)","(collnamespace,oid)","(collowner,oid)","(collencoding,integer)","(collcollate,text)","(collctype,text)"}
9.2	pg_constraint	Catalog	{"(xmin,xid)","(oid,oid)","(conname,text)","(connamespace,oid)","(contype,\\"\\"\\"char\\"\\"\\")","(condeferrable,boolean)","(condeferred,boolean)","(convalidated,boolean)","(conrelid,oid)","(contypid,oid)","(conindid,oid)","(confrelid,oid)","(confupdtype,\\"\\"\\"char\\"\\"\\")","(confdeltype,\\"\\"\\"char\\"\\"\\")","(confmatchtype,\\"\\"\\"char\\"\\"\\")","(conislocal,boolean)","(coninhcount,integer)","(connoinherit,boolean)","(conkey,smallint[])","(confkey,smallint[])","(conpfeqop,oid[])","(conppeqop,oid[])","(conffeqop,oid[])","(conexclop,oid[])","(conbin,pg_node_tree)","(consrc,text)"}
9.2	pg_conversion	Catalog	{"(xmin,xid)","(oid,oid)","(conname,text)","(connamespace,oid)","(conowner,oid)","(conforencoding,integer)","(contoencoding,integer)","(conproc,regproc)","(condefault,boolean)"}
9.2	pg_cursors	Other Status	{"(name,text)","(statement,text)","(is_holdable,boolean)","(is_binary,boolean)","(is_scrollable,boolean)","(creation_time,\\"timestamp with time zone\\")"}
9.2	pg_database	Catalog	{"(xmin,xid)","(oid,oid)","(datname,text)","(datdba,oid)","(encoding,integer)","(datcollate,text)","(datctype,text)","(datistemplate,boolean)","(datallowconn,boolean)","(datconnlimit,integer)","(datlastsysoid,oid)","(datfrozenxid,xid)","(dattablespace,oid)","(datacl,aclitem[])"}
9.2	pg_db_role_setting	Catalog	{"(xmin,xid)","(setdatabase,oid)","(setrole,oid)","(setconfig,text[])"}
9.2	pg_default_acl	Catalog	{"(xmin,xid)","(oid,oid)","(defaclrole,oid)","(defaclnamespace,oid)","(defaclobjtype,\\"\\"\\"char\\"\\"\\")","(defaclacl,aclitem[])"}
9.2	pg_depend	Catalog	{"(xmin,xid)","(classid,oid)","(objid,oid)","(objsubid,integer)","(refclassid,oid)","(refobjid,oid)","(refobjsubid,integer)","(deptype,\\"\\"\\"char\\"\\"\\")"}
9.2	pg_description	Catalog	{"(xmin,xid)","(objoid,oid)","(classoid,oid)","(objsubid,integer)","(description,text)"}
9.2	pg_extension	Catalog	{"(xmin,xid)","(oid,oid)","(extname,text)","(extowner,oid)","(extnamespace,oid)","(extrelocatable,boolean)","(extversion,text)","(extconfig,oid[])","(extcondition,text[])"}
9.2	pg_foreign_data_wrapper	Catalog	{"(xmin,xid)","(oid,oid)","(fdwname,text)","(fdwowner,oid)","(fdwhandler,oid)","(fdwvalidator,oid)","(fdwacl,aclitem[])","(fdwoptions,text[])"}
9.2	pg_foreign_server	Catalog	{"(xmin,xid)","(oid,oid)","(srvname,text)","(srvowner,oid)","(srvfdw,oid)","(srvtype,text)","(srvversion,text)","(srvacl,aclitem[])","(srvoptions,text[])"}
9.2	pg_foreign_table	Catalog	{"(xmin,xid)","(ftrelid,oid)","(ftserver,oid)","(ftoptions,text[])"}
9.2	pg_index	Catalog	{"(xmin,xid)","(indexrelid,oid)","(indrelid,oid)","(indnatts,smallint)","(indisunique,boolean)","(indisprimary,boolean)","(indisexclusion,boolean)","(indimmediate,boolean)","(indisclustered,boolean)","(indisvalid,boolean)","(indcheckxmin,boolean)","(indisready,boolean)","(indkey,int2vector)","(indcollation,oidvector)","(indclass,oidvector)","(indoption,int2vector)","(indexprs,pg_node_tree)","(indpred,pg_node_tree)"}
9.2	pg_inherits	Catalog	{"(xmin,xid)","(inhrelid,oid)","(inhparent,oid)","(inhseqno,integer)"}
9.2	pg_language	Catalog	{"(xmin,xid)","(oid,oid)","(lanname,text)","(lanowner,oid)","(lanispl,boolean)","(lanpltrusted,boolean)","(lanplcallfoid,oid)","(laninline,oid)","(lanvalidator,oid)","(lanacl,aclitem[])"}
9.2	pg_largeobject	Catalog	{"(xmin,xid)","(loid,oid)","(pageno,integer)","(data,bytea)"}
9.2	pg_largeobject_metadata	Catalog	{"(xmin,xid)","(oid,oid)","(lomowner,oid)","(lomacl,aclitem[])"}
9.2	pg_locks	Other Status	{"(locktype,text)","(database,oid)","(relation,oid)","(page,integer)","(tuple,smallint)","(virtualxid,text)","(transactionid,xid)","(classid,oid)","(objid,oid)","(objsubid,smallint)","(virtualtransaction,text)","(pid,integer)","(mode,text)","(granted,boolean)","(fastpath,boolean)"}
9.2	pg_namespace	Catalog	{"(xmin,xid)","(oid,oid)","(nspname,text)","(nspowner,oid)","(nspacl,aclitem[])"}
9.2	pg_opclass	Catalog	{"(xmin,xid)","(oid,oid)","(opcmethod,oid)","(opcname,text)","(opcnamespace,oid)","(opcowner,oid)","(opcfamily,oid)","(opcintype,oid)","(opcdefault,boolean)","(opckeytype,oid)"}
9.2	pg_operator	Catalog	{"(xmin,xid)","(oid,oid)","(oprname,text)","(oprnamespace,oid)","(oprowner,oid)","(oprkind,\\"\\"\\"char\\"\\"\\")","(oprcanmerge,boolean)","(oprcanhash,boolean)","(oprleft,oid)","(oprright,oid)","(oprresult,oid)","(oprcom,oid)","(oprnegate,oid)","(oprcode,regproc)","(oprrest,regproc)","(oprjoin,regproc)"}
9.2	pg_opfamily	Catalog	{"(xmin,xid)","(oid,oid)","(opfmethod,oid)","(opfname,text)","(opfnamespace,oid)","(opfowner,oid)"}
9.2	pg_pltemplate	Catalog	{"(xmin,xid)","(tmplname,text)","(tmpltrusted,boolean)","(tmpldbacreate,boolean)","(tmplhandler,text)","(tmplinline,text)","(tmplvalidator,text)","(tmpllibrary,text)","(tmplacl,aclitem[])"}
9.2	pg_prepared_statements	Other Status	{"(name,text)","(statement,text)","(prepare_time,\\"timestamp with time zone\\")","(parameter_types,regtype[])","(from_sql,boolean)"}
9.2	pg_prepared_xacts	Other Status	{"(transaction,xid)","(gid,text)","(prepared,\\"timestamp with time zone\\")","(owner,text)","(database,text)"}
9.2	pg_stat_bgwriter	Stats File	{"(checkpoints_timed,bigint)","(checkpoints_req,bigint)","(checkpoint_write_time,\\"double precision\\")","(checkpoint_sync_time,\\"double precision\\")","(buffers_checkpoint,bigint)","(buffers_clean,bigint)","(maxwritten_clean,bigint)","(buffers_backend,bigint)","(buffers_backend_fsync,bigint)","(buffers_alloc,bigint)","(stats_reset,\\"timestamp with time zone\\")"}
9.2	pg_proc	Catalog	{"(xmin,xid)","(oid,oid)","(proname,text)","(pronamespace,oid)","(proowner,oid)","(prolang,oid)","(procost,real)","(prorows,real)","(provariadic,oid)","(protransform,regproc)","(proisagg,boolean)","(proiswindow,boolean)","(prosecdef,boolean)","(proleakproof,boolean)","(proisstrict,boolean)","(proretset,boolean)","(provolatile,\\"\\"\\"char\\"\\"\\")","(pronargs,smallint)","(pronargdefaults,smallint)","(prorettype,oid)","(proargtypes,oidvector)","(proallargtypes,oid[])","(proargmodes,\\"\\"\\"char\\"\\"[]\\")","(proargnames,text[])","(proargdefaults,pg_node_tree)","(prosrc,text)","(probin,text)","(proconfig,text[])","(proacl,aclitem[])"}
9.2	pg_range	Catalog	{"(xmin,xid)","(rngtypid,oid)","(rngsubtype,oid)","(rngcollation,oid)","(rngsubopc,oid)","(rngcanonical,regproc)","(rngsubdiff,regproc)"}
9.2	pg_rewrite	Catalog	{"(xmin,xid)","(oid,oid)","(rulename,text)","(ev_class,oid)","(ev_attr,smallint)","(ev_type,\\"\\"\\"char\\"\\"\\")","(ev_enabled,\\"\\"\\"char\\"\\"\\")","(is_instead,boolean)","(ev_qual,pg_node_tree)","(ev_action,pg_node_tree)"}
9.2	pg_roles	Other Status	{"(rolname,text)","(rolsuper,boolean)","(rolinherit,boolean)","(rolcreaterole,boolean)","(rolcreatedb,boolean)","(rolcatupdate,boolean)","(rolcanlogin,boolean)","(rolreplication,boolean)","(rolconnlimit,integer)","(rolpassword,text)","(rolvaliduntil,\\"timestamp with time zone\\")","(rolconfig,text[])","(oid,oid)"}
9.2	pg_rules	Other Status	{"(schemaname,text)","(tablename,text)","(rulename,text)","(definition,text)"}
9.2	pg_seclabel	Catalog	{"(xmin,xid)","(objoid,oid)","(classoid,oid)","(objsubid,integer)","(provider,text)","(label,text)"}
9.2	pg_seclabels	Other Status	{"(objoid,oid)","(classoid,oid)","(objsubid,integer)","(objtype,text)","(objnamespace,oid)","(objname,text)","(provider,text)","(label,text)"}
9.2	pg_settings	Other Status	{"(name,text)","(setting,text)","(unit,text)","(category,text)","(short_desc,text)","(extra_desc,text)","(context,text)","(vartype,text)","(source,text)","(min_val,text)","(max_val,text)","(enumvals,text[])","(boot_val,text)","(reset_val,text)","(sourcefile,text)","(sourceline,integer)"}
9.2	pg_shdepend	Catalog	{"(xmin,xid)","(dbid,oid)","(classid,oid)","(objid,oid)","(objsubid,integer)","(refclassid,oid)","(refobjid,oid)","(deptype,\\"\\"\\"char\\"\\"\\")"}
9.2	pg_shdescription	Catalog	{"(xmin,xid)","(objoid,oid)","(classoid,oid)","(description,text)"}
9.2	pg_shseclabel	Catalog	{"(xmin,xid)","(objoid,oid)","(classoid,oid)","(provider,text)","(label,text)"}
9.2	pg_stat_activity	Stats File	{"(datid,oid)","(datname,text)","(pid,integer)","(usesysid,oid)","(usename,text)","(application_name,text)","(client_addr,inet)","(client_hostname,text)","(client_port,integer)","(backend_start,\\"timestamp with time zone\\")","(xact_start,\\"timestamp with time zone\\")","(query_start,\\"timestamp with time zone\\")","(state_change,\\"timestamp with time zone\\")","(waiting,boolean)","(state,text)","(query,text)"}
9.2	pg_stat_all_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_scan,bigint)","(idx_tup_read,bigint)","(idx_tup_fetch,bigint)"}
9.2	pg_stat_all_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)","(n_live_tup,bigint)","(n_dead_tup,bigint)","(last_vacuum,\\"timestamp with time zone\\")","(last_autovacuum,\\"timestamp with time zone\\")","(last_analyze,\\"timestamp with time zone\\")","(last_autoanalyze,\\"timestamp with time zone\\")","(vacuum_count,bigint)","(autovacuum_count,bigint)","(analyze_count,bigint)","(autoanalyze_count,bigint)"}
9.2	pg_stat_database	Stats File	{"(datid,oid)","(datname,text)","(numbackends,integer)","(xact_commit,bigint)","(xact_rollback,bigint)","(blks_read,bigint)","(blks_hit,bigint)","(tup_returned,bigint)","(tup_fetched,bigint)","(tup_inserted,bigint)","(tup_updated,bigint)","(tup_deleted,bigint)","(conflicts,bigint)","(temp_files,bigint)","(temp_bytes,bigint)","(deadlocks,bigint)","(blk_read_time,\\"double precision\\")","(blk_write_time,\\"double precision\\")","(stats_reset,\\"timestamp with time zone\\")"}
9.2	pg_stat_database_conflicts	Stats File	{"(datid,oid)","(datname,text)","(confl_tablespace,bigint)","(confl_lock,bigint)","(confl_snapshot,bigint)","(confl_bufferpin,bigint)","(confl_deadlock,bigint)"}
9.2	pg_stat_replication	Stats File	{"(pid,integer)","(usesysid,oid)","(usename,text)","(application_name,text)","(client_addr,inet)","(client_hostname,text)","(client_port,integer)","(backend_start,\\"timestamp with time zone\\")","(state,text)","(sent_location,text)","(write_location,text)","(flush_location,text)","(replay_location,text)","(sync_priority,integer)","(sync_state,text)"}
9.2	pg_stat_sys_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_scan,bigint)","(idx_tup_read,bigint)","(idx_tup_fetch,bigint)"}
9.2	pg_stat_sys_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)","(n_live_tup,bigint)","(n_dead_tup,bigint)","(last_vacuum,\\"timestamp with time zone\\")","(last_autovacuum,\\"timestamp with time zone\\")","(last_analyze,\\"timestamp with time zone\\")","(last_autoanalyze,\\"timestamp with time zone\\")","(vacuum_count,bigint)","(autovacuum_count,bigint)","(analyze_count,bigint)","(autoanalyze_count,bigint)"}
9.2	pg_stat_user_functions	Stats File	{"(funcid,oid)","(schemaname,text)","(funcname,text)","(calls,bigint)","(total_time,\\"double precision\\")","(self_time,\\"double precision\\")"}
9.2	pg_stat_user_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_scan,bigint)","(idx_tup_read,bigint)","(idx_tup_fetch,bigint)"}
9.2	pg_stat_user_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)","(n_live_tup,bigint)","(n_dead_tup,bigint)","(last_vacuum,\\"timestamp with time zone\\")","(last_autovacuum,\\"timestamp with time zone\\")","(last_analyze,\\"timestamp with time zone\\")","(last_autoanalyze,\\"timestamp with time zone\\")","(vacuum_count,bigint)","(autovacuum_count,bigint)","(analyze_count,bigint)","(autoanalyze_count,bigint)"}
9.2	pg_stat_xact_all_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)"}
9.2	pg_tablespace	Catalog	{"(xmin,xid)","(oid,oid)","(spcname,text)","(spcowner,oid)","(spcacl,aclitem[])","(spcoptions,text[])"}
9.2	pg_timezone_abbrevs	Other Status	{"(abbrev,text)","(utc_offset,interval)","(is_dst,boolean)"}
9.2	pg_stat_xact_sys_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)"}
9.2	pg_stat_xact_user_functions	Stats File	{"(funcid,oid)","(schemaname,text)","(funcname,text)","(calls,bigint)","(total_time,\\"double precision\\")","(self_time,\\"double precision\\")"}
9.2	pg_stat_xact_user_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)"}
9.2	pg_statio_all_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)"}
9.2	pg_statio_all_sequences	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(blks_read,bigint)","(blks_hit,bigint)"}
9.2	pg_statio_all_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(heap_blks_read,bigint)","(heap_blks_hit,bigint)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)","(toast_blks_read,bigint)","(toast_blks_hit,bigint)","(tidx_blks_read,bigint)","(tidx_blks_hit,bigint)"}
9.2	pg_statio_sys_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)"}
9.2	pg_statio_sys_sequences	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(blks_read,bigint)","(blks_hit,bigint)"}
9.2	pg_statio_sys_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(heap_blks_read,bigint)","(heap_blks_hit,bigint)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)","(toast_blks_read,bigint)","(toast_blks_hit,bigint)","(tidx_blks_read,bigint)","(tidx_blks_hit,bigint)"}
9.2	pg_statio_user_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)"}
9.2	pg_statio_user_sequences	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(blks_read,bigint)","(blks_hit,bigint)"}
9.2	pg_statio_user_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(heap_blks_read,bigint)","(heap_blks_hit,bigint)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)","(toast_blks_read,bigint)","(toast_blks_hit,bigint)","(tidx_blks_read,bigint)","(tidx_blks_hit,bigint)"}
9.2	pg_stats	Stats File	{"(schemaname,text)","(tablename,text)","(attname,text)","(inherited,boolean)","(null_frac,real)","(avg_width,integer)","(n_distinct,real)","(most_common_vals,text)","(most_common_freqs,real[])","(histogram_bounds,text)","(correlation,real)","(most_common_elems,text)","(most_common_elem_freqs,real[])","(elem_count_histogram,real[])"}
9.2	pg_timezone_names	Other Status	{"(name,text)","(abbrev,text)","(utc_offset,interval)","(is_dst,boolean)"}
9.2	pg_trigger	Catalog	{"(xmin,xid)","(oid,oid)","(tgrelid,oid)","(tgname,text)","(tgfoid,oid)","(tgtype,smallint)","(tgenabled,\\"\\"\\"char\\"\\"\\")","(tgisinternal,boolean)","(tgconstrrelid,oid)","(tgconstrindid,oid)","(tgconstraint,oid)","(tgdeferrable,boolean)","(tginitdeferred,boolean)","(tgnargs,smallint)","(tgattr,int2vector)","(tgargs,bytea)","(tgqual,pg_node_tree)"}
9.2	pg_ts_config	Catalog	{"(xmin,xid)","(oid,oid)","(cfgname,text)","(cfgnamespace,oid)","(cfgowner,oid)","(cfgparser,oid)"}
9.2	pg_ts_config_map	Catalog	{"(xmin,xid)","(mapcfg,oid)","(maptokentype,integer)","(mapseqno,integer)","(mapdict,oid)"}
9.2	pg_ts_dict	Catalog	{"(xmin,xid)","(oid,oid)","(dictname,text)","(dictnamespace,oid)","(dictowner,oid)","(dicttemplate,oid)","(dictinitoption,text)"}
9.2	pg_ts_parser	Catalog	{"(xmin,xid)","(oid,oid)","(prsname,text)","(prsnamespace,oid)","(prsstart,regproc)","(prstoken,regproc)","(prsend,regproc)","(prsheadline,regproc)","(prslextype,regproc)"}
9.2	pg_ts_template	Catalog	{"(xmin,xid)","(oid,oid)","(tmplname,text)","(tmplnamespace,oid)","(tmplinit,regproc)","(tmpllexize,regproc)"}
9.2	pg_type	Catalog	{"(xmin,xid)","(oid,oid)","(typname,text)","(typnamespace,oid)","(typowner,oid)","(typlen,smallint)","(typbyval,boolean)","(typtype,\\"\\"\\"char\\"\\"\\")","(typcategory,\\"\\"\\"char\\"\\"\\")","(typispreferred,boolean)","(typisdefined,boolean)","(typdelim,\\"\\"\\"char\\"\\"\\")","(typrelid,oid)","(typelem,oid)","(typarray,oid)","(typinput,regproc)","(typoutput,regproc)","(typreceive,regproc)","(typsend,regproc)","(typmodin,regproc)","(typmodout,regproc)","(typanalyze,regproc)","(typalign,\\"\\"\\"char\\"\\"\\")","(typstorage,\\"\\"\\"char\\"\\"\\")","(typnotnull,boolean)","(typbasetype,oid)","(typtypmod,integer)","(typndims,integer)","(typcollation,oid)","(typdefaultbin,pg_node_tree)","(typdefault,text)","(typacl,aclitem[])"}
9.2	pg_user_mapping	Catalog	{"(xmin,xid)","(oid,oid)","(umuser,oid)","(umserver,oid)","(umoptions,text[])"}
9.3	pg_aggregate	Catalog	{"(xmin,xid)","(aggfnoid,regproc)","(aggtransfn,regproc)","(aggfinalfn,regproc)","(aggsortop,oid)","(aggtranstype,oid)","(agginitval,text)"}
9.3	pg_am	Catalog	{"(xmin,xid)","(oid,oid)","(amname,text)","(amstrategies,smallint)","(amsupport,smallint)","(amcanorder,boolean)","(amcanorderbyop,boolean)","(amcanbackward,boolean)","(amcanunique,boolean)","(amcanmulticol,boolean)","(amoptionalkey,boolean)","(amsearcharray,boolean)","(amsearchnulls,boolean)","(amstorage,boolean)","(amclusterable,boolean)","(ampredlocks,boolean)","(amkeytype,oid)","(aminsert,regproc)","(ambeginscan,regproc)","(amgettuple,regproc)","(amgetbitmap,regproc)","(amrescan,regproc)","(amendscan,regproc)","(ammarkpos,regproc)","(amrestrpos,regproc)","(ambuild,regproc)","(ambuildempty,regproc)","(ambulkdelete,regproc)","(amvacuumcleanup,regproc)","(amcanreturn,regproc)","(amcostestimate,regproc)","(amoptions,regproc)"}
9.3	pg_amop	Catalog	{"(xmin,xid)","(oid,oid)","(amopfamily,oid)","(amoplefttype,oid)","(amoprighttype,oid)","(amopstrategy,smallint)","(amoppurpose,\\"\\"\\"char\\"\\"\\")","(amopopr,oid)","(amopmethod,oid)","(amopsortfamily,oid)"}
9.3	pg_amproc	Catalog	{"(xmin,xid)","(oid,oid)","(amprocfamily,oid)","(amproclefttype,oid)","(amprocrighttype,oid)","(amprocnum,smallint)","(amproc,regproc)"}
9.3	pg_attrdef	Catalog	{"(xmin,xid)","(oid,oid)","(adrelid,oid)","(adnum,smallint)","(adbin,pg_node_tree)","(adsrc,text)"}
9.3	pg_enum	Catalog	{"(xmin,xid)","(oid,oid)","(enumtypid,oid)","(enumsortorder,real)","(enumlabel,text)"}
9.3	pg_event_trigger	Catalog	{"(xmin,xid)","(oid,oid)","(evtname,text)","(evtevent,text)","(evtowner,oid)","(evtfoid,oid)","(evtenabled,\\"\\"\\"char\\"\\"\\")","(evttags,text[])"}
9.4	pg_enum	Catalog	{"(xmin,xid)","(oid,oid)","(enumtypid,oid)","(enumsortorder,real)","(enumlabel,text)"}
9.3	pg_attribute	Catalog	{"(xmin,xid)","(attrelid,oid)","(attname,text)","(atttypid,oid)","(attstattarget,integer)","(attlen,smallint)","(attnum,smallint)","(attndims,integer)","(attcacheoff,integer)","(atttypmod,integer)","(attbyval,boolean)","(attstorage,\\"\\"\\"char\\"\\"\\")","(attalign,\\"\\"\\"char\\"\\"\\")","(attnotnull,boolean)","(atthasdef,boolean)","(attisdropped,boolean)","(attislocal,boolean)","(attinhcount,integer)","(attcollation,oid)","(attacl,aclitem[])","(attoptions,text[])","(attfdwoptions,text[])"}
9.3	pg_auth_members	Catalog	{"(xmin,xid)","(roleid,oid)","(member,oid)","(grantor,oid)","(admin_option,boolean)"}
9.3	pg_available_extension_versions	Other Status	{"(name,text)","(version,text)","(installed,boolean)","(superuser,boolean)","(relocatable,boolean)","(schema,text)","(requires,name[])","(comment,text)"}
9.3	pg_available_extensions	Other Status	{"(name,text)","(default_version,text)","(installed_version,text)","(comment,text)"}
9.3	pg_cast	Catalog	{"(xmin,xid)","(oid,oid)","(castsource,oid)","(casttarget,oid)","(castfunc,oid)","(castcontext,\\"\\"\\"char\\"\\"\\")","(castmethod,\\"\\"\\"char\\"\\"\\")"}
9.3	pg_class	Catalog	{"(xmin,xid)","(oid,oid)","(relname,text)","(relnamespace,oid)","(reltype,oid)","(reloftype,oid)","(relowner,oid)","(relam,oid)","(relfilenode,oid)","(reltablespace,oid)","(relpages,integer)","(reltuples,real)","(relallvisible,integer)","(reltoastrelid,oid)","(reltoastidxid,oid)","(relhasindex,boolean)","(relisshared,boolean)","(relpersistence,\\"\\"\\"char\\"\\"\\")","(relkind,\\"\\"\\"char\\"\\"\\")","(relnatts,smallint)","(relchecks,smallint)","(relhasoids,boolean)","(relhaspkey,boolean)","(relhasrules,boolean)","(relhastriggers,boolean)","(relhassubclass,boolean)","(relispopulated,boolean)","(relfrozenxid,xid)","(relminmxid,xid)","(relacl,aclitem[])","(reloptions,text[])"}
9.3	pg_collation	Catalog	{"(xmin,xid)","(oid,oid)","(collname,text)","(collnamespace,oid)","(collowner,oid)","(collencoding,integer)","(collcollate,text)","(collctype,text)"}
9.3	pg_constraint	Catalog	{"(xmin,xid)","(oid,oid)","(conname,text)","(connamespace,oid)","(contype,\\"\\"\\"char\\"\\"\\")","(condeferrable,boolean)","(condeferred,boolean)","(convalidated,boolean)","(conrelid,oid)","(contypid,oid)","(conindid,oid)","(confrelid,oid)","(confupdtype,\\"\\"\\"char\\"\\"\\")","(confdeltype,\\"\\"\\"char\\"\\"\\")","(confmatchtype,\\"\\"\\"char\\"\\"\\")","(conislocal,boolean)","(coninhcount,integer)","(connoinherit,boolean)","(conkey,smallint[])","(confkey,smallint[])","(conpfeqop,oid[])","(conppeqop,oid[])","(conffeqop,oid[])","(conexclop,oid[])","(conbin,pg_node_tree)","(consrc,text)"}
9.3	pg_conversion	Catalog	{"(xmin,xid)","(oid,oid)","(conname,text)","(connamespace,oid)","(conowner,oid)","(conforencoding,integer)","(contoencoding,integer)","(conproc,regproc)","(condefault,boolean)"}
9.3	pg_cursors	Other Status	{"(name,text)","(statement,text)","(is_holdable,boolean)","(is_binary,boolean)","(is_scrollable,boolean)","(creation_time,\\"timestamp with time zone\\")"}
9.3	pg_database	Catalog	{"(xmin,xid)","(oid,oid)","(datname,text)","(datdba,oid)","(encoding,integer)","(datcollate,text)","(datctype,text)","(datistemplate,boolean)","(datallowconn,boolean)","(datconnlimit,integer)","(datlastsysoid,oid)","(datfrozenxid,xid)","(datminmxid,xid)","(dattablespace,oid)","(datacl,aclitem[])"}
9.3	pg_db_role_setting	Catalog	{"(xmin,xid)","(setdatabase,oid)","(setrole,oid)","(setconfig,text[])"}
9.3	pg_default_acl	Catalog	{"(xmin,xid)","(oid,oid)","(defaclrole,oid)","(defaclnamespace,oid)","(defaclobjtype,\\"\\"\\"char\\"\\"\\")","(defaclacl,aclitem[])"}
9.3	pg_depend	Catalog	{"(xmin,xid)","(classid,oid)","(objid,oid)","(objsubid,integer)","(refclassid,oid)","(refobjid,oid)","(refobjsubid,integer)","(deptype,\\"\\"\\"char\\"\\"\\")"}
9.3	pg_description	Catalog	{"(xmin,xid)","(objoid,oid)","(classoid,oid)","(objsubid,integer)","(description,text)"}
9.3	pg_extension	Catalog	{"(xmin,xid)","(oid,oid)","(extname,text)","(extowner,oid)","(extnamespace,oid)","(extrelocatable,boolean)","(extversion,text)","(extconfig,oid[])","(extcondition,text[])"}
9.3	pg_foreign_data_wrapper	Catalog	{"(xmin,xid)","(oid,oid)","(fdwname,text)","(fdwowner,oid)","(fdwhandler,oid)","(fdwvalidator,oid)","(fdwacl,aclitem[])","(fdwoptions,text[])"}
9.3	pg_foreign_server	Catalog	{"(xmin,xid)","(oid,oid)","(srvname,text)","(srvowner,oid)","(srvfdw,oid)","(srvtype,text)","(srvversion,text)","(srvacl,aclitem[])","(srvoptions,text[])"}
9.3	pg_foreign_table	Catalog	{"(xmin,xid)","(ftrelid,oid)","(ftserver,oid)","(ftoptions,text[])"}
9.3	pg_index	Catalog	{"(xmin,xid)","(indexrelid,oid)","(indrelid,oid)","(indnatts,smallint)","(indisunique,boolean)","(indisprimary,boolean)","(indisexclusion,boolean)","(indimmediate,boolean)","(indisclustered,boolean)","(indisvalid,boolean)","(indcheckxmin,boolean)","(indisready,boolean)","(indislive,boolean)","(indkey,int2vector)","(indcollation,oidvector)","(indclass,oidvector)","(indoption,int2vector)","(indexprs,pg_node_tree)","(indpred,pg_node_tree)"}
9.3	pg_inherits	Catalog	{"(xmin,xid)","(inhrelid,oid)","(inhparent,oid)","(inhseqno,integer)"}
9.3	pg_language	Catalog	{"(xmin,xid)","(oid,oid)","(lanname,text)","(lanowner,oid)","(lanispl,boolean)","(lanpltrusted,boolean)","(lanplcallfoid,oid)","(laninline,oid)","(lanvalidator,oid)","(lanacl,aclitem[])"}
9.3	pg_largeobject	Catalog	{"(xmin,xid)","(loid,oid)","(pageno,integer)","(data,bytea)"}
9.3	pg_largeobject_metadata	Catalog	{"(xmin,xid)","(oid,oid)","(lomowner,oid)","(lomacl,aclitem[])"}
9.3	pg_locks	Other Status	{"(locktype,text)","(database,oid)","(relation,oid)","(page,integer)","(tuple,smallint)","(virtualxid,text)","(transactionid,xid)","(classid,oid)","(objid,oid)","(objsubid,smallint)","(virtualtransaction,text)","(pid,integer)","(mode,text)","(granted,boolean)","(fastpath,boolean)"}
9.3	pg_matviews	Other Status	{"(schemaname,text)","(matviewname,text)","(matviewowner,text)","(tablespace,text)","(hasindexes,boolean)","(ispopulated,boolean)","(definition,text)"}
9.3	pg_namespace	Catalog	{"(xmin,xid)","(oid,oid)","(nspname,text)","(nspowner,oid)","(nspacl,aclitem[])"}
9.3	pg_opclass	Catalog	{"(xmin,xid)","(oid,oid)","(opcmethod,oid)","(opcname,text)","(opcnamespace,oid)","(opcowner,oid)","(opcfamily,oid)","(opcintype,oid)","(opcdefault,boolean)","(opckeytype,oid)"}
9.3	pg_operator	Catalog	{"(xmin,xid)","(oid,oid)","(oprname,text)","(oprnamespace,oid)","(oprowner,oid)","(oprkind,\\"\\"\\"char\\"\\"\\")","(oprcanmerge,boolean)","(oprcanhash,boolean)","(oprleft,oid)","(oprright,oid)","(oprresult,oid)","(oprcom,oid)","(oprnegate,oid)","(oprcode,regproc)","(oprrest,regproc)","(oprjoin,regproc)"}
9.3	pg_opfamily	Catalog	{"(xmin,xid)","(oid,oid)","(opfmethod,oid)","(opfname,text)","(opfnamespace,oid)","(opfowner,oid)"}
9.3	pg_pltemplate	Catalog	{"(xmin,xid)","(tmplname,text)","(tmpltrusted,boolean)","(tmpldbacreate,boolean)","(tmplhandler,text)","(tmplinline,text)","(tmplvalidator,text)","(tmpllibrary,text)","(tmplacl,aclitem[])"}
9.3	pg_prepared_statements	Other Status	{"(name,text)","(statement,text)","(prepare_time,\\"timestamp with time zone\\")","(parameter_types,regtype[])","(from_sql,boolean)"}
9.3	pg_prepared_xacts	Other Status	{"(transaction,xid)","(gid,text)","(prepared,\\"timestamp with time zone\\")","(owner,text)","(database,text)"}
9.4	pg_amop	Catalog	{"(xmin,xid)","(oid,oid)","(amopfamily,oid)","(amoplefttype,oid)","(amoprighttype,oid)","(amopstrategy,smallint)","(amoppurpose,\\"\\"\\"char\\"\\"\\")","(amopopr,oid)","(amopmethod,oid)","(amopsortfamily,oid)"}
9.3	pg_proc	Catalog	{"(xmin,xid)","(oid,oid)","(proname,text)","(pronamespace,oid)","(proowner,oid)","(prolang,oid)","(procost,real)","(prorows,real)","(provariadic,oid)","(protransform,regproc)","(proisagg,boolean)","(proiswindow,boolean)","(prosecdef,boolean)","(proleakproof,boolean)","(proisstrict,boolean)","(proretset,boolean)","(provolatile,\\"\\"\\"char\\"\\"\\")","(pronargs,smallint)","(pronargdefaults,smallint)","(prorettype,oid)","(proargtypes,oidvector)","(proallargtypes,oid[])","(proargmodes,\\"\\"\\"char\\"\\"[]\\")","(proargnames,text[])","(proargdefaults,pg_node_tree)","(prosrc,text)","(probin,text)","(proconfig,text[])","(proacl,aclitem[])"}
9.3	pg_range	Catalog	{"(xmin,xid)","(rngtypid,oid)","(rngsubtype,oid)","(rngcollation,oid)","(rngsubopc,oid)","(rngcanonical,regproc)","(rngsubdiff,regproc)"}
9.3	pg_rewrite	Catalog	{"(xmin,xid)","(oid,oid)","(rulename,text)","(ev_class,oid)","(ev_attr,smallint)","(ev_type,\\"\\"\\"char\\"\\"\\")","(ev_enabled,\\"\\"\\"char\\"\\"\\")","(is_instead,boolean)","(ev_qual,pg_node_tree)","(ev_action,pg_node_tree)"}
9.3	pg_roles	Other Status	{"(rolname,text)","(rolsuper,boolean)","(rolinherit,boolean)","(rolcreaterole,boolean)","(rolcreatedb,boolean)","(rolcatupdate,boolean)","(rolcanlogin,boolean)","(rolreplication,boolean)","(rolconnlimit,integer)","(rolpassword,text)","(rolvaliduntil,\\"timestamp with time zone\\")","(rolconfig,text[])","(oid,oid)"}
9.3	pg_rules	Other Status	{"(schemaname,text)","(tablename,text)","(rulename,text)","(definition,text)"}
9.3	pg_seclabel	Catalog	{"(xmin,xid)","(objoid,oid)","(classoid,oid)","(objsubid,integer)","(provider,text)","(label,text)"}
9.3	pg_seclabels	Other Status	{"(objoid,oid)","(classoid,oid)","(objsubid,integer)","(objtype,text)","(objnamespace,oid)","(objname,text)","(provider,text)","(label,text)"}
9.3	pg_settings	Other Status	{"(name,text)","(setting,text)","(unit,text)","(category,text)","(short_desc,text)","(extra_desc,text)","(context,text)","(vartype,text)","(source,text)","(min_val,text)","(max_val,text)","(enumvals,text[])","(boot_val,text)","(reset_val,text)","(sourcefile,text)","(sourceline,integer)"}
9.3	pg_shdepend	Catalog	{"(xmin,xid)","(dbid,oid)","(classid,oid)","(objid,oid)","(objsubid,integer)","(refclassid,oid)","(refobjid,oid)","(deptype,\\"\\"\\"char\\"\\"\\")"}
9.3	pg_shdescription	Catalog	{"(xmin,xid)","(objoid,oid)","(classoid,oid)","(description,text)"}
9.3	pg_shseclabel	Catalog	{"(xmin,xid)","(objoid,oid)","(classoid,oid)","(provider,text)","(label,text)"}
9.3	pg_stat_activity	Stats File	{"(datid,oid)","(datname,text)","(pid,integer)","(usesysid,oid)","(usename,text)","(application_name,text)","(client_addr,inet)","(client_hostname,text)","(client_port,integer)","(backend_start,\\"timestamp with time zone\\")","(xact_start,\\"timestamp with time zone\\")","(query_start,\\"timestamp with time zone\\")","(state_change,\\"timestamp with time zone\\")","(waiting,boolean)","(state,text)","(query,text)"}
9.3	pg_stat_all_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_scan,bigint)","(idx_tup_read,bigint)","(idx_tup_fetch,bigint)"}
9.3	pg_stat_all_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)","(n_live_tup,bigint)","(n_dead_tup,bigint)","(last_vacuum,\\"timestamp with time zone\\")","(last_autovacuum,\\"timestamp with time zone\\")","(last_analyze,\\"timestamp with time zone\\")","(last_autoanalyze,\\"timestamp with time zone\\")","(vacuum_count,bigint)","(autovacuum_count,bigint)","(analyze_count,bigint)","(autoanalyze_count,bigint)"}
9.3	pg_stat_bgwriter	Stats File	{"(checkpoints_timed,bigint)","(checkpoints_req,bigint)","(checkpoint_write_time,\\"double precision\\")","(checkpoint_sync_time,\\"double precision\\")","(buffers_checkpoint,bigint)","(buffers_clean,bigint)","(maxwritten_clean,bigint)","(buffers_backend,bigint)","(buffers_backend_fsync,bigint)","(buffers_alloc,bigint)","(stats_reset,\\"timestamp with time zone\\")"}
9.3	pg_stat_database	Stats File	{"(datid,oid)","(datname,text)","(numbackends,integer)","(xact_commit,bigint)","(xact_rollback,bigint)","(blks_read,bigint)","(blks_hit,bigint)","(tup_returned,bigint)","(tup_fetched,bigint)","(tup_inserted,bigint)","(tup_updated,bigint)","(tup_deleted,bigint)","(conflicts,bigint)","(temp_files,bigint)","(temp_bytes,bigint)","(deadlocks,bigint)","(blk_read_time,\\"double precision\\")","(blk_write_time,\\"double precision\\")","(stats_reset,\\"timestamp with time zone\\")"}
9.3	pg_stat_database_conflicts	Stats File	{"(datid,oid)","(datname,text)","(confl_tablespace,bigint)","(confl_lock,bigint)","(confl_snapshot,bigint)","(confl_bufferpin,bigint)","(confl_deadlock,bigint)"}
9.3	pg_stat_replication	Stats File	{"(pid,integer)","(usesysid,oid)","(usename,text)","(application_name,text)","(client_addr,inet)","(client_hostname,text)","(client_port,integer)","(backend_start,\\"timestamp with time zone\\")","(state,text)","(sent_location,text)","(write_location,text)","(flush_location,text)","(replay_location,text)","(sync_priority,integer)","(sync_state,text)"}
9.3	pg_stat_sys_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_scan,bigint)","(idx_tup_read,bigint)","(idx_tup_fetch,bigint)"}
9.3	pg_stat_sys_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)","(n_live_tup,bigint)","(n_dead_tup,bigint)","(last_vacuum,\\"timestamp with time zone\\")","(last_autovacuum,\\"timestamp with time zone\\")","(last_analyze,\\"timestamp with time zone\\")","(last_autoanalyze,\\"timestamp with time zone\\")","(vacuum_count,bigint)","(autovacuum_count,bigint)","(analyze_count,bigint)","(autoanalyze_count,bigint)"}
9.3	pg_stat_user_functions	Stats File	{"(funcid,oid)","(schemaname,text)","(funcname,text)","(calls,bigint)","(total_time,\\"double precision\\")","(self_time,\\"double precision\\")"}
9.3	pg_stat_user_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_scan,bigint)","(idx_tup_read,bigint)","(idx_tup_fetch,bigint)"}
9.3	pg_stat_user_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)","(n_live_tup,bigint)","(n_dead_tup,bigint)","(last_vacuum,\\"timestamp with time zone\\")","(last_autovacuum,\\"timestamp with time zone\\")","(last_analyze,\\"timestamp with time zone\\")","(last_autoanalyze,\\"timestamp with time zone\\")","(vacuum_count,bigint)","(autovacuum_count,bigint)","(analyze_count,bigint)","(autoanalyze_count,bigint)"}
9.4	pg_amproc	Catalog	{"(xmin,xid)","(oid,oid)","(amprocfamily,oid)","(amproclefttype,oid)","(amprocrighttype,oid)","(amprocnum,smallint)","(amproc,regproc)"}
9.3	pg_stat_xact_all_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)"}
9.3	pg_stat_xact_sys_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)"}
9.3	pg_stat_xact_user_functions	Stats File	{"(funcid,oid)","(schemaname,text)","(funcname,text)","(calls,bigint)","(total_time,\\"double precision\\")","(self_time,\\"double precision\\")"}
9.3	pg_stat_xact_user_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)"}
9.3	pg_statio_all_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)"}
9.3	pg_statio_all_sequences	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(blks_read,bigint)","(blks_hit,bigint)"}
9.3	pg_statio_all_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(heap_blks_read,bigint)","(heap_blks_hit,bigint)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)","(toast_blks_read,bigint)","(toast_blks_hit,bigint)","(tidx_blks_read,bigint)","(tidx_blks_hit,bigint)"}
9.3	pg_statio_sys_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)"}
9.3	pg_statio_sys_sequences	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(blks_read,bigint)","(blks_hit,bigint)"}
9.3	pg_statio_sys_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(heap_blks_read,bigint)","(heap_blks_hit,bigint)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)","(toast_blks_read,bigint)","(toast_blks_hit,bigint)","(tidx_blks_read,bigint)","(tidx_blks_hit,bigint)"}
9.3	pg_statio_user_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)"}
9.3	pg_statio_user_sequences	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(blks_read,bigint)","(blks_hit,bigint)"}
9.3	pg_statio_user_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(heap_blks_read,bigint)","(heap_blks_hit,bigint)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)","(toast_blks_read,bigint)","(toast_blks_hit,bigint)","(tidx_blks_read,bigint)","(tidx_blks_hit,bigint)"}
9.3	pg_stats	Stats File	{"(schemaname,text)","(tablename,text)","(attname,text)","(inherited,boolean)","(null_frac,real)","(avg_width,integer)","(n_distinct,real)","(most_common_vals,text)","(most_common_freqs,real[])","(histogram_bounds,text)","(correlation,real)","(most_common_elems,text)","(most_common_elem_freqs,real[])","(elem_count_histogram,real[])"}
9.3	pg_tablespace	Catalog	{"(xmin,xid)","(oid,oid)","(spcname,text)","(spcowner,oid)","(spcacl,aclitem[])","(spcoptions,text[])"}
9.3	pg_timezone_abbrevs	Other Status	{"(abbrev,text)","(utc_offset,interval)","(is_dst,boolean)"}
9.3	pg_timezone_names	Other Status	{"(name,text)","(abbrev,text)","(utc_offset,interval)","(is_dst,boolean)"}
9.3	pg_trigger	Catalog	{"(xmin,xid)","(oid,oid)","(tgrelid,oid)","(tgname,text)","(tgfoid,oid)","(tgtype,smallint)","(tgenabled,\\"\\"\\"char\\"\\"\\")","(tgisinternal,boolean)","(tgconstrrelid,oid)","(tgconstrindid,oid)","(tgconstraint,oid)","(tgdeferrable,boolean)","(tginitdeferred,boolean)","(tgnargs,smallint)","(tgattr,int2vector)","(tgargs,bytea)","(tgqual,pg_node_tree)"}
9.3	pg_ts_config	Catalog	{"(xmin,xid)","(oid,oid)","(cfgname,text)","(cfgnamespace,oid)","(cfgowner,oid)","(cfgparser,oid)"}
9.3	pg_ts_config_map	Catalog	{"(xmin,xid)","(mapcfg,oid)","(maptokentype,integer)","(mapseqno,integer)","(mapdict,oid)"}
9.3	pg_ts_dict	Catalog	{"(xmin,xid)","(oid,oid)","(dictname,text)","(dictnamespace,oid)","(dictowner,oid)","(dicttemplate,oid)","(dictinitoption,text)"}
9.3	pg_ts_parser	Catalog	{"(xmin,xid)","(oid,oid)","(prsname,text)","(prsnamespace,oid)","(prsstart,regproc)","(prstoken,regproc)","(prsend,regproc)","(prsheadline,regproc)","(prslextype,regproc)"}
9.3	pg_ts_template	Catalog	{"(xmin,xid)","(oid,oid)","(tmplname,text)","(tmplnamespace,oid)","(tmplinit,regproc)","(tmpllexize,regproc)"}
9.3	pg_type	Catalog	{"(xmin,xid)","(oid,oid)","(typname,text)","(typnamespace,oid)","(typowner,oid)","(typlen,smallint)","(typbyval,boolean)","(typtype,\\"\\"\\"char\\"\\"\\")","(typcategory,\\"\\"\\"char\\"\\"\\")","(typispreferred,boolean)","(typisdefined,boolean)","(typdelim,\\"\\"\\"char\\"\\"\\")","(typrelid,oid)","(typelem,oid)","(typarray,oid)","(typinput,regproc)","(typoutput,regproc)","(typreceive,regproc)","(typsend,regproc)","(typmodin,regproc)","(typmodout,regproc)","(typanalyze,regproc)","(typalign,\\"\\"\\"char\\"\\"\\")","(typstorage,\\"\\"\\"char\\"\\"\\")","(typnotnull,boolean)","(typbasetype,oid)","(typtypmod,integer)","(typndims,integer)","(typcollation,oid)","(typdefaultbin,pg_node_tree)","(typdefault,text)","(typacl,aclitem[])"}
9.3	pg_user_mapping	Catalog	{"(xmin,xid)","(oid,oid)","(umuser,oid)","(umserver,oid)","(umoptions,text[])"}
9.4	pg_aggregate	Catalog	{"(xmin,xid)","(aggfnoid,regproc)","(aggkind,\\"\\"\\"char\\"\\"\\")","(aggnumdirectargs,smallint)","(aggtransfn,regproc)","(aggfinalfn,regproc)","(aggmtransfn,regproc)","(aggminvtransfn,regproc)","(aggmfinalfn,regproc)","(aggfinalextra,boolean)","(aggmfinalextra,boolean)","(aggsortop,oid)","(aggtranstype,oid)","(aggtransspace,integer)","(aggmtranstype,oid)","(aggmtransspace,integer)","(agginitval,text)","(aggminitval,text)"}
9.4	pg_am	Catalog	{"(xmin,xid)","(oid,oid)","(amname,text)","(amstrategies,smallint)","(amsupport,smallint)","(amcanorder,boolean)","(amcanorderbyop,boolean)","(amcanbackward,boolean)","(amcanunique,boolean)","(amcanmulticol,boolean)","(amoptionalkey,boolean)","(amsearcharray,boolean)","(amsearchnulls,boolean)","(amstorage,boolean)","(amclusterable,boolean)","(ampredlocks,boolean)","(amkeytype,oid)","(aminsert,regproc)","(ambeginscan,regproc)","(amgettuple,regproc)","(amgetbitmap,regproc)","(amrescan,regproc)","(amendscan,regproc)","(ammarkpos,regproc)","(amrestrpos,regproc)","(ambuild,regproc)","(ambuildempty,regproc)","(ambulkdelete,regproc)","(amvacuumcleanup,regproc)","(amcanreturn,regproc)","(amcostestimate,regproc)","(amoptions,regproc)"}
9.4	pg_attribute	Catalog	{"(xmin,xid)","(attrelid,oid)","(attname,text)","(atttypid,oid)","(attstattarget,integer)","(attlen,smallint)","(attnum,smallint)","(attndims,integer)","(attcacheoff,integer)","(atttypmod,integer)","(attbyval,boolean)","(attstorage,\\"\\"\\"char\\"\\"\\")","(attalign,\\"\\"\\"char\\"\\"\\")","(attnotnull,boolean)","(atthasdef,boolean)","(attisdropped,boolean)","(attislocal,boolean)","(attinhcount,integer)","(attcollation,oid)","(attacl,aclitem[])","(attoptions,text[])","(attfdwoptions,text[])"}
9.4	pg_auth_members	Catalog	{"(xmin,xid)","(roleid,oid)","(member,oid)","(grantor,oid)","(admin_option,boolean)"}
9.4	pg_available_extension_versions	Other Status	{"(name,text)","(version,text)","(installed,boolean)","(superuser,boolean)","(relocatable,boolean)","(schema,text)","(requires,name[])","(comment,text)"}
9.4	pg_available_extensions	Other Status	{"(name,text)","(default_version,text)","(installed_version,text)","(comment,text)"}
9.4	pg_cast	Catalog	{"(xmin,xid)","(oid,oid)","(castsource,oid)","(casttarget,oid)","(castfunc,oid)","(castcontext,\\"\\"\\"char\\"\\"\\")","(castmethod,\\"\\"\\"char\\"\\"\\")"}
9.4	pg_class	Catalog	{"(xmin,xid)","(oid,oid)","(relname,text)","(relnamespace,oid)","(reltype,oid)","(reloftype,oid)","(relowner,oid)","(relam,oid)","(relfilenode,oid)","(reltablespace,oid)","(relpages,integer)","(reltuples,real)","(relallvisible,integer)","(reltoastrelid,oid)","(relhasindex,boolean)","(relisshared,boolean)","(relpersistence,\\"\\"\\"char\\"\\"\\")","(relkind,\\"\\"\\"char\\"\\"\\")","(relnatts,smallint)","(relchecks,smallint)","(relhasoids,boolean)","(relhaspkey,boolean)","(relhasrules,boolean)","(relhastriggers,boolean)","(relhassubclass,boolean)","(relispopulated,boolean)","(relreplident,\\"\\"\\"char\\"\\"\\")","(relfrozenxid,xid)","(relminmxid,xid)","(relacl,aclitem[])","(reloptions,text[])"}
9.4	pg_collation	Catalog	{"(xmin,xid)","(oid,oid)","(collname,text)","(collnamespace,oid)","(collowner,oid)","(collencoding,integer)","(collcollate,text)","(collctype,text)"}
9.4	pg_constraint	Catalog	{"(xmin,xid)","(oid,oid)","(conname,text)","(connamespace,oid)","(contype,\\"\\"\\"char\\"\\"\\")","(condeferrable,boolean)","(condeferred,boolean)","(convalidated,boolean)","(conrelid,oid)","(contypid,oid)","(conindid,oid)","(confrelid,oid)","(confupdtype,\\"\\"\\"char\\"\\"\\")","(confdeltype,\\"\\"\\"char\\"\\"\\")","(confmatchtype,\\"\\"\\"char\\"\\"\\")","(conislocal,boolean)","(coninhcount,integer)","(connoinherit,boolean)","(conkey,smallint[])","(confkey,smallint[])","(conpfeqop,oid[])","(conppeqop,oid[])","(conffeqop,oid[])","(conexclop,oid[])","(conbin,pg_node_tree)","(consrc,text)"}
9.4	pg_conversion	Catalog	{"(xmin,xid)","(oid,oid)","(conname,text)","(connamespace,oid)","(conowner,oid)","(conforencoding,integer)","(contoencoding,integer)","(conproc,regproc)","(condefault,boolean)"}
9.4	pg_cursors	Other Status	{"(name,text)","(statement,text)","(is_holdable,boolean)","(is_binary,boolean)","(is_scrollable,boolean)","(creation_time,\\"timestamp with time zone\\")"}
9.4	pg_database	Catalog	{"(xmin,xid)","(oid,oid)","(datname,text)","(datdba,oid)","(encoding,integer)","(datcollate,text)","(datctype,text)","(datistemplate,boolean)","(datallowconn,boolean)","(datconnlimit,integer)","(datlastsysoid,oid)","(datfrozenxid,xid)","(datminmxid,xid)","(dattablespace,oid)","(datacl,aclitem[])"}
9.4	pg_db_role_setting	Catalog	{"(xmin,xid)","(setdatabase,oid)","(setrole,oid)","(setconfig,text[])"}
9.4	pg_default_acl	Catalog	{"(xmin,xid)","(oid,oid)","(defaclrole,oid)","(defaclnamespace,oid)","(defaclobjtype,\\"\\"\\"char\\"\\"\\")","(defaclacl,aclitem[])"}
9.4	pg_depend	Catalog	{"(xmin,xid)","(classid,oid)","(objid,oid)","(objsubid,integer)","(refclassid,oid)","(refobjid,oid)","(refobjsubid,integer)","(deptype,\\"\\"\\"char\\"\\"\\")"}
9.4	pg_description	Catalog	{"(xmin,xid)","(objoid,oid)","(classoid,oid)","(objsubid,integer)","(description,text)"}
9.4	pg_event_trigger	Catalog	{"(xmin,xid)","(oid,oid)","(evtname,text)","(evtevent,text)","(evtowner,oid)","(evtfoid,oid)","(evtenabled,\\"\\"\\"char\\"\\"\\")","(evttags,text[])"}
9.4	pg_extension	Catalog	{"(xmin,xid)","(oid,oid)","(extname,text)","(extowner,oid)","(extnamespace,oid)","(extrelocatable,boolean)","(extversion,text)","(extconfig,oid[])","(extcondition,text[])"}
9.4	pg_foreign_data_wrapper	Catalog	{"(xmin,xid)","(oid,oid)","(fdwname,text)","(fdwowner,oid)","(fdwhandler,oid)","(fdwvalidator,oid)","(fdwacl,aclitem[])","(fdwoptions,text[])"}
9.4	pg_foreign_server	Catalog	{"(xmin,xid)","(oid,oid)","(srvname,text)","(srvowner,oid)","(srvfdw,oid)","(srvtype,text)","(srvversion,text)","(srvacl,aclitem[])","(srvoptions,text[])"}
9.4	pg_foreign_table	Catalog	{"(xmin,xid)","(ftrelid,oid)","(ftserver,oid)","(ftoptions,text[])"}
9.4	pg_index	Catalog	{"(xmin,xid)","(indexrelid,oid)","(indrelid,oid)","(indnatts,smallint)","(indisunique,boolean)","(indisprimary,boolean)","(indisexclusion,boolean)","(indimmediate,boolean)","(indisclustered,boolean)","(indisvalid,boolean)","(indcheckxmin,boolean)","(indisready,boolean)","(indislive,boolean)","(indisreplident,boolean)","(indkey,int2vector)","(indcollation,oidvector)","(indclass,oidvector)","(indoption,int2vector)","(indexprs,pg_node_tree)","(indpred,pg_node_tree)"}
9.4	pg_inherits	Catalog	{"(xmin,xid)","(inhrelid,oid)","(inhparent,oid)","(inhseqno,integer)"}
9.4	pg_language	Catalog	{"(xmin,xid)","(oid,oid)","(lanname,text)","(lanowner,oid)","(lanispl,boolean)","(lanpltrusted,boolean)","(lanplcallfoid,oid)","(laninline,oid)","(lanvalidator,oid)","(lanacl,aclitem[])"}
9.4	pg_largeobject	Catalog	{"(xmin,xid)","(loid,oid)","(pageno,integer)","(data,bytea)"}
9.4	pg_largeobject_metadata	Catalog	{"(xmin,xid)","(oid,oid)","(lomowner,oid)","(lomacl,aclitem[])"}
9.4	pg_locks	Other Status	{"(locktype,text)","(database,oid)","(relation,oid)","(page,integer)","(tuple,smallint)","(virtualxid,text)","(transactionid,xid)","(classid,oid)","(objid,oid)","(objsubid,smallint)","(virtualtransaction,text)","(pid,integer)","(mode,text)","(granted,boolean)","(fastpath,boolean)"}
9.4	pg_matviews	Other Status	{"(schemaname,text)","(matviewname,text)","(matviewowner,text)","(tablespace,text)","(hasindexes,boolean)","(ispopulated,boolean)","(definition,text)"}
9.4	pg_namespace	Catalog	{"(xmin,xid)","(oid,oid)","(nspname,text)","(nspowner,oid)","(nspacl,aclitem[])"}
9.4	pg_opclass	Catalog	{"(xmin,xid)","(oid,oid)","(opcmethod,oid)","(opcname,text)","(opcnamespace,oid)","(opcowner,oid)","(opcfamily,oid)","(opcintype,oid)","(opcdefault,boolean)","(opckeytype,oid)"}
9.4	pg_operator	Catalog	{"(xmin,xid)","(oid,oid)","(oprname,text)","(oprnamespace,oid)","(oprowner,oid)","(oprkind,\\"\\"\\"char\\"\\"\\")","(oprcanmerge,boolean)","(oprcanhash,boolean)","(oprleft,oid)","(oprright,oid)","(oprresult,oid)","(oprcom,oid)","(oprnegate,oid)","(oprcode,regproc)","(oprrest,regproc)","(oprjoin,regproc)"}
9.4	pg_opfamily	Catalog	{"(xmin,xid)","(oid,oid)","(opfmethod,oid)","(opfname,text)","(opfnamespace,oid)","(opfowner,oid)"}
9.4	pg_pltemplate	Catalog	{"(xmin,xid)","(tmplname,text)","(tmpltrusted,boolean)","(tmpldbacreate,boolean)","(tmplhandler,text)","(tmplinline,text)","(tmplvalidator,text)","(tmpllibrary,text)","(tmplacl,aclitem[])"}
9.4	pg_prepared_statements	Other Status	{"(name,text)","(statement,text)","(prepare_time,\\"timestamp with time zone\\")","(parameter_types,regtype[])","(from_sql,boolean)"}
9.4	pg_prepared_xacts	Other Status	{"(transaction,xid)","(gid,text)","(prepared,\\"timestamp with time zone\\")","(owner,text)","(database,text)"}
9.4	pg_proc	Catalog	{"(xmin,xid)","(oid,oid)","(proname,text)","(pronamespace,oid)","(proowner,oid)","(prolang,oid)","(procost,real)","(prorows,real)","(provariadic,oid)","(protransform,regproc)","(proisagg,boolean)","(proiswindow,boolean)","(prosecdef,boolean)","(proleakproof,boolean)","(proisstrict,boolean)","(proretset,boolean)","(provolatile,\\"\\"\\"char\\"\\"\\")","(pronargs,smallint)","(pronargdefaults,smallint)","(prorettype,oid)","(proargtypes,oidvector)","(proallargtypes,oid[])","(proargmodes,\\"\\"\\"char\\"\\"[]\\")","(proargnames,text[])","(proargdefaults,pg_node_tree)","(prosrc,text)","(probin,text)","(proconfig,text[])","(proacl,aclitem[])"}
9.4	pg_range	Catalog	{"(xmin,xid)","(rngtypid,oid)","(rngsubtype,oid)","(rngcollation,oid)","(rngsubopc,oid)","(rngcanonical,regproc)","(rngsubdiff,regproc)"}
9.4	pg_replication_slots	Stats File	{"(slot_name,text)","(plugin,text)","(slot_type,text)","(datoid,oid)","(database,text)","(active,boolean)","(xmin,xid)","(catalog_xmin,xid)","(restart_lsn,pg_lsn)"}
9.4	pg_rewrite	Catalog	{"(xmin,xid)","(oid,oid)","(rulename,text)","(ev_class,oid)","(ev_type,\\"\\"\\"char\\"\\"\\")","(ev_enabled,\\"\\"\\"char\\"\\"\\")","(is_instead,boolean)","(ev_qual,pg_node_tree)","(ev_action,pg_node_tree)"}
9.4	pg_roles	Other Status	{"(rolname,text)","(rolsuper,boolean)","(rolinherit,boolean)","(rolcreaterole,boolean)","(rolcreatedb,boolean)","(rolcatupdate,boolean)","(rolcanlogin,boolean)","(rolreplication,boolean)","(rolconnlimit,integer)","(rolpassword,text)","(rolvaliduntil,\\"timestamp with time zone\\")","(rolconfig,text[])","(oid,oid)"}
9.4	pg_rules	Other Status	{"(schemaname,text)","(tablename,text)","(rulename,text)","(definition,text)"}
9.4	pg_seclabel	Catalog	{"(xmin,xid)","(objoid,oid)","(classoid,oid)","(objsubid,integer)","(provider,text)","(label,text)"}
9.4	pg_seclabels	Other Status	{"(objoid,oid)","(classoid,oid)","(objsubid,integer)","(objtype,text)","(objnamespace,oid)","(objname,text)","(provider,text)","(label,text)"}
9.4	pg_settings	Other Status	{"(name,text)","(setting,text)","(unit,text)","(category,text)","(short_desc,text)","(extra_desc,text)","(context,text)","(vartype,text)","(source,text)","(min_val,text)","(max_val,text)","(enumvals,text[])","(boot_val,text)","(reset_val,text)","(sourcefile,text)","(sourceline,integer)"}
9.4	pg_shdepend	Catalog	{"(xmin,xid)","(dbid,oid)","(classid,oid)","(objid,oid)","(objsubid,integer)","(refclassid,oid)","(refobjid,oid)","(deptype,\\"\\"\\"char\\"\\"\\")"}
9.4	pg_shdescription	Catalog	{"(xmin,xid)","(objoid,oid)","(classoid,oid)","(description,text)"}
9.4	pg_shseclabel	Catalog	{"(xmin,xid)","(objoid,oid)","(classoid,oid)","(provider,text)","(label,text)"}
9.4	pg_stat_activity	Stats File	{"(datid,oid)","(datname,text)","(pid,integer)","(usesysid,oid)","(usename,text)","(application_name,text)","(client_addr,inet)","(client_hostname,text)","(client_port,integer)","(backend_start,\\"timestamp with time zone\\")","(xact_start,\\"timestamp with time zone\\")","(query_start,\\"timestamp with time zone\\")","(state_change,\\"timestamp with time zone\\")","(waiting,boolean)","(state,text)","(backend_xid,xid)","(backend_xmin,xid)","(query,text)"}
9.4	pg_stat_all_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_scan,bigint)","(idx_tup_read,bigint)","(idx_tup_fetch,bigint)"}
9.4	pg_stat_user_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_scan,bigint)","(idx_tup_read,bigint)","(idx_tup_fetch,bigint)"}
9.4	pg_stat_all_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)","(n_live_tup,bigint)","(n_dead_tup,bigint)","(n_mod_since_analyze,bigint)","(last_vacuum,\\"timestamp with time zone\\")","(last_autovacuum,\\"timestamp with time zone\\")","(last_analyze,\\"timestamp with time zone\\")","(last_autoanalyze,\\"timestamp with time zone\\")","(vacuum_count,bigint)","(autovacuum_count,bigint)","(analyze_count,bigint)","(autoanalyze_count,bigint)"}
9.4	pg_stat_archiver	Stats File	{"(archived_count,bigint)","(last_archived_wal,text)","(last_archived_time,\\"timestamp with time zone\\")","(failed_count,bigint)","(last_failed_wal,text)","(last_failed_time,\\"timestamp with time zone\\")","(stats_reset,\\"timestamp with time zone\\")"}
9.4	pg_stat_bgwriter	Stats File	{"(checkpoints_timed,bigint)","(checkpoints_req,bigint)","(checkpoint_write_time,\\"double precision\\")","(checkpoint_sync_time,\\"double precision\\")","(buffers_checkpoint,bigint)","(buffers_clean,bigint)","(maxwritten_clean,bigint)","(buffers_backend,bigint)","(buffers_backend_fsync,bigint)","(buffers_alloc,bigint)","(stats_reset,\\"timestamp with time zone\\")"}
9.4	pg_stat_database	Stats File	{"(datid,oid)","(datname,text)","(numbackends,integer)","(xact_commit,bigint)","(xact_rollback,bigint)","(blks_read,bigint)","(blks_hit,bigint)","(tup_returned,bigint)","(tup_fetched,bigint)","(tup_inserted,bigint)","(tup_updated,bigint)","(tup_deleted,bigint)","(conflicts,bigint)","(temp_files,bigint)","(temp_bytes,bigint)","(deadlocks,bigint)","(blk_read_time,\\"double precision\\")","(blk_write_time,\\"double precision\\")","(stats_reset,\\"timestamp with time zone\\")"}
9.4	pg_stat_database_conflicts	Stats File	{"(datid,oid)","(datname,text)","(confl_tablespace,bigint)","(confl_lock,bigint)","(confl_snapshot,bigint)","(confl_bufferpin,bigint)","(confl_deadlock,bigint)"}
9.4	pg_stat_replication	Stats File	{"(pid,integer)","(usesysid,oid)","(usename,text)","(application_name,text)","(client_addr,inet)","(client_hostname,text)","(client_port,integer)","(backend_start,\\"timestamp with time zone\\")","(backend_xmin,xid)","(state,text)","(sent_location,pg_lsn)","(write_location,pg_lsn)","(flush_location,pg_lsn)","(replay_location,pg_lsn)","(sync_priority,integer)","(sync_state,text)"}
9.4	pg_stat_sys_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_scan,bigint)","(idx_tup_read,bigint)","(idx_tup_fetch,bigint)"}
9.4	pg_stat_sys_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)","(n_live_tup,bigint)","(n_dead_tup,bigint)","(n_mod_since_analyze,bigint)","(last_vacuum,\\"timestamp with time zone\\")","(last_autovacuum,\\"timestamp with time zone\\")","(last_analyze,\\"timestamp with time zone\\")","(last_autoanalyze,\\"timestamp with time zone\\")","(vacuum_count,bigint)","(autovacuum_count,bigint)","(analyze_count,bigint)","(autoanalyze_count,bigint)"}
9.4	pg_stat_user_functions	Stats File	{"(funcid,oid)","(schemaname,text)","(funcname,text)","(calls,bigint)","(total_time,\\"double precision\\")","(self_time,\\"double precision\\")"}
9.4	pg_stat_user_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)","(n_live_tup,bigint)","(n_dead_tup,bigint)","(n_mod_since_analyze,bigint)","(last_vacuum,\\"timestamp with time zone\\")","(last_autovacuum,\\"timestamp with time zone\\")","(last_analyze,\\"timestamp with time zone\\")","(last_autoanalyze,\\"timestamp with time zone\\")","(vacuum_count,bigint)","(autovacuum_count,bigint)","(analyze_count,bigint)","(autoanalyze_count,bigint)"}
9.4	pg_stat_xact_all_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)"}
9.4	pg_stat_xact_sys_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)"}
9.4	pg_stat_xact_user_functions	Stats File	{"(funcid,oid)","(schemaname,text)","(funcname,text)","(calls,bigint)","(total_time,\\"double precision\\")","(self_time,\\"double precision\\")"}
9.4	pg_stat_xact_user_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)"}
9.4	pg_statio_all_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)"}
9.4	pg_statio_all_sequences	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(blks_read,bigint)","(blks_hit,bigint)"}
9.4	pg_statio_all_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(heap_blks_read,bigint)","(heap_blks_hit,bigint)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)","(toast_blks_read,bigint)","(toast_blks_hit,bigint)","(tidx_blks_read,bigint)","(tidx_blks_hit,bigint)"}
9.4	pg_statio_sys_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)"}
9.4	pg_statio_sys_sequences	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(blks_read,bigint)","(blks_hit,bigint)"}
9.4	pg_statio_sys_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(heap_blks_read,bigint)","(heap_blks_hit,bigint)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)","(toast_blks_read,bigint)","(toast_blks_hit,bigint)","(tidx_blks_read,bigint)","(tidx_blks_hit,bigint)"}
9.4	pg_statio_user_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)"}
9.4	pg_statio_user_sequences	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(blks_read,bigint)","(blks_hit,bigint)"}
9.4	pg_statio_user_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(heap_blks_read,bigint)","(heap_blks_hit,bigint)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)","(toast_blks_read,bigint)","(toast_blks_hit,bigint)","(tidx_blks_read,bigint)","(tidx_blks_hit,bigint)"}
9.4	pg_stats	Stats File	{"(schemaname,text)","(tablename,text)","(attname,text)","(inherited,boolean)","(null_frac,real)","(avg_width,integer)","(n_distinct,real)","(most_common_vals,text)","(most_common_freqs,real[])","(histogram_bounds,text)","(correlation,real)","(most_common_elems,text)","(most_common_elem_freqs,real[])","(elem_count_histogram,real[])"}
9.4	pg_tablespace	Catalog	{"(xmin,xid)","(oid,oid)","(spcname,text)","(spcowner,oid)","(spcacl,aclitem[])","(spcoptions,text[])"}
9.4	pg_timezone_abbrevs	Other Status	{"(abbrev,text)","(utc_offset,interval)","(is_dst,boolean)"}
9.4	pg_timezone_names	Other Status	{"(name,text)","(abbrev,text)","(utc_offset,interval)","(is_dst,boolean)"}
9.4	pg_trigger	Catalog	{"(xmin,xid)","(oid,oid)","(tgrelid,oid)","(tgname,text)","(tgfoid,oid)","(tgtype,smallint)","(tgenabled,\\"\\"\\"char\\"\\"\\")","(tgisinternal,boolean)","(tgconstrrelid,oid)","(tgconstrindid,oid)","(tgconstraint,oid)","(tgdeferrable,boolean)","(tginitdeferred,boolean)","(tgnargs,smallint)","(tgattr,int2vector)","(tgargs,bytea)","(tgqual,pg_node_tree)"}
9.4	pg_ts_config	Catalog	{"(xmin,xid)","(oid,oid)","(cfgname,text)","(cfgnamespace,oid)","(cfgowner,oid)","(cfgparser,oid)"}
9.4	pg_ts_config_map	Catalog	{"(xmin,xid)","(mapcfg,oid)","(maptokentype,integer)","(mapseqno,integer)","(mapdict,oid)"}
9.4	pg_ts_dict	Catalog	{"(xmin,xid)","(oid,oid)","(dictname,text)","(dictnamespace,oid)","(dictowner,oid)","(dicttemplate,oid)","(dictinitoption,text)"}
9.4	pg_ts_parser	Catalog	{"(xmin,xid)","(oid,oid)","(prsname,text)","(prsnamespace,oid)","(prsstart,regproc)","(prstoken,regproc)","(prsend,regproc)","(prsheadline,regproc)","(prslextype,regproc)"}
9.4	pg_ts_template	Catalog	{"(xmin,xid)","(oid,oid)","(tmplname,text)","(tmplnamespace,oid)","(tmplinit,regproc)","(tmpllexize,regproc)"}
9.4	pg_type	Catalog	{"(xmin,xid)","(oid,oid)","(typname,text)","(typnamespace,oid)","(typowner,oid)","(typlen,smallint)","(typbyval,boolean)","(typtype,\\"\\"\\"char\\"\\"\\")","(typcategory,\\"\\"\\"char\\"\\"\\")","(typispreferred,boolean)","(typisdefined,boolean)","(typdelim,\\"\\"\\"char\\"\\"\\")","(typrelid,oid)","(typelem,oid)","(typarray,oid)","(typinput,regproc)","(typoutput,regproc)","(typreceive,regproc)","(typsend,regproc)","(typmodin,regproc)","(typmodout,regproc)","(typanalyze,regproc)","(typalign,\\"\\"\\"char\\"\\"\\")","(typstorage,\\"\\"\\"char\\"\\"\\")","(typnotnull,boolean)","(typbasetype,oid)","(typtypmod,integer)","(typndims,integer)","(typcollation,oid)","(typdefaultbin,pg_node_tree)","(typdefault,text)","(typacl,aclitem[])"}
9.4	pg_user_mapping	Catalog	{"(xmin,xid)","(oid,oid)","(umuser,oid)","(umserver,oid)","(umoptions,text[])"}
9.5	pg_aggregate	Catalog	{"(xmin,xid)","(aggfnoid,regproc)","(aggkind,\\"\\"\\"char\\"\\"\\")","(aggnumdirectargs,smallint)","(aggtransfn,regproc)","(aggfinalfn,regproc)","(aggmtransfn,regproc)","(aggminvtransfn,regproc)","(aggmfinalfn,regproc)","(aggfinalextra,boolean)","(aggmfinalextra,boolean)","(aggsortop,oid)","(aggtranstype,oid)","(aggtransspace,integer)","(aggmtranstype,oid)","(aggmtransspace,integer)","(agginitval,text)","(aggminitval,text)"}
9.5	pg_seclabel	Catalog	{"(xmin,xid)","(objoid,oid)","(classoid,oid)","(objsubid,integer)","(provider,text)","(label,text)"}
9.5	pg_am	Catalog	{"(xmin,xid)","(oid,oid)","(amname,text)","(amstrategies,smallint)","(amsupport,smallint)","(amcanorder,boolean)","(amcanorderbyop,boolean)","(amcanbackward,boolean)","(amcanunique,boolean)","(amcanmulticol,boolean)","(amoptionalkey,boolean)","(amsearcharray,boolean)","(amsearchnulls,boolean)","(amstorage,boolean)","(amclusterable,boolean)","(ampredlocks,boolean)","(amkeytype,oid)","(aminsert,regproc)","(ambeginscan,regproc)","(amgettuple,regproc)","(amgetbitmap,regproc)","(amrescan,regproc)","(amendscan,regproc)","(ammarkpos,regproc)","(amrestrpos,regproc)","(ambuild,regproc)","(ambuildempty,regproc)","(ambulkdelete,regproc)","(amvacuumcleanup,regproc)","(amcanreturn,regproc)","(amcostestimate,regproc)","(amoptions,regproc)"}
9.5	pg_amop	Catalog	{"(xmin,xid)","(oid,oid)","(amopfamily,oid)","(amoplefttype,oid)","(amoprighttype,oid)","(amopstrategy,smallint)","(amoppurpose,\\"\\"\\"char\\"\\"\\")","(amopopr,oid)","(amopmethod,oid)","(amopsortfamily,oid)"}
9.5	pg_amproc	Catalog	{"(xmin,xid)","(oid,oid)","(amprocfamily,oid)","(amproclefttype,oid)","(amprocrighttype,oid)","(amprocnum,smallint)","(amproc,regproc)"}
9.5	pg_attrdef	Catalog	{"(xmin,xid)","(oid,oid)","(adrelid,oid)","(adnum,smallint)","(adbin,pg_node_tree)","(adsrc,text)"}
9.5	pg_attribute	Catalog	{"(xmin,xid)","(attrelid,oid)","(attname,text)","(atttypid,oid)","(attstattarget,integer)","(attlen,smallint)","(attnum,smallint)","(attndims,integer)","(attcacheoff,integer)","(atttypmod,integer)","(attbyval,boolean)","(attstorage,\\"\\"\\"char\\"\\"\\")","(attalign,\\"\\"\\"char\\"\\"\\")","(attnotnull,boolean)","(atthasdef,boolean)","(attisdropped,boolean)","(attislocal,boolean)","(attinhcount,integer)","(attcollation,oid)","(attacl,aclitem[])","(attoptions,text[])","(attfdwoptions,text[])"}
9.5	pg_auth_members	Catalog	{"(xmin,xid)","(roleid,oid)","(member,oid)","(grantor,oid)","(admin_option,boolean)"}
9.5	pg_available_extension_versions	Other Status	{"(name,text)","(version,text)","(installed,boolean)","(superuser,boolean)","(relocatable,boolean)","(schema,text)","(requires,name[])","(comment,text)"}
9.5	pg_available_extensions	Other Status	{"(name,text)","(default_version,text)","(installed_version,text)","(comment,text)"}
9.5	pg_cast	Catalog	{"(xmin,xid)","(oid,oid)","(castsource,oid)","(casttarget,oid)","(castfunc,oid)","(castcontext,\\"\\"\\"char\\"\\"\\")","(castmethod,\\"\\"\\"char\\"\\"\\")"}
9.5	pg_class	Catalog	{"(xmin,xid)","(oid,oid)","(relname,text)","(relnamespace,oid)","(reltype,oid)","(reloftype,oid)","(relowner,oid)","(relam,oid)","(relfilenode,oid)","(reltablespace,oid)","(relpages,integer)","(reltuples,real)","(relallvisible,integer)","(reltoastrelid,oid)","(relhasindex,boolean)","(relisshared,boolean)","(relpersistence,\\"\\"\\"char\\"\\"\\")","(relkind,\\"\\"\\"char\\"\\"\\")","(relnatts,smallint)","(relchecks,smallint)","(relhasoids,boolean)","(relhaspkey,boolean)","(relhasrules,boolean)","(relhastriggers,boolean)","(relhassubclass,boolean)","(relrowsecurity,boolean)","(relforcerowsecurity,boolean)","(relispopulated,boolean)","(relreplident,\\"\\"\\"char\\"\\"\\")","(relfrozenxid,xid)","(relminmxid,xid)","(relacl,aclitem[])","(reloptions,text[])"}
9.5	pg_collation	Catalog	{"(xmin,xid)","(oid,oid)","(collname,text)","(collnamespace,oid)","(collowner,oid)","(collencoding,integer)","(collcollate,text)","(collctype,text)"}
9.5	pg_constraint	Catalog	{"(xmin,xid)","(oid,oid)","(conname,text)","(connamespace,oid)","(contype,\\"\\"\\"char\\"\\"\\")","(condeferrable,boolean)","(condeferred,boolean)","(convalidated,boolean)","(conrelid,oid)","(contypid,oid)","(conindid,oid)","(confrelid,oid)","(confupdtype,\\"\\"\\"char\\"\\"\\")","(confdeltype,\\"\\"\\"char\\"\\"\\")","(confmatchtype,\\"\\"\\"char\\"\\"\\")","(conislocal,boolean)","(coninhcount,integer)","(connoinherit,boolean)","(conkey,smallint[])","(confkey,smallint[])","(conpfeqop,oid[])","(conppeqop,oid[])","(conffeqop,oid[])","(conexclop,oid[])","(conbin,pg_node_tree)","(consrc,text)"}
9.5	pg_conversion	Catalog	{"(xmin,xid)","(oid,oid)","(conname,text)","(connamespace,oid)","(conowner,oid)","(conforencoding,integer)","(contoencoding,integer)","(conproc,regproc)","(condefault,boolean)"}
9.5	pg_cursors	Other Status	{"(name,text)","(statement,text)","(is_holdable,boolean)","(is_binary,boolean)","(is_scrollable,boolean)","(creation_time,\\"timestamp with time zone\\")"}
9.5	pg_database	Catalog	{"(xmin,xid)","(oid,oid)","(datname,text)","(datdba,oid)","(encoding,integer)","(datcollate,text)","(datctype,text)","(datistemplate,boolean)","(datallowconn,boolean)","(datconnlimit,integer)","(datlastsysoid,oid)","(datfrozenxid,xid)","(datminmxid,xid)","(dattablespace,oid)","(datacl,aclitem[])"}
9.5	pg_db_role_setting	Catalog	{"(xmin,xid)","(setdatabase,oid)","(setrole,oid)","(setconfig,text[])"}
9.5	pg_default_acl	Catalog	{"(xmin,xid)","(oid,oid)","(defaclrole,oid)","(defaclnamespace,oid)","(defaclobjtype,\\"\\"\\"char\\"\\"\\")","(defaclacl,aclitem[])"}
9.5	pg_depend	Catalog	{"(xmin,xid)","(classid,oid)","(objid,oid)","(objsubid,integer)","(refclassid,oid)","(refobjid,oid)","(refobjsubid,integer)","(deptype,\\"\\"\\"char\\"\\"\\")"}
9.5	pg_description	Catalog	{"(xmin,xid)","(objoid,oid)","(classoid,oid)","(objsubid,integer)","(description,text)"}
9.5	pg_enum	Catalog	{"(xmin,xid)","(oid,oid)","(enumtypid,oid)","(enumsortorder,real)","(enumlabel,text)"}
9.5	pg_event_trigger	Catalog	{"(xmin,xid)","(oid,oid)","(evtname,text)","(evtevent,text)","(evtowner,oid)","(evtfoid,oid)","(evtenabled,\\"\\"\\"char\\"\\"\\")","(evttags,text[])"}
9.5	pg_extension	Catalog	{"(xmin,xid)","(oid,oid)","(extname,text)","(extowner,oid)","(extnamespace,oid)","(extrelocatable,boolean)","(extversion,text)","(extconfig,oid[])","(extcondition,text[])"}
9.5	pg_file_settings	Other Status	{"(sourcefile,text)","(sourceline,integer)","(seqno,integer)","(name,text)","(setting,text)","(applied,boolean)","(error,text)"}
9.5	pg_foreign_data_wrapper	Catalog	{"(xmin,xid)","(oid,oid)","(fdwname,text)","(fdwowner,oid)","(fdwhandler,oid)","(fdwvalidator,oid)","(fdwacl,aclitem[])","(fdwoptions,text[])"}
9.5	pg_foreign_server	Catalog	{"(xmin,xid)","(oid,oid)","(srvname,text)","(srvowner,oid)","(srvfdw,oid)","(srvtype,text)","(srvversion,text)","(srvacl,aclitem[])","(srvoptions,text[])"}
9.5	pg_foreign_table	Catalog	{"(xmin,xid)","(ftrelid,oid)","(ftserver,oid)","(ftoptions,text[])"}
9.5	pg_index	Catalog	{"(xmin,xid)","(indexrelid,oid)","(indrelid,oid)","(indnatts,smallint)","(indisunique,boolean)","(indisprimary,boolean)","(indisexclusion,boolean)","(indimmediate,boolean)","(indisclustered,boolean)","(indisvalid,boolean)","(indcheckxmin,boolean)","(indisready,boolean)","(indislive,boolean)","(indisreplident,boolean)","(indkey,int2vector)","(indcollation,oidvector)","(indclass,oidvector)","(indoption,int2vector)","(indexprs,pg_node_tree)","(indpred,pg_node_tree)"}
9.5	pg_inherits	Catalog	{"(xmin,xid)","(inhrelid,oid)","(inhparent,oid)","(inhseqno,integer)"}
9.5	pg_language	Catalog	{"(xmin,xid)","(oid,oid)","(lanname,text)","(lanowner,oid)","(lanispl,boolean)","(lanpltrusted,boolean)","(lanplcallfoid,oid)","(laninline,oid)","(lanvalidator,oid)","(lanacl,aclitem[])"}
9.5	pg_largeobject	Catalog	{"(xmin,xid)","(loid,oid)","(pageno,integer)","(data,bytea)"}
9.5	pg_largeobject_metadata	Catalog	{"(xmin,xid)","(oid,oid)","(lomowner,oid)","(lomacl,aclitem[])"}
9.5	pg_roles	Other Status	{"(rolname,text)","(rolsuper,boolean)","(rolinherit,boolean)","(rolcreaterole,boolean)","(rolcreatedb,boolean)","(rolcanlogin,boolean)","(rolreplication,boolean)","(rolconnlimit,integer)","(rolpassword,text)","(rolvaliduntil,\\"timestamp with time zone\\")","(rolbypassrls,boolean)","(rolconfig,text[])","(oid,oid)"}
9.5	pg_locks	Other Status	{"(locktype,text)","(database,oid)","(relation,oid)","(page,integer)","(tuple,smallint)","(virtualxid,text)","(transactionid,xid)","(classid,oid)","(objid,oid)","(objsubid,smallint)","(virtualtransaction,text)","(pid,integer)","(mode,text)","(granted,boolean)","(fastpath,boolean)"}
9.5	pg_matviews	Other Status	{"(schemaname,text)","(matviewname,text)","(matviewowner,text)","(tablespace,text)","(hasindexes,boolean)","(ispopulated,boolean)","(definition,text)"}
9.5	pg_namespace	Catalog	{"(xmin,xid)","(oid,oid)","(nspname,text)","(nspowner,oid)","(nspacl,aclitem[])"}
9.5	pg_opclass	Catalog	{"(xmin,xid)","(oid,oid)","(opcmethod,oid)","(opcname,text)","(opcnamespace,oid)","(opcowner,oid)","(opcfamily,oid)","(opcintype,oid)","(opcdefault,boolean)","(opckeytype,oid)"}
9.5	pg_operator	Catalog	{"(xmin,xid)","(oid,oid)","(oprname,text)","(oprnamespace,oid)","(oprowner,oid)","(oprkind,\\"\\"\\"char\\"\\"\\")","(oprcanmerge,boolean)","(oprcanhash,boolean)","(oprleft,oid)","(oprright,oid)","(oprresult,oid)","(oprcom,oid)","(oprnegate,oid)","(oprcode,regproc)","(oprrest,regproc)","(oprjoin,regproc)"}
9.5	pg_opfamily	Catalog	{"(xmin,xid)","(oid,oid)","(opfmethod,oid)","(opfname,text)","(opfnamespace,oid)","(opfowner,oid)"}
9.5	pg_pltemplate	Catalog	{"(xmin,xid)","(tmplname,text)","(tmpltrusted,boolean)","(tmpldbacreate,boolean)","(tmplhandler,text)","(tmplinline,text)","(tmplvalidator,text)","(tmpllibrary,text)","(tmplacl,aclitem[])"}
9.5	pg_policies	Other Status	{"(schemaname,text)","(tablename,text)","(policyname,text)","(roles,name[])","(cmd,text)","(qual,text)","(with_check,text)"}
9.5	pg_policy	Catalog	{"(xmin,xid)","(oid,oid)","(polname,text)","(polrelid,oid)","(polcmd,\\"\\"\\"char\\"\\"\\")","(polroles,oid[])","(polqual,pg_node_tree)","(polwithcheck,pg_node_tree)"}
9.5	pg_prepared_statements	Other Status	{"(name,text)","(statement,text)","(prepare_time,\\"timestamp with time zone\\")","(parameter_types,regtype[])","(from_sql,boolean)"}
9.5	pg_prepared_xacts	Other Status	{"(transaction,xid)","(gid,text)","(prepared,\\"timestamp with time zone\\")","(owner,text)","(database,text)"}
9.5	pg_proc	Catalog	{"(xmin,xid)","(oid,oid)","(proname,text)","(pronamespace,oid)","(proowner,oid)","(prolang,oid)","(procost,real)","(prorows,real)","(provariadic,oid)","(protransform,regproc)","(proisagg,boolean)","(proiswindow,boolean)","(prosecdef,boolean)","(proleakproof,boolean)","(proisstrict,boolean)","(proretset,boolean)","(provolatile,\\"\\"\\"char\\"\\"\\")","(pronargs,smallint)","(pronargdefaults,smallint)","(prorettype,oid)","(proargtypes,oidvector)","(proallargtypes,oid[])","(proargmodes,\\"\\"\\"char\\"\\"[]\\")","(proargnames,text[])","(proargdefaults,pg_node_tree)","(protrftypes,oid[])","(prosrc,text)","(probin,text)","(proconfig,text[])","(proacl,aclitem[])"}
9.5	pg_range	Catalog	{"(xmin,xid)","(rngtypid,oid)","(rngsubtype,oid)","(rngcollation,oid)","(rngsubopc,oid)","(rngcanonical,regproc)","(rngsubdiff,regproc)"}
9.5	pg_replication_origin	Catalog	{"(xmin,xid)","(roident,oid)","(roname,text)"}
9.5	pg_replication_origin_status	Stats File	{"(local_id,oid)","(external_id,text)","(remote_lsn,pg_lsn)","(local_lsn,pg_lsn)"}
9.5	pg_replication_slots	Stats File	{"(slot_name,text)","(plugin,text)","(slot_type,text)","(datoid,oid)","(database,text)","(active,boolean)","(active_pid,integer)","(xmin,xid)","(catalog_xmin,xid)","(restart_lsn,pg_lsn)"}
9.5	pg_rewrite	Catalog	{"(xmin,xid)","(oid,oid)","(rulename,text)","(ev_class,oid)","(ev_type,\\"\\"\\"char\\"\\"\\")","(ev_enabled,\\"\\"\\"char\\"\\"\\")","(is_instead,boolean)","(ev_qual,pg_node_tree)","(ev_action,pg_node_tree)"}
9.5	pg_rules	Other Status	{"(schemaname,text)","(tablename,text)","(rulename,text)","(definition,text)"}
9.5	pg_seclabels	Other Status	{"(objoid,oid)","(classoid,oid)","(objsubid,integer)","(objtype,text)","(objnamespace,oid)","(objname,text)","(provider,text)","(label,text)"}
9.5	pg_settings	Other Status	{"(name,text)","(setting,text)","(unit,text)","(category,text)","(short_desc,text)","(extra_desc,text)","(context,text)","(vartype,text)","(source,text)","(min_val,text)","(max_val,text)","(enumvals,text[])","(boot_val,text)","(reset_val,text)","(sourcefile,text)","(sourceline,integer)","(pending_restart,boolean)"}
9.5	pg_shdepend	Catalog	{"(xmin,xid)","(dbid,oid)","(classid,oid)","(objid,oid)","(objsubid,integer)","(refclassid,oid)","(refobjid,oid)","(deptype,\\"\\"\\"char\\"\\"\\")"}
9.5	pg_shdescription	Catalog	{"(xmin,xid)","(objoid,oid)","(classoid,oid)","(description,text)"}
9.5	pg_shseclabel	Catalog	{"(xmin,xid)","(objoid,oid)","(classoid,oid)","(provider,text)","(label,text)"}
9.5	pg_stat_activity	Stats File	{"(datid,oid)","(datname,text)","(pid,integer)","(usesysid,oid)","(usename,text)","(application_name,text)","(client_addr,inet)","(client_hostname,text)","(client_port,integer)","(backend_start,\\"timestamp with time zone\\")","(xact_start,\\"timestamp with time zone\\")","(query_start,\\"timestamp with time zone\\")","(state_change,\\"timestamp with time zone\\")","(waiting,boolean)","(state,text)","(backend_xid,xid)","(backend_xmin,xid)","(query,text)"}
9.5	pg_stat_all_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_scan,bigint)","(idx_tup_read,bigint)","(idx_tup_fetch,bigint)"}
9.5	pg_stat_all_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)","(n_live_tup,bigint)","(n_dead_tup,bigint)","(n_mod_since_analyze,bigint)","(last_vacuum,\\"timestamp with time zone\\")","(last_autovacuum,\\"timestamp with time zone\\")","(last_analyze,\\"timestamp with time zone\\")","(last_autoanalyze,\\"timestamp with time zone\\")","(vacuum_count,bigint)","(autovacuum_count,bigint)","(analyze_count,bigint)","(autoanalyze_count,bigint)"}
9.5	pg_stat_archiver	Stats File	{"(archived_count,bigint)","(last_archived_wal,text)","(last_archived_time,\\"timestamp with time zone\\")","(failed_count,bigint)","(last_failed_wal,text)","(last_failed_time,\\"timestamp with time zone\\")","(stats_reset,\\"timestamp with time zone\\")"}
9.5	pg_stat_bgwriter	Stats File	{"(checkpoints_timed,bigint)","(checkpoints_req,bigint)","(checkpoint_write_time,\\"double precision\\")","(checkpoint_sync_time,\\"double precision\\")","(buffers_checkpoint,bigint)","(buffers_clean,bigint)","(maxwritten_clean,bigint)","(buffers_backend,bigint)","(buffers_backend_fsync,bigint)","(buffers_alloc,bigint)","(stats_reset,\\"timestamp with time zone\\")"}
9.5	pg_stat_database	Stats File	{"(datid,oid)","(datname,text)","(numbackends,integer)","(xact_commit,bigint)","(xact_rollback,bigint)","(blks_read,bigint)","(blks_hit,bigint)","(tup_returned,bigint)","(tup_fetched,bigint)","(tup_inserted,bigint)","(tup_updated,bigint)","(tup_deleted,bigint)","(conflicts,bigint)","(temp_files,bigint)","(temp_bytes,bigint)","(deadlocks,bigint)","(blk_read_time,\\"double precision\\")","(blk_write_time,\\"double precision\\")","(stats_reset,\\"timestamp with time zone\\")"}
9.5	pg_stat_database_conflicts	Stats File	{"(datid,oid)","(datname,text)","(confl_tablespace,bigint)","(confl_lock,bigint)","(confl_snapshot,bigint)","(confl_bufferpin,bigint)","(confl_deadlock,bigint)"}
9.5	pg_stat_replication	Stats File	{"(pid,integer)","(usesysid,oid)","(usename,text)","(application_name,text)","(client_addr,inet)","(client_hostname,text)","(client_port,integer)","(backend_start,\\"timestamp with time zone\\")","(backend_xmin,xid)","(state,text)","(sent_location,pg_lsn)","(write_location,pg_lsn)","(flush_location,pg_lsn)","(replay_location,pg_lsn)","(sync_priority,integer)","(sync_state,text)"}
9.5	pg_stat_ssl	Stats File	{"(pid,integer)","(ssl,boolean)","(version,text)","(cipher,text)","(bits,integer)","(compression,boolean)","(clientdn,text)"}
9.5	pg_stat_sys_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_scan,bigint)","(idx_tup_read,bigint)","(idx_tup_fetch,bigint)"}
9.5	pg_stat_sys_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)","(n_live_tup,bigint)","(n_dead_tup,bigint)","(n_mod_since_analyze,bigint)","(last_vacuum,\\"timestamp with time zone\\")","(last_autovacuum,\\"timestamp with time zone\\")","(last_analyze,\\"timestamp with time zone\\")","(last_autoanalyze,\\"timestamp with time zone\\")","(vacuum_count,bigint)","(autovacuum_count,bigint)","(analyze_count,bigint)","(autoanalyze_count,bigint)"}
9.5	pg_stat_user_functions	Stats File	{"(funcid,oid)","(schemaname,text)","(funcname,text)","(calls,bigint)","(total_time,\\"double precision\\")","(self_time,\\"double precision\\")"}
9.5	pg_stat_user_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_scan,bigint)","(idx_tup_read,bigint)","(idx_tup_fetch,bigint)"}
9.5	pg_stat_user_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)","(n_live_tup,bigint)","(n_dead_tup,bigint)","(n_mod_since_analyze,bigint)","(last_vacuum,\\"timestamp with time zone\\")","(last_autovacuum,\\"timestamp with time zone\\")","(last_analyze,\\"timestamp with time zone\\")","(last_autoanalyze,\\"timestamp with time zone\\")","(vacuum_count,bigint)","(autovacuum_count,bigint)","(analyze_count,bigint)","(autoanalyze_count,bigint)"}
9.5	pg_stat_xact_all_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)"}
9.5	pg_stat_xact_sys_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)"}
9.5	pg_stat_xact_user_functions	Stats File	{"(funcid,oid)","(schemaname,text)","(funcname,text)","(calls,bigint)","(total_time,\\"double precision\\")","(self_time,\\"double precision\\")"}
9.5	pg_stat_xact_user_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(seq_scan,bigint)","(seq_tup_read,bigint)","(idx_scan,bigint)","(idx_tup_fetch,bigint)","(n_tup_ins,bigint)","(n_tup_upd,bigint)","(n_tup_del,bigint)","(n_tup_hot_upd,bigint)"}
9.5	pg_statio_all_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)"}
9.5	pg_statio_all_sequences	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(blks_read,bigint)","(blks_hit,bigint)"}
9.5	pg_statio_all_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(heap_blks_read,bigint)","(heap_blks_hit,bigint)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)","(toast_blks_read,bigint)","(toast_blks_hit,bigint)","(tidx_blks_read,bigint)","(tidx_blks_hit,bigint)"}
9.5	pg_statio_sys_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)"}
9.5	pg_statio_sys_sequences	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(blks_read,bigint)","(blks_hit,bigint)"}
9.5	pg_statio_sys_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(heap_blks_read,bigint)","(heap_blks_hit,bigint)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)","(toast_blks_read,bigint)","(toast_blks_hit,bigint)","(tidx_blks_read,bigint)","(tidx_blks_hit,bigint)"}
9.5	pg_statio_user_indexes	Stats File	{"(relid,oid)","(indexrelid,oid)","(schemaname,text)","(relname,text)","(indexrelname,text)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)"}
9.5	pg_statio_user_sequences	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(blks_read,bigint)","(blks_hit,bigint)"}
9.5	pg_statio_user_tables	Stats File	{"(relid,oid)","(schemaname,text)","(relname,text)","(heap_blks_read,bigint)","(heap_blks_hit,bigint)","(idx_blks_read,bigint)","(idx_blks_hit,bigint)","(toast_blks_read,bigint)","(toast_blks_hit,bigint)","(tidx_blks_read,bigint)","(tidx_blks_hit,bigint)"}
9.5	pg_stats	Stats File	{"(schemaname,text)","(tablename,text)","(attname,text)","(inherited,boolean)","(null_frac,real)","(avg_width,integer)","(n_distinct,real)","(most_common_vals,text)","(most_common_freqs,real[])","(histogram_bounds,text)","(correlation,real)","(most_common_elems,text)","(most_common_elem_freqs,real[])","(elem_count_histogram,real[])"}
9.5	pg_tablespace	Catalog	{"(xmin,xid)","(oid,oid)","(spcname,text)","(spcowner,oid)","(spcacl,aclitem[])","(spcoptions,text[])"}
9.5	pg_timezone_abbrevs	Other Status	{"(abbrev,text)","(utc_offset,interval)","(is_dst,boolean)"}
9.5	pg_timezone_names	Other Status	{"(name,text)","(abbrev,text)","(utc_offset,interval)","(is_dst,boolean)"}
9.5	pg_transform	Catalog	{"(xmin,xid)","(oid,oid)","(trftype,oid)","(trflang,oid)","(trffromsql,regproc)","(trftosql,regproc)"}
9.5	pg_trigger	Catalog	{"(xmin,xid)","(oid,oid)","(tgrelid,oid)","(tgname,text)","(tgfoid,oid)","(tgtype,smallint)","(tgenabled,\\"\\"\\"char\\"\\"\\")","(tgisinternal,boolean)","(tgconstrrelid,oid)","(tgconstrindid,oid)","(tgconstraint,oid)","(tgdeferrable,boolean)","(tginitdeferred,boolean)","(tgnargs,smallint)","(tgattr,int2vector)","(tgargs,bytea)","(tgqual,pg_node_tree)"}
9.5	pg_ts_config	Catalog	{"(xmin,xid)","(oid,oid)","(cfgname,text)","(cfgnamespace,oid)","(cfgowner,oid)","(cfgparser,oid)"}
9.5	pg_ts_config_map	Catalog	{"(xmin,xid)","(mapcfg,oid)","(maptokentype,integer)","(mapseqno,integer)","(mapdict,oid)"}
9.5	pg_ts_dict	Catalog	{"(xmin,xid)","(oid,oid)","(dictname,text)","(dictnamespace,oid)","(dictowner,oid)","(dicttemplate,oid)","(dictinitoption,text)"}
9.5	pg_ts_parser	Catalog	{"(xmin,xid)","(oid,oid)","(prsname,text)","(prsnamespace,oid)","(prsstart,regproc)","(prstoken,regproc)","(prsend,regproc)","(prsheadline,regproc)","(prslextype,regproc)"}
9.5	pg_ts_template	Catalog	{"(xmin,xid)","(oid,oid)","(tmplname,text)","(tmplnamespace,oid)","(tmplinit,regproc)","(tmpllexize,regproc)"}
9.5	pg_type	Catalog	{"(xmin,xid)","(oid,oid)","(typname,text)","(typnamespace,oid)","(typowner,oid)","(typlen,smallint)","(typbyval,boolean)","(typtype,\\"\\"\\"char\\"\\"\\")","(typcategory,\\"\\"\\"char\\"\\"\\")","(typispreferred,boolean)","(typisdefined,boolean)","(typdelim,\\"\\"\\"char\\"\\"\\")","(typrelid,oid)","(typelem,oid)","(typarray,oid)","(typinput,regproc)","(typoutput,regproc)","(typreceive,regproc)","(typsend,regproc)","(typmodin,regproc)","(typmodout,regproc)","(typanalyze,regproc)","(typalign,\\"\\"\\"char\\"\\"\\")","(typstorage,\\"\\"\\"char\\"\\"\\")","(typnotnull,boolean)","(typbasetype,oid)","(typtypmod,integer)","(typndims,integer)","(typcollation,oid)","(typdefaultbin,pg_node_tree)","(typdefault,text)","(typacl,aclitem[])"}
9.5	pg_user_mapping	Catalog	{"(xmin,xid)","(oid,oid)","(umuser,oid)","(umserver,oid)","(umoptions,text[])"}
\.


--
-- Name: entity_pkey; Type: CONSTRAINT; Schema: public; Owner: decibel
--

ALTER TABLE ONLY catalog_relations
    ADD CONSTRAINT entity_pkey PRIMARY KEY (version, entity_name);


--
-- Name: public; Type: ACL; Schema: -; Owner: decibel
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM decibel;
GRANT ALL ON SCHEMA public TO decibel;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

