
procedure imlintran (input, output, xrotation, yrotation, xmag, ymag, xin, yin,
	xout, yout, ncols, nrows, interpolant, boundary, constant,
	fluxconserve, nxblock, nyblock)

string	input
string	output
real	xrotation
real	yrotation
real	xmag
real	ymag
real	xin
real	yin
real	xout
real	yout
real	ncols
real	nlines
string	interpolant
string	boundary
real	constant
bool	fluxconserve
int	nxblock
int	nyblock


begin
	# Declare local variables.
	string	tinput, toutput
	real	txrotation, tyrotation

	# Get the parameters.
	tinput = input
	toutput = output
	txrotation = xrotation
	tyrotation = yrotation

	geotran (input=tinput, output=toutput, database="",
	    xrotation=txrotation, yrotation=tyrotation, xin=xin, yin=yin,
	    xout=xout, yout=yout, xshift=INDEF, yshift=INDEF, xmin=1.0,
	    xmax=ncols, ymin=1.0, ymax=nlines, xscale=1.0, yscale=1.0,
	    ncols=INDEF, nlines=INDEF, xmag=xmag, ymag=ymag,
	    interpolant=interpolant, boundary=boundary, constant=constant,
	    xsample=1., ysample=1., fluxconserve=fluxconserve, nxblock=nxblock,
	    nyblock= nyblock)
end

