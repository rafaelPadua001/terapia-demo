--
-- PostgreSQL database dump
--

\restrict GoSFsAkjevrfeq36aLZZgfxRJhwHafmb4mIA9BhUubv0Gv4K56757osnr6iMNXZ

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

-- Started on 2026-03-20 00:37:16

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


\unrestrict GoSFsAkjevrfeq36aLZZgfxRJhwHafmb4mIA9BhUubv0Gv4K56757osnr6iMNXZ
\connect clinics
\restrict GoSFsAkjevrfeq36aLZZgfxRJhwHafmb4mIA9BhUubv0Gv4K56757osnr6iMNXZ

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

INSERT INTO public.alembic_version VALUES ('0015_patient_guardians_nn');


--
-- TOC entry 5007 (class 0 OID 197273)
-- Dependencies: 222
-- Data for Name: anamneses; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.anamneses VALUES ('91ef74e8-7ee0-49c4-b2fa-3fa27d70f7aa', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', '0997808f-2d1d-4051-b7da-62c77e7cf39b', '{"values": {"0-0": "não possui", "0-1": "não possui"}, "sections": [{"title": "Hist�rico Familiar", "fields": [{"type": "text", "label": "Doen�as na fam�lia"}, {"type": "textarea", "label": "Observa��es"}]}]}', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-18 02:09:03.55219', '2026-03-18 02:26:00.730826', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-18 02:26:00.730849');
INSERT INTO public.anamneses VALUES ('2fae095d-90c6-4576-a86e-86f70572a358', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', '0997808f-2d1d-4051-b7da-62c77e7cf39b', '{"values": {"0-0": "teste", "0-1": "teste"}, "sections": [{"title": "Histórico Familiar", "fields": [{"type": "text", "label": "Doenças na família"}, {"type": "textarea", "label": "Observações"}]}]}', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-18 02:34:04.536607', NULL, NULL, NULL);
INSERT INTO public.anamneses VALUES ('8b6a41bb-8bbc-4986-88e5-de676293c585', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', '0997808f-2d1d-4051-b7da-62c77e7cf39b', '{"values": {"0-0": "Não possui", "0-1": "Não possui"}, "sections": [{"title": "Hist?rico Familiar", "fields": [{"type": "text", "label": "Doen?as na fam?lia"}, {"type": "textarea", "label": "Observações"}]}]}', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-19 00:41:19.091633', '2026-03-19 01:22:17.491755', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-19 01:22:17.491792');
INSERT INTO public.anamneses VALUES ('af4eff07-234c-476c-a116-b08dffd104e0', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', '95f4d7dd-7093-4865-854f-a4928455e647', '{"values": {"0-0": "Não possui", "0-1": "Não possui"}, "sections": [{"title": "Histórico Familiar", "fields": [{"type": "text", "label": "Doenças na família"}, {"type": "textarea", "label": "Observações"}]}]}', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-19 01:22:31.15005', NULL, NULL, NULL);
INSERT INTO public.anamneses VALUES ('b3b0ce7b-396e-433e-a4a7-76accbfff826', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'cf5af676-6617-46a0-895c-d200d82ebb45', '{"values": {"0-0": "Não possui", "0-1": "Não possui"}, "sections": [{"title": "Histórico Familiar", "fields": [{"type": "text", "label": "Doenças na família"}, {"type": "textarea", "label": "Observações"}]}]}', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-19 17:34:26.534984', NULL, NULL, NULL);


--
-- TOC entry 5013 (class 0 OID 197387)
-- Dependencies: 228
-- Data for Name: appointments; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.appointments VALUES ('25043469-34b1-486e-b834-784dd7c22089', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', '0997808f-2d1d-4051-b7da-62c77e7cf39b', 'be9f06d8-7bbe-43c4-b5a8-f4bed1bb00bd', '2026-03-20 06:43:00', 'scheduled', 'cvcxvcxvdsfdsfd', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-19 03:37:33.902896', '2026-03-19 03:41:42.76751', '2026-03-19 03:41:42.767484', '2026-03-20', '06:43:00', 'Terapia ABA', false, false, NULL, NULL);
INSERT INTO public.appointments VALUES ('6b1c1a13-8d18-47a5-b05c-131148233c51', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', '95f4d7dd-7093-4865-854f-a4928455e647', 'be9f06d8-7bbe-43c4-b5a8-f4bed1bb00bd', '2026-03-20 06:49:00', 'scheduled', 'Teste', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-19 03:43:38.883735', '2026-03-19 03:43:52.388086', '2026-03-19 03:43:52.388066', '2026-03-20', '06:49:00', 'Terapia ABA', false, false, NULL, NULL);
INSERT INTO public.appointments VALUES ('dba652ef-2e26-42a2-855d-233c1ab2bc40', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', '1eb130b9-b673-47f4-847d-00cc7c4a4e2c', 'be9f06d8-7bbe-43c4-b5a8-f4bed1bb00bd', '2026-03-01 13:00:00', 'scheduled', '', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', NULL, '2026-03-19 13:57:40.608847', NULL, NULL, '2026-03-01', '13:00:00', 'Reforço escolar', true, false, NULL, NULL);
INSERT INTO public.appointments VALUES ('fb73e2fe-4be3-4d09-b956-02a5d4162fb9', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', '1eb130b9-b673-47f4-847d-00cc7c4a4e2c', 'be9f06d8-7bbe-43c4-b5a8-f4bed1bb00bd', '2026-03-20 13:01:00', 'scheduled', '', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-19 13:58:20.416435', '2026-03-19 14:21:00.551053', NULL, '2026-03-20', '13:01:00', 'Reforço escolar', false, true, '2026-03-19 14:21:00.551053', 'af907885-7976-4ff1-a7d6-f1834f3cf63c');
INSERT INTO public.appointments VALUES ('cdcee7b2-be5e-4f43-84b0-2540dd9f99c6', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', '0997808f-2d1d-4051-b7da-62c77e7cf39b', 'be9f06d8-7bbe-43c4-b5a8-f4bed1bb00bd', '2026-03-20 02:55:00', 'scheduled', 'zzxzx', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-19 03:53:41.225339', '2026-03-19 14:23:51.574072', '2026-03-19 14:23:51.574012', '2026-03-20', '02:55:00', 'Terapia convencional', true, false, NULL, NULL);
INSERT INTO public.appointments VALUES ('0d70657a-cd10-48d2-92f4-5f3f6b155e33', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', '95f4d7dd-7093-4865-854f-a4928455e647', 'be9f06d8-7bbe-43c4-b5a8-f4bed1bb00bd', '2026-03-15 04:00:00', 'scheduled', 'dsadsadsad', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-19 03:57:35.847083', '2026-03-19 14:25:22.247662', NULL, '2026-03-15', '04:00:00', 'Reforço escolar', false, false, NULL, NULL);
INSERT INTO public.appointments VALUES ('4da7c541-9d15-4ecc-bc1b-7d0cb59e4f4a', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'cf5af676-6617-46a0-895c-d200d82ebb45', 'be9f06d8-7bbe-43c4-b5a8-f4bed1bb00bd', '2026-03-01 17:41:00', 'scheduled', '', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-19 17:38:53.298068', '2026-03-19 17:39:58.139632', NULL, '2026-03-01', '17:41:00', 'Terapia convencional', true, true, '2026-03-19 17:39:58.139632', 'af907885-7976-4ff1-a7d6-f1834f3cf63c');


--
-- TOC entry 5011 (class 0 OID 197361)
-- Dependencies: 226
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.audit_logs VALUES ('fd68eddd-0eb7-49b5-942c-1a2330d09940', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'patient', '0997808f-2d1d-4051-b7da-62c77e7cf39b', '{}', '2026-03-18 01:17:27.289429');
INSERT INTO public.audit_logs VALUES ('f4146b9f-37d1-4f7d-9689-9f4d7ad50020', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'patient', '95f4d7dd-7093-4865-854f-a4928455e647', '{}', '2026-03-18 01:17:42.534716');
INSERT INTO public.audit_logs VALUES ('1d2ed1fe-eaf7-47eb-b5c5-6a0f6666fa02', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'update', 'patient', '95f4d7dd-7093-4865-854f-a4928455e647', '{}', '2026-03-18 01:17:58.794126');
INSERT INTO public.audit_logs VALUES ('c5c11735-c576-4659-baf6-7c69bce20802', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'anamnese', '91ef74e8-7ee0-49c4-b2fa-3fa27d70f7aa', '{}', '2026-03-18 02:09:03.570439');
INSERT INTO public.audit_logs VALUES ('3af16d74-73f1-4fce-a4c2-a9c18daff02c', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'evaluation', 'aff46a5f-ed7b-4f10-9785-881f52c6e066', '{}', '2026-03-18 02:09:27.096722');
INSERT INTO public.audit_logs VALUES ('8e0a9bef-36ae-4d46-9c9d-3612c6f95961', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'validate', 'evaluation', 'aff46a5f-ed7b-4f10-9785-881f52c6e066', '{"status": "approved"}', '2026-03-18 02:09:37.46088');
INSERT INTO public.audit_logs VALUES ('79684bd6-9b3c-4453-8082-09680f0b106d', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'validate', 'evaluation', 'aff46a5f-ed7b-4f10-9785-881f52c6e066', '{"status": "rejected"}', '2026-03-18 02:09:39.506713');
INSERT INTO public.audit_logs VALUES ('89cd6e68-1764-4851-849a-65e1332215e3', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'evolution', 'd7b74037-a0d3-4cb7-a5df-e17d63ecf872', '{}', '2026-03-18 02:10:07.430725');
INSERT INTO public.audit_logs VALUES ('f9504b37-d7af-47cf-bcd0-f6c9414631b6', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'delete', 'anamnese', '91ef74e8-7ee0-49c4-b2fa-3fa27d70f7aa', '{}', '2026-03-18 02:26:00.733856');
INSERT INTO public.audit_logs VALUES ('9e1dbb5f-29aa-436f-bcb3-b08c9c3db811', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'delete', 'evaluation', 'aff46a5f-ed7b-4f10-9785-881f52c6e066', '{}', '2026-03-18 02:26:10.149909');
INSERT INTO public.audit_logs VALUES ('a896f176-c5a1-42b1-b2e0-e3e320b64ca1', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'evaluation', '0c35d147-95c9-4dcd-afd3-6243d241eaf6', '{}', '2026-03-18 02:33:40.681296');
INSERT INTO public.audit_logs VALUES ('d8659592-2120-4d1f-bb3f-71422750722c', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'anamnese', '2fae095d-90c6-4576-a86e-86f70572a358', '{}', '2026-03-18 02:34:04.539983');
INSERT INTO public.audit_logs VALUES ('91fb985c-c1a5-42ab-a251-a9a577308e36', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'validate', 'evaluation', '0c35d147-95c9-4dcd-afd3-6243d241eaf6', '{"status": "approved"}', '2026-03-18 03:24:12.784594');
INSERT INTO public.audit_logs VALUES ('05e4c282-1089-4ed6-bc8b-7d8a7158ece9', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'delete', 'evolution', 'd7b74037-a0d3-4cb7-a5df-e17d63ecf872', '{}', '2026-03-18 03:26:13.236574');
INSERT INTO public.audit_logs VALUES ('0e005806-33bf-401a-a50d-8bb5e8cc7610', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'guardian', '18d06ba3-9ddb-441d-ae77-770dfc2d25c4', '{}', '2026-03-18 03:53:05.64292');
INSERT INTO public.audit_logs VALUES ('232684a6-977f-48a3-acf1-f8a29b8782d0', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'update', 'guardian', '18d06ba3-9ddb-441d-ae77-770dfc2d25c4', '{}', '2026-03-19 00:40:38.952344');
INSERT INTO public.audit_logs VALUES ('aa8d1a1c-4d7d-42d4-a218-8b469b6f13db', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'anamnese', '8b6a41bb-8bbc-4986-88e5-de676293c585', '{}', '2026-03-19 00:41:19.097144');
INSERT INTO public.audit_logs VALUES ('3cea55fc-a34e-46e6-aedb-da3108caeb14', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'guardian', '2c4d9533-5503-4cdc-96d6-ae6afe383f69', '{}', '2026-03-19 00:42:23.062933');
INSERT INTO public.audit_logs VALUES ('6c251c57-d512-4c27-8b47-f52f7a657a10', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'evaluation', '1afb52d2-390e-434a-9634-cc7762daa732', '{}', '2026-03-19 00:44:21.71172');
INSERT INTO public.audit_logs VALUES ('1d0f0227-f69e-4d4c-817e-fedfe0861849', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'evolution', '7c47ebb3-d876-4bc4-bfc8-e72b6a778cbb', '{}', '2026-03-19 00:52:10.874556');
INSERT INTO public.audit_logs VALUES ('f122b5eb-834a-49d2-a54b-0be788075a28', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'delete', 'evolution', '7c47ebb3-d876-4bc4-bfc8-e72b6a778cbb', '{}', '2026-03-19 00:53:12.705874');
INSERT INTO public.audit_logs VALUES ('038a84b2-49fa-4165-a4ce-7f112853c305', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'evolution', 'ba452a14-550c-4135-8140-a94dfc4866ec', '{}', '2026-03-19 00:53:59.206012');
INSERT INTO public.audit_logs VALUES ('bf571585-b0d9-4117-a417-46c7133865fc', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'delete', 'anamnese', '8b6a41bb-8bbc-4986-88e5-de676293c585', '{}', '2026-03-19 01:22:17.498918');
INSERT INTO public.audit_logs VALUES ('f28cb40e-6d40-4bfd-8818-c216a075fa4e', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'anamnese', 'af4eff07-234c-476c-a116-b08dffd104e0', '{}', '2026-03-19 01:22:31.154148');
INSERT INTO public.audit_logs VALUES ('9bb7f52a-238a-4a7d-a521-25e8a42c4046', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'appointment', '25043469-34b1-486e-b834-784dd7c22089', '{}', '2026-03-19 03:37:33.912634');
INSERT INTO public.audit_logs VALUES ('ead12275-9c44-42f2-a503-1c4f814fb533', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'delete', 'appointment', '25043469-34b1-486e-b834-784dd7c22089', '{}', '2026-03-19 03:41:42.77115');
INSERT INTO public.audit_logs VALUES ('37d2e359-03da-4965-bc74-aaba97363779', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'appointment', '6b1c1a13-8d18-47a5-b05c-131148233c51', '{}', '2026-03-19 03:43:38.894055');
INSERT INTO public.audit_logs VALUES ('11fc54d7-3627-4f21-9db5-d07efd6ecf35', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'delete', 'appointment', '6b1c1a13-8d18-47a5-b05c-131148233c51', '{}', '2026-03-19 03:43:52.391564');
INSERT INTO public.audit_logs VALUES ('2a983076-64fc-4576-a590-612d9d219aba', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'appointment', 'cdcee7b2-be5e-4f43-84b0-2540dd9f99c6', '{}', '2026-03-19 03:53:41.237154');
INSERT INTO public.audit_logs VALUES ('90a8e859-47b5-43e8-abb2-9e257e70f3fa', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'update', 'appointment', 'cdcee7b2-be5e-4f43-84b0-2540dd9f99c6', '{}', '2026-03-19 03:54:18.461095');
INSERT INTO public.audit_logs VALUES ('759dfc86-bdcc-4e20-9884-49f6426a1cf9', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'update', 'appointment', 'cdcee7b2-be5e-4f43-84b0-2540dd9f99c6', '{}', '2026-03-19 03:54:43.015963');
INSERT INTO public.audit_logs VALUES ('d3aeec58-4f47-478b-a82c-93296961c45f', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'update', 'appointment', 'cdcee7b2-be5e-4f43-84b0-2540dd9f99c6', '{}', '2026-03-19 03:55:06.276582');
INSERT INTO public.audit_logs VALUES ('83c84973-ef2c-47fb-91e7-feaee5eeee4f', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'update', 'appointment', 'cdcee7b2-be5e-4f43-84b0-2540dd9f99c6', '{}', '2026-03-19 03:55:27.106775');
INSERT INTO public.audit_logs VALUES ('66d1fa22-8ec4-47ef-aea3-6df7f5388caa', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'appointment', '0d70657a-cd10-48d2-92f4-5f3f6b155e33', '{}', '2026-03-19 03:57:35.850933');
INSERT INTO public.audit_logs VALUES ('545bfb80-fa63-4350-b33a-38ef8908425a', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'update', 'patient', '95f4d7dd-7093-4865-854f-a4928455e647', '{}', '2026-03-19 04:05:17.215446');
INSERT INTO public.audit_logs VALUES ('91815b11-9af0-4718-b183-708bff1f39a0', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'delete', 'guardian', '2c4d9533-5503-4cdc-96d6-ae6afe383f69', '{}', '2026-03-19 04:06:54.222759');
INSERT INTO public.audit_logs VALUES ('97c6f46b-e8a5-4463-bbb0-2bae4c347a16', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'delete', 'patient', '0997808f-2d1d-4051-b7da-62c77e7cf39b', '{}', '2026-03-19 04:07:29.20911');
INSERT INTO public.audit_logs VALUES ('85c63844-7342-4ba6-a6af-0e970df1d067', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'patient', '1eb130b9-b673-47f4-847d-00cc7c4a4e2c', '{}', '2026-03-19 13:56:56.246342');
INSERT INTO public.audit_logs VALUES ('a9aa83ff-5bb4-4c89-b277-23f1959d4115', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'appointment', 'dba652ef-2e26-42a2-855d-233c1ab2bc40', '{}', '2026-03-19 13:57:40.618395');
INSERT INTO public.audit_logs VALUES ('87423c62-4b89-4e22-a9e9-909fa8fd62ce', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'appointment', 'fb73e2fe-4be3-4d09-b956-02a5d4162fb9', '{}', '2026-03-19 13:58:20.419978');
INSERT INTO public.audit_logs VALUES ('e222f80e-37ac-486a-ad15-174f95baeb7e', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'patient', '13938e0a-bcdd-4779-9f78-62eacb3ac22d', '{}', '2026-03-19 14:16:49.121852');
INSERT INTO public.audit_logs VALUES ('5bc2580d-8ca4-4fbf-a22f-02898185466c', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'confirm', 'appointment', 'fb73e2fe-4be3-4d09-b956-02a5d4162fb9', '{}', '2026-03-19 14:21:00.561188');
INSERT INTO public.audit_logs VALUES ('b5423edc-05fe-4383-81e8-f0dc6eef488f', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'delete', 'appointment', 'cdcee7b2-be5e-4f43-84b0-2540dd9f99c6', '{}', '2026-03-19 14:23:51.581762');
INSERT INTO public.audit_logs VALUES ('091359ad-5923-4330-9bc6-0d9c3023bd55', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'update', 'appointment', '0d70657a-cd10-48d2-92f4-5f3f6b155e33', '{}', '2026-03-19 14:25:22.251744');
INSERT INTO public.audit_logs VALUES ('625e4d29-d4ee-4695-a60c-15dbee624ee9', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'validate', 'evaluation', '0c35d147-95c9-4dcd-afd3-6243d241eaf6', '{"status": "rejected"}', '2026-03-19 14:35:05.580648');
INSERT INTO public.audit_logs VALUES ('6eb2c9a1-3669-4c0d-a721-15180d6fda34', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'validate', 'evaluation', '0c35d147-95c9-4dcd-afd3-6243d241eaf6', '{"status": "approved"}', '2026-03-19 14:35:07.378306');
INSERT INTO public.audit_logs VALUES ('d8314b1a-b341-44cc-8aca-4824e4132770', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'validate', 'evaluation', '0c35d147-95c9-4dcd-afd3-6243d241eaf6', '{"status": "rejected"}', '2026-03-19 14:35:21.792895');
INSERT INTO public.audit_logs VALUES ('641a0879-9cc0-4242-be69-c2453e7316ee', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'validate', 'evaluation', '0c35d147-95c9-4dcd-afd3-6243d241eaf6', '{"status": "approved"}', '2026-03-19 14:35:22.881492');
INSERT INTO public.audit_logs VALUES ('39acf94c-87d9-4ea0-ba93-d388d0766931', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'validate', 'evaluation', '0c35d147-95c9-4dcd-afd3-6243d241eaf6', '{"status": "approved"}', '2026-03-19 14:35:23.510941');
INSERT INTO public.audit_logs VALUES ('1ab9a80b-07d6-43f7-9cc9-4f2322d7e06a', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'validate', 'evaluation', '0c35d147-95c9-4dcd-afd3-6243d241eaf6', '{"status": "rejected"}', '2026-03-19 14:35:24.158131');
INSERT INTO public.audit_logs VALUES ('0b6c694d-bc0c-4f7c-bb70-6a0c8aa6eaa7', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'validate', 'evaluation', '0c35d147-95c9-4dcd-afd3-6243d241eaf6', '{"status": "rejected"}', '2026-03-19 14:35:24.837259');
INSERT INTO public.audit_logs VALUES ('fc464cae-92f8-4faa-8c19-fefd5e7e0feb', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'validate', 'evaluation', '0c35d147-95c9-4dcd-afd3-6243d241eaf6', '{"status": "approved"}', '2026-03-19 14:35:25.43289');
INSERT INTO public.audit_logs VALUES ('7a7cef21-ce46-4b30-81ac-e644dd057614', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'validate', 'evaluation', '0c35d147-95c9-4dcd-afd3-6243d241eaf6', '{"status": "rejected"}', '2026-03-19 14:35:27.218359');
INSERT INTO public.audit_logs VALUES ('70d5566f-1fdf-4436-ad1c-eebe45f9a33c', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'validate', 'evaluation', '0c35d147-95c9-4dcd-afd3-6243d241eaf6', '{"status": "approved"}', '2026-03-19 14:35:28.191887');
INSERT INTO public.audit_logs VALUES ('58b16940-82be-4b40-a72f-ecf47c32384c', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'validate', 'evaluation', '0c35d147-95c9-4dcd-afd3-6243d241eaf6', '{"status": "approved"}', '2026-03-19 14:57:08.063707');
INSERT INTO public.audit_logs VALUES ('ff978282-7361-41d3-a79e-055875ebf7fa', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'validate', 'evaluation', '0c35d147-95c9-4dcd-afd3-6243d241eaf6', '{"status": "approved"}', '2026-03-19 14:57:09.203042');
INSERT INTO public.audit_logs VALUES ('e99561ca-1b76-4404-aa87-16f4b6ff115b', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'validate', 'evaluation', '0c35d147-95c9-4dcd-afd3-6243d241eaf6', '{"status": "approved"}', '2026-03-19 14:57:10.706173');
INSERT INTO public.audit_logs VALUES ('40810ec1-d8f7-4cc7-85f6-f372fbbafa3a', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'validate', 'evaluation', '0c35d147-95c9-4dcd-afd3-6243d241eaf6', '{"status": "approved"}', '2026-03-19 14:57:11.458566');
INSERT INTO public.audit_logs VALUES ('a93099e9-403a-4a9e-bad9-cd4ab6b8f663', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'validate', 'evaluation', '0c35d147-95c9-4dcd-afd3-6243d241eaf6', '{"status": "approved"}', '2026-03-19 14:57:12.779679');
INSERT INTO public.audit_logs VALUES ('061acbde-051c-43ee-9ece-c72ab6d14fd7', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'validate', 'evaluation', '0c35d147-95c9-4dcd-afd3-6243d241eaf6', '{"status": "rejected"}', '2026-03-19 14:58:14.695794');
INSERT INTO public.audit_logs VALUES ('e1fb603d-49a5-4d3a-9e0c-c6652967eaba', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'validate', 'evaluation', '0c35d147-95c9-4dcd-afd3-6243d241eaf6', '{"status": "rejected"}', '2026-03-19 14:58:18.845818');
INSERT INTO public.audit_logs VALUES ('be78c45b-cc76-4ce7-8263-b136316a7a65', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'patient', 'fe0af5f6-5d6e-48aa-b947-6ed745ba0d41', '{}', '2026-03-19 15:24:38.890634');
INSERT INTO public.audit_logs VALUES ('d2372656-5bbf-4d8c-a800-fada3334aebc', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'validate', 'evaluation', '1afb52d2-390e-434a-9634-cc7762daa732', '{"status": "approved"}', '2026-03-19 15:26:20.142165');
INSERT INTO public.audit_logs VALUES ('fa7a42a8-d136-4b85-afb3-8c4bb7d8e78d', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'delete', 'patient', 'fe0af5f6-5d6e-48aa-b947-6ed745ba0d41', '{}', '2026-03-19 15:36:07.950638');
INSERT INTO public.audit_logs VALUES ('1121567c-2cd1-4262-9d9a-0316fdc8108c', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'patient', '0f208c0e-f4c3-46f2-9e9b-cf81824004de', '{}', '2026-03-19 15:36:45.523325');
INSERT INTO public.audit_logs VALUES ('6bd73e4d-24af-4c4e-846b-b7c3fa847dc6', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'patient', '3519b5bc-d883-4a6e-88e6-0eab4dbd4243', '{}', '2026-03-19 15:40:40.944646');
INSERT INTO public.audit_logs VALUES ('d085f1ad-31d8-4b47-9d00-312506854633', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'patient', 'fab45985-4c8f-4132-839e-9abc82354ef6', '{}', '2026-03-19 16:12:58.915247');
INSERT INTO public.audit_logs VALUES ('76383c62-6653-4e1c-889e-6b8f399146c1', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'patient', '550da466-724e-44ae-b609-265a7fad55ae', '{}', '2026-03-19 16:26:54.53152');
INSERT INTO public.audit_logs VALUES ('c562ff0e-77eb-4ec7-a262-2545656dba75', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'patient', 'cf5af676-6617-46a0-895c-d200d82ebb45', '{}', '2026-03-19 16:52:34.457699');
INSERT INTO public.audit_logs VALUES ('d1810ff5-41c4-40c7-9d87-c7753f2c2b5f', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'anamnese', 'b3b0ce7b-396e-433e-a4a7-76accbfff826', '{}', '2026-03-19 17:34:26.544034');
INSERT INTO public.audit_logs VALUES ('9fa38906-5ff4-4757-b9f4-7289ad75a51e', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'evaluation', '6aceb9b0-1cb2-4804-aed6-65a66ceb5c36', '{}', '2026-03-19 17:35:04.980301');
INSERT INTO public.audit_logs VALUES ('36362352-1a44-4cc3-a884-fa032fa32439', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'validate', 'evaluation', '6aceb9b0-1cb2-4804-aed6-65a66ceb5c36', '{"status": "approved"}', '2026-03-19 17:36:47.138227');
INSERT INTO public.audit_logs VALUES ('b5701223-6112-49ba-9b34-6cb008bb754f', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'evolution', 'd1af7297-230e-4873-8b01-b0aa54a11c92', '{}', '2026-03-19 17:37:33.655981');
INSERT INTO public.audit_logs VALUES ('e58b3786-63cd-4a7d-8d9d-f1c42f757857', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'create', 'appointment', '4da7c541-9d15-4ecc-bc1b-7d0cb59e4f4a', '{}', '2026-03-19 17:38:53.305007');
INSERT INTO public.audit_logs VALUES ('6733a197-15e7-4dbf-9b89-9b1fa01ff2ab', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'confirm', 'appointment', '4da7c541-9d15-4ecc-bc1b-7d0cb59e4f4a', '{}', '2026-03-19 17:39:58.143795');


--
-- TOC entry 5003 (class 0 OID 197224)
-- Dependencies: 218
-- Data for Name: clinics; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.clinics VALUES ('800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'Clínica Demo', '2026-03-17 19:03:23.389566');


--
-- TOC entry 5008 (class 0 OID 197295)
-- Dependencies: 223
-- Data for Name: evaluations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.evaluations VALUES ('aff46a5f-ed7b-4f10-9785-881f52c6e066', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', '0997808f-2d1d-4051-b7da-62c77e7cf39b', 'TEste', '{"raw": "Teste"}', 'rejected', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-18 02:09:27.001504', '2026-03-18 02:26:10.145969', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-18 02:26:10.145999');
INSERT INTO public.evaluations VALUES ('0c35d147-95c9-4dcd-afd3-6243d241eaf6', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', '0997808f-2d1d-4051-b7da-62c77e7cf39b', 'teste', '{"value": "teste"}', 'rejected', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-18 02:33:40.675624', NULL, 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-19 14:58:18.842052');
INSERT INTO public.evaluations VALUES ('1afb52d2-390e-434a-9634-cc7762daa732', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', '95f4d7dd-7093-4865-854f-a4928455e647', 'Teste de psicomotor', '{"value": "Foi observada melhorias ao pegar e segurar objetos usando as duas mãos."}', 'approved', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-19 00:44:21.708202', NULL, 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-19 15:26:20.13438');
INSERT INTO public.evaluations VALUES ('6aceb9b0-1cb2-4804-aed6-65a66ceb5c36', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'cf5af676-6617-46a0-895c-d200d82ebb45', 'Teste', '{"value": "teste"}', 'approved', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-19 17:35:04.975161', NULL, 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-19 17:36:47.127699');


--
-- TOC entry 5010 (class 0 OID 197339)
-- Dependencies: 225
-- Data for Name: evolutions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.evolutions VALUES ('d7b74037-a0d3-4cb7-a5df-e17d63ecf872', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', '0997808f-2d1d-4051-b7da-62c77e7cf39b', 'sadsadsadsa', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-18 02:10:07.423602', '2026-03-18 03:26:13.227814', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-18 03:26:13.227844');
INSERT INTO public.evolutions VALUES ('7c47ebb3-d876-4bc4-bfc8-e72b6a778cbb', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', '95f4d7dd-7093-4865-854f-a4928455e647', 'Teste de avaliação', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-19 00:52:10.870875', '2026-03-19 00:53:12.697726', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-19 00:53:12.69775');
INSERT INTO public.evolutions VALUES ('ba452a14-550c-4135-8140-a94dfc4866ec', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', '95f4d7dd-7093-4865-854f-a4928455e647', 'teste evolução', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-19 00:53:59.203864', NULL, NULL, NULL);
INSERT INTO public.evolutions VALUES ('d1af7297-230e-4873-8b01-b0aa54a11c92', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'cf5af676-6617-46a0-895c-d200d82ebb45', 'teste De evolução', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-19 17:37:33.65187', NULL, NULL, NULL);


--
-- TOC entry 5006 (class 0 OID 197256)
-- Dependencies: 221
-- Data for Name: guardians; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.guardians VALUES ('18d06ba3-9ddb-441d-ae77-770dfc2d25c4', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'dsads', '123213', NULL, NULL, 'Mãe');
INSERT INTO public.guardians VALUES ('2c4d9533-5503-4cdc-96d6-ae6afe383f69', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'Maria Joaquina', '12345678909', NULL, '2026-03-19 04:06:54.218295', 'Mãe');
INSERT INTO public.guardians VALUES ('c30591f9-327f-4d65-9e22-6cd7c52144d2', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'Maria', '61991865680', 'maria@email.com', NULL, 'Mãe');
INSERT INTO public.guardians VALUES ('c10b96a5-1b04-475e-90a8-dab6d9528b3b', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'Maria', '61991865680', NULL, NULL, 'Mãe');
INSERT INTO public.guardians VALUES ('26fb63ee-a7a8-45c4-977e-e60da8a41da9', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'Maria de Fatima', NULL, 'teste@email.com', NULL, 'Mãe');


--
-- TOC entry 5014 (class 0 OID 197498)
-- Dependencies: 229
-- Data for Name: patient_guardians; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.patient_guardians VALUES ('18d06ba3-9ddb-441d-ae77-770dfc2d25c4', '0997808f-2d1d-4051-b7da-62c77e7cf39b', '2026-03-19 02:27:47.236347');
INSERT INTO public.patient_guardians VALUES ('c30591f9-327f-4d65-9e22-6cd7c52144d2', '1eb130b9-b673-47f4-847d-00cc7c4a4e2c', '2026-03-19 13:56:56.240724');
INSERT INTO public.patient_guardians VALUES ('c10b96a5-1b04-475e-90a8-dab6d9528b3b', '13938e0a-bcdd-4779-9f78-62eacb3ac22d', '2026-03-19 14:16:49.115318');
INSERT INTO public.patient_guardians VALUES ('26fb63ee-a7a8-45c4-977e-e60da8a41da9', 'fab45985-4c8f-4132-839e-9abc82354ef6', '2026-03-19 16:12:58.906691');
INSERT INTO public.patient_guardians VALUES ('26fb63ee-a7a8-45c4-977e-e60da8a41da9', 'cf5af676-6617-46a0-895c-d200d82ebb45', '2026-03-19 16:52:34.445611');
INSERT INTO public.patient_guardians VALUES ('18d06ba3-9ddb-441d-ae77-770dfc2d25c4', '95f4d7dd-7093-4865-854f-a4928455e647', '2026-03-19 14:21:25.277226');
INSERT INTO public.patient_guardians VALUES ('2c4d9533-5503-4cdc-96d6-ae6afe383f69', '0997808f-2d1d-4051-b7da-62c77e7cf39b', '2026-03-19 14:21:25.277226');


--
-- TOC entry 5005 (class 0 OID 197244)
-- Dependencies: 220
-- Data for Name: patients; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.patients VALUES ('95f4d7dd-7093-4865-854f-a4928455e647', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'Teste da silva 2', '2026-03-18', 'teste', 'criança com teste ', '2026-03-18 01:17:42.531524', NULL, 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-19 04:05:17.208756', 'PAC-000002', NULL, NULL, NULL);
INSERT INTO public.patients VALUES ('0997808f-2d1d-4051-b7da-62c77e7cf39b', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'Teste da silva', '2026-03-18', 'teste', 'criança com teste teste teste teste teste teste', '2026-03-18 01:17:27.275147', '2026-03-19 04:07:29.206398', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', '2026-03-19 04:07:29.206419', 'PAC-000001', NULL, NULL, NULL);
INSERT INTO public.patients VALUES ('1eb130b9-b673-47f4-847d-00cc7c4a4e2c', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'Teste 003', '2026-03-02', '', '', '2026-03-19 13:56:55.765265', NULL, 'af907885-7976-4ff1-a7d6-f1834f3cf63c', NULL, NULL, 'PAC-000004', NULL, '61991865680', 'teste@teste.com');
INSERT INTO public.patients VALUES ('13938e0a-bcdd-4779-9f78-62eacb3ac22d', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'teste 0065', '2026-03-01', '', '', '2026-03-19 14:16:49.10646', NULL, 'af907885-7976-4ff1-a7d6-f1834f3cf63c', NULL, NULL, 'PAC-000005', NULL, '61991865680', NULL);
INSERT INTO public.patients VALUES ('fab45985-4c8f-4132-839e-9abc82354ef6', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'rafael teste', '2026-03-01', '', '', '2026-03-19 16:12:58.453677', NULL, 'af907885-7976-4ff1-a7d6-f1834f3cf63c', NULL, NULL, 'PAC-000009', NULL, '61991865680', 'rafael.f.p.faria@hotmail.com');
INSERT INTO public.patients VALUES ('cf5af676-6617-46a0-895c-d200d82ebb45', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'rafael teste 001', '2026-03-01', '', '', '2026-03-19 16:52:34.192229', NULL, 'af907885-7976-4ff1-a7d6-f1834f3cf63c', NULL, NULL, 'PAC-000011', NULL, '61991865680', 'rafael.f.p.fariadk@gmail.com');


--
-- TOC entry 5004 (class 0 OID 197229)
-- Dependencies: 219
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.users VALUES ('af907885-7976-4ff1-a7d6-f1834f3cf63c', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'Admin', 'admin@clinic.com', '$2b$12$/7ovYDTAupeJc3oYP3wVROk1rKqZ5L/F8hLpTeeULVJwxqLlHuwei', 'admin', '2026-03-17 19:03:23.632623', NULL, NULL, NULL, false);
INSERT INTO public.users VALUES ('be9f06d8-7bbe-43c4-b5a8-f4bed1bb00bd', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'Terapeuta Demo', 'terapeuta@demo.com', '$2b$12$fGpJ1OL6syMFKi3IAEn0HeMYnXz9u9MO8jwEF8RUU72h3XZ5iFGji', 'therapist', '2026-03-19 02:27:46.564394', NULL, NULL, NULL, false);
INSERT INTO public.users VALUES ('cdf95792-29b7-4401-9caf-e3686c0b7f6f', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'Recepção Demo', 'recepcao@demo.com', '$2b$12$J.RwlrnSdgDc7A23Sc5yLumZtcJtfTiufV4YcJ4i5xmJpJQczuhye', 'receptionist', '2026-03-19 02:27:46.788859', NULL, NULL, NULL, false);
INSERT INTO public.users VALUES ('3e40ccb6-8dbb-44ce-b23e-11f900eb747c', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'Responsável Demo', 'responsavel@demo.com', '$2b$12$2rVr45cEDXXMZwduUQIYSufZg7ymgE5vmsGGdBb.o/bfiDP/RjfN6', 'guardian', '2026-03-19 02:27:47.229331', NULL, NULL, '18d06ba3-9ddb-441d-ae77-770dfc2d25c4', false);
INSERT INTO public.users VALUES ('6816d629-c66d-4ad7-8cc7-70e188684526', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'Teste 003', 'teste@teste.com', '$2b$12$nJTTwhB8lgqGeKhphJ9MTeVILQEunZeEWNqkMLrveeh591Lm9IrzS', 'patient', '2026-03-19 13:56:56.012032', NULL, '1eb130b9-b673-47f4-847d-00cc7c4a4e2c', NULL, false);
INSERT INTO public.users VALUES ('038b38d8-d5ec-4228-83ec-73c6049b3862', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'Maria', 'maria@email.com', '$2b$12$piEMUXkRVXYoaTntnCFy0.YS2NLDwOYqpSf7U/kKKW8W9fb7oV4yK', 'guardian', '2026-03-19 13:56:56.241587', NULL, NULL, 'c30591f9-327f-4d65-9e22-6cd7c52144d2', false);
INSERT INTO public.users VALUES ('ac65418c-2cc9-46e6-b9f0-376d1bd9bfa6', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'Paciente Demo', 'paciente@demo.com', '$2b$12$Z72ZsLnJ2ZydwKmrNvB4fOe36pYyT4UE4SoYcYQh8xqCJhi9GbJpO', 'patient', '2026-03-19 02:27:47.010412', NULL, NULL, NULL, false);
INSERT INTO public.users VALUES ('9a958139-1ea4-42fd-94d2-0159c0411fbe', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'Maria de Fatima', 'teste@email.com', '$2b$12$Ez7sGa5M4CUXf8E5mAcyGuPOXDCeszYrQgpG/J0c3QW/I3PLngIrC', 'guardian', '2026-03-19 16:12:58.907582', NULL, NULL, '26fb63ee-a7a8-45c4-977e-e60da8a41da9', false);
INSERT INTO public.users VALUES ('080e261f-1940-4e1a-9f17-0f27c04b3eac', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'rafael teste', 'rafael.f.p.faria@hotmail.com', '$2b$12$rI99wMEOf/FdCM56oCit0eXTl4HRbXigdyzUE1iFV6zOTSPiLtoYK', 'patient', '2026-03-19 16:12:58.67923', NULL, 'fab45985-4c8f-4132-839e-9abc82354ef6', NULL, true);
INSERT INTO public.users VALUES ('b6b62e95-dd5c-4b25-bc49-256a6a8d0f43', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', 'rafael teste 001', 'rafael.f.p.fariadk@gmail.com', '$2b$12$La/dZMdECapPPj6FPM9xxO7a6nOkH5Xy2z70lCXnYd.Ecj1JrB206', 'patient', '2026-03-19 16:52:34.437161', NULL, 'cf5af676-6617-46a0-895c-d200d82ebb45', NULL, false);


--
-- TOC entry 5009 (class 0 OID 197317)
-- Dependencies: 224
-- Data for Name: validations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.validations VALUES ('12d84bda-97c2-45b9-a30b-d3168f0821ae', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', '1afb52d2-390e-434a-9634-cc7762daa732', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'approved', NULL, '2026-03-19 15:26:20.137319', NULL);
INSERT INTO public.validations VALUES ('5cad841e-298c-42bd-a58e-975087f25fd6', '800f03ea-6d6b-44b6-8a2c-3cb0b391033c', '6aceb9b0-1cb2-4804-aed6-65a66ceb5c36', 'af907885-7976-4ff1-a7d6-f1834f3cf63c', 'approved', NULL, '2026-03-19 17:36:47.131711', NULL);


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


-- Completed on 2026-03-20 00:37:16

--
-- PostgreSQL database dump complete
--

\unrestrict GoSFsAkjevrfeq36aLZZgfxRJhwHafmb4mIA9BhUubv0Gv4K56757osnr6iMNXZ

