--
-- PostgreSQL database cluster dump
--

\restrict 5EGIftb9F2Je05gORq4kT8ZqvqOfK0hwBpxetQ7UfqlC9u7Ipz3VBDwihLIetLB

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE admin;
ALTER ROLE admin WITH SUPERUSER INHERIT NOCREATEROLE CREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:gSv2nliXb7xDizI5jVjFlQ==$jcSntb9ws09CwQ4EZIVa03mZg3+M31jfH1GB0SW1344=:oxz72mP6NKQ5QyfZ+VO/d2mvQ3bp9WKrMFMpbVILxZM=';
CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:fsbvxbjOUOK/VkiUEpUrYw==$h3ZIE/3GUhhJMduSUynNmsRs93oV+R/K/heUCpmzPQs=:mtROyEOA+AoWbEJjfYFrdv/0GFt3Gt7UsvsoZ7dDww0=';






\unrestrict 5EGIftb9F2Je05gORq4kT8ZqvqOfK0hwBpxetQ7UfqlC9u7Ipz3VBDwihLIetLB

--
-- Databases
--

--
-- Database "template1" dump
--

\connect template1

--
-- PostgreSQL database dump
--

\restrict DYiLwX7KL1qZdfmkrwNKKvfl2WJaNtwzMDE3gGLnS8wsu2gSoGCqyigVpwysk9i

-- Dumped from database version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)

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
-- PostgreSQL database dump complete
--

\unrestrict DYiLwX7KL1qZdfmkrwNKKvfl2WJaNtwzMDE3gGLnS8wsu2gSoGCqyigVpwysk9i

--
-- Database "alerts_db" dump
--

--
-- PostgreSQL database dump
--

\restrict qcFIOMNlinp9uG3lOMAAxgWIIrxW7eHRVd7FjXMkzlTzNDOKRHOi8gMhHdjUlZr

-- Dumped from database version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)

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
-- Name: alerts_db; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE alerts_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_IN';


\unrestrict qcFIOMNlinp9uG3lOMAAxgWIIrxW7eHRVd7FjXMkzlTzNDOKRHOi8gMhHdjUlZr
\connect alerts_db
\restrict qcFIOMNlinp9uG3lOMAAxgWIIrxW7eHRVd7FjXMkzlTzNDOKRHOi8gMhHdjUlZr

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
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: alert_conditions_operator_enum; Type: TYPE; Schema: public; Owner: -
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
    'endsWith'
);


--
-- Name: alerts_severity_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.alerts_severity_enum AS ENUM (
    'low',
    'medium',
    'high',
    'critical'
);


--
-- Name: alerts_triggertype_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.alerts_triggertype_enum AS ENUM (
    'schedule',
    'continuous_check'
);


--
-- Name: triggered_alerts_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.triggered_alerts_status_enum AS ENUM (
    'active',
    'acknowledged',
    'resolved'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alert_conditions; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: alert_triggers; Type: TABLE; Schema: public; Owner: -
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
    status character varying DEFAULT 'active'::character varying NOT NULL
);


--
-- Name: alerts; Type: TABLE; Schema: public; Owner: -
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
    "isActive" boolean DEFAULT true NOT NULL,
    alert_status boolean DEFAULT true NOT NULL,
    actions jsonb DEFAULT '[]'::jsonb NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    "lastTriggeredAt" timestamp with time zone,
    "triggerCount" integer DEFAULT 0 NOT NULL,
    "cooldownPeriod" integer DEFAULT 300
);


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    "timestamp" bigint NOT NULL,
    name character varying NOT NULL
);


--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: triggered_alerts; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: triggered_alerts PK_1c1dcfae594fa1c57725efff389; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.triggered_alerts
    ADD CONSTRAINT "PK_1c1dcfae594fa1c57725efff389" PRIMARY KEY (id);


--
-- Name: alert_conditions PK_280a963fa1fb3293cff994dcc6a; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_conditions
    ADD CONSTRAINT "PK_280a963fa1fb3293cff994dcc6a" PRIMARY KEY (id);


--
-- Name: alerts PK_60f895662df096bfcdfab7f4b96; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT "PK_60f895662df096bfcdfab7f4b96" PRIMARY KEY (id);


--
-- Name: alert_triggers PK_8a7ba06f20359a3ed5a86f5c3fc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_triggers
    ADD CONSTRAINT "PK_8a7ba06f20359a3ed5a86f5c3fc" PRIMARY KEY (id);


--
-- Name: migrations PK_8c82d7f526340ab734260ea46be; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT "PK_8c82d7f526340ab734260ea46be" PRIMARY KEY (id);


--
-- Name: triggered_alerts FK_4d2599477c8b9a22dfe410f27a6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.triggered_alerts
    ADD CONSTRAINT "FK_4d2599477c8b9a22dfe410f27a6" FOREIGN KEY ("alertId") REFERENCES public.alerts(id) ON DELETE CASCADE;


--
-- Name: alert_conditions FK_85580af3e70a1323e52afeda39f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_conditions
    ADD CONSTRAINT "FK_85580af3e70a1323e52afeda39f" FOREIGN KEY ("alertId") REFERENCES public.alerts(id) ON DELETE CASCADE;


--
-- Name: alert_triggers FK_a55489709c7989bbaa3df3243a9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_triggers
    ADD CONSTRAINT "FK_a55489709c7989bbaa3df3243a9" FOREIGN KEY ("alertId") REFERENCES public.alerts(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict qcFIOMNlinp9uG3lOMAAxgWIIrxW7eHRVd7FjXMkzlTzNDOKRHOi8gMhHdjUlZr

--
-- Database "application_db" dump
--

--
-- PostgreSQL database dump
--

\restrict RA4k9RM8X16klYqW689y9cu94d2Rfr8gqXKinGA1yZqYeQeaouDg6JYpVIMpUN8

-- Dumped from database version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)

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
-- Name: application_db; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE application_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.UTF-8';


\unrestrict RA4k9RM8X16klYqW689y9cu94d2Rfr8gqXKinGA1yZqYeQeaouDg6JYpVIMpUN8
\connect application_db
\restrict RA4k9RM8X16klYqW689y9cu94d2Rfr8gqXKinGA1yZqYeQeaouDg6JYpVIMpUN8

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
-- PostgreSQL database dump complete
--

\unrestrict RA4k9RM8X16klYqW689y9cu94d2Rfr8gqXKinGA1yZqYeQeaouDg6JYpVIMpUN8

--
-- Database "applications" dump
--

--
-- PostgreSQL database dump
--

\restrict B1ysKlajZPpUwbdqQJ2AQ7DKacqEVtnG8PaNCLdszUiUhYUl8HdZm9UHXebxQir

-- Dumped from database version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)

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
-- Name: applications; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE applications WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.UTF-8';


\unrestrict B1ysKlajZPpUwbdqQJ2AQ7DKacqEVtnG8PaNCLdszUiUhYUl8HdZm9UHXebxQir
\connect applications
\restrict B1ysKlajZPpUwbdqQJ2AQ7DKacqEVtnG8PaNCLdszUiUhYUl8HdZm9UHXebxQir

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
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


