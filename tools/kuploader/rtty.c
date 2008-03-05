#include <termios.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/signal.h>
#include <sys/types.h>
#include <sys/ioctl.h>

volatile int comfd;

int transfer_byte(int from, int to, int is_control) {
	char c;
	int ret;
	ret = read(from, &c, 1);
	if(ret == 1) {
		if(write(to, &c, 1) != 1) {
			perror("write failed");
		}
	}
	return 0;
}

void handle_alarm(int sig){
	close(comfd);
	exit(0);
}


main(int argc, char *argv[])
{	char *devicename = argv[1];
	
	if(argc < 2) {
		fprintf(stderr, "example: %s /dev/ttyS0\n", argv[0]);
		exit(1);
	}

	comfd = open(devicename, O_RDWR | O_NOCTTY | O_NONBLOCK);
	if (comfd < 0)
	{
		perror(devicename);
		exit(-1);
	}

	signal (SIGALRM, handle_alarm);

	alarm(1);

	while( 1 ) {
		fd_set fds;
		int ret;
		
		FD_ZERO(&fds);
		FD_SET(STDOUT_FILENO, &fds);
		FD_SET(comfd, &fds);


		ret = select(comfd+1, &fds, NULL, NULL, NULL);
		if(ret == -1) {
			perror("select");
		} else if (ret > 0) {
			transfer_byte(comfd, STDOUT_FILENO, 0);
		}
	}	
}
