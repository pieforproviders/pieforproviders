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
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: license_types; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.license_types AS ENUM (
    'licensed_center',
    'licensed_family_home',
    'licensed_group_home',
    'license_exempt_home',
    'license_exempt_center'
);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: agencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agencies (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    state character varying NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: blocked_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blocked_tokens (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    jti character varying NOT NULL,
    expiration timestamp without time zone NOT NULL
);


--
-- Name: businesses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.businesses (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    active boolean DEFAULT true NOT NULL,
    category character varying NOT NULL,
    name character varying NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    slug character varying NOT NULL
);


--
-- Name: child_sites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.child_sites (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    child_id uuid NOT NULL,
    site_id uuid NOT NULL,
    started_care date,
    ended_care date
);


--
-- Name: children; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.children (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    active boolean DEFAULT true NOT NULL,
    ccms_id character varying,
    full_name character varying NOT NULL,
    date_of_birth date NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    slug character varying NOT NULL
);


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    paid_on date NOT NULL,
    care_started_on date NOT NULL,
    care_finished_on date NOT NULL,
    amount_cents integer DEFAULT 0 NOT NULL,
    amount_currency character varying DEFAULT 'USD'::character varying NOT NULL,
    slug character varying NOT NULL,
    discrepancy_cents integer,
    discrepancy_currency character varying DEFAULT 'USD'::character varying,
    site_id uuid NOT NULL,
    agency_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sites (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    active boolean DEFAULT true NOT NULL,
    name character varying NOT NULL,
    address character varying NOT NULL,
    city character varying NOT NULL,
    state character varying NOT NULL,
    zip character varying NOT NULL,
    county character varying NOT NULL,
    slug character varying NOT NULL,
    qris_rating character varying,
    business_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    active boolean DEFAULT true NOT NULL,
    full_name character varying NOT NULL,
    greeting_name character varying,
    email character varying NOT NULL,
    language character varying NOT NULL,
    phone_type character varying,
    opt_in_email boolean DEFAULT true NOT NULL,
    opt_in_phone boolean DEFAULT true NOT NULL,
    opt_in_text boolean DEFAULT true NOT NULL,
    phone_number character varying,
    service_agreement_accepted boolean DEFAULT false NOT NULL,
    timezone character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    slug character varying NOT NULL,
    organization character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    failed_attempts integer DEFAULT 0 NOT NULL,
    unlock_token character varying,
    locked_at timestamp without time zone
);


--
-- Name: agencies agencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agencies
    ADD CONSTRAINT agencies_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: blocked_tokens blocked_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocked_tokens
    ADD CONSTRAINT blocked_tokens_pkey PRIMARY KEY (id);


--
-- Name: businesses businesses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.businesses
    ADD CONSTRAINT businesses_pkey PRIMARY KEY (id);


--
-- Name: child_sites child_sites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.child_sites
    ADD CONSTRAINT child_sites_pkey PRIMARY KEY (id);


--
-- Name: children children_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.children
    ADD CONSTRAINT children_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sites sites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_agencies_on_name_and_state; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_agencies_on_name_and_state ON public.agencies USING btree (name, state);


--
-- Name: index_blocked_tokens_on_jti; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_blocked_tokens_on_jti ON public.blocked_tokens USING btree (jti);


--
-- Name: index_businesses_on_name_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_businesses_on_name_and_user_id ON public.businesses USING btree (name, user_id);


--
-- Name: index_businesses_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_businesses_on_slug ON public.businesses USING btree (slug);


--
-- Name: index_businesses_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_businesses_on_user_id ON public.businesses USING btree (user_id);


--
-- Name: index_child_sites_on_child_id_and_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_child_sites_on_child_id_and_site_id ON public.child_sites USING btree (child_id, site_id);


--
-- Name: index_children_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_children_on_slug ON public.children USING btree (slug);


--
-- Name: index_children_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_children_on_user_id ON public.children USING btree (user_id);


--
-- Name: index_payments_on_site_id_and_agency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payments_on_site_id_and_agency_id ON public.payments USING btree (site_id, agency_id);


--
-- Name: index_sites_on_name_and_business_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_sites_on_name_and_business_id ON public.sites USING btree (name, business_id);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_phone_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_phone_number ON public.users USING btree (phone_number);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_slug ON public.users USING btree (slug);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON public.users USING btree (unlock_token);


--
-- Name: unique_children; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_children ON public.children USING btree (full_name, date_of_birth, user_id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20191201163315'),
('20191228173615'),
('20200405020218'),
('20200406025948'),
('20200415011742'),
('20200415014152'),
('20200425210517'),
('20200425220142'),
('20200426002926'),
('20200429014219'),
('20200429020409'),
('20200614143825'),
('20200615004546'),
('20200802164810'),
('20200802173943'),
('20200802210346'),
('20200802222331'),
('20200814013700');