--
-- Name: applications; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
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
    mission_details jsonb
);


--
-- Name: versions UQ_b551ed60613c1c39655a77ffef8; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT "UQ_b551ed60613c1c39655a77ffef8" UNIQUE (application_version_id);


--
-- Name: applications UQ_fcdfc51648dfbc8cfa417d6c3fc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT "UQ_fcdfc51648dfbc8cfa417d6c3fc" UNIQUE (name);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: applications applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: IDX_7ab97e23f4482c78e873c8424b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_7ab97e23f4482c78e873c8424b" ON public.applications USING btree (customer_id);


--
-- Name: IDX_b551ed60613c1c39655a77ffef; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_b551ed60613c1c39655a77ffef" ON public.versions USING btree (application_version_id);


--
-- Name: IDX_d18469031b39e2058c5d076302; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_d18469031b39e2058c5d076302" ON public.versions USING btree (application_id);


--
-- Name: versions FK_d18469031b39e2058c5d076302d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT "FK_d18469031b39e2058c5d076302d" FOREIGN KEY (application_id) REFERENCES public.applications(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict B1ysKlajZPpUwbdqQJ2AQ7DKacqEVtnG8PaNCLdszUiUhYUl8HdZm9UHXebxQir

--
-- Database "central_ota_db" dump
--

--
-- PostgreSQL database dump
--

\restrict MvpMAnfDHg4aThdbG5D30GPCyXzXdW9bXDZbCdimMg69XzBfCWre095wny9njaj

-- Dumped from database version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)

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
-- Name: central_ota_db; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE central_ota_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_IN';


\unrestrict MvpMAnfDHg4aThdbG5D30GPCyXzXdW9bXDZbCdimMg69XzBfCWre095wny9njaj
\connect central_ota_db
\restrict MvpMAnfDHg4aThdbG5D30GPCyXzXdW9bXDZbCdimMg69XzBfCWre095wny9njaj

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
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: campaign_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.campaign_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'PAUSED',
    'COMPLETED'
);


--
-- Name: campaign_targettype_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.campaign_targettype_enum AS ENUM (
    'ALL_CUSTOMERS',
    'SPECIFIC'
);


--
-- Name: update_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.update_status_enum AS ENUM (
    'DRAFT',
    'READY',
    'ARCHIVED'
);


--
-- Name: update_updatetype_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.update_updatetype_enum AS ENUM (
    'MAJOR',
    'MINOR',
    'PATCH'
);


--
-- Name: user_role_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_role_enum AS ENUM (
    'admin',
    'user'
);


--
-- Name: users_role_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.users_role_enum AS ENUM (
    'super_admin',
    'admin',
    'operator',
    'user'
);


