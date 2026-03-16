--
-- PostgreSQL database dump
--

\restrict 0JOKhyIniyQRHX6qg32muDkrdlcZfhOcvMy9agMZqvxXyO2wAcETNrKEEunwLQQ

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


--
-- Name: available_updates_status_enum; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.available_updates_status_enum AS ENUM (
    'AVAILABLE',
    'REGISTERED',
    'DOWNLOADING',
    'READY_TO_INSTALL',
    'INSTALLING',
    'INSTALLED',
    'FAILED'
);


ALTER TYPE public.available_updates_status_enum OWNER TO admin;

--
-- Name: customer_update_status_status_enum; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.customer_update_status_status_enum AS ENUM (
    'AVAILABLE',
    'REGISTERED',
    'DOWNLOADING',
    'READY_TO_INSTALL',
    'INSTALLING',
    'INSTALLED',
    'FAILED'
);


ALTER TYPE public.customer_update_status_status_enum OWNER TO admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: available_updates; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.available_updates (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    version character varying NOT NULL,
    "updateName" text,
    description text,
    services text,
    package_url character varying NOT NULL,
    script_url character varying NOT NULL,
    release_date timestamp with time zone,
    status public.available_updates_status_enum DEFAULT 'AVAILABLE'::public.available_updates_status_enum NOT NULL,
    download_path character varying,
    script_path character varying,
    logs text,
    download_progress integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.available_updates OWNER TO admin;

--
-- Name: customer_update_status; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.customer_update_status (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    update_id uuid NOT NULL,
    customer_id character varying NOT NULL,
    customer_name character varying,
    status public.customer_update_status_status_enum DEFAULT 'AVAILABLE'::public.customer_update_status_status_enum NOT NULL,
    logs text,
    installed_at timestamp with time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.customer_update_status OWNER TO admin;

--
-- Name: system_update_config; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.system_update_config (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    cloud_url character varying NOT NULL,
    auto_check boolean DEFAULT true NOT NULL,
    check_interval_seconds integer DEFAULT 3600 NOT NULL,
    last_checked timestamp with time zone,
    customer_id character varying,
    company_name character varying,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.system_update_config OWNER TO admin;

--
-- Name: available_updates PK_0b623a297284d8248fab59825e0; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.available_updates
    ADD CONSTRAINT "PK_0b623a297284d8248fab59825e0" PRIMARY KEY (id);


--
-- Name: system_update_config PK_d3a7c3a6975d6fdf1f8de78b018; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.system_update_config
    ADD CONSTRAINT "PK_d3a7c3a6975d6fdf1f8de78b018" PRIMARY KEY (id);


--
-- Name: customer_update_status PK_d567ea79aaa107df4be3b07dc50; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.customer_update_status
    ADD CONSTRAINT "PK_d567ea79aaa107df4be3b07dc50" PRIMARY KEY (id);


--
-- Name: available_updates UQ_4e957c8fd6fe976e42ff0f78c8a; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.available_updates
    ADD CONSTRAINT "UQ_4e957c8fd6fe976e42ff0f78c8a" UNIQUE (version);


--
-- Name: customer_update_status FK_34f57e6e23b27f0b20d2c042e70; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.customer_update_status
    ADD CONSTRAINT "FK_34f57e6e23b27f0b20d2c042e70" FOREIGN KEY (update_id) REFERENCES public.available_updates(id);


--
-- PostgreSQL database dump complete
--

\unrestrict 0JOKhyIniyQRHX6qg32muDkrdlcZfhOcvMy9agMZqvxXyO2wAcETNrKEEunwLQQ

