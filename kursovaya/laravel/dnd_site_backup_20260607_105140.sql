--
-- PostgreSQL database dump
--

\restrict dfZKWXAu4B8naL5uV9cE9eeDmJMfiQkcMYUuicyLHydeTmDSivIifOAdhZvxkoK

-- Dumped from database version 16.13
-- Dumped by pg_dump version 16.13

-- Started on 2026-06-07 10:51:40 MSK

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
-- TOC entry 245 (class 1255 OID 114693)
-- Name: level_up_character(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.level_up_character(p_character_id integer, p_gained_xp integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_current_level INT;
    v_current_xp INT;
    v_new_xp INT;
    v_new_level INT;
    v_health_bonus_per_level INT := 5;   -- например, +5 HP за каждый новый уровень
    v_old_health_max INT;
    v_level_up_count INT := 0;
BEGIN
    -- Получаем текущие параметры персонажа
    SELECT level, experience, health_max
    INTO v_current_level, v_current_xp, v_old_health_max
    FROM characters
    WHERE id = p_character_id
    FOR UPDATE;   -- блокируем строку для избежания гонки

    IF NOT FOUND THEN
        RETURN 'Ошибка: персонаж с ID ' || p_character_id || ' не найден.';
    END IF;

    -- Добавляем полученный опыт
    v_new_xp := v_current_xp + p_gained_xp;
    v_new_level := v_current_level;

    -- Цикл повышения уровня (формула: для уровня L нужно XP = 100 * (L-1)^2)
    -- Примерный порог: 0, 100, 400, 900, 1600...
    WHILE v_new_xp >= 100 * (v_new_level * v_new_level) LOOP
        v_new_level := v_new_level + 1;
        v_level_up_count := v_level_up_count + 1;
    END LOOP;

    -- Если уровень повысился
    IF v_new_level > v_current_level THEN
        -- Обновляем уровень, опыт, здоровье
        UPDATE characters
        SET level = v_new_level,
            experience = v_new_xp,
            health_max = v_old_health_max + (v_new_level - v_current_level) * v_health_bonus_per_level
        WHERE id = p_character_id;

        -- Логируем событие (если есть таблица level_up_log)
        INSERT INTO level_up_log (character_id, old_level, new_level, timestamp)
        VALUES (p_character_id, v_current_level, v_new_level, NOW());

        RETURN format('Персонаж повышен с уровня %s до %s! (получено опыта: %s, новый опыт: %s, бонус здоровья: +%s)',
                      v_current_level, v_new_level, p_gained_xp, v_new_xp,
                      (v_new_level - v_current_level) * v_health_bonus_per_level);
    ELSE
        -- Опыта недостаточно – просто обновляем опыт
        UPDATE characters SET experience = v_new_xp WHERE id = p_character_id;
        RETURN format('Опыта недостаточно для повышения уровня. Текущий уровень: %s, опыт: %s/%s',
                      v_current_level, v_new_xp, 100 * (v_current_level * v_current_level));
    END IF;
END;
$$;


ALTER FUNCTION public.level_up_character(p_character_id integer, p_gained_xp integer) OWNER TO postgres;

--
-- TOC entry 244 (class 1255 OID 110911)
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 215 (class 1259 OID 110912)
-- Name: abilities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.abilities (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    ability_type character varying(255) NOT NULL,
    health_cost integer DEFAULT 0 NOT NULL,
    damage integer DEFAULT 0 NOT NULL,
    healing integer DEFAULT 0 NOT NULL,
    required_level integer DEFAULT 1 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.abilities OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 110921)
-- Name: abilities_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.abilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.abilities_id_seq OWNER TO postgres;

--
-- TOC entry 4558 (class 0 OID 0)
-- Dependencies: 216
-- Name: abilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.abilities_id_seq OWNED BY public.abilities.id;


--
-- TOC entry 217 (class 1259 OID 110922)
-- Name: character_abilities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.character_abilities (
    id bigint NOT NULL,
    character_id bigint NOT NULL,
    ability_id bigint NOT NULL,
    is_unlocked boolean DEFAULT true NOT NULL,
    level integer DEFAULT 1 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.character_abilities OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 110927)
-- Name: character_abilities_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.character_abilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.character_abilities_id_seq OWNER TO postgres;

--
-- TOC entry 4559 (class 0 OID 0)
-- Dependencies: 218
-- Name: character_abilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.character_abilities_id_seq OWNED BY public.character_abilities.id;


--
-- TOC entry 219 (class 1259 OID 110928)
-- Name: character_ability; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.character_ability (
    id bigint NOT NULL,
    character_id bigint NOT NULL,
    ability_id bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.character_ability OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 110931)
-- Name: character_ability_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.character_ability_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.character_ability_id_seq OWNER TO postgres;

--
-- TOC entry 4560 (class 0 OID 0)
-- Dependencies: 220
-- Name: character_ability_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.character_ability_id_seq OWNED BY public.character_ability.id;


--
-- TOC entry 221 (class 1259 OID 110932)
-- Name: character_inventory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.character_inventory (
    id bigint NOT NULL,
    character_id bigint NOT NULL,
    item_id bigint NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.character_inventory OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 110936)
-- Name: character_inventory_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.character_inventory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.character_inventory_id_seq OWNER TO postgres;

--
-- TOC entry 4561 (class 0 OID 0)
-- Dependencies: 222
-- Name: character_inventory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.character_inventory_id_seq OWNED BY public.character_inventory.id;


--
-- TOC entry 223 (class 1259 OID 110937)
-- Name: character_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.character_item (
    id bigint NOT NULL,
    character_id bigint NOT NULL,
    item_id bigint NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.character_item OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 110941)
-- Name: character_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.character_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.character_item_id_seq OWNER TO postgres;

--
-- TOC entry 4562 (class 0 OID 0)
-- Dependencies: 224
-- Name: character_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.character_item_id_seq OWNED BY public.character_item.id;


--
-- TOC entry 225 (class 1259 OID 110942)
-- Name: characters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.characters (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    race_id bigint,
    class_id bigint,
    level integer DEFAULT 1 NOT NULL,
    experience integer DEFAULT 0 NOT NULL,
    strength integer DEFAULT 10 NOT NULL,
    dexterity integer DEFAULT 10 NOT NULL,
    intelligence integer DEFAULT 10 NOT NULL,
    iconstitution integer DEFAULT 10 NOT NULL,
    wisdom integer DEFAULT 10 NOT NULL,
    charisma integer DEFAULT 10 NOT NULL,
    health_max integer DEFAULT 100 NOT NULL,
    gold integer DEFAULT 0 NOT NULL,
    copper integer DEFAULT 0 NOT NULL,
    silver integer DEFAULT 0 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE public.characters OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 110957)
-- Name: characters_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.characters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.characters_id_seq OWNER TO postgres;

--
-- TOC entry 4563 (class 0 OID 0)
-- Dependencies: 226
-- Name: characters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.characters_id_seq OWNED BY public.characters.id;


--
-- TOC entry 227 (class 1259 OID 110958)
-- Name: classes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.classes (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    primary_attribute character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.classes OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 110963)
-- Name: classes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.classes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.classes_id_seq OWNER TO postgres;

--
-- TOC entry 4564 (class 0 OID 0)
-- Dependencies: 228
-- Name: classes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.classes_id_seq OWNED BY public.classes.id;


--
-- TOC entry 229 (class 1259 OID 110964)
-- Name: failed_jobs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.failed_jobs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.failed_jobs OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 110970)
-- Name: failed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.failed_jobs_id_seq OWNER TO postgres;

--
-- TOC entry 4565 (class 0 OID 0)
-- Dependencies: 230
-- Name: failed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.failed_jobs_id_seq OWNED BY public.failed_jobs.id;


--
-- TOC entry 231 (class 1259 OID 110971)
-- Name: items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.items (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    item_type character varying(255) NOT NULL,
    rarity character varying(255) DEFAULT 'common'::character varying NOT NULL,
    level_required integer DEFAULT 1 NOT NULL,
    strength integer DEFAULT 0 NOT NULL,
    agility integer DEFAULT 0 NOT NULL,
    intelligence integer DEFAULT 0 NOT NULL,
    health_bonus integer DEFAULT 0 NOT NULL,
    damage_bonus integer DEFAULT 0 NOT NULL,
    defense_bonus integer DEFAULT 0 NOT NULL,
    price integer DEFAULT 0 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.items OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 110985)
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.items_id_seq OWNER TO postgres;

--
-- TOC entry 4566 (class 0 OID 0)
-- Dependencies: 232
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.items_id_seq OWNED BY public.items.id;


--
-- TOC entry 243 (class 1259 OID 114695)
-- Name: level_up_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.level_up_log (
    id integer NOT NULL,
    character_id integer,
    old_level integer NOT NULL,
    new_level integer NOT NULL,
    "timestamp" timestamp without time zone DEFAULT now()
);


ALTER TABLE public.level_up_log OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 114694)
-- Name: level_up_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.level_up_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.level_up_log_id_seq OWNER TO postgres;

