-- -----------------------------------------------------------------------------
-- $Id: mysql_update_tf-b4rt-61.to.tf-b4rt-7.sql 2607 2007-03-09 19:33:07Z b4rt $
-- -----------------------------------------------------------------------------
--
-- MySQL-Update-File for 'Torrentflux-2.1-b4rt-7'.
-- Updates a 'Torrentflux 2.1-b4rt-61' Database to a 'Torrentflux 2.1-b4rt-7'.
--
-- This Stuff is provided 'as-is'. In no way will the author be held
-- liable for any damages to your soft- or hardware from this.
-- -----------------------------------------------------------------------------

--
-- inserts
--
INSERT INTO tf_settings VALUES ('metainfoclient','btshowmetainfo.py');
INSERT INTO tf_settings VALUES ('enable_restrictivetview','1');

