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
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: case_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.case_status AS ENUM (
    'submitted',
    'pending',
    'approved',
    'denied'
);


--
-- Name: copay_frequency; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.copay_frequency AS ENUM (
    'daily',
    'weekly',
    'monthly'
);


--
-- Name: duration_definitions; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.duration_definitions AS ENUM (
    'part_day',
    'full_day',
    'full_plus_part_day',
    'full_plus_full_day'
);


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

SET default_table_access_method = heap;

--
-- Name: agencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agencies (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    state_id uuid NOT NULL
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
-- Name: attendances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attendances (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    child_case_cycle_id uuid NOT NULL,
    starts_on date NOT NULL,
    check_in time without time zone NOT NULL,
    check_out time without time zone NOT NULL,
    total_time_in_care interval NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    attendance_duration public.duration_definitions DEFAULT 'full_day'::public.duration_definitions NOT NULL
);


--
-- Name: COLUMN attendances.total_time_in_care; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.attendances.total_time_in_care IS 'Calculated: check_out time - check_in time';


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
    name character varying NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    license_type public.license_types
);


--
-- Name: case_cycles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.case_cycles (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    case_number character varying,
    copay_cents integer DEFAULT 0 NOT NULL,
    copay_currency character varying DEFAULT 'USD'::character varying NOT NULL,
    submitted_on date NOT NULL,
    effective_on date,
    notified_on date,
    expires_on date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    status public.case_status DEFAULT 'submitted'::public.case_status NOT NULL,
    copay_frequency public.copay_frequency NOT NULL,
    user_id uuid NOT NULL
);


