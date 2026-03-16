--
-- PostgreSQL database dump
--

\restrict Zx8AcwhAHJgRawSYJbhMFEitVX1SFPqSKaYaIALbD3w5fLNUoY2e5J778B0MU2z

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
-- Name: deployments; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.deployments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    plant_id uuid NOT NULL,
    deployment_type character varying,
    description text NOT NULL,
    priority character varying,
    estimated_duration integer,
    budget numeric(10,2),
    notes text,
    planned_start_date timestamp with time zone,
    planned_end_date timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.deployments OWNER TO admin;

--
-- Name: migrations; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    "timestamp" bigint NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.migrations OWNER TO admin;

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.migrations_id_seq OWNER TO admin;

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: path_layers; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.path_layers (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    zone_id uuid NOT NULL,
    "pathData" jsonb NOT NULL,
    version integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    "internalPathData" jsonb DEFAULT '{}'::jsonb NOT NULL,
    "junctionPaths" jsonb,
    "wallAreas" jsonb,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    map_version integer
);


ALTER TABLE public.path_layers OWNER TO admin;

--
-- Name: plants; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.plants (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    type character varying NOT NULL,
    address character varying NOT NULL,
    city character varying NOT NULL,
    state character varying NOT NULL,
    zip_code character varying NOT NULL,
    country character varying NOT NULL,
    description character varying,
    contact_person character varying NOT NULL,
    contact_email character varying NOT NULL,
    contact_phone character varying NOT NULL,
    customer_id uuid NOT NULL,
    plant_image character varying,
    pixel_per_meter double precision,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.plants OWNER TO admin;

--
-- Name: zone_device_assignment; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.zone_device_assignment (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "deviceId" character varying NOT NULL,
    "zoneId" uuid,
    "deviceName" character varying,
    "mapAssigned" character varying NOT NULL,
    "pathAssigned" character varying NOT NULL,
    applicationid character varying,
    "assignedAt" timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.zone_device_assignment OWNER TO admin;

--
-- Name: zones; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.zones (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    deployment_id uuid NOT NULL,
    zone_type character varying NOT NULL,
    description text NOT NULL,
    area double precision NOT NULL,
    capacity integer NOT NULL,
    safety_level character varying NOT NULL,
    access_level character varying NOT NULL,
    coordinates jsonb NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    map_file_path character varying,
    yaml_file_path character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    origin jsonb,
    plant_image character varying,
    starting_point jsonb,
    map_version integer,
    digital_twin jsonb,
    pixel_per_meter double precision,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.zones OWNER TO admin;

--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: deployments PK_1e5627acb3c950deb83fe98fc48; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.deployments
    ADD CONSTRAINT "PK_1e5627acb3c950deb83fe98fc48" PRIMARY KEY (id);


--
-- Name: path_layers PK_6cb1d91368fe18f128f5e5dc4be; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.path_layers
    ADD CONSTRAINT "PK_6cb1d91368fe18f128f5e5dc4be" PRIMARY KEY (id);


--
-- Name: plants PK_7056d6b283b48ee2bb0e53bee60; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.plants
    ADD CONSTRAINT "PK_7056d6b283b48ee2bb0e53bee60" PRIMARY KEY (id);


--
-- Name: zones PK_880484a43ca311707b05895bd4a; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.zones
    ADD CONSTRAINT "PK_880484a43ca311707b05895bd4a" PRIMARY KEY (id);


--
-- Name: migrations PK_8c82d7f526340ab734260ea46be; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT "PK_8c82d7f526340ab734260ea46be" PRIMARY KEY (id);


--
-- Name: zone_device_assignment PK_9f18151d14f736574f1c402d20c; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.zone_device_assignment
    ADD CONSTRAINT "PK_9f18151d14f736574f1c402d20c" PRIMARY KEY (id);


--
-- Name: zone_device_assignment UQ_acd3610c81176f2833066a61a5d; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.zone_device_assignment
    ADD CONSTRAINT "UQ_acd3610c81176f2833066a61a5d" UNIQUE ("deviceId");


--
-- Name: zones FK_15d4269069700ff13ce40dd11e1; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.zones
    ADD CONSTRAINT "FK_15d4269069700ff13ce40dd11e1" FOREIGN KEY (deployment_id) REFERENCES public.deployments(id);


--
-- Name: deployments FK_5778065f357e6901b3776c37a7f; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.deployments
    ADD CONSTRAINT "FK_5778065f357e6901b3776c37a7f" FOREIGN KEY (plant_id) REFERENCES public.plants(id);


--
-- Name: path_layers FK_63a8664c7eb3382118a6b563b42; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.path_layers
    ADD CONSTRAINT "FK_63a8664c7eb3382118a6b563b42" FOREIGN KEY (zone_id) REFERENCES public.zones(id);


--
-- Name: zone_device_assignment FK_8664fa5a0b3db477e4165794e8a; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.zone_device_assignment
    ADD CONSTRAINT "FK_8664fa5a0b3db477e4165794e8a" FOREIGN KEY ("zoneId") REFERENCES public.zones(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict Zx8AcwhAHJgRawSYJbhMFEitVX1SFPqSKaYaIALbD3w5fLNUoY2e5J778B0MU2z

