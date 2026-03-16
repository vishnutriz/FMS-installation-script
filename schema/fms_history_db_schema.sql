--
-- PostgreSQL database dump
--

\restrict K2vmPUm9XdNt4we8bqLrJhXnNzwS2fGKbhioGj2PL2Z2jjSFqnLrzND1DiJNDXb

-- Dumped from database version 14.22 (Ubuntu 14.22-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.22 (Ubuntu 14.22-0ubuntu0.22.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _migrations; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public._migrations (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    executed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public._migrations OWNER TO admin;

--
-- Name: _migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public._migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public._migrations_id_seq OWNER TO admin;

--
-- Name: _migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public._migrations_id_seq OWNED BY public._migrations.id;


--
-- Name: backup_config; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.backup_config (
    id integer NOT NULL,
    config_key character varying(100) NOT NULL,
    config_value text NOT NULL,
    description text,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by character varying(255),
    customer_id character varying(255)
);


ALTER TABLE public.backup_config OWNER TO admin;

--
-- Name: TABLE backup_config; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.backup_config IS 'Stores backup system configuration settings';


--
-- Name: backup_config_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.backup_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.backup_config_id_seq OWNER TO admin;

--
-- Name: backup_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.backup_config_id_seq OWNED BY public.backup_config.id;


--
-- Name: backup_logs; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.backup_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    backup_id uuid,
    action character varying(20) NOT NULL,
    level character varying(10) NOT NULL,
    message text NOT NULL,
    metadata jsonb,
    "timestamp" timestamp with time zone DEFAULT now() NOT NULL,
    customer_id character varying(255),
    CONSTRAINT backup_logs_action_check CHECK (((action)::text = ANY ((ARRAY['backup'::character varying, 'restore'::character varying, 'cleanup'::character varying, 'config'::character varying])::text[]))),
    CONSTRAINT backup_logs_level_check CHECK (((level)::text = ANY ((ARRAY['info'::character varying, 'error'::character varying, 'warn'::character varying])::text[])))
);


ALTER TABLE public.backup_logs OWNER TO admin;

--
-- Name: TABLE backup_logs; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.backup_logs IS 'Comprehensive logging for all backup/restore/cleanup actions';


--
-- Name: backup_metadata; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.backup_metadata (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    db_type character varying(20) NOT NULL,
    db_identifier character varying(255) NOT NULL,
    backup_path text NOT NULL,
    size_bytes bigint,
    status character varying(20) NOT NULL,
    error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    completed_at timestamp with time zone,
    customer_id character varying(255),
    backup_type character varying(20) DEFAULT 'manual'::character varying,
    CONSTRAINT backup_metadata_db_type_check CHECK (((db_type)::text = ANY ((ARRAY['postgres'::character varying, 'influx'::character varying, 'mongodb'::character varying, 'unified'::character varying])::text[]))),
    CONSTRAINT backup_metadata_status_check CHECK (((status)::text = ANY ((ARRAY['running'::character varying, 'success'::character varying, 'failed'::character varying])::text[]))),
    CONSTRAINT backup_type_check CHECK (((backup_type)::text = ANY ((ARRAY['manual'::character varying, 'scheduled'::character varying])::text[])))
);


ALTER TABLE public.backup_metadata OWNER TO admin;

--
-- Name: TABLE backup_metadata; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.backup_metadata IS 'Tracks all backup operations and their metadata';


--
-- Name: COLUMN backup_metadata.backup_type; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.backup_metadata.backup_type IS 'Type of backup: manual (customer-specific) or scheduled (system-wide)';


--
-- Name: CONSTRAINT backup_metadata_db_type_check ON backup_metadata; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON CONSTRAINT backup_metadata_db_type_check ON public.backup_metadata IS 'Allowed database types: postgres, influx, mongodb, unified';


--
-- Name: cleanup_history; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.cleanup_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    executed_at timestamp with time zone DEFAULT now() NOT NULL,
    dry_run boolean NOT NULL,
    customer_id character varying(255),
    retention_unit character varying(10) NOT NULL,
    retention_value integer NOT NULL,
    cutoff_timestamp timestamp with time zone NOT NULL,
    targets jsonb NOT NULL,
    results jsonb NOT NULL,
    executed_by character varying(255),
    status character varying(50) NOT NULL,
    error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.cleanup_history OWNER TO admin;

--
-- Name: TABLE cleanup_history; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.cleanup_history IS 'Stores historical records of all cleanup operations';


--
-- Name: COLUMN cleanup_history.targets; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.cleanup_history.targets IS 'JSONB containing the cleanup targets (influx/postgres configurations)';


--
-- Name: COLUMN cleanup_history.results; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.cleanup_history.results IS 'JSONB containing the cleanup results (deleted counts, errors, etc)';


--
-- Name: histories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.histories (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    customer_id character varying(150),
    section_name character varying(100) NOT NULL,
    section_id character varying(150) NOT NULL,
    action character varying(50) NOT NULL,
    created_by_user_name character varying(100),
    created_by_user_id character varying(100),
    updated_by_user_name character varying(100),
    updated_by_user_id character varying(100),
    old_data jsonb,
    new_data jsonb,
    description text,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.histories OWNER TO postgres;

--
-- Name: _migrations id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public._migrations ALTER COLUMN id SET DEFAULT nextval('public._migrations_id_seq'::regclass);


--
-- Name: backup_config id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.backup_config ALTER COLUMN id SET DEFAULT nextval('public.backup_config_id_seq'::regclass);


--
-- Name: histories PK_36b0e707452a8b674f9d95da743; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.histories
    ADD CONSTRAINT "PK_36b0e707452a8b674f9d95da743" PRIMARY KEY (id);


--
-- Name: _migrations _migrations_name_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public._migrations
    ADD CONSTRAINT _migrations_name_key UNIQUE (name);


--
-- Name: _migrations _migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public._migrations
    ADD CONSTRAINT _migrations_pkey PRIMARY KEY (id);


--
-- Name: backup_config backup_config_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.backup_config
    ADD CONSTRAINT backup_config_pkey PRIMARY KEY (id);


--
-- Name: backup_logs backup_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.backup_logs
    ADD CONSTRAINT backup_logs_pkey PRIMARY KEY (id);


--
-- Name: backup_metadata backup_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.backup_metadata
    ADD CONSTRAINT backup_metadata_pkey PRIMARY KEY (id);


--
-- Name: cleanup_history cleanup_history_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.cleanup_history
    ADD CONSTRAINT cleanup_history_pkey PRIMARY KEY (id);


--
-- Name: idx_backup_config_key_customer; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX idx_backup_config_key_customer ON public.backup_config USING btree (config_key, customer_id);


--
-- Name: idx_backup_logs_action; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_backup_logs_action ON public.backup_logs USING btree (action);


--
-- Name: idx_backup_logs_backup_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_backup_logs_backup_id ON public.backup_logs USING btree (backup_id);


--
-- Name: idx_backup_logs_customer_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_backup_logs_customer_id ON public.backup_logs USING btree (customer_id);


--
-- Name: idx_backup_logs_level; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_backup_logs_level ON public.backup_logs USING btree (level);


--
-- Name: idx_backup_logs_timestamp; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_backup_logs_timestamp ON public.backup_logs USING btree ("timestamp" DESC);


--
-- Name: idx_backup_metadata_backup_type; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_backup_metadata_backup_type ON public.backup_metadata USING btree (backup_type);


--
-- Name: idx_backup_metadata_created_at; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_backup_metadata_created_at ON public.backup_metadata USING btree (created_at DESC);


--
-- Name: idx_backup_metadata_customer_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_backup_metadata_customer_id ON public.backup_metadata USING btree (customer_id);


--
-- Name: idx_backup_metadata_db_identifier; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_backup_metadata_db_identifier ON public.backup_metadata USING btree (db_identifier);


--
-- Name: idx_backup_metadata_db_type; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_backup_metadata_db_type ON public.backup_metadata USING btree (db_type);


--
-- Name: idx_backup_metadata_expires_at; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_backup_metadata_expires_at ON public.backup_metadata USING btree (expires_at);


--
-- Name: idx_backup_metadata_status; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_backup_metadata_status ON public.backup_metadata USING btree (status);


--
-- Name: idx_cleanup_history_customer_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_cleanup_history_customer_id ON public.cleanup_history USING btree (customer_id);


--
-- Name: idx_cleanup_history_dry_run; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_cleanup_history_dry_run ON public.cleanup_history USING btree (dry_run);


--
-- Name: idx_cleanup_history_executed_at; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_cleanup_history_executed_at ON public.cleanup_history USING btree (executed_at DESC);


--
-- Name: idx_cleanup_history_status; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_cleanup_history_status ON public.cleanup_history USING btree (status);


--
-- Name: backup_logs backup_logs_backup_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.backup_logs
    ADD CONSTRAINT backup_logs_backup_id_fkey FOREIGN KEY (backup_id) REFERENCES public.backup_metadata(id) ON DELETE CASCADE;


--
-- Name: TABLE histories; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.histories TO admin;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO admin;


--
-- PostgreSQL database dump complete
--

\unrestrict K2vmPUm9XdNt4we8bqLrJhXnNzwS2fGKbhioGj2PL2Z2jjSFqnLrzND1DiJNDXb

