CREATE TABLE "chrRaces" (
	  "raceID" tinyint(3) NOT NULL,
	  "raceName" varchar(100) default NULL,
	  "graphicID" smallint(6) default NULL,
	  PRIMARY KEY  ("raceID")
);
CREATE TABLE "invMarketGroups" (
	  "marketGroupID" smallint(6) NOT NULL,
	  "parentGroupID" smallint(6) default NULL,
	  "marketGroupName" varchar(100) default NULL,
	  "description" varchar(3000) default NULL,
	  "graphicID" smallint(6) default NULL,
	  "hasTypes" tinyint(1) default NULL,
	  PRIMARY KEY  ("marketGroupID")
);
CREATE INDEX "invMarketGroups_IX_graphicID" ON "invMarketGroups" ("graphicID");
CREATE INDEX "invMarketGroups_IX_parentGroupID" ON "invMarketGroups" ("parentGroupID");
CREATE INDEX "chrRaces_IX_graphicID" ON "chrRaces" ("graphicID");
CREATE TABLE "invTypes" (
  "typeID" smallint(6) NOT NULL,
  "groupID" smallint(6) default NULL,
  "typeName" varchar(100) default NULL,
  "description" varchar(3000) default NULL,
  "graphicID" smallint(6) default NULL,
  "radius" double default NULL,
  "mass" double default NULL,
  "volume" double default NULL,
  "capacity" double default NULL,
  "raceID" tinyint(3) default NULL,
  "basePrice" double default NULL,
  "marketGroupID" smallint(6) default NULL,
  PRIMARY KEY  ("typeID")
);
CREATE INDEX "invTypes_IX_Group" ON "invTypes" ("groupID");
CREATE INDEX "invTypes_IX_graphicID" ON "invTypes" ("graphicID");
CREATE INDEX "invTypes_IX_marketGroupID" ON "invTypes" ("marketGroupID");
CREATE INDEX "invTypes_IX_raceID" ON "invTypes" ("raceID");

CREATE TABLE "invGroups" (
  "groupID" smallint(6) NOT NULL,
  "categoryID" tinyint(3) default NULL,
  "groupName" varchar(100) default NULL,
  "graphicID" smallint(6) default NULL,
  PRIMARY KEY  ("groupID")
);
CREATE INDEX "invGroups_IX_category" ON "invGroups" ("categoryID");
CREATE INDEX "invGroups_IX_graphicID" ON "invGroups" ("graphicID");

CREATE TABLE "invCategories" (
  "categoryID" tinyint(3) NOT NULL,
  "categoryName" varchar(100) default NULL,
  "graphicID" smallint(6) default NULL,
  PRIMARY KEY  ("categoryID")
);
CREATE INDEX "invCategories_IX_graphicID" ON "invCategories" ("graphicID");

CREATE TABLE "dgmTypeAttributes" (
  "typeID" smallint(6) NOT NULL,
  "attributeID" smallint(6) NOT NULL,
  "valueInt" int(11) default NULL,
  "valueFloat" double default NULL,
  PRIMARY KEY  ("typeID","attributeID")
);
CREATE INDEX "dgmTypeAttributes_IX_attributeID" ON "dgmTypeAttributes" ("attributeID");

CREATE TABLE "dgmAttributeTypes" (
  "attributeID" smallint(6) NOT NULL,
  "attributeName" varchar(100) default NULL,
  "description" varchar(1000) default NULL,
  "graphicID" smallint(6) default NULL,
  "defaultValue" double default NULL,
  "displayName" varchar(100) default NULL,
  "unitID" tinyint(3) default NULL,
  "stackable" tinyint(1) default NULL,
  "highIsGood" tinyint(1) default NULL,
  "categoryID" tinyint(3) default NULL,
  PRIMARY KEY  ("attributeID")
);
CREATE INDEX "dgmAttributeTypes_IX_categoryID" ON "dgmAttributeTypes" ("categoryID");
CREATE INDEX "dgmAttributeTypes_IX_graphicID" ON "dgmAttributeTypes" ("graphicID");
CREATE INDEX "dgmAttributeTypes_IX_unitID" ON "dgmAttributeTypes" ("unitID");