--
-- Name: users_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.users_status_enum AS ENUM (
    'active',
    'inactive'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: campaign; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.campaign (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    "updateId" uuid NOT NULL,
    status public.campaign_status_enum DEFAULT 'DRAFT'::public.campaign_status_enum NOT NULL,
    "targetType" public.campaign_targettype_enum DEFAULT 'SPECIFIC'::public.campaign_targettype_enum NOT NULL,
    "targetCustomerIds" text,
    "forceDowngrade" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: customer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "customerId" character varying NOT NULL,
    "companyName" character varying NOT NULL,
    "contactEmail" character varying,
    "contactPhone" character varying,
    "ipAddress" character varying,
    "currentVersion" character varying,
    status character varying DEFAULT 'active'::character varying NOT NULL,
    "lastHeartbeat" timestamp without time zone,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "productId" character varying
);


--
-- Name: device; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.device (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "deviceId" character varying NOT NULL,
    name character varying,
    "ipAddress" character varying,
    "currentVersion" character varying,
    status character varying,
    "lastHeartbeat" timestamp without time zone,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "companyName" character varying
);


--
-- Name: installation_report; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.installation_report (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "updateVersion" character varying NOT NULL,
    "customerId" character varying NOT NULL,
    status character varying NOT NULL,
    logs text,
    "installedAt" timestamp without time zone,
    "reportedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "companyName" character varying,
    "detectedAt" timestamp without time zone,
    "downloadedAt" timestamp without time zone,
    "campaignName" character varying
);


--
-- Name: product; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    code character varying NOT NULL,
    description character varying,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: published_update; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.published_update (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    version character varying NOT NULL,
    "updateName" character varying NOT NULL,
    description character varying NOT NULL,
    "packageUrl" character varying NOT NULL,
    "scriptUrl" character varying NOT NULL,
    services text,
    "releaseDate" timestamp without time zone DEFAULT now() NOT NULL,
    "targetCustomers" text,
    "targetAll" boolean DEFAULT false NOT NULL,
    priority character varying DEFAULT 'normal'::character varying NOT NULL
);


--
-- Name: service; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.service (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    code character varying NOT NULL,
    "productId" uuid NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "userId" uuid NOT NULL,
    "refreshTokenHash" character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "lastUsedAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    revoked boolean DEFAULT false NOT NULL,
    "rotatedFrom" character varying
);


--
-- Name: update; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.update (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    version character varying NOT NULL,
    status public.update_status_enum DEFAULT 'DRAFT'::public.update_status_enum NOT NULL,
    "serviceId" uuid NOT NULL,
    "productId" uuid NOT NULL,
    "packageUrl" character varying NOT NULL,
    "scriptUrl" character varying,
    "updateType" public.update_updatetype_enum DEFAULT 'PATCH'::public.update_updatetype_enum NOT NULL,
    "releaseNotes" text,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: update_delivery; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.update_delivery (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "updateId" uuid NOT NULL,
    "customerId" character varying NOT NULL,
    "customerName" character varying,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    "retryCount" integer DEFAULT 0 NOT NULL,
    "lastAttempt" timestamp without time zone,
    "notifiedAt" timestamp without time zone,
    "acknowledgedAt" timestamp without time zone,
    "installedAt" timestamp without time zone,
    "errorMessage" character varying,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email character varying NOT NULL,
    username character varying,
    password character varying NOT NULL,
    "firstName" character varying,
    "lastName" character varying,
    role public.users_role_enum DEFAULT 'user'::public.users_role_enum NOT NULL,
    status public.users_status_enum DEFAULT 'active'::public.users_status_enum NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "lastLogin" timestamp without time zone,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: campaign PK_0ce34d26e7f2eb316a3a592cdc4; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign
    ADD CONSTRAINT "PK_0ce34d26e7f2eb316a3a592cdc4" PRIMARY KEY (id);


--
-- Name: installation_report PK_153d14e22aa25aa56aa89dd8834; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.installation_report
    ADD CONSTRAINT "PK_153d14e22aa25aa56aa89dd8834" PRIMARY KEY (id);


--
-- Name: published_update PK_2129cfe7571eb6d88d566ec9bbe; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.published_update
    ADD CONSTRAINT "PK_2129cfe7571eb6d88d566ec9bbe" PRIMARY KEY (id);


--
-- Name: device PK_2dc10972aa4e27c01378dad2c72; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device
    ADD CONSTRAINT "PK_2dc10972aa4e27c01378dad2c72" PRIMARY KEY (id);


--
-- Name: sessions PK_3238ef96f18b355b671619111bc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT "PK_3238ef96f18b355b671619111bc" PRIMARY KEY (id);


--
-- Name: update_delivery PK_3d3bd23ee169d2393850ff40bad; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.update_delivery
    ADD CONSTRAINT "PK_3d3bd23ee169d2393850ff40bad" PRIMARY KEY (id);


--
-- Name: update PK_575f77a0576d6293bc1cb752847; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.update
    ADD CONSTRAINT "PK_575f77a0576d6293bc1cb752847" PRIMARY KEY (id);


--
-- Name: service PK_85a21558c006647cd76fdce044b; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service
    ADD CONSTRAINT "PK_85a21558c006647cd76fdce044b" PRIMARY KEY (id);


--
-- Name: users PK_a3ffb1c0c8416b9fc6f907b7433; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "PK_a3ffb1c0c8416b9fc6f907b7433" PRIMARY KEY (id);


--
-- Name: customer PK_a7a13f4cacb744524e44dfdad32; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT "PK_a7a13f4cacb744524e44dfdad32" PRIMARY KEY (id);


--
-- Name: product PK_bebc9158e480b949565b4dc7a82; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT "PK_bebc9158e480b949565b4dc7a82" PRIMARY KEY (id);


--
-- Name: device UQ_6fe2df6e1c34fc6c18c786ca26e; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device
    ADD CONSTRAINT "UQ_6fe2df6e1c34fc6c18c786ca26e" UNIQUE ("deviceId");


--
-- Name: customer UQ_71302d30c27acbf513b3d74f81c; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT "UQ_71302d30c27acbf513b3d74f81c" UNIQUE ("customerId");


--
-- Name: users UQ_97672ac88f789774dd47f7c8be3; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "UQ_97672ac88f789774dd47f7c8be3" UNIQUE (email);


--
-- Name: product UQ_99c39b067cfa73c783f0fc49a61; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT "UQ_99c39b067cfa73c783f0fc49a61" UNIQUE (code);


--
-- Name: service FK_2ec83cb9d5dac6c246a0d59ba96; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service
    ADD CONSTRAINT "FK_2ec83cb9d5dac6c246a0d59ba96" FOREIGN KEY ("productId") REFERENCES public.product(id);


--
-- Name: sessions FK_57de40bc620f456c7311aa3a1e6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT "FK_57de40bc620f456c7311aa3a1e6" FOREIGN KEY ("userId") REFERENCES public.users(id);


--
-- Name: campaign FK_a64d0b09f04eba7e2245db850b5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign
    ADD CONSTRAINT "FK_a64d0b09f04eba7e2245db850b5" FOREIGN KEY ("updateId") REFERENCES public.update(id);


--
-- Name: update FK_c0fb4e8350f5f56fba2fdd751a3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.update
    ADD CONSTRAINT "FK_c0fb4e8350f5f56fba2fdd751a3" FOREIGN KEY ("serviceId") REFERENCES public.service(id);


--
-- Name: update_delivery FK_c30e710ec67bb7230ff7375ef5c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.update_delivery
    ADD CONSTRAINT "FK_c30e710ec67bb7230ff7375ef5c" FOREIGN KEY ("updateId") REFERENCES public.update(id) ON DELETE CASCADE;


--
-- Name: update FK_caf6ad7f048e65ca3c698072c56; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.update
    ADD CONSTRAINT "FK_caf6ad7f048e65ca3c698072c56" FOREIGN KEY ("productId") REFERENCES public.product(id);


--
-- PostgreSQL database dump complete
--

\unrestrict MvpMAnfDHg4aThdbG5D30GPCyXzXdW9bXDZbCdimMg69XzBfCWre095wny9njaj

--
-- Database "dashboard" dump
--

--
-- PostgreSQL database dump
--

\restrict Qz4lgHexxcgOXF1c09z4Ic6FtGFk0d1TpGnMDtd80kej4i3BJxhqiL6paEDHCED

-- Dumped from database version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)

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
-- Name: dashboard; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE dashboard WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_IN';


\unrestrict Qz4lgHexxcgOXF1c09z4Ic6FtGFk0d1TpGnMDtd80kej4i3BJxhqiL6paEDHCED
\connect dashboard
\restrict Qz4lgHexxcgOXF1c09z4Ic6FtGFk0d1TpGnMDtd80kej4i3BJxhqiL6paEDHCED

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: AssignedSchedulerAsset; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AssignedSchedulerAsset" (
    id text NOT NULL,
    "schedulerId" text NOT NULL,
    assets jsonb NOT NULL,
    "deploymentId" text NOT NULL,
    "zoneId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "customerId" text NOT NULL
);


--
-- Name: CustomDashboard; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CustomDashboard" (
    id text NOT NULL,
    "dashboardId" text NOT NULL,
    name text NOT NULL,
    description text,
    widgets jsonb NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "customerId" text NOT NULL
);


--
-- Name: Dashboard; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Dashboard" (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    asset jsonb NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "customerId" text NOT NULL
);


--
-- Name: Mission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Mission" (
    id text NOT NULL,
    name text NOT NULL,
    "missionId" text NOT NULL,
    "deploymentId" text NOT NULL,
    "deploymentData" jsonb,
    "zoneId" text NOT NULL,
    "zoneData" jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "customerId" text NOT NULL
);


--
-- Name: Scheduler; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Scheduler" (
    id text NOT NULL,
    "schedulerName" text NOT NULL,
    "schedulerId" text NOT NULL,
    "deploymentId" text NOT NULL,
    "zoneId" text NOT NULL,
    "missionIds" text[],
    "schedulerOption" jsonb NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "customerId" text NOT NULL
);


--
-- Name: User; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."User" (
    id text NOT NULL,
    email text NOT NULL,
    name text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: Waypoint; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Waypoint" (
    id text NOT NULL,
    "pointId" text NOT NULL,
    label text NOT NULL,
    "order" integer,
    "missionId" text NOT NULL,
    tasks jsonb NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "customerId" text NOT NULL
);


--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


--
-- Name: AssignedSchedulerAsset AssignedSchedulerAsset_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AssignedSchedulerAsset"
    ADD CONSTRAINT "AssignedSchedulerAsset_pkey" PRIMARY KEY (id);


--
-- Name: CustomDashboard CustomDashboard_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomDashboard"
    ADD CONSTRAINT "CustomDashboard_pkey" PRIMARY KEY (id);


--
-- Name: Dashboard Dashboard_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Dashboard"
    ADD CONSTRAINT "Dashboard_pkey" PRIMARY KEY (id);


--
-- Name: Mission Mission_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Mission"
    ADD CONSTRAINT "Mission_pkey" PRIMARY KEY (id);


