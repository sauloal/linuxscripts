-- -----------------------------------------------------------------------------
-- $Id: mysql_update_tf-b4rt-82.to.tf-b4rt-83.sql 2607 2007-03-09 19:33:07Z b4rt $
-- -----------------------------------------------------------------------------
--
-- MySQL-Update-File for 'Torrentflux-2.1-b4rt-83'.
-- Updates a 'Torrentflux 2.1-b4rt-82' Database to a 'Torrentflux 2.1-b4rt-83'.
--
-- This Stuff is provided 'as-is'. In no way will the author be held
-- liable for any damages to your soft- or hardware from this.
-- -----------------------------------------------------------------------------

--
-- inserts
--
INSERT INTO tf_settings VALUES ('enable_bulkops','1');
INSERT INTO tf_settings VALUES ('week_start','Monday');
INSERT INTO tf_settings VALUES ('month_start','1');
INSERT INTO tf_settings VALUES ('hack_multiupload_rows','6');
INSERT INTO tf_settings VALUES ('hack_goodlookstats_settings','63');
INSERT INTO tf_settings VALUES ('ui_indexrefresh','1');
