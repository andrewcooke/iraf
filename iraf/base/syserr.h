# SYSERR.H -- System Error Codes.  Each code has a corresponding error message,
# given in <syserrmsg>.  System errors are numbered starting at 500.

define	SYS_XACV		501		# Exceptions
define	SYS_XARITH		502		# ALSO DEFINED in error.h
define	SYS_XINT		503
define	SYS_XIPC		504

define	SYS_SONERROVFL		550		# ETC, TTY, MEMIO
define	SYS_SONEXITOVFL		551
define	SYS_ENVNNUM		552
define	SYS_ENVNF		553
define	SYS_TTYMOVOOR		554
define	SYS_TTYOVFL		555
define	SYS_TTYDEVNF		556
define	SYS_TTYSET		557
define	SYS_TTYSTAT		558
define	SYS_TTYTC		559
define	SYS_TTYBINSRCH		560
define	SYS_GMULOPN		561
define	SYS_TTYINVDES		562
define	SYS_MCORRUPTED		570
define	SYS_MEMFILALIGN		571
define	SYS_MFULL		572
define	SYS_MSSTKUNFL		573
define	SYS_PROVFL		574
define	SYS_PROPEN		575
define	SYS_PRNOTFOUND		576
define	SYS_PRSIGNAL		577
define	SYS_PRIPCSYNTAX		578
define	SYS_PRBKGNF		579
define	SYS_PRBKGNOKILL		580
define	SYS_PRBKGOVFL		581
define	SYS_PRBKGOPEN		582
define	SYS_PRSTAT		583
define	SYS_PRPSIOUCI		584
define	SYS_STTYNUMARG		585
define	SYS_STTYNOGDEV		586
define	SYS_PSOPEN		587
define	SYS_PSFONT		588
define	SYS_PSSPFONT		589

define	SYS_CLNPSETS		598
define	SYS_CLPSETOOS		599
define	SYS_CLEOFNLP		600		# CLIO
define	SYS_CLNOTBOOL		601
define	SYS_CLNOTCC		602
define	SYS_CLNOTNUM		603
define	SYS_CLSTATUS		606
define	SYS_CLSETUKNPAR		607
define	SYS_CLGWRD		608
define	SYS_CLCMDNC		609

define	SYS_FNTMAGIC		610		# FNT
define	SYS_FNTBADPAT		611
define	SYS_FNTMAXPAT		612
define	SYS_FNTMAXEDIT		613
define	SYS_FNTEDIT		614

define	SYS_FALLOC		720		# FIO
define	SYS_FARDALIGN		721
define	SYS_FARDOOB		722
define	SYS_FAWRALIGN		723
define	SYS_FAWROOB		724
define	SYS_FCANTCLOB		725
define	SYS_FCLOBBER		726
define	SYS_FCLOBOPNFIL		727
define	SYS_FDELETE		728
define	SYS_FDELPROTFIL		729
define	SYS_FDEVNOTFOUND	730
define	SYS_FDEVSTAT		731
define	SYS_FDEVTBLOVFL		732
define	SYS_FILENOTOPEN		733
define	SYS_FILLEGMODE		734
define	SYS_FILLEGTYPE		735
define	SYS_FIOINPROGRESS	736
define	SYS_FINITREP		737
define	SYS_FMKTEMP		738
define	SYS_FNOREADPERM		739
define	SYS_FNOWRITEPERM	740
define	SYS_FOPEN		741
define	SYS_FOPENDEV		742
define	SYS_FOPNNEXFIL		743
define	SYS_FPROTECT		744
define	SYS_FPROTNEXFIL		745
define	SYS_FREAD		746
define	SYS_FDELNXF		747
define	SYS_FRENAME		748
define	SYS_FRENAMECLOB		749
define	SYS_FREOPNMODE		750
define	SYS_FREOPNTYPE		751
define	SYS_FSEEK		752
define	SYS_FSETUKNPAR		753
define	SYS_FSTAT		754
define	SYS_FSTATUNKPAR		755
define	SYS_FSTRFILOVFL		756
define	SYS_FTOOMANYFILES	757
define	SYS_FUNPROTECT		758
define	SYS_FWRITE		759
define	SYS_FWTNOACC		760
define	SYS_FWTOPNFIL		761
define	SYS_FZMAPOVFL		762
define	SYS_FZMAPRECUR		763
define	SYS_FPATHNAME		764
define	SYS_FGCWD		765
define	SYS_FSEEKNTXF		766
define	SYS_FSTATTYPE		767
define	SYS_FOWNER		768
define	SYS_FINITLOCK		769
define	SYS_FVFNMODE		770
define	SYS_FVFNCHKSUM		771
define	SYS_FDEGEN		772
define	SYS_FTMLONGFN		773
define	SYS_FNOLOCK		774
define	SYS_FCLOSE		775
define	SYS_FREDIRFNO		776
define	SYS_FMULTREDIR		777
define	SYS_FCHDIR		778
define	SYS_FOPENDIR		779
define	SYS_FNOSUCHFILE		780
define	SYS_FPBOVFL		781
define	SYS_FREADP		782
define	SYS_FWRITEP		783
define	SYS_FMKDIR		784
define	SYS_FMKDIRFNTL		785
define	SYS_FACCDIR		786
define	SYS_FMKCOPY		787
define	SYS_FSFOPNF		788
define	SYS_FNOFNAME		789
define	SYS_FCLFDTX		790
define	SYS_FCLFDNF		791
define	SYS_FUTIME		792

