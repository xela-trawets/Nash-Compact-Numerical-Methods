10 PRINT "bastimer.bas"
30 PRINT DATE$, TIME$
40 LET N=765432
45 LET T1=TIMER()
50 LET Y=0
60 FOR I=1 TO N
70 LET X=EXP(SIN(COS(I)))
80 LET Y=Y+X
90 NEXT I
100 LET T2=TIMER()
110 PRINT "# OF LOOPS=",N,"  ELAPSED SECS = ";T2-T1
120 END