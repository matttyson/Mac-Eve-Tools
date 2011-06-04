
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <openssl/sha.h>
#include "bsd-base64.h"

#define MEGABYTE 1024*1024

int main(int argc, char *argv[])
{
	int fd;
	ssize_t len;
	unsigned char *buffer;
	unsigned char digest[SHA_DIGEST_LENGTH];
	SHA_CTX ctx;

	fd = open(argv[1],O_RDONLY);
	if(fd == -1){
		fd = 0; /*read from stdin*/
	}

	SHA1_Init(&ctx);

	buffer = malloc(MEGABYTE);
	
	while((len = read(fd,buffer,MEGABYTE)) != 0){
		SHA1_Update(&ctx,buffer,len);
	}

	SHA1_Final(digest,&ctx);

	if(fd != 0){
		close(fd);
	}

	len = b64_ntop(digest,SHA_DIGEST_LENGTH,buffer,MEGABYTE);

	write(1,buffer,len);
	
	free(buffer);

	return 0;
}
