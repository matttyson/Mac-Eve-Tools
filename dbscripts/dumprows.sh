#!/bin/bash

CATEGORIES="6,7,8,16"
SCRIPT=dump_table.py

/usr/bin/python $SCRIPT -t chrRaces -f $1 \
-q "SELECT raceID, raceName, iconID FROM chrRaces;";

/usr/bin/python $SCRIPT -t invMarketGroups -f $1 \
-q "SELECT marketGroupID, parentGroupID, marketGroupName, description, iconID, hasTypes FROM invMarketGroups;"

/usr/bin/python $SCRIPT -t invCategories -f $1 \
-q "SELECT categoryID,categoryName,iconID
FROM invCategories
WHERE published = 1
AND categoryID IN ($CATEGORIES);"

/usr/bin/python $SCRIPT -t invGroups -f $1 \
-q "SELECT groupID,categoryID,groupName,iconID
FROM invGroups
WHERE published = 1
AND categoryID IN ($CATEGORIES);"

/usr/bin/python $SCRIPT -t invTypes -f $1 \
-q "SELECT typeID,groupID,typeName,description,iconID,radius,mass,volume,capacity,raceID,basePrice,marketGroupID 
FROM invTypes 
WHERE published = 1
AND groupID IN (SELECT groupID FROM invGroups WHERE published = 1 AND categoryID IN ($CATEGORIES));"

/usr/bin/python $SCRIPT -t dgmTypeAttributes -f $1 \
-q" SELECT typeID, attributeID, valueInt, valueFloat
FROM dgmTypeAttributes
WHERE typeID IN (SELECT typeID FROM invTypes WHERE published = 1 AND groupID IN (SELECT groupID FROM invGroups WHERE categoryID IN ($CATEGORIES)));"

/usr/bin/python $SCRIPT -t dgmAttributeTypes -f $1 \
-q "SELECT attributeID, attributeName, description, iconID, defaultValue, displayName, unitID, stackable, highIsGood, categoryID
FROM dgmAttributeTypes
WHERE published = 1
AND attributeID IN 
	(SELECT attributeID FROM dgmTypeAttributes WHERE published = 1 AND typeID IN 
			(SELECT typeID FROM invTypes WHERE groupID IN 
						(SELECT groupID FROM invGroups WHERE categoryID IN ($CATEGORIES))));"

/usr/bin/python $SCRIPT -t invMetaTypes -f $1 \
-q "SELECT typeID, parentTypeID, metaGroupID FROM invMetaTypes WHERE typeID IN
	(SELECT typeID FROM invTypes WHERE published = 1 AND groupID IN (SELECT groupID FROM invGroups WHERE categoryID IN ($CATEGORIES)));"


/usr/bin/python $SCRIPT -t invMetaGroups -f $1 \
-q "SELECT metaGroupID, metaGroupName FROM invMetaGroups WHERE metaGroupID IN (1,2,3,4,5,6,14);"

/usr/bin/python $SCRIPT -t eveUnits -f $1 \
-q "SELECT unitID, unitName, displayName FROM eveUnits;"

#/usr/bin/python $SCRIPT -t eveGraphics -f $1 \
#-q "SELECT graphicID, icon FROM eveGraphics WHERE icon <> '';"

/usr/bin/python $SCRIPT -t trnTranslations -f $1 \
-q "SELECT tcID, keyID, languageID, text FROM trnTranslations WHERE languageID IN ('DE','RU');"

/usr/bin/python $SCRIPT -t trnTranslationColumns -f $1 \
-q "SELECT tcGroupID,tcID,tableName,columnName,masterID FROM trnTranslationColumns;"

/usr/bin/python $SCRIPT -t crtCategories -f $1 \
-q "SELECT categoryID, categoryName FROM crtCategories WHERE categoryID <> 17;"

/usr/bin/python $SCRIPT -t crtCertificates -f $1 \
-q "SELECT certificateID, categoryID, classID, grade, description FROM crtCertificates;";

/usr/bin/python $SCRIPT -t crtClasses -f $1 \
-q "SELECT classID, className FROM crtClasses;";

/usr/bin/python $SCRIPT -t crtRelationships -f $1 \
-q "SELECT relationshipID, parentID, parentTypeID, parentLevel, childID from crtRelationships;";

/usr/local/bin/perl dump_pre.pl >> $1
/usr/bin/python dump_attrs.py -f $1

