//
//  main.c
//  inject_helper
//
//  Created by Albert Zeyer on 07.09.11.
//  Copyright 2011 Albert Zeyer. All rights reserved.
//

/*
 We keep this as an extra small helper binary
 to have separate versions for each architecture
 for this.
 */

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <mach_inject_bundle/mach_inject_bundle.h>
#include "SIMBL.h"

int main (int argc, const char * argv[])
{
	assert(argc == 2);
	pid_t pid = atoi(argv[1]);
	assert(pid > 0);
	
	fprintf(stderr, "injecting into %i ...\n", pid);
	mach_inject_bundle_pid(SIMBLE_bundle_path, pid);	
    return 0;
}
