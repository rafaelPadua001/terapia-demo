--
-- PostgreSQL database cluster dump
--

-- Started on 2026-03-20 00:04:56

\restrict 8dfhyR1RbCN1J05Qb31KsjOLcWTbadjX67XCAyomNMM3agg4Gmmkir00OES98VS

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:AcyGloYdqwbt18DTgBrjPA==$uWqRAofT3DpGd5Mf6lKQQ5xNsoU4ittvNpEbJzJ4cd0=:0f42ueZ5+arJMANJ0/vfOjAnZ65mWhDbgIh4UDS4GI4=';

--
-- User Configurations
--






\unrestrict 8dfhyR1RbCN1J05Qb31KsjOLcWTbadjX67XCAyomNMM3agg4Gmmkir00OES98VS

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

\restrict IsgorEs8phc82PL4OeaBnRmMZtPVA3ADAIa4bOQ19PxBoniO7A4Xn8OQttTwhmk

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

-- Started on 2026-03-20 00:04:56

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

-- Completed on 2026-03-20 00:04:57

--
-- PostgreSQL database dump complete
--

\unrestrict IsgorEs8phc82PL4OeaBnRmMZtPVA3ADAIa4bOQ19PxBoniO7A4Xn8OQttTwhmk

--
-- Database "clinics" dump
--

--
-- PostgreSQL database dump
--

\restrict wahruJ6FIuq4g3Ms4B4bOiRtQTyY3PCHDAb6yI0hlUIfB0t2xSzCUcD1Z30ntMO

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

-- Started on 2026-03-20 00:04:57

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5020 (class 1262 OID 197213)
-- Name: clinics; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE clinics WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'br';


\unrestrict wahruJ6FIuq4g3Ms4B4bOiRtQTyY3PCHDAb6yI0hlUIfB0t2xSzCUcD1Z30ntMO
\connect clinics
\restrict wahruJ6FIuq4g3Ms4B4bOiRtQTyY3PCHDAb6yI0hlUIfB0t2xSzCUcD1Z30ntMO

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
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
-- TOC entry 217 (class 1259 OID 197219)
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alembic_version (
    version_num character varying(64) NOT NULL
);


--
-- TOC entry 222 (class 1259 OID 197273)
-- Name: anamneses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.anamneses (
    id uuid NOT NULL,
    clinic_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    data jsonb NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    updated_by uuid,
    updated_at timestamp without time zone
);


--
-- TOC entry 228 (class 1259 OID 197387)
-- Name: appointments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.appointments (
    id uuid NOT NULL,
    clinic_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    therapist_id uuid NOT NULL,
    scheduled_at timestamp without time zone NOT NULL,
    status character varying(64) NOT NULL,
    notes character varying(500),
    created_by uuid NOT NULL,
    updated_by uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone,
    date date,
    "time" time without time zone,
    type character varying(100),
    is_first_visit boolean NOT NULL,
    is_confirmed boolean DEFAULT false NOT NULL,
    confirmed_at timestamp without time zone,
    confirmed_by uuid
);


--
-- TOC entry 226 (class 1259 OID 197361)
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs (
    id uuid NOT NULL,
    clinic_id uuid NOT NULL,
    user_id uuid NOT NULL,
    action character varying(100) NOT NULL,
    entity character varying(100) NOT NULL,
    entity_id character varying(64) NOT NULL,
    meta jsonb,
    created_at timestamp without time zone NOT NULL
);


