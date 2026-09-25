--
-- PostgreSQL database dump
--

\restrict cATcxOzrlhwNkO1177tFyaUyscJguplnPcYbEf7OLncjlbi4bJtsJCXVUyQYaVc

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: _realtime; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA _realtime;


--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA extensions;


--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql;


--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql_public;


--
-- Name: pg_net; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_net; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_net IS 'Async HTTP';


--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pgbouncer;


--
-- Name: private; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA private;


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA realtime;


--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA storage;


--
-- Name: supabase_functions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA supabase_functions;


--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA vault;


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


--
-- Name: oauth_authorization_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_authorization_status AS ENUM (
    'pending',
    'approved',
    'denied',
    'expired'
);


--
-- Name: oauth_client_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_client_type AS ENUM (
    'public',
    'confidential'
);


--
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


--
-- Name: oauth_response_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_response_type AS ENUM (
    'code'
);


--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


--
-- Name: action; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in',
    'like',
    'ilike',
    'is',
    'match',
    'imatch',
    'isdistinct'
);


--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text,
	negate boolean
);


--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


--
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: -
--

CREATE TYPE storage.buckettype AS ENUM (
    'STANDARD',
    'ANALYTICS',
    'VECTOR'
);


--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
begin
    if not exists (
        select 1
        from pg_event_trigger_ddl_commands() ev
        join pg_catalog.pg_extension e on ev.objid = e.oid
        where e.extname = 'pg_graphql'
    ) then
        return;
    end if;

    drop function if exists graphql_public.graphql;
    create or replace function graphql_public.graphql(
        "operationName" text default null,
        query text default null,
        variables jsonb default null,
        extensions jsonb default null
    )
        returns jsonb
        language sql
    as $$
        select graphql.resolve(
            query := query,
            variables := coalesce(variables, '{}'),
            "operationName" := "operationName",
            extensions := extensions
        );
    $$;

    -- Attach the wrapper to the extension so DROP EXTENSION cascades to it,
    -- which in turn triggers set_graphql_placeholder to reinstall the "not enabled" stub.
    alter extension pg_graphql add function graphql_public.graphql(text, text, jsonb, jsonb);

    grant usage on schema graphql to postgres, anon, authenticated, service_role;
    grant execute on function graphql.resolve to postgres, anon, authenticated, service_role;
    grant usage on schema graphql to postgres with grant option;
    grant usage on schema graphql_public to postgres with grant option;
end;
$_$;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: graphql(text, text, jsonb, jsonb); Type: FUNCTION; Schema: graphql_public; Owner: -
--

CREATE FUNCTION graphql_public.graphql("operationName" text DEFAULT NULL::text, query text DEFAULT NULL::text, variables jsonb DEFAULT NULL::jsonb, extensions jsonb DEFAULT NULL::jsonb) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: -
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $_$
begin
    raise debug 'PgBouncer auth request: %', p_usename;

    return query
    select 
        rolname::text, 
        case when rolvaliduntil < now() 
            then null 
            else rolpassword::text 
        end 
    from pg_authid 
    where rolname=$1 and rolcanlogin;
end;
$_$;


--
-- Name: accept_patient_invitation(text); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.accept_patient_invitation(invitation_code text) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
declare patient uuid := private.my_patient_id(); invitation public.patient_invitations;
begin
  if auth.uid() is null or patient is null then raise exception 'Patient account required'; end if;
  select * into invitation from public.patient_invitations where code=upper(regexp_replace(invitation_code,'[^a-zA-Z0-9]','','g')) for update;
  if invitation.id is null or invitation.expires_at<now() or invitation.revoked_at is not null
    or (invitation.accepted_by is not null and invitation.accepted_by<>patient) then raise exception 'INVITATION_UNAVAILABLE'; end if;
  -- A previously consumed code must not restore a deliberately revoked relationship.
  if invitation.accepted_by=patient then return invitation.professional_id; end if;
  insert into public.professional_patients(professional_id,patient_id) values(invitation.professional_id,patient)
    on conflict (professional_id,patient_id) do update set active=true, linked_at=now(), ended_at=null;
  update public.patient_invitations set accepted_by=patient,accepted_at=now() where id=invitation.id;
  return invitation.professional_id;
end $$;