--
-- Name: Scheduler Scheduler_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Scheduler"
    ADD CONSTRAINT "Scheduler_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: Waypoint Waypoint_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Waypoint"
    ADD CONSTRAINT "Waypoint_pkey" PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: AssignedSchedulerAsset_schedulerId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "AssignedSchedulerAsset_schedulerId_key" ON public."AssignedSchedulerAsset" USING btree ("schedulerId");


--
-- Name: CustomDashboard_dashboardId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CustomDashboard_dashboardId_key" ON public."CustomDashboard" USING btree ("dashboardId");


--
-- Name: Mission_deploymentId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Mission_deploymentId_idx" ON public."Mission" USING btree ("deploymentId");


--
-- Name: Mission_deploymentId_name_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Mission_deploymentId_name_key" ON public."Mission" USING btree ("deploymentId", name);


--
-- Name: Mission_missionId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Mission_missionId_key" ON public."Mission" USING btree ("missionId");


--
-- Name: Mission_zoneId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Mission_zoneId_idx" ON public."Mission" USING btree ("zoneId");


--
-- Name: Scheduler_deploymentId_schedulerName_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Scheduler_deploymentId_schedulerName_key" ON public."Scheduler" USING btree ("deploymentId", "schedulerName");


--
-- Name: Scheduler_schedulerId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Scheduler_schedulerId_key" ON public."Scheduler" USING btree ("schedulerId");


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: Waypoint_missionId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Waypoint_missionId_idx" ON public."Waypoint" USING btree ("missionId");


--
-- Name: Waypoint_missionId_pointId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Waypoint_missionId_pointId_key" ON public."Waypoint" USING btree ("missionId", "pointId");


--
-- Name: AssignedSchedulerAsset AssignedSchedulerAsset_schedulerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AssignedSchedulerAsset"
    ADD CONSTRAINT "AssignedSchedulerAsset_schedulerId_fkey" FOREIGN KEY ("schedulerId") REFERENCES public."Scheduler"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CustomDashboard CustomDashboard_dashboardId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomDashboard"
    ADD CONSTRAINT "CustomDashboard_dashboardId_fkey" FOREIGN KEY ("dashboardId") REFERENCES public."Dashboard"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Waypoint Waypoint_missionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Waypoint"
    ADD CONSTRAINT "Waypoint_missionId_fkey" FOREIGN KEY ("missionId") REFERENCES public."Mission"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict Qz4lgHexxcgOXF1c09z4Ic6FtGFk0d1TpGnMDtd80kej4i3BJxhqiL6paEDHCED

--
-- Database "deployment" dump
--

--
-- PostgreSQL database dump
--

\restrict tO2y0k7WdCdzYdORV87diw9OmBUArBtX06YnBQ9DXAO6mWyHNV2IAc8G4L40MWP

-- Dumped from database version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)

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
-- Name: deployment; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE deployment WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_IN';


\unrestrict tO2y0k7WdCdzYdORV87diw9OmBUArBtX06YnBQ9DXAO6mWyHNV2IAc8G4L40MWP
\connect deployment
\restrict tO2y0k7WdCdzYdORV87diw9OmBUArBtX06YnBQ9DXAO6mWyHNV2IAc8G4L40MWP

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
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: deployments; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    "timestamp" bigint NOT NULL,
    name character varying NOT NULL
);


--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: path_layers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.path_layers (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    zone_id uuid NOT NULL,
    "pathData" jsonb NOT NULL,
    version integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    "junctionPaths" jsonb,
    "internalPathData" jsonb DEFAULT '{}'::jsonb NOT NULL,
    "wallAreas" jsonb,
    map_version integer,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: plants; Type: TABLE; Schema: public; Owner: -
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
    contact_person character varying NOT NULL,
    contact_email character varying NOT NULL,
    contact_phone character varying NOT NULL,
    customer_id uuid NOT NULL,
    plant_image character varying,
    description character varying,
    pixel_per_meter double precision,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: zone_device_assignment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.zone_device_assignment (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "zoneId" uuid,
    "deviceId" character varying NOT NULL,
    "deviceName" character varying,
    "mapAssigned" character varying NOT NULL,
    "pathAssigned" character varying NOT NULL,
    applicationid character varying,
    "assignedAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: zones; Type: TABLE; Schema: public; Owner: -
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
    plant_image character varying,
    origin jsonb,
    starting_point jsonb,
    map_version integer,
    digital_twin jsonb,
    pixel_per_meter double precision,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: deployments PK_1e5627acb3c950deb83fe98fc48; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deployments
    ADD CONSTRAINT "PK_1e5627acb3c950deb83fe98fc48" PRIMARY KEY (id);


--
-- Name: path_layers PK_6cb1d91368fe18f128f5e5dc4be; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.path_layers
    ADD CONSTRAINT "PK_6cb1d91368fe18f128f5e5dc4be" PRIMARY KEY (id);


--
-- Name: plants PK_7056d6b283b48ee2bb0e53bee60; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plants
    ADD CONSTRAINT "PK_7056d6b283b48ee2bb0e53bee60" PRIMARY KEY (id);


--
-- Name: zones PK_880484a43ca311707b05895bd4a; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zones
    ADD CONSTRAINT "PK_880484a43ca311707b05895bd4a" PRIMARY KEY (id);


--
-- Name: migrations PK_8c82d7f526340ab734260ea46be; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT "PK_8c82d7f526340ab734260ea46be" PRIMARY KEY (id);


--
-- Name: zone_device_assignment PK_9f18151d14f736574f1c402d20c; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zone_device_assignment
    ADD CONSTRAINT "PK_9f18151d14f736574f1c402d20c" PRIMARY KEY (id);


--
-- Name: zone_device_assignment UQ_acd3610c81176f2833066a61a5d; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zone_device_assignment
    ADD CONSTRAINT "UQ_acd3610c81176f2833066a61a5d" UNIQUE ("deviceId");


--
-- Name: zones FK_15d4269069700ff13ce40dd11e1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zones
    ADD CONSTRAINT "FK_15d4269069700ff13ce40dd11e1" FOREIGN KEY (deployment_id) REFERENCES public.deployments(id);


--
-- Name: deployments FK_5778065f357e6901b3776c37a7f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deployments
    ADD CONSTRAINT "FK_5778065f357e6901b3776c37a7f" FOREIGN KEY (plant_id) REFERENCES public.plants(id);


--
-- Name: path_layers FK_63a8664c7eb3382118a6b563b42; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.path_layers
    ADD CONSTRAINT "FK_63a8664c7eb3382118a6b563b42" FOREIGN KEY (zone_id) REFERENCES public.zones(id);


--
-- Name: zone_device_assignment FK_8664fa5a0b3db477e4165794e8a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zone_device_assignment
    ADD CONSTRAINT "FK_8664fa5a0b3db477e4165794e8a" FOREIGN KEY ("zoneId") REFERENCES public.zones(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict tO2y0k7WdCdzYdORV87diw9OmBUArBtX06YnBQ9DXAO6mWyHNV2IAc8G4L40MWP

--
-- Database "device_db" dump
--

--
-- PostgreSQL database dump
--

\restrict rHyYP4PZgTgUypRIEhfEqCD4HYoFeuqHwDxnGZDmlKlOMkXLU8X9WQsmFeRN8bS

-- Dumped from database version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)

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
-- Name: device_db; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE device_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.UTF-8';


\unrestrict rHyYP4PZgTgUypRIEhfEqCD4HYoFeuqHwDxnGZDmlKlOMkXLU8X9WQsmFeRN8bS
\connect device_db
\restrict rHyYP4PZgTgUypRIEhfEqCD4HYoFeuqHwDxnGZDmlKlOMkXLU8X9WQsmFeRN8bS

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
-- PostgreSQL database dump complete
--

\unrestrict rHyYP4PZgTgUypRIEhfEqCD4HYoFeuqHwDxnGZDmlKlOMkXLU8X9WQsmFeRN8bS

--
-- Database "device_service" dump
--

--
-- PostgreSQL database dump
--

\restrict Pruk3wxgcgou4dNoIrg4vyEpcLzcLfV6FafZdCSFpgJS1I8mlW39e9vwZS0LIr5

-- Dumped from database version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)

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
-- Name: device_service; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE device_service WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.UTF-8';


\unrestrict Pruk3wxgcgou4dNoIrg4vyEpcLzcLfV6FafZdCSFpgJS1I8mlW39e9vwZS0LIr5
\connect device_service
\restrict Pruk3wxgcgou4dNoIrg4vyEpcLzcLfV6FafZdCSFpgJS1I8mlW39e9vwZS0LIr5

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
-- PostgreSQL database dump complete
--

\unrestrict Pruk3wxgcgou4dNoIrg4vyEpcLzcLfV6FafZdCSFpgJS1I8mlW39e9vwZS0LIr5

--
-- Database "devices" dump
--

--
-- PostgreSQL database dump
--

\restrict TWhCtyaDY6q2lKoipGphUasbvolyJDfJX4r1MAf1dtQz6oyRT1r4keB8Zxrpqge

-- Dumped from database version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)

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
-- Name: devices; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE devices WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.UTF-8';