define	SYS_IMRDPIXFILE		800		# IMIO
define	SYS_IMUPIMHDR		801
define	SYS_IMACMODE		802
define	SYS_IMNDIM		803
define	SYS_IMDIMLEN		804
define	SYS_IMMAGNCPY		805
define	SYS_IMMAGOPSF		806
define	SYS_IMNOPIX		807
define	SYS_IMREFOOB		808
define	SYS_IMHDRRDERR		809
define	SYS_IMSECTNEWIM		810
define	SYS_IMSYNSEC		811
define	SYS_IMDIMSEC		812
define	SYS_IMSTEPSEC		813
define	SYS_IMSETUNKPAR		814
define	SYS_IMSTATUNKPAR	815
define	SYS_IMDEVOPN		816
define	SYS_IMFNOVFL		817
define	SYS_IMGSZNEQ		818

define	SYS_IKICLOB		820
define	SYS_IKICLOSE		821
define	SYS_IKICOPY		822
define	SYS_IKIDEL		823
define	SYS_IKIEXTN		824
define	SYS_IKIIMNF		825
define	SYS_IKIKTBLOVFL		826
define	SYS_IKIOPEN		827
define	SYS_IKIOPIX		828
define	SYS_IKIRENAME		829
define	SYS_IKIUPDHDR		830
define	SYS_IKIKSECTNS		831
define	SYS_IKIAMBIG		832

define	SYS_IDBKEYNF		835
define	SYS_IDBOVFL		836
define	SYS_IDBREDEF		837
define	SYS_IDBTYPE		838
define	SYS_IDBNODEL		839
define	SYS_IDBDELNXKW		840

define	SYS_GGCUR		850		# GIO
define	SYS_GGETWCS		851
define	SYS_GINDEF		852
define	SYS_GSCALE		853
define	SYS_GSET		854
define	SYS_GSTAT		855
define	SYS_GXNORANGE		856
define	SYS_GYNORANGE		857
define	SYS_GGCELL		858
define	SYS_GWRITEP		859
define	SYS_GKERNPARAM		860
define	SYS_GGNONE		861
define	SYS_GINONE		862
define	SYS_GPNONE		863
define	SYS_GNOKF		864

define	SYS_MTFILSPEC		900		# MTIO
define	SYS_MTACMODE		901
define	SYS_MTALLOC		902
define	SYS_MTMULTOPEN		903
define	SYS_MTNOTALLOC		904
define	SYS_MTNOTOWN		905
define	SYS_MTPOSINDEF		906
define	SYS_MTSKIPREC		907
define	SYS_MTREW		908
define	SYS_MTDEVNF		909
define	SYS_MTTAPECAP		910

define	SYS_PLBADMASK		919		# PLIO, more IMIO
define	SYS_IMRLOVFL		920
define	SYS_PLBADSAVEF		921
define	SYS_PLINACTDES		922
define	SYS_PLINVDES		923
define	SYS_PLNULLSRC		924
define	SYS_PLREFOOB		925
define	SYS_IMPLNORI		926
define	SYS_IMPLSIZE		927
define	SYS_PLSTKOVFL		928
define	SYS_PLINVPAR		929

