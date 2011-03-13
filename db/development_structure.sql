CREATE TABLE "alerts" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "name" varchar(255), "dismissed" boolean DEFAULT 'f', "created_at" datetime, "updated_at" datetime);
CREATE TABLE "beers" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "brew_id" integer, "abv" float, "price" float, "quantity" integer, "created_at" datetime, "updated_at" datetime, "cellar_id" integer, "cellared_at" datetime, "year" varchar(255), "bottle_size_id" integer, "name" varchar(255), "brewery_name" varchar(255), "removed_at" datetime, "finish_aging_at" datetime);
CREATE TABLE "bottle_sizes" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "created_at" datetime, "updated_at" datetime, "sort_order" integer);
CREATE TABLE "brew_types" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "breweries" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "country" varchar(255), "state" varchar(255), "city" varchar(255), "created_at" datetime, "updated_at" datetime, "sanitized_name" varchar(255));
CREATE TABLE "brews" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "brewery_id" integer, "created_at" datetime, "updated_at" datetime, "brew_type_id" integer, "ibus" integer, "abv" float, "suggested_aging_years" integer, "suggested_aging_months" integer);
CREATE TABLE "cellars" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "created_at" datetime, "updated_at" datetime, "user_id" integer);
CREATE TABLE "comments" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "title" varchar(50) DEFAULT '', "comment" text, "commentable_id" integer, "commentable_type" varchar(255), "user_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "events" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "created_at" datetime, "updated_at" datetime, "source_type" varchar(255), "source_id" integer, "formatter_type" varchar(255));
CREATE TABLE "newsletter_signups" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "email" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "password_reset_attempts" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "security_token" varchar(255), "created_at" datetime, "updated_at" datetime, "confirmed" boolean DEFAULT 'f');
CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE TABLE "tastings" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "created_at" datetime, "updated_at" datetime, "brew_id" integer, "cellared_at" datetime);
CREATE TABLE "uploaded_beer_records" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "job_id" varchar(255), "brewery" varchar(255), "variety" varchar(255), "bottle_size" varchar(255), "quantity" varchar(255), "brew_style" varchar(255), "year" varchar(255), "cellared_at" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "email" varchar(255), "password_hash" varchar(255), "created_at" datetime, "updated_at" datetime, "username" varchar(255), "email_consent" boolean DEFAULT 'f', "country" varchar(255), "state" varchar(255), "city" varchar(255), "should_show_own_events" boolean DEFAULT 't', "should_receive_email_notifications" boolean DEFAULT 't');
CREATE TABLE "wikis" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "for_id" integer, "for_type" varchar(255), "markup" text, "revision" integer, "created_at" datetime, "updated_at" datetime);
CREATE INDEX "index_comments_on_commentable_id" ON "comments" ("commentable_id");
CREATE INDEX "index_comments_on_commentable_type" ON "comments" ("commentable_type");
CREATE INDEX "index_comments_on_user_id" ON "comments" ("user_id");
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
INSERT INTO schema_migrations (version) VALUES ('20110118232403');

INSERT INTO schema_migrations (version) VALUES ('20110118232433');

INSERT INTO schema_migrations (version) VALUES ('20110118232524');

INSERT INTO schema_migrations (version) VALUES ('20110118232549');

INSERT INTO schema_migrations (version) VALUES ('20110118233131');

INSERT INTO schema_migrations (version) VALUES ('20110118233254');

INSERT INTO schema_migrations (version) VALUES ('20110119000425');

INSERT INTO schema_migrations (version) VALUES ('20110119184009');

INSERT INTO schema_migrations (version) VALUES ('20110119213022');

INSERT INTO schema_migrations (version) VALUES ('20110119221656');

INSERT INTO schema_migrations (version) VALUES ('20110119224908');

INSERT INTO schema_migrations (version) VALUES ('20110120180949');

INSERT INTO schema_migrations (version) VALUES ('20110120212242');

INSERT INTO schema_migrations (version) VALUES ('20110121014543');

INSERT INTO schema_migrations (version) VALUES ('20110121044121');

INSERT INTO schema_migrations (version) VALUES ('20110121044202');

INSERT INTO schema_migrations (version) VALUES ('20110121172830');

INSERT INTO schema_migrations (version) VALUES ('20110121172901');

INSERT INTO schema_migrations (version) VALUES ('20110122020851');

INSERT INTO schema_migrations (version) VALUES ('20110122184428');

INSERT INTO schema_migrations (version) VALUES ('20110122190425');

INSERT INTO schema_migrations (version) VALUES ('20110122190456');

INSERT INTO schema_migrations (version) VALUES ('20110122190540');

INSERT INTO schema_migrations (version) VALUES ('20110122190558');

INSERT INTO schema_migrations (version) VALUES ('20110122193351');

INSERT INTO schema_migrations (version) VALUES ('20110122205541');

INSERT INTO schema_migrations (version) VALUES ('20110122205857');

INSERT INTO schema_migrations (version) VALUES ('20110122205937');

INSERT INTO schema_migrations (version) VALUES ('20110122213507');

INSERT INTO schema_migrations (version) VALUES ('20110122214012');

INSERT INTO schema_migrations (version) VALUES ('20110123201435');

INSERT INTO schema_migrations (version) VALUES ('20110124062606');

INSERT INTO schema_migrations (version) VALUES ('20110124062622');

INSERT INTO schema_migrations (version) VALUES ('20110124062636');

INSERT INTO schema_migrations (version) VALUES ('20110124174508');

INSERT INTO schema_migrations (version) VALUES ('20110124232040');

INSERT INTO schema_migrations (version) VALUES ('20110125072803');

INSERT INTO schema_migrations (version) VALUES ('20110125221524');

INSERT INTO schema_migrations (version) VALUES ('20110126004751');

INSERT INTO schema_migrations (version) VALUES ('20110126190705');

INSERT INTO schema_migrations (version) VALUES ('20110127190300');

INSERT INTO schema_migrations (version) VALUES ('20110131040602');

INSERT INTO schema_migrations (version) VALUES ('20110202181212');

INSERT INTO schema_migrations (version) VALUES ('20110203014244');

INSERT INTO schema_migrations (version) VALUES ('20110203015945');

INSERT INTO schema_migrations (version) VALUES ('20110204223726');

INSERT INTO schema_migrations (version) VALUES ('20110209003219');

INSERT INTO schema_migrations (version) VALUES ('20110210063116');

INSERT INTO schema_migrations (version) VALUES ('20110214222511');