--
-- TOC entry 4567 (class 0 OID 0)
-- Dependencies: 242
-- Name: level_up_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.level_up_log_id_seq OWNED BY public.level_up_log.id;


--
-- TOC entry 233 (class 1259 OID 110986)
-- Name: migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);


ALTER TABLE public.migrations OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 110989)
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.migrations_id_seq OWNER TO postgres;

--
-- TOC entry 4568 (class 0 OID 0)
-- Dependencies: 234
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- TOC entry 235 (class 1259 OID 110990)
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.password_reset_tokens (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);


ALTER TABLE public.password_reset_tokens OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 110995)
-- Name: personal_access_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personal_access_tokens (
    id bigint NOT NULL,
    tokenable_type character varying(255) NOT NULL,
    tokenable_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    token character varying(64) NOT NULL,
    abilities text,
    last_used_at timestamp(0) without time zone,
    expires_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.personal_access_tokens OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 111000)
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.personal_access_tokens_id_seq OWNER TO postgres;

--
-- TOC entry 4569 (class 0 OID 0)
-- Dependencies: 237
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.personal_access_tokens_id_seq OWNED BY public.personal_access_tokens.id;


--
-- TOC entry 238 (class 1259 OID 111001)
-- Name: races; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.races (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    strength_bonus integer DEFAULT 0 NOT NULL,
    dexterity_bonus integer DEFAULT 0 NOT NULL,
    constitution_bonus integer DEFAULT 0 NOT NULL,
    intelligence_bonus integer DEFAULT 0 NOT NULL,
    wisdom_bonus integer DEFAULT 0 NOT NULL,
    charisma_bonus integer DEFAULT 0 NOT NULL,
    health_bonus integer DEFAULT 0 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.races OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 111013)