\unrestrict TWhCtyaDY6q2lKoipGphUasbvolyJDfJX4r1MAf1dtQz6oyRT1r4keB8Zxrpqge
\connect devices
\restrict TWhCtyaDY6q2lKoipGphUasbvolyJDfJX4r1MAf1dtQz6oyRT1r4keB8Zxrpqge

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
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: commandstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.commandstatus AS ENUM (
    'pending',
    'sent',
    'delivered',
    'executed',
    'failed',
    'timeout'
);


--
-- Name: devicestatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.devicestatus AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'PROVISIONING',
    'UPDATING',
    'ERROR',
    'OFFLINE'
);


--
-- Name: mqttconnectionstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.mqttconnectionstatus AS ENUM (
    'CONNECTED',
    'DISCONNECTED',
    'RECONNECTING',
    'ERROR'
);


--
-- Name: telemetrytype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.telemetrytype AS ENUM (
    'TELEMETRY',
    'LOG',
    'EVENT',
    'METRIC'
);


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
            NEW.updated_at = NOW();
            RETURN NEW;
        END;
        $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


--
-- Name: application_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_versions (
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    id uuid NOT NULL,
    application_id uuid NOT NULL,
    version character varying NOT NULL,
    description character varying,
    is_active boolean NOT NULL,
    app_metadata jsonb
);


--
-- Name: device_commands; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.device_commands (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    device_id uuid NOT NULL,
    command character varying(100) NOT NULL,
    payload json NOT NULL,
    status character varying(20) DEFAULT 'pending'::public.commandstatus NOT NULL,
    sent_at timestamp without time zone NOT NULL,
    delivered_at timestamp without time zone,
    completed_at timestamp without time zone,
    response json,
    error text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    retry_count integer DEFAULT 0 NOT NULL,
    max_retries integer DEFAULT 3 NOT NULL,
    next_retry_at timestamp without time zone
);


--
-- Name: device_telemetry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.device_telemetry (
    id uuid NOT NULL,
    device_id uuid NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    type public.telemetrytype NOT NULL,
    name character varying NOT NULL,
    value jsonb NOT NULL,
    telemetry_metadata jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: device_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.device_tokens (
    id uuid NOT NULL,
    device_id uuid NOT NULL,
    token_hash character varying NOT NULL,
    encrypted_token character varying NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone NOT NULL,
    last_used timestamp without time zone,
    expires_at timestamp without time zone,
    is_active boolean
);


--
-- Name: devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.devices (
    id uuid NOT NULL,
    name character varying NOT NULL,
    endpoint_id character varying NOT NULL,
    application_id uuid NOT NULL,
    customer_id uuid NOT NULL,
    application_version_id character varying NOT NULL,
    status public.devicestatus NOT NULL,
    last_seen timestamp without time zone,
    device_metadata jsonb,
    location jsonb,
    firmware_version character varying,
    hardware_model character varying,
    is_online boolean NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    "timestamp" bigint NOT NULL,
    name character varying NOT NULL
);


--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: mqtt_connection_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mqtt_connection_logs (
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    id uuid NOT NULL,
    status public.mqttconnectionstatus NOT NULL,
    error_message text,
    "timestamp" timestamp without time zone NOT NULL,
    broker_host character varying,
    broker_port character varying,
    client_id character varying
);


--
-- Name: packet_loss_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.packet_loss_events (
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    id uuid NOT NULL,
    device_id uuid NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    last_counter integer NOT NULL,
    current_counter integer NOT NULL,
    lost_count integer NOT NULL
);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: migrations PK_8c82d7f526340ab734260ea46be; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT "PK_8c82d7f526340ab734260ea46be" PRIMARY KEY (id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: application_versions application_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_versions
    ADD CONSTRAINT application_versions_pkey PRIMARY KEY (id);


--
-- Name: device_commands device_commands_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device_commands
    ADD CONSTRAINT device_commands_pkey PRIMARY KEY (id);


--
-- Name: device_telemetry device_telemetry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device_telemetry
    ADD CONSTRAINT device_telemetry_pkey PRIMARY KEY (id);


--
-- Name: device_tokens device_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_pkey PRIMARY KEY (id);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: mqtt_connection_logs mqtt_connection_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mqtt_connection_logs
    ADD CONSTRAINT mqtt_connection_logs_pkey PRIMARY KEY (id);


--
-- Name: packet_loss_events packet_loss_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.packet_loss_events
    ADD CONSTRAINT packet_loss_events_pkey PRIMARY KEY (id);


--
-- Name: idx_device_telemetry_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_device_telemetry_timestamp ON public.device_telemetry USING btree (device_id, "timestamp");


--
-- Name: idx_telemetry_type_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_telemetry_type_name ON public.device_telemetry USING btree (type, name);


--
-- Name: ix_application_versions_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_application_versions_application_id ON public.application_versions USING btree (application_id);


--
-- Name: ix_application_versions_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_application_versions_version ON public.application_versions USING btree (version);


--
-- Name: ix_device_commands_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_device_commands_device_id ON public.device_commands USING btree (device_id);


--
-- Name: ix_device_telemetry_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_device_telemetry_device_id ON public.device_telemetry USING btree (device_id);


--
-- Name: ix_device_telemetry_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_device_telemetry_name ON public.device_telemetry USING btree (name);


--
-- Name: ix_device_telemetry_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_device_telemetry_timestamp ON public.device_telemetry USING btree ("timestamp");


--
-- Name: ix_device_tokens_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_device_tokens_device_id ON public.device_tokens USING btree (device_id);


--
-- Name: ix_device_tokens_token_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_device_tokens_token_hash ON public.device_tokens USING btree (token_hash);


--
-- Name: ix_devices_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_devices_application_id ON public.devices USING btree (application_id);


--
-- Name: ix_devices_application_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_devices_application_version_id ON public.devices USING btree (application_version_id);


--
-- Name: ix_devices_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_devices_customer_id ON public.devices USING btree (customer_id);


--
-- Name: ix_devices_endpoint_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_devices_endpoint_id ON public.devices USING btree (endpoint_id);


--
-- Name: ix_devices_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_devices_name ON public.devices USING btree (name);


--
-- Name: ix_mqtt_connection_logs_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_mqtt_connection_logs_timestamp ON public.mqtt_connection_logs USING btree ("timestamp");


--
-- Name: ix_packet_loss_events_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_packet_loss_events_device_id ON public.packet_loss_events USING btree (device_id);


--
-- Name: device_commands update_device_commands_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_device_commands_updated_at BEFORE UPDATE ON public.device_commands FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: device_commands device_commands_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device_commands
    ADD CONSTRAINT device_commands_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id);


--
-- Name: device_telemetry device_telemetry_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device_telemetry
    ADD CONSTRAINT device_telemetry_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id);


