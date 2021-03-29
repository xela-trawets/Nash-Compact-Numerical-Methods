C&&& A4-4A
C  TEST ALGORITHM 4 & 4A  AUG 1978  J.C.NASH
C  J.C. NASH   JULY 1978, APRIL 1989
C
C  USES FRANK MATRIX COLUMNS
      LOGICAL NTOL
C  G MAY NOT BE NEEDED
      INTEGER M,N,ND,IPOS,NVAR,MD,I,J,K,YPOS(10),N1,NG,GG,NOBS
      REAL Y(10)
      REAL A(30,10),D,G(30),X(10),Z(10),Q,V(10,10),W(11,11),EPS
      COMMON /INPW/ M,NVAR,IPOS(10),D(30,10)
C
      EXTERNAL FRANKM
C  I/O CHANNELS
      NIN=5
      NOUT=6
      ND=10
      MD=30
      ND1=ND+1
   1  READ(NIN,900)M,NVAR
 900  FORMAT(10I4)
      WRITE(NOUT,950)M,NVAR
 950  FORMAT(' TESTS USING DATA MATRIX',I4,' BY',I4)
      IF(M.LE.0.OR.NVAR.LE.0)STOP
      CALL A3PREP(M,NVAR,D,MD,FRANKM)
      WRITE(NOUT,952)
 952  FORMAT(' D MATRIX')
      CALL OUT(D,MD,M,NVAR,NOUT)
  11  READ(NIN,900)IPOS
      WRITE(NOUT,951)IPOS
 951  FORMAT(' COL. #S OF INDEPENDENT VARIABLES'/10I4)
      N=0
  20  N=N+1
      IF(IPOS(N).LE.0)GOTO 30
      K=IPOS(N)
      DO 25 J=1,M
        A(J,N)=D(J,K)
  25  CONTINUE
      GOTO 20
  30  N=N-1
      IF(N.EQ.0)GOTO 1
      WRITE(NOUT,953)
 953  FORMAT(' A MATRIX')
      CALL OUT(A,MD,M,N,NOUT)
  35  READ(NIN,900)YPOS
      WRITE(NOUT,954)YPOS
 954  FORMAT(' DEPENDENT VARIABLES FROM COL.',10I4)
      GG=0
  36  GG=GG+1
      IF(YPOS(GG).LE.0)GOTO 45
C  COPY DATA POSITION
      NG=N+GG
C  CAUTION TO NOT OVERFLOW DATA
      IF(NG.GT.ND)STOP
      I=YPOS(GG)
      WRITE(NOUT,958)GG,I
 958  FORMAT(' DEP. VAR.',I4,' FROM COL.',I4)
      WRITE(NOUT,955)(D(J,I),J=1,M)
 955  FORMAT(1H ,5E16.8)
      IPOS(NG)=I
      GOTO 36
  45  GG=GG-1
      NTOL=.FALSE.
  50  READ(NIN,902)Q
 902  FORMAT(E16.8)
      WRITE(NOUT,956)Q
 956  FORMAT(' SING. VALS. .LE.',E16.8,'  ARE PRESUMED ZERO')
      IF(Q.LT.0.0)GOTO 11
C  IBM MACHINE PRECISION VALUE
      EPS=16.0**(-5)
      N1=N+1
      CALL A4LSGS(W,ND1,N1,NG,N,Y,GG,X,Z,NOUT,NOBS,EPS,Q,NTOL)
      NTOL=.TRUE.
      GOTO 50
      END
      SUBROUTINE INW(W,ND1,N1,NG,NOBS,DEND)
C  J.C. NASH   JULY 1978, APRIL 1989
      LOGICAL DEND
      INTEGER N1,NG,M,NVAR,IPOS,NT,N,I,IP,ND1
      REAL W(ND1,NG)
      COMMON /INPW/ M,NVAR,IPOS(10),D(30,10)
      NT=NOBS+1
      IF(NT.GT.M)GOTO 100
      DO 10 I=1,NG
        IP=IPOS(I)
        W(N1,I)=D(NT,IP)
  10  CONTINUE
      RETURN
 100  DEND=.TRUE.
      RETURN
      END
      SUBROUTINE A4LSGS(W,ND1,N1,NG,N,H,G,X,Z,IPR,NOBS,EPS,QTOL,NTOL)
