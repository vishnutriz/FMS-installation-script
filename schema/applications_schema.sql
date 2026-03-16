--
-- PostgreSQL database dump
--

\restrict BCjw84NQBjvfdI8hKgpcbzx7dK67GOOdBDTL1Z1xiCRWcefZIWiJB1nIX0Xxs8a

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
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO admin;

--
-- Name: applications; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.applications (
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    description character varying,
    customer_id uuid NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    image character varying,
    app_metadata jsonb
);


ALTER TABLE public.applications OWNER TO admin;

--
-- Name: versions; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.versions (
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    application_version_id character varying NOT NULL,
    version character varying NOT NULL,
    changelog character varying,
    is_active boolean DEFAULT false NOT NULL,
    deprecated boolean DEFAULT false NOT NULL,
    release_date timestamp without time zone DEFAULT now() NOT NULL,
    application_id uuid NOT NULL,
    communication_types jsonb DEFAULT '["REST"]'::jsonb NOT NULL,
    metadata jsonb,
    auto_parse_enabled boolean DEFAULT false NOT NULL,
    dependencies jsonb,
    mission_details jsonb,
    error_codes jsonb
);


ALTER TABLE public.versions OWNER TO admin;

--
-- Name: versions UQ_b551ed60613c1c39655a77ffef8; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT "UQ_b551ed60613c1c39655a77ffef8" UNIQUE (application_version_id);


--
-- Name: applications UQ_f81f3bc093fa88f244793d12c77; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT "UQ_f81f3bc093fa88f244793d12c77" UNIQUE (name, customer_id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: applications applications_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: IDX_7ab97e23f4482c78e873c8424b; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IDX_7ab97e23f4482c78e873c8424b" ON public.applications USING btree (customer_id);


--
-- Name: IDX_b551ed60613c1c39655a77ffef; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IDX_b551ed60613c1c39655a77ffef" ON public.versions USING btree (application_version_id);


--
-- Name: IDX_d18469031b39e2058c5d076302; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IDX_d18469031b39e2058c5d076302" ON public.versions USING btree (application_id);


--
-- Name: versions FK_d18469031b39e2058c5d076302d; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT "FK_d18469031b39e2058c5d076302d" FOREIGN KEY (application_id) REFERENCES public.applications(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict BCjw84NQBjvfdI8hKgpcbzx7dK67GOOdBDTL1Z1xiCRWcefZIWiJB1nIX0Xxs8a

