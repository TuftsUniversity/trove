-- MySQL dump 10.13  Distrib 5.6.50, for Linux (x86_64)
--
-- Host: localhost    Database: trove
-- ------------------------------------------------------
-- Server version	5.6.50-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `hyrax_collection_types`
--

DROP TABLE IF EXISTS `hyrax_collection_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hyrax_collection_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `description` text COLLATE utf8_bin,
  `machine_id` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `nestable` tinyint(1) NOT NULL DEFAULT '1',
  `discoverable` tinyint(1) NOT NULL DEFAULT '1',
  `sharable` tinyint(1) NOT NULL DEFAULT '1',
  `allow_multiple_membership` tinyint(1) NOT NULL DEFAULT '1',
  `require_membership` tinyint(1) NOT NULL DEFAULT '0',
  `assigns_workflow` tinyint(1) NOT NULL DEFAULT '0',
  `assigns_visibility` tinyint(1) NOT NULL DEFAULT '0',
  `share_applies_to_new_works` tinyint(1) NOT NULL DEFAULT '1',
  `brandable` tinyint(1) NOT NULL DEFAULT '1',
  `badge_color` varchar(255) COLLATE utf8_bin DEFAULT '#663333',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_hyrax_collection_types_on_machine_id` (`machine_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hyrax_collection_types`
--

LOCK TABLES `hyrax_collection_types` WRITE;
/*!40000 ALTER TABLE `hyrax_collection_types` DISABLE KEYS */;
INSERT INTO `hyrax_collection_types` VALUES (1,'User Collection','A User Collection can be created by any user to organize their works.','user_collection',1,1,1,1,0,0,0,0,1,'#705070'),(2,'Admin Set','An aggregation of works that is intended to help with administrative control. Admin Sets provide a way of defining behaviors and policies around a set of works.','admin_set',0,0,1,0,1,1,1,1,0,'#405060'),(3,'Course Collection','For Trove','course_collection',1,1,1,1,0,0,0,1,1,'#663333'),(4,'Personal Collection','For Trove','personal_collection',1,1,1,1,0,0,0,1,1,'#663333');
/*!40000 ALTER TABLE `hyrax_collection_types` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-08-30 10:54:38
