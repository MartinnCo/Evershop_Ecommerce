--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

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
-- Name: add_category_created_event(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_category_created_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      INSERT INTO event (name, data)
      VALUES ('category_created', row_to_json(NEW));
      RETURN NEW;
    END;
    $$;


ALTER FUNCTION public.add_category_created_event() OWNER TO postgres;

--
-- Name: add_category_deleted_event(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_category_deleted_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      INSERT INTO event (name, data)
      VALUES ('category_deleted', row_to_json(OLD));
      RETURN OLD;
    END;
    $$;


ALTER FUNCTION public.add_category_deleted_event() OWNER TO postgres;

--
-- Name: add_category_updated_event(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_category_updated_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      INSERT INTO event (name, data)
      VALUES ('category_updated', row_to_json(NEW));
      RETURN NEW;
    END;
    $$;


ALTER FUNCTION public.add_category_updated_event() OWNER TO postgres;

--
-- Name: add_customer_created_event(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_customer_created_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      INSERT INTO event (name, data)
      VALUES ('customer_created', row_to_json(NEW));
      RETURN NEW;
    END;
    $$;


ALTER FUNCTION public.add_customer_created_event() OWNER TO postgres;

--
-- Name: add_customer_deleted_event(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_customer_deleted_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      INSERT INTO event (name, data)
      VALUES ('customer_deleted', row_to_json(OLD));
      RETURN OLD;
    END;
    $$;


ALTER FUNCTION public.add_customer_deleted_event() OWNER TO postgres;

--
-- Name: add_customer_updated_event(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_customer_updated_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      INSERT INTO event (name, data)
      VALUES ('customer_updated', row_to_json(NEW));
      RETURN NEW;
    END;
    $$;


ALTER FUNCTION public.add_customer_updated_event() OWNER TO postgres;

--
-- Name: add_order_created_event(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_order_created_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      INSERT INTO event (name, data)
      VALUES ('order_created', row_to_json(NEW));
      RETURN NEW;
    END;
    $$;


ALTER FUNCTION public.add_order_created_event() OWNER TO postgres;

--
-- Name: add_product_created_event(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_product_created_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      INSERT INTO event (name, data)
      VALUES ('product_created', row_to_json(NEW));
      RETURN NEW;
    END;
    $$;


ALTER FUNCTION public.add_product_created_event() OWNER TO postgres;

--
-- Name: add_product_deleted_event(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_product_deleted_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      INSERT INTO event (name, data)
      VALUES ('product_deleted', row_to_json(OLD));
      RETURN OLD;
    END;
    $$;


ALTER FUNCTION public.add_product_deleted_event() OWNER TO postgres;

--
-- Name: add_product_inventory_updated_event(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_product_inventory_updated_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      INSERT INTO event (name, data)
      VALUES ('inventory_updated', json_build_object('old', row_to_json(OLD), 'new', row_to_json(NEW)));
      RETURN NEW;
    END;
    $$;


ALTER FUNCTION public.add_product_inventory_updated_event() OWNER TO postgres;

--
-- Name: add_product_updated_event(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_product_updated_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      INSERT INTO event (name, data)
      VALUES ('product_updated', row_to_json(NEW));
      RETURN NEW;
    END;
    $$;


ALTER FUNCTION public.add_product_updated_event() OWNER TO postgres;

--
-- Name: build_url_key(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.build_url_key() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
      url_key TEXT;
    BEGIN
      IF(NEW.url_key IS NULL) THEN
        url_key = regexp_replace(NEW.name, '[^a-zA-Z0-9]+', '-', 'g');
        url_key = regexp_replace(url_key, '^-|-$', '', 'g');
        url_key = lower(url_key);
        url_key = url_key || '-' || (SELECT floor(random() * 1000000)::text);
        NEW.url_key = url_key;
      ELSE
        IF (NEW.url_key ~ '[/\#]') THEN
          RAISE EXCEPTION 'Invalid url_key: %', NEW.url_key;
        END IF;
      END IF;
      RETURN NEW;
    END;
    $_$;


ALTER FUNCTION public.build_url_key() OWNER TO postgres;

--
-- Name: delete_product_attribute_value_index(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_product_attribute_value_index() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        DELETE FROM "product_attribute_value_index" WHERE "product_attribute_value_index".option_id = OLD.attribute_option_id AND "product_attribute_value_index"."attribute_id" = OLD.attribute_id;
        RETURN OLD;
      END;
      $$;


ALTER FUNCTION public.delete_product_attribute_value_index() OWNER TO postgres;

--
-- Name: delete_sub_categories(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_sub_categories() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      sub_categories RECORD;
    BEGIN
      FOR sub_categories IN
        WITH RECURSIVE sub_categories AS (
          SELECT * FROM category WHERE parent_id = OLD.category_id
          UNION
          SELECT c.* FROM category c
          INNER JOIN sub_categories sc ON c.parent_id = sc.category_id
        ) SELECT * FROM sub_categories
      LOOP
        DELETE FROM category WHERE category_id = sub_categories.category_id;
      END LOOP;
      RETURN OLD;
    END;
    $$;


ALTER FUNCTION public.delete_sub_categories() OWNER TO postgres;

--
-- Name: delete_variant_group_after_attribute_type_changed(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_variant_group_after_attribute_type_changed() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF (OLD.type = 'select' AND NEW.type <> 'select') THEN
          DELETE FROM "variant_group" WHERE ("variant_group".attribute_one = OLD.attribute_id OR "variant_group".attribute_two = OLD.attribute_id OR "variant_group".attribute_three = OLD.attribute_id OR "variant_group".attribute_four = OLD.attribute_id OR "variant_group".attribute_five = OLD.attribute_id);
        END IF;
        RETURN NEW;
      END
      $$;


ALTER FUNCTION public.delete_variant_group_after_attribute_type_changed() OWNER TO postgres;

--
-- Name: prevent_change_attribute_group(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.prevent_change_attribute_group() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF OLD.group_id != NEW.group_id AND OLD.variant_group_id IS NOT NULL THEN
          RAISE EXCEPTION 'Cannot change attribute group of product with variants';
        END IF;
        RETURN NEW;
      END;
      $$;


ALTER FUNCTION public.prevent_change_attribute_group() OWNER TO postgres;

--
-- Name: prevent_delete_default_attribute_group(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.prevent_delete_default_attribute_group() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF OLD.attribute_group_id = 1 THEN
          RAISE EXCEPTION 'Cannot delete default attribute group';
        END IF;
        RETURN OLD;
      END;
      $$;


ALTER FUNCTION public.prevent_delete_default_attribute_group() OWNER TO postgres;

--
-- Name: prevent_delete_default_customer_group(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.prevent_delete_default_customer_group() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF OLD.customer_group_id = 1 THEN
          RAISE EXCEPTION 'Cannot delete default customer group';
        END IF;
        RETURN OLD;
      END;
      $$;


ALTER FUNCTION public.prevent_delete_default_customer_group() OWNER TO postgres;

--
-- Name: prevent_delete_default_tax_class(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.prevent_delete_default_tax_class() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF OLD.tax_class_id = 1 THEN
          RAISE EXCEPTION 'Cannot delete default tax class';
        END IF;
        RETURN OLD;
      END;
      $$;


ALTER FUNCTION public.prevent_delete_default_tax_class() OWNER TO postgres;

--
-- Name: product_image_insert_trigger(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.product_image_insert_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        INSERT INTO event (name, data)
        VALUES ('product_image_added', row_to_json(NEW));
        RETURN NEW;
      END;
      $$;


ALTER FUNCTION public.product_image_insert_trigger() OWNER TO postgres;

--
-- Name: reduce_product_stock_when_order_placed(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.reduce_product_stock_when_order_placed() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        UPDATE product_inventory SET qty = qty - NEW.qty WHERE product_inventory_product_id = NEW.product_id AND manage_stock = TRUE;
        RETURN NEW;
      END
      $$;


ALTER FUNCTION public.reduce_product_stock_when_order_placed() OWNER TO postgres;

--
-- Name: remove_attribute_from_group(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.remove_attribute_from_group() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        DELETE FROM product_attribute_value_index WHERE product_attribute_value_index.attribute_id = OLD.attribute_id AND product_attribute_value_index.product_id IN (SELECT product.product_id FROM product WHERE product.group_id = OLD.group_id);
        DELETE FROM variant_group WHERE variant_group.attribute_group_id = OLD.group_id AND (variant_group.attribute_one = OLD.attribute_id OR variant_group.attribute_two = OLD.attribute_id OR variant_group.attribute_three = OLD.attribute_id OR variant_group.attribute_four = OLD.attribute_id OR variant_group.attribute_five = OLD.attribute_id);
        RETURN OLD;
      END;
      $$;


ALTER FUNCTION public.remove_attribute_from_group() OWNER TO postgres;

--
-- Name: set_coupon_used_time(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_coupon_used_time() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        UPDATE "coupon" SET used_time = used_time + 1 WHERE coupon = NEW.coupon;
        RETURN NEW;
      END;
      $$;


ALTER FUNCTION public.set_coupon_used_time() OWNER TO postgres;

--
-- Name: set_default_customer_group(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_default_customer_group() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF NEW.group_id IS NULL THEN
          NEW.group_id = 1;
        END IF;
        RETURN NEW;
      END;
      $$;


ALTER FUNCTION public.set_default_customer_group() OWNER TO postgres;

--
-- Name: update_attribute_index_and_variant_group_visibility(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_attribute_index_and_variant_group_visibility() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        DELETE FROM "product_attribute_value_index"
        WHERE "product_attribute_value_index"."product_id" = NEW.product_id 
        AND "product_attribute_value_index"."attribute_id" NOT IN (SELECT "attribute_group_link"."attribute_id" FROM "attribute_group_link" WHERE "attribute_group_link"."group_id" = NEW.group_id);
        UPDATE "variant_group" SET visibility = COALESCE((SELECT bool_or(visibility) FROM "product" WHERE "product"."variant_group_id" = NEW.variant_group_id AND "product"."status" = TRUE GROUP BY "product"."variant_group_id"), FALSE) WHERE "variant_group"."variant_group_id" = NEW.variant_group_id;
        RETURN NEW;
      END;
      $$;


ALTER FUNCTION public.update_attribute_index_and_variant_group_visibility() OWNER TO postgres;

--
-- Name: update_product_attribute_option_value_text(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_product_attribute_option_value_text() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        UPDATE "product_attribute_value_index" SET "option_text" = NEW.option_text
        WHERE "product_attribute_value_index".option_id = NEW.attribute_option_id AND "product_attribute_value_index".attribute_id = NEW.attribute_id;
        RETURN NEW;
      END;
      $$;


ALTER FUNCTION public.update_product_attribute_option_value_text() OWNER TO postgres;

--
-- Name: update_variant_group_visibility(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_variant_group_visibility() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        UPDATE "variant_group" SET visibility = (SELECT bool_or(visibility) FROM "product" WHERE "product"."variant_group_id" = NEW.variant_group_id AND "product"."status" = TRUE) WHERE "variant_group"."variant_group_id" = NEW.variant_group_id;
        RETURN NEW;
      END;
      $$;


ALTER FUNCTION public.update_variant_group_visibility() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_user (
    admin_user_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    status boolean DEFAULT true NOT NULL,
    email character varying NOT NULL,
    password character varying NOT NULL,
    full_name character varying,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.admin_user OWNER TO postgres;

--
-- Name: admin_user_admin_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.admin_user ALTER COLUMN admin_user_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.admin_user_admin_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: attribute; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attribute (
    attribute_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    attribute_code character varying NOT NULL,
    attribute_name character varying NOT NULL,
    type character varying NOT NULL,
    is_required boolean DEFAULT false NOT NULL,
    display_on_frontend boolean DEFAULT false NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    is_filterable boolean DEFAULT false NOT NULL
);


ALTER TABLE public.attribute OWNER TO postgres;

--
-- Name: attribute_attribute_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.attribute ALTER COLUMN attribute_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.attribute_attribute_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: attribute_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attribute_group (
    attribute_group_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    group_name text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.attribute_group OWNER TO postgres;

--
-- Name: attribute_group_attribute_group_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.attribute_group ALTER COLUMN attribute_group_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.attribute_group_attribute_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: attribute_group_link; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attribute_group_link (
    attribute_group_link_id integer NOT NULL,
    attribute_id integer NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE public.attribute_group_link OWNER TO postgres;

--
-- Name: attribute_group_link_attribute_group_link_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.attribute_group_link ALTER COLUMN attribute_group_link_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.attribute_group_link_attribute_group_link_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: attribute_option; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attribute_option (
    attribute_option_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    attribute_id integer NOT NULL,
    attribute_code character varying NOT NULL,
    option_text character varying NOT NULL
);


ALTER TABLE public.attribute_option OWNER TO postgres;

--
-- Name: attribute_option_attribute_option_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.attribute_option ALTER COLUMN attribute_option_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.attribute_option_attribute_option_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cart; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart (
    cart_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    sid character varying,
    currency character varying NOT NULL,
    customer_id integer,
    customer_group_id smallint,
    customer_email character varying,
    customer_full_name character varying,
    user_ip character varying,
    status boolean DEFAULT false NOT NULL,
    coupon character varying,
    shipping_fee_excl_tax numeric(12,4) DEFAULT NULL::numeric,
    shipping_fee_incl_tax numeric(12,4) DEFAULT NULL::numeric,
    discount_amount numeric(12,4) DEFAULT NULL::numeric,
    sub_total numeric(12,4) NOT NULL,
    sub_total_incl_tax numeric(12,4) NOT NULL,
    sub_total_with_discount numeric(12,4) NOT NULL,
    sub_total_with_discount_incl_tax numeric(12,4) NOT NULL,
    total_qty integer NOT NULL,
    total_weight numeric(12,4) DEFAULT NULL::numeric,
    tax_amount numeric(12,4) NOT NULL,
    tax_amount_before_discount numeric(12,4) NOT NULL,
    shipping_tax_amount numeric(12,4) NOT NULL,
    grand_total numeric(12,4) NOT NULL,
    shipping_method character varying,
    shipping_method_name character varying,
    shipping_zone_id integer,
    shipping_address_id integer,
    payment_method character varying,
    payment_method_name character varying,
    billing_address_id integer,
    shipping_note text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    total_tax_amount numeric(12,4)
);


ALTER TABLE public.cart OWNER TO postgres;

--
-- Name: cart_address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_address (
    cart_address_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    full_name character varying,
    postcode character varying,
    telephone character varying,
    country character varying,
    province character varying,
    city character varying,
    address_1 character varying,
    address_2 character varying
);


ALTER TABLE public.cart_address OWNER TO postgres;

--
-- Name: cart_address_cart_address_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.cart_address ALTER COLUMN cart_address_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.cart_address_cart_address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cart_cart_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.cart ALTER COLUMN cart_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.cart_cart_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cart_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_item (
    cart_item_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    cart_id integer NOT NULL,
    product_id integer NOT NULL,
    product_sku character varying NOT NULL,
    product_name text NOT NULL,
    thumbnail character varying,
    product_weight numeric(12,4) DEFAULT NULL::numeric,
    product_price numeric(12,4) NOT NULL,
    product_price_incl_tax numeric(12,4) NOT NULL,
    qty integer NOT NULL,
    final_price numeric(12,4) NOT NULL,
    final_price_incl_tax numeric(12,4) NOT NULL,
    tax_percent numeric(12,4) NOT NULL,
    tax_amount numeric(12,4) NOT NULL,
    tax_amount_before_discount numeric(12,4) NOT NULL,
    discount_amount numeric(12,4) NOT NULL,
    line_total numeric(12,4) NOT NULL,
    line_total_with_discount numeric(12,4) NOT NULL,
    line_total_incl_tax numeric(12,4) NOT NULL,
    line_total_with_discount_incl_tax numeric(12,4) NOT NULL,
    variant_group_id integer,
    variant_options text,
    product_custom_options text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.cart_item OWNER TO postgres;

--
-- Name: cart_item_cart_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.cart_item ALTER COLUMN cart_item_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.cart_item_cart_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.category (
    category_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    status boolean NOT NULL,
    parent_id integer,
    include_in_nav boolean NOT NULL,
    "position" smallint,
    show_products boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.category OWNER TO postgres;

--
-- Name: category_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.category ALTER COLUMN category_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.category_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: category_description; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.category_description (
    category_description_id integer NOT NULL,
    category_description_category_id integer NOT NULL,
    name character varying NOT NULL,
    short_description text,
    description text,
    image character varying,
    meta_title text,
    meta_keywords text,
    meta_description text,
    url_key character varying NOT NULL
);


ALTER TABLE public.category_description OWNER TO postgres;

--
-- Name: category_description_category_description_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.category_description ALTER COLUMN category_description_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.category_description_category_description_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cms_page; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cms_page (
    cms_page_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    status boolean,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.cms_page OWNER TO postgres;

--
-- Name: cms_page_cms_page_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.cms_page ALTER COLUMN cms_page_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.cms_page_cms_page_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cms_page_description; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cms_page_description (
    cms_page_description_id integer NOT NULL,
    cms_page_description_cms_page_id integer,
    url_key character varying NOT NULL,
    name character varying NOT NULL,
    content text,
    meta_title character varying,
    meta_keywords character varying,
    meta_description text
);


ALTER TABLE public.cms_page_description OWNER TO postgres;

--
-- Name: cms_page_description_cms_page_description_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.cms_page_description ALTER COLUMN cms_page_description_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.cms_page_description_cms_page_description_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: collection; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collection (
    collection_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    description text,
    code character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.collection OWNER TO postgres;

--
-- Name: collection_collection_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.collection ALTER COLUMN collection_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.collection_collection_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: coupon; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.coupon (
    coupon_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    status boolean DEFAULT true NOT NULL,
    description character varying NOT NULL,
    discount_amount numeric(12,4) NOT NULL,
    free_shipping boolean DEFAULT false NOT NULL,
    discount_type character varying DEFAULT '1'::character varying NOT NULL,
    coupon character varying NOT NULL,
    used_time integer DEFAULT 0 NOT NULL,
    target_products jsonb,
    condition jsonb,
    user_condition jsonb,
    buyx_gety jsonb,
    max_uses_time_per_coupon integer,
    max_uses_time_per_customer integer,
    start_date timestamp with time zone,
    end_date timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "POSITIVE_DISCOUNT_AMOUNT" CHECK ((discount_amount >= (0)::numeric)),
    CONSTRAINT "VALID_PERCENTAGE_DISCOUNT" CHECK (((discount_amount <= (100)::numeric) OR ((discount_type)::text <> 'percentage'::text)))
);


ALTER TABLE public.coupon OWNER TO postgres;

--
-- Name: coupon_coupon_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.coupon ALTER COLUMN coupon_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.coupon_coupon_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: customer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer (
    customer_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    status smallint DEFAULT 1 NOT NULL,
    group_id integer DEFAULT 1,
    email character varying NOT NULL,
    password character varying NOT NULL,
    full_name character varying,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.customer OWNER TO postgres;

--
-- Name: customer_address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer_address (
    customer_address_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    customer_id integer NOT NULL,
    full_name character varying,
    telephone character varying,
    address_1 character varying,
    address_2 character varying,
    postcode character varying,
    city character varying,
    province character varying,
    country character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_default boolean
);


ALTER TABLE public.customer_address OWNER TO postgres;

--
-- Name: customer_address_customer_address_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.customer_address ALTER COLUMN customer_address_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.customer_address_customer_address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: customer_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.customer ALTER COLUMN customer_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.customer_customer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: customer_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer_group (
    customer_group_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    group_name character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.customer_group OWNER TO postgres;

--
-- Name: customer_group_customer_group_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.customer_group ALTER COLUMN customer_group_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.customer_group_customer_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: event; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.event (
    event_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    data json,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.event OWNER TO postgres;

--
-- Name: event_event_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.event ALTER COLUMN event_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.event_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: migration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration (
    migration_id integer NOT NULL,
    module character varying NOT NULL,
    version character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.migration OWNER TO postgres;

--
-- Name: migration_migration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.migration ALTER COLUMN migration_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.migration_migration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: order; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."order" (
    order_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    integration_order_id character varying,
    sid character varying,
    order_number character varying NOT NULL,
    status character varying NOT NULL,
    cart_id integer NOT NULL,
    currency character varying NOT NULL,
    customer_id integer,
    customer_email character varying,
    customer_full_name character varying,
    user_ip character varying,
    user_agent character varying,
    coupon character varying,
    shipping_fee_excl_tax numeric(12,4) DEFAULT NULL::numeric,
    shipping_fee_incl_tax numeric(12,4) DEFAULT NULL::numeric,
    discount_amount numeric(12,4) DEFAULT NULL::numeric,
    sub_total numeric(12,4) NOT NULL,
    sub_total_incl_tax numeric(12,4) NOT NULL,
    sub_total_with_discount numeric(12,4) NOT NULL,
    sub_total_with_discount_incl_tax numeric(12,4) NOT NULL,
    total_qty integer NOT NULL,
    total_weight numeric(12,4) DEFAULT NULL::numeric,
    tax_amount numeric(12,4) NOT NULL,
    tax_amount_before_discount numeric(12,4) NOT NULL,
    shipping_tax_amount numeric(12,4) NOT NULL,
    shipping_note text,
    grand_total numeric(12,4) NOT NULL,
    shipping_method character varying,
    shipping_method_name character varying,
    shipping_address_id integer,
    payment_method character varying,
    payment_method_name character varying,
    billing_address_id integer,
    shipment_status character varying,
    payment_status character varying,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    total_tax_amount numeric(12,4)
);


ALTER TABLE public."order" OWNER TO postgres;

--
-- Name: order_activity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_activity (
    order_activity_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    order_activity_order_id integer NOT NULL,
    comment text NOT NULL,
    customer_notified boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.order_activity OWNER TO postgres;

--
-- Name: order_activity_order_activity_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.order_activity ALTER COLUMN order_activity_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.order_activity_order_activity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: order_address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_address (
    order_address_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    full_name character varying,
    postcode character varying,
    telephone character varying,
    country character varying,
    province character varying,
    city character varying,
    address_1 character varying,
    address_2 character varying
);


ALTER TABLE public.order_address OWNER TO postgres;

--
-- Name: order_address_order_address_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.order_address ALTER COLUMN order_address_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.order_address_order_address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: order_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_item (
    order_item_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    order_item_order_id integer NOT NULL,
    product_id integer NOT NULL,
    referer integer,
    product_sku character varying NOT NULL,
    product_name text NOT NULL,
    thumbnail character varying,
    product_weight numeric(12,4) DEFAULT NULL::numeric,
    product_price numeric(12,4) NOT NULL,
    product_price_incl_tax numeric(12,4) NOT NULL,
    qty integer NOT NULL,
    final_price numeric(12,4) NOT NULL,
    final_price_incl_tax numeric(12,4) NOT NULL,
    tax_percent numeric(12,4) NOT NULL,
    tax_amount numeric(12,4) NOT NULL,
    tax_amount_before_discount numeric(12,4) NOT NULL,
    discount_amount numeric(12,4) NOT NULL,
    line_total numeric(12,4) NOT NULL,
    line_total_with_discount numeric(12,4) NOT NULL,
    line_total_incl_tax numeric(12,4) NOT NULL,
    line_total_with_discount_incl_tax numeric(12,4) NOT NULL,
    variant_group_id integer,
    variant_options text,
    product_custom_options text,
    requested_data text
);


ALTER TABLE public.order_item OWNER TO postgres;

--
-- Name: order_item_order_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.order_item ALTER COLUMN order_item_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.order_item_order_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: order_order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."order" ALTER COLUMN order_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.order_order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: payment_transaction; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_transaction (
    payment_transaction_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    payment_transaction_order_id integer NOT NULL,
    transaction_id character varying,
    transaction_type character varying NOT NULL,
    amount numeric(12,4) NOT NULL,
    parent_transaction_id character varying,
    payment_action character varying,
    additional_information text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.payment_transaction OWNER TO postgres;

--
-- Name: payment_transaction_payment_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.payment_transaction ALTER COLUMN payment_transaction_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.payment_transaction_payment_transaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product (
    product_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    type character varying DEFAULT 'simple'::character varying NOT NULL,
    variant_group_id integer,
    visibility boolean DEFAULT true NOT NULL,
    group_id integer DEFAULT 1,
    sku character varying NOT NULL,
    price numeric(12,4) NOT NULL,
    weight numeric(12,4) DEFAULT NULL::numeric,
    tax_class smallint,
    status boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    category_id integer,
    CONSTRAINT "UNSIGNED_PRICE" CHECK ((price >= (0)::numeric)),
    CONSTRAINT "UNSIGNED_WEIGHT" CHECK ((weight >= (0)::numeric))
);


ALTER TABLE public.product OWNER TO postgres;

--
-- Name: product_attribute_value_index; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_attribute_value_index (
    product_attribute_value_index_id integer NOT NULL,
    product_id integer NOT NULL,
    attribute_id integer NOT NULL,
    option_id integer,
    option_text text
);


ALTER TABLE public.product_attribute_value_index OWNER TO postgres;

--
-- Name: product_attribute_value_index_product_attribute_value_index_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.product_attribute_value_index ALTER COLUMN product_attribute_value_index_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.product_attribute_value_index_product_attribute_value_index_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: product_collection; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_collection (
    product_collection_id integer NOT NULL,
    collection_id integer NOT NULL,
    product_id integer NOT NULL
);


ALTER TABLE public.product_collection OWNER TO postgres;

--
-- Name: product_collection_product_collection_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.product_collection ALTER COLUMN product_collection_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.product_collection_product_collection_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: product_custom_option; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_custom_option (
    product_custom_option_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    product_custom_option_product_id integer NOT NULL,
    option_name character varying NOT NULL,
    option_type character varying NOT NULL,
    is_required boolean DEFAULT false NOT NULL,
    sort_order integer
);


ALTER TABLE public.product_custom_option OWNER TO postgres;

--
-- Name: product_custom_option_product_custom_option_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.product_custom_option ALTER COLUMN product_custom_option_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.product_custom_option_product_custom_option_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: product_custom_option_value; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_custom_option_value (
    product_custom_option_value_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    option_id integer NOT NULL,
    extra_price numeric(12,4) DEFAULT NULL::numeric,
    sort_order integer,
    value character varying NOT NULL
);


ALTER TABLE public.product_custom_option_value OWNER TO postgres;

--
-- Name: product_custom_option_value_product_custom_option_value_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.product_custom_option_value ALTER COLUMN product_custom_option_value_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.product_custom_option_value_product_custom_option_value_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: product_description; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_description (
    product_description_id integer NOT NULL,
    product_description_product_id integer NOT NULL,
    name character varying NOT NULL,
    description text,
    short_description text,
    url_key character varying NOT NULL,
    meta_title text,
    meta_description text,
    meta_keywords text
);


ALTER TABLE public.product_description OWNER TO postgres;

--
-- Name: product_description_product_description_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.product_description ALTER COLUMN product_description_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.product_description_product_description_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: product_image; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_image (
    product_image_id integer NOT NULL,
    product_image_product_id integer NOT NULL,
    origin_image character varying NOT NULL,
    thumb_image text,
    listing_image text,
    single_image text,
    is_main boolean DEFAULT false
);


ALTER TABLE public.product_image OWNER TO postgres;

--
-- Name: product_image_product_image_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.product_image ALTER COLUMN product_image_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.product_image_product_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: product_inventory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_inventory (
    product_inventory_id integer NOT NULL,
    product_inventory_product_id integer NOT NULL,
    qty integer DEFAULT 0 NOT NULL,
    manage_stock boolean DEFAULT false NOT NULL,
    stock_availability boolean DEFAULT false NOT NULL
);


ALTER TABLE public.product_inventory OWNER TO postgres;

--
-- Name: product_inventory_product_inventory_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.product_inventory ALTER COLUMN product_inventory_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.product_inventory_product_inventory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: product_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.product ALTER COLUMN product_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.product_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: reset_password_token; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reset_password_token (
    reset_password_token_id integer NOT NULL,
    customer_id integer NOT NULL,
    token text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.reset_password_token OWNER TO postgres;

--
-- Name: reset_password_token_reset_password_token_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.reset_password_token ALTER COLUMN reset_password_token_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.reset_password_token_reset_password_token_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session (
    sid character varying NOT NULL,
    sess json NOT NULL,
    expire timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.session OWNER TO postgres;

--
-- Name: setting; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.setting (
    setting_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    value text,
    is_json boolean DEFAULT false NOT NULL
);


ALTER TABLE public.setting OWNER TO postgres;

--
-- Name: setting_setting_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.setting ALTER COLUMN setting_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.setting_setting_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: shipment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shipment (
    shipment_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    shipment_order_id integer NOT NULL,
    carrier character varying,
    tracking_number character varying,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.shipment OWNER TO postgres;

--
-- Name: shipment_shipment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.shipment ALTER COLUMN shipment_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.shipment_shipment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: shipping_method; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shipping_method (
    shipping_method_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.shipping_method OWNER TO postgres;

--
-- Name: shipping_method_shipping_method_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.shipping_method ALTER COLUMN shipping_method_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.shipping_method_shipping_method_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: shipping_zone; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shipping_zone (
    shipping_zone_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    country character varying NOT NULL
);


ALTER TABLE public.shipping_zone OWNER TO postgres;

--
-- Name: shipping_zone_method; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shipping_zone_method (
    shipping_zone_method_id integer NOT NULL,
    method_id integer NOT NULL,
    zone_id integer NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    cost numeric(12,4) DEFAULT NULL::numeric,
    calculate_api character varying,
    condition_type character varying,
    max numeric(12,4) DEFAULT NULL::numeric,
    min numeric(12,4) DEFAULT NULL::numeric,
    price_based_cost jsonb,
    weight_based_cost jsonb
);


ALTER TABLE public.shipping_zone_method OWNER TO postgres;

--
-- Name: shipping_zone_method_shipping_zone_method_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.shipping_zone_method ALTER COLUMN shipping_zone_method_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.shipping_zone_method_shipping_zone_method_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: shipping_zone_province; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shipping_zone_province (
    shipping_zone_province_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    zone_id integer NOT NULL,
    province character varying NOT NULL
);


ALTER TABLE public.shipping_zone_province OWNER TO postgres;

--
-- Name: shipping_zone_province_shipping_zone_province_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.shipping_zone_province ALTER COLUMN shipping_zone_province_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.shipping_zone_province_shipping_zone_province_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: shipping_zone_shipping_zone_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.shipping_zone ALTER COLUMN shipping_zone_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.shipping_zone_shipping_zone_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tax_class; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tax_class (
    tax_class_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.tax_class OWNER TO postgres;

--
-- Name: tax_class_tax_class_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tax_class ALTER COLUMN tax_class_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tax_class_tax_class_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tax_rate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tax_rate (
    tax_rate_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    tax_class_id integer,
    country character varying DEFAULT '*'::character varying NOT NULL,
    province character varying DEFAULT '*'::character varying NOT NULL,
    postcode character varying DEFAULT '*'::character varying NOT NULL,
    rate numeric(12,4) NOT NULL,
    is_compound boolean DEFAULT false NOT NULL,
    priority integer NOT NULL,
    CONSTRAINT "UNSIGNED_PRIORITY" CHECK ((priority >= 0)),
    CONSTRAINT "UNSIGNED_RATE" CHECK ((rate >= (0)::numeric))
);


ALTER TABLE public.tax_rate OWNER TO postgres;

--
-- Name: tax_rate_tax_rate_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tax_rate ALTER COLUMN tax_rate_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tax_rate_tax_rate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: url_rewrite; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.url_rewrite (
    url_rewrite_id integer NOT NULL,
    language character varying DEFAULT 'en'::character varying NOT NULL,
    request_path character varying NOT NULL,
    target_path character varying NOT NULL,
    entity_uuid uuid,
    entity_type character varying
);


ALTER TABLE public.url_rewrite OWNER TO postgres;

--
-- Name: url_rewrite_url_rewrite_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.url_rewrite ALTER COLUMN url_rewrite_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.url_rewrite_url_rewrite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: variant_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.variant_group (
    variant_group_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    attribute_group_id integer NOT NULL,
    attribute_one integer,
    attribute_two integer,
    attribute_three integer,
    attribute_four integer,
    attribute_five integer,
    visibility boolean DEFAULT false NOT NULL
);


ALTER TABLE public.variant_group OWNER TO postgres;

--
-- Name: variant_group_variant_group_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.variant_group ALTER COLUMN variant_group_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.variant_group_variant_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: widget; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.widget (
    widget_id integer NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    type character varying NOT NULL,
    route jsonb DEFAULT '[]'::jsonb NOT NULL,
    area jsonb DEFAULT '[]'::jsonb NOT NULL,
    sort_order integer DEFAULT 1 NOT NULL,
    settings jsonb DEFAULT '{}'::jsonb NOT NULL,
    status boolean,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.widget OWNER TO postgres;

--
-- Name: widget_widget_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.widget ALTER COLUMN widget_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.widget_widget_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: admin_user ADMIN_USER_EMAIL_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_user
    ADD CONSTRAINT "ADMIN_USER_EMAIL_UNIQUE" UNIQUE (email);


--
-- Name: admin_user ADMIN_USER_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_user
    ADD CONSTRAINT "ADMIN_USER_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: attribute ATTRIBUTE_CODE_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attribute
    ADD CONSTRAINT "ATTRIBUTE_CODE_UNIQUE" UNIQUE (attribute_code);


--
-- Name: attribute ATTRIBUTE_CODE_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attribute
    ADD CONSTRAINT "ATTRIBUTE_CODE_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: attribute_group_link ATTRIBUTE_GROUP_LINK_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attribute_group_link
    ADD CONSTRAINT "ATTRIBUTE_GROUP_LINK_UNIQUE" UNIQUE (attribute_id, group_id);


--
-- Name: attribute_group ATTRIBUTE_GROUP_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attribute_group
    ADD CONSTRAINT "ATTRIBUTE_GROUP_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: attribute_option ATTRIBUTE_OPTION_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attribute_option
    ADD CONSTRAINT "ATTRIBUTE_OPTION_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: cart_address CART_ADDRESS_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_address
    ADD CONSTRAINT "CART_ADDRESS_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: cart_item CART_ITEM_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_item
    ADD CONSTRAINT "CART_ITEM_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: cart CART_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT "CART_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: category_description CATEGORY_ID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category_description
    ADD CONSTRAINT "CATEGORY_ID_UNIQUE" UNIQUE (category_description_category_id);


--
-- Name: category_description CATEGORY_URL_KEY_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category_description
    ADD CONSTRAINT "CATEGORY_URL_KEY_UNIQUE" UNIQUE (url_key);


--
-- Name: category CATEGORY_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT "CATEGORY_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: cms_page CMS_PAGE_UUID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cms_page
    ADD CONSTRAINT "CMS_PAGE_UUID" UNIQUE (uuid);


--
-- Name: collection COLLECTION_CODE_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection
    ADD CONSTRAINT "COLLECTION_CODE_UNIQUE" UNIQUE (code);


--
-- Name: collection COLLECTION_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection
    ADD CONSTRAINT "COLLECTION_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: coupon COUPON_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coupon
    ADD CONSTRAINT "COUPON_UNIQUE" UNIQUE (coupon);


--
-- Name: coupon COUPON_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coupon
    ADD CONSTRAINT "COUPON_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: customer_address CUSTOMER_ADDRESS_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_address
    ADD CONSTRAINT "CUSTOMER_ADDRESS_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: customer CUSTOMER_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT "CUSTOMER_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: customer EMAIL_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT "EMAIL_UNIQUE" UNIQUE (email);


--
-- Name: event EVENT_UUID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT "EVENT_UUID" UNIQUE (uuid);


--
-- Name: shipping_zone_method METHOD_ZONE_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_zone_method
    ADD CONSTRAINT "METHOD_ZONE_UNIQUE" UNIQUE (zone_id, method_id);


--
-- Name: migration MODULE_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration
    ADD CONSTRAINT "MODULE_UNIQUE" UNIQUE (module);


--
-- Name: product_attribute_value_index OPTION_VALUE_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_attribute_value_index
    ADD CONSTRAINT "OPTION_VALUE_UNIQUE" UNIQUE (product_id, attribute_id, option_id);


--
-- Name: order_activity ORDER_ACTIVITY_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_activity
    ADD CONSTRAINT "ORDER_ACTIVITY_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: order_address ORDER_ADDRESS_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_address
    ADD CONSTRAINT "ORDER_ADDRESS_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: order_item ORDER_ITEM_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT "ORDER_ITEM_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: order ORDER_NUMBER_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT "ORDER_NUMBER_UNIQUE" UNIQUE (order_number);


--
-- Name: order ORDER_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT "ORDER_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: cms_page_description PAGE_ID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cms_page_description
    ADD CONSTRAINT "PAGE_ID_UNIQUE" UNIQUE (cms_page_description_cms_page_id);


--
-- Name: payment_transaction PAYMENT_TRANSACTION_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_transaction
    ADD CONSTRAINT "PAYMENT_TRANSACTION_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: product_collection PRODUCT_COLLECTION_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_collection
    ADD CONSTRAINT "PRODUCT_COLLECTION_UNIQUE" UNIQUE (collection_id, product_id);


--
-- Name: product_custom_option PRODUCT_CUSTOM_OPTION_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_custom_option
    ADD CONSTRAINT "PRODUCT_CUSTOM_OPTION_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: product_custom_option_value PRODUCT_CUSTOM_OPTION_VALUE_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_custom_option_value
    ADD CONSTRAINT "PRODUCT_CUSTOM_OPTION_VALUE_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: product_description PRODUCT_ID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_description
    ADD CONSTRAINT "PRODUCT_ID_UNIQUE" UNIQUE (product_description_product_id);


--
-- Name: product_inventory PRODUCT_INVENTORY_PRODUCT_ID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_inventory
    ADD CONSTRAINT "PRODUCT_INVENTORY_PRODUCT_ID_UNIQUE" UNIQUE (product_inventory_product_id);


--
-- Name: product PRODUCT_SKU_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT "PRODUCT_SKU_UNIQUE" UNIQUE (sku);


--
-- Name: product_description PRODUCT_URL_KEY_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_description
    ADD CONSTRAINT "PRODUCT_URL_KEY_UNIQUE" UNIQUE (url_key);


--
-- Name: product PRODUCT_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT "PRODUCT_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: session SESSION_PKEY; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT "SESSION_PKEY" PRIMARY KEY (sid);


--
-- Name: setting SETTING_NAME_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.setting
    ADD CONSTRAINT "SETTING_NAME_UNIQUE" UNIQUE (name);


--
-- Name: setting SETTING_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.setting
    ADD CONSTRAINT "SETTING_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: shipment SHIPMENT_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipment
    ADD CONSTRAINT "SHIPMENT_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: shipping_method SHIPPING_METHOD_NAME_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_method
    ADD CONSTRAINT "SHIPPING_METHOD_NAME_UNIQUE" UNIQUE (name);


--
-- Name: shipping_method SHIPPING_METHOD_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_method
    ADD CONSTRAINT "SHIPPING_METHOD_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: shipping_zone_province SHIPPING_ZONE_PROVINCE_PROVINCE_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_zone_province
    ADD CONSTRAINT "SHIPPING_ZONE_PROVINCE_PROVINCE_UNIQUE" UNIQUE (province);


--
-- Name: shipping_zone_province SHIPPING_ZONE_PROVINCE_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_zone_province
    ADD CONSTRAINT "SHIPPING_ZONE_PROVINCE_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: shipping_zone SHIPPING_ZONE_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_zone
    ADD CONSTRAINT "SHIPPING_ZONE_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: tax_class TAX_CLASS_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_class
    ADD CONSTRAINT "TAX_CLASS_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: tax_rate TAX_RATE_PRIORITY_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_rate
    ADD CONSTRAINT "TAX_RATE_PRIORITY_UNIQUE" UNIQUE (priority, tax_class_id);


--
-- Name: tax_rate TAX_RATE_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_rate
    ADD CONSTRAINT "TAX_RATE_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: payment_transaction UNQ_PAYMENT_TRANSACTION_ID_ORDER_ID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_transaction
    ADD CONSTRAINT "UNQ_PAYMENT_TRANSACTION_ID_ORDER_ID" UNIQUE (payment_transaction_order_id, transaction_id);


--
-- Name: cms_page_description URL_KEY_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cms_page_description
    ADD CONSTRAINT "URL_KEY_UNIQUE" UNIQUE (url_key);


--
-- Name: url_rewrite URL_REWRITE_PATH_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.url_rewrite
    ADD CONSTRAINT "URL_REWRITE_PATH_UNIQUE" UNIQUE (language, entity_uuid);


--
-- Name: variant_group VARIANT_GROUP_UUID_UNIQUE; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.variant_group
    ADD CONSTRAINT "VARIANT_GROUP_UUID_UNIQUE" UNIQUE (uuid);


--
-- Name: widget WIDGET_UUID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.widget
    ADD CONSTRAINT "WIDGET_UUID" UNIQUE (uuid);


--
-- Name: admin_user admin_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_user
    ADD CONSTRAINT admin_user_pkey PRIMARY KEY (admin_user_id);


--
-- Name: attribute_group_link attribute_group_link_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attribute_group_link
    ADD CONSTRAINT attribute_group_link_pkey PRIMARY KEY (attribute_group_link_id);


--
-- Name: attribute_group attribute_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attribute_group
    ADD CONSTRAINT attribute_group_pkey PRIMARY KEY (attribute_group_id);


--
-- Name: attribute_option attribute_option_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attribute_option
    ADD CONSTRAINT attribute_option_pkey PRIMARY KEY (attribute_option_id);


--
-- Name: attribute attribute_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attribute
    ADD CONSTRAINT attribute_pkey PRIMARY KEY (attribute_id);


--
-- Name: cart_address cart_address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_address
    ADD CONSTRAINT cart_address_pkey PRIMARY KEY (cart_address_id);


--
-- Name: cart_item cart_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_item
    ADD CONSTRAINT cart_item_pkey PRIMARY KEY (cart_item_id);


--
-- Name: cart cart_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_pkey PRIMARY KEY (cart_id);


--
-- Name: category_description category_description_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category_description
    ADD CONSTRAINT category_description_pkey PRIMARY KEY (category_description_id);


--
-- Name: category category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (category_id);


--
-- Name: cms_page_description cms_page_description_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cms_page_description
    ADD CONSTRAINT cms_page_description_pkey PRIMARY KEY (cms_page_description_id);


--
-- Name: cms_page cms_page_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cms_page
    ADD CONSTRAINT cms_page_pkey PRIMARY KEY (cms_page_id);


--
-- Name: collection collection_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection
    ADD CONSTRAINT collection_pkey PRIMARY KEY (collection_id);


--
-- Name: coupon coupon_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coupon
    ADD CONSTRAINT coupon_pkey PRIMARY KEY (coupon_id);


--
-- Name: customer_address customer_address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_address
    ADD CONSTRAINT customer_address_pkey PRIMARY KEY (customer_address_id);


--
-- Name: customer_group customer_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_group
    ADD CONSTRAINT customer_group_pkey PRIMARY KEY (customer_group_id);


--
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (customer_id);


--
-- Name: event event_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT event_pkey PRIMARY KEY (event_id);


--
-- Name: migration migration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration
    ADD CONSTRAINT migration_pkey PRIMARY KEY (migration_id);


--
-- Name: order_activity order_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_activity
    ADD CONSTRAINT order_activity_pkey PRIMARY KEY (order_activity_id);


--
-- Name: order_address order_address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_address
    ADD CONSTRAINT order_address_pkey PRIMARY KEY (order_address_id);


--
-- Name: order_item order_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_pkey PRIMARY KEY (order_item_id);


--
-- Name: order order_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_pkey PRIMARY KEY (order_id);


--
-- Name: payment_transaction payment_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_transaction
    ADD CONSTRAINT payment_transaction_pkey PRIMARY KEY (payment_transaction_id);


--
-- Name: product_attribute_value_index product_attribute_value_index_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_attribute_value_index
    ADD CONSTRAINT product_attribute_value_index_pkey PRIMARY KEY (product_attribute_value_index_id);


--
-- Name: product_collection product_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_collection
    ADD CONSTRAINT product_collection_pkey PRIMARY KEY (product_collection_id);


--
-- Name: product_custom_option product_custom_option_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_custom_option
    ADD CONSTRAINT product_custom_option_pkey PRIMARY KEY (product_custom_option_id);


--
-- Name: product_custom_option_value product_custom_option_value_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_custom_option_value
    ADD CONSTRAINT product_custom_option_value_pkey PRIMARY KEY (product_custom_option_value_id);


--
-- Name: product_description product_description_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_description
    ADD CONSTRAINT product_description_pkey PRIMARY KEY (product_description_id);


--
-- Name: product_image product_image_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_image
    ADD CONSTRAINT product_image_pkey PRIMARY KEY (product_image_id);


--
-- Name: product_inventory product_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_inventory
    ADD CONSTRAINT product_inventory_pkey PRIMARY KEY (product_inventory_id);


--
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (product_id);


--
-- Name: reset_password_token reset_password_token_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reset_password_token
    ADD CONSTRAINT reset_password_token_pkey PRIMARY KEY (reset_password_token_id);


--
-- Name: setting setting_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.setting
    ADD CONSTRAINT setting_pkey PRIMARY KEY (setting_id);


--
-- Name: shipment shipment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipment
    ADD CONSTRAINT shipment_pkey PRIMARY KEY (shipment_id);


--
-- Name: shipping_method shipping_method_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_method
    ADD CONSTRAINT shipping_method_pkey PRIMARY KEY (shipping_method_id);


--
-- Name: shipping_zone_method shipping_zone_method_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_zone_method
    ADD CONSTRAINT shipping_zone_method_pkey PRIMARY KEY (shipping_zone_method_id);


--
-- Name: shipping_zone shipping_zone_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_zone
    ADD CONSTRAINT shipping_zone_pkey PRIMARY KEY (shipping_zone_id);


--
-- Name: shipping_zone_province shipping_zone_province_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_zone_province
    ADD CONSTRAINT shipping_zone_province_pkey PRIMARY KEY (shipping_zone_province_id);


--
-- Name: tax_class tax_class_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_class
    ADD CONSTRAINT tax_class_pkey PRIMARY KEY (tax_class_id);


--
-- Name: tax_rate tax_rate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_rate
    ADD CONSTRAINT tax_rate_pkey PRIMARY KEY (tax_rate_id);


--
-- Name: url_rewrite url_rewrite_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.url_rewrite
    ADD CONSTRAINT url_rewrite_pkey PRIMARY KEY (url_rewrite_id);


--
-- Name: variant_group variant_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.variant_group
    ADD CONSTRAINT variant_group_pkey PRIMARY KEY (variant_group_id);


--
-- Name: widget widget_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.widget
    ADD CONSTRAINT widget_pkey PRIMARY KEY (widget_id);


--
-- Name: FK_ATTRIBUTE_GROUP_VARIANT; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_ATTRIBUTE_GROUP_VARIANT" ON public.variant_group USING btree (attribute_group_id);


--
-- Name: FK_ATTRIBUTE_LINK; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_ATTRIBUTE_LINK" ON public.attribute_group_link USING btree (attribute_id);


--
-- Name: FK_ATTRIBUTE_OPTION; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_ATTRIBUTE_OPTION" ON public.attribute_option USING btree (attribute_id);


--
-- Name: FK_ATTRIBUTE_OPTION_VALUE_LINK; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_ATTRIBUTE_OPTION_VALUE_LINK" ON public.product_attribute_value_index USING btree (option_id);


--
-- Name: FK_ATTRIBUTE_VALUE_LINK; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_ATTRIBUTE_VALUE_LINK" ON public.product_attribute_value_index USING btree (attribute_id);


--
-- Name: FK_ATTRIBUTE_VARIANT_FIVE; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_ATTRIBUTE_VARIANT_FIVE" ON public.variant_group USING btree (attribute_five);


--
-- Name: FK_ATTRIBUTE_VARIANT_FOUR; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_ATTRIBUTE_VARIANT_FOUR" ON public.variant_group USING btree (attribute_four);


--
-- Name: FK_ATTRIBUTE_VARIANT_ONE; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_ATTRIBUTE_VARIANT_ONE" ON public.variant_group USING btree (attribute_one);


--
-- Name: FK_ATTRIBUTE_VARIANT_THREE; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_ATTRIBUTE_VARIANT_THREE" ON public.variant_group USING btree (attribute_three);


--
-- Name: FK_ATTRIBUTE_VARIANT_TWO; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_ATTRIBUTE_VARIANT_TWO" ON public.variant_group USING btree (attribute_two);


--
-- Name: FK_CART_ITEM; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_CART_ITEM" ON public.cart_item USING btree (cart_id);


--
-- Name: FK_CART_ITEM_PRODUCT; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_CART_ITEM_PRODUCT" ON public.cart_item USING btree (product_id);


--
-- Name: FK_CART_SHIPPING_ZONE; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_CART_SHIPPING_ZONE" ON public.cart USING btree (shipping_zone_id);


--
-- Name: FK_CATEGORY_DESCRIPTION; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_CATEGORY_DESCRIPTION" ON public.category_description USING btree (category_description_category_id);


--
-- Name: FK_CMS_PAGE_DESCRIPTION; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_CMS_PAGE_DESCRIPTION" ON public.cms_page_description USING btree (cms_page_description_cms_page_id);


--
-- Name: FK_COLLECTION_PRODUCT_LINK; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_COLLECTION_PRODUCT_LINK" ON public.product_collection USING btree (collection_id);


--
-- Name: FK_CUSTOMER_ADDRESS; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_CUSTOMER_ADDRESS" ON public.customer_address USING btree (customer_id);


--
-- Name: FK_CUSTOMER_GROUP; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_CUSTOMER_GROUP" ON public.customer USING btree (group_id);


--
-- Name: FK_CUSTOM_OPTION_VALUE; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_CUSTOM_OPTION_VALUE" ON public.product_custom_option_value USING btree (option_id);


--
-- Name: FK_GROUP_LINK; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_GROUP_LINK" ON public.attribute_group_link USING btree (group_id);


--
-- Name: FK_METHOD_ZONE; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_METHOD_ZONE" ON public.shipping_zone_method USING btree (method_id);


--
-- Name: FK_ORDER; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_ORDER" ON public.order_item USING btree (order_item_order_id);


--
-- Name: FK_ORDER_ACTIVITY; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_ORDER_ACTIVITY" ON public.order_activity USING btree (order_activity_order_id);


--
-- Name: FK_ORDER_SHIPMENT; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_ORDER_SHIPMENT" ON public.shipment USING btree (shipment_order_id);


--
-- Name: FK_PAYMENT_TRANSACTION_ORDER; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_PAYMENT_TRANSACTION_ORDER" ON public.payment_transaction USING btree (payment_transaction_order_id);


--
-- Name: FK_PRODUCT_ATTRIBUTE_GROUP; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_PRODUCT_ATTRIBUTE_GROUP" ON public.product USING btree (group_id);


--
-- Name: FK_PRODUCT_ATTRIBUTE_LINK; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_PRODUCT_ATTRIBUTE_LINK" ON public.product_attribute_value_index USING btree (product_id);


--
-- Name: FK_PRODUCT_COLLECTION_LINK; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_PRODUCT_COLLECTION_LINK" ON public.product_collection USING btree (product_id);


--
-- Name: FK_PRODUCT_CUSTOM_OPTION; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_PRODUCT_CUSTOM_OPTION" ON public.product_custom_option USING btree (product_custom_option_product_id);


--
-- Name: FK_PRODUCT_DESCRIPTION; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_PRODUCT_DESCRIPTION" ON public.product_description USING btree (product_description_product_id);


--
-- Name: FK_PRODUCT_IMAGE_LINK; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_PRODUCT_IMAGE_LINK" ON public.product_image USING btree (product_image_product_id);


--
-- Name: FK_PRODUCT_VARIANT_GROUP; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_PRODUCT_VARIANT_GROUP" ON public.product USING btree (variant_group_id);


--
-- Name: FK_SHIPPING_ZONE_PROVINCE; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_SHIPPING_ZONE_PROVINCE" ON public.shipping_zone_province USING btree (zone_id);


--
-- Name: FK_ZONE_METHOD; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "FK_ZONE_METHOD" ON public.shipping_zone_method USING btree (zone_id);


--
-- Name: IDX_SESSION_EXPIRE; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_SESSION_EXPIRE" ON public.session USING btree (expire);


--
-- Name: PRODUCT_SEARCH_INDEX; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PRODUCT_SEARCH_INDEX" ON public.product_description USING gin (to_tsvector('simple'::regconfig, (((name)::text || ' '::text) || description)));


--
-- Name: category ADD_CATEGORY_CREATED_EVENT_TRIGGER; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "ADD_CATEGORY_CREATED_EVENT_TRIGGER" AFTER INSERT ON public.category FOR EACH ROW EXECUTE FUNCTION public.add_category_created_event();


--
-- Name: category ADD_CATEGORY_DELETED_EVENT_TRIGGER; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "ADD_CATEGORY_DELETED_EVENT_TRIGGER" AFTER DELETE ON public.category FOR EACH ROW EXECUTE FUNCTION public.add_category_deleted_event();


--
-- Name: category ADD_CATEGORY_UPDATED_EVENT_TRIGGER; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "ADD_CATEGORY_UPDATED_EVENT_TRIGGER" AFTER UPDATE ON public.category FOR EACH ROW EXECUTE FUNCTION public.add_category_updated_event();


--
-- Name: customer ADD_CUSTOMER_CREATED_EVENT_TRIGGER; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "ADD_CUSTOMER_CREATED_EVENT_TRIGGER" AFTER INSERT ON public.customer FOR EACH ROW EXECUTE FUNCTION public.add_customer_created_event();


--
-- Name: customer ADD_CUSTOMER_DELETED_EVENT_TRIGGER; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "ADD_CUSTOMER_DELETED_EVENT_TRIGGER" AFTER DELETE ON public.customer FOR EACH ROW EXECUTE FUNCTION public.add_customer_deleted_event();


--
-- Name: customer ADD_CUSTOMER_UPDATED_EVENT_TRIGGER; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "ADD_CUSTOMER_UPDATED_EVENT_TRIGGER" AFTER UPDATE ON public.customer FOR EACH ROW EXECUTE FUNCTION public.add_customer_updated_event();


--
-- Name: product_inventory ADD_INVENTORY_UPDATED_EVENT_TRIGGER; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "ADD_INVENTORY_UPDATED_EVENT_TRIGGER" AFTER UPDATE ON public.product_inventory FOR EACH ROW EXECUTE FUNCTION public.add_product_inventory_updated_event();


--
-- Name: order ADD_ORDER_CREATED_EVENT_TRIGGER; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "ADD_ORDER_CREATED_EVENT_TRIGGER" AFTER INSERT ON public."order" FOR EACH ROW EXECUTE FUNCTION public.add_order_created_event();


--
-- Name: product ADD_PRODUCT_CREATED_EVENT_TRIGGER; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "ADD_PRODUCT_CREATED_EVENT_TRIGGER" AFTER INSERT ON public.product FOR EACH ROW EXECUTE FUNCTION public.add_product_created_event();


--
-- Name: product ADD_PRODUCT_DELETED_EVENT_TRIGGER; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "ADD_PRODUCT_DELETED_EVENT_TRIGGER" AFTER DELETE ON public.product FOR EACH ROW EXECUTE FUNCTION public.add_product_deleted_event();


--
-- Name: product ADD_PRODUCT_UPDATED_EVENT_TRIGGER; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "ADD_PRODUCT_UPDATED_EVENT_TRIGGER" AFTER UPDATE ON public.product FOR EACH ROW EXECUTE FUNCTION public.add_product_updated_event();


--
-- Name: category_description BUILD_CATEGORY_URL_KEY_TRIGGER; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "BUILD_CATEGORY_URL_KEY_TRIGGER" BEFORE INSERT OR UPDATE ON public.category_description FOR EACH ROW EXECUTE FUNCTION public.build_url_key();


--
-- Name: product_description BUILD_PRODUCT_URL_KEY_TRIGGER; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "BUILD_PRODUCT_URL_KEY_TRIGGER" BEFORE INSERT OR UPDATE ON public.product_description FOR EACH ROW EXECUTE FUNCTION public.build_url_key();


--
-- Name: category DELETE_SUB_CATEGORIES_TRIGGER; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "DELETE_SUB_CATEGORIES_TRIGGER" AFTER DELETE ON public.category FOR EACH ROW EXECUTE FUNCTION public.delete_sub_categories();


--
-- Name: product PREVENT_CHANGING_ATTRIBUTE_GROUP_OF_PRODUCT_WITH_VARIANTS; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "PREVENT_CHANGING_ATTRIBUTE_GROUP_OF_PRODUCT_WITH_VARIANTS" BEFORE UPDATE ON public.product FOR EACH ROW EXECUTE FUNCTION public.prevent_change_attribute_group();


--
-- Name: attribute_group PREVENT_DELETING_THE_DEFAULT_ATTRIBUTE_GROUP; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "PREVENT_DELETING_THE_DEFAULT_ATTRIBUTE_GROUP" BEFORE DELETE ON public.attribute_group FOR EACH ROW EXECUTE FUNCTION public.prevent_delete_default_attribute_group();


--
-- Name: customer_group PREVENT_DELETING_THE_DEFAULT_CUSTOMER_GROUP; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "PREVENT_DELETING_THE_DEFAULT_CUSTOMER_GROUP" BEFORE DELETE ON public.customer_group FOR EACH ROW EXECUTE FUNCTION public.prevent_delete_default_customer_group();


--
-- Name: tax_class PREVENT_DELETING_THE_DEFAULT_TAX_CLASS; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "PREVENT_DELETING_THE_DEFAULT_TAX_CLASS" BEFORE DELETE ON public.tax_class FOR EACH ROW EXECUTE FUNCTION public.prevent_delete_default_tax_class();


--
-- Name: product_image PRODUCT_IMAGE_ADDED; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "PRODUCT_IMAGE_ADDED" AFTER INSERT ON public.product_image FOR EACH ROW EXECUTE FUNCTION public.product_image_insert_trigger();


--
-- Name: customer SET_DEFAULT_CUSTOMER_GROUP; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "SET_DEFAULT_CUSTOMER_GROUP" BEFORE INSERT ON public.customer FOR EACH ROW EXECUTE FUNCTION public.set_default_customer_group();


--
-- Name: attribute_option TRIGGER_AFTER_ATTRIBUTE_OPTION_UPDATE; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "TRIGGER_AFTER_ATTRIBUTE_OPTION_UPDATE" AFTER UPDATE ON public.attribute_option FOR EACH ROW EXECUTE FUNCTION public.update_product_attribute_option_value_text();


--
-- Name: attribute_option TRIGGER_AFTER_DELETE_ATTRIBUTE_OPTION; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "TRIGGER_AFTER_DELETE_ATTRIBUTE_OPTION" AFTER DELETE ON public.attribute_option FOR EACH ROW EXECUTE FUNCTION public.delete_product_attribute_value_index();


--
-- Name: order_item TRIGGER_AFTER_INSERT_ORDER_ITEM; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "TRIGGER_AFTER_INSERT_ORDER_ITEM" AFTER INSERT ON public.order_item FOR EACH ROW EXECUTE FUNCTION public.reduce_product_stock_when_order_placed();


--
-- Name: product TRIGGER_AFTER_INSERT_PRODUCT; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE CONSTRAINT TRIGGER "TRIGGER_AFTER_INSERT_PRODUCT" AFTER INSERT ON public.product DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE FUNCTION public.update_variant_group_visibility();


--
-- Name: attribute_group_link TRIGGER_AFTER_REMOVE_ATTRIBUTE_FROM_GROUP; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "TRIGGER_AFTER_REMOVE_ATTRIBUTE_FROM_GROUP" AFTER DELETE ON public.attribute_group_link FOR EACH ROW EXECUTE FUNCTION public.remove_attribute_from_group();


--
-- Name: attribute TRIGGER_AFTER_UPDATE_ATTRIBUTE; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "TRIGGER_AFTER_UPDATE_ATTRIBUTE" AFTER UPDATE ON public.attribute FOR EACH ROW EXECUTE FUNCTION public.delete_variant_group_after_attribute_type_changed();


--
-- Name: product TRIGGER_PRODUCT_AFTER_UPDATE; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE CONSTRAINT TRIGGER "TRIGGER_PRODUCT_AFTER_UPDATE" AFTER UPDATE ON public.product DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.update_attribute_index_and_variant_group_visibility();


--
-- Name: order TRIGGER_UPDATE_COUPON_USED_TIME_AFTER_CREATE_ORDER; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "TRIGGER_UPDATE_COUPON_USED_TIME_AFTER_CREATE_ORDER" AFTER INSERT ON public."order" FOR EACH ROW EXECUTE FUNCTION public.set_coupon_used_time();


--
-- Name: variant_group FK_ATTRIBUTE_GROUP_VARIANT; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.variant_group
    ADD CONSTRAINT "FK_ATTRIBUTE_GROUP_VARIANT" FOREIGN KEY (attribute_group_id) REFERENCES public.attribute_group(attribute_group_id) ON DELETE CASCADE;


--
-- Name: attribute_group_link FK_ATTRIBUTE_LINK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attribute_group_link
    ADD CONSTRAINT "FK_ATTRIBUTE_LINK" FOREIGN KEY (attribute_id) REFERENCES public.attribute(attribute_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: attribute_option FK_ATTRIBUTE_OPTION; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attribute_option
    ADD CONSTRAINT "FK_ATTRIBUTE_OPTION" FOREIGN KEY (attribute_id) REFERENCES public.attribute(attribute_id) ON DELETE CASCADE;


--
-- Name: product_attribute_value_index FK_ATTRIBUTE_OPTION_VALUE_LINK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_attribute_value_index
    ADD CONSTRAINT "FK_ATTRIBUTE_OPTION_VALUE_LINK" FOREIGN KEY (option_id) REFERENCES public.attribute_option(attribute_option_id) ON DELETE CASCADE;


--
-- Name: product_attribute_value_index FK_ATTRIBUTE_VALUE_LINK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_attribute_value_index
    ADD CONSTRAINT "FK_ATTRIBUTE_VALUE_LINK" FOREIGN KEY (attribute_id) REFERENCES public.attribute(attribute_id) ON DELETE CASCADE;


--
-- Name: variant_group FK_ATTRIBUTE_VARIANT_FIVE; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.variant_group
    ADD CONSTRAINT "FK_ATTRIBUTE_VARIANT_FIVE" FOREIGN KEY (attribute_five) REFERENCES public.attribute(attribute_id) ON DELETE CASCADE;


--
-- Name: variant_group FK_ATTRIBUTE_VARIANT_FOUR; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.variant_group
    ADD CONSTRAINT "FK_ATTRIBUTE_VARIANT_FOUR" FOREIGN KEY (attribute_four) REFERENCES public.attribute(attribute_id) ON DELETE CASCADE;


--
-- Name: variant_group FK_ATTRIBUTE_VARIANT_ONE; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.variant_group
    ADD CONSTRAINT "FK_ATTRIBUTE_VARIANT_ONE" FOREIGN KEY (attribute_one) REFERENCES public.attribute(attribute_id) ON DELETE CASCADE;


--
-- Name: variant_group FK_ATTRIBUTE_VARIANT_THREE; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.variant_group
    ADD CONSTRAINT "FK_ATTRIBUTE_VARIANT_THREE" FOREIGN KEY (attribute_three) REFERENCES public.attribute(attribute_id) ON DELETE CASCADE;


--
-- Name: variant_group FK_ATTRIBUTE_VARIANT_TWO; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.variant_group
    ADD CONSTRAINT "FK_ATTRIBUTE_VARIANT_TWO" FOREIGN KEY (attribute_two) REFERENCES public.attribute(attribute_id) ON DELETE CASCADE;


--
-- Name: cart_item FK_CART_ITEM; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_item
    ADD CONSTRAINT "FK_CART_ITEM" FOREIGN KEY (cart_id) REFERENCES public.cart(cart_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart_item FK_CART_ITEM_PRODUCT; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_item
    ADD CONSTRAINT "FK_CART_ITEM_PRODUCT" FOREIGN KEY (product_id) REFERENCES public.product(product_id) ON DELETE CASCADE;


--
-- Name: cart FK_CART_SHIPPING_ZONE; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT "FK_CART_SHIPPING_ZONE" FOREIGN KEY (shipping_zone_id) REFERENCES public.shipping_zone(shipping_zone_id) ON DELETE SET NULL;


--
-- Name: category_description FK_CATEGORY_DESCRIPTION; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category_description
    ADD CONSTRAINT "FK_CATEGORY_DESCRIPTION" FOREIGN KEY (category_description_category_id) REFERENCES public.category(category_id) ON DELETE CASCADE;


--
-- Name: cms_page_description FK_CMS_PAGE_DESCRIPTION; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cms_page_description
    ADD CONSTRAINT "FK_CMS_PAGE_DESCRIPTION" FOREIGN KEY (cms_page_description_cms_page_id) REFERENCES public.cms_page(cms_page_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_collection FK_COLLECTION_PRODUCT_LINK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_collection
    ADD CONSTRAINT "FK_COLLECTION_PRODUCT_LINK" FOREIGN KEY (collection_id) REFERENCES public.collection(collection_id) ON DELETE CASCADE;


--
-- Name: customer_address FK_CUSTOMER_ADDRESS; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_address
    ADD CONSTRAINT "FK_CUSTOMER_ADDRESS" FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id) ON DELETE CASCADE;


--
-- Name: customer FK_CUSTOMER_GROUP; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT "FK_CUSTOMER_GROUP" FOREIGN KEY (group_id) REFERENCES public.customer_group(customer_group_id) ON DELETE SET NULL;


--
-- Name: product_custom_option_value FK_CUSTOM_OPTION_VALUE; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_custom_option_value
    ADD CONSTRAINT "FK_CUSTOM_OPTION_VALUE" FOREIGN KEY (option_id) REFERENCES public.product_custom_option(product_custom_option_id) ON DELETE CASCADE;


--
-- Name: attribute_group_link FK_GROUP_LINK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attribute_group_link
    ADD CONSTRAINT "FK_GROUP_LINK" FOREIGN KEY (group_id) REFERENCES public.attribute_group(attribute_group_id) ON DELETE CASCADE;


--
-- Name: shipping_zone_method FK_METHOD_ZONE; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_zone_method
    ADD CONSTRAINT "FK_METHOD_ZONE" FOREIGN KEY (method_id) REFERENCES public.shipping_method(shipping_method_id) ON DELETE CASCADE;


--
-- Name: order_item FK_ORDER; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT "FK_ORDER" FOREIGN KEY (order_item_order_id) REFERENCES public."order"(order_id) ON DELETE CASCADE;


--
-- Name: order_activity FK_ORDER_ACTIVITY; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_activity
    ADD CONSTRAINT "FK_ORDER_ACTIVITY" FOREIGN KEY (order_activity_order_id) REFERENCES public."order"(order_id) ON DELETE CASCADE;


--
-- Name: shipment FK_ORDER_SHIPMENT; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipment
    ADD CONSTRAINT "FK_ORDER_SHIPMENT" FOREIGN KEY (shipment_order_id) REFERENCES public."order"(order_id) ON DELETE CASCADE;


--
-- Name: payment_transaction FK_PAYMENT_TRANSACTION_ORDER; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_transaction
    ADD CONSTRAINT "FK_PAYMENT_TRANSACTION_ORDER" FOREIGN KEY (payment_transaction_order_id) REFERENCES public."order"(order_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product FK_PRODUCT_ATTRIBUTE_GROUP; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT "FK_PRODUCT_ATTRIBUTE_GROUP" FOREIGN KEY (group_id) REFERENCES public.attribute_group(attribute_group_id) ON DELETE SET NULL;


--
-- Name: product_attribute_value_index FK_PRODUCT_ATTRIBUTE_LINK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_attribute_value_index
    ADD CONSTRAINT "FK_PRODUCT_ATTRIBUTE_LINK" FOREIGN KEY (product_id) REFERENCES public.product(product_id) ON DELETE CASCADE;


--
-- Name: product_collection FK_PRODUCT_COLLECTION_LINK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_collection
    ADD CONSTRAINT "FK_PRODUCT_COLLECTION_LINK" FOREIGN KEY (product_id) REFERENCES public.product(product_id) ON DELETE CASCADE;


--
-- Name: product_custom_option FK_PRODUCT_CUSTOM_OPTION; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_custom_option
    ADD CONSTRAINT "FK_PRODUCT_CUSTOM_OPTION" FOREIGN KEY (product_custom_option_product_id) REFERENCES public.product(product_id) ON DELETE CASCADE;


--
-- Name: product_description FK_PRODUCT_DESCRIPTION; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_description
    ADD CONSTRAINT "FK_PRODUCT_DESCRIPTION" FOREIGN KEY (product_description_product_id) REFERENCES public.product(product_id) ON DELETE CASCADE;


--
-- Name: product_image FK_PRODUCT_IMAGE_LINK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_image
    ADD CONSTRAINT "FK_PRODUCT_IMAGE_LINK" FOREIGN KEY (product_image_product_id) REFERENCES public.product(product_id) ON DELETE CASCADE;


--
-- Name: product FK_PRODUCT_VARIANT_GROUP; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT "FK_PRODUCT_VARIANT_GROUP" FOREIGN KEY (variant_group_id) REFERENCES public.variant_group(variant_group_id) ON DELETE SET NULL;


--
-- Name: reset_password_token FK_RESET_PASSWORD_TOKEN_CUSTOMER; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reset_password_token
    ADD CONSTRAINT "FK_RESET_PASSWORD_TOKEN_CUSTOMER" FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id) ON DELETE CASCADE;


--
-- Name: shipping_zone_province FK_SHIPPING_ZONE_PROVINCE; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_zone_province
    ADD CONSTRAINT "FK_SHIPPING_ZONE_PROVINCE" FOREIGN KEY (zone_id) REFERENCES public.shipping_zone(shipping_zone_id) ON DELETE CASCADE;


--
-- Name: product FK_TAX_CLASS; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT "FK_TAX_CLASS" FOREIGN KEY (tax_class) REFERENCES public.tax_class(tax_class_id) ON DELETE SET NULL;


--
-- Name: tax_rate FK_TAX_RATE_TAX_CLASS; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_rate
    ADD CONSTRAINT "FK_TAX_RATE_TAX_CLASS" FOREIGN KEY (tax_class_id) REFERENCES public.tax_class(tax_class_id) ON DELETE CASCADE;


--
-- Name: shipping_zone_method FK_ZONE_METHOD; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_zone_method
    ADD CONSTRAINT "FK_ZONE_METHOD" FOREIGN KEY (zone_id) REFERENCES public.shipping_zone(shipping_zone_id) ON DELETE CASCADE;


--
-- Name: product PRODUCT_CATEGORY_ID_CONSTRAINT; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT "PRODUCT_CATEGORY_ID_CONSTRAINT" FOREIGN KEY (category_id) REFERENCES public.category(category_id) ON DELETE SET NULL;


--
-- Name: product_inventory PRODUCT_INVENTORY_PRODUCT_ID_CONSTANTSRAINT; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_inventory
    ADD CONSTRAINT "PRODUCT_INVENTORY_PRODUCT_ID_CONSTANTSRAINT" FOREIGN KEY (product_inventory_product_id) REFERENCES public.product(product_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