C  ALGORITHM 4  LEAST SQUARES SOLUTION BY GIVENS' REDUCTION  AND ROW
C     ORTHOGONALISATION SINGULAR VALUE DECOMPOSITION
C  J.C. NASH   JULY 1978, FEBRUARY 1980, APRIL 1989
C   W IS WORKING ARRAY  N1 BY NG   DIMENSIONED ND1 BY NG
C   G  RIGHT HAND SIDES
C   N  INDEPENDENT VARIABLES (INCLUDING CONSTANT)
C   N1=N+1
C   NG=N+G
C   IPR  =  PRINT CHANNEL   IPR.GT.0 FOR PRINTING
C   NOBS =  NUMBER OF OBSERVATIONS - OUTPUT - COUNTED DURING EXECUTION
C    X   =  SOLUTION VECTOR
C    H   =  RESIDUAL SUM OF SQUARES ACCUMULATOR
C   EPS  =  MACHINE PRECISION
C  QTOL  = TOLERANCE FOR SINGULAR VALUES
C        SING. VALS. .LE. QTOL ARE TAKEN AS ZERO
C  NTOL  =  .TRUE. IF ONLY NEW VALUE OF QTOL
C  STEP 0
      LOGICAL DEND,NTOL
      REAL QTOL
      INTEGER N1,NG,N,G,IPR,NOBS,T,K,M,NM1,J1,ND1
      REAL W(ND1,NG),H(G),X(N),Z(N),EPS,TOL,S,C,P,B,Q,R
      IF(N.NE.N1-1.OR.NG.NE.N+G)STOP
      IF(NTOL)GOTO 240
      TOL=N*N*EPS*EPS
      NOBS=0
      DO 4 I=1,N
        DO 2 J=1,NG
          W(I,J)=0.0
   2    CONTINUE
   4  CONTINUE
      T=NG
      K=N1
      IF(G.LT.1)GOTO 9
      DO 6 J=1,G
        H(J)=0.0
   6  CONTINUE
C  STEP 1
   9  DEND=.FALSE.
  10  CALL INW(W,ND1,N1,NG,NOBS,DEND)
C  STEP 2
      IF(DEND)GOTO 110
C  STEP 3
      NOBS=NOBS+1
C  STEP 4
      DO 90 J=1,N
C  STEP 5
        M=J
        S=W(K,J)
        C=W(J,J)
        B=ABS(C)
        IF(ABS(S).GT.B)B=ABS(S)
C  STEP 6
        IF(B.EQ.0.0)GOTO 90
        C=C/B
        S=S/B
      P=SQRT(C**2+S**2)
C  STEP 7
        S=S/P
        IF(ABS(S).LT.TOL)GOTO 90
C  STEP 8
        C=C/P
        CALL ROTN(J,K,S,C,M,T,W,ND1,NG)
C  STEP 9
  90  CONTINUE
C  STEP 10
      IF(G.LT.1)GOTO 10
      DO 105 J=1,G
        M=N+J
        H(J)=H(J)+W(N1,M)**2
 105  CONTINUE
      GOTO 10
C  STEP 11
 110  M=1
C  STEP 12
      NM1=N-1
 120  COUNT=N*(N-1)/2
C  STEP 13
      DO 215 J=1,NM1
        J1=J+1
C  STEP 14
        DO 210 K=J1,N
C  STEP 15
          P=0.0
          Q=0.0
          R=0.0
          DO 155 I=1,N
            P=P+W(J,I)*W(K,I)
            Q=Q+W(J,I)**2
            R=R+W(K,I)**2
 155      CONTINUE
C  STEP 16
          IF(Q.GE.R)GOTO 170
          C=0.0
          S=1.0
          GOTO 190
 170      IF(Q*R.EQ.0.0)GOTO 200
C  STEP 17
          IF((P*P)/(Q*R).LT.TOL)GOTO 200
C  STEP 18
          Q=Q-R
          R=SQRT(4.0*P**2+Q**2)
          C=SQRT((R+Q)/(2.0*R))
          S=P/(R*C)
C  STEP 19
 190      CALL ROTN(J,K,S,C,M,T,W,ND1,NG)
          GOTO 210
 200      COUNT=COUNT-1
C  STEP 20
C  STEP 21
 210    CONTINUE
 215  CONTINUE
C  STEP 22
      IF(COUNT.GT.0)GOTO 120
C  STEP 23
      DO 238 J=1,N
        S=0.0
        DO 232 I=1,N
          S=S+W(J,I)**2
 232    CONTINUE
        S=SQRT(S)
        Z(J)=S
        IF(S.LT.TOL)GOTO 238
      DO 236 I=1,N
          W(J,I)=W(J,I)/S
 236    CONTINUE
 238  CONTINUE
      IF(IPR.GT.0)WRITE(IPR,983)(J,Z(J),J=1,N)
 983  FORMAT(11H SING. VAL.,I3,3H = ,1PE16.8)
