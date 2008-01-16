/* Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.
 */

#define import_spp
#define import_libc
#define import_xnames
#include <iraf.h>

/*
 * CPRDET -- Detached processes.  A detached process is a process which runs
 * asynchronously with and independently of the parent, generally without 
 * interprocess communication during execution.  The primary example of a
 * detached process in IRAF is the CL process spawned by an interactive CL
 * to execute a command in the background.
 *
 * The parent communicates with the child by means of the "bkgfile", the name
 * of which is passed by the system to the child during process startup.
 * While the format and contents of the bkgfile are in general application
 * dependent, the system default action is to open the bkgfile as a text file
 * and read commands from it.  The CL process does not make use of this
 * default, but rather uses its own special format binary file to communicate
 * the full runtime context of the parent to the child, partially emulating
 * the UNIX fork.  The system automatically deletes the bkgfile when the
 * child process terminates.
 *
 * N.B.: The environment and cwd are not automatically passed to the child,
 * as they are for a connected subprocess.  The application must see to it
 * that this information is passed in the bkgfile if needed by the child.
 */

/* C_PROPDPR -- Open a detached process.  The named process is either spawned
 * or queued for delayed execution (depending on the system and other factors).
 * When the process eventually runs it reads the bkgfile passed by the parent
 * to determine what to do.  When the process terminates, either normally or
 * abnormally, the system deletes the bkgfile.  Deletion of the bkgfile signals
 * process termination.
 */
/* process : filename of executable file */
/* bkgfile : filename of bkgfile         */
/* bkgmsg  : control string for kernel  */
job_t c_propdpr ( const char *process, const char *bkgfile, const char *bkgmsg )
{
	job_t job;
	XCHAR	spp_bkgfile[SZ_PATHNAME];
	XCHAR	spp_bkgmsg[SZ_LINE];

	c_strupk (bkgfile, spp_bkgfile, SZ_PATHNAME);
	c_strupk (bkgmsg,  spp_bkgmsg,  SZ_LINE);
	iferr (job = PROPDPR (c_sppstr(process), spp_bkgfile, spp_bkgmsg))
	    return 0;
	else
	    return (job);
}


/* C_PRCLDPR -- Close a detached process.  Wait (indefinitely) for process
 * termination, then free all system resources allocated to the process.
 * Should be called if a detached process terminated while the parent is
 * still executing.  The exit status of the child is returned as the function
 * value; the value OK (0) indicates normal termination.  A positive value
 * is the error code of the error which caused abnormal process termination.
 */
/* job : job code from C_PROPDPR */
int c_prcldpr ( job_t job )
{
	XINT x_job = job;
	return (PRCLDPR (&x_job));
}


/* C_PRDONE -- Determine if a bkg job is still executing (function return NO)
 * or has terminated (function return YES).
 */
/* job : job code from C_PROPDPR */
int c_prdone ( job_t job )
{
	XINT x_job = job;
	return (PRDONE (&x_job));
}


/* C_PRKILL -- Kill a bkg job.  If the bkg job has begun execution it is
 * killed without error recovery.  If the bkg job is still sitting in a queue
 * it is dequeued.  C_PRKILL returns ERR for an illegal jobcode or if sufficient
 * permission is not available to kill the job.  C_PRCLDPR should subsequently
 * be called to wait for process termination and free system resources.
 */
/* job : job code from C_PROPDPR */
int c_prkill ( job_t job )
{
	XINT x_job = job;
	iferr (PRKILL (&x_job))
	    return (ERR);
	else
	    return (OK);
}