--
-- PostgreSQL database dump
--

\restrict g6nfJgbyIEaDHwZvfwSVNNIcuI1LDbDnDt7VRwN9tb3ixq1O0KVZbD4AxlMbJFi

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
-- Name: mission_executions_status_enum; Type: TYPE; Schema: public; Owner: admin
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


ALTER TYPE public.mission_executions_status_enum OWNER TO admin;

--
-- Name: mission_path_status_enum; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.mission_path_status_enum AS ENUM (
    'pending',
    'travelling',
    'blocked',
    'completed',
    'failed',
    'cancelled'
);


ALTER TYPE public.mission_path_status_enum OWNER TO admin;

--
-- Name: mission_paths_status_enum; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.mission_paths_status_enum AS ENUM (
    'pending',
    'travelling',
    'blocked',
    'completed',
    'failed'
);


ALTER TYPE public.mission_paths_status_enum OWNER TO admin;

--
-- Name: paths_status_enum; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.paths_status_enum AS ENUM (
    'active',
    'inactive',
    'maintenance'
);


ALTER TYPE public.paths_status_enum OWNER TO admin;

--
-- Name: paths_type_enum; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.paths_type_enum AS ENUM (
    'navigation',
    'charging',
    'service',
    'custom'
);


ALTER TYPE public.paths_type_enum OWNER TO admin;

--
-- Name: scheduler_executions_status_enum; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.scheduler_executions_status_enum AS ENUM (
    'pending',
    'running',
    'paused',
    'completed',
    'failed',
    'cancelled'
);


ALTER TYPE public.scheduler_executions_status_enum OWNER TO admin;

--
-- Name: scheduler_queue_priority_enum; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.scheduler_queue_priority_enum AS ENUM (
    'high',
    'normal',
    'low'
);


ALTER TYPE public.scheduler_queue_priority_enum OWNER TO admin;

--
-- Name: scheduler_queue_status_enum; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.scheduler_queue_status_enum AS ENUM (
    'queued',
    'running',
    'completed',
    'cancelled',
    'failed'
);


ALTER TYPE public.scheduler_queue_status_enum OWNER TO admin;

--
-- Name: vda5050_command_trackers_commandtype_enum; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.vda5050_command_trackers_commandtype_enum AS ENUM (
    'order',
    'instantAction'
);


ALTER TYPE public.vda5050_command_trackers_commandtype_enum OWNER TO admin;

--
-- Name: vda5050_command_trackers_status_enum; Type: TYPE; Schema: public; Owner: admin
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


ALTER TYPE public.vda5050_command_trackers_status_enum OWNER TO admin;

--
-- Name: waypoint_executions_status_enum; Type: TYPE; Schema: public; Owner: admin
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


ALTER TYPE public.waypoint_executions_status_enum OWNER TO admin;

--
-- Name: update_scheduler_queue_updated_at(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.update_scheduler_queue_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_scheduler_queue_updated_at() OWNER TO admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: locked_segment; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.locked_segment (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "segmentId" character varying NOT NULL,
    "vehicleId" character varying NOT NULL
);


ALTER TABLE public.locked_segment OWNER TO admin;

--
-- Name: mission_executions; Type: TABLE; Schema: public; Owner: admin
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
    "completedAt" timestamp with time zone,
    "distanceTravelled" double precision DEFAULT '0'::double precision
);


ALTER TABLE public.mission_executions OWNER TO admin;

--
-- Name: mission_path; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.mission_path (
    id uuid NOT NULL,
    "missionId" character varying NOT NULL,
    "deviceId" character varying NOT NULL,
    waypoints jsonb NOT NULL,
    distance double precision NOT NULL,
    "estimatedDuration" double precision NOT NULL,
    "waypointCount" integer NOT NULL,
    status public.mission_path_status_enum DEFAULT 'pending'::public.mission_path_status_enum NOT NULL,
    "currentWaypointIndex" integer DEFAULT 0 NOT NULL,
    "completedWaypoints" integer DEFAULT 0 NOT NULL,
    "distanceTravelled" double precision DEFAULT '0'::double precision NOT NULL,
    "calculatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    "startedAt" timestamp with time zone,
    "completedAt" timestamp with time zone
);


ALTER TABLE public.mission_path OWNER TO admin;

--
-- Name: mission_paths; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.mission_paths (
    id uuid NOT NULL,
    "missionId" character varying NOT NULL,
    "deviceId" character varying NOT NULL,
    waypoints jsonb NOT NULL,
    distance double precision NOT NULL,
    "estimatedDuration" double precision NOT NULL,
    "calculatedAt" timestamp without time zone DEFAULT now() NOT NULL,
    "waypointCount" integer NOT NULL,
    "currentWaypointIndex" integer DEFAULT 0 NOT NULL,
    "completedWaypoints" integer DEFAULT 0 NOT NULL,
    "distanceTravelled" double precision DEFAULT '0'::double precision NOT NULL,
    status public.mission_paths_status_enum DEFAULT 'pending'::public.mission_paths_status_enum NOT NULL,
    "startedAt" timestamp without time zone,
    "completedAt" timestamp without time zone
);


ALTER TABLE public.mission_paths OWNER TO admin;

