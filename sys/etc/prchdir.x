# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

# PRCHDIR -- Change the current working directory of a connected child
# process, or of all connected subprocesses if pid=0.

procedure prchdir (pid, newdir)

int	pid		# process id of child, or 0 for all subprocesses
char	newdir[ARB]	# new directory
pointer	sp, cmd

begin
	call smark (sp)
	call salloc (cmd, SZ_LINE, TY_CHAR)

	call strcpy ("chdir ", Memc[cmd], SZ_LINE)
	call strcat (newdir, Memc[cmd], SZ_LINE)

	call prupdate (pid, Memc[cmd])
	call sfree (sp)
end