define	SYS_FMBADMAGIC		930		# FMIO
define	SYS_FMCLOSE		931
define	SYS_FMCOPYO		932
define	SYS_FMLFCOPY		933
define	SYS_FMLFNOOB		934
define	SYS_FMOOF		935
define	SYS_FMOPEN		936
define	SYS_FMPTIOVFL		937
define	SYS_FMRERR		938
define	SYS_FMTRUNC		939
define	SYS_FMWRERR		940
define	SYS_FMBLKCHSZ		941
define	SYS_FMFSINUSE		942
define	SYS_FMLFLOCKED		943
define	SYS_FMFCFULL		944
define	SYS_FMLOKACTLF		945

define	SYS_QPBLOCKOOR		948		# QPOE
define	SYS_QPINVEVT		949
define	SYS_QMNFILES		950
define	SYS_QPBADCONV		951
define	SYS_QPBADFILE		952
define	SYS_QPBADIX		953
define	SYS_QPBADKEY		954
define	SYS_QPBADVAL		955
define	SYS_QPCLOBBER		956
define	SYS_QPEVNSORT		957
define	SYS_QPEXBADRNG		958
define	SYS_QPEXDBOVFL		959
define	SYS_QPEXLEVEL		960
define	SYS_QPEXMLP		961
define	SYS_QPEXPBOVFL		962
define	SYS_QPEXRPAREN		963
define	SYS_QPINDXOOR		964
define	SYS_QPINVDD		965
define	SYS_QPMRECUR		966
define	SYS_QPNEVPAR		967
define	SYS_QPNOEH		968
define	SYS_QPNOVAL		969
define	SYS_QPNOXYF		970
define	SYS_QPPLSIZE		971
define	SYS_QPPOPEN		972
define	SYS_QPPVALOVF		973
define	SYS_QPREDEF		974
define	SYS_QPUKNPAR		975
define	SYS_QPXYFNS		976
define	SYS_QPNOWCS		977
define	SYS_QPIOSYN		978
define	SYS_QPEXSYN		979

define	SYS_MWATOVFL		980		# MWCS
define	SYS_MWFCOVFL		981
define	SYS_MWFUNCOVFL		982
define	SYS_MWINVAXMAP		983
define	SYS_MWMAGIC		984
define	SYS_MWMAXWCS		985
define	SYS_MWMISSAX		986
define	SYS_MWNDIM		987
define	SYS_MWNOWCS		988
define	SYS_MWNOWSAMP		989
define	SYS_MWROTDEP		990
define	SYS_MWSET		991
define	SYS_MWSTAT		992
define	SYS_MWUNKFN		993
define	SYS_MWWATTRNF		994
define	SYS_MWWCSNF		995
define	SYS_MWWCSREDEF		996
define	SYS_MWFNOVFL		997
define	SYS_MWCTOVFL		998
define	SYS_MWROT2AX		999
define	SYS_MWFITSOVFL		1000

define	SYS_FXFDELMEF		1100		# IMIO - FITS image kernel
define	SYS_FXFKSNV		1101
define	SYS_FXFKSNDEC		1102
define	SYS_FXFKSSYN		1103
define	SYS_FXFKSSVAL		1104
define	SYS_FXFKSEXT		1105
define	SYS_FXFKSINVAL		1106
define	SYS_FXFKSPVAL		1107
define	SYS_FXFKSOVR		1108
define	SYS_FXFKSBOP		1109
define	SYS_FXFKSNEXT		1110
define	SYS_FXFKSNOVR		1111
define	SYS_FXFOPEXTNV		1112
define	SYS_FXFOPNOEXTNV	1113
define	SYS_FXFOVRBEXTN		1114
define	SYS_FXFOVRTOPN		1115
define	SYS_FXFBSDTY		1116
define	SYS_FXFPKDTYP		1117
define	SYS_FXFRDHSC		1118
define	SYS_FXFBADINH		1119
define	SYS_FXFRFNEXTNV		1120
define	SYS_FXFRFEOF		1121
define	SYS_FXFRFBNAXIS		1122
define	SYS_FXFRFSIMPLE		1123
define	SYS_FXFUPHBEXTN		1124
define	SYS_FXFUPHBTYP		1125
define	SYS_FXFUPHEXP		1126
define	SYS_FXFUPKDTY		1127
define	SYS_FXFFKNULL		1128
define	SYS_FXFKSBADGR		1129
define	SYS_FXFKSBADFKIG	1130
define	SYS_FXFKSBADEXN		1131
define	SYS_FXFEXTNF		1132
define	SYS_FXFRMASK		1133