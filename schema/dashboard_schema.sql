--
-- PostgreSQL database dump
--

\restrict LKfSDCJ6phfV10BioGBIPa1FFE7TCvfhbDqjJUL1XiPwZ79mtSjPXuIhUYU0aFM

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: CustomDashboard; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public."CustomDashboard" OWNER TO admin;

--
-- Name: Dashboard; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public."Dashboard" OWNER TO admin;

--
-- Name: CustomDashboard CustomDashboard_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."CustomDashboard"
    ADD CONSTRAINT "CustomDashboard_pkey" PRIMARY KEY (id);


--
-- Name: Dashboard Dashboard_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."Dashboard"
    ADD CONSTRAINT "Dashboard_pkey" PRIMARY KEY (id);


--
-- Name: CustomDashboard_dashboardId_key; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX "CustomDashboard_dashboardId_key" ON public."CustomDashboard" USING btree ("dashboardId");


--
-- Name: CustomDashboard CustomDashboard_dashboardId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."CustomDashboard"
    ADD CONSTRAINT "CustomDashboard_dashboardId_fkey" FOREIGN KEY ("dashboardId") REFERENCES public."Dashboard"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict LKfSDCJ6phfV10BioGBIPa1FFE7TCvfhbDqjJUL1XiPwZ79mtSjPXuIhUYU0aFM

