BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "auth_group" (
	"id"	integer NOT NULL,
	"name"	varchar(150) NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "auth_group_permissions" (
	"id"	integer NOT NULL,
	"group_id"	integer NOT NULL,
	"permission_id"	integer NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("group_id") REFERENCES "auth_group"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("permission_id") REFERENCES "auth_permission"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "auth_permission" (
	"id"	integer NOT NULL,
	"content_type_id"	integer NOT NULL,
	"codename"	varchar(100) NOT NULL,
	"name"	varchar(255) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("content_type_id") REFERENCES "django_content_type"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "auth_user" (
	"id"	integer NOT NULL,
	"password"	varchar(128) NOT NULL,
	"last_login"	datetime,
	"is_superuser"	bool NOT NULL,
	"username"	varchar(150) NOT NULL UNIQUE,
	"last_name"	varchar(150) NOT NULL,
	"email"	varchar(254) NOT NULL,
	"is_staff"	bool NOT NULL,
	"is_active"	bool NOT NULL,
	"date_joined"	datetime NOT NULL,
	"first_name"	varchar(150) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "auth_user_groups" (
	"id"	integer NOT NULL,
	"user_id"	integer NOT NULL,
	"group_id"	integer NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("group_id") REFERENCES "auth_group"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "auth_user_user_permissions" (
	"id"	integer NOT NULL,
	"user_id"	integer NOT NULL,
	"permission_id"	integer NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("permission_id") REFERENCES "auth_permission"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "django_admin_log" (
	"id"	integer NOT NULL,
	"object_id"	text,
	"object_repr"	varchar(200) NOT NULL,
	"action_flag"	smallint unsigned NOT NULL CHECK("action_flag" >= 0),
	"change_message"	text NOT NULL,
	"content_type_id"	integer,
	"user_id"	integer NOT NULL,
	"action_time"	datetime NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("content_type_id") REFERENCES "django_content_type"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("user_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "django_content_type" (
	"id"	integer NOT NULL,
	"app_label"	varchar(100) NOT NULL,
	"model"	varchar(100) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "django_migrations" (
	"id"	integer NOT NULL,
	"app"	varchar(255) NOT NULL,
	"name"	varchar(255) NOT NULL,
	"applied"	datetime NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "django_session" (
	"session_key"	varchar(40) NOT NULL,
	"session_data"	text NOT NULL,
	"expire_date"	datetime NOT NULL,
	PRIMARY KEY("session_key")
);
INSERT INTO "auth_permission" VALUES (1,1,'add_logentry','Can add log entry');
INSERT INTO "auth_permission" VALUES (2,1,'change_logentry','Can change log entry');
INSERT INTO "auth_permission" VALUES (3,1,'delete_logentry','Can delete log entry');
INSERT INTO "auth_permission" VALUES (4,1,'view_logentry','Can view log entry');
INSERT INTO "auth_permission" VALUES (5,2,'add_permission','Can add permission');
INSERT INTO "auth_permission" VALUES (6,2,'change_permission','Can change permission');
INSERT INTO "auth_permission" VALUES (7,2,'delete_permission','Can delete permission');
INSERT INTO "auth_permission" VALUES (8,2,'view_permission','Can view permission');
INSERT INTO "auth_permission" VALUES (9,3,'add_group','Can add group');
INSERT INTO "auth_permission" VALUES (10,3,'change_group','Can change group');
INSERT INTO "auth_permission" VALUES (11,3,'delete_group','Can delete group');
INSERT INTO "auth_permission" VALUES (12,3,'view_group','Can view group');
INSERT INTO "auth_permission" VALUES (13,4,'add_user','Can add user');
INSERT INTO "auth_permission" VALUES (14,4,'change_user','Can change user');
INSERT INTO "auth_permission" VALUES (15,4,'delete_user','Can delete user');
INSERT INTO "auth_permission" VALUES (16,4,'view_user','Can view user');
INSERT INTO "auth_permission" VALUES (17,5,'add_contenttype','Can add content type');
INSERT INTO "auth_permission" VALUES (18,5,'change_contenttype','Can change content type');
INSERT INTO "auth_permission" VALUES (19,5,'delete_contenttype','Can delete content type');
INSERT INTO "auth_permission" VALUES (20,5,'view_contenttype','Can view content type');
INSERT INTO "auth_permission" VALUES (21,6,'add_session','Can add session');
INSERT INTO "auth_permission" VALUES (22,6,'change_session','Can change session');
INSERT INTO "auth_permission" VALUES (23,6,'delete_session','Can delete session');
INSERT INTO "auth_permission" VALUES (24,6,'view_session','Can view session');
INSERT INTO "auth_user" VALUES (1,'pbkdf2_sha256$1000000$4scuJhFWemhk8N9TLeJsa1$BGopIM1Q0MM+gj6FGS4Whyx2QIAlswJlEb/1eREV1S4=','2026-03-06 10:22:37.105557',1,'nyv','nasypaeva','nyv@test.ru',1,1,'2026-03-05 09:27:57','yana');
INSERT INTO "auth_user" VALUES (2,'pbkdf2_sha256$1000000$LpFp07RBYxDUuLRCuRMIXh$EBJoKy2ldOCPfRjiyAkh8OHLoc/MVSfB5rc6pDHn+64=',NULL,0,'afs','','',0,1,'2026-03-05 10:24:50.629575','');
INSERT INTO "auth_user" VALUES (3,'pbkdf2_sha256$1000000$DRLEVKzJwpzNx22VdIu0Ed$g6JPgHyW3T0TUA2Uu8toAI1Ar/Q1RsQQHQBVu2mPdso=',NULL,0,'sdf','','',0,1,'2026-03-05 10:25:05.607665','');
INSERT INTO "auth_user" VALUES (4,'pbkdf2_sha256$1000000$4LPJ50Z0DrZ69yQFTlSEWL$/U3ChelKyDf5N8+HjR/Hd0qPrlutSvq8YR6YHOvLS2I=',NULL,0,'ghj','','',0,1,'2026-03-06 10:21:09.763270','');
INSERT INTO "auth_user" VALUES (5,'pbkdf2_sha256$1000000$ynrCfBmHD2Ob3JCOojuC6Q$IQS6JbSgXnoS8H2hzLC1KE4jzxnms0b126pNAjvL2Rw=',NULL,0,'qwer','','',0,1,'2026-03-06 10:21:25.598110','');
INSERT INTO "auth_user" VALUES (6,'pbkdf2_sha256$1000000$KoCOlf1iVAlKIQsXD8FcGR$s67ZZJrhEY2yutpGGjuweH2m5l3n/mr6CjKpBgfxYYs=',NULL,0,'hjkl','','',0,1,'2026-03-11 07:46:33.593762','');
INSERT INTO "auth_user" VALUES (7,'pbkdf2_sha256$1000000$lfS6CbDErI0ZHGovDZ6Ue8$hbrM24IyHg9h1FH0b9zSQ9ZKg/pwUKdwm9iRjOU9MGA=',NULL,0,'vl;d','','',0,1,'2026-03-11 07:48:09.932234','');
INSERT INTO "auth_user" VALUES (8,'pbkdf2_sha256$1000000$nZDlN0wLtCTcW2lR17qSNf$hOqVg1AA9J162zN5cKR4QfbxFuqRnHGI9Hiad8iOU8Q=',NULL,0,'vbnh7yb','','',0,1,'2026-03-11 07:53:03.993965','');
INSERT INTO "auth_user" VALUES (9,'pbkdf2_sha256$1000000$c3tRs76yBqdDfnZ8VZFocc$yNU7y2atfQKjpH4v7tbd/753PVFK9ZwL/b3kUWUuOWA=','2026-03-12 09:56:05.802147',0,'mister','','',0,1,'2026-03-12 09:55:04.955634','');
INSERT INTO "auth_user" VALUES (10,'pbkdf2_sha256$1000000$gt5X7e7NVdKofKVHNLv3Kd$Z3GgWhnfWbIFft/NofUeE59j2YhNs7oQ3Q2SSfqeIwI=',NULL,0,'NYV','','',0,1,'2026-03-13 09:09:39.080930','');
INSERT INTO "django_admin_log" VALUES (1,'1','nyv',2,'[{"changed": {"fields": ["First name", "Last name"]}}]',4,1,'2026-03-05 09:38:54.169742');
INSERT INTO "django_content_type" VALUES (1,'admin','logentry');
INSERT INTO "django_content_type" VALUES (2,'auth','permission');
INSERT INTO "django_content_type" VALUES (3,'auth','group');
INSERT INTO "django_content_type" VALUES (4,'auth','user');
INSERT INTO "django_content_type" VALUES (5,'contenttypes','contenttype');
INSERT INTO "django_content_type" VALUES (6,'sessions','session');
INSERT INTO "django_migrations" VALUES (1,'contenttypes','0001_initial','2026-03-05 09:26:17.458918');
INSERT INTO "django_migrations" VALUES (2,'auth','0001_initial','2026-03-05 09:26:17.470200');
INSERT INTO "django_migrations" VALUES (3,'admin','0001_initial','2026-03-05 09:26:17.477253');
INSERT INTO "django_migrations" VALUES (4,'admin','0002_logentry_remove_auto_add','2026-03-05 09:26:17.484196');
INSERT INTO "django_migrations" VALUES (5,'admin','0003_logentry_add_action_flag_choices','2026-03-05 09:26:17.489417');
INSERT INTO "django_migrations" VALUES (6,'contenttypes','0002_remove_content_type_name','2026-03-05 09:26:17.500592');
INSERT INTO "django_migrations" VALUES (7,'auth','0002_alter_permission_name_max_length','2026-03-05 09:26:17.506983');
INSERT INTO "django_migrations" VALUES (8,'auth','0003_alter_user_email_max_length','2026-03-05 09:26:17.513418');
INSERT INTO "django_migrations" VALUES (9,'auth','0004_alter_user_username_opts','2026-03-05 09:26:17.518540');
INSERT INTO "django_migrations" VALUES (10,'auth','0005_alter_user_last_login_null','2026-03-05 09:26:17.525266');
INSERT INTO "django_migrations" VALUES (11,'auth','0006_require_contenttypes_0002','2026-03-05 09:26:17.527232');
INSERT INTO "django_migrations" VALUES (12,'auth','0007_alter_validators_add_error_messages','2026-03-05 09:26:17.532543');
INSERT INTO "django_migrations" VALUES (13,'auth','0008_alter_user_username_max_length','2026-03-05 09:26:17.539507');
INSERT INTO "django_migrations" VALUES (14,'auth','0009_alter_user_last_name_max_length','2026-03-05 09:26:17.547108');
INSERT INTO "django_migrations" VALUES (15,'auth','0010_alter_group_name_max_length','2026-03-05 09:26:17.553850');
INSERT INTO "django_migrations" VALUES (16,'auth','0011_update_proxy_permissions','2026-03-05 09:26:17.558706');
INSERT INTO "django_migrations" VALUES (17,'auth','0012_alter_user_first_name_max_length','2026-03-05 09:26:17.565044');
INSERT INTO "django_migrations" VALUES (18,'sessions','0001_initial','2026-03-05 09:26:17.569467');
INSERT INTO "django_session" VALUES ('j2ixp7ak5kpc4ztji658pugw9jq8fyv7','.eJxVjMsOgkAMAP-lZ7MpS_chR-98AyltEdRAwsLJ-O-GhINeZybzho73bez2Yms3KTRQweWX9SxPmw-hD57vi5Nl3tapd0fiTltcu6i9bmf7Nxi5jNBAxoASLJpGwUwhq9cohKxEmbjmeFXCiLk2GhJL3VvyPqRq8CgpRPh8AdJZNz4:1vy566:-zR4proZSX48-ToFs22W220TWUNxMsIlgAIt9D73FCQ','2026-03-19 09:34:22.012522');
INSERT INTO "django_session" VALUES ('vos0kjhppadf1v528mbc0r8j2dpwvqdb','.eJxVjMsOgkAMAP-lZ7MpS_chR-98AyltEdRAwsLJ-O-GhINeZybzho73bez2Yms3KTRQweWX9SxPmw-hD57vi5Nl3tapd0fiTltcu6i9bmf7Nxi5jNBAxoASLJpGwUwhq9cohKxEmbjmeFXCiLk2GhJL3VvyPqRq8CgpRPh8AdJZNz4:1vySKL:w5lY4zHGqR6jhVE7ciyhBLHfR-bY1UV6C5qUgyslQp8','2026-03-20 10:22:37.107510');
INSERT INTO "django_session" VALUES ('qewtob6wi5txqdnlk1c1xju3ff4zlbx1','.eJxVjLsOwjAMAP_FM4raJHbjjux8Q5XYKS2gROpjQvw7qtQB1rvTvWGI-zYN-5qXYVbogeHyy1KUZy6H0Ecs92qklm2ZkzkSc9rV3Krm1_Vs_wZTXCfogTqUJpALjUe2gduRkFuSBpFRVV1ECh3bnEjJR5us82MWCR6DOJvh8wWoTjba:1w0clx:YGONpNDoAjaQ2bB8YXRqG8DUrNRBMftl7_JZC3-XINA','2026-03-26 09:56:05.805570');
CREATE INDEX IF NOT EXISTS "auth_group_permissions_group_id_b120cbf9" ON "auth_group_permissions" (
	"group_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "auth_group_permissions_group_id_permission_id_0cd325b0_uniq" ON "auth_group_permissions" (
	"group_id",
	"permission_id"
);
CREATE INDEX IF NOT EXISTS "auth_group_permissions_permission_id_84c5c92e" ON "auth_group_permissions" (
	"permission_id"
);
CREATE INDEX IF NOT EXISTS "auth_permission_content_type_id_2f476e4b" ON "auth_permission" (
	"content_type_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "auth_permission_content_type_id_codename_01ab375a_uniq" ON "auth_permission" (
	"content_type_id",
	"codename"
);
CREATE INDEX IF NOT EXISTS "auth_user_groups_group_id_97559544" ON "auth_user_groups" (
	"group_id"
);
CREATE INDEX IF NOT EXISTS "auth_user_groups_user_id_6a12ed8b" ON "auth_user_groups" (
	"user_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "auth_user_groups_user_id_group_id_94350c0c_uniq" ON "auth_user_groups" (
	"user_id",
	"group_id"
);
CREATE INDEX IF NOT EXISTS "auth_user_user_permissions_permission_id_1fbb5f2c" ON "auth_user_user_permissions" (
	"permission_id"
);
CREATE INDEX IF NOT EXISTS "auth_user_user_permissions_user_id_a95ead1b" ON "auth_user_user_permissions" (
	"user_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "auth_user_user_permissions_user_id_permission_id_14a6b632_uniq" ON "auth_user_user_permissions" (
	"user_id",
	"permission_id"
);
CREATE INDEX IF NOT EXISTS "django_admin_log_content_type_id_c4bce8eb" ON "django_admin_log" (
	"content_type_id"
);
CREATE INDEX IF NOT EXISTS "django_admin_log_user_id_c564eba6" ON "django_admin_log" (
	"user_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "django_content_type_app_label_model_76bd3d3b_uniq" ON "django_content_type" (
	"app_label",
	"model"
);
CREATE INDEX IF NOT EXISTS "django_session_expire_date_a5c62663" ON "django_session" (
	"expire_date"
);
COMMIT;
