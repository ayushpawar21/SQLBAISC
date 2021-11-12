

CREATE    FUNCTION Fn_ReturnTgtforScoreCard(@Pi_TypeId INT,@Pi_MasterId INT,@Pi_MasterVal INT,@Pi_CurrDate DATETIME,@Pi_CmpId INT)

RETURNS NUMERIC(38,2)

AS

/************************************************************

* FUNCTION	: Fn_ReturnTgtforScoreCard

* PURPOSE	: To get the Target for Score card 

* CREATED BY	: Nandakumar R.G

* CREATED DATE	: 29/01/2008

* NOTE		:

* MODIFIED

* DATE      AUTHOR     DESCRIPTION

------------------------------------------------

* {date} {developer}  {brief modification description}

	

*************************************************************/



/***********************

@Pi_MasterId

-------------

1 - Salesman

2 - Route

3 - Retailer

4 - Product



@Pi_TypeId

-----------

1 - Year Target

2 - Quarter Target

3 - Month Target

************************/

BEGIN

    DECLARE @RetValue as NUMERIC(38,2)

    DECLARE @JcmId as INT

    DECLARE @JcmJc as INT

    DECLARE @Quarter as NVARCHAR(10)

    

    IF @Pi_TypeId=1

    BEGIN

        SELECT @JcmId=J.JcmId

        FROM JCMonth JM WITH (NOLOCK),JCMast J WITH (NOLOCK)

        WHERE @Pi_CurrDate BETWEEN JM.JcmSdt AND JM.JcmEdt

        AND J.JcmId=JM.JcmId AND J.CmpId=@Pi_CmpId

    

        IF @Pi_MasterId=1

        BEGIN

    	     SELECT @RetValue = ISNULL(SUM(TGD.CurMonthTarget),0) FROM TargetAnalysisDt TGD WITH (NOLOCK),

	         TargetAnalysisHd TGH WITH (NOLOCK)

             WHERE TGH.TargetAnalysisId=TGD.TargetAnalysisId

             AND TGD.SMId=@Pi_MasterVal AND TGH.JcmId=@JcmId

        END

        ELSE IF @Pi_MasterId=2

        BEGIN

    	     SELECT @RetValue = ISNULL(SUM(TGD.CurMonthTarget),0) FROM TargetAnalysisDt TGD WITH (NOLOCK),

	         TargetAnalysisHd TGH WITH (NOLOCK)

             WHERE TGH.TargetAnalysisId=TGD.TargetAnalysisId

             AND TGD.RMId=@Pi_MasterVal AND TGH.JcmId=@JcmId

        END

        ELSE IF @Pi_MasterId=3

        BEGIN

    	     SELECT @RetValue = ISNULL(SUM(TGD.CurMonthTarget),0) FROM TargetAnalysisDt TGD WITH (NOLOCK),

	         TargetAnalysisHd TGH WITH (NOLOCK)

             WHERE TGH.TargetAnalysisId=TGD.TargetAnalysisId

             AND TGD.RtrId=@Pi_MasterVal AND TGH.JcmId=@JcmId

        END

	ELSE IF @Pi_MasterId=4

        BEGIN

    	     SELECT @RetValue = ISNULL(SUM(TGD.CurMonthTarget),0) FROM TargetAnalysisDt TGD WITH (NOLOCK),

	         TargetAnalysisHd TGH WITH (NOLOCK)

             WHERE TGH.TargetAnalysisId=TGD.TargetAnalysisId

             AND TGD.PrdId=@Pi_MasterVal AND TGH.JcmId=@JcmId

        END

    END

    ELSE IF @Pi_TypeId=2

    BEGIN



        SELECT @JcmId=JCMID,@Quarter=QuarterDt FROM

		(

			SELECT DISTINCT  A.JCMID,A.QuarterDT  FROM JCMonth A

			INNER JOIN JCMast B ON A.JCMID = B.JCMID

			WHERE @Pi_CurrDate BETWEEN JCMSdt AND  JCMEdt AND CmpId=@Pi_CmpId

		) AS C

		

		IF @Pi_MasterId=1

        BEGIN

    	     SELECT @RetValue = ISNULL(SUM(TGD.CurMonthTarget),0) FROM TargetAnalysisDt TGD WITH (NOLOCK),

	         TargetAnalysisHd TGH WITH (NOLOCK)

             WHERE TGH.TargetAnalysisId=TGD.TargetAnalysisId

             AND TGD.SMId=@Pi_MasterVal AND TGH.JcmId=@JcmId AND TGH.JcmJc IN

             (SELECT JcmJc FROM JCMonth JM WITH (NOLOCK) WHERE JM.JcmId=@JcmId AND JM.QuarterDt=@Quarter)

        END

        ELSE IF @Pi_MasterId=2

        BEGIN

    	     SELECT @RetValue = ISNULL(SUM(TGD.CurMonthTarget),0) FROM TargetAnalysisDt TGD WITH (NOLOCK),

	         TargetAnalysisHd TGH WITH (NOLOCK)

             WHERE TGH.TargetAnalysisId=TGD.TargetAnalysisId

             AND TGD.RMId=@Pi_MasterVal AND TGH.JcmId=@JcmId AND TGH.JcmJc IN

             (SELECT JcmJc FROM JCMonth JM WITH (NOLOCK) WHERE JM.JcmId=@JcmId AND JM.QuarterDt=@Quarter)

        END

        ELSE IF @Pi_MasterId=3

        BEGIN

    	     SELECT @RetValue = ISNULL(SUM(TGD.CurMonthTarget),0) FROM TargetAnalysisDt TGD WITH (NOLOCK),

	         TargetAnalysisHd TGH WITH (NOLOCK)

             WHERE TGH.TargetAnalysisId=TGD.TargetAnalysisId

          AND TGD.RtrId=@Pi_MasterVal AND TGH.JcmId=@JcmId AND TGH.JcmJc IN

             (SELECT JcmJc FROM JCMonth JM WITH (NOLOCK) WHERE JM.JcmId=@JcmId AND JM.QuarterDt=@Quarter)

        END

	ELSE IF @Pi_MasterId=4

        BEGIN

    	     SELECT @RetValue = ISNULL(SUM(TGD.CurMonthTarget),0) FROM TargetAnalysisDt TGD WITH (NOLOCK),

	         TargetAnalysisHd TGH WITH (NOLOCK)

             WHERE TGH.TargetAnalysisId=TGD.TargetAnalysisId

             AND TGD.PrdId=@Pi_MasterVal AND TGH.JcmId=@JcmId AND TGH.JcmJc IN

             (SELECT JcmJc FROM JCMonth JM WITH (NOLOCK) WHERE JM.JcmId=@JcmId AND JM.QuarterDt=@Quarter)

        END

    END

    ELSE IF @Pi_TypeId=3

    BEGIN



		SELECT DISTINCT  @JcmId=A.JCMID,@JcmJc=A.JcmJc  FROM JCMonth A

		INNER JOIN JCMast B ON A.JCMID = B.JCMID

		WHERE @Pi_CurrDate BETWEEN JCMSdt AND  JCMEdt AND CmpId=@Pi_CmpId

		

		IF @Pi_MasterId=1

        BEGIN

    	     SELECT @RetValue = ISNULL(SUM(TGD.CurMonthTarget),0) FROM TargetAnalysisDt TGD WITH (NOLOCK),

	         TargetAnalysisHd TGH WITH (NOLOCK)

             WHERE TGH.TargetAnalysisId=TGD.TargetAnalysisId

             AND TGD.SMId=@Pi_MasterVal AND TGH.JcmId=@JcmId AND TGH.JcmJc=@JcmJc

        END

        ELSE IF @Pi_MasterId=2

        BEGIN

    	     SELECT @RetValue = ISNULL(SUM(TGD.CurMonthTarget),0) FROM TargetAnalysisDt TGD WITH (NOLOCK),

	         TargetAnalysisHd TGH WITH (NOLOCK)

             WHERE TGH.TargetAnalysisId=TGD.TargetAnalysisId

             AND TGD.RMId=@Pi_MasterVal AND TGH.JcmId=@JcmId AND TGH.JcmJc=@JcmJc

        END

        ELSE IF @Pi_MasterId=3

        BEGIN

    	     SELECT @RetValue = ISNULL(SUM(TGD.CurMonthTarget),0) FROM TargetAnalysisDt TGD WITH (NOLOCK),

	         TargetAnalysisHd TGH WITH (NOLOCK)

             WHERE TGH.TargetAnalysisId=TGD.TargetAnalysisId

             AND TGD.RtrId=@Pi_MasterVal AND TGH.JcmId=@JcmId AND TGH.JcmJc=@JcmJc

        END

	ELSE IF @Pi_MasterId=4

        BEGIN

    	     SELECT @RetValue = ISNULL(SUM(TGD.CurMonthTarget),0) FROM TargetAnalysisDt TGD WITH (NOLOCK),

	         TargetAnalysisHd TGH WITH (NOLOCK)

             WHERE TGH.TargetAnalysisId=TGD.TargetAnalysisId

             AND TGD.PrdId=@Pi_MasterVal AND TGH.JcmId=@JcmId AND TGH.JcmJc=@JcmJc

        END

    END

RETURN(@RetValue)

END




