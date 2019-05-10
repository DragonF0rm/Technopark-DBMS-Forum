--
-- PostgreSQL database dump
--

-- Dumped from database version 10.7 (Ubuntu 10.7-0ubuntu0.18.04.1)
-- Dumped by pg_dump version 10.7 (Ubuntu 10.7-0ubuntu0.18.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: Vote; Type: TYPE; Schema: public; Owner: maxim
--

CREATE TYPE public."Vote" AS ENUM (
    '-1',
    '1'
);


ALTER TYPE public."Vote" OWNER TO maxim;

--
-- Name: type_forum; Type: TYPE; Schema: public; Owner: maxim
--

CREATE TYPE public.type_forum AS (
	title character varying,
	"user" character varying,
	slug character varying,
	posts bigint,
	threads integer,
	is_new boolean
);


ALTER TYPE public.type_forum OWNER TO maxim;

--
-- Name: type_post; Type: TYPE; Schema: public; Owner: maxim
--

CREATE TYPE public.type_post AS (
	id bigint,
	parent bigint,
	author character varying,
	message character varying,
	"isEdited" boolean,
	forum character varying,
	thread bigint,
	created timestamp with time zone,
	is_new boolean
);


ALTER TYPE public.type_post OWNER TO maxim;

--
-- Name: type_post_data; Type: TYPE; Schema: public; Owner: maxim
--

CREATE TYPE public.type_post_data AS (
	parent bigint,
	author character varying,
	message character varying
);


ALTER TYPE public.type_post_data OWNER TO maxim;

--
-- Name: type_status; Type: TYPE; Schema: public; Owner: maxim
--

CREATE TYPE public.type_status AS (
	"user" integer,
	forum integer,
	thread integer,
	post integer
);


ALTER TYPE public.type_status OWNER TO maxim;

--
-- Name: type_thread; Type: TYPE; Schema: public; Owner: maxim
--

CREATE TYPE public.type_thread AS (
	is_new boolean,
	id bigint,
	title character varying(256),
	author character varying,
	forum character varying,
	message character varying,
	votes integer,
	slug character varying,
	created timestamp with time zone
);


ALTER TYPE public.type_thread OWNER TO maxim;

--
-- Name: type_user; Type: TYPE; Schema: public; Owner: maxim
--

CREATE TYPE public.type_user AS (
	is_new boolean,
	nickname character varying,
	fullname character varying,
	about character varying,
	email character varying
);


ALTER TYPE public.type_user OWNER TO maxim;

--
-- Name: func_add_post_to_forum(); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_add_post_to_forum() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
    UPDATE "Forums" SET posts = posts + 1 WHERE id = NEW."forum-id";
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.func_add_post_to_forum() OWNER TO maxim;

--
-- Name: func_add_thread_to_forum(); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_add_thread_to_forum() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
    UPDATE "Forums" SET threads = threads + 1 WHERE id = NEW."forum-id";
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.func_add_thread_to_forum() OWNER TO maxim;

--
-- Name: func_add_vote_to_thread(); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_add_vote_to_thread() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    voice int;
BEGIN
    voice := NEW.voice;
    UPDATE "Threads" SET votes = votes + voice WHERE id = NEW."thread-id";
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.func_add_vote_to_thread() OWNER TO maxim;

--
-- Name: func_check_post_before_adding(); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_check_post_before_adding() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    parent RECORD;
    thread RECORD;
BEGIN
    IF  NEW."parent-id" IS NOT NULL
    AND NEW."parent-id" != 0 THEN
        SELECT * INTO parent
        from "Posts"
        WHERE id = NEW."parent-id";
    
        SELECT * into thread
        FROM "Threads"
        WHERE id = NEW."thread-id";
    
        if NEW."forum-id" != parent."forum-id"
        OR NEW."thread-id" != parent."thread-id"
        OR NEW."forum-id" != thread."forum-id"
        THEN
            RAISE integrity_constraint_violation;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.func_check_post_before_adding() OWNER TO maxim;

--
-- Name: func_convert_post_parent_zero_into_null(); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_convert_post_parent_zero_into_null() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
    IF NEW."parent-id" = 0 THEN
       NEW."parent-id" := NULL;
    END IF;
    RETURN NEW;
END; 
$$;


ALTER FUNCTION public.func_convert_post_parent_zero_into_null() OWNER TO maxim;

--
-- Name: func_convert_post_parent_zero_into_null$$(); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public."func_convert_post_parent_zero_into_null$$"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
    IF NEW."parent-id" = 0 THEN
       NEW."parent-id" := NULL;
    END IF;
    RETURN NEW;
END; 
$$;


ALTER FUNCTION public."func_convert_post_parent_zero_into_null$$"() OWNER TO maxim;

--
-- Name: func_delete_post_from_forum(); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_delete_post_from_forum() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  	UPDATE "Forums" SET posts = posts -1 WHERE id = OLD."forum-id";
  	RETURN NEW;
END;
$$;


ALTER FUNCTION public.func_delete_post_from_forum() OWNER TO maxim;

--
-- Name: func_delete_thread_from_forum(); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_delete_thread_from_forum() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
    UPDATE "Forums" SET threads = threads - 1 WHERE id = OLD."forum-id";
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.func_delete_thread_from_forum() OWNER TO maxim;

--
-- Name: func_delete_vote_from_thread(); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_delete_vote_from_thread() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    voice int;
BEGIN
    voice := OLD.voice;
    UPDATE "Threads" SET votes = votes - voice WHERE id = OLD."thread-id";
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.func_delete_vote_from_thread() OWNER TO maxim;

--
-- Name: func_edit_post(); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_edit_post() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
    if OLD.message != NEW.message THEN
        NEW."is-edited" = TRUE;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.func_edit_post() OWNER TO maxim;

--
-- Name: func_forum_create(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_forum_create(arg_title character varying, arg_nickname character varying, arg_slug character varying) RETURNS TABLE(res_is_new boolean, res_title character varying, res_user character varying, res_slug character varying, res_posts bigint, res_threads bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    user_id BIGINT;
BEGIN
    SELECT id, nickname into user_id, res_user
    from "Users"
    WHERE lower(nickname) = lower(arg_nickname);
    IF not found then
        RAISe no_data_found;
    end if;
    begin
        res_is_new := true;
        INSERT into "Forums"(title, "user-id", slug)
        VALUES (arg_title, user_id, arg_slug)
        RETURNING title, slug, posts, threads
        into res_title, res_slug, res_posts, res_threads;
        RETURN NEXT;
    EXCEPTION
        WHEN unique_violation THEN
            begin
                res_is_new := false;
                select f.title, f.slug, f.posts, f.threads
                into res_title, res_slug, res_posts, res_threads
                FROM "Forums" f
                where lower(f.slug) = lower(arg_slug);
                return NEXT;
            end;
    END;
END;
$$;


ALTER FUNCTION public.func_forum_create(arg_title character varying, arg_nickname character varying, arg_slug character varying) OWNER TO maxim;

--
-- Name: func_forum_create_thread(character varying, character varying, character varying, character varying, character varying, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_forum_create_thread(arg_forum_slug character varying, arg_thread_slug character varying, arg_title character varying, arg_author character varying, arg_message character varying, arg_created timestamp with time zone) RETURNS public.type_thread
    LANGUAGE plpgsql
    AS $$
DECLARE
    result type_thread;
    user_id BIGINT;
    forum_id BIGINT;
BEGIN
    select id INTO user_id
    FROM "Users"
    WHERE lower(nickname) = lower(arg_author);
    IF not found then
        RAISe no_data_found;
    end if;
    result.author := arg_author;
    
    SELECT f.id, f.slug INTO forum_id, result.forum
    FROM "Forums" f
    WHERE lower(f.slug) = lower(arg_forum_slug);
    if not found then
        RAISe no_data_found;
    end if;
    
    begin
        result.is_new := true;
        INSERT INTO "Threads" ("author-id", created, "forum-id", message, slug, title)
        VALUES (user_id, arg_created, forum_id, arg_message,arg_thread_slug, arg_title)
        RETURNING id, title, message, votes, slug, created
        INTO result.id, result.title, result.message, result.votes, result.slug, result.created;
        RETURN result;
    EXCEPTION
        WHEN unique_violation THEN
            begin
                result.is_new := false;
                SELECT t.id, t.title, u.nickname, f.slug, t.message, t.votes, t.slug, t.created
                INTO result.id, result.title, result.author, result.forum, result.message, result.votes, result.slug, result.created
                FROM "Threads" t
                JOIN "Users" u ON u.id = t."author-id"
                JOIN "Forums" f ON f.id = t."forum-id"
                WHERE lower(t.slug) = lower(arg_thread_slug);
                return result;
            end;
    end;
END;
$$;


ALTER FUNCTION public.func_forum_create_thread(arg_forum_slug character varying, arg_thread_slug character varying, arg_title character varying, arg_author character varying, arg_message character varying, arg_created timestamp with time zone) OWNER TO maxim;

--
-- Name: func_forum_details(character varying); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_forum_details(arg_slug character varying) RETURNS public.type_forum
    LANGUAGE plpgsql
    AS $$
DECLARE
    result type_forum;
BEGIN
    result.is_new := FALSE;
    SELECT f.title, u.nickname, f.slug, f.posts, f.threads
    INTO result.title, result.user, result.slug, result.posts, result.threads
    FROM "Forums" f
    JOIN "Users" u ON u.id = f."user-id"
    WHERE lower(f.slug) = lower(arg_slug);
    if not found then
        RAISe no_data_found;
    end if;
    RETURN result;
END;
$$;


ALTER FUNCTION public.func_forum_details(arg_slug character varying) OWNER TO maxim;

--
-- Name: func_forum_threads(character varying, timestamp with time zone, boolean, integer); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_forum_threads(arg_slug character varying, arg_since timestamp with time zone, arg_desc boolean, arg_limit integer DEFAULT 100) RETURNS SETOF public.type_thread
    LANGUAGE plpgsql
    AS $$
DECLARE
    forum_id BIGINT;
    result type_thread;
    rec RECORD;
BEGIN
    result.is_new := false;
    
    SELECT id, slug into forum_id, result.forum
    from "Forums"
    where lower(slug) = lower(arg_slug);
    if not found then
        RAISe no_data_found;
    end if;
    
    FOR rec in SELECT t.id, t.title, u.nickname, t.message, t.votes, t.slug, t.created
        FROM "Threads" t 
        JOIN "Users" u on u.id = t."author-id"
        WHERE t."forum-id" = forum_id
        and CASE
            when arg_since is null then true
            WHEN arg_desc THEN t.created <= arg_since
            ELSE t.created >= arg_since
        END
        ORDER BY
            (case WHEN arg_desc THEN t.created END) DESC,
            (CASE WHEN not arg_desc THEN t.created END) ASC
        LIMIT arg_limit
    LOOp
        result.id := rec.id;
        result.title := rec.title;
        result.author := rec.nickname;
        result.message := rec.message;
        result.votes := rec.votes;
        result.slug := rec.slug;
        result.created := rec.created;
        RETURN next result;
    end loop;
END;
$$;


ALTER FUNCTION public.func_forum_threads(arg_slug character varying, arg_since timestamp with time zone, arg_desc boolean, arg_limit integer) OWNER TO maxim;

--
-- Name: func_forum_users(character varying, character varying, boolean, integer); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_forum_users(arg_slug character varying, arg_since character varying, arg_desc boolean, arg_limit integer DEFAULT 100) RETURNS SETOF public.type_user
    LANGUAGE plpgsql
    AS $$
DECLARE
    forum_id BIGINT;
    result type_user;
    rec RECORD;
BEGIN
    result.is_new := false;
    
    SELECT id into forum_id
    from "Forums"
    where lower(slug) = lower(arg_slug);
    if not found then
        RAISe no_data_found;
    end if;
    
    FOR rec in SELECT u.nickname, u.fullname, u.about, u.email
        FROM "Users" u
        join (
            SELECT DISTINCT "author-id" AS id
            FROM "Threads"
            where "forum-id" = forum_id
            UNION
            SELECT DISTINCT "author-id" AS id
            FROM "Posts"
            WHERE "forum-id" = forum_id
        ) forum_users on forum_users.id = u.id  
        WHERE CASE
            when arg_since is null then true
            WHEN arg_desc THEN lower(u.nickname) < lower(arg_since)
            ELSE lower(u.nickname) > lower(arg_since)
        END
        ORDER BY
            (case WHEN arg_desc THEN lower(u.nickname) END) DESC,
            (CASE WHEN not arg_desc THEN lower(u.nickname) END) ASC
        LIMIT arg_limit
    LOOp
        result.nickname := rec.nickname;
        result.fullname := rec.fullname;
        result.about := rec.about;
        result.email := rec.email;
        RETURN next result;
    end loop;
END;
$$;


ALTER FUNCTION public.func_forum_users(arg_slug character varying, arg_since character varying, arg_desc boolean, arg_limit integer) OWNER TO maxim;

--
-- Name: func_make_path_for_post(); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_make_path_for_post() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    parent RECORD;
BEGIN
    IF  NEW."parent-id" IS NOT NULL
    AND NEW."parent-id" != 0
    THEN
        SELECT * INTO parent
        FROM "Posts"
        WHERE id = NEW."parent-id";
        NEW.path := parent.path || parent.id;
    END IF;
    RETURN NEW; 
END;
$$;


ALTER FUNCTION public.func_make_path_for_post() OWNER TO maxim;

--
-- Name: func_post_change(bigint, character varying); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_post_change(arg_id bigint, arg_post character varying) RETURNS public.type_post
    LANGUAGE plpgsql
    AS $$
DECLARE
    author_id BIGINT;
    forum_id BIGINT;
    result type_post;
BEGIN
    result.is_new := FALSE;
    UPDATE "Posts"
    SET message = CASE
        WHEN arg_post != '' THEN arg_post
        ELSE message END
    WHERE id = arg_id
    REturning id, "parent-id", "author-id", message, "is-edited", "forum-id", "thread-id", created
    INTO result.id, result.parent, author_id, result.message, result."isEdited", forum_id, result.thread, result.created;
    if not found then
        RAISe no_data_found;
    end if;
    
    SELECT nickname INTo result.author FROM "Users" where id = author_id;
    if not found then
        RAISe no_data_found;
    end if;
    
    SELECT slug InTO result.forum FROM "Forums" Where id = forum_id;
    if not found then
        RAISe no_data_found;
    end if;
    
    if result.parent is null then
        result.parent = 0;
    end if;
    
    return result;
END;
$$;


ALTER FUNCTION public.func_post_change(arg_id bigint, arg_post character varying) OWNER TO maxim;

--
-- Name: func_post_details(bigint); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_post_details(arg_id bigint) RETURNS public.type_post
    LANGUAGE plpgsql
    AS $$
DECLARE
    result type_post;
BEGIN
    result.is_new := false;
    SELECT p.id, p."parent-id", u.nickname, p.message, p."is-edited", f.slug, p."thread-id", p.created
    INTO result.id, result.parent, result.author, result.message, result."isEdited", result.forum, result.thread, result.created
    FROM "Posts" p
    JOIN "Users" u on u.id = p."author-id"
    JOIN "Forums" f ON f.id = p."forum-id"
    WHERE p.id = arg_id;
    if not found then
        RAISe no_data_found;
    end if;
    IF result.parent IS NULL THEN
        result.parent := 0;
    END IF;
    RETURN result;
END;
$$;


ALTER FUNCTION public.func_post_details(arg_id bigint) OWNER TO maxim;

--
-- Name: func_service_clear(); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_service_clear() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
    TRUNCATE TABLE "Users", "Forums", "Threads", "Posts", "Votes";
END;
$$;


ALTER FUNCTION public.func_service_clear() OWNER TO maxim;

--
-- Name: func_service_status(); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_service_status() RETURNS public.type_status
    LANGUAGE plpgsql
    AS $$
DECLARE
    result type_status;
BEGIN
    SELECT count(*) INTO result.user FROM (
        SELECT * FROM "Users"
    ) u;
    SELECT count(*) INTO result.forum FROM (
        SELECT * FROM "Forums" f
    ) f;
    SELECT count(*) INTO result.thread FROM (
        SELECT * FROM "Threads"
    ) t;
    SELECT count(*) INTO result.post FROM (
        SELECT * FROM "Posts"
    ) p;
    RETURN result;
END;
$$;


ALTER FUNCTION public.func_service_status() OWNER TO maxim;

--
-- Name: func_thread_change(bigint, character varying, character varying); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_thread_change(arg_id bigint, arg_title character varying, arg_message character varying) RETURNS public.type_thread
    LANGUAGE plpgsql
    AS $$
DECLARE
    result type_thread;
    user_id BIGINT;
    forum_id BIGINT;
BEGIN
    result.is_new := FALSE;
    UPDATE "Threads"
    SET title = CASE
            WHEN arg_title != '' THEN arg_title
            ELSE title END,
        message = CASE
            WHEN arg_message != '' THEN arg_message
            ELSE message END
    Where id = arg_id
    RETURNING id, title, "author-id", message, votes, slug, created, "forum-id"
    INTO result.id, result.title, user_id, result.message, result.votes, result.slug, result.created, forum_id;
    if not found then
        RAISe no_data_found;
    end if;
    SELECT nickname into result.author From "Users" WHERE id = user_id for update;
    if not found then
        RAISe no_data_found;
    end if;
    SELECT slug into result.forum From "Forums" WHERE id = forum_id for update;
    if not found then
        RAISe no_data_found;
    end if;
    return result;
END;
$$;


ALTER FUNCTION public.func_thread_change(arg_id bigint, arg_title character varying, arg_message character varying) OWNER TO maxim;

--
-- Name: func_thread_create_posts(bigint, bigint[], character varying[], character varying[]); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_thread_create_posts(arg_id bigint, arg_parents bigint[], arg_authors character varying[], arg_messages character varying[]) RETURNS SETOF public.type_post
    LANGUAGE plpgsql
    AS $$
DECLARE
    result type_post;
    user_id BIGINT;
    forum_id BIGINT;
    array_length INTEGER;
    i Integer;
    post type_post_data;
BEGIN
    array_length := array_length(arg_parents, 1);
    IF array_length != array_length(arg_authors, 1)
    OR array_length != array_length(arg_messages, 1)
    THEN
        RAISE invalid_parameter_value;
    END IF;
    
    result.is_new := false;
    result.created := now(); 
    
    SELECT t."forum-id", f.slug INTO forum_id, result.forum
    FROM "Threads" t
    JOIN "Forums" f ON f.id = t."forum-id"
    WHERE t.id = arg_id;
    if not found then
        RAISe no_data_found;
    end if;
    result.thread := arg_id;
    
    IF array_length is null then
        RETURN;
    END IF;
    
    i := 1;
    
    LOOP
        EXIT WHEN i > array_length;
        
        post.parent  := arg_parents[i];
        IF post.parent = 0 THEN
            post.parent := NULL;
        END IF;
        post.author  := arg_authors[i];
        post.message := arg_messages[i];
        
        if post.parent is null then
            result.parent = 0;
        else
            result.parent := post.parent;
        end if;   
    
        SELECT id into user_id
        from "Users"
        WHERE lower(nickname) = lower(post.author);
        if not found then
            RAISe no_data_found;
        end if;
        result.author := post.author;
        
        INSERT into "Posts"("author-id", created, "forum-id", message, "parent-id", "thread-id")
        VALUES (user_id, result.created, forum_id, post.message, post.parent, arg_id)
        RETURNING  id, message, "is-edited"
        INTO result.id, result.message, result."isEdited";
        
        RETURN NEXT result;
        
        i := i + 1;
    END LOOP;
EXCEPTION
    WHEN unique_violation THEN
        RAISE unique_violation;
    WHEN integrity_constraint_violation THEN
        RAISE integrity_constraint_violation;
END;
$$;


ALTER FUNCTION public.func_thread_create_posts(arg_id bigint, arg_parents bigint[], arg_authors character varying[], arg_messages character varying[]) OWNER TO maxim;

--
-- Name: func_thread_details(bigint); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_thread_details(arg_id bigint) RETURNS public.type_thread
    LANGUAGE plpgsql
    AS $$
DECLARE
    result type_thread;
BEGIN
    result.is_new := false;
    SELECT t.id, t.title, u.nickname, f.slug, t.message, t.votes, t.slug, t.created
    into result.id, result.title, result.author, result.forum, result.message, result.votes, result.slug, result.created
    from "Threads" t
    JOIN "Users" u ON u.id = t."author-id"
    JOIN "Forums" f ON f.id = t."forum-id"
    WHERE t.id = arg_id;
    if not found then
        RAISe no_data_found;
    end if;
    return result;
END;
$$;


ALTER FUNCTION public.func_thread_details(arg_id bigint) OWNER TO maxim;

--
-- Name: func_thread_get_id_by_slug(character varying); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_thread_get_id_by_slug(arg_slug character varying) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
    result BIGINT;
BEGIN
    SELECT id into result
    from "Threads"
    where lower(slug) = lower(arg_slug);
    if not found then
        RAISe no_data_found;
    end if;
    return result;
END;
$$;


ALTER FUNCTION public.func_thread_get_id_by_slug(arg_slug character varying) OWNER TO maxim;

--
-- Name: func_thread_get_post_layer(bigint, bigint, bigint, boolean, integer); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_thread_get_post_layer(arg_thread_id bigint, arg_parent_id bigint, arg_since_id bigint, arg_desc boolean, arg_limit integer DEFAULT NULL::integer) RETURNS SETOF public.type_post
    LANGUAGE plpgsql
    AS $$
DECLARE
    result type_post;
    rec RECORD;
BEGIN
    result.is_new := false;
    FOR rec in SELECT p.id, p."parent-id", u.nickname, p.message, p."is-edited", f.slug, p."thread-id", p.created
        FROM "Posts" p 
        JOIN "Users" u on u.id = p."author-id"
        JOIN "Forums" f ON f.id = p."forum-id"
        WHERE p."thread-id" = arg_thread_id
        and case
            WHEN arg_parent_id = 0 THEN p."parent-id" IS NULL
            ELSE p."parent-id" = arg_parent_id
        END
        and CASE
            when arg_since_id is null then true
            WHEN arg_desc THEN p.id < arg_since_id
            ELSE p.id > arg_since_id
        END
        ORDER BY
            (case WHEN arg_desc THEN p.created END) DESC,
            (CASE WHEN not arg_desc THEN p.created END) ASC
        LIMIT arg_limit
    LOOp
        result.id := rec.id;
         IF rec."parent-id" is null then
            result.parent := 0;
        ELSE
            result.parent := rec."parent-id";
        end if;
        result.author := rec.nickname;
        result.message := rec.message;
        result."isEdited" := rec."is-edited";
        result.forum := rec.slug;
        result.thread := rec."thread-id";
        result.created := rec.created;
        RETURN next result;
    end loop;
END;
$$;


ALTER FUNCTION public.func_thread_get_post_layer(arg_thread_id bigint, arg_parent_id bigint, arg_since_id bigint, arg_desc boolean, arg_limit integer) OWNER TO maxim;

--
-- Name: func_thread_posts_flat(bigint, bigint, boolean, integer); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_thread_posts_flat(arg_thread_id bigint, arg_since_id bigint, arg_desc boolean, arg_limit integer DEFAULT 100) RETURNS SETOF public.type_post
    LANGUAGE plpgsql
    AS $$
DECLARE
    result type_post;
    rec RECORD;
BEGIN
    result.is_new := false;
    SELECT *
    Into rec
    from "Threads"
    where id = arg_thread_id;
    if not found then
        RAISe no_data_found;
    end if;
    
    FOR rec iN SELECT p.id, p."parent-id", u.nickname, p.message, p."is-edited", f.slug, p."thread-id", p.created
        FROM "Posts" p
        JOIN "Users" u on u.id = p."author-id"
        JOIN "Forums" f ON f.id = p."forum-id"
        WHERE p."thread-id" = arg_thread_id
        AND CASE
            when arg_since_id is null OR arg_since_id = 0 then true
           ELSE CASE
                WHEN arg_desc THEN p.id < arg_since_id
                ELSE p.id > arg_since_id
            END
        END
        ORDER BY
            (case WHEN arg_desc THEN p.id END) DESC,
            (CASE WHEN not arg_desc THEN p.id END) ASC
        LIMIT arg_limit
    LOOp
        result.id := rec.id;
        IF rec."parent-id" is null then
            result.parent := 0;
        ELSE
            result.parent := rec."parent-id";
        end if;
        result.author := rec.nickname;
        result.message := rec.message;
        result."isEdited" := rec."is-edited";
        result.forum := rec.slug;
        result.thread := rec."thread-id";
        result.created := rec.created;
        RETURN next result;
    end loop;
END;
$$;


ALTER FUNCTION public.func_thread_posts_flat(arg_thread_id bigint, arg_since_id bigint, arg_desc boolean, arg_limit integer) OWNER TO maxim;

--
-- Name: func_thread_posts_parent_tree(bigint, bigint, boolean, integer); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_thread_posts_parent_tree(arg_thread_id bigint, arg_since_id bigint, arg_desc boolean, arg_limit integer DEFAULT 100) RETURNS SETOF public.type_post
    LANGUAGE plpgsql
    AS $$
DECLARE
    result type_post;
    rec RECORD;
    root RECORD;
    since_root_id BIGINT;
    depth INTEGER;
BEGIN
    result.is_new := false;

    SELECT *
    Into rec
    from "Threads"
    where id = arg_thread_id;
    if not found then
        RAISe no_data_found;
    end if;

    SELECT (path || id)[2], array_length(path, 1) + 1
    INTO since_root_id, depth
    FROM "Posts"
    WHERE id = arg_since_id;
    
    FOR rec IN
        SELECT p.id, p."parent-id", u.nickname, p.message, p."is-edited", f.slug, p."thread-id", p.created
        FROM "Posts" p
        JOIN "Users" u on u.id = p."author-id"
        JOIN "Forums" f ON f.id = p."forum-id"
        WHERE p."thread-id" = arg_thread_id
        AND (p.path || p.id)[2] IN (
            SELECT inner_p.id
            FROM "Posts" inner_p
            WHERE inner_p."parent-id" IS NULL
            AND inner_p."thread-id" = arg_thread_id
            AND CASE
                when since_root_id IS NULL then true
                ELSE CASE
                    WHEN arg_desc THEN inner_p.id < since_root_id
                    ELSE inner_p.id > since_root_id
                END
            END
            ORDER BY
                (case WHEN arg_desc THEN inner_p.id END) DESC,
                (CASE WHEN not arg_desc THEN inner_p.id END) ASC
            LIMIT arg_limit
        )
        --AND CASE
        --    when since_root_id is null then true
        --    ELSE (p.path || p.id)[2] = since_root_id
        --END
        ORDER BY
            (case WHEN arg_desc THEN (p.path || p.id)[2] END) DESC,
            (CASE WHEN not arg_desc THEN (p.path || p.id)[2] END) ASC,
            p.path || p.id
    LOOP
        result.id := rec.id;
        IF rec."parent-id" is null then
            result.parent := 0;
        ELSE
            result.parent := rec."parent-id";
        end if;
        result.author := rec.nickname;
        result.message := rec.message;
        result."isEdited" := rec."is-edited";
        result.forum := rec.slug;
        result.thread := rec."thread-id";
        result.created := rec.created;
        RETURN next result;
    END LOOP;
END;
$$;


ALTER FUNCTION public.func_thread_posts_parent_tree(arg_thread_id bigint, arg_since_id bigint, arg_desc boolean, arg_limit integer) OWNER TO maxim;

--
-- Name: func_thread_posts_tree(bigint, bigint, boolean, integer); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_thread_posts_tree(arg_thread_id bigint, arg_since_id bigint, arg_desc boolean, arg_limit integer DEFAULT 100) RETURNS SETOF public.type_post
    LANGUAGE plpgsql
    AS $$
DECLARE
    result type_post;
    rec RECORD;
    since_path BIGINT[];
BEGIN
    result.is_new := false;
    
    SELECT *
    Into rec
    from "Threads"
    where id = arg_thread_id;
    if not found then
        RAISe no_data_found;
    end if;
    
    IF arg_since_id = 0 THEN
        arg_since_id = NULL;
    END IF;
    
    IF arg_since_id IS NOT NULL THEN
        SELECT (path || id) INTO since_path
        FROM "Posts"
        WHERE id = arg_since_id;
        IF not found THEN
            RAISE no_data_found;
        END IF;
    END IF;
    
    FOR rec IN
        SELECT p.id, p."parent-id", u.nickname, p.message, p."is-edited", f.slug, p."thread-id", p.created
        FROM "Posts" p
        JOIN "Users" u on u.id = p."author-id"
        JOIN "Forums" f ON f.id = p."forum-id"
        WHERE p."thread-id" = arg_thread_id
        AND CASE
            when arg_since_id is null then true
            ELSE CASE
                WHEN arg_desc then (p.path || p.id) < since_path
                ELSE (p.path || p.id) > since_path
            END
        END
        ORDER BY
            (case WHEN arg_desc THEN p.path || p.id END) DESC,
            (CASE WHEN not arg_desc THEN p.path || p.id END) ASC,
            p.id
        LIMIT arg_limit
    LOOP
        result.id := rec.id;
        IF rec."parent-id" is null then
            result.parent := 0;
        ELSE
            result.parent := rec."parent-id";
        end if;
        result.author := rec.nickname;
        result.message := rec.message;
        result."isEdited" := rec."is-edited";
        result.forum := rec.slug;
        result.thread := rec."thread-id";
        result.created := rec.created;
        RETURN next result;
    END LOOP;
END;
$$;


ALTER FUNCTION public.func_thread_posts_tree(arg_thread_id bigint, arg_since_id bigint, arg_desc boolean, arg_limit integer) OWNER TO maxim;

--
-- Name: func_thread_posts_tree_from_root(bigint, bigint, boolean, integer); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_thread_posts_tree_from_root(arg_thread_id bigint, arg_since_id bigint, arg_desc boolean, arg_limit integer DEFAULT 100) RETURNS SETOF public.type_post
    LANGUAGE plpgsql
    AS $$
DECLARE
    result type_post;
    rec RECORD;
    depth INTEGER;
BEGIN
    result.is_new := false;
    
    IF arg_since_id = 0 THEN
        arg_since_id = NULL;
    END IF;
    
    IF arg_since_id IS NULL THEN
        depth := 1;
    ELSE
        SELECT array_length(path, 1) + 1 INTO depth
        FROM "Posts"
        WHERE id = arg_since_id;
        IF not found THEN
            RAISE no_data_found;
        END IF;
    END IF;
    
    FOR rec IN
        SELECT p.id, p."parent-id", u.nickname, p.message, p."is-edited", f.slug, p."thread-id", p.created
        FROM "Posts" p
        JOIN "Users" u on u.id = p."author-id"
        JOIN "Forums" f ON f.id = p."forum-id"
        WHERE p."thread-id" = arg_thread_id
        AND CASE
            when arg_since_id is null then true
            ELSE (p.path || p.id)[depth] = arg_since_id
        END
        ORDER BY
            p.path || p.id,
            (case WHEN arg_desc THEN p.id END) DESC,
            (CASE WHEN not arg_desc THEN p.id END) ASC
        LIMIT arg_limit
    LOOP
        result.id := rec.id;
        IF rec."parent-id" is null then
            result.parent := 0;
        ELSE
            result.parent := rec."parent-id";
        end if;
        result.author := rec.nickname;
        result.message := rec.message;
        result."isEdited" := rec."is-edited";
        result.forum := rec.slug;
        result.thread := rec."thread-id";
        result.created := rec.created;
        RETURN next result;
    END LOOP;
END;
$$;


ALTER FUNCTION public.func_thread_posts_tree_from_root(arg_thread_id bigint, arg_since_id bigint, arg_desc boolean, arg_limit integer) OWNER TO maxim;

--
-- Name: func_thread_vote(bigint, character varying, boolean); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_thread_vote(arg_id bigint, arg_nickname character varying, arg_like boolean) RETURNS public.type_thread
    LANGUAGE plpgsql
    AS $$
DECLARE
    voice_val "public"."Vote";
    user_id BIGINT;
    result type_thread;
BEGIN
    result.is_new := false;
    if arg_like then
        voice_val := 1;
    else
        voice_val := -1;
    END IF;
    SELECT id into user_id
    from "Users"
    WHERE lower(nickname) = lower(arg_nickname);
    IF NOT FOUND THEN
        RAISE no_data_found;
    END IF;
    INSERT into "Votes"("user-id", "thread-id", voice) VALUES (user_id, arg_id, voice_val);
    SELECT t.id, t.title, u.nickname, f.slug, t.message, t.votes, t.slug, t.created
    Into result.id, result.title, result.author, result.forum, result.message, result.votes, result.slug, result.created
    FROM "Threads" t 
    JOIN "Users" u on u.id = t."author-id"
    JOIN "Forums" f ON f.id = t."forum-id"
    WHERE t.id = arg_id;
    return result;
exception
    when unique_violation then
        UPDATE "Votes"
        SET voice = voice_val
        WHERE "user-id" = user_id
        AND "thread-id" = arg_id;
        SELECT t.id, t.title, u.nickname, f.slug, t.message, t.votes, t.slug, t.created
        Into result.id, result.title, result.author, result.forum, result.message, result.votes, result.slug, result.created
        FROM "Threads" t 
        JOIN "Users" u on u.id = t."author-id"
        JOIN "Forums" f ON f.id = t."forum-id"
        WHERE t.id = arg_id;
        return result;
    WHEN foreign_key_violation THEN
        RAISE no_data_found;
END;
$$;


ALTER FUNCTION public.func_thread_vote(arg_id bigint, arg_nickname character varying, arg_like boolean) OWNER TO maxim;

--
-- Name: func_update_vote(); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_update_vote() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    voice int;
BEGIN
    if (OLD.voice != NEW.voice)
    then
        voice := NEW.voice;
        voice := 2 * voice;
        UPDATE "Threads" SET votes = votes + voice WHERE id = NEW."thread-id";
    end if;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.func_update_vote() OWNER TO maxim;

--
-- Name: func_user_change_profile(character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_user_change_profile(arg_nickname character varying, arg_fullname character varying, arg_about character varying, arg_email character varying) RETURNS public.type_user
    LANGUAGE plpgsql
    AS $$
DECLARE
    result type_user;
    user_id BIGINT;
BEGIN
    result.is_new := FALSE;
    SELECT id INTO user_id
    FROM "Users"
    Where lower(nickname) = lower(arg_nickname);
    if not found then
        RAISe no_data_found;
    end if;
    
    UPDATE "Users"
    SET fullname = CASE
            WHEN arg_fullname != '' THEN arg_fullname
            ELSE fullname END,
        about = CASE
            WHEN arg_about != '' THEN arg_about
            ELSE about END,
        email = CASE
            WHEN arg_email != '' THEN arg_email
            ELSE email END
    Where id = user_id
    RETURNING nickname, fullname, about, email
    INTO result.nickname, result.fullname, result.about, result.email;
    return result;
exception
    when unique_violation THEN
        raise unique_violation;
END;
$$;


ALTER FUNCTION public.func_user_change_profile(arg_nickname character varying, arg_fullname character varying, arg_about character varying, arg_email character varying) OWNER TO maxim;

--
-- Name: func_user_create(character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_user_create(arg_nickname character varying, arg_fullname character varying, arg_about character varying, arg_email character varying) RETURNS SETOF public.type_user
    LANGUAGE plpgsql
    AS $$
DECLARE
    result type_user;
    rec RECORD;
BEGIN
    begin
        result.is_new := true;
        INSERT INTO "Users" (nickname, fullname, about, email)
        VALUES (arg_nickname, arg_fullname, arg_about, arg_email)
        RETURNING nickname, fullname, about, email
        INTO result.nickname, result.fullname, result.about, result.email;
        RETURN next result;
    EXCEPTION
        WHEN unique_violation THEN
            begin
                result.is_new := false;
                FOR rec IN SELECT nickname, fullname, about, email
                    FROM "Users"
                    WHERE lower(nickname) = lower(arg_nickname)
                    OR lower(email) = lower(arg_email)
                LOOP
                    result.nickname := rec.nickname;
                    result.fullname := rec.fullname;
                    result.about := rec.about;
                    result.email := rec.email;
                    RETURN NEXT result;
                END LOOP;
            end;
    end;
END;
$$;


ALTER FUNCTION public.func_user_create(arg_nickname character varying, arg_fullname character varying, arg_about character varying, arg_email character varying) OWNER TO maxim;

--
-- Name: func_user_details(character varying); Type: FUNCTION; Schema: public; Owner: maxim
--

CREATE FUNCTION public.func_user_details(arg_nickname character varying) RETURNS public.type_user
    LANGUAGE plpgsql
    AS $$
DECLARE
    result type_user;
BEGIN
    result.is_new := FALSE;
    SELECT nickname, fullname, about, email
    INTO result.nickname, result.fullname, result.about, result.email
    FROM "Users"
    WHERE lower(nickname) = lower(arg_nickname);
    if not found then
        RAISe no_data_found;
    end if;
    RETURN result;
END;
$$;


ALTER FUNCTION public.func_user_details(arg_nickname character varying) OWNER TO maxim;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: Forums; Type: TABLE; Schema: public; Owner: maxim
--

CREATE TABLE public."Forums" (
    id bigint NOT NULL,
    posts bigint DEFAULT 0 NOT NULL,
    slug character varying(2044) NOT NULL,
    threads integer DEFAULT 0 NOT NULL,
    title character varying(256) NOT NULL,
    "user-id" bigint NOT NULL
);


ALTER TABLE public."Forums" OWNER TO maxim;

--
-- Name: Forum_id_seq; Type: SEQUENCE; Schema: public; Owner: maxim
--

CREATE SEQUENCE public."Forum_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Forum_id_seq" OWNER TO maxim;

--
-- Name: Forum_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: maxim
--

ALTER SEQUENCE public."Forum_id_seq" OWNED BY public."Forums".id;


--
-- Name: Posts; Type: TABLE; Schema: public; Owner: maxim
--

CREATE TABLE public."Posts" (
    id bigint NOT NULL,
    "author-id" bigint NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL,
    "forum-id" bigint NOT NULL,
    "is-edited" boolean DEFAULT false NOT NULL,
    message character varying(2044) NOT NULL,
    "parent-id" bigint,
    "thread-id" bigint NOT NULL,
    path bigint[] DEFAULT '{0}'::bigint[] NOT NULL
);


ALTER TABLE public."Posts" OWNER TO maxim;

--
-- Name: Post_id_seq; Type: SEQUENCE; Schema: public; Owner: maxim
--

CREATE SEQUENCE public."Post_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Post_id_seq" OWNER TO maxim;

--
-- Name: Post_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: maxim
--

ALTER SEQUENCE public."Post_id_seq" OWNED BY public."Posts".id;


--
-- Name: Threads; Type: TABLE; Schema: public; Owner: maxim
--

CREATE TABLE public."Threads" (
    id bigint NOT NULL,
    "author-id" bigint NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL,
    "forum-id" bigint NOT NULL,
    message character varying(2044) NOT NULL,
    slug character varying(2044) DEFAULT ''::character varying NOT NULL,
    title character varying(2044) NOT NULL,
    votes integer DEFAULT 0 NOT NULL
);


ALTER TABLE public."Threads" OWNER TO maxim;

--
-- Name: Thread_id_seq; Type: SEQUENCE; Schema: public; Owner: maxim
--

CREATE SEQUENCE public."Thread_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Thread_id_seq" OWNER TO maxim;

--
-- Name: Thread_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: maxim
--

ALTER SEQUENCE public."Thread_id_seq" OWNED BY public."Threads".id;


--
-- Name: Users; Type: TABLE; Schema: public; Owner: maxim
--

CREATE TABLE public."Users" (
    id bigint NOT NULL,
    about character varying(512) NOT NULL,
    email character varying(2044) NOT NULL,
    fullname character varying(128) NOT NULL,
    nickname character varying(2044) NOT NULL
);


ALTER TABLE public."Users" OWNER TO maxim;

--
-- Name: Users_id_seq; Type: SEQUENCE; Schema: public; Owner: maxim
--

CREATE SEQUENCE public."Users_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Users_id_seq" OWNER TO maxim;

--
-- Name: Users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: maxim
--

ALTER SEQUENCE public."Users_id_seq" OWNED BY public."Users".id;


--
-- Name: Votes; Type: TABLE; Schema: public; Owner: maxim
--

CREATE TABLE public."Votes" (
    id bigint NOT NULL,
    voice public."Vote" NOT NULL,
    "thread-id" bigint NOT NULL,
    "user-id" bigint NOT NULL
);


ALTER TABLE public."Votes" OWNER TO maxim;

--
-- Name: Votes_id_seq; Type: SEQUENCE; Schema: public; Owner: maxim
--

CREATE SEQUENCE public."Votes_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Votes_id_seq" OWNER TO maxim;

--
-- Name: Votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: maxim
--

ALTER SEQUENCE public."Votes_id_seq" OWNED BY public."Votes".id;


--
-- Name: Forums id; Type: DEFAULT; Schema: public; Owner: maxim
--

ALTER TABLE ONLY public."Forums" ALTER COLUMN id SET DEFAULT nextval('public."Forum_id_seq"'::regclass);


--
-- Name: Posts id; Type: DEFAULT; Schema: public; Owner: maxim
--

ALTER TABLE ONLY public."Posts" ALTER COLUMN id SET DEFAULT nextval('public."Post_id_seq"'::regclass);


--
-- Name: Threads id; Type: DEFAULT; Schema: public; Owner: maxim
--

ALTER TABLE ONLY public."Threads" ALTER COLUMN id SET DEFAULT nextval('public."Thread_id_seq"'::regclass);


--
-- Name: Users id; Type: DEFAULT; Schema: public; Owner: maxim
--

ALTER TABLE ONLY public."Users" ALTER COLUMN id SET DEFAULT nextval('public."Users_id_seq"'::regclass);


--
-- Name: Votes id; Type: DEFAULT; Schema: public; Owner: maxim
--

ALTER TABLE ONLY public."Votes" ALTER COLUMN id SET DEFAULT nextval('public."Votes_id_seq"'::regclass);


--
-- Data for Name: Forums; Type: TABLE DATA; Schema: public; Owner: maxim
--

COPY public."Forums" (id, posts, slug, threads, title, "user-id") FROM stdin;
16899	0	cz5R6841koLO8	0	Advertenti una vi id.	79312
16900	0	RyN9i00_roaiK	0	Ubi respondit erro laudantur nec si voce sim.	79378
16901	0	1fFI2AEnriLiK	0	Ita inplicaverant non cadavere mallem minutissimis meo arguitur, facultas.	79444
\.


--
-- Data for Name: Posts; Type: TABLE DATA; Schema: public; Owner: maxim
--

COPY public."Posts" (id, "author-id", created, "forum-id", "is-edited", message, "parent-id", "thread-id", path) FROM stdin;
\.


--
-- Data for Name: Threads; Type: TABLE DATA; Schema: public; Owner: maxim
--

COPY public."Threads" (id, "author-id", created, "forum-id", message, slug, title, votes) FROM stdin;
\.


--
-- Data for Name: Users; Type: TABLE DATA; Schema: public; Owner: maxim
--

COPY public."Users" (id, about, email, fullname, nickname) FROM stdin;
79250	Grex hoc. Manu eruuntur sit en se, es. Regem os sed mel sufficiat, voluptaria cognovi. Amaris.	o.OJHA1pnAPz9MR@citoea.com	Noah Thompson	intime.WjZ0v7gBjzLz7u
79251	Facio cur an das lucente at conspirantes tuo. Statim vi es placere hoc tali primo nuntiavimus moveri. Ille bibendi meque.	rei.Gsmy1jgApMLMj@sintmundis.org	Mia Miller	e.Gxz0DR2YRm3m71
79252	Ne has medice in actionibus, meae optare aliquod frangat. Mediatorem solo ne et vanitatis at tum.	tutor.ONhAu72Arm3mP@tamenmei.org	Joseph Johnson	erro.W4hAVP2Yp69mRU
79254	Dici loco mittere sub. Super nolo. Tremore grex capiar ibi tangendo, insaniam auras odores. Ac stet contremunt eris a. Eloquia contemnere regina res putem, pati diu significantur. Inexcusabiles duxi das deceptum si alta. Ergone faciunt e cibus. Poterunt pulchra piam claudicans corruptione, domi quos. Fit das canem.	laudatur.sVCAVp40pm9Hr@totquas.com	William Jackson	audiunt.x1F017gAJZ9hRV
79255	Omni. Te tu est eodem volunt. Te videt angelos. Secreti minusve in sedem quadam mea. Laetus an pro confitentem ab me ubi nequeunt. Si quibusve eo da aliter malo fornax. Defluximus una approbavi.	naturae.k5501PgBRzKzR@abigoneque.org	Charlotte Harris	nocte.K5fY17N0pZ3MR1
79257	Numquid huc me te tui corones potuere redemit, posside.	eunt.E7tY1RGarm3Zr@dulcetuum.net	William Taylor	fuero.ojSbvPNbJ63mj1
79258	Se eant servi suavi tot. Olet illis ne dulcis cor caro sine. Vel e ait.	vident.7pw0dJ20Pm96J@nuntiosgressum.com	Joseph Harris	inruebam.7PqadPnaPM9H7d
79260	Utrumque praeteritorum hi plena, pro quoquo obtentu, qui clauditur. Deum iste ut. Diebus quis mei. Ad sim excogitanda agitis eam, adducor videbat, re grave. Obumbret tacet illis tuorum, muta. Remotiora grave itaque fuerimus conspectu respiciens, res ad nesciebam.	fiat.L8Q01r4A7HlZr@lataelati.net	Joseph Williams	quos.k8Ead74bjZ3HRd
79261	Faciat fecisti fuisse. Re meum ex sinu fabricasti miseriae res. Ne facie. Rationes. Falsissime casto oraremus vos vi hac lenia tu, fugiamus.	omnibus.dGWbV7GyjzKzJ@infaciens.org	Zoey Martinez	credita.1GOYD7najzKH71
79263	Lucentem eo violari ullo rei. Influxit alis temptandi.	hi.FC0Y1R20J6l67@ipsaquees.org	Olivia Thompson	dare.5C0yVrGBRM3hrV
79264	Noe dei miris ex eris faciant. Sed cavis poscuntur quare. Manna post e immo ab ait vero, si.	fames.UB00v7nBR69H7@eantfuerunt.org	Emma Martinez	stet.uab0vP4yRzlHR1
79266	Post ei id via curo tunc hos. Sedet aerumnosum si. Posse. Mea vos ea qua. Spes homines incideram. Hoc eas naturam coniugio alia in.	bestiae.834BdJ2BpM3z7@itaeligam.net	Andrew Johnson	novi.XL2YUR40rz9Mru
79267	Possim terra sum debui, eo. Adprobandi spe manes laetusque utroque obumbret generatimque semel recognoscitur. Tolerari deo pius desiderans. Sub recognoscimus ea ac iam. Voluntas virtus et immortalis ingerantur. Sentio audivi sit fueris, licet, ei eas habiti. Mali tum agro tanto voluptaria resisto.	a.Ze2y174A7zLzr@triasalute.org	Anthony Davis	finis.6qNYvp4BjzKz7v
79269	Ideo ea manu abundabimus ab, celeritate. Et si occurro. Ea colores si tolerat ait infirmior. Vox ob testis sonum die. Tuo ceteros ob ullis praetoria formas. Vis. Mea absit amasti conferunt hi una cogeremur.	es.Ehp41P4YpZlmj@aliavidens.com	Elizabeth Thomas	melius.eM74v72bJ63zrV
79270	Ventris absunt bene tui neminem vicit seu hi quoque. Et dei quas me desiderium meos socias rerum. E aures respondeat lux. Vae.	ea.MXRNV7nyr6lmP@afficitpropria.net	Charlotte Jones	haurimus.Ztp4VP2A76kHrD
79272	Cuius fortius cui deum mortalitatis e affectu servis. Oculus. Id hi sive an repetamus qua. Quot fructus subsidium os curiosa, amaris. Capiamur sinu tui tota multos ei os. Locum de ac os ea, adprobandi.	spargant.w1UnUR4yp6kZp@tuaenuntios.net	Charlotte Jackson	re.euU41PNarh9hR1
79273	Dulce amo audiunt. Bona sacerdos hoc fias ob itidem. Una viva tam e, olet. Texisti. Recognoscitur praesentior. Nondum eas vasis. Neglecta os res a.	agnosco.9CU41PGY7696j@deimprimi.net	Anthony Miller	salvi.KiDN1720RZlzJU
79275	Doce venit quis da sentientem alienorum imaginem. Dicatur audiuntur ob sit. Das sinu pars cur cur die manducandi. Aer filiis quandam indigentiae aliae dexteram psalmi eos. Raptae e est.	thesaurus.apMGDRg07z3Zj@pretiumfilum.com	Mia Johnson	places.apZ4dr4bPH36PV
79276	Ore eliqua aut his. Tu speciem ut id capacitas factus da cogitari. Ut inruentes. Hoc. Vae de curiositas solebat ipse quaedam. Neminem cogo totum. Totius. Odores sinus vegetas. Texisti fleo humilibus voluptate veluti ob.	gressum.59H2uR4AjZ3hJ@oleatescas.net	Benjamin Thompson	nuda.Ikm2urg0Rz3ZJV
79278	Uterque es habet sentiens, conectitur solo. Sed hinc viam. Absunt via amaremus sedet a dum sui. Saepius ob transfigurans fratres, me.	e.gGm2V740rZ3M7@durumoculum.com	Mia Miller	tertium.G4Zg1R4aR6LM7v
79279	Interius in ea ex, non suavia. Meo lux inspirationis aetate ad.	abs.5ZKgUR2AP69MR@dielux.net	David Martin	reddatur.IMKnVP20pHkhRD
79281	O interfui viventis ea, meminimus essent tobis en. Usui cantarentur pars canoris mare. Inruentibus timeri e graeca ille inpiorum se, iste. Delectarentur futuri inpiorum creaturam gaudiis. Super ad cum elati, de sub. Ei mediatorem regina o evellas recondi en sensu. Teneat recognoscimus spe fide, videat iube. Alienam macula.	cernimus.r432upNArHKmP@unumquos.org	Aubrey Martinez	e.P232V74YJ69hPV
79282	Displiceo assequitur aboleatur alios praeteritam horrendum.	es.S1Ig1J20RmlMj@tamgeritur.net	James White	positus.xvFgUP4armKZRu
79284	O. Ne ut geritur eis, a.	ambulent.jb54u7407h9h7@obse.org	Anthony Martinez	aqua.7aCg1P4yRH9HR1
79285	Se. Loca esca. Euge liliorum tam potuere en caro, piam. Sed tamenetsi lux en curare praeteritae, olet corruptione. Numeramus o quaerere auri. Cepit has nos sero perturbatione. Temptationum frequentatur. Eos quodam absorbuit. Proferrem mallem ad et eis ad.	spem.Br841JN07m3ZJ@sanctaemoveat.com	Sophia Miller	a.AJTNVJNbRmkZJd
79287	Mei. Percussisti dona. Vel vix quantulum deo. Servis civium corpus amo ago qui lenia, hi. Elian. Exultatione. Euge per amo cum fames. Malim tota.	vox.VwSg1PN0r6k6p@antelata.net	Charlotte Williams	se.vQT2Drgb76lzru
79288	Maris hac tu dicit ac. Recognovi. Respondes ore ingressus inpinguandum resolvisti.	tamenetsi.YnS2Dpg07Z3Z7@huiccoepta.com	Sofia Miller	a.BGX2Vr2A7zLZ71
79290	Avertit eam amo sapit os. Nostrique me sua captus plenariam contra nutu. Mortem sic aromatum scio rogantem inhiant. Seu ventos sum moderationi corde. De parum. Usui meis ac vox es has ego vis leges.	eis.DsWGDP2Br69mp@ibiduxi.com	Alexander Harris	locutus.vxoN1jnbjmLMRv
79291	Detruncata malo invenisse illuc canora pecco ea det dura. Cur eripe dixit resistis. Aliae. Qua ab facit magnifico offeratur.	a.2Bq21PNyPhLhp@pacemmodo.net	Benjamin Martin	e.nAe2U720RhKZP1
79293	De ipsas deliciosas cavernis quas. Lege est. Et eos vita rogo, fit. Vim qui. Invectarum eris videtur. Iesus ne secreta vox me condit eo eam os.	cogitetur.650nvP4YRZkm7@adparetcui.com	David Garcia	fraternis.6f0N1r4aR6lhrv
79294	Si dei. Nemo etiam elian pro se es. Vi tua. Amo cui dulcedinem pietatis, resistit calciamentis altius vim. Ut.	inplicans.J0AnDJNYjhlzr@praeterdiem.org	Ella Anderson	affectent.p0YGDr4y7zLZ71
79296	Quamvis in nesciebam eo se scio de. Se sint sitis e fames sua. Consensio appetam oblivionis malo en laudor necesse.	earum.cLgnuJ40RM9hj@nudaob.net	Matthew Davis	saucio.5942UPnBjZ36P1
79297	Poenaliter conmixta iam. Dispulerim nolunt.	suspirent.1O4guj20rz3HR@speransme.net	Aiden Harris	aures.ue421j2bRZkZ71
79299	Captans an eum quo cogito temporis. Inmemor e nuda bonorumque fine per ei. Id praecidere ad. Sat auget timore mea sit somnis nimia, gaudere.	officium.c6pJMr40jHLz7@audireex.com	David White	superbi.cHRpZjGBJM96pu
79300	Abiciendum vi dum tenuissimas. Mavult amem totum. O imnagines eam tuam quibusdam ad mediator ut una. At unus habes victoriam inperturbata cogenda vel vel, petam. Praeibat quod sacrifico nollem humanus cogit mansuefecisti. Qui sacrificium aer deo, ecclesia os cessatione verae tetigi. Carent gressum cor da prosperitatis. Facit en gustandi visione via facere, futurae. Pusillus an lapidem lux prodigia caput delectatus conforta.	ulla.utr7Z7NY7m3M7@amaturtu.org	Aiden Thomas	gratiam.d87r674Ajm9z7D
79302	Urunt sat dixi loquens, splendorem. Veritas. Facie illi re frangat ne inveni valeo. Credunt suppetat oculi os deo auras fui. Hymnum intonas suffragatio sat quanti, lustravi. E se retenta si vim, es scirem occupantur. Re tale filio an eo. Indica o utcumque canitur magisque ad tot etsi. Tu.	corpora.xDDJ6Rgbj63Mr@silentedum.com	Daniel Johnson	conor.T1DpMrnaRZ9zpU
79303	Auris gemitus. Cor ab eras grex regio. Sua remotiora ac noe ac. Casu suo supra et sunt, an. Ille adesset habet munerum. Naturam per.	e.6f1JmPGyjmkMj@oscuncta.org	Mia White	e.HIDRhPn0RHKzpu
79305	Exclamaverunt fama ex. Gaudeam coepisti necessitas mundis venit. Capiar ne nota. Redigens loco latissimos cogo quaeram te cito da, fui.	ipsaque.EPHJm74bjZlzR@subde.org	Noah Thompson	eo.e7h7MPG0J69Hj1
79306	Intellegentis ei curam gaudentes a, suis, ulla dixeris fortius. Eorum iudex multi desperarem desideraris e.	privatio.6LmRh7NAph36r@tuusubi.org	Aiden Martin	et.m3M76J4YP6K67d
79308	Assumuntur ventrem sic odorem alter ne de. Commendatum oleum es se, iudicet.	niteat.og67Z7NY7H9hj@dixithabes.com	Elizabeth Jones	a.WG6j6JGB7H3H7u
79309	Praeciperet operum inpinguandum illud e iubes ita.	tuas.KZ97mr4Ajhl67@veraxaditum.net	Benjamin Taylor	mirandum.3Z376P2BRzLHP1
79310	Audeo. Manu colorum hi imples interrogatio. Os decet contremunt sed nimirum. Dedisti vim cogitari quando aut oderunt, nam posse. Hi praeire sed sono in. Tua. Mirari respuitur nam ob sit ex qua.	a.u83PmR407zKZJ6@hincsedet.com	Mia Williams	a.VTk7z7Nbjm9mP3
79311	Satago est vos difficultatis admoniti deo amo, in. Innotescunt pleno nares hymnus mei fletur eant capio sibimet. Ei relaxatione ob. Fallit placeam vix moderatum det. Cadunt id os viderunt. Grex. Ac sic thesauri propitius.	vanitatis.tHFrHRGyJZk6J@suntflexu.org	Joseph Harris	ei.o29JHp20RMkhp1
79312	Eunt timore dicat miracula percepta. Lata sequi bibo mali id fuerit amo abundabimus. Hic amet oraremus admoneas ut ab, permanens dico. Sequi se os solo. Venit inruentes aer ore retinetur, ante illa.	a.FqcP6jnB7mKM7@usumeo.org	Elijah Miller	latere.fQIRMP4Bj6kMJd
79313	Бездельник третьего разряда 😋	fornax.nmtR6P4aRh3zj@cogoet.net	Маркиз О-де-Колóн	praetende.NmXP6jNBrZ3zpV
79314	Amor dei posita ex. Canora pretium clamore tot plangendae filum acceptam en vae. Re tua audeo nullam ita gratiae suis.	fac.TOSR6Pn0rM9m7@tacetsumus.net	Emma Taylor	deus.8OSJhP2bRhKHpv
79315	Sed ei me eas.	escae.91Er6pgbP69h7@indeserviam.org	Mason Harris	en.l1ejmJG0rmlH71
79316	En illum locum disputare saucio aperit gaudeam, hi nominis. Porto meis hac malo ex. Meretur invectarum nullo ubi, canenti. Sanctis muta suspensus. Olet id. Ut resistis colligo coniunctam assequitur. Desiderem vox ideo quarum.	ex.5JM9Zg2Ap6k6r@cadereab.net	Emma Brown	alta.IPMK622bJHkZju
79317	Possidere deo beata iumenti fac viam. Praecedentium piam. Comes tibi vi posco. Sui ut vitae.	aut.BVelmn2a769hP@sicur.com	Emma Davis	ea.avW9Zn4Ypz3mrV
79318	Aenigmate nonne et lapsus, tenebant os cedendo, benedicitur.	clauditur.xSW9z2NbR6KhP@hiesca.com	Mia Harris	mendacio.8So3ZgG0P63hju
79320	A circumstant noe ieiuniis re vim pauper. Os habere nigrum. Novum distinguere ubi ista munere meis. Volunt e abstinentia strepitu refrenare. Id te. Ait fuerit elati at se manu.	sonus.Zp49624A7ZKH7@nesciatnec.net	James Garcia	ut.mRGkHNgarMLZr1
79321	Antepono agnovi. Antiqua probet intravi. Corruptible e dicere continens.	latine.B6n3M22brml6p@vaniasamplius.org	Zoey Garcia	liliorum.b6N9M22aPz967D
79323	O hierusalem. Omnia ut. Mystice homo ad. Cur cito alii iucundiora naturam o cessavit vi dixi. Iam quod ob quanta spe. Cor sint qua mihi ad, fui careamus.	tu.6NgkzgGBrM3H7@beareste.com	Ethan Jones	tuorum.H243622yjm96JD
79324	Mare iniqua agit evigilet una diu fructum fallacia. Laetatum pusilla ibi lege solo ignorat gaudiis sparsa meum. Vi nonnumquam ipso es responsa ob. Eo vocibus ipsa. Capit plena tantum alta molle fallere nova, obliviscar magnifico. Diu sui tu a. Narium lugens deum hi en peccavit freni.	amicum.2dp5hGgB7M36r@oslenia.org	Avery Wilson	tota.gdrI6NG0PZ36rd
79326	Formosa dicentia solus. Frequentatur me ei pax scribentur. Spectaculis iam accidit diceremus, os doctrinis da hic.	commune.kAjIH4gajH36P@ventosdictis.org	Mason Smith	leguntur.ky7IM22YjzKzpd
79327	Ei pristinum cui. Lux vix merito cur id o viva id vita. Pater appareat seu eo eloquia. Laudis die viam discurro vellent. Eant stet.	infirma.PV1562gBPmlmp@eiqui.net	Andrew Jackson	multos.jDUimnGa7M3Zp1
79329	Carne clamat pater hic. Vasis.	sitio.LeVC62NArzKm7@verbumvident.org	Ella Thompson	ex.LWviHn4BrHLz7v
79330	Quo temptaverunt credita ex. Tot ac tu cum gratia capit quaere est supplicii. Vi hi subditi eo dei, eras veris. Dicam conscius ait nescio, apud, et docuisti captans. Molestias filios ei sum. Discernebat incertum usum ea. Deserens nuda pax placentes. Vita constrictione pati adest, vel loqueretur. Deinde et contrahit volo, eis cotidie.	ferre.r7HiMGg0pmL6R@expertaviva.net	Aubrey Moore	tibi.jpZ5m2GB7ZLHPu
79332	Ut de quamvis amat fleo ullis nondum re calciamentis. Indicat laudis fiat ex stat. Distincte sim misera quia flabiles aliis sic.	ibi.fS6iH2gBpHl6R@tertiofirma.org	Addison Brown	augeret.CtmfZ4g07Z96rd
79333	Ambulent ab inimicus per nisi si tu, hi. Si a deo ac bellum. Est ea huc praebens eventa. Nobis reccido malorum ponendi dona dona da os incertum. Mel ait.	alioquin.d465ZGGyjZK6J@sitheatra.com	Daniel Martin	subduntur.U4z5M240rMKzJd
79335	Tale at iucundiora oleat, ait gaudent. Nepotibus. Diei.	fundum.c5KF6N2yJZKMp@quaerites.org	Aubrey Smith	e.c59F6g2AJZ9mPd
79336	Tam visionum fama meae. Gustatae interiusque. Nati da his es experimentum toto vide ita, sectatur. Recoleretur ebriosus exemplo audire huc vox, bibendo.	suis.1a3CmgnARHLZ7@inaves.org	Lily Robinson	se.1Y95HgGyJH96ju
79378	Ei fores vi severitate o diutius. Praesentia vim volebant. Vim erogo faciens. Recordarer vidi quas campis necessarium. Lumen illam dormienti cibum.	transit.PT4sZG4BRmLMj@hasiumenti.com	Lily Taylor	velint.JX2ThN20JM96jd
79338	Factum dextera suo lateat. Quam illuc fudi illico at. Leges animi e cura, vim a auribus. Aenigmate. Corporalis actiones ulterius nutu, ego sui. De. Tuos an assunt vanae qualibus id mutare.	graventur.XkFFzg20JMKhJ@quaedamhaec.net	Sofia Williams	videam.S3cChG2bj63Mpd
79339	Desideravit sciri et audiuntur. Rapiunt sequi spectandum cetera omni copiosae huc ex dixit. Traiecta molestiam doce cantilenarum diu canora lingua. Cui fit fabricasti ut o libet, alia. Conspectum reficiatur abundantiore eo omnia de. Venio nam interpellante transire intentioni sui ergo. Potest difficultates tunc diversitate, liquide.	o.3ocih4nAjh96J@transeohae.com	Madison Moore	erro.LQFih44ArMK67u
79341	Evigilantes refugio rem cor, prius. Se ut elapsum. Vi inpressas meus. Quot displiceant ita. Sonum. Ei. Deo nostrum a tui vituperari. Auri es me possim mei, inpressas invisibiles haeream.	occurrat.WZsFHG4brz9zj@verusinlusio.org	Anthony Smith	quaeque.q6X5ZgNB7636r1
79342	Tu tremorem adsit vi delectat, cupio huc ei vox. Iugo memoriae duxi alter re utrique an, vix. Drachmam.	en.IxxcH24BJ6LZr@guttureinvenio.com	Joseph Harris	gratias.ixtfmG2B7ZK6jV
79344	Inlexit sibi olefac. Quia occulto denuo se id sensus vel audis eum. Noscendique ad diu. Da eam inveni defenditur nescirem una sectantur tu. Dignaris gutture inesse bellum pulchritudine molestias.	leges.w1oFm4nbrm3mr@utpossem.net	James Robinson	colorum.EDqCz4nYRh3zRd
79345	Sapientiae hos olet miseria a falsum. Transibo iam cui nostros, vivente fui suggestionum dormies res.	istam.5foCZGN0jmkZr@medicusnimirum.net	Ella Davis	servi.fCwFZ420r636Jd
79347	Ponere violis iacto si tua salus illis. Mea meo excusatio id delectatus mel. Coram ob suo relinquentes attigi a. Promisisti pro ob quemadmodum adsunt o. Lenticulae captus rem nidosve deinde, vellemus has cur at. Diebus. Minister ut colorum defluximus, ne, te. Florum pulchritudine firma vere.	mirabilia.yRAc642bjHlzj@fieretut.com	Ethan Williams	fit.bRbch2nY7hl6pU
79348	Aeris intraverunt affectionum hoc en id continebat numeramus, mortaliter. Sitio. Captus. Fudi re inmortalem antepono luminoso, olet noe plus perdite. Tu agnoscimus sedem. Et. Putem redducet hac vocatur dissimilia novit. Potest mare tale meo hymnum audiunt non.	cavens.x3B5m44aRHL6P@ipsocarnem.net	Sophia Moore	absorpta.8L0Iz2G0p6Lz7d
79350	Vi hos infirmior. Ac tibi sed sub in diei videt id. Hoc inventum tuo nolunt ingesta. Spes fit erit necessarium ore respondes. Das accedimus dura bene quot fundum aequo meo. Recognovi. Has scrutamur me huic deus per imaginatur si, lenia.	cetera.D1N5HN20rzlmj@verusgenere.net	Daniel Moore	ab.1VGfm2G0pZkh7d
79351	Ob pecco etsi grave carthaginem difficultates congesta alis inexcusabiles. Sonare. Solem a homines tuae qua factumque metumve ambitum inmemor. Alia os fuisse quidem sum ago, pepercisti.	potuimus.y9gfMG2Ajhl6R@videantigitur.org	Jacob Wilson	deponamus.bLn56n4Aphl6Rd
79353	Infelix infinita et euge. Se reminiscerer filium nostram ex. Cibo deum pro passionis pertendam id cotidie texisti, vulnera. Pater noe mutant eram tuo. Sicuti oris sibi solis tu, malis visa das israel. Valeo meos abscondo ei scit usui cui.	videmus.HJrxMgn0R6L67@communedicant.org	Aiden Miller	ad.MJRxmn4bPh3Z71
79354	Dona clamasti cito promissio. Silentio o faciei invenirem.	varia.06rX642BR6lzp@eaei.net	Chloe Wilson	mortui.bmrxH4Gy7zkMRD
79356	Colligenda. Odoratus contemnenda tam. Id tota.	ei.64jS644B76k6p@meamodium.com	William Davis	via.mg7sHgN0pM3H71
79357	Prece malo manu. Comes diabolus furens mei liberalibus me, usui quare.	concubitu.guUXZ4n0RH9hp@atinveni.com	Anthony Jones	gaudio.gDusHgGapzl671
79359	Sit abigo violari ut velit vituperetur, obliviscar. Rem grex.	caritatis.fYDXZ24bRzKh7@ingentisurgam.net	Sophia White	ut.fYVXhGGA76LhJD
79360	Quo da silente gaudii pax fit. Interdum cognoscendum canto probet. Ventris nati. Occurrant cura ab pendenda contristor. Procedunt falsi fit cadunt petat in reminiscimur. Noe tu iam invenimus. Fortasse aula quantis infinita mea fui oboritur re.	sero.gr68m24bJmL67@afueritplagas.com	Matthew Smith	vae.G7HSMNGBJz36pu
79362	Tremorem e interstitio inveniebam. Pertinet pro infirmitate talium. Credita curiositatis ac significat. Es occurrerit appetitum plus ab me aut. Meo vi alieno. Simus motus terra ex ruga doces cito moles eligam.	ac.9o6T6g20RZlzp@aliaenovi.org	Mia Martin	o.keZs6G20rH3M7D
79363	Eos mirari. David reperiamus catervas referrem interfui ipse illam recognoscimus obliviscamur. Conexos amo sui. Visa possideri insidiis eis ea meo. Auri hic oboritur.	habito.jj3TZg207zL6p@ventremagit.net	Avery Williams	a.7j9SZ24YrmL6jU
79365	Fortius inmortalem lapidem cogitetur volui, aer. Sat sed. Vides vera se carneo frigidique vi re. Ea his orare eruens. Et mihi an nec e, cui cur misericordiam cui. Hae te abyssus vide desiderem suis, eo surditatem cor. Possit apparet nonnullius id temptationis.	e.iT98Hnnarm367@abshaereo.org	Sofia Harris	e.Ft3xz24yJm9Mru
79366	Interfui es tu sed ulla. Hi fecisti. Oblectandi vix ob mortalitatis invocari. Latina gero laudatorem ei o. Dicunt ambitum omnipotenti agnosco leve, colligimus.	duxi.U4kTm4gyRH9Zp@cortamquam.org	Joseph Jackson	pax.V4L8H4GB7z3HjD
79368	Bona fieri ut leve. Audiat sub qui ita num. Amissum o discendi opus continens munere. Hos vana quanta scit, iam diu. Genera numquid sum ab vix potes, ut sub. Eundem manes adprobandi os eruerentur lectorem inveniret apud. Nonnullius homo inventum mors abs misericordiae. Pro sanare ab ex velle ibi lene et.	quamvis.Tcfxm4ga7M3hR@parvusvidendi.org	Abigail White	contemptu.xCcSH240JZ96pV
79369	Aliis occurrit commendantur firma ut loco deceptum ea misericordiam. In posco solitudinem victoria quibusdam dixi quis numquid. Te.	vox.Ua5s64g0JZlm7@uterqueniteat.net	Joshua Wilson	exemplo.MyIS6G4A76lzJ
79371	Sanum dominos. Velim interiusque metas sapores ingesta, eant e, ob.	amavi.8ksxm4GAJm36J@piaecadere.net	Liam Taylor	auri.XltSM440Pm967V
79372	Respiciens rem delectari ut deerat se audiat sua miseriae. Ob omni. Res inveni sacrificium perit a lux, vi saepe nos. Periculum freni. Vidi dum pro seducam, turibulis casto. Tobis tria cum conexos rogo cupiant dei. Eo inmensa da haereo.	vasis.9Qss6ggy7Z3H7@easi.net	Joseph Moore	tu.kQS8z440JZlZ7D
79374	En te utimur te. Succurrat.	officium.QZe8Z4gbjH9Mp@rationiscierim.com	Daniel Robinson	minus.ozEs6240P6kZrv
79375	Diu latissimos cui. Eos male en. Fletur dei intravi possem es laetus eventa. Contristatur ea. Utrique fecit sero das resisto. Iube noverunt evigilet victor. Donum retinetur vera pars huc ago adhuc. Cohiberi da omnem vi, ac, sacrifico mali dum. Subditi diei inplicaverant bibo se prodeat unus qua artes.	possidere.58Q864gA7m367@amatpopuli.com	Aubrey Moore	ego.f8qs624bJm3zPv
79376	Mea. Reconditae propinquius ipsum modi. Cernimus curo temptatio da facit sint. Tu. Niteat creatorem tu cur.	suam.1GoSh2g07ZkZ7Z@peccodeo.net	Mason Davis	aer.U2q8m2gYr63ZJL
79377	Miserabiliter. Approbet refugio palpa humanus. Id alas dico suo, per, plus notiones. Valent. Ad sit rei spe te illico noe ago quadam. Vitaliter re libeat fieri. Abditioribus ore. O an eo tum membra respuitur de. Facio cui deo re, offeretur ad rem.	distantia.Tx0xMn2AjHLzP@quasi.net	Aubrey Thompson	os.w6Bsz440769H7d
79379	Бездельник третьего разряда 😋	ad.1aJez44aPhlmj@vocatursero.com	Маркиз О-де-Колóн	servis.vbJO6nGb763MjU
79380	Animi tam os iniqua beata. Christus supplicii macula mea, verbis naturam repente si re. Moveat eum mortalitatis. Concubitu gero vi. Alia. Potu de seu eo es, ea amo, thesaurus. Aspero perpetret vae odor nutu. Sperans des sua sine dolorem videam, eo ne.	vana.44UoH24bPH9mJ@aliquodapud.org	Charlotte Brown	da.N4dEm4GyJ6lHrV
79381	Cotidianas corruptione quaerit me vide, ecclesia re has spernat. Infinitum infirmitate ceterarumque rei valida. Videor num tuo necessitas aut, manifestus ego benedicere, si. Minutissimis volens. Amoenos ac veni. Es voluptatibus promisisti deliciosas beatitudinis piam sit e, tua. Sic posside est en, hos fructum ob vasis. Beati alia.	id.ZJ3WH42a7636R@eantad.net	Matthew Johnson	graeci.mpkQz4NaRZlH7v
79382	Rei. Me es.	sancte.nNZ71kV2r6Lz7@locaab.com	Benjamin Brown	a.gn67VkVgRZkMjD
79383	Es. Laboro hos es iudicia caro en transcendi faciat. Sacrificatori capiamur tobis adversitatis amissum concludamus.	mali.DFl7V3v4r63hp@deeritvultu.org	Sofia Moore	quidam.vI3Pdkv47hk6rd
79384	Mortilitate genus da. Solet habeas scierim reliquerim ore. Eripietur hi mole eum. Hae. Modis ne das aer ex aetate subditus occurro. Meus separavit invenisse. Eos noe requirunt vivam.	confitear.GykRD312rM9M7@veniosobrios.com	Daniel Brown	odium.g0Krd9uGR69Hrv
79386	Resisto reprehensum se hi. Per. Proruunt. Violari consequentium capacitas. Quisquis manducandi piam desiderium meo euge dicit. Deo conduntur ruga invoco diu quamquam.	diabolus.M5fRdkv27MKhr@similisvocatur.org	Emily Garcia	rupisti.HCfPu3U2pM9mrU
79387	Videant varia lata at recordor. Aliud tuae nec ecce in invenit vita nunc dabis. Rapiatur a debet rebellis. Te ubi dare colligenda his. Dexteram. Fias sua respuitur. Fit en fecisse fui capior, innumerabiles a, sum lux. Vicit utrubique prodeunt praeteritorum quisquis.	agam.gwc7DKV2rh3Hp@cordavestra.net	Andrew Smith	patriam.gefRUlDgp6lHru
79389	Bonae ad peccatum. Ipsa stelio hic agit. Videor da meminit nam. Generatimque sit. Omnium laudandum nollem vi ad deo ne odor aperit. Rursus ipsaque colligere iam emendicata.	cum.yctru9U4JzlZP@misistiei.org	Abigail Thomas	a.aC8ju3VG7MkHjv
79390	At deinde inde dicis. In mendacio meminerunt filium forte, ibi sonare. Sui mei fine hac si, sic, ne dei.	e.5BS719d27M3HP@graecadas.org	Abigail Harris	enim.FBTj19UnPHK67V
79392	Ut quidem vi se grandis. Num detruncata vana foris homines. Ad recondo hebesco difficultates teque. Dulce det te ista es duobus. Hi regem his suo se peregrinor via iaceat. Ambitiones. Olent horum.	retibus.gLEPDLUnJH9Mr@dulcedomole.com	Madison Garcia	apparens.2lq7d312PZKhRV
79393	Fiat os alio certum, mentitur. Leguntur cogitationis esto his. A sat ore si, cogeremur imples.	mendacio.qWO713DG76LmJ@hicogo.com	Jayden Thomas	novi.OqorvKD2j6kHJd
79395	At id dum negotium, iugo, conterritus.	dicentem.JKBRulD4PM96P@fecisseme.org	Natalie Wilson	ea.7LAR1lU47zKzpV
79396	Piam rem periculo victima animo et si id gemitu. Diceretur tutum id contristor, vix variis noe. Satago recordabor ait os te desiderant, templi. Ubi tu creaturam.	diei.wxApD9u2jh9zr@aliquoeunt.net	Matthew Williams	ubi.QX07V9U4RH36p1
79398	Certa te cognovi dignitatis conceptaculum oraremus animalia vocem. Transitus diverso vi an. Sim amo. Ianuas vi es re. Filio quisque ac enim soli. Da agro unico animam at alium. Deserens requiramus peste eam videam memini redimas.	en.764p19UG769mJ@eointravi.com	Chloe Harris	verax.7m47vl1GP69HP1
79399	Fugasti influxit. Ore nam invisibiles. Seducam lege. Geritur placere assuescunt hi unum a des depereunt suo.	re.0I2juKD47M9zR@deut.org	Emma Davis	mortem.052pu3Vg76Lmjd
79401	Dixit divellit. Consuetudinis perfusus amor mundatior turpibus aut sint. In. Castrorum enim patriam vivit interpellat avertitur eos stilo. Vis teneor cupiditatem ob facit tu hi. O fit divellit quem voce aer sicut. Hierusalem animo furens nos, gemitu. Metas affectum eris das. Approbat datur illa.	da.1vp11LdgjM3Hr@ease.com	Abigail Smith	faciam.D1j1vk147h3zJ1
79402	Ei. Ob salus eo num. Re splendeat cui colorum alienam dei vis ab imaginum.	facta.29PVul1N7zKHp@sicutflumina.com	Natalie Thomas	ab.29j1DlV27m3Z71
79404	Os congesta animales sentitur, quod. Fortitudinem os accende salvus da ad condit ut. Eo amatoribus omnium det abiciam re, dixi factito sectatur. Subdita nec diligit. Si. Hic ipse odoratus auribus excogitanda transfigurans quando contristat. Bona dominos odium nostram.	tot.K7uVDLU2r69zp@meustu.org	Abigail Taylor	o.l7VddKdnRH9Hjv
79405	Ab iste transisse si ullis salus.	meo.jlVVu9UNJh3HP@noevide.net	Alexander Garcia	ad.791dUkd2Rhk67v
79407	Ut usque eam eam oblitumque, fuit lege. Certe mei amo facio ea pondere. Respondi occurrat e cupiditate adamavi per psalterium. Sibi os abs os, da te re. Evelles. Das absorpta conforta. Virtus cogo multique eosdem, cantantem ob abs se. Illa deserens solo bonam lapsus.	agam.9Gd11314JMK6J@hacquo.com	Ethan Martin	nam.k4duu31gr69mPD
79408	Nolle satis sententiis notus ea, curiositas. Ita deus discernere defuissent erant meam. Proferrem ne diu vae. Te et maris spe percipitur ad, lucem petitur audiebam. Volvere quas durum recuperatae diligit diversisque. Vi destruas oblivio ingentibus noscendi en scire spe. Indicat des. Vituperatio utique odore difficultatis tuos olet, ne.	iudicante.JZMv1k1g7m36r@minusveillic.com	Matthew Taylor	o.RhHVu9dgpHkHpD
79410	Optimus custodiant pecco quo. Auram nec gratiae respondes. Sonuerit sed pati at. Ambulasti libro os beati ego.	meo.IYmUVLVG7h36r@fieriinest.org	Joseph Thomas	superbam.iBHV1ldGPM9zRD
79411	Iube humanus possint unico est loco. Hoc. Cor nos gemitus mei grandis plus mei spem. Fidem. O diligi me nosse e. Debet servi vitam artibus sonet. Memini eo habitare ipse, id naturam parva non. Affectio.	vanitatem.VVld1ld47M3m7@quaerotempore.org	David Miller	tutiusque.1dK1D31g7M96pU
79413	Hac quo de esse cur innotescunt fallar percepta evigilet. Eum abs contristari. Huc si re transitu ac hic alteri capiuntur. Stat e re eo abs, et moderationi ex, silva.	fudi.xWLdu9U2PM3ZJ@factostimeri.com	Zoey Moore	e.TO9UDL147hl6j1
79414	Quem sub abs. Mirantur nollem os te decernam en, praesignata. Se ascendam non aquilone tu sensum terram edendo hi. Gloriatur potuero appetitum aures. Pati donec carne.	ab.Hrf1VKD4jHKmp@speciemfac.net	Isabella Moore	si.6JIuV914p63m7d
79416	Aliud olet at alia, secreti. Sim cor an doleam tristitia. Ac credendum sic crapula, verbis agam fecisti.	hoc.tSCdDk14pmLhj@gaudiodei.net	Chloe Miller	ex.ttCu13D27MLZj1
79417	Sententiis. Os tuis posco a. Tam habito loquebar insinuat se mei id. Quousque conor aderat id manus.	dicat.MG5vDLu47H9hr@regemei.com	Zoey Anderson	eodem.h25V1Ku2jh9MPv
79419	Respondeat mirifica reminiscimur. Reminiscerer laetatus hae ingerantur cibo. Filiis dura in. Ego mel nolle. Si. Te spiritus spe. Iam eas caritas.	satietate.eftu19d2jMkh7@vivamalim.net	Mason Moore	imaginem.Oixuu9D47mlmp1
79420	Res fit cadere lucustis cur beatus da resistis. Vos fit consulens ubi, recondens. A sat campos quas parvus, e currentem nos omnibus. Lux avide ab an num. Trium meum vi et colligo ad et invectarum dignaris. Cum tot odoratus tui lucentem aboleatur. Ei os frangat sedentem lux nolo dolores. Laqueo locutus famulatum cogo ad dubitant. Fuisse ita ac sit discrevisse scit tenebant se pulchritudo.	possit.3ys1U9vNPM9M7@aerplaces.net	Isabella Wilson	a.LYsV19UN7mKMpv
79422	Vae minuit ad te ab det convertit. Significantur es cum ambitum tum propter, die. Da ne. Accende. Quare primo edunt.	interest.a9wvV3V4ph9zp@idoneusres.net	David Jones	modi.A3oUd31NrH96PV
79423	Oblitus fide dicat. Ante vel hoc hi eas solus, imprimi statim o.	a.5EE11KDN7m3hJ@potudici.net	Ella Martin	nota.5Wwd1LdNpM96JD
79425	Vituperari eum durum exultatione. Silva. Praestat.	sicuti.bzb1d3DNj6Lzp@remvae.com	David Williams	e.AH01VLU2jML6jV
79426	Me. Minor vera. Illos vita non an aditum. Ego doctrinis hic affectus inlustratori os perturbatione, at afuerit. Nos ex alas.	e.XSyUuK1N7Z36R@tulonge.com	Joseph Jones	doleamus.x8ydvlU4RzLMjV
79428	Locus audi abs. De eo ore. Sat corpore. Vestra te rideat iam, ex manu possidere. Transeo inspirationis cognoscam a meum mea, cor meretur. Beatos es viderem radios si. Sacerdos aer intendimus. Hoc praeciditur praestat dei suam pertendam casu, si deinde. Conceptaculum concupiscit inde dicebam de, convertit.	vocem.41gV19d2PMLm7@ibigaudio.com	Charlotte Miller	fames.g1nuUKDn7hkHpv
79429	Sicut videam thesaurus. Deserens pulchritudo animus at os me si confessione agenti. Deputabimus vere ne fructum, quid pro primitus, candorem rem.	suavia.QiGUUKU4Jm9ZR@itavocasti.com	Abigail Smith	retinuit.WInvD3VN7HKM7d
79431	Redire mea ea captans e oleat, nec tibi. Mei caecis visco. Sanum vi. Id diligit a mea ipsi es dixeris utilitate nunc. Per contrario veritas ne album videtur. Das. Conmoniti det eam illud extingueris dinoscens.	capio.rvpzD9V2jMlhR@tumistis.org	Elijah Jackson	antiqua.rDpZ19v2RZ9MPV
79432	Misericordiam carnem eos doces. Ruga en occulto meam, amare, permanentes. Foeda vos. Praeibat esse reddatur. Spe. De anima neminem nam. Det.	parte.Q9phvK12pz3ZR@alteriac.com	Andrew Taylor	retribuet.Q3rHv3U47z3zRv
79434	Ubi an mallem contendunt sub.	dura.h7dhd312JMkMp@etscit.com	Michael Johnson	o.hJ1Zv9D2P63z7v
79435	Unde. Tu os fletur. Nati pergo domino pars. Liberasti sine de creditarum vindicavit ubi. Sicubi beatam speculum melos munerum, mirum variando. Vim. De quae daviticum da, verae temptari os cur cupiditate. Tradidisti ut. Vivit circo das sat hic ait.	desidero.BHUmvK1g7HlZP@meosuae.net	Natalie Thomas	gaudium.bzuzdLD4r6LH7V
79437	Prospera. Sed heremo nutu quidquid an, in, aboleatur. Vox ob qualis essem adquiescat. Tecum a exteriora. Rem a discernens meus adsuefacta. Ac det os rei at in quo. Intellegentis vere.	quandam.Z4vZ1l1NjMkZr@quofateor.com	Olivia Williams	occulto.H2VZ1lDG7mKz7u
79438	Ingemescentem. Retrusa. Sim en laqueo molestiam aer similitudinem da. Autem confortat praedicans relinquunt at diiudico abundantiore loquendo. Saturari dissimile vivarum mutant. Esau. Desiderata noe magni pax os dominus.	mirabilia.GVZ6dL12RmK6J@eaac.org	Lily Brown	cum.2u6zUL12Jm9Zp1
79440	Corpus per. Per aspectui pietatis ut, infirmitati infligi hac. Moles furens.	solem.my6m1912rZkzR@teneamdixit.com	Charlotte Thomas	laetusque.Z0m61LD4pzlmjd
79441	Cogitare cupio. Ab alias sua. Utique. Amo hinc praeteritorum eras eam. Sub dare me maerore re ea. Tenuissimas ei vita relinquentes, sit, en. Muta.	a.GrKHuL127H3HP@teperdite.org	Emily Martin	lunam.Gp9mdkD4jzLM7U
79442	Eis quoquo eloquiorum tetigi. Velim dare se retinemus. Se via amplexibus careo e, retarder sic. Peccare aestimantur potens indidem teneo cor me. Extrinsecus. Nam lapsus at auget condit temptationes id vide. Sua es gero. Ubi ut.	sudoris.s3Lm13u276L6rZ@pulvisiaceat.org	Natalie Wilson	meorum.89361ku4JM3Zr3
79443	Vel nolle oblitumque servientes, cogenda apparet. Miseratione quomodo rapiunt retenta mulus tui. Ea eloquio. Nati es ullo de me plus contractando. Gemitu sanctis saepius gaudens. Diei ut.	pervenire.V1iz19dGPmlZ7@hanctum.com	Chloe Thomas	subsidium.CBKZVk1GJZKz7U
79444	Suggeruntur ego. Alexandrino diu sit tibi resolvisti istas. Cui peccare. Amor fortitudinem. Quaerentes respondeat vide ista aula tenent isti.	dignatus.yFiZ19d2pm9m7@bonisdocens.net	Charlotte Brown	utrique.0556DLd4J69hru
79445	Бездельник третьего разряда 😋	mala.91sZd3d4rz36P@amorita.net	Маркиз О-де-Колóн	num.91t6VKVGPzlMp1
79446	Vae. Num tobis.	sumpturus.U88hu9UN7m3M7@auresdomi.org	Anthony Jackson	superbiae.DXxm1k1Gj636r1
79447	Casu veluti quo inventor, quem re illum. Meum mel e meus, tui fuimus. Prospera aerumnosum dei furens, diverso ob angelum tuos ea. Ecce toto re adamavi egerim. Tuo interpellat custodis. Requiro sat eligam habito ago. Consulentibus impressum metas.	de.bNSmD9V27z967@necfaciet.net	Isabella Wilson	fac.BnTzdL12Pz3mju
\.


--
-- Data for Name: Votes; Type: TABLE DATA; Schema: public; Owner: maxim
--

COPY public."Votes" (id, voice, "thread-id", "user-id") FROM stdin;
\.


--
-- Name: Forum_id_seq; Type: SEQUENCE SET; Schema: public; Owner: maxim
--

SELECT pg_catalog.setval('public."Forum_id_seq"', 16901, true);


--
-- Name: Post_id_seq; Type: SEQUENCE SET; Schema: public; Owner: maxim
--

SELECT pg_catalog.setval('public."Post_id_seq"', 11937998, true);


--
-- Name: Thread_id_seq; Type: SEQUENCE SET; Schema: public; Owner: maxim
--

SELECT pg_catalog.setval('public."Thread_id_seq"', 185396, true);


--
-- Name: Users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: maxim
--

SELECT pg_catalog.setval('public."Users_id_seq"', 79447, true);


--
-- Name: Votes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: maxim
--

SELECT pg_catalog.setval('public."Votes_id_seq"', 1524761, true);


--
-- Name: Forums Forum_pkey; Type: CONSTRAINT; Schema: public; Owner: maxim
--

ALTER TABLE ONLY public."Forums"
    ADD CONSTRAINT "Forum_pkey" PRIMARY KEY (id);


--
-- Name: Posts Post_pkey; Type: CONSTRAINT; Schema: public; Owner: maxim
--

ALTER TABLE ONLY public."Posts"
    ADD CONSTRAINT "Post_pkey" PRIMARY KEY (id);


--
-- Name: Threads Thread_pkey; Type: CONSTRAINT; Schema: public; Owner: maxim
--

ALTER TABLE ONLY public."Threads"
    ADD CONSTRAINT "Thread_pkey" PRIMARY KEY (id);


--
-- Name: Users Users_pkey; Type: CONSTRAINT; Schema: public; Owner: maxim
--

ALTER TABLE ONLY public."Users"
    ADD CONSTRAINT "Users_pkey" PRIMARY KEY (id);


--
-- Name: Votes Votes_pkey; Type: CONSTRAINT; Schema: public; Owner: maxim
--

ALTER TABLE ONLY public."Votes"
    ADD CONSTRAINT "Votes_pkey" PRIMARY KEY (id);


--
-- Name: Forums unique_Forum_id; Type: CONSTRAINT; Schema: public; Owner: maxim
--

ALTER TABLE ONLY public."Forums"
    ADD CONSTRAINT "unique_Forum_id" UNIQUE (id);


--
-- Name: Posts unique_Post_id; Type: CONSTRAINT; Schema: public; Owner: maxim
--

ALTER TABLE ONLY public."Posts"
    ADD CONSTRAINT "unique_Post_id" UNIQUE (id);


--
-- Name: Threads unique_Thread_id; Type: CONSTRAINT; Schema: public; Owner: maxim
--

ALTER TABLE ONLY public."Threads"
    ADD CONSTRAINT "unique_Thread_id" UNIQUE (id);


--
-- Name: Users unique_Users_id; Type: CONSTRAINT; Schema: public; Owner: maxim
--

ALTER TABLE ONLY public."Users"
    ADD CONSTRAINT "unique_Users_id" UNIQUE (id);


--
-- Name: Votes unique_Votes_id; Type: CONSTRAINT; Schema: public; Owner: maxim
--

ALTER TABLE ONLY public."Votes"
    ADD CONSTRAINT "unique_Votes_id" UNIQUE (id);


--
-- Name: Votes unique_Votes_user_thread_pair; Type: CONSTRAINT; Schema: public; Owner: maxim
--

ALTER TABLE ONLY public."Votes"
    ADD CONSTRAINT "unique_Votes_user_thread_pair" UNIQUE ("thread-id", "user-id");


--
-- Name: idx_forum_ci_slug; Type: INDEX; Schema: public; Owner: maxim
--

CREATE UNIQUE INDEX idx_forum_ci_slug ON public."Forums" USING btree (lower((slug)::text));


--
-- Name: idx_post_author_id; Type: INDEX; Schema: public; Owner: maxim
--

CREATE INDEX idx_post_author_id ON public."Posts" USING btree ("author-id");


--
-- Name: idx_post_forum_id; Type: INDEX; Schema: public; Owner: maxim
--

CREATE INDEX idx_post_forum_id ON public."Posts" USING btree ("forum-id");


--
-- Name: idx_post_path; Type: INDEX; Schema: public; Owner: maxim
--

CREATE INDEX idx_post_path ON public."Posts" USING btree (path);


--
-- Name: idx_post_thread_id; Type: INDEX; Schema: public; Owner: maxim
--

CREATE INDEX idx_post_thread_id ON public."Posts" USING btree ("thread-id");


--
-- Name: idx_thread_author_id; Type: INDEX; Schema: public; Owner: maxim
--

CREATE INDEX idx_thread_author_id ON public."Threads" USING btree ("author-id");


--
-- Name: idx_thread_ci_slug; Type: INDEX; Schema: public; Owner: maxim
--

CREATE UNIQUE INDEX idx_thread_ci_slug ON public."Threads" USING btree (lower((slug)::text)) WHERE ((slug)::text <> ''::text);


--
-- Name: idx_thread_created; Type: INDEX; Schema: public; Owner: maxim
--

CREATE INDEX idx_thread_created ON public."Threads" USING btree (created);


--
-- Name: idx_thread_forum_id; Type: INDEX; Schema: public; Owner: maxim
--

CREATE INDEX idx_thread_forum_id ON public."Threads" USING btree ("forum-id");


--
-- Name: idx_user_email; Type: INDEX; Schema: public; Owner: maxim
--

CREATE UNIQUE INDEX idx_user_email ON public."Users" USING btree (lower((email)::text));


--
-- Name: idx_user_nickname; Type: INDEX; Schema: public; Owner: maxim
--

CREATE UNIQUE INDEX idx_user_nickname ON public."Users" USING btree (lower((nickname)::text));


--
-- Name: idx_vote_thread_id; Type: INDEX; Schema: public; Owner: maxim
--

CREATE INDEX idx_vote_thread_id ON public."Votes" USING btree ("thread-id");


--
-- Name: idx_vote_user_id; Type: INDEX; Schema: public; Owner: maxim
--

CREATE INDEX idx_vote_user_id ON public."Votes" USING btree ("user-id");


--
-- Name: Posts trg_add_post_to_forum; Type: TRIGGER; Schema: public; Owner: maxim
--

CREATE TRIGGER trg_add_post_to_forum AFTER INSERT ON public."Posts" FOR EACH ROW EXECUTE PROCEDURE public.func_add_post_to_forum();


--
-- Name: Threads trg_add_thread_to_forum; Type: TRIGGER; Schema: public; Owner: maxim
--

CREATE TRIGGER trg_add_thread_to_forum AFTER INSERT ON public."Threads" FOR EACH ROW EXECUTE PROCEDURE public.func_add_thread_to_forum();


--
-- Name: Votes trg_add_vote_to_thread; Type: TRIGGER; Schema: public; Owner: maxim
--

CREATE TRIGGER trg_add_vote_to_thread AFTER INSERT ON public."Votes" FOR EACH ROW EXECUTE PROCEDURE public.func_add_vote_to_thread();


--
-- Name: Posts trg_check_post_before_adding; Type: TRIGGER; Schema: public; Owner: maxim
--

CREATE TRIGGER trg_check_post_before_adding BEFORE INSERT OR UPDATE ON public."Posts" FOR EACH ROW EXECUTE PROCEDURE public.func_check_post_before_adding();


--
-- Name: Posts trg_convert_post_parent_zero_into_null; Type: TRIGGER; Schema: public; Owner: maxim
--

CREATE TRIGGER trg_convert_post_parent_zero_into_null BEFORE INSERT OR UPDATE ON public."Posts" FOR EACH ROW EXECUTE PROCEDURE public.func_convert_post_parent_zero_into_null();


--
-- Name: Threads trg_delete thread_from_forum; Type: TRIGGER; Schema: public; Owner: maxim
--

CREATE TRIGGER "trg_delete thread_from_forum" AFTER DELETE ON public."Threads" FOR EACH ROW EXECUTE PROCEDURE public.func_delete_thread_from_forum();


--
-- Name: Posts trg_delete_post_from_forum; Type: TRIGGER; Schema: public; Owner: maxim
--

CREATE TRIGGER trg_delete_post_from_forum BEFORE DELETE ON public."Posts" FOR EACH ROW EXECUTE PROCEDURE public.func_delete_post_from_forum();


--
-- Name: Votes trg_delete_vote_from_thread; Type: TRIGGER; Schema: public; Owner: maxim
--

CREATE TRIGGER trg_delete_vote_from_thread AFTER DELETE ON public."Votes" FOR EACH ROW EXECUTE PROCEDURE public.func_delete_vote_from_thread();


--
-- Name: Posts trg_edit_post; Type: TRIGGER; Schema: public; Owner: maxim
--

CREATE TRIGGER trg_edit_post BEFORE UPDATE ON public."Posts" FOR EACH ROW EXECUTE PROCEDURE public.func_edit_post();


--
-- Name: Posts trg_make_post_path; Type: TRIGGER; Schema: public; Owner: maxim
--

CREATE TRIGGER trg_make_post_path BEFORE INSERT ON public."Posts" FOR EACH ROW EXECUTE PROCEDURE public.func_make_path_for_post();


--
-- Name: Votes trg_update_vote; Type: TRIGGER; Schema: public; Owner: maxim
--

CREATE TRIGGER trg_update_vote AFTER UPDATE ON public."Votes" FOR EACH ROW EXECUTE PROCEDURE public.func_update_vote();


--
-- Name: Posts lnk_Forums_Posts; Type: FK CONSTRAINT; Schema: public; Owner: maxim
--

ALTER TABLE ONLY public."Posts"
    ADD CONSTRAINT "lnk_Forums_Posts" FOREIGN KEY ("forum-id") REFERENCES public."Forums"(id) MATCH FULL ON DELETE CASCADE;


--
-- Name: Threads lnk_Forums_Threads; Type: FK CONSTRAINT; Schema: public; Owner: maxim
--

ALTER TABLE ONLY public."Threads"
    ADD CONSTRAINT "lnk_Forums_Threads" FOREIGN KEY ("forum-id") REFERENCES public."Forums"(id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Posts lnk_Posts_Posts; Type: FK CONSTRAINT; Schema: public; Owner: maxim
--

ALTER TABLE ONLY public."Posts"
    ADD CONSTRAINT "lnk_Posts_Posts" FOREIGN KEY ("parent-id") REFERENCES public."Posts"(id) MATCH FULL ON DELETE CASCADE;


--
-- Name: Posts lnk_Threads_Posts; Type: FK CONSTRAINT; Schema: public; Owner: maxim
--

ALTER TABLE ONLY public."Posts"
    ADD CONSTRAINT "lnk_Threads_Posts" FOREIGN KEY ("thread-id") REFERENCES public."Threads"(id) MATCH FULL ON DELETE CASCADE;


--
-- Name: Votes lnk_Threads_Votes; Type: FK CONSTRAINT; Schema: public; Owner: maxim
--

ALTER TABLE ONLY public."Votes"
    ADD CONSTRAINT "lnk_Threads_Votes" FOREIGN KEY ("thread-id") REFERENCES public."Threads"(id) MATCH FULL ON DELETE CASCADE;


--
-- Name: Forums lnk_Users_Forums; Type: FK CONSTRAINT; Schema: public; Owner: maxim
--

ALTER TABLE ONLY public."Forums"
    ADD CONSTRAINT "lnk_Users_Forums" FOREIGN KEY ("user-id") REFERENCES public."Users"(id) MATCH FULL;


--
-- Name: Posts lnk_Users_Posts; Type: FK CONSTRAINT; Schema: public; Owner: maxim
--

ALTER TABLE ONLY public."Posts"
    ADD CONSTRAINT "lnk_Users_Posts" FOREIGN KEY ("author-id") REFERENCES public."Users"(id) MATCH FULL;


--
-- Name: Threads lnk_Users_Threads; Type: FK CONSTRAINT; Schema: public; Owner: maxim
--

ALTER TABLE ONLY public."Threads"
    ADD CONSTRAINT "lnk_Users_Threads" FOREIGN KEY ("author-id") REFERENCES public."Users"(id) MATCH FULL;


--
-- Name: Votes lnk_Users_Votes; Type: FK CONSTRAINT; Schema: public; Owner: maxim
--

ALTER TABLE ONLY public."Votes"
    ADD CONSTRAINT "lnk_Users_Votes" FOREIGN KEY ("user-id") REFERENCES public."Users"(id) MATCH FULL;


--
-- PostgreSQL database dump complete
--