--
-- TOC entry 218 (class 1259 OID 197224)
-- Name: clinics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clinics (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- TOC entry 223 (class 1259 OID 197295)
-- Name: evaluations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.evaluations (
    id uuid NOT NULL,
    clinic_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    type character varying(100) NOT NULL,
    result jsonb NOT NULL,
    status character varying(64) NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    updated_by uuid,
    updated_at timestamp without time zone
);


--
-- TOC entry 225 (class 1259 OID 197339)
-- Name: evolutions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.evolutions (
    id uuid NOT NULL,
    clinic_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    description text NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    updated_by uuid,
    updated_at timestamp without time zone
);


--
-- TOC entry 221 (class 1259 OID 197256)
-- Name: guardians; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.guardians (
    id uuid NOT NULL,
    clinic_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    phone character varying(50),
    email character varying(255),
    deleted_at timestamp without time zone,
    relationship_type character varying(128)
);


--
-- TOC entry 227 (class 1259 OID 197384)
-- Name: patient_code_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.patient_code_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 229 (class 1259 OID 197498)
-- Name: patient_guardians; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patient_guardians (
    guardian_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- TOC entry 220 (class 1259 OID 197244)
-- Name: patients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patients (
    id uuid NOT NULL,
    clinic_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    birth_date date NOT NULL,
    diagnosis character varying(255),
    notes text,
    created_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    created_by uuid NOT NULL,
    updated_by uuid,
    updated_at timestamp without time zone,
    patient_code character varying(20) NOT NULL,
    cpf character varying(11),
    phone character varying(20),
    email character varying(255)
);


--
-- TOC entry 219 (class 1259 OID 197229)
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    clinic_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    role character varying(64) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    patient_id uuid,
    guardian_id uuid,
    email_is_confirmed boolean DEFAULT false NOT NULL
);


--
-- TOC entry 224 (class 1259 OID 197317)
-- Name: validations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.validations (
    id uuid NOT NULL,
    clinic_id uuid NOT NULL,
    evaluation_id uuid NOT NULL,
    validated_by uuid NOT NULL,
    status character varying(50) NOT NULL,
    notes text,
    created_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- TOC entry 5002 (class 0 OID 197219)
-- Dependencies: 217
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.alembic_version (version_num) FROM stdin;
0015_patient_guardians_nn
\.


--
-- TOC entry 5007 (class 0 OID 197273)
-- Dependencies: 222
-- Data for Name: anamneses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.anamneses (id, clinic_id, patient_id, data, created_by, created_at, deleted_at, updated_by, updated_at) FROM stdin;
91ef74e8-7ee0-49c4-b2fa-3fa27d70f7aa	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	0997808f-2d1d-4051-b7da-62c77e7cf39b	{"values": {"0-0": "não possui", "0-1": "não possui"}, "sections": [{"title": "Hist�rico Familiar", "fields": [{"type": "text", "label": "Doen�as na fam�lia"}, {"type": "textarea", "label": "Observa��es"}]}]}	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-18 02:09:03.55219	2026-03-18 02:26:00.730826	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-18 02:26:00.730849
2fae095d-90c6-4576-a86e-86f70572a358	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	0997808f-2d1d-4051-b7da-62c77e7cf39b	{"values": {"0-0": "teste", "0-1": "teste"}, "sections": [{"title": "Histórico Familiar", "fields": [{"type": "text", "label": "Doenças na família"}, {"type": "textarea", "label": "Observações"}]}]}	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-18 02:34:04.536607	\N	\N	\N
8b6a41bb-8bbc-4986-88e5-de676293c585	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	0997808f-2d1d-4051-b7da-62c77e7cf39b	{"values": {"0-0": "Não possui", "0-1": "Não possui"}, "sections": [{"title": "Hist?rico Familiar", "fields": [{"type": "text", "label": "Doen?as na fam?lia"}, {"type": "textarea", "label": "Observações"}]}]}	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-19 00:41:19.091633	2026-03-19 01:22:17.491755	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-19 01:22:17.491792
af4eff07-234c-476c-a116-b08dffd104e0	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	95f4d7dd-7093-4865-854f-a4928455e647	{"values": {"0-0": "Não possui", "0-1": "Não possui"}, "sections": [{"title": "Histórico Familiar", "fields": [{"type": "text", "label": "Doenças na família"}, {"type": "textarea", "label": "Observações"}]}]}	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-19 01:22:31.15005	\N	\N	\N
b3b0ce7b-396e-433e-a4a7-76accbfff826	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	cf5af676-6617-46a0-895c-d200d82ebb45	{"values": {"0-0": "Não possui", "0-1": "Não possui"}, "sections": [{"title": "Histórico Familiar", "fields": [{"type": "text", "label": "Doenças na família"}, {"type": "textarea", "label": "Observações"}]}]}	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-19 17:34:26.534984	\N	\N	\N
\.


--
-- TOC entry 5013 (class 0 OID 197387)
-- Dependencies: 228
-- Data for Name: appointments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.appointments (id, clinic_id, patient_id, therapist_id, scheduled_at, status, notes, created_by, updated_by, created_at, updated_at, deleted_at, date, "time", type, is_first_visit, is_confirmed, confirmed_at, confirmed_by) FROM stdin;
25043469-34b1-486e-b834-784dd7c22089	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	0997808f-2d1d-4051-b7da-62c77e7cf39b	be9f06d8-7bbe-43c4-b5a8-f4bed1bb00bd	2026-03-20 06:43:00	scheduled	cvcxvcxvdsfdsfd	af907885-7976-4ff1-a7d6-f1834f3cf63c	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-19 03:37:33.902896	2026-03-19 03:41:42.76751	2026-03-19 03:41:42.767484	2026-03-20	06:43:00	Terapia ABA	f	f	\N	\N
6b1c1a13-8d18-47a5-b05c-131148233c51	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	95f4d7dd-7093-4865-854f-a4928455e647	be9f06d8-7bbe-43c4-b5a8-f4bed1bb00bd	2026-03-20 06:49:00	scheduled	Teste	af907885-7976-4ff1-a7d6-f1834f3cf63c	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-19 03:43:38.883735	2026-03-19 03:43:52.388086	2026-03-19 03:43:52.388066	2026-03-20	06:49:00	Terapia ABA	f	f	\N	\N
dba652ef-2e26-42a2-855d-233c1ab2bc40	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	1eb130b9-b673-47f4-847d-00cc7c4a4e2c	be9f06d8-7bbe-43c4-b5a8-f4bed1bb00bd	2026-03-01 13:00:00	scheduled		af907885-7976-4ff1-a7d6-f1834f3cf63c	\N	2026-03-19 13:57:40.608847	\N	\N	2026-03-01	13:00:00	Reforço escolar	t	f	\N	\N
fb73e2fe-4be3-4d09-b956-02a5d4162fb9	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	1eb130b9-b673-47f4-847d-00cc7c4a4e2c	be9f06d8-7bbe-43c4-b5a8-f4bed1bb00bd	2026-03-20 13:01:00	scheduled		af907885-7976-4ff1-a7d6-f1834f3cf63c	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-19 13:58:20.416435	2026-03-19 14:21:00.551053	\N	2026-03-20	13:01:00	Reforço escolar	f	t	2026-03-19 14:21:00.551053	af907885-7976-4ff1-a7d6-f1834f3cf63c
cdcee7b2-be5e-4f43-84b0-2540dd9f99c6	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	0997808f-2d1d-4051-b7da-62c77e7cf39b	be9f06d8-7bbe-43c4-b5a8-f4bed1bb00bd	2026-03-20 02:55:00	scheduled	zzxzx	af907885-7976-4ff1-a7d6-f1834f3cf63c	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-19 03:53:41.225339	2026-03-19 14:23:51.574072	2026-03-19 14:23:51.574012	2026-03-20	02:55:00	Terapia convencional	t	f	\N	\N
0d70657a-cd10-48d2-92f4-5f3f6b155e33	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	95f4d7dd-7093-4865-854f-a4928455e647	be9f06d8-7bbe-43c4-b5a8-f4bed1bb00bd	2026-03-15 04:00:00	scheduled	dsadsadsad	af907885-7976-4ff1-a7d6-f1834f3cf63c	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-19 03:57:35.847083	2026-03-19 14:25:22.247662	\N	2026-03-15	04:00:00	Reforço escolar	f	f	\N	\N
4da7c541-9d15-4ecc-bc1b-7d0cb59e4f4a	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	cf5af676-6617-46a0-895c-d200d82ebb45	be9f06d8-7bbe-43c4-b5a8-f4bed1bb00bd	2026-03-01 17:41:00	scheduled		af907885-7976-4ff1-a7d6-f1834f3cf63c	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-19 17:38:53.298068	2026-03-19 17:39:58.139632	\N	2026-03-01	17:41:00	Terapia convencional	t	t	2026-03-19 17:39:58.139632	af907885-7976-4ff1-a7d6-f1834f3cf63c
\.


--
-- TOC entry 5011 (class 0 OID 197361)
-- Dependencies: 226
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_logs (id, clinic_id, user_id, action, entity, entity_id, meta, created_at) FROM stdin;
fd68eddd-0eb7-49b5-942c-1a2330d09940	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	patient	0997808f-2d1d-4051-b7da-62c77e7cf39b	{}	2026-03-18 01:17:27.289429
f4146b9f-37d1-4f7d-9689-9f4d7ad50020	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	patient	95f4d7dd-7093-4865-854f-a4928455e647	{}	2026-03-18 01:17:42.534716
1d2ed1fe-eaf7-47eb-b5c5-6a0f6666fa02	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	update	patient	95f4d7dd-7093-4865-854f-a4928455e647	{}	2026-03-18 01:17:58.794126
c5c11735-c576-4659-baf6-7c69bce20802	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	anamnese	91ef74e8-7ee0-49c4-b2fa-3fa27d70f7aa	{}	2026-03-18 02:09:03.570439
3af16d74-73f1-4fce-a4c2-a9c18daff02c	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	evaluation	aff46a5f-ed7b-4f10-9785-881f52c6e066	{}	2026-03-18 02:09:27.096722
8e0a9bef-36ae-4d46-9c9d-3612c6f95961	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	validate	evaluation	aff46a5f-ed7b-4f10-9785-881f52c6e066	{"status": "approved"}	2026-03-18 02:09:37.46088
79684bd6-9b3c-4453-8082-09680f0b106d	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	validate	evaluation	aff46a5f-ed7b-4f10-9785-881f52c6e066	{"status": "rejected"}	2026-03-18 02:09:39.506713
89cd6e68-1764-4851-849a-65e1332215e3	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	evolution	d7b74037-a0d3-4cb7-a5df-e17d63ecf872	{}	2026-03-18 02:10:07.430725
f9504b37-d7af-47cf-bcd0-f6c9414631b6	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	delete	anamnese	91ef74e8-7ee0-49c4-b2fa-3fa27d70f7aa	{}	2026-03-18 02:26:00.733856
9e1dbb5f-29aa-436f-bcb3-b08c9c3db811	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	delete	evaluation	aff46a5f-ed7b-4f10-9785-881f52c6e066	{}	2026-03-18 02:26:10.149909
a896f176-c5a1-42b1-b2e0-e3e320b64ca1	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	evaluation	0c35d147-95c9-4dcd-afd3-6243d241eaf6	{}	2026-03-18 02:33:40.681296
d8659592-2120-4d1f-bb3f-71422750722c	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	anamnese	2fae095d-90c6-4576-a86e-86f70572a358	{}	2026-03-18 02:34:04.539983
91fb985c-c1a5-42ab-a251-a9a577308e36	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	validate	evaluation	0c35d147-95c9-4dcd-afd3-6243d241eaf6	{"status": "approved"}	2026-03-18 03:24:12.784594
05e4c282-1089-4ed6-bc8b-7d8a7158ece9	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	delete	evolution	d7b74037-a0d3-4cb7-a5df-e17d63ecf872	{}	2026-03-18 03:26:13.236574
0e005806-33bf-401a-a50d-8bb5e8cc7610	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	guardian	18d06ba3-9ddb-441d-ae77-770dfc2d25c4	{}	2026-03-18 03:53:05.64292
232684a6-977f-48a3-acf1-f8a29b8782d0	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	update	guardian	18d06ba3-9ddb-441d-ae77-770dfc2d25c4	{}	2026-03-19 00:40:38.952344
aa8d1a1c-4d7d-42d4-a218-8b469b6f13db	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	anamnese	8b6a41bb-8bbc-4986-88e5-de676293c585	{}	2026-03-19 00:41:19.097144
3cea55fc-a34e-46e6-aedb-da3108caeb14	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	guardian	2c4d9533-5503-4cdc-96d6-ae6afe383f69	{}	2026-03-19 00:42:23.062933
6c251c57-d512-4c27-8b47-f52f7a657a10	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	evaluation	1afb52d2-390e-434a-9634-cc7762daa732	{}	2026-03-19 00:44:21.71172
1d0f0227-f69e-4d4c-817e-fedfe0861849	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	evolution	7c47ebb3-d876-4bc4-bfc8-e72b6a778cbb	{}	2026-03-19 00:52:10.874556
f122b5eb-834a-49d2-a54b-0be788075a28	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	delete	evolution	7c47ebb3-d876-4bc4-bfc8-e72b6a778cbb	{}	2026-03-19 00:53:12.705874
038a84b2-49fa-4165-a4ce-7f112853c305	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	evolution	ba452a14-550c-4135-8140-a94dfc4866ec	{}	2026-03-19 00:53:59.206012
bf571585-b0d9-4117-a417-46c7133865fc	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	delete	anamnese	8b6a41bb-8bbc-4986-88e5-de676293c585	{}	2026-03-19 01:22:17.498918
f28cb40e-6d40-4bfd-8818-c216a075fa4e	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	anamnese	af4eff07-234c-476c-a116-b08dffd104e0	{}	2026-03-19 01:22:31.154148
9bb7f52a-238a-4a7d-a521-25e8a42c4046	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	appointment	25043469-34b1-486e-b834-784dd7c22089	{}	2026-03-19 03:37:33.912634
ead12275-9c44-42f2-a503-1c4f814fb533	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	delete	appointment	25043469-34b1-486e-b834-784dd7c22089	{}	2026-03-19 03:41:42.77115
37d2e359-03da-4965-bc74-aaba97363779	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	appointment	6b1c1a13-8d18-47a5-b05c-131148233c51	{}	2026-03-19 03:43:38.894055
11fc54d7-3627-4f21-9db5-d07efd6ecf35	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	delete	appointment	6b1c1a13-8d18-47a5-b05c-131148233c51	{}	2026-03-19 03:43:52.391564
2a983076-64fc-4576-a590-612d9d219aba	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	appointment	cdcee7b2-be5e-4f43-84b0-2540dd9f99c6	{}	2026-03-19 03:53:41.237154
90a8e859-47b5-43e8-abb2-9e257e70f3fa	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	update	appointment	cdcee7b2-be5e-4f43-84b0-2540dd9f99c6	{}	2026-03-19 03:54:18.461095
759dfc86-bdcc-4e20-9884-49f6426a1cf9	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	update	appointment	cdcee7b2-be5e-4f43-84b0-2540dd9f99c6	{}	2026-03-19 03:54:43.015963
d3aeec58-4f47-478b-a82c-93296961c45f	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	update	appointment	cdcee7b2-be5e-4f43-84b0-2540dd9f99c6	{}	2026-03-19 03:55:06.276582
83c84973-ef2c-47fb-91e7-feaee5eeee4f	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	update	appointment	cdcee7b2-be5e-4f43-84b0-2540dd9f99c6	{}	2026-03-19 03:55:27.106775
66d1fa22-8ec4-47ef-aea3-6df7f5388caa	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	appointment	0d70657a-cd10-48d2-92f4-5f3f6b155e33	{}	2026-03-19 03:57:35.850933
545bfb80-fa63-4350-b33a-38ef8908425a	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	update	patient	95f4d7dd-7093-4865-854f-a4928455e647	{}	2026-03-19 04:05:17.215446
91815b11-9af0-4718-b183-708bff1f39a0	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	delete	guardian	2c4d9533-5503-4cdc-96d6-ae6afe383f69	{}	2026-03-19 04:06:54.222759
97c6f46b-e8a5-4463-bbb0-2bae4c347a16	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	delete	patient	0997808f-2d1d-4051-b7da-62c77e7cf39b	{}	2026-03-19 04:07:29.20911
85c63844-7342-4ba6-a6af-0e970df1d067	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	patient	1eb130b9-b673-47f4-847d-00cc7c4a4e2c	{}	2026-03-19 13:56:56.246342
a9aa83ff-5bb4-4c89-b277-23f1959d4115	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	appointment	dba652ef-2e26-42a2-855d-233c1ab2bc40	{}	2026-03-19 13:57:40.618395
87423c62-4b89-4e22-a9e9-909fa8fd62ce	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	appointment	fb73e2fe-4be3-4d09-b956-02a5d4162fb9	{}	2026-03-19 13:58:20.419978
e222f80e-37ac-486a-ad15-174f95baeb7e	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	patient	13938e0a-bcdd-4779-9f78-62eacb3ac22d	{}	2026-03-19 14:16:49.121852
5bc2580d-8ca4-4fbf-a22f-02898185466c	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	confirm	appointment	fb73e2fe-4be3-4d09-b956-02a5d4162fb9	{}	2026-03-19 14:21:00.561188
b5423edc-05fe-4383-81e8-f0dc6eef488f	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	delete	appointment	cdcee7b2-be5e-4f43-84b0-2540dd9f99c6	{}	2026-03-19 14:23:51.581762
091359ad-5923-4330-9bc6-0d9c3023bd55	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	update	appointment	0d70657a-cd10-48d2-92f4-5f3f6b155e33	{}	2026-03-19 14:25:22.251744
625e4d29-d4ee-4695-a60c-15dbee624ee9	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	validate	evaluation	0c35d147-95c9-4dcd-afd3-6243d241eaf6	{"status": "rejected"}	2026-03-19 14:35:05.580648
6eb2c9a1-3669-4c0d-a721-15180d6fda34	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	validate	evaluation	0c35d147-95c9-4dcd-afd3-6243d241eaf6	{"status": "approved"}	2026-03-19 14:35:07.378306
d8314b1a-b341-44cc-8aca-4824e4132770	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	validate	evaluation	0c35d147-95c9-4dcd-afd3-6243d241eaf6	{"status": "rejected"}	2026-03-19 14:35:21.792895
641a0879-9cc0-4242-be69-c2453e7316ee	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	validate	evaluation	0c35d147-95c9-4dcd-afd3-6243d241eaf6	{"status": "approved"}	2026-03-19 14:35:22.881492
39acf94c-87d9-4ea0-ba93-d388d0766931	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	validate	evaluation	0c35d147-95c9-4dcd-afd3-6243d241eaf6	{"status": "approved"}	2026-03-19 14:35:23.510941
1ab9a80b-07d6-43f7-9cc9-4f2322d7e06a	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	validate	evaluation	0c35d147-95c9-4dcd-afd3-6243d241eaf6	{"status": "rejected"}	2026-03-19 14:35:24.158131
0b6c694d-bc0c-4f7c-bb70-6a0c8aa6eaa7	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	validate	evaluation	0c35d147-95c9-4dcd-afd3-6243d241eaf6	{"status": "rejected"}	2026-03-19 14:35:24.837259
fc464cae-92f8-4faa-8c19-fefd5e7e0feb	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	validate	evaluation	0c35d147-95c9-4dcd-afd3-6243d241eaf6	{"status": "approved"}	2026-03-19 14:35:25.43289
7a7cef21-ce46-4b30-81ac-e644dd057614	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	validate	evaluation	0c35d147-95c9-4dcd-afd3-6243d241eaf6	{"status": "rejected"}	2026-03-19 14:35:27.218359
70d5566f-1fdf-4436-ad1c-eebe45f9a33c	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	validate	evaluation	0c35d147-95c9-4dcd-afd3-6243d241eaf6	{"status": "approved"}	2026-03-19 14:35:28.191887
58b16940-82be-4b40-a72f-ecf47c32384c	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	validate	evaluation	0c35d147-95c9-4dcd-afd3-6243d241eaf6	{"status": "approved"}	2026-03-19 14:57:08.063707
ff978282-7361-41d3-a79e-055875ebf7fa	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	validate	evaluation	0c35d147-95c9-4dcd-afd3-6243d241eaf6	{"status": "approved"}	2026-03-19 14:57:09.203042
e99561ca-1b76-4404-aa87-16f4b6ff115b	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	validate	evaluation	0c35d147-95c9-4dcd-afd3-6243d241eaf6	{"status": "approved"}	2026-03-19 14:57:10.706173
40810ec1-d8f7-4cc7-85f6-f372fbbafa3a	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	validate	evaluation	0c35d147-95c9-4dcd-afd3-6243d241eaf6	{"status": "approved"}	2026-03-19 14:57:11.458566
a93099e9-403a-4a9e-bad9-cd4ab6b8f663	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	validate	evaluation	0c35d147-95c9-4dcd-afd3-6243d241eaf6	{"status": "approved"}	2026-03-19 14:57:12.779679
061acbde-051c-43ee-9ece-c72ab6d14fd7	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	validate	evaluation	0c35d147-95c9-4dcd-afd3-6243d241eaf6	{"status": "rejected"}	2026-03-19 14:58:14.695794
e1fb603d-49a5-4d3a-9e0c-c6652967eaba	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	validate	evaluation	0c35d147-95c9-4dcd-afd3-6243d241eaf6	{"status": "rejected"}	2026-03-19 14:58:18.845818
be78c45b-cc76-4ce7-8263-b136316a7a65	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	patient	fe0af5f6-5d6e-48aa-b947-6ed745ba0d41	{}	2026-03-19 15:24:38.890634
d2372656-5bbf-4d8c-a800-fada3334aebc	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	validate	evaluation	1afb52d2-390e-434a-9634-cc7762daa732	{"status": "approved"}	2026-03-19 15:26:20.142165
fa7a42a8-d136-4b85-afb3-8c4bb7d8e78d	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	delete	patient	fe0af5f6-5d6e-48aa-b947-6ed745ba0d41	{}	2026-03-19 15:36:07.950638
1121567c-2cd1-4262-9d9a-0316fdc8108c	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	patient	0f208c0e-f4c3-46f2-9e9b-cf81824004de	{}	2026-03-19 15:36:45.523325
6bd73e4d-24af-4c4e-846b-b7c3fa847dc6	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	patient	3519b5bc-d883-4a6e-88e6-0eab4dbd4243	{}	2026-03-19 15:40:40.944646
d085f1ad-31d8-4b47-9d00-312506854633	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	patient	fab45985-4c8f-4132-839e-9abc82354ef6	{}	2026-03-19 16:12:58.915247
76383c62-6653-4e1c-889e-6b8f399146c1	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	patient	550da466-724e-44ae-b609-265a7fad55ae	{}	2026-03-19 16:26:54.53152
c562ff0e-77eb-4ec7-a262-2545656dba75	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	patient	cf5af676-6617-46a0-895c-d200d82ebb45	{}	2026-03-19 16:52:34.457699
d1810ff5-41c4-40c7-9d87-c7753f2c2b5f	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	anamnese	b3b0ce7b-396e-433e-a4a7-76accbfff826	{}	2026-03-19 17:34:26.544034
9fa38906-5ff4-4757-b9f4-7289ad75a51e	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	evaluation	6aceb9b0-1cb2-4804-aed6-65a66ceb5c36	{}	2026-03-19 17:35:04.980301
36362352-1a44-4cc3-a884-fa032fa32439	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	validate	evaluation	6aceb9b0-1cb2-4804-aed6-65a66ceb5c36	{"status": "approved"}	2026-03-19 17:36:47.138227
b5701223-6112-49ba-9b34-6cb008bb754f	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	evolution	d1af7297-230e-4873-8b01-b0aa54a11c92	{}	2026-03-19 17:37:33.655981
e58b3786-63cd-4a7d-8d9d-f1c42f757857	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	create	appointment	4da7c541-9d15-4ecc-bc1b-7d0cb59e4f4a	{}	2026-03-19 17:38:53.305007
6733a197-15e7-4dbf-9b89-9b1fa01ff2ab	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	af907885-7976-4ff1-a7d6-f1834f3cf63c	confirm	appointment	4da7c541-9d15-4ecc-bc1b-7d0cb59e4f4a	{}	2026-03-19 17:39:58.143795
\.


--
-- TOC entry 5003 (class 0 OID 197224)
-- Dependencies: 218
-- Data for Name: clinics; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.clinics (id, name, created_at) FROM stdin;
800f03ea-6d6b-44b6-8a2c-3cb0b391033c	Clínica Demo	2026-03-17 19:03:23.389566
\.


--
-- TOC entry 5008 (class 0 OID 197295)
-- Dependencies: 223
-- Data for Name: evaluations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.evaluations (id, clinic_id, patient_id, type, result, status, created_by, created_at, deleted_at, updated_by, updated_at) FROM stdin;
aff46a5f-ed7b-4f10-9785-881f52c6e066	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	0997808f-2d1d-4051-b7da-62c77e7cf39b	TEste	{"raw": "Teste"}	rejected	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-18 02:09:27.001504	2026-03-18 02:26:10.145969	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-18 02:26:10.145999
0c35d147-95c9-4dcd-afd3-6243d241eaf6	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	0997808f-2d1d-4051-b7da-62c77e7cf39b	teste	{"value": "teste"}	rejected	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-18 02:33:40.675624	\N	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-19 14:58:18.842052
1afb52d2-390e-434a-9634-cc7762daa732	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	95f4d7dd-7093-4865-854f-a4928455e647	Teste de psicomotor	{"value": "Foi observada melhorias ao pegar e segurar objetos usando as duas mãos."}	approved	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-19 00:44:21.708202	\N	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-19 15:26:20.13438
6aceb9b0-1cb2-4804-aed6-65a66ceb5c36	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	cf5af676-6617-46a0-895c-d200d82ebb45	Teste	{"value": "teste"}	approved	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-19 17:35:04.975161	\N	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-19 17:36:47.127699
\.


--
-- TOC entry 5010 (class 0 OID 197339)
-- Dependencies: 225
-- Data for Name: evolutions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.evolutions (id, clinic_id, patient_id, description, created_by, created_at, deleted_at, updated_by, updated_at) FROM stdin;
d7b74037-a0d3-4cb7-a5df-e17d63ecf872	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	0997808f-2d1d-4051-b7da-62c77e7cf39b	sadsadsadsa	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-18 02:10:07.423602	2026-03-18 03:26:13.227814	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-18 03:26:13.227844
7c47ebb3-d876-4bc4-bfc8-e72b6a778cbb	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	95f4d7dd-7093-4865-854f-a4928455e647	Teste de avaliação	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-19 00:52:10.870875	2026-03-19 00:53:12.697726	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-19 00:53:12.69775
ba452a14-550c-4135-8140-a94dfc4866ec	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	95f4d7dd-7093-4865-854f-a4928455e647	teste evolução	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-19 00:53:59.203864	\N	\N	\N
d1af7297-230e-4873-8b01-b0aa54a11c92	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	cf5af676-6617-46a0-895c-d200d82ebb45	teste De evolução	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-19 17:37:33.65187	\N	\N	\N
\.


--
-- TOC entry 5006 (class 0 OID 197256)
-- Dependencies: 221
-- Data for Name: guardians; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.guardians (id, clinic_id, name, phone, email, deleted_at, relationship_type) FROM stdin;
18d06ba3-9ddb-441d-ae77-770dfc2d25c4	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	dsads	123213	\N	\N	Mãe
2c4d9533-5503-4cdc-96d6-ae6afe383f69	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	Maria Joaquina	12345678909	\N	2026-03-19 04:06:54.218295	Mãe
c30591f9-327f-4d65-9e22-6cd7c52144d2	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	Maria	61991865680	maria@email.com	\N	Mãe
c10b96a5-1b04-475e-90a8-dab6d9528b3b	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	Maria	61991865680	\N	\N	Mãe
26fb63ee-a7a8-45c4-977e-e60da8a41da9	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	Maria de Fatima	\N	teste@email.com	\N	Mãe
\.


--
-- TOC entry 5014 (class 0 OID 197498)
-- Dependencies: 229
-- Data for Name: patient_guardians; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.patient_guardians (guardian_id, patient_id, created_at) FROM stdin;
18d06ba3-9ddb-441d-ae77-770dfc2d25c4	0997808f-2d1d-4051-b7da-62c77e7cf39b	2026-03-19 02:27:47.236347
c30591f9-327f-4d65-9e22-6cd7c52144d2	1eb130b9-b673-47f4-847d-00cc7c4a4e2c	2026-03-19 13:56:56.240724
c10b96a5-1b04-475e-90a8-dab6d9528b3b	13938e0a-bcdd-4779-9f78-62eacb3ac22d	2026-03-19 14:16:49.115318
26fb63ee-a7a8-45c4-977e-e60da8a41da9	fab45985-4c8f-4132-839e-9abc82354ef6	2026-03-19 16:12:58.906691
26fb63ee-a7a8-45c4-977e-e60da8a41da9	cf5af676-6617-46a0-895c-d200d82ebb45	2026-03-19 16:52:34.445611
18d06ba3-9ddb-441d-ae77-770dfc2d25c4	95f4d7dd-7093-4865-854f-a4928455e647	2026-03-19 14:21:25.277226
2c4d9533-5503-4cdc-96d6-ae6afe383f69	0997808f-2d1d-4051-b7da-62c77e7cf39b	2026-03-19 14:21:25.277226
\.


--
-- TOC entry 5005 (class 0 OID 197244)
-- Dependencies: 220
-- Data for Name: patients; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.patients (id, clinic_id, name, birth_date, diagnosis, notes, created_at, deleted_at, created_by, updated_by, updated_at, patient_code, cpf, phone, email) FROM stdin;
95f4d7dd-7093-4865-854f-a4928455e647	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	Teste da silva 2	2026-03-18	teste	criança com teste 	2026-03-18 01:17:42.531524	\N	af907885-7976-4ff1-a7d6-f1834f3cf63c	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-19 04:05:17.208756	PAC-000002	\N	\N	\N
0997808f-2d1d-4051-b7da-62c77e7cf39b	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	Teste da silva	2026-03-18	teste	criança com teste teste teste teste teste teste	2026-03-18 01:17:27.275147	2026-03-19 04:07:29.206398	af907885-7976-4ff1-a7d6-f1834f3cf63c	af907885-7976-4ff1-a7d6-f1834f3cf63c	2026-03-19 04:07:29.206419	PAC-000001	\N	\N	\N
1eb130b9-b673-47f4-847d-00cc7c4a4e2c	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	Teste 003	2026-03-02			2026-03-19 13:56:55.765265	\N	af907885-7976-4ff1-a7d6-f1834f3cf63c	\N	\N	PAC-000004	\N	61991865680	teste@teste.com
13938e0a-bcdd-4779-9f78-62eacb3ac22d	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	teste 0065	2026-03-01			2026-03-19 14:16:49.10646	\N	af907885-7976-4ff1-a7d6-f1834f3cf63c	\N	\N	PAC-000005	\N	61991865680	\N
fab45985-4c8f-4132-839e-9abc82354ef6	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	rafael teste	2026-03-01			2026-03-19 16:12:58.453677	\N	af907885-7976-4ff1-a7d6-f1834f3cf63c	\N	\N	PAC-000009	\N	61991865680	rafael.f.p.faria@hotmail.com
cf5af676-6617-46a0-895c-d200d82ebb45	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	rafael teste 001	2026-03-01			2026-03-19 16:52:34.192229	\N	af907885-7976-4ff1-a7d6-f1834f3cf63c	\N	\N	PAC-000011	\N	61991865680	rafael.f.p.fariadk@gmail.com
\.


--
-- TOC entry 5004 (class 0 OID 197229)
-- Dependencies: 219
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, clinic_id, name, email, password_hash, role, created_at, deleted_at, patient_id, guardian_id, email_is_confirmed) FROM stdin;
af907885-7976-4ff1-a7d6-f1834f3cf63c	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	Admin	admin@clinic.com	$2b$12$/7ovYDTAupeJc3oYP3wVROk1rKqZ5L/F8hLpTeeULVJwxqLlHuwei	admin	2026-03-17 19:03:23.632623	\N	\N	\N	f
be9f06d8-7bbe-43c4-b5a8-f4bed1bb00bd	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	Terapeuta Demo	terapeuta@demo.com	$2b$12$fGpJ1OL6syMFKi3IAEn0HeMYnXz9u9MO8jwEF8RUU72h3XZ5iFGji	therapist	2026-03-19 02:27:46.564394	\N	\N	\N	f
cdf95792-29b7-4401-9caf-e3686c0b7f6f	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	Recepção Demo	recepcao@demo.com	$2b$12$J.RwlrnSdgDc7A23Sc5yLumZtcJtfTiufV4YcJ4i5xmJpJQczuhye	receptionist	2026-03-19 02:27:46.788859	\N	\N	\N	f
3e40ccb6-8dbb-44ce-b23e-11f900eb747c	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	Responsável Demo	responsavel@demo.com	$2b$12$2rVr45cEDXXMZwduUQIYSufZg7ymgE5vmsGGdBb.o/bfiDP/RjfN6	guardian	2026-03-19 02:27:47.229331	\N	\N	18d06ba3-9ddb-441d-ae77-770dfc2d25c4	f
6816d629-c66d-4ad7-8cc7-70e188684526	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	Teste 003	teste@teste.com	$2b$12$nJTTwhB8lgqGeKhphJ9MTeVILQEunZeEWNqkMLrveeh591Lm9IrzS	patient	2026-03-19 13:56:56.012032	\N	1eb130b9-b673-47f4-847d-00cc7c4a4e2c	\N	f
038b38d8-d5ec-4228-83ec-73c6049b3862	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	Maria	maria@email.com	$2b$12$piEMUXkRVXYoaTntnCFy0.YS2NLDwOYqpSf7U/kKKW8W9fb7oV4yK	guardian	2026-03-19 13:56:56.241587	\N	\N	c30591f9-327f-4d65-9e22-6cd7c52144d2	f
ac65418c-2cc9-46e6-b9f0-376d1bd9bfa6	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	Paciente Demo	paciente@demo.com	$2b$12$Z72ZsLnJ2ZydwKmrNvB4fOe36pYyT4UE4SoYcYQh8xqCJhi9GbJpO	patient	2026-03-19 02:27:47.010412	\N	\N	\N	f
9a958139-1ea4-42fd-94d2-0159c0411fbe	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	Maria de Fatima	teste@email.com	$2b$12$Ez7sGa5M4CUXf8E5mAcyGuPOXDCeszYrQgpG/J0c3QW/I3PLngIrC	guardian	2026-03-19 16:12:58.907582	\N	\N	26fb63ee-a7a8-45c4-977e-e60da8a41da9	f
080e261f-1940-4e1a-9f17-0f27c04b3eac	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	rafael teste	rafael.f.p.faria@hotmail.com	$2b$12$rI99wMEOf/FdCM56oCit0eXTl4HRbXigdyzUE1iFV6zOTSPiLtoYK	patient	2026-03-19 16:12:58.67923	\N	fab45985-4c8f-4132-839e-9abc82354ef6	\N	t
b6b62e95-dd5c-4b25-bc49-256a6a8d0f43	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	rafael teste 001	rafael.f.p.fariadk@gmail.com	$2b$12$La/dZMdECapPPj6FPM9xxO7a6nOkH5Xy2z70lCXnYd.Ecj1JrB206	patient	2026-03-19 16:52:34.437161	\N	cf5af676-6617-46a0-895c-d200d82ebb45	\N	f
\.


--
-- TOC entry 5009 (class 0 OID 197317)
-- Dependencies: 224
-- Data for Name: validations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.validations (id, clinic_id, evaluation_id, validated_by, status, notes, created_at, deleted_at) FROM stdin;
12d84bda-97c2-45b9-a30b-d3168f0821ae	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	1afb52d2-390e-434a-9634-cc7762daa732	af907885-7976-4ff1-a7d6-f1834f3cf63c	approved	\N	2026-03-19 15:26:20.137319	\N
5cad841e-298c-42bd-a58e-975087f25fd6	800f03ea-6d6b-44b6-8a2c-3cb0b391033c	6aceb9b0-1cb2-4804-aed6-65a66ceb5c36	af907885-7976-4ff1-a7d6-f1834f3cf63c	approved	\N	2026-03-19 17:36:47.131711	\N
\.


--
-- TOC entry 5021 (class 0 OID 0)
-- Dependencies: 227
-- Name: patient_code_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.patient_code_seq', 11, true);


--
-- TOC entry 4789 (class 2606 OID 197521)
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- TOC entry 4807 (class 2606 OID 197279)
-- Name: anamneses anamneses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anamneses
    ADD CONSTRAINT anamneses_pkey PRIMARY KEY (id);


--
-- TOC entry 4822 (class 2606 OID 197393)
-- Name: appointments appointments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_pkey PRIMARY KEY (id);


--
-- TOC entry 4820 (class 2606 OID 197367)
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 4791 (class 2606 OID 197228)
-- Name: clinics clinics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clinics
    ADD CONSTRAINT clinics_pkey PRIMARY KEY (id);


--
-- TOC entry 4810 (class 2606 OID 197301)
-- Name: evaluations evaluations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evaluations
    ADD CONSTRAINT evaluations_pkey PRIMARY KEY (id);


--
-- TOC entry 4817 (class 2606 OID 197345)
-- Name: evolutions evolutions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evolutions
    ADD CONSTRAINT evolutions_pkey PRIMARY KEY (id);


--
-- TOC entry 4805 (class 2606 OID 197262)
-- Name: guardians guardians_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guardians
    ADD CONSTRAINT guardians_pkey PRIMARY KEY (id);


--
-- TOC entry 4803 (class 2606 OID 197250)
-- Name: patients patients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_pkey PRIMARY KEY (id);


--
-- TOC entry 4829 (class 2606 OID 197556)
-- Name: patient_guardians pk_patient_guardians; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_guardians
    ADD CONSTRAINT pk_patient_guardians PRIMARY KEY (patient_id, guardian_id);


--
-- TOC entry 4796 (class 2606 OID 197237)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4798 (class 2606 OID 197235)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4815 (class 2606 OID 197323)
-- Name: validations validations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.validations
    ADD CONSTRAINT validations_pkey PRIMARY KEY (id);


--
-- TOC entry 4808 (class 1259 OID 197379)
-- Name: ix_anamneses_clinic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_anamneses_clinic_id ON public.anamneses USING btree (clinic_id);


--
-- TOC entry 4823 (class 1259 OID 197419)
-- Name: ix_appointments_clinic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_appointments_clinic_id ON public.appointments USING btree (clinic_id);


--
-- TOC entry 4824 (class 1259 OID 197420)
-- Name: ix_appointments_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_appointments_patient_id ON public.appointments USING btree (patient_id);


--
-- TOC entry 4825 (class 1259 OID 197421)
-- Name: ix_appointments_scheduled_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_appointments_scheduled_at ON public.appointments USING btree (scheduled_at);


--
-- TOC entry 4811 (class 1259 OID 197380)
-- Name: ix_evaluations_clinic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_evaluations_clinic_id ON public.evaluations USING btree (clinic_id);


--
-- TOC entry 4812 (class 1259 OID 197381)
-- Name: ix_evaluations_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_evaluations_patient_id ON public.evaluations USING btree (patient_id);


--
-- TOC entry 4813 (class 1259 OID 197526)
-- Name: ix_evaluations_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_evaluations_status ON public.evaluations USING btree (status);


--
-- TOC entry 4818 (class 1259 OID 197383)
-- Name: ix_evolutions_clinic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_evolutions_clinic_id ON public.evolutions USING btree (clinic_id);


--
-- TOC entry 4826 (class 1259 OID 197568)
-- Name: ix_patient_guardians_guardian_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_patient_guardians_guardian_id ON public.patient_guardians USING btree (guardian_id);


--
-- TOC entry 4827 (class 1259 OID 197567)
-- Name: ix_patient_guardians_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_patient_guardians_patient_id ON public.patient_guardians USING btree (patient_id);


--
-- TOC entry 4799 (class 1259 OID 197378)
-- Name: ix_patients_clinic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_patients_clinic_id ON public.patients USING btree (clinic_id);


--
-- TOC entry 4800 (class 1259 OID 197386)
-- Name: ix_patients_cpf; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_patients_cpf ON public.patients USING btree (cpf);


--
-- TOC entry 4801 (class 1259 OID 197385)
-- Name: ix_patients_patient_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_patients_patient_code ON public.patients USING btree (patient_code);


--
-- TOC entry 4792 (class 1259 OID 197243)
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- TOC entry 4793 (class 1259 OID 197487)
-- Name: ix_users_guardian_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_users_guardian_id ON public.users USING btree (guardian_id);


--
-- TOC entry 4794 (class 1259 OID 197486)
-- Name: ix_users_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_users_patient_id ON public.users USING btree (patient_id);


--
-- TOC entry 4835 (class 2606 OID 197280)
-- Name: anamneses anamneses_clinic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anamneses
    ADD CONSTRAINT anamneses_clinic_id_fkey FOREIGN KEY (clinic_id) REFERENCES public.clinics(id);


--
-- TOC entry 4836 (class 2606 OID 197290)
-- Name: anamneses anamneses_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anamneses
    ADD CONSTRAINT anamneses_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- TOC entry 4837 (class 2606 OID 197285)
-- Name: anamneses anamneses_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anamneses
    ADD CONSTRAINT anamneses_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- TOC entry 4849 (class 2606 OID 197394)
-- Name: appointments appointments_clinic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_clinic_id_fkey FOREIGN KEY (clinic_id) REFERENCES public.clinics(id);


--
-- TOC entry 4850 (class 2606 OID 197409)
-- Name: appointments appointments_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- TOC entry 4851 (class 2606 OID 197399)
-- Name: appointments appointments_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- TOC entry 4852 (class 2606 OID 197404)
-- Name: appointments appointments_therapist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_therapist_id_fkey FOREIGN KEY (therapist_id) REFERENCES public.users(id);


--
-- TOC entry 4853 (class 2606 OID 197414)
-- Name: appointments appointments_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- TOC entry 4847 (class 2606 OID 197368)
-- Name: audit_logs audit_logs_clinic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_clinic_id_fkey FOREIGN KEY (clinic_id) REFERENCES public.clinics(id);


--
-- TOC entry 4848 (class 2606 OID 197373)
-- Name: audit_logs audit_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 4838 (class 2606 OID 197302)
-- Name: evaluations evaluations_clinic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evaluations
    ADD CONSTRAINT evaluations_clinic_id_fkey FOREIGN KEY (clinic_id) REFERENCES public.clinics(id);


--
-- TOC entry 4839 (class 2606 OID 197312)
-- Name: evaluations evaluations_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evaluations
    ADD CONSTRAINT evaluations_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- TOC entry 4840 (class 2606 OID 197307)
-- Name: evaluations evaluations_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evaluations
    ADD CONSTRAINT evaluations_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- TOC entry 4844 (class 2606 OID 197346)
-- Name: evolutions evolutions_clinic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evolutions
    ADD CONSTRAINT evolutions_clinic_id_fkey FOREIGN KEY (clinic_id) REFERENCES public.clinics(id);


--
-- TOC entry 4845 (class 2606 OID 197356)
-- Name: evolutions evolutions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evolutions
    ADD CONSTRAINT evolutions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- TOC entry 4846 (class 2606 OID 197351)
-- Name: evolutions evolutions_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evolutions
    ADD CONSTRAINT evolutions_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- TOC entry 4854 (class 2606 OID 197534)
-- Name: appointments fk_appointments_confirmed_by_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT fk_appointments_confirmed_by_users FOREIGN KEY (confirmed_by) REFERENCES public.users(id);


--
-- TOC entry 4855 (class 2606 OID 197562)
-- Name: patient_guardians fk_patient_guardians_guardian_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_guardians
    ADD CONSTRAINT fk_patient_guardians_guardian_id FOREIGN KEY (guardian_id) REFERENCES public.guardians(id) ON DELETE CASCADE;


--
-- TOC entry 4856 (class 2606 OID 197557)
-- Name: patient_guardians fk_patient_guardians_patient_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_guardians
    ADD CONSTRAINT fk_patient_guardians_patient_id FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- TOC entry 4830 (class 2606 OID 197493)
-- Name: users fk_users_guardian_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_users_guardian_id FOREIGN KEY (guardian_id) REFERENCES public.guardians(id);


--
-- TOC entry 4831 (class 2606 OID 197488)
-- Name: users fk_users_patient_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_users_patient_id FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- TOC entry 4834 (class 2606 OID 197263)
-- Name: guardians guardians_clinic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guardians
    ADD CONSTRAINT guardians_clinic_id_fkey FOREIGN KEY (clinic_id) REFERENCES public.clinics(id);


--
-- TOC entry 4833 (class 2606 OID 197251)
-- Name: patients patients_clinic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_clinic_id_fkey FOREIGN KEY (clinic_id) REFERENCES public.clinics(id);


--
-- TOC entry 4832 (class 2606 OID 197238)
-- Name: users users_clinic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_clinic_id_fkey FOREIGN KEY (clinic_id) REFERENCES public.clinics(id);


--
-- TOC entry 4841 (class 2606 OID 197324)
-- Name: validations validations_clinic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.validations
    ADD CONSTRAINT validations_clinic_id_fkey FOREIGN KEY (clinic_id) REFERENCES public.clinics(id);


--
-- TOC entry 4842 (class 2606 OID 197329)
-- Name: validations validations_evaluation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.validations
    ADD CONSTRAINT validations_evaluation_id_fkey FOREIGN KEY (evaluation_id) REFERENCES public.evaluations(id);


--
-- TOC entry 4843 (class 2606 OID 197334)
-- Name: validations validations_validated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.validations
    ADD CONSTRAINT validations_validated_by_fkey FOREIGN KEY (validated_by) REFERENCES public.users(id);


-- Completed on 2026-03-20 00:04:57

--
-- PostgreSQL database dump complete
--

\unrestrict wahruJ6FIuq4g3Ms4B4bOiRtQTyY3PCHDAb6yI0hlUIfB0t2xSzCUcD1Z30ntMO

--
-- Database "demo_storeDb" dump
--

--
-- PostgreSQL database dump
--

\restrict C9p0AP8GdreVhi9n9Ab52d6IALyfieOK8uw2RawDY0yRm1NN57QiN1D3P6Ys6vg

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

-- Started on 2026-03-20 00:04:57

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5240 (class 1262 OID 147459)
-- Name: demo_storeDb; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE "demo_storeDb" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'br';


\unrestrict C9p0AP8GdreVhi9n9Ab52d6IALyfieOK8uw2RawDY0yRm1NN57QiN1D3P6Ys6vg
\connect "demo_storeDb"
\restrict C9p0AP8GdreVhi9n9Ab52d6IALyfieOK8uw2RawDY0yRm1NN57QiN1D3P6Ys6vg

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 6 (class 2615 OID 147860)
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- TOC entry 5241 (class 0 OID 0)
-- Dependencies: 6
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS '';


--
-- TOC entry 2 (class 3079 OID 147971)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 5242 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- TOC entry 1040 (class 1247 OID 155655)
-- Name: variation_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.variation_type_enum AS ENUM (
    'color',
    'size'
);


--
-- TOC entry 315 (class 1255 OID 148008)
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
-- TOC entry 218 (class 1259 OID 148009)
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.addresses (
    id integer NOT NULL,
    client_user_id uuid NOT NULL,
    cep character varying(9) NOT NULL,
    logradouro character varying(255) NOT NULL,
    numero character varying(20) NOT NULL,
    complemento character varying(100),
    bairro character varying(100) NOT NULL,
    cidade character varying(100) NOT NULL,
    estado character varying(2) NOT NULL,
    pais character varying(50),
    referencia character varying(255),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    profile_id uuid
);


--
-- TOC entry 219 (class 1259 OID 148016)
-- Name: addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.addresses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5243 (class 0 OID 0)
-- Dependencies: 219
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.addresses_id_seq OWNED BY public.addresses.id;


--
-- TOC entry 220 (class 1259 OID 148017)
-- Name: blog_posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blog_posts (
    id integer NOT NULL,
    page_id integer NOT NULL,
    slug character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    excerpt character varying(300),
    content text NOT NULL,
    cover_image character varying(500),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- TOC entry 221 (class 1259 OID 148022)
-- Name: blog_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.blog_posts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5244 (class 0 OID 0)
-- Dependencies: 221
-- Name: blog_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.blog_posts_id_seq OWNED BY public.blog_posts.id;


--
-- TOC entry 222 (class 1259 OID 148023)
-- Name: cart_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_items (
    id integer NOT NULL,
    cart_id integer NOT NULL,
    product_id integer NOT NULL,
    product_name text NOT NULL,
    product_price numeric(10,2) NOT NULL,
    product_image text,
    product_height numeric(10,2),
    product_width numeric(10,2),
    product_weight numeric(10,2),
    product_length numeric(10,2),
    quantity integer,
    created_at timestamp without time zone,
    user_id uuid,
    variation_data json
);


--
-- TOC entry 223 (class 1259 OID 148028)
-- Name: cart_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cart_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5245 (class 0 OID 0)
-- Dependencies: 223
-- Name: cart_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cart_items_id_seq OWNED BY public.cart_items.id;


--
-- TOC entry 224 (class 1259 OID 148029)
-- Name: carts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.carts (
    id integer NOT NULL,
    created_at timestamp without time zone,
    client_id uuid,
    user_id uuid
);


--
-- TOC entry 225 (class 1259 OID 148032)
-- Name: carts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.carts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5246 (class 0 OID 0)
-- Dependencies: 225
-- Name: carts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.carts_id_seq OWNED BY public.carts.id;


--
-- TOC entry 276 (class 1259 OID 148311)
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    name character varying(50),
    is_subcategory boolean,
    parent_id integer,
    user_id uuid,
    id integer NOT NULL
);


--
-- TOC entry 277 (class 1259 OID 148336)
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.categories ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 226 (class 1259 OID 148036)
-- Name: client_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.client_users (
    name character varying(150) NOT NULL,
    birth_date date NOT NULL,
    email character varying(150) NOT NULL,
    password_hash character varying(255) NOT NULL,
    type character varying(50) DEFAULT 'client'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- TOC entry 227 (class 1259 OID 148044)
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id integer NOT NULL,
    comment character varying(128),
    user_id character varying(50),
    user_name character varying(50),
    product_id integer,
    status character varying(50),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    avatar_url character varying(256)
);


--
-- TOC entry 228 (class 1259 OID 148049)
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5247 (class 0 OID 0)
-- Dependencies: 228
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- TOC entry 229 (class 1259 OID 148050)
-- Name: coupons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.coupons (
    id integer NOT NULL,
    user_id integer,
    title character varying(50),
    code character varying(50),
    discount real,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    image_path character varying(128),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    client_username character varying(50),
    client_id character varying(50)
);


--
-- TOC entry 230 (class 1259 OID 148053)
-- Name: coupons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.coupons ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.coupons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 231 (class 1259 OID 148054)
-- Name: coupons_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.coupons_user (
    id integer NOT NULL,
    coupon_id integer,
    title character varying(50),
    code character varying(50),
    discount real,
    start_date character varying(50),
    end_date character varying(50),
    created_at character varying(50),
    client_username character varying(50),
    updated_at character varying(50),
    client_id uuid
);


--
-- TOC entry 232 (class 1259 OID 148057)
-- Name: coupons_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.coupons_user ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.coupons_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 233 (class 1259 OID 148058)
-- Name: delivery_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delivery_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 234 (class 1259 OID 148059)
-- Name: delivery; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delivery (
    id integer DEFAULT nextval('public.delivery_id_seq'::regclass),
    product_ids json,
    recipient_name character varying(50),
    street character varying(50),
    number integer,
    complement character varying(50),
    city character varying(50),
    state character varying(50),
    zip_code character varying(50),
    country character varying(50),
    phone character varying(50),
    bairro character varying(50),
    total_value numeric(10,2),
    delivery_id integer,
    width real,
    height real,
    length real,
    weight real,
    melhorenvio_id character varying(50),
    order_id character varying(50),
    user_id character varying(255),
    user_name character varying(50),
    serviceid character varying(50),
    quote numeric,
    coupon character varying(50),
    discount numeric,
    delivery_min character varying(50),
    delivery_max character varying(50),
    status character varying(50),
    diameter numeric,
    format character varying(50),
    billed_weight numeric,
    receipt character varying(50),
    own_hand character varying(50),
    collect character varying(50),
    collect_schedule_at timestamp without time zone,
    reverse character varying(50),
    non_commercial character varying(50),
    authorization_code character varying(50),
    tracking character varying(50),
    self_tracking character varying(50),
    delivery_receipt character varying(50),
    additional_info character varying(50),
    cte_key character varying(50),
    paid_at timestamp without time zone,
    generated_at timestamp without time zone,
    posted_at timestamp without time zone,
    delivered_at timestamp without time zone,
    canceled_at timestamp without time zone,
    suspend_at timestamp without time zone,
    expired_at timestamp without time zone,
    create_at timestamp without time zone,
    updated_at timestamp without time zone,
    parse_api_at timestamp without time zone,
    received_at timestamp without time zone,
    risk character varying(50),
    product_id json
);


--
-- TOC entry 235 (class 1259 OID 148065)
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 236 (class 1259 OID 148066)
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id integer DEFAULT nextval('public.notifications_id_seq'::regclass),
    user_id character varying(50),
    message character varying(128),
    is_read boolean,
    created_at character varying(50),
    is_global boolean
);