--
-- Name: device_tokens device_tokens_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id);


--
-- Name: packet_loss_events packet_loss_events_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.packet_loss_events
    ADD CONSTRAINT packet_loss_events_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id);


--
-- PostgreSQL database dump complete
--

\unrestrict TWhCtyaDY6q2lKoipGphUasbvolyJDfJX4r1MAf1dtQz6oyRT1r4keB8Zxrpqge

--
-- Database "iotcore" dump
--

--
-- PostgreSQL database dump
--

\restrict e3yNIyUSVGOte8jUAchsSmxW10Q2goCFdeoRG9ndknbuhr82GU19JvzgopOkZOW

-- Dumped from database version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)

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
-- Name: iotcore; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE iotcore WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.UTF-8';


\unrestrict e3yNIyUSVGOte8jUAchsSmxW10Q2goCFdeoRG9ndknbuhr82GU19JvzgopOkZOW
\connect iotcore
\restrict e3yNIyUSVGOte8jUAchsSmxW10Q2goCFdeoRG9ndknbuhr82GU19JvzgopOkZOW

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
-- PostgreSQL database dump complete
--

\unrestrict e3yNIyUSVGOte8jUAchsSmxW10Q2goCFdeoRG9ndknbuhr82GU19JvzgopOkZOW

--
-- Database "missions" dump
--

--
-- PostgreSQL database dump
--

\restrict N6FxNMDXerP4aG0j4JjUDFWd6xYGwcD2mHSboKPy4UEXb8BpFg8XkNQ1ZusqnEU

-- Dumped from database version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)

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
-- Name: missions; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE missions WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.UTF-8';


\unrestrict N6FxNMDXerP4aG0j4JjUDFWd6xYGwcD2mHSboKPy4UEXb8BpFg8XkNQ1ZusqnEU
\connect missions
\restrict N6FxNMDXerP4aG0j4JjUDFWd6xYGwcD2mHSboKPy4UEXb8BpFg8XkNQ1ZusqnEU

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: AssignedSchedulerAsset; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AssignedSchedulerAsset" (
    id text NOT NULL,
    "schedulerId" text NOT NULL,
    assets jsonb NOT NULL,
    "deploymentId" text NOT NULL,
    "zoneId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "customerId" text NOT NULL
);


--
-- Name: CustomDashboard; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CustomDashboard" (
    id text NOT NULL,
    "dashboardId" text NOT NULL,
    name text NOT NULL,
    description text,
    widgets jsonb NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "customerId" text NOT NULL
);


--
-- Name: Dashboard; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Dashboard" (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    asset jsonb NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "customerId" text NOT NULL
);


--
-- Name: Mission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Mission" (
    id text NOT NULL,
    name text NOT NULL,
    "missionId" text NOT NULL,
    "deploymentId" text NOT NULL,
    "deploymentData" jsonb,
    "zoneId" text NOT NULL,
    "zoneData" jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "customerId" text NOT NULL,
    applications text[]
);


--
-- Name: Scheduler; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Scheduler" (
    id text NOT NULL,
    "schedulerName" text NOT NULL,
    "schedulerId" text NOT NULL,
    "deploymentId" text NOT NULL,
    "zoneId" text NOT NULL,
    "missionIds" text[],
    "schedulerOption" jsonb NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "customerId" text NOT NULL
);


--
-- Name: User; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."User" (
    id text NOT NULL,
    email text NOT NULL,
    name text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: Waypoint; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Waypoint" (
    id text NOT NULL,
    "pointId" text NOT NULL,
    label text NOT NULL,
    "order" integer,
    "missionId" text NOT NULL,
    tasks jsonb NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "customerId" text NOT NULL
);


--
-- Name: AssignedSchedulerAsset AssignedSchedulerAsset_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AssignedSchedulerAsset"
    ADD CONSTRAINT "AssignedSchedulerAsset_pkey" PRIMARY KEY (id);


--
-- Name: CustomDashboard CustomDashboard_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomDashboard"
    ADD CONSTRAINT "CustomDashboard_pkey" PRIMARY KEY (id);


--
-- Name: Dashboard Dashboard_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Dashboard"
    ADD CONSTRAINT "Dashboard_pkey" PRIMARY KEY (id);


--
-- Name: Mission Mission_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Mission"
    ADD CONSTRAINT "Mission_pkey" PRIMARY KEY (id);


--
-- Name: Scheduler Scheduler_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Scheduler"
    ADD CONSTRAINT "Scheduler_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: Waypoint Waypoint_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Waypoint"
    ADD CONSTRAINT "Waypoint_pkey" PRIMARY KEY (id);


--
-- Name: AssignedSchedulerAsset_schedulerId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "AssignedSchedulerAsset_schedulerId_key" ON public."AssignedSchedulerAsset" USING btree ("schedulerId");


--
-- Name: CustomDashboard_dashboardId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CustomDashboard_dashboardId_key" ON public."CustomDashboard" USING btree ("dashboardId");


--
-- Name: Mission_deploymentId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Mission_deploymentId_idx" ON public."Mission" USING btree ("deploymentId");


--
-- Name: Mission_zoneId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Mission_zoneId_idx" ON public."Mission" USING btree ("zoneId");


--
-- Name: Mission_zoneId_missionId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Mission_zoneId_missionId_key" ON public."Mission" USING btree ("zoneId", "missionId");