--
-- Name: child_case_cycles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.child_case_cycles (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    part_days_allowed integer NOT NULL,
    full_days_allowed integer NOT NULL,
    child_id uuid NOT NULL,
    subsidy_rule_id uuid NOT NULL,
    case_cycle_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
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
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: data_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.data_migrations (
    version character varying NOT NULL
);


--
-- Name: lookup_cities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lookup_cities (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    state_id uuid NOT NULL,
    county_id uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lookup_counties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lookup_counties (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    state_id uuid,
    abbr character varying,
    name character varying NOT NULL,
    county_seat character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lookup_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lookup_states (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    abbr character varying(2) NOT NULL,
    name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lookup_zipcodes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lookup_zipcodes (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    code character varying NOT NULL,
    state_id uuid,
    county_id uuid,
    city_id uuid,
    area_code character varying,
    lat numeric(15,10),
    lon numeric(15,10),
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
-- Name: subsidy_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subsidy_rules (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    license_type public.license_types NOT NULL,
    county_id uuid NOT NULL,
    state_id uuid NOT NULL,
    max_age numeric NOT NULL,
    part_day_rate_cents integer DEFAULT 0 NOT NULL,
    part_day_rate_currency character varying DEFAULT 'USD'::character varying NOT NULL,
    full_day_rate_cents integer DEFAULT 0 NOT NULL,
    full_day_rate_currency character varying DEFAULT 'USD'::character varying NOT NULL,
    part_day_max_hours numeric NOT NULL,
    full_day_max_hours numeric NOT NULL,
    full_plus_part_day_max_hours numeric NOT NULL,
    full_plus_full_day_max_hours numeric NOT NULL,
    part_day_threshold numeric NOT NULL,
    full_day_threshold numeric NOT NULL,
    qris_rating character varying,
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
    greeting_name character varying NOT NULL,
    email character varying NOT NULL,
    language character varying NOT NULL,
    phone_type character varying,
    opt_in_email boolean DEFAULT true NOT NULL,
    opt_in_text boolean DEFAULT true NOT NULL,
    phone_number character varying,
    service_agreement_accepted boolean DEFAULT false NOT NULL,
    timezone character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
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
    locked_at timestamp without time zone,
    admin boolean DEFAULT false NOT NULL
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
-- Name: attendances attendances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT attendances_pkey PRIMARY KEY (id);


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
-- Name: case_cycles case_cycles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_cycles
    ADD CONSTRAINT case_cycles_pkey PRIMARY KEY (id);


--
-- Name: child_case_cycles child_case_cycles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.child_case_cycles
    ADD CONSTRAINT child_case_cycles_pkey PRIMARY KEY (id);


--
-- Name: children children_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.children
    ADD CONSTRAINT children_pkey PRIMARY KEY (id);


--
-- Name: data_migrations data_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_migrations
    ADD CONSTRAINT data_migrations_pkey PRIMARY KEY (version);


--
-- Name: lookup_cities lookup_cities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lookup_cities
    ADD CONSTRAINT lookup_cities_pkey PRIMARY KEY (id);


--
-- Name: lookup_counties lookup_counties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lookup_counties
    ADD CONSTRAINT lookup_counties_pkey PRIMARY KEY (id);


--
-- Name: lookup_states lookup_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lookup_states
    ADD CONSTRAINT lookup_states_pkey PRIMARY KEY (id);


--
-- Name: lookup_zipcodes lookup_zipcodes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lookup_zipcodes
    ADD CONSTRAINT lookup_zipcodes_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: subsidy_rules subsidy_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subsidy_rules
    ADD CONSTRAINT subsidy_rules_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_agencies_on_name_and_state_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_agencies_on_name_and_state_id ON public.agencies USING btree (name, state_id);


--
-- Name: index_attendances_on_child_case_cycle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attendances_on_child_case_cycle_id ON public.attendances USING btree (child_case_cycle_id);


--
-- Name: index_blocked_tokens_on_jti; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_blocked_tokens_on_jti ON public.blocked_tokens USING btree (jti);


--
-- Name: index_businesses_on_name_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_businesses_on_name_and_user_id ON public.businesses USING btree (name, user_id);


--
-- Name: index_businesses_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_businesses_on_user_id ON public.businesses USING btree (user_id);


--
-- Name: index_case_cycles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_case_cycles_on_user_id ON public.case_cycles USING btree (user_id);


--
-- Name: index_child_case_cycles_on_case_cycle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_child_case_cycles_on_case_cycle_id ON public.child_case_cycles USING btree (case_cycle_id);


--
-- Name: index_child_case_cycles_on_child_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_child_case_cycles_on_child_id ON public.child_case_cycles USING btree (child_id);


--
-- Name: index_child_case_cycles_on_subsidy_rule_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_child_case_cycles_on_subsidy_rule_id ON public.child_case_cycles USING btree (subsidy_rule_id);


--
-- Name: index_children_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_children_on_user_id ON public.children USING btree (user_id);


--
-- Name: index_lookup_cities_on_county_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lookup_cities_on_county_id ON public.lookup_cities USING btree (county_id);


--
-- Name: index_lookup_cities_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lookup_cities_on_name ON public.lookup_cities USING btree (name);


--
-- Name: index_lookup_cities_on_name_and_state_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_lookup_cities_on_name_and_state_id ON public.lookup_cities USING btree (name, state_id);


--
-- Name: index_lookup_cities_on_state_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lookup_cities_on_state_id ON public.lookup_cities USING btree (state_id);


--
-- Name: index_lookup_counties_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lookup_counties_on_name ON public.lookup_counties USING btree (name);


--
-- Name: index_lookup_counties_on_state_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lookup_counties_on_state_id ON public.lookup_counties USING btree (state_id);


--
-- Name: index_lookup_counties_on_state_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_lookup_counties_on_state_id_and_name ON public.lookup_counties USING btree (state_id, name);


--
-- Name: index_lookup_states_on_abbr; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_lookup_states_on_abbr ON public.lookup_states USING btree (abbr);


--
-- Name: index_lookup_states_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_lookup_states_on_name ON public.lookup_states USING btree (name);


--
-- Name: index_lookup_zipcodes_on_city_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lookup_zipcodes_on_city_id ON public.lookup_zipcodes USING btree (city_id);


--
-- Name: index_lookup_zipcodes_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_lookup_zipcodes_on_code ON public.lookup_zipcodes USING btree (code);


--
-- Name: index_lookup_zipcodes_on_county_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lookup_zipcodes_on_county_id ON public.lookup_zipcodes USING btree (county_id);


--
-- Name: index_lookup_zipcodes_on_state_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lookup_zipcodes_on_state_id ON public.lookup_zipcodes USING btree (state_id);


--
-- Name: index_lookup_zipcodes_on_state_id_and_city_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lookup_zipcodes_on_state_id_and_city_id ON public.lookup_zipcodes USING btree (state_id, city_id);


--
-- Name: index_subsidy_rules_on_county_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subsidy_rules_on_county_id ON public.subsidy_rules USING btree (county_id);


--
-- Name: index_subsidy_rules_on_state_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subsidy_rules_on_state_id ON public.subsidy_rules USING btree (state_id);


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
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON public.users USING btree (unlock_token);


--
-- Name: unique_children; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_children ON public.children USING btree (full_name, date_of_birth, user_id);


--
-- Name: case_cycles fk_rails_02471acfd5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.case_cycles
    ADD CONSTRAINT fk_rails_02471acfd5 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: child_case_cycles fk_rails_b4f3c7d474; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.child_case_cycles
    ADD CONSTRAINT fk_rails_b4f3c7d474 FOREIGN KEY (child_id) REFERENCES public.children(id);


--
-- Name: child_case_cycles fk_rails_bd0bf4a589; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.child_case_cycles
    ADD CONSTRAINT fk_rails_bd0bf4a589 FOREIGN KEY (subsidy_rule_id) REFERENCES public.subsidy_rules(id);


--
-- Name: attendances fk_rails_c1c1bbb16f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT fk_rails_c1c1bbb16f FOREIGN KEY (child_case_cycle_id) REFERENCES public.child_case_cycles(id);


--
-- Name: child_case_cycles fk_rails_e441dceee7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.child_case_cycles
    ADD CONSTRAINT fk_rails_e441dceee7 FOREIGN KEY (case_cycle_id) REFERENCES public.case_cycles(id);


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
('20200814013700'),
('20200824023040'),
('20200824023511'),
('20200824025129'),
('20200825180000'),
('20200825180100'),
('20200825180200'),
('20200825180300'),
('20200828013851'),
('20200902182940'),
('20200902184516'),
('20200903112138'),
('20200906195706'),
('20200906232048'),
('20200907181541'),
('20200910021812'),
('20200911180200'),
('20200911220200'),
('20200913004651'),
('20200913005807'),
('20200914030020'),
('20200918232336'),
('20201007145834'),
('20201007161749');


