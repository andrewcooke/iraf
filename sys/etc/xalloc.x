# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<xalloc.h>
include	<syserr.h>
include	<ctype.h>
include	<knet.h>

.helpsys xalloc
.nf _________________________________________________________________________
XALLOC -- Device allocation package.

	  xallocate (device)
	xdeallocate (device, rewind)
	  xdevowner (device, owner, maxch)
	 xdevstatus (fd, device)
	  xgdevlist (device, devlist, maxch)

status:

	DV_DEVFREE	device is free and can be allocated
	DV_DEVALLOC	device is already allocated
	DV_DEVINUSE	device is in use by someone else
	DV_DEVNOTFOUND	device is not in device table

The allocatable devices are defined in the text file DEV$DEVICES.  Note that
for each magtape device there are a set of entries corresponding to the
specific densities and the default density, e.g.:

	mta		magtape device A, default density
	mta.800		magtape device A, 800 bpi
	mta.1600	magtape device A, 1600 bpi
				(etc.)

The XGDEVLIST procedure is used to get the host device list from the device
table.  If the device being allocated is a magtape, XALLOCATE will call
MT_ALLOCATE to initialize MTIO, and XDEALLOCATE will call MT_DEALLOCATE.
.endhelp ____________________________________________________________________

define	SZ_DEVLIST	256
define	ALLOCATE	1
define	DEALLOCATE	0


# XALLOCATE -- Attempt to allocate the named device, i.e., allocate the device
# for exclusive i/o, and ready it for i/o following some sort of OPEN call.
# Allocate performs the function called "mount" on some systems, as well as
# allocating the device.

int procedure xallocate (device)

char	device[ARB]		# IRAF name of device to be allocated.
int	status, onedev, junk
pointer	sp, devlist
int	xgdevlist(), mtfile()
errchk	xgdevlist, mt_allocate

begin
	call smark (sp)
	call salloc (devlist, SZ_DEVLIST, TY_CHAR)

	# Fetch the device list for the named device.
	onedev = NO
	status = xgdevlist (device, junk, Memc[devlist], SZ_DEVLIST, onedev)
	if (status != OK)
	    return (status)

	# Attempt to allocate the device at the host system level.
	call strpak (Memc[devlist], Memc[devlist], SZ_DEVLIST)
	call zdvall (Memc[devlist], ALLOCATE, status)

	# If that worked and the device is a magtape, call MTIO to complete
	# the allocation process.

	if (status == OK && mtfile (device) == YES)
	    call mt_allocate (device)

	call sfree (sp)
	return (status)
end


# XDEALLOCATE -- Deallocate the named device.

int procedure xdeallocate (device, rewind)

char	device[ARB]		# IRAF name of device to be deallocated
int	rewind			# rewind if magtape?

int	status, onedev, junk, ip
pointer	sp, devlist, osdev, owner
int	xgdevlist(), mtfile(), ctowrd()
errchk	xgdevlist, syserrs

begin
	call smark (sp)
	call salloc (devlist, SZ_DEVLIST, TY_CHAR)
	call salloc (osdev, SZ_FNAME, TY_CHAR)
	call salloc (owner, SZ_FNAME, TY_CHAR)

	# Fetch the device list for the named device.
	onedev = NO
	status = xgdevlist (device, junk, Memc[devlist], SZ_DEVLIST, onedev)
	if (status != OK)
	    return (status)

	# Verify that the device is actually allocated.  If the device is a
	# magtape, call MTIO to conditionally rewind the drive and deallocate
	# the drive in MTIO.

	ip = 1; status = ctowrd (Memc[devlist], ip, Memc[osdev], SZ_FNAME)
	call strpak (Memc[osdev], Memc[osdev], SZ_FNAME)
	call zdvown (Memc[osdev], Memc[owner], SZ_FNAME, status)
	if (status != DV_DEVALLOC)
	    call syserrs (SYS_MTNOTALLOC, device)
	else if (mtfile (device) == YES)
	    call mt_deallocate (device, rewind)

	# Physically deallocate the device.
	call strpak (Memc[devlist], Memc[devlist], SZ_DEVLIST)
	call zdvall (Memc[devlist], DEALLOCATE, status)

	call sfree (sp)
	return (status)
end


# XDEVSTATUS -- Print the status of the named device on the output file.

procedure xdevstatus (out, device)

int	out			# output file
char	device[ARB]		# device

int	status
char	owner[SZ_FNAME]
int	xdevowner(), mtfile()
errchk	xdevowner, mtfile

begin
	status = xdevowner (device, owner, SZ_FNAME)

	switch (status) {
	case DV_DEVFREE:
	    call fprintf (out, "device %s is not currently allocated\n")
		call pargstr (device)
	case DV_DEVINUSE:
	    call fprintf (out, "device %s is currently allocated to %s\n")
		call pargstr (device)
		call pargstr (owner)
	case DV_DEVALLOC:
	    if (mtfile (device) == YES)
		call mtstatus (out, device)
	    else {
		call fprintf (out, "device %s is allocated\n")
		    call pargstr (device)
	    }
	default:
	    call fprintf (out, "cannot get device status for `%s'\n")
		call pargstr (device)
	}
end


# XDEVOWNER -- Determine whether or not the named device is already allocated,
# and if the device is currently allocated to someone else, return the owner
# name.

int procedure xdevowner (device, owner, maxch)

char	device[ARB]		# IRAF name of device to be deallocated.
char	owner[maxch]		# receives owner name if alloc to someone else
int	maxch

int	status, onedev, junk
pointer	sp, devlist
int	xgdevlist()
errchk	xgdevlist

begin
	call smark (sp)
	call salloc (devlist, SZ_DEVLIST, TY_CHAR)

	# Fetch the device list for the named device.
	onedev = YES
	status = xgdevlist (device, junk, Memc[devlist], SZ_DEVLIST, onedev)
	if (status != OK)
	    return (status)

	# Query device allocation.
	call strpak (Memc[devlist], Memc[devlist], SZ_DEVLIST)
	call zdvown (Memc[devlist], owner, maxch, status)
	call strupk (owner, owner, maxch)

	call sfree (sp)
	return (status)
end