-- Name: races_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.races_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.races_id_seq OWNER TO postgres;

--
-- TOC entry 4570 (class 0 OID 0)
-- Dependencies: 239
-- Name: races_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.races_id_seq OWNED BY public.races.id;


--
-- TOC entry 240 (class 1259 OID 111014)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    email_verified_at timestamp(0) without time zone,
    password character varying(255) NOT NULL,
    remember_token character varying(100),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    is_admin boolean DEFAULT false NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 111020)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 4571 (class 0 OID 0)
-- Dependencies: 241
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 4273 (class 2604 OID 111021)
-- Name: abilities id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.abilities ALTER COLUMN id SET DEFAULT nextval('public.abilities_id_seq'::regclass);


--
-- TOC entry 4278 (class 2604 OID 111022)
-- Name: character_abilities id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_abilities ALTER COLUMN id SET DEFAULT nextval('public.character_abilities_id_seq'::regclass);


--
-- TOC entry 4281 (class 2604 OID 111023)
-- Name: character_ability id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_ability ALTER COLUMN id SET DEFAULT nextval('public.character_ability_id_seq'::regclass);


--
-- TOC entry 4282 (class 2604 OID 111024)
-- Name: character_inventory id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_inventory ALTER COLUMN id SET DEFAULT nextval('public.character_inventory_id_seq'::regclass);


--
-- TOC entry 4284 (class 2604 OID 111025)
-- Name: character_item id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_item ALTER COLUMN id SET DEFAULT nextval('public.character_item_id_seq'::regclass);


--
-- TOC entry 4286 (class 2604 OID 111026)
-- Name: characters id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.characters ALTER COLUMN id SET DEFAULT nextval('public.characters_id_seq'::regclass);


--
-- TOC entry 4299 (class 2604 OID 111027)
-- Name: classes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes ALTER COLUMN id SET DEFAULT nextval('public.classes_id_seq'::regclass);


--
-- TOC entry 4300 (class 2604 OID 111028)
-- Name: failed_jobs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.failed_jobs ALTER COLUMN id SET DEFAULT nextval('public.failed_jobs_id_seq'::regclass);


--
-- TOC entry 4302 (class 2604 OID 111029)
-- Name: items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items ALTER COLUMN id SET DEFAULT nextval('public.items_id_seq'::regclass);


--
-- TOC entry 4324 (class 2604 OID 114698)
-- Name: level_up_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.level_up_log ALTER COLUMN id SET DEFAULT nextval('public.level_up_log_id_seq'::regclass);


--
-- TOC entry 4312 (class 2604 OID 111030)
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- TOC entry 4313 (class 2604 OID 111031)
-- Name: personal_access_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.personal_access_tokens_id_seq'::regclass);


--
-- TOC entry 4314 (class 2604 OID 111032)
-- Name: races id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.races ALTER COLUMN id SET DEFAULT nextval('public.races_id_seq'::regclass);


--
-- TOC entry 4322 (class 2604 OID 111033)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 4524 (class 0 OID 110912)
-- Dependencies: 215
-- Data for Name: abilities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.abilities (id, name, description, ability_type, health_cost, damage, healing, required_level, created_at, updated_at) FROM stdin;
1	Сильный удар	Наносит двойной урон	атака	5	10	0	1	2026-04-30 13:23:10	2026-04-30 13:23:10
2	Легкая поступь	Увеличивает ловкость на 2	бафф	0	0	0	1	2026-04-30 13:23:10	2026-04-30 13:23:10
3	Огненный шар	Атакует всех врагов	заклинание	8	15	0	2	2026-04-30 13:23:10	2026-04-30 13:23:10
4	Исцеление	Восстанавливает 10 HP	лечение	0	0	10	1	2026-04-30 13:23:10	2026-04-30 13:23:10
5	Боевой клич	Увеличивает силу группы	бафф	3	0	0	1	2026-04-30 13:23:10	2026-04-30 13:23:10
6	Щит	Уменьшает получаемый урон	защита	4	0	0	1	2026-04-30 13:23:10	2026-04-30 13:23:10
7	Сильный удар	Наносит двойной урон	атака	5	10	0	1	2026-04-30 13:23:18	2026-04-30 13:23:18
8	Легкая поступь	Увеличивает ловкость на 2	бафф	0	0	0	1	2026-04-30 13:23:18	2026-04-30 13:23:18
9	Огненный шар	Атакует всех врагов	заклинание	8	15	0	2	2026-04-30 13:23:18	2026-04-30 13:23:18
10	Исцеление	Восстанавливает 10 HP	лечение	0	0	10	1	2026-04-30 13:23:18	2026-04-30 13:23:18
11	Боевой клич	Увеличивает силу группы	бафф	3	0	0	1	2026-04-30 13:23:18	2026-04-30 13:23:18
12	Щит	Уменьшает получаемый урон	защита	4	0	0	1	2026-04-30 13:23:18	2026-04-30 13:23:18
13	Сильный удар	Наносит двойной урон	attack	5	10	0	1	2026-05-05 15:45:40	2026-05-05 15:45:40
14	Легкая поступь	Увеличивает ловкость на 2	buff	0	0	0	1	2026-05-05 15:45:40	2026-05-05 15:45:40
15	Огненный шар	Атакует всех врагов	magic	8	15	0	2	2026-05-05 15:45:40	2026-05-05 15:45:40
16	Исцеление	Восстанавливает 10 HP	heal	0	0	10	1	2026-05-05 15:45:40	2026-05-05 15:45:40
17	Боевой клич	Увеличивает силу группы	buff	3	0	0	1	2026-05-05 15:45:40	2026-05-05 15:45:40
18	Щит	Уменьшает получаемый урон	defense	4	0	0	1	2026-05-05 15:45:40	2026-05-05 15:45:40
\.