CREATE TABLE "typePrerequisites"(
	"typeID" smallint(6),
	"skillTypeID" smallint(6),
	"skillLevel" smallint(2),
	"skillOrder" smallint(2)
);
CREATE INDEX "typePrerequisites_IX_typeID" ON "typePrerequisites" ("typeID");

CREATE TABLE "invMetaTypes" (
	  "typeID" smallint(6) NOT NULL,
	  "parentTypeID" smallint(6) default NULL,
	  "metaGroupID" smallint(6) default NULL,
	  PRIMARY KEY  ("typeID")
);
CREATE INDEX "invMetaTypes_IX_metaGroupID" ON "invMetaTypes" ("metaGroupID");
CREATE INDEX "invMetaTypes_IX_parentTypeID" ON "invMetaTypes" ("parentTypeID");

CREATE TABLE "invMetaGroups" (
	  "metaGroupID" smallint(6) NOT NULL,
	  "metaGroupName" varchar(100) default NULL,
	  PRIMARY KEY  ("metaGroupID")
);
CREATE TABLE "eveUnits" (
	  "unitID" tinyint(3) NOT NULL,
	  "unitName" varchar(100) default NULL,
	  "displayName" varchar(20) default NULL,
	  PRIMARY KEY  ("unitID")
);
CREATE INDEX "eveUnits_IX_unitID" ON "eveUnits" ("unitID");

CREATE TABLE "eveGraphics" (
	  "graphicID" smallint(6) NOT NULL,
	  "icon" varchar(100) default NULL,
	  PRIMARY KEY  ("graphicID")
);
CREATE INDEX "eveGraphics_IX_graphicID" ON "eveGraphics" ("graphicID");

CREATE TABLE "metAttributeTypes" (
	"attributeID" smallint(6) NOT NULL,
	"unitID" tinyint(3),
	"graphicID" smallint(6),
	"displayName" varchar(32),
	"attributeName" varchar(32),
	"displayType" smallint(6),
	PRIMARY KEY ("attributeID")
);

CREATE TABLE "trnTranslationColumns" (
	"tcGroupID" smallint(6),
	"tcID" smallint(6) NOT NULL,
	"tableName" varchar(256) NOT NULL,
	"columnName" varchar(128) NOT NULL,
	"masterID" varchar(128),
	PRIMARY KEY ("tcID")
);

CREATE TABLE "trnTranslations" (
	"tcID" smallint(6),
	"keyID" int(11),
	"languageID" char(2),
	"text" varchar(16000),
	PRIMARY KEY("tcID","keyID","languageID")
);

CREATE TABLE "crtCategories" (
	"categoryID" smallint(6),
	"categoryName" varchar(256),
	PRIMARY KEY("categoryID")
);

CREATE TABLE "crtCertificates" (
	"certificateID" int(11),
	"categoryID" smallint(6),
	"classID" int(11),
	"grade" smallint(6),
	"description" varchar(500),
	PRIMARY KEY("certificateID")
);

CREATE TABLE "crtClasses" (
	"classID" int(11),
	"className" varchar(256),
	PRIMARY KEY("classID")
);

CREATE TABLE "crtRelationships" (
	"relationshipID" int(11),
	"parentID" int(11),
	"parentTypeID" smallint(6),
	"parentLevel" smallint(6),
	"childID" int(11),
	PRIMARY KEY("relationshipID")
);



CREATE TABLE "version"(
	"versionNum" smallint(6),
	"versionName" text(32)
);

CREATE TABLE "metLanguage"(
	"languageNum" smallint(6),
	"languageCode" char(2),
	"languageName" varchar(16),
	PRIMARY KEY ("languageNum")
);

INSERT INTO metLanguage VALUES(0,'EN','English');
INSERT INTO metLanguage VALUES(1,'DE','German');
INSERT INTO metLanguage VALUES(2,'RU','Russian');