C  STEP 24
 240  Q=QTOL
      IF(G.LT.1)RETURN
C  STEP 25
      DO 300 I=1,G
C  STEP 25A
        RSS=H(I)
C  STEP 26
      DO 290 J=1,N
C  STEP 27
          P=0.0
          J1=N+I
          DO 275 K=1,N
            IF(Z(K).LE.Q)GOTO 275
            P=P+W(K,J)*W(K,J1)/Z(K)
 275      CONTINUE
C  STEP 28
          X(J)=P
C         IF(Z(J).LE.Q)H(I)=H(I)+W(J,J1)**2
C  STEP 28A
          IF(Z(J).LE.Q)RSS=RSS+W(J,J1)**2
C  STEP 29
 290    CONTINUE
        IF(IPR.GT.0)WRITE(IPR,981)I,RSS
 981    FORMAT(' RESIDUAL SUM OF SQUARES FOR SOLN',I4,'=',1PE16.8)
        IF(IPR.GT.0)WRITE(IPR,982)(J,X(J),J=1,N)
 982    FORMAT( 3H X(,I3,2H)=,1PE16.8)
C  STEP 30
 300  CONTINUE
      RETURN
        END
      SUBROUTINE ROTN(J,K,S,C,M,T,W,N1,NG)
C  PLANE ROTATION  ALGORITHM 4A   J.C.NASH  JULY 1978
C  J.C. NASH   JULY 1978, FEBRUARY 1980, APRIL 1989
      INTEGER J,K,M,T,N1,NG,I
      REAL  S,C,W(N1,NG),R
C  STEP 1
      DO 10 I=M,T
        R=W(J,I)
        W(J,I)=R*C+S*W(K,I)
        W(K,I)=-R*S+C*W(K,I)
  10  CONTINUE
C  STEP 2
      RETURN
      END
      SUBROUTINE OUT(A,NA,N,NP,NOUT)
C  J.C. NASH   JULY 1978, APRIL 1989
      INTEGER NA,N,NOUT,I,J
      REAL A(NA,NP)
      DO 20 I=1,N
        WRITE(NOUT,951)I
 951    FORMAT(' ROW',I3)
        WRITE(NOUT,952)(A(I,J),J=1,NP)
 952    FORMAT(1H ,1P5E16.8)
  20  CONTINUE
      RETURN
      END
      SUBROUTINE FRANKM(M,N,A,NA)
C  J.C. NASH   JULY 1978, APRIL 1989
      INTEGER M,N,NA,I,J
C  INPUTS FRANK MATRIX M BY N INTO A
      REAL A(NA,N)
      DO 20 I=1,M
        DO 10 J=1,N
          A(I,J)=AMIN0(I,J)
  10    CONTINUE
  20  CONTINUE
      RETURN
      END
      SUBROUTINE A3PREP(M,N1,A,NA,AIN)
C  PREPARE A3 TEST
C  J.C. NASH   JULY 1978, APRIL 1989
C  MATRIX M BY N=N1-1 IS INPUT VIA SUBROUTINE AIN
C  COL. N1 IS SET TO SUM OF OTHER COLS.  - UNIT SOLUTION ELEMENTS
C  BUT ONLY IF M=N - OTHERWISE SIMPLY INPUT MATRIX
C  NA = FIRST DIMENSION OF A
      INTEGER M,N1,NA,N,J,I
      REAL A(NA,N1),S
      N=N1-1
      CALL AIN(M,N,A,NA)
      IF(M.NE.N)RETURN
      DO 40 I=1,N
        S=0.0
        DO 30 J=1,N
          S=S+A(I,J)
  30    CONTINUE
        A(I,N1)=S
  40  CONTINUE
      RETURN
      END
C&&&    4   5
C&&&    1   2   0
C&&&    3   4   5  -1
C&&&   0.0       E 00
C&&&  -1.0       E 00
C&&&    1   2   3   4   5   0
C&&&    1
C&&&   0.0       E 00
C&&&  1.0        E-04
C&&&  -1.0       E 00
C&&&   -1
C&&&   20  10
C&&&    1   2   3   0
C&&&    4
C&&&   0.0       E 00
C&&&  1.0        E-04
C&&&  -1.0       E 00
C&&&   -1
C&&&    0
