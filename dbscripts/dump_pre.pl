use warnings;
use strict;
use 5.010;


use DBI;

my $q_type_id = 'SELECT typeID FROM invTypes where published = 1 AND groupID IN (SELECT groupID FROM invGroups WHERE categoryID IN (6,7,8,16));';

my $conn = DBI->connect('DBI:mysql:eve','matt',undef) or die 'Could not connect';

my $table_query = <<EOF;
SELECT taSkill.typeID,
	COALESCE(taSkill.valueInt,FLOOR(taSkill.valueFloat)) as skillTypeID, 
	COALESCE(taLevel.valueInt,FLOOR(taLevel.valueFloat)) as skillLevel
FROM 
	dgmTypeAttributes taSkill JOIN dgmAttributeTypes atSkill ON (taSkill.attributeID = atSkill.attributeID),
	dgmTypeAttributes taLevel JOIN dgmAttributeTypes atLevel ON (taLevel.attributeID = atLevel.attributeID)
WHERE taSkill.typeID = ?
	AND taSkill.typeID = taLevel.typeID
	AND atLevel.categoryID = atSkill.categoryID
	AND atSkill.attributeName REGEXP \'^requiredSkill[0-9]\$\'
	AND atLevel.attributeName REGEXP \'^requiredSkill[0-9]Level\$\'
	AND atLevel.attributeName REGEXP atSkill.attributeName;
EOF

my $cursor = $conn->prepare($q_type_id) or die;
$cursor->execute() or die;

my $skill_cursor = $conn->prepare($table_query) or die;

say 'BEGIN TRANSACTION;';

my $result;
while($result = $cursor->fetchrow_arrayref()){
	my $typeid = $result->[0];

	$skill_cursor->execute(@$result) or die 'error executing query';

	my $row;
	my $i = 0;
	while($row = $skill_cursor->fetchrow_arrayref()){
		say "INSERT INTO typePrerequisites VALUES ($row->[0],$row->[1],$row->[2],$i);";
		$i++;
	}

}

say 'COMMIT TRANSACTION;';


$conn->disconnect();