--
-- Name: can_access_patient(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.can_access_patient(target_patient_id uuid) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
    select
        private.is_patient_owner(target_patient_id)
        or
        private.is_assigned_professional(target_patient_id);
$$;


--
-- Name: can_view_patient(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.can_view_patient(target uuid) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
  select (select auth.uid()) is not null and (coalesce(target = private.my_patient_id(),false) or exists (
    select 1 from public.professional_patients pp where pp.patient_id=target and pp.active and pp.professional_id=private.my_professional_id()))
$$;


--
-- Name: can_view_profile(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.can_view_profile(target uuid) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
  select (select auth.uid()) is not null and (target=private.my_profile_id()
    or exists(select 1 from public.patients p where p.profile_id=target and private.can_view_patient(p.id))
    or exists(select 1 from public.professionals p join public.professional_patients pp on pp.professional_id=p.id
      where p.profile_id=target and pp.patient_id=private.my_patient_id() and pp.active))
$$;


--
-- Name: create_account(text, text); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.create_account(account_role text, account_name text) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
declare profile_id uuid; patient_id uuid;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if account_role not in ('patient','professional') then raise exception 'Invalid role'; end if;
  perform pg_advisory_xact_lock(hashtextextended(auth.uid()::text, 0));
  select id into profile_id from public.profiles where user_id=auth.uid();
  if profile_id is not null then return profile_id; end if;
  insert into public.profiles(user_id, role, display_name) values(auth.uid(), account_role, trim(account_name)) returning id into profile_id;
  if account_role='patient' then
    insert into public.patients(profile_id) values(profile_id) returning id into patient_id;
    insert into public.patient_histories(patient_id) values(patient_id);
  else
    insert into public.professionals(profile_id) values(profile_id);
  end if;
  return profile_id;
end $$;


--
-- Name: current_patient_id(); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.current_patient_id() RETURNS uuid
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
    select pt.id
    from public.patients pt
    join public.profiles p
      on p.id = pt.profile_id
    where p.user_id = (select auth.uid())
      and pt.status = 'active'
    limit 1;
$$;


--
-- Name: current_professional_id(); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.current_professional_id() RETURNS uuid
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
    select pr.id
    from public.professionals pr
    join public.profiles p
      on p.id = pr.profile_id
    where p.user_id = (select auth.uid())
      and pr.status = 'active'
    limit 1;
$$;


--
-- Name: current_profile_id(); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.current_profile_id() RETURNS uuid
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
    select p.id
    from public.profiles p
    where p.user_id = (select auth.uid())
    limit 1;
$$;


--
-- Name: end_patient_assignment(uuid, uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.end_patient_assignment(target_patient uuid, target_professional uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
begin
  if auth.uid() is null or not(coalesce(target_patient=private.my_patient_id(),false) or coalesce(target_professional=private.my_professional_id(),false)) then raise exception 'Not allowed'; end if;
  update public.professional_patients set active=false, ended_at=now() where patient_id=target_patient and professional_id=target_professional;
end $$;


--
-- Name: enforce_alert_professional_update(); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.enforce_alert_professional_update() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
declare
    v_professional_id uuid;
begin
    -- Los procesos servidor con service_role pueden operar la alerta.
    if auth.role() = 'service_role' then
        new.updated_at := now();
        return new;
    end if;

    -- Debe existir un profesional autenticado.
    v_professional_id := private.current_professional_id();

    if v_professional_id is null then
        raise exception 'Only a professional can update an alert';
    end if;

    -- Debe estar asignado al paciente de la alerta.
    if not private.is_assigned_professional(old.patient_id) then
        raise exception 'Professional is not assigned to this patient';
    end if;

    -- Por ahora, el único cambio permitido desde cliente es:
    -- open -> acknowledged
    if old.status = 'open'
       and new.status = 'acknowledged' then

        new.acknowledged_by_professional_id := v_professional_id;
        new.acknowledged_at := now();
        new.closed_at := null;
        new.updated_at := now();

        return new;
    end if;

    raise exception
        'Invalid alert transition from % to %',
        old.status,
        new.status;
end;
$$;


--
-- Name: enforce_clinical_task_professional_update(); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.enforce_clinical_task_professional_update() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
declare
    v_professional_id uuid;
begin
    -- Los procesos servidor/n8n con service_role pueden operar.
    if auth.role() = 'service_role' then
        new.updated_at := now();
        return new;
    end if;

    v_professional_id := private.current_professional_id();

    if v_professional_id is null then
        raise exception 'Only a professional can update a clinical task';
    end if;

    if old.assigned_professional_id is distinct from v_professional_id then
        raise exception 'Clinical task is not assigned to this professional';
    end if;

    if not private.is_assigned_professional(old.patient_id) then
        raise exception 'Professional is not assigned to this patient';
    end if;


    -- -----------------------------------------------------
    -- TRANSICIÓN 1:
    -- pending_review -> in_review
    -- -----------------------------------------------------

    if old.status = 'pending_review'
       and new.status = 'in_review' then

        -- Todavía no debe existir decisión final.
        if new.final_decision is not null then
            raise exception 'Final decision cannot be recorded when starting review';
        end if;

        if new.review_note is not null
           and btrim(new.review_note) <> '' then
            raise exception 'Review note must be recorded when closing the task';
        end if;

        new.first_review_at := coalesce(old.first_review_at, now());
        new.closed_at := null;
        new.final_decision := null;
        new.review_note := null;
        new.updated_at := now();

        return new;
    end if;


    -- -----------------------------------------------------
    -- TRANSICIÓN 2:
    -- in_review -> closed
    -- -----------------------------------------------------

    if old.status = 'in_review'
       and new.status = 'closed' then

        if old.first_review_at is null then
            raise exception 'Task cannot be closed without first_review_at';
        end if;

        if new.final_decision is null
           or new.final_decision not in (
               'approved',
               'modified',
               'cancelled'
           ) then
            raise exception
                'final_decision must be approved, modified or cancelled';
        end if;

        if new.review_note is null
           or btrim(new.review_note) = '' then
            raise exception 'review_note is required to close the task';
        end if;

        new.first_review_at := old.first_review_at;
        new.closed_at := now();
        new.updated_at := now();

        return new;
    end if;


    raise exception
        'Invalid clinical task transition from % to %',
        old.status,
        new.status;
end;
$$;


--
-- Name: is_assigned_professional(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.is_assigned_professional(target_patient_id uuid) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
    select exists (
        select 1
        from public.patient_professionals pp

        join public.professionals pr
          on pr.id = pp.professional_id

        join public.profiles p
          on p.id = pr.profile_id

        where pp.patient_id = target_patient_id

          and pp.ended_at is null

          and pr.status = 'active'

          and p.user_id = (select auth.uid())
    );
$$;


--
-- Name: is_patient_owner(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.is_patient_owner(target_patient_id uuid) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
    select exists (
        select 1
        from public.patients pt
        join public.profiles p
          on p.id = pt.profile_id
        where pt.id = target_patient_id
          and pt.status = 'active'
          and p.user_id = (select auth.uid())
    );
$$;


--
-- Name: is_profile_of_assigned_patient(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.is_profile_of_assigned_patient(target_profile_id uuid) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
    select exists (
        select 1
        from public.patients p
        join public.patient_professionals pp
          on pp.patient_id = p.id
         and pp.ended_at is null
        where p.profile_id = target_profile_id
          and pp.professional_id = private.current_professional_id()
    );
$$;


--
-- Name: my_patient_id(); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.my_patient_id() RETURNS uuid
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
  select p.id from public.patients p join public.profiles pr on pr.id=p.profile_id where pr.user_id=(select auth.uid())
$$;


--
-- Name: my_professional_id(); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.my_professional_id() RETURNS uuid
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
  select p.id from public.professionals p join public.profiles pr on pr.id=p.profile_id where pr.user_id=(select auth.uid())
$$;


--
-- Name: my_profile_id(); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.my_profile_id() RETURNS uuid
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO ''
    AS $$
  select id from public.profiles where user_id = (select auth.uid())
$$;


--
-- Name: preview_patient_invitation(text); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.preview_patient_invitation(invitation_code text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
declare result jsonb;
begin
  if auth.uid() is null or private.my_patient_id() is null then raise exception 'Patient account required'; end if;
  select jsonb_build_object('id',p.id,'name',pr.display_name,'specialty',p.specialty,'institution',p.institution)
    into result from public.patient_invitations i join public.professionals p on p.id=i.professional_id
    join public.profiles pr on pr.id=p.profile_id
    where i.code=upper(regexp_replace(invitation_code,'[^a-zA-Z0-9]','','g')) and i.expires_at>now()
      and i.revoked_at is null and i.accepted_at is null;
  if result is null then raise exception 'INVITATION_UNAVAILABLE'; end if;
  return result;
end $$;


--
-- Name: record_clinical_transition(); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.record_clinical_transition() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
begin
  if auth.uid() is null then return new; end if;
  if tg_table_name='alerts' then
    if old.status <> 'open' or new.status <> 'acknowledged' then raise exception 'Invalid alert transition'; end if;
    new.acknowledged_at:=now(); new.acknowledged_by_professional_id:=private.my_professional_id();
  elsif old.status='pending_review' and new.status='in_review' then
    if new.final_decision is distinct from old.final_decision or new.review_note is distinct from old.review_note then raise exception 'Decision requires review'; end if;
    new.first_review_at:=coalesce(old.first_review_at,now());
  elsif old.status='in_review' and new.status='closed' then
    if new.final_decision is null or length(trim(coalesce(new.review_note,'')))=0 then raise exception 'Decision and note required'; end if;
    new.closed_at:=now();
  else raise exception 'Invalid task transition';
  end if;
  return new;
end $$;


--
-- Name: review_patient_history(uuid, integer, text); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.review_patient_history(target_patient uuid, expected_revision integer, review_note text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
declare professional uuid := private.my_professional_id(); history public.patient_histories;
begin
  if auth.uid() is null or professional is null or not coalesce(private.can_view_patient(target_patient),false) then raise exception 'Not allowed'; end if;
  select * into history from public.patient_histories where patient_id=target_patient for update;
  if history.completed_at is null or history.revision<>expected_revision then raise exception 'HISTORY_CONFLICT'; end if;
  insert into public.patient_history_reviews(patient_id,professional_id,history_revision,note)
    values(target_patient,professional,expected_revision,trim(review_note));
end $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: patient_histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patient_histories (
    patient_id uuid NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    current_step integer DEFAULT 0 NOT NULL,
    revision integer DEFAULT 0 NOT NULL,
    completed_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT patient_histories_current_step_check CHECK (((current_step >= 0) AND (current_step <= 3))),
    CONSTRAINT patient_histories_data_check CHECK ((jsonb_typeof(data) = 'object'::text))
);


--
-- Name: save_patient_history(jsonb, integer, integer, boolean); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.save_patient_history(history_data jsonb, next_step integer, expected_revision integer, complete boolean) RETURNS public.patient_histories
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
declare patient uuid := private.my_patient_id(); saved public.patient_histories; field text; item jsonb;
begin
  if auth.uid() is null or patient is null then raise exception 'Patient account required'; end if;
  if jsonb_typeof(history_data) <> 'object' or octet_length(history_data::text)>50000 then raise exception 'Invalid history'; end if;
  foreach field in array array['birthDate','sex','phone','address','occupation','emergencyContact','diabetesType','diagnosisYear','conditionsStatus','otherConditions','familyHistory','severeLowHistory','treatmentStatus','allergyStatus','allergies','smoking','alcohol','activity','support','notes'] loop
    if history_data ? field and (jsonb_typeof(history_data->field)<>'string' or length(history_data->>field)>2000) then raise exception 'Invalid history field'; end if;
  end loop;
  if history_data ? 'conditions' and jsonb_typeof(history_data->'conditions')<>'array' then raise exception 'Invalid conditions'; end if;
  for item in select value from jsonb_array_elements(coalesce(history_data->'conditions','[]')) loop
    if jsonb_typeof(item)<>'string' then raise exception 'Invalid condition'; end if;
  end loop;
  if history_data ? 'medications' and jsonb_typeof(history_data->'medications')<>'array' then raise exception 'Invalid medications'; end if;
  if jsonb_array_length(coalesce(history_data->'medications','[]'))>20 then raise exception 'Too many medications'; end if;
  for item in select value from jsonb_array_elements(coalesce(history_data->'medications','[]')) loop
    if jsonb_typeof(item)<>'object' or jsonb_typeof(item->'name') is distinct from 'string'
      or jsonb_typeof(item->'dose') is distinct from 'string' or jsonb_typeof(item->'schedule') is distinct from 'string'
      then raise exception 'Invalid medication'; end if;
  end loop;
  if complete and (coalesce(history_data->>'birthDate','')='' or coalesce(history_data->>'sex','')=''
    or coalesce(history_data->>'diabetesType','')='' or coalesce(history_data->>'treatmentStatus','')=''
    or coalesce(history_data->>'allergyStatus','')='' or coalesce(history_data->>'conditionsStatus','')=''
    or coalesce(history_data->>'informationConfirmed','false') <> 'true') then raise exception 'Complete the required sections'; end if;
  if complete and (history_data->>'birthDate')::date > current_date then raise exception 'Invalid birth date'; end if;
  if complete and ((history_data->>'birthDate')::date < date '1900-01-01'
    or history_data->>'sex' not in ('female','male','other')
    or history_data->>'diabetesType' not in ('type_1','type_2','gestational','other','unknown')
    or history_data->>'treatmentStatus' not in ('none','medication','insulin','both','unknown')
    or history_data->>'allergyStatus' not in ('yes','no','unknown')
    or history_data->>'conditionsStatus' not in ('yes','no','unknown')) then raise exception 'Invalid history selection'; end if;
  if complete and history_data->>'allergyStatus'='yes' and length(trim(coalesce(history_data->>'allergies','')))=0 then raise exception 'Describe the allergy'; end if;
  if complete and history_data->>'conditionsStatus'='yes' and jsonb_array_length(coalesce(history_data->'conditions','[]'))=0 then raise exception 'Describe the conditions'; end if;
  if complete and coalesce(history_data->>'diagnosisYear','')<>'' and
    ((history_data->>'diagnosisYear')::int<extract(year from (history_data->>'birthDate')::date) or (history_data->>'diagnosisYear')::int>extract(year from current_date)) then raise exception 'Invalid diagnosis year'; end if;
  update public.patient_histories set data=history_data, current_step=next_step, revision=revision+1,
    completed_at=case when complete then now() else null end, updated_at=now()
    where patient_id=patient and revision=expected_revision returning * into saved;
  if saved.patient_id is null then raise exception 'HISTORY_CONFLICT'; end if;
  insert into public.patient_history_versions(patient_id, revision, data, actor_profile_id)
    values(patient, saved.revision, history_data, private.my_profile_id());
  return saved;
end $$;


--
-- Name: set_glucose_reading_actor(); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.set_glucose_reading_actor() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
declare
    current_profile uuid;
begin

    -- Si existe un usuario Supabase autenticado,
    -- determinamos su identidad automáticamente.
    if (select auth.uid()) is not null then

        select private.current_profile_id()
        into current_profile;

        if current_profile is null then
            raise exception
                'Authenticated user does not have a TrackyGlu profile';
        end if;


        -- Siempre reemplazamos cualquier valor enviado por el cliente.
        new.recorded_by_profile_id := current_profile;


        -- El usuario registra su propia lectura.
        if private.is_patient_owner(new.patient_id) then

            new.recorded_by_actor_type := 'patient';


        -- El profesional registra una lectura
        -- de uno de sus pacientes asignados.
        elsif private.is_assigned_professional(new.patient_id) then

            new.recorded_by_actor_type := 'professional';


        else

            raise exception
                'User is not authorized to register readings for this patient';

        end if;

    end if;

    return new;
end;
$$;


--
-- Name: touch_adherence_summary(); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.touch_adherence_summary() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO ''
    AS $$
begin
  new.updated_at := now();
  return new;
end $$;


--
-- Name: touch_daily_context(); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.touch_daily_context() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO ''
    AS $$
begin
  new.updated_at := now();
  return new;
end $$;


--
-- Name: accept_patient_invitation(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.accept_patient_invitation(invitation_code text) RETURNS uuid
    LANGUAGE sql
    SET search_path TO ''
    AS $$ select private.accept_patient_invitation(invitation_code) $$;


--
-- Name: coach_due_notifications(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.coach_due_notifications() RETURNS TABLE(chat_id text, message_text text, notification_type text, class_id uuid)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
declare
  r record;
  local_now timestamp := now() at time zone 'America/Mexico_City';
  start_local timestamp;
  s public.coach_state;
begin
  for r in
    select c.*,co.telegram_chat_id from public.coach_classes c join public.coaches co on co.id=c.coach_id
    where co.active=true and c.status='scheduled' and c.reminder_sent_at is null
  loop
    start_local:=r.class_date+r.start_time;
    if start_local>local_now and start_local<=local_now+interval '2 hours' then
      update public.coach_classes set reminder_sent_at=now(),updated_at=now() where id=r.id;
      chat_id:=r.telegram_chat_id; class_id:=r.id; notification_type:='pre_class';
      message_text:='⏰ Recordatorio de clase'||E'\n\nHoy '||to_char(r.class_date,'DD/MM')||' a las '||to_char(r.start_time,'HH24:MI')||'.'||E'\n\nAl terminar te preguntaré cuántos riders tuviste y si deseas agregar algún comentario.';
      return next;
    end if;
  end loop;

  for r in
    select c.*,co.telegram_chat_id from public.coach_classes c join public.coaches co on co.id=c.coach_id
    where co.active=true and c.status='scheduled' and c.post_prompt_sent_at is null
    order by c.class_date,c.start_time
  loop
    start_local:=r.class_date+r.start_time;
    if local_now>=start_local+make_interval(mins=>r.duration_minutes) then
      select * into s from public.coach_state where coach_id=r.coach_id for update;
      if s.active_class_id is null and s.state not in ('awaiting_class_result','awaiting_no_class_payment','awaiting_manual_payment','awaiting_class_comment') then
        update public.coach_classes set post_prompt_sent_at=now(),updated_at=now() where id=r.id;
        update public.coach_state set state='awaiting_class_result',active_class_id=r.id,updated_at=now() where coach_id=r.coach_id;
        chat_id:=r.telegram_chat_id; class_id:=r.id; notification_type:='post_class';
        message_text:='🚴 Terminó tu clase de las '||to_char(r.start_time,'HH24:MI')||'.'||E'\n\n¿La impartiste?'||E'\nSi sí, dime también cuántos riders tuviste. Ejemplo: “sí, 7 riders”.'||E'\nSi no se realizó, responde “no la di”.';
        return next;
      end if;
    end if;
  end loop;
end;
$$;


--
-- Name: coach_get_context(text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.coach_get_context(p_chat_id text, p_username text, p_display_name text, p_message_text text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
declare
  v_coach public.coaches;
  v_state public.coach_state;
  v_today date := (now() at time zone 'America/Mexico_City')::date;
begin
  insert into public.coaches(telegram_chat_id,telegram_username,display_name,updated_at)
  values(p_chat_id,p_username,coalesce(nullif(p_display_name,''),'Coach'),now())
  on conflict(telegram_chat_id) do update set
    telegram_username=coalesce(excluded.telegram_username,public.coaches.telegram_username),
    display_name=coalesce(nullif(excluded.display_name,''),public.coaches.display_name),
    updated_at=now()
  returning * into v_coach;

  insert into public.coach_state(coach_id) values(v_coach.id)
  on conflict(coach_id) do nothing;

  select * into v_state from public.coach_state where coach_id=v_coach.id;

  return jsonb_build_object(
    'telegram_chat_id',v_coach.telegram_chat_id,
    'coach_id',v_coach.id,
    'display_name',v_coach.display_name,
    'message_text',p_message_text,
    'state',v_state.state,
    'active_class_id',v_state.active_class_id,
    'target_week_start',v_state.target_week_start,
    'schedule_draft',v_state.schedule_draft,
    'current_schedule_text',public.conecta_schedule_text(v_coach.id,v_today,14)
  );
end;
$$;


--
-- Name: coach_get_note_capture_context(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.coach_get_note_capture_context(p_chat_id text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
declare
  v_coach_id uuid;
  v_active boolean := false;
  v_expires_at timestamptz;
begin
  select id
    into v_coach_id
  from public.coaches
  where telegram_chat_id = p_chat_id;

  if not found then
    return jsonb_build_object(
      'note_capture_active', false,
      'note_capture_expires_at', null
    );
  end if;

  select
    n.is_active
      and n.expires_at is not null
      and n.expires_at > now(),
    n.expires_at
    into
      v_active,
      v_expires_at
  from public.coach_note_capture n
  where n.coach_id = v_coach_id;

  if not found then
    v_active := false;
    v_expires_at := null;
  end if;

  -- Si expiró, cerrarla automáticamente.
  if coalesce(v_active, false) = false then
    update public.coach_note_capture
       set is_active = false,
           updated_at = now()
     where coach_id = v_coach_id
       and is_active = true
       and (expires_at is null or expires_at <= now());
  end if;

  return jsonb_build_object(
    'note_capture_active', coalesce(v_active, false),
    'note_capture_expires_at', v_expires_at
  );
end;
$$;


--
-- Name: coach_get_weekly_notes(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.coach_get_weekly_notes(p_chat_id text, p_week_scope text DEFAULT 'current'::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
declare
  v_coach_id uuid;
  v_today date := (now() at time zone 'America/Mexico_City')::date;
  v_week_start date;
  v_week_end date;
  v_notes text;
  v_total integer := 0;
begin
  select id
    into v_coach_id
  from public.coaches
  where telegram_chat_id = p_chat_id;

  if not found then
    return jsonb_build_object(
      'chat_id', p_chat_id,
      'reply_text', 'No encontré tu perfil.'
    );
  end if;

  v_week_start := public.conecta_monday(v_today);

  if lower(coalesce(p_week_scope, 'current')) = 'previous' then
    v_week_start := v_week_start - 7;
  end if;

  v_week_end := v_week_start + 6;

  select count(*)
    into v_total
  from public.coach_weekly_notes n
  where n.coach_id = v_coach_id
    and n.week_start = v_week_start;

  if v_total = 0 then
    return jsonb_build_object(
      'chat_id', p_chat_id,
      'reply_text',
        '📝 No tienes notas registradas para la semana del ' ||
        to_char(v_week_start, 'DD/MM') || ' al ' ||
        to_char(v_week_end, 'DD/MM') || '.'
    );
  end if;

  with recent_notes as (
    select
      n.note_text,
      n.created_at
    from public.coach_weekly_notes n
    where n.coach_id = v_coach_id
      and n.week_start = v_week_start
    order by n.created_at desc
    limit 40
  )
  select string_agg(
           to_char(r.created_at at time zone 'America/Mexico_City', 'DD/MM HH24:MI')
           || E'\n• '
           || r.note_text,
           E'\n\n'
           order by r.created_at
         )
    into v_notes
  from recent_notes r;

  return jsonb_build_object(
    'chat_id', p_chat_id,
    'reply_text',
      '📝 Notas de la semana · ' ||
      to_char(v_week_start, 'DD/MM') || '–' ||
      to_char(v_week_end, 'DD/MM') ||
      E'\n\n' ||
      coalesce(v_notes, '') ||
      case
        when v_total > 40
          then E'\n\nMostrando las 40 notas más recientes de ' || v_total::text || '.'
        else ''
      end
  );
end;
$$;


--
-- Name: coach_handle_message(text, text, jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.coach_handle_message(p_chat_id text, p_message_text text, p_intent jsonb) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $_$
declare
  v_coach public.coaches;
  v_state public.coach_state;
  v_intent text := coalesce(p_intent->>'intent','unknown');
  v_entries jsonb := coalesce(p_intent->'schedule_entries','[]'::jsonb);
  v_changes jsonb := coalesce(p_intent->'schedule_changes','[]'::jsonb);
  v_result jsonb := coalesce(p_intent->'class_result','{}'::jsonb);
  v_yes boolean := coalesce((p_intent#>>'{reply_signal,yes}')::boolean,false);
  v_no boolean := coalesce((p_intent#>>'{reply_signal,no}')::boolean,false);
  v_finish boolean := coalesce((p_intent->>'schedule_finished')::boolean,false);
  v_confirm boolean := coalesce((p_intent->>'schedule_confirmed')::boolean,false);
  v_today date := (now() at time zone 'America/Mexico_City')::date;
  v_week_start date;
  v_item jsonb;
  v_draft jsonb;
  v_class public.coach_classes;
  v_gave boolean;
  v_riders integer;
  v_paid boolean;
  v_amount numeric;
  v_comment text;
  v_scope text := coalesce(p_intent->>'week_scope','current');
  old_date date; new_date date; old_wd integer; new_wd integer; old_time time; new_time time; note_text text;
  v_rows integer := 0;
  v_affected integer := 0;
  v_requested integer := 0;
begin
  select * into v_coach from public.coaches where telegram_chat_id=p_chat_id;
  if not found then return jsonb_build_object('chat_id',p_chat_id,'reply_text','No encontré tu perfil. Envía nuevamente el mensaje.'); end if;
  select * into v_state from public.coach_state where coach_id=v_coach.id for update;

  if v_intent='show_schedule' then
    return jsonb_build_object('chat_id',p_chat_id,'reply_text','📅 Tu horario próximo:'||E'\n\n'||public.conecta_schedule_text(v_coach.id,v_today,14));
  end if;

  if v_intent='start_schedule' or (v_state.state='awaiting_schedule_offer' and (v_yes or v_intent='affirmative')) then
    v_week_start:=public.conecta_monday(v_today)+7;
    update public.coach_state set state='loading_schedule',target_week_start=v_week_start,schedule_draft='[]'::jsonb,updated_at=now() where coach_id=v_coach.id;
    return jsonb_build_object('chat_id',p_chat_id,'reply_text','Perfecto. Envíame tus clases de la próxima semana. Puedes mandar una o varias juntas.'||E'\n\nEjemplo: “lunes 7 pm, miércoles 8 pm y viernes 6 pm”.'||E'\n\nCuando termines dime “son todas”.');
  end if;

  if v_state.state='awaiting_schedule_offer' and (v_no or v_intent='negative') then
    update public.coach_state set state='idle',updated_at=now() where coach_id=v_coach.id;
    return jsonb_build_object('chat_id',p_chat_id,'reply_text','De acuerdo. Cuando quieras cargarlo, escribe “quiero cargar mi horario”.');
  end if;

  if v_intent='modify_schedule' then
    -- La semana objetivo debe corresponder al horario próximo que se le muestra al coach.
    -- Tomamos la semana de su primera clase programada futura dentro de los próximos 14 días.
    select public.conecta_monday(min(c.class_date))
      into v_week_start
    from public.coach_classes c
    where c.coach_id=v_coach.id
      and c.status='scheduled'
      and c.class_date between v_today and (v_today+14);

    -- Si todavía no hay una clase futura, usamos la semana actual como respaldo.
    v_week_start:=coalesce(v_week_start,public.conecta_monday(v_today));

    update public.coach_state
       set state='modifying_schedule',
           target_week_start=v_week_start,
           updated_at=now()
     where coach_id=v_coach.id;

    return jsonb_build_object(
      'chat_id',p_chat_id,
      'reply_text','Claro. Tu horario próximo:'||E'\n\n'||
        public.conecta_schedule_text(v_coach.id,v_today,14)||
        E'\n\nDime el cambio. Ejemplos:'||
        E'\n• “mueve mi miércoles 19:00 al jueves 20:00”'||
        E'\n• “quita viernes 18:00”'||
        E'\n• “agrega sábado 09:00”'||
        E'\n• “intercambié martes 19:00 con Ana y ahora doy jueves 20:00”.'
    );
  end if;

  if v_state.state='loading_schedule' then
    v_week_start:=coalesce(v_state.target_week_start,public.conecta_monday(v_today)+7);
    v_draft:=coalesce(v_state.schedule_draft,'[]'::jsonb);
    if jsonb_array_length(v_entries)>0 then
      for v_item in select * from jsonb_array_elements(v_entries) loop
        if (v_item->>'weekday') is not null and (v_item->>'time') is not null then
          v_draft:=v_draft||jsonb_build_array(jsonb_build_object('weekday',(v_item->>'weekday')::integer,'time',v_item->>'time'));
        end if;
      end loop;
      update public.coach_state set schedule_draft=v_draft,updated_at=now() where coach_id=v_coach.id;
    end if;
    if v_finish or v_intent='finish_schedule' then
      if jsonb_array_length(v_draft)=0 then return jsonb_build_object('chat_id',p_chat_id,'reply_text','Todavía no tengo ninguna clase capturada.'); end if;
      update public.coach_state set state='awaiting_schedule_confirmation',updated_at=now() where coach_id=v_coach.id;
      return jsonb_build_object('chat_id',p_chat_id,'reply_text','📅 Tengo este horario:'||E'\n\n'||public.conecta_draft_text(v_draft,v_week_start)||E'\n\n¿Lo confirmas? Responde “sí” para programarlo o dime que quieres modificarlo.');
    end if;
    if jsonb_array_length(v_entries)>0 then
      return jsonb_build_object('chat_id',p_chat_id,'reply_text','Anotado ✅'||E'\n\n'||public.conecta_draft_text(v_draft,v_week_start)||E'\n\nPuedes seguir enviando clases. Cuando termines dime “son todas”.');
    end if;
    return jsonb_build_object('chat_id',p_chat_id,'reply_text','No identifiqué un día y hora. Ejemplo: “martes 7 pm”.');
  end if;

  if v_state.state='awaiting_schedule_confirmation' then
    if v_confirm or v_yes or v_intent in ('confirm_schedule','affirmative') then
      v_week_start:=coalesce(v_state.target_week_start,public.conecta_monday(v_today)+7);
      v_draft:=coalesce(v_state.schedule_draft,'[]'::jsonb);
      for v_item in select * from jsonb_array_elements(v_draft) loop
        insert into public.coach_classes(coach_id,class_date,start_time,status)
        values(v_coach.id,v_week_start+((v_item->>'weekday')::integer-1),(v_item->>'time')::time,'scheduled')
        on conflict do nothing;
      end loop;
      update public.coach_state set state='idle',schedule_draft='[]'::jsonb,active_class_id=null,updated_at=now() where coach_id=v_coach.id;
      return jsonb_build_object('chat_id',p_chat_id,'reply_text','Horario programado ✅'||E'\n\n'||public.conecta_schedule_text(v_coach.id,v_week_start,6)||E'\n\nTe recordaré cada clase aproximadamente 2 horas antes y al terminar te pediré el reporte.');
    end if;
    if v_no or v_intent in ('reject_schedule','negative','modify_schedule') then
      update public.coach_state set state='loading_schedule',updated_at=now() where coach_id=v_coach.id;
      return jsonb_build_object('chat_id',p_chat_id,'reply_text','De acuerdo. Sigue enviando el horario correcto. Cuando termines dime “son todas”.');
    end if;
    return jsonb_build_object('chat_id',p_chat_id,'reply_text','Necesito que confirmes el horario. Responde “sí” o indica que quieres modificarlo.');
  end if;

  if v_state.state='modifying_schedule' or v_intent='schedule_change' then
    if jsonb_array_length(v_changes)=0 then
      return jsonb_build_object('chat_id',p_chat_id,'reply_text','No identifiqué el cambio exacto. Ejemplo: “mueve mi miércoles 19:00 al jueves 20:00”.');
    end if;

    -- Si previamente se abrió el flujo de modificación, usamos exactamente la semana
    -- del horario que se mostró al coach. El scope del modelo sólo queda como respaldo.
    v_week_start:=coalesce(
      v_state.target_week_start,
      case when v_scope='next'
        then public.conecta_monday(v_today)+7
        else public.conecta_monday(v_today)
      end
    );

    v_affected:=0;
    v_requested:=jsonb_array_length(v_changes);

    for v_item in select * from jsonb_array_elements(v_changes) loop
      old_wd:=nullif(v_item->>'old_weekday','')::integer;
      new_wd:=nullif(v_item->>'new_weekday','')::integer;
      old_time:=nullif(v_item->>'old_time','')::time;
      new_time:=nullif(v_item->>'new_time','')::time;
      note_text:=concat_ws(
        ' · ',
        nullif(v_item->>'note',''),
        case when nullif(v_item->>'other_coach','') is not null
          then 'Intercambio con '||(v_item->>'other_coach')
        end
      );

      old_date:=case when old_wd is null then null else v_week_start+(old_wd-1) end;
      new_date:=case when new_wd is null then null else v_week_start+(new_wd-1) end;
      v_rows:=0;

      if v_item->>'operation'='remove' and old_date is not null and old_time is not null then
        update public.coach_classes
           set status='cancelled',
               change_note=nullif(note_text,''),
               updated_at=now()
         where coach_id=v_coach.id
           and class_date=old_date
           and start_time=old_time
           and status='scheduled';
        get diagnostics v_rows = row_count;

      elsif v_item->>'operation'='add' and new_date is not null and new_time is not null then
        insert into public.coach_classes(coach_id,class_date,start_time,status,change_note)
        values(v_coach.id,new_date,new_time,'scheduled',nullif(note_text,''))
        on conflict do nothing;
        get diagnostics v_rows = row_count;

      elsif v_item->>'operation'='move'
        and old_date is not null and old_time is not null
        and new_date is not null and new_time is not null then
        update public.coach_classes
           set class_date=new_date,
               start_time=new_time,
               change_note=nullif(note_text,''),
               reminder_sent_at=null,
               post_prompt_sent_at=null,
               updated_at=now()
         where coach_id=v_coach.id
           and class_date=old_date
           and start_time=old_time
           and status='scheduled';
        get diagnostics v_rows = row_count;
      end if;

      v_affected:=v_affected+coalesce(v_rows,0);
    end loop;

    -- Nunca afirmar que se aplicó un cambio si ninguna fila cambió.
    if v_affected=0 then
      update public.coach_state
         set state='modifying_schedule',
             updated_at=now()
       where coach_id=v_coach.id;

      return jsonb_build_object(
        'chat_id',p_chat_id,
        'reply_text','No encontré una clase programada que coincida con ese cambio ⚠️'||
          E'\n\nTu horario próximo sigue siendo:'||E'\n\n'||
          public.conecta_schedule_text(v_coach.id,v_today,14)||
          E'\n\nInténtalo de nuevo indicando día y hora exactamente como aparecen arriba.'
      );
    end if;

    update public.coach_state
       set state='idle',
           updated_at=now()
     where coach_id=v_coach.id;

    return jsonb_build_object(
      'chat_id',p_chat_id,
      'reply_text',
        case when v_affected<v_requested
          then 'Se aplicaron '||v_affected::text||' de '||v_requested::text||' cambios ⚠️'
          else 'Cambio aplicado ✅'
        end||
        E'\n\nTu horario próximo queda:'||E'\n\n'||
        public.conecta_schedule_text(v_coach.id,v_today,14)
    );
  end if;

  if v_state.state='awaiting_class_result' then
    select * into v_class from public.coach_classes where id=v_state.active_class_id for update;
    v_gave:=nullif(v_result->>'gave_class','')::boolean; v_riders:=nullif(v_result->>'riders','')::integer;
    v_paid:=nullif(v_result->>'paid_without_class','')::boolean; v_amount:=nullif(v_result->>'manual_payment_amount','')::numeric;
    v_comment:=nullif(trim(v_result->>'comment'),'');
    if v_gave is true then
      if v_riders is null then return jsonb_build_object('chat_id',p_chat_id,'reply_text','Perfecto. ¿Cuántos riders tuviste?'); end if;
      update public.coach_classes set class_given=true,riders_count=v_riders,payment_amount=public.conecta_payment_for_riders(v_riders),status='completed',updated_at=now() where id=v_class.id;
      if v_comment is not null then
        update public.coach_classes set comment=v_comment,closed_at=now(),updated_at=now() where id=v_class.id;
        update public.coach_state set state='idle',active_class_id=null,updated_at=now() where coach_id=v_coach.id;
        return jsonb_build_object('chat_id',p_chat_id,'reply_text','Registrado ✅ '||v_riders||' riders · Pago $'||public.conecta_payment_for_riders(v_riders)::text||E'\nComentario: '||v_comment);
      end if;
      update public.coach_state set state='awaiting_class_comment',updated_at=now() where coach_id=v_coach.id;
      return jsonb_build_object('chat_id',p_chat_id,'reply_text','Registrado ✅'||E'\nRiders: '||v_riders||E'\nPago de la clase: $'||public.conecta_payment_for_riders(v_riders)::text||E'\n\n¿Quieres agregar algún detalle o comentario de esta clase? Escríbelo o responde “no”.');
    end if;
    if v_gave is false then
      update public.coach_classes set class_given=false,riders_count=0,status='completed',updated_at=now() where id=v_class.id;
      if v_paid is true and v_amount is not null then
        update public.coach_classes set paid_without_class=true,payment_amount=v_amount,updated_at=now() where id=v_class.id;
        update public.coach_state set state='awaiting_class_comment',updated_at=now() where coach_id=v_coach.id;
        return jsonb_build_object('chat_id',p_chat_id,'reply_text','No se impartió, pero quedó pagada por $'||v_amount::text||E'\n\n¿Quieres agregar algún detalle o comentario?');
      end if;
      if v_paid is false then
        update public.coach_classes set paid_without_class=false,payment_amount=0,updated_at=now() where id=v_class.id;
        update public.coach_state set state='awaiting_class_comment',updated_at=now() where coach_id=v_coach.id;
        return jsonb_build_object('chat_id',p_chat_id,'reply_text','Quedó como no impartida y sin pago.'||E'\n\n¿Quieres agregar algún detalle o comentario?');
      end if;
      update public.coach_state set state='awaiting_no_class_payment',updated_at=now() where coach_id=v_coach.id;
      return jsonb_build_object('chat_id',p_chat_id,'reply_text','Entendido. No se impartió la clase.'||E'\n\n¿Te la van a pagar de todos modos?');
    end if;
    return jsonb_build_object('chat_id',p_chat_id,'reply_text','Dime si impartiste la clase y, si sí, cuántos riders tuviste. Ejemplo: “sí, 6 riders” o “no la di”.');
  end if;

  if v_state.state='awaiting_no_class_payment' then
    v_paid:=nullif(v_result->>'paid_without_class','')::boolean; v_amount:=nullif(v_result->>'manual_payment_amount','')::numeric;
    if v_paid is null then if v_yes or v_intent='affirmative' then v_paid:=true; end if; if v_no or v_intent='negative' then v_paid:=false; end if; end if;
    if v_paid is true then
      if v_amount is not null then
        update public.coach_classes set paid_without_class=true,payment_amount=v_amount,updated_at=now() where id=v_state.active_class_id;
        update public.coach_state set state='awaiting_class_comment',updated_at=now() where coach_id=v_coach.id;
        return jsonb_build_object('chat_id',p_chat_id,'reply_text','Pago registrado: $'||v_amount::text||E'\n\n¿Quieres agregar algún detalle o comentario?');
      end if;
      update public.coach_state set state='awaiting_manual_payment',updated_at=now() where coach_id=v_coach.id;
      return jsonb_build_object('chat_id',p_chat_id,'reply_text','Sí se pagará. ¿Con cuánto te van a pagar esa clase? Ejemplo: “150”.');
    end if;
    if v_paid is false then
      update public.coach_classes set paid_without_class=false,payment_amount=0,updated_at=now() where id=v_state.active_class_id;
      update public.coach_state set state='awaiting_class_comment',updated_at=now() where coach_id=v_coach.id;
      return jsonb_build_object('chat_id',p_chat_id,'reply_text','Quedó registrada sin pago.'||E'\n\n¿Quieres agregar algún detalle o comentario?');
    end if;
    return jsonb_build_object('chat_id',p_chat_id,'reply_text','Respóndeme si te van a pagar esa clase: sí o no.');
  end if;

  if v_state.state='awaiting_manual_payment' then
    v_amount:=nullif(v_result->>'manual_payment_amount','')::numeric;
    if v_amount is null and p_message_text ~ '^[[:space:]]*[0-9]+([.][0-9]+)?[[:space:]]*$' then v_amount:=trim(p_message_text)::numeric; end if;
    if v_amount is null then return jsonb_build_object('chat_id',p_chat_id,'reply_text','No identifiqué el monto. Ejemplo: “150”.'); end if;
    update public.coach_classes set paid_without_class=true,payment_amount=v_amount,updated_at=now() where id=v_state.active_class_id;
    update public.coach_state set state='awaiting_class_comment',updated_at=now() where coach_id=v_coach.id;
    return jsonb_build_object('chat_id',p_chat_id,'reply_text','Pago registrado: $'||v_amount::text||E'\n\n¿Quieres agregar algún detalle o comentario?');
  end if;

  if v_state.state='awaiting_class_comment' then
    v_comment:=nullif(trim(v_result->>'comment'),'');
    if v_no or v_intent='negative' or lower(trim(p_message_text)) in ('no','ninguno','ninguna','sin comentario','sin comentarios') then v_comment:=null;
    elsif v_comment is null then v_comment:=nullif(trim(p_message_text),''); end if;
    update public.coach_classes set comment=v_comment,closed_at=now(),updated_at=now() where id=v_state.active_class_id;
    select * into v_class from public.coach_classes where id=v_state.active_class_id;
    update public.coach_state set state='idle',active_class_id=null,updated_at=now() where coach_id=v_coach.id;
    return jsonb_build_object('chat_id',p_chat_id,'reply_text','Clase cerrada ✅'||E'\nRiders: '||coalesce(v_class.riders_count,0)::text||E'\nPago registrado: $'||coalesce(v_class.payment_amount,0)::text||case when v_comment is not null then E'\nComentario: '||v_comment else '' end);
  end if;

  if jsonb_array_length(v_entries)>0 and v_intent='add_schedule' then
    v_week_start:=public.conecta_monday(v_today)+7; v_draft:='[]'::jsonb;
    for v_item in select * from jsonb_array_elements(v_entries) loop
      if (v_item->>'weekday') is not null and (v_item->>'time') is not null then v_draft:=v_draft||jsonb_build_array(jsonb_build_object('weekday',(v_item->>'weekday')::integer,'time',v_item->>'time')); end if;
    end loop;
    update public.coach_state set state='loading_schedule',target_week_start=v_week_start,schedule_draft=v_draft,updated_at=now() where coach_id=v_coach.id;
    return jsonb_build_object('chat_id',p_chat_id,'reply_text','Empecé a cargar tu próxima semana ✅'||E'\n\n'||public.conecta_draft_text(v_draft,v_week_start)||E'\n\nMándame las demás. Cuando termines dime “son todas”.');
  end if;

  if v_intent='help' then
    return jsonb_build_object('chat_id',p_chat_id,'reply_text','Puedes escribir: “quiero cargar mi horario”, “quiero modificar mi horario”, “muéstrame mi horario”, o mandar directamente “lunes 7 pm y miércoles 8 pm”.');
  end if;

  return jsonb_build_object('chat_id',p_chat_id,'reply_text','No identifiqué qué necesitas. Puedes decir “quiero cargar mi horario”, “quiero modificar mi horario” o “muéstrame mi horario”.');
end;
$_$;


--
-- Name: coach_save_weekly_note(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.coach_save_weekly_note(p_chat_id text, p_note_text text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
declare
  v_coach_id uuid;
  v_capture public.coach_note_capture;
  v_today date := (now() at time zone 'America/Mexico_City')::date;
  v_week_start date;
  v_note_id uuid;
begin
  select id
    into v_coach_id
  from public.coaches
  where telegram_chat_id = p_chat_id;

  if not found then
    return jsonb_build_object(
      'chat_id', p_chat_id,
      'reply_text', 'No encontré tu perfil.'
    );
  end if;

  select *
    into v_capture
  from public.coach_note_capture
  where coach_id = v_coach_id
  for update;

  if not found
     or v_capture.is_active is not true
     or v_capture.expires_at is null
     or v_capture.expires_at <= now()
  then
    return jsonb_build_object(
      'chat_id', p_chat_id,
      'reply_text',
        'La captura de nota ya no está activa. Pulsa “Registrar nota” y vuelve a intentarlo.'
    );
  end if;

  if p_note_text is null or btrim(p_note_text) = '' then
    return jsonb_build_object(
      'chat_id', p_chat_id,
      'reply_text',
        'La nota está vacía. Escríbeme el texto que quieres guardar.'
    );
  end if;

  v_week_start := public.conecta_monday(v_today);

  insert into public.coach_weekly_notes(
    coach_id,
    week_start,
    note_text
  )
  values(
    v_coach_id,
    v_week_start,
    p_note_text
  )
  returning id into v_note_id;

  update public.coach_note_capture
     set is_active = false,
         expires_at = null,
         updated_at = now()
   where coach_id = v_coach_id;

  -- IMPORTANTE:
  -- coach_state NO se modifica.

  return jsonb_build_object(
    'chat_id', p_chat_id,
    'note_id', v_note_id,
    'reply_text',
      'Nota guardada ✅' ||
      E'\n\n' ||
      p_note_text
  );
end;
$$;


--
-- Name: coach_start_weekly_note(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.coach_start_weekly_note(p_chat_id text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
declare
  v_coach_id uuid;
begin
  select id
    into v_coach_id
  from public.coaches
  where telegram_chat_id = p_chat_id;

  if not found then
    return jsonb_build_object(
      'chat_id', p_chat_id,
      'reply_text', 'No encontré tu perfil. Envía “Hola” y vuelve a intentarlo.'
    );
  end if;

  insert into public.coach_note_capture(
    coach_id,
    is_active,
    started_at,
    expires_at,
    updated_at
  )
  values(
    v_coach_id,
    true,
    now(),
    now() + interval '15 minutes',
    now()
  )
  on conflict (coach_id)
  do update set
    is_active = true,
    started_at = now(),
    expires_at = now() + interval '15 minutes',
    updated_at = now();

  return jsonb_build_object(
    'chat_id', p_chat_id,
    'reply_text',
      '📝 Escríbeme la nota que quieres guardar.' ||
      E'\n\nLa guardaré tal como la escribas.'
  );
end;
$$;


--
-- Name: coach_weekly_summaries(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.coach_weekly_summaries() RETURNS TABLE(chat_id text, message_text text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $_$
declare
  co record;
  week_start date:=public.conecta_monday((now() at time zone 'America/Mexico_City')::date);
  week_end date:=week_start+6;
  next_week date:=week_start+7;
  details text;
  total_classes integer;
  total_riders integer;
  total_payment numeric;
  pending integer;
  st public.coach_state;
begin
  for co in select * from public.coaches where active=true order by display_name loop
    select
      coalesce(string_agg(
        case extract(isodow from c.class_date)::int when 1 then 'Lunes' when 2 then 'Martes' when 3 then 'Miércoles' when 4 then 'Jueves' when 5 then 'Viernes' when 6 then 'Sábado' when 7 then 'Domingo' end
        ||' '||to_char(c.class_date,'DD/MM')||' '||to_char(c.start_time,'HH24:MI')||' · '||
        case
          when c.closed_at is not null and c.class_given=true then coalesce(c.riders_count,0)::text||' riders · $'||coalesce(c.payment_amount,0)::text
          when c.closed_at is not null and c.class_given=false and c.paid_without_class=true then 'No impartida · PAGADA $'||coalesce(c.payment_amount,0)::text
          when c.closed_at is not null and c.class_given=false then 'No impartida · $0'
          when c.status='cancelled' then 'Cancelada'
          else 'Pendiente'
        end || case when nullif(c.comment,'') is not null then E'\n   ↳ '||c.comment else '' end,
        E'\n' order by c.class_date,c.start_time),'(sin clases registradas)'),
      count(*) filter(where c.closed_at is not null),
      coalesce(sum(c.riders_count) filter(where c.closed_at is not null),0),
      coalesce(sum(c.payment_amount) filter(where c.closed_at is not null),0),
      count(*) filter(where c.closed_at is null and c.status='scheduled')
    into details,total_classes,total_riders,total_payment,pending
    from public.coach_classes c
    where c.coach_id=co.id and c.class_date between week_start and week_end;

    select * into st from public.coach_state where coach_id=co.id for update;
    if st.state not in ('awaiting_class_result','awaiting_no_class_payment','awaiting_manual_payment','awaiting_class_comment') then
      update public.coach_state set state='awaiting_schedule_offer',target_week_start=next_week,schedule_draft='[]'::jsonb,updated_at=now() where coach_id=co.id;
    end if;

    chat_id:=co.telegram_chat_id;
    message_text:='📊 RESUMEN SEMANAL'||E'\n'||to_char(week_start,'DD/MM')||' – '||to_char(week_end,'DD/MM')||E'\n\n'||details||E'\n\n──────────────'||E'\nClases cerradas: '||total_classes::text||E'\nRiders acumulados: '||total_riders::text||E'\nPago acumulado: $'||total_payment::text||case when pending>0 then E'\nPendientes: '||pending::text else '' end||E'\n\n¿Quieres cargar el horario de la próxima semana? Responde “sí” y empezamos.';
    return next;
  end loop;
end;
$_$;


--
-- Name: conecta_draft_text(jsonb, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.conecta_draft_text(p_draft jsonb, p_week_start date) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
  r jsonb;
  out_text text := '';
  wd integer;
  d date;
begin
  if p_draft is null or jsonb_array_length(p_draft)=0 then return '(sin clases capturadas)'; end if;
  for r in select * from jsonb_array_elements(p_draft) loop
    wd := nullif(r->>'weekday','')::integer;
    d := p_week_start + greatest(coalesce(wd,1)-1,0);
    out_text := out_text ||
      case wd when 1 then 'Lunes' when 2 then 'Martes' when 3 then 'Miércoles' when 4 then 'Jueves'
        when 5 then 'Viernes' when 6 then 'Sábado' when 7 then 'Domingo' else 'Día' end
      || ' ' || to_char(d,'DD/MM') || ' · ' || coalesce(r->>'time','--:--') || E'\n';
  end loop;
  return trim(out_text);
end;
$$;


--
-- Name: conecta_monday(date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.conecta_monday(p_date date) RETURNS date
    LANGUAGE sql IMMUTABLE
    AS $$
  select (p_date - (extract(isodow from p_date)::int - 1));
$$;


--
-- Name: conecta_payment_for_riders(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.conecta_payment_for_riders(p_riders integer) RETURNS numeric
    LANGUAGE sql IMMUTABLE
    AS $$
  select case
    when p_riders is null or p_riders <= 0 then 0
    when p_riders = 1 then 100
    when p_riders between 2 and 8 then 150
    else 200
  end;
$$;


--
-- Name: conecta_schedule_text(uuid, date, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.conecta_schedule_text(p_coach_id uuid, p_from date DEFAULT CURRENT_DATE, p_days integer DEFAULT 14) RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select coalesce(
    string_agg(
      case extract(isodow from c.class_date)::int
        when 1 then 'Lunes' when 2 then 'Martes' when 3 then 'Miércoles'
        when 4 then 'Jueves' when 5 then 'Viernes' when 6 then 'Sábado' when 7 then 'Domingo'
      end || ' ' || to_char(c.class_date,'DD/MM') || ' · ' || to_char(c.start_time,'HH24:MI'),
      E'\n' order by c.class_date,c.start_time
    ),
    '(sin clases programadas)'
  )
  from public.coach_classes c
  where c.coach_id=p_coach_id
    and c.class_date between p_from and (p_from+p_days)
    and c.status <> 'cancelled';
$$;


--
-- Name: create_account(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_account(account_role text, account_name text) RETURNS uuid
    LANGUAGE sql
    SET search_path TO ''
    AS $$ select private.create_account(account_role, account_name) $$;


--
-- Name: end_patient_assignment(uuid, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.end_patient_assignment(target_patient uuid, target_professional uuid) RETURNS void
    LANGUAGE sql
    SET search_path TO ''
    AS $$ select private.end_patient_assignment(target_patient, target_professional) $$;


--
-- Name: preview_patient_invitation(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.preview_patient_invitation(invitation_code text) RETURNS jsonb
    LANGUAGE sql
    SET search_path TO ''
    AS $$ select private.preview_patient_invitation(invitation_code) $$;


--
-- Name: review_patient_history(uuid, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.review_patient_history(target_patient uuid, expected_revision integer, review_note text) RETURNS void
    LANGUAGE sql
    SET search_path TO ''
    AS $$ select private.review_patient_history(target_patient, expected_revision, review_note) $$;


--
-- Name: save_patient_history(jsonb, integer, integer, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.save_patient_history(history_data jsonb, next_step integer, expected_revision integer, complete boolean) RETURNS public.patient_histories
    LANGUAGE sql
    SET search_path TO ''
    AS $$ select private.save_patient_history(history_data, next_step, expected_revision, complete) $$;


--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
    -- Regclass of the table e.g. public.notes
    entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

    -- I, U, D, T: insert, update ...
    action realtime.action = (
        case wal ->> 'action'
            when 'I' then 'INSERT'
            when 'U' then 'UPDATE'
            when 'D' then 'DELETE'
            else 'ERROR'
        end
    );

    -- Is row level security enabled for the table
    is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

    subscriptions realtime.subscription[] = array_agg(subs)
        from
            realtime.subscription subs
        where
            subs.entity = entity_
            -- Filter by action early - only get subscriptions interested in this action
            -- action_filter column can be: '*' (all), 'INSERT', 'UPDATE', or 'DELETE'
            and (subs.action_filter = '*' or subs.action_filter = action::text);

    -- Subscription vars
    working_role regrole;
    working_selected_columns text[];
    claimed_role regrole;
    claims jsonb;

    subscription_id uuid;
    subscription_has_access bool;
    visible_to_subscription_ids uuid[] = '{}';

    -- structured info for wal's columns
    columns realtime.wal_column[];
    -- previous identity values for update/delete
    old_columns realtime.wal_column[];

    error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

    -- Primary jsonb output for record
    output jsonb;

    -- Loop record for iterating unique roles (outer loop)
    role_record record;
    -- Loop record for iterating unique selected_columns within a role (inner loop)
    cols_record record;
    -- Subscription ids visible at the role level (before fanning out by selected_columns)
    visible_role_sub_ids uuid[] = '{}';

begin
    perform set_config('role', null, true);

    columns =
        array_agg(
            (
                x->>'name',
                x->>'type',
                x->>'typeoid',
                realtime.cast(
                    (x->'value') #>> '{}',
                    coalesce(
                        (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                        (x->>'type')::regtype
                    )
                ),
                (pks ->> 'name') is not null,
                true
            )::realtime.wal_column
        )
        from
            jsonb_array_elements(wal -> 'columns') x
            left join jsonb_array_elements(wal -> 'pk') pks
                on (x ->> 'name') = (pks ->> 'name');

    old_columns =
        array_agg(
            (
                x->>'name',
                x->>'type',
                x->>'typeoid',
                realtime.cast(
                    (x->'value') #>> '{}',
                    coalesce(
                        (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                        (x->>'type')::regtype
                    )
                ),
                (pks ->> 'name') is not null,
                true
            )::realtime.wal_column
        )
        from
            jsonb_array_elements(wal -> 'identity') x
            left join jsonb_array_elements(wal -> 'pk') pks
                on (x ->> 'name') = (pks ->> 'name');

    for role_record in
        select claims_role
        from (select distinct claims_role from unnest(subscriptions)) t
        order by claims_role::text
    loop
        working_role := role_record.claims_role;

        -- Update `is_selectable` for columns and old_columns (once per role)
        columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(columns) c;

        old_columns =
                array_agg(
                    (
                        c.name,
                        c.type_name,
                        c.type_oid,
                        c.value,
                        c.is_pkey,
                        pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                    )::realtime.wal_column
                )
                from
                    unnest(old_columns) c;

        if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
            -- Fan out 400 error per distinct selected_columns for this role
            for cols_record in
                select selected_columns
                from (select distinct selected_columns from unnest(subscriptions) s where s.claims_role = working_role) t
                order by coalesce(array_to_string(selected_columns, ','), '')
            loop
                working_selected_columns := cols_record.selected_columns;
                return next (
                    jsonb_build_object(
                        'schema', wal ->> 'schema',
                        'table', wal ->> 'table',
                        'type', action
                    ),
                    is_rls_enabled,
                    (select array_agg(s.subscription_id) from unnest(subscriptions) as s where s.claims_role = working_role and (s.selected_columns is not distinct from working_selected_columns)),
                    array['Error 400: Bad Request, no primary key']
                )::realtime.wal_rls;
            end loop;

        -- The claims role does not have SELECT permission to the primary key of entity
        elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
            -- Fan out 401 error per distinct selected_columns for this role
            for cols_record in
                select selected_columns
                from (select distinct selected_columns from unnest(subscriptions) s where s.claims_role = working_role) t
                order by coalesce(array_to_string(selected_columns, ','), '')
            loop
                working_selected_columns := cols_record.selected_columns;
                return next (
                    jsonb_build_object(
                        'schema', wal ->> 'schema',
                        'table', wal ->> 'table',
                        'type', action
                    ),
                    is_rls_enabled,
                    (select array_agg(s.subscription_id) from unnest(subscriptions) as s where s.claims_role = working_role and (s.selected_columns is not distinct from working_selected_columns)),
                    array['Error 401: Unauthorized']
                )::realtime.wal_rls;
            end loop;

        else
            -- Create the prepared statement (once per role)
            if is_rls_enabled and action <> 'DELETE' then
                if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                    deallocate walrus_rls_stmt;
                end if;
                execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
            end if;

            -- Collect all visible subscription IDs for this role (filter check + RLS check)
            visible_role_sub_ids = '{}';

            for subscription_id, claims in (
                    select
                        subs.subscription_id,
                        subs.claims
                    from
                        unnest(subscriptions) subs
                    where
                        subs.entity = entity_
                        and subs.claims_role = working_role
                        and (
                            realtime.is_visible_through_filters(columns, subs.filters)
                            or (
                              action = 'DELETE'
                              and realtime.is_visible_through_filters(old_columns, subs.filters)
                            )
                        )
            ) loop

                if not is_rls_enabled or action = 'DELETE' then
                    visible_role_sub_ids = visible_role_sub_ids || subscription_id;
                else
                    -- Check if RLS allows the role to see the record
                    perform
                        -- Trim leading and trailing quotes from working_role because set_config
                        -- doesn't recognize the role as valid if they are included
                        set_config('role', trim(both '"' from working_role::text), true),
                        set_config('request.jwt.claims', claims::text, true);

                    execute 'execute walrus_rls_stmt' into subscription_has_access;

                    -- Reset the role on every FOR..LOOP batch execution.
                    -- The first batch of 10 rows is pre-fetched using the current connection role (PG internal behaviour)
                    -- then we have to reset it again otherwise it would use the role defined in the `set_config` above
                    -- to fetch the remaining rows when rows>10, which could be a user-defined role that lacks execution grants.
                    -- The flow is:
                    --   1. run batch with conn role
                    --   2. set_config working_role
                    --   3. execute walrus
                    --   4. reset role (revert)
                    --   5. repeat
                    perform set_config('role', null, true);

                    if subscription_has_access then
                        visible_role_sub_ids = visible_role_sub_ids || subscription_id;
                    end if;
                end if;
            end loop;

            perform set_config('role', null, true);

            -- Inner loop: per distinct selected_columns for this role
            for cols_record in
                select selected_columns
                from (select distinct selected_columns from unnest(subscriptions) s where s.claims_role = working_role) t
                order by coalesce(array_to_string(selected_columns, ','), '')
            loop
                working_selected_columns := cols_record.selected_columns;

                output = jsonb_build_object(
                    'schema', wal ->> 'schema',
                    'table', wal ->> 'table',
                    'type', action,
                    'commit_timestamp', to_char(
                        ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                        'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
                    ),
                    'columns', (
                        select
                            jsonb_agg(
                                jsonb_build_object(
                                    'name', pa.attname,
                                    'type', pt.typname
                                )
                                order by pa.attnum asc
                            )
                        from
                            pg_attribute pa
                            join pg_type pt
                                on pa.atttypid = pt.oid
                            left join (
                                select unnest(conkey) as pkey_attnum
                                from pg_constraint
                                where conrelid = entity_ and contype = 'p'
                            ) pk on pk.pkey_attnum = pa.attnum
                        where
                            attrelid = entity_
                            and attnum > 0
                            and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
                            and (working_selected_columns is null or pa.attname = any(working_selected_columns) or pk.pkey_attnum is not null)
                    )
                )
                -- Add "record" key for insert and update
                || case
                    when action in ('INSERT', 'UPDATE') then
                        jsonb_build_object(
                            'record',
                            (
                                select
                                    jsonb_object_agg(
                                        -- if unchanged toast, get column name and value from old record
                                        coalesce((c).name, (oc).name),
                                        case
                                            when (c).name is null then (oc).value
                                            else (c).value
                                        end
                                    )
                                from
                                    unnest(columns) c
                                    full outer join unnest(old_columns) oc
                                        on (c).name = (oc).name
                                where
                                    coalesce((c).is_selectable, (oc).is_selectable)
                                    and (working_selected_columns is null or coalesce((c).name, (oc).name) = any(working_selected_columns) or coalesce((c).is_pkey, (oc).is_pkey))
                                    and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            )
                        )
                    else '{}'::jsonb
                end
                -- Add "old_record" key for update and delete
                || case
                    when action = 'UPDATE' then
                        jsonb_build_object(
                                'old_record',
                                (
                                    select jsonb_object_agg((c).name, (c).value)
                                    from unnest(old_columns) c
                                    where
                                        (c).is_selectable
                                        and (working_selected_columns is null or (c).name = any(working_selected_columns) or (c).is_pkey)
                                        and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                                )
                            )
                    when action = 'DELETE' then
                        jsonb_build_object(
                            'old_record',
                            (
                                select jsonb_object_agg((c).name, (c).value)
                                from unnest(old_columns) c
                                where
                                    (c).is_selectable
                                    and (working_selected_columns is null or (c).name = any(working_selected_columns) or (c).is_pkey)
                                    and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                                    and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                            )
                        )
                    else '{}'::jsonb
                end;

                -- Filter visible_role_sub_ids to those matching the current selected_columns group
                visible_to_subscription_ids = coalesce(
                    (
                        select array_agg(s.subscription_id)
                        from unnest(subscriptions) s
                        where s.claims_role = working_role
                          and (s.selected_columns is not distinct from working_selected_columns)
                          and s.subscription_id = any(visible_role_sub_ids)
                    ),
                    '{}'::uuid[]
                );

                return next (
                    output,
                    is_rls_enabled,
                    visible_to_subscription_ids,
                    case
                        when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                        else '{}'
                    end
                )::realtime.wal_rls;
            end loop;

        end if;
    end loop;

    perform set_config('role', null, true);
end;
$$;


--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
  res jsonb;
begin
  if type_::text = 'bytea' then
    return to_jsonb(val);
  end if;
  execute format('select to_jsonb(%L::'|| type_::text || ')', val) into res;
  return res;
end
$$;


--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
/*
Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
*/
declare
    op_symbol text = (
        case
            when op = 'eq' then '='
            when op = 'neq' then '!='
            when op = 'lt' then '<'
            when op = 'lte' then '<='
            when op = 'gt' then '>'
            when op = 'gte' then '>='
            when op = 'in' then '= any'
            else 'UNKNOWN OP'
        end
    );
    res boolean;
begin
    execute format(
        'select %L::'|| type_::text || ' ' || op_symbol
        || ' ( %L::'
        || (
            case
                when op = 'in' then type_::text || '[]'
                else type_::text end
        )
        || ')', val_1, val_2) into res;
    return res;
end;
$$;


--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text, negate boolean) RETURNS boolean
    LANGUAGE plpgsql STABLE
    AS $$
declare
    op_symbol text;
    res boolean;
begin
    -- IS DISTINCT FROM / IS NOT DISTINCT FROM: infix, both sides typed literals
    if op = 'isdistinct' then
        execute format(
            'select %L::%s %s %L::%s',
            val_1,
            type_::text,
            case when negate then 'IS NOT DISTINCT FROM' else 'IS DISTINCT FROM' end,
            val_2,
            type_::text
        ) into res;
        return res;
    end if;

    -- IS requires a keyword RHS (NULL, TRUE, FALSE, UNKNOWN), not a typed literal
    if op = 'is' then
        if val_2 not in ('null', 'true', 'false', 'unknown') then
            raise exception 'invalid value for is filter: must be null, true, false, or unknown';
        end if;
        execute format(
            'select %L::%s %s %s',
            val_1,
            type_::text,
            case when negate then 'IS NOT' else 'IS' end,
            upper(val_2)
        ) into res;
        return res;
    end if;

    op_symbol = case
        when op = 'eq'    then '='
        when op = 'neq'   then '!='
        when op = 'lt'    then '<'
        when op = 'lte'   then '<='
        when op = 'gt'    then '>'
        when op = 'gte'   then '>='
        when op = 'in'    then '= any'
        when op = 'like'   then 'LIKE'
        when op = 'ilike'  then 'ILIKE'
        when op = 'match'  then '~'
        when op = 'imatch' then '~*'
        else null
    end;

    if op_symbol is null then
        raise exception 'unsupported equality operator: %', op::text;
    end if;

    execute format(
        'select %L::%s %s (%L::%s)',
        val_1,
        type_::text,
        op_symbol,
        val_2,
        case when op = 'in' then type_::text || '[]' else type_::text end
    ) into res;

    return case when negate then not res else res end;
end;
$$;


--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
    select
        filters is null
        or array_length(filters, 1) is null
        or coalesce(
            count(col.name) = count(1)
            and sum(
                realtime.check_equality_op(
                    op:=f.op,
                    type_:=coalesce(col.type_oid::regtype, col.type_name::regtype),
                    val_1:=col.value #>> '{}',
                    val_2:=f.value,
                    negate:=coalesce(f.negate, false)
                )::int
            ) filter (where col.name is not null) = count(col.name),
            false
        )
    from
        unnest(filters) f
        left join unnest(columns) col
            on f.column_name = col.name;
$$;


--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS TABLE(wal jsonb, is_rls_enabled boolean, subscription_ids uuid[], errors text[], slot_changes_count bigint)
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
  WITH pub AS (
    SELECT
      concat_ws(
        ',',
        CASE WHEN bool_or(pubinsert) THEN 'insert' ELSE NULL END,
        CASE WHEN bool_or(pubupdate) THEN 'update' ELSE NULL END,
        CASE WHEN bool_or(pubdelete) THEN 'delete' ELSE NULL END
      ) AS w2j_actions,
      coalesce(
        string_agg(
          realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
          ','
        ) filter (WHERE ppt.tablename IS NOT NULL),
        ''
      ) AS w2j_add_tables
    FROM pg_publication pp
    LEFT JOIN pg_publication_tables ppt ON pp.pubname = ppt.pubname
    WHERE pp.pubname = publication
    GROUP BY pp.pubname
    LIMIT 1
  ),
  -- MATERIALIZED ensures pg_logical_slot_get_changes is called exactly once
  w2j AS MATERIALIZED (
    SELECT x.*, pub.w2j_add_tables
    FROM pub,
         pg_logical_slot_get_changes(
           slot_name, null, max_changes,
           'include-pk', 'true',
           'include-transaction', 'false',
           'include-timestamp', 'true',
           'include-type-oids', 'true',
           'format-version', '2',
           'actions', pub.w2j_actions,
           'add-tables', pub.w2j_add_tables
         ) x
  ),
  slot_count AS (
    SELECT count(*)::bigint AS cnt
    FROM w2j
    WHERE w2j.w2j_add_tables <> ''
  ),
  rls_filtered AS (
    SELECT xyz.wal, xyz.is_rls_enabled, xyz.subscription_ids, xyz.errors
    FROM w2j,
         realtime.apply_rls(
           wal := w2j.data::jsonb,
           max_record_bytes := max_record_bytes
         ) xyz(wal, is_rls_enabled, subscription_ids, errors)
    WHERE w2j.w2j_add_tables <> ''
      AND xyz.subscription_ids[1] IS NOT NULL
  )
  SELECT rf.wal, rf.is_rls_enabled, rf.subscription_ids, rf.errors, sc.cnt
  FROM rls_filtered rf, slot_count sc

  UNION ALL

  SELECT null, null, null, null, sc.cnt
  FROM slot_count sc
  WHERE NOT EXISTS (SELECT 1 FROM rls_filtered)
$$;


--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
  SELECT
    realtime.wal2json_escape_identifier(nsp.nspname::text)
    || '.'
    || realtime.wal2json_escape_identifier(pc.relname::text)
  FROM pg_class pc
  JOIN pg_namespace nsp ON pc.relnamespace = nsp.oid
  WHERE pc.oid = entity
$$;


--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
  final_payload jsonb;
BEGIN
  BEGIN
    generated_id := gen_random_uuid();

    -- Check if payload has an 'id' key, if not, add the generated UUID
    IF payload ? 'id' THEN
      final_payload := payload;
    ELSE
      final_payload := jsonb_set(payload, '{id}', to_jsonb(generated_id));
    END IF;

    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    INSERT INTO realtime.messages (id, payload, event, topic, private, extension)
    VALUES (generated_id, final_payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING 'WarnSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


--
-- Name: send_binary(bytea, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.send_binary(payload bytea, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
BEGIN
  BEGIN
    generated_id := gen_random_uuid();

    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    INSERT INTO realtime.messages (id, binary_payload, event, topic, private, extension)
    VALUES (generated_id, payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING 'WarnSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    col_names text[] = coalesce(
            array_agg(a.attname order by a.attnum),
            '{}'::text[]
        )
        from
            pg_catalog.pg_attribute a
        where
            a.attrelid = new.entity
            and a.attnum > 0
            and not a.attisdropped
            and pg_catalog.has_column_privilege(
                (new.claims ->> 'role'),
                a.attrelid,
                a.attnum,
                'SELECT'
            );
    filter realtime.user_defined_filter;
    col_type regtype;
    in_val jsonb;
    selected_col text;
begin
    for filter in select * from unnest(new.filters) loop
        if not filter.column_name = any(col_names) then
            raise exception 'invalid column for filter %', filter.column_name;
        end if;

        col_type = (
            select atttypid::regtype
            from pg_catalog.pg_attribute
            where attrelid = new.entity
                  and attname = filter.column_name
        );
        if col_type is null then
            raise exception 'failed to lookup type for column %', filter.column_name;
        end if;

        if filter.op = 'in'::realtime.equality_op then
            in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
            if coalesce(jsonb_array_length(in_val), 0) > 100 then
                raise exception 'too many values for `in` filter. Maximum 100';
            end if;
        elsif filter.op = 'is'::realtime.equality_op then
            -- `is` requires a keyword RHS rather than a typed literal
            if filter.value not in ('null', 'true', 'false', 'unknown') then
                raise exception 'invalid value for is filter: must be null, true, false, or unknown';
            end if;
            -- IS NULL works for any type, but IS TRUE/FALSE/UNKNOWN require a boolean
            -- operand. Reject the non-null keywords on non-boolean columns here so they
            -- don't abort apply_rls at WAL time.
            if filter.value <> 'null' and col_type <> 'boolean'::regtype then
                raise exception 'is % filter requires a boolean column, got %', filter.value, col_type::text;
            end if;
        elsif filter.op in ('like'::realtime.equality_op, 'ilike'::realtime.equality_op) then
            -- like/ilike apply the text pattern operator (~~); reject column types that
            -- have no such operator instead of failing at WAL time
            if not exists (
                select 1 from pg_catalog.pg_operator
                where oprname = '~~' and oprleft = col_type
            ) then
                raise exception 'operator % requires a text-compatible column type, got %', filter.op::text, col_type::text;
            end if;
        elsif filter.op in ('match'::realtime.equality_op, 'imatch'::realtime.equality_op) then
            -- match/imatch apply the regex operators ~ / ~*; reject column types that have
            -- no such operator (e.g. integer) instead of failing at WAL time, mirroring the
            -- like/ilike guard above.
            if not exists (
                select 1 from pg_catalog.pg_operator
                where oprname = case when filter.op = 'imatch'::realtime.equality_op then '~*' else '~' end
                  and oprleft = col_type
                  and oprright = col_type
                  and oprresult = 'boolean'::regtype
            ) then
                raise exception 'operator % requires a text-compatible column type, got %', filter.op::text, col_type::text;
            end if;
            -- validate the regex eagerly so a bad pattern is rejected here, not inside
            -- apply_rls where it would abort the WAL stream for the entity
            begin
                perform '' ~ filter.value;
            exception when others then
                raise exception 'invalid regular expression for % filter: %', filter.op::text, sqlerrm;
            end;
        else
            -- eq/neq/lt/lte/gt/gte: value must be coercable to the type
            perform realtime.cast(filter.value, col_type);
        end if;
    end loop;

    if new.selected_columns is not null then
        for selected_col in select * from unnest(new.selected_columns) loop
            if not selected_col = any(col_names) then
                raise exception 'invalid column for select %', selected_col;
            end if;
        end loop;
    end if;

    -- Apply consistent order to filters so the unique constraint can't be tricked by a
    -- different filter order. negate is part of the sort key.
    new.filters = coalesce(
        array_agg(f order by f.column_name, f.op, f.value, f.negate),
        '{}'
    ) from unnest(new.filters) f;

    new.selected_columns = (
        select array_agg(c order by c)
        from unnest(new.selected_columns) c
    );

    return new;
end;
$$;


--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


--
-- Name: wal2json_escape_identifier(text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.wal2json_escape_identifier(name text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
  -- Prefix `\`, `,`, `.`, and any whitespace with `\`
  SELECT regexp_replace(name, '([\\,.[:space:]])', '\\\1', 'g')
$$;


--
-- Name: allow_any_operation(text[]); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.allow_any_operation(expected_operations text[]) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  WITH current_operation AS (
    SELECT storage.operation() AS raw_operation
  ),
  normalized AS (
    SELECT CASE
      WHEN raw_operation LIKE 'storage.%' THEN substr(raw_operation, 9)
      ELSE raw_operation
    END AS current_operation
    FROM current_operation
  )
  SELECT EXISTS (
    SELECT 1
    FROM normalized n
    CROSS JOIN LATERAL unnest(expected_operations) AS expected_operation
    WHERE expected_operation IS NOT NULL
      AND expected_operation <> ''
      AND n.current_operation = CASE
        WHEN expected_operation LIKE 'storage.%' THEN substr(expected_operation, 9)
        ELSE expected_operation
      END
  );
$$;


--
-- Name: allow_only_operation(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.allow_only_operation(expected_operation text) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  WITH current_operation AS (
    SELECT storage.operation() AS raw_operation
  ),
  normalized AS (
    SELECT
      CASE
        WHEN raw_operation LIKE 'storage.%' THEN substr(raw_operation, 9)
        ELSE raw_operation
      END AS current_operation,
      CASE
        WHEN expected_operation LIKE 'storage.%' THEN substr(expected_operation, 9)
        ELSE expected_operation
      END AS requested_operation
    FROM current_operation
  )
  SELECT CASE
    WHEN requested_operation IS NULL OR requested_operation = '' THEN FALSE
    ELSE COALESCE(current_operation = requested_operation, FALSE)
  END
  FROM normalized;
$$;


--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


--
-- Name: enforce_bucket_lifecycle_service_role(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.enforce_bucket_lifecycle_service_role() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog'
    AS $$
BEGIN
  IF current_user::text IS DISTINCT FROM TG_ARGV[0]
     AND (
       OLD.lifecycle_configuration IS DISTINCT FROM NEW.lifecycle_configuration
       OR OLD.lifecycle_configuration_generation IS DISTINCT FROM NEW.lifecycle_configuration_generation
     ) THEN
    -- AFTER runs only after caller RLS has accepted the proposed row. The API
    -- recognizes this specific error after rolling back its permission probe;
    -- direct non-service writes still fail and cannot persist the change.
    RAISE EXCEPTION 'bucket control columns may only be changed by the configured storage service role'
      USING ERRCODE = 'PST01',
            SCHEMA = TG_TABLE_SCHEMA,
            TABLE = TG_TABLE_NAME,
            CONSTRAINT = TG_NAME;
  END IF;

  RETURN NULL;
END;
$$;


--
-- Name: enforce_bucket_name_length(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.enforce_bucket_name_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Get the last path segment (the actual filename)
    SELECT _parts[array_length(_parts, 1)] INTO _filename;
    -- Extract extension: reverse, split on '.', then reverse again
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;


--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    SELECT string_to_array(name, '/') INTO _parts;
    RETURN _parts[array_length(_parts, 1)];
END
$$;


--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;


--
-- Name: get_common_prefix(text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_common_prefix(p_key text, p_prefix text, p_delimiter text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
SELECT CASE
    WHEN position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)) > 0
    THEN left(p_key, length(p_prefix) + position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)))
    ELSE NULL
END;
$$;


--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::bigint)::bigint as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_objects_with_delimiter(_bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;

    -- Configuration
    v_is_asc BOOLEAN;
    v_prefix TEXT;
    v_start TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;

    -- Seek state
    v_next_seek TEXT;
    v_count INT := 0;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;

BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_is_asc := lower(coalesce(sort_order, 'asc')) = 'asc';
    v_prefix := coalesce(prefix_param, '');
    v_start := CASE WHEN coalesce(next_token, '') <> '' THEN next_token ELSE coalesce(start_after, '') END;
    v_file_batch_size := LEAST(GREATEST(max_keys * 2, 100), 1000);

    -- Calculate upper bound for prefix filtering (bytewise, using COLLATE "C")
    IF v_prefix = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix, 1) = delimiter_param THEN
        v_upper_bound := left(v_prefix, -1) || chr(ascii(delimiter_param) + 1);
    ELSE
        v_upper_bound := left(v_prefix, -1) || chr(ascii(right(v_prefix, 1)) + 1);
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" >= $2 ' ||
                'AND o.name COLLATE "C" < $3 ORDER BY o.name COLLATE "C" ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" >= $2 ' ||
                'ORDER BY o.name COLLATE "C" ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" < $2 ' ||
                'AND o.name COLLATE "C" >= $3 ORDER BY o.name COLLATE "C" DESC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" < $2 ' ||
                'ORDER BY o.name COLLATE "C" DESC LIMIT $4';
        END IF;
    END IF;

    -- ========================================================================
    -- SEEK INITIALIZATION: Determine starting position
    -- ========================================================================
    IF v_start = '' THEN
        IF v_is_asc THEN
            v_next_seek := v_prefix;
        ELSE
            -- DESC without cursor: find the last item in range
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_prefix AND o.name COLLATE "C" < v_upper_bound
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix <> '' THEN
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            END IF;

            IF v_next_seek IS NOT NULL THEN
                v_next_seek := v_next_seek || delimiter_param;
            ELSE
                RETURN;
            END IF;
        END IF;
    ELSE
        -- Cursor provided: determine if it refers to a folder or leaf
        IF EXISTS (
            SELECT 1 FROM storage.objects o
            WHERE o.bucket_id = _bucket_id
              AND o.name COLLATE "C" LIKE v_start || delimiter_param || '%'
            LIMIT 1
        ) THEN
            -- Cursor refers to a folder
            IF v_is_asc THEN
                v_next_seek := v_start || chr(ascii(delimiter_param) + 1);
            ELSE
                v_next_seek := v_start || delimiter_param;
            END IF;
        ELSE
            -- Cursor refers to a leaf object
            IF v_is_asc THEN
                v_next_seek := v_start || delimiter_param;
            ELSE
                v_next_seek := v_start;
            END IF;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= max_keys;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        IF v_is_asc THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_next_seek AND o.name COLLATE "C" < v_upper_bound
                ORDER BY o.name COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_next_seek
                ORDER BY o.name COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSE
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix <> '' THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(v_peek_name, v_prefix, delimiter_param);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Emit and skip to next folder (no heap access needed)
            name := rtrim(v_common_prefix, delimiter_param);
            id := NULL;
            updated_at := NULL;
            created_at := NULL;
            last_accessed_at := NULL;
            metadata := NULL;
            RETURN NEXT;
            v_count := v_count + 1;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := left(v_common_prefix, -1) || chr(ascii(delimiter_param) + 1);
            ELSE
                v_next_seek := v_common_prefix;
            END IF;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query USING _bucket_id, v_next_seek,
                CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix) ELSE v_prefix END, v_file_batch_size
            LOOP
                v_common_prefix := storage.get_common_prefix(v_current.name, v_prefix, delimiter_param);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it
                    v_next_seek := v_current.name;
                    EXIT;
                END IF;

                -- Emit file
                name := v_current.name;
                id := v_current.id;
                updated_at := v_current.updated_at;
                created_at := v_current.created_at;
                last_accessed_at := v_current.last_accessed_at;
                metadata := v_current.metadata;
                RETURN NEXT;
                v_count := v_count + 1;

                -- Advance seek past this file
                IF v_is_asc THEN
                    v_next_seek := v_current.name || delimiter_param;
                ELSE
                    v_next_seek := v_current.name;
                END IF;

                EXIT WHEN v_count >= max_keys;
            END LOOP;
        END IF;
    END LOOP;
END;
$_$;


--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


--
-- Name: protect_bucket_control_columns(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.protect_bucket_control_columns() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog'
    AS $$
DECLARE
  configuration_changed boolean;
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.lifecycle_configuration IS NOT NULL
       OR NEW.lifecycle_configuration_generation IS NOT NULL THEN
      IF NOT pg_has_role(current_user, TG_ARGV[0], 'MEMBER') THEN
        RAISE EXCEPTION 'only members of the configured storage service role may insert lifecycle policy state'
          USING ERRCODE = '42501',
                HINT = format(
                  'Insert with both lifecycle columns NULL and configure lifecycle through the Storage API afterward, or insert as a member of %I.',
                  TG_ARGV[0]
                );
      END IF;
    END IF;

    RETURN NEW;
  END IF;

  configuration_changed =
    OLD.lifecycle_configuration IS DISTINCT FROM NEW.lifecycle_configuration
    OR OLD.lifecycle_configuration_generation IS DISTINCT FROM NEW.lifecycle_configuration_generation;

  IF NOT configuration_changed THEN
    RETURN NEW;
  END IF;

  IF NEW.type IS DISTINCT FROM 'STANDARD' THEN
    RAISE EXCEPTION 'bucket versioning and lifecycle controls require a Standard bucket'
      USING ERRCODE = '0A000';
  END IF;

  IF NEW.lifecycle_configuration IS NULL
     AND NEW.lifecycle_configuration_generation IS NULL THEN
    RETURN NEW;
  END IF;

  IF NEW.lifecycle_configuration IS NULL
     OR NEW.lifecycle_configuration_generation IS NULL
     OR OLD.lifecycle_configuration IS NOT DISTINCT FROM NEW.lifecycle_configuration
     OR OLD.lifecycle_configuration_generation IS NOT DISTINCT FROM NEW.lifecycle_configuration_generation THEN
    RAISE EXCEPTION 'a changed lifecycle policy requires a new non-null generation'
      USING ERRCODE = '22023';
  END IF;

  RETURN NEW;
END;
$$;


--
-- Name: protect_delete(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.protect_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if storage.allow_delete_query is set to 'true'
    IF COALESCE(current_setting('storage.allow_delete_query', true), 'false') != 'true' THEN
        RAISE EXCEPTION 'Direct deletion from storage tables is not allowed. Use the Storage API instead.'
            USING HINT = 'This prevents accidental data loss from orphaned objects.',
                  ERRCODE = '42501';
    END IF;
    RETURN NULL;
END;
$$;


--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;
    v_delimiter CONSTANT TEXT := '/';

    -- Configuration
    v_limit INT;
    v_prefix TEXT;
    v_prefix_lower TEXT;
    v_prefix_len INT;
    v_prefix_start INT;
    v_combined_levels INT;
    v_is_asc BOOLEAN;
    v_order_by TEXT;
    v_sort_order TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;

    -- Seek state
    v_next_seek TEXT;
    v_count INT := 0;
    v_skipped INT := 0;
BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_limit := LEAST(coalesce(limits, 100), 1500);
    v_prefix := coalesce(prefix, '') || coalesce(search, '');
    v_prefix_lower := lower(v_prefix);
    v_prefix_len := length(coalesce(prefix, ''));
    v_prefix_start := coalesce(array_length(string_to_array(coalesce(prefix, ''), v_delimiter), 1), 1);
    v_combined_levels := coalesce(array_length(string_to_array(v_prefix, v_delimiter), 1), 1);
    v_is_asc := lower(coalesce(sortorder, 'asc')) = 'asc';
    v_file_batch_size := LEAST(GREATEST(v_limit * 2, 100), 1000);

    -- Validate sort column
    CASE lower(coalesce(sortcolumn, 'name'))
        WHEN 'name' THEN v_order_by := 'name';
        WHEN 'updated_at' THEN v_order_by := 'updated_at';
        WHEN 'created_at' THEN v_order_by := 'created_at';
        WHEN 'last_accessed_at' THEN v_order_by := 'last_accessed_at';
        ELSE v_order_by := 'name';
    END CASE;

    v_sort_order := CASE WHEN v_is_asc THEN 'asc' ELSE 'desc' END;

    -- ========================================================================
    -- NON-NAME SORTING: Use path_tokens approach
    -- ========================================================================
    IF v_order_by != 'name' THEN
        RETURN QUERY EXECUTE format(
            $sql$
            WITH folders AS (
                SELECT array_to_string(path_tokens[$1:$2], '/') AS folder
                FROM storage.objects
                WHERE objects.name ILIKE $3 || '%%'
                  AND bucket_id = $4
                  AND array_length(objects.path_tokens, 1) <> $2
                GROUP BY folder
                ORDER BY folder %s
            )
            (SELECT folder AS "name",
                   NULL::uuid AS id,
                   NULL::timestamptz AS updated_at,
                   NULL::timestamptz AS created_at,
                   NULL::timestamptz AS last_accessed_at,
                   NULL::jsonb AS metadata FROM folders)
            UNION ALL
            (SELECT array_to_string(path_tokens[$1:$2], '/') AS "name",
                   id, updated_at, created_at, last_accessed_at, metadata
             FROM storage.objects
             WHERE objects.name ILIKE $3 || '%%'
               AND bucket_id = $4
               AND array_length(objects.path_tokens, 1) = $2
             ORDER BY %I %s)
            LIMIT $5 OFFSET $6
            $sql$, v_sort_order, v_order_by, v_sort_order
        ) USING v_prefix_start, v_combined_levels, v_prefix, bucketname, v_limit, offsets;
        RETURN;
    END IF;

    -- ========================================================================
    -- NAME SORTING: Hybrid skip-scan with batch optimization
    -- ========================================================================

    -- Calculate upper bound for prefix filtering
    IF v_prefix_lower = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix_lower, 1) = v_delimiter THEN
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(v_delimiter) + 1);
    ELSE
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(right(v_prefix_lower, 1)) + 1);
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" >= $2 ' ||
                'AND lower(o.name) COLLATE "C" < $3 ORDER BY lower(o.name) COLLATE "C" ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" >= $2 ' ||
                'ORDER BY lower(o.name) COLLATE "C" ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 ' ||
                'AND lower(o.name) COLLATE "C" >= $3 ORDER BY lower(o.name) COLLATE "C" DESC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 ' ||
                'ORDER BY lower(o.name) COLLATE "C" DESC LIMIT $4';
        END IF;
    END IF;

    -- Initialize seek position
    IF v_is_asc THEN
        v_next_seek := v_prefix_lower;
    ELSE
        -- DESC: find the last item in range first (static SQL)
        IF v_upper_bound IS NOT NULL THEN
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_prefix_lower AND lower(o.name) COLLATE "C" < v_upper_bound
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        ELSIF v_prefix_lower <> '' THEN
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_prefix_lower
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        ELSE
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        END IF;

        IF v_peek_name IS NOT NULL THEN
            v_next_seek := lower(v_peek_name) || v_delimiter;
        ELSE
            RETURN;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= v_limit;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        IF v_is_asc THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek AND lower(o.name) COLLATE "C" < v_upper_bound
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSE
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix_lower <> '' THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(lower(v_peek_name), v_prefix_lower, v_delimiter);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Handle offset, emit if needed, skip to next folder
            IF v_skipped < offsets THEN
                v_skipped := v_skipped + 1;
            ELSE
                name := substring(rtrim(storage.get_common_prefix(v_peek_name, v_prefix, v_delimiter), v_delimiter) from v_prefix_len + 1);
                id := NULL;
                updated_at := NULL;
                created_at := NULL;
                last_accessed_at := NULL;
                metadata := NULL;
                RETURN NEXT;
                v_count := v_count + 1;
            END IF;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := lower(left(v_common_prefix, -1)) || chr(ascii(v_delimiter) + 1);
            ELSE
                v_next_seek := lower(v_common_prefix);
            END IF;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix_lower is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query
                USING bucketname, v_next_seek,
                    CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix_lower) ELSE v_prefix_lower END, v_file_batch_size
            LOOP
                v_common_prefix := storage.get_common_prefix(lower(v_current.name), v_prefix_lower, v_delimiter);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it
                    v_next_seek := lower(v_current.name);
                    EXIT;
                END IF;

                -- Handle offset skipping
                IF v_skipped < offsets THEN
                    v_skipped := v_skipped + 1;
                ELSE
                    -- Emit file
                    name := substring(v_current.name from v_prefix_len + 1);
                    id := v_current.id;
                    updated_at := v_current.updated_at;
                    created_at := v_current.created_at;
                    last_accessed_at := v_current.last_accessed_at;
                    metadata := v_current.metadata;
                    RETURN NEXT;
                    v_count := v_count + 1;
                END IF;

                -- Advance seek past this file
                IF v_is_asc THEN
                    v_next_seek := lower(v_current.name) || v_delimiter;
                ELSE
                    v_next_seek := lower(v_current.name);
                END IF;

                EXIT WHEN v_count >= v_limit;
            END LOOP;
        END IF;
    END LOOP;
END;
$_$;


--
-- Name: search_by_timestamp(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_by_timestamp(p_prefix text, p_bucket_id text, p_limit integer, p_level integer, p_start_after text, p_sort_order text, p_sort_column text, p_sort_column_after text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_cursor_op text;
    v_query text;
    v_prefix text;
    v_sort_order text;
    v_sort_column text;
BEGIN
    v_prefix := coalesce(p_prefix, '');

    -- Defense-in-depth: this function is independently reachable and must
    -- not trust p_sort_order/p_sort_column to already be validated by a
    -- caller. Normalize to the same strict allow-list storage.search_v2
    -- uses before interpolating anything into dynamic SQL below.
    v_sort_order := lower(coalesce(p_sort_order, 'asc'));
    IF v_sort_order NOT IN ('asc', 'desc') THEN
        v_sort_order := 'asc';
    END IF;

    v_sort_column := lower(coalesce(p_sort_column, 'updated_at'));
    IF v_sort_column NOT IN ('updated_at', 'created_at') THEN
        v_sort_column := 'updated_at';
    END IF;

    IF v_sort_order = 'asc' THEN
        v_cursor_op := '>';
    ELSE
        v_cursor_op := '<';
    END IF;

    v_query := format($sql$
        WITH raw_objects AS (
            SELECT
                o.name AS obj_name,
                o.id AS obj_id,
                o.updated_at AS obj_updated_at,
                o.created_at AS obj_created_at,
                o.last_accessed_at AS obj_last_accessed_at,
                o.metadata AS obj_metadata,
                storage.get_common_prefix(o.name, $1, '/') AS common_prefix
            FROM storage.objects o
            WHERE o.bucket_id = $2
              AND o.name COLLATE "C" LIKE $1 || '%%'
        ),
        -- Aggregate common prefixes (folders)
        -- Both created_at and updated_at use MIN(obj_created_at) to match the old prefixes table behavior
        aggregated_prefixes AS (
            SELECT
                rtrim(common_prefix, '/') AS name,
                NULL::uuid AS id,
                MIN(obj_created_at) AS updated_at,
                MIN(obj_created_at) AS created_at,
                NULL::timestamptz AS last_accessed_at,
                NULL::jsonb AS metadata,
                TRUE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NOT NULL
            GROUP BY common_prefix
        ),
        leaf_objects AS (
            SELECT
                obj_name AS name,
                obj_id AS id,
                obj_updated_at AS updated_at,
                obj_created_at AS created_at,
                obj_last_accessed_at AS last_accessed_at,
                obj_metadata AS metadata,
                FALSE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NULL
        ),
        combined AS (
            SELECT * FROM aggregated_prefixes
            UNION ALL
            SELECT * FROM leaf_objects
        ),
        filtered AS (
            SELECT *
            FROM combined
            WHERE (
                $5 = ''
                OR ROW(
                    date_trunc('milliseconds', %I),
                    name COLLATE "C"
                ) %s ROW(
                    COALESCE(NULLIF($6, '')::timestamptz, 'epoch'::timestamptz),
                    $5
                )
            )
        )
        SELECT
            split_part(name, '/', $3) AS key,
            name,
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
        FROM filtered
        ORDER BY
            COALESCE(date_trunc('milliseconds', %I), 'epoch'::timestamptz) %s,
            name COLLATE "C" %s
        LIMIT $4
    $sql$,
        v_sort_column,
        v_cursor_op,
        v_sort_column,
        v_sort_order,
        v_sort_order
    );

    RETURN QUERY EXECUTE v_query
    USING v_prefix, p_bucket_id, p_level, p_limit, p_start_after, p_sort_column_after;
END;
$_$;


--
-- Name: search_v2(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, sort_column text DEFAULT 'name'::text, sort_column_after text DEFAULT ''::text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_sort_col text;
    v_sort_ord text;
    v_limit int;
BEGIN
    -- Cap limit to maximum of 1500 records
    v_limit := LEAST(coalesce(limits, 100), 1500);

    -- Validate and normalize sort_order
    v_sort_ord := lower(coalesce(sort_order, 'asc'));
    IF v_sort_ord NOT IN ('asc', 'desc') THEN
        v_sort_ord := 'asc';
    END IF;

    -- Validate and normalize sort_column
    v_sort_col := lower(coalesce(sort_column, 'name'));
    IF v_sort_col NOT IN ('name', 'updated_at', 'created_at') THEN
        v_sort_col := 'name';
    END IF;

    -- Route to appropriate implementation
    IF v_sort_col = 'name' THEN
        -- Use list_objects_with_delimiter for name sorting (most efficient: O(k * log n))
        RETURN QUERY
        SELECT
            split_part(l.name, '/', levels) AS key,
            l.name AS name,
            l.id,
            l.updated_at,
            l.created_at,
            l.last_accessed_at,
            l.metadata
        FROM storage.list_objects_with_delimiter(
            bucket_name,
            coalesce(prefix, ''),
            '/',
            v_limit,
            start_after,
            '',
            v_sort_ord
        ) l;
    ELSE
        -- Use aggregation approach for timestamp sorting
        -- Not efficient for large datasets but supports correct pagination
        RETURN QUERY SELECT * FROM storage.search_by_timestamp(
            prefix, bucket_name, v_limit, levels, start_after,
            v_sort_ord, v_sort_col, sort_column_after
        );
    END IF;
END;
$$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


--
-- Name: http_request(); Type: FUNCTION; Schema: supabase_functions; Owner: -
--

CREATE FUNCTION supabase_functions.http_request() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'supabase_functions'
    AS $$
    DECLARE
      request_id bigint;
      payload jsonb;
      url text := TG_ARGV[0]::text;
      method text := TG_ARGV[1]::text;
      headers jsonb DEFAULT '{}'::jsonb;
      params jsonb DEFAULT '{}'::jsonb;
      timeout_ms integer DEFAULT 1000;
    BEGIN
      IF url IS NULL OR url = 'null' THEN
        RAISE EXCEPTION 'url argument is missing';
      END IF;

      IF method IS NULL OR method = 'null' THEN
        RAISE EXCEPTION 'method argument is missing';
      END IF;

      IF TG_ARGV[2] IS NULL OR TG_ARGV[2] = 'null' THEN
        headers = '{"Content-Type": "application/json"}'::jsonb;
      ELSE
        headers = TG_ARGV[2]::jsonb;
      END IF;

      IF TG_ARGV[3] IS NULL OR TG_ARGV[3] = 'null' THEN
        params = '{}'::jsonb;
      ELSE
        params = TG_ARGV[3]::jsonb;
      END IF;

      IF TG_ARGV[4] IS NULL OR TG_ARGV[4] = 'null' THEN
        timeout_ms = 1000;
      ELSE
        timeout_ms = TG_ARGV[4]::integer;
      END IF;

      CASE
        WHEN method = 'GET' THEN
          SELECT http_get INTO request_id FROM net.http_get(
            url,
            params,
            headers,
            timeout_ms
          );
        WHEN method = 'POST' THEN
          payload = jsonb_build_object(
            'old_record', OLD,
            'record', NEW,
            'type', TG_OP,
            'table', TG_TABLE_NAME,
            'schema', TG_TABLE_SCHEMA
          );

          SELECT http_post INTO request_id FROM net.http_post(
            url,
            payload,
            params,
            headers,
            timeout_ms
          );
        ELSE
          RAISE EXCEPTION 'method argument % is invalid', method;
      END CASE;

      INSERT INTO supabase_functions.hooks
        (hook_table_id, hook_name, request_id)
      VALUES
        (TG_RELID, TG_NAME, request_id);

      RETURN NEW;
    END
  $$;


--
-- Name: extensions; Type: TABLE; Schema: _realtime; Owner: -
--

CREATE TABLE _realtime.extensions (
    id uuid NOT NULL,
    type text,
    settings jsonb,
    tenant_external_id text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: feature_flags; Type: TABLE; Schema: _realtime; Owner: -
--

CREATE TABLE _realtime.feature_flags (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    rollout_percentage integer DEFAULT 100 NOT NULL,
    bucket_key character varying(255),
    CONSTRAINT rollout_percentage_must_be_between_0_and_100 CHECK (((rollout_percentage >= 0) AND (rollout_percentage <= 100)))
);


--
-- Name: schema_migrations; Type: TABLE; Schema: _realtime; Owner: -
--

CREATE TABLE _realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: tenants; Type: TABLE; Schema: _realtime; Owner: -
--

CREATE TABLE _realtime.tenants (
    id uuid NOT NULL,
    name text,
    external_id text,
    jwt_secret text,
    max_concurrent_users integer DEFAULT 200 NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    max_events_per_second integer DEFAULT 100 NOT NULL,
    postgres_cdc_default text DEFAULT 'postgres_cdc_rls'::text,
    max_bytes_per_second integer DEFAULT 100000 NOT NULL,
    max_channels_per_client integer DEFAULT 100 NOT NULL,
    max_joins_per_second integer DEFAULT 500 NOT NULL,
    suspend boolean DEFAULT false,
    jwt_jwks jsonb,
    notify_private_alpha boolean DEFAULT false,
    private_only boolean DEFAULT false NOT NULL,
    migrations_ran integer DEFAULT 0,
    broadcast_adapter character varying(255) DEFAULT 'gen_rpc'::character varying,
    max_presence_events_per_second integer DEFAULT 1000,
    max_payload_size_in_kb integer DEFAULT 3000,
    max_client_presence_events_per_window integer,
    client_presence_window_ms integer,
    presence_enabled boolean DEFAULT false NOT NULL,
    feature_flags jsonb DEFAULT '{}'::jsonb NOT NULL,
    gcm_migrated_at timestamp(0) without time zone,
    CONSTRAINT jwt_secret_or_jwt_jwks_required CHECK (((jwt_secret IS NOT NULL) OR (jwt_jwks IS NOT NULL)))
);


--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: custom_oauth_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.custom_oauth_providers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    provider_type text NOT NULL,
    identifier text NOT NULL,
    name text NOT NULL,
    client_id text NOT NULL,
    client_secret text NOT NULL,
    acceptable_client_ids text[] DEFAULT '{}'::text[] NOT NULL,
    scopes text[] DEFAULT '{}'::text[] NOT NULL,
    pkce_enabled boolean DEFAULT true NOT NULL,
    attribute_mapping jsonb DEFAULT '{}'::jsonb NOT NULL,
    authorization_params jsonb DEFAULT '{}'::jsonb NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    email_optional boolean DEFAULT false NOT NULL,
    issuer text,
    discovery_url text,
    skip_nonce_check boolean DEFAULT false NOT NULL,
    cached_discovery jsonb,
    discovery_cached_at timestamp with time zone,
    authorization_url text,
    token_url text,
    userinfo_url text,
    jwks_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    custom_claims_allowlist text[] DEFAULT '{}'::text[] NOT NULL,
    CONSTRAINT custom_oauth_providers_authorization_url_https CHECK (((authorization_url IS NULL) OR (authorization_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_authorization_url_length CHECK (((authorization_url IS NULL) OR (char_length(authorization_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_client_id_length CHECK (((char_length(client_id) >= 1) AND (char_length(client_id) <= 512))),
    CONSTRAINT custom_oauth_providers_discovery_url_length CHECK (((discovery_url IS NULL) OR (char_length(discovery_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_identifier_format CHECK ((identifier ~ '^[a-z0-9][a-z0-9:-]{0,48}[a-z0-9]$'::text)),
    CONSTRAINT custom_oauth_providers_issuer_length CHECK (((issuer IS NULL) OR ((char_length(issuer) >= 1) AND (char_length(issuer) <= 2048)))),
    CONSTRAINT custom_oauth_providers_jwks_uri_https CHECK (((jwks_uri IS NULL) OR (jwks_uri ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_jwks_uri_length CHECK (((jwks_uri IS NULL) OR (char_length(jwks_uri) <= 2048))),
    CONSTRAINT custom_oauth_providers_name_length CHECK (((char_length(name) >= 1) AND (char_length(name) <= 100))),
    CONSTRAINT custom_oauth_providers_oauth2_requires_endpoints CHECK (((provider_type <> 'oauth2'::text) OR ((authorization_url IS NOT NULL) AND (token_url IS NOT NULL) AND (userinfo_url IS NOT NULL)))),
    CONSTRAINT custom_oauth_providers_oidc_discovery_url_https CHECK (((provider_type <> 'oidc'::text) OR (discovery_url IS NULL) OR (discovery_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_issuer_https CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NULL) OR (issuer ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_requires_issuer CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NOT NULL))),
    CONSTRAINT custom_oauth_providers_provider_type_check CHECK ((provider_type = ANY (ARRAY['oauth2'::text, 'oidc'::text]))),
    CONSTRAINT custom_oauth_providers_token_url_https CHECK (((token_url IS NULL) OR (token_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_token_url_length CHECK (((token_url IS NULL) OR (char_length(token_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_userinfo_url_https CHECK (((userinfo_url IS NULL) OR (userinfo_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_userinfo_url_length CHECK (((userinfo_url IS NULL) OR (char_length(userinfo_url) <= 2048)))
);


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text,
    code_challenge_method auth.code_challenge_method,
    code_challenge text,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone,
    invite_token text,
    referrer text,
    oauth_client_state_id uuid,
    linking_target_id uuid,
    email_optional boolean DEFAULT false NOT NULL
);


--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.flow_state IS 'Stores metadata for all OAuth/SSO login flows';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid,
    last_webauthn_challenge_data jsonb
);


--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: COLUMN mfa_factors.last_webauthn_challenge_data; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.mfa_factors.last_webauthn_challenge_data IS 'Stores the latest WebAuthn challenge data including attestation/assertion for customer verification';


--
-- Name: oauth_authorizations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_authorizations (
    id uuid NOT NULL,
    authorization_id text NOT NULL,
    client_id uuid NOT NULL,
    user_id uuid,
    redirect_uri text NOT NULL,
    scope text NOT NULL,
    state text,
    resource text,
    code_challenge text,
    code_challenge_method auth.code_challenge_method,
    response_type auth.oauth_response_type DEFAULT 'code'::auth.oauth_response_type NOT NULL,
    status auth.oauth_authorization_status DEFAULT 'pending'::auth.oauth_authorization_status NOT NULL,
    authorization_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '00:03:00'::interval) NOT NULL,
    approved_at timestamp with time zone,
    nonce text,
    CONSTRAINT oauth_authorizations_authorization_code_length CHECK ((char_length(authorization_code) <= 255)),
    CONSTRAINT oauth_authorizations_code_challenge_length CHECK ((char_length(code_challenge) <= 128)),
    CONSTRAINT oauth_authorizations_expires_at_future CHECK ((expires_at > created_at)),
    CONSTRAINT oauth_authorizations_nonce_length CHECK ((char_length(nonce) <= 255)),
    CONSTRAINT oauth_authorizations_redirect_uri_length CHECK ((char_length(redirect_uri) <= 2048)),
    CONSTRAINT oauth_authorizations_resource_length CHECK ((char_length(resource) <= 2048)),
    CONSTRAINT oauth_authorizations_scope_length CHECK ((char_length(scope) <= 4096)),
    CONSTRAINT oauth_authorizations_state_length CHECK ((char_length(state) <= 4096))
);


--
-- Name: oauth_client_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_client_states (
    id uuid NOT NULL,
    provider_type text NOT NULL,
    code_verifier text,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: TABLE oauth_client_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.oauth_client_states IS 'Stores OAuth states for third-party provider authentication flows where Supabase acts as the OAuth client.';


--
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_secret_hash text,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    client_type auth.oauth_client_type DEFAULT 'confidential'::auth.oauth_client_type NOT NULL,
    token_endpoint_auth_method text NOT NULL,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048)),
    CONSTRAINT oauth_clients_token_endpoint_auth_method_check CHECK ((token_endpoint_auth_method = ANY (ARRAY['client_secret_basic'::text, 'client_secret_post'::text, 'none'::text])))
);


--
-- Name: oauth_consents; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_consents (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    client_id uuid NOT NULL,
    scopes text NOT NULL,
    granted_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_at timestamp with time zone,
    CONSTRAINT oauth_consents_revoked_after_granted CHECK (((revoked_at IS NULL) OR (revoked_at >= granted_at))),
    CONSTRAINT oauth_consents_scopes_length CHECK ((char_length(scopes) <= 2048)),
    CONSTRAINT oauth_consents_scopes_not_empty CHECK ((char_length(TRIM(BOTH FROM scopes)) > 0))
);


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: -
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: -
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text,
    oauth_client_id uuid,
    refresh_token_hmac_key text,
    refresh_token_counter bigint,
    scopes text,
    CONSTRAINT sessions_scopes_length CHECK ((char_length(scopes) <= 4096))
);


--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: COLUMN sessions.refresh_token_hmac_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_hmac_key IS 'Holds a HMAC-SHA256 key used to sign refresh tokens for this session.';


--
-- Name: COLUMN sessions.refresh_token_counter; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_counter IS 'Holds the ID (counter) of the last issued refresh token.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: webauthn_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.webauthn_challenges (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    challenge_type text NOT NULL,
    session_data jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    CONSTRAINT webauthn_challenges_challenge_type_check CHECK ((challenge_type = ANY (ARRAY['signup'::text, 'registration'::text, 'authentication'::text])))
);


--
-- Name: webauthn_credentials; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.webauthn_credentials (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    credential_id bytea NOT NULL,
    public_key bytea NOT NULL,
    attestation_type text DEFAULT ''::text NOT NULL,
    aaguid uuid,
    sign_count bigint DEFAULT 0 NOT NULL,
    transports jsonb DEFAULT '[]'::jsonb NOT NULL,
    backup_eligible boolean DEFAULT false NOT NULL,
    backed_up boolean DEFAULT false NOT NULL,
    friendly_name text DEFAULT ''::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    last_used_at timestamp with time zone
);


--
-- Name: adherence_summary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adherence_summary (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    patient_id uuid NOT NULL,
    window_days integer NOT NULL,
    period_end_date date NOT NULL,
    days_with_reading integer NOT NULL,
    total_readings integer NOT NULL,
    adherence_pct numeric(5,1) NOT NULL,
    readings_per_week numeric(7,2) NOT NULL,
    max_streak_days integer NOT NULL,
    current_streak_days integer NOT NULL,
    max_gap_days integer NOT NULL,
    last_reading_at timestamp with time zone,
    days_since_last_reading integer,
    abandoned_flag boolean DEFAULT false NOT NULL,
    retention_30_flag boolean,
    complete_days integer DEFAULT 0 NOT NULL,
    completeness_pct numeric(5,1) DEFAULT 0 NOT NULL,
    expected_readings integer DEFAULT 0 NOT NULL,
    slot_coverage_pct numeric(5,1) DEFAULT 0 NOT NULL,
    daily_slots jsonb DEFAULT '[]'::jsonb NOT NULL,
    workflow_run_id uuid,
    calculated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT adherence_summary_adherence_pct_check CHECK (((adherence_pct >= (0)::numeric) AND (adherence_pct <= (100)::numeric))),
    CONSTRAINT adherence_summary_check CHECK (((days_with_reading >= 0) AND (days_with_reading <= window_days))),
    CONSTRAINT adherence_summary_check1 CHECK (((max_streak_days >= 0) AND (max_streak_days <= window_days))),
    CONSTRAINT adherence_summary_check2 CHECK (((current_streak_days >= 0) AND (current_streak_days <= window_days))),
    CONSTRAINT adherence_summary_check3 CHECK (((max_gap_days >= 0) AND (max_gap_days <= window_days))),
    CONSTRAINT adherence_summary_check4 CHECK (((complete_days >= 0) AND (complete_days <= window_days))),
    CONSTRAINT adherence_summary_completeness_pct_check CHECK (((completeness_pct >= (0)::numeric) AND (completeness_pct <= (100)::numeric))),
    CONSTRAINT adherence_summary_daily_slots_check CHECK ((jsonb_typeof(daily_slots) = 'array'::text)),
    CONSTRAINT adherence_summary_days_since_last_reading_check CHECK (((days_since_last_reading IS NULL) OR (days_since_last_reading >= 0))),
    CONSTRAINT adherence_summary_expected_readings_check CHECK ((expected_readings >= 0)),
    CONSTRAINT adherence_summary_readings_per_week_check CHECK ((readings_per_week >= (0)::numeric)),
    CONSTRAINT adherence_summary_slot_coverage_pct_check CHECK (((slot_coverage_pct >= (0)::numeric) AND (slot_coverage_pct <= (100)::numeric))),
    CONSTRAINT adherence_summary_total_readings_check CHECK ((total_readings >= 0)),
    CONSTRAINT adherence_summary_window_days_check CHECK ((window_days = ANY (ARRAY[7, 14, 30])))
);


--
-- Name: TABLE adherence_summary; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.adherence_summary IS 'Persisted 7/14/30-day continuity and three-slot completeness summaries.';


--
-- Name: COLUMN adherence_summary.adherence_pct; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.adherence_summary.adherence_pct IS 'Continuity: days_with_reading / window_days * 100.';


--
-- Name: COLUMN adherence_summary.completeness_pct; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.adherence_summary.completeness_pct IS 'Complete days / window_days * 100. A complete day has morning, afternoon and night readings.';


--
-- Name: COLUMN adherence_summary.slot_coverage_pct; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.adherence_summary.slot_coverage_pct IS 'Observed readings / expected readings, capped at 100 percent.';


--
-- Name: alerts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alerts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id uuid DEFAULT gen_random_uuid() NOT NULL,
    patient_id uuid NOT NULL,
    source_reading_id uuid,
    alert_type text NOT NULL,
    severity text NOT NULL,
    status text DEFAULT 'open'::text NOT NULL,
    reason text NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    acknowledged_at timestamp with time zone,
    closed_at timestamp with time zone,
    acknowledged_by_professional_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    source_event_id uuid,
    workflow_run_id uuid,
    CONSTRAINT alerts_severity_check CHECK ((severity = ANY (ARRAY['info'::text, 'warning'::text, 'critical'::text]))),
    CONSTRAINT alerts_status_check CHECK ((status = ANY (ARRAY['open'::text, 'acknowledged'::text, 'closed'::text])))
);


--
-- Name: clinical_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clinical_tasks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id uuid DEFAULT gen_random_uuid() NOT NULL,
    patient_id uuid NOT NULL,
    source_event_id uuid,
    source_alert_id uuid,
    trigger_rule text NOT NULL,
    priority text NOT NULL,
    status text DEFAULT 'pending_review'::text NOT NULL,
    assigned_professional_id uuid,
    first_review_at timestamp with time zone,
    closed_at timestamp with time zone,
    final_decision text,
    review_note text,
    ai_draft_status text DEFAULT 'not_requested'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    workflow_run_id uuid,
    CONSTRAINT clinical_tasks_final_decision_check CHECK ((final_decision = ANY (ARRAY['approved'::text, 'modified'::text, 'cancelled'::text]))),
    CONSTRAINT clinical_tasks_priority_check CHECK ((priority = ANY (ARRAY['info'::text, 'warning'::text, 'critical'::text]))),
    CONSTRAINT clinical_tasks_status_check CHECK ((status = ANY (ARRAY['pending_review'::text, 'draft_ready'::text, 'in_review'::text, 'closed'::text])))
);


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    event_id uuid DEFAULT gen_random_uuid() NOT NULL,
    patient_id uuid NOT NULL,
    event_type text NOT NULL,
    entity_type text NOT NULL,
    entity_id uuid NOT NULL,
    causation_event_id uuid,
    actor_type text NOT NULL,
    actor_profile_id uuid,
    source_channel text DEFAULT 'n8n'::text NOT NULL,
    workflow_run_id uuid,
    previous_state jsonb,
    new_state jsonb,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT events_actor_type_check CHECK ((actor_type = ANY (ARRAY['patient'::text, 'professional'::text, 'device'::text, 'system'::text, 'workflow'::text]))),
    CONSTRAINT events_entity_type_check CHECK (((length(TRIM(BOTH FROM entity_type)) >= 1) AND (length(TRIM(BOTH FROM entity_type)) <= 80))),
    CONSTRAINT events_event_type_check CHECK (((length(TRIM(BOTH FROM event_type)) >= 1) AND (length(TRIM(BOTH FROM event_type)) <= 120))),
    CONSTRAINT events_metadata_check CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT events_new_state_check CHECK (((new_state IS NULL) OR (jsonb_typeof(new_state) = 'object'::text))),
    CONSTRAINT events_previous_state_check CHECK (((previous_state IS NULL) OR (jsonb_typeof(previous_state) = 'object'::text))),
    CONSTRAINT events_source_channel_check CHECK ((source_channel = ANY (ARRAY['web'::text, 'app'::text, 'whatsapp'::text, 'n8n'::text, 'system'::text])))
);


--
-- Name: TABLE events; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.events IS 'Immutable business events emitted by the ingestion, adherence, alert and clinical workflows.';


--
-- Name: glucose_daily_context; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.glucose_daily_context (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    patient_id uuid NOT NULL,
    local_date date NOT NULL,
    treatment_adherence_24h boolean,
    missed_doses_7d text,
    missed_dose_reason text,
    illness_flag boolean,
    stress_flag boolean,
    sleep_quality text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT daily_context_reason_check CHECK (((missed_doses_7d IS NULL) OR (missed_doses_7d = 'none'::text) OR (missed_dose_reason IS NOT NULL))),
    CONSTRAINT glucose_daily_context_missed_dose_reason_check CHECK (((missed_dose_reason IS NULL) OR (missed_dose_reason = ANY (ARRAY['forgetfulness'::text, 'unavailable'::text, 'side_effects'::text, 'cost'::text, 'other'::text])))),
    CONSTRAINT glucose_daily_context_missed_doses_7d_check CHECK (((missed_doses_7d IS NULL) OR (missed_doses_7d = ANY (ARRAY['none'::text, 'one_two'::text, 'three_five'::text, 'more_than_five'::text])))),
    CONSTRAINT glucose_daily_context_sleep_quality_check CHECK (((sleep_quality IS NULL) OR (sleep_quality = ANY (ARRAY['good'::text, 'regular'::text, 'poor'::text, 'unknown'::text]))))
);


--
-- Name: glucose_readings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.glucose_readings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id uuid DEFAULT gen_random_uuid() NOT NULL,
    patient_id uuid NOT NULL,
    glucose_value numeric NOT NULL,
    unit text DEFAULT 'mg/dL'::text NOT NULL,
    measurement_context text NOT NULL,
    measured_at timestamp with time zone NOT NULL,
    source_channel text DEFAULT 'web'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    recorded_by_profile_id uuid DEFAULT private.my_profile_id(),
    recorded_by_actor_type text DEFAULT 'patient'::text,
    measurement_source text DEFAULT 'capillary'::text NOT NULL,
    has_eaten boolean,
    last_meal_at timestamp with time zone,
    meal_type text,
    carbohydrate_estimate smallint,
    treatment_due_before_measurement boolean,
    treatment_taken_as_scheduled boolean,
    recent_physical_activity boolean,
    activity_duration_min smallint,
    activity_intensity text,
    symptoms_present boolean,
    symptoms jsonb DEFAULT '[]'::jsonb NOT NULL,
    illness_flag boolean,
    stress_flag boolean,
    sleep_quality text,
    observation text,
    access_channel text DEFAULT 'direct_url'::text NOT NULL,
    quality_state text DEFAULT 'valid'::text NOT NULL,
    processing_state text DEFAULT 'persisted'::text NOT NULL,
    CONSTRAINT glucose_readings_activity_duration_check CHECK (((activity_duration_min IS NULL) OR ((activity_duration_min >= 1) AND (activity_duration_min <= 720)))),
    CONSTRAINT glucose_readings_activity_intensity_check CHECK (((activity_intensity IS NULL) OR (activity_intensity = ANY (ARRAY['light'::text, 'moderate'::text, 'vigorous'::text])))),
    CONSTRAINT glucose_readings_carbohydrate_check CHECK (((carbohydrate_estimate IS NULL) OR ((carbohydrate_estimate >= 0) AND (carbohydrate_estimate <= 300)))),
    CONSTRAINT glucose_readings_context_source_check CHECK ((measurement_source = ANY (ARRAY['capillary'::text, 'cgm'::text, 'lab'::text, 'other'::text]))),
    CONSTRAINT glucose_readings_glucose_value_check CHECK ((glucose_value > (0)::numeric)),
    CONSTRAINT glucose_readings_meal_before_reading_check CHECK (((last_meal_at IS NULL) OR (last_meal_at <= measured_at))),
    CONSTRAINT glucose_readings_meal_type_check CHECK (((meal_type IS NULL) OR (meal_type = ANY (ARRAY['breakfast'::text, 'lunch'::text, 'dinner'::text, 'snack'::text, 'other'::text])))),
    CONSTRAINT glucose_readings_measurement_context_check CHECK ((measurement_context = ANY (ARRAY['fasting_morning'::text, 'pre_meal'::text, 'post_meal_1h'::text, 'post_meal_2h'::text, 'post_meal_3h_plus'::text, 'bedtime'::text, 'random'::text, 'other'::text]))),
    CONSTRAINT glucose_readings_observation_length_check CHECK (((observation IS NULL) OR (length(observation) <= 2000))),
    CONSTRAINT glucose_readings_processing_check CHECK ((processing_state = ANY (ARRAY['persisted'::text, 'skipped_duplicate'::text, 'failed'::text, 'filtered'::text]))),
    CONSTRAINT glucose_readings_quality_check CHECK ((quality_state = ANY (ARRAY['valid'::text, 'invalid'::text, 'na'::text]))),
    CONSTRAINT glucose_readings_sleep_quality_check CHECK (((sleep_quality IS NULL) OR (sleep_quality = ANY (ARRAY['good'::text, 'regular'::text, 'poor'::text, 'unknown'::text])))),
    CONSTRAINT glucose_readings_source_channel_check CHECK ((source_channel = ANY (ARRAY['web'::text, 'app'::text, 'whatsapp'::text]))),
    CONSTRAINT glucose_readings_symptoms_check CHECK ((jsonb_typeof(symptoms) = 'array'::text)),
    CONSTRAINT glucose_readings_unit_check CHECK ((unit = 'mg/dL'::text))
);


--
-- Name: COLUMN glucose_readings.event_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.glucose_readings.event_id IS 'Stable event reference for traceability and duplicate detection.';


--
-- Name: COLUMN glucose_readings.measurement_context; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.glucose_readings.measurement_context IS 'Patient-confirmed physiological context used to stratify readings; it is not a diagnosis.';


--
-- Name: COLUMN glucose_readings.measured_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.glucose_readings.measured_at IS 'The actual date and time when the patient took the measurement.';


--
-- Name: COLUMN glucose_readings.source_channel; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.glucose_readings.source_channel IS 'The channel through which the reading entered the system.';


--
-- Name: COLUMN glucose_readings.has_eaten; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.glucose_readings.has_eaten IS 'Optional patient-reported food status captured only when the daily context is ambiguous.';


--
-- Name: COLUMN glucose_readings.treatment_taken_as_scheduled; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.glucose_readings.treatment_taken_as_scheduled IS 'Optional patient report. TrackyGlu does not infer or change a treatment plan.';


--
-- Name: COLUMN glucose_readings.quality_state; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.glucose_readings.quality_state IS 'Technical quality gate for future workflow calculations. Objective 2 writes valid for accepted web readings.';


--
-- Name: patient_history_reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patient_history_reviews (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    patient_id uuid NOT NULL,
    professional_id uuid NOT NULL,
    history_revision integer NOT NULL,
    note text NOT NULL,
    reviewed_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT patient_history_reviews_note_check CHECK (((length(TRIM(BOTH FROM note)) >= 1) AND (length(TRIM(BOTH FROM note)) <= 4000)))
);


--
-- Name: patient_history_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patient_history_versions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    patient_id uuid NOT NULL,
    revision integer NOT NULL,
    data jsonb NOT NULL,
    actor_profile_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: patient_invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patient_invitations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    professional_id uuid NOT NULL,
    code text DEFAULT upper(replace((gen_random_uuid())::text, '-'::text, ''::text)) NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '7 days'::interval) NOT NULL,
    accepted_by uuid,
    accepted_at timestamp with time zone,
    revoked_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: patients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patients (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    profile_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: professional_patients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.professional_patients (
    professional_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    active boolean DEFAULT true NOT NULL,
    linked_at timestamp with time zone DEFAULT now() NOT NULL,
    ended_at timestamp with time zone
);


--
-- Name: professionals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.professionals (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    profile_id uuid NOT NULL,
    specialty text DEFAULT ''::text NOT NULL,
    license_number text DEFAULT ''::text NOT NULL,
    institution text DEFAULT ''::text NOT NULL,
    phone text DEFAULT ''::text NOT NULL,
    completed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT professional_completion CHECK (((completed_at IS NULL) OR ((length(TRIM(BOTH FROM specialty)) > 0) AND (length(TRIM(BOTH FROM license_number)) > 0) AND (length(TRIM(BOTH FROM institution)) > 0))))
);


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profiles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    role text NOT NULL,
    display_name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT profiles_display_name_check CHECK (((char_length(TRIM(BOTH FROM display_name)) >= 2) AND (char_length(TRIM(BOTH FROM display_name)) <= 120))),
    CONSTRAINT profiles_role_check CHECK ((role = ANY (ARRAY['patient'::text, 'professional'::text, 'admin'::text])))
);


--
-- Name: workflow_runs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workflow_runs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    workflow_key text NOT NULL,
    workflow_name text NOT NULL,
    workflow_version text NOT NULL,
    n8n_execution_id text,
    status text DEFAULT 'running'::text NOT NULL,
    trigger_event_id uuid,
    input_payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    output_payload jsonb,
    error_message text,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    finished_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT workflow_run_finished_state_check CHECK ((((status = 'running'::text) AND (finished_at IS NULL)) OR ((status = ANY (ARRAY['succeeded'::text, 'failed'::text])) AND (finished_at IS NOT NULL)))),
    CONSTRAINT workflow_runs_input_payload_check CHECK ((jsonb_typeof(input_payload) = 'object'::text)),
    CONSTRAINT workflow_runs_output_payload_check CHECK (((output_payload IS NULL) OR (jsonb_typeof(output_payload) = 'object'::text))),
    CONSTRAINT workflow_runs_status_check CHECK ((status = ANY (ARRAY['running'::text, 'succeeded'::text, 'failed'::text]))),
    CONSTRAINT workflow_runs_workflow_key_check CHECK (((length(TRIM(BOTH FROM workflow_key)) >= 1) AND (length(TRIM(BOTH FROM workflow_key)) <= 160))),
    CONSTRAINT workflow_runs_workflow_name_check CHECK (((length(TRIM(BOTH FROM workflow_name)) >= 1) AND (length(TRIM(BOTH FROM workflow_name)) <= 200))),
    CONSTRAINT workflow_runs_workflow_version_check CHECK (((length(TRIM(BOTH FROM workflow_version)) >= 1) AND (length(TRIM(BOTH FROM workflow_version)) <= 40)))
);


--
-- Name: TABLE workflow_runs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.workflow_runs IS 'Execution provenance for n8n workflows. Internal operational data; service_role only.';


--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea,
    skip_broadcast boolean DEFAULT false NOT NULL
)
PARTITION BY RANGE (inserted_at);


--
-- Name: messages_2026_09_12; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2026_09_12 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea,
    skip_broadcast boolean DEFAULT false NOT NULL,
    CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL)))
);


--
-- Name: messages_2026_09_13; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2026_09_13 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea,
    skip_broadcast boolean DEFAULT false NOT NULL,
    CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL)))
);


--
-- Name: messages_2026_09_14; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2026_09_14 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea,
    skip_broadcast boolean DEFAULT false NOT NULL,
    CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL)))
);


--
-- Name: messages_2026_09_15; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2026_09_15 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea,
    skip_broadcast boolean DEFAULT false NOT NULL,
    CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL)))
);


--
-- Name: messages_2026_09_16; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2026_09_16 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea,
    skip_broadcast boolean DEFAULT false NOT NULL,
    CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL)))
);


--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone DEFAULT now()
);


--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    action_filter text DEFAULT '*'::text,
    selected_columns text[],
    CONSTRAINT subscription_action_filter_check CHECK ((action_filter = ANY (ARRAY['*'::text, 'INSERT'::text, 'UPDATE'::text, 'DELETE'::text])))
);


--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: -
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text,
    type storage.buckettype DEFAULT 'STANDARD'::storage.buckettype NOT NULL,
    versioning_status text DEFAULT 'DISABLED'::text NOT NULL,
    lifecycle_configuration jsonb,
    lifecycle_configuration_generation uuid,
    CONSTRAINT buckets_lifecycle_configuration_pair_check CHECK (((lifecycle_configuration IS NULL) = (lifecycle_configuration_generation IS NULL))),
    CONSTRAINT buckets_lifecycle_configuration_shape_check CHECK (((lifecycle_configuration IS NULL) OR ((jsonb_typeof(lifecycle_configuration) = 'object'::text) AND (lifecycle_configuration ? 'rules'::text) AND
CASE
    WHEN (jsonb_typeof((lifecycle_configuration -> 'rules'::text)) = 'array'::text) THEN ((jsonb_array_length((lifecycle_configuration -> 'rules'::text)) >= 1) AND (jsonb_array_length((lifecycle_configuration -> 'rules'::text)) <= 1000))
    ELSE false
END))),
    CONSTRAINT buckets_lifecycle_configuration_standard_only_check CHECK (((type = 'STANDARD'::storage.buckettype) OR ((lifecycle_configuration IS NULL) AND (lifecycle_configuration_generation IS NULL)))),
    CONSTRAINT buckets_versioning_dark_check CHECK ((versioning_status = 'DISABLED'::text)),
    CONSTRAINT buckets_versioning_standard_only_check CHECK (((type = 'STANDARD'::storage.buckettype) OR (versioning_status = 'DISABLED'::text))),
    CONSTRAINT buckets_versioning_status_check CHECK ((versioning_status = ANY (ARRAY['DISABLED'::text, 'ENABLED'::text, 'SUSPENDED'::text])))
);


--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: buckets_analytics; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_analytics (
    name text NOT NULL,
    type storage.buckettype DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL,
    format text DEFAULT 'ICEBERG'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: buckets_vectors; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_vectors (
    id text NOT NULL,
    type storage.buckettype DEFAULT 'VECTOR'::storage.buckettype NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: iceberg_namespaces; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.iceberg_namespaces (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_name text NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    catalog_id uuid NOT NULL
);


--
-- Name: iceberg_tables; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.iceberg_tables (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    namespace_id uuid NOT NULL,
    bucket_name text NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    location text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    remote_table_id text,
    shard_key text,
    shard_id text,
    catalog_id uuid NOT NULL
);


--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: objects; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb,
    archived_at timestamp with time zone,
    is_delete_marker boolean DEFAULT false NOT NULL,
    is_versioned boolean DEFAULT false NOT NULL
);


--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb,
    metadata jsonb
);


--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: vector_indexes; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.vector_indexes (
    id text DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    bucket_id text NOT NULL,
    data_type text NOT NULL,
    dimension integer NOT NULL,
    distance_metric text NOT NULL,
    metadata_configuration jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: hooks; Type: TABLE; Schema: supabase_functions; Owner: -
--

CREATE TABLE supabase_functions.hooks (
    id bigint NOT NULL,
    hook_table_id integer NOT NULL,
    hook_name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    request_id bigint
);


--
-- Name: TABLE hooks; Type: COMMENT; Schema: supabase_functions; Owner: -
--

COMMENT ON TABLE supabase_functions.hooks IS 'Supabase Functions Hooks: Audit trail for triggered hooks.';


--
-- Name: hooks_id_seq; Type: SEQUENCE; Schema: supabase_functions; Owner: -
--

CREATE SEQUENCE supabase_functions.hooks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hooks_id_seq; Type: SEQUENCE OWNED BY; Schema: supabase_functions; Owner: -
--

ALTER SEQUENCE supabase_functions.hooks_id_seq OWNED BY supabase_functions.hooks.id;


--
-- Name: migrations; Type: TABLE; Schema: supabase_functions; Owner: -
--

CREATE TABLE supabase_functions.migrations (
    version text NOT NULL,
    inserted_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: messages_2026_09_12; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_09_12 FOR VALUES FROM ('2026-09-12 00:00:00') TO ('2026-09-13 00:00:00');


--
-- Name: messages_2026_09_13; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_09_13 FOR VALUES FROM ('2026-09-13 00:00:00') TO ('2026-09-14 00:00:00');


--
-- Name: messages_2026_09_14; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_09_14 FOR VALUES FROM ('2026-09-14 00:00:00') TO ('2026-09-15 00:00:00');


--
-- Name: messages_2026_09_15; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_09_15 FOR VALUES FROM ('2026-09-15 00:00:00') TO ('2026-09-16 00:00:00');


--
-- Name: messages_2026_09_16; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_09_16 FOR VALUES FROM ('2026-09-16 00:00:00') TO ('2026-09-17 00:00:00');


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Name: hooks id; Type: DEFAULT; Schema: supabase_functions; Owner: -
--

ALTER TABLE ONLY supabase_functions.hooks ALTER COLUMN id SET DEFAULT nextval('supabase_functions.hooks_id_seq'::regclass);


--
-- Name: extensions extensions_pkey; Type: CONSTRAINT; Schema: _realtime; Owner: -
--

ALTER TABLE ONLY _realtime.extensions
    ADD CONSTRAINT extensions_pkey PRIMARY KEY (id);


--
-- Name: feature_flags feature_flags_pkey; Type: CONSTRAINT; Schema: _realtime; Owner: -
--

ALTER TABLE ONLY _realtime.feature_flags
    ADD CONSTRAINT feature_flags_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: _realtime; Owner: -
--

ALTER TABLE ONLY _realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: _realtime; Owner: -
--

ALTER TABLE ONLY _realtime.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: custom_oauth_providers custom_oauth_providers_identifier_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_identifier_key UNIQUE (identifier);


--
-- Name: custom_oauth_providers custom_oauth_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_code_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_code_key UNIQUE (authorization_code);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_id_key UNIQUE (authorization_id);


--
-- Name: oauth_authorizations oauth_authorizations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_pkey PRIMARY KEY (id);


--
-- Name: oauth_client_states oauth_client_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_client_states
    ADD CONSTRAINT oauth_client_states_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_user_client_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_client_unique UNIQUE (user_id, client_id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: webauthn_challenges webauthn_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_challenges
    ADD CONSTRAINT webauthn_challenges_pkey PRIMARY KEY (id);


--
-- Name: webauthn_credentials webauthn_credentials_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_pkey PRIMARY KEY (id);


--
-- Name: adherence_summary adherence_summary_patient_id_window_days_period_end_date_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adherence_summary
    ADD CONSTRAINT adherence_summary_patient_id_window_days_period_end_date_key UNIQUE (patient_id, window_days, period_end_date);


--
-- Name: adherence_summary adherence_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adherence_summary
    ADD CONSTRAINT adherence_summary_pkey PRIMARY KEY (id);


--
-- Name: alerts alerts_event_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT alerts_event_id_key UNIQUE (event_id);


--
-- Name: alerts alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT alerts_pkey PRIMARY KEY (id);


--
-- Name: clinical_tasks clinical_tasks_event_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clinical_tasks
    ADD CONSTRAINT clinical_tasks_event_id_key UNIQUE (event_id);


--
-- Name: clinical_tasks clinical_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clinical_tasks
    ADD CONSTRAINT clinical_tasks_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (event_id);


--
-- Name: glucose_daily_context glucose_daily_context_patient_id_local_date_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.glucose_daily_context
    ADD CONSTRAINT glucose_daily_context_patient_id_local_date_key UNIQUE (patient_id, local_date);


--
-- Name: glucose_daily_context glucose_daily_context_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.glucose_daily_context
    ADD CONSTRAINT glucose_daily_context_pkey PRIMARY KEY (id);


--
-- Name: glucose_readings glucose_readings_event_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.glucose_readings
    ADD CONSTRAINT glucose_readings_event_id_key UNIQUE (event_id);


--
-- Name: glucose_readings glucose_readings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.glucose_readings
    ADD CONSTRAINT glucose_readings_pkey PRIMARY KEY (id);


--
-- Name: patient_histories patient_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_histories
    ADD CONSTRAINT patient_histories_pkey PRIMARY KEY (patient_id);


--
-- Name: patient_history_reviews patient_history_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_history_reviews
    ADD CONSTRAINT patient_history_reviews_pkey PRIMARY KEY (id);


--
-- Name: patient_history_versions patient_history_versions_patient_id_revision_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_history_versions
    ADD CONSTRAINT patient_history_versions_patient_id_revision_key UNIQUE (patient_id, revision);


--
-- Name: patient_history_versions patient_history_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_history_versions
    ADD CONSTRAINT patient_history_versions_pkey PRIMARY KEY (id);


--
-- Name: patient_invitations patient_invitations_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_invitations
    ADD CONSTRAINT patient_invitations_code_key UNIQUE (code);


--
-- Name: patient_invitations patient_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_invitations
    ADD CONSTRAINT patient_invitations_pkey PRIMARY KEY (id);


--
-- Name: patients patients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_pkey PRIMARY KEY (id);


--
-- Name: patients patients_profile_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_profile_id_key UNIQUE (profile_id);


--
-- Name: professional_patients professional_patients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.professional_patients
    ADD CONSTRAINT professional_patients_pkey PRIMARY KEY (professional_id, patient_id);


--
-- Name: professionals professionals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.professionals
    ADD CONSTRAINT professionals_pkey PRIMARY KEY (id);


--
-- Name: professionals professionals_profile_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.professionals
    ADD CONSTRAINT professionals_profile_id_key UNIQUE (profile_id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_user_id_key UNIQUE (user_id);


--
-- Name: workflow_runs workflow_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_runs
    ADD CONSTRAINT workflow_runs_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_09_12 messages_2026_09_12_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2026_09_12
    ADD CONSTRAINT messages_2026_09_12_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_09_13 messages_2026_09_13_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2026_09_13
    ADD CONSTRAINT messages_2026_09_13_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_09_14 messages_2026_09_14_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2026_09_14
    ADD CONSTRAINT messages_2026_09_14_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_09_15 messages_2026_09_15_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2026_09_15
    ADD CONSTRAINT messages_2026_09_15_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_09_16 messages_2026_09_16_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2026_09_16
    ADD CONSTRAINT messages_2026_09_16_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages messages_payload_exclusive; Type: CHECK CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE realtime.messages
    ADD CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL))) NOT VALID;


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_analytics
    ADD CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: buckets_vectors buckets_vectors_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_vectors
    ADD CONSTRAINT buckets_vectors_pkey PRIMARY KEY (id);


--
-- Name: iceberg_namespaces iceberg_namespaces_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.iceberg_namespaces
    ADD CONSTRAINT iceberg_namespaces_pkey PRIMARY KEY (id);


--
-- Name: iceberg_tables iceberg_tables_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.iceberg_tables
    ADD CONSTRAINT iceberg_tables_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: vector_indexes vector_indexes_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_pkey PRIMARY KEY (id);


--
-- Name: hooks hooks_pkey; Type: CONSTRAINT; Schema: supabase_functions; Owner: -
--

ALTER TABLE ONLY supabase_functions.hooks
    ADD CONSTRAINT hooks_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: supabase_functions; Owner: -
--

ALTER TABLE ONLY supabase_functions.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (version);


--
-- Name: extensions_tenant_external_id_index; Type: INDEX; Schema: _realtime; Owner: -
--

CREATE INDEX extensions_tenant_external_id_index ON _realtime.extensions USING btree (tenant_external_id);


--
-- Name: extensions_tenant_external_id_type_index; Type: INDEX; Schema: _realtime; Owner: -
--

CREATE UNIQUE INDEX extensions_tenant_external_id_type_index ON _realtime.extensions USING btree (tenant_external_id, type);


--
-- Name: feature_flags_name_index; Type: INDEX; Schema: _realtime; Owner: -
--

CREATE UNIQUE INDEX feature_flags_name_index ON _realtime.feature_flags USING btree (name);


--
-- Name: tenants_external_id_index; Type: INDEX; Schema: _realtime; Owner: -
--

CREATE UNIQUE INDEX tenants_external_id_index ON _realtime.tenants USING btree (external_id);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: custom_oauth_providers_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_created_at_idx ON auth.custom_oauth_providers USING btree (created_at);


--
-- Name: custom_oauth_providers_enabled_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_enabled_idx ON auth.custom_oauth_providers USING btree (enabled);


--
-- Name: custom_oauth_providers_identifier_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_identifier_idx ON auth.custom_oauth_providers USING btree (identifier);


--
-- Name: custom_oauth_providers_provider_type_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_provider_type_idx ON auth.custom_oauth_providers USING btree (provider_type);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_oauth_client_states_created_at; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_oauth_client_states_created_at ON auth.oauth_client_states USING btree (created_at);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: oauth_auth_pending_exp_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_auth_pending_exp_idx ON auth.oauth_authorizations USING btree (expires_at) WHERE (status = 'pending'::auth.oauth_authorization_status);


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- Name: oauth_consents_active_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_client_idx ON auth.oauth_consents USING btree (client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_active_user_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_user_client_idx ON auth.oauth_consents USING btree (user_id, client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_user_order_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_user_order_idx ON auth.oauth_consents USING btree (user_id, granted_at DESC);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_oauth_client_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_oauth_client_id_idx ON auth.sessions USING btree (oauth_client_id);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: webauthn_challenges_expires_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_challenges_expires_at_idx ON auth.webauthn_challenges USING btree (expires_at);


--
-- Name: webauthn_challenges_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_challenges_user_id_idx ON auth.webauthn_challenges USING btree (user_id);


--
-- Name: webauthn_credentials_credential_id_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX webauthn_credentials_credential_id_key ON auth.webauthn_credentials USING btree (credential_id);


--
-- Name: webauthn_credentials_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_credentials_user_id_idx ON auth.webauthn_credentials USING btree (user_id);


--
-- Name: adherence_summary_patient_window_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX adherence_summary_patient_window_idx ON public.adherence_summary USING btree (patient_id, window_days, period_end_date DESC);


--
-- Name: alerts_patient_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX alerts_patient_idx ON public.alerts USING btree (patient_id, created_at DESC);


--
-- Name: alerts_source_event_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX alerts_source_event_idx ON public.alerts USING btree (source_event_id) WHERE (source_event_id IS NOT NULL);


--
-- Name: alerts_workflow_run_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX alerts_workflow_run_idx ON public.alerts USING btree (workflow_run_id) WHERE (workflow_run_id IS NOT NULL);


--
-- Name: clinical_tasks_patient_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX clinical_tasks_patient_idx ON public.clinical_tasks USING btree (patient_id, created_at DESC);


--
-- Name: clinical_tasks_workflow_run_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX clinical_tasks_workflow_run_idx ON public.clinical_tasks USING btree (workflow_run_id) WHERE (workflow_run_id IS NOT NULL);


--
-- Name: events_causation_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_causation_idx ON public.events USING btree (causation_event_id) WHERE (causation_event_id IS NOT NULL);


--
-- Name: events_patient_created_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_patient_created_idx ON public.events USING btree (patient_id, created_at DESC);


--
-- Name: events_transition_idempotency_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX events_transition_idempotency_idx ON public.events USING btree (entity_id, event_type) WHERE (event_type = ANY (ARRAY['glucose_reading.created'::text, 'alert.created'::text, 'alert.acknowledged'::text, 'clinical_task.created'::text, 'clinical_task.review_started'::text, 'clinical_task.closed'::text]));


--
-- Name: events_workflow_run_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_workflow_run_idx ON public.events USING btree (workflow_run_id) WHERE (workflow_run_id IS NOT NULL);


--
-- Name: glucose_daily_context_patient_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX glucose_daily_context_patient_date_idx ON public.glucose_daily_context USING btree (patient_id, local_date DESC);


--
-- Name: glucose_readings_patient_context_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX glucose_readings_patient_context_idx ON public.glucose_readings USING btree (patient_id, measurement_context, measured_at DESC);


--
-- Name: glucose_readings_patient_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX glucose_readings_patient_id_idx ON public.glucose_readings USING btree (patient_id);


--
-- Name: glucose_readings_patient_measured_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX glucose_readings_patient_measured_at_idx ON public.glucose_readings USING btree (patient_id, measured_at DESC);


--
-- Name: patient_history_reviews_patient_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX patient_history_reviews_patient_idx ON public.patient_history_reviews USING btree (patient_id, reviewed_at DESC);


--
-- Name: patient_invitations_professional_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX patient_invitations_professional_idx ON public.patient_invitations USING btree (professional_id, created_at DESC);


--
-- Name: professional_patients_patient_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX professional_patients_patient_idx ON public.professional_patients USING btree (patient_id, professional_id) WHERE active;


--
-- Name: workflow_runs_key_started_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX workflow_runs_key_started_idx ON public.workflow_runs USING btree (workflow_key, started_at DESC);


--
-- Name: workflow_runs_n8n_execution_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX workflow_runs_n8n_execution_idx ON public.workflow_runs USING btree (n8n_execution_id) WHERE (n8n_execution_id IS NOT NULL);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: messages_inserted_at_topic_index; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2026_09_12_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2026_09_12_inserted_at_topic_idx ON realtime.messages_2026_09_12 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2026_09_13_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2026_09_13_inserted_at_topic_idx ON realtime.messages_2026_09_13 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2026_09_14_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2026_09_14_inserted_at_topic_idx ON realtime.messages_2026_09_14 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2026_09_15_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2026_09_15_inserted_at_topic_idx ON realtime.messages_2026_09_15 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2026_09_16_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2026_09_16_inserted_at_topic_idx ON realtime.messages_2026_09_16 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: subscription_subscription_id_entity_filters_action_filter_selec; Type: INDEX; Schema: realtime; Owner: -
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_action_filter_selec ON realtime.subscription USING btree (subscription_id, entity, filters, action_filter, COALESCE(selected_columns, '{}'::text[]));


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: buckets_analytics_unique_name_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX buckets_analytics_unique_name_idx ON storage.buckets_analytics USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: idx_iceberg_namespaces_bucket_id; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX idx_iceberg_namespaces_bucket_id ON storage.iceberg_namespaces USING btree (catalog_id, name);


--
-- Name: idx_iceberg_tables_location; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX idx_iceberg_tables_location ON storage.iceberg_tables USING btree (location);


--
-- Name: idx_iceberg_tables_namespace_id; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX idx_iceberg_tables_namespace_id ON storage.iceberg_tables USING btree (catalog_id, namespace_id, name);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: idx_objects_bucket_id_name_lower; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name_lower ON storage.objects USING btree (bucket_id, lower(name) COLLATE "C");


--
-- Name: idx_objects_current_version; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX idx_objects_current_version ON storage.objects USING btree (bucket_id, name COLLATE "C") WHERE (archived_at IS NULL);


--
-- Name: idx_objects_null_version; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX idx_objects_null_version ON storage.objects USING btree (bucket_id, name COLLATE "C") WHERE (NOT is_versioned);


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: objects_bucket_id_name_version_key; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX objects_bucket_id_name_version_key ON storage.objects USING btree (bucket_id, name COLLATE "C", version) NULLS NOT DISTINCT;


--
-- Name: vector_indexes_name_bucket_id_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX vector_indexes_name_bucket_id_idx ON storage.vector_indexes USING btree (name, bucket_id);


--
-- Name: supabase_functions_hooks_h_table_id_h_name_idx; Type: INDEX; Schema: supabase_functions; Owner: -
--

CREATE INDEX supabase_functions_hooks_h_table_id_h_name_idx ON supabase_functions.hooks USING btree (hook_table_id, hook_name);


--
-- Name: supabase_functions_hooks_request_id_idx; Type: INDEX; Schema: supabase_functions; Owner: -
--

CREATE INDEX supabase_functions_hooks_request_id_idx ON supabase_functions.hooks USING btree (request_id);


--
-- Name: messages_2026_09_12_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_09_12_inserted_at_topic_idx;


--
-- Name: messages_2026_09_12_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_09_12_pkey;


--
-- Name: messages_2026_09_13_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_09_13_inserted_at_topic_idx;


--
-- Name: messages_2026_09_13_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_09_13_pkey;


--
-- Name: messages_2026_09_14_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_09_14_inserted_at_topic_idx;


--
-- Name: messages_2026_09_14_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_09_14_pkey;


--
-- Name: messages_2026_09_15_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_09_15_inserted_at_topic_idx;


--
-- Name: messages_2026_09_15_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_09_15_pkey;


--
-- Name: messages_2026_09_16_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_09_16_inserted_at_topic_idx;


--
-- Name: messages_2026_09_16_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_09_16_pkey;


--
-- Name: adherence_summary adherence_summary_touch; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER adherence_summary_touch BEFORE UPDATE ON public.adherence_summary FOR EACH ROW EXECUTE FUNCTION private.touch_adherence_summary();


--
-- Name: alerts alert_transition; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER alert_transition BEFORE UPDATE ON public.alerts FOR EACH ROW EXECUTE FUNCTION private.record_clinical_transition();


--
-- Name: glucose_daily_context glucose_daily_context_touch; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER glucose_daily_context_touch BEFORE UPDATE ON public.glucose_daily_context FOR EACH ROW EXECUTE FUNCTION private.touch_daily_context();


--
-- Name: clinical_tasks task_transition; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER task_transition BEFORE UPDATE ON public.clinical_tasks FOR EACH ROW EXECUTE FUNCTION private.record_clinical_transition();


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: -
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();


--
-- Name: buckets protect_bucket_control_insert; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_bucket_control_insert BEFORE INSERT ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.protect_bucket_control_columns('service_role');


--
-- Name: buckets protect_bucket_control_update; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_bucket_control_update BEFORE UPDATE OF lifecycle_configuration, lifecycle_configuration_generation ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.protect_bucket_control_columns();


--
-- Name: buckets protect_bucket_control_update_role; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_bucket_control_update_role AFTER UPDATE OF lifecycle_configuration, lifecycle_configuration_generation ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_lifecycle_service_role('service_role');


--
-- Name: buckets protect_buckets_delete; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_buckets_delete BEFORE DELETE ON storage.buckets FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();


--
-- Name: objects protect_objects_delete; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_objects_delete BEFORE DELETE ON storage.objects FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: extensions extensions_tenant_external_id_fkey; Type: FK CONSTRAINT; Schema: _realtime; Owner: -
--

ALTER TABLE ONLY _realtime.extensions
    ADD CONSTRAINT extensions_tenant_external_id_fkey FOREIGN KEY (tenant_external_id) REFERENCES _realtime.tenants(external_id) ON DELETE CASCADE;


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_oauth_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_oauth_client_id_fkey FOREIGN KEY (oauth_client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: webauthn_challenges webauthn_challenges_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_challenges
    ADD CONSTRAINT webauthn_challenges_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: webauthn_credentials webauthn_credentials_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: adherence_summary adherence_summary_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adherence_summary
    ADD CONSTRAINT adherence_summary_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- Name: adherence_summary adherence_summary_workflow_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adherence_summary
    ADD CONSTRAINT adherence_summary_workflow_run_id_fkey FOREIGN KEY (workflow_run_id) REFERENCES public.workflow_runs(id);


--
-- Name: alerts alerts_acknowledged_by_professional_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT alerts_acknowledged_by_professional_id_fkey FOREIGN KEY (acknowledged_by_professional_id) REFERENCES public.professionals(id);


--
-- Name: alerts alerts_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT alerts_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: alerts alerts_source_reading_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT alerts_source_reading_id_fkey FOREIGN KEY (source_reading_id) REFERENCES public.glucose_readings(id);


--
-- Name: alerts alerts_workflow_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT alerts_workflow_run_id_fkey FOREIGN KEY (workflow_run_id) REFERENCES public.workflow_runs(id);


--
-- Name: clinical_tasks clinical_tasks_assigned_professional_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clinical_tasks
    ADD CONSTRAINT clinical_tasks_assigned_professional_id_fkey FOREIGN KEY (assigned_professional_id) REFERENCES public.professionals(id);


--
-- Name: clinical_tasks clinical_tasks_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clinical_tasks
    ADD CONSTRAINT clinical_tasks_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: clinical_tasks clinical_tasks_source_alert_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clinical_tasks
    ADD CONSTRAINT clinical_tasks_source_alert_id_fkey FOREIGN KEY (source_alert_id) REFERENCES public.alerts(id);


--
-- Name: clinical_tasks clinical_tasks_workflow_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clinical_tasks
    ADD CONSTRAINT clinical_tasks_workflow_run_id_fkey FOREIGN KEY (workflow_run_id) REFERENCES public.workflow_runs(id);


--
-- Name: events events_actor_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_actor_profile_id_fkey FOREIGN KEY (actor_profile_id) REFERENCES public.profiles(id);


--
-- Name: events events_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- Name: events events_workflow_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_workflow_run_id_fkey FOREIGN KEY (workflow_run_id) REFERENCES public.workflow_runs(id);


--
-- Name: glucose_daily_context glucose_daily_context_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.glucose_daily_context
    ADD CONSTRAINT glucose_daily_context_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- Name: glucose_readings glucose_patient_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.glucose_readings
    ADD CONSTRAINT glucose_patient_fk FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: glucose_readings glucose_readings_recorded_by_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.glucose_readings
    ADD CONSTRAINT glucose_readings_recorded_by_profile_id_fkey FOREIGN KEY (recorded_by_profile_id) REFERENCES public.profiles(id);


--
-- Name: patient_histories patient_histories_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_histories
    ADD CONSTRAINT patient_histories_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- Name: patient_history_reviews patient_history_reviews_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_history_reviews
    ADD CONSTRAINT patient_history_reviews_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- Name: patient_history_reviews patient_history_reviews_patient_id_history_revision_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_history_reviews
    ADD CONSTRAINT patient_history_reviews_patient_id_history_revision_fkey FOREIGN KEY (patient_id, history_revision) REFERENCES public.patient_history_versions(patient_id, revision);


--
-- Name: patient_history_reviews patient_history_reviews_professional_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_history_reviews
    ADD CONSTRAINT patient_history_reviews_professional_id_fkey FOREIGN KEY (professional_id) REFERENCES public.professionals(id);


--
-- Name: patient_history_versions patient_history_versions_actor_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_history_versions
    ADD CONSTRAINT patient_history_versions_actor_profile_id_fkey FOREIGN KEY (actor_profile_id) REFERENCES public.profiles(id);


--
-- Name: patient_history_versions patient_history_versions_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_history_versions
    ADD CONSTRAINT patient_history_versions_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- Name: patient_invitations patient_invitations_accepted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_invitations
    ADD CONSTRAINT patient_invitations_accepted_by_fkey FOREIGN KEY (accepted_by) REFERENCES public.patients(id);


--
-- Name: patient_invitations patient_invitations_professional_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_invitations
    ADD CONSTRAINT patient_invitations_professional_id_fkey FOREIGN KEY (professional_id) REFERENCES public.professionals(id) ON DELETE CASCADE;


--
-- Name: patients patients_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: professional_patients professional_patients_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.professional_patients
    ADD CONSTRAINT professional_patients_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- Name: professional_patients professional_patients_professional_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.professional_patients
    ADD CONSTRAINT professional_patients_professional_id_fkey FOREIGN KEY (professional_id) REFERENCES public.professionals(id) ON DELETE CASCADE;


--
-- Name: professionals professionals_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.professionals
    ADD CONSTRAINT professionals_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: profiles profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: iceberg_namespaces iceberg_namespaces_catalog_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.iceberg_namespaces
    ADD CONSTRAINT iceberg_namespaces_catalog_id_fkey FOREIGN KEY (catalog_id) REFERENCES storage.buckets_analytics(id) ON DELETE CASCADE;


--
-- Name: iceberg_tables iceberg_tables_catalog_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.iceberg_tables
    ADD CONSTRAINT iceberg_tables_catalog_id_fkey FOREIGN KEY (catalog_id) REFERENCES storage.buckets_analytics(id) ON DELETE CASCADE;


--
-- Name: iceberg_tables iceberg_tables_namespace_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.iceberg_tables
    ADD CONSTRAINT iceberg_tables_namespace_id_fkey FOREIGN KEY (namespace_id) REFERENCES storage.iceberg_namespaces(id) ON DELETE CASCADE;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: vector_indexes vector_indexes_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets_vectors(id);


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: adherence_summary; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.adherence_summary ENABLE ROW LEVEL SECURITY;

--
-- Name: adherence_summary adherence_summary_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY adherence_summary_read ON public.adherence_summary FOR SELECT TO authenticated USING (private.can_view_patient(patient_id));


--
-- Name: alerts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.alerts ENABLE ROW LEVEL SECURITY;

--
-- Name: alerts alerts_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY alerts_read ON public.alerts FOR SELECT TO authenticated USING (((private.my_professional_id() IS NOT NULL) AND private.can_view_patient(patient_id)));


--
-- Name: alerts alerts_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY alerts_update ON public.alerts FOR UPDATE TO authenticated USING (((private.my_professional_id() IS NOT NULL) AND private.can_view_patient(patient_id))) WITH CHECK (((private.my_professional_id() IS NOT NULL) AND private.can_view_patient(patient_id)));


--
-- Name: professional_patients assignments_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY assignments_read ON public.professional_patients FOR SELECT TO authenticated USING (((patient_id = ( SELECT private.my_patient_id() AS my_patient_id)) OR (professional_id = ( SELECT private.my_professional_id() AS my_professional_id))));


--
-- Name: clinical_tasks; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.clinical_tasks ENABLE ROW LEVEL SECURITY;

--
-- Name: events; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

--
-- Name: glucose_readings glucose_create; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY glucose_create ON public.glucose_readings FOR INSERT TO authenticated WITH CHECK (((patient_id = ( SELECT private.my_patient_id() AS my_patient_id)) AND (EXISTS ( SELECT 1
   FROM public.patient_histories h
  WHERE ((h.patient_id = glucose_readings.patient_id) AND (h.completed_at IS NOT NULL))))));


--
-- Name: glucose_daily_context; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.glucose_daily_context ENABLE ROW LEVEL SECURITY;

--
-- Name: glucose_daily_context glucose_daily_context_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY glucose_daily_context_insert ON public.glucose_daily_context FOR INSERT TO authenticated WITH CHECK ((patient_id = ( SELECT private.my_patient_id() AS my_patient_id)));


--
-- Name: glucose_daily_context glucose_daily_context_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY glucose_daily_context_read ON public.glucose_daily_context FOR SELECT TO authenticated USING (private.can_view_patient(patient_id));


--
-- Name: glucose_daily_context glucose_daily_context_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY glucose_daily_context_update ON public.glucose_daily_context FOR UPDATE TO authenticated USING ((patient_id = ( SELECT private.my_patient_id() AS my_patient_id))) WITH CHECK ((patient_id = ( SELECT private.my_patient_id() AS my_patient_id)));


--
-- Name: glucose_readings glucose_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY glucose_read ON public.glucose_readings FOR SELECT TO authenticated USING (private.can_view_patient(patient_id));


--
-- Name: glucose_readings; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.glucose_readings ENABLE ROW LEVEL SECURITY;

--
-- Name: patient_histories histories_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY histories_read ON public.patient_histories FOR SELECT TO authenticated USING (private.can_view_patient(patient_id));


--
-- Name: patient_invitations invitations_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY invitations_insert ON public.patient_invitations FOR INSERT TO authenticated WITH CHECK (((professional_id = ( SELECT private.my_professional_id() AS my_professional_id)) AND (EXISTS ( SELECT 1
   FROM public.professionals
  WHERE ((professionals.id = patient_invitations.professional_id) AND (professionals.completed_at IS NOT NULL))))));


--
-- Name: patient_invitations invitations_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY invitations_read ON public.patient_invitations FOR SELECT TO authenticated USING ((professional_id = ( SELECT private.my_professional_id() AS my_professional_id)));


--
-- Name: patient_histories; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.patient_histories ENABLE ROW LEVEL SECURITY;

--
-- Name: patient_history_reviews; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.patient_history_reviews ENABLE ROW LEVEL SECURITY;

--
-- Name: patient_history_versions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.patient_history_versions ENABLE ROW LEVEL SECURITY;

--
-- Name: patient_invitations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.patient_invitations ENABLE ROW LEVEL SECURITY;

--
-- Name: patients; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.patients ENABLE ROW LEVEL SECURITY;

--
-- Name: patients patients_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY patients_read ON public.patients FOR SELECT TO authenticated USING (private.can_view_patient(id));


--
-- Name: professional_patients; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.professional_patients ENABLE ROW LEVEL SECURITY;

--
-- Name: professionals; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.professionals ENABLE ROW LEVEL SECURITY;

--
-- Name: professionals professionals_edit; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY professionals_edit ON public.professionals FOR UPDATE TO authenticated USING ((id = ( SELECT private.my_professional_id() AS my_professional_id))) WITH CHECK ((id = ( SELECT private.my_professional_id() AS my_professional_id)));


--
-- Name: professionals professionals_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY professionals_read ON public.professionals FOR SELECT TO authenticated USING (private.can_view_profile(profile_id));


--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles profiles_edit_name; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY profiles_edit_name ON public.profiles FOR UPDATE TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid))) WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- Name: profiles profiles_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY profiles_read ON public.profiles FOR SELECT TO authenticated USING (private.can_view_profile(id));


--
-- Name: patient_history_reviews reviews_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY reviews_read ON public.patient_history_reviews FOR SELECT TO authenticated USING (private.can_view_patient(patient_id));


--
-- Name: clinical_tasks tasks_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tasks_read ON public.clinical_tasks FOR SELECT TO authenticated USING (((private.my_professional_id() IS NOT NULL) AND private.can_view_patient(patient_id)));


--
-- Name: clinical_tasks tasks_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tasks_update ON public.clinical_tasks FOR UPDATE TO authenticated USING ((private.can_view_patient(patient_id) AND (assigned_professional_id = private.my_professional_id()))) WITH CHECK ((private.can_view_patient(patient_id) AND (assigned_professional_id = private.my_professional_id())));


--
-- Name: patient_history_versions versions_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY versions_read ON public.patient_history_versions FOR SELECT TO authenticated USING (private.can_view_patient(patient_id));


--
-- Name: workflow_runs; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.workflow_runs ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: -
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_analytics ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_vectors; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_vectors ENABLE ROW LEVEL SECURITY;

--
-- Name: iceberg_namespaces; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.iceberg_namespaces ENABLE ROW LEVEL SECURITY;

--
-- Name: iceberg_tables; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.iceberg_tables ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: vector_indexes; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.vector_indexes ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: -
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


--
-- PostgreSQL database dump complete
--

\unrestrict cATcxOzrlhwNkO1177tFyaUyscJguplnPcYbEf7OLncjlbi4bJtsJCXVUyQYaVc