--
-- TOC entry 4526 (class 0 OID 110922)
-- Dependencies: 217
-- Data for Name: character_abilities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.character_abilities (id, character_id, ability_id, is_unlocked, level, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 4528 (class 0 OID 110928)
-- Dependencies: 219
-- Data for Name: character_ability; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.character_ability (id, character_id, ability_id, created_at, updated_at) FROM stdin;
16	73	2	\N	\N
17	73	4	\N	\N
18	73	5	\N	\N
25	76	15	\N	\N
26	76	10	\N	\N
27	76	12	\N	\N
28	77	1	\N	\N
29	77	7	\N	\N
30	77	12	\N	\N
31	78	12	\N	\N
32	78	9	\N	\N
33	78	14	\N	\N
34	79	4	\N	\N
35	79	2	\N	\N
36	79	9	\N	\N
37	80	9	\N	\N
38	80	6	\N	\N
39	80	1	\N	\N
40	81	4	\N	\N
41	81	17	\N	\N
42	81	18	\N	\N
43	82	2	\N	\N
44	82	17	\N	\N
45	82	3	\N	\N
\.


--
-- TOC entry 4530 (class 0 OID 110932)
-- Dependencies: 221
-- Data for Name: character_inventory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.character_inventory (id, character_id, item_id, quantity, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 4532 (class 0 OID 110937)
-- Dependencies: 223
-- Data for Name: character_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.character_item (id, character_id, item_id, quantity, created_at, updated_at) FROM stdin;
17	73	4	1	2026-05-01 08:19:35	2026-05-01 08:19:35
18	73	11	1	2026-05-01 08:19:35	2026-05-01 08:19:35
27	76	14	1	2026-05-05 16:04:50	2026-05-05 16:04:50
28	76	8	1	2026-05-05 16:04:50	2026-05-05 16:04:50
29	76	5	1	2026-05-05 16:04:50	2026-05-05 16:04:50
30	76	6	1	2026-05-05 16:04:50	2026-05-05 16:04:50
31	76	10	1	2026-05-05 16:04:50	2026-05-05 16:04:50
32	77	7	1	2026-05-05 16:24:09	2026-05-05 16:24:09
33	77	14	1	2026-05-05 16:24:09	2026-05-05 16:24:09
34	77	10	1	2026-05-05 16:24:09	2026-05-05 16:24:09
35	77	18	1	2026-05-05 16:24:09	2026-05-05 16:24:09
36	77	15	1	2026-05-05 16:24:09	2026-05-05 16:24:09
37	78	11	1	2026-05-05 16:24:13	2026-05-05 16:24:13
38	78	7	1	2026-05-05 16:24:13	2026-05-05 16:24:13
39	78	17	1	2026-05-05 16:24:13	2026-05-05 16:24:13
40	78	5	1	2026-05-05 16:24:13	2026-05-05 16:24:13
41	79	16	1	2026-05-05 16:24:17	2026-05-05 16:24:17
42	80	17	1	2026-05-05 16:24:26	2026-05-05 16:24:26
43	80	1	1	2026-05-05 16:24:26	2026-05-05 16:24:26
44	80	5	1	2026-05-05 16:24:26	2026-05-05 16:24:26
45	80	12	1	2026-05-05 16:24:26	2026-05-05 16:24:26
46	81	11	1	2026-05-05 16:24:40	2026-05-05 16:24:40
47	81	3	1	2026-05-05 16:24:40	2026-05-05 16:24:40
48	81	7	1	2026-05-05 16:24:40	2026-05-05 16:24:40
49	82	17	1	2026-06-04 09:20:19	2026-06-04 09:20:19
50	82	4	1	2026-06-04 09:20:19	2026-06-04 09:20:19
\.


--
-- TOC entry 4534 (class 0 OID 110942)
-- Dependencies: 225
-- Data for Name: characters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.characters (id, user_id, name, race_id, class_id, level, experience, strength, dexterity, intelligence, iconstitution, wisdom, charisma, health_max, gold, copper, silver, created_at, updated_at, deleted_at) FROM stdin;
76	3	DAS	11	1	1	0	17	8	15	18	16	17	8	13	61	1	2026-05-05 16:04:50	2026-05-05 16:04:50	\N
77	8	DAS	3	2	1	0	15	9	10	12	8	9	6	13	47	76	2026-05-05 16:24:09	2026-05-05 16:24:09	\N
78	8	SAD	4	2	1	0	17	10	8	11	15	12	7	11	25	27	2026-05-05 16:24:13	2026-05-05 16:24:13	\N
79	8	WAS	3	2	1	0	8	17	16	16	16	15	11	5	73	50	2026-05-05 16:24:17	2026-05-05 16:24:17	\N
80	8	МАРИОНЕТКА	9	1	1	0	16	17	11	11	15	8	6	8	36	28	2026-05-05 16:24:26	2026-05-05 16:24:26	\N
81	8	Варианил	10	2	1	0	12	13	8	9	9	15	6	11	80	50	2026-05-05 16:24:40	2026-05-05 16:24:40	\N
82	20	USER11	6	2	3	800	13	16	14	15	9	12	24	10	49	85	2026-06-04 09:20:19	2026-06-04 09:20:19	\N
73	1	CHAMBER	2	1	1	0	16	12	17	9	9	15	14	14	92	54	2026-05-01 08:19:35	2026-05-01 08:19:35	\N
\.


--
-- TOC entry 4536 (class 0 OID 110958)
-- Dependencies: 227
-- Data for Name: classes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.classes (id, name, description, primary_attribute, created_at, updated_at) FROM stdin;
1	Бард	вы абоятельны и любите музыку и творчество, а еще ОЧЕНЬ харизматичны.	\N	2026-04-29 14:32:43	2026-04-29 14:32:43
2	Жрец	вы способны к божественной магии, а также у вас глубокая связь с вашим божество.	\N	2026-04-29 14:33:27	2026-04-29 14:33:27
\.


--
-- TOC entry 4538 (class 0 OID 110964)
-- Dependencies: 229
-- Data for Name: failed_jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.failed_jobs (id, uuid, connection, queue, payload, exception, failed_at) FROM stdin;
\.


--
-- TOC entry 4540 (class 0 OID 110971)
-- Dependencies: 231
-- Data for Name: items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.items (id, name, description, item_type, rarity, level_required, strength, agility, intelligence, health_bonus, damage_bonus, defense_bonus, price, created_at, updated_at) FROM stdin;
1	Меч	Обычный одноручный меч	оружие	простой	1	2	0	0	0	3	0	100	2026-04-30 13:23:10	2026-04-30 13:23:10
2	Кожаный доспех	Лёгкая броня	броня	простой	1	0	1	0	5	0	2	150	2026-04-30 13:23:10	2026-04-30 13:23:10
3	Зелье лечения	Восстанавливает 10 HP	зелье	простой	1	0	0	0	10	0	0	50	2026-04-30 13:23:10	2026-04-30 13:23:10
4	Лук	Дальнобойное оружие	оружие	простой	1	1	2	0	0	4	0	120	2026-04-30 13:23:10	2026-04-30 13:23:10
5	Посох мага	Увеличивает интеллект	оружие	редкий	2	0	0	3	0	2	0	200	2026-04-30 13:23:10	2026-04-30 13:23:10
6	Амулет здоровья	Даёт +15 к здоровью	артефакт	редкий	1	0	0	0	15	0	1	300	2026-04-30 13:23:10	2026-04-30 13:23:10
7	Меч	Обычный одноручный меч	оружие	простой	1	2	0	0	0	3	0	100	2026-04-30 13:23:18	2026-04-30 13:23:18
8	Кожаный доспех	Лёгкая броня	броня	простой	1	0	1	0	5	0	2	150	2026-04-30 13:23:18	2026-04-30 13:23:18
9	Зелье лечения	Восстанавливает 10 HP	зелье	простой	1	0	0	0	10	0	0	50	2026-04-30 13:23:18	2026-04-30 13:23:18
10	Лук	Дальнобойное оружие	оружие	простой	1	1	2	0	0	4	0	120	2026-04-30 13:23:18	2026-04-30 13:23:18
11	Посох мага	Увеличивает интеллект	оружие	редкий	2	0	0	3	0	2	0	200	2026-04-30 13:23:18	2026-04-30 13:23:18
12	Амулет здоровья	Даёт +15 к здоровью	артефакт	редкий	1	0	0	0	15	0	1	300	2026-04-30 13:23:18	2026-04-30 13:23:18
13	Меч	Обычный одноручный меч	weapon	common	1	2	0	0	0	3	0	100	2026-05-05 15:45:40	2026-05-05 15:45:40
14	Кожаный доспех	Лёгкая броня	armor	common	1	0	1	0	5	0	2	150	2026-05-05 15:45:40	2026-05-05 15:45:40
15	Зелье лечения	Восстанавливает 10 HP	potion	common	1	0	0	0	10	0	0	50	2026-05-05 15:45:40	2026-05-05 15:45:40
16	Лук	Дальнобойное оружие	weapon	common	1	1	2	0	0	4	0	120	2026-05-05 15:45:40	2026-05-05 15:45:40
17	Посох мага	Увеличивает интеллект	weapon	rare	2	0	0	3	0	2	0	200	2026-05-05 15:45:40	2026-05-05 15:45:40
18	Амулет здоровья	Даёт +15 к здоровью	accessory	rare	1	0	0	0	15	0	1	300	2026-05-05 15:45:40	2026-05-05 15:45:40
\.


--
-- TOC entry 4552 (class 0 OID 114695)
-- Dependencies: 243
-- Data for Name: level_up_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.level_up_log (id, character_id, old_level, new_level, "timestamp") FROM stdin;
1	82	1	2	2026-06-04 12:20:25.629396
2	82	2	3	2026-06-04 12:20:32.535985
\.


--
-- TOC entry 4542 (class 0 OID 110986)
-- Dependencies: 233
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.migrations (id, migration, batch) FROM stdin;
1	2014_10_12_000000_create_users_table	1
2	2014_10_12_100000_create_password_reset_tokens_table	1
3	2019_08_19_000000_create_failed_jobs_table	1
4	2019_12_14_000001_create_personal_access_tokens_table	1
5	2026_04_25_094921_create_races_table	1
6	2026_04_25_095030_create_classes_table	1
7	2026_04_25_095039_create_abilities_table	1
8	2026_04_25_095048_create_items_table	1
9	2026_04_25_095122_create_characters_table	1
10	2026_04_25_095138_create_character_abilities_table	1
11	2026_04_25_095152_create_character_inventory_table	1
12	2026_04_29_145458_make_character_columns_nullable_or_default	2
13	2026_04_30_130428_create_character_item_table	2
14	2026_04_30_130449_create_character_ability_table	2
15	2026_05_05_154325_add_is_admin_to_users_table	3
\.


--
-- TOC entry 4544 (class 0 OID 110990)
-- Dependencies: 235
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.password_reset_tokens (email, token, created_at) FROM stdin;
\.


--
-- TOC entry 4545 (class 0 OID 110995)
-- Dependencies: 236
-- Data for Name: personal_access_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personal_access_tokens (id, tokenable_type, tokenable_id, name, token, abilities, last_used_at, expires_at, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 4547 (class 0 OID 111001)
-- Dependencies: 238
-- Data for Name: races; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.races (id, name, description, strength_bonus, dexterity_bonus, constitution_bonus, intelligence_bonus, wisdom_bonus, charisma_bonus, health_bonus, created_at, updated_at) FROM stdin;
1	Человек	у вас средний рост и вы не обладаете особенными навыками, но вы хороши в адаптации и у вас сильный дух	0	0	0	0	0	0	0	2026-04-29 14:30:03	2026-04-29 14:30:03
2	Эльф	у вас есть навык "темное зрение", вы высоки и прекрасны, а также весьма мудры и долговечны в своей красоте	0	0	0	0	0	0	0	2026-04-29 14:30:51	2026-04-29 14:30:51
3	дварф	вы коренасты и сильны, имеете устойчивость к ядам и темное зрение, а также славятся ваша выносливость и трудолюбие	0	0	2	0	1	0	0	\N	\N
4	халфлинг	вы маленького роста, удачливы и проворны, вас трудно напугать, а ваша жизнерадостность заражает окружающих	0	2	0	0	0	1	0	\N	\N
5	гном	вы невысоки, но обладаете острым умом и технической смекалкой, а также имеете темное зрение и устойчивость к магии	0	0	1	2	0	0	0	\N	\N
6	драконорожденный	вы покрыты чешуёй, можете извергать стихийную энергию и внушаете страх или уважение своей мощью и харизмой	2	0	0	0	0	1	0	\N	\N
7	тифлинг	вы несёте в себе кровь инферналов, обладаете врождённой устойчивостью к огню и магическими способностями, притягивая взгляды своей необычной внешностью	0	0	0	1	0	2	0	\N	\N
8	полуэльф	вы унаследовали grace эльфов и адаптивность людей, обладаете темным зрением и природным обаянием, легко находя общий язык с разными расами	0	1	0	0	0	2	0	\N	\N
9	полуорк	вы массивны и свирепы, обладаете невероятной живучестью и способностью наносить сокрушительные удары, а ваша суровая внешность часто пугает врагов	2	0	1	0	0	0	0	\N	\N
10	аасимар	вы несёте искру небес, светитесь внутренним светом, устойчивы к некротической энергии и обладаете божественным обаянием и прозорливостью	0	0	0	0	1	2	0	\N	\N
11	табакси	вы похожи на кошку — быстры, грациозны и обладаете острыми когтями, ночной охотой и врождённым чувством опасности	0	2	0	0	1	0	0	\N	\N
12	голиаф	вы гигантского роста, покрыты каменной кожей, привыкли к суровым горам и обладаете феноменальной физической силой и выносливостью	2	0	1	0	0	-1	0	\N	\N
\.


--
-- TOC entry 4549 (class 0 OID 111014)
-- Dependencies: 240
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, email, email_verified_at, password, remember_token, created_at, updated_at, is_admin) FROM stdin;
3	ADMIN	ADMIN@gmail.com	\N	$2y$12$qp2cZ4Jj8/1gt3Y3qwEUu.hzJcYrUP6MoJRkkkov0N8rWpRQgSoA2	\N	2026-05-05 15:56:35	2026-05-05 15:56:35	f
1	NYV	NYV@gmail.com	\N	$2y$12$Gf3HbevVWrR440GwUueTqOqXgVYSfKnSViqiBbWmiNZfgFJ.6IINe	\N	2026-04-29 14:35:34	2026-04-29 14:35:34	t
8	polzovatel1	polzovatel@gmail.com	\N	$2y$12$zERHBzM90FJuLFtO8X3au.lEG1TMZnPx0sKLM2YyX3gqPLp/Zqko.	\N	2026-05-05 16:24:05	2026-05-05 16:24:05	f
10	user1	user1@example.com	\N	4691a749	\N	\N	\N	f
11	user2	user2@example.com	\N	34b79c05	\N	\N	\N	f
12	user3	user3@example.com	\N	16e642ea	\N	\N	\N	f
13	user4	user4@example.com	\N	f817ef7d	\N	\N	\N	f
14	user5	user5@example.com	\N	ccc1d0a1	\N	\N	\N	f
15	user6	user6@example.com	\N	aed0df62	\N	\N	\N	f
16	user7	user7@example.com	\N	21b5c253	\N	\N	\N	f
17	user8	user8@example.com	\N	e1b1440b	\N	\N	\N	f
18	user9	user9@example.com	\N	e9b864a4	\N	\N	\N	f
19	user10	user10@example.com	\N	c5ac935e	\N	\N	\N	f
20	USER1	USER110@gmail.com	\N	$2y$12$LMEMD2ZFOKJEwAFt979Mue9yHMOKAV/47anBSAID94dRoNPlg2qoe	\N	2026-06-04 09:20:13	2026-06-04 09:20:13	f
\.


--
-- TOC entry 4572 (class 0 OID 0)
-- Dependencies: 216
-- Name: abilities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.abilities_id_seq', 18, true);


--
-- TOC entry 4573 (class 0 OID 0)
-- Dependencies: 218
-- Name: character_abilities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.character_abilities_id_seq', 1, false);


--
-- TOC entry 4574 (class 0 OID 0)
-- Dependencies: 220
-- Name: character_ability_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.character_ability_id_seq', 45, true);


--
-- TOC entry 4575 (class 0 OID 0)
-- Dependencies: 222
-- Name: character_inventory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.character_inventory_id_seq', 1, false);


--
-- TOC entry 4576 (class 0 OID 0)
-- Dependencies: 224
-- Name: character_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.character_item_id_seq', 50, true);


--
-- TOC entry 4577 (class 0 OID 0)
-- Dependencies: 226
-- Name: characters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.characters_id_seq', 82, true);


--
-- TOC entry 4578 (class 0 OID 0)
-- Dependencies: 228
-- Name: classes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.classes_id_seq', 2, true);


--
-- TOC entry 4579 (class 0 OID 0)
-- Dependencies: 230
-- Name: failed_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.failed_jobs_id_seq', 1, false);


--
-- TOC entry 4580 (class 0 OID 0)
-- Dependencies: 232
-- Name: items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.items_id_seq', 18, true);


--
-- TOC entry 4581 (class 0 OID 0)
-- Dependencies: 242
-- Name: level_up_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.level_up_log_id_seq', 2, true);


--
-- TOC entry 4582 (class 0 OID 0)
-- Dependencies: 234
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.migrations_id_seq', 15, true);


--
-- TOC entry 4583 (class 0 OID 0)
-- Dependencies: 237
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.personal_access_tokens_id_seq', 1, false);


--
-- TOC entry 4584 (class 0 OID 0)
-- Dependencies: 239
-- Name: races_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.races_id_seq', 12, true);


--
-- TOC entry 4585 (class 0 OID 0)
-- Dependencies: 241
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 20, true);


--
-- TOC entry 4327 (class 2606 OID 111035)
-- Name: abilities abilities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.abilities
    ADD CONSTRAINT abilities_pkey PRIMARY KEY (id);


--
-- TOC entry 4329 (class 2606 OID 111037)
-- Name: character_abilities character_abilities_character_id_ability_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_abilities
    ADD CONSTRAINT character_abilities_character_id_ability_id_unique UNIQUE (character_id, ability_id);


--
-- TOC entry 4331 (class 2606 OID 111039)
-- Name: character_abilities character_abilities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_abilities
    ADD CONSTRAINT character_abilities_pkey PRIMARY KEY (id);


--
-- TOC entry 4333 (class 2606 OID 111041)
-- Name: character_ability character_ability_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_ability
    ADD CONSTRAINT character_ability_pkey PRIMARY KEY (id);


--
-- TOC entry 4335 (class 2606 OID 111043)
-- Name: character_inventory character_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_inventory
    ADD CONSTRAINT character_inventory_pkey PRIMARY KEY (id);


--
-- TOC entry 4337 (class 2606 OID 111045)
-- Name: character_item character_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_item
    ADD CONSTRAINT character_item_pkey PRIMARY KEY (id);


--
-- TOC entry 4339 (class 2606 OID 111047)
-- Name: characters characters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT characters_pkey PRIMARY KEY (id);


--
-- TOC entry 4341 (class 2606 OID 111049)
-- Name: classes classes_name_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_name_unique UNIQUE (name);


--
-- TOC entry 4343 (class 2606 OID 111051)
-- Name: classes classes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_pkey PRIMARY KEY (id);


--
-- TOC entry 4345 (class 2606 OID 111053)
-- Name: failed_jobs failed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);


