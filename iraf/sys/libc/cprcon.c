/* Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.
 */

#define import_spp
#define import_libc
#define import_xnames
#define import_stdio
#define import_prstat
#include <iraf.h>

/* CPRCON -- Connected subprocesses.  A connected subprocess is an active filter
 * which communicates with the parent process via an input stream and an output
 * stream.  A connected subprocess is logically equivalent to the user terminal.
 * The set of useful operations thus far identified for connected subprocesses
 * are open and close, read and write, and signal (interrupt).  The read and
 * write operations are provided by interfacing the IPC channels from the
 * subprocess to FIO.  The remaining operations are peculiar to connected
 * subprocesses and are summarized below.
 *
 *		  pid =	c_propen (process, in, out)
 *		stat = c_prclose (pid)
 *		stat = c_prstati (pid, param)
 *		      c_prsignal (pid, signal)
 *		       c_prredir (pid, stream, new_fd)
 *		       c_prchdir (pid, newdir)
 *		      c_prenvset (pid, envvar, valuestr)
 *
 * A connected subprocess must be opened either with c_propen or with the low
 * level procedure PROPCPR (the latter does not require that the subprocess
 * recognize the standard IPC protocol).  An idle subprocess may be closed
 * with c_prclose, which not only closes the process but releases important
 * system resources.  The c_prsignal procedure raises the X_INT (interrupt)
 * exception in a subprocess, generally following receipt of a user interrupt
 * by the parent process.  Redirection of the child's standard i/o streams
 * is provided by c_prredir.  Finally, c_prchdir and c_prenvsets are used
 * to update the current directory and environment in child processes.
 */

/* C_PROPEN -- Open a connected subprocess, i.e., spawn the subprocess and
 * connect the two IPC channels connecting the child and parent to FIO.
 * The FIO streams may subsequently be opened for C style STDIO by calling
 * FDOPEN, if desired.  The C_PROPEN procedure sends the current environment
 * and working directory to the child as part of process startup.  The process
 * id (PID) of the child process is returned as the function value.  This
 * magic integer value uniquely identifies the process to the system.
 *
 * N.B.: opening a child process leaves the child in the IRAF Main interpreter
 * loop, with the child waiting for a command from the parent.  A child process
 * is capabable of performing an arbitrary number of "tasks".  To get the child
 * to run a task, the parent must write the name of the task to the OUT stream,
 * then read from the IN stream, responding to all queries from the child until
 * "bye" or "error" is received.
 */
/* process : filename of executable process */
/* in      : FD for reading from child      */
/* out     : FD for writing to child        */
pid_t c_propen ( const char *process, int *in, int *out )
{
	pid_t pid;
	XINT x_in = *in;
	XINT x_out = *out;

	iferr (pid = PROPEN (c_sppstr(process), &x_in, &x_out)) {
	    *in = x_in;
	    *out = x_out;
	    return 0;
	}
	else {
	    *in = x_in;
	    *out = x_out;
	    FDTOFP(x_in)->_fflags |= _FIPC;
	    return (pid);
	}
}


/* C_PRCLOSE -- Close a connected subprocess.  The "bye" command is sent to
 * the child, commanding it to shut down, and when the task terminates the
 * exit status is returned as the function value.  The C_PRCLOSE procedure
 * must be called at process termination to free system resources.  C_PRCLOSE
 * is automatically called by the system if error recovery takes place in
 * the parent process.  Calling C_PRCLOSE is equivalent to individually
 * closing the IN and OUT streams to the subprocess (which is what happens
 * if system error recovery takes place).
 */
/* pid : process id returned by C_PROPEN */
int c_prclose ( pid_t pid )
{
	XINT x_pid = pid;
	return (PRCLOSE (&x_pid));
}


/* C_PRSTATI -- Get status on a connected subprocess.  See <libc/prstat.h>
 * for a list of parameters.
 */
/* pid   : process id of process            */
/* param : parameter for which value is ret */
int c_prstati ( pid_t pid, int param )
{
	XINT x_pid = pid;
	XINT x_param = param;
	return (PRSTATI (&x_pid, &x_param));
}


/* C_PRSIGNAL -- Send a signal, i.e., asynchronous interrupt, to a connected
 * child process.  Currently only the X_INT signal is implemented, and the
 * second argument is not used.  The value X_INT should nontheless be passed.
 */
/* pid    : process id of process */
/* signal : not used at present   */
int c_prsignal ( pid_t pid, int signal )
{
	XINT x_pid = pid;
	XINT x_signal = signal;
	iferr (PRSIGNAL (&x_pid, &x_signal))
	    return (ERR);
	else
	    return (OK);
}


/* C_PRREDIR -- Redirect one of the standard i/o streams of the child process.
 * By default the child inherits the standard i/o streams of the parent at
 * C_PROPEN time, i.e., the STDOUT of the child is connected to the STDOUT of
 * the parent.  If the parent's STDOUT is subsequently redirected, e.g., with
 * C_FREDIR, the child's output will be redirected as well.  More commonly
 * one or more of the child's streams will be explicitly redirected with
 * C_PRREDIR.  Such redirection remains in effect for the life of the
 * process, i.e., until process termination via C_PRCLOSE or until another
 * call to C_PRREDIR.  Note that often this is not what is desired, rather,
 * one wishes to redirect a stream for the duration of a task running within
 * the process.  For this reason it is recommended that C_PRREDIR be called
 * for each standard stream (it costs almost nothing) immediately prior to
 * task execution.
 *
 * Example:
 *		fp = fopen ("tmp$spoolfile", "w");
 *		if (c_prredir (pid, STDOUT, fileno(fp)) == ERR)
 *			...
 */
/* pid    : process id of child             */
/* stream : child's stream to be redirected */
/* new_fd : FD of opened file in parent     */
int c_prredir ( pid_t pid, int stream, int new_fd )
{
	XINT x_pid = pid;
	XINT x_stream = stream;
	XINT x_new_fd = new_fd;
	iferr (PRREDIR (&x_pid, &x_stream, &x_new_fd))
	    return (ERR);
	else
	    return (OK);
}


/* C_PRCHDIR -- Change the current working directory of a child process.
 * If pid=NULL all currently connected processes are updated.  May only
 * be called when the child process is idle.
 */
int c_prchdir ( pid_t pid, const char *newdir )
{
	XINT x_pid = pid;
	return (PRCHDIR (&x_pid, c_sppstr (newdir)));
}


/* C_PRENVSET -- Transmit a set environment directive to the child process.
 * If pid=NULL all currently connected processes are updated.  May only
 * be called when the child process is idle.
 */
int c_prenvset ( pid_t pid, const char *envvar, const char *value )
{
	XCHAR	spp_value[SZ_LINE];

	c_strupk (value, spp_value, SZ_LINE);
	return (PRENVSET (&pid, c_sppstr (envvar), spp_value));
}