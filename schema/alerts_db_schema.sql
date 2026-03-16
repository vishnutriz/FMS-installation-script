--
-- PostgreSQL database dump
--

\restrict UJeabjuH9G0ZvayM0X9FsIABwgq41hMUbEUjoglEMlhe4zCKObpdTrA03o1Ghcu

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
-- Name: alert_conditions_operator_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.alert_conditions_operator_enum AS ENUM (
    'eq',
    'neq',
    'gt',
    'gte',
    'lt',
    'lte',
    'contains',
    'startsWith',
    'endsWith',
    'is_not_null'
);


ALTER TYPE public.alert_conditions_operator_enum OWNER TO postgres;

--
-- Name: alerts_severity_enum; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.alerts_severity_enum AS ENUM (
    'low',
    'medium',
    'high',
    'critical'
);


ALTER TYPE public.alerts_severity_enum OWNER TO admin;

--
-- Name: alerts_triggertype_enum; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.alerts_triggertype_enum AS ENUM (
    'schedule',
    'continuous_check'
);


ALTER TYPE public.alerts_triggertype_enum OWNER TO admin;

--
-- Name: triggered_alerts_status_enum; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.triggered_alerts_status_enum AS ENUM (
    'active',
    'acknowledged',
    'resolved'
);


ALTER TYPE public.triggered_alerts_status_enum OWNER TO admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alert_conditions; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.alert_conditions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    field character varying(100) NOT NULL,
    operator public.alert_conditions_operator_enum NOT NULL,
    value character varying NOT NULL,
    "logicalOperator" character varying(10),
    "alertId" uuid NOT NULL,
    "order" integer NOT NULL
);


ALTER TABLE public.alert_conditions OWNER TO admin;

--
-- Name: alert_triggers; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.alert_triggers (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "triggeredAt" timestamp with time zone DEFAULT now() NOT NULL,
    "metricData" jsonb NOT NULL,
    "deviceId" uuid NOT NULL,
    "deviceName" character varying(255),
    "alertName" character varying(255) NOT NULL,
    severity character varying(50) NOT NULL,
    "alertId" uuid NOT NULL,
    "triggerCount" integer DEFAULT 1 NOT NULL,
    "lastUpdatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    status character varying DEFAULT 'active'::character varying NOT NULL,
    "position" jsonb
);


ALTER TABLE public.alert_triggers OWNER TO admin;

--
-- Name: alerts; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.alerts (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    application character varying(100) NOT NULL,
    customer_id character varying(100) NOT NULL,
    devices jsonb,
    severity public.alerts_severity_enum DEFAULT 'medium'::public.alerts_severity_enum NOT NULL,
    "triggerType" public.alerts_triggertype_enum NOT NULL,
    schedule jsonb,
    alert_status boolean DEFAULT true NOT NULL,
    actions jsonb DEFAULT '[]'::jsonb NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    "lastTriggeredAt" timestamp with time zone,
    "triggerCount" integer DEFAULT 0 NOT NULL,
    "cooldownPeriod" integer DEFAULT 300,
    application_version jsonb,
    save_position boolean DEFAULT false NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL
);


ALTER TABLE public.alerts OWNER TO admin;

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
-- Name: triggered_alerts; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.triggered_alerts (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "alertId" uuid NOT NULL,
    "deviceId" uuid NOT NULL,
    "metricValues" jsonb DEFAULT '{}'::jsonb NOT NULL,
    status public.triggered_alerts_status_enum DEFAULT 'active'::public.triggered_alerts_status_enum NOT NULL,
    acknowledged boolean DEFAULT false NOT NULL,
    count integer DEFAULT 1 NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    "resolvedAt" timestamp with time zone
);


ALTER TABLE public.triggered_alerts OWNER TO admin;

--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: triggered_alerts PK_1c1dcfae594fa1c57725efff389; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.triggered_alerts
    ADD CONSTRAINT "PK_1c1dcfae594fa1c57725efff389" PRIMARY KEY (id);


--
-- Name: alert_conditions PK_280a963fa1fb3293cff994dcc6a; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.alert_conditions
    ADD CONSTRAINT "PK_280a963fa1fb3293cff994dcc6a" PRIMARY KEY (id);


--
-- Name: alerts PK_60f895662df096bfcdfab7f4b96; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT "PK_60f895662df096bfcdfab7f4b96" PRIMARY KEY (id);


--
-- Name: alert_triggers PK_8a7ba06f20359a3ed5a86f5c3fc; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.alert_triggers
    ADD CONSTRAINT "PK_8a7ba06f20359a3ed5a86f5c3fc" PRIMARY KEY (id);


--
-- Name: migrations PK_8c82d7f526340ab734260ea46be; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT "PK_8c82d7f526340ab734260ea46be" PRIMARY KEY (id);


--
-- Name: triggered_alerts FK_4d2599477c8b9a22dfe410f27a6; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.triggered_alerts
    ADD CONSTRAINT "FK_4d2599477c8b9a22dfe410f27a6" FOREIGN KEY ("alertId") REFERENCES public.alerts(id) ON DELETE CASCADE;


--
-- Name: alert_conditions FK_85580af3e70a1323e52afeda39f; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.alert_conditions
    ADD CONSTRAINT "FK_85580af3e70a1323e52afeda39f" FOREIGN KEY ("alertId") REFERENCES public.alerts(id) ON DELETE CASCADE;


--
-- Name: alert_triggers FK_a55489709c7989bbaa3df3243a9; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.alert_triggers
    ADD CONSTRAINT "FK_a55489709c7989bbaa3df3243a9" FOREIGN KEY ("alertId") REFERENCES public.alerts(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict UJeabjuH9G0ZvayM0X9FsIABwgq41hMUbEUjoglEMlhe4zCKObpdTrA03o1Ghcu