--
-- TOC entry 4347 (class 2606 OID 111055)
-- Name: failed_jobs failed_jobs_uuid_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_uuid_unique UNIQUE (uuid);


--
-- TOC entry 4349 (class 2606 OID 111057)
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- TOC entry 4368 (class 2606 OID 114701)
-- Name: level_up_log level_up_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.level_up_log
    ADD CONSTRAINT level_up_log_pkey PRIMARY KEY (id);


--
-- TOC entry 4351 (class 2606 OID 111059)
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- TOC entry 4353 (class 2606 OID 111061)
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (email);


--
-- TOC entry 4355 (class 2606 OID 111063)
-- Name: personal_access_tokens personal_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 4357 (class 2606 OID 111065)
-- Name: personal_access_tokens personal_access_tokens_token_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_token_unique UNIQUE (token);


--
-- TOC entry 4360 (class 2606 OID 111067)
-- Name: races races_name_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.races
    ADD CONSTRAINT races_name_unique UNIQUE (name);


--
-- TOC entry 4362 (class 2606 OID 111069)
-- Name: races races_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.races
    ADD CONSTRAINT races_pkey PRIMARY KEY (id);


--
-- TOC entry 4364 (class 2606 OID 111071)
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- TOC entry 4366 (class 2606 OID 111073)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4358 (class 1259 OID 111074)
-- Name: personal_access_tokens_tokenable_type_tokenable_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX personal_access_tokens_tokenable_type_tokenable_id_index ON public.personal_access_tokens USING btree (tokenable_type, tokenable_id);