--
-- Name: Mission_zoneId_name_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Mission_zoneId_name_key" ON public."Mission" USING btree ("zoneId", name);


--
-- Name: Scheduler_zoneId_schedulerId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Scheduler_zoneId_schedulerId_key" ON public."Scheduler" USING btree ("zoneId", "schedulerId");


--
-- Name: Scheduler_zoneId_schedulerName_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Scheduler_zoneId_schedulerName_key" ON public."Scheduler" USING btree ("zoneId", "schedulerName");


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: Waypoint_missionId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Waypoint_missionId_idx" ON public."Waypoint" USING btree ("missionId");


--
-- Name: Waypoint_missionId_pointId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Waypoint_missionId_pointId_key" ON public."Waypoint" USING btree ("missionId", "pointId");


--
-- Name: AssignedSchedulerAsset AssignedSchedulerAsset_schedulerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AssignedSchedulerAsset"
    ADD CONSTRAINT "AssignedSchedulerAsset_schedulerId_fkey" FOREIGN KEY ("schedulerId") REFERENCES public."Scheduler"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CustomDashboard CustomDashboard_dashboardId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomDashboard"
    ADD CONSTRAINT "CustomDashboard_dashboardId_fkey" FOREIGN KEY ("dashboardId") REFERENCES public."Dashboard"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Waypoint Waypoint_missionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Waypoint"
    ADD CONSTRAINT "Waypoint_missionId_fkey" FOREIGN KEY ("missionId") REFERENCES public."Mission"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict N6FxNMDXerP4aG0j4JjUDFWd6xYGwcD2mHSboKPy4UEXb8BpFg8XkNQ1ZusqnEU

--
-- Database "ota_service" dump
--

--
-- PostgreSQL database dump
--

\restrict SGWQTQTBxFZNLUZ5OKzKJChUWS6LKV7HLV9o09904VrPMaK7XpX3R0YJTIb9d7J

-- Dumped from database version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)

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
-- Name: ota_service; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE ota_service WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_IN';


\unrestrict SGWQTQTBxFZNLUZ5OKzKJChUWS6LKV7HLV9o09904VrPMaK7XpX3R0YJTIb9d7J
\connect ota_service
\restrict SGWQTQTBxFZNLUZ5OKzKJChUWS6LKV7HLV9o09904VrPMaK7XpX3R0YJTIb9d7J

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
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: available_updates_status_enum; Type: TYPE; Schema: public; Owner: -
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


--
-- Name: customer_update_status_status_enum; Type: TYPE; Schema: public; Owner: -
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


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: available_updates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.available_updates (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    version character varying NOT NULL,
    description text,
    package_url character varying NOT NULL,
    script_url character varying NOT NULL,
    release_date timestamp with time zone,
    status public.available_updates_status_enum DEFAULT 'AVAILABLE'::public.available_updates_status_enum NOT NULL,
    download_path character varying,
    script_path character varying,
    logs text,
    download_progress integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    services text,
    "updateName" text
);


--
-- Name: customer_update_status; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: system_update_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_update_config (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    cloud_url character varying NOT NULL,
    auto_check boolean DEFAULT true NOT NULL,
    check_interval_seconds integer DEFAULT 3600 NOT NULL,
    last_checked timestamp with time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    customer_id character varying,
    company_name character varying
);


--
-- Name: available_updates PK_0b623a297284d8248fab59825e0; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.available_updates
    ADD CONSTRAINT "PK_0b623a297284d8248fab59825e0" PRIMARY KEY (id);


--
-- Name: system_update_config PK_d3a7c3a6975d6fdf1f8de78b018; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_update_config
    ADD CONSTRAINT "PK_d3a7c3a6975d6fdf1f8de78b018" PRIMARY KEY (id);


--
-- Name: customer_update_status PK_d567ea79aaa107df4be3b07dc50; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_update_status
    ADD CONSTRAINT "PK_d567ea79aaa107df4be3b07dc50" PRIMARY KEY (id);


--
-- Name: available_updates UQ_4e957c8fd6fe976e42ff0f78c8a; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.available_updates
    ADD CONSTRAINT "UQ_4e957c8fd6fe976e42ff0f78c8a" UNIQUE (version);


--
-- Name: customer_update_status FK_34f57e6e23b27f0b20d2c042e70; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_update_status
    ADD CONSTRAINT "FK_34f57e6e23b27f0b20d2c042e70" FOREIGN KEY (update_id) REFERENCES public.available_updates(id);


--
-- PostgreSQL database dump complete
--

\unrestrict SGWQTQTBxFZNLUZ5OKzKJChUWS6LKV7HLV9o09904VrPMaK7XpX3R0YJTIb9d7J

--
-- Database "postgres" dump
--

\connect postgres

--
-- PostgreSQL database dump
--

\restrict jz4w5iBrAzpuSHonzfuHFTjUUzLQNJivlVX22jCuD3SKAkEXySne3iI5OzGTEUE

-- Dumped from database version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)

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
-- PostgreSQL database dump complete
--

\unrestrict jz4w5iBrAzpuSHonzfuHFTjUUzLQNJivlVX22jCuD3SKAkEXySne3iI5OzGTEUE

--
-- Database "traffic_management" dump
--

--
-- PostgreSQL database dump
--

\restrict 9IsJ2lPbNuW8eNZphECnL5xO2pzsNJVksP6Gg2xgBsJrvszFrAuw3AecBTpmtvk

-- Dumped from database version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)

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
-- Name: traffic_management; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE traffic_management WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.UTF-8';


\unrestrict 9IsJ2lPbNuW8eNZphECnL5xO2pzsNJVksP6Gg2xgBsJrvszFrAuw3AecBTpmtvk
\connect traffic_management
\restrict 9IsJ2lPbNuW8eNZphECnL5xO2pzsNJVksP6Gg2xgBsJrvszFrAuw3AecBTpmtvk

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
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: mission_executions_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.mission_executions_status_enum AS ENUM (
    'pending',
    'planning',
    'executing',
    'paused',
    'waiting_for_action',
    'completed',
    'failed',
    'cancelled'
);


--
-- Name: paths_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.paths_status_enum AS ENUM (
    'active',
    'inactive',
    'maintenance'
);


--
-- Name: paths_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.paths_type_enum AS ENUM (
    'navigation',
    'charging',
    'service',
    'custom'
);


--
-- Name: scheduler_executions_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.scheduler_executions_status_enum AS ENUM (
    'pending',
    'running',
    'paused',
    'completed',
    'failed',
    'cancelled'
);


--
-- Name: vda5050_command_trackers_commandtype_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.vda5050_command_trackers_commandtype_enum AS ENUM (
    'order',
    'instantAction'
);


--
-- Name: vda5050_command_trackers_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.vda5050_command_trackers_status_enum AS ENUM (
    'pending',
    'sent',
    'delivered',
    'executing',
    'succeeded',
    'failed',
    'timeout'
);


