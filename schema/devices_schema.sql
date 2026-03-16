--
-- PostgreSQL database dump
--

\restrict c1g9ym6pe7Rk81NpdYGR4N3z7Ddp9fZA4IGPF2ZB3CAdy53HgksjYy8e9mcpHBx

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
-- Name: commandstatus; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.commandstatus AS ENUM (
    'pending',
    'sent',
    'delivered',
    'executed',
    'failed',
    'timeout'
);


ALTER TYPE public.commandstatus OWNER TO admin;

--
-- Name: devicestatus; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.devicestatus AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'PROVISIONING',
    'UPDATING',
    'ERROR',
    'OFFLINE'
);


ALTER TYPE public.devicestatus OWNER TO admin;

--
-- Name: mqttconnectionstatus; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.mqttconnectionstatus AS ENUM (
    'CONNECTED',
    'DISCONNECTED',
    'RECONNECTING',
    'ERROR'
);


ALTER TYPE public.mqttconnectionstatus OWNER TO admin;

--
-- Name: telemetrytype; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.telemetrytype AS ENUM (
    'TELEMETRY',
    'LOG',
    'EVENT',
    'METRIC'
);


ALTER TYPE public.telemetrytype OWNER TO admin;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
            NEW.updated_at = NOW();
            RETURN NEW;
        END;
        $$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO admin;

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
-- Name: application_versions; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.application_versions OWNER TO admin;

--
-- Name: device_commands; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.device_commands OWNER TO admin;

--
-- Name: device_telemetry; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.device_telemetry OWNER TO admin;

--
-- Name: device_tokens; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.device_tokens OWNER TO admin;

--
-- Name: devices; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.devices OWNER TO admin;

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
-- Name: mqtt_connection_logs; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.mqtt_connection_logs OWNER TO admin;

--
-- Name: packet_loss_events; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.packet_loss_events (
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    id uuid NOT NULL,
    device_id uuid NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    expected_next_counter integer NOT NULL,
    received_counter integer NOT NULL,
    packets_lost_since_last integer NOT NULL
);


ALTER TABLE public.packet_loss_events OWNER TO admin;

--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: migrations PK_8c82d7f526340ab734260ea46be; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT "PK_8c82d7f526340ab734260ea46be" PRIMARY KEY (id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: application_versions application_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.application_versions
    ADD CONSTRAINT application_versions_pkey PRIMARY KEY (id);


--
-- Name: device_commands device_commands_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.device_commands
    ADD CONSTRAINT device_commands_pkey PRIMARY KEY (id);


--
-- Name: device_telemetry device_telemetry_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.device_telemetry
    ADD CONSTRAINT device_telemetry_pkey PRIMARY KEY (id);


--
-- Name: device_tokens device_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_pkey PRIMARY KEY (id);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: mqtt_connection_logs mqtt_connection_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.mqtt_connection_logs
    ADD CONSTRAINT mqtt_connection_logs_pkey PRIMARY KEY (id);


--
-- Name: packet_loss_events packet_loss_events_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.packet_loss_events
    ADD CONSTRAINT packet_loss_events_pkey PRIMARY KEY (id);


--
-- Name: idx_device_telemetry_timestamp; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_device_telemetry_timestamp ON public.device_telemetry USING btree (device_id, "timestamp");


--
-- Name: idx_telemetry_type_name; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_telemetry_type_name ON public.device_telemetry USING btree (type, name);


--
-- Name: ix_application_versions_application_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_application_versions_application_id ON public.application_versions USING btree (application_id);


--
-- Name: ix_application_versions_version; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_application_versions_version ON public.application_versions USING btree (version);


--
-- Name: ix_device_commands_device_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_device_commands_device_id ON public.device_commands USING btree (device_id);


--
-- Name: ix_device_telemetry_device_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_device_telemetry_device_id ON public.device_telemetry USING btree (device_id);


--
-- Name: ix_device_telemetry_name; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_device_telemetry_name ON public.device_telemetry USING btree (name);


--
-- Name: ix_device_telemetry_timestamp; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_device_telemetry_timestamp ON public.device_telemetry USING btree ("timestamp");


--
-- Name: ix_device_tokens_device_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_device_tokens_device_id ON public.device_tokens USING btree (device_id);


--
-- Name: ix_device_tokens_token_hash; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX ix_device_tokens_token_hash ON public.device_tokens USING btree (token_hash);


--
-- Name: ix_devices_application_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_devices_application_id ON public.devices USING btree (application_id);


--
-- Name: ix_devices_application_version_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_devices_application_version_id ON public.devices USING btree (application_version_id);


--
-- Name: ix_devices_customer_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_devices_customer_id ON public.devices USING btree (customer_id);


--
-- Name: ix_devices_endpoint_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX ix_devices_endpoint_id ON public.devices USING btree (endpoint_id);


--
-- Name: ix_devices_name; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_devices_name ON public.devices USING btree (name);


--
-- Name: ix_mqtt_connection_logs_timestamp; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_mqtt_connection_logs_timestamp ON public.mqtt_connection_logs USING btree ("timestamp");


--
-- Name: ix_packet_loss_events_device_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX ix_packet_loss_events_device_id ON public.packet_loss_events USING btree (device_id);


--
-- Name: device_commands update_device_commands_updated_at; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER update_device_commands_updated_at BEFORE UPDATE ON public.device_commands FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: device_commands device_commands_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.device_commands
    ADD CONSTRAINT device_commands_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id);


--
-- Name: device_telemetry device_telemetry_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.device_telemetry
    ADD CONSTRAINT device_telemetry_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id);


--
-- Name: device_tokens device_tokens_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id);


--
-- Name: packet_loss_events packet_loss_events_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.packet_loss_events
    ADD CONSTRAINT packet_loss_events_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id);


--
-- PostgreSQL database dump complete
--

\unrestrict c1g9ym6pe7Rk81NpdYGR4N3z7Ddp9fZA4IGPF2ZB3CAdy53HgksjYy8e9mcpHBx