--
-- TOC entry 4369 (class 2606 OID 111075)
-- Name: character_abilities character_abilities_ability_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_abilities
    ADD CONSTRAINT character_abilities_ability_id_foreign FOREIGN KEY (ability_id) REFERENCES public.abilities(id) ON DELETE CASCADE;


--
-- TOC entry 4370 (class 2606 OID 111080)
-- Name: character_abilities character_abilities_character_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_abilities
    ADD CONSTRAINT character_abilities_character_id_foreign FOREIGN KEY (character_id) REFERENCES public.characters(id) ON DELETE CASCADE;


--
-- TOC entry 4371 (class 2606 OID 111085)
-- Name: character_ability character_ability_ability_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_ability
    ADD CONSTRAINT character_ability_ability_id_foreign FOREIGN KEY (ability_id) REFERENCES public.abilities(id) ON DELETE CASCADE;


--
-- TOC entry 4372 (class 2606 OID 111090)
-- Name: character_ability character_ability_character_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_ability
    ADD CONSTRAINT character_ability_character_id_foreign FOREIGN KEY (character_id) REFERENCES public.characters(id) ON DELETE CASCADE;


--
-- TOC entry 4373 (class 2606 OID 111095)
-- Name: character_inventory character_inventory_character_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_inventory
    ADD CONSTRAINT character_inventory_character_id_foreign FOREIGN KEY (character_id) REFERENCES public.characters(id) ON DELETE CASCADE;