--
-- TOC entry 237 (class 1259 OID 148070)
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 238 (class 1259 OID 148071)
-- Name: order_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_items (
    id integer DEFAULT nextval('public.order_items_id_seq'::regclass),
    order_id integer,
    product_id integer,
    quantity integer,
    unit_price real,
    total_price real
);


--
-- TOC entry 239 (class 1259 OID 148075)
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    payment_id integer,
    delivery_id integer,
    shipment_info character varying(50),
    total_amount real,
    order_date timestamp without time zone,
    status character varying(50),
    user_id uuid
);


--
-- TOC entry 240 (class 1259 OID 148078)
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.orders ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 241 (class 1259 OID 148079)
-- Name: pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pages (
    name character varying(50),
    title character varying(50),
    content character varying(50),
    hero_title character varying(50),
    hero_subtitle character varying(128),
    hero_background_color character varying(50),
    hero_image character varying(128),
    hero_buttons character varying(512),
    carousel_images character varying(50),
    footer_text character varying(50),
    id integer NOT NULL
);


--
-- TOC entry 242 (class 1259 OID 148084)
-- Name: pages_new_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pages_new_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5248 (class 0 OID 0)
-- Dependencies: 242
-- Name: pages_new_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pages_new_id_seq OWNED BY public.pages.id;


