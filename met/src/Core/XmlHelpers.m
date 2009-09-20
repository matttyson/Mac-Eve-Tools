/*
 This file is part of Mac Eve Tools.
 
 Mac Eve Tools is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Mac Eve Tools is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Mac Eve Tools.  If not, see <http://www.gnu.org/licenses/>.
 
 Copyright Matt Tyson, 2009.
 */


#import "XmlHelpers.m"

#import <libxml/tree.h>
#import <libxml/parser.h>


xmlAttr* xmlNewPropString(xmlNode *node, xmlChar* str1, NSString *str2)
{
	return xmlNewProp(node,str1,(xmlChar*)[str2 UTF8String]);
}

xmlNode*
findChildNode(xmlNode *node, xmlChar *childName)
{
	xmlNode *cur_node;
	
	for(cur_node = node->children; cur_node != NULL; cur_node = cur_node->next){
		if(cur_node->type != XML_ELEMENT_NODE){
			continue;
		}
		if(xmlStrcmp(cur_node->name,childName) == 0){
			return cur_node;
		}
	}
	
	return NULL;
}

NSString*
findAttribute(xmlNode *node, xmlChar *attributeName)
{
	xmlAttr *attr;
	
	for(attr = node->properties; attr; attr = attr->next){
		if(xmlStrcmp(attr->name,attributeName) == 0){
			return [NSString stringWithUTF8String:(const char*) attr->children->content];
		}
	}
	
	return NULL;
}

NSString*
getNodeText(xmlNode *node)
{
	if(node->children->content != NULL){
		return [NSString stringWithUTF8String:(char*)node->children->content];
	}
	return nil;
}

const xmlChar*
getNodeCText(xmlNode *node)
{
	if(node->children->content != NULL){
		return node->children->content;
	}
	return NULL;
}