--
-- TOC entry 4374 (class 2606 OID 111100)
-- Name: character_inventory character_inventory_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_inventory
    ADD CONSTRAINT character_inventory_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.items(id) ON DELETE RESTRICT;


--
-- TOC entry 4375 (class 2606 OID 111105)
-- Name: character_item character_item_character_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_item
    ADD CONSTRAINT character_item_character_id_foreign FOREIGN KEY (character_id) REFERENCES public.characters(id) ON DELETE CASCADE;


--
-- TOC entry 4376 (class 2606 OID 111110)
-- Name: character_item character_item_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.character_item
    ADD CONSTRAINT character_item_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.items(id) ON DELETE CASCADE;


--
-- TOC entry 4377 (class 2606 OID 111115)
-- Name: characters characters_class_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT characters_class_id_foreign FOREIGN KEY (class_id) REFERENCES public.classes(id) ON DELETE SET NULL;


--
-- TOC entry 4378 (class 2606 OID 111120)
-- Name: characters characters_race_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT characters_race_id_foreign FOREIGN KEY (race_id) REFERENCES public.races(id) ON DELETE SET NULL;


--
-- TOC entry 4379 (class 2606 OID 111125)
-- Name: characters characters_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT characters_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4380 (class 2606 OID 114702)
-- Name: level_up_log level_up_log_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.level_up_log
    ADD CONSTRAINT level_up_log_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id) ON DELETE CASCADE;


-- Completed on 2026-06-07 10:51:43 MSK

--
-- PostgreSQL database dump complete
--

\unrestrict dfZKWXAu4B8naL5uV9cE9eeDmJMfiQkcMYUuicyLHydeTmDSivIifOAdhZvxkoK

