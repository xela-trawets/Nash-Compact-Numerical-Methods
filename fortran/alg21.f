      SUBROUTINE A21VM(N,B,BH,NBH,X,C,G,T,IFN,IG,NOCOM,IPR,P0,FUN,DER)
C  ALGORITHM 21 VARIABLE METRIC FUNCTION MINIMIZATION
C  J.C. NASH   JULY 1978, FEBRUARY 1980, APRIL 1989
C  N = NO. OF PARAMETERS TO BE ADJUSTED
C  B = INITIAL SET OF PARAMETERS (INPUT)
C    = MINIMUM  (OUTPUT)
C  BH= WORKING ARRAY
C  NBH= FIRST DIMENSION OF BH
C  X,C,G,T = WORKING VECTORS OF LENGTH AT LEAST N
C  ON OUTPUT G CONTAINS LAST GRADIENT EVALUATED
C  IFN= COUNT OF FUNCTION EVALUATIONS USED
C     = LIMIT ON THESE (INPUT)
C  IG = COUNT OF GRADIENT EVALUATIONS USED
C  NOCOM = LOGICAL FLAG SET .TRUE. IF INITIAL POINT INFEASIBLE
C  IPR = PRINTER CHANNEL.  PRINTING ONLY IF IPR.GT.0
C  P0 = MINIMAL FUNCTION VALUE
C  FUN = NAME OF FUNCTION SUBROUTINE
C  DER = NAME OF DERIVATIVE SUBROUTINE
C     CALLING SEQUENCE   P=FUN(N,B,NOCOM) -- OTHER INFO. PASSED
C     CALLING SEQUENCE   CALL DER(N,B,G)  --  THROUGH COMMON
C  STEP 0
      LOGICAL NOCOM
      INTEGER N,NBH,IFN,IG,IPR,ILAST,I,J,COUNT
      REAL B(N),BH(NBH,N),X(N),C(N),G(N),T(N),P0,W,TOL,K,S,D1,D2,P
      IG=0
      LIFN=IFN
      IFN=0
      W=0.2
      TOL=0.0001
C  STEP 1
      NOCOM=.FALSE.
      P0=FUN(N,B,NOCOM)
      IFN=IFN+1
      IF(NOCOM)RETURN
C  STEP 2  - ASSUME DERIVATIVES CAN BE COMPUTED IF FUNCTION CAN
      CALL DER(N,B,G)
      IG=IG+1
C  STEP 3
  30  DO 35 I=1,N
        DO 32 J=1,N
          BH(I,J)=0.0
  32    CONTINUE
        BH(I,I)=1.0
  35  CONTINUE
      ILAST=IG
C  STEP 4
  40  IF(IPR.GT.0)WRITE(IPR,950)IG,IFN,P0
 950  FORMAT( 6H AFTER,I4,8H GRAD. &,I4,22H FN EVALUATIONS, FMIN=,
     *1PE16.8)
      DO 45 I=1,N
        X(I)=B(I)
        C(I)=G(I)
  45  CONTINUE
C  STEP 5
      D1=0.0
      DO 55 I=1,N
        S=0.0
        DO 53 J=1,N
          S=S-BH(I,J)*G(J)
  53    CONTINUE
        T(I)=S
        D1=D1-S*G(I)
  55  CONTINUE
C  STEP 6
      IF(D1.GT.0.0)GOTO 70
      IF(ILAST.EQ.IG)GOTO 180
      GOTO 30
  70  K=1.0
C  STEP 7
C  STEP 8
  80  COUNT=0
      DO 85 I=1,N
        B(I)=X(I)+K*T(I)
        IF(B(I).EQ.X(I))COUNT=COUNT+1
  85  CONTINUE
C  STEP 9
      IF(COUNT.LT.N)GOTO 100
      IF(ILAST.EQ.IG)GOTO 180
      GOTO 30
C  STEP 10
 100  IFN=IFN+1
      IF(IFN.GT.LIFN)GOTO 175
      P=FUN(N,B,NOCOM)
      IF(.NOT.NOCOM)GOTO 110
      K=W*K
      GOTO 80
C  STEP 11
 110  IF(P.LT.P0-D1*K*TOL)GOTO 120
      K=W*K
      GOTO 80
 120  P0=P
      IG=IG+1
      CALL DER(N,B,G)
C  STEP 13
      D1=0.0
      DO 135 I=1,N
        T(I)=K*T(I)
        C(I)=G(I)-C(I)
        D1=D1+T(I)*C(I)
 135  CONTINUE
C  STEP 14
      IF(D1.LE.0.0)GOTO 30
C  STEP 15
      D2=0.0
      DO 156 I=1,N
        S=0.0
        DO 154 J=1,N
          S=S+BH(I,J)*C(J)
 154    CONTINUE
        X(I)=S
        D2=D2+S*C(I)
 156  CONTINUE
C  STEP 16
      D2=1.0+D2/D1
      DO 165 I=1,N
        DO 164 J=1,N
          BH(I,J)=BH(I,J)-(T(I)*X(J)+X(I)*T(J)-D2*T(I)*T(J))/D1
 164    CONTINUE
 165  CONTINUE
C  STEP 17
      GOTO 40
C  RESET B IN CASE FN EVALN LIMIT REACHED
C  OUT OF EVALUATIONS!  (mod 2021-2-12)
 175  IFN=-IFN
C  SET COUNT OF FUNCTIONS NEGATIVE IF LIMIT REACHED
      DO 177 I=1,N
        B(I)=X(I)
 177  CONTINUE
 180  IF(IPR.LE.0)RETURN
      WRITE(IPR,951)
 951  FORMAT(10H CONVERGED)
      WRITE(IPR,950)IG,IFN,P0
      RETURN
      END