--
-- Name: paths; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.paths (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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


ALTER TABLE public.paths OWNER TO admin;

--
-- Name: scheduler_executions; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.scheduler_executions OWNER TO admin;

--
-- Name: scheduler_queue; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.scheduler_queue (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    mission_ids jsonb NOT NULL,
    scheduler_option jsonb NOT NULL,
    queue_position integer NOT NULL,
    queued_at timestamp without time zone DEFAULT now() NOT NULL,
    started_at timestamp without time zone,
    completed_at timestamp without time zone,
    error text,
    metadata jsonb,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    scheduler_id character varying NOT NULL,
    scheduler_name character varying NOT NULL,
    scheduler_execution_id character varying,
    device_id character varying NOT NULL,
    customer_id character varying NOT NULL,
    deployment_id character varying NOT NULL,
    zone_id character varying NOT NULL,
    status public.scheduler_queue_status_enum DEFAULT 'queued'::public.scheduler_queue_status_enum NOT NULL,
    priority public.scheduler_queue_priority_enum DEFAULT 'normal'::public.scheduler_queue_priority_enum NOT NULL
);


ALTER TABLE public.scheduler_queue OWNER TO admin;

--
-- Name: vda5050_command_trackers; Type: TABLE; Schema: public; Owner: admin
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
    metadata jsonb,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    "sentAt" timestamp with time zone,
    "deliveredAt" timestamp with time zone,
    "completedAt" timestamp with time zone,
    "timeoutAt" timestamp with time zone
);


ALTER TABLE public.vda5050_command_trackers OWNER TO admin;

--
-- Name: waypoint_executions; Type: TABLE; Schema: public; Owner: admin
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
    "totalActions" integer DEFAULT 0 NOT NULL,
    "completedActions" integer DEFAULT 0 NOT NULL,
    "failedActions" integer DEFAULT 0 NOT NULL,
    "actionResults" jsonb,
    metadata jsonb,
    error text,
    "navigationStartedAt" timestamp with time zone,
    "navigationCompletedAt" timestamp with time zone,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    "startedAt" timestamp with time zone,
    "completedAt" timestamp with time zone
);


ALTER TABLE public.waypoint_executions OWNER TO admin;

--
-- Name: mission_path PK_0901d41bc1d87bf186a22634282; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.mission_path
    ADD CONSTRAINT "PK_0901d41bc1d87bf186a22634282" PRIMARY KEY (id);


--
-- Name: vda5050_command_trackers PK_0fc69e7d1c190fa3ad9e17de834; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.vda5050_command_trackers
    ADD CONSTRAINT "PK_0fc69e7d1c190fa3ad9e17de834" PRIMARY KEY (id);


--
-- Name: locked_segment PK_199724e14968cdd60554b4cc20f; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.locked_segment
    ADD CONSTRAINT "PK_199724e14968cdd60554b4cc20f" PRIMARY KEY (id);


--
-- Name: paths PK_3023c8d7a50ae9c50117a94e502; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.paths
    ADD CONSTRAINT "PK_3023c8d7a50ae9c50117a94e502" PRIMARY KEY (id);


--
-- Name: mission_executions PK_64de19702bbadf1bf343175a06c; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.mission_executions
    ADD CONSTRAINT "PK_64de19702bbadf1bf343175a06c" PRIMARY KEY (id);


--
-- Name: scheduler_executions PK_74d2c227b818f733aba6f7bce60; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.scheduler_executions
    ADD CONSTRAINT "PK_74d2c227b818f733aba6f7bce60" PRIMARY KEY (id);


--
-- Name: mission_paths PK_ab1757409356223fdb9fce50b6f; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.mission_paths
    ADD CONSTRAINT "PK_ab1757409356223fdb9fce50b6f" PRIMARY KEY (id);


--
-- Name: waypoint_executions PK_af52823c4aa5fcadc2aad413eda; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.waypoint_executions
    ADD CONSTRAINT "PK_af52823c4aa5fcadc2aad413eda" PRIMARY KEY (id);


--
-- Name: scheduler_queue scheduler_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.scheduler_queue
    ADD CONSTRAINT scheduler_queue_pkey PRIMARY KEY (id);


--
-- Name: IDX_1b3191e7ab8c1c308dc6a4dd92; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IDX_1b3191e7ab8c1c308dc6a4dd92" ON public.scheduler_queue USING btree (device_id);


--
-- Name: IDX_33e84f28051775ffd66ed1b1f8; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IDX_33e84f28051775ffd66ed1b1f8" ON public.scheduler_queue USING btree (status);


--
-- Name: IDX_706d46910b295b687948178780; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IDX_706d46910b295b687948178780" ON public.scheduler_queue USING btree (scheduler_id);


--
-- Name: IDX_7a8ce8e9f6123cc7b52e1e8262; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IDX_7a8ce8e9f6123cc7b52e1e8262" ON public.scheduler_queue USING btree (device_id, status);


--
-- Name: IDX_98d63674a3d993f340c9cfc905; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IDX_98d63674a3d993f340c9cfc905" ON public.scheduler_queue USING btree (device_id, queue_position);


--
-- Name: scheduler_queue trigger_scheduler_queue_updated_at; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trigger_scheduler_queue_updated_at BEFORE UPDATE ON public.scheduler_queue FOR EACH ROW EXECUTE FUNCTION public.update_scheduler_queue_updated_at();


--
-- Name: waypoint_executions FK_9390e5756e19d182e55e0db05d3; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.waypoint_executions
    ADD CONSTRAINT "FK_9390e5756e19d182e55e0db05d3" FOREIGN KEY ("missionExecutionId") REFERENCES public.mission_executions(id);


--
-- Name: mission_executions FK_b08a6371365e59b325c739094cc; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.mission_executions
    ADD CONSTRAINT "FK_b08a6371365e59b325c739094cc" FOREIGN KEY ("schedulerExecutionId") REFERENCES public.scheduler_executions(id);


--
-- PostgreSQL database dump complete
--

\unrestrict g6nfJgbyIEaDHwZvfwSVNNIcuI1LDbDnDt7VRwN9tb3ixq1O0KVZbD4AxlMbJFi