--
-- TOC entry 243 (class 1259 OID 148085)
-- Name: password_reset_token; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.password_reset_token (
    id character varying(50),
    user_id character varying(50),
    token character varying(50),
    expire_at character varying(50)
);


--
-- TOC entry 244 (class 1259 OID 148088)
-- Name: payment_products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payment_products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 245 (class 1259 OID 148089)
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id integer NOT NULL,
    payment_id text,
    total_value real,
    payment_date character varying(50),
    payment_type character varying(50),
    cpf character varying(11),
    email character varying(50),
    status character varying(50),
    usuario_id uuid,
    coupon_code character varying(50),
    coupon_amount real,
    name character varying(50)
);


--
-- TOC entry 246 (class 1259 OID 148094)
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.payments ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 247 (class 1259 OID 148095)
-- Name: payments_product_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payments_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 248 (class 1259 OID 148096)
-- Name: payments_product; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments_product (
    id integer DEFAULT nextval('public.payments_product_id_seq'::regclass) NOT NULL,
    payment_id integer,
    product_id integer,
    product_name character varying(64),
    product_quantity integer,
    product_price real
);


--
-- TOC entry 249 (class 1259 OID 148100)
-- Name: post_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_comments (
    id integer NOT NULL,
    post_id integer NOT NULL,
    user_id uuid,
    username character varying(100),
    user_avatar character varying(500),
    login_provider character varying(50),
    text text NOT NULL,
    status character varying(20) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- TOC entry 250 (class 1259 OID 148105)
-- Name: post_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5249 (class 0 OID 0)
-- Dependencies: 250
-- Name: post_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_comments_id_seq OWNED BY public.post_comments.id;


--
-- TOC entry 251 (class 1259 OID 148106)
-- Name: post_seo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_seo (
    id integer NOT NULL,
    post_id integer NOT NULL,
    keywords character varying(255),
    description character varying(255),
    canonical_url character varying(255),
    og_title character varying(255),
    og_description character varying(255),
    og_image character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- TOC entry 252 (class 1259 OID 148111)
-- Name: post_seo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_seo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5250 (class 0 OID 0)
-- Dependencies: 252
-- Name: post_seo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_seo_id_seq OWNED BY public.post_seo.id;


--
-- TOC entry 253 (class 1259 OID 148112)
-- Name: post_views; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_views (
    id integer NOT NULL,
    post_id integer NOT NULL,
    created_at timestamp without time zone
);


--
-- TOC entry 254 (class 1259 OID 148115)
-- Name: post_views_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_views_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5251 (class 0 OID 0)
-- Dependencies: 254
-- Name: post_views_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_views_id_seq OWNED BY public.post_views.id;


--
-- TOC entry 255 (class 1259 OID 148116)
-- Name: product_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_images (
    id integer NOT NULL,
    product_id integer,
    image_path character varying(256),
    is_thumbnail boolean,
    created_at timestamp without time zone
);


--
-- TOC entry 256 (class 1259 OID 148119)
-- Name: product_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.product_images ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.product_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 257 (class 1259 OID 148120)
-- Name: product_seo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_seo (
    id integer NOT NULL,
    product_id integer,
    meta_title character varying(128),
    meta_description character varying(512),
    slug character varying(50),
    keywords character varying(512),
    created_at character varying(50),
    updated_at character varying(50)
);


--
-- TOC entry 258 (class 1259 OID 148125)
-- Name: product_seo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.product_seo ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.product_seo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 259 (class 1259 OID 148126)
-- Name: product_variations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_variations (
    id integer NOT NULL,
    product_id integer NOT NULL,
    product_name character varying(255) NOT NULL,
    variation_type character varying(20) NOT NULL,
    value character varying(255) NOT NULL,
    quantity integer NOT NULL,
    created_at timestamp without time zone
);


--
-- TOC entry 260 (class 1259 OID 148131)
-- Name: product_variations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_variations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5252 (class 0 OID 0)
-- Dependencies: 260
-- Name: product_variations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_variations_id_seq OWNED BY public.product_variations.id;


--
-- TOC entry 261 (class 1259 OID 148132)
-- Name: product_videos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_videos (
    id character varying(50),
    product_id integer,
    video_path character varying(50),
    created_at timestamp without time zone
);


--
-- TOC entry 262 (class 1259 OID 148135)
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name character varying(128),
    description character varying(1024),
    price numeric(10,2),
    category_id integer,
    subcategory_id integer,
    image_paths json,
    quantity integer,
    width real,
    height real,
    weight real,
    length real,
    user_id text,
    thumbnail_path character varying(512)
);


--
-- TOC entry 263 (class 1259 OID 148140)
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.products ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 264 (class 1259 OID 148141)
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profiles (
    user_id uuid,
    username character varying(50),
    full_name character varying(50),
    birth_date character varying(50),
    avatar_url character varying(255),
    phone character varying(20) DEFAULT ''::character varying NOT NULL,
    mobile character varying(20) DEFAULT ''::character varying NOT NULL,
    id integer NOT NULL,
    client_user_id uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- TOC entry 265 (class 1259 OID 148148)
-- Name: profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5253 (class 0 OID 0)
-- Dependencies: 265
-- Name: profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.profiles_id_seq OWNED BY public.profiles.id;


--
-- TOC entry 266 (class 1259 OID 148149)
-- Name: seo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.seo (
    id integer,
    route integer,
    metatitle character varying(128),
    metadescription character varying(256),
    metakeywords character varying(256),
    ogtitle character varying(64),
    ogdescription character varying(256),
    ogimage character varying(128)
);


--
-- TOC entry 278 (class 1259 OID 155652)
-- Name: seo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5254 (class 0 OID 0)
-- Dependencies: 278
-- Name: seo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.seo_id_seq OWNED BY public.seo.id;


--
-- TOC entry 267 (class 1259 OID 148154)
-- Name: stock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stock (
    id integer NOT NULL,
    id_product integer,
    user_id text,
    category_id integer,
    product_name character varying(128),
    product_price real,
    product_quantity real,
    variations jsonb,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- TOC entry 268 (class 1259 OID 148159)
-- Name: stock_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.stock ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stock_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 269 (class 1259 OID 148160)
-- Name: subcategories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subcategories (
    id character varying(50),
    name character varying(50),
    category_id character varying(50)
);


--
-- TOC entry 270 (class 1259 OID 148163)
-- Name: token_blocklist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.token_blocklist (
    id integer NOT NULL,
    jti character varying(36) NOT NULL,
    user_id character varying(36) NOT NULL,
    created_at timestamp without time zone
);


--
-- TOC entry 271 (class 1259 OID 148166)
-- Name: token_blocklist_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.token_blocklist_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5255 (class 0 OID 0)
-- Dependencies: 271
-- Name: token_blocklist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.token_blocklist_id_seq OWNED BY public.token_blocklist.id;


--
-- TOC entry 272 (class 1259 OID 148167)
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    email character varying(50),
    password character varying(64),
    name character varying(50),
    birth_date character varying(50),
    type character varying(50) DEFAULT 'client'::character varying NOT NULL,
    fcm_token text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- TOC entry 273 (class 1259 OID 148176)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 274 (class 1259 OID 148177)
-- Name: variations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.variations (
    id integer NOT NULL,
    product_id integer NOT NULL,
    variation_type character varying(50) NOT NULL,
    value character varying(100) NOT NULL,
    quantity integer
);


--
-- TOC entry 275 (class 1259 OID 148180)
-- Name: variations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.variations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5256 (class 0 OID 0)
-- Dependencies: 275
-- Name: variations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.variations_id_seq OWNED BY public.variations.id;


--
-- TOC entry 4935 (class 2604 OID 148314)
-- Name: addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses ALTER COLUMN id SET DEFAULT nextval('public.addresses_id_seq'::regclass);


--
-- TOC entry 4938 (class 2604 OID 148315)
-- Name: blog_posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_posts ALTER COLUMN id SET DEFAULT nextval('public.blog_posts_id_seq'::regclass);


--
-- TOC entry 4939 (class 2604 OID 148316)
-- Name: cart_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items ALTER COLUMN id SET DEFAULT nextval('public.cart_items_id_seq'::regclass);


--
-- TOC entry 4940 (class 2604 OID 148317)
-- Name: carts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carts ALTER COLUMN id SET DEFAULT nextval('public.carts_id_seq'::regclass);


--
-- TOC entry 4944 (class 2604 OID 148318)
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- TOC entry 4948 (class 2604 OID 148319)
-- Name: pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages ALTER COLUMN id SET DEFAULT nextval('public.pages_new_id_seq'::regclass);


--
-- TOC entry 4950 (class 2604 OID 148320)
-- Name: post_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_comments ALTER COLUMN id SET DEFAULT nextval('public.post_comments_id_seq'::regclass);


--
-- TOC entry 4951 (class 2604 OID 148321)
-- Name: post_seo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_seo ALTER COLUMN id SET DEFAULT nextval('public.post_seo_id_seq'::regclass);


--
-- TOC entry 4952 (class 2604 OID 148322)
-- Name: post_views id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_views ALTER COLUMN id SET DEFAULT nextval('public.post_views_id_seq'::regclass);


--
-- TOC entry 4953 (class 2604 OID 148323)
-- Name: product_variations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variations ALTER COLUMN id SET DEFAULT nextval('public.product_variations_id_seq'::regclass);


--
-- TOC entry 4956 (class 2604 OID 148324)
-- Name: profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles ALTER COLUMN id SET DEFAULT nextval('public.profiles_id_seq'::regclass);


--
-- TOC entry 4959 (class 2604 OID 155653)
-- Name: seo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seo ALTER COLUMN id SET DEFAULT nextval('public.seo_id_seq'::regclass);


--
-- TOC entry 4960 (class 2604 OID 148325)
-- Name: token_blocklist id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_blocklist ALTER COLUMN id SET DEFAULT nextval('public.token_blocklist_id_seq'::regclass);


--
-- TOC entry 4965 (class 2604 OID 148326)
-- Name: variations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.variations ALTER COLUMN id SET DEFAULT nextval('public.variations_id_seq'::regclass);


--
-- TOC entry 5174 (class 0 OID 148009)
-- Dependencies: 218
-- Data for Name: addresses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.addresses (id, client_user_id, cep, logradouro, numero, complemento, bairro, cidade, estado, pais, referencia, created_at, updated_at, profile_id) FROM stdin;
48	e77f01ac-251c-4a28-9a23-e55fba2afc13	73082-180	Quadra QMS 19	11	sadsadsa	Setor de Mansões de Sobradinho	Brasília	DF	sadsadsa	\N	2025-12-24 12:17:48.020494	2025-12-24 12:17:48.020494	\N
\.


--
-- TOC entry 5176 (class 0 OID 148017)
-- Dependencies: 220
-- Data for Name: blog_posts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.blog_posts (id, page_id, slug, title, excerpt, content, cover_image, created_at, updated_at) FROM stdin;
23	1	como-escolher-sua-seda	Como escolher sua seda 	Descubra a melhor forma de escolher a sua seda	<p><strong>sadsadsadsadsasdsadsadsadsaguy</strong></p><p>&lt;ad-banner slot="1234567890" format="auto"&gt;&lt;/ad-banner&gt;</p><p><strong>oifjdsoifjdsofd</strong></p><p>&lt;ad-banner slot="1234567890" format="auto"&gt;&lt;/ad-banner&gt;</p><p><strong>dsadihsaiudhsaiudhsaidsa</strong></p><p>&lt;ad-banner slot="1234567890" format="auto"&gt;&lt;/ad-banner&gt;</p>	https://res.cloudinary.com/dnfnevy9e/image/upload/v1759169702/blogs/como-escolher-sua-seda/cover.png	2025-09-29 18:15:01.408837	\N
\.


--
-- TOC entry 5178 (class 0 OID 148023)
-- Dependencies: 222
-- Data for Name: cart_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cart_items (id, cart_id, product_id, product_name, product_price, product_image, product_height, product_width, product_weight, product_length, quantity, created_at, user_id, variation_data) FROM stdin;
155	6	82	Camiseta Oversize Roxa	69.90	https://res.cloudinary.com/dnfnevy9e/image/upload/v1766587112/product_images/Camiseta_Oversize_Roxa/56710d72-89e2-45a8-8201-4f1d605aeb02_20251224143832270922.png	3.00	25.00	0.30	30.00	1	2026-01-04 00:48:36.816297	e77f01ac-251c-4a28-9a23-e55fba2afc13	[{"variation_id": 84, "quantity": 1, "value": "XG"}, {"variation_id": 89, "quantity": 1, "value": "#8507F3"}]
157	6	83	Caneca Personalizada	34.90	https://res.cloudinary.com/dnfnevy9e/image/upload/v1766590169/product_images/Caneca_Personalizada/5ccb5095-0ea3-414a-ab09-088f9b944bcc_20251224152927255332.png	9.50	12.00	0.40	12.00	1	2026-01-04 01:42:38.660311	e77f01ac-251c-4a28-9a23-e55fba2afc13	[]
\.


--
-- TOC entry 5180 (class 0 OID 148029)
-- Dependencies: 224
-- Data for Name: carts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.carts (id, created_at, client_id, user_id) FROM stdin;
5	2025-12-24 14:41:32.656092	\N	9d509dc8-9f53-4be5-985a-7105090a1a23
6	2025-12-24 14:42:24.676023	\N	e77f01ac-251c-4a28-9a23-e55fba2afc13
\.


--
-- TOC entry 5232 (class 0 OID 148311)
-- Dependencies: 276
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.categories (name, is_subcategory, parent_id, user_id, id) FROM stdin;
Camisetas	f	\N	9d509dc8-9f53-4be5-985a-7105090a1a23	31
Básica	t	31	9d509dc8-9f53-4be5-985a-7105090a1a23	32
Canecas	f	\N	9d509dc8-9f53-4be5-985a-7105090a1a23	33
Personalizadas	t	33	9d509dc8-9f53-4be5-985a-7105090a1a23	34
Bonés	f	\N	9d509dc8-9f53-4be5-985a-7105090a1a23	35
Casual	t	31	9d509dc8-9f53-4be5-985a-7105090a1a23	36
Casual	t	35	9d509dc8-9f53-4be5-985a-7105090a1a23	37
Moletom	f	\N	9d509dc8-9f53-4be5-985a-7105090a1a23	38
Casual	t	38	9d509dc8-9f53-4be5-985a-7105090a1a23	39
\.


--
-- TOC entry 5182 (class 0 OID 148036)
-- Dependencies: 226
-- Data for Name: client_users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.client_users (name, birth_date, email, password_hash, type, created_at, updated_at, id) FROM stdin;
rafael 	2004-02-26	rafael.f.p.faria@hotmail.com	scrypt:32768:8:1$hlxgmAsjPZYL9W6q$78e9945f93bccd4bfd69e10ffd65db2698412b4fe8af76bde924dd395a98e38b862f5e556d3027126006dba58d5d4baaed40478759acb701cb9c833c1ff06367	client	2025-10-24 16:00:57.076011	\N	e77f01ac-251c-4a28-9a23-e55fba2afc13
\.


--
-- TOC entry 5183 (class 0 OID 148044)
-- Dependencies: 227
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.comments (id, comment, user_id, user_name, product_id, status, created_at, updated_at, avatar_url) FROM stdin;
\.


--
-- TOC entry 5185 (class 0 OID 148050)
-- Dependencies: 229
-- Data for Name: coupons; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.coupons (id, user_id, title, code, discount, start_date, end_date, image_path, created_at, updated_at, client_username, client_id) FROM stdin;
\.


--
-- TOC entry 5187 (class 0 OID 148054)
-- Dependencies: 231
-- Data for Name: coupons_user; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.coupons_user (id, coupon_id, title, code, discount, start_date, end_date, created_at, client_username, updated_at, client_id) FROM stdin;
\.


--
-- TOC entry 5190 (class 0 OID 148059)
-- Dependencies: 234
-- Data for Name: delivery; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.delivery (id, product_ids, recipient_name, street, number, complement, city, state, zip_code, country, phone, bairro, total_value, delivery_id, width, height, length, weight, melhorenvio_id, order_id, user_id, user_name, serviceid, quote, coupon, discount, delivery_min, delivery_max, status, diameter, format, billed_weight, receipt, own_hand, collect, collect_schedule_at, reverse, non_commercial, authorization_code, tracking, self_tracking, delivery_receipt, additional_info, cte_key, paid_at, generated_at, posted_at, delivered_at, canceled_at, suspend_at, expired_at, create_at, updated_at, parse_api_at, received_at, risk, product_id) FROM stdin;
124	["82"]	rafael 	Quadra QMS 19	11	sadsadsa	Brasília	DF	73082-180	sadsadsa	\N	Setor de Mansões de Sobradinho	162.33	\N	25	3	30	0.3	\N	\N	e77f01ac-251c-4a28-9a23-e55fba2afc13	apro	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
125	["82"]	rafael 	Quadra QMS 19	11	sadsadsa	Brasília	DF	73082-180	sadsadsa	\N	Setor de Mansões de Sobradinho	372.49	\N	125	15	150	1.5	\N	\N	e77f01ac-251c-4a28-9a23-e55fba2afc13	apro	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
126	[82]		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0	0	0	\N	\N	155f2da0-178f-477d-a474-4c94f9ce2bf5		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
127	[82]		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0	0	0	\N	\N	155f2da0-178f-477d-a474-4c94f9ce2bf5		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
128	[82]	Rafael 	Quadra QMS 19	11	Casa 17	Brasília	DF	73082-180	\N	\N	Setor de Mansões de Sobradinho	12.03	2	0	0	0	0	\N	\N	155f2da0-178f-477d-a474-4c94f9ce2bf5	rafael teste	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
129	[82]	Rafael 	Quadra QMS 19	11	Casa 17	Brasília	DF	73082-180	\N	\N	Setor de Mansões de Sobradinho	12.03	2	0	0	0	0	\N	\N	155f2da0-178f-477d-a474-4c94f9ce2bf5	rafael teste	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
130	[82]	Rafael 	Quadra QMS 19	11	Casa 17	Brasília	DF	73082-180	\N	\N	Setor de Mansões de Sobradinho	12.03	2	0	0	0	0	\N	\N	155f2da0-178f-477d-a474-4c94f9ce2bf5	rafael teste	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
131	[82]	Rafael 	Quadra QMS 19	11	Casa 17	Brasília	DF	73082-180	\N	\N	Setor de Mansões de Sobradinho	12.03	2	0	0	0	0	\N	\N	155f2da0-178f-477d-a474-4c94f9ce2bf5	rafael teste	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
132	[82]	Rafael 	Quadra QMS 19	11	Casa 17	Brasília	DF	73082-180	\N	\N	Setor de Mansões de Sobradinho	12.03	2	0	0	0	0	\N	\N	155f2da0-178f-477d-a474-4c94f9ce2bf5	rafael teste	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
133	[82]	Rafael 	Quadra QMS 19	11	Casa 17	Brasília	DF	73082-180	\N	\N	Setor de Mansões de Sobradinho	12.56	2	0	0	0	0	\N	\N	155f2da0-178f-477d-a474-4c94f9ce2bf5	rafael teste	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- TOC entry 5192 (class 0 OID 148066)
-- Dependencies: 236
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notifications (id, user_id, message, is_read, created_at, is_global) FROM stdin;
63	9d509dc8-9f53-4be5-985a-7105090a1a23	Novo pedido recebido: #245, Para: Cliente, valor total: R$162.33	f	2025-12-24 15:19:54.102097	t
64	2270f1e3-99e8-42c0-a0d7-930e750c8749	Novo pedido recebido: #245, Para: Cliente, valor total: R$162.33	f	2025-12-24 15:19:54.150893	t
65	97832ada-019c-42e3-b1e7-4b7f3c09a35c	Novo pedido recebido: #245, Para: Cliente, valor total: R$162.33	f	2025-12-24 15:19:54.309554	t
66	9d509dc8-9f53-4be5-985a-7105090a1a23	Novo pedido recebido: #246, Para: Cliente, valor total: R$372.49	f	2025-12-26 02:56:24.952296	t
67	2270f1e3-99e8-42c0-a0d7-930e750c8749	Novo pedido recebido: #246, Para: Cliente, valor total: R$372.49	f	2025-12-26 02:56:25.001529	t
68	97832ada-019c-42e3-b1e7-4b7f3c09a35c	Novo pedido recebido: #246, Para: Cliente, valor total: R$372.49	f	2025-12-26 02:56:25.047943	t
69	9d509dc8-9f53-4be5-985a-7105090a1a23	Novo pedido recebido: #247, Para: Cliente, valor total: R$82.46	f	2026-01-03 17:57:28.180183	t
70	2270f1e3-99e8-42c0-a0d7-930e750c8749	Novo pedido recebido: #247, Para: Cliente, valor total: R$82.46	f	2026-01-03 17:57:28.344648	t
71	97832ada-019c-42e3-b1e7-4b7f3c09a35c	Novo pedido recebido: #247, Para: Cliente, valor total: R$82.46	f	2026-01-03 17:57:28.391924	t
72	9d509dc8-9f53-4be5-985a-7105090a1a23	Novo pedido recebido: #248, Para: Cliente, valor total: R$82.46	f	2026-01-03 17:57:35.111661	t
73	2270f1e3-99e8-42c0-a0d7-930e750c8749	Novo pedido recebido: #248, Para: Cliente, valor total: R$82.46	f	2026-01-03 17:57:35.158283	t
74	97832ada-019c-42e3-b1e7-4b7f3c09a35c	Novo pedido recebido: #248, Para: Cliente, valor total: R$82.46	f	2026-01-03 17:57:35.207256	t
75	9d509dc8-9f53-4be5-985a-7105090a1a23	Novo pedido recebido: #249, Para: Rafael , valor total: R$81.93	f	2026-01-03 18:03:50.142848	t
76	2270f1e3-99e8-42c0-a0d7-930e750c8749	Novo pedido recebido: #249, Para: Rafael , valor total: R$81.93	f	2026-01-03 18:03:50.190868	t
77	97832ada-019c-42e3-b1e7-4b7f3c09a35c	Novo pedido recebido: #249, Para: Rafael , valor total: R$81.93	f	2026-01-03 18:03:50.239325	t
78	9d509dc8-9f53-4be5-985a-7105090a1a23	Novo pedido recebido: #250, Para: Rafael , valor total: R$81.93	f	2026-01-04 00:34:21.872479	t
79	2270f1e3-99e8-42c0-a0d7-930e750c8749	Novo pedido recebido: #250, Para: Rafael , valor total: R$81.93	f	2026-01-04 00:34:21.92262	t
80	97832ada-019c-42e3-b1e7-4b7f3c09a35c	Novo pedido recebido: #250, Para: Rafael , valor total: R$81.93	f	2026-01-04 00:34:21.970553	t
81	9d509dc8-9f53-4be5-985a-7105090a1a23	Novo pedido recebido: #251, Para: Rafael , valor total: R$81.93	f	2026-01-04 00:35:37.940174	t
82	2270f1e3-99e8-42c0-a0d7-930e750c8749	Novo pedido recebido: #251, Para: Rafael , valor total: R$81.93	f	2026-01-04 00:35:37.988582	t
83	97832ada-019c-42e3-b1e7-4b7f3c09a35c	Novo pedido recebido: #251, Para: Rafael , valor total: R$81.93	f	2026-01-04 00:35:38.1503	t
84	9d509dc8-9f53-4be5-985a-7105090a1a23	Novo pedido recebido: #252, Para: Rafael , valor total: R$81.93	f	2026-01-04 01:40:52.791086	t
85	2270f1e3-99e8-42c0-a0d7-930e750c8749	Novo pedido recebido: #252, Para: Rafael , valor total: R$81.93	f	2026-01-04 01:40:52.845838	t
86	97832ada-019c-42e3-b1e7-4b7f3c09a35c	Novo pedido recebido: #252, Para: Rafael , valor total: R$81.93	f	2026-01-04 01:40:53.001393	t
87	9d509dc8-9f53-4be5-985a-7105090a1a23	Novo pedido recebido: #253, Para: Rafael , valor total: R$81.93	f	2026-01-04 01:44:15.603737	t
88	2270f1e3-99e8-42c0-a0d7-930e750c8749	Novo pedido recebido: #253, Para: Rafael , valor total: R$81.93	f	2026-01-04 01:44:15.653939	t
89	97832ada-019c-42e3-b1e7-4b7f3c09a35c	Novo pedido recebido: #253, Para: Rafael , valor total: R$81.93	f	2026-01-04 01:44:15.703228	t
90	9d509dc8-9f53-4be5-985a-7105090a1a23	Novo pedido recebido: #254, Para: Rafael , valor total: R$82.46	f	2026-01-04 15:15:48.04236	t
91	2270f1e3-99e8-42c0-a0d7-930e750c8749	Novo pedido recebido: #254, Para: Rafael , valor total: R$82.46	f	2026-01-04 15:15:48.091881	t
92	97832ada-019c-42e3-b1e7-4b7f3c09a35c	Novo pedido recebido: #254, Para: Rafael , valor total: R$82.46	f	2026-01-04 15:15:48.139628	t
\.


--
-- TOC entry 5194 (class 0 OID 148071)
-- Dependencies: 238
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_items (id, order_id, product_id, quantity, unit_price, total_price) FROM stdin;
195	245	82	1	69.9	162.33
196	246	82	5	69.9	372.49
197	247	82	1	69.9	\N
198	248	82	1	69.9	\N
199	249	82	1	69.9	\N
200	250	82	1	69.9	81.93
201	251	82	1	69.9	81.93
202	252	82	1	69.9	81.93
203	253	82	1	69.9	81.93
204	254	82	1	69.9	82.46
\.


--
-- TOC entry 5195 (class 0 OID 148075)
-- Dependencies: 239
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.orders (id, payment_id, delivery_id, shipment_info, total_amount, order_date, status, user_id) FROM stdin;
245	176	124	73082-180	162.33	2025-12-24 15:19:54.097469	approved	e77f01ac-251c-4a28-9a23-e55fba2afc13
246	177	125	73082-180	372.49	2025-12-26 02:56:24.946489	approved	e77f01ac-251c-4a28-9a23-e55fba2afc13
247	178	126		82.46	2026-01-03 17:57:28.166918	pending	155f2da0-178f-477d-a474-4c94f9ce2bf5
248	179	127		82.46	2026-01-03 17:57:35.108758	pending	155f2da0-178f-477d-a474-4c94f9ce2bf5
249	180	128	73082-180	81.93	2026-01-03 18:03:50.139871	pending	155f2da0-178f-477d-a474-4c94f9ce2bf5
250	181	129	73082-180	81.93	2026-01-04 00:34:21.865719	approved	155f2da0-178f-477d-a474-4c94f9ce2bf5
251	182	130	73082-180	81.93	2026-01-04 00:35:37.937082	approved	155f2da0-178f-477d-a474-4c94f9ce2bf5
252	183	131	73082-180	81.93	2026-01-04 01:40:52.784803	approved	155f2da0-178f-477d-a474-4c94f9ce2bf5
253	184	132	73082-180	81.93	2026-01-04 01:44:15.598187	approved	155f2da0-178f-477d-a474-4c94f9ce2bf5
254	185	133	73082-180	82.46	2026-01-04 15:15:48.035566	approved	155f2da0-178f-477d-a474-4c94f9ce2bf5
\.


--
-- TOC entry 5197 (class 0 OID 148079)
-- Dependencies: 241
-- Data for Name: pages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pages (name, title, content, hero_title, hero_subtitle, hero_background_color, hero_image, hero_buttons, carousel_images, footer_text, id) FROM stdin;
Blog	Blog	<p>Blog description</p>	Blog	Blog	#3F51B5	http://localhost:5000/uploadImages/uploads/logo.png	[]	[]		1
Home Page	Home Page	<p><strong>Welcome To</strong></p>	Venda online com app próprio e loja integrada	Uma solução completa para transformar seu negócio em digital.	#000000	http://localhost:5000/uploadImages/uploads/logo.png	[]	[]		7
\.


--
-- TOC entry 5199 (class 0 OID 148085)
-- Dependencies: 243
-- Data for Name: password_reset_token; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.password_reset_token (id, user_id, token, expire_at) FROM stdin;
\.


--
-- TOC entry 5201 (class 0 OID 148089)
-- Dependencies: 245
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payments (id, payment_id, total_value, payment_date, payment_type, cpf, email, status, usuario_id, coupon_code, coupon_amount, name) FROM stdin;
176	1343394843	162.33	2025-12-24T11:19:53.934-04:00	crédito	12345678909	rafael.f.p.faria@hotmail.com	approved	e77f01ac-251c-4a28-9a23-e55fba2afc13	\N	0	apro
177	1325732532	372.49	2025-12-25T22:56:24.452-04:00	crédito	12345678909	rafael.f.p.fariadk@gmail.com	approved	e77f01ac-251c-4a28-9a23-e55fba2afc13	\N	0	apro
178	1325793464	82.46	2026-01-03 14:57:27.960189	pix		rafael.f.p.fariadk@gmail.com	pending	155f2da0-178f-477d-a474-4c94f9ce2bf5		0	
179	1325793468	82.46	2026-01-03 14:57:35.006672	pix		rafael.f.p.fariadk@gmail.com	pending	155f2da0-178f-477d-a474-4c94f9ce2bf5		0	
180	1325793496	81.93	2026-01-03 15:03:50.036214	pix	12345678909	rafael.f.p.fariadk@gmail.com	pending	155f2da0-178f-477d-a474-4c94f9ce2bf5		0	rafael teste
181	1343550649	81.93	2026-01-03T20:34:21.489-04:00	crédito	12345678909	rafael.f.p.fariadk@gmail.com	approved	155f2da0-178f-477d-a474-4c94f9ce2bf5		0	rafael teste
182	1343550661	81.93	2026-01-03T20:35:37.455-04:00	crédito	12345678909	rafael.f.p.fariadk@gmail.com	approved	155f2da0-178f-477d-a474-4c94f9ce2bf5		0	rafael teste
183	1343550927	81.93	2026-01-03T21:40:52.431-04:00	crédito	12345678909	rafael.f.p.fariadk@gmail.com	approved	155f2da0-178f-477d-a474-4c94f9ce2bf5		0	rafael teste
184	1343549111	81.93	2026-01-03T21:44:15.281-04:00	crédito	12345678909	rafael.f.p.fariadk@gmail.com	approved	155f2da0-178f-477d-a474-4c94f9ce2bf5		0	rafael teste
185	1325797680	82.46	2026-01-04T11:15:47.104-04:00	crédito	12345678909	rafael.f.p.fariadk@gmail.com	approved	155f2da0-178f-477d-a474-4c94f9ce2bf5		0	rafael teste
\.


--
-- TOC entry 5204 (class 0 OID 148096)
-- Dependencies: 248
-- Data for Name: payments_product; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payments_product (id, payment_id, product_id, product_name, product_quantity, product_price) FROM stdin;
308	176	82	Camiseta Oversize Roxa	1	69.9
309	177	82	Camiseta Oversize Roxa	5	69.9
310	178	82	Camiseta Oversize Roxa	1	69.9
311	179	82	Camiseta Oversize Roxa	1	69.9
312	180	82	Camiseta Oversize Roxa	1	69.9
313	181	82	Camiseta Oversize Roxa	1	69.9
314	182	82	Camiseta Oversize Roxa	1	69.9
315	183	82	Camiseta Oversize Roxa	1	69.9
316	184	82	Camiseta Oversize Roxa	1	69.9
317	185	82	Camiseta Oversize Roxa	1	69.9
\.


--
-- TOC entry 5205 (class 0 OID 148100)
-- Dependencies: 249
-- Data for Name: post_comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.post_comments (id, post_id, user_id, username, user_avatar, login_provider, text, status, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5207 (class 0 OID 148106)
-- Dependencies: 251
-- Data for Name: post_seo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.post_seo (id, post_id, keywords, description, canonical_url, og_title, og_description, og_image, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5209 (class 0 OID 148112)
-- Dependencies: 253
-- Data for Name: post_views; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.post_views (id, post_id, created_at) FROM stdin;
16	23	2026-01-08 05:13:18.263196
\.


--
-- TOC entry 5211 (class 0 OID 148116)
-- Dependencies: 255
-- Data for Name: product_images; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_images (id, product_id, image_path, is_thumbnail, created_at) FROM stdin;
27	82	https://res.cloudinary.com/dnfnevy9e/image/upload/v1766587114/product_images/Camiseta_Oversize_Roxa/56710d72-89e2-45a8-8201-4f1d605aeb02_20251224143833299945.png	f	2025-12-24 11:38:34.630266
28	84	https://res.cloudinary.com/dnfnevy9e/image/upload/v1766604829/product_images/Bone_Casual/ChatGPT_Image_24_de_dez._de_2025_16_26_27_20251224193348016809.png	f	2025-12-24 16:33:50.003474
29	84	https://res.cloudinary.com/dnfnevy9e/image/upload/v1766604830/product_images/Bone_Casual/ChatGPT_Image_24_de_dez._de_2025_16_28_26_20251224193348996955.png	f	2025-12-24 16:33:50.003474
30	85	https://res.cloudinary.com/dnfnevy9e/image/upload/v1766606663/product_images/Moletom_Demo_Store__Preto_Classico/ChatGPT_Image_24_de_dez._de_2025_16_56_51_20251224200421242675.jpg	f	2025-12-24 17:04:24.895196
31	85	https://res.cloudinary.com/dnfnevy9e/image/upload/v1766606665/product_images/Moletom_Demo_Store__Preto_Classico/ChatGPT_Image_24_de_dez._de_2025_16_56_57_20251224200423173407.jpg	f	2025-12-24 17:04:24.895196
\.


--
-- TOC entry 5213 (class 0 OID 148120)
-- Dependencies: 257
-- Data for Name: product_seo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_seo (id, product_id, meta_title, meta_description, slug, keywords, created_at, updated_at) FROM stdin;
66	82	Camiseta Oversize Roxa | Estilo Urbano – Rua11 Store	Camiseta oversize roxa com estilo urbano, confortável e versátil. Ideal para quem busca atitude, conforto e visual moderno no dia a dia.	camiseta-oversize-roxa-rua11	camiseta oversize roxa, camiseta oversized, camiseta streetwear, camiseta urbana, camiseta casual, moda streetwear, camiseta unissex, rua11 store	2025-12-24 14:38:34.581897	2025-12-24 14:38:34.581901
67	83	Caneca Personalizada em Cerâmica | Presente Criativo	Caneca personalizada em cerâmica com estampa exclusiva, ideal para presentear ou uso diário. Produto resistente, acabamento brilhante e frete simples.	caneca-personalizada-ceramica	caneca personalizada, caneca de cerâmica, caneca personalizada com nome, caneca para presente, caneca criativa, caneca personalizada barata, caneca personalizada ecommerce, caneca decorada, caneca café personalizada	2025-12-24 15:29:30.136789	2025-12-24 15:29:30.136792
68	84	Boné Casual Ajustável | Estilo e Conforto para o Dia a Dia	Boné casual ajustável com design moderno, confortável e resistente. Ideal para uso diário, lazer e estilo urbano. Aproveite.\r\n	bone-casual	boné casual,boné masculino,boné ajustável,boné moderno,acessório de moda,boné urbano,boné para o dia a dia,boné estiloso	2025-12-24 19:33:49.959123	2025-12-24 19:33:49.959126
69	85	Moletom Preto Demo Store Masculino | Conforto e Estilo Urbano	Moletom preto Demo Store masculino com capuz, bolso canguru e estampa exclusiva. Confortável, estiloso e ideal para o dia a dia urbano.	moletom-preto-demo-store-masculino	moletom preto, moletom masculino, moletom com capuz, moletom streetwear, moletom urbano, moletom demo store, roupa masculina, hoodie preto	2025-12-24 20:04:24.741318	2025-12-24 20:04:24.741322
\.


--
-- TOC entry 5215 (class 0 OID 148126)
-- Dependencies: 259
-- Data for Name: product_variations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_variations (id, product_id, product_name, variation_type, value, quantity, created_at) FROM stdin;
84	82	Camiseta Oversize Roxa	Size	XG	10	2025-12-24 14:38:34.583401
85	82	Camiseta Oversize Roxa	Size	GG	10	2025-12-24 14:38:34.583403
86	82	Camiseta Oversize Roxa	Size	G	10	2025-12-24 14:38:34.583405
87	82	Camiseta Oversize Roxa	Size	M	10	2025-12-24 14:38:34.583406
88	82	Camiseta Oversize Roxa	Size	P	10	2025-12-24 14:38:34.583407
89	82	Camiseta Oversize Roxa	Color	#8507F3	10	2025-12-24 14:38:34.583408
90	82	Camiseta Oversize Roxa	Color	#0F0F0F	10	2025-12-24 14:38:34.583409
91	83	Caneca Personalizada	Color	#FCF8F8	1	2025-12-24 15:40:25.038978
92	84	Boné Casual	Color	#0C0C0C	10	2025-12-24 19:33:49.960112
93	85	Moletom Demo Store – Preto Clássico	Size	GG	10	2025-12-24 20:04:24.742482
94	85	Moletom Demo Store – Preto Clássico	Color	#070707	10	2025-12-24 20:04:24.742485
\.


--
-- TOC entry 5217 (class 0 OID 148132)
-- Dependencies: 261
-- Data for Name: product_videos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_videos (id, product_id, video_path, created_at) FROM stdin;
\.


--
-- TOC entry 5218 (class 0 OID 148135)
-- Dependencies: 262
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.products (id, name, description, price, category_id, subcategory_id, image_paths, quantity, width, height, weight, length, user_id, thumbnail_path) FROM stdin;
82	Camiseta Oversize Roxa	Camiseta oversize confeccionada em algodão de alta qualidade, com caimento confortável e moderno. Ideal para o dia a dia, oferece liberdade de movimento e um visual urbano. Possui gola reforçada, mangas amplas e acabamento premium, garantindo durabilidade e estilo.\r\n\r\nProduto pensado para quem busca conforto sem abrir mão do visual.	69.90	31	32	["https://res.cloudinary.com/dnfnevy9e/image/upload/v1766587114/product_images/Camiseta_Oversize_Roxa/56710d72-89e2-45a8-8201-4f1d605aeb02_20251224143833299945.png"]	50	25	3	0.3	30	9d509dc8-9f53-4be5-985a-7105090a1a23	https://res.cloudinary.com/dnfnevy9e/image/upload/v1766587112/product_images/Camiseta_Oversize_Roxa/56710d72-89e2-45a8-8201-4f1d605aeb02_20251224143832270922.png
83	Caneca Personalizada	Caneca personalizada em cerâmica de alta qualidade, ideal para presentear ou uso diário. Possui acabamento brilhante, estampa nítida e durável, resistente a lavagens. Perfeita para café, chá ou outras bebidas quentes e frias. Produto exclusivo, sem variação de modelo.\r\n\r\n📏 Dimensões e Especificações\r\n\r\nAltura: 9,5 cm\r\n\r\nLargura: 8 cm\r\n\r\nLargura (com alça): 12 cm\r\n\r\nPeso: 400 g\r\n\r\nCapacidade aproximada: 325 ml\r\n\r\n📦 Informações adicionais\r\n\r\nVariações: Não possui\r\n\r\nMaterial: Cerâmica\r\n\r\n	34.90	33	34	[""]	100	12	9.5	0.4	12	9d509dc8-9f53-4be5-985a-7105090a1a23	https://res.cloudinary.com/dnfnevy9e/image/upload/v1766590169/product_images/Caneca_Personalizada/5ccb5095-0ea3-414a-ab09-088f9b944bcc_20251224152927255332.png
84	Boné Casual	O Boné Casual é a escolha ideal para quem busca estilo e conforto no dia a dia. Com design moderno e acabamento de qualidade, ele combina facilmente com diferentes looks, sendo perfeito para uso urbano, lazer ou atividades ao ar livre. Possui ajuste traseiro que garante melhor encaixe na cabeça e aba curva que oferece proteção contra o sol. Um acessório versátil, resistente e cheio de personalidade.	59.90	35	37	["https://res.cloudinary.com/dnfnevy9e/image/upload/v1766604829/product_images/Bone_Casual/ChatGPT_Image_24_de_dez._de_2025_16_26_27_20251224193348016809.png", "https://res.cloudinary.com/dnfnevy9e/image/upload/v1766604830/product_images/Bone_Casual/ChatGPT_Image_24_de_dez._de_2025_16_28_26_20251224193348996955.png"]	10	18	13	0.25	28	9d509dc8-9f53-4be5-985a-7105090a1a23	https://res.cloudinary.com/dnfnevy9e/image/upload/v1766604828/product_images/Bone_Casual/ChatGPT_Image_24_de_dez._de_2025_16_25_34_20251224193345560596.png
85	Moletom Demo Store – Preto Clássico	O Moletom Demo Store Preto é a escolha ideal para quem busca estilo urbano, conforto e versatilidade no dia a dia. Produzido em tecido encorpado e macio, oferece excelente caimento e proteção térmica, sendo perfeito para dias frios ou meia-estação.\r\n\r\nCom design moderno e minimalista, o logotipo Demo Store estampado no peito adiciona personalidade e identidade à peça. Possui capuz ajustável com cordão, bolso canguru funcional e acabamento reforçado nos punhos e barra, garantindo durabilidade e conforto prolongado.\r\n\r\nIdeal para compor looks casuais, streetwear ou urbanos, seja para sair com amigos ou para o uso diário.	179.90	38	39	["https://res.cloudinary.com/dnfnevy9e/image/upload/v1766606663/product_images/Moletom_Demo_Store__Preto_Classico/ChatGPT_Image_24_de_dez._de_2025_16_56_51_20251224200421242675.jpg", "https://res.cloudinary.com/dnfnevy9e/image/upload/v1766606665/product_images/Moletom_Demo_Store__Preto_Classico/ChatGPT_Image_24_de_dez._de_2025_16_56_57_20251224200423173407.jpg"]	10	56	70	0.82	70	9d509dc8-9f53-4be5-985a-7105090a1a23	https://res.cloudinary.com/dnfnevy9e/image/upload/v1766606660/product_images/Moletom_Demo_Store__Preto_Classico/ChatGPT_Image_24_de_dez._de_2025_16_58_57_20251224200415465969.jpg
\.


--
-- TOC entry 5220 (class 0 OID 148141)
-- Dependencies: 264
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.profiles (user_id, username, full_name, birth_date, avatar_url, phone, mobile, id, client_user_id, created_at, updated_at) FROM stdin;
\N	Christoffer Pádua 	Christoffer Pádua 	2005-07-21				2	\N	2025-10-22 00:55:10.962938	2025-10-22 21:15:43.645438
e77f01ac-251c-4a28-9a23-e55fba2afc13	client	rafael 	2025-10-24	https://res.cloudinary.com/dnfnevy9e/image/upload/v1761321842/user_avatars/fwc41kn2hlpy9z8oebep.jpg	(12) 34567-8909	(12) 34567-8909	13	\N	2025-10-24 16:03:39.35522	2025-10-24 13:03:58.352528
9d509dc8-9f53-4be5-985a-7105090a1a23	Teste	Teste	2000-01-01		(00) 00000-0000	(00) 00000-0000	17	\N	2025-11-25 00:57:39.960006	2025-12-22 23:24:11.552051
\.


--
-- TOC entry 5222 (class 0 OID 148149)
-- Dependencies: 266
-- Data for Name: seo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.seo (id, route, metatitle, metadescription, metakeywords, ogtitle, ogdescription, ogimage) FROM stdin;
1	7	dasdsadsa	dsadsa	sdsadsa	dsadsa	dsadsa	https://res.cloudinary.com/dnfnevy9e/image/upload/v1767542841/demo-store/seo/logo.png
2	7	teste	teste	teste	teste	teste	https://res.cloudinary.com/dnfnevy9e/image/upload/v1767542841/demo-store/seo/logo.png
\.


--
-- TOC entry 5223 (class 0 OID 148154)
-- Dependencies: 267
-- Data for Name: stock; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.stock (id, id_product, user_id, category_id, product_name, product_price, product_quantity, variations, created_at, updated_at) FROM stdin;
89	83	9d509dc8-9f53-4be5-985a-7105090a1a23	33	Caneca Personalizada	34.9	100	{"sizes": [], "colors": [{"value": "#FCF8F8", "quantity": 1}]}	2025-12-24 15:29:30.081185	2025-12-24 15:40:25.147367
90	84	9d509dc8-9f53-4be5-985a-7105090a1a23	35	Boné Casual	59.9	10	null	2025-12-24 19:33:49.904745	2025-12-24 19:33:49.904749
91	85	9d509dc8-9f53-4be5-985a-7105090a1a23	38	Moletom Demo Store – Preto Clássico	179.9	10	null	2025-12-24 20:04:24.689692	2025-12-24 20:04:24.689695
88	82	9d509dc8-9f53-4be5-985a-7105090a1a23	31	Camiseta Oversize Roxa	69.9	42	null	2025-12-24 14:38:34.523585	2026-01-04 15:15:47.981051
\.


--
-- TOC entry 5225 (class 0 OID 148160)
-- Dependencies: 269
-- Data for Name: subcategories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.subcategories (id, name, category_id) FROM stdin;
\.


--
-- TOC entry 5226 (class 0 OID 148163)
-- Dependencies: 270
-- Data for Name: token_blocklist; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.token_blocklist (id, jti, user_id, created_at) FROM stdin;
73	2bbfc174-7867-489a-8f7e-212960a6aef9	9d509dc8-9f53-4be5-985a-7105090a1a23	2025-12-23 02:37:53.173583
74	822ca522-1f0b-486e-bee2-64ec3b41e8c1	e77f01ac-251c-4a28-9a23-e55fba2afc13	2025-12-24 21:39:12.660195
75	58c3dd39-5d9f-42ae-8d9f-482e497ef49d	9d509dc8-9f53-4be5-985a-7105090a1a23	2026-01-04 15:32:20.568693
76	4a9fff79-2288-45f0-b60f-5e68b30fbbb6	e77f01ac-251c-4a28-9a23-e55fba2afc13	2026-01-05 23:45:10.63523
\.


--
-- TOC entry 5228 (class 0 OID 148167)
-- Dependencies: 272
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (email, password, name, birth_date, type, fcm_token, created_at, updated_at, id) FROM stdin;
rafael.f.p.faria@hotmail.com	$2b$12$djZz.PBWYIXVn2IoVNdiGOmP0j0tBJ25.R6L9hoVXCguwB3goWlI.	Rafael Pádua	1991-06-05	admin	\N	2025-11-22 23:50:35.74066	2025-11-22 23:50:35.74066	9d509dc8-9f53-4be5-985a-7105090a1a23
paduachristoffer@gmail.com	$2b$12$WzkuF4w1h3isv7KZ/XVjX.LD4N5DCnfHr9NCZKVePviSv1WFH2tX2	Christoffer Pádua 	2005-07-21	admin	\N	2025-11-22 23:50:35.74066	2025-11-22 23:50:35.74066	2270f1e3-99e8-42c0-a0d7-930e750c8749
teste@email.com	$2b$12$sPuz7cwRfiNo6AAo1tsLvuzTIDryS44UZQbagkk.NwUY7g6uwzpQu	Teste	2000-01-01	admin	\N	2025-11-25 00:57:39.956587	2025-11-25 00:57:39.95659	97832ada-019c-42e3-b1e7-4b7f3c09a35c
\.


--
-- TOC entry 5230 (class 0 OID 148177)
-- Dependencies: 274
-- Data for Name: variations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.variations (id, product_id, variation_type, value, quantity) FROM stdin;
\.


--
-- TOC entry 5257 (class 0 OID 0)
-- Dependencies: 219
-- Name: addresses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.addresses_id_seq', 48, true);


--
-- TOC entry 5258 (class 0 OID 0)
-- Dependencies: 221
-- Name: blog_posts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.blog_posts_id_seq', 23, true);


--
-- TOC entry 5259 (class 0 OID 0)
-- Dependencies: 223
-- Name: cart_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cart_items_id_seq', 157, true);


--
-- TOC entry 5260 (class 0 OID 0)
-- Dependencies: 225
-- Name: carts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.carts_id_seq', 6, true);


--
-- TOC entry 5261 (class 0 OID 0)
-- Dependencies: 277
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.categories_id_seq', 39, true);


--
-- TOC entry 5262 (class 0 OID 0)
-- Dependencies: 228
-- Name: comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.comments_id_seq', 31, true);


--
-- TOC entry 5263 (class 0 OID 0)
-- Dependencies: 230
-- Name: coupons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.coupons_id_seq', 28, true);


--
-- TOC entry 5264 (class 0 OID 0)
-- Dependencies: 232
-- Name: coupons_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.coupons_user_id_seq', 13, true);


--
-- TOC entry 5265 (class 0 OID 0)
-- Dependencies: 233
-- Name: delivery_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.delivery_id_seq', 133, true);


--
-- TOC entry 5266 (class 0 OID 0)
-- Dependencies: 235
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.notifications_id_seq', 92, true);


--
-- TOC entry 5267 (class 0 OID 0)
-- Dependencies: 237
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_items_id_seq', 204, true);


--
-- TOC entry 5268 (class 0 OID 0)
-- Dependencies: 240
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.orders_id_seq', 254, true);


--
-- TOC entry 5269 (class 0 OID 0)
-- Dependencies: 242
-- Name: pages_new_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.pages_new_id_seq', 7, true);


--
-- TOC entry 5270 (class 0 OID 0)
-- Dependencies: 244
-- Name: payment_products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.payment_products_id_seq', 3, true);


--
-- TOC entry 5271 (class 0 OID 0)
-- Dependencies: 246
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.payments_id_seq', 185, true);


--
-- TOC entry 5272 (class 0 OID 0)
-- Dependencies: 247
-- Name: payments_product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.payments_product_id_seq', 317, true);


--
-- TOC entry 5273 (class 0 OID 0)
-- Dependencies: 250
-- Name: post_comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.post_comments_id_seq', 7, true);


--
-- TOC entry 5274 (class 0 OID 0)
-- Dependencies: 252
-- Name: post_seo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.post_seo_id_seq', 4, true);


--
-- TOC entry 5275 (class 0 OID 0)
-- Dependencies: 254
-- Name: post_views_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.post_views_id_seq', 16, true);


--
-- TOC entry 5276 (class 0 OID 0)
-- Dependencies: 256
-- Name: product_images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_images_id_seq', 33, true);


--
-- TOC entry 5277 (class 0 OID 0)
-- Dependencies: 258
-- Name: product_seo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_seo_id_seq', 70, true);


--
-- TOC entry 5278 (class 0 OID 0)
-- Dependencies: 260
-- Name: product_variations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_variations_id_seq', 96, true);


--
-- TOC entry 5279 (class 0 OID 0)
-- Dependencies: 263
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.products_id_seq', 86, true);


--
-- TOC entry 5280 (class 0 OID 0)
-- Dependencies: 265
-- Name: profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.profiles_id_seq', 17, true);


--
-- TOC entry 5281 (class 0 OID 0)
-- Dependencies: 278
-- Name: seo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seo_id_seq', 2, true);


--
-- TOC entry 5282 (class 0 OID 0)
-- Dependencies: 268
-- Name: stock_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.stock_id_seq', 92, true);


--
-- TOC entry 5283 (class 0 OID 0)
-- Dependencies: 271
-- Name: token_blocklist_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.token_blocklist_id_seq', 76, true);


--
-- TOC entry 5284 (class 0 OID 0)
-- Dependencies: 273
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 3, true);


--
-- TOC entry 5285 (class 0 OID 0)
-- Dependencies: 275
-- Name: variations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.variations_id_seq', 1, false);


--
-- TOC entry 4967 (class 2606 OID 148195)
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- TOC entry 4969 (class 2606 OID 148197)
-- Name: blog_posts blog_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_posts
    ADD CONSTRAINT blog_posts_pkey PRIMARY KEY (id);


--
-- TOC entry 4971 (class 2606 OID 148199)
-- Name: blog_posts blog_posts_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_posts
    ADD CONSTRAINT blog_posts_slug_key UNIQUE (slug);


--
-- TOC entry 4973 (class 2606 OID 148201)
-- Name: cart_items cart_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_pkey PRIMARY KEY (id);


--
-- TOC entry 4975 (class 2606 OID 148203)
-- Name: carts carts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carts
    ADD CONSTRAINT carts_pkey PRIMARY KEY (id);


--
-- TOC entry 5016 (class 2606 OID 148338)
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- TOC entry 4977 (class 2606 OID 148205)
-- Name: client_users client_users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_users
    ADD CONSTRAINT client_users_email_key UNIQUE (email);


--
-- TOC entry 4979 (class 2606 OID 148207)
-- Name: client_users client_users_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_users
    ADD CONSTRAINT client_users_pk PRIMARY KEY (id);


--
-- TOC entry 4981 (class 2606 OID 148209)
-- Name: pages pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- TOC entry 4983 (class 2606 OID 148211)
-- Name: payments_product payments_product_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments_product
    ADD CONSTRAINT payments_product_pkey PRIMARY KEY (id);


--
-- TOC entry 4985 (class 2606 OID 148213)
-- Name: post_comments post_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_comments
    ADD CONSTRAINT post_comments_pkey PRIMARY KEY (id);


--
-- TOC entry 4987 (class 2606 OID 148215)
-- Name: post_seo post_seo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_seo
    ADD CONSTRAINT post_seo_pkey PRIMARY KEY (id);


--
-- TOC entry 4989 (class 2606 OID 148217)
-- Name: post_seo post_seo_post_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_seo
    ADD CONSTRAINT post_seo_post_id_key UNIQUE (post_id);


--
-- TOC entry 4991 (class 2606 OID 148219)
-- Name: post_views post_views_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_views
    ADD CONSTRAINT post_views_pkey PRIMARY KEY (id);


--
-- TOC entry 4993 (class 2606 OID 148221)
-- Name: product_seo product_seo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_seo
    ADD CONSTRAINT product_seo_pkey PRIMARY KEY (id);


--
-- TOC entry 4996 (class 2606 OID 148223)
-- Name: product_variations product_variations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variations
    ADD CONSTRAINT product_variations_pkey PRIMARY KEY (id);


--
-- TOC entry 4998 (class 2606 OID 148225)
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- TOC entry 5000 (class 2606 OID 148227)
-- Name: profiles profiles_client_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_client_user_id_key UNIQUE (client_user_id);


--
-- TOC entry 5002 (class 2606 OID 148229)
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- TOC entry 5006 (class 2606 OID 148231)
-- Name: stock stock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock
    ADD CONSTRAINT stock_pkey PRIMARY KEY (id);


--
-- TOC entry 5010 (class 2606 OID 148233)
-- Name: token_blocklist token_blocklist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_blocklist
    ADD CONSTRAINT token_blocklist_pkey PRIMARY KEY (id);


--
-- TOC entry 5004 (class 2606 OID 148235)
-- Name: profiles unique_user_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT unique_user_id UNIQUE (user_id);


--
-- TOC entry 5012 (class 2606 OID 148237)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 5014 (class 2606 OID 148239)
-- Name: variations variations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.variations
    ADD CONSTRAINT variations_pkey PRIMARY KEY (id);


--
-- TOC entry 4994 (class 1259 OID 148240)
-- Name: ix_product_variations_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_product_variations_product_id ON public.product_variations USING btree (product_id);


--
-- TOC entry 5007 (class 1259 OID 148241)
-- Name: ix_token_blocklist_jti; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_token_blocklist_jti ON public.token_blocklist USING btree (jti);


--
-- TOC entry 5008 (class 1259 OID 148242)
-- Name: ix_token_blocklist_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_token_blocklist_user_id ON public.token_blocklist USING btree (user_id);


--
-- TOC entry 5028 (class 2620 OID 148243)
-- Name: profiles trigger_update_profiles_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 5017 (class 2606 OID 148244)
-- Name: addresses addresses_client_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_client_user_id_fkey FOREIGN KEY (client_user_id) REFERENCES public.client_users(id);


--
-- TOC entry 5018 (class 2606 OID 148249)
-- Name: addresses addresses_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(user_id) ON DELETE CASCADE;


--
-- TOC entry 5019 (class 2606 OID 148254)
-- Name: blog_posts blog_posts_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_posts
    ADD CONSTRAINT blog_posts_page_id_fkey FOREIGN KEY (page_id) REFERENCES public.pages(id);


--
-- TOC entry 5020 (class 2606 OID 148259)
-- Name: cart_items cart_items_cart_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_cart_id_fkey FOREIGN KEY (cart_id) REFERENCES public.carts(id);


--
-- TOC entry 5021 (class 2606 OID 148264)
-- Name: cart_items cart_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- TOC entry 5027 (class 2606 OID 148328)
-- Name: categories categories_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5022 (class 2606 OID 148269)
-- Name: cart_items fk_cart_items_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT fk_cart_items_user FOREIGN KEY (user_id) REFERENCES public.client_users(id);


--
-- TOC entry 5023 (class 2606 OID 148274)
-- Name: post_comments post_comments_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_comments
    ADD CONSTRAINT post_comments_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.blog_posts(id);


--
-- TOC entry 5024 (class 2606 OID 148279)
-- Name: post_seo post_seo_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_seo
    ADD CONSTRAINT post_seo_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.blog_posts(id);


--
-- TOC entry 5025 (class 2606 OID 148284)
-- Name: post_views post_views_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_views
    ADD CONSTRAINT post_views_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.blog_posts(id);


--
-- TOC entry 5026 (class 2606 OID 148289)
-- Name: variations variations_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.variations
    ADD CONSTRAINT variations_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


-- Completed on 2026-03-20 00:04:57

--
-- PostgreSQL database dump complete
--

\unrestrict C9p0AP8GdreVhi9n9Ab52d6IALyfieOK8uw2RawDY0yRm1NN57QiN1D3P6Ys6vg

-- Completed on 2026-03-20 00:04:57

--
-- PostgreSQL database cluster dump complete
--

