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
-- Name: approvals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.approvals (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    case_number character varying,
    copay_frequency public.copay_frequency,
    effective_on date,
    expires_on date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    copay_cents integer,
    copay_currency character varying DEFAULT 'USD'::character varying NOT NULL
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
    total_time_in_care interval NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    check_in timestamp without time zone,
    check_out timestamp without time zone
);


--
-- Name: COLUMN attendances.total_time_in_care; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.attendances.total_time_in_care IS 'Calculated: check_out time - check_in time';


--
-- Name: billable_occurrence_rate_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.billable_occurrence_rate_types (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    billable_occurrence_id uuid,
    rate_type_id uuid NOT NULL
);


--
-- Name: billable_occurrences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.billable_occurrences (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    child_approval_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    billable_type character varying,
    billable_id uuid
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
    name character varying NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    license_type public.license_types,
    county_id uuid NOT NULL,
    zipcode_id uuid NOT NULL
);


--
-- Name: child_approval_rate_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.child_approval_rate_types (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    child_approval_id uuid,
    rate_type_id uuid NOT NULL
);


--
-- Name: child_approvals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.child_approvals (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    subsidy_rule_id uuid,
    approval_id uuid NOT NULL,
    child_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: children; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.children (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    active boolean DEFAULT true NOT NULL,
    full_name character varying NOT NULL,
    date_of_birth date NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    business_id uuid NOT NULL
);


--
-- Name: counties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.counties (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    state_id uuid NOT NULL,
    abbr character varying,
    name character varying,
    county_seat character varying,
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
-- Name: illinois_subsidy_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.illinois_subsidy_rules (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    bronze_percentage numeric,
    silver_percentage numeric,
    gold_percentage numeric,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: rate_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rate_types (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    amount_cents integer DEFAULT 0 NOT NULL,
    amount_currency character varying DEFAULT 'USD'::character varying NOT NULL,
    max_duration numeric,
    threshold numeric,
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
-- Name: states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.states (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    abbr character varying(2),
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: subsidy_rule_rate_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subsidy_rule_rate_types (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    subsidy_rule_id uuid,
    rate_type_id uuid NOT NULL
);


--
-- Name: subsidy_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subsidy_rules (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    license_type public.license_types NOT NULL,
    max_age numeric NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    county_id uuid,
    state_id uuid NOT NULL,
    effective_on date,
    expires_on date,
    subsidy_ruleable_type character varying,
    subsidy_ruleable_id uuid
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
-- Name: zipcodes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.zipcodes (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    code character varying NOT NULL,
    city character varying,
    state_id uuid NOT NULL,
    county_id uuid NOT NULL,
    area_code character varying,
    lat numeric(15,10),
    lon numeric(15,10),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: approvals approvals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.approvals
    ADD CONSTRAINT approvals_pkey PRIMARY KEY (id);


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
-- Name: billable_occurrence_rate_types billable_occurrence_rate_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billable_occurrence_rate_types
    ADD CONSTRAINT billable_occurrence_rate_types_pkey PRIMARY KEY (id);


--
-- Name: billable_occurrences billable_occurrences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billable_occurrences
    ADD CONSTRAINT billable_occurrences_pkey PRIMARY KEY (id);


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
-- Name: child_approval_rate_types child_approval_rate_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.child_approval_rate_types
    ADD CONSTRAINT child_approval_rate_types_pkey PRIMARY KEY (id);


--
-- Name: child_approvals child_approvals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.child_approvals
    ADD CONSTRAINT child_approvals_pkey PRIMARY KEY (id);


--
-- Name: children children_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.children
    ADD CONSTRAINT children_pkey PRIMARY KEY (id);


--
-- Name: counties counties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.counties
    ADD CONSTRAINT counties_pkey PRIMARY KEY (id);


--
-- Name: data_migrations data_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_migrations
    ADD CONSTRAINT data_migrations_pkey PRIMARY KEY (version);


--
-- Name: illinois_subsidy_rules illinois_subsidy_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.illinois_subsidy_rules
    ADD CONSTRAINT illinois_subsidy_rules_pkey PRIMARY KEY (id);


--
-- Name: rate_types rate_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rate_types
    ADD CONSTRAINT rate_types_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: states states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);


--
-- Name: subsidy_rule_rate_types subsidy_rule_rate_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subsidy_rule_rate_types
    ADD CONSTRAINT subsidy_rule_rate_types_pkey PRIMARY KEY (id);


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
-- Name: zipcodes zipcodes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zipcodes
    ADD CONSTRAINT zipcodes_pkey PRIMARY KEY (id);


--
-- Name: billable_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX billable_index ON public.billable_occurrences USING btree (billable_type, billable_id);


--
-- Name: index_billable_occurrence_rate_types_on_billable_occurrence_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_billable_occurrence_rate_types_on_billable_occurrence_id ON public.billable_occurrence_rate_types USING btree (billable_occurrence_id);


--
-- Name: index_billable_occurrence_rate_types_on_rate_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_billable_occurrence_rate_types_on_rate_type_id ON public.billable_occurrence_rate_types USING btree (rate_type_id);


--
-- Name: index_billable_occurrences_on_child_approval_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_billable_occurrences_on_child_approval_id ON public.billable_occurrences USING btree (child_approval_id);


--
-- Name: index_blocked_tokens_on_jti; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_blocked_tokens_on_jti ON public.blocked_tokens USING btree (jti);


--
-- Name: index_businesses_on_county_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_businesses_on_county_id ON public.businesses USING btree (county_id);


--
-- Name: index_businesses_on_name_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_businesses_on_name_and_user_id ON public.businesses USING btree (name, user_id);


--
-- Name: index_businesses_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_businesses_on_user_id ON public.businesses USING btree (user_id);


--
-- Name: index_businesses_on_zipcode_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_businesses_on_zipcode_id ON public.businesses USING btree (zipcode_id);


--
-- Name: index_child_approval_rate_types_on_child_approval_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_child_approval_rate_types_on_child_approval_id ON public.child_approval_rate_types USING btree (child_approval_id);


--
-- Name: index_child_approval_rate_types_on_rate_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_child_approval_rate_types_on_rate_type_id ON public.child_approval_rate_types USING btree (rate_type_id);


--
-- Name: index_child_approvals_on_approval_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_child_approvals_on_approval_id ON public.child_approvals USING btree (approval_id);


--
-- Name: index_child_approvals_on_child_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_child_approvals_on_child_id ON public.child_approvals USING btree (child_id);


--
-- Name: index_child_approvals_on_subsidy_rule_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_child_approvals_on_subsidy_rule_id ON public.child_approvals USING btree (subsidy_rule_id);


--
-- Name: index_children_on_business_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_children_on_business_id ON public.children USING btree (business_id);


--
-- Name: index_counties_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_counties_on_name ON public.counties USING btree (name);


--
-- Name: index_counties_on_state_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_counties_on_state_id ON public.counties USING btree (state_id);


--
-- Name: index_states_on_abbr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_states_on_abbr ON public.states USING btree (abbr);


--
-- Name: index_subsidy_rule_rate_types_on_rate_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subsidy_rule_rate_types_on_rate_type_id ON public.subsidy_rule_rate_types USING btree (rate_type_id);


--
-- Name: index_subsidy_rule_rate_types_on_subsidy_rule_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subsidy_rule_rate_types_on_subsidy_rule_id ON public.subsidy_rule_rate_types USING btree (subsidy_rule_id);


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
-- Name: index_zipcodes_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_zipcodes_on_code ON public.zipcodes USING btree (code);


--
-- Name: index_zipcodes_on_county_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_zipcodes_on_county_id ON public.zipcodes USING btree (county_id);


--
-- Name: index_zipcodes_on_lat_and_lon; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_zipcodes_on_lat_and_lon ON public.zipcodes USING btree (lat, lon);


--
-- Name: index_zipcodes_on_state_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_zipcodes_on_state_id ON public.zipcodes USING btree (state_id);


--
-- Name: subsidy_ruleable_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX subsidy_ruleable_index ON public.subsidy_rules USING btree (subsidy_ruleable_type, subsidy_ruleable_id);


--
-- Name: unique_children; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_children ON public.children USING btree (full_name, date_of_birth, business_id);


--
-- Name: counties fk_rails_028abb0ec1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.counties
    ADD CONSTRAINT fk_rails_028abb0ec1 FOREIGN KEY (state_id) REFERENCES public.states(id);


--
-- Name: businesses fk_rails_25d0b15649; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.businesses
    ADD CONSTRAINT fk_rails_25d0b15649 FOREIGN KEY (county_id) REFERENCES public.counties(id);


--
-- Name: child_approvals fk_rails_2af12c67c9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.child_approvals
    ADD CONSTRAINT fk_rails_2af12c67c9 FOREIGN KEY (subsidy_rule_id) REFERENCES public.subsidy_rules(id);


--
-- Name: subsidy_rules fk_rails_2bb2a806ed; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subsidy_rules
    ADD CONSTRAINT fk_rails_2bb2a806ed FOREIGN KEY (county_id) REFERENCES public.counties(id);


--
-- Name: subsidy_rule_rate_types fk_rails_2c8ca83220; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subsidy_rule_rate_types
    ADD CONSTRAINT fk_rails_2c8ca83220 FOREIGN KEY (rate_type_id) REFERENCES public.rate_types(id);


--
-- Name: billable_occurrence_rate_types fk_rails_39b46a8efd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billable_occurrence_rate_types
    ADD CONSTRAINT fk_rails_39b46a8efd FOREIGN KEY (rate_type_id) REFERENCES public.rate_types(id);


--
-- Name: billable_occurrence_rate_types fk_rails_3ecc6abdd0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billable_occurrence_rate_types
    ADD CONSTRAINT fk_rails_3ecc6abdd0 FOREIGN KEY (billable_occurrence_id) REFERENCES public.billable_occurrences(id);


--
-- Name: businesses fk_rails_48152d6e55; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.businesses
    ADD CONSTRAINT fk_rails_48152d6e55 FOREIGN KEY (zipcode_id) REFERENCES public.zipcodes(id);


--
-- Name: zipcodes fk_rails_4916202daf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zipcodes
    ADD CONSTRAINT fk_rails_4916202daf FOREIGN KEY (state_id) REFERENCES public.states(id);


--
-- Name: subsidy_rule_rate_types fk_rails_56583d3a66; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subsidy_rule_rate_types
    ADD CONSTRAINT fk_rails_56583d3a66 FOREIGN KEY (subsidy_rule_id) REFERENCES public.subsidy_rules(id);


--
-- Name: billable_occurrences fk_rails_5b2fd4e167; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billable_occurrences
    ADD CONSTRAINT fk_rails_5b2fd4e167 FOREIGN KEY (child_approval_id) REFERENCES public.child_approvals(id);


--
-- Name: child_approvals fk_rails_6a1cefaf48; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.child_approvals
    ADD CONSTRAINT fk_rails_6a1cefaf48 FOREIGN KEY (child_id) REFERENCES public.children(id);


--
-- Name: child_approvals fk_rails_b4c39906ee; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.child_approvals
    ADD CONSTRAINT fk_rails_b4c39906ee FOREIGN KEY (approval_id) REFERENCES public.approvals(id);


--
-- Name: children fk_rails_b51aaa1e8e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.children
    ADD CONSTRAINT fk_rails_b51aaa1e8e FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- Name: zipcodes fk_rails_c1f1e8d4c3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zipcodes
    ADD CONSTRAINT fk_rails_c1f1e8d4c3 FOREIGN KEY (county_id) REFERENCES public.counties(id);


--
-- Name: child_approval_rate_types fk_rails_d3d552ef33; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.child_approval_rate_types
    ADD CONSTRAINT fk_rails_d3d552ef33 FOREIGN KEY (rate_type_id) REFERENCES public.rate_types(id);


--
-- Name: child_approval_rate_types fk_rails_dbacd97c03; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.child_approval_rate_types
    ADD CONSTRAINT fk_rails_dbacd97c03 FOREIGN KEY (child_approval_id) REFERENCES public.child_approvals(id);


--
-- Name: subsidy_rules fk_rails_eac641c57e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subsidy_rules
    ADD CONSTRAINT fk_rails_eac641c57e FOREIGN KEY (state_id) REFERENCES public.states(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20201112193701'),
('20201115203512');