--
-- Name: waypoint_executions_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.waypoint_executions_status_enum AS ENUM (
    'pending',
    'navigating',
    'executing_actions',
    'paused',
    'completed',
    'failed',
    'skipped',
    'cancelled'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: locked_segment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locked_segment (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "segmentId" character varying NOT NULL,
    "vehicleId" character varying NOT NULL
);


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    "timestamp" bigint NOT NULL,
    name character varying NOT NULL
);


--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: mission_executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mission_executions (
    id uuid NOT NULL,
    "schedulerExecutionId" uuid NOT NULL,
    "missionId" character varying NOT NULL,
    "missionName" character varying NOT NULL,
    "deviceId" character varying NOT NULL,
    "deploymentId" character varying NOT NULL,
    "zoneId" character varying NOT NULL,
    "customerId" character varying NOT NULL,
    status public.mission_executions_status_enum DEFAULT 'pending'::public.mission_executions_status_enum NOT NULL,
    "missionData" jsonb NOT NULL,
    "plannedPath" jsonb,
    "currentWaypointIndex" integer DEFAULT 0 NOT NULL,
    "totalWaypoints" integer DEFAULT 0 NOT NULL,
    "completedWaypoints" integer DEFAULT 0 NOT NULL,
    "loopIteration" integer DEFAULT 0 NOT NULL,
    metadata jsonb,
    error text,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    "startedAt" timestamp with time zone,
    "completedAt" timestamp with time zone
);


--
-- Name: paths; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.paths (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    "deviceId" uuid NOT NULL,
    waypoints jsonb NOT NULL,
    type public.paths_type_enum DEFAULT 'navigation'::public.paths_type_enum NOT NULL,
    status public.paths_status_enum DEFAULT 'active'::public.paths_status_enum NOT NULL,
    metadata jsonb,
    distance double precision DEFAULT '0'::double precision NOT NULL,
    "estimatedDuration" double precision DEFAULT '0'::double precision NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: scheduler_executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scheduler_executions (
    id uuid NOT NULL,
    "schedulerId" character varying NOT NULL,
    "schedulerName" character varying NOT NULL,
    "deploymentId" character varying NOT NULL,
    "zoneId" character varying NOT NULL,
    "customerId" character varying NOT NULL,
    "deviceId" character varying NOT NULL,
    "missionIds" text NOT NULL,
    status public.scheduler_executions_status_enum DEFAULT 'pending'::public.scheduler_executions_status_enum NOT NULL,
    "schedulerOption" jsonb NOT NULL,
    "currentLoop" integer DEFAULT 0 NOT NULL,
    "currentMissionIndex" integer DEFAULT 0 NOT NULL,
    "totalMissionsCompleted" integer DEFAULT 0 NOT NULL,
    "totalMissionsFailed" integer DEFAULT 0 NOT NULL,
    metadata jsonb,
    error text,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    "startedAt" timestamp with time zone,
    "completedAt" timestamp with time zone,
    "lastActivityAt" timestamp with time zone
);


--
-- Name: vda5050_command_trackers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vda5050_command_trackers (
    id uuid NOT NULL,
    "commandId" character varying NOT NULL,
    "commandType" public.vda5050_command_trackers_commandtype_enum NOT NULL,
    "deviceId" character varying NOT NULL,
    "schedulerExecutionId" character varying,
    "missionExecutionId" character varying,
    "waypointExecutionId" character varying,
    "commandPayload" jsonb NOT NULL,
    status public.vda5050_command_trackers_status_enum DEFAULT 'pending'::public.vda5050_command_trackers_status_enum NOT NULL,
    response jsonb,
    error text,
    "retryCount" integer DEFAULT 0 NOT NULL,
    "timeoutSeconds" integer DEFAULT 30 NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    "sentAt" timestamp with time zone,
    "deliveredAt" timestamp with time zone,
    "completedAt" timestamp with time zone,
    "timeoutAt" timestamp with time zone,
    metadata jsonb
);


--
-- Name: waypoint_executions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.waypoint_executions (
    id uuid NOT NULL,
    "missionExecutionId" uuid NOT NULL,
    "waypointId" character varying NOT NULL,
    "pointId" character varying NOT NULL,
    label character varying NOT NULL,
    "deviceId" character varying NOT NULL,
    status public.waypoint_executions_status_enum DEFAULT 'pending'::public.waypoint_executions_status_enum NOT NULL,
    "waypointData" jsonb NOT NULL,
    "navigationCompleted" boolean DEFAULT false NOT NULL,
    "navigationStartedAt" timestamp with time zone,
    "navigationCompletedAt" timestamp with time zone,
    "totalActions" integer DEFAULT 0 NOT NULL,
    "completedActions" integer DEFAULT 0 NOT NULL,
    "failedActions" integer DEFAULT 0 NOT NULL,
    "actionResults" jsonb,
    metadata jsonb,
    error text,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    "startedAt" timestamp with time zone,
    "completedAt" timestamp with time zone
);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: vda5050_command_trackers PK_0fc69e7d1c190fa3ad9e17de834; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vda5050_command_trackers
    ADD CONSTRAINT "PK_0fc69e7d1c190fa3ad9e17de834" PRIMARY KEY (id);


--
-- Name: locked_segment PK_199724e14968cdd60554b4cc20f; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locked_segment
    ADD CONSTRAINT "PK_199724e14968cdd60554b4cc20f" PRIMARY KEY (id);


--
-- Name: paths PK_3023c8d7a50ae9c50117a94e502; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paths
    ADD CONSTRAINT "PK_3023c8d7a50ae9c50117a94e502" PRIMARY KEY (id);


--
-- Name: mission_executions PK_64de19702bbadf1bf343175a06c; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mission_executions
    ADD CONSTRAINT "PK_64de19702bbadf1bf343175a06c" PRIMARY KEY (id);


--
-- Name: scheduler_executions PK_74d2c227b818f733aba6f7bce60; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduler_executions
    ADD CONSTRAINT "PK_74d2c227b818f733aba6f7bce60" PRIMARY KEY (id);


--
-- Name: migrations PK_8c82d7f526340ab734260ea46be; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT "PK_8c82d7f526340ab734260ea46be" PRIMARY KEY (id);


--
-- Name: waypoint_executions PK_af52823c4aa5fcadc2aad413eda; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.waypoint_executions
    ADD CONSTRAINT "PK_af52823c4aa5fcadc2aad413eda" PRIMARY KEY (id);


--
-- Name: waypoint_executions FK_9390e5756e19d182e55e0db05d3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.waypoint_executions
    ADD CONSTRAINT "FK_9390e5756e19d182e55e0db05d3" FOREIGN KEY ("missionExecutionId") REFERENCES public.mission_executions(id);


--
-- Name: mission_executions FK_b08a6371365e59b325c739094cc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mission_executions
    ADD CONSTRAINT "FK_b08a6371365e59b325c739094cc" FOREIGN KEY ("schedulerExecutionId") REFERENCES public.scheduler_executions(id);


--
-- PostgreSQL database dump complete
--

\unrestrict 9IsJ2lPbNuW8eNZphECnL5xO2pzsNJVksP6Gg2xgBsJrvszFrAuw3AecBTpmtvk

--
-- PostgreSQL database cluster dump complete
--

