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

#include "read_query.h"

#include <stdio.h>

long read_query(char *restrict buffer, long n, FILE *stream)
{
	long i = 0;
	long quote = 0;
	int c = 0; //current char
	
	flockfile(stream);
	
	for(i = 0; i < n; i++){
		c = getc_unlocked(stream);
		if(c == EOF){
			*buffer = '\0';
			funlockfile(stream);
			return i;
		}
		
		/*
		 check to see if we are inside a quoted text block. 
		 the ';' character must be ignored in this case
		 */
		if(c == '\''){
			quote = !quote;
		}
		
		*buffer++ = (char)c;
		
		if(c == ';'){
			if(quote == 0){
				break;
			}
		}
	}
	funlockfile(stream);
	
	if(i >= n){
		/*error, buffer not large enough*/
		ungetc(*buffer,stream);
	}else{
		i++;
	}
	*buffer = '\0';
	
	return i;
}
