USE [DWH_Database]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spProdToDWHCompatibilityTestViaCSEntities] 
AS

/* 
(-1-)  FACT_DailyMassPaymentCSEntityDataSource				#PROD_TO_DWH_VIEW_FACT_DailyMassPaymentCSEntityDataSource				&	#CSHARP_TO_PROD_VIEW_FACT_DailyMassPaymentCSEntityDataSource			
(-2-)  FACT_DailyInvoicePaymentCSEntityDataSource				#PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource				&	#CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource			
(-3-)  FACT_DailyRemittanceCSEntityDataSource			#PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource				&	#CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource			
(-4-)  FACT_DailyUserAttributesCSEntityDataSource					#PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_(A-B, C, D, E)		&	#CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A				
(-5-)  FACT_DailyPersonalCommercialCSEntityDataSource		#PROD_TO_DWH_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource,		&	#CSHARP_TO_PROD_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource		
(-6-)  FACT_DailyFinancialCSEntityDataSource				#PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource					&	#CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource				
(-7-)  FACT_CSEntityDataSource								#PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_(A-B-C-D-E-F-G)				&	#CSHARP_TO_PROD_VIEW_FACT_CSEntityDataSource							
(-8-)  FACT_DailyDepositAndWithdrawalCSEntityDataSource	#PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource		&	#CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	
(-9-)  FACT_DailyDatabaseCardCSEntityDataSource				#PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource(A-E)			&	#CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource				
(-10-) FACT_DailyDatabaseCardCashbackCSEntityDataSource		#PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource		&	#CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource		
(-11-) FACT_DailyCheckoutCSEntityDataSource				#PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource					&	#CSHARP_TO_PROD_VIEW_FACT_DailyCheckoutCSEntityDataSource				
(-12-) FACT_DailyInsuranceCSEntityDataSource				#PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource					&	#CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource				
*/ 
/*Parametrik tanimlama günler ile oynayarak manuel test yapabilmek için kullanilmistir*/
Declare @BaseDay AS DATE = CONVERT(DATE,GETDATE()) /*Baz alinan son gün tarih formatinda girilir.				 Default -> GETDATE()*/		
       ,@d       AS INT  = 1					   /*Geriye yönelik kontrol edilecek gün sayisi buradan girilir. Default -> 1        */ 

/* TABLO DOLDURULDU
CREATE TABLE BI_Workspace.dbo.DailyAdminReportBasedDWHTestV6 (Id int Identity(1,1), StreamDate Date, TestDateTime DateTime, TestType NVARCHAR(10), BasedReportTable NVARCHAR(50), 
															 BasedReportTableField NVARCHAR(100), Tested_DWH_Table NVARCHAR(100), Tested_DWH_Table_Field NVARCHAR(150), Currency NVARCHAR(3), Value1 NVARCHAR(230), Formula NVARCHAR(200), MetricExplanation NVARCHAR(200),
															 CSHARP_TO_PROD_VIEW DECIMAL(20,1), PROD_TO_DWH_VIEW DECIMAL(20,1), [Difference] DECIMAL(20,1), Compatibility NVARCHAR(20),IsCompatible BIT, IsWarningField BIT, Superiority NVARCHAR(25), Accuracy DECIMAL(24,20),IsResolved BIT)

*/
--drop table BI_Workspace.dbo.DailyAdminReportBasedDWHTestV6
--TRUNCATE TABLE BI_Workspace.dbo.DailyAdminReportBasedDWHTestV6 /*Tablo içerigi her seferinde silinir-Gelistirme için yapildi, kaldirilacak*/
DELETE FROM DWH_Database.dbo.[FACT_ProdToDWHCompatibilityTestViaCSEntities] WHERE CAST(StreamDate AS DATE) >= DATEADD(DAY,-@d,@BaseDay) /*Her zaman araligini siler*/


/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyMassPaymentCSEntityDataSource*/	
	SELECT
		    CAST(CreatedAt AS DATE) [Date]
		   ,CAST(ISNULL(Cnt(		   CASE WHEN FeatureType = 9		THEN Id				ELSE NULL END)	,0) AS DECIMAL(20,1))	MassPaymentCnt
		   ,CAST(ISNULL(ABS(SUM(	   CASE WHEN FeatureType = 9		THEN Fee			ELSE NULL END))	,0) AS DECIMAL(20,1))	MassPaymentFee
		   ,CAST(ISNULL(ABS(SUM(	   CASE WHEN FeatureType = 9		THEN TxAmount			ELSE NULL END))	,0) AS DECIMAL(20,1))	MassPaymentVol
		   ,CAST(ISNULL(Cnt(DISTINCT CASE WHEN FeatureType = 9		THEN Merchandiser_Key	ELSE NULL END)	,0) AS DECIMAL(20,1))	UniqueMerchandisersLastDay
		   ,CAST(ISNULL(Cnt(DISTINCT CASE WHEN FeatureType = 9		THEN User_Key		ELSE NULL END)	,0) AS DECIMAL(20,1))	UniqueUserAttributesLastDay
	INTO #PROD_TO_DWH_VIEW_FACT_DailyMassPaymentCSEntityDataSource
	FROM FACT_MerchandiserTransactions (nolock)
	WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay AND FeatureType = 9
	GROUP BY CAST(CreatedAt AS DATE)
/*END - #PROD_TO_DWH_VIEW_FACT_DailyMassPaymentCSEntityDataSource*/	
PRINT '1 - Completed -#PROD_TO_DWH_VIEW_FACT_DailyMassPaymentCSEntityDataSource' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #CSHARP_TO_PROD_VIEW_FACT_DailyMassPaymentCSEntityDataSource*/			
/*Manuel karsilastirma için Admin Raporu */
	SELECT	 CAST(CreatedAt AS DATE) [Date]
			,CAST(MassPaymentCnt			AS DECIMAL(20,1))	MassPaymentCnt		
			,CAST(MassPaymentFee			AS DECIMAL(20,1))	MassPaymentFee		
			,CAST(MassPaymentVol			AS DECIMAL(20,1))	MassPaymentVol		
			,CAST(UniqueMerchandisersLastDay	AS DECIMAL(20,1))	UniqueMerchandisersLastDay
			,CAST(UniqueUserAttributesLastDay		AS DECIMAL(20,1))	UniqueUserAttributesLastDay	
	INTO #CSHARP_TO_PROD_VIEW_FACT_DailyMassPaymentCSEntityDataSource
	FROM FACT_DailyMassPaymentCSEntityDataSource (nolock)		   
	WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
	  AND MassPaymentCnt != 0 AND MassPaymentFee != 0 AND MassPaymentVol != 0 AND UniqueMerchandisersLastDay != 0 AND UniqueUserAttributesLastDay != 0
/*END - #CSHARP_TO_PROD_VIEW_FACT_DailyMassPaymentCSEntityDataSource*/	
PRINT '2 - Completed - #CSHARP_TO_PROD_VIEW_FACT_DailyMassPaymentCSEntityDataSource' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource*/	
	SELECT
		    CAST(CreatedAt AS DATE) [Date]
		   ,CAST(Cnt(			CASE WHEN InvoiceCategoryId = 4			   THEN Id		ELSE NULL END)			AS DECIMAL(20,1))		CellPhoneCnt
		   ,CAST(Cnt(DISTINCT CASE WHEN InvoiceCategoryId = 4			   THEN User_Key ELSE NULL END)			AS DECIMAL(20,1))		CellPhoneUserCnt
		   ,CAST(ISNULL(ABS(SUM(CASE WHEN InvoiceCategoryId = 4			   THEN TxAmount  ELSE NULL END))	,0)		AS DECIMAL(20,1))		CellPhoneVol
															   								
		   ,CAST(Cnt(			CASE WHEN InvoiceCategoryId = 9			   THEN Id		ELSE NULL END)			AS DECIMAL(20,1))		DonateToCharitiesCnt
		   ,CAST(Cnt(DISTINCT CASE WHEN InvoiceCategoryId = 9			   THEN User_Key ELSE NULL END)			AS DECIMAL(20,1))		DonateToCharitiesUserCnt
		   ,CAST(ISNULL(ABS(SUM(CASE WHEN InvoiceCategoryId = 9			   THEN TxAmount  ELSE NULL END))	,0)		AS DECIMAL(20,1))		DonateToCharitiesVol
															   								
		   ,CAST(Cnt(		    CASE WHEN InvoiceCategoryId = 2			   THEN Id		ELSE NULL END)			AS DECIMAL(20,1))		ElectricityCnt
		   ,CAST(Cnt(DISTINCT CASE WHEN InvoiceCategoryId = 2			   THEN User_Key ELSE NULL END)			AS DECIMAL(20,1))		ElectricityUserCnt
		   ,CAST(ISNULL(ABS(SUM(CASE WHEN InvoiceCategoryId = 2			   THEN TxAmount  ELSE NULL END))	,0)		AS DECIMAL(20,1))		ElectricityVol
															   									
		   ,CAST(Cnt(			CASE WHEN InvoiceCategoryId = 5			   THEN Id		ELSE NULL END)			AS DECIMAL(20,1))		GameCnt
		   ,CAST(Cnt(DISTINCT CASE WHEN InvoiceCategoryId = 5			   THEN User_Key ELSE NULL END)			AS DECIMAL(20,1))		GameUserCnt
		   ,CAST(ISNULL(ABS(SUM(CASE WHEN InvoiceCategoryId = 5			   THEN TxAmount  ELSE NULL END))	,0)		AS DECIMAL(20,1))		GameVol
															   									
		   ,CAST(Cnt(			CASE WHEN InvoiceCategoryId = 6			   THEN Id		ELSE NULL END)			AS DECIMAL(20,1))		InternetAndTvCnt
		   ,CAST(Cnt(DISTINCT CASE WHEN InvoiceCategoryId = 6			   THEN User_Key ELSE NULL END)			AS DECIMAL(20,1))		InternetAndTvUserCnt
		   ,CAST(ISNULL(ABS(SUM(CASE WHEN InvoiceCategoryId = 6			   THEN TxAmount  ELSE NULL END))	,0)		AS DECIMAL(20,1))		InternetAndTvVol
															   									
		   ,CAST(Cnt(		    CASE WHEN InvoiceCategoryId = 8			   THEN Id		ELSE NULL END)			AS DECIMAL(20,1))		CityRingTravelCardCnt
		   ,CAST(Cnt(DISTINCT CASE WHEN InvoiceCategoryId = 8			   THEN User_Key ELSE NULL END)			AS DECIMAL(20,1))		CityRingTravelCardUserCnt
		   ,CAST(ISNULL(ABS(SUM(CASE WHEN InvoiceCategoryId = 8			   THEN TxAmount  ELSE NULL END))	,0)		AS DECIMAL(20,1))		CityRingTravelCardVol
														   								
		   ,CAST(Cnt(		   CASE WHEN InvoiceCategoryId =  12			   THEN Id		ELSE NULL END)			AS DECIMAL(20,1))		LotteryCnt
		 --,CAST(Cnt(DISTINCT CASE WHEN InvoiceCategoryId = 12			   THEN User_Key ELSE NULL END)			AS DECIMAL(20,1))		LotteryUserCnt				 --Raporda yok fakat biz ekleyip commentlestirdik
		   ,CAST(ISNULL(ABS(SUM(CASE WHEN InvoiceCategoryId = 12			   THEN TxAmount  ELSE NULL END))	,0)		AS DECIMAL(20,1))		CouponVol
															   										
		   ,CAST(Cnt(		    CASE WHEN InvoiceCategoryId = 13			   THEN Id		ELSE NULL END)			AS DECIMAL(20,1))		MembershipPaymentCnt
		   ,CAST(Cnt(DISTINCT CASE WHEN InvoiceCategoryId = 13			   THEN User_Key ELSE NULL END)			AS DECIMAL(20,1))		MembershipPaymentUserCnt
		   ,CAST(ISNULL(ABS(SUM(CASE WHEN InvoiceCategoryId = 13			   THEN TxAmount  ELSE NULL END)) ,0)		AS DECIMAL(20,1))		MembershipPaymentVol
															   										
		   ,CAST(Cnt(		   CASE WHEN InvoiceCategoryId =  1			   THEN Id		ELSE NULL END)			AS DECIMAL(20,1))		NaturalGasCnt
		   ,CAST(Cnt(DISTINCT CASE WHEN InvoiceCategoryId = 1			   THEN User_Key ELSE NULL END)			AS DECIMAL(20,1))		NaturalGasUserCnt
		   ,CAST(ISNULL(ABS(SUM(CASE WHEN InvoiceCategoryId = 1			   THEN TxAmount  ELSE NULL END))	,0)		AS DECIMAL(20,1))		NaturalGasVol
																   								
		   ,CAST(Cnt(		   CASE WHEN InvoiceCategoryId =  3			   THEN Id		ELSE NULL END)			AS DECIMAL(20,1))		WaterCnt
		   ,CAST(Cnt(DISTINCT CASE WHEN InvoiceCategoryId = 3			   THEN User_Key ELSE NULL END)			AS DECIMAL(20,1))		WaterUserCnt
		   ,CAST(ISNULL(ABS(SUM(CASE WHEN InvoiceCategoryId = 3			   THEN TxAmount  ELSE NULL END))	,0)		AS DECIMAL(20,1))		WaterVol
														   								
		   ,CAST(Cnt(		   CASE WHEN InvoiceCategoryId =  7			   THEN Id		ELSE NULL END)			AS DECIMAL(20,1))		OtherCnt
		   ,CAST(Cnt(DISTINCT CASE WHEN InvoiceCategoryId = 7			   THEN User_Key ELSE NULL END)			AS DECIMAL(20,1))		OtherUserCnt
		   ,CAST(ISNULL(ABS(SUM(CASE WHEN InvoiceCategoryId = 7			   THEN TxAmount  ELSE NULL END))	,0)		AS DECIMAL(20,1))		OtherVol
																									
		   ,CAST(Cnt(DISTINCT CASE WHEN FeatureType IN (14,17,18,22,31)	   THEN User_Key ELSE NULL END)			AS DECIMAL(20,1))		TotalPaymentUserAttributesCnt	
	INTO #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource
	FROM FACT_Transactions (nolock) 			
	WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
	GROUP BY CAST(CreatedAt AS DATE)
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource*/			
PRINT '3 - Completed - #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource' + ' -DATETIME : '  + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource*/		
/*Manuel karsilastirma için Admin Raporu */
SELECT  CAST(CreatedAt AS DATE) [Date]
		    ,CAST(ISNULL(CellPhoneCnt				,0) AS DECIMAL(20,1))	CellPhoneCnt			
			,CAST(ISNULL(CellPhoneUserCnt			,0) AS DECIMAL(20,1))	CellPhoneUserCnt		
			,CAST(ISNULL(CellPhoneVol			,0) AS DECIMAL(20,1))	CellPhoneVol		
			,CAST(ISNULL(DonateToCharitiesCnt				,0) AS DECIMAL(20,1))	DonateToCharitiesCnt			
			,CAST(ISNULL(DonateToCharitiesUserCnt			,0) AS DECIMAL(20,1))	DonateToCharitiesUserCnt		
			,CAST(ISNULL(DonateToCharitiesVol				,0) AS DECIMAL(20,1))	DonateToCharitiesVol			
			,CAST(ISNULL(ElectricityCnt			,0) AS DECIMAL(20,1))	ElectricityCnt		
			,CAST(ISNULL(ElectricityUserCnt		,0) AS DECIMAL(20,1))	ElectricityUserCnt	
			,CAST(ISNULL(ElectricityVol			,0) AS DECIMAL(20,1))	ElectricityVol		
			,CAST(ISNULL(GameCnt					,0) AS DECIMAL(20,1))	GameCnt				
			,CAST(ISNULL(GameUserCnt				,0) AS DECIMAL(20,1))	GameUserCnt			
			,CAST(ISNULL(GameVol					,0) AS DECIMAL(20,1))	GameVol				
			,CAST(ISNULL(InternetAndTvCnt			,0) AS DECIMAL(20,1))	InternetAndTvCnt		
			,CAST(ISNULL(InternetAndTvUserCnt		,0) AS DECIMAL(20,1))	InternetAndTvUserCnt	
			,CAST(ISNULL(InternetAndTvVol		,0) AS DECIMAL(20,1))	InternetAndTvVol	
			,CAST(ISNULL(CityRingTravelCardCnt			,0) AS DECIMAL(20,1))	CityRingTravelCardCnt		
			,CAST(ISNULL(CityRingTravelCardUserCnt		,0) AS DECIMAL(20,1))	CityRingTravelCardUserCnt	
			,CAST(ISNULL(CityRingTravelCardVol			,0) AS DECIMAL(20,1))	CityRingTravelCardVol		
			,CAST(ISNULL(LotteryCnt				,0) AS DECIMAL(20,1))	LotteryCnt			
			,CAST(ISNULL(CouponVol				,0) AS DECIMAL(20,1))	CouponVol			
			,CAST(ISNULL(MembershipPaymentCnt		,0) AS DECIMAL(20,1))	MembershipPaymentCnt	
			,CAST(ISNULL(MembershipPaymentVol	,0) AS DECIMAL(20,1))	MembershipPaymentVol
			,CAST(ISNULL(NaturalGasCnt			,0) AS DECIMAL(20,1))	NaturalGasCnt		
			,CAST(ISNULL(NaturalGasUserCnt		,0) AS DECIMAL(20,1))	NaturalGasUserCnt	
			,CAST(ISNULL(NaturalGasVol			,0) AS DECIMAL(20,1))	NaturalGasVol		
			,CAST(ISNULL(WaterCnt					,0) AS DECIMAL(20,1))	WaterCnt				
			,CAST(ISNULL(WaterUserCnt				,0) AS DECIMAL(20,1))	WaterUserCnt			
			,CAST(ISNULL(WaterVol				,0) AS DECIMAL(20,1))	WaterVol			
			,CAST(ISNULL(OtherCnt					,0) AS DECIMAL(20,1))	OtherCnt				
			,CAST(ISNULL(OtherUserCnt				,0) AS DECIMAL(20,1))	OtherUserCnt			
			,CAST(ISNULL(OtherVol				,0) AS DECIMAL(20,1))	OtherVol			
			,CAST(ISNULL(TotalPaymentUserAttributesCnt		,0) AS DECIMAL(20,1))	TotalPaymentUserAttributesCnt	
	INTO #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource
		   FROM FACT_DailyInvoicePaymentCSEntityDataSource (nolock)
WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
/*END - #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource*/
PRINT '4 - Completed - #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource*/
		SELECT
		  k.[Date]
		 ,k.Currency
		 ,CAST(ISNULL(AcCntNoCnt							, 0)	AS DECIMAL(20,1))	AcCntNoCnt
		 ,CAST(ISNULL(AcCntNoVol							, 0)	AS DECIMAL(20,1))	AcCntNoVol
		 ,CAST(ISNULL(CompletedRemittanceReqCnt					, 0)	AS DECIMAL(20,1))	CompletedRemittanceReqCnt
		 ,CAST(ISNULL(CompletedRemittanceReqVol					, 0)	AS DECIMAL(20,1))	CompletedRemittanceReqVol
		 ,CAST(ISNULL(IbanRemittanceCnt						, 0)	AS DECIMAL(20,1))	IbanRemittanceCnt
		 ,CAST(ISNULL(IbanRemittanceUserAttributesCnt					, 0)	AS DECIMAL(20,1))	IbanRemittanceUserAttributesCnt
		 ,CAST(ISNULL(IbanRemittanceVol						, 0)	AS DECIMAL(20,1))	IbanRemittanceVol
		 ,CAST(ISNULL(InviteByMoneySendCompletedUserAttributesCnt			, 0)	AS DECIMAL(20,1))	InviteByMoneySendCompletedUserAttributesCnt
	--	 ,CAST(ISNULL(InviteBySendMoneyCompletedCnt				, 0)	AS DECIMAL(20,1))	InviteBySendMoneyCompletedCnt			 --TESTE ALMA
	--	 ,CAST(ISNULL(InviteBySendMoneyCompletedVol				, 0)	AS DECIMAL(20,1))	InviteBySendMoneyCompletedVol		 --TESTE ALMA
	--	 ,CAST(ISNULL(InviteBySendMoneyCnt						, 0)	AS DECIMAL(20,1))	InviteBySendMoneyCnt					 --TESTE ALMA
	--	 ,CAST(ISNULL(InviteBySendMoneyVol						, 0)	AS DECIMAL(20,1))	InviteBySendMoneyVol					 --TESTE ALMA
		 ,CAST(ISNULL(RemittanceReqAcCntNoCnt				, 0)	AS DECIMAL(20,1))	RemittanceReqAcCntNoCnt
		 ,CAST(ISNULL(RemittanceReqAcCntNoVol				, 0)	AS DECIMAL(20,1))	RemittanceReqAcCntNoVol	
		 ,CAST(ISNULL(RemittanceReqCnt								, 0)	AS DECIMAL(20,1))	RemittanceReqCnt
		 ,CAST(ISNULL(RemittanceReqPhoneNoCnt					, 0)	AS DECIMAL(20,1))	RemittanceReqPhoneNoCnt	
		 ,CAST(ISNULL(RemittanceReqPhoneNoVol					, 0)	AS DECIMAL(20,1))	RemittanceReqPhoneNoVol
		 ,CAST(ISNULL(RemittanceReqReceivedAcCntNoUserAttributesCnt	, 0)	AS DECIMAL(20,1))	RemittanceReqReceivedAcCntNoUserAttributesCnt
		 ,CAST(ISNULL(RemittanceReqReceivedPhoneNoUserAttributesCnt		, 0)	AS DECIMAL(20,1))	RemittanceReqReceivedPhoneNoUserAttributesCnt
		 ,CAST(ISNULL(RemittanceReqSendAcCntNoUserAttributesCnt		, 0)	AS DECIMAL(20,1))	RemittanceReqSendAcCntNoUserAttributesCnt
		 ,CAST(ISNULL(RemittanceReqSendPhoneNoUserAttributesCnt			, 0)	AS DECIMAL(20,1))	RemittanceReqSendPhoneNoUserAttributesCnt
		 ,CAST(ISNULL(RemittanceReqVol							, 0)	AS DECIMAL(20,1))	RemittanceReqVol
	--	 ,CAST(ISNULL(RemittanceReqWithSplitCancelledCnt			, 0)	AS DECIMAL(20,1))	RemittanceReqWithSplitCancelledCnt		--TESTE ALMA
	--	 ,CAST(ISNULL(RemittanceReqWithSplitCancelledVol			, 0)	AS DECIMAL(20,1))	RemittanceReqWithSplitCancelledVol	--TESTE ALMA
	--	 ,CAST(ISNULL(RemittanceReqWithSplitCompletedCnt			, 0)	AS DECIMAL(20,1))	RemittanceReqWithSplitCompletedCnt
	--	 ,CAST(ISNULL(RemittanceReqWithSplitCompletedVol			, 0)	AS DECIMAL(20,1))	RemittanceReqWithSplitCompletedVol	--TESTE ALMA
		 ,CAST(ISNULL(RemittanceFee								, 0)	AS DECIMAL(20,1))	RemittanceFee
		 ,CAST(ISNULL(PaidRecievedCnt								, 0)	AS DECIMAL(20,1))	PaidRecievedCnt
		 ,CAST(ISNULL(PaidRecievedVol							, 0)	AS DECIMAL(20,1))	PaidRecievedVol
		 ,CAST(ISNULL(PhoneNoCnt								, 0)	AS DECIMAL(20,1))	PhoneNoCnt
		 ,CAST(ISNULL(PhoneNoVol								, 0)	AS DECIMAL(20,1))	PhoneNoVol
		 ,CAST(ISNULL(QrCodeCnt									, 0)	AS DECIMAL(20,1))	QrCodeCnt
		 ,CAST(ISNULL(QrCodeVol									, 0)	AS DECIMAL(20,1))	QrCodeVol
		 ,CAST(ISNULL(ReceivedAcCntNoUserAttributesCnt				, 0)	AS DECIMAL(20,1))	ReceivedAcCntNoUserAttributesCnt
		 ,CAST(ISNULL(ReceivedPhoneNoUserAttributesCnt					, 0)	AS DECIMAL(20,1))	ReceivedPhoneNoUserAttributesCnt
		 ,CAST(ISNULL(ReceivedQrUserAttributesCnt							, 0)	AS DECIMAL(20,1))	ReceivedQrUserAttributesCnt
		 ,CAST(ISNULL(SendAcCntNoUserAttributesCnt					, 0)	AS DECIMAL(20,1))	SendAcCntNoUserAttributesCnt
		 ,CAST(ISNULL(SendPhoneNoUserAttributesCnt						, 0)	AS DECIMAL(20,1))	SendPhoneNoUserAttributesCnt
		 ,CAST(ISNULL(SendQrUserAttributesCnt								, 0)	AS DECIMAL(20,1))	SendQrUserAttributesCnt
		 ,CAST(ISNULL(TotalRemittanceReqReceivedUserAttributesCnt			, 0)	AS DECIMAL(20,1))	TotalRemittanceReqReceivedUserAttributesCnt
		 ,CAST(ISNULL(TotalRemittanceReqSendUserAttributesCnt				, 0)	AS DECIMAL(20,1))	TotalRemittanceReqSendUserAttributesCnt
		 ,CAST(ISNULL(TotalRemittanceReqUserAttributesCnt					, 0)	AS DECIMAL(20,1))	TotalRemittanceReqUserAttributesCnt
		 ,CAST(ISNULL(TotalRemittanceUserAttributesCnt					, 0)	AS DECIMAL(20,1))	TotalRemittanceUserAttributesCnt
		 ,CAST(ISNULL(TotalReceivedRemittanceUserAttributesCnt			, 0)	AS DECIMAL(20,1))	TotalReceivedRemittanceUserAttributesCnt
		 ,CAST(ISNULL(TotalSendRemittanceUserAttributesCnt				, 0)	AS DECIMAL(20,1))	TotalSendRemittanceUserAttributesCnt
		 ,CAST(ISNULL(WithNoteCnt									, 0)	AS DECIMAL(20,1))	WithNoteCnt
		 ,CAST(ISNULL(WithNoteVol								, 0)	AS DECIMAL(20,1))	WithNoteVol

		INTO #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource
		FROM
		
			(
				SELECT
					    CAST(l.CreatedAt AS DATE) [Date]
					   ,l.Currency
					   ,Cnt(			 CASE WHEN l.Method		 = 2  AND RemittanceType = 1					THEN   l.Id		   ELSE NULL END)	AcCntNoCnt
					   ,ABS(SUM(		 CASE WHEN l.Method		 = 2  AND RemittanceType = 1					THEN   l.TxAmount	   ELSE NULL END))	AcCntNoVol
					   ,Cnt(			 CASE WHEN mr.[Status]	 = 1											THEN   l.Id		   ELSE NULL END)	CompletedRemittanceReqCnt
					   ,	SUM(		 CASE WHEN mr.[Status]	 = 1											THEN   l.TxAmount	   ELSE NULL END)	CompletedRemittanceReqVol
					   ,Cnt(			 CASE WHEN l.FeatureType   = 21											THEN   l.Id		   ELSE NULL END)	IbanRemittanceCnt
					   ,Cnt(	DISTINCT CASE WHEN l.FeatureType   = 21											THEN   l.User_Key   ELSE NULL END)	IbanRemittanceUserAttributesCnt
					   ,ABS(SUM(		 CASE WHEN l.FeatureType   = 21											THEN   l.TxAmount	   ELSE NULL END))	IbanRemittanceVol
					   ,ABS(SUM(		 CASE WHEN l.FeatureType   = 7											THEN   l.Fee	   ELSE NULL END))	RemittanceFee
					   ,Cnt(			 CASE WHEN l.FeatureType   = 7 AND RemittanceType = 0 AND Fee	 != 0	THEN   l.Id		   ELSE NULL END)	PaidRecievedCnt
					   ,ABS(SUM(		 CASE WHEN l.FeatureType   = 7 AND RemittanceType = 0 AND Fee	 != 0	THEN   l.TxAmount    ELSE NULL END))	PaidRecievedVol
					   ,Cnt(			 CASE WHEN l.FeatureType   = 7 AND RemittanceType = 1 AND l.Method = 1	THEN   l.Id		   ELSE NULL END)	PhoneNoCnt
					   ,ABS(SUM(		 CASE WHEN l.FeatureType   = 7 AND RemittanceType = 1 AND l.Method = 1	THEN   l.TxAmount    ELSE NULL END))	PhoneNoVol
					   ,Cnt(			 CASE WHEN l.FeatureType   = 7 AND RemittanceType = 1 AND l.Method = 3	THEN   l.Id		   ELSE NULL END)	QrCodeCnt
					   ,ABS(SUM(		 CASE WHEN l.FeatureType   = 7 AND RemittanceType = 1 AND l.Method = 3	THEN   l.TxAmount    ELSE NULL END))	QrCodeVol
					   ,Cnt(	DISTINCT CASE WHEN l.FeatureType   = 7 AND RemittanceType = 0 AND l.Method = 2	THEN   l.User_Key   ELSE NULL END)	ReceivedAcCntNoUserAttributesCnt
					   ,Cnt(	DISTINCT CASE WHEN l.FeatureType   = 7 AND RemittanceType = 0 AND l.Method = 1	THEN   l.User_Key   ELSE NULL END)	ReceivedPhoneNoUserAttributesCnt
					   ,Cnt(  DISTINCT CASE WHEN l.FeatureType   = 7 AND RemittanceType = 0 AND l.Method = 3	THEN   l.User_Key   ELSE NULL END)	ReceivedQrUserAttributesCnt
					   ,Cnt(  DISTINCT CASE WHEN l.FeatureType   = 7 AND RemittanceType = 1 AND l.Method = 2	THEN   l.User_Key   ELSE NULL END)	SendAcCntNoUserAttributesCnt
					   ,Cnt(  DISTINCT CASE WHEN l.FeatureType   = 7 AND RemittanceType = 1 AND l.Method = 1	THEN   l.User_Key   ELSE NULL END)	SendPhoneNoUserAttributesCnt
					   ,Cnt(  DISTINCT CASE WHEN l.FeatureType   = 7 AND RemittanceType = 1 AND l.Method = 3	THEN   l.User_Key   ELSE NULL END)	SendQrUserAttributesCnt
					   ,Cnt(	DISTINCT CASE WHEN l.FeatureType   = 7											THEN   l.User_Key   ELSE NULL END)	TotalRemittanceUserAttributesCnt
					   ,Cnt(	DISTINCT CASE WHEN l.FeatureType   = 7 AND RemittanceType = 0					THEN   l.User_Key   ELSE NULL END)	TotalReceivedRemittanceUserAttributesCnt
					   ,Cnt(	DISTINCT CASE WHEN l.FeatureType   = 7 AND RemittanceType = 1					THEN   l.User_Key   ELSE NULL END)	TotalSendRemittanceUserAttributesCnt
					   ,Cnt(	DISTINCT CASE WHEN l.FeatureType   = 7 AND RemittanceType = 1 AND (l.[Description] not like 'Giden para transferi%' and l.[Description] IS NOT NULL  and LEN(l.[Description]) != 0) THEN l.Id	 ELSE NULL END)		WithNoteCnt
					   ,ABS(SUM(		 CASE WHEN l.FeatureType   = 7 AND RemittanceType = 1 AND (l.[Description] not like 'Giden para transferi%' and l.[Description] IS NOT NULL  and LEN(l.[Description]) != 0) THEN l.TxAmount ELSE NULL END))	WithNoteVol
				FROM FACT_Transactions (nolock) L
				FULL OUTER JOIN (select CreatedAt, Id,User_Key, OtherUser_Key, [Status], Method, RemittanceTransactionsId, Currency FROM FACT_RemittanceReqs (nolock)) mr on mr.RemittanceTransactionsId = l.Id
				WHERE (l.CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND l.CreatedAt < @BaseDay) AND FeatureType IN (7,21)
				GROUP BY CAST(l.CreatedAt AS DATE), l.Currency
			) k
			FULL OUTER JOIN
			(
				SELECT
						CAST(CreatedAt AS DATE) [Date],
						Currency
					   ,Cnt(DISTINCT CASE WHEN [Type]  = 1  AND	[Status] = 1		THEN User_Key ELSE NULL END)	 InviteByMoneySendCompletedUserAttributesCnt
			--		   ,Cnt(		   CASE WHEN [Type]  = 1  AND	[Status] = 1		THEN Id		 ELSE NULL END)	 InviteBySendMoneyCompletedCnt
			--		   ,ABS(SUM(	   CASE WHEN [Type]  = 1  AND	[Status] = 1		THEN TxAmount	 ELSE NULL END)) InviteBySendMoneyCompletedVol
			--		   ,Cnt(		   CASE WHEN [Type]  = 1  AND	[Status] in  (0,1)	THEN Id		 ELSE NULL END)	 InviteBySendMoneyCnt
			--		   ,ABS(SUM(	   CASE WHEN [Type]  = 1  AND	[Status] in  (0,1)	THEN TxAmount  ELSE NULL END)) InviteBySendMoneyVol

				FROM FACT_InviteByRemittances (NOLOCK)
				WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
				GROUP BY CAST(CreatedAt AS DATE), Currency
			) z on z.[Date] =k.[Date] and Z.Currency = K.Currency
			FULL OUTER JOIN
			(
				SELECT
						CAST(CreatedAt AS DATE) [Date]
					   ,Currency
					   ,Cnt(CASE WHEN Method	 = 2						  THEN Id			 ELSE NULL END)	RemittanceReqAcCntNoCnt				
					   ,SUM(  CASE WHEN Method	 = 2						  THEN TxAmount		 ELSE NULL END)	RemittanceReqAcCntNoVol	
					   ,Cnt(*)											  									RemittanceReqCnt
					   ,Cnt(CASE WHEN Method	 = 1						  THEN Id			 ELSE NULL END)	RemittanceReqPhoneNoCnt				
					   ,SUM(  CASE WHEN Method	 = 1						  THEN TxAmount		 ELSE NULL END)	RemittanceReqPhoneNoVol
					   ,Cnt(DISTINCT CASE WHEN Method	 = 2				  THEN User_Key		 ELSE NULL END)	RemittanceReqReceivedAcCntNoUserAttributesCnt
					   ,Cnt(DISTINCT CASE WHEN Method	 = 1				  THEN User_Key		 ELSE NULL END)	RemittanceReqReceivedPhoneNoUserAttributesCnt
					   ,Cnt(DISTINCT CASE WHEN Method	 = 2				  THEN OtherUser_Key ELSE NULL END)	RemittanceReqSendAcCntNoUserAttributesCnt
					   ,Cnt(DISTINCT CASE WHEN Method	 = 1				  THEN OtherUser_Key ELSE NULL END)	RemittanceReqSendPhoneNoUserAttributesCnt
					   ,SUM(TxAmount)																				RemittanceReqVol
				--	   ,Cnt(CASE WHEN IsSplitted = 1 AND [Status] in (2,3)  THEN Id			 ELSE NULL END)	RemittanceReqWithSplitCancelledCnt
				--	   ,SUM(  CASE WHEN IsSplitted = 1 AND [Status] in (2,3)  THEN TxAmount		 ELSE NULL END)	RemittanceReqWithSplitCancelledVol
				--	   ,Cnt(CASE WHEN IsSplitted = 1 AND [Status] = 1		  THEN Id			 ELSE NULL END)	RemittanceReqWithSplitCompletedCnt
				--	   ,SUM(  CASE WHEN IsSplitted = 1 AND [Status] = 1		  THEN TxAmount		 ELSE NULL END)	RemittanceReqWithSplitCompletedVol
					   ,Cnt(DISTINCT User_Key)																TotalRemittanceReqReceivedUserAttributesCnt
					   ,Cnt(DISTINCT OtherUser_Key)															TotalRemittanceReqSendUserAttributesCnt
					   ,Cnt(DISTINCT User_Key)																TotalRemittanceReqUserAttributesCnt
				FROM FACT_RemittanceReqs (nolock)
				WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
				GROUP BY CAST(CreatedAt AS DATE), Currency
			) t on t.[Date] = z.[Date] and t.Currency = z.Currency
		WHERE
				    AcCntNoCnt								!= 0
				or AcCntNoVol								!= 0
				or CompletedRemittanceReqCnt						!= 0
				or CompletedRemittanceReqVol						!= 0
				or IbanRemittanceCnt							!= 0
				or IbanRemittanceUserAttributesCnt						!= 0
				or IbanRemittanceVol							!= 0
				or InviteByMoneySendCompletedUserAttributesCnt				!= 0
		--		or InviteBySendMoneyCompletedCnt					!= 0
		--		or InviteBySendMoneyCompletedVol					!= 0
		--		or InviteBySendMoneyCnt							!= 0
		--		or InviteBySendMoneyVol							!= 0
				or RemittanceReqAcCntNoCnt					!= 0
				or RemittanceReqAcCntNoVol					!= 0
				or RemittanceReqCnt								!= 0
				or RemittanceReqPhoneNoCnt						!= 0
				or RemittanceReqPhoneNoVol					!= 0
				or RemittanceReqReceivedAcCntNoUserAttributesCnt		!= 0
				or RemittanceReqReceivedPhoneNoUserAttributesCnt		!= 0
				or RemittanceReqSendAcCntNoUserAttributesCnt			!= 0
				or RemittanceReqSendPhoneNoUserAttributesCnt			!= 0
				or RemittanceReqVol								!= 0
		--		or RemittanceReqWithSplitCancelledCnt				!= 0
		--		or RemittanceReqWithSplitCancelledVol				!= 0
		--		or RemittanceReqWithSplitCompletedCnt				!= 0
		--		or RemittanceReqWithSplitCompletedVol				!= 0
				or RemittanceFee									!= 0
				or PaidRecievedCnt								!= 0
				or PaidRecievedVol								!= 0
				or PhoneNoCnt									!= 0
				or PhoneNoVol								!= 0
				or QrCodeCnt										!= 0
				or QrCodeVol										!= 0
				or ReceivedAcCntNoUserAttributesCnt					!= 0
				or ReceivedPhoneNoUserAttributesCnt					!= 0
				or ReceivedQrUserAttributesCnt								!= 0
				or SendAcCntNoUserAttributesCnt						!= 0
				or SendPhoneNoUserAttributesCnt						!= 0
				or SendQrUserAttributesCnt									!= 0
				or TotalRemittanceReqReceivedUserAttributesCnt				!= 0
				or TotalRemittanceReqSendUserAttributesCnt					!= 0
				or TotalRemittanceReqUserAttributesCnt						!= 0
				or TotalRemittanceUserAttributesCnt						!= 0
				or TotalReceivedRemittanceUserAttributesCnt				!= 0
				or TotalSendRemittanceUserAttributesCnt					!= 0
				or WithNoteCnt									!= 0
				or WithNoteVol									!= 0		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource*/
PRINT '5 - Completed - #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource'  + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource*/		
/*Manuel karsilastirma için Admin Raporu */
SELECT CAST(CreatedAt AS DATE) [Date]
		   ,Currency
		   ,CAST(ISNULL(AcCntNoCnt																,0) AS DECIMAL(20,1))	AcCntNoCnt															
		   ,CAST(ISNULL(AcCntNoVol																,0) AS DECIMAL(20,1))	AcCntNoVol														
		   ,CAST(ISNULL(CompletedRemittanceReqCnt														,0) AS DECIMAL(20,1))	CompletedRemittanceReqCnt													
		   ,CAST(ISNULL(CompletedRemittanceReqVol														,0) AS DECIMAL(20,1))	CompletedRemittanceReqVol												
		   ,CAST(ISNULL(IbanRemittanceCnt															,0) AS DECIMAL(20,1))	IbanRemittanceCnt														
		   ,CAST(ISNULL(IbanRemittanceUserAttributesCnt														,0) AS DECIMAL(20,1))	IbanRemittanceUserAttributesCnt												
		   ,CAST(ISNULL(IbanRemittanceVol															,0) AS DECIMAL(20,1))	IbanRemittanceVol													
		   ,CAST(ISNULL(InviteByMoneySendCompletedUserAttributesCnt											,0) AS DECIMAL(20,1))	InviteByMoneySendCompletedUserAttributesCnt										
	--	   ,CAST(ISNULL(InviteBySendMoneyCompletedCnt													,0) AS DECIMAL(20,1))	InviteBySendMoneyCompletedCnt											
	--	   ,CAST(ISNULL(InviteBySendMoneyCompletedVol												,0) AS DECIMAL(20,1))	InviteBySendMoneyCompletedVol											
	--	   ,CAST(ISNULL(InviteBySendMoneyCnt															,0) AS DECIMAL(20,1))	InviteBySendMoneyCnt														
	--	   ,CAST(ISNULL(InviteBySendMoneyVol															,0) AS DECIMAL(20,1))	InviteBySendMoneyVol													
		   ,CAST(ISNULL(RemittanceReqAcCntNoCnt													,0) AS DECIMAL(20,1))	RemittanceReqAcCntNoCnt												
		   ,CAST(ISNULL(RemittanceReqAcCntNoVol													,0) AS DECIMAL(20,1))	RemittanceReqAcCntNoVol											
		   ,CAST(ISNULL(RemittanceReqCnt																,0) AS DECIMAL(20,1))	RemittanceReqCnt															
		   ,CAST(ISNULL(RemittanceReqPhoneNoCnt													,0) AS DECIMAL(20,1))	RemittanceReqPhoneNoCnt												
		   ,CAST(ISNULL(RemittanceReqPhoneNoVol													,0) AS DECIMAL(20,1))	RemittanceReqPhoneNoVol												
		   ,CAST(ISNULL(RemittanceReqReceivedAcCntNoUserAttributesCnt										,0) AS DECIMAL(20,1))	RemittanceReqReceivedAcCntNoUserAttributesCnt								
		   ,CAST(ISNULL(RemittanceReqReceivedPhoneNoUserAttributesCnt										,0) AS DECIMAL(20,1))	RemittanceReqReceivedPhoneNoUserAttributesCnt									
		   ,CAST(ISNULL(RemittanceReqSendAcCntNoUserAttributesCnt											,0) AS DECIMAL(20,1))	RemittanceReqSendAcCntNoUserAttributesCnt									
		   ,CAST(ISNULL(RemittanceReqSendPhoneNoUserAttributesCnt											,0) AS DECIMAL(20,1))	RemittanceReqSendPhoneNoUserAttributesCnt										
		   ,CAST(ISNULL(RemittanceReqVol																,0) AS DECIMAL(20,1))	RemittanceReqVol															
	--	   ,CAST(ISNULL(RemittanceReqWithSplitCancelledCnt												,0) AS DECIMAL(20,1))	RemittanceReqWithSplitCancelledCnt										
	--	   ,CAST(ISNULL(RemittanceReqWithSplitCancelledVol											,0) AS DECIMAL(20,1))	RemittanceReqWithSplitCancelledVol										
	--	   ,CAST(ISNULL(RemittanceReqWithSplitCompletedCnt												,0) AS DECIMAL(20,1))	RemittanceReqWithSplitCompletedCnt										
	--	   ,CAST(ISNULL(RemittanceReqWithSplitCompletedVol											,0) AS DECIMAL(20,1))	RemittanceReqWithSplitCompletedVol										
		   ,CAST(ISNULL(RemittanceFee																,0) AS DECIMAL(20,1))	RemittanceFee															
		   ,CAST(ISNULL(PaidRecievedCnt																,0) AS DECIMAL(20,1))	PaidRecievedCnt															
		   ,CAST(ISNULL(PaidRecievedVol																,0) AS DECIMAL(20,1))	PaidRecievedVol															
		   ,CAST(ISNULL(PhoneNoCnt																,0) AS DECIMAL(20,1))	PhoneNoCnt															
		   ,CAST(ISNULL(PhoneNoVol																,0) AS DECIMAL(20,1))	PhoneNoVol															
		   ,CAST(ISNULL(QrCodeCnt																		,0) AS DECIMAL(20,1))	QrCodeCnt																
		   ,CAST(ISNULL(QrCodeVol																	,0) AS DECIMAL(20,1))	QrCodeVol																
		   ,CAST(ISNULL(ReceivedAcCntNoUserAttributesCnt													,0) AS DECIMAL(20,1))	ReceivedAcCntNoUserAttributesCnt											
		   ,CAST(ISNULL(ReceivedPhoneNoUserAttributesCnt													,0) AS DECIMAL(20,1))	ReceivedPhoneNoUserAttributesCnt												
		   ,CAST(ISNULL(ReceivedQrUserAttributesCnt															,0) AS DECIMAL(20,1))	ReceivedQrUserAttributesCnt														
		   ,CAST(ISNULL(SendAcCntNoUserAttributesCnt														,0) AS DECIMAL(20,1))	SendAcCntNoUserAttributesCnt												
		   ,CAST(ISNULL(SendPhoneNoUserAttributesCnt														,0) AS DECIMAL(20,1))	SendPhoneNoUserAttributesCnt													
		   ,CAST(ISNULL(SendQrUserAttributesCnt																,0) AS DECIMAL(20,1))	SendQrUserAttributesCnt															
		   ,CAST(ISNULL(TotalRemittanceReqReceivedUserAttributesCnt												,0) AS DECIMAL(20,1))	TotalRemittanceReqReceivedUserAttributesCnt										
		   ,CAST(ISNULL(TotalRemittanceReqSendUserAttributesCnt													,0) AS DECIMAL(20,1))	TotalRemittanceReqSendUserAttributesCnt											
		   ,CAST(ISNULL(TotalRemittanceReqUserAttributesCnt														,0) AS DECIMAL(20,1))	TotalRemittanceReqUserAttributesCnt												
		   ,CAST(ISNULL(TotalRemittanceUserAttributesCnt													,0) AS DECIMAL(20,1))	TotalRemittanceUserAttributesCnt												
		   ,CAST(ISNULL(TotalReceivedRemittanceUserAttributesCnt											,0) AS DECIMAL(20,1))	TotalReceivedRemittanceUserAttributesCnt										
		   ,CAST(ISNULL(TotalSendRemittanceUserAttributesCnt												,0) AS DECIMAL(20,1))	TotalSendRemittanceUserAttributesCnt											
		 --,CAST(ISNULL(UserExceedingRemittanceReceiverLimitCnt /*DWH'ta tablosu yoktur*/			,0) AS DECIMAL(20,1))	(-,UserExceedingRemittanceReceiverLimitCnt /*DWH'ta tablosu yoktur*/	
	     --,CAST(ISNULL(UserExceedingRemittanceSenderLimitCnt   /*DWH'ta tablosu yoktur*/			,0) AS DECIMAL(20,1))	(-,UserExceedingRemittanceSenderLimitCnt   /*DWH'ta tablosu yoktur*/	
		   ,CAST(ISNULL(WithNoteCnt																	,0) AS DECIMAL(20,1))	WithNoteCnt																
		   ,CAST(ISNULL(WithNoteVol																	,0) AS DECIMAL(20,1))	WithNoteVol																
		INTO #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource									
FROM FACT_DailyRemittanceCSEntityDataSource (nolock)
WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
/*END - #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource*/	
PRINT '6 - Completed - #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A*/	
SELECT
	  CAST(CreatedAt AS DATE)																																						 [Date]
	 ,CAST(ISNULL(Cnt(U.User_Key)																							 ,0) AS DECIMAL(20,1))	/*Total New UserAttributes*/				 'NewUserAttributes'
	 ,CAST(ISNULL(Cnt(CASE WHEN							 InorganicSigninRefCode IS NULL	 THEN U.User_Key ELSE NULL END)	 ,0) AS DECIMAL(20,1))	/*New UserAttributes (Organic)*/			 'NewUserAttributesOrganic'
	 ,CAST(ISNULL(Cnt(CASE WHEN							 InorganicSigninRefCode IS NOT NULL THEN U.User_Key ELSE NULL END)	 ,0) AS DECIMAL(20,1))	/*New UserAttributes (Marketing)*/		 'NewUserAttributesMarketing'
	 ,CAST(ISNULL(Cnt(CASE WHEN SigninType	 = 0	 AND InorganicSigninRefCode IS NULL	 THEN U.User_Key ELSE NULL END)	 ,0) AS DECIMAL(20,1))	/*Browser Registers (Organic)*/		 'BrowserRegistersOrganic'
	 ,CAST(ISNULL(Cnt(CASE WHEN SigninType	 = 0	 AND InorganicSigninRefCode IS NOT NULL THEN U.User_Key ELSE NULL END)	 ,0) AS DECIMAL(20,1))	/*Browser Registers (Marketing)*/	 'BrowserRegistersMarketing'
	 ,CAST(ISNULL(Cnt(CASE WHEN SigninMethod	 = 0	 AND SigninType = 0				 THEN U.User_Key ELSE NULL END)	 ,0) AS DECIMAL(20,1))	/*Browser Registers (Form)*/		 'BrowserRegistersForm'
	 ,CAST(ISNULL(Cnt(CASE WHEN SigninMethod	 = 2	 AND SigninType = 0				 THEN U.User_Key ELSE NULL END)	 ,0) AS DECIMAL(20,1))	/*Browser Registers (Google)*/		 'BrowserRegistersGoogle'
	 ,CAST(ISNULL(Cnt(CASE WHEN SigninMethod	 = 1	 AND SigninType = 0				 THEN U.User_Key ELSE NULL END)	 ,0) AS DECIMAL(20,1))	/*Browser Registers (Facebook)*/	 'BrowserRegistersFacebook'
	 ,CAST(ISNULL(Cnt(CASE WHEN SigninType IN (1,2) AND InorganicSigninRefCode IS NULL	 THEN U.User_Key ELSE NULL END)	 ,0) AS DECIMAL(20,1))	/*Mobile Registers (Organic)*/	 'MobileRegistersOrganic'		--Huawei (SigninType = 3) Admin Report'ta alinmamis
	 ,CAST(ISNULL(Cnt(CASE WHEN SigninType IN (1,2) AND InorganicSigninRefCode IS NOT NULL THEN U.User_Key ELSE NULL END)	 ,0) AS DECIMAL(20,1))	/*Mobile Registers (Marketing)*/ 'MobileRegistersMarketing'		--Huawei (SigninType = 3) Admin Report'ta alinmamis
	 ,CAST(ISNULL(Cnt(CASE WHEN SigninMethod	 = 0	 AND SigninType = 1				 THEN U.User_Key ELSE NULL END)	 ,0) AS DECIMAL(20,1))									 'IosRegistersForm'
	 ,CAST(ISNULL(Cnt(CASE WHEN SigninMethod	 = 1	 AND SigninType = 1				 THEN U.User_Key ELSE NULL END)	 ,0) AS DECIMAL(20,1))									 'IosRegistersFacebook'
	 ,CAST(ISNULL(Cnt(CASE WHEN SigninMethod	 = 3	 AND SigninType = 1				 THEN U.User_Key ELSE NULL END)	 ,0) AS DECIMAL(20,1))									 'IosRegistersApple'
	 ,CAST(ISNULL(Cnt(CASE WHEN SigninMethod	 = 0	 AND SigninType = 2				 THEN U.User_Key ELSE NULL END)	 ,0) AS DECIMAL(20,1))									 'AndroidRegistersForm'
	 ,CAST(ISNULL(Cnt(CASE WHEN SigninMethod	 = 2	 AND SigninType = 2				 THEN U.User_Key ELSE NULL END)	 ,0) AS DECIMAL(20,1))									 'AndroidRegistersGoogle'
	 ,CAST(ISNULL(Cnt(CASE WHEN SigninMethod	 = 1	 AND SigninType = 2				 THEN U.User_Key ELSE NULL END)	 ,0) AS DECIMAL(20,1))									 'AndroidRegistersFacebook'
	 ,CAST(ISNULL(Cnt(CASE WHEN SigninMethod	 = 0	 AND SigninType = 3				 THEN U.User_Key ELSE NULL END)	 ,0) AS DECIMAL(20,1))									 'HuaweiRegistersForm'
	 ,CAST(ISNULL(Cnt(CASE WHEN SigninMethod	 = 2	 AND SigninType = 3				 THEN U.User_Key ELSE NULL END)	 ,0) AS DECIMAL(20,1))									 'HuaweiRegistersGoogle'
	 ,CAST(ISNULL(Cnt(CASE WHEN SigninMethod	 = 1	 AND SigninType = 3				 THEN U.User_Key ELSE NULL END)	 ,0) AS DECIMAL(20,1))									 'HuaweiRegistersFacebook'
--	 ,CAST(ISNULL(Cnt(CASE WHEN ProfilePhotoURL IS NOT NULL									 THEN U.User_Key ELSE NULL END)  ,0) AS DECIMAL(20,1))									  ProfilePictureRegistersDaily	--Test tipi degil
INTO #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A
FROM DIM_UserAttributes (NOLOCK) u
JOIN DIM_UserAttributes_Details (nolock) Ud on UD.User_Key = U.User_Key
WHERE	  CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
GROUP BY					  CAST(CreatedAt AS DATE)
/*END - #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A*/	
PRINT '7 - Completed - #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_B*/
SELECT CAST(CreatedAt AS DATE) [Date],
	   CAST(ISNULL(Cnt(distinct User_Key),0) AS DECIMAL(20,2)) 'ActiveLoginDailyCnt'
INTO #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_B
FROM FACT_UserLogins (nolock) 
where CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
group by CAST(CreatedAt AS DATE)
/*END - #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_B*/
PRINT '8 - Completed - #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_B' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_C*/
SELECT CAST(CreatedAt AS DATE) [Date],
	   CAST(ISNULL(Cnt(distinct User_Key),0) AS DECIMAL(20,2)) 'ActiveFinancialTransactionDailyCnt'
INTO #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_C
FROM FACT_Transactions (nolock) 
WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
GROUP BY CAST(CreatedAt AS DATE)
/*END - #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_C*/
PRINT '9 - Completed - #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_C' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_D*/
SELECT
	*
INTO #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_D
FROM	
	  (
		SELECT CAST(CreatedAt AS DATE) [Date], 
			   CAST(ISNULL(SUM(Cnt(User_Key)) OVER (ORDER BY CAST(CreatedAt AS DATE)),0) AS DECIMAL(20,2)) 'TotalUserAttributes'
		FROM DIM_UserAttributes (nolock) 
		WHERE CreatedAt < @BaseDay
		GROUP BY CAST(CreatedAt AS DATE)
	  ) TURT
WHERE [Date] >= DATEADD(DAY,-@d,@BaseDay) AND [Date] < @BaseDay
/*END - #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_D*/
PRINT '10 - Completed - #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_D' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))
	   
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_E*/
SELECT
	 CAST(UiR.CreatedAt AS DATE) [Date]
	,CAST(ISNULL(AVG(DATEDIFF(YEAR,U.DateOfBirth,@BaseDay)),0)								   AS DECIMAL(20,2)) NewApprovedUserAttributesAverageAge
	,CAST(ISNULL(Cnt(DISTINCT CASE WHEN u.ApprovalType = 3 THEN u.User_Key ELSE NULL END),0) AS DECIMAL(20,2)) AcceptanceMethodForeignIdentity
	,CAST(ISNULL(Cnt(DISTINCT CASE WHEN u.ApprovalType = 2 THEN u.User_Key ELSE NULL END),0) AS DECIMAL(20,2)) AcceptanceMethodIdentity
	,CAST(ISNULL(Cnt(DISTINCT CASE WHEN u.ApprovalType = 1 THEN u.User_Key ELSE NULL END),0) AS DECIMAL(20,2)) AcceptanceMethodTCKK
INTO #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_E
FROM DIM_UserAttributes (nolock) U
JOIN FACT_UserIdentityRegistrations (nolock) UiR
on U.User_Key = UiR.User_Key
WHERE Uir.CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND Uir.CreatedAt < @BaseDay
GROUP BY CAST(UiR.CreatedAt AS DATE)
/*END - #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_E*/
PRINT '11 - Completed - #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_E'  + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A*/	
SELECT CAST(CreatedAt AS DATE)								[Date]
	  ,CAST(NewUserAttributes							 AS DECIMAL(20,1))	NewUserAttributes					
	  ,CAST(NewUserAttributesOrganic   					 AS DECIMAL(20,1))	NewUserAttributesOrganic   			
	  ,CAST(NewUserAttributesMarketing					 AS DECIMAL(20,1))	NewUserAttributesMarketing			
	  ,CAST(BrowserRegistersOrganic					 AS DECIMAL(20,1))	BrowserRegistersOrganic		
	  ,CAST(BrowserRegistersMarketing				 AS DECIMAL(20,1))	BrowserRegistersMarketing		
	  ,CAST(BrowserRegistersForm					 AS DECIMAL(20,1))	BrowserRegistersForm			
	  ,CAST(BrowserRegistersGoogle					 AS DECIMAL(20,1))	BrowserRegistersGoogle			
	  ,CAST(BrowserRegistersFacebook				 AS DECIMAL(20,1))	BrowserRegistersFacebook		
	  ,CAST(MobileRegistersOrganic				 AS DECIMAL(20,1))	MobileRegistersOrganic		
	  ,CAST(MobileRegistersMarketing			 AS DECIMAL(20,1))	MobileRegistersMarketing	
	  ,CAST(IosRegistersForm					 AS DECIMAL(20,1))	IosRegistersForm			
	  ,CAST(IosRegistersFacebook				 AS DECIMAL(20,1))	IosRegistersFacebook		
	  ,CAST(IosRegistersApple					 AS DECIMAL(20,1))	IosRegistersApple			
	  ,CAST(AndroidRegistersForm				 AS DECIMAL(20,1))	AndroidRegistersForm		
	  ,CAST(AndroidRegistersGoogle				 AS DECIMAL(20,1))	AndroidRegistersGoogle		
	  ,CAST(AndroidRegistersFacebook			 AS DECIMAL(20,1))	AndroidRegistersFacebook	
	  ,CAST(HuaweiRegistersForm					 AS DECIMAL(20,1))	HuaweiRegistersForm		
	  ,CAST(HuaweiRegistersGoogle				 AS DECIMAL(20,1))	HuaweiRegistersGoogle		
	  ,CAST(HuaweiRegistersFacebook				 AS DECIMAL(20,1))	HuaweiRegistersFacebook
	  ,CAST(ActiveLoginDailyCnt				 AS DECIMAL(20,1))  ActiveLoginDailyCnt				 /*#CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_B*/						
	  ,CAST(ActiveFinancialTransactionDailyCnt AS	DECIMAL(20,1))	ActiveFinancialTransactionDailyCnt /*#CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_C*/
	  ,CAST(TotalUserAttributes							 AS	DECIMAL(20,1))	TotalUserAttributes							 /*#CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_D*/						
	  ,CAST(NewApprovedUserAttributesAverageAge			 AS	DECIMAL(20,1))	NewApprovedUserAttributesAverageAge			 /*#CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_E*/
	  ,CAST(AcceptanceMethodForeignIdentity		 AS DECIMAL(20,1))	AcceptanceMethodForeignIdentity		
	  ,CAST(AcceptanceMethodIdentity				 AS DECIMAL(20,1))	AcceptanceMethodIdentity	
	  ,CAST(AcceptanceMethodTCKK					 AS DECIMAL(20,1))	AcceptanceMethodTCKK		
--	  ,CAST(ProfilePictureRegistersDaily  AS DECIMAL(20,1))	ProfilePictureRegistersDaily
INTO #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A
FROM FACT_DailyUserAttributesCSEntityDataSource (nolock)
WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
/*END - #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A*/	
PRINT '12 - Completed - #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A'		 + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource*/	
		SELECT
		  k.[Date]
		 ,k.JobTypeName
		 ,CAST(ISNULL(PaidUniqueUserCntDaily					,0) AS DECIMAL(20,1))	PaidUniqueUserCntDaily
		 ,CAST(ISNULL(PaidUniqueUserWithAcCntCntDaily		,0) AS DECIMAL(20,1))	PaidUniqueUserWithAcCntCntDaily
		 ,CAST(ISNULL(PaidUniqueUserWithCardCntDaily			,0) AS DECIMAL(20,1))	PaidUniqueUserWithCardCntDaily
		 ,CAST(ISNULL(ReceivingCntToAcCntWithAcCnt		,0) AS DECIMAL(20,1))	ReceivingCntToAcCntWithAcCnt
		 ,CAST(ISNULL(ReceivingCntToAcCntWithCard			,0) AS DECIMAL(20,1))	ReceivingCntToAcCntWithCard
		 ,CAST(ISNULL(ReceivingCntToMobileWithAcCnt			,0) AS DECIMAL(20,1))	ReceivingCntToMobileWithAcCnt
		 ,CAST(ISNULL(ReceivingCntToMobileWithCard			,0) AS DECIMAL(20,1))	ReceivingCntToMobileWithCard
		 ,CAST(ISNULL(ReceivingCntToQrCodeWithAcCnt			,0) AS DECIMAL(20,1))	ReceivingCntToQrCodeWithAcCnt
		 ,CAST(ISNULL(ReceivingCntToQrCodeWithCard			,0) AS DECIMAL(20,1))	ReceivingCntToQrCodeWithCard
		 ,CAST(ISNULL(ReceivingVolToAcVolWithAcVol		,0) AS DECIMAL(20,1))	ReceivingVolToAcCntWithAcCnt
		 ,CAST(ISNULL(ReceivingVolToAcVolWithCard			,0) AS DECIMAL(20,1))	ReceivingVolToAcCntWithCard
		 ,CAST(ISNULL(ReceivingVolToMobileWithAcVol		,0) AS DECIMAL(20,1))	ReceivingVolToMobileWithAcCnt
		 ,CAST(ISNULL(ReceivingVolToMobileWithCard			,0) AS DECIMAL(20,1))	ReceivingVolToMobileWithCard
		 ,CAST(ISNULL(ReceivingVolToQrCodeWithAcVol		,0) AS DECIMAL(20,1))	ReceivingVolToQrCodeWithAcCnt
		 ,CAST(ISNULL(ReceivingVolToQrCodeWithCard			,0) AS DECIMAL(20,1))	ReceivingVolToQrCodeWithCard
		 ,CAST(ISNULL(SuccessfullApplyDailyCnt				,0) AS DECIMAL(20,1))	SuccessfullApplyDailyCnt
		 ,CAST(ISNULL(UniqueReceivingDailyCnt					,0) AS DECIMAL(20,1))	UniqueReceivingDailyCnt
		 ,CAST(ISNULL(UnsuccessfullApplyDailyCnt				,0) AS DECIMAL(20,1))	UnsuccessfullApplyDailyCnt
		INTO #PROD_TO_DWH_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource
		FROM
		
			(
				SELECT
					    CAST(l.CreatedAt AS DATE) [Date]
					   ,jt.Name_Tr																														JobTypeName
					   ,CAST(ISNULL(Cnt(DISTINCT  l.OtherUser_Key),0) AS DECIMAL(20,1))																PaidUniqueUserCntDaily
					   ,CAST(ISNULL(Cnt(DISTINCT CASE WHEN l.FeatureType = 7				    THEN l.OtherUser_Key	ELSE NULL END),0) AS DECIMAL(20,1))	PaidUniqueUserWithAcCntCntDaily
					   ,CAST(ISNULL(Cnt(DISTINCT CASE WHEN l.FeatureType = 20				    THEN l.OtherUser_Key	ELSE NULL END),0) AS DECIMAL(20,1))	PaidUniqueUserWithCardCntDaily
					   ,CAST(ISNULL(Cnt(DISTINCT CASE WHEN l.FeatureType = 7  AND Method = 2	THEN l.Id			ELSE NULL END),0) AS DECIMAL(20,1))	ReceivingCntToAcCntWithAcCnt
					   ,CAST(ISNULL(Cnt(DISTINCT CASE WHEN l.FeatureType = 20 AND Method = 2	THEN l.Id			ELSE NULL END),0) AS DECIMAL(20,1))	ReceivingCntToAcCntWithCard
					   ,CAST(ISNULL(Cnt(DISTINCT CASE WHEN l.FeatureType = 7  AND Method = 1	THEN l.Id			ELSE NULL END),0) AS DECIMAL(20,1))	ReceivingCntToMobileWithAcCnt
					   ,CAST(ISNULL(Cnt(DISTINCT CASE WHEN l.FeatureType = 20 AND Method = 1	THEN l.Id			ELSE NULL END),0) AS DECIMAL(20,1))	ReceivingCntToMobileWithCard
					   ,CAST(ISNULL(Cnt(DISTINCT CASE WHEN l.FeatureType = 7  AND Method = 3	THEN l.Id			ELSE NULL END),0) AS DECIMAL(20,1))	ReceivingCntToQrCodeWithAcCnt
					   ,CAST(ISNULL(Cnt(DISTINCT CASE WHEN l.FeatureType = 20 AND Method = 3	THEN l.Id			ELSE NULL END),0) AS DECIMAL(20,1))	ReceivingCntToQrCodeWithCard
					   ,CAST(ISNULL(SUM(		   CASE WHEN l.FeatureType = 7  AND Method = 2	THEN l.TxAmount		ELSE NULL END),0) AS DECIMAL(20,1))	ReceivingVolToAcVolWithAcVol
					   ,CAST(ISNULL(SUM(		   CASE WHEN l.FeatureType = 20 AND Method = 2	THEN l.TxAmount		ELSE NULL END),0) AS DECIMAL(20,1))	ReceivingVolToAcVolWithCard
					   ,CAST(ISNULL(SUM(		   CASE WHEN l.FeatureType = 7  AND Method = 1	THEN l.TxAmount		ELSE NULL END),0) AS DECIMAL(20,1))	ReceivingVolToMobileWithAcVol
					   ,CAST(ISNULL(SUM(		   CASE WHEN l.FeatureType = 20 AND Method = 1	THEN l.TxAmount		ELSE NULL END),0) AS DECIMAL(20,1))	ReceivingVolToMobileWithCard
					   ,CAST(ISNULL(SUM(		   CASE WHEN l.FeatureType = 7  AND Method = 3	THEN l.TxAmount		ELSE NULL END),0) AS DECIMAL(20,1))	ReceivingVolToQrCodeWithAcVol
					   ,CAST(ISNULL(SUM(		   CASE WHEN l.FeatureType = 20 AND Method = 3	THEN l.TxAmount		ELSE NULL END),0) AS DECIMAL(20,1))	ReceivingVolToQrCodeWithCard
					   ,CAST(ISNULL(Cnt(DISTINCT User_Key),0) AS DECIMAL(20,1))																		UniqueReceivingDailyCnt
				FROM FACT_Transactions (nolock) L
				INNER JOIN DIM_UserAttributes	(nolock) u  on u.User_Key = L.User_Key
				RIGHT JOIN DIM_JobTypes (nolock) jt on		jt.Id = u.JobType
				WHERE (l.CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND l.CreatedAt < @BaseDay) AND jt.IsCommercial = 1 and l.IsCommercial = 1 and L.RemittanceType = 0--l.TxAmount>0
				GROUP BY CAST(l.CreatedAt AS DATE), jt.Name_Tr
			) k
			LEFT JOIN
			(
				SELECT
						CAST(a.CreatedAt AS DATE) [Date]
					   ,jt.Name_Tr													JobTypeName
					   ,Cnt(CASE WHEN OperationName = 90 THEN a.Id ELSE NULL END)	SuccessfullApplyDailyCnt
					   ,Cnt(CASE WHEN OperationName = 91 THEN a.Id ELSE NULL END)	UnsuccessfullApplyDailyCnt


				FROM FACT_AuditionLogs		(nolock) a
				INNER JOIN DIM_UserAttributes	(nolock) u  on u.User_Key = a.User_Key
				RIGHT JOIN DIM_JobTypes (nolock) jt on	    jt.Id = u.JobType
				WHERE a.CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND a.CreatedAt < @BaseDay
				GROUP BY CAST(a.CreatedAt AS DATE), jt.Name_Tr
			) z on z.[Date] = k.[Date] AND k.JobTypeName = z.JobTypeName

/*END - #PROD_TO_DWH_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource*/	
PRINT '13 - Completed - #PROD_TO_DWH_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource'  + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #CSHARP_TO_PROD_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource*/
SELECT CAST(CreatedAt AS DATE) [Date]
		   ,JobTypeName
		   ,CAST(PaidUniqueUserCntDaily				AS DECIMAL(20,1))	PaidUniqueUserCntDaily
		   ,CAST(PaidUniqueUserWithAcCntCntDaily	AS DECIMAL(20,1))	PaidUniqueUserWithAcCntCntDaily
		   ,CAST(PaidUniqueUserWithCardCntDaily		AS DECIMAL(20,1))	PaidUniqueUserWithCardCntDaily
		   ,CAST(ReceivingCntToAcCntWithAcCnt		AS DECIMAL(20,1))	ReceivingCntToAcCntWithAcCnt
		   ,CAST(ReceivingCntToAcCntWithCard		AS DECIMAL(20,1))	ReceivingCntToAcCntWithCard
		   ,CAST(ReceivingCntToMobileWithAcCnt		AS DECIMAL(20,1))	ReceivingCntToMobileWithAcCnt
		   ,CAST(ReceivingCntToMobileWithCard			AS DECIMAL(20,1))	ReceivingCntToMobileWithCard
		   ,CAST(ReceivingCntToQrCodeWithAcCnt		AS DECIMAL(20,1))	ReceivingCntToQrCodeWithAcCnt
		   ,CAST(ReceivingCntToQrCodeWithCard			AS DECIMAL(20,1))	ReceivingCntToQrCodeWithCard
		   ,CAST(ReceivingVolToAcCntWithAcCnt	AS DECIMAL(20,1))	ReceivingVolToAcCntWithAcCnt
		   ,CAST(ReceivingVolToAcCntWithCard		AS DECIMAL(20,1))	ReceivingVolToAcCntWithCard
		   ,CAST(ReceivingVolToMobileWithAcCnt		AS DECIMAL(20,1))	ReceivingVolToMobileWithAcCnt
		   ,CAST(ReceivingVolToMobileWithCard		AS DECIMAL(20,1))	ReceivingVolToMobileWithCard
		   ,CAST(ReceivingVolToQrCodeWithAcCnt		AS DECIMAL(20,1))	ReceivingVolToQrCodeWithAcCnt
		   ,CAST(ReceivingVolToQrCodeWithCard		AS DECIMAL(20,1))	ReceivingVolToQrCodeWithCard
		   ,CAST(SuccessfullApplyDailyCnt				AS DECIMAL(20,1))	SuccessfullApplyDailyCnt
		   ,CAST(UniqueReceivingDailyCnt				AS DECIMAL(20,1))	UniqueReceivingDailyCnt
		   ,CAST(UnsuccessfullApplyDailyCnt			AS DECIMAL(20,1))	UnsuccessfullApplyDailyCnt
INTO #CSHARP_TO_PROD_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource
FROM FACT_DailyPersonalCommercialCSEntityDataSource (nolock)
WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
ORDER BY [Date], JobTypeName
/*END - #CSHARP_TO_PROD_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource*/
PRINT '14 - Completed - #CSHARP_TO_PROD_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource*/	
		SELECT --Sayilarin farkli gelmesi normaldir.
		  k.[Date]
		 ,k.Currency
		 ,CAST(ISNULL(MerchandiserBankTransferTxVol		,0)	  AS DECIMAL(20,1))																											MerchandiserBankTransferTxVol
		 ,CAST(ISNULL(BankTransferTxVol				,0)	  AS DECIMAL(20,1))																											BankTransferTxVol
		 ,CAST(ISNULL(IbanRemittanceVol_Transactions	,0)	  + ISNULL(IbanRemittanceVol_MerchandiserTransactions	 ,0)			AS DECIMAL(20,1))										IbanRemittanceVol
		 ,CAST(ISNULL(ExternalTopUpCardDepositTxVol				,0)	  																	AS DECIMAL(20,1))										ExternalTopUpCardDepositTxVol
		 ,CAST(ISNULL(PostPaidCashDepositTxVol		,0)	  																	AS DECIMAL(20,1))										PostPaidCashDepositTxVol
		 ,CAST(ISNULL(InvoicePaymentTxVol				,0)	  																	AS DECIMAL(20,1))										InvoicePaymentTxVol
		 ,CAST(ISNULL(CityRingTravelCardTxVol				,0)	  																	AS DECIMAL(20,1))										CityRingTravelCardTxVol
		 ,CAST(ISNULL(LotteryPaymentTxVol_Transactions		,0)	  + ISNULL(LotteryPaymentTxVol_MerchandiserTransactions	 ,0)			AS DECIMAL(20,1))										LotteryPaymentTxVol			--Rakamlar tutuyor fakat Admin hesaplamasi dogru olmayabilir
		 ,CAST(ISNULL(GamePaymentTxVol_Transactions		,0)	  + ISNULL(GamePaymentTxVol_MerchandiserTransactions		 ,0)			AS DECIMAL(20,1))										GamePaymentTxVol
		 ,CAST(ISNULL(DonateToCharitiesTxVol					,0)	  																	AS DECIMAL(20,1))										DonateToCharitiesTxVol
		 ,CAST((ISNULL(DatabaseCardTxVol_Transactions		,0)	  + ISNULL(PCTxV_MerchandiserDatabaseCardTransaction_MerchandiserTransactions ,0) 
															  - ISNULL(PCTxV_sumVirtualCardFee_Transactions					  ,0)
															  - ISNULL(PCTxV_sumMerchandiserVirtualCardFee_MerchandiserTransactions	  ,0)
															  - ISNULL(PCTxV_balanceInquiry_MerchandiserTransactions			      ,0)
															  - ISNULL(PCTxV_corporateCardBalanceSum_MerchandiserTransactions	      ,0)
															  - ISNULL(PCTxV_cardFee_MerchandiserTransactions					      ,0))  AS DECIMAL(20,1))										DatabaseCardTxVol				--%100 KARSILAMAMASI NORMALDIR		
		,CAST(ISNULL( DatabaseCardCashbackTxVol		,0)																		AS DECIMAL(20,1))										DatabaseCardCashbackTxVol
		,CAST((ISNULL(ManuelNegativeTransactionsCnt_Transactions  ,0)	  + ISNULL(ManuelNegativeTransactionsCnt_MerchandiserTransactions  ,0))			AS DECIMAL(20,1))										ManuelNegativeTransactionsCnt
		,CAST((ISNULL(ManuelNegativeTransactionsVol_Transactions ,0)	  + ISNULL(ManuelNegativeTransactionsVol_MerchandiserTransactions ,0))			AS DECIMAL(20,1))										ManuelNegativeTransactionsVol
		,CAST((ISNULL(ManuelPositiveTransactionsCnt_Transactions  ,0)	  + ISNULL(ManuelPositiveTransactionsCnt_MerchandiserTransactions  ,0))			AS DECIMAL(20,1))										ManuelPositiveTransactionsCnt
		,CAST((ISNULL(ManuelPositiveTransactionsVol_Transactions ,0)	  + ISNULL(ManuelPositiveTransactionsVol_MerchandiserTransactions ,0))			AS DECIMAL(20,1))										ManuelPositiveTransactionsVol
		,CAST((ISNULL(MerchandiserFee_MerchandiserFeeVol_MerchandiserTransactions  ,0)   + ISNULL(PCTxV_sumMerchandiserVirtualCardFee_MerchandiserTransactions  ,0)
																		  + ISNULL(corporateDatabaseCardApplicationVol_MerchandiserFeeVol_MerchandiserTransactions  ,0)) AS DECIMAL(20,1))		MerchandiserFeeVol
																  																							
		,CAST( ISNULL(MerchandiserGuestPaymentVol		,0)		AS DECIMAL(20,1))																										MerchandiserGuestPaymentVol
		,CAST((ISNULL(FxTxVol_Transactions					,0)   + ISNULL(FxTxVol_MerchandiserTransactions ,0)) AS DECIMAL(20,1))																	FxTxVol
		,CAST( ISNULL(PfPosPaymentVol				,0)		AS DECIMAL(20,1))																										PfPosPaymentVol
		,CAST( ISNULL(MembershipPaymentTxVol			,0)		AS DECIMAL(20,1))																										MembershipPaymentTxVol
		,CAST( ISNULL(InvestmentFundingTxVol			,0)		AS DECIMAL(20,1))																										InvestmentFundingTxVol
		
		INTO #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource
		FROM
		
			(
				SELECT
					    CAST(CreatedAt AS DATE) [Date]
					   ,Currency
					   ,SUM(	CASE WHEN FeatureType =  1 THEN TxAmount	ELSE NULL END)								BankTransferTxVol
					   ,SUM(	CASE WHEN FeatureType = 21 THEN TxAmount	ELSE NULL END)								IbanRemittanceVol_Transactions
					   ,SUM(	CASE WHEN FeatureType =  3 THEN TxAmount	ELSE NULL END)								ExternalTopUpCardDepositTxVol
					   ,SUM(	CASE WHEN FeatureType = 14 THEN TxAmount	ELSE NULL END)								InvoicePaymentTxVol
					   ,SUM(	CASE WHEN FeatureType = 18 THEN TxAmount	ELSE NULL END)								CityRingTravelCardTxVol
					   ,SUM(	CASE WHEN FeatureType = 27 THEN TxAmount	ELSE NULL END)								LotteryPaymentTxVol_Transactions
					   ,SUM(	CASE WHEN FeatureType = 17 THEN TxAmount	ELSE NULL END)								GamePaymentTxVol_Transactions
					   ,SUM(	CASE WHEN FeatureType = 22 THEN TxAmount	ELSE NULL END)								DonateToCharitiesTxVol
					   ,SUM(	CASE WHEN FeatureType =  2							 THEN TxAmount	ELSE NULL END)	DatabaseCardTxVol_Transactions		/*DatabaseCardTxVol Grubu*/
					   ,SUM(	CASE WHEN FeatureType =  2	AND DatabaseCardTxType = 6 THEN TxAmount	ELSE NULL END)	PCTxV_sumVirtualCardFee_Transactions	/*DatabaseCardTxVol Grubu*/
					   ,SUM(	CASE WHEN FeatureType = 15							 THEN TxAmount    ELSE NULL END)	DatabaseCardCashbackTxVol
					   ,Cnt(	CASE WHEN FeatureType = 0		AND SIGN(TxAmount) = -1	 THEN Id	    ELSE NULL END)	ManuelNegativeTransactionsCnt_Transactions
					   ,SUM(	CASE WHEN FeatureType = 0		AND SIGN(TxAmount) = -1	 THEN TxAmount	ELSE NULL END)	ManuelNegativeTransactionsVol_Transactions
					   ,Cnt(	CASE WHEN FeatureType = 0		AND SIGN(TxAmount) =  1	 THEN Id		ELSE NULL END)	ManuelPositiveTransactionsCnt_Transactions
					   ,SUM(	CASE WHEN FeatureType = 0		AND SIGN(TxAmount) =  1	 THEN TxAmount	ELSE NULL END)	ManuelPositiveTransactionsVol_Transactions	
					   ,SUM(	CASE WHEN FeatureType = 13							 THEN TxAmount ELSE NULL END)		FxTxVol_Transactions
					   ,SUM(	CASE WHEN FeatureType = 31							 THEN TxAmount ELSE NULL END)		MembershipPaymentTxVol
					   ,SUM(	CASE WHEN FeatureType = 28							 THEN TxAmount ELSE NULL END)		InvestmentFundingTxVol
				FROM FACT_Transactions (nolock)
				WHERE (CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay) AND FeatureType IN (0,1,2,3,13,14,15,17,18,21,22,27,28,31)
				GROUP BY CAST(CreatedAt AS DATE), Currency
			) k
		   FULL OUTER JOIN
			(
				SELECT
						CAST(CreatedAt AS DATE) [Date]
					   ,Currency
					   ,	SUM(	CASE WHEN FeatureType =  1									THEN TxAmount		ELSE NULL END)	 MerchandiserBankTransferTxVol
					   ,	SUM(	CASE WHEN FeatureType = 21									THEN TxAmount		ELSE NULL END)	 IbanRemittanceVol_MerchandiserTransactions
					   ,ABS(SUM(	CASE WHEN FeatureType =  6	AND Postpaid = 1				THEN TxAmount		ELSE NULL END))	 PostPaidCashDepositTxVol
					   ,    SUM(	CASE WHEN FeatureType = 27									THEN TxAmount		ELSE NULL END)	 LotteryPaymentTxVol_MerchandiserTransactions
					   ,	SUM(	CASE WHEN FeatureType = 17									THEN TxAmount		ELSE NULL END)	 GamePaymentTxVol_MerchandiserTransactions
					   ,	SUM(	CASE WHEN FeatureType =  2	 								THEN TxAmount		ELSE NULL END)	 PCTxV_MerchandiserDatabaseCardTransaction_MerchandiserTransactions	 /*DatabaseCardTxVol Grubu*/
					   ,	SUM(	CASE WHEN FeatureType =  2	AND DatabaseCardTxType = 6		THEN TxAmount		ELSE NULL END)	 PCTxV_sumMerchandiserVirtualCardFee_MerchandiserTransactions		 /*DatabaseCardTxVol Grubu*//*MerchandiserFeeVol Grubu*/
					   ,	SUM(	CASE WHEN FeatureType =  2	AND DatabaseCardTxType = 2		THEN TxAmount		ELSE NULL END)	 PCTxV_balanceInquiry_MerchandiserTransactions				 /*DatabaseCardTxVol Grubu*/
					   ,	SUM(	CASE WHEN FeatureType =  2	AND DatabaseCardTxType = 9		THEN TxAmount		ELSE NULL END)	 PCTxV_corporateCardBalanceSum_MerchandiserTransactions		 /*DatabaseCardTxVol Grubu*/
					   ,	SUM(	CASE WHEN FeatureType =  2	AND DatabaseCardTxType = 3		THEN TxAmount		ELSE NULL END)	 PCTxV_cardFee_MerchandiserTransactions						 /*DatabaseCardTxVol Grubu*/
					   ,	Cnt(	CASE WHEN FeatureType =  0	AND SIGN(TxAmount) = -1			THEN Id			ELSE NULL END)	 ManuelNegativeTransactionsCnt_MerchandiserTransactions
					   ,	SUM(	CASE WHEN FeatureType =  0	AND SIGN(TxAmount) = -1			THEN TxAmount		ELSE NULL END)	 ManuelNegativeTransactionsVol_MerchandiserTransactions
					   ,	Cnt(	CASE WHEN FeatureType =  0	AND SIGN(TxAmount) =  1			THEN Id			ELSE NULL END)	 ManuelPositiveTransactionsCnt_MerchandiserTransactions
					   ,	SUM(	CASE WHEN FeatureType =  0	AND SIGN(TxAmount) =  1			THEN TxAmount		ELSE NULL END)	 ManuelPositiveTransactionsVol_MerchandiserTransactions	
					   ,	SUM(Fee)																							 MerchandiserFee_MerchandiserFeeVol_MerchandiserTransactions							/*MerchandiserFeeVol Grubu*/	
					   ,	SUM(	CASE WHEN FeatureType = 29									THEN TxAmount		ELSE NULL END)	 corporateDatabaseCardApplicationVol_MerchandiserFeeVol_MerchandiserTransactions	/*MerchandiserFeeVol Grubu*/			   
					   ,	SUM(	CASE WHEN FeatureType = 26									THEN TxAmount		ELSE NULL END)	 MerchandiserGuestPaymentVol
					   ,	SUM(	CASE WHEN FeatureType = 13									THEN TxAmount		ELSE NULL END)	 FxTxVol_MerchandiserTransactions
					   ,	SUM(	CASE WHEN FeatureType = 30									THEN TxAmount		ELSE NULL END)	 PfPosPaymentVol
				FROM FACT_MerchandiserTransactions (nolock)
				WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
				GROUP BY CAST(CreatedAt AS DATE), Currency
			) l on k.[Date] = l.[Date] AND k.Currency = l.Currency
/*END - #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource*/
PRINT '15 - Completed - #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource'  + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource*/
SELECT CAST(CreatedAt AS DATE) [Date]
		   ,Currency
		   ,CAST(ISNULL(MerchandiserBankTransferTxVol	,0) AS DECIMAL(20,1))	MerchandiserBankTransferTxVol
		   ,CAST(ISNULL(BankTransferTxVol			,0) AS DECIMAL(20,1))	BankTransferTxVol		
		   ,CAST(ISNULL(IbanRemittanceVol			,0) AS DECIMAL(20,1))	IbanRemittanceVol		
		   ,CAST(ISNULL(ExternalTopUpCardDepositTxVol				,0) AS DECIMAL(20,1))	ExternalTopUpCardDepositTxVol			
		   ,CAST(ISNULL(PostPaidCashDepositTxVol		,0) AS DECIMAL(20,1))	PostPaidCashDepositTxVol	
		   ,CAST(ISNULL(InvoicePaymentTxVol				,0) AS DECIMAL(20,1))	InvoicePaymentTxVol			
		   ,CAST(ISNULL(CityRingTravelCardTxVol			,0) AS DECIMAL(20,1))	CityRingTravelCardTxVol		
		   ,CAST(ISNULL(LotteryPaymentTxVol			,0) AS DECIMAL(20,1))	LotteryPaymentTxVol		
		   ,CAST(ISNULL(GamePaymentTxVol				,0) AS DECIMAL(20,1))	GamePaymentTxVol			
		   ,CAST(ISNULL(DonateToCharitiesTxVol				,0) AS DECIMAL(20,1))	DonateToCharitiesTxVol			
		   ,CAST(ISNULL(DatabaseCardTxVol				,0) AS DECIMAL(20,1))	DatabaseCardTxVol			
		   ,CAST(ISNULL(DatabaseCardCashbackTxVol		,0) AS DECIMAL(20,1))	DatabaseCardCashbackTxVol	
		   ,CAST(ISNULL(ManuelNegativeTransactionsCnt		,0) AS DECIMAL(20,1))	ManuelNegativeTransactionsCnt	
		   ,CAST(ISNULL(ManuelNegativeTransactionsVol		,0) AS DECIMAL(20,1))	ManuelNegativeTransactionsVol	
		   ,CAST(ISNULL(ManuelPositiveTransactionsCnt		,0) AS DECIMAL(20,1))	ManuelPositiveTransactionsCnt	
		   ,CAST(ISNULL(ManuelPositiveTransactionsVol		,0) AS DECIMAL(20,1))	ManuelPositiveTransactionsVol	
		   ,CAST(ISNULL(MerchandiserFeeVol				,0) AS DECIMAL(20,1))	MerchandiserFeeVol			
		   ,CAST(ISNULL(MerchandiserGuestPaymentVol		,0) AS DECIMAL(20,1))	MerchandiserGuestPaymentVol	
		   ,CAST(ISNULL(FxTxVol						,0) AS DECIMAL(20,1))	FxTxVol					
		   ,CAST(ISNULL(PfPosPaymentVol				,0) AS DECIMAL(20,1))	PfPosPaymentVol			
		   ,CAST(ISNULL(MembershipPaymentTxVol		,0) AS DECIMAL(20,1))	MembershipPaymentTxVol
		   ,CAST(ISNULL(InvestmentFundingTxVol		,0) AS DECIMAL(20,1)) 	InvestmentFundingTxVol
INTO #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource 
FROM FACT_DailyFinancialCSEntityDataSource (nolock)
WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay  
/*END - #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource*/
PRINT '16 - Completed - #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_A*/	
		SELECT
				 CAST(CreatedAt AS DATE) [Date]
				,CAST(ISNULL(Cnt(*) ,0) AS DECIMAL(20,1)) AddedCardCnt
		INTO #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_A
		FROM DIM_ExternalTopUpCards (nolock) 
		WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
		GROUP BY CAST(CreatedAt AS DATE)
/*END - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_A*/
PRINT '17 - Completed - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_A' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B*/	
	SELECT
			 CAST(CreatedAt AS DATE) [Date]
			,CAST(ISNULL(Cnt(CASE WHEN		SigninMethod  = 0 THEN User_Key ELSE NULL END) ,0) AS DECIMAL(20,1)) FormRegisteredUserCnt
			,CAST(ISNULL(Cnt(CASE WHEN		SigninMethod  = 1 THEN User_Key ELSE NULL END) ,0) AS DECIMAL(20,1)) FacebookRegisteredUserCnt
			,CAST(ISNULL(Cnt(CASE WHEN		SigninMethod =  2 THEN User_Key ELSE NULL END) ,0) AS DECIMAL(20,1)) GoogleRegisteredUserCnt
			,CAST(ISNULL(Cnt(CASE WHEN		SigninType = 0 THEN User_Key ELSE NULL END) ,0) AS DECIMAL(20,1)) BrowserRegisteredUserCnt
			,CAST(ISNULL(Cnt(CASE WHEN		SigninType = 1 THEN User_Key ELSE NULL END) ,0) AS DECIMAL(20,1)) IosRegisteredUserCnt
			,CAST(ISNULL(Cnt(CASE WHEN		SigninType = 2 THEN User_Key ELSE NULL END) ,0) AS DECIMAL(20,1)) AndroidRegisteredUserCnt
			,CAST(ISNULL(Cnt(CASE WHEN PhoneNoConfirmed = 0 THEN User_Key ELSE NULL END) ,0) AS DECIMAL(20,1)) PhoneNoNotConfirmedUserCnt
	INTO #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B
	FROM	  DIM_UserAttributes (nolock) u

	WHERE	 CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
	GROUP BY CAST(CreatedAt AS DATE)

/*END - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B*/
PRINT '18 - Completed - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_C*/	
	SELECT
			 CAST(u.CreatedAt AS DATE) [Date]
			,CAST(ISNULL(Cnt(*) ,0) AS DECIMAL(20,1)) CompletedInviteByRemittanceCnt
	INTO #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_C
	FROM	  DIM_UserAttributes (nolock) U
	JOIN	  (select User_Key, ReceiversPhoneNo from FACT_InviteByRemittances (nolock) where [Status]=1) imt on imt.ReceiversPhoneNo = U.PhoneNo
	WHERE	  u.CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND u.CreatedAt < @BaseDay
	GROUP BY CAST(u.CreatedAt AS DATE)

/*END - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_C*/
PRINT '19 - Completed - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_C' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_D*/	
	SELECT --Sadece önceki gün verisinin tutarli rakam vermesi anormal degildir
			 CAST(CreatedAt AS DATE) [Date]
			,CAST(ISNULL(ABS(SUM(CASE WHEN	BankTransferType  = 1 AND [Status] in (0,1) THEN TxAmount+Fee ELSE NULL END)) ,0) AS DECIMAL(20,1)) MerchandiserPendingWithdrawalBalance

	INTO #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_D
	FROM	  FACT_MerchandiserBankTransferRequests (nolock)
	WHERE	  CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
	GROUP BY CAST(CreatedAt AS DATE)
/*END - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_D*/  
PRINT '20 - Completed - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_D' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_E*/	
	SELECT 
			 CAST(CreatedAt AS DATE) [Date]
			,CAST(ISNULL(Cnt(CASE WHEN [Type] in (4,5) THEN Id ELSE NULL END) ,0) AS DECIMAL(20,1)) DatabaseCardApplicationCnt
	INTO #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_E
	FROM	  DIM_DatabaseCards (nolock)
	WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
	GROUP BY CAST(CreatedAt AS DATE)
/*END - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_E*/	
PRINT '21 - Completed - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_E' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_F*/		
SELECT --Sayilarin farkli gelmesi normaldir.
         k.[Date]
        ,CAST(ISNULL( TotalFee_Transactions + TotalFee_MerchandiserTransactions
        /*Card Related Fees logged in TxAmount */
         + TotalFee_L_BalanceInquiry
         + TotalFee_L_CardFee
         + TotalFee_L_VirtualCardFee
         + TotalFee_L_DatabasePurchase
         + TotalFee_ML_VirtualCardFee
         + TotalFee_ML_DatabaseCardApplicationFee, 0) AS DECIMAL(20,1)) 'TotalFee'
        ,CAST(ISNULL(TotalFeeUsd_Transactions            +        TotalFeeUsd_MerchandiserTransactions ,0) AS DECIMAL(20,1)) TotalFeeUsd    
        ,CAST(ISNULL(TotalFeeEur_Transactions            +        TotalFeeEur_MerchandiserTransactions ,0) AS DECIMAL(20,1)) TotalFeeEur    
        ,CAST(ISNULL(TotalFeeGbp_Transactions            +        TotalFeeGbp_MerchandiserTransactions ,0) AS DECIMAL(20,1)) TotalFeeGbp
		,CAST(ISNULL(TotalFeeXau_Transactions            +        TotalFeeXau_MerchandiserTransactions ,0) AS DECIMAL(20,1)) TotalFeeXau
        INTO #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_F
        FROM DIM_Date (nolock) d
        JOIN
            (
                SELECT
                        CAST(CreatedAt AS DATE) [Date]
                        /*Transactions Fees-TRY-BEGIN*/
                       ,ISNULL(ABS(SUM(CASE WHEN Currency = 0                           THEN Fee         ELSE NULL END)),0)   TotalFee_Transactions
                       ,ISNULL(ABS(SUM(CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 2 THEN TxAmount_Fee  ELSE NULL END)),0)   TotalFee_L_BalanceInquiry
                       ,ISNULL(ABS(SUM(CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 3 THEN TxAmount_Fee  ELSE NULL END)),0)   TotalFee_L_CardFee
                       ,ISNULL(ABS(SUM(CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 6 THEN TxAmount_Fee  ELSE NULL END)),0)   TotalFee_L_VirtualCardFee
                       ,ISNULL(ABS(SUM(CASE WHEN FeatureType = 29                         THEN TxAmount_Fee  ELSE NULL END)),0)   TotalFee_L_DatabasePurchase
                        /*Transactions Fees-TRY-END*/
                       ,ISNULL(SUM(CASE WHEN Currency  = 1  THEN Fee ELSE NULL END),0) TotalFeeUsd_Transactions
                       ,ISNULL(SUM(CASE WHEN Currency  = 2  THEN Fee ELSE NULL END),0) TotalFeeEur_Transactions
                       ,ISNULL(SUM(CASE WHEN Currency  = 4  THEN Fee ELSE NULL END),0) TotalFeeGbp_Transactions
					   ,ISNULL(SUM(CASE WHEN Currency  = 27 THEN Fee ELSE NULL END),0) TotalFeeXau_Transactions
                FROM FACT_Transactions (nolock)
                WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
                GROUP BY CAST(CreatedAt AS DATE)
            ) k  ON D.CreateDate = k.[Date]
            JOIN
            (
                SELECT
                        CAST(CreatedAt AS DATE) [Date]
                        /*MerchandiserTransactions Fees-TRY-BEGIN*/
                       ,ISNULL(ABS(SUM(CASE WHEN Currency  = 0                           THEN Fee        ELSE NULL END)),0)         TotalFee_MerchandiserTransactions
                       ,ISNULL(ABS(SUM(CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 6  THEN TxAmount_Fee ELSE NULL END)*(-1.0)),0)  TotalFee_ML_VirtualCardFee
                       ,ISNULL(ABS(SUM(CASE WHEN FeatureType = 29                          THEN TxAmount_Fee ELSE NULL END)),0)         TotalFee_ML_DatabaseCardApplicationFee
                        /*Transactions Fees-TRY-END*/
                       ,ISNULL(SUM(CASE WHEN Currency  = 1  THEN Fee ELSE NULL END),0) TotalFeeUsd_MerchandiserTransactions
                       ,ISNULL(SUM(CASE WHEN Currency  = 2  THEN Fee ELSE NULL END),0) TotalFeeEur_MerchandiserTransactions
                       ,ISNULL(SUM(CASE WHEN Currency  = 4  THEN Fee ELSE NULL END),0) TotalFeeGbp_MerchandiserTransactions
					   ,ISNULL(SUM(CASE WHEN Currency  = 27 THEN Fee ELSE NULL END),0) TotalFeeXau_MerchandiserTransactions
                FROM FACT_MerchandiserTransactions (nolock)
                WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
                GROUP BY CAST(CreatedAt AS DATE)
            ) l on D.CreateDate = L.[Date]
		--SELECT --Sayilarin farkli gelmesi normaldir.
		-- k.[Date]

		--,CAST(ISNULL( TotalFee_Transactions + TotalFee_MerchandiserTransactions
		--/*Card Related Fees logged in TxAmount */
		-- + TotalFee_L_BalanceInquiry
		-- + TotalFee_L_CardFee
		-- + TotalFee_L_VirtualCardFee
		-- + TotalFee_L_DatabasePurchase
		-- + TotalFee_ML_VirtualCardFee
		-- + TotalFee_ML_DatabaseCardApplicationFee, 0) AS DECIMAL(20,1)) 'TotalFee'


		--,CAST(ISNULL(TotalFeeUsd_Transactions			+		TotalFeeUsd_MerchandiserTransactions ,0) AS DECIMAL(20,1)) TotalFeeUsd	
		--,CAST(ISNULL(TotalFeeEur_Transactions			+		TotalFeeEur_MerchandiserTransactions ,0) AS DECIMAL(20,1)) TotalFeeEur	
		--,CAST(ISNULL(TotalFeeGbp_Transactions			+		TotalFeeGbp_MerchandiserTransactions ,0) AS DECIMAL(20,1)) TotalFeeGbp	
		--INTO #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_F
		--FROM
		
		--	(
		--		SELECT
		--			    CAST(CreatedAt AS DATE) [Date]
		--				/*Transactions Fees-TRY-BEGIN*/
		--			   ,ISNULL(ABS(SUM(CASE WHEN Currency = 0							THEN Fee		ELSE NULL END)),0)   TotalFee_Transactions
		--			   ,ISNULL(ABS(SUM(CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 2 THEN TxAmount_Fee	ELSE NULL END)),0)   TotalFee_L_BalanceInquiry
		--			   ,ISNULL(ABS(SUM(CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 3 THEN TxAmount_Fee	ELSE NULL END)),0)   TotalFee_L_CardFee
		--			   ,ISNULL(ABS(SUM(CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 6 THEN TxAmount_Fee	ELSE NULL END)),0)   TotalFee_L_VirtualCardFee
		--			   ,ISNULL(ABS(SUM(CASE WHEN FeatureType = 29							 THEN TxAmount_Fee ELSE NULL END)),0)	 TotalFee_L_DatabasePurchase

		--			    /*Transactions Fees-TRY-END*/
		--			   ,ISNULL(SUM(CASE WHEN Currency  = 1 THEN Fee ELSE NULL END),0) TotalFeeUsd_Transactions
		--			   ,ISNULL(SUM(CASE WHEN Currency  = 2 THEN Fee ELSE NULL END),0) TotalFeeEur_Transactions
		--			   ,ISNULL(SUM(CASE WHEN Currency  = 4 THEN Fee ELSE NULL END),0) TotalFeeGbp_Transactions					
		--		FROM FACT_Transactions (nolock)
		--		WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
		--		GROUP BY CAST(CreatedAt AS DATE)
		--	) k
		--    JOIN
		--	(
		--		SELECT
		--				CAST(CreatedAt AS DATE) [Date]
		--				/*MerchandiserTransactions Fees-TRY-BEGIN*/
		--			   ,ISNULL(ABS(SUM(CASE WHEN Currency = 0							 THEN Fee		 ELSE NULL END)),0)			TotalFee_MerchandiserTransactions
		--			   ,ISNULL(ABS(SUM(CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 6  THEN TxAmount_Fee ELSE NULL END)*(-1.0)),0)  TotalFee_ML_VirtualCardFee
		--			   ,ISNULL(ABS(SUM(CASE WHEN FeatureType = 29							 THEN TxAmount_Fee ELSE NULL END)),0)			TotalFee_ML_DatabaseCardApplicationFee
		--			    /*Transactions Fees-TRY-END*/

		--			   ,ISNULL(SUM(CASE WHEN Currency  = 1 THEN Fee ELSE NULL END),0)  TotalFeeUsd_MerchandiserTransactions
		--			   ,ISNULL(SUM(CASE WHEN Currency  = 2 THEN Fee ELSE NULL END),0)  TotalFeeEur_MerchandiserTransactions
		--			   ,ISNULL(SUM(CASE WHEN Currency  = 4 THEN Fee ELSE NULL END),0)  TotalFeeGbp_MerchandiserTransactions	
		--		FROM FACT_MerchandiserTransactions (nolock)
		--		WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
		--		GROUP BY CAST(CreatedAt AS DATE)
		--	) l on k.[Date] = l.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_F*/		
PRINT '22 - Completed - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_F' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_G*/	
SELECT * 
INTO #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_G
FROM
	(
		SELECT
				 CAST(CreatedAt AS DATE) [Date]
				,CAST(ISNULL(SUM(Cnt(User_Key)) OVER (ORDER BY CAST(CreatedAt AS DATE)) ,0) AS DECIMAL(20,1)) TotalUserCnt

		FROM	  DIM_UserAttributes (nolock) u
		WHERE	  CreatedAt <= @BaseDay
		GROUP BY CAST(CreatedAt AS DATE)
	
	) k
WHERE [Date] >= DATEADD(DAY,-@d,@BaseDay) AND [Date] < @BaseDay 
/*END - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_G*/
PRINT '23 - Completed - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_G' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #CSHARP_TO_PROD_VIEW_FACT_CSEntityDataSource*/	
SELECT CAST(CreatedAt AS DATE) [Date]
		   ,CAST(ISNULL(AddedCardCnt						 ,0) AS DECIMAL(20,1))	AddedCardCnt						
		   ,CAST(ISNULL(FormRegisteredUserCnt				 ,0) AS DECIMAL(20,1))	FormRegisteredUserCnt				
		   ,CAST(ISNULL(FacebookRegisteredUserCnt			 ,0) AS DECIMAL(20,1))	FacebookRegisteredUserCnt			
		   ,CAST(ISNULL(GoogleRegisteredUserCnt			 ,0) AS DECIMAL(20,1))	GoogleRegisteredUserCnt			
		   ,CAST(ISNULL(BrowserRegisteredUserCnt				 ,0) AS DECIMAL(20,1))	BrowserRegisteredUserCnt				
		   ,CAST(ISNULL(IosRegisteredUserCnt				 ,0) AS DECIMAL(20,1))	IosRegisteredUserCnt				
		   ,CAST(ISNULL(AndroidRegisteredUserCnt			 ,0) AS DECIMAL(20,1))	AndroidRegisteredUserCnt			
		   ,CAST(ISNULL(PhoneNoNotConfirmedUserCnt	 ,0) AS DECIMAL(20,1))	PhoneNoNotConfirmedUserCnt	   
		   ,CAST(ISNULL(CompletedInviteByRemittanceCnt	 ,0) AS DECIMAL(20,1))	CompletedInviteByRemittanceCnt	   
		   ,CAST(ISNULL(MerchandiserPendingWithdrawalBalance	 ,0) AS DECIMAL(20,1))	MerchandiserPendingWithdrawalBalance	   
		   ,CAST(ISNULL(DatabaseCardApplicationCnt		   	 ,0) AS DECIMAL(20,1))	DatabaseCardApplicationCnt		   	   
		   ,CAST(ISNULL(TotalFee							 ,0) AS DECIMAL(20,1))	TotalFee							
		   ,CAST(ISNULL(TotalFeeUsd							 ,0) AS DECIMAL(20,1))	TotalFeeUsd							
		   ,CAST(ISNULL(TotalFeeEuro						 ,0) AS DECIMAL(20,1))	TotalFeeEuro						
		   ,CAST(ISNULL(TotalFeeGbp							 ,0) AS DECIMAL(20,1))	TotalFeeGbp
		   ,CAST(ISNULL(TotalFeeXau							 ,0) AS DECIMAL(20,1))	TotalFeeXau
		   ,CAST(ISNULL(TotalUserCnt						 ,0) AS DECIMAL(20,1))	TotalUserCnt						
INTO #CSHARP_TO_PROD_VIEW_FACT_CSEntityDataSource	   
FROM FACT_CSEntityDataSource (nolock)
WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
/*END - #CSHARP_TO_PROD_VIEW_FACT_CSEntityDataSource*/
PRINT '24 - Completed - #CSHARP_TO_PROD_VIEW_FACT_CSEntityDataSource'					    + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource*/
		SELECT
		  k.[Date]
		 ,k.Currency
		 ,CAST(ISNULL(ExternalTopUpCardDepositCnt								,0)											AS DECIMAL(20,1))	ExternalTopUpCardDepositCnt
		 ,CAST(ISNULL(ExternalTopUpCardDepositVol								,0)											AS DECIMAL(20,1))	ExternalTopUpCardDepositVol
		 ,CAST(ISNULL(MerchandiserDepositCnt							,0)											AS DECIMAL(20,1))	MerchandiserDepositCnt
		 ,CAST(ISNULL(MerchandiserDepositVol							,0)											AS DECIMAL(20,1))	MerchandiserDepositVol
		 ,CAST(ISNULL(MerchandiserDepositFeeVol						,0)											AS DECIMAL(20,1))	MerchandiserDepositFeeVol
		 ,CAST(ISNULL(MerchandiserWithdrawalCnt						,0)											AS DECIMAL(20,1))	MerchandiserWithdrawalCnt
		 ,CAST(ISNULL(MerchandiserWithdrawalVol						,0)											AS DECIMAL(20,1))	MerchandiserWithdrawalVol
		 ,CAST(ISNULL(PostPaidCashDepositCnt						,0)											AS DECIMAL(20,1))	PostPaidCashDepositCnt
		 ,CAST(ISNULL(PostPaidCashDepositVol						,0)											AS DECIMAL(20,1))	PostPaidCashDepositVol
		 ,CAST(ISNULL(PrePaidCashDepositCnt						,0)											AS DECIMAL(20,1))	PrePaidCashDepositCnt
		 ,CAST(ISNULL(PrePaidCashDepositVol						,0)											AS DECIMAL(20,1))	PrePaidCashDepositVol
		 ,CAST(ISNULL(PttDepositCnt								,0)											AS DECIMAL(20,1))	PttDepositCnt	
		 ,CAST(ISNULL(PttDepositVol								,0)											AS DECIMAL(20,1))	PttDepositVol	
		 ,CAST(ISNULL(TeknosaDepositCnt							,0)											AS DECIMAL(20,1))	TeknosaDepositCnt
		 ,CAST(ISNULL(TeknosaDepositVol							,0)											AS DECIMAL(20,1))	TeknosaDepositVol
		 ,CAST(ISNULL(UserBankTransferDepositCnt					,0)	+ ISNULL(PostPaidCashDepositCnt   ,0) 					
												 						+ ISNULL(PrePaidCashDepositCnt    ,0) AS DECIMAL(20,1))	TotalUserDepositsCnt	 
		 ,CAST(ISNULL(UserBankTransferDepositVol					,0)	+ ISNULL(PostPaidCashDepositVol  ,0) 					
		 										 						+ ISNULL(PrePaidCashDepositVol   ,0) AS DECIMAL(20,1))	TotalUserDepositsVol
		 ,CAST(ISNULL(UserBankAtmDepositCnt					   ,0)											AS DECIMAL(20,1))	UserBankAtmDepositCnt
		 ,CAST(ISNULL(UserBankAtmDepositVol					   ,0)											AS DECIMAL(20,1))	UserBankAtmDepositVol
		 ,CAST(ISNULL(UserBankFastDepositCnt					   ,0)											AS DECIMAL(20,1))	UserBankFastDepositCnt			
		 ,CAST(ISNULL(UserBankFastDepositVol					   ,0)											AS DECIMAL(20,1))	UserBankFastDepositVol		
		 ,CAST(ISNULL(UserBankTransferDepositCnt				   ,0)											AS DECIMAL(20,1))	UserBankTransferDepositCnt
		 ,CAST(ISNULL(UserBankTransferDepositVol				   ,0)											AS DECIMAL(20,1))	UserBankTransferDepositVol
		 ,CAST(ISNULL(UserBankWithdrawalCnt					   ,0)											AS DECIMAL(20,1))	UserBankWithdrawalCnt
		 ,CAST(ISNULL(UserBankWithdrawalVol					   ,0)											AS DECIMAL(20,1))	UserBankWithdrawalVol
		 ,CAST(ISNULL(UserManuelProcessedBankTransferDepositCnt  ,0)											AS DECIMAL(20,1))	UserManuelProcessedBankTransferDepositCnt
		 ,CAST(ISNULL(IbanRemittanceCnt					   ,0)											AS DECIMAL(20,1))	IbanRemittanceCnt		
		 ,CAST(ISNULL(IbanRemittanceVol					   ,0)											AS DECIMAL(20,1))	IbanRemittanceVol
		 ,CAST(ISNULL(OnlyExternalTopUpCardDepositCnt						   ,0)											AS DECIMAL(20,1))	OnlyExternalTopUpCardDepositCnt
		 ,CAST(ISNULL(OnlyExternalTopUpCardDepositVol						   ,0)											AS DECIMAL(20,1))	OnlyExternalTopUpCardDepositVol
		 ,CAST(ISNULL(MerchandiserIbanRemittanceCnt			   ,0)											AS DECIMAL(20,1))	MerchandiserIbanRemittanceCnt  /*YENI*/
		 ,CAST(ISNULL(MerchandiserIbanRemittanceVol  			   ,0)											AS DECIMAL(20,1))   MerchandiserIbanRemittanceVol /*YENI*/ 
		 ,CAST(ISNULL(MerchandiserIbanRemittanceFee  			   ,0)											AS DECIMAL(20,1))   MerchandiserIbanRemittanceFee    /*YENI*/ 
		 
		INTO #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource
		FROM DIM_Date (nolock) d
		JOIN
			(
				SELECT
					    CAST(l.CreatedAt AS DATE) [Date]
					   ,l.Currency
					   ,Cnt(	CASE WHEN IsDepositForPayment = 1												THEN l.Id		ELSE NULL END)	ExternalTopUpCardDepositCnt
					   ,SUM  (	CASE WHEN IsDepositForPayment = 1												THEN l.TxAmount	ELSE NULL END)	ExternalTopUpCardDepositVol
					   ,Cnt(  CASE WHEN MerchandiserKey		  = 14												THEN l.Id	    ELSE NULL END)	PttDepositCnt
					   ,ABS(SUM(CASE WHEN MerchandiserKey		  = 14												THEN l.TxAmount	ELSE NULL END))	PttDepositVol
					   ,Cnt(	CASE WHEN MerchandiserKey		  = 186												THEN l.Id	    ELSE NULL END)	TeknosaDepositCnt
					   ,ABS(SUM(CASE WHEN MerchandiserKey		  = 186												THEN l.TxAmount	ELSE NULL END))	TeknosaDepositVol
					   ,Cnt(	CASE WHEN FeatureType = 1		AND btr.BankTransferType = 0						THEN l.Id		ELSE NULL END)	UserBankTransferDepositCnt
					   ,	SUM(CASE WHEN FeatureType = 1		AND btr.BankTransferType = 0						THEN l.TxAmount	ELSE NULL END)	UserBankTransferDepositVol
					   ,Cnt(	CASE WHEN FeatureType = 1		AND btr.BankTransferType = 0 AND	L.ViaAtm = 1	THEN l.Id		ELSE NULL END)	UserBankAtmDepositCnt
					   ,ABS(SUM(CASE WHEN FeatureType = 1		AND btr.BankTransferType = 0 AND	L.ViaAtm = 1	THEN l.TxAmount	ELSE NULL END))	UserBankAtmDepositVol
					   ,Cnt(	CASE WHEN FeatureType = 1		AND btr.BankTransferType = 0 AND btr.ViaFast = 1	THEN l.Id		ELSE NULL END)	UserBankFastDepositCnt
					   ,ABS(SUM(CASE WHEN FeatureType = 1		AND btr.BankTransferType = 0 AND btr.ViaFast = 1	THEN l.TxAmount	ELSE NULL END))	UserBankFastDepositVol
					   ,Cnt(	CASE WHEN FeatureType = 1		AND btr.BankTransferType = 1						THEN l.Id		ELSE NULL END)	UserBankWithdrawalCnt
					   ,	SUM(CASE WHEN FeatureType = 1		AND btr.BankTransferType = 1						THEN l.TxAmount	ELSE NULL END)	UserBankWithdrawalVol
					   ,Cnt(  CASE WHEN FeatureType = 1		AND btr.BankTransferType = 0 AND btr.[Status] = 2	THEN l.Id		ELSE NULL END)	UserManuelProcessedBankTransferDepositCnt
					   ,Cnt(	CASE WHEN FeatureType = 21														THEN l.Id		ELSE NULL END)  IbanRemittanceCnt
					   ,ABS(SUM(CASE WHEN FeatureType = 21														THEN l.TxAmount	ELSE NULL END))	IbanRemittanceVol
					   ,Cnt(	CASE WHEN IsDepositForPayment = 0												THEN l.Id		ELSE NULL END)	OnlyExternalTopUpCardDepositCnt
					   ,SUM  (	CASE WHEN IsDepositForPayment = 0												THEN l.TxAmount	ELSE NULL END)	OnlyExternalTopUpCardDepositVol														  
				FROM FACT_Transactions (nolock) L
				LEFT JOIN FACT_BankTransferRequests (nolock) btr on btr.Id = L.StartingRequestId
				WHERE l.CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND l.CreatedAt < @BaseDay
				GROUP BY CAST(l.CreatedAt AS DATE), l.Currency
			) k ON D.CreateDate = k.[Date]
		   FULL OUTER JOIN
			(
				SELECT
						CAST(ml.CreatedAt AS DATE) [Date]
					   ,ml.Currency
					   ,CAST(ISNULL(Cnt(	CASE WHEN mbtr.BankTransferType = 0			THEN ml.Id	   ELSE NULL END)	 ,0) AS DECIMAL(20,1))	MerchandiserDepositCnt
					   ,CAST(ISNULL(SUM(	CASE WHEN mbtr.BankTransferType = 0			THEN ml.TxAmount ELSE NULL END)	 ,0) AS DECIMAL(20,1))	MerchandiserDepositVol
					   ,CAST(ISNULL(ABS(SUM(CASE WHEN mbtr.BankTransferType = 0			THEN ml.Fee	   ELSE NULL END))	 ,0) AS DECIMAL(20,1))	MerchandiserDepositFeeVol
					   ,CAST(ISNULL(Cnt(	CASE WHEN mbtr.BankTransferType = 1			THEN ml.Id	   ELSE NULL END)	 ,0) AS DECIMAL(20,1))	MerchandiserWithdrawalCnt
					   ,CAST(ISNULL(SUM(	CASE WHEN mbtr.BankTransferType = 1			THEN ml.TxAmount ELSE NULL END)	 ,0) AS DECIMAL(20,1))	MerchandiserWithdrawalVol
					   ,CAST(ISNULL(Cnt(	CASE WHEN FeatureType	= 6	AND Postpaid = 1	THEN ml.Id	   ELSE NULL END)	 ,0) AS DECIMAL(20,1))	PostPaidCashDepositCnt
					   ,CAST(ISNULL(ABS(SUM(CASE WHEN FeatureType = 6	AND Postpaid = 1	THEN ml.TxAmount ELSE NULL END))	 ,0) AS DECIMAL(20,1))	PostPaidCashDepositVol
					   ,CAST(ISNULL(Cnt(	CASE WHEN FeatureType	= 6	AND Postpaid = 0	THEN ml.Id	   ELSE NULL END)	 ,0) AS DECIMAL(20,1))	PrePaidCashDepositCnt
					   ,CAST(ISNULL(ABS(SUM(CASE WHEN FeatureType = 6	AND Postpaid = 0	THEN ml.TxAmount ELSE NULL END))	 ,0) AS DECIMAL(20,1))	PrePaidCashDepositVol
					   ,CAST(ISNULL(Cnt(	CASE WHEN FeatureType = 21					THEN ml.Id	   ELSE NULL END)	 ,0) AS DECIMAL(20,1))	MerchandiserIbanRemittanceCnt /*yeni*/
					   ,CAST(ISNULL(ABS(SUM(CASE WHEN FeatureType = 21					THEN ml.TxAmount  ELSE NULL END))	 ,0) AS DECIMAL(20,1))	MerchandiserIbanRemittanceVol /*yeni*/
					   ,CAST(ISNULL(ABS(SUM(CASE WHEN FeatureType = 21					THEN ml.Fee	   ELSE NULL END))	 ,0) AS DECIMAL(20,1))	MerchandiserIbanRemittanceFee   /*yeni*/
				FROM FACT_MerchandiserTransactions (nolock) ml
				LEFT JOIN (select Id, BankTransferType, [Status], CreatedAt FROM FACT_MerchandiserBankTransferRequests (nolock) ) mbtr on mbtr.Id = ml.StartingRequestId
				WHERE ml.CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND ml.CreatedAt < @BaseDay
				GROUP BY CAST(ml.CreatedAt AS DATE), ml.Currency
			) l on D.CreateDate = L.[Date] AND k.Currency = l.Currency
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource*/	
PRINT '25 - Completed - #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource'  + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))
		
/*BEGIN - #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource*/
SELECT CAST(CreatedAt AS DATE) [Date]
		   ,Currency											
		   ,CAST(ISNULL(ExternalTopUpCardDepositCnt									 ,0) AS DECIMAL(20,1))	ExternalTopUpCardDepositCnt							
		   ,CAST(ISNULL(ExternalTopUpCardDepositVol									 ,0) AS DECIMAL(20,1))	ExternalTopUpCardDepositVol							
		   ,CAST(ISNULL(MerchandiserDepositCnt								 ,0) AS DECIMAL(20,1))	MerchandiserDepositCnt						
		   ,CAST(ISNULL(MerchandiserDepositVol								 ,0) AS DECIMAL(20,1))	MerchandiserDepositVol						
		   ,CAST(ISNULL(MerchandiserDepositFeeVol							 ,0) AS DECIMAL(20,1))	MerchandiserDepositFeeVol					
		   ,CAST(ISNULL(MerchandiserWithdrawalCnt								 ,0) AS DECIMAL(20,1))	MerchandiserWithdrawalCnt						
		   ,CAST(ISNULL(MerchandiserWithdrawalVol							 ,0) AS DECIMAL(20,1))	MerchandiserWithdrawalVol					
		   ,CAST(ISNULL(PostPaidCashDepositCnt							 ,0) AS DECIMAL(20,1))	PostPaidCashDepositCnt					
		   ,CAST(ISNULL(PostPaidCashDepositVol							 ,0) AS DECIMAL(20,1))	PostPaidCashDepositVol					
		   ,CAST(ISNULL(PrePaidCashDepositCnt								 ,0) AS DECIMAL(20,1))	PrePaidCashDepositCnt						
		   ,CAST(ISNULL(PrePaidCashDepositVol							 ,0) AS DECIMAL(20,1))	PrePaidCashDepositVol					
		   ,CAST(ISNULL(PttDepositCnt										 ,0) AS DECIMAL(20,1))	PttDepositCnt								
		   ,CAST(ISNULL(PttDepositVol									 ,0) AS DECIMAL(20,1))	PttDepositVol							
		   ,CAST(ISNULL(TeknosaDepositCnt									 ,0) AS DECIMAL(20,1))	TeknosaDepositCnt							
		   ,CAST(ISNULL(TeknosaDepositVol								 ,0) AS DECIMAL(20,1))	TeknosaDepositVol						
		   ,CAST(ISNULL(TotalUserDepositsCnt								 ,0) AS DECIMAL(20,1))	TotalUserDepositsCnt						
		   ,CAST(ISNULL(TotalUserDepositsVol								 ,0) AS DECIMAL(20,1))	TotalUserDepositsVol						
		   ,CAST(ISNULL(UserBankAtmDepositCnt								 ,0) AS DECIMAL(20,1))	UserBankAtmDepositCnt						
		   ,CAST(ISNULL(UserBankAtmDepositVol							 ,0) AS DECIMAL(20,1))	UserBankAtmDepositVol					
		   ,CAST(ISNULL(UserBankFastDepositCnt							 ,0) AS DECIMAL(20,1))	UserBankFastDepositCnt					
		   ,CAST(ISNULL(UserBankFastDepositVol							 ,0) AS DECIMAL(20,1))	UserBankFastDepositVol					
		   ,CAST(ISNULL(UserBankTransferDepositCnt						 ,0) AS DECIMAL(20,1))	UserBankTransferDepositCnt				
		   ,CAST(ISNULL(UserBankTransferDepositVol						 ,0) AS DECIMAL(20,1))	UserBankTransferDepositVol				
		   ,CAST(ISNULL(UserBankWithdrawalCnt								 ,0) AS DECIMAL(20,1))	UserBankWithdrawalCnt						
		   ,CAST(ISNULL(UserBankWithdrawalVol							 ,0) AS DECIMAL(20,1))	UserBankWithdrawalVol					
		   ,CAST(ISNULL(UserManuelProcessedBankTransferDepositCnt			 ,0) AS DECIMAL(20,1))	UserManuelProcessedBankTransferDepositCnt	
		   ,CAST(ISNULL(IbanRemittanceCnt								 ,0) AS DECIMAL(20,1))	IbanRemittanceCnt						
		   ,CAST(ISNULL(IbanRemittanceVol								 ,0) AS DECIMAL(20,1))	IbanRemittanceVol						
		   ,CAST(ISNULL(OnlyExternalTopUpCardDepositCnt								 ,0) AS DECIMAL(20,1))	OnlyExternalTopUpCardDepositCnt						
		   ,CAST(ISNULL(OnlyExternalTopUpCardDepositVol								 ,0) AS DECIMAL(20,1))	OnlyExternalTopUpCardDepositVol
		   ,CAST(ISNULL(MerchandiserIbanRemittanceCnt					 	 ,0) AS DECIMAL(20,1))	MerchandiserIbanRemittanceCnt	/*Yeni*/
		   ,CAST(ISNULL(MerchandiserIbanRemittanceFee  					 	 ,0) AS DECIMAL(20,1))  MerchandiserIbanRemittanceFee /*Yeni*/	
		   ,CAST(ISNULL(MerchandiserIbanRemittanceVol 					 ,0) AS DECIMAL(20,1))  MerchandiserIbanRemittanceVol	/*Yeni*/		   
INTO #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource
FROM FACT_DailyDepositAndWithdrawalCSEntityDataSource (nolock)
WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
/*END - #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource*/	
PRINT '26 - Completed - #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource*/	   
SELECT  L.[Date]
	   ,CAST(ISNULL(OnlinePosTxVol_Transactions	  +  OnlinePosTxVol_MerchandiserTransactions				 ,0) AS DECIMAL(20,1))	OnlinePosTxVol					
	   ,CAST(ISNULL(OnlinePosTxCnt_Transactions		  +  OnlinePosTxCnt_MerchandiserTransactions				 ,0) AS DECIMAL(20,1))	OnlinePosTxCnt				
	   ,CAST(ISNULL(OnlinePosTxUserCnt_Transactions   +  OnlinePosTxMerchandiserCnt_MerchandiserTransactions		 ,0) AS DECIMAL(20,1))	OnlinePosTxUserCnt
	   ,CAST(ISNULL(PhysicalTxPosTxVol_Transactions	  +  PhysicalTxPosTxVol_MerchandiserTransactions				 ,0) AS DECIMAL(20,1))	PhysicalTxPosTxVol	
	   ,CAST(ISNULL(PhysicalTxPosTxCnt_Transactions	  +  PhysicalTxPosTxCnt_MerchandiserTransactions				 ,0) AS DECIMAL(20,1))	PhysicalTxPosTxCnt	
	   ,CAST(ISNULL(PhysicalTxPosTxUserCnt_Transactions  +  PhysicalTxPosTxMerchandiserCnt_MerchandiserTransactions		 ,0) AS DECIMAL(20,1))	PhysicalTxPosTxUserCnt	
	   ,CAST(ISNULL(							     AtmWithdrawalTxUserCnt						 ,0) AS DECIMAL(20,1))	AtmWithdrawalTxUserCnt		
	   ,CAST(ISNULL(							     AtmDepositTxUserCnt							 ,0) AS DECIMAL(20,1))	AtmDepositTxUserCnt			
	   ,CAST(ISNULL(							     CardToCardTransferTxVol						 ,0) AS DECIMAL(20,1))	CardToCardTransferTxVol		
	   ,CAST(ISNULL(							     GiftCardTxVol								 ,0) AS DECIMAL(20,1))	GiftCardTxVol				
	   ,CAST(ISNULL(							     GiftCardTxCnt								 ,0) AS DECIMAL(20,1))	GiftCardTxCnt				
	   ,CAST(ISNULL(AtmWithdrawalTxFeeVol_MerchandiserTransactions,0)+ISNULL(AtmWithdrawalTxFeeVol_Transactions,0) AS DECIMAL(20,1))	AtmWithdrawalTxFeeVol		
	   ,CAST(ISNULL(							     AtmDepositTxFeeVol							 ,0) AS DECIMAL(20,1))	AtmDepositTxFeeVol			
	   ,CAST(ISNULL(							     AtmBalanceInquiryTxFeeVol					 ,0) AS DECIMAL(20,1))	AtmBalanceInquiryTxFeeVol	
	   ,CAST(ISNULL(							     AtmBalanceInquiryTxCnt						 ,0) AS DECIMAL(20,1))	AtmBalanceInquiryTxCnt		
	   ,CAST(ISNULL(							     CardToCardTransferTxCnt						 ,0) AS DECIMAL(20,1))	CardToCardTransferTxCnt		
	   ,CAST(ISNULL(							     CollectionFootballCardFeeVol							 ,0) AS DECIMAL(20,1))	CollectionFootballCardFeeVol
	   ,CAST(ISNULL(							     CollectionTeamCardFeeVol								 ,0) AS DECIMAL(20,1))	CollectionTeamCardFeeVol
	   ,CAST(ISNULL(							     DatabaseCardTxUserDailyCnt						 ,0) AS DECIMAL(20,1))	DatabaseCardTxUserDailyCnt		
	   ,CAST(ISNULL(							     TotalPosTxUserDailyCnt						 ,0) AS DECIMAL(20,1))	TotalPosTxUserDailyCnt		
	   ,CAST(ISNULL(							     TotalAtmTxUserDailyCnt						 ,0) AS DECIMAL(20,1))	TotalAtmTxUserDailyCnt		
	   ,CAST(ISNULL(							     DatabaseCardShipmentFeeVol					 ,0) AS DECIMAL(20,1))	DatabaseCardShipmentFeeVol	
	   ,CAST(ISNULL(							     AtmDepositTxVol								 ,0) AS DECIMAL(20,1))	AtmDepositTxVol				
	   ,CAST(ISNULL(							     AtmDepositTxCnt								 ,0) AS DECIMAL(20,1))	AtmDepositTxCnt				
	   ,CAST(ISNULL(AtmWithdrawalTxVol_Transactions,0) +ISNULL(AtmWithdrawalTxVol_MerchandiserTransactions	 ,0) AS DECIMAL(20,1))	AtmWithdrawalTxVol			
	   ,CAST(ISNULL(AtmWithdrawalTxCnt_Transactions ,0)	+ISNULL(AtmWithdrawalTxCnt_MerchandiserTransactions		 ,0) AS DECIMAL(20,1))	AtmWithdrawalTxCnt			
	   ,CAST(ISNULL(							     RetailCardRefundTxCnt							 ,0) AS DECIMAL(20,1))	RetailCardRefundTxCnt			
	   ,CAST(ISNULL(							     RetailCardRefundTxVol							 ,0) AS DECIMAL(20,1))	RetailCardRefundTxVol			
	   ,CAST(ISNULL(							     PosTxRefundCnt								 ,0) AS DECIMAL(20,1))	PosTxRefundCnt				
	   ,CAST(ISNULL(							     PosTxRefundVol								 ,0) AS DECIMAL(20,1))	PosTxRefundVol				
	   ,CAST(ISNULL(							     AtmWithdrawalTxRefundCnt						 ,0) AS DECIMAL(20,1))	AtmWithdrawalTxRefundCnt		
	   ,CAST(ISNULL(							     AtmWithdrawalTxRefundVol					 ,0) AS DECIMAL(20,1))	AtmWithdrawalTxRefundVol	
	   ,CAST(ISNULL(							     CorporateGiftCardTxCnt						 ,0) AS DECIMAL(20,1))	CorporateGiftCardTxCnt		
	   ,CAST(ISNULL(							     CorporateGiftCardTxVol						 ,0) AS DECIMAL(20,1))	CorporateGiftCardTxVol			
	   ,CAST(ISNULL(PaidNewVirtualCardCnt_Transactions + PaidNewVirtualCardCnt_MerchandiserTransactions			 ,0) AS DECIMAL(20,1))	PaidNewVirtualCardCnt
	   ,CAST(ISNULL(VirtualCardFeeVol_Transactions	   + VirtualCardFeeVol_MerchandiserTransactions			 ,0) AS DECIMAL(20,1))	VirtualCardFeeVol
			
INTO #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource
FROM DIM_Date (nolock) d
JOIN
		 (
				SELECT  CAST(CreatedAt AS DATE) [Date] 
					   ,Cnt(			CASE WHEN FeatureType = 2	and DatabaseCardTxType = 1 and  IsPhysicalCardTx = 0							  THEN Id	   ELSE NULL END)		OnlinePosTxCnt_Transactions			
					   ,ABS(SUM(		CASE WHEN FeatureType = 2 and DatabaseCardTxType = 1 and  IsPhysicalCardTx = 0							  THEN TxAmount  ELSE NULL END))		OnlinePosTxVol_Transactions	
					   ,Cnt( DISTINCT CASE WHEN FeatureType = 2 and DatabaseCardTxType = 1 and  IsPhysicalCardTx = 0							  THEN User_Key ELSE NULL END)		OnlinePosTxUserCnt_Transactions	
					   ,Cnt(		    CASE WHEN FeatureType = 2 and DatabaseCardTxType = 1 and (IsPhysicalCardTx = 1  OR IsPhysicalCardTx IS NULL)	  THEN Id	   ELSE NULL END)		PhysicalTxPosTxCnt_Transactions	    
					   ,ABS(SUM(		CASE WHEN FeatureType = 2 and DatabaseCardTxType = 1 and (IsPhysicalCardTx = 1  OR IsPhysicalCardTx IS NULL)	  THEN TxAmount  ELSE NULL END))		PhysicalTxPosTxVol_Transactions   
					   ,Cnt(DISTINCT  CASE WHEN FeatureType = 2 and DatabaseCardTxType = 1 and (IsPhysicalCardTx = 1  OR IsPhysicalCardTx IS NULL)	  THEN User_Key ELSE NULL END)		PhysicalTxPosTxUserCnt_Transactions
					   ,Cnt(DISTINCT	CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 0												  THEN User_Key ELSE NULL END) 		AtmWithdrawalTxUserCnt
					   ,Cnt(DISTINCT	CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 5												  THEN User_Key ELSE NULL END) 		AtmDepositTxUserCnt
					   ,		SUM(	CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 4							 					  THEN TxAmount  ELSE NULL END) 		CardToCardTransferTxVol
					   ,ABS(	SUM(	CASE WHEN FeatureType = 23																		  THEN TxAmount  ELSE NULL END)) 		GiftCardTxVol
					   ,Cnt		(	CASE WHEN FeatureType = 23																		  THEN Id	   ELSE NULL END) 		GiftCardTxCnt
					   ,ABS(	SUM(	CASE WHEN FeatureType = 2  AND DatabaseCardTxType = 0												  THEN Fee	   ELSE NULL END)) 		AtmWithdrawalTxFeeVol_Transactions
					   ,ABS(	SUM(	CASE WHEN FeatureType = 2  AND DatabaseCardTxType = 5												  THEN Fee	   ELSE NULL END)) 		AtmDepositTxFeeVol
					   ,ABS(	SUM(	CASE WHEN FeatureType = 2  AND DatabaseCardTxType = 2												  THEN TxAmount  ELSE NULL END)) 		AtmBalanceInquiryTxFeeVol
					   ,Cnt(			CASE WHEN FeatureType = 2  AND DatabaseCardTxType = 2												  THEN Id	   ELSE NULL END)		AtmBalanceInquiryTxCnt
						,Cnt(			CASE WHEN FeatureType	= 2  AND DatabaseCardTxType = 4												  THEN Id	   ELSE NULL END)		CardToCardTransferTxCnt
					   ,		SUM(	CASE WHEN FeatureType = 29 AND (EntrySubType	 = 0 OR EntrySubType IS NULL)						  THEN TxAmount  ELSE NULL END) 		CollectionFootballCardFeeVol
					   ,		SUM(	CASE WHEN FeatureType = 29 AND  EntrySubType	 = 2												  THEN TxAmount  ELSE NULL END) 		CollectionTeamCardFeeVol
					   ,Cnt(DISTINCT  CASE WHEN FeatureType = 2																			  THEN User_Key ELSE NULL END) 		DatabaseCardTxUserDailyCnt
					   ,Cnt(DISTINCT  CASE WHEN FeatureType = 2  AND DatabaseCardTxType = 1												  THEN User_Key ELSE NULL END) 		TotalPosTxUserDailyCnt
					   ,Cnt(DISTINCT  CASE WHEN FeatureType = 2  AND DatabaseCardTxType in (0,5)											  THEN User_Key ELSE NULL END) 		TotalAtmTxUserDailyCnt
					   ,	   SUM(		CASE WHEN EntrySubType = 1																		  THEN TxAmount  ELSE NULL END)		DatabaseCardShipmentFeeVol
					   	,ABS  (SUM(		CASE WHEN FeatureType = 2  AND DatabaseCardTxType = 5												  THEN TxAmount  ELSE NULL END))		AtmDepositTxVol
					   	,Cnt(			CASE WHEN FeatureType = 2  AND DatabaseCardTxType = 5												  THEN Id	   ELSE NULL END)		AtmDepositTxCnt
					   	,ABS  (SUM(		CASE WHEN FeatureType = 2  AND DatabaseCardTxType = 0												  THEN TxAmount  ELSE NULL END))		AtmWithdrawalTxVol_Transactions
					   	,Cnt(			CASE WHEN FeatureType = 2  AND DatabaseCardTxType = 0												  THEN Id	   ELSE NULL END)		AtmWithdrawalTxCnt_Transactions
						,Cnt(			CASE WHEN FeatureType = 2  AND DatabaseCardTxType = 8												  THEN Id	   ELSE NULL END)		RetailCardRefundTxCnt
						,SUM  (			CASE WHEN FeatureType = 2  AND DatabaseCardTxType = 8												  THEN TxAmount  ELSE NULL END)		RetailCardRefundTxVol
						,Cnt(			CASE WHEN FeatureType = 2  AND DatabaseCardTxType = 1 AND IsCancellation = 1						  THEN Id	   ELSE NULL END)		PosTxRefundCnt
						,SUM  (			CASE WHEN FeatureType = 2  AND DatabaseCardTxType = 1 AND IsCancellation = 1						  THEN TxAmount  ELSE NULL END)		PosTxRefundVol
						,Cnt(			CASE WHEN FeatureType = 2  AND DatabaseCardTxType = 0 AND IsCancellation = 1						  THEN Id	   ELSE NULL END)		AtmWithdrawalTxRefundCnt
						,SUM  (			CASE WHEN FeatureType = 2  AND DatabaseCardTxType = 0 AND IsCancellation = 1						  THEN TxAmount  ELSE NULL END)		AtmWithdrawalTxRefundVol
						,Cnt(			CASE WHEN FeatureType = 2  AND DatabaseCardTxType = 6												  THEN Id	   ELSE NULL END)		PaidNewVirtualCardCnt_Transactions
						,ABS(SUM(		CASE WHEN FeatureType = 2  AND DatabaseCardTxType = 6												  THEN TxAmount  ELSE NULL END))		VirtualCardFeeVol_Transactions
						
				FROM FACT_Transactions (NOLOCK)
				WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
				GROUP BY CAST(CreatedAt AS DATE)
		  ) L ON D.CreateDate = L.[Date]
JOIN
		  (
				SELECT CAST(CreatedAt AS DATE) [Date], 
					   Cnt(		  CASE WHEN FeatureType = 2  and DatabaseCardTxType = 1 and  IsPhysicalCardTx = 0								  THEN Id	    ELSE NULL END)	OnlinePosTxCnt_MerchandiserTransactions				,
					   ABS(SUM(		  CASE WHEN FeatureType = 2  and DatabaseCardTxType = 1 and  IsPhysicalCardTx = 0								  THEN TxAmount   ELSE NULL END))	OnlinePosTxVol_MerchandiserTransactions			,
					   Cnt(DISTINCT CASE WHEN FeatureType = 2  and DatabaseCardTxType = 1 and  IsPhysicalCardTx = 0								  THEN User_Key ELSE NULL END)	OnlinePosTxMerchandiserCnt_MerchandiserTransactions		,
					   Cnt(		  CASE WHEN FeatureType = 2  and DatabaseCardTxType = 1 and (IsPhysicalCardTx = 1 OR IsPhysicalCardTx IS NULL)		  THEN Id	    ELSE NULL END)	PhysicalTxPosTxCnt_MerchandiserTransactions			,
					   ABS(SUM(		  CASE WHEN FeatureType = 2  and DatabaseCardTxType = 1 and (IsPhysicalCardTx = 1 OR IsPhysicalCardTx IS NULL)		  THEN TxAmount   ELSE NULL END))	PhysicalTxPosTxVol_MerchandiserTransactions			,
					   Cnt(DISTINCT CASE WHEN FeatureType = 2  and DatabaseCardTxType = 1 and (IsPhysicalCardTx = 1 OR IsPhysicalCardTx IS NULL)		  THEN User_Key ELSE NULL END)	PhysicalTxPosTxMerchandiserCnt_MerchandiserTransactions	,
					   Cnt(		  CASE WHEN FeatureType = 23																			  THEN Id		ELSE NULL END)	CorporateGiftCardTxCnt					,
					   ABS(SUM(		  CASE WHEN FeatureType = 23																			  THEN TxAmount   ELSE NULL END))	CorporateGiftCardTxVol					,
					   Cnt(		  CASE WHEN					   DatabaseCardTxType = 6													  THEN Id		ELSE NULL END)	PaidNewVirtualCardCnt_MerchandiserTransactions		,
					   ABS(SUM(		  CASE WHEN					   DatabaseCardTxType = 6													  THEN TxAmount   ELSE NULL END))	VirtualCardFeeVol_MerchandiserTransactions			,
					   Cnt(		  CASE WHEN FeatureType = 2  AND DatabaseCardTxType = 0													  THEN Id	    ELSE NULL END)	AtmWithdrawalTxCnt_MerchandiserTransactions			,
					   ABS  (SUM(	  CASE WHEN FeatureType = 2  AND DatabaseCardTxType = 0													  THEN TxAmount   ELSE NULL END))	AtmWithdrawalTxVol_MerchandiserTransactions		,
					   ABS(	SUM(	CASE WHEN FeatureType = 2  AND DatabaseCardTxType = 0													  THEN Fee	    ELSE NULL END)) AtmWithdrawalTxFeeVol_MerchandiserTransactions


				FROM FACT_MerchandiserTransactions (NOLOCK)
				WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
				GROUP BY CAST(CreatedAt AS DATE)
		  ) M
ON D.CreateDate = M.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource*/	
PRINT '27 - Completed - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource'  + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_A*/	 
		 		 SELECT
					   CAST(CreatedAt AS DATE)												[Date],
					   CAST(ISNULL(Cnt(CASE WHEN [Type] in (4,5) THEN Id ELSE NULL END),0) AS DECIMAL(20,1))				  GeneralCardApplicationCnt,
					   CAST(ISNULL(Cnt(DISTINCT CASE WHEN [Type] in (3,10,11,9) THEN Id ELSE NULL END),0) AS DECIMAL(20,1)) NewVirtualCardCnt
				 INTO #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_A
				 FROM DIM_DatabaseCards (nolock)
				 WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
				 GROUP BY CAST(CreatedAt AS DATE)
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_A*/	
PRINT '28 - Completed - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_A'  + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_B*/		 
				SELECT  CAST(ActivationDate AS DATE) [Date]																																				,
						CAST(ISNULL(AVG(  CASE WHEN [Type] IN (4,5) AND datediff(day,CreatedAt,ActivationDate) < 120 THEN datediff(day,CreatedAt,ActivationDate) ELSE NULL END),0) AS DECIMAL(20,1)) ApplicationToActivationTimeAvg		,
						CAST(ISNULL(Cnt(CASE WHEN [Type] IN (4,5)												     THEN Id									 ELSE NULL END),0) AS DECIMAL(20,1)) GeneralCardActivationCnt			,
						CAST(ISNULL(Cnt(CASE WHEN [Type] IN (6,7)												     THEN Id									 ELSE NULL END),0) AS DECIMAL(20,1)) RetailCardActivationCnt			,
						CAST(ISNULL(Cnt(CASE WHEN [Type]	 = 8												     THEN Id									 ELSE NULL END),0) AS DECIMAL(20,1)) PremiumCardActivationCnt			
				INTO #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_B
				FROM DIM_DatabaseCards (nolock)
				where ActivationDate >= DATEADD(DAY,-@d,@BaseDay) AND ActivationDate < @BaseDay
				GROUP BY CAST(ActivationDate AS DATE)
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_B*/	
PRINT '29 - Completed - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_B'  + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_C*/
				SELECT  CAST(CreatedAt AS DATE) [Date]
					   ,CAST(ISNULL(Cnt(  CASE WHEN TransactionType = 1 AND PentryMode NOT IN ('010','011','012','100','102','810','811','812','W','R','O','L') THEN Id	  ELSE NULL END) ,0) AS DECIMAL(20,1)) DeclinedPhysicalTxPosTxCnt
					   ,CAST(ISNULL(ABS(SUM(CASE WHEN TransactionType = 1 AND PentryMode NOT IN ('010','011','012','100','102','810','811','812','W','R','O','L') THEN TxAmount ELSE NULL END)),0) AS DECIMAL(20,1)) DeclinedPhysicalTxPosTxVol
					   ,CAST(ISNULL(Cnt(  CASE WHEN TransactionType = 1 AND PentryMode	 IN ('010','011','012','100','102','810','811','812','W','R','O','L') THEN Id	  ELSE NULL END) ,0) AS DECIMAL(20,1)) DeclinedOnlinePosTxCnt
					   ,CAST(ISNULL(ABS(SUM(CASE WHEN TransactionType = 1 AND PentryMode	 IN ('010','011','012','100','102','810','811','812','W','R','O','L') THEN TxAmount ELSE NULL END)),0) AS DECIMAL(20,1)) DeclinedOnlinePosTxVol
					   ,CAST(ISNULL(Cnt(  CASE WHEN TransactionType = 0																						  THEN Id	  ELSE NULL END) ,0) AS DECIMAL(20,1)) DeclinedAtmWithdrawalTxCnt
					   ,CAST(ISNULL(ABS(SUM(CASE WHEN TransactionType = 0																						  THEN TxAmount ELSE NULL END)),0) AS DECIMAL(20,1)) DeclinedAtmWithdrawalTxVol					   
				INTO #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_C
				FROM FACT_DatabaseCardTransactionFailedLogs (NOLOCK)
				WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
				GROUP BY CAST(CreatedAt AS DATE)
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_C*/	
PRINT '30 - Completed - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_C'  + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_D*/
				SELECT	 CAST(L.CreatedAt AS DATE) [Date]
						,CAST(ISNULL(Cnt(DISTINCT CASE WHEN l.FeatureType = 2 AND p.[Type] in (4,5)									THEN l.DatabaseCardId ELSE NULL END) 	,0) AS DECIMAL(20,1)) ActiveGeneralCardDailyCnt
						,CAST(ISNULL(Cnt(DISTINCT CASE WHEN l.FeatureType = 2 AND p.[Type] in (6,7)									THEN l.DatabaseCardId ELSE NULL END)	,0) AS DECIMAL(20,1)) ActiveRetailCardDailyCnt
						,CAST(ISNULL(Cnt(DISTINCT CASE WHEN l.FeatureType = 2 AND p.[Type] in (3,9,10)								THEN l.DatabaseCardId ELSE NULL END)	,0) AS DECIMAL(20,1)) ActiveVirtualCardDailyCnt
						,CAST(ISNULL(Cnt(DISTINCT CASE WHEN l.FeatureType = 2 AND p.[Type]  =  8									THEN l.DatabaseCardId ELSE NULL END)	,0) AS DECIMAL(20,1)) ActivePremiumCardDailyCnt
						,CAST(ISNULL(Cnt(			CASE WHEN l.FeatureType = 2 AND p.[Type] in (4,5)		AND l.DatabaseCardTxType = 1	THEN l.Id			ELSE NULL END)	,0) AS DECIMAL(20,1)) GeneralCardPosTxCnt		
						,CAST(ISNULL(ABS(SUM(		CASE WHEN l.FeatureType = 2 AND p.[Type] in (4,5)		AND l.DatabaseCardTxType = 1	THEN l.TxAmount		ELSE NULL END))	,0) AS DECIMAL(20,1)) GeneralCardPosTxVol	
						,CAST(ISNULL(Cnt(			CASE WHEN l.FeatureType = 2 AND p.[Type] in (3,9,10)	AND l.DatabaseCardTxType = 1	THEN l.Id			ELSE NULL END)	,0) AS DECIMAL(20,1)) VirtualCardPosTxCnt
						,CAST(ISNULL(ABS(SUM(		CASE WHEN l.FeatureType = 2 AND p.[Type] in (3,9,10)	AND l.DatabaseCardTxType = 1	THEN l.TxAmount		ELSE NULL END))	,0) AS DECIMAL(20,1)) VirtualCardPosTxVol
						,CAST(ISNULL(Cnt(			CASE WHEN l.FeatureType = 2 AND p.[Type]  =  9		AND l.DatabaseCardTxType = 1	THEN L.Id			ELSE NULL END)	,0) AS DECIMAL(20,1)) GiftCardPosTxCnt			
						,CAST(ISNULL(SUM(			CASE WHEN l.FeatureType = 2 AND p.[Type]  =  9		AND l.DatabaseCardTxType = 1	THEN l.TxAmount		ELSE NULL END)	,0) AS DECIMAL(20,1)) GiftCardPosTxVol			
						,CAST(ISNULL(Cnt(			CASE WHEN l.FeatureType = 2 AND p.[Type]  =  12		AND l.DatabaseCardTxType = 1	THEN L.Id			ELSE NULL END)	,0) AS DECIMAL(20,1)) CorporateGiftCardPosTxCnt	
						,CAST(ISNULL(SUM(			CASE WHEN l.FeatureType = 2 AND p.[Type]  =  12		AND l.DatabaseCardTxType = 1	THEN l.TxAmount		ELSE NULL END)	,0) AS DECIMAL(20,1)) CorporateGiftCardPosTxVol
						,CAST(ISNULL(Cnt(			CASE WHEN l.FeatureType = 2 AND p.[Type] in (4,5)		AND l.DatabaseCardTxType = 0	THEN L.Id			ELSE NULL END)	,0) AS DECIMAL(20,1)) GeneralCardAtmWithdrawalTxCnt	
						,CAST(ISNULL(ABS(SUM(		CASE WHEN l.FeatureType = 2 AND p.[Type] in (4,5)		AND l.DatabaseCardTxType = 0	THEN l.TxAmount		ELSE NULL END))	,0) AS DECIMAL(20,1)) GeneralCardAtmWithdrawalTxVol	
						,CAST(ISNULL(Cnt(			CASE WHEN l.FeatureType = 2 AND p.[Type] in (4,5)		AND l.DatabaseCardTxType = 5	THEN L.Id			ELSE NULL END)	,0) AS DECIMAL(20,1)) GeneralCardAtmDepositTxCnt		
						,CAST(ISNULL(ABS(SUM(		CASE WHEN l.FeatureType = 2 AND p.[Type] in (4,5)		AND l.DatabaseCardTxType = 5	THEN l.TxAmount		ELSE NULL END))	,0) AS DECIMAL(20,1)) GeneralCardAtmDepositTxVol		
						,CAST(ISNULL(Cnt(			CASE WHEN l.FeatureType = 2 AND p.[Type] in (6,7)		AND l.DatabaseCardTxType = 5	THEN L.Id			ELSE NULL END)	,0) AS DECIMAL(20,1)) RetailCardAtmDepositTxCnt		
						,CAST(ISNULL(ABS(SUM(		CASE WHEN l.FeatureType = 2 AND p.[Type] in (6,7)		AND l.DatabaseCardTxType = 5	THEN l.TxAmount		ELSE NULL END))	,0) AS DECIMAL(20,1)) RetailCardAtmDepositTxVol
						,CAST(ISNULL(SUM(			CASE WHEN l.FeatureType = 2 AND p.[Type]  =  8		AND l.DatabaseCardTxType = 3	THEN l.TxAmount		ELSE NULL END)	,0) AS DECIMAL(20,1)) PremiumCardFeeVol
						,CAST(ISNULL(ABS(SUM(			CASE WHEN l.FeatureType = 2 AND p.[Type]  =  15		AND l.DatabaseCardTxType = 3	THEN l.TxAmount		ELSE NULL END))	,0) AS DECIMAL(20,1)) VoiceCardFeeVol	
				 INTO #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_D
				 FROM FACT_Transactions (nolock) L																		
				 JOIN DIM_DatabaseCards (nolock) P ON L.DatabaseCardId = P.Id											
				 WHERE L.CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND L.CreatedAt < @BaseDay 									
				 GROUP BY CAST(L.CreatedAt AS DATE)
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_D*/	
PRINT '31 - Completed - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_D'  + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_E*/
				SELECT																								
						 CAST(mL.CreatedAt AS DATE) [Date]															
						,CAST(ISNULL(Cnt(DISTINCT CASE WHEN ml.FeatureType = 2 AND p.[Type] in (1,11)								THEN mL.DatabaseCardId ELSE NULL END) ,0) AS DECIMAL(20,1)) ActiveCorporateCardDailyCnt
						,CAST(ISNULL(Cnt(			CASE WHEN ml.FeatureType = 2 AND p.[Type] in (1,11)	AND ml.DatabaseCardTxType = 1	THEN mL.Id			 ELSE NULL END)	,0) AS DECIMAL(20,1)) CorporateCardPosTxCnt
						,CAST(ISNULL(ABS(SUM(		CASE WHEN ml.FeatureType = 2 AND p.[Type] in (1,11)	AND ml.DatabaseCardTxType = 1	THEN ml.TxAmount		 ELSE NULL END)),0) AS DECIMAL(20,1)) CorporateCardPosTxVol
				 INTO #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_E
				 FROM FACT_MerchandiserTransactions (nolock) mL
				 JOIN DIM_DatabaseCards (nolock) P ON mL.DatabaseCardId = P.Id
				 WHERE ML.CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND ML.CreatedAt < @BaseDay
				 GROUP BY CAST(ML.CreatedAt AS DATE)
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_E*/	
PRINT '32 - Completed - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_E'  + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))


/*BEGIN - #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource*/	
SELECT CAST(CreatedAt AS DATE) [Date],
	   CAST(ISNULL(OnlinePosTxVol				,0) AS DECIMAL(20,1))	OnlinePosTxVol					,
	   CAST(ISNULL(OnlinePosTxCnt					,0) AS DECIMAL(20,1))	OnlinePosTxCnt					,
	   CAST(ISNULL(OnlinePosTxUserCnt				,0) AS DECIMAL(20,1))	OnlinePosTxUserCnt				,
	   CAST(ISNULL(PhysicalTxPosTxVol				,0) AS DECIMAL(20,1))	PhysicalTxPosTxVol					,
	   CAST(ISNULL(PhysicalTxPosTxCnt				,0) AS DECIMAL(20,1))	PhysicalTxPosTxCnt					,
	   CAST(ISNULL(PhysicalTxPosTxUserCnt			,0) AS DECIMAL(20,1))	PhysicalTxPosTxUserCnt				,
	   CAST(ISNULL(GeneralCardApplicationCnt		,0) AS DECIMAL(20,1))	GeneralCardApplicationCnt			,
	   CAST(ISNULL(ApplicationToActivationTimeAvg	,0) AS DECIMAL(20,1))	ApplicationToActivationTimeAvg		,
	   CAST(ISNULL(GeneralCardActivationCnt			,0) AS DECIMAL(20,1))	GeneralCardActivationCnt			,
	   CAST(ISNULL(RetailCardActivationCnt			,0) AS DECIMAL(20,1))	RetailCardActivationCnt				,
	   CAST(ISNULL(PremiumCardActivationCnt			,0) AS DECIMAL(20,1))	PremiumCardActivationCnt			,
	   CAST(ISNULL(AtmWithdrawalTxUserCnt			,0) AS DECIMAL(20,1))	AtmWithdrawalTxUserCnt			,
	   CAST(ISNULL(AtmDepositTxUserCnt			,0) AS DECIMAL(20,1))	AtmDepositTxUserCnt				,
	   CAST(ISNULL(CardToCardTransferTxVol		,0) AS DECIMAL(20,1))	CardToCardTransferTxVol			,
	   CAST(ISNULL(GiftCardTxVol					,0) AS DECIMAL(20,1))	GiftCardTxVol					,
	   CAST(ISNULL(GiftCardTxCnt					,0) AS DECIMAL(20,1))	GiftCardTxCnt						,
	   CAST(ISNULL(AtmWithdrawalTxFeeVol			,0) AS DECIMAL(20,1))	AtmWithdrawalTxFeeVol			,
	   CAST(ISNULL(AtmDepositTxFeeVol			,0) AS DECIMAL(20,1))	AtmDepositTxFeeVol				,
	   CAST(ISNULL(AtmBalanceInquiryTxFeeVol		,0) AS DECIMAL(20,1))	AtmBalanceInquiryTxFeeVol		,
	   CAST(ISNULL(AtmBalanceInquiryTxCnt         ,0) AS DECIMAL(20,1))	AtmBalanceInquiryTxCnt         	,
	   CAST(ISNULL(CardToCardTransferTxCnt		,0) AS DECIMAL(20,1))	CardToCardTransferTxCnt			,
	   CAST(ISNULL(CollectionFootballCardFeeVol				,0) AS DECIMAL(20,1))	CollectionFootballCardFeeVol					,
	   CAST(ISNULL(CollectionTeamCardFeeVol				,0) AS DECIMAL(20,1))	CollectionTeamCardFeeVol					,
	   CAST(ISNULL(DatabaseCardTxUserDailyCnt		,0) AS DECIMAL(20,1))	DatabaseCardTxUserDailyCnt			,
	   CAST(ISNULL(TotalPosTxUserDailyCnt			,0) AS DECIMAL(20,1))	TotalPosTxUserDailyCnt			,
	   CAST(ISNULL(TotalAtmTxUserDailyCnt			,0) AS DECIMAL(20,1))	TotalAtmTxUserDailyCnt			,
	   CAST(ISNULL(DatabaseCardShipmentFeeVol		,0) AS DECIMAL(20,1))	DatabaseCardShipmentFeeVol			,
	   CAST(ISNULL(AtmDepositTxVol				,0) AS DECIMAL(20,1))	AtmDepositTxVol					,
	   CAST(ISNULL(AtmDepositTxCnt				,0) AS DECIMAL(20,1))	AtmDepositTxCnt					,
	   CAST(ISNULL(AtmWithdrawalTxVol			,0) AS DECIMAL(20,1))	AtmWithdrawalTxVol				,
	   CAST(ISNULL(AtmWithdrawalTxCnt				,0) AS DECIMAL(20,1))	AtmWithdrawalTxCnt				,
	   CAST(ISNULL(RetailCardRefundTxCnt			,0) AS DECIMAL(20,1))	RetailCardRefundTxCnt				,
	   CAST(ISNULL(RetailCardRefundTxVol			,0) AS DECIMAL(20,1))	RetailCardRefundTxVol				,
	   CAST(ISNULL(PosTxRefundCnt					,0) AS DECIMAL(20,1))	PosTxRefundCnt					,
	   CAST(ISNULL(PosTxRefundVol				,0) AS DECIMAL(20,1))	PosTxRefundVol					,
	   CAST(ISNULL(AtmWithdrawalTxRefundCnt		,0) AS DECIMAL(20,1))	AtmWithdrawalTxRefundCnt			,
	   CAST(ISNULL(AtmWithdrawalTxRefundVol		,0) AS DECIMAL(20,1))	AtmWithdrawalTxRefundVol			,
	   CAST(ISNULL(CorporateGiftCardTxCnt			,0) AS DECIMAL(20,1))	CorporateGiftCardTxCnt			,
	   CAST(ISNULL(CorporateGiftCardTxVol		,0) AS DECIMAL(20,1))	CorporateGiftCardTxVol			,
	   CAST(ISNULL(NewVirtualCardCnt				,0) AS DECIMAL(20,1))	NewVirtualCardCnt					,
	   CAST(ISNULL(PaidNewVirtualCardCnt			,0) AS DECIMAL(20,1))	PaidNewVirtualCardCnt				,
	   CAST(ISNULL(VirtualCardFeeVol				,0) AS DECIMAL(20,1))	VirtualCardFeeVol				,
	   CAST(ISNULL(DeclinedPhysicalTxPosTxCnt		,0) AS DECIMAL(20,1))	DeclinedPhysicalTxPosTxCnt			,
	   CAST(ISNULL(DeclinedPhysicalTxPosTxVol		,0) AS DECIMAL(20,1))	DeclinedPhysicalTxPosTxVol			,
	   CAST(ISNULL(DeclinedOnlinePosTxCnt			,0) AS DECIMAL(20,1))	DeclinedOnlinePosTxCnt			,
	   CAST(ISNULL(DeclinedOnlinePosTxVol		,0) AS DECIMAL(20,1))	DeclinedOnlinePosTxVol			,
	   CAST(ISNULL(DeclinedAtmWithdrawalTxCnt		,0) AS DECIMAL(20,1))	DeclinedAtmWithdrawalTxCnt		,
	   CAST(ISNULL(DeclinedAtmWithdrawalTxVol	,0) AS DECIMAL(20,1))	DeclinedAtmWithdrawalTxVol		,
	   CAST(ISNULL(ActiveGeneralCardDailyCnt		,0) AS DECIMAL(20,1))	ActiveGeneralCardDailyCnt			,
	   CAST(ISNULL(ActiveRetailCardDailyCnt			,0) AS DECIMAL(20,1))	ActiveRetailCardDailyCnt			,
	   CAST(ISNULL(ActiveVirtualCardDailyCnt		,0) AS DECIMAL(20,1))	ActiveVirtualCardDailyCnt			,
	   CAST(ISNULL(ActiveCorporateCardDailyCnt	,0) AS DECIMAL(20,1))	ActiveCorporateCardDailyCnt		,
	   CAST(ISNULL(ActivePremiumCardDailyCnt  		,0) AS DECIMAL(20,1))	ActivePremiumCardDailyCnt  			,
	   CAST(ISNULL(GeneralCardPosTxCnt				,0) AS DECIMAL(20,1))	GeneralCardPosTxCnt					,
	   CAST(ISNULL(GeneralCardPosTxVol				,0) AS DECIMAL(20,1))	GeneralCardPosTxVol				,
	   CAST(ISNULL(VirtualCardPosTxCnt			,0) AS DECIMAL(20,1))	VirtualCardPosTxCnt				,
	   CAST(ISNULL(VirtualCardPosTxVol			,0) AS DECIMAL(20,1))	VirtualCardPosTxVol				,
	   CAST(ISNULL(GiftCardPosTxCnt				,0) AS DECIMAL(20,1))	GiftCardPosTxCnt					,
	   CAST(ISNULL(GiftCardPosTxVol				,0) AS DECIMAL(20,1))	GiftCardPosTxVol					,
	   CAST(ISNULL(CorporateGiftCardPosTxCnt		,0) AS DECIMAL(20,1))	CorporateGiftCardPosTxCnt			,
	   CAST(ISNULL(CorporateGiftCardPosTxVol		,0) AS DECIMAL(20,1))	CorporateGiftCardPosTxVol		,
	   CAST(ISNULL(CorporateCardPosTxCnt			,0) AS DECIMAL(20,1))	CorporateCardPosTxCnt				,
	   CAST(ISNULL(CorporateCardPosTxVol			,0) AS DECIMAL(20,1))	CorporateCardPosTxVol			,
	   CAST(ISNULL(GeneralCardAtmWithdrawalTxCnt	,0) AS DECIMAL(20,1))	GeneralCardAtmWithdrawalTxCnt		,
	   CAST(ISNULL(GeneralCardAtmWithdrawalTxVol	,0) AS DECIMAL(20,1))	GeneralCardAtmWithdrawalTxVol		,
	   CAST(ISNULL(GeneralCardAtmDepositTxCnt		,0) AS DECIMAL(20,1))	GeneralCardAtmDepositTxCnt			,
	   CAST(ISNULL(GeneralCardAtmDepositTxVol		,0) AS DECIMAL(20,1))	GeneralCardAtmDepositTxVol			,
	   CAST(ISNULL(RetailCardAtmDepositTxCnt		,0) AS DECIMAL(20,1))	RetailCardAtmDepositTxCnt			,
	   CAST(ISNULL(RetailCardAtmDepositTxVol		,0) AS DECIMAL(20,1))	RetailCardAtmDepositTxVol			,
	   CAST(ISNULL(PremiumCardFeeVol				,0) AS DECIMAL(20,1))	PremiumCardFeeVol					,
	   CAST(ISNULL(VoiceCardFeeVol				,0) AS DECIMAL(20,1))	VoiceCardFeeVol					
INTO #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource
FROM FACT_DailyDatabaseCardCSEntityDataSource (nolock)
WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
/*END - #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource*/	
PRINT '33 - Completed - #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource'	+ ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource*/
SELECT
		k.[Date],
		CashbackName,
		CAST(ISNULL(CashbackCnt						,0) AS DECIMAL(20,1))	CashbackCnt				,
		CAST(ISNULL(CashbackVol						,0) AS DECIMAL(20,1))	CashbackVol				,
		CAST(ISNULL(EndOfTheMonthCasbacksCnt			,0) AS DECIMAL(20,1))	EndOfTheMonthCasbacksCnt	,
		CAST(ISNULL(EndOfTheMonthCasbacksVol			,0) AS DECIMAL(20,1))	EndOfTheMonthCasbacksVol	,
		CAST(ISNULL(CasbackUserAttributesDailyCnt				,0) AS DECIMAL(20,1))	CasbackUserAttributesDailyCnt		
INTO #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource
FROM DIM_Date (nolock) d
JOIN
	  (
		select CAST(l.CreatedAt AS DATE) [Date],
				CB.Id,
				cb.DescriptionTitle CashbackName,
				Cnt(		   CASE WHEN l.FeatureType = 15			 THEN L.Id	    ELSE NULL END) CashbackCnt,
				Cnt(DISTINCT CASE WHEN l.ConditionId is not null	 THEN l.User_Key ELSE NULL END) CasbackUserAttributesDailyCnt,
				SUM(		   CASE WHEN l.FeatureType = 15			 THEN l.TxAmount  ELSE NULL END) CashbackVol	
		from
		FACT_Transactions (nolock) L
		join DIM_CashbackConditions (nolock) cb on l.ConditionId = cb.Id
		WHERE l.CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND l.CreatedAt < @BaseDay	
		GROUP BY CAST(L.CreatedAt AS DATE), CB.Id,cb.DescriptionTitle
	  ) K ON D.CreateDate = k.[Date]
JOIN
	  (
		select CAST(CreatedAt AS DATE) [Date],
			   ConditionId,
			   Cnt(Id)		 EndOfTheMonthCasbacksCnt,
			   abs(sum(TxAmount))  EndOfTheMonthCasbacksVol
		
		FROM FACT_EndOfTheMonthCashbacks (NOLOCK)
		WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay 			
		GROUP BY CAST(CreatedAt AS DATE),ConditionId
	  ) L 
ON D.CreateDate = L.[Date] and k.Id = L.ConditionId
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource*/
PRINT '34 - Completed - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - ADMIN_FACT_DailyDatabaseCardCashbackCSEntityDataSource*/
SELECT CAST(CreatedAt AS DATE) [Date],
			CashbackName,
			CAST(ISNULL(CashbackCnt					,0) AS DECIMAL(20,1))	CashbackCnt				,
			CAST(ISNULL(CashbackVol					,0) AS DECIMAL(20,1))	CashbackVol				,
			CAST(ISNULL(EndOfTheMonthCasbacksCnt		,0) AS DECIMAL(20,1))	EndOfTheMonthCasbacksCnt	,
			CAST(ISNULL(EndOfTheMonthCasbacksVol		,0) AS DECIMAL(20,1))	EndOfTheMonthCasbacksVol	,
			CAST(ISNULL(CasbackUserAttributesDailyCnt			,0) AS DECIMAL(20,1))	CasbackUserAttributesDailyCnt		
INTO #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource
FROM FACT_DailyDatabaseCardCashbackCSEntityDataSource (nolock)
WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
/*END - ADMIN_FACT_DailyDatabaseCardCashbackCSEntityDataSource*/
PRINT '35 - Completed - ADMIN_FACT_DailyDatabaseCardCashbackCSEntityDataSource' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource*/
SELECT
	    CAST(CreatedAt AS DATE) [Date]
	   ,Currency
	   ,Cnt(Id) CheckoutCnt
	   ,ABS(SUM(TxAmount)) CheckoutVol
	   ,ABS(SUM(Fee)) CheckoutFee
	   ,Cnt(	  CASE WHEN PaymentMethod = 1	THEN   Id		ELSE NULL END)	PaidWithCreditCardCnt
	   ,ABS(SUM(  CASE WHEN PaymentMethod = 1	THEN   TxAmount	ELSE NULL END))	PaidWithCreditCardVol
	   ,Cnt(DISTINCT Merchandiser_Key)															UniqueMerchandisersLastDay
	   ,Cnt(DISTINCT User_Key)																UniqueUserAttributesLastDay
INTO #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource
FROM FACT_Payments (nolock)				
WHERE (CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay) and [Status] = 1
GROUP BY CAST(CreatedAt AS DATE), Currency
/*
SELECT
	 p.[Date]
	,P.Currency
/*	,CheckoutCnt
	,CheckoutFee
	,CheckoutVol*/
	,ISNULL(PaidWithCreditCardCnt_P,0)		/*+	ISNULL(PaidWithCreditCardCnt_ML,0) */  PaidWithCreditCardCnt
	,ISNULL(PaidWithCreditCardVol_P,0)		/*+	ISNULL(PaidWithCreditCardVol_ML,0)*/  PaidWithCreditCardVol
	,UniqueMerchandisersLastDay
	,UniqueUserAttributesLastDay
INTO #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource
FROM DIM_Date (nolock) d
JOIN
		(
		
				SELECT
					    CAST(CreatedAt AS DATE) [Date]
					   ,Currency
					   ,Cnt(CASE WHEN PaymentMethod = 1 and [Status] = 1	THEN   Id		ELSE NULL END)	PaidWithCreditCardCnt_P
					   ,SUM(  CASE WHEN PaymentMethod = 1 and [Status] = 1	THEN   TxAmount	ELSE NULL END)	PaidWithCreditCardVol_P
					   ,Cnt(DISTINCT Merchandiser_Key)										UniqueMerchandisersLastDay
					   ,Cnt(DISTINCT User_Key)											UniqueUserAttributesLastDay

				FROM FACT_Payments (nolock)				
				WHERE (CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay) and SIGN(TxAmount) = 1
				GROUP BY CAST(CreatedAt AS DATE), Currency
				
		) P ON D.CreateDate = P.[Date]
JOIN
		(
				SELECT
					    CAST(CreatedAt AS DATE) [Date]
					   ,Currency
				/*	   ,Cnt(DISTINCT CASE WHEN FeatureType IN (8,26) AND IsCancellation = 0 THEN PaymentId ELSE NULL END)	CheckoutCnt
					   ,ABS(SUM(	   CASE WHEN FeatureType IN (8,26) AND IsCancellation = 0 THEN Fee	   ELSE NULL END))	CheckoutFee
					   ,SUM(		   CASE WHEN FeatureType IN (8,26) AND IsCancellation = 0 THEN TxAmount	   ELSE NULL END)	CheckoutVol*/
					   ,Cnt(		   CASE WHEN FeatureType = 26							    THEN Id		   ELSE NULL END)	PaidWithCreditCardCnt_ML
					   ,SUM(		   CASE WHEN FeatureType = 26							    THEN TxAmount    ELSE NULL END)	PaidWithCreditCardVol_ML

				FROM FACT_MerchandiserTransactions (nolock)				
				WHERE (CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay) and SIGN(TxAmount) = 1
				GROUP BY CAST(CreatedAt AS DATE), Currency				
		) mL
ON D.CreateDate = mL.[Date] AND P.Currency = ML.Currency
*/
/*END - #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource*/	
PRINT '36 - Completed - #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource'  + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #CSHARP_TO_PROD_VIEW_FACT_DailyCheckoutCSEntityDataSource*/
SELECT CAST(CreatedAt AS DATE) [Date]
		   ,CheckoutCnt
		   ,CheckoutVol
		   ,CheckoutFee
		   ,PaidWithCreditCardCnt
		   ,PaidWithCreditCardVol
		   ,UniqueMerchandisersLastDay
		   ,UniqueUserAttributesLastDay
INTO #CSHARP_TO_PROD_VIEW_FACT_DailyCheckoutCSEntityDataSource
FROM FACT_DailyCheckoutCSEntityDataSource (nolock)
WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
/*END - #CSHARP_TO_PROD_VIEW_FACT_DailyCheckoutCSEntityDataSource*/
PRINT '37 - Completed - #CSHARP_TO_PROD_VIEW_FACT_DailyCheckoutCSEntityDataSource' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))


Declare @BSMV	AS FLOAT = 0.05,	--Banka ve Sigorta Muameleleri Vergisi
		@msr	AS FLOAT = 0.15,	--Mobile_Phone_Screen_Rate
		@mfr	AS FLOAT = 0.2 ,	--Mobile_Phone_Full_Rate	
		@upr	AS FLOAT = 0.2 ,	--Urgency package Pet Insurance
		@fpr	AS FLOAT = 0.2 ,	--Full package Pet Insurance
		@tsp	AS FLOAT = 0.25,	--Travel-Health Standart Plan
		@tpp	AS FLOAT = 0.25,	--Travel-Health Premium Plan
		@hsp	AS FLOAT = 0.25,	--Home Standard Plan
		@hpp	AS FLOAT = 0.25,	--Home Premium Plan
		@hppp	AS FLOAT = 0.25		--Home Premium Plan Plus
--NOT: 3-3-23 > C# Kodları BE'de dönüştürüldü. Tutarlar artık Policies tablosundaki Premium'dan değil, Transactions ve ExternalTransactions'da TxAmount'tan hesaplanıyor.
SELECT dir1.*, TotalCashback 
INTO #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource
FROM
	(
	SELECT			
		    CAST(CreatedAt AS DATE) [Date]
		   ,CAST(ISNULL(Cnt(CASE WHEN FeatureType = 24 AND IsCancellation != 1 THEN PolicyId ELSE NULL END) - Cnt(CASE WHEN FeatureType = 24 AND IsCancellation = 1 THEN PolicyId	   ELSE NULL END) ,0) AS DECIMAL(20,2)) TotalInsuranceTx
		   ,CAST(ISNULL(SUM(  CASE WHEN FeatureType = 24																												THEN TxAmount		   ELSE NULL END) ,0) AS DECIMAL(20,2)) TotalInsurancePremiumVol
		   ,CAST(ISNULL(SUM(		   CASE WHEN ProductType = 1 AND FeatureType = 24 																				THEN TxAmount*@msr/2	
											WHEN ProductType = 2 AND FeatureType = 24 																				THEN TxAmount*@mfr/2	
											WHEN ProductType = 3 AND FeatureType = 24 																				THEN TxAmount*@upr/2
											WHEN ProductType = 4 AND FeatureType = 24 																				THEN TxAmount*@fpr/2
											WHEN ProductType = 5 AND FeatureType = 24 																				THEN TxAmount*@tsp/2
											WHEN ProductType = 6 AND FeatureType = 24 																				THEN TxAmount*@tpp/2 
											WHEN ProductType = 7 AND FeatureType = 24 																				THEN TxAmount*@hsp/2 
											WHEN ProductType = 8 AND FeatureType = 24 																				THEN TxAmount*@hpp/2 
											WHEN ProductType = 9 AND FeatureType = 24 																				THEN TxAmount*@hppp/2 ELSE NULL END) ,0) AS DECIMAL(20,2)) TotalInsuranceFee											
		   ,CAST(ISNULL(Cnt(		   CASE WHEN FeatureType = 24  AND  TransactionsId IS NOT NULL AND IsCancellation != 1				THEN PolicyId ELSE NULL END) 
					  - Cnt(		   CASE WHEN FeatureType = 24  AND  TransactionsId IS NOT NULL AND IsCancellation  = 1				THEN PolicyId ELSE NULL END) ,0) AS DECIMAL(20,2)) TotalInAppPaymentTx
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24  AND  TransactionsId IS NOT NULL										THEN TxAmount	  ELSE NULL END) ,0) AS DECIMAL(20,2)) TotalInAppPaymentVol
		   ,CAST(ISNULL(SUM(		   CASE WHEN ProductType = 1 AND FeatureType = 24												THEN (TxAmount/(1+@BSMV))*@msr 
											WHEN ProductType = 2 AND FeatureType = 24												THEN (TxAmount/(1+@BSMV))*@mfr 
											WHEN ProductType = 3 AND FeatureType = 24												THEN (TxAmount/(1+@BSMV))*@upr 
											WHEN ProductType = 4 AND FeatureType = 24												THEN (TxAmount/(1+@BSMV))*@fpr
											WHEN ProductType = 5 AND FeatureType = 24												THEN (TxAmount/(1+@BSMV))*@tsp
											WHEN ProductType = 6 AND FeatureType = 24												THEN (TxAmount/(1+@BSMV))*@tpp 
											WHEN ProductType = 7 AND FeatureType = 24												THEN (TxAmount/(1+@BSMV))*@hsp 
											WHEN ProductType = 8 AND FeatureType = 24												THEN (TxAmount/(1+@BSMV))*@hpp 
											WHEN ProductType = 9 AND FeatureType = 24												THEN (TxAmount/(1+@BSMV))*@hppp ELSE NULL END) ,0) AS DECIMAL(20,2)) TotalInsuranceTotalFee																																								 
		   ,CAST(ISNULL(Cnt(		   CASE WHEN FeatureType = 24  AND ExternalTransactionId  IS NOT NULL AND IsCancellation != 1		THEN PolicyId				  ELSE NULL END)
					  - Cnt(		   CASE WHEN FeatureType = 24  AND ExternalTransactionId  IS NOT NULL AND IsCancellation  = 1		THEN PolicyId				  ELSE NULL END) ,0) AS DECIMAL(20,2)) TotalOutAppPaymentTx
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24  AND				 		 ExternalTransactionId  IS NOT NULL		THEN TxAmount					  ELSE NULL END) ,0) AS DECIMAL(20,2)) TotalOutAppPaymentVol
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24  AND ProductType = 1	 AND ExternalTransactionId  IS NOT NULL		THEN TxAmount*@msr/2	
											WHEN FeatureType = 24  AND ProductType = 2	 AND ExternalTransactionId  IS NOT NULL		THEN TxAmount*@mfr/2		
											WHEN FeatureType = 24  AND ProductType = 3	 AND ExternalTransactionId  IS NOT NULL		THEN TxAmount*@upr/2
											WHEN FeatureType = 24  AND ProductType = 4	 AND ExternalTransactionId  IS NOT NULL		THEN TxAmount*@fpr/2
											WHEN FeatureType = 24  AND ProductType = 5	 AND ExternalTransactionId  IS NOT NULL		THEN TxAmount*@tsp/2
											WHEN FeatureType = 24  AND ProductType = 6	 AND ExternalTransactionId  IS NOT NULL		THEN TxAmount*@tpp/2			 
											WHEN FeatureType = 24  AND ProductType = 7	 AND ExternalTransactionId  IS NOT NULL		THEN TxAmount*@hsp/2
											WHEN FeatureType = 24  AND ProductType = 8	 AND ExternalTransactionId  IS NOT NULL		THEN TxAmount*@hpp/2
											WHEN FeatureType = 24  AND ProductType = 9	 AND ExternalTransactionId  IS NOT NULL		THEN TxAmount*@hppp/2			 ELSE NULL END) ,0) AS DECIMAL(20,2)) TotalOutAppPaymentFee			
		   ,CAST(ISNULL(Cnt(DISTINCT CASE WHEN FeatureType = 24																	THEN User_Key				 ELSE NULL END) ,0) AS DECIMAL(20,2)) UniqueUserTotal																		 
		   ,CAST(ISNULL(Cnt(		   CASE WHEN FeatureType = 24 AND ProductType = 2	 AND IsCancellation != 1					THEN PolicyId ELSE NULL END)
					  - Cnt(		   CASE WHEN FeatureType = 24 AND ProductType = 2	 AND IsCancellation  = 1					THEN PolicyId ELSE NULL END),0) AS DECIMAL(20,2)) MobilePhoneInsuranceTx
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND ProductType = 2																THEN TxAmount					 ELSE NULL END) ,0) AS DECIMAL(20,2)) MobilePhoneInsurancePremiumVol
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND ProductType = 1							 AND  TransactionsId		    IS NOT NULL	THEN TxAmount*@msr/2					 
											WHEN FeatureType = 24 AND ProductType = 2							 AND  TransactionsId		    IS NOT NULL	THEN TxAmount*@mfr/2					 
											WHEN FeatureType = 24 AND ProductType = 3							 AND  TransactionsId		    IS NOT NULL	THEN TxAmount*@upr/2					 
											WHEN FeatureType = 24 AND ProductType = 4							 AND  TransactionsId		    IS NOT NULL	THEN TxAmount*@fpr/2
											WHEN FeatureType = 24 AND ProductType = 5							 AND  TransactionsId		    IS NOT NULL	THEN TxAmount*@tsp/2
											WHEN FeatureType = 24 AND ProductType = 6							 AND  TransactionsId		    IS NOT NULL	THEN TxAmount*@tpp/2			 
											WHEN FeatureType = 24 AND ProductType = 7							 AND  TransactionsId		    IS NOT NULL	THEN TxAmount*@hsp/2
											WHEN FeatureType = 24 AND ProductType = 8 						 AND  TransactionsId		    IS NOT NULL	THEN TxAmount*@hpp/2
											WHEN FeatureType = 24 AND ProductType = 9							 AND  TransactionsId		    IS NOT NULL	THEN TxAmount*@hppp/2			 ELSE NULL END) ,0) AS DECIMAL(20,2)) TotalInAppPaymentFee											
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND ProductType = 2							 									THEN TxAmount*@mfr/2	 		 ELSE NULL END) ,0) AS DECIMAL(20,2)) MobilePhoneInsuranceFee
		   ,CAST(ISNULL(Cnt(		   CASE WHEN FeatureType = 24 AND ProductType = 2	 AND IsCancellation != 1 AND  TransactionsId		    IS NOT NULL	THEN PolicyId				 ELSE NULL END)
					  - Cnt(		   CASE WHEN FeatureType = 24 AND ProductType = 2	 AND IsCancellation  = 1 AND  TransactionsId		    IS NOT NULL	THEN PolicyId				 ELSE NULL END) ,0) AS DECIMAL(20,2)) MobilePhoneInAppPaymentTx
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND ProductType = 2	 AND						  TransactionsId		    IS NOT NULL	THEN TxAmount					 ELSE NULL END) ,0) AS DECIMAL(20,2)) MobilePhoneInAppPaymentVol
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND ProductType = 2	 AND						  TransactionsId		    IS NOT NULL	THEN TxAmount*@mfr/2			 ELSE NULL END) ,0) AS DECIMAL(20,2)) MobilePhoneInAppPaymentFee
		   ,CAST(ISNULL(Cnt(		   CASE WHEN FeatureType = 24 AND ProductType = 2	 AND IsCancellation != 1 AND  ExternalTransactionId  IS NOT NULL	THEN PolicyId				 ELSE NULL END)
					  - Cnt(		   CASE WHEN FeatureType = 24 AND ProductType = 2	 AND IsCancellation  = 1 AND  ExternalTransactionId  IS NOT NULL	THEN PolicyId				 ELSE NULL END) ,0) AS DECIMAL(20,2)) MobilePhoneOutAppPaymentTx
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND ProductType = 2	 AND						  ExternalTransactionId  IS NOT NULL	THEN TxAmount					 ELSE NULL END) ,0) AS DECIMAL(20,2)) MobilePhoneOutAppPaymentVol
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND ProductType = 2	 AND						  ExternalTransactionId  IS NOT NULL	THEN TxAmount*@mfr/2			 ELSE NULL END) ,0) AS DECIMAL(20,2)) MobilePhoneOutAppPaymentFee
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND ProductType = 2	 						 									THEN (TxAmount/(1+@BSMV))*@mfr ELSE NULL END) ,0) AS DECIMAL(20,2)) MobilePhoneInsuranceTotalFee
		   ,CAST(ISNULL(Cnt(DISTINCT CASE WHEN FeatureType = 24 AND ProductType = 2	 						 									THEN User_Key				 ELSE NULL END) ,0) AS DECIMAL(20,2)) UniqueUserMobilePhoneInsurance
		   ,CAST(ISNULL(Cnt(		   CASE WHEN FeatureType = 24 AND ProductType = 1 AND IsCancellation != 1  									THEN PolicyId				 ELSE NULL END)
					  - Cnt(		   CASE WHEN FeatureType = 24 AND ProductType = 1 AND IsCancellation  = 1  									THEN PolicyId				 ELSE NULL END),0) AS DECIMAL(20,2))  MobilePhoneScreenInsuranceTx
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND ProductType = 1	 						 									THEN TxAmount*@msr/2			 ELSE NULL END),0) AS DECIMAL(20,2))  MobilePhoneScreenInsuranceFee
		   ,CAST(ISNULL(Cnt(		   CASE WHEN FeatureType = 24 AND ProductType = 1	 AND IsCancellation != 1 AND  TransactionsId		    IS NOT NULL	THEN PolicyId				 ELSE NULL END)
					  - Cnt(		   CASE WHEN FeatureType = 24 AND ProductType = 1	 AND IsCancellation  = 1 AND  TransactionsId		    IS NOT NULL	THEN PolicyId				 ELSE NULL END),0) AS DECIMAL(20,2))  MobilePhoneScreenInAppPaymentTx
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND ProductType = 1	 AND						  TransactionsId		    IS NOT NULL	THEN TxAmount					 ELSE NULL END) ,0) AS DECIMAL(20,2)) MobilePhoneScreenInAppPaymentVol
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND ProductType = 1	 AND						  TransactionsId		    IS NOT NULL	THEN TxAmount*@msr/2			 ELSE NULL END) ,0) AS DECIMAL(20,2)) MobilePhoneScreenInAppPaymentFee
		   ,CAST(ISNULL(Cnt(		   CASE WHEN FeatureType = 24 AND ProductType = 1	 AND						  ExternalTransactionId  IS NOT NULL	THEN PolicyId				 ELSE NULL END) ,0) AS DECIMAL(20,2)) MobilePhoneScreenOutAppPaymentTx
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND ProductType = 1							 AND  ExternalTransactionId  IS NOT NULL	THEN TxAmount					 ELSE NULL END) ,0) AS DECIMAL(20,2)) MobilePhoneScreenOutAppPaymentVol
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND ProductType = 1							 AND  ExternalTransactionId  IS NOT NULL	THEN TxAmount*@msr/2			 ELSE NULL END) ,0) AS DECIMAL(20,2)) MobilePhoneScreenOutAppPaymentFee
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND ProductType = 1		  														THEN (TxAmount/(1+@BSMV))*@msr ELSE NULL END) ,0) AS DECIMAL(20,2)) MobilePhoneScreenInsuranceTotalFee
		   ,CAST(ISNULL(Cnt(DISTINCT CASE WHEN FeatureType = 24 AND ProductType = 1							 									THEN User_Key				 ELSE NULL END) ,0) AS DECIMAL(20,2)) UniqueUserMobilePhoneScreenInsurance
		   ,CAST(ISNULL(Cnt(		   CASE WHEN FeatureType = 24 AND BranchType  = 7	 AND IsCancellation != 1  							 		THEN PolicyId				 ELSE NULL END)
					  - Cnt(		   CASE WHEN FeatureType = 24 AND BranchType  = 7	 AND IsCancellation  = 1  							 		THEN PolicyId				 ELSE NULL END),0) AS DECIMAL(20,2))  PetInsuranceTx
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND BranchType  = 7							 							 		THEN TxAmount					 ELSE NULL END),0) AS DECIMAL(20,2)) PetInsurancePremiumVol
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND BranchType  = 7	 AND ProductType = 3  										THEN TxAmount*@upr/2
											WHEN FeatureType = 24 AND BranchType  = 7	 AND ProductType = 4  										THEN TxAmount*@fpr/2			 ELSE NULL END) ,0) AS DECIMAL(20,2)) PetInsuranceFee
		   ,CAST(ISNULL(Cnt(		   CASE WHEN FeatureType = 24 AND BranchType  = 7	 AND IsCancellation != 1 AND  TransactionsId		    IS NOT NULL	THEN PolicyId				 ELSE NULL END)
					  - Cnt(		   CASE WHEN FeatureType = 24 AND BranchType  = 7	 AND IsCancellation  = 1 AND  TransactionsId		    IS NOT NULL	THEN PolicyId				 ELSE NULL END) ,0) AS DECIMAL(20,2)) PetInsuranceInAppPaymentTx
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND BranchType  = 7	 AND						  TransactionsId		    IS NOT NULL	THEN TxAmount					 ELSE NULL END) ,0) AS DECIMAL(20,2)) PetInsuranceInAppPaymentVol
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND BranchType  = 7	 AND ProductType = 3	 AND  TransactionsId		    IS NOT NULL	THEN TxAmount*@upr/2  
											WHEN FeatureType = 24 AND BranchType  = 7	 AND ProductType = 4	 AND  TransactionsId		    IS NOT NULL	THEN TxAmount*@fpr/2			 ELSE NULL END) ,0) AS DECIMAL(20,2)) PetInsuranceInAppPaymentFee
		   ,CAST(ISNULL(Cnt(		   CASE WHEN FeatureType = 24 AND BranchType  = 7	 AND IsCancellation != 1 AND  ExternalTransactionId  IS NOT NULL	THEN PolicyId				 ELSE NULL END)
					  - Cnt(		   CASE WHEN FeatureType = 24 AND BranchType  = 7	 AND IsCancellation  = 1 AND  ExternalTransactionId  IS NOT NULL	THEN PolicyId				 ELSE NULL END) ,0) AS DECIMAL(20,2)) PetInsuranceOutAppPaymentTx
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND BranchType  = 7							 AND  ExternalTransactionId  IS NOT NULL	THEN TxAmount					 ELSE NULL END) ,0) AS DECIMAL(20,2)) PetInsuranceOutAppPaymentVol																																														  
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND BranchType  = 7	 AND ProductType = 3	 AND  ExternalTransactionId  IS NOT NULL	THEN TxAmount*@upr/2	  
										    WHEN FeatureType = 24 AND BranchType  = 7	 AND ProductType = 4	 AND  ExternalTransactionId  IS NOT NULL	THEN TxAmount*@fpr/2			 ELSE NULL END) ,0) AS DECIMAL(20,2)) PetInsuranceOutAppPaymentFee																																																							  
		   ,CAST(ISNULL(Cnt(DISTINCT CASE WHEN FeatureType = 24 AND BranchType  = 7	/* AND IsCancellation != 1*/								THEN User_Key				 ELSE NULL END) ,0) AS DECIMAL(20,2)) UniqueUserPetInsurance
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND BranchType  = 7																THEN (TxAmount/(1+@BSMV))*@fpr ELSE NULL END) ,0) AS DECIMAL(20,2)) PetInsurancePaymentTotalFee
		   --HOME INSURANCE
		   ,CAST(ISNULL(Cnt(		   CASE WHEN FeatureType = 24 AND BranchType  = 10 AND IsCancellation != 1  							 		THEN PolicyId				 ELSE NULL END)
					  - Cnt(		   CASE WHEN FeatureType = 24 AND BranchType  = 10 AND IsCancellation  = 1  							 		THEN PolicyId				 ELSE NULL END) ,0) AS DECIMAL(20,2)) HomeInsuranceTx
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND BranchType  = 10						 							 		THEN TxAmount					 ELSE NULL END) ,0) AS DECIMAL(20,2)) HomeInsurancePremiumVol
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND BranchType  = 10 AND ProductType = 7  										THEN TxAmount*@hsp/2
											WHEN FeatureType = 24 AND BranchType  = 10 AND ProductType = 8  										THEN TxAmount*@hpp/2
											WHEN FeatureType = 24 AND BranchType  = 10 AND ProductType = 9  										THEN TxAmount*@hppp/2			 ELSE NULL END) ,0) AS DECIMAL(20,2)) HomeInsuranceFee
		   ,CAST(ISNULL(Cnt(		   CASE WHEN FeatureType = 24 AND BranchType  = 10 AND IsCancellation != 1 AND  TransactionsId		    IS NOT NULL	THEN PolicyId				 ELSE NULL END)
					  - Cnt(		   CASE WHEN FeatureType = 24 AND BranchType  = 10 AND IsCancellation  = 1 AND  TransactionsId		    IS NOT NULL	THEN PolicyId				 ELSE NULL END) ,0) AS DECIMAL(20,2)) HomeInsuranceInAppPaymentTx
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND BranchType  = 10 AND						  TransactionsId		    IS NOT NULL	THEN TxAmount					 ELSE NULL END) ,0) AS DECIMAL(20,2)) HomeInsuranceInAppPaymentVol
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND BranchType  = 10 AND ProductType = 7	 AND  TransactionsId		    IS NOT NULL	THEN TxAmount*@hsp/2  
											WHEN FeatureType = 24 AND BranchType  = 10 AND ProductType = 8	 AND  TransactionsId		    IS NOT NULL	THEN TxAmount*@hpp/2
											WHEN FeatureType = 24 AND BranchType  = 10 AND ProductType = 9	 AND  TransactionsId		    IS NOT NULL	THEN TxAmount*@hppp/2			 ELSE NULL END) ,0) AS DECIMAL(20,2)) HomeInsuranceInAppPaymentFee
		   ,CAST(ISNULL(Cnt(		   CASE WHEN FeatureType = 24 AND BranchType  = 10 AND IsCancellation != 1 AND  ExternalTransactionId  IS NOT NULL	THEN PolicyId				 ELSE NULL END)
					  - Cnt(		   CASE WHEN FeatureType = 24 AND BranchType  = 10 AND IsCancellation  = 1 AND  ExternalTransactionId  IS NOT NULL	THEN PolicyId				 ELSE NULL END) ,0) AS DECIMAL(20,2)) HomeInsuranceOutAppPaymentTx
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND BranchType  = 10						 AND  ExternalTransactionId  IS NOT NULL	THEN TxAmount					 ELSE NULL END) ,0) AS DECIMAL(20,2)) HomeInsuranceOutAppPaymentVol																																														  
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND BranchType  = 10 AND ProductType = 7	 AND  ExternalTransactionId  IS NOT NULL	THEN TxAmount*@hsp/2 	  
										    WHEN FeatureType = 24 AND BranchType  = 10 AND ProductType = 8	 AND  ExternalTransactionId  IS NOT NULL	THEN TxAmount*@hpp/2			 
											WHEN FeatureType = 24 AND BranchType  = 10 AND ProductType = 9	 AND  ExternalTransactionId  IS NOT NULL	THEN TxAmount*@hppp/2			 ELSE NULL END) ,0) AS DECIMAL(20,2)) HomeInsuranceOutAppPaymentFee																																																							  
		   ,CAST(ISNULL(Cnt(DISTINCT CASE WHEN FeatureType = 24 AND BranchType  = 10 AND IsCancellation != 1									THEN User_Key				 ELSE NULL END) ,0) AS DECIMAL(20,2)) UniqueUserHomeInsurance
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND BranchType  = 10															THEN (TxAmount/(1+@BSMV))*@hpp ELSE NULL END) ,0) AS DECIMAL(20,2)) HomeInsurancePaymentTotalFee
		   --,CAST(ISNULL(SUM(		   CASE WHEN 																				THEN P.Id					 ELSE NULL END) ,0) AS DECIMAL(20,2)) TotalCanceledInsuranceTx
		   --,CAST(ISNULL(SUM(		   CASE WHEN 																				THEN P.Premium				 ELSE NULL END) ,0) AS DECIMAL(20,2)) TotalCanceledInsurancePremiumVol
		   --,CAST(ISNULL(SUM(		   CASE WHEN P.ProductId = 1																THEN p.Premium*@msr/2		 
					--						WHEN P.ProductId = 2																THEN p.Premium*@mfr/2		 
					--						WHEN P.ProductId = 3																THEN p.Premium*@upr/2		 
					--						WHEN P.ProductId = 4																THEN p.Premium*@fpr/2		 ELSE NULL END) ,0) AS DECIMAL(20,2)) TotalCanceledInsuranceFee	
		   ,CAST(ISNULL(Cnt(		   CASE WHEN FeatureType = 24 AND BranchType  = 2	 AND IsCancellation != 1	 								THEN PolicyId				 ELSE NULL END)
					  - Cnt(		   CASE WHEN FeatureType = 24 AND BranchType  = 2	 AND IsCancellation  = 1	 								THEN PolicyId				 ELSE NULL END) ,0) AS DECIMAL(20,2)) TravelHealthInsuranceTx
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND BranchType  = 2  	 							 							THEN TxAmount					 ELSE NULL END) ,0) AS DECIMAL(20,2)) TravelHealthInsurancePremiumVol
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND BranchType  = 2	 AND ProductType = 5  										THEN TxAmount*@tsp/2
											WHEN FeatureType = 24 AND BranchType  = 2	 AND ProductType = 6  										THEN TxAmount*@tpp/2			 ELSE NULL END) ,0) AS DECIMAL(20,2)) TravelHealthInsuranceFee
		   ,CAST(ISNULL(Cnt(		   CASE WHEN FeatureType = 24 AND BranchType  = 2	 AND IsCancellation != 1 AND  TransactionsId		    IS NOT NULL	THEN PolicyId				 ELSE NULL END)
					  - Cnt(		   CASE WHEN FeatureType = 24 AND BranchType  = 2	 AND IsCancellation  = 1 AND  TransactionsId		    IS NOT NULL	THEN PolicyId				 ELSE NULL END) ,0) AS DECIMAL(20,2)) TravelHealthInsuranceInAppPaymentTx
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND BranchType  = 2							 AND  TransactionsId		    IS NOT NULL	THEN TxAmount					 ELSE NULL END) ,0) AS DECIMAL(20,2)) TravelHealthInsuranceInAppPaymentVol
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND BranchType  = 2	 AND ProductType = 5	 AND  TransactionsId			IS NOT NULL	THEN TxAmount*@tsp/2  
											WHEN FeatureType = 24 AND BranchType  = 2	 AND ProductType = 6	 AND  TransactionsId			IS NOT NULL	THEN TxAmount*@tpp/2			 ELSE NULL END) ,0) AS DECIMAL(20,2)) TravelHealthInsuranceInAppPaymentFee
		   ,CAST(ISNULL(Cnt(		   CASE WHEN FeatureType = 24 AND BranchType  = 2	 AND IsCancellation != 1 AND  ExternalTransactionId  IS NOT NULL	THEN PolicyId				 ELSE NULL END)
					  - Cnt(		   CASE WHEN FeatureType = 24 AND BranchType  = 2	 AND IsCancellation  = 1 AND  ExternalTransactionId  IS NOT NULL	THEN PolicyId				 ELSE NULL END) ,0) AS DECIMAL(20,2)) TravelHealthInsuranceOutAppPaymentTx
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND BranchType  = 2							 AND  ExternalTransactionId  IS NOT NULL	THEN TxAmount					 ELSE NULL END) ,0) AS DECIMAL(20,2)) TravelHealthInsuranceOutAppPaymentVol																																														  
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND BranchType  = 2	 AND ProductType = 5	 AND  ExternalTransactionId  IS NOT NULL	THEN TxAmount*@tsp/2	  
										    WHEN FeatureType = 24 AND BranchType  = 2	 AND ProductType = 6	 AND  ExternalTransactionId  IS NOT NULL	THEN TxAmount*@tpp/2			 ELSE NULL END) ,0) AS DECIMAL(20,2)) TravelHealthInsuranceOutAppPaymentFee																																																							  
		   ,CAST(ISNULL(SUM(		   CASE WHEN FeatureType = 24 AND BranchType  = 2	 															THEN (TxAmount/(1+@BSMV))*@tpp ELSE NULL END) ,0) AS DECIMAL(20,2)) TravelHealthInsurancePaymentTotalFee
	  FROM 
		(																													
				SELECT l.CreatedAt,fip.TransactionsId,fip.ExternalTransactionId,fip.PolicyId,fip.BranchType,fip.ProductType, l.User_Key, l.TxAmount * -1 TxAmount,  l.FeatureType,  l.IsCancellation
				FROM  FACT_Transactions (nolock) l 
				JOIN FACT_InsurancePolicies (nolock) fip on l.TransactionId = fip.TransactionId
				WHERE   l.CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND  l.CreatedAt < @BaseDay  and l.FeatureType = 24 and Fip.BranchType IN (1,2,7,10)
		 UNION
				SELECT el.CreatedAt,fip.TransactionsId,fip.ExternalTransactionId,fip.PolicyId,fip.BranchType,fip.ProductType,el.User_Key,el.TxAmount * -1 TxAmount, el.FeatureType, el.IsCancellation
				FROM FACT_ExternalTransactions (nolock) el  
				JOIN FACT_InsurancePolicies (nolock) fip  on el.TransactionId = fip.TransactionId
				WHERE  el.CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND el.CreatedAt < @BaseDay and el.FeatureType = 24 and Fip.BranchType IN (1,2,7,10)
		) UnitedTransactionsAndExternalTransactions
	  GROUP BY CAST(CreatedAt AS DATE)
	) dir1
	JOIN DIM_Date (nolock) d ON d.CreateDate = dir1.[Date]
	LEFT JOIN
			(
			SELECT
				 CAST(l.CreatedAt AS DATE) [Date]
				,CAST(ISNULL(SUM(CASE WHEN L.FeatureType = 15 THEN l.TxAmount  ELSE NULL END) ,0) AS DECIMAL(20,2)) TotalCashback
			FROM FACT_Transactions		(nolock) l 
			JOIN FACT_InsurancePolicies (nolock) fip2	 on l.TransactionId = fip2.TransactionId AND IsCancellation != 1 AND l.CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND l.CreatedAt < @BaseDay --l.CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND l.CreatedAt < @BaseDay
			WHERE fip2.BranchType IN (1,2,7,10)
			GROUP BY CAST(l.CreatedAt AS DATE)
			) LI 
	ON d.CreateDate = LI.[Date]

/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource*/	
PRINT '38 - Completed - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource'		   + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))
/*BEGIN - #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource*/			
/*Manuel karşılaştırma için Admin Raporu */
	SELECT	 CAST(CreatedAt AS DATE) [Date]
			,CAST(TotalInsuranceTx						AS DECIMAL(20,2))	TotalInsuranceTx					
			,CAST(TotalInsurancePremiumVol			AS DECIMAL(20,2))	TotalInsurancePremiumVol	
			,CAST(TotalInsuranceFee						AS DECIMAL(20,2))	TotalInsuranceFee					
			,CAST(TotalInAppPaymentTx					AS DECIMAL(20,2))	TotalInAppPaymentTx
			,CAST(TotalInAppPaymentVol				AS DECIMAL(20,2))	TotalInAppPaymentVol	
			,CAST(TotalInsuranceTotalFee				AS DECIMAL(20,2))	TotalInsuranceTotalFee
			,CAST(TotalOutAppPaymentTx					AS DECIMAL(20,2))	TotalOutAppPaymentTx		
			,CAST(TotalOutAppPaymentVol				AS DECIMAL(20,2))	TotalOutAppPaymentVol
			,CAST(TotalOutAppPaymentFee					AS DECIMAL(20,2))	TotalOutAppPaymentFee	
			,CAST(UniqueUserTotal						AS DECIMAL(20,2))	UniqueUserTotal					
			,CAST(MobilePhoneInsuranceTx				AS DECIMAL(20,2))	MobilePhoneInsuranceTx				
			,CAST(MobilePhoneInsurancePremiumVol		AS DECIMAL(20,2))	MobilePhoneInsurancePremiumVol	
			,CAST(TotalInAppPaymentFee					AS DECIMAL(20,2))	TotalInAppPaymentFee					
			,CAST(MobilePhoneInsuranceFee				AS DECIMAL(20,2))	MobilePhoneInsuranceFee			
			,CAST(MobilePhoneInAppPaymentTx				AS DECIMAL(20,2))	MobilePhoneInAppPaymentTx				
			,CAST(MobilePhoneInAppPaymentVol			AS DECIMAL(20,2))	MobilePhoneInAppPaymentVol			
			,CAST(MobilePhoneInAppPaymentFee			AS DECIMAL(20,2))	MobilePhoneInAppPaymentFee			
			,CAST(MobilePhoneOutAppPaymentTx			AS DECIMAL(20,2))	MobilePhoneOutAppPaymentTx			
			,CAST(MobilePhoneOutAppPaymentVol		AS DECIMAL(20,2))	MobilePhoneOutAppPaymentVol		
			,CAST(MobilePhoneOutAppPaymentFee			AS DECIMAL(20,2))	MobilePhoneOutAppPaymentFee		
			,CAST(MobilePhoneInsuranceTotalFee			AS DECIMAL(20,2))	MobilePhoneInsuranceTotalFee
			,CAST(UniqueUserMobilePhoneInsurance		AS DECIMAL(20,2))	UniqueUserMobilePhoneInsurance
			,CAST(MobilePhoneScreenInsuranceTx			AS DECIMAL(20,2))	MobilePhoneScreenInsuranceTx
			,CAST(MobilePhoneScreenInsuranceFee			AS DECIMAL(20,2))	MobilePhoneScreenInsuranceFee
			,CAST(MobilePhoneScreenInAppPaymentTx		AS DECIMAL(20,2))	MobilePhoneScreenInAppPaymentTx	
			,CAST(MobilePhoneScreenInAppPaymentVol	AS DECIMAL(20,2))	MobilePhoneScreenInAppPaymentVol
			,CAST(MobilePhoneScreenInAppPaymentFee		AS DECIMAL(20,2))	MobilePhoneScreenInAppPaymentFee		
			,CAST(MobilePhoneScreenOutAppPaymentTx		AS DECIMAL(20,2))	MobilePhoneScreenOutAppPaymentTx		
			,CAST(MobilePhoneScreenOutAppPaymentVol	AS DECIMAL(20,2))	MobilePhoneScreenOutAppPaymentVol	
			,CAST(MobilePhoneScreenOutAppPaymentFee		AS DECIMAL(20,2))	MobilePhoneScreenOutAppPaymentFee		
			,CAST(MobilePhoneScreenInsuranceTotalFee	AS DECIMAL(20,2))	MobilePhoneScreenInsuranceTotalFee	
			,CAST(UniqueUserMobilePhoneScreenInsurance	AS DECIMAL(20,2))	UniqueUserMobilePhoneScreenInsurance
			,CAST(PetInsuranceTx						AS DECIMAL(20,2))	PetInsuranceTx			
			,CAST(PetInsurancePremiumVol				AS DECIMAL(20,2))	PetInsurancePremiumVol	
			,CAST(PetInsuranceFee						AS DECIMAL(20,2))	PetInsuranceFee			
			,CAST(PetInsuranceInAppPaymentTx			AS DECIMAL(20,2))	PetInsuranceInAppPaymentTx	
			,CAST(PetInsuranceInAppPaymentVol		AS DECIMAL(20,2))	PetInsuranceInAppPaymentVol
			,CAST(PetInsuranceInAppPaymentFee			AS DECIMAL(20,2))	PetInsuranceInAppPaymentFee	
			,CAST(PetInsuranceOutAppPaymentTx			AS DECIMAL(20,2))	PetInsuranceOutAppPaymentTx	
			,CAST(PetInsuranceOutAppPaymentVol		AS DECIMAL(20,2))	PetInsuranceOutAppPaymentVol
			,CAST(PetInsuranceOutAppPaymentFee			AS DECIMAL(20,2))	PetInsuranceOutAppPaymentFee	
			,CAST(UniqueUserPetInsurance				AS DECIMAL(20,2))	UniqueUserPetInsurance	
			,CAST(PetInsurancePaymentTotalFee			AS DECIMAL(20,2))	PetInsurancePaymentTotalFee
			--,CAST(TotalCanceledInsuranceTx				AS DECIMAL(20,2)) TotalCanceledInsuranceTx
			--,CAST(TotalCanceledInsurancePremiumVol		AS DECIMAL(20,2)) TotalCanceledInsurancePremiumVol
			--,CAST(TotalCanceledInsuranceFee				AS DECIMAL(20,2)) TotalCanceledInsuranceFee
			,CAST(TravelHealthInsuranceTx				    AS DECIMAL(20,2)) TravelHealthInsuranceTx
			,CAST(TravelHealthInsurancePremiumVol	    AS DECIMAL(20,2)) TravelHealthInsurancePremiumVol	  
			,CAST(TravelHealthInsuranceFee				    AS DECIMAL(20,2)) TravelHealthInsuranceFee				  
			,CAST(TravelHealthInsuranceInAppPaymentTx	    AS DECIMAL(20,2)) TravelHealthInsuranceInAppPaymentTx	  
			,CAST(TravelHealthInsuranceInAppPaymentVol   AS DECIMAL(20,2)) TravelHealthInsuranceInAppPaymentVol 
			,CAST(TravelHealthInsuranceInAppPaymentFee	    AS DECIMAL(20,2)) TravelHealthInsuranceInAppPaymentFee	  
			,CAST(TravelHealthInsuranceOutAppPaymentTx	    AS DECIMAL(20,2)) TravelHealthInsuranceOutAppPaymentTx	  
			,CAST(TravelHealthInsuranceOutAppPaymentVol  AS DECIMAL(20,2)) TravelHealthInsuranceOutAppPaymentVol
			,CAST(TravelHealthInsuranceOutAppPaymentFee	    AS DECIMAL(20,2)) TravelHealthInsuranceOutAppPaymentFee	  
			,CAST(TravelHealthInsurancePaymentTotalFee	    AS DECIMAL(20,2)) TravelHealthInsurancePaymentTotalFee
			,CAST(HomeInsuranceTx							AS DECIMAL(20,2))										HomeInsuranceTx
			,CAST(HomeInsurancePremiumVol				AS DECIMAL(20,2))										HomeInsurancePremiumVol	  
			,CAST(HomeInsuranceFee							AS DECIMAL(20,2))										HomeInsuranceFee				  
			,CAST(HomeInsuranceInAppPaymentTx				AS DECIMAL(20,2))										HomeInsuranceInAppPaymentTx	  
			,CAST(HomeInsuranceInAppPaymentVol			AS DECIMAL(20,2))										HomeInsuranceInAppPaymentVol 
			,CAST(HomeInsuranceInAppPaymentFee				AS DECIMAL(20,2))										HomeInsuranceInAppPaymentFee	  
			,CAST(HomeInsuranceOutAppPaymentTx				AS DECIMAL(20,2))										HomeInsuranceOutAppPaymentTx	  
			,CAST(HomeInsuranceOutAppPaymentVol			AS DECIMAL(20,2))										HomeInsuranceOutAppPaymentVol
			,CAST(HomeInsuranceOutAppPaymentFee				AS DECIMAL(20,2))										HomeInsuranceOutAppPaymentFee	  
			,CAST(HomeInsurancePaymentTotalFee				AS DECIMAL(20,2))										HomeInsurancePaymentTotalFee
			,CAST(TotalCashback								AS DECIMAL(20,2)) TotalCashback

INTO #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource
	FROM FACT_DailyInsuranceCSEntityDataSource (nolock) 
	WHERE CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND CreatedAt < @BaseDay
/*END - #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource*/
PRINT '39 - Completed - #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource'						+ ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #BI_TransactionsSuperiorityIncompleteDataTest - FACT_Transactions Superior to FACT_Transactions_Details*/
SELECT
	 CAST(l.CreatedAt AS DATE) [Date]
	,l.Currency
	,Cnt( l.Id) TransactionsSuperiorityIdCnt --ADMIN
	,Cnt(ld.Id) TransactionsSuperiorityDetailsIdCnt --BI
INTO #BI_TransactionsSuperiorityIncompleteDataTest
FROM FACT_Transactions 			  (Nolock) l
LEFT JOIN FACT_Transactions_Details (Nolock) ld on l.Id = ld.Id
WHERE L.CreatedAt >= DATEADD(DAY,-@d,@BaseDay) AND L.CreatedAt < @BaseDay
GROUP BY CAST(l.CreatedAt AS DATE), l.Currency
/*END - #BI_TransactionsSuperiorityIncompleteDataTest - FACT_Transactions Superior to FACT_Transactions_Details*/
PRINT '40-A1 (INTERIOR TEST) - Completed - #BI_TransactionsSuperiorityIncompleteDataTest' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #BI_UserAttributesSuperiorityIncompleteDataTest - DIM_UserAttributes Superior to DIM_UserAttributes_Details*/
SELECT
	 CAST(MAX(u.CreatedAt) AS DATE) [Date]
	,Cnt( u.Id) UserAttributesSuperiorityIdCnt --ADMIN
	,Cnt(ud.Id) UserAttributesSuperiorityDetailsIdCnt --BI
	,Cnt( u.User_Key) UserAttributesSuperiorityUser_KeyCnt --ADMIN
	,Cnt(ud.User_Key) UserAttributesSuperiorityDetailsUser_KeyCnt --BI
INTO #BI_UserAttributesSuperiorityIncompleteDataTest
FROM DIM_UserAttributes 				(Nolock) u
LEFT JOIN DIM_UserAttributes_Details (Nolock) ud on u.Id = ud.Id
WHERE  u.CreatedAt < @BaseDay
/*END - #BI_UserAttributesSuperiorityIncompleteDataTest - DIM_UserAttributes Superior to DIM_UserAttributes_Details*/
PRINT '40-A2 (INTERIOR TEST) - Completed - #BI_UserAttributesSuperiorityIncompleteDataTest' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*BEGIN - #BI_DatabaseCardsSuperiorityIncompleteDataTest - DIM_DatabaseCards Superior to DIM_DatabaseCards_Details*/
SELECT
	 CAST(MAX(pc.CreatedAt) AS DATE) [Date]
	,Cnt(pc.Id)		 DatabaseCardSuperiorityIdCnt 			--ADMIN
	,Cnt(pcd.Id)		 DatabaseCardSuperiorityDetailsIdCnt	--BI
	,Cnt(pc.User_Key)  DatabaseCardSuperiorityUser_KeyCnt 		--ADMIN
	,Cnt(pcd.UserId)	 DatabaseCardSuperiorityDetailsUserIdCnt--BI

INTO #BI_DatabaseCardSuperiorityIncompleteDataTest
FROM DIM_DatabaseCards 			  (Nolock) pc
LEFT JOIN DIM_DatabaseCards_Details (Nolock) pcd on pc.Id = pcd.Id
WHERE  pc.CreatedAt < @BaseDay
/*END - #BI_DatabaseCardsSuperiorityIncompleteDataTest - DIM_DatabaseCards Superior to DIM_DatabaseCards_Details*/
PRINT '41-A3 (INTERIOR TEST) - Completed - #BI_DatabaseCardsSuperiorityIncompleteDataTest' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))

/*UNION ALL BÖLÜMÜ*/

INSERT INTO DWH_Database.dbo.[FACT_ProdToDWHCompatibilityTestViaCSEntities]

/*BU KISIMDA TÜM HESAPLAMALAR YAPILABILIR*/
SELECT 
		StreamDate,
		GETDATE()																																		TestDateTime,
        TestType,
        BasedReportTable,
        BasedReportTableField,
        Tested_DWH_Table,
        Tested_DWH_Table_Field,
		CASE WHEN Currency = 0 THEN 'TRY'
			 WHEN Currency = 1 THEN 'USD'
			 WHEN Currency = 2 THEN 'EUR'
			 WHEN Currency = 3 THEN 'BTC'
			 WHEN Currency = 4 THEN 'GBP'
							   ELSE 'N/A' END																											Currency,
        Value1,
		Formula,
        MetricExplanation,
        CSHARP_TO_PROD_VIEW,
        PROD_TO_DWH_VIEW,																	   
	  	CSHARP_TO_PROD_VIEW - PROD_TO_DWH_VIEW																															[Difference],
		CASE WHEN CAST(CSHARP_TO_PROD_VIEW AS INT) = CAST(PROD_TO_DWH_VIEW AS INT)  THEN 'COMPATIBLE'  ELSE 'INCOMPATIBLE'	END											Compatibility,
		CASE WHEN CAST(CSHARP_TO_PROD_VIEW AS INT) = CAST(PROD_TO_DWH_VIEW AS INT)  THEN 1			 ELSE 0					END											IsCompatible,
		IsWarningField,
		CASE WHEN CAST(CSHARP_TO_PROD_VIEW AS INT) > CAST(PROD_TO_DWH_VIEW AS INT)  THEN 'CSHARP_TO_PROD_VIEW > PROD_TO_DWH_VIEW'
			 WHEN CAST(CSHARP_TO_PROD_VIEW AS INT) < CAST(PROD_TO_DWH_VIEW AS INT)  THEN 'CSHARP_TO_PROD_VIEW < PROD_TO_DWH_VIEW'
																  ELSE 'CSHARP_TO_PROD_VIEW = PROD_TO_DWH_VIEW' END														Superiority,
		CASE WHEN CSHARP_TO_PROD_VIEW  >= PROD_TO_DWH_VIEW THEN 1-abs(COALESCE((ABS(CSHARP_TO_PROD_VIEW - PROD_TO_DWH_VIEW))*1.000/(NULLIF(ABS(CSHARP_TO_PROD_VIEW), 0)), 0))*1.000 ELSE -1 END		Accuracy,
		0																																				IsResolved
FROM
	(
	/*SCRIPTS*/
			/*BEGIN-FACT_DailyMassPaymentCSEntityDataSource MassPaymentCnt*/
				  SELECT 
						bdmpr.[Date]																													StreamDate,
						'Tx.#'																															TestType,
						'FACT_DailyMassPaymentCSEntityDataSource'																									BasedReportTable,
						'MassPaymentCnt'																												BasedReportTableField,
						'FACT_MerchandiserTransactions'																											Tested_DWH_Table,
						'FeatureType;Id'																													Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'Cnt(CASE WHEN FeatureType = 9 THEN Id ELSE NULL END)'																			Formula,
						'Daily Mass Payment Cnt'																										MetricExplanation,
						admpr.MassPaymentCnt																											CSHARP_TO_PROD_VIEW,
						bdmpr.MassPaymentCnt																											PROD_TO_DWH_VIEW
						,1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyMassPaymentCSEntityDataSource bdmpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyMassPaymentCSEntityDataSource admpr on bdmpr.[Date] = admpr.[Date]
			/*END-FACT_DailyMassPaymentCSEntityDataSource MassPaymentCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyMassPaymentCSEntityDataSource MassPaymentFee*/
				  SELECT 
						bdmpr.[Date]																													StreamDate,
						'V.'																															TestType,
						'FACT_DailyMassPaymentCSEntityDataSource'																									BasedReportTable,
						'MassPaymentFee'																												BasedReportTableField,
						'FACT_MerchandiserTransactions'																											Tested_DWH_Table,
						'FeatureType;Fee'																													Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'SUM(CASE WHEN FeatureType = 9 THEN Fee ELSE NULL END)'																			Formula,
						'Daily Mass Payment Fee'																										MetricExplanation,
						admpr.MassPaymentFee																											CSHARP_TO_PROD_VIEW,
						bdmpr.MassPaymentFee																											PROD_TO_DWH_VIEW
						,1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyMassPaymentCSEntityDataSource bdmpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyMassPaymentCSEntityDataSource admpr on bdmpr.[Date] = admpr.[Date]
			/*END-FACT_DailyMassPaymentCSEntityDataSource MassPaymentFee*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyMassPaymentCSEntityDataSource MassPaymentVol*/
				  SELECT 
						bdmpr.[Date]																													StreamDate,
						'V.'																															TestType,
						'FACT_DailyMassPaymentCSEntityDataSource'																									BasedReportTable,
						'MassPaymentVol'																												BasedReportTableField,
						'FACT_MerchandiserTransactions'																											Tested_DWH_Table,
						'FeatureType;TxAmount'																												Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'SUM(CASE WHEN FeatureType = 9 THEN TxAmount ELSE NULL END)'																		Formula,
						'Daily Mass Payment Vol'																										MetricExplanation,
						admpr.MassPaymentVol																											CSHARP_TO_PROD_VIEW,
						bdmpr.MassPaymentVol																											PROD_TO_DWH_VIEW
						,1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyMassPaymentCSEntityDataSource bdmpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyMassPaymentCSEntityDataSource admpr on bdmpr.[Date] = admpr.[Date]
			/*END-FACT_DailyMassPaymentCSEntityDataSource MassPaymentVol*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyMassPaymentCSEntityDataSource UniqueMerchandisersLastDay*/
				  SELECT 
						bdmpr.[Date]																													StreamDate,
						'UM'																															TestType,
						'FACT_DailyMassPaymentCSEntityDataSource'																									BasedReportTable,
						'UniqueMerchandisersLastDay'																										BasedReportTableField,
						'FACT_MerchandiserTransactions'																											Tested_DWH_Table,
						'FeatureType;Merchandiser_Key'																										Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 9 THEN Merchandiser_Key ELSE NULL END)'														Formula,
						'Unique Merchandisers had mass payment'																								MetricExplanation,
						admpr.UniqueMerchandisersLastDay																									CSHARP_TO_PROD_VIEW,
						bdmpr.UniqueMerchandisersLastDay																									PROD_TO_DWH_VIEW
						,1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyMassPaymentCSEntityDataSource bdmpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyMassPaymentCSEntityDataSource admpr on bdmpr.[Date] = admpr.[Date]
			/*END-FACT_DailyMassPaymentCSEntityDataSource UniqueMerchandisersLastDay*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyMassPaymentCSEntityDataSource UniqueUserAttributesLastDay*/
				  SELECT 
						bdmpr.[Date]																													StreamDate,			
						'UU'																															TestType,
						'FACT_DailyMassPaymentCSEntityDataSource'																									BasedReportTable,
						'UniqueUserAttributesLastDay'																											BasedReportTableField,
						'FACT_MerchandiserTransactions'																											Tested_DWH_Table,
						'FeatureType;User_Key'																											Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 9 THEN User_Key ELSE NULL END)'															Formula,
						'Unique UserAttributes utilized mass payment'																							MetricExplanation,
						admpr.UniqueUserAttributesLastDay																										CSHARP_TO_PROD_VIEW,
						bdmpr.UniqueUserAttributesLastDay																										PROD_TO_DWH_VIEW
						,1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyMassPaymentCSEntityDataSource bdmpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyMassPaymentCSEntityDataSource admpr on bdmpr.[Date] = admpr.[Date]
			/*END-FACT_DailyMassPaymentCSEntityDataSource UniqueUserAttributesLastDay*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource CellPhoneCnt*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'Tx.#'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'CellPhoneCnt'																												BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;Id'																												Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'Cnt(CASE WHEN InvoiceCategoryId = 4 THEN Id ELSE NULL END)'																		Formula,
						'Cnt of cellphone'																											MetricExplanation,
						adbpr.CellPhoneCnt																											CSHARP_TO_PROD_VIEW,
						bdbpr.CellPhoneCnt																											PROD_TO_DWH_VIEW	
						,1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource CellPhoneCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource CellPhoneUserCnt*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'UU'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'CellPhoneUserCnt'																											BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;User_Key'																										Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'Cnt(DISTINCT CASE WHEN InvoiceCategoryId = 4 THEN User_Key ELSE NULL END)'														Formula,
						'Cnt of cellphone UU'																											MetricExplanation,
						adbpr.CellPhoneUserCnt																										CSHARP_TO_PROD_VIEW,
						bdbpr.CellPhoneUserCnt																										PROD_TO_DWH_VIEW		
						,1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource    bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource CellPhoneUserCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource CellPhoneVol*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'V.'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'CellPhoneVol'																												BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;TxAmount'																											Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'ABS(SUM(CASE WHEN InvoiceCategoryId = 4 THEN TxAmount ELSE NULL END)))'																Formula,
						'Cnt of cellphone Vol'																										MetricExplanation,
						adbpr.CellPhoneVol																											CSHARP_TO_PROD_VIEW,
						bdbpr.CellPhoneVol																											PROD_TO_DWH_VIEW	
						,1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource CellPhoneVol*/
			
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource DonateToCharitiesCnt*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'Tx.#'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'DonateToCharitiesCnt'																													BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;Id'																												Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'Cnt(CASE WHEN InvoiceCategoryId = 9 THEN Id ELSE NULL END)'																		Formula,
						'Cnt of DonateToCharities'																												MetricExplanation,
						adbpr.DonateToCharitiesCnt																												CSHARP_TO_PROD_VIEW,
						bdbpr.DonateToCharitiesCnt																												PROD_TO_DWH_VIEW
						,1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource DonateToCharitiesCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource DonateToCharitiesUserCnt*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'UU'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'DonateToCharitiesUserCnt'																												BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;User_Key'																										Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'Cnt(DISTINCT CASE WHEN InvoiceCategoryId = 9 THEN User_Key ELSE NULL END)'														Formula,
						'DonateToCharities UU'																													MetricExplanation,
						adbpr.DonateToCharitiesUserCnt																											CSHARP_TO_PROD_VIEW,
						bdbpr.DonateToCharitiesUserCnt																											PROD_TO_DWH_VIEW		
						,1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource DonateToCharitiesUserCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource DonateToCharitiesVol*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'V.'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'DonateToCharitiesVol'																												BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;TxAmount'																											Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'ABS(SUM(CASE WHEN InvoiceCategoryId = 9 THEN TxAmount ELSE NULL END))'																Formula,
						'DonateToCharities V.'																													MetricExplanation,
						adbpr.DonateToCharitiesVol																											CSHARP_TO_PROD_VIEW,
						bdbpr.DonateToCharitiesVol																											PROD_TO_DWH_VIEW		
						,1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource	  bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource DonateToCharitiesVol*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource ElectricityCnt*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'Tx.#'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'ElectricityCnt'																												BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;Id'																												Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'Cnt(CASE WHEN InvoiceCategoryId = 2 THEN Id ELSE NULL END)'																		Formula,
						'Cnt of Electricity'																											MetricExplanation,
						adbpr.ElectricityCnt																											CSHARP_TO_PROD_VIEW,
						bdbpr.ElectricityCnt																											PROD_TO_DWH_VIEW	
						,1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource ElectricityCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource ElectricityUserCnt*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'UU'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'ElectricityUserCnt'																											BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;User_Key'																										Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'Cnt(DISTINCT CASE WHEN InvoiceCategoryId = 2 THEN User_Key ELSE NULL END)'														Formula,
						'Electricity UU'																												MetricExplanation,
						adbpr.ElectricityUserCnt																										CSHARP_TO_PROD_VIEW,
						bdbpr.ElectricityUserCnt																										PROD_TO_DWH_VIEW		
						,1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource ElectricityUserCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource ElectricityVol*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'V.'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'ElectricityVol'																												BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;TxAmount'																											Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'ABS(SUM(CASE WHEN InvoiceCategoryId = 2 THEN TxAmount ELSE NULL END))'																Formula,
						'Electricity V.'																												MetricExplanation,
						adbpr.ElectricityVol																											CSHARP_TO_PROD_VIEW,
						bdbpr.ElectricityVol																											PROD_TO_DWH_VIEW		
						,1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource	  bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource ElectricityVol*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource GameCnt*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'Tx.#'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'GameCnt'																														BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;Id'																												Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'Cnt(CASE WHEN InvoiceCategoryId = 5 THEN Id ELSE NULL END)'																		Formula,
						'Cnt of Game'																													MetricExplanation,
						adbpr.GameCnt																													CSHARP_TO_PROD_VIEW,
						bdbpr.GameCnt																													PROD_TO_DWH_VIEW	
						,1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource GameCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource GameUserCnt*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'UU'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'GameUserCnt'																													BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;User_Key'																										Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'Cnt(DISTINCT CASE WHEN InvoiceCategoryId = 5 THEN User_Key ELSE NULL END)'														Formula,
						'Game UU'																														MetricExplanation,
						adbpr.GameUserCnt																												CSHARP_TO_PROD_VIEW,
						bdbpr.GameUserCnt																												PROD_TO_DWH_VIEW,  1 IsWarningField		
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource GameUserCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource GameVol*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'V.'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'GameVol'																													BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;TxAmount'																											Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'ABS(SUM(CASE WHEN InvoiceCategoryId = 5 THEN TxAmount ELSE NULL END))'																Formula,
						'Game V.'																														MetricExplanation,
						adbpr.GameVol																												CSHARP_TO_PROD_VIEW,
						bdbpr.GameVol																												PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource	  bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource GameVol*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource InternetAndTvCnt*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'Tx.#'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'InternetAndTvCnt'																											BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;Id'																												Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'Cnt(CASE WHEN InvoiceCategoryId = 6 THEN Id ELSE NULL END)'																		Formula,
						'Cnt of Internet & Tv'																										MetricExplanation,
						adbpr.InternetAndTvCnt																										CSHARP_TO_PROD_VIEW,
						bdbpr.InternetAndTvCnt																										PROD_TO_DWH_VIEW,  1 IsWarningField		
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource InternetAndTvCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource InternetAndTvUserCnt*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'UU'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'InternetAndTvUserCnt'																										BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;User_Key'																										Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'Cnt(DISTINCT CASE WHEN InvoiceCategoryId = 6 THEN User_Key ELSE NULL END)'														Formula,
						'Internet & Tv UU'																												MetricExplanation,
						adbpr.InternetAndTvUserCnt																									CSHARP_TO_PROD_VIEW,
						bdbpr.InternetAndTvUserCnt																									PROD_TO_DWH_VIEW,  1 IsWarningField		
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource InternetAndTvUserCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource InternetAndTvVol*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'V.'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'InternetAndTvVol'																											BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;TxAmount'																											Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'ABS(SUM(CASE WHEN InvoiceCategoryId = 6 THEN TxAmount ELSE NULL END))'																Formula,
						'Internet & Tv V.'																												MetricExplanation,
						adbpr.InternetAndTvVol																										CSHARP_TO_PROD_VIEW,
						bdbpr.InternetAndTvVol																										PROD_TO_DWH_VIEW,  1 IsWarningField		
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource	  bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource InternetAndTvVol*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource CityRingTravelCardCnt*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'Tx.#'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'CityRingTravelCardCnt'																												BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;Id'																												Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'Cnt(CASE WHEN InvoiceCategoryId = 8 THEN Id ELSE NULL END)'																		Formula,
						'Cnt of CityRingTravelCard'																											MetricExplanation,
						adbpr.CityRingTravelCardCnt																											CSHARP_TO_PROD_VIEW,
						bdbpr.CityRingTravelCardCnt																											PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource CityRingTravelCardCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource CityRingTravelCardUserCnt*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'UU'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'CityRingTravelCardUserCnt'																											BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;User_Key'																										Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'Cnt(DISTINCT CASE WHEN InvoiceCategoryId = 8 THEN User_Key ELSE NULL END)'														Formula,
						'CityRingTravelCard UU'																												MetricExplanation,
						adbpr.CityRingTravelCardUserCnt																										CSHARP_TO_PROD_VIEW,
						bdbpr.CityRingTravelCardUserCnt																										PROD_TO_DWH_VIEW,  1 IsWarningField		
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource CityRingTravelCardUserCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource CityRingTravelCardVol*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'V.'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'CityRingTravelCardVol'																											BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;TxAmount'																											Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'ABS(SUM(CASE WHEN InvoiceCategoryId = 8 THEN TxAmount ELSE NULL END))'																Formula,
						'CityRingTravelCard V.'																												MetricExplanation,
						adbpr.CityRingTravelCardVol																										CSHARP_TO_PROD_VIEW,
						bdbpr.CityRingTravelCardVol																										PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource	  bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource CityRingTravelCardVol*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource LotteryCnt*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'Tx.#'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'LotteryCnt'																													BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;Id'																												Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'Cnt(CASE WHEN InvoiceCategoryId = 12 THEN Id ELSE NULL END)'																	Formula,
						'Cnt of Lottery'																												MetricExplanation,
						adbpr.LotteryCnt																												CSHARP_TO_PROD_VIEW,
						bdbpr.LotteryCnt																												PROD_TO_DWH_VIEW,  1 IsWarningField					
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource LotteryCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource CouponVol*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'V.'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'CouponVol'																													BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;TxAmount'																											Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'ABS(SUM(CASE WHEN InvoiceCategoryId = 12 THEN TxAmount ELSE NULL END))'																Formula,
						'Lottery V.'																													MetricExplanation,
						adbpr.CouponVol																												CSHARP_TO_PROD_VIEW,
						bdbpr.CouponVol																												PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource	  bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource CouponVol*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource MembershipPaymentCnt*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'Tx.#'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'MembershipPaymentCnt'																										BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;Id'																												Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'Cnt(CASE WHEN InvoiceCategoryId = 13 THEN Id ELSE NULL END)'																	Formula,
						'Cnt of Membership Payment'																									MetricExplanation,
						adbpr.MembershipPaymentCnt																									CSHARP_TO_PROD_VIEW,
						bdbpr.MembershipPaymentCnt																									PROD_TO_DWH_VIEW,  1 IsWarningField		
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource MembershipPaymentCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource MembershipPaymentVol*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'V.'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'MembershipPaymentVol'																										BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;TxAmount'																											Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'ABS(SUM(CASE WHEN InvoiceCategoryId = 13 THEN TxAmount ELSE NULL END))'																Formula,
						'Membership Payment V.'																											MetricExplanation,
						adbpr.MembershipPaymentVol																									CSHARP_TO_PROD_VIEW,
						bdbpr.MembershipPaymentVol																									PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource	  bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource MembershipPaymentVol*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource NaturalGasCnt*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'Tx.#'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'NaturalGasCnt'																												BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;Id'																												Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'Cnt(CASE WHEN InvoiceCategoryId = 1 THEN Id ELSE NULL END)'																		Formula,
						'Cnt of NaturalGas'																											MetricExplanation,
						adbpr.NaturalGasCnt																											CSHARP_TO_PROD_VIEW,
						bdbpr.NaturalGasCnt																											PROD_TO_DWH_VIEW,  1 IsWarningField		
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource NaturalGasCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource NaturalGasUserCnt*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'UU'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'NaturalGasUserCnt'																											BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;User_Key'																										Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'Cnt(DISTINCT CASE WHEN InvoiceCategoryId = 1 THEN User_Key ELSE NULL END)'														Formula,
						'Natural Gas UU'																												MetricExplanation,
						adbpr.NaturalGasUserCnt																										CSHARP_TO_PROD_VIEW,
						bdbpr.NaturalGasUserCnt																										PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource NaturalGasUserCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource NaturalGasVol*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'V.'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'NaturalGasVol'																												BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;TxAmount'																											Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'ABS(SUM(CASE WHEN InvoiceCategoryId = 1 THEN TxAmount ELSE NULL END))'																Formula,
						'NaturalGas V.'																													MetricExplanation,
						adbpr.NaturalGasVol																											CSHARP_TO_PROD_VIEW,
						bdbpr.NaturalGasVol																											PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource	  bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource NaturalGasVol*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource WaterCnt*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'Tx.#'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'WaterCnt'																													BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;Id'																												Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'Cnt(CASE WHEN InvoiceCategoryId = 3 THEN Id ELSE NULL END)'																		Formula,
						'Cnt of Water'																												MetricExplanation,
						adbpr.WaterCnt																												CSHARP_TO_PROD_VIEW,
						bdbpr.WaterCnt																												PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource WaterCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource WaterUserCnt*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'UU'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'WaterUserCnt'																												BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;User_Key'																										Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'Cnt(DISTINCT CASE WHEN InvoiceCategoryId = 3 THEN User_Key ELSE NULL END)'														Formula,
						'Water UU'																														MetricExplanation,
						adbpr.WaterUserCnt																											CSHARP_TO_PROD_VIEW,
						bdbpr.WaterUserCnt																											PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource WaterUserCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource WaterVol*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'V.'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'WaterVol'																													BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;TxAmount'																											Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'ABS(SUM(CASE WHEN InvoiceCategoryId = 3 THEN TxAmount ELSE NULL END))'																Formula,
						'Water V.'																														MetricExplanation,
						adbpr.WaterVol																												CSHARP_TO_PROD_VIEW,
						bdbpr.WaterVol																												PROD_TO_DWH_VIEW,  1 IsWarningField	
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource	  bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource WaterVol*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource OtherCnt*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'Tx.#'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'OtherCnt'																													BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;Id'																												Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'Cnt(CASE WHEN InvoiceCategoryId = 7 THEN Id ELSE NULL END)'																		Formula,
						'Cnt of Other'																												MetricExplanation,
						adbpr.OtherCnt																												CSHARP_TO_PROD_VIEW,
						bdbpr.OtherCnt																												PROD_TO_DWH_VIEW,  1 IsWarningField		
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource OtherCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource OtherUserCnt*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'UU'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'OtherUserCnt'																												BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;User_Key'																										Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'Cnt(DISTINCT CASE WHEN InvoiceCategoryId = 7 THEN User_Key ELSE NULL END)'														Formula,
						'Other UU'																														MetricExplanation,
						adbpr.OtherUserCnt																											CSHARP_TO_PROD_VIEW,
						bdbpr.OtherUserCnt																											PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource OtherUserCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource OtherVol*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'V.'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'OtherVol'																													BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'InvoiceCategoryId;TxAmount'																											Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'ABS(SUM(CASE WHEN InvoiceCategoryId = 7 THEN TxAmount ELSE NULL END))'																Formula,
						'Other V.'																														MetricExplanation,
						adbpr.OtherVol																												CSHARP_TO_PROD_VIEW,
						bdbpr.OtherVol																												PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource	  bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource OtherVol*/

			UNION ALL
			
			/*BEGIN-FACT_DailyInvoicePaymentCSEntityDataSource TotalPaymentUserAttributesCnt*/
				  SELECT 
						bdbpr.[Date]																													StreamDate,
						'UU'																															TestType,
						'FACT_DailyInvoicePaymentCSEntityDataSource'																									BasedReportTable,
						'TotalPaymentUserAttributesCnt'																										BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'FeatureType;User_Key'																												Tested_DWH_Table_Field,
						0																																Currency,
						'N/A'																															Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType IN (14,17,18,22,31) THEN User_Key ELSE NULL END)'											Formula,
						'Other V.'																														MetricExplanation,
						adbpr.TotalPaymentUserAttributesCnt																									CSHARP_TO_PROD_VIEW,
						bdbpr.TotalPaymentUserAttributesCnt																									PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource	  bdbpr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource adbpr on bdbpr.[Date] = adbpr.[Date]
			/*END-FACT_DailyInvoicePaymentCSEntityDataSource TotalPaymentUserAttributesCnt*/		
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource AcCntNoCnt*/
				  SELECT 
						bdmtr.[Date]																													StreamDate,
						'Tx.#'																															TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																								BasedReportTable,
						'AcCntNoCnt'																											BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'Method;RemittanceType;Id'																									Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																															Value1,
						'Cnt(CASE WHEN l.Method = 2  AND RemittanceType = 1 THEN l.Id ELSE NULL END)'												Formula,
						'Money transfer done by AcCnt Id Cnt'																						MetricExplanation,
						admtr.AcCntNoCnt																										CSHARP_TO_PROD_VIEW,
						bdmtr.AcCntNoCnt																										PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	  		 bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource AcCntNoCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource AcCntNoVol*/
				  SELECT 
						bdmtr.[Date]																													StreamDate,
						'V.'																															TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																								BasedReportTable,
						'AcCntNoVol'																											BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'Method;RemittanceType;TxAmount'																								Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																															Value1,
						'ABS(SUM(CASE WHEN l.Method = 2  AND RemittanceType = 1 THEN l.TxAmount ELSE NULL END))'										Formula,
						'Money transfer done by AcCnt Id Vol'																						MetricExplanation,
						admtr.AcCntNoVol																										CSHARP_TO_PROD_VIEW,
						bdmtr.AcCntNoVol																										PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	  		 bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource AcCntNoVol*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource CompletedRemittanceReqCnt*/
				  SELECT 
						bdmtr.[Date]																													StreamDate,
						'Tx.#'																															TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																								BasedReportTable,
						'CompletedRemittanceReqCnt'																									BasedReportTableField,
						'FACT_Transactions(l);FACT_RemittanceReqs(mr)'																							Tested_DWH_Table,
						'mr.[Status];l.Id'																												Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																															Value1,
						'Cnt(CASE WHEN mr.[Status] = 1 THEN l.Id ELSE NULL END)'																		Formula,
						'Total completed money request Cnt'																							MetricExplanation,
						admtr.CompletedRemittanceReqCnt																								CSHARP_TO_PROD_VIEW,
						bdmtr.CompletedRemittanceReqCnt																								PROD_TO_DWH_VIEW,  1 IsWarningField
			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource CompletedRemittanceReqCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource CompletedRemittanceReqVol*/
				  SELECT 
						bdmtr.[Date]																													StreamDate,
						'V.'																															TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																								BasedReportTable,
						'CompletedRemittanceReqVol'																									BasedReportTableField,
						'FACT_Transactions(l);FACT_RemittanceReqs(mr)'																							Tested_DWH_Table,
						'mr.[Status];l.TxAmount'																											Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																															Value1,
						'SUM(CASE WHEN mr.[Status] = 1 THEN l.Id ELSE NULL END)'																		Formula,
						'Total completed money request Vol'																							MetricExplanation,
						admtr.CompletedRemittanceReqVol																								CSHARP_TO_PROD_VIEW,
						bdmtr.CompletedRemittanceReqVol																								PROD_TO_DWH_VIEW,  1 IsWarningField
			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource CompletedRemittanceReqVol*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource IbanRemittanceCnt*/
				  SELECT 
						bdmtr.[Date]																													StreamDate,
						'Tx.#'																															TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																								BasedReportTable,
						'IbanRemittanceCnt'																										BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'FeatureType;Id'																													Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																															Value1,
						'Cnt(CASE WHEN FeatureType = 21 THEN Id ELSE NULL END)'																			Formula,
						'Total IBAN money transfers Cnt'																								MetricExplanation,
						admtr.IbanRemittanceCnt																									CSHARP_TO_PROD_VIEW,
						bdmtr.IbanRemittanceCnt																									PROD_TO_DWH_VIEW,  1 IsWarningField	
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource IbanRemittanceCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource IbanRemittanceUserAttributesCnt*/
				  SELECT 
						bdmtr.[Date]																													StreamDate,
						'UU'																															TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																								BasedReportTable,
						'IbanRemittanceUserAttributesCnt'																									BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'FeatureType;User_Key'																												Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																															Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 21 THEN l.User_Key ELSE NULL END)'															Formula,
						'Total IBAN money transfers unique UserAttributes (UU) Cnt'																			MetricExplanation,
						admtr.IbanRemittanceUserAttributesCnt																								CSHARP_TO_PROD_VIEW,
						bdmtr.IbanRemittanceUserAttributesCnt																								PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource IbanRemittanceUserAttributesCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource IbanRemittanceVol*/
				  SELECT 
						bdmtr.[Date]																													StreamDate,
						'V.'																															TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																								BasedReportTable,
						'IbanRemittanceVol'																										BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'FeatureType;TxAmount'																												Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																															Value1,
						'ABS(SUM(CASE WHEN FeatureType = 21 THEN l.TxAmount ELSE NULL END))'																Formula,
						'Total IBAN money transfer Vol'																								MetricExplanation,
						admtr.IbanRemittanceVol																									CSHARP_TO_PROD_VIEW,
						bdmtr.IbanRemittanceVol																									PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource IbanRemittanceVol*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource InviteByMoneySendCompletedUserAttributesCnt*/
				  SELECT 
						bdmtr.[Date]																													StreamDate,
						'UU'																															TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																								BasedReportTable,
						'InviteByMoneySendCompletedUserAttributesCnt'																							BasedReportTableField,
						'FACT_InviteByRemittances'																									Tested_DWH_Table,
						'Type;Status;User_Key'																											Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																															Value1,
						'Cnt(DISTINCT CASE WHEN [Type] = 1 AND [Status] = 1 THEN User_Key ELSE NULL END)'												Formula,
						'Total completed invite by money send unique user Cnt (UU)'																	MetricExplanation,
						admtr.InviteByMoneySendCompletedUserAttributesCnt																						CSHARP_TO_PROD_VIEW,
						bdmtr.InviteByMoneySendCompletedUserAttributesCnt																						PROD_TO_DWH_VIEW,  0 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource InviteByMoneySendCompletedUserAttributesCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource RemittanceReqAcCntNoCnt*/
				  SELECT 
						bdmtr.[Date]																													StreamDate,
						'Tx.#'																															TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																								BasedReportTable,
						'RemittanceReqAcCntNoCnt'																								BasedReportTableField,
						'FACT_RemittanceReqs'																											Tested_DWH_Table,
						'Method,Id'																														Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																															Value1,
						'Cnt(CASE WHEN Method = 2 THEN Id ELSE NULL END)'																				Formula,
						'Money request done by acCnt id Cnt'																						MetricExplanation,
						admtr.RemittanceReqAcCntNoCnt																							CSHARP_TO_PROD_VIEW,
						bdmtr.RemittanceReqAcCntNoCnt																							PROD_TO_DWH_VIEW,  1 IsWarningField	
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource RemittanceReqAcCntNoCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource RemittanceReqAcCntNoVol*/
				  SELECT 
						bdmtr.[Date]																													StreamDate,
						'V.'																															TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																								BasedReportTable,
						'RemittanceReqAcCntNoVol'																								BasedReportTableField,
						'FACT_RemittanceReqs'																											Tested_DWH_Table,
						'Method;TxAmount'																													Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																															Value1,
						'SUM(CASE WHEN Method = 2 THEN TxAmount ELSE NULL END)'																			Formula,
						'Money request done by acCnt id Vol'																						MetricExplanation,
						admtr.RemittanceReqAcCntNoVol																							CSHARP_TO_PROD_VIEW,
						bdmtr.RemittanceReqAcCntNoVol																							PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource RemittanceReqAcCntNoVol*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource RemittanceReqCnt*/
				  SELECT 
						bdmtr.[Date]																													StreamDate,
						'Tx.#'																															TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																								BasedReportTable,
						'RemittanceReqCnt'																												BasedReportTableField,
						'FACT_RemittanceReqs'																											Tested_DWH_Table,
						'Id'																															Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																															Value1,
						'Cnt(*)'																														Formula,
						'Total completed money request Cnt'																							MetricExplanation,
						admtr.RemittanceReqCnt																											CSHARP_TO_PROD_VIEW,
						bdmtr.RemittanceReqCnt																											PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource RemittanceReqCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource RemittanceReqPhoneNoCnt*/
				  SELECT 
						bdmtr.[Date]																													StreamDate,
						'Tx.#'																															TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																								BasedReportTable,
						'RemittanceReqPhoneNoCnt'																									BasedReportTableField,
						'FACT_RemittanceReqs'																											Tested_DWH_Table,
						'Method;Id'																														Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																															Value1,
						'Cnt(CASE WHEN Method = 1 THEN Id ELSE NULL END)'																				Formula,
						'Money request done by phone No Cnt'																						MetricExplanation,
						admtr.RemittanceReqPhoneNoCnt																								CSHARP_TO_PROD_VIEW,
						bdmtr.RemittanceReqPhoneNoCnt																								PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource RemittanceReqPhoneNoCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource RemittanceReqPhoneNoVol*/
				  SELECT 
						bdmtr.[Date]																													StreamDate,
						'V.'																															TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																								BasedReportTable,
						'RemittanceReqPhoneNoVol'																									BasedReportTableField,
						'FACT_RemittanceReqs'																											Tested_DWH_Table,
						'Method;TxAmount'																													Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																															Value1,
						'SUM(CASE WHEN Method = 1 THEN TxAmount ELSE NULL END)'																			Formula,
						'Money request done by phone No Vol'																						MetricExplanation,
						admtr.RemittanceReqPhoneNoVol																								CSHARP_TO_PROD_VIEW,
						bdmtr.RemittanceReqPhoneNoVol																								PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource RemittanceReqPhoneNoVol*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource RemittanceReqReceivedAcCntNoUserAttributesCnt*/
				  SELECT 
						bdmtr.[Date]																													StreamDate,
						'UU'																															TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																								BasedReportTable,
						'RemittanceReqReceivedAcCntNoUserAttributesCnt'																					BasedReportTableField,
						'FACT_RemittanceReqs'																											Tested_DWH_Table,
						'Method;User_Key'																												Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																															Value1,
						'Cnt(DISTINCT CASE WHEN Method = 2 THEN User_Key ELSE NULL END)'																Formula,
						'Total money transfer request received by acCnt id UU Cnt'																	MetricExplanation,
						admtr.RemittanceReqReceivedAcCntNoUserAttributesCnt																				CSHARP_TO_PROD_VIEW,
						bdmtr.RemittanceReqReceivedAcCntNoUserAttributesCnt																				PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource RemittanceReqReceivedAcCntNoUserAttributesCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource RemittanceReqReceivedPhoneNoUserAttributesCnt*/
				  SELECT 
						bdmtr.[Date]																													StreamDate,
						'UU'																															TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																								BasedReportTable,
						'RemittanceReqReceivedPhoneNoUserAttributesCnt'																						BasedReportTableField,
						'FACT_RemittanceReqs'																											Tested_DWH_Table,
						'Method,User_Key'																												Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																															Value1,
						'Cnt(DISTINCT CASE WHEN Method = 1 THEN User_Key ELSE NULL END)'																Formula,
						'Total money transfer request received by phone No UU Cnt'																MetricExplanation,
						admtr.RemittanceReqReceivedPhoneNoUserAttributesCnt																					CSHARP_TO_PROD_VIEW,
						bdmtr.RemittanceReqReceivedPhoneNoUserAttributesCnt																					PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource RemittanceReqReceivedPhoneNoUserAttributesCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource RemittanceReqSendAcCntNoUserAttributesCnt*/
				  SELECT 
						bdmtr.[Date]																													StreamDate,
						'UU'																															TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																								BasedReportTable,
						'RemittanceReqSendAcCntNoUserAttributesCnt'																						BasedReportTableField,
						'FACT_RemittanceReqs'																											Tested_DWH_Table,
						'Method;OtherUser_Key'																											Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																															Value1,
						'Cnt(DISTINCT CASE WHEN Method = 2 THEN OtherUser_Key ELSE NULL END)'															Formula,
						'Total money transfer request send by acCnt id UU Cnt'																		MetricExplanation,
						admtr.RemittanceReqSendAcCntNoUserAttributesCnt																					CSHARP_TO_PROD_VIEW,
						bdmtr.RemittanceReqSendAcCntNoUserAttributesCnt																					PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource RemittanceReqSendAcCntNoUserAttributesCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource RemittanceReqSendPhoneNoUserAttributesCnt*/
				  SELECT 
						bdmtr.[Date]																													StreamDate,
						'UU'																															TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																								BasedReportTable,
						'RemittanceReqSendPhoneNoUserAttributesCnt'																							BasedReportTableField,
						'FACT_RemittanceReqs'																											Tested_DWH_Table,
						'Method,OtherUser_Key'																											Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																															Value1,
						'Cnt(DISTINCT CASE WHEN Method = 1 THEN OtherUser_Key ELSE NULL END)'															Formula,
						'Total money transfer request send by phone No UU Cnt'																	MetricExplanation,
						admtr.RemittanceReqSendPhoneNoUserAttributesCnt																						CSHARP_TO_PROD_VIEW,
						bdmtr.RemittanceReqSendPhoneNoUserAttributesCnt																						PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource RemittanceReqSendPhoneNoUserAttributesCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource RemittanceReqVol*/
				  SELECT 
						bdmtr.[Date]																													StreamDate,
						'V.'																															TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																								BasedReportTable,
						'RemittanceReqVol'																											BasedReportTableField,
						'FACT_RemittanceReqs'																											Tested_DWH_Table,
						'TxAmount'																														Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																															Value1,
						'SUM(TxAmount)'																													Formula,
						'Money request Vol'																											MetricExplanation,
						admtr.RemittanceReqVol																										CSHARP_TO_PROD_VIEW,
						bdmtr.RemittanceReqVol																										PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource RemittanceReqVol*/
			
			--UNION ALL
			
			--/*BEGIN-FACT_DailyRemittanceCSEntityDataSource RemittanceReqWithSplitCompletedCnt*/
			--	  SELECT 
			--			bdmtr.[Date]																													StreamDate,
			--			'Tx.#'																															TestType,
			--			'FACT_DailyRemittanceCSEntityDataSource'																								BasedReportTable,
			--			'RemittanceReqWithSplitCompletedCnt'																							BasedReportTableField,
			--			'FACT_RemittanceReqs'																											Tested_DWH_Table,
			--			'Status;IsSplitted;Id'																											Tested_DWH_Table_Field,
			--			bdmtr.Currency,
			--			'N/A'																															Value1,
			--			'Cnt(CASE WHEN IsSplitted = 1 AND [Status] = 1 THEN Id ELSE NULL END)'														Formula,
			--			'Money request completed by split Cnt'																						MetricExplanation,
			--			admtr.RemittanceReqWithSplitCompletedCnt																						CSHARP_TO_PROD_VIEW,
			--			bdmtr.RemittanceReqWithSplitCompletedCnt																						PROD_TO_DWH_VIEW,  1 IsWarningField
			--	  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
			--	  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			--/*END-FACT_DailyRemittanceCSEntityDataSource RemittanceReqWithSplitCompletedCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource RemittanceFee*/
				  SELECT 
						bdmtr.[Date]																													StreamDate,
						'V.'																															TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																								BasedReportTable,
						'RemittanceFee'																												BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'FeatureType,Fee'																													Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																															Value1,
						'ABS(SUM(CASE WHEN FeatureType = 7 THEN Fee ELSE NULL END))'																		Formula,
						'Money transfer transaction fee'																								MetricExplanation,
						admtr.RemittanceFee																											CSHARP_TO_PROD_VIEW,
						bdmtr.RemittanceFee																											PROD_TO_DWH_VIEW,  1 IsWarningField	
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource RemittanceFee*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource PaidRecievedCnt*/
				  SELECT 
						bdmtr.[Date]																													StreamDate,
						'Tx.#'																															TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																								BasedReportTable,
						'PaidRecievedCnt'																												BasedReportTableField,
						'FACT_Transactions'																													Tested_DWH_Table,
						'FeatureType;RemittanceType;Fee;Id'																							Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																															Value1,
						'Cnt(CASE WHEN FeatureType = 7 AND RemittanceType = 0 AND Fee != 0 THEN l.Id ELSE NULL END)'									Formula,
						'Paid money transfer Cnt'																										MetricExplanation,
						admtr.PaidRecievedCnt																											CSHARP_TO_PROD_VIEW,
						bdmtr.PaidRecievedCnt																											PROD_TO_DWH_VIEW,  1 IsWarningField		
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource PaidRecievedCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource PaidRecievedVol*/
				  SELECT 
						bdmtr.[Date]																												StreamDate,
						'V.'																														TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																							BasedReportTable,
						'PaidRecievedVol'																										BasedReportTableField,
						'FACT_Transactions'																												Tested_DWH_Table,
						'FeatureType;RemittanceType;Fee;TxAmount'																					Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																														Value1,
						'ABS(SUM(CASE WHEN FeatureType = 7 AND RemittanceType = 0 AND Fee != 0 THEN l.TxAmount ELSE NULL END))'						Formula,
						'Paid money transfer Vol'																								MetricExplanation,
						admtr.PaidRecievedVol																									CSHARP_TO_PROD_VIEW,
						bdmtr.PaidRecievedVol																									PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource PaidRecievedVol*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource PhoneNoCnt*/
				  SELECT 
						bdmtr.[Date]																												StreamDate,
						'Tx.#'																														TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																							BasedReportTable,
						'PhoneNoCnt'																											BasedReportTableField,
						'FACT_Transactions'																												Tested_DWH_Table,
						'FeatureType;RemittanceType;Method;Id'																						Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																														Value1,
						'Cnt(CASE WHEN FeatureType = 7 AND RemittanceType = 1 AND l.Method = 1 THEN l.Id ELSE NULL END)'							Formula,
						'Money transfer done by phone No Cnt'																					MetricExplanation,
						admtr.PhoneNoCnt																										CSHARP_TO_PROD_VIEW,
						bdmtr.PhoneNoCnt																										PROD_TO_DWH_VIEW,  1 IsWarningField
			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource PhoneNoCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource PhoneNoVol*/
				  SELECT 
						bdmtr.[Date]																												StreamDate,
						'V.'																														TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																							BasedReportTable,
						'PhoneNoVol'																											BasedReportTableField,
						'FACT_Transactions'																												Tested_DWH_Table,
						'FeatureType;RemittanceType;Method;TxAmount'																					Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																														Value1,
						'ABS(SUM(CASE WHEN FeatureType = 7 AND RemittanceType = 1 AND l.Method = 1 THEN l.TxAmount ELSE NULL END))'					Formula,
						'Money transfer done by phone No Vol'																				MetricExplanation,
						admtr.PhoneNoVol																										CSHARP_TO_PROD_VIEW,
						bdmtr.PhoneNoVol																										PROD_TO_DWH_VIEW,  1 IsWarningField		
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource PhoneNoVol*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource QrCodeCnt*/
				  SELECT 
						bdmtr.[Date]																												StreamDate,
						'Tx.#'																														TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																							BasedReportTable,
						'QrCodeCnt'																												BasedReportTableField,
						'FACT_Transactions'																												Tested_DWH_Table,
						'FeatureType;RemittanceType;Method;Id'																						Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																														Value1,
						'Cnt(CASE WHEN FeatureType = 7 AND RemittanceType = 1 AND l.Method = 3 THEN l.Id ELSE NULL END)'							Formula,
						'Money transfer done by QrCode Cnt'																						MetricExplanation,
						admtr.QrCodeCnt																											CSHARP_TO_PROD_VIEW,
						bdmtr.QrCodeCnt																											PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource QrCodeCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource QrCodeVol*/
				  SELECT 
						bdmtr.[Date]																												StreamDate,
						'V.'																														TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																							BasedReportTable,
						'QrCodeVol'																												BasedReportTableField,
						'FACT_Transactions'																												Tested_DWH_Table,
						'FeatureType;RemittanceType;Method;TxAmount'																					Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																														Value1,
						'ABS(SUM(CASE WHEN FeatureType = 7 AND RemittanceType = 1 AND l.Method = 1 THEN l.TxAmount ELSE NULL END))'					Formula,
						'Money transfer done by QrCode Vol'																						MetricExplanation,
						admtr.QrCodeVol																											CSHARP_TO_PROD_VIEW,
						bdmtr.QrCodeVol																											PROD_TO_DWH_VIEW,  1 IsWarningField
			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource QrCodeVol*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource ReceivedAcCntNoUserAttributesCnt*/
				  SELECT 
						bdmtr.[Date]																												StreamDate,
						'UU'																														TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																							BasedReportTable,
						'ReceivedAcCntNoUserAttributesCnt'																							BasedReportTableField,
						'FACT_Transactions'																												Tested_DWH_Table,
						'FeatureType;RemittanceType;Method;User_Key'																				Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																														Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 7 AND RemittanceType = 0 AND l.Method = 2 THEN l.User_Key ELSE NULL END)'			Formula,
						'Total money transfer request received by acCnt id unique user Cnt'														MetricExplanation,
						admtr.ReceivedAcCntNoUserAttributesCnt																						CSHARP_TO_PROD_VIEW,
						bdmtr.ReceivedAcCntNoUserAttributesCnt																						PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource ReceivedAcCntNoUserAttributesCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource ReceivedPhoneNoUserAttributesCnt*/
				  SELECT 
						bdmtr.[Date]																												StreamDate,
						'UU'																														TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																							BasedReportTable,
						'ReceivedPhoneNoUserAttributesCnt'																								BasedReportTableField,
						'FACT_Transactions'																												Tested_DWH_Table,
						'FeatureType;RemittanceType;Method;User_Key'																				Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																														Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 7 AND RemittanceType = 0 AND l.Method = 1 THEN l.User_Key ELSE NULL END)'			Formula,
						'Total money transfer received by phone No UU Cnt'																	MetricExplanation,
						admtr.ReceivedPhoneNoUserAttributesCnt																							CSHARP_TO_PROD_VIEW,
						bdmtr.ReceivedPhoneNoUserAttributesCnt																							PROD_TO_DWH_VIEW,  1 IsWarningField
			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource ReceivedPhoneNoUserAttributesCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource ReceivedQrUserAttributesCnt*/
				  SELECT 
						bdmtr.[Date]																												StreamDate,
						'UU'																														TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																							BasedReportTable,
						'ReceivedQrUserAttributesCnt'																										BasedReportTableField,
						'FACT_Transactions'																												Tested_DWH_Table,
						'FeatureType;RemittanceType;Method;User_Key'																				Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																														Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 7 AND RemittanceType = 0 AND l.Method = 3 THEN l.User_Key ELSE NULL END)'			Formula,
						'Total money transfer received by QrCode UU Cnt'																			MetricExplanation,
						admtr.ReceivedQrUserAttributesCnt																									CSHARP_TO_PROD_VIEW,
						bdmtr.ReceivedQrUserAttributesCnt																									PROD_TO_DWH_VIEW,  1 IsWarningField
			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource ReceivedQrUserAttributesCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource SendAcCntNoUserAttributesCnt*/
				  SELECT 
						bdmtr.[Date]																												StreamDate,
						'UU'																														TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																							BasedReportTable,
						'SendAcCntNoUserAttributesCnt'																								BasedReportTableField,
						'FACT_Transactions'																												Tested_DWH_Table,
						'FeatureType;RemittanceType;Method;Method;User_Key'																			Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																														Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 7 AND RemittanceType = 1 AND l.Method = 2 THEN l.User_Key ELSE NULL END)'			Formula,
						'Money transfer send by acCnt id unique user Cnt'																		MetricExplanation,
						admtr.SendAcCntNoUserAttributesCnt																							CSHARP_TO_PROD_VIEW,
						bdmtr.SendAcCntNoUserAttributesCnt																							PROD_TO_DWH_VIEW,  1 IsWarningField		
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource SendAcCntNoUserAttributesCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource SendPhoneNoUserAttributesCnt*/
				  SELECT 
						bdmtr.[Date]																												StreamDate,
						'UU'																														TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																							BasedReportTable,
						'SendPhoneNoUserAttributesCnt'																									BasedReportTableField,
						'FACT_Transactions'																												Tested_DWH_Table,
						'FeatureType;RemittanceType;Method;User_Key'																				Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																														Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 7 AND RemittanceType = 1 AND l.Method = 1 THEN l.User_Key ELSE NULL END)'			Formula,
						'Money transfer send by phone No unique user Cnt'																		MetricExplanation,
						admtr.SendPhoneNoUserAttributesCnt																								CSHARP_TO_PROD_VIEW,
						bdmtr.SendPhoneNoUserAttributesCnt																								PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource SendPhoneNoUserAttributesCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource SendQrUserAttributesCnt*/
				  SELECT 
						bdmtr.[Date]																												StreamDate,
						'UU'																														TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																							BasedReportTable,
						'SendQrUserAttributesCnt'																											BasedReportTableField,
						'FACT_Transactions'																												Tested_DWH_Table,
						'FeatureType;RemittanceType;Method;User_Key'																				Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																														Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 7 AND RemittanceType = 1 AND Method = 3 THEN User_Key ELSE NULL END)'				Formula,
						'Money transfer send by phone No UU Cnt'																				MetricExplanation,
						admtr.SendQrUserAttributesCnt																										CSHARP_TO_PROD_VIEW,
						bdmtr.SendQrUserAttributesCnt																										PROD_TO_DWH_VIEW,  1 IsWarningField	
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource SendQrUserAttributesCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource TotalRemittanceReqReceivedUserAttributesCnt*/
				  SELECT 
						bdmtr.[Date]																												StreamDate,
						'UU'																														TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																							BasedReportTable,
						'TotalRemittanceReqReceivedUserAttributesCnt'																						BasedReportTableField,
						'FACT_RemittanceReqs'																										Tested_DWH_Table,
						'User_Key'																													Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																														Value1,
						'Cnt(DISTINCT User_Key)'																									Formula,
						'Total money requested UU Cnt'																							MetricExplanation,
						admtr.TotalRemittanceReqReceivedUserAttributesCnt																					CSHARP_TO_PROD_VIEW,
						bdmtr.TotalRemittanceReqReceivedUserAttributesCnt																					PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource TotalRemittanceReqReceivedUserAttributesCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource TotalRemittanceReqSendUserAttributesCnt*/
				  SELECT 
						bdmtr.[Date]																												StreamDate,
						'UU'																														TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																							BasedReportTable,
						'TotalRemittanceReqSendUserAttributesCnt'																							BasedReportTableField,
						'FACT_Transactions'																												Tested_DWH_Table,
						'OtherUser_Key'																												Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																														Value1,
						'Cnt(DISTINCT OtherUser_Key)'																								Formula,
						'Total money request send UU Cnt'																							MetricExplanation,
						admtr.TotalRemittanceReqSendUserAttributesCnt																						CSHARP_TO_PROD_VIEW,
						bdmtr.TotalRemittanceReqSendUserAttributesCnt																						PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource TotalRemittanceReqSendUserAttributesCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource TotalRemittanceReqUserAttributesCnt*/
				  SELECT 
						bdmtr.[Date]																												StreamDate,
						'UU'																														TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																							BasedReportTable,
						'TotalRemittanceReqUserAttributesCnt'																								BasedReportTableField,
						'FACT_Transactions'																												Tested_DWH_Table,
						'User_Key'																													Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																														Value1,
						'Cnt(DISTINCT User_Key)'																									Formula,
						'Total money request UU Cnt'																								MetricExplanation,
						admtr.TotalRemittanceReqUserAttributesCnt																							CSHARP_TO_PROD_VIEW,
						bdmtr.TotalRemittanceReqUserAttributesCnt																							PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource TotalRemittanceReqUserAttributesCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource TotalRemittanceUserAttributesCnt*/
				  SELECT 
						bdmtr.[Date]																												StreamDate,
						'UU'																														TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																							BasedReportTable,
						'TotalRemittanceUserAttributesCnt'																								BasedReportTableField,
						'FACT_Transactions(l);FACT_RemittanceReqs(mr)'																						Tested_DWH_Table,
						'FeatureType;User_Key'																											Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																														Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 7 THEN User_Key ELSE NULL END)'														Formula,
						'Total money transfer UU Cnt'																								MetricExplanation,
						admtr.TotalRemittanceUserAttributesCnt																							CSHARP_TO_PROD_VIEW,
						bdmtr.TotalRemittanceUserAttributesCnt																							PROD_TO_DWH_VIEW,  1 IsWarningField	
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource TotalRemittanceUserAttributesCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource TotalReceivedRemittanceUserAttributesCnt*/
				  SELECT 
					bdmtr.[Date]																													StreamDate,
						'UU'																														TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																							BasedReportTable,
						'TotalReceivedRemittanceUserAttributesCnt'																						BasedReportTableField,
						'FACT_Transactions'																												Tested_DWH_Table,
						'FeatureType;RemittanceType;User_Key'																						Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																															Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 7 AND RemittanceType = 0 THEN User_Key ELSE NULL END)'								Formula,
						'Total money transfer received UU Cnt'																					MetricExplanation,
						admtr.TotalReceivedRemittanceUserAttributesCnt																					CSHARP_TO_PROD_VIEW,
						bdmtr.TotalReceivedRemittanceUserAttributesCnt																					PROD_TO_DWH_VIEW,  1 IsWarningField	
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource TotalReceivedRemittanceUserAttributesCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource TotalSendRemittanceUserAttributesCnt*/
				  SELECT 
						bdmtr.[Date]																														StreamDate,
						'UU'																																TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																									BasedReportTable,
						'TotalSendRemittanceUserAttributesCnt'																									BasedReportTableField,
						'FACT_Transactions'																														Tested_DWH_Table,
						'FeatureType;RemittanceType;User_Key'																								Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																															Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 7 AND RemittanceType = 1 THEN l.User_Key ELSE NULL END)'									Formula,
						'Total money transfer send UU'																										MetricExplanation,
						admtr.TotalSendRemittanceUserAttributesCnt																								CSHARP_TO_PROD_VIEW,
						bdmtr.TotalSendRemittanceUserAttributesCnt																								PROD_TO_DWH_VIEW,  1 IsWarningField	
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource TotalSendRemittanceUserAttributesCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource WithNoteCnt*/
				  SELECT 
						bdmtr.[Date]																																																 StreamDate,
						'Tx.#'																																																		 TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																																											 BasedReportTable,
						'WithNoteCnt'																																																 BasedReportTableField,
						'FACT_Transactions'																																																 Tested_DWH_Table,
						'FeatureType;RemittanceType;Description;Id'																																								 Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																															Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 7 AND RemittanceType = 1 AND ([Description] not like "Giden para transferi%" and [Description] IS NOT NULL  and LEN([Description]) != 0) THEN l.Id'  Formula,
						'Money transfer done by note Cnt'																																											 MetricExplanation,
						admtr.WithNoteCnt																																															 CSHARP_TO_PROD_VIEW,
						bdmtr.WithNoteCnt																																															 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource WithNoteCnt*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyRemittanceCSEntityDataSource WithNoteVol*/
				  SELECT 
						bdmtr.[Date]																																																StreamDate,
						'Tx.#'																																																		TestType,
						'FACT_DailyRemittanceCSEntityDataSource'																																											BasedReportTable,
						'WithNoteVol'																																															BasedReportTableField,
						'FACT_Transactions'																																																Tested_DWH_Table,
						'FeatureType;RemittanceType;Description;TxAmount'																																							Tested_DWH_Table_Field,
						bdmtr.Currency,
						'N/A'																															Value1,
						'ABS(SUM(CASE WHEN FeatureType = 7 AND RemittanceType = 1 AND ([Description] not like "Giden para transferi%" and [Description] IS NOT NULL  and LEN([Description]) != 0) THEN l.TxAmount'	Formula,
						'Money transfer done by note Vol'																																										MetricExplanation,
						admtr.WithNoteVol																																														CSHARP_TO_PROD_VIEW,
						bdmtr.WithNoteVol																																														PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource	bdmtr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource admtr on bdmtr.[Date] = admtr.[Date] AND bdmtr.Currency = admtr.Currency
			/*END-FACT_DailyRemittanceCSEntityDataSource WithNoteVol*/

			UNION ALL
			
			/*BEGIN-FACT_DailyUserAttributesCSEntityDataSource NewUserAttributes*/
				  SELECT 
						bdurA.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'NewUserAttributes'																																																	 BasedReportTableField,
						'DIM_UserAttributes;DIM_UserAttributes_Details'																																												 Tested_DWH_Table,
						'User_Key'																																																	 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'Cnt(User_Key)'																																															 Formula,
						'Daily new comers'																																															 MetricExplanation,
						adurA.NewUserAttributes																																																 CSHARP_TO_PROD_VIEW,
						bdurA.NewUserAttributes																																																 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A	bdurA
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurA.[Date] = adurA.[Date]
			/*END-FACT_DailyUserAttributesCSEntityDataSource NewUserAttributes*/

			UNION ALL
			
			/*BEGIN-FACT_DailyUserAttributesCSEntityDataSource NewUserAttributesOrganic*/
				  SELECT 
						bdurA.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'NewUserAttributesOrganic'																																															 BasedReportTableField,
						'DIM_UserAttributes;DIM_UserAttributes_Details'																																												 Tested_DWH_Table,
						'User_Key;InorganicSigninRefCode'																																												 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'Cnt(CASE WHEN InorganicSigninRefCode IS NULL THEN U.User_Key ELSE NULL END)'																																 Formula,
						'Daily organic new comers'																																													 MetricExplanation,
						adurA.NewUserAttributesOrganic																																														 CSHARP_TO_PROD_VIEW,
						bdurA.NewUserAttributesOrganic																																														 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A	bdurA
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurA.[Date] = adurA.[Date]
			/*END-FACT_DailyUserAttributesCSEntityDataSource NewUserAttributesOrganic*/

			UNION ALL
			
			/*BEGIN-FACT_DailyUserAttributesCSEntityDataSource NewUserAttributesMarketing*/
				  SELECT 
						bdurA.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'NewUserAttributesMarketing'																																															 BasedReportTableField,
						'DIM_UserAttributes;DIM_UserAttributes_Details'																																												 Tested_DWH_Table,
						'User_Key;InorganicSigninRefCode'																																												 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'Cnt(CASE WHEN SigninType = 0 AND InorganicSigninRefCode IS NOT NULL THEN U.User_Key ELSE NULL END)'																										 Formula,
						'Daily new comers with Marketing'																																											 MetricExplanation,
						adurA.NewUserAttributesMarketing																																														 CSHARP_TO_PROD_VIEW,
						bdurA.NewUserAttributesMarketing																																														 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A	bdurA
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurA.[Date] = adurA.[Date]
			/*END-FACT_DailyUserAttributesCSEntityDataSource NewUserAttributesMarketing*/

			UNION ALL
			
			/*BEGIN-FACT_DailyUserAttributesCSEntityDataSource BrowserRegistersOrganic*/
				  SELECT 
						bdurA.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'BrowserRegistersOrganic'																																														 BasedReportTableField,
						'DIM_UserAttributes;DIM_UserAttributes_Details'																																																	 Tested_DWH_Table,
						'SigninType;InorganicSigninRefCode;User_Key'																																								 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'Cnt(CASE WHEN SigninType = 0 AND InorganicSigninRefCode IS NULL THEN U.User_Key ELSE NULL END)'																											 Formula,
						'UserAttributes signed up via Browser organically'																																										 MetricExplanation,
						adurA.BrowserRegistersOrganic																																													 CSHARP_TO_PROD_VIEW,
						bdurA.BrowserRegistersOrganic																																													 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A	bdurA
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurA.[Date] = adurA.[Date]
			/*END-FACT_DailyUserAttributesCSEntityDataSource BrowserRegistersOrganic*/

			UNION ALL
			
			/*BEGIN-FACT_DailyUserAttributesCSEntityDataSource NewUserAttributesOrganic*/
				  SELECT 
						bdurA.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'BrowserRegistersMarketing'																																														 BasedReportTableField,
						'DIM_UserAttributes;DIM_UserAttributes_Details'																																																	 Tested_DWH_Table,
						'SigninType;InorganicSigninRefCode;User_Key'																																								 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'Cnt(CASE WHEN SigninType = 0 AND InorganicSigninRefCode IS NULL THEN U.User_Key ELSE NULL END)'																											 Formula,
						'UserAttributes signed up via Browser by Marketing'																																										 MetricExplanation,
						adurA.NewUserAttributesOrganic																																														 CSHARP_TO_PROD_VIEW,
						bdurA.NewUserAttributesOrganic																																														 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A	bdurA
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurA.[Date] = adurA.[Date]
			/*END-FACT_DailyUserAttributesCSEntityDataSource NewUserAttributesOrganic*/

			UNION ALL
			
			/*BEGIN-FACT_DailyUserAttributesCSEntityDataSource BrowserRegistersForm*/
				  SELECT 
						bdurA.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'BrowserRegistersForm'																																															 BasedReportTableField,
						'DIM_UserAttributes;DIM_UserAttributes_Details'																																																	 Tested_DWH_Table,
						'SigninMethod;SigninType;User_Key'																																										 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'Cnt(CASE WHEN SigninMethod = 0 ND SigninType = 0 THEN U.User_Key ELSE NULL END)'																														 Formula,
						'UserAttributes signed up via Browser with Form'																																											 MetricExplanation,
						adurA.BrowserRegistersForm																																														 CSHARP_TO_PROD_VIEW,
						bdurA.BrowserRegistersForm																																														 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A	bdurA
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurA.[Date] = adurA.[Date]
			/*END-FACT_DailyUserAttributesCSEntityDataSource BrowserRegistersForm*/

			UNION ALL
			
			/*BEGIN-FACT_DailyUserAttributesCSEntityDataSource BrowserRegistersGoogle*/
				  SELECT 
						bdurA.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'BrowserRegistersGoogle'																																														 BasedReportTableField,
						'DIM_UserAttributes;DIM_UserAttributes_Details'																																																	 Tested_DWH_Table,
						'SigninMethod;SigninType;User_Key'																																										 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'Cnt(CASE WHEN SigninMethod = 2 AND SigninType = 0 THEN User_Key ELSE NULL END)'																													 Formula,
						'UserAttributes signed up via Browser-Google'																																											 MetricExplanation,
						adurA.BrowserRegistersGoogle																																													 CSHARP_TO_PROD_VIEW,
						bdurA.BrowserRegistersGoogle																																													 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A	bdurA
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurA.[Date] = adurA.[Date]
			/*END-FACT_DailyUserAttributesCSEntityDataSource BrowserRegistersGoogle*/

			UNION ALL
			
			/*BEGIN-FACT_DailyUserAttributesCSEntityDataSource BrowserRegistersFacebook*/
				  SELECT 
						bdurA.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'BrowserRegistersFacebook'																																														 BasedReportTableField,
						'DIM_UserAttributes;DIM_UserAttributes_Details'																																																	 Tested_DWH_Table,
						'SigninMethod;SigninType;User_Key'																																										 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'Cnt(CASE WHEN SigninMethod = 1 AND SigninType = 0 THEN User_Key ELSE NULL END)'																														 Formula,
						'UserAttributes signed up via Browser-Facebook'																																											 MetricExplanation,
						adurA.BrowserRegistersFacebook																																													 CSHARP_TO_PROD_VIEW,
						bdurA.BrowserRegistersFacebook																																													 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A	bdurA
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurA.[Date] = adurA.[Date]
			/*END-FACT_DailyUserAttributesCSEntityDataSource BrowserRegistersFacebook*/

			UNION ALL
			
			/*BEGIN-FACT_DailyUserAttributesCSEntityDataSource MobileRegistersOrganic*/
				  SELECT 
						bdurA.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'MobileRegistersOrganic'																																													 BasedReportTableField,
						'DIM_UserAttributes;DIM_UserAttributes_Details'																																																	 Tested_DWH_Table,
						'SigninType;InorganicSigninRefCode;User_Key'																																								 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'Cnt(CASE WHEN SigninType IN (1,2) AND InorganicSigninRefCode IS NULL	THEN U.User_Key ELSE NULL END)'																										 Formula,
						'Organic registers by Mobile'																																												 MetricExplanation,
						adurA.MobileRegistersOrganic																																												 CSHARP_TO_PROD_VIEW,
						bdurA.MobileRegistersOrganic																																												 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A	bdurA
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurA.[Date] = adurA.[Date]
			/*END-FACT_DailyUserAttributesCSEntityDataSource MobileRegistersOrganic*/

			UNION ALL
			
			/*BEGIN-FACT_DailyUserAttributesCSEntityDataSource MobileRegistersMarketing*/
				  SELECT 
						bdurA.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'MobileRegistersMarketing'																																													 BasedReportTableField,
						'DIM_UserAttributes;DIM_UserAttributes_Details'																																																	 Tested_DWH_Table,
						'SigninType;InorganicSigninRefCode;User_Key'																																								 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'Cnt(CASE WHEN SigninType IN (1,2) AND InorganicSigninRefCode IS NOT NULL THEN U.User_Key ELSE NULL END)'																									 Formula,
						'Mobile registers with marketing'																																											 MetricExplanation,
						adurA.MobileRegistersMarketing																																												 CSHARP_TO_PROD_VIEW,
						bdurA.MobileRegistersMarketing																																												 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A	bdurA
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurA.[Date] = adurA.[Date]
			/*END-FACT_DailyUserAttributesCSEntityDataSource MobileRegistersMarketing*/

			UNION ALL
			
			/*BEGIN-FACT_DailyUserAttributesCSEntityDataSource IosRegistersForm*/
				  SELECT 
						bdurA.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'IosRegistersForm'																																															 BasedReportTableField,
						'DIM_UserAttributes;DIM_UserAttributes_Details'																																																	 Tested_DWH_Table,
						'SigninMethod;SigninType;User_Key'																																										 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'Cnt(CASE WHEN SigninMethod = 0 AND SigninType = 1 THEN U.User_Key ELSE NULL END)'																														 Formula,
						'IOS Registers via Form'																																													 MetricExplanation,
						adurA.IosRegistersForm																																														 CSHARP_TO_PROD_VIEW,
						bdurA.IosRegistersForm																																														 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A	  bdurA
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurA.[Date] = adurA.[Date]
			/*END-FACT_DailyUserAttributesCSEntityDataSource IosRegistersForm*/

			UNION ALL
			
			/*BEGIN-FACT_DailyUserAttributesCSEntityDataSource IosRegistersFacebook*/
				  SELECT 
						bdurA.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'IosRegistersFacebook'																																														 BasedReportTableField,
						'DIM_UserAttributes;DIM_UserAttributes_Details'																																																	 Tested_DWH_Table,
						'SigninMethod;SigninType;User_Key'																																										 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'Cnt(CASE WHEN SigninMethod = 1 AND SigninType = 1 THEN U.User_Key ELSE NULL END)'																														 Formula,
						'IOS Registers via Facebook'																																												 MetricExplanation,
						adurA.IosRegistersFacebook																																													 CSHARP_TO_PROD_VIEW,
						bdurA.IosRegistersFacebook																																													 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A	  bdurA
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurA.[Date] = adurA.[Date]
			/*END-FACT_DailyUserAttributesCSEntityDataSource IosRegistersFacebook*/

			UNION ALL
			
			/*BEGIN-FACT_DailyUserAttributesCSEntityDataSource IosRegistersApple*/
				  SELECT 
						bdurA.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'IosRegistersApple'																																															 BasedReportTableField,
						'DIM_UserAttributes;DIM_UserAttributes_Details'																																																	 Tested_DWH_Table,
						'SigninMethod;SigninType;User_Key'																																										 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'Cnt(CASE WHEN SigninMethod = 3 AND SigninType = 1 THEN U.User_Key ELSE NULL END)'																														 Formula,
						'IOS Registers via Apple platform'																																											 MetricExplanation,
						adurA.IosRegistersApple																																														 CSHARP_TO_PROD_VIEW,
						bdurA.IosRegistersApple																																														 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A	  bdurA
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurA.[Date] = adurA.[Date]
			/*END-FACT_DailyUserAttributesCSEntityDataSource IosRegistersApple*/

			UNION ALL
			
			/*BEGIN-FACT_DailyUserAttributesCSEntityDataSource AndroidRegistersForm*/
				  SELECT 
						bdurA.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'AndroidRegistersForm'																																														 BasedReportTableField,
						'DIM_UserAttributes;DIM_UserAttributes_Details'																																																	 Tested_DWH_Table,
						'SigninMethod;SigninType;User_Key'																																										 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'Cnt(CASE WHEN SigninMethod = 0 AND SigninType = 2 THEN U.User_Key ELSE NULL END)'																														 Formula,
						'Android Registers via Form'																																												 MetricExplanation,
						adurA.AndroidRegistersForm																																													 CSHARP_TO_PROD_VIEW,
						bdurA.AndroidRegistersForm																																													 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A	  bdurA
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurA.[Date] = adurA.[Date]
			/*END-FACT_DailyUserAttributesCSEntityDataSource AndroidRegistersForm*/

			UNION ALL
			
			/*BEGIN-FACT_DailyUserAttributesCSEntityDataSource AndroidRegistersGoogle*/
				  SELECT 
						bdurA.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'AndroidRegistersGoogle'																																													 BasedReportTableField,
						'DIM_UserAttributes;DIM_UserAttributes_Details'																																																	 Tested_DWH_Table,
						'SigninMethod;SigninType;User_Key'																																										 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'Cnt(CASE WHEN SigninMethod = 2 AND SigninType = 2 THEN U.User_Key ELSE NULL END)'																														 Formula,
						'Android Registers via Google'																																												 MetricExplanation,
						adurA.AndroidRegistersGoogle																																												 CSHARP_TO_PROD_VIEW,
						bdurA.AndroidRegistersGoogle																																												 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A	  bdurA
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurA.[Date] = adurA.[Date]
			/*END-FACT_DailyUserAttributesCSEntityDataSource AndroidRegistersGoogle*/


			UNION ALL
			
			/*BEGIN-FACT_FACT_DailyUserAttributesCSEntityDataSource AndroidRegistersFacebook*/
				  SELECT 
						bdurA.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'AndroidRegistersFacebook'																																													 BasedReportTableField,
						'DIM_UserAttributes;DIM_UserAttributes_Details'																																																	 Tested_DWH_Table,
						'SigninMethod;SigninType;User_Key'																																										 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'Cnt(CASE WHEN SigninMethod = 1 AND SigninType = 2 THEN U.User_Key ELSE NULL END)'																														 Formula,
						'Android Registers via Facebook'																																											 MetricExplanation,
						adurA.AndroidRegistersFacebook																																												 CSHARP_TO_PROD_VIEW,
						bdurA.AndroidRegistersFacebook																																												 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A	  bdurA
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurA.[Date] = adurA.[Date]
			/*END-FACT_DailyUserAttributesCSEntityDataSource AndroidRegistersFacebook*/

			UNION ALL
			
			/*BEGIN-FACT_DailyUserAttributesCSEntityDataSource HuaweiRegistersForm*/
				  SELECT 
						bdurA.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'HuaweiRegistersForm'																																														 BasedReportTableField,
						'DIM_UserAttributes;DIM_UserAttributes_Details'																																																	 Tested_DWH_Table,
						'SigninMethod;SigninType;User_Key'																																										 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'Cnt(CASE WHEN SigninMethod = 0 AND SigninType = 2 THEN U.User_Key ELSE NULL END)'																														 Formula,
						'Huawei Registers via Form'																																													MetricExplanation,
						adurA.HuaweiRegistersForm																																													 CSHARP_TO_PROD_VIEW,
						bdurA.HuaweiRegistersForm																																													 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A	  bdurA
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurA.[Date] = adurA.[Date]
			/*END-FACT_DailyUserAttributesCSEntityDataSource HuaweiRegistersForm*/

			UNION ALL
			
			/*BEGIN-FACT_DailyUserAttributesCSEntityDataSource HuaweiRegistersGoogle*/
				  SELECT 
						bdurA.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'HuaweiRegistersGoogle'																																														 BasedReportTableField,
						'DIM_UserAttributes;DIM_UserAttributes_Details'																																																	 Tested_DWH_Table,
						'SigninMethod;SigninType;User_Key'																																										 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'Cnt(CASE WHEN SigninMethod = 2 AND SigninType = 2 THEN U.User_Key ELSE NULL END)'																														 Formula,
						'Huawei Registers via Google'																																												 MetricExplanation,
						adurA.HuaweiRegistersGoogle																																													 CSHARP_TO_PROD_VIEW,
						bdurA.HuaweiRegistersGoogle																																													 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A	  bdurA
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurA.[Date] = adurA.[Date]
			/*END-FACT_DailyUserAttributesCSEntityDataSource HuaweiRegistersGoogle*/


			UNION ALL
			
			/*BEGIN-FACT_DailyUserAttributesCSEntityDataSource HuaweiRegistersFacebook*/
				  SELECT 
						bdurA.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'HuaweiRegistersFacebook'																																													 BasedReportTableField,
						'DIM_UserAttributes;DIM_UserAttributes_Details'																																																	 Tested_DWH_Table,
						'SigninMethod;SigninType;User_Key'																																										 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'Cnt(CASE WHEN SigninMethod = 1 AND SigninType = 2 THEN U.User_Key ELSE NULL END)'																														 Formula,
						'Huawei Registers via Facebook'																																												 MetricExplanation,
						adurA.HuaweiRegistersFacebook																																												 CSHARP_TO_PROD_VIEW,
						bdurA.HuaweiRegistersFacebook																																												 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A	  bdurA
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurA.[Date] = adurA.[Date]
			/*END-FACT_DailyRemittanceCSEntityDataSource HuaweiRegistersFacebook*/

			UNION ALL
			
			/*BEGIN-FACT_DailyUserAttributesCSEntityDataSource ActiveLoginDailyCnt*/
				  SELECT 
						bdurB.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'ActiveLoginDailyCnt'																																														 BasedReportTableField,
						'FACT_UserLogins'																																															 Tested_DWH_Table,
						'User_Key'																																										 							 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'Cnt(DISTINCT User_Key)'																														 															 Formula,
						'Daily UU Login Cnt'																																												 		 MetricExplanation,
						adurA.ActiveLoginDailyCnt																																												 	 CSHARP_TO_PROD_VIEW,
						bdurB.ActiveLoginDailyCnt																																												 	 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_B	  bdurB
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurB.[Date] = adurA.[Date]
			/*END-FACT_DailyRemittanceCSEntityDataSource ActiveLoginDailyCnt*/

			UNION ALL
			
			/*BEGIN-FACT_DailyUserAttributesCSEntityDataSource ActiveFinancialTransactionDailyCnt*/
				  SELECT 
						 bdurC.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'ActiveFinancialTransactionDailyCnt'																																										 BasedReportTableField,
						'FACT_Transactions'																																																 Tested_DWH_Table,
						'User_Key'																																										 							 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'Cnt(distinct User_Key)'																														 															 Formula,
						'Financially active UserAttributes (1=<Tx)'																																											 MetricExplanation,
						 adurA.ActiveFinancialTransactionDailyCnt																																									 CSHARP_TO_PROD_VIEW,
						 bdurC.ActiveFinancialTransactionDailyCnt																																									 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_C	  bdurC
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurC.[Date] = adurA.[Date]
			/*END-FACT_DailyUserAttributesCSEntityDataSource ActiveFinancialTransactionDailyCnt*/


			UNION ALL
			
			/*BEGIN-FACT_DailyUserAttributesCSEntityDataSource TotalUserAttributes*/
				  SELECT 
						 bdurD.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'TotalUserAttributes'																																										 						 BasedReportTableField,
						'DIM_UserAttributes'																																																 	 Tested_DWH_Table,
						'User_Key'																																										 							 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'SUM(Cnt(User_Key)) OVER (PARTITION BY "Manipulated for Running Total - SK" order by CAST(CreatedAt AS DATE))'																							 Formula,
						'Total User #'																																											 					 MetricExplanation,
						 adurA.TotalUserAttributes																																									 						 CSHARP_TO_PROD_VIEW,
						 bdurD.TotalUserAttributes																																														 	 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_D	  bdurD
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurD.[Date] = adurA.[Date]
			/*END-FACT_DailyUserAttributesCSEntityDataSource TotalUserAttributes*/

			UNION ALL
			
			/*BEGIN-FACT_DailyUserAttributesCSEntityDataSource NewApprovedUserAttributesAverageAge*/
				  SELECT 
						 bdurE.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'NewApprovedUserAttributesAverageAge'																																										 		 BasedReportTableField,
						'DIM_UserAttributes;FACT_UserIdentityRegistrations'																																									 Tested_DWH_Table,
						'DateOfBirth'																																										 						 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'AVG(DATEDIFF(YEAR,U.DateOfBirth,TodayTestDate)'																																							 Formula,
						'Total Approved User #'																																											 			 MetricExplanation,
						 adurA.NewApprovedUserAttributesAverageAge																																									 		 CSHARP_TO_PROD_VIEW,
						 bdurE.NewApprovedUserAttributesAverageAge																																											 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_E	  bdurE
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurE.[Date] = adurA.[Date]
			/*END-FACT_DailyUserAttributesCSEntityDataSource NewApprovedUserAttributesAverageAge*/
			UNION ALL
			
			/*BEGIN-FACT_DailyUserAttributesCSEntityDataSource AcceptanceMethodForeignIdentity*/
				  SELECT 
						 bdurE.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'AcceptanceMethodForeignIdentity'																																										 		 BasedReportTableField,
						'DIM_UserAttributes;FACT_UserIdentityRegistrations'																																									 Tested_DWH_Table,
						'ApprovalType;User_Key'																																										 				 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'Cnt(DISTINCT CASE WHEN u.ApprovalType = 3 THEN u.User_Key ELSE NULL END)'																																 Formula,
						'User # Approved with Foreign Id'																																											 MetricExplanation,
						 adurA.AcceptanceMethodForeignIdentity																																									 	 CSHARP_TO_PROD_VIEW,
						 bdurE.AcceptanceMethodForeignIdentity																																										 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_E	  bdurE
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurE.[Date] = adurA.[Date]
			/*END-FACT_DailyUserAttributesCSEntityDataSource AcceptanceMethodForeignIdentity*/
			
			
			
			UNION ALL
			
			/*BEGIN-FACT_DailyUserAttributesCSEntityDataSource AcceptanceMethodIdentity*/
				  SELECT 
						 bdurE.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'AcceptanceMethodIdentity'																																										 			 BasedReportTableField,
						'DIM_UserAttributes;FACT_UserIdentityRegistrations'																																									 Tested_DWH_Table,
						'ApprovalType;User_Key'																																										 				 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'Cnt(DISTINCT CASE WHEN u.ApprovalType = 2 THEN u.User_Key ELSE NULL END)'																																 Formula,
						'User # Approved with Old Id'																																											 	 MetricExplanation,
						 adurA.AcceptanceMethodIdentity																																									 		 	 CSHARP_TO_PROD_VIEW,
						 bdurE.AcceptanceMethodIdentity																																											 	 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_E	  bdurE
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurE.[Date] = adurA.[Date]
			/*END-FACT_DailyUserAttributesCSEntityDataSource AcceptanceMethodIdentity*/

			UNION ALL
			
			/*BEGIN-FACT_DailyUserAttributesCSEntityDataSource AcceptanceMethodTCKK*/
				  SELECT 
						 bdurE.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyUserAttributesCSEntityDataSource'																																													 BasedReportTable,
						'AcceptanceMethodTCKK'																																										 				 BasedReportTableField,
						'DIM_UserAttributes;FACT_UserIdentityRegistrations'																																									 Tested_DWH_Table,
						'ApprovalType;User_Key'																																										 				 Tested_DWH_Table_Field,
						-1																																																			 Currency,
						'N/A'																																																		 Value1,
						'Cnt(DISTINCT CASE WHEN u.ApprovalType = 1 THEN u.User_Key ELSE NULL END)'																																 Formula,
						'User # Approved with New Id'																																											 	 MetricExplanation,
						 adurA.AcceptanceMethodTCKK																																									 		 		 CSHARP_TO_PROD_VIEW,
						 bdurE.AcceptanceMethodTCKK																																											 		 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_E	  bdurE
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A adurA on bdurE.[Date] = adurA.[Date]
			/*END-FACT_DailyUserAttributesCSEntityDataSource AcceptanceMethodTCKK*/
			UNION ALL
			
			/*BEGIN-FACT_DailyPersonalCommercialCSEntityDataSource PaidUniqueUserCntDaily*/
				  SELECT 
						 bdpcr.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyPersonalCommercialCSEntityDataSource'																																										 BasedReportTable,
						'PaidUniqueUserCntDaily'																																										 			 BasedReportTableField,
						'FACT_Transactions;DIM_UserAttributes;DIM_JobTypes'																																										 Tested_DWH_Table,
						'OtherUser_Key;IsCommercial;JobType'																																											 Tested_DWH_Table_Field,
						0																																																			 Currency,
						 bdpcr.JobTypeName																																															 Value1,
						'Cnt(DISTINCT l.OtherUser_Key)'																																											 Formula,
						'Paid UU Daily Cnt'																																											 			 MetricExplanation,
						 adpcr.PaidUniqueUserCntDaily																																									 			 CSHARP_TO_PROD_VIEW,
						 bdpcr.PaidUniqueUserCntDaily																																												 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource	  bdpcr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource  adpcr on bdpcr.[Date] = adpcr.[Date] AND bdpcr.JobTypeName = adpcr.JobTypeName
			/*END-FACT_DailyPersonalCommercialCSEntityDataSource PaidUniqueUserCntDaily*/

			UNION ALL
			
			/*BEGIN-FACT_DailyPersonalCommercialCSEntityDataSource PaidUniqueUserWithAcCntCntDaily*/
				  SELECT 
						 bdpcr.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyPersonalCommercialCSEntityDataSource'																																										 BasedReportTable,
						'PaidUniqueUserWithAcCntCntDaily'																																										 BasedReportTableField,
						'FACT_Transactions;DIM_UserAttributes;DIM_JobTypes'																																										 Tested_DWH_Table,
						'OtherUser_Key;FeatureType;IsCommercial'																																										 Tested_DWH_Table_Field,
						0																																																			 Currency,
						 bdpcr.JobTypeName																																															 Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 7 and IsCommercial = 1 THEN l.OtherUser_Key	ELSE NULL END)'																											 Formula,
						'Daily UU Cnt paid with acCnt'																																											 MetricExplanation,
						 adpcr.PaidUniqueUserWithAcCntCntDaily																																									 CSHARP_TO_PROD_VIEW,
						 bdpcr.PaidUniqueUserWithAcCntCntDaily																																									 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource	  bdpcr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource  adpcr on bdpcr.[Date] = adpcr.[Date] AND bdpcr.JobTypeName = adpcr.JobTypeName
			/*END-FACT_DailyPersonalCommercialCSEntityDataSource PaidUniqueUserWithAcCntCntDaily*/
			UNION ALL
			
			/*BEGIN-FACT_DailyPersonalCommercialCSEntityDataSource PaidUniqueUserWithCardCntDaily*/
				  SELECT 
						 bdpcr.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyPersonalCommercialCSEntityDataSource'																																										 BasedReportTable,
						'PaidUniqueUserWithCardCntDaily'																																											 BasedReportTableField,
						'FACT_Transactions;DIM_UserAttributes;DIM_JobTypes'																																										 Tested_DWH_Table,
						'OtherUser_Key;FeatureType;IsCommercial'																																										 Tested_DWH_Table_Field,
						0																																																			 Currency,
						 bdpcr.JobTypeName																																															 Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 20 THEN l.OtherUser_Key ELSE NULL END)'																																 Formula,
						'Daily UU Cnt paid with Database Card'																																										 MetricExplanation,
						 adpcr.PaidUniqueUserWithCardCntDaily																																									 	 CSHARP_TO_PROD_VIEW,
						 bdpcr.PaidUniqueUserWithCardCntDaily																																										 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource	  bdpcr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource  adpcr on bdpcr.[Date] = adpcr.[Date] AND bdpcr.JobTypeName = adpcr.JobTypeName
			/*END-FACT_DailyPersonalCommercialCSEntityDataSource PaidUniqueUserWithCardCntDaily*/

			UNION ALL
			
			/*BEGIN-FACT_DailyPersonalCommercialCSEntityDataSource ReceivingCntToAcCntWithAcCnt*/
				  SELECT 
						 bdpcr.[Date]																																																 StreamDate,
						'Tx.#'																																																		 TestType,
						'FACT_DailyPersonalCommercialCSEntityDataSource'																																										 BasedReportTable,
						'ReceivingCntToAcCntWithAcCnt'																																										 BasedReportTableField,
						'FACT_Transactions;DIM_UserAttributes;DIM_JobTypes'																																										 Tested_DWH_Table,
						'Id;FeatureType;IsCommercial'																																													 Tested_DWH_Table_Field,
						0																																																			 Currency,
						 bdpcr.JobTypeName																																															 Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 7 AND Method = 2 THEN l.Id ELSE NULL END)'																															 Formula,
						'Daily Tx Cnt paid with acCnt to commercial acCnts'																																					 MetricExplanation,
						 adpcr.ReceivingCntToAcCntWithAcCnt																																									 CSHARP_TO_PROD_VIEW,
						 bdpcr.ReceivingCntToAcCntWithAcCnt																																									 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource	  bdpcr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource  adpcr on bdpcr.[Date] = adpcr.[Date] AND bdpcr.JobTypeName = adpcr.JobTypeName
			/*END-FACT_DailyPersonalCommercialCSEntityDataSource ReceivingCntToAcCntWithAcCnt*/

			UNION ALL

			/*BEGIN-FACT_DailyPersonalCommercialCSEntityDataSource ReceivingCntToAcCntWithCard*/
				  SELECT 
						 bdpcr.[Date]																																																 StreamDate,
						'Tx.#'																																																		 TestType,
						'FACT_DailyPersonalCommercialCSEntityDataSource'																																										 BasedReportTable,
						'ReceivingCntToAcCntWithCard'																																											 BasedReportTableField,
						'FACT_Transactions;DIM_UserAttributes;DIM_JobTypes'																																										 Tested_DWH_Table,
						'Id;FeatureType;IsCommercial'																																													 Tested_DWH_Table_Field,
						0																																																			 Currency,
						 bdpcr.JobTypeName																																															 Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 20 AND Method = 1 THEN l.Id ELSE NULL END)'																															 Formula,
						'Daily Tx Cnt paid with Mobile Phone with Database Card to commercial acCnts'																																 MetricExplanation,
						 adpcr.ReceivingCntToAcCntWithCard																																									 	 CSHARP_TO_PROD_VIEW,
						 bdpcr.ReceivingCntToAcCntWithCard																																										 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource	  bdpcr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource  adpcr on bdpcr.[Date] = adpcr.[Date] AND bdpcr.JobTypeName = adpcr.JobTypeName
			/*END-FACT_DailyPersonalCommercialCSEntityDataSource PaidUniqueUserWithAcCntCntDaily*/

			UNION ALL
			
			/*BEGIN-FACT_DailyPersonalCommercialCSEntityDataSource ReceivingCntToMobileWithAcCnt*/
				  SELECT 
						 bdpcr.[Date]																																																 StreamDate,
						'Tx.#'																																																		 TestType,
						'FACT_DailyPersonalCommercialCSEntityDataSource'																																										 BasedReportTable,
						'ReceivingCntToMobileWithAcCnt'																																											 BasedReportTableField,
						'FACT_Transactions;DIM_UserAttributes;DIM_JobTypes'																																										 Tested_DWH_Table,
						'Id;FeatureType;IsCommercial'																																													 Tested_DWH_Table_Field,
						0																																																			 Currency,
						 bdpcr.JobTypeName																																															 Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 7 AND Method = 1	THEN l.Id ELSE NULL END)'																															 Formula,
						'Daily Tx Cnt paid with Mobile Phone to commercial acCnts'																																				 MetricExplanation,
						 adpcr.ReceivingCntToMobileWithAcCnt																																									 CSHARP_TO_PROD_VIEW,
						 bdpcr.ReceivingCntToMobileWithAcCnt																																									 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource	  bdpcr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource  adpcr on bdpcr.[Date] = adpcr.[Date] AND bdpcr.JobTypeName = adpcr.JobTypeName
			/*END-FACT_DailyPersonalCommercialCSEntityDataSource ReceivingCntToMobileWithAcCnt*/

			UNION ALL
			
			/*BEGIN-FACT_DailyPersonalCommercialCSEntityDataSource ReceivingCntToMobileWithCard*/
				  SELECT 
						 bdpcr.[Date]																																																 StreamDate,
						'Tx.#'																																																		 TestType,
						'FACT_DailyPersonalCommercialCSEntityDataSource'																																										 BasedReportTable,
						'ReceivingCntToMobileWithCard'																																											 BasedReportTableField,
						'FACT_Transactions;DIM_UserAttributes;DIM_JobTypes'																																										 Tested_DWH_Table,
						'Id;FeatureType;IsCommercial'																																													 Tested_DWH_Table_Field,
						0																																																			 Currency,
						 bdpcr.JobTypeName																																															 Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 20 AND Method = 1	THEN l.Id ELSE NULL END)'																															 Formula,
						'Daily Tx Cnt paid with Mobile Phone by Card to commercial acCnts'																																		 MetricExplanation,
						 adpcr.ReceivingCntToMobileWithCard																																									 	 CSHARP_TO_PROD_VIEW,
						 bdpcr.ReceivingCntToMobileWithCard																																										 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource	  bdpcr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource  adpcr on bdpcr.[Date] = adpcr.[Date] AND bdpcr.JobTypeName = adpcr.JobTypeName
			/*END-FACT_DailyPersonalCommercialCSEntityDataSource ReceivingCntToMobileWithCard*/

			UNION ALL
			
			/*BEGIN-FACT_DailyPersonalCommercialCSEntityDataSource ReceivingCntToQrCodeWithAcCnt*/
				  SELECT 
						 bdpcr.[Date]																																																 StreamDate,
						'Tx.#'																																																		 TestType,
						'FACT_DailyPersonalCommercialCSEntityDataSource'																																										 BasedReportTable,
						'ReceivingCntToQrCodeWithAcCnt'																																											 BasedReportTableField,
						'FACT_Transactions;DIM_UserAttributes;DIM_JobTypes'																																										 Tested_DWH_Table,
						'Id;FeatureType;IsCommercial'																																													 Tested_DWH_Table_Field,
						0																																																			 Currency,
						 bdpcr.JobTypeName																																															 Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 7 AND Method = 3	THEN l.Id ELSE NULL END)'																															 Formula,
						'Daily Tx Cnt paid by QR code with AcCnt to commercial acCnts'																																		 MetricExplanation,
						 adpcr.ReceivingCntToQrCodeWithAcCnt																																									 CSHARP_TO_PROD_VIEW,
						 bdpcr.ReceivingCntToQrCodeWithAcCnt																																									 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource	  bdpcr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource  adpcr on bdpcr.[Date] = adpcr.[Date] AND bdpcr.JobTypeName = adpcr.JobTypeName
			/*END-FACT_DailyPersonalCommercialCSEntityDataSource ReceivingCntToQrCodeWithAcCnt*/

			UNION ALL
			
			/*BEGIN-FACT_DailyPersonalCommercialCSEntityDataSource ReceivingCntToQrCodeWithCard*/
				  SELECT 
						 bdpcr.[Date]																																																 StreamDate,
						'Tx.#'																																																		 TestType,
						'FACT_DailyPersonalCommercialCSEntityDataSource'																																										 BasedReportTable,
						'ReceivingCntToQrCodeWithCard'																																											 BasedReportTableField,
						'FACT_Transactions;DIM_UserAttributes;DIM_JobTypes'																																										 Tested_DWH_Table,
						'Id;FeatureType;IsCommercial'																																													 Tested_DWH_Table_Field,
						 0																																																			 Currency,
						 bdpcr.JobTypeName																																															 Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 20 AND Method = 3	THEN l.Id ELSE NULL END)'																															 Formula,
						'Daily Tx Cnt paid by QR code with Database Card to commercial acCnts'																																	 MetricExplanation,
						 adpcr.ReceivingCntToQrCodeWithCard																																									 	 CSHARP_TO_PROD_VIEW,
						 bdpcr.ReceivingCntToQrCodeWithCard																																										 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource	  bdpcr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource  adpcr on bdpcr.[Date] = adpcr.[Date] AND bdpcr.JobTypeName = adpcr.JobTypeName
			/*END-FACT_DailyPersonalCommercialCSEntityDataSource ReceivingCntToQrCodeWithCard*/
			UNION ALL
			
			/*BEGIN-FACT_DailyPersonalCommercialCSEntityDataSource ReceivingVolToAcCntWithAcCnt*/
				  SELECT 
						 bdpcr.[Date]																																																 StreamDate,
						'V.'																																																		 TestType,
						'FACT_DailyPersonalCommercialCSEntityDataSource'																																										 BasedReportTable,
						'ReceivingVolToAcCntWithAcCnt'																																										 BasedReportTableField,
						'FACT_Transactions;DIM_UserAttributes;DIM_JobTypes'																																										 Tested_DWH_Table,
						'TxAmount;FeatureType;Method'																																													 Tested_DWH_Table_Field,
						0																																																			 Currency,
						 bdpcr.JobTypeName																																															 Value1,
						'SUM(CASE WHEN FeatureType = 7 AND Method = 2 THEN l.TxAmount ELSE NULL END)'																																	 Formula,
						'Daily Vol of tx paid by acCnt with acCnt to commercial acCnts'																																	 MetricExplanation,
						 adpcr.ReceivingVolToAcCntWithAcCnt																																									 CSHARP_TO_PROD_VIEW,
						 bdpcr.ReceivingVolToAcCntWithAcCnt																																									 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource	  bdpcr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource  adpcr on bdpcr.[Date] = adpcr.[Date] AND bdpcr.JobTypeName = adpcr.JobTypeName
			/*END-FACT_DailyPersonalCommercialCSEntityDataSource ReceivingVolToAcCntWithAcCnt*/

			UNION ALL
			
			/*BEGIN-FACT_DailyPersonalCommercialCSEntityDataSource ReceivingVolToAcCntWithCard*/
				  SELECT 
						 bdpcr.[Date]																																																 StreamDate,
						'V.'																																																		 TestType,
						'FACT_DailyPersonalCommercialCSEntityDataSource'																																										 BasedReportTable,
						'ReceivingVolToAcCntWithCard'																																											 BasedReportTableField,
						'FACT_Transactions;DIM_UserAttributes;DIM_JobTypes'																																										 Tested_DWH_Table,
						'TxAmount;FeatureType;Method'																																													 Tested_DWH_Table_Field,
						0																																																			 Currency,
						 bdpcr.JobTypeName																																															 Value1,
						'SUM(CASE WHEN FeatureType = 20 AND Method = 2 THEN l.TxAmount ELSE NULL END)'																																	 Formula,
						'Daily Vol of tx paid by phone with Database Card to commercial acCnts'																																	 MetricExplanation,
						 adpcr.ReceivingVolToAcCntWithCard																																									 	 CSHARP_TO_PROD_VIEW,
						 bdpcr.ReceivingVolToAcCntWithCard																																										 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource	  bdpcr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource  adpcr on bdpcr.[Date] = adpcr.[Date] AND bdpcr.JobTypeName = adpcr.JobTypeName
			/*END-FACT_DailyPersonalCommercialCSEntityDataSource ReceivingVolToAcCntWithCard*/

			UNION ALL
			
			/*BEGIN-FACT_DailyPersonalCommercialCSEntityDataSource ReceivingVolToMobileWithAcCnt*/
				  SELECT 
						 bdpcr.[Date]																																																 StreamDate,
						'V.'																																																		 TestType,
						'FACT_DailyPersonalCommercialCSEntityDataSource'																																										 BasedReportTable,
						'ReceivingVolToMobileWithAcCnt'																																										 BasedReportTableField,
						'FACT_Transactions;DIM_UserAttributes;DIM_JobTypes'																																										 Tested_DWH_Table,
						'TxAmount;FeatureType;Method'																																													 Tested_DWH_Table_Field,
						0																																																			 Currency,
						 bdpcr.JobTypeName																																															 Value1,
						'SUM(CASE WHEN FeatureType = 7 AND Method = 1	THEN l.TxAmount ELSE NULL END)'																																	 Formula,
						'Daily Vol of transactions paid by phone with acCnt to commercial acCnts'																															 MetricExplanation,
						 adpcr.ReceivingVolToMobileWithAcCnt																																									 CSHARP_TO_PROD_VIEW,
						 bdpcr.ReceivingVolToMobileWithAcCnt																																									 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource	  bdpcr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource  adpcr on bdpcr.[Date] = adpcr.[Date] AND bdpcr.JobTypeName = adpcr.JobTypeName
			/*END-FACT_DailyPersonalCommercialCSEntityDataSource ReceivingVolToMobileWithAcCnt*/

			UNION ALL
			
			/*BEGIN-FACT_DailyPersonalCommercialCSEntityDataSource ReceivingVolToMobileWithCard*/
				  SELECT 
						 bdpcr.[Date]																																																 StreamDate,
						'V.'																																																		 TestType,
						'FACT_DailyPersonalCommercialCSEntityDataSource'																																										 BasedReportTable,
						'ReceivingVolToMobileWithCard'																																											 BasedReportTableField,
						'FACT_Transactions;DIM_UserAttributes;DIM_JobTypes'																																										 Tested_DWH_Table,
						'TxAmount;FeatureType;Method'																																													 Tested_DWH_Table_Field,
						0																																																			 Currency,
						 bdpcr.JobTypeName																																															 Value1,
						'SUM(CASE WHEN FeatureType = 20 AND Method = 1 THEN l.TxAmount ELSE NULL END)'																																	 Formula,
						'Daily Vol of transactions paid by phone with card to commercial acCnts'																																 MetricExplanation,
						 adpcr.ReceivingVolToMobileWithCard																																									 	 CSHARP_TO_PROD_VIEW,
						 bdpcr.ReceivingVolToMobileWithCard																																										 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource	  bdpcr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource  adpcr on bdpcr.[Date] = adpcr.[Date] AND bdpcr.JobTypeName = adpcr.JobTypeName
			/*END-FACT_DailyPersonalCommercialCSEntityDataSource ReceivingVolToMobileWithCard*/

UNION ALL

			/*BEGIN-FACT_DailyPersonalCommercialCSEntityDataSource ReceivingVolToQrCodeWithAcCnt*/
				  SELECT 
						 bdpcr.[Date]																																																 StreamDate,
						'V.'																																																		 TestType,
						'FACT_DailyPersonalCommercialCSEntityDataSource'																																										 BasedReportTable,
						'ReceivingVolToQrCodeWithAcCnt'																																										 BasedReportTableField,
						'FACT_Transactions;DIM_UserAttributes;DIM_JobTypes'																																										 Tested_DWH_Table,
						'TxAmount;FeatureType;Method'																																													 Tested_DWH_Table_Field,
						0																																																			 Currency,
						 bdpcr.JobTypeName																																															 Value1,
						'SUM(CASE WHEN FeatureType = 7 AND Method = 3 THEN l.TxAmount ELSE NULL END)'																																	 Formula,
						'Daily Vol of transactions paid by QR code with acCnt to commercial acCnts'																															 MetricExplanation,
						 adpcr.ReceivingVolToQrCodeWithAcCnt																																									 CSHARP_TO_PROD_VIEW,
						 bdpcr.ReceivingVolToQrCodeWithAcCnt																																									 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource	  bdpcr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource  adpcr on bdpcr.[Date] = adpcr.[Date] AND bdpcr.JobTypeName = adpcr.JobTypeName
			/*END-FACT_DailyPersonalCommercialCSEntityDataSource ReceivingVolToQrCodeWithAcCnt*/

			UNION ALL
			
			/*BEGIN-FACT_DailyPersonalCommercialCSEntityDataSource ReceivingVolToQrCodeWithCard*/
				  SELECT 
						 bdpcr.[Date]																																																 StreamDate,
						'V.'																																																		 TestType,
						'FACT_DailyPersonalCommercialCSEntityDataSource'																																										 BasedReportTable,
						'ReceivingVolToQrCodeWithCard'																																											 BasedReportTableField,
						'FACT_Transactions;DIM_UserAttributes;DIM_JobTypes'																																										 Tested_DWH_Table,
						'TxAmount;FeatureType;Method'																																													 Tested_DWH_Table_Field,
						0																																																			 Currency,
						 bdpcr.JobTypeName																																															 Value1,
						'SUM(CASE WHEN FeatureType = 20 AND Method = 3 THEN l.TxAmount ELSE NULL END)'																																	 Formula,
						'Daily Vol of transactions paid by QR code with Database Card to commercial acCnts'																														 MetricExplanation,
						 adpcr.ReceivingVolToQrCodeWithCard																																									 	 CSHARP_TO_PROD_VIEW,
						 bdpcr.ReceivingVolToQrCodeWithCard																																										 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource	  bdpcr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource  adpcr on bdpcr.[Date] = adpcr.[Date] AND bdpcr.JobTypeName = adpcr.JobTypeName
			/*END-FACT_DailyPersonalCommercialCSEntityDataSource ReceivingVolToQrCodeWithCard*/

			UNION ALL
						
			/*BEGIN-FACT_DailyPersonalCommercialCSEntityDataSource SuccessfullApplyDailyCnt*/
				  SELECT 
						 bdpcr.[Date]																																																 StreamDate,
						'Tx.#'																																																		 TestType,
						'FACT_DailyPersonalCommercialCSEntityDataSource'																																										 BasedReportTable,
						'SuccessfullApplyDailyCnt'																																												 BasedReportTableField,
						'FACT_AuditionLogs'																																															 Tested_DWH_Table,
						'Id;OperationName'																																															 Tested_DWH_Table_Field,
						0																																																			 Currency,
						 bdpcr.JobTypeName																																															 Value1,
						'Cnt(CASE WHEN OperationName = 90 THEN a.Id ELSE NULL END)'																																				 Formula,
						'Successful apply daily Cnt'																																												 MetricExplanation,
						 adpcr.SuccessfullApplyDailyCnt																																									 		 CSHARP_TO_PROD_VIEW,
						 bdpcr.SuccessfullApplyDailyCnt																																											 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource	  bdpcr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource  adpcr on bdpcr.[Date] = adpcr.[Date] AND bdpcr.JobTypeName = adpcr.JobTypeName
			/*END-FACT_DailyPersonalCommercialCSEntityDataSource SuccessfullApplyDailyCnt*/

			UNION ALL
			
			/*BEGIN-FACT_DailyPersonalCommercialCSEntityDataSource UniqueReceivingDailyCnt*/
				  SELECT 
						 bdpcr.[Date]																																																 StreamDate,
						'UU'																																																		 TestType,
						'FACT_DailyPersonalCommercialCSEntityDataSource'																																										 BasedReportTable,
						'UniqueReceivingDailyCnt'																																													 BasedReportTableField,
						'FACT_Transactions;DIM_UserAttributes;DIM_JobTypes'																																										 Tested_DWH_Table,
						'User_Key;IsCommercial'																																														 Tested_DWH_Table_Field,
						0																																																			 Currency,
						 bdpcr.JobTypeName																																															 Value1,
						'Cnt(DISTINCT User_Key)'																																													 Formula,
						'Daily UU commercial money receiving'																																										 MetricExplanation,
						 adpcr.UniqueReceivingDailyCnt																																									 		 CSHARP_TO_PROD_VIEW,
						 bdpcr.UniqueReceivingDailyCnt																																											 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource	  bdpcr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource  adpcr on bdpcr.[Date] = adpcr.[Date] AND bdpcr.JobTypeName = adpcr.JobTypeName
			/*END-FACT_DailyPersonalCommercialCSEntityDataSource UniqueReceivingDailyCnt*/

			UNION ALL
			
			/*BEGIN-FACT_DailyPersonalCommercialCSEntityDataSource UnsuccessfullApplyDailyCnt*/
				  SELECT 
						 bdpcr.[Date]																																																 StreamDate,
						'Tx.#'																																																		 TestType,
						'FACT_DailyPersonalCommercialCSEntityDataSource'																																										 BasedReportTable,
						'UnsuccessfullApplyDailyCnt'																																												 BasedReportTableField,
						'FACT_AuditionLogs'																																															 Tested_DWH_Table,
						'Id;OperationName'																																															 Tested_DWH_Table_Field,
						 0																																																			 Currency,
						 bdpcr.JobTypeName																																															 Value1,
						'Cnt(CASE WHEN OperationName = 91 THEN a.Id ELSE NULL END)'																																				 Formula,
						'Unsuccessful apply daily Cnt'																																											 MetricExplanation,
						 adpcr.UnsuccessfullApplyDailyCnt																																									 		 CSHARP_TO_PROD_VIEW,
						 bdpcr.UnsuccessfullApplyDailyCnt																																											 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource	  bdpcr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource  adpcr on bdpcr.[Date] = adpcr.[Date] AND bdpcr.JobTypeName = adpcr.JobTypeName
			/*END-FACT_DailyPersonalCommercialCSEntityDataSource UnsuccessfullApplyDailyCnt*/

			UNION ALL
			
			/*BEGIN-FACT_DailyFinancialCSEntityDataSource MerchandiserBankTransferTxVol*/
				  SELECT 
						bdfr.[Date]																																																StreamDate,
						'V.'																																																	TestType,
						'FACT_DailyFinancialCSEntityDataSource'																																											BasedReportTable,
						'MerchandiserBankTransferTxVol'																																											BasedReportTableField,
						'FACT_MerchandiserTransactions'																																													Tested_DWH_Table,
						'FeatureType;TxAmount'																																														Tested_DWH_Table_Field,
						bdfr.Currency,
						'N/A'																																																	Value1,
						'SUM(CASE WHEN FeatureType =  1 THEN TxAmount ELSE NULL END)'																																				Formula,
						'Merchandiser Bank Transfer Tx. Vol'																																										MetricExplanation,
						adfr.MerchandiserBankTransferTxVol																																										CSHARP_TO_PROD_VIEW,
						bdfr.MerchandiserBankTransferTxVol																																										PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource	bdfr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource adfr on bdfr.[Date] = adfr.[Date] AND bdfr.Currency = adfr.Currency
			/*END-FACT_DailyFinancialCSEntityDataSource MerchandiserBankTransferTxVol*/

			UNION ALL
			
			/*BEGIN-FACT_DailyFinancialCSEntityDataSource BankTransferTxVol*/
				  SELECT 
						bdfr.[Date]																																																StreamDate,
						'V.'																																																	TestType,
						'FACT_DailyFinancialCSEntityDataSource'																																											BasedReportTable,
						'BankTransferTxVol'																																													BasedReportTableField,
						'FACT_Transactions'																																															Tested_DWH_Table,
						'FeatureType;TxAmount'																																														Tested_DWH_Table_Field,
						bdfr.Currency,
						'N/A'																																																	Value1,
						'SUM(CASE WHEN FeatureType =  1 THEN TxAmount ELSE NULL END)'																																				Formula,
						'Bank Transfer Tx. Vol'																																												MetricExplanation,
						adfr.BankTransferTxVol																																												CSHARP_TO_PROD_VIEW,
						bdfr.BankTransferTxVol																																												PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource	bdfr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource adfr on bdfr.[Date] = adfr.[Date] AND bdfr.Currency = adfr.Currency
			/*END-FACT_DailyFinancialCSEntityDataSource BankTransferTxVol*/

			UNION ALL
			
			/*BEGIN-FACT_DailyFinancialCSEntityDataSource IbanRemittanceVol*/
				  SELECT 
						bdfr.[Date]																																																StreamDate,
						'V.'																																																	TestType,
						'FACT_DailyFinancialCSEntityDataSource'																																											BasedReportTable,
						'IbanRemittanceVol'																																												BasedReportTableField,
						'FACT_Transactions;FACT_MerchandiserTransactions'																																										Tested_DWH_Table,
						'FeatureType;TxAmount'																																														Tested_DWH_Table_Field,
						bdfr.Currency,
						'N/A'																																																	Value1,
						'SUM(CASE WHEN FeatureType = 21 THEN TxAmount ELSE NULL END)'																																				Formula,
						'Money transfer to IBAN Tx. Vol'																																										MetricExplanation,
						adfr.IbanRemittanceVol																																											CSHARP_TO_PROD_VIEW,
						bdfr.IbanRemittanceVol																																											PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource	bdfr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource adfr on bdfr.[Date] = adfr.[Date] AND bdfr.Currency = adfr.Currency
			/*END-FACT_DailyFinancialCSEntityDataSource IbanRemittanceVol*/

			UNION ALL
			
			/*BEGIN-FACT_DailyFinancialCSEntityDataSource ExternalTopUpCardDepositTxVol*/
				  SELECT 
						bdfr.[Date]																																																StreamDate,
						'V.'																																																	TestType,
						'FACT_DailyFinancialCSEntityDataSource'																																											BasedReportTable,
						'ExternalTopUpCardDepositTxVol'																																													BasedReportTableField,
						'FACT_Transactions'																																															Tested_DWH_Table,
						'FeatureType;TxAmount'																																														Tested_DWH_Table_Field,
						bdfr.Currency,
						'N/A'																																																	Value1,
						'SUM(CASE WHEN FeatureType =  3 THEN TxAmount ELSE NULL END)'																																				Formula,
						'Card Deposits from Saved Cards'																																										MetricExplanation,
						adfr.ExternalTopUpCardDepositTxVol																																												CSHARP_TO_PROD_VIEW,
						bdfr.ExternalTopUpCardDepositTxVol																																												PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource	bdfr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource adfr on bdfr.[Date] = adfr.[Date] AND bdfr.Currency = adfr.Currency
			/*END-FACT_DailyFinancialCSEntityDataSource ExternalTopUpCardDepositTxVol*/

			UNION ALL
			
			/*BEGIN-FACT_DailyFinancialCSEntityDataSource PostPaidCashDepositTxVol*/
				  SELECT 
						bdfr.[Date]																																																StreamDate,
						'V.'																																																	TestType,
						'FACT_DailyFinancialCSEntityDataSource'																																											BasedReportTable,
						'PostPaidCashDepositTxVol'																																											BasedReportTableField,
						'FACT_MerchandiserTransactions'																																													Tested_DWH_Table,
						'FeatureType;Postpaid;TxAmount'																																												Tested_DWH_Table_Field,
						bdfr.Currency,
						'N/A'																																																	Value1,
						'ABS(SUM(CASE WHEN FeatureType = 6 AND Postpaid = 1 THEN TxAmount ELSE NULL END))'																															Formula,
						'Post Paid Cash Deposit Tx. Vol'																																										MetricExplanation,
						adfr.PostPaidCashDepositTxVol																																										CSHARP_TO_PROD_VIEW,
						bdfr.PostPaidCashDepositTxVol																																										PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource	bdfr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource adfr on bdfr.[Date] = adfr.[Date] AND bdfr.Currency = adfr.Currency
			/*END-FACT_DailyFinancialCSEntityDataSource PostPaidCashDepositTxVol*/

			UNION ALL
			
			/*BEGIN-FACT_DailyFinancialCSEntityDataSource InvoicePaymentTxVol*/
				  SELECT 
						bdfr.[Date]																																																StreamDate,
						'V.'																																																	TestType,
						'FACT_DailyFinancialCSEntityDataSource'																																											BasedReportTable,
						'InvoicePaymentTxVol'																																													BasedReportTableField,
						'FACT_Transactions'																																															Tested_DWH_Table,
						'FeatureType;TxAmount'																																														Tested_DWH_Table_Field,
						bdfr.Currency,
						'N/A'																																																	Value1,
						'SUM(CASE WHEN FeatureType = 14 THEN TxAmount ELSE NULL END)'																																				Formula,
						'Invoice Payment Tx. Vol'																																												MetricExplanation,
						adfr.InvoicePaymentTxVol																																												CSHARP_TO_PROD_VIEW,
						bdfr.InvoicePaymentTxVol																																												PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource	bdfr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource adfr on bdfr.[Date] = adfr.[Date] AND bdfr.Currency = adfr.Currency
			/*END-FACT_DailyFinancialCSEntityDataSource InvoicePaymentTxVol*/

			UNION ALL
			
			/*BEGIN-FACT_DailyFinancialCSEntityDataSource CityRingTravelCardTxVol*/
				  SELECT 
						bdfr.[Date]																																																StreamDate,
						'V.'																																																	TestType,
						'FACT_DailyFinancialCSEntityDataSource'																																											BasedReportTable,
						'CityRingTravelCardTxVol'																																													BasedReportTableField,
						'FACT_Transactions'																																															Tested_DWH_Table,
						'FeatureType;TxAmount'																																														Tested_DWH_Table_Field,
						bdfr.Currency,
						'N/A'																																																	Value1,
						'SUM(CASE WHEN FeatureType = 18 THEN TxAmount ELSE NULL END)'																																				Formula,
						'CityRingTravelCard (TravelCard) Tx. Vol'																																									MetricExplanation,
						adfr.CityRingTravelCardTxVol																																												CSHARP_TO_PROD_VIEW,
						bdfr.CityRingTravelCardTxVol																																												PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource	bdfr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource adfr on bdfr.[Date] = adfr.[Date] AND bdfr.Currency = adfr.Currency
			/*END-FACT_DailyFinancialCSEntityDataSource CityRingTravelCardTxVol*/

			UNION ALL
			
			/*BEGIN-FACT_DailyFinancialCSEntityDataSource LotteryPaymentTxVol*/
				  SELECT 
						bdfr.[Date]																																																StreamDate,
						'V.'																																																	TestType,
						'FACT_DailyFinancialCSEntityDataSource'																																											BasedReportTable,
						'LotteryPaymentTxVol'																																												BasedReportTableField,
						'FACT_Transactions;FACT_MerchandiserTransactions'																																										Tested_DWH_Table,
						'FeatureType;TxAmount'																																														Tested_DWH_Table_Field,
						bdfr.Currency,
						'N/A'																																																	Value1,
						'SUM(CASE WHEN FeatureType = 27 THEN TxAmount ELSE NULL END)'																																				Formula,
						'Lottery (Milli Piyango) Tx. Vol'																																									MetricExplanation,
						adfr.LotteryPaymentTxVol																																												CSHARP_TO_PROD_VIEW,
						bdfr.LotteryPaymentTxVol																																												PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource	bdfr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource adfr on bdfr.[Date] = adfr.[Date] AND bdfr.Currency = adfr.Currency
			/*END-FACT_DailyFinancialCSEntityDataSource LotteryPaymentTxVol*/


			UNION ALL
			
			/*BEGIN-FACT_DailyFinancialCSEntityDataSource GamePaymentTxVol*/
				  SELECT 
						bdfr.[Date]																																																StreamDate,
						'V.'																																																	TestType,
						'FACT_DailyFinancialCSEntityDataSource'																																											BasedReportTable,
						'GamePaymentTxVol'																																													BasedReportTableField,
						'FACT_Transactions;FACT_MerchandiserTransactions'																																										Tested_DWH_Table,
						'FeatureType;TxAmount'																																														Tested_DWH_Table_Field,
						bdfr.Currency,
						'N/A'																																																	Value1,
						'SUM(CASE WHEN FeatureType = 17 THEN TxAmount ELSE NULL END)'																																				Formula,
						'Game Payment Tx. Vol (Epin;Eglence Fabrikasi vs)'																																					MetricExplanation,
						adfr.GamePaymentTxVol																																												CSHARP_TO_PROD_VIEW,
						bdfr.GamePaymentTxVol																																												PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource	bdfr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource adfr on bdfr.[Date] = adfr.[Date] AND bdfr.Currency = adfr.Currency
			/*END-FACT_DailyFinancialCSEntityDataSource GamePaymentTxVol*/

			UNION ALL
			
			/*BEGIN-FACT_DailyFinancialCSEntityDataSource DonateToCharitiesTxVol*/
				  SELECT 
						bdfr.[Date]																																																StreamDate,
						'V.'																																																	TestType,
						'FACT_DailyFinancialCSEntityDataSource'																																											BasedReportTable,
						'DonateToCharitiesTxVol'																																														BasedReportTableField,
						'FACT_Transactions'																																															Tested_DWH_Table,
						'FeatureType;TxAmount'																																														Tested_DWH_Table_Field,
						bdfr.Currency,
						'N/A'																																																	Value1,
						'SUM(CASE WHEN FeatureType = 22 THEN TxAmount ELSE NULL END)'																																				Formula,
						'DonateToCharities Tx. Vol'																																													MetricExplanation,
						adfr.DonateToCharitiesTxVol																																													CSHARP_TO_PROD_VIEW,
						bdfr.DonateToCharitiesTxVol																																													PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource	bdfr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource adfr on bdfr.[Date] = adfr.[Date] AND bdfr.Currency = adfr.Currency
			/*END-FACT_DailyFinancialCSEntityDataSource DonateToCharitiesTxVol*/	

			UNION ALL
			
			/*BEGIN-FACT_DailyFinancialCSEntityDataSource DatabaseCardTxVol*/
				  SELECT 
						bdfr.[Date]																																																StreamDate,
						'V.'																																																	TestType,
						'FACT_DailyFinancialCSEntityDataSource'																																											BasedReportTable,
						'DatabaseCardTxVol'																																													BasedReportTableField,
						'FACT_Transactions;FACT_MerchandiserTransactions'																																										Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;TxAmount'																																										Tested_DWH_Table_Field,
						bdfr.Currency,
						'N/A'																																																	Value1,
						'SUM(CASE WHEN FeatureType = 2 THEN TxAmount ELSE NULL END)-(CASES: DatabaseCardTxType ={2,3,6,9}'																											Formula,
						'Database Card Tx. V. (Transactions + Merchandiser)'																																								MetricExplanation,
						adfr.DatabaseCardTxVol																																													CSHARP_TO_PROD_VIEW,
						bdfr.DatabaseCardTxVol																																													PROD_TO_DWH_VIEW,  0 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource	bdfr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource adfr on bdfr.[Date] = adfr.[Date] AND bdfr.Currency = adfr.Currency
			/*END-FACT_DailyFinancialCSEntityDataSource DatabaseCardTxVol*/

			UNION ALL
			
			/*BEGIN-FACT_DailyFinancialCSEntityDataSource DatabaseCardCashbackTxVol*/
				  SELECT 
						bdfr.[Date]																																																StreamDate,
						'V.'																																																	TestType,
						'FACT_DailyFinancialCSEntityDataSource'																																											BasedReportTable,
						'DatabaseCardCashbackTxVol'																																											BasedReportTableField,
						'FACT_Transactions'																																															Tested_DWH_Table,
						'FeatureType;TxAmount'																																														Tested_DWH_Table_Field,
						bdfr.Currency,
						'N/A'																																																	Value1,
						'SUM(CASE WHEN FeatureType = 15 THEN TxAmount ELSE NULL END)'																																				Formula,
						'Database Card Cashback V.'																																												MetricExplanation,
						adfr.DatabaseCardCashbackTxVol																																											CSHARP_TO_PROD_VIEW,
						bdfr.DatabaseCardCashbackTxVol																																											PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource	bdfr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource adfr on bdfr.[Date] = adfr.[Date] AND bdfr.Currency = adfr.Currency
			/*END-FACT_DailyFinancialCSEntityDataSource DatabaseCardCashbackTxVol*/

			UNION ALL
			
			/*BEGIN-FACT_DailyFinancialCSEntityDataSource ManuelNegativeTransactionsCnt*/
				  SELECT 
						bdfr.[Date]																																																StreamDate,
						'Tx.#'																																																	TestType,
						'FACT_DailyFinancialCSEntityDataSource'																																											BasedReportTable,
						'ManuelNegativeTransactionsCnt'																																												BasedReportTableField,
						'FACT_Transactions;FACT_MerchandiserTransactions'																																										Tested_DWH_Table,
						'FeatureType;Id'																																															Tested_DWH_Table_Field,
						bdfr.Currency,
						'N/A'																																																	Value1,
						'Cnt(CASE WHEN FeatureType = 0 AND SIGN(TxAmount)=-1 THEN Id ELSE NULL END)'																																	Formula,
						'Negative Manual Tx.#'																																													MetricExplanation,
						adfr.ManuelNegativeTransactionsCnt																																											CSHARP_TO_PROD_VIEW,
						bdfr.ManuelNegativeTransactionsCnt																																											PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource	bdfr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource adfr on bdfr.[Date] = adfr.[Date] AND bdfr.Currency = adfr.Currency
			/*END-FACT_DailyFinancialCSEntityDataSource ManuelNegativeTransactionsCnt*/

			UNION ALL
			
			/*BEGIN-FACT_DailyFinancialCSEntityDataSource ManuelNegativeTransactionsVol*/
				  SELECT 
						bdfr.[Date]																																																StreamDate,
						'V.'																																																	TestType,
						'FACT_DailyFinancialCSEntityDataSource'																																											BasedReportTable,
						'ManuelNegativeTransactionsVol'																																											BasedReportTableField,
						'FACT_Transactions;FACT_MerchandiserTransactions'																																										Tested_DWH_Table,
						'FeatureType;TxAmount'																																														Tested_DWH_Table_Field,
						bdfr.Currency,
						'N/A'																																																	Value1,
						'SUM(CASE WHEN FeatureType = 0 AND SIGN(TxAmount)=-1 THEN TxAmount ELSE NULL END)'																																	Formula,
						'Negative Manual Tx. V.'																																												MetricExplanation,
						adfr.ManuelNegativeTransactionsVol																																											CSHARP_TO_PROD_VIEW,
						bdfr.ManuelNegativeTransactionsVol																																											PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource	bdfr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource adfr on bdfr.[Date] = adfr.[Date] AND bdfr.Currency = adfr.Currency
			/*END-FACT_DailyFinancialCSEntityDataSource ManuelNegativeTransactionsVol*/

			UNION ALL
			
			/*BEGIN-FACT_DailyFinancialCSEntityDataSource ManuelPositiveTransactionsCnt*/
				  SELECT 
						bdfr.[Date]																																																StreamDate,
						'Tx.#'																																																	TestType,
						'FACT_DailyFinancialCSEntityDataSource'																																											BasedReportTable,
						'ManuelPositiveTransactionsCnt'																																												BasedReportTableField,
						'FACT_Transactions;FACT_MerchandiserTransactions'																																										Tested_DWH_Table,
						'FeatureType;TxAmount;Id'																																													Tested_DWH_Table_Field,
						bdfr.Currency,
						'N/A'																																																	Value1,
						'Cnt(CASE WHEN FeatureType = 0 AND SIGN(TxAmount)=1 THEN Id ELSE NULL END)'																																	Formula,
						'Positive Manual Tx.#'																																													MetricExplanation,
						adfr.ManuelPositiveTransactionsCnt																																											CSHARP_TO_PROD_VIEW,
						bdfr.ManuelPositiveTransactionsCnt																																											PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource	bdfr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource adfr on bdfr.[Date] = adfr.[Date] AND bdfr.Currency = adfr.Currency
			/*END-FACT_DailyFinancialCSEntityDataSource ManuelPositiveTransactionsCnt*/

			UNION ALL
			
			/*BEGIN-FACT_DailyFinancialCSEntityDataSource ManuelPositiveTransactionsVol*/
				  SELECT 
						bdfr.[Date]																																																StreamDate,
						'V.'																																																	TestType,
						'FACT_DailyFinancialCSEntityDataSource'																																											BasedReportTable,
						'ManuelPositiveTransactionsVol'																																											BasedReportTableField,
						'FACT_Transactions;FACT_MerchandiserTransactions'																																										Tested_DWH_Table,
						'FeatureType;TxAmount'																																														Tested_DWH_Table_Field,
						bdfr.Currency,
						'N/A'																																																	Value1,
						'SUM(CASE WHEN FeatureType = 0 AND SIGN(TxAmount)=1 THEN TxAmount ELSE NULL END)'																																	Formula,
						'Positive Manual Tx. V.'																																												MetricExplanation,
						adfr.ManuelPositiveTransactionsVol																																											CSHARP_TO_PROD_VIEW,
						bdfr.ManuelPositiveTransactionsVol																																											PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource	bdfr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource adfr on bdfr.[Date] = adfr.[Date] AND bdfr.Currency = adfr.Currency
			/*END-FACT_DailyFinancialCSEntityDataSource ManuelPositiveTransactionsVol*/

			UNION ALL
			
			/*BEGIN-FACT_DailyFinancialCSEntityDataSource MerchandiserFeeVol*/
				  SELECT 
						bdfr.[Date]																																																StreamDate,
						'V.'																																																	TestType,
						'FACT_DailyFinancialCSEntityDataSource'																																											BasedReportTable,
						'MerchandiserFeeVol'																																														BasedReportTableField,
						'FACT_MerchandiserTransactions'																																													Tested_DWH_Table,
						'Fee'																																																	Tested_DWH_Table_Field,
						bdfr.Currency,
						'N/A'																																																	Value1,
						'SUM(Fee)'																																																Formula,
						'Merchandiser Fee V.'																																														MetricExplanation,
						adfr.MerchandiserFeeVol																																													CSHARP_TO_PROD_VIEW,
						bdfr.MerchandiserFeeVol																																													PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource	bdfr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource adfr on bdfr.[Date] = adfr.[Date] AND bdfr.Currency = adfr.Currency
			/*END-FACT_DailyFinancialCSEntityDataSource MerchandiserFeeVol*/

			UNION ALL
			
			/*BEGIN-FACT_DailyFinancialCSEntityDataSource MerchandiserGuestPaymentVol*/
				  SELECT 
						bdfr.[Date]																																																StreamDate,
						'V.'																																																	TestType,
						'FACT_DailyFinancialCSEntityDataSource'																																											BasedReportTable,
						'MerchandiserGuestPaymentVol'																																											BasedReportTableField,
						'FACT_MerchandiserTransactions'																																													Tested_DWH_Table,
						'FeatureType;TxAmount'																																														Tested_DWH_Table_Field,
						bdfr.Currency,
						'N/A'																																																	Value1,
						'SUM(CASE WHEN FeatureType = 26 THEN TxAmount ELSE NULL END)'																																				Formula,
						'Guest payment Vol to Merchandiser'																																										MetricExplanation,
						adfr.MerchandiserGuestPaymentVol																																											CSHARP_TO_PROD_VIEW,
						bdfr.MerchandiserGuestPaymentVol																																											PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource	bdfr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource adfr on bdfr.[Date] = adfr.[Date] AND bdfr.Currency = adfr.Currency
			/*END-FACT_DailyFinancialCSEntityDataSource MerchandiserGuestPaymentVol*/

			UNION ALL
			
			/*BEGIN-FACT_DailyFinancialCSEntityDataSource FxTxVol*/
				  SELECT 
						bdfr.[Date]																																																StreamDate,
						'V.'																																																	TestType,
						'FACT_DailyFinancialCSEntityDataSource'																																											BasedReportTable,
						'FxTxVol'																																															BasedReportTableField,
						'FACT_Transactions;FACT_MerchandiserTransactions'																																										Tested_DWH_Table,
						'FeatureType;TxAmount'																																														Tested_DWH_Table_Field,
						bdfr.Currency,
						'N/A'																																																	Value1,
						'SUM(CASE WHEN FeatureType = 13 THEN TxAmount ELSE NULL END)'																																				Formula,
						'FX Buy/Sell Vol'																																													MetricExplanation,
						adfr.FxTxVol																																															CSHARP_TO_PROD_VIEW,
						bdfr.FxTxVol																																															PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource	bdfr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource adfr on bdfr.[Date] = adfr.[Date] AND bdfr.Currency = adfr.Currency
			/*END-FACT_DailyFinancialCSEntityDataSource FxTxVol*/

			UNION ALL
			
			/*BEGIN-FACT_DailyFinancialCSEntityDataSource PfPosPaymentVol*/
				  SELECT 
						bdfr.[Date]																																																StreamDate,
						'V.'																																																	TestType,
						'FACT_DailyFinancialCSEntityDataSource'																																											BasedReportTable,
						'PfPosPaymentVol'																																													BasedReportTableField,
						'FACT_MerchandiserTransactions'																																													Tested_DWH_Table,
						'FeatureType;TxAmount'																																														Tested_DWH_Table_Field,
						bdfr.Currency,
						'N/A'																																																	Value1,
						'SUM(CASE WHEN FeatureType = 30 THEN TxAmount ELSE NULL END)'																																				Formula,
						'PF POS Payment Tx. Vol'																																												MetricExplanation,
						adfr.PfPosPaymentVol																																													CSHARP_TO_PROD_VIEW,
						bdfr.PfPosPaymentVol																																													PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource	bdfr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource adfr on bdfr.[Date] = adfr.[Date] AND bdfr.Currency = adfr.Currency
			/*END-FACT_DailyFinancialCSEntityDataSource PfPosPaymentVol*/

			UNION ALL
			
			/*BEGIN-FACT_DailyFinancialCSEntityDataSource MembershipPaymentTxVol*/
				  SELECT 
						bdfr.[Date]																																																StreamDate,
						'V.'																																																	TestType,
						'FACT_DailyFinancialCSEntityDataSource'																																											BasedReportTable,
						'MembershipPaymentTxVol'																																												BasedReportTableField,
						'FACT_Transactions'																																															Tested_DWH_Table,
						'FeatureType;TxAmount'																																														Tested_DWH_Table_Field,
						bdfr.Currency,
						'N/A'																																																	Value1,
						'SUM(CASE WHEN FeatureType = 31 THEN TxAmount ELSE NULL END)'																																				Formula,
						'Membership Payment Tx. V.'																																												MetricExplanation,
						adfr.MembershipPaymentTxVol																																											CSHARP_TO_PROD_VIEW,
						bdfr.MembershipPaymentTxVol																																											PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource	bdfr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource adfr on bdfr.[Date] = adfr.[Date] AND bdfr.Currency = adfr.Currency
			/*END-FACT_DailyFinancialCSEntityDataSource MembershipPaymentTxVol*/
			UNION ALL
			
			/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_A AddedCardCnt*/
				  SELECT 
						br.[Date]																																											StreamDate,
						'Tx.#'																																												TestType,
						'FACT_CSEntityDataSource'																																										BasedReportTable,
						'AddedCardCnt'																																									BasedReportTableField,
						'DIM_ExternalTopUpCards'																																									Tested_DWH_Table,
						'Id'																																												Tested_DWH_Table_Field,
						-1																																													Currency,
						'N/A'																																												Value1,
						'Cnt(Id)'																																											Formula,
						'Added saved card Cnt to User AcCnt'																																			MetricExplanation,
						ar.AddedCardCnt																																									CSHARP_TO_PROD_VIEW,
						br.AddedCardCnt																																									PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_A  br
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_CSEntityDataSource ar on br.[Date] = ar.[Date]

			/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_A AddedCardCnt*/
			UNION ALL
			
			/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B FormRegisteredUserCnt*/
				  SELECT 
						br.[Date]																																											StreamDate,
						'UU'																																												TestType,
						'FACT_CSEntityDataSource'																																										BasedReportTable,
						'FormRegisteredUserCnt'																																							BasedReportTableField,
						'DIM_UserAttributes'																																											Tested_DWH_Table,
						'SigninMethod;User_Key'																																								Tested_DWH_Table_Field,
						-1																																													Currency,
						'N/A'																																												Value1,
						'Cnt(CASE WHEN SigninMethod = 0 THEN User_Key ELSE NULL END)'																														Formula,
						'UserAttributes came from Form to register'																																					MetricExplanation,
						ar.FormRegisteredUserCnt																																							CSHARP_TO_PROD_VIEW,
						br.FormRegisteredUserCnt																																							PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B  br
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_CSEntityDataSource ar on br.[Date] = ar.[Date]
			/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B FormRegisteredUserCnt*/

			UNION ALL
			
			/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B FacebookRegisteredUserCnt*/
				  SELECT 
						br.[Date]																																											StreamDate,
						'UU'																																												TestType,
						'FACT_CSEntityDataSource'																																										BasedReportTable,
						'FacebookRegisteredUserCnt'																																						BasedReportTableField,
						'DIM_UserAttributes'																																											Tested_DWH_Table,
						'SigninMethod;User_Key'																																								Tested_DWH_Table_Field,
						-1																																													Currency,
						'N/A'																																												Value1,
						'Cnt(CASE WHEN SigninMethod  = 1 THEN User_Key ELSE NULL END)'																													Formula,
						'UserAttributes came from Facebook to register'																																				MetricExplanation,
						ar.FacebookRegisteredUserCnt																																						CSHARP_TO_PROD_VIEW,
						br.FacebookRegisteredUserCnt																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B  br
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_CSEntityDataSource ar on br.[Date] = ar.[Date]
			/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B FacebookRegisteredUserCnt*/

			UNION ALL
			
			/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B GoogleRegisteredUserCnt*/
				  SELECT 
						br.[Date]																																											StreamDate,
						'UU'																																												TestType,
						'FACT_CSEntityDataSource'																																										BasedReportTable,
						'GoogleRegisteredUserCnt'																																							BasedReportTableField,
						'DIM_UserAttributes'																																											Tested_DWH_Table,
						'SigninMethod;User_Key'																																								Tested_DWH_Table_Field,
						-1																																													Currency,
						'N/A'																																												Value1,
						'Cnt(CASE WHEN SigninMethod = 1 THEN User_Key ELSE NULL END)'																														Formula,
						'UserAttributes came from Google to register'																																				MetricExplanation,
						ar.GoogleRegisteredUserCnt																																						CSHARP_TO_PROD_VIEW,
						br.GoogleRegisteredUserCnt																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B  br
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_CSEntityDataSource ar on br.[Date] = ar.[Date]
			/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B GoogleRegisteredUserCnt*/

			UNION ALL
			
			/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B BrowserRegisteredUserCnt*/
				  SELECT 
						br.[Date]																																											StreamDate,
						'UU'																																												TestType,
						'FACT_CSEntityDataSource'																																										BasedReportTable,
						'BrowserRegisteredUserCnt'																																							BasedReportTableField,
						'DIM_UserAttributes'																																											Tested_DWH_Table,
						'SigninType;User_Key'																																							Tested_DWH_Table_Field,
						-1																																													Currency,
						'N/A'																																												Value1,
						'Cnt(CASE WHEN SigninType = 0 THEN User_Key ELSE NULL END)'																													Formula,
						'UserAttributes came up with Browser to register'																																				MetricExplanation,
						ar.BrowserRegisteredUserCnt																																							CSHARP_TO_PROD_VIEW,
						br.BrowserRegisteredUserCnt																																							PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B  br
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_CSEntityDataSource ar on br.[Date] = ar.[Date]
			/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B BrowserRegisteredUserCnt*/

			UNION ALL
			
			/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B IosRegisteredUserCnt*/
				  SELECT 
						br.[Date]																																											StreamDate,
						'UU'																																												TestType,
						'FACT_CSEntityDataSource'																																										BasedReportTable,
						'IosRegisteredUserCnt'																																							BasedReportTableField,
						'DIM_UserAttributes'																																											Tested_DWH_Table,
						'SigninType;User_Key'																																							Tested_DWH_Table_Field,
						-1																																													Currency,
						'N/A'																																												Value1,
						'Cnt(CASE WHEN SigninType = 1 THEN User_Key ELSE NULL END)'																													Formula,
						'UserAttributes came up with IOS to register'																																				MetricExplanation,
						ar.IosRegisteredUserCnt																																							CSHARP_TO_PROD_VIEW,
						br.IosRegisteredUserCnt																																							PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B  br
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_CSEntityDataSource ar on br.[Date] = ar.[Date]
			/*END - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B IosRegisteredUserCnt*/

			UNION ALL
			
			/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B AndroidRegisteredUserCnt*/
				  SELECT 
						br.[Date]																																											StreamDate,
						'UU'																																												TestType,
						'FACT_CSEntityDataSource'																																										BasedReportTable,
						'AndroidRegisteredUserCnt'																																						BasedReportTableField,
						'DIM_UserAttributes'																																											Tested_DWH_Table,
						'SigninType;User_Key'																																							Tested_DWH_Table_Field,
						-1																																													Currency,
						'N/A'																																												Value1,
						'Cnt(CASE WHEN SigninType = 2 THEN User_Key ELSE NULL END)'																													Formula,
						'UserAttributes came up with IOS to register'																																				MetricExplanation,
						ar.AndroidRegisteredUserCnt																																						CSHARP_TO_PROD_VIEW,
						br.AndroidRegisteredUserCnt																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B  br
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_CSEntityDataSource ar on br.[Date] = ar.[Date]
			/*END - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B AndroidRegisteredUserCnt*/

			UNION ALL
			
			/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B PhoneNoNotConfirmedUserCnt*/
				  SELECT 
						br.[Date]																																											StreamDate,
						'UU'																																												TestType,
						'FACT_CSEntityDataSource'																																										BasedReportTable,
						'PhoneNoNotConfirmedUserCnt'																																					BasedReportTableField,
						'DIM_UserAttributes'																																											Tested_DWH_Table,
						'PhoneNoConfirmed;User_Key'																																						Tested_DWH_Table_Field,
						-1																																													Currency,
						'N/A'																																												Value1,
						'Cnt(CASE WHEN PhoneNoConfirmed = 0 THEN User_Key ELSE NULL END)'																												Formula,
						'UUs whose Phone No not confirmed'																																				MetricExplanation,
						ar.PhoneNoNotConfirmedUserCnt																																					CSHARP_TO_PROD_VIEW,
						br.PhoneNoNotConfirmedUserCnt																																					PROD_TO_DWH_VIEW,  0 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B  br
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_CSEntityDataSource ar on br.[Date] = ar.[Date]
			/*END - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B PhoneNoNotConfirmedUserCnt*/

			UNION ALL
			
			/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_C CompletedInviteByRemittanceCnt*/
				  SELECT 
						br.[Date]																																											StreamDate,
						'UU'																																												TestType,
						'FACT_CSEntityDataSource'																																										BasedReportTable,
						'CompletedInviteByRemittanceCnt'																																				BasedReportTableField,
						'DIM_UserAttributes;FACT_InviteByRemittances'																																				Tested_DWH_Table,
						'ReceiversPhoneNo;u.User_Key;imt.Status'																																			Tested_DWH_Table_Field,
						-1																																													Currency,
						'N/A'																																												Value1,
						'Cnt(CASE WHEN PhoneNoConfirmed = 0 THEN User_Key ELSE NULL END)>>SubQuery: imt.Status=1'																						Formula,
						'Invited by money transfer completed'																																				MetricExplanation,
						ar.CompletedInviteByRemittanceCnt																																				CSHARP_TO_PROD_VIEW,
						br.CompletedInviteByRemittanceCnt																																				PROD_TO_DWH_VIEW,  0 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_C  br
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_CSEntityDataSource ar on br.[Date] = ar.[Date]
			/*END - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_C CompletedInviteByRemittanceCnt*/

			UNION ALL
			
			/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_D MerchandiserPendingWithdrawalBalance*/
				  SELECT 
						br.[Date]																																											StreamDate,
						'V.'																																												TestType,
						'FACT_CSEntityDataSource'																																										BasedReportTable,
						'MerchandiserPendingWithdrawalBalance'																																					BasedReportTableField,
						'FACT_MerchandiserBankTransferRequests'																																					Tested_DWH_Table,
						'BankTransferType;Status;TxAmount;Fee'																																				Tested_DWH_Table_Field,
						0																																													Currency,
						'N/A'																																												Value1,
						'ABS(SUM(CASE WHEN BankTransferType = 1 AND [Status] in (0,1) THEN TxAmount+Fee ELSE NULL END))'																						Formula,
						'Overall withdrawal requests'																																						MetricExplanation,
						ar.MerchandiserPendingWithdrawalBalance																																					CSHARP_TO_PROD_VIEW,
						br.MerchandiserPendingWithdrawalBalance																																					PROD_TO_DWH_VIEW,  0 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_D  br
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_CSEntityDataSource ar on br.[Date] = ar.[Date]
			/*END - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_D MerchandiserPendingWithdrawalBalance*/

			UNION ALL
			
			/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_E DatabaseCardApplicationCnt*/
				  SELECT 
						br.[Date]																																											StreamDate,
						'Tx.#'																																												TestType,
						'FACT_CSEntityDataSource'																																										BasedReportTable,
						'DatabaseCardApplicationCnt'																																						BasedReportTableField,
						'DIM_DatabaseCards'																																									Tested_DWH_Table,
						'Type;Id'																																											Tested_DWH_Table_Field,
						-1																																													Currency,
						'N/A'																																												Value1,
						'Cnt(CASE WHEN [Type] in (4,5) THEN Id ELSE NULL END)'																															Formula,
						'Database Card Application Cnt'																																						MetricExplanation,
						ar.DatabaseCardApplicationCnt																																						CSHARP_TO_PROD_VIEW,
						br.DatabaseCardApplicationCnt																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_E  br
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_CSEntityDataSource ar on br.[Date] = ar.[Date]
			/*END - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_E DatabaseCardApplicationCnt*/

			UNION ALL
			
			/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_F TotalFee*/
				  SELECT 
						br.[Date]																																											StreamDate,
						'V.'																																												TestType,
						'FACT_CSEntityDataSource'																																										BasedReportTable,
						'TotalFee'																																											BasedReportTableField,
						'FACT_Transactions;FACT_MerchandiserTransactions'																																					Tested_DWH_Table,
						'Currency;FeatureType;DatabaseCardTxType;TxAmount_Fee;Fee'																																Tested_DWH_Table_Field,
						0																																													Currency,
						'N/A'																																												Value1,
						'All discluded ATM Inquiry, Card Fee,VirtualCard Fee, Card purchase. See document'																									Formula,
						'Total fee covers Transactions, ATM Inquiry, Card Fee,VirtualCard Fee, Card purchase'																										MetricExplanation,
						ar.TotalFee																																											CSHARP_TO_PROD_VIEW,
						br.TotalFee																																											PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_F  br
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_CSEntityDataSource ar on br.[Date] = ar.[Date]
			/*END - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_F TotalFee*/

			UNION ALL
			
			/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_F TotalFeeUsd*/
				  SELECT 
						br.[Date]																																											StreamDate,
						'V.'																																												TestType,
						'FACT_CSEntityDataSource'																																										BasedReportTable,
						'TotalFeeUsd'																																										BasedReportTableField,
						'FACT_Transactions;FACT_MerchandiserTransactions'																																					Tested_DWH_Table,
						'Currency;Fee'																																										Tested_DWH_Table_Field,
						1																																													Currency,
						'N/A'																																												Value1,
						'SUM(CASE WHEN Currency= 1 THEN Fee ELSE NULL END)'																																	Formula,
						'Total USD Based Fee'																																								MetricExplanation,
						ar.TotalFeeUsd																																										CSHARP_TO_PROD_VIEW,
						br.TotalFeeUsd																																										PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_F  br
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_CSEntityDataSource ar on br.[Date] = ar.[Date]
			/*END - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_F TotalFeeUsd*/

			UNION ALL
			
			/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_F TotalFeeUsd*/
				  SELECT 
						br.[Date]																																											StreamDate,
						'V.'																																												TestType,
						'FACT_CSEntityDataSource'																																										BasedReportTable,
						'TotalFeeEuro'																																										BasedReportTableField,
						'FACT_Transactions;FACT_MerchandiserTransactions'																																					Tested_DWH_Table,
						'Currency;Fee'																																										Tested_DWH_Table_Field,
						2																																													Currency,
						'N/A'																																												Value1,
						'SUM(CASE WHEN Currency= 2 THEN Fee ELSE NULL END)'																																Formula,
						'Total EUR Based Fee'																																								MetricExplanation,
						ar.TotalFeeEuro																																										CSHARP_TO_PROD_VIEW,
						br.TotalFeeEur																																										PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_F  br
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_CSEntityDataSource ar on br.[Date] = ar.[Date]
			/*END - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_F TotalFeeUsd*/

			UNION ALL
			
			/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_F TotalFeeUsd*/
				  SELECT 
						br.[Date]																																											StreamDate,
						'V.'																																												TestType,
						'FACT_CSEntityDataSource'																																										BasedReportTable,
						'TotalFeeGbp'																																										BasedReportTableField,
						'FACT_Transactions;FACT_MerchandiserTransactions'																																					Tested_DWH_Table,
						'Currency;TxAmount_Fee;Fee'																																							Tested_DWH_Table_Field,
						4																																													Currency,
						'N/A'																																												Value1,
						'SUM(CASE WHEN Currency = 4 THEN Fee ELSE NULL END)'																																Formula,
						'Total GBP Based Fee'																																								MetricExplanation,
						ar.TotalFeeGbp																																										CSHARP_TO_PROD_VIEW,
						br.TotalFeeGbp																																										PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_F  br
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_CSEntityDataSource ar on br.[Date] = ar.[Date]
			/*END - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_F TotalFeeUsd*/

			UNION ALL

			/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_F TotalFeeXau*/
				  SELECT 
						br.[Date]																																											StreamDate,
						'V.'																																												TestType,
						'FACT_CSEntityDataSource'																																										BasedReportTable,
						'TotalFeeXau'																																										BasedReportTableField,
						'FACT_Transactions;FACT_MerchandiserTransactions'																																					Tested_DWH_Table,
						'Currency;Fee'																																										Tested_DWH_Table_Field,
						4																																													Currency,
						'N/A'																																												Value1,
						'SUM(CASE WHEN Currency = 27 THEN Fee ELSE NULL END)'																																Formula,
						'Total XAU (Precious Metal) Based Fee'																																				MetricExplanation,
						ar.TotalFeeXau																																										CSHARP_TO_PROD_VIEW,
						br.TotalFeeXau																																										PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_F  br
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_CSEntityDataSource ar on br.[Date] = ar.[Date]
			/*END - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_F TotalFeeXau*/

			UNION ALL			
			/*BEGIN - #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_G TotalUserCnt*/
				  SELECT 
						br.[Date]																																											StreamDate,
						'UU'																																												TestType,
						'FACT_CSEntityDataSource'																																										BasedReportTable,
						'TotalUserCnt'																																									BasedReportTableField,
						'DWH_Table'																																											Tested_DWH_Table,
						'DWH_Table_Field'																																									Tested_DWH_Table_Field,
						-1																																													Currency,
						'N/A'																																												Value1,
						'SUM(Cnt(User_Key)) OVER (ORDER BY CAST(CreatedAt AS DATE))'																														Formula,
						'Total registered UU'																																								MetricExplanation,
						ar.TotalUserCnt																																									CSHARP_TO_PROD_VIEW,
						br.TotalUserCnt																																									PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_G  br
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_CSEntityDataSource ar on br.[Date] = ar.[Date]
			/*END- #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_G TotalUserCnt*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource ExternalTopUpCardDepositCnt*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'Tx.#'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'ExternalTopUpCardDepositCnt'																																											BasedReportTableField,
						'FACT_Transactions'																																												Tested_DWH_Table,
						'IsDepositForPayment;Id'																																									Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'Cnt(CASE WHEN IsDepositForPayment = 1 THEN Id ELSE NULL END)'																															Formula,
						'UU Saved Card deposit Cnt for payment'																																					MetricExplanation,
						addwr.ExternalTopUpCardDepositCnt																																										CSHARP_TO_PROD_VIEW,
						bddwr.ExternalTopUpCardDepositCnt																																										PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource ExternalTopUpCardDepositCnt*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource ExternalTopUpCardDepositVol*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'V.'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'ExternalTopUpCardDepositVol'																																											BasedReportTableField,
						'FACT_Transactions'																																												Tested_DWH_Table,
						'IsDepositForPayment;TxAmount'																																								Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'SUM(CASE WHEN IsDepositForPayment = 1 THEN TxAmount ELSE NULL END)'																															Formula,
						'Vol of Saved Card deposit Cnt for payment'																																			MetricExplanation,
						addwr.ExternalTopUpCardDepositVol																																										CSHARP_TO_PROD_VIEW,
						bddwr.ExternalTopUpCardDepositVol																																										PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource ExternalTopUpCardDepositVol*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource MerchandiserDepositCnt*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'Tx.#'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'MerchandiserDepositCnt'																																										BasedReportTableField,
						'MerchandiserTransactions;MerchandiserBankTransferRequests'																																		Tested_DWH_Table,
						'BankTransferType;Id'																																										Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'Cnt(CASE WHEN mbtr.BankTransferType = 0 THEN Id ELSE NULL END)'																															Formula,
						'Merchandiser Bank Transfer Deposit Tx.#'																																						MetricExplanation,
						addwr.MerchandiserDepositCnt																																									CSHARP_TO_PROD_VIEW,
						bddwr.MerchandiserDepositCnt																																									PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource MerchandiserDepositCnt*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource MerchandiserDepositVol*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'V.'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'MerchandiserDepositVol'																																										BasedReportTableField,
						'MerchandiserTransactions;MerchandiserBankTransferRequests'																																		Tested_DWH_Table,
						'BankTransferType;TxAmount'																																									Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'SUM(CASE WHEN mbtr.BankTransferType = 0 THEN TxAmount ELSE NULL END)'																														Formula,
						'Merchandiser Bank Transfer Deposit Tx. Vol'																																					MetricExplanation,
						addwr.MerchandiserDepositVol																																									CSHARP_TO_PROD_VIEW,
						bddwr.MerchandiserDepositVol																																									PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource MerchandiserDepositVol*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource MerchandiserDepositFeeVol*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'V.'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'MerchandiserDepositFeeVol'																																									BasedReportTableField,
						'MerchandiserTransactions;MerchandiserBankTransferRequests'																																		Tested_DWH_Table,
						'BankTransferType;Fee'																																										Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'ABS(SUM(CASE WHEN mbtr.BankTransferType = 0 THEN Fee ELSE NULL END))'																														Formula,
						'Merchandiser Bank Transfer Deposit Tx. Fee Vol'																																				MetricExplanation,
						addwr.MerchandiserDepositFeeVol																																								CSHARP_TO_PROD_VIEW,
						bddwr.MerchandiserDepositFeeVol																																								PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource MerchandiserDepositFeeVol*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource MerchandiserWithdrawalCnt*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'Tx.#'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'MerchandiserWithdrawalCnt'																																									BasedReportTableField,
						'MerchandiserTransactions;MerchandiserBankTransferRequests'																																		Tested_DWH_Table,
						'BankTransferType;Id'																																										Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'Cnt(CASE WHEN mbtr.BankTransferType = 1 THEN Id ELSE NULL END)'																															Formula,
						'Merchandiser Withdrawal Tx.#'																																									MetricExplanation,
						addwr.MerchandiserWithdrawalCnt																																								CSHARP_TO_PROD_VIEW,
						bddwr.MerchandiserWithdrawalCnt																																								PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource MerchandiserWithdrawalCnt*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource MerchandiserWithdrawalVol*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'V.'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'MerchandiserWithdrawalVol'																																									BasedReportTableField,
						'MerchandiserTransactions;MerchandiserBankTransferRequests'																																		Tested_DWH_Table,
						'BankTransferType;TxAmount'																																									Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'SUM(CASE WHEN mbtr.BankTransferType = 1 THEN TxAmount ELSE NULL END)'																														Formula,
						'Merchandiser Withdrawal Tx.V.'																																									MetricExplanation,
						addwr.MerchandiserWithdrawalVol																																								CSHARP_TO_PROD_VIEW,
						bddwr.MerchandiserWithdrawalVol																																								PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource MerchandiserWithdrawalVol*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource PostPaidCashDepositCnt*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'Tx.#'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'PostPaidCashDepositCnt'																																									BasedReportTableField,
						'FACT_MerchandiserTransactions'																																										Tested_DWH_Table,
						'FeatureType;Postpaid;Id'																																										Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'Cnt(CASE WHEN FeatureType = 6 AND Postpaid = 1 THEN Id ELSE NULL END)'																													Formula,
						'Post paid cash deposit Tx.# from physical(Contracted Merchandiser) point'																														MetricExplanation,
						addwr.PostPaidCashDepositCnt																																								CSHARP_TO_PROD_VIEW,
						bddwr.PostPaidCashDepositCnt																																								PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource PostPaidCashDepositCnt*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource PostPaidCashDepositVol*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'V.'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'PostPaidCashDepositVol'																																									BasedReportTableField,
						'FACT_MerchandiserTransactions			'																																							Tested_DWH_Table,
						'FeatureType;Postpaid;TxAmount'																																									Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'ABS(SUM(CASE WHEN FeatureType = 6 AND Postpaid = 1 THEN TxAmount ELSE NULL END))'																												Formula,
						'Post paid cash deposit Tx.V. from physical(Contracted Merchandiser) point'																														MetricExplanation,
						addwr.PostPaidCashDepositVol																																								CSHARP_TO_PROD_VIEW,
						bddwr.PostPaidCashDepositVol																																								PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource PostPaidCashDepositVol*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource PrePaidCashDepositCnt*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'Tx.#'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'PrePaidCashDepositCnt'																																									BasedReportTableField,
						'FACT_MerchandiserTransactions'																																										Tested_DWH_Table,
						'FeatureType;Postpaid;Id'																																										Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'Cnt(CASE WHEN FeatureType	= 6	AND Postpaid = 0 THEN Id ELSE NULL END)'																													Formula,
						'Prepaid cash deposit Tx.# from physical(Contracted Merchandiser) point'																														MetricExplanation,
						addwr.PrePaidCashDepositCnt																																								CSHARP_TO_PROD_VIEW,
						bddwr.PrePaidCashDepositCnt																																								PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource PrePaidCashDepositCnt*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource PrePaidCashDepositVol*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'V.'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'PrePaidCashDepositVol'																																									BasedReportTableField,
						'FACT_MerchandiserTransactions'																																										Tested_DWH_Table,
						'FeatureType;Postpaid;TxAmount'																																									Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'ABS(SUM(CASE WHEN FeatureType = 6 AND Postpaid = 0 THEN TxAmount ELSE NULL END))'																												Formula,
						'Prepaid cash deposit Tx.V. from physical(Contracted Merchandiser) point'																														MetricExplanation,
						addwr.PrePaidCashDepositVol																																								CSHARP_TO_PROD_VIEW,
						bddwr.PrePaidCashDepositVol																																								PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource PrePaidCashDepositVol*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource PttDepositCnt*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'Tx.#'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'PttDepositCnt'																																											BasedReportTableField,
						'FACT_Transactions'																																												Tested_DWH_Table,
						'MerchandiserKey;Id'																																											Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'Cnt(CASE WHEN MerchandiserKey = 14 THEN Id ELSE NULL END)'																																	Formula,
						'Deposit Cnt from contracted Merchandiser PTT'																																				MetricExplanation,
						addwr.PttDepositCnt																																										CSHARP_TO_PROD_VIEW,
						bddwr.PttDepositCnt																																										PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource PttDepositCnt*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource PttDepositVol*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'V.'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'PttDepositVol'																																											BasedReportTableField,
						'FACT_Transactions'																																												Tested_DWH_Table,
						'DWH_Table_Field'																																					Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'ABS(SUM(CASE WHEN MerchandiserKey = 14 THEN TxAmount ELSE NULL END))'																															Formula,
						'Deposit V. from contracted Merchandiser PTT'																								MetricExplanation,
						addwr.PttDepositVol																																										CSHARP_TO_PROD_VIEW,
						bddwr.PttDepositVol																																										PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource PttDepositVol*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource TeknosaDepositCnt*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'Tx.#'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'TeknosaDepositCnt'																																										BasedReportTableField,
						'FACT_Transactions'																																												Tested_DWH_Table,
						'MerchandiserKey;Id'																																											Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'Cnt(CASE WHEN MerchandiserKey = 186 THEN Id ELSE NULL END)'																																	Formula,
						'Deposit Cnt from contracted Merchandiser Teknosa'																																			MetricExplanation,
						addwr.TeknosaDepositCnt																																									CSHARP_TO_PROD_VIEW,
						bddwr.TeknosaDepositCnt																																									PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource TeknosaDepositCnt*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource TeknosaDepositVol*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'V.'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'TeknosaDepositVol'																																										BasedReportTableField,
						'FACT_Transactions'																																												Tested_DWH_Table,
						'MerchandiserKey;TxAmount'																																										Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'ABS(SUM(CASE WHEN MerchandiserKey = 186 THEN TxAmount ELSE NULL END))'																															Formula,
						'Deposit V. from contracted Merchandiser Teknosa'																																				MetricExplanation,
						addwr.TeknosaDepositVol																																									CSHARP_TO_PROD_VIEW,
						bddwr.TeknosaDepositVol																																									PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource TeknosaDepositVol*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource TotalUserDepositsCnt*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'Tx.#'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'TotalUserDepositsCnt'																																									BasedReportTableField,
						'FACT_Transactions'																																												Tested_DWH_Table,
						'MerchandiserKey;TxAmount;FeatureType;Postpaid'																																						Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'See. Total of UserBankTransferDepositCnt,PrePaidCashDepositCnt,TotalUserDepositsCnt'																									Formula,
						'Total User Deposit Tx.#'																																									MetricExplanation,
						addwr.TotalUserDepositsCnt																																								CSHARP_TO_PROD_VIEW,
						bddwr.TotalUserDepositsCnt																																								PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource TotalUserDepositsCnt*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource TotalUserDepositsVol*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'V.'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'TotalUserDepositsVol'																																									BasedReportTableField,
						'FACT_Transactions'																																												Tested_DWH_Table,
						'MerchandiserKey;Id;FeatureType;Postpaid'																																							Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'See. Total of UserBankTransferDepositVol,PrePaidCashDepositVol,TotalUserDepositsVol'																								Formula,
						'Total User Deposit Tx.V.'																																									MetricExplanation,
						addwr.TotalUserDepositsVol																																								CSHARP_TO_PROD_VIEW,
						bddwr.TotalUserDepositsVol																																								PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource TotalUserDepositsVol*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource UserBankAtmDepositCnt*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'Tx.#'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'UserBankAtmDepositCnt'																																									BasedReportTableField,
						'FACT_Transactions;FACT_BankTransferRequests'																																						Tested_DWH_Table,
						'FeatureType;BankTransferType;ViaAtm;Id'																																						Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'Cnt(CASE WHEN FeatureType = 1 AND btr.BankTransferType = 0 AND L.ViaAtm = 1 THEN Id ELSE NULL END)'																						Formula,
						'ATM Deposit Tx.#'																																											MetricExplanation,
						addwr.UserBankAtmDepositCnt																																								CSHARP_TO_PROD_VIEW,
						bddwr.UserBankAtmDepositCnt																																								PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource UserBankAtmDepositCnt*/
	
			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource UserBankAtmDepositVol*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'V.'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'UserBankAtmDepositVol'																																									BasedReportTableField,
						'FACT_Transactions;FACT_BankTransferRequests'																																						Tested_DWH_Table,
						'FeatureType;BankTransferType;ViaAtm;TxAmount'																																					Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'SUM(CASE WHEN FeatureType = 1 AND btr.BankTransferType = 0 AND L.ViaAtm = 1 THEN l.TxAmount ELSE NULL END))'																					Formula,
						'ATM Deposit Tx.V.'																																											MetricExplanation,
						addwr.UserBankAtmDepositVol																																								CSHARP_TO_PROD_VIEW,
						bddwr.UserBankAtmDepositVol																																								PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource UserBankAtmDepositVol*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource UserBankFastDepositCnt*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'Tx.#'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'UserBankFastDepositCnt'																																									BasedReportTableField,
						'FACT_Transactions;;FACT_BankTransferRequests'																																					Tested_DWH_Table,
						'FeatureType;BankTransferType;ViaFast;Id'																																						Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'Cnt(CASE WHEN FeatureType = 1 AND btr.BankTransferType = 0 AND btr.ViaFast = 1	THEN l.Id ELSE NULL END)'																					Formula,
						'User Bank FAST Deposit Tx.#'																																								MetricExplanation,
						addwr.UserBankFastDepositCnt																																								CSHARP_TO_PROD_VIEW,
						bddwr.UserBankFastDepositCnt																																								PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource UserBankFastDepositCnt*/


			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource UserBankFastDepositVol*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'V.'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'UserBankFastDepositVol'																																									BasedReportTableField,
						'FACT_Transactions;FACT_BankTransferRequests'																																						Tested_DWH_Table,
						'FeatureType;BankTransferType;ViaFast;TxAmount'																																					Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'SUM(CASE WHEN FeatureType = 1 AND btr.BankTransferType = 0 AND ViaFast = 1 THEN TxAmount ELSE NULL END)'																						Formula,
						'User Bank FAST Deposit Tx.V.'																																								MetricExplanation,
						addwr.UserBankFastDepositVol																																								CSHARP_TO_PROD_VIEW,
						bddwr.UserBankFastDepositVol																																								PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	   bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource UserBankFastDepositVol*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource UserBankTransferDepositCnt*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'Tx.#'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'UserBankTransferDepositCnt'																																								BasedReportTableField,
						'FACT_Transactions;FACT_BankTransferRequests'																																						Tested_DWH_Table,
						'FeatureType;BankTransferType;Id'																																								Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'Cnt(CASE WHEN FeatureType = 1 AND btr.BankTransferType = 0 THEN Id ELSE NULL END)'																											Formula,
						'User Bank Transfer Deposit Tx.#'																																							MetricExplanation,
						addwr.UserBankTransferDepositCnt																																							CSHARP_TO_PROD_VIEW,
						bddwr.UserBankTransferDepositCnt																																							PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource UserBankTransferDepositCnt*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource UserBankTransferDepositVol*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'V.'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'UserBankTransferDepositVol'																																								BasedReportTableField,
						'FACT_Transactions;FACT_BankTransferRequests'																																						Tested_DWH_Table,
						'FeatureType;BankTransferType;TxAmount'																																							Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'SUM(CASE WHEN FeatureType = 1 AND btr.BankTransferType = 0 THEN TxAmount ELSE NULL END)'																										Formula,
						'User Bank Transfer Deposit Tx.V.'																																							MetricExplanation,
						addwr.UserBankTransferDepositVol																																							CSHARP_TO_PROD_VIEW,
						bddwr.UserBankTransferDepositVol																																							PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource UserBankTransferDepositVol*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource UserBankWithdrawalCnt*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'Tx.#'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'UserBankWithdrawalCnt'																																									BasedReportTableField,
						'FACT_Transactions;FACT_BankTransferRequests'																																						Tested_DWH_Table,
						'FeatureType;BankTransferType;Id'																																								Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'Cnt(CASE WHEN FeatureType = 1 AND btr.BankTransferType = 1 THEN Id ELSE NULL END)'																											Formula,
						'User Bank Withdrawal Tx.#'																																									MetricExplanation,
						addwr.UserBankWithdrawalCnt																																								CSHARP_TO_PROD_VIEW,
						bddwr.UserBankWithdrawalCnt																																								PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource UserBankWithdrawalCnt*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource UserBankWithdrawalVol*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'V.'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'UserBankWithdrawalVol'																																									BasedReportTableField,
						'FACT_Transactions;FACT_BankTransferRequests'																																						Tested_DWH_Table,
						'FeatureType;BankTransferType;TxAmount'																																							Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'SUM(CASE WHEN FeatureType = 1 AND btr.BankTransferType = 1 THEN TxAmount ELSE NULL END)'																										Formula,
						'User Bank Withdrawal Tx.V.'																																								MetricExplanation,
						addwr.UserBankWithdrawalVol																																								CSHARP_TO_PROD_VIEW,
						bddwr.UserBankWithdrawalVol																																								PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource UserBankWithdrawalVol*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource UserManuelProcessedBankTransferDepositCnt*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'Tx.#'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'UserManuelProcessedBankTransferDepositCnt'																																				BasedReportTableField,
						'FACT_Transactions;FACT_BankTransferRequests'																																						Tested_DWH_Table,
						'FeatureType;BankTransferType;Status;Id'																																						Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'Cnt(CASE WHEN FeatureType = 1 AND btr.BankTransferType = 0 AND btr.[Status] = 2 THEN Id ELSE NULL END)'																					Formula,
						'Deposit Tx.# that manually approved'																																						MetricExplanation,
						addwr.UserManuelProcessedBankTransferDepositCnt																																			CSHARP_TO_PROD_VIEW,
						bddwr.UserManuelProcessedBankTransferDepositCnt																																			PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource UserManuelProcessedBankTransferDepositCnt*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource IbanRemittanceCnt*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'Tx.#'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'IbanRemittanceCnt'																																									BasedReportTableField,
						'FACT_Transactions'																																												Tested_DWH_Table,
						'FeatureType;Id'																																												Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'Cnt(CASE WHEN FeatureType = 21 THEN Id ELSE NULL END)'																																		Formula,
						'IBAN money transfer money transfer Tx.#'																																					MetricExplanation,
						addwr.IbanRemittanceCnt																																								CSHARP_TO_PROD_VIEW,
						bddwr.IbanRemittanceCnt																																								PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource IbanRemittanceCnt*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource IbanRemittanceVol*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'V.'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'IbanRemittanceVol'																																									BasedReportTableField,
						'FACT_Transactions'																																												Tested_DWH_Table,
						'FeatureType;TxAmount'																																											Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'ABS(SUM(CASE WHEN FeatureType = 21 THEN l.TxAmount	ELSE NULL END))'																															Formula,
						'IBAN money transfer money transfer Tx.V.'																																					MetricExplanation,
						addwr.IbanRemittanceVol																																								CSHARP_TO_PROD_VIEW,
						bddwr.IbanRemittanceVol																																								PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource IbanRemittanceVol*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource OnlyExternalTopUpCardDepositCnt*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'Tx.#'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'OnlyExternalTopUpCardDepositCnt'																																										BasedReportTableField,
						'FACT_Transactions'																																												Tested_DWH_Table,
						'IsDepositForPayment;Id'																																									Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'Cnt(CASE WHEN IsDepositForPayment = 0 THEN l.Id ELSE NULL END)'																															Formula,
						'Saved Card deposit Tx.# not for payment'																																					MetricExplanation,
						addwr.OnlyExternalTopUpCardDepositCnt																																									CSHARP_TO_PROD_VIEW,
						bddwr.OnlyExternalTopUpCardDepositCnt																																									PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource OnlyExternalTopUpCardDepositCnt*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource OnlyExternalTopUpCardDepositVol*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'V.'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'OnlyExternalTopUpCardDepositVol'																																										BasedReportTableField,
						'FACT_Transactions'																																												Tested_DWH_Table,
						'IsDepositForPayment;TxAmount'																																								Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'SUM(CASE WHEN IsDepositForPayment = 0 THEN TxAmount ELSE NULL END)'																															Formula,
						'Saved Card deposit Tx.V. not for payment'																																					MetricExplanation,
						addwr.OnlyExternalTopUpCardDepositVol																																									CSHARP_TO_PROD_VIEW,
						bddwr.OnlyExternalTopUpCardDepositVol																																									PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource OnlyExternalTopUpCardDepositVol*/
	
			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource OnlinePosTxVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'OnlinePosTxVol'																																								BasedReportTableField,
						'FACT_Transactions;FACT_MerchandiserTransactions'																																				Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;IsPhysicalCardTx;TxAmount'																																	Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'ABS(SUM(CASE WHEN FeatureType = 2 and DatabaseCardTxType = 1 AND IsPhysicalCardTx = 0 THEN TxAmount ELSE NULL END))'																		Formula,
						'Online POS Tx. Vol'																																							MetricExplanation,
						adpcr.OnlinePosTxVol																																							CSHARP_TO_PROD_VIEW,
						bdpcr.OnlinePosTxVol																																							PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource OnlinePosTxVol*/
 
			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource OnlinePosTxCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'OnlinePosTxCnt'																																								BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;IsPhysicalCardTx;Id'																																		Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN FeatureType = 2 and DatabaseCardTxType = 1 and  IsPhysicalCardTx = 0 THEN Id ELSE NULL END)'																				Formula,
						'Online POS Tx.#'																																								MetricExplanation,
						adpcr.OnlinePosTxCnt																																							CSHARP_TO_PROD_VIEW,
						bdpcr.OnlinePosTxCnt																																							PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource OnlinePosTxCnt*/
 
			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource OnlinePosTxUserCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'UU'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'OnlinePosTxUserCnt'																																							BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;IsPhysicalCardTx;User_Key'																																	Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 2 and DatabaseCardTxType = 1 and IsPhysicalCardTx = 0 THEN User_Key ELSE NULL END)'																Formula,
						'Online POS Tx. UU'																																								MetricExplanation,
						adpcr.OnlinePosTxUserCnt																																						CSHARP_TO_PROD_VIEW,
						bdpcr.OnlinePosTxUserCnt																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource OnlinePosTxUserCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource PhysicalTxPosTxVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'PhysicalTxPosTxVol'																																							BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;IsPhysicalCardTx;TxAmount'																																	Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'ABS(SUM(CASE WHEN FeatureType = 2 and DatabaseCardTxType = 1 and (IsPhysicalCardTx = 1 OR IsPhysicalCardTx IS NULL) THEN TxAmount ELSE NULL END))'												Formula,
						'PhysicalTx POS Tx. Vol'																																						MetricExplanation,
						adpcr.PhysicalTxPosTxVol																																						CSHARP_TO_PROD_VIEW,
						bdpcr.PhysicalTxPosTxVol																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource PhysicalTxPosTxVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource PhysicalTxPosTxCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'PhysicalTxPosTxCnt'																																								BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;IsPhysicalCardTx;Id'																																		Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN FeatureType = 2 and DatabaseCardTxType = 1 and (IsPhysicalCardTx = 1 OR IsPhysicalCardTx IS NULL) THEN Id ELSE NULL END)'														Formula,
						'PhysicalTx POS Tx.#'																																								MetricExplanation,
						adpcr.PhysicalTxPosTxCnt																																							CSHARP_TO_PROD_VIEW,
						bdpcr.PhysicalTxPosTxCnt																																							PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource PhysicalTxPosTxCnt*/
 
			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource PhysicalTxPosTxUserCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'UU'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'PhysicalTxPosTxUserCnt'																																							BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;IsPhysicalCardTx;User_Key'																																	Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 2 and DatabaseCardTxType = 1 and (IsPhysicalCardTx = 1 OR IsPhysicalCardTx IS NULL) THEN User_Key ELSE NULL END)'										Formula,
						'PhysicalTx POS Tx. UU'																																							MetricExplanation,
						adpcr.PhysicalTxPosTxUserCnt																																						CSHARP_TO_PROD_VIEW,
						bdpcr.PhysicalTxPosTxUserCnt																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource PhysicalTxPosTxUserCnt*/
 
			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource GeneralCardApplicationCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'GeneralCardApplicationCnt'																																						BasedReportTableField,
						'DIM_DatabaseCards'																																								Tested_DWH_Table,
						'Type;Id'																																										Tested_DWH_Table_Field,
						-1																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN [Type] in (4,5) THEN Id ELSE NULL END)'																														Formula,
						'Black Card Application Cnt'																																					MetricExplanation,
						adpcr.GeneralCardApplicationCnt																																					CSHARP_TO_PROD_VIEW,
						bdpcr.GeneralCardApplicationCnt																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_A    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource GeneralCardApplicationCnt*/
 
			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource ApplicationToActivationTimeAvg*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'ApplicationToActivationTimeAvg'																																				BasedReportTableField,
						'DIM_DatabaseCards'																																								Tested_DWH_Table,
						'Type;CreatedAt;ActivationDate'																																					Tested_DWH_Table_Field,
						-1																																												Currency,
						'N/A'																																											Value1,
						'AVG(CASE WHEN [Type] IN (4,5) AND datediff(day,CreatedAt,ActivationDate) < 120 THEN datediff(day,CreatedAt,ActivationDate) ELSE NULL END)'										Formula,
						'Day difference between Application & Activation for Black Card'																												MetricExplanation,
						adpcr.ApplicationToActivationTimeAvg																																			CSHARP_TO_PROD_VIEW,
						bdpcr.ApplicationToActivationTimeAvg																																			PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_B    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource ApplicationToActivationTimeAvg*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource GeneralCardActivationCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'GeneralCardActivationCnt'																																						BasedReportTableField,
						'DIM_DatabaseCards'																																								Tested_DWH_Table,
						'Type;ActivationDate;Id'																																						Tested_DWH_Table_Field,
						-1																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN [Type] IN (4,5) THEN Id ELSE NULL END)'																														Formula,
						'Black Card Activation #'																																						MetricExplanation,
						adpcr.GeneralCardActivationCnt																																					CSHARP_TO_PROD_VIEW,
						bdpcr.GeneralCardActivationCnt																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_B    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource GeneralCardActivationCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource RetailCardActivationCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'RetailCardActivationCnt'																																						BasedReportTableField,
						'DIM_DatabaseCards'																																								Tested_DWH_Table,
						'Type;ActivationDate;Id'																																						Tested_DWH_Table_Field,
						-1																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN [Type] IN (6,7) THEN Id ELSE NULL END)'																														Formula,
						'Lite Card Activation #'																																						MetricExplanation,
						adpcr.RetailCardActivationCnt																																					CSHARP_TO_PROD_VIEW,
						bdpcr.RetailCardActivationCnt																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_B    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource RetailCardActivationCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource PremiumCardActivationCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'PremiumCardActivationCnt'																																						BasedReportTableField,
						'DIM_DatabaseCards'																																								Tested_DWH_Table,
						'Type;ActivationDate;Id'																																						Tested_DWH_Table_Field,
						-1																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN [Type] = 8 THEN Id ELSE NULL END)'																																Formula,
						'Metal Card Activation #'																																						MetricExplanation,
						adpcr.PremiumCardActivationCnt																																					CSHARP_TO_PROD_VIEW,
						bdpcr.PremiumCardActivationCnt																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_B    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource PremiumCardActivationCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource AtmWithdrawalTxUserCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'UU'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'AtmWithdrawalTxUserCnt'																																						BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;User_Key'																																			Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(DISTINCT	CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 0 THEN User_Key ELSE NULL END)'																					Formula,
						'UU withdrew money from ATM'																																					MetricExplanation,
						adpcr.AtmWithdrawalTxUserCnt																																					CSHARP_TO_PROD_VIEW,
						bdpcr.AtmWithdrawalTxUserCnt																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource AtmWithdrawalTxUserCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource AtmDepositTxUserCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'UU'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'AtmDepositTxUserCnt'																																							BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;User_Key'																																			Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(DISTINCT	CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 5 THEN User_Key ELSE NULL END)'																					Formula,
						'UU deposited money from ATM'																																					MetricExplanation,
						adpcr.AtmDepositTxUserCnt																																						CSHARP_TO_PROD_VIEW,
						bdpcr.AtmDepositTxUserCnt																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource AtmDepositTxUserCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource CardToCardTransferTxVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'CardToCardTransferTxVol'																																					BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;TxAmount'																																				Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'SUM(CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 4 THEN TxAmount ELSE NULL END)'																								Formula,
						'Card to Card Money Transfer Vol (Aka KKPT)'																																	MetricExplanation,
						adpcr.CardToCardTransferTxVol																																				CSHARP_TO_PROD_VIEW,
						bdpcr.CardToCardTransferTxVol																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource CardToCardTransferTxVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource GiftCardTxVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'GiftCardTxVol'																																								BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;TxAmount'																																								Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'ABS(SUM(CASE WHEN FeatureType = 23 THEN TxAmount ELSE NULL END))'																													Formula,
						'Gift Card Tx. Vol'																																							MetricExplanation,
						adpcr.GiftCardTxVol																																							CSHARP_TO_PROD_VIEW,
						bdpcr.GiftCardTxVol																																							PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource GiftCardTxVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource GiftCardTxCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'GiftCardTxCnt'																																								BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;Id'																																									Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN FeatureType = 23 THEN Id ELSE NULL END)'																															Formula,
						'Gift Card Tx.#'																																								MetricExplanation,
						adpcr.GiftCardTxCnt																																							CSHARP_TO_PROD_VIEW,
						bdpcr.GiftCardTxCnt																																							PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource GiftCardTxCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource AtmWithdrawalTxFeeVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'AtmWithdrawalTxFeeVol'																																						BasedReportTableField,
						'FACT_Transactions;FACT_MerchandiserTransactions'																																				Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType'																																					Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'ABS(SUM(CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 0 THEN Fee ELSE NULL END))'																								Formula,
						'ATM Withdrawal Tx. Fee Vol'																																					MetricExplanation,
						adpcr.AtmWithdrawalTxFeeVol																																					CSHARP_TO_PROD_VIEW,
						bdpcr.AtmWithdrawalTxFeeVol																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource AtmWithdrawalTxFeeVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource AtmDepositTxFeeVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'AtmDepositTxFeeVol'																																							BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;Fee'																																				Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'ABS(SUM(CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 5 THEN Fee ELSE NULL END))'																								Formula,
						'ATM Deposit Tx. Fee Vol'																																					MetricExplanation,
						adpcr.AtmDepositTxFeeVol																																						CSHARP_TO_PROD_VIEW,
						bdpcr.AtmDepositTxFeeVol																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource AtmDepositTxFeeVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource AtmBalanceInquiryTxFeeVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'AtmBalanceInquiryTxFeeVol'																																					BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;TxAmount'																																				Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'ABS(SUM(CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 2 THEN TxAmount ELSE NULL END))'																							Formula,
						'ATM Balance Inquiry Tx. Fee Vol'																																			MetricExplanation,
						adpcr.AtmBalanceInquiryTxFeeVol																																				CSHARP_TO_PROD_VIEW,
						bdpcr.AtmBalanceInquiryTxFeeVol																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource AtmBalanceInquiryTxFeeVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource AtmBalanceInquiryTxCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'AtmBalanceInquiryTxCnt'																																						BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;Id'																																					Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 2 THEN Id ELSE NULL END)'																									Formula,
						'ATM Balance Inquiry Tx.#'																																						MetricExplanation,
						adpcr.AtmBalanceInquiryTxCnt																																					CSHARP_TO_PROD_VIEW,
						bdpcr.AtmBalanceInquiryTxCnt																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource AtmBalanceInquiryTxCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource CardToCardTransferTxCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'CardToCardTransferTxCnt'																																						BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;Id'																																					Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 4 THEN Id ELSE NULL END)'																									Formula,
						'Card to Card Money Transfer Tx.# (Aka KKPT)'																																	MetricExplanation,
						adpcr.CardToCardTransferTxCnt																																					CSHARP_TO_PROD_VIEW,
						bdpcr.CardToCardTransferTxCnt																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource CardToCardTransferTxCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource CollectionFootballCardFeeVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'CollectionFootballCardFeeVol'																																							BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;EntrySubType'																																						Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'ABS(SUM(CASE WHEN FeatureType = 29 AND (EntrySubType = 0 OR EntrySubType IS NULL) THEN TxAmount ELSE NULL END))'																	Formula,
						'CollectionFootballCard Charge Total Vol'																																				MetricExplanation,
						adpcr.CollectionFootballCardFeeVol																																						CSHARP_TO_PROD_VIEW,
						bdpcr.CollectionFootballCardFeeVol																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource CollectionFootballCardFeeVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource CollectionTeamCardFeeVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'CollectionTeamCardFeeVol'																																							BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;EntrySubType'																																						Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'ABS(SUM(CASE WHEN FeatureType = 29 AND EntrySubType = 2 THEN TxAmount ELSE NULL END)'																								Formula,
						'Joker Card Charge Total Vol'																																				MetricExplanation,
						adpcr.CollectionTeamCardFeeVol																																						CSHARP_TO_PROD_VIEW,
						bdpcr.CollectionTeamCardFeeVol																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource CollectionTeamCardFeeVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource DatabaseCardTxUserDailyCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'UU'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'DatabaseCardTxUserDailyCnt'																																					BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;User_Key'																																								Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 2 THEN User_Key ELSE NULL END)'																											Formula,
						'Daily UU of whole Database Card'																																					MetricExplanation,
						adpcr.DatabaseCardTxUserDailyCnt																																				CSHARP_TO_PROD_VIEW,
						bdpcr.DatabaseCardTxUserDailyCnt																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource DatabaseCardTxUserDailyCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource TotalPosTxUserDailyCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'UU'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'TotalPosTxUserDailyCnt'																																						BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;User_Key'																																			Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 1 THEN User_Key ELSE NULL END)'																					Formula,
						'Daily POS UU of whole Database Card'																																				MetricExplanation,
						adpcr.TotalPosTxUserDailyCnt																																					CSHARP_TO_PROD_VIEW,
						bdpcr.TotalPosTxUserDailyCnt																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource TotalPosTxUserDailyCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource TotalAtmTxUserDailyCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'UU'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'TotalAtmTxUserDailyCnt'																																						BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;User_Key'																																			Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 2 AND DatabaseCardTxType in (0,5) THEN User_Key ELSE NULL END)'																				Formula,
						'UU withdrew or deposit money from ATM'																																			MetricExplanation,
						adpcr.TotalAtmTxUserDailyCnt																																					CSHARP_TO_PROD_VIEW,
						bdpcr.TotalAtmTxUserDailyCnt																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource TotalAtmTxUserDailyCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource DatabaseCardShipmentFeeVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'DatabaseCardShipmentFeeVol'																																					BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType'																																					Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'ABS(SUM(CASE WHEN EntrySubType = 1 THEN TxAmount  ELSE NULL END))'																												Formula,
						'Database Card shipment fee'																																						MetricExplanation,
						adpcr.DatabaseCardShipmentFeeVol																																				CSHARP_TO_PROD_VIEW,
						bdpcr.DatabaseCardShipmentFeeVol																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource DatabaseCardShipmentFeeVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource AtmDepositTxVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'AtmDepositTxVol'																																							BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;TxAmount'																																				Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'ABS(SUM(CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 5 THEN TxAmount ELSE NULL END))'																							Formula,
						'ATM Deposit Tx. Vol'																																						MetricExplanation,
						adpcr.AtmDepositTxVol																																						CSHARP_TO_PROD_VIEW,
						bdpcr.AtmDepositTxVol																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource AtmDepositTxVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource AtmDepositTxCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'AtmDepositTxCnt'																																								BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;Id'																																					Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 5 THEN Id ELSE NULL END)' 																								Formula,
						'ATM Deposit Tx.#'																																								MetricExplanation,
						adpcr.AtmDepositTxCnt																																							CSHARP_TO_PROD_VIEW,
						bdpcr.AtmDepositTxCnt																																							PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource AtmDepositTxCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource AtmWithdrawalTxVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'AtmWithdrawalTxVol'																																							BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;TxAmount'																																				Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'ABS(SUM(CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 0 THEN TxAmount ELSE NULL END))'																							Formula,
						'ATM Withdrawal Tx.V'																																							MetricExplanation,
						adpcr.AtmWithdrawalTxVol																																						CSHARP_TO_PROD_VIEW,
						bdpcr.AtmWithdrawalTxVol																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource AtmWithdrawalTxVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource AtmWithdrawalTxCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'AtmWithdrawalTxCnt'																																							BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;Id'																																					Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 0 THEN Id ELSE NULL END)'																									Formula,
						'ATM Withdrawal Tx.#'																																							MetricExplanation,
						adpcr.AtmWithdrawalTxCnt																																						CSHARP_TO_PROD_VIEW,
						bdpcr.AtmWithdrawalTxCnt																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource AtmWithdrawalTxCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource RetailCardRefundTxCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'RetailCardRefundTxCnt'																																							BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType'																																					Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 8 THEN Id ELSE NULL END)'																									Formula,
						'Lite Card Refund Tx.# (RetailCard prices must be refunded to User)'																												MetricExplanation,
						adpcr.RetailCardRefundTxCnt																																						CSHARP_TO_PROD_VIEW,
						bdpcr.RetailCardRefundTxCnt																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource RetailCardRefundTxCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource RetailCardRefundTxVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'RetailCardRefundTxVol'																																						BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;TxAmount'																																				Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'SUM(CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 8 THEN TxAmount ELSE NULL END)'																								Formula,
						'Lite Card Refund Tx.V. (RetailCard prices must be refunded to User)'																												MetricExplanation,
						adpcr.RetailCardRefundTxVol																																					CSHARP_TO_PROD_VIEW,
						bdpcr.RetailCardRefundTxVol																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource RetailCardRefundTxVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource PosTxRefundCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'PosTxRefundCnt'																																								BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;IsCancellation;Id'																																	Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 1 AND IsCancellation = 1 THEN Id ELSE NULL END)'																			Formula,
						'POS Refund Tx.# for cancelled Tx.'																																				MetricExplanation,
						adpcr.PosTxRefundCnt																																							CSHARP_TO_PROD_VIEW,
						bdpcr.PosTxRefundCnt																																							PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource PosTxRefundCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource PosTxRefundVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'PosTxRefundVol'																																								BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;IsCancellation;TxAmount'																																Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'SUM(CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 1 AND IsCancellation = 1 THEN TxAmount ELSE NULL END)'																		Formula,
						'POS Refund Tx.V. for cancelled Tx.'																																			MetricExplanation,
						adpcr.PosTxRefundVol																																							CSHARP_TO_PROD_VIEW,
						bdpcr.PosTxRefundVol																																							PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource PosTxRefundVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource AtmWithdrawalTxRefundCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'AtmWithdrawalTxRefundCnt'																																					BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;IsCancellation;Id'																																	Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 0 AND IsCancellation = 1 THEN Id ELSE NULL END)'																			Formula,
						'ATM Withdrawal Refund Tx.# for cancelled Tx.'																																	MetricExplanation,
						adpcr.AtmWithdrawalTxRefundCnt																																				CSHARP_TO_PROD_VIEW,
						bdpcr.AtmWithdrawalTxRefundCnt																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource AtmWithdrawalTxRefundCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource AtmWithdrawalTxRefundVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'AtmWithdrawalTxRefundVol'																																					BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;IsCancellation;TxAmount'																																Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'SUM(CASE WHEN FeatureType = 2 AND DatabaseCardTxType = 0 AND IsCancellation = 1 THEN TxAmount ELSE NULL END)'																		Formula,
						'ATM Refund Tx.V. for cancelled Tx.'																																			MetricExplanation,
						adpcr.AtmWithdrawalTxRefundVol																																				CSHARP_TO_PROD_VIEW,
						bdpcr.AtmWithdrawalTxRefundVol																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource AtmWithdrawalTxRefundVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource CorporateGiftCardTxCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'CorporateGiftCardTxCnt'																																						BasedReportTableField,
						'FACT_MerchandiserTransactions'																																							Tested_DWH_Table,
						'FeatureType;Id'																																									Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN FeatureType = 23 THEN Id ELSE NULL END)'																															Formula,
						'Corpore GiftCard Tx.# loaded by Merchandisers'																																		MetricExplanation,
						adpcr.CorporateGiftCardTxCnt																																					CSHARP_TO_PROD_VIEW,
						bdpcr.CorporateGiftCardTxCnt																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource CorporateGiftCardTxCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource CorporateGiftCardTxVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'CorporateGiftCardTxVol'																																						BasedReportTableField,
						'FACT_MerchandiserTransactions'																																							Tested_DWH_Table,
						'FeatureType;TxAmount'																																								Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'ABS(SUM(CASE WHEN FeatureType = 23 THEN TxAmount ELSE NULL END))'																													Formula,
						'Corpore GiftCard Tx.V. loaded by Merchandisers'																																	MetricExplanation,
						adpcr.CorporateGiftCardTxVol																																					CSHARP_TO_PROD_VIEW,
						bdpcr.CorporateGiftCardTxVol																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource CorporateGiftCardTxVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource NewVirtualCardCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'NewVirtualCardCnt'																																							BasedReportTableField,
						'FACT_Transactions'																																									Tested_DWH_Table,
						'Type;Id'																																										Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(DISTINCT CASE WHEN [Type] in (3,9,10,11) THEN Id ELSE NULL END)'																											Formula,
						'New Virtual Card Cnt'																																						MetricExplanation,
						adpcr.NewVirtualCardCnt																																						CSHARP_TO_PROD_VIEW,
						bdpcr.NewVirtualCardCnt																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_A    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource NewVirtualCardCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource PaidNewVirtualCardCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'PaidNewVirtualCardCnt'																																						BasedReportTableField,
						'FACT_Transactions;FACT_MerchandiserTransactions'																																				Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;Id'																																					Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN DatabaseCardTxType = 6 THEN Id ELSE NULL END)'																													Formula,
						'Charged Virtual Card Cnt (Cnt version of VirtualCardFeeVol)'																											MetricExplanation,
						adpcr.PaidNewVirtualCardCnt																																					CSHARP_TO_PROD_VIEW,
						bdpcr.PaidNewVirtualCardCnt																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource PaidNewVirtualCardCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource VirtualCardFeeVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'VirtualCardFeeVol'																																							BasedReportTableField,
						'FACT_Transactions;FACT_MerchandiserTransactions'																																				Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;TxAmount'																																				Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'ABS(SUM(CASE WHEN DatabaseCardTxType = 6 THEN TxAmount ELSE NULL END))'																											Formula,
						'Virtual Card Charge Vol (Vol of PaidNewVirtualCardCnt)'																												MetricExplanation,
						adpcr.VirtualCardFeeVol																																						CSHARP_TO_PROD_VIEW,
						bdpcr.VirtualCardFeeVol																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource VirtualCardFeeVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource DeclinedPhysicalTxPosTxCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'DeclinedPhysicalTxPosTxCnt'																																						BasedReportTableField,
						'FACT_DatabaseCardTransactionFailedLogs'																																			Tested_DWH_Table,
						'TransactionType;PentryMode;Id'																																					Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN TransactionType = 1 AND PentryMode NOT IN ("010","011","012","100","102","810","811","812","W","R","O","L") THEN Id ELSE NULL END)'							Formula,
						'Declined PhysicalTx POS Tx.#'																																						MetricExplanation,
						adpcr.DeclinedPhysicalTxPosTxCnt																																					CSHARP_TO_PROD_VIEW,
						bdpcr.DeclinedPhysicalTxPosTxCnt																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_C    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource DeclinedPhysicalTxPosTxCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource DeclinedPhysicalTxPosTxVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'DeclinedPhysicalTxPosTxVol'																																					BasedReportTableField,
						'FACT_DatabaseCardTransactionFailedLogs'																																			Tested_DWH_Table,
						'TransactionType;PentryMode;TxAmount'																																				Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'ABS(SUM(CASE WHEN TransactionType = 1 AND PentryMode NOT IN ("010","011","012","100","102","810","811","812","W","R","O","L") THEN TxAmount ELSE NULL END))'						Formula,
						'Declined PhysicalTx POS Tx.V.'																																					MetricExplanation,
						adpcr.DeclinedPhysicalTxPosTxVol																																				CSHARP_TO_PROD_VIEW,
						bdpcr.DeclinedPhysicalTxPosTxVol																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_C    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource DeclinedPhysicalTxPosTxVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource DeclinedOnlinePosTxCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'DeclinedOnlinePosTxCnt'																																						BasedReportTableField,
						'FACT_DatabaseCardTransactionFailedLogs'																																			Tested_DWH_Table,
						'TransactionType;PentryMode;Id'																																					Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN TransactionType = 1 AND PentryMode IN ("010","011","012","100","102","810","811","812","W","R","O","L") THEN Id ELSE NULL END)'								Formula,
						'Declined Online POS Tx.#'																																						MetricExplanation,
						adpcr.DeclinedOnlinePosTxCnt																																					CSHARP_TO_PROD_VIEW,
						bdpcr.DeclinedOnlinePosTxCnt																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_C    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource DeclinedOnlinePosTxCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource DeclinedOnlinePosTxVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'DeclinedOnlinePosTxVol'																																						BasedReportTableField,
						'FACT_DatabaseCardTransactionFailedLogs'																																			Tested_DWH_Table,
						'TransactionType;PentryMode;TxAmount'																																				Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'ABS(SUM(CASE WHEN TransactionType = 1 AND PentryMode IN ("010","011","012","100","102","810","811","812","W","R","O","L") THEN TxAmount ELSE NULL END))'							Formula,
						'Declined Online POS Tx.V.'																																						MetricExplanation,
						adpcr.DeclinedOnlinePosTxVol																																					CSHARP_TO_PROD_VIEW,
						bdpcr.DeclinedOnlinePosTxVol																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_C    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource DeclinedOnlinePosTxVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource DeclinedAtmWithdrawalTxCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'DeclinedAtmWithdrawalTxCnt'																																					BasedReportTableField,
						'FACT_DatabaseCardTransactionFailedLogs'																																			Tested_DWH_Table,
						'TransactionType;PentryMode;Id'																																					Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN TransactionType = 0 THEN Id ELSE NULL END)'																													Formula,
						'Declined ATM Withdrawal Tx.#'																																					MetricExplanation,
						adpcr.DeclinedAtmWithdrawalTxCnt																																				CSHARP_TO_PROD_VIEW,
						bdpcr.DeclinedAtmWithdrawalTxCnt																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_C    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource DeclinedAtmWithdrawalTxCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource DeclinedAtmWithdrawalTxVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'DeclinedAtmWithdrawalTxVol'																																					BasedReportTableField,
						'FACT_DatabaseCardTransactionFailedLogs'																																			Tested_DWH_Table,
						'TransactionType;PentryMode;TxAmount'																																				Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'ABS(SUM(CASE WHEN TransactionType = 0 THEN TxAmount ELSE NULL END))'																												Formula,
						'Declined ATM Withdrawal Tx.V.'																																					MetricExplanation,
						adpcr.DeclinedAtmWithdrawalTxVol																																				CSHARP_TO_PROD_VIEW,
						bdpcr.DeclinedAtmWithdrawalTxVol																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_C    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource DeclinedAtmWithdrawalTxVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource ActiveGeneralCardDailyCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'UC'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'ActiveGeneralCardDailyCnt'																																						BasedReportTableField,
						'FACT_Transactions;DIM_DatabaseCards'																																					Tested_DWH_Table,
						'FeatureType;Type;DatabaseCardId'																																					Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 2 AND [Type] in (4,5) THEN DatabaseCardId ELSE NULL END)'																					Formula,
						'Daily Unique Black Cards with Tx.'																																				MetricExplanation,
						adpcr.ActiveGeneralCardDailyCnt																																					CSHARP_TO_PROD_VIEW,
						bdpcr.ActiveGeneralCardDailyCnt																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_D    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource ActiveGeneralCardDailyCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource ActiveRetailCardDailyCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'UC'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'ActiveRetailCardDailyCnt'																																						BasedReportTableField,
						'FACT_Transactions;DIM_DatabaseCards'																																					Tested_DWH_Table,
						'FeatureType;Type;DatabaseCardId'																																					Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 2 AND [Type] in (6,7) THEN DatabaseCardId ELSE NULL END)'																					Formula,
						'Daily Unique Lite Cards with Tx.'																																				MetricExplanation,
						adpcr.ActiveRetailCardDailyCnt																																					CSHARP_TO_PROD_VIEW,
						bdpcr.ActiveRetailCardDailyCnt																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_D    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource ActiveRetailCardDailyCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource ActiveVirtualCardDailyCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'UC'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'ActiveVirtualCardDailyCnt'																																					BasedReportTableField,
						'FACT_Transactions;DIM_DatabaseCards'																																					Tested_DWH_Table,
						'FeatureType;Type;DatabaseCardTxType'																																				Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 2 AND [Type] in (3,9,10) THEN DatabaseCardId ELSE NULL END)'																				Formula,
						'Daily Unique Virtual Cards with Tx.'																																			MetricExplanation,
						adpcr.ActiveVirtualCardDailyCnt																																				CSHARP_TO_PROD_VIEW,
						bdpcr.ActiveVirtualCardDailyCnt																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_D    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource ActiveVirtualCardDailyCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource ActiveCorporateCardDailyCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'UC'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'ActiveCorporateCardDailyCnt'																																					BasedReportTableField,
						'FACT_Transactions;DIM_DatabaseCards'																																					Tested_DWH_Table,
						'FeatureType;Type;DatabaseCardId'																																					Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 2 AND [Type] in (1,11) THEN DatabaseCardId ELSE NULL END)'																					Formula,
						'Daily Unique Corporate Cards with Tx.'																																			MetricExplanation,
						adpcr.ActiveCorporateCardDailyCnt																																				CSHARP_TO_PROD_VIEW,
						bdpcr.ActiveCorporateCardDailyCnt																																				PROD_TO_DWH_VIEW,  0 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_E    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource ActiveCorporateCardDailyCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource ActivePremiumCardDailyCnt  */
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'UC'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'ActivePremiumCardDailyCnt  '																																					BasedReportTableField,
						'FACT_Transactions;DIM_DatabaseCards'																																					Tested_DWH_Table,
						'FeatureType;Type;DatabaseCardId'																																					Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 2 AND [Type] = 8 THEN DatabaseCardId ELSE NULL END)'																						Formula,
						'Daily Unique Metal Cards with Tx.'																																				MetricExplanation,
						adpcr.ActivePremiumCardDailyCnt  																																				CSHARP_TO_PROD_VIEW,
						bdpcr.ActivePremiumCardDailyCnt  																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_D    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource ActivePremiumCardDailyCnt  */

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource GeneralCardPosTxCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'GeneralCardPosTxCnt'																																							BasedReportTableField,
						'FACT_Transactions;DIM_DatabaseCards'																																					Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;Type;Id'																																			Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN FeatureType = 2 AND [Type] in (4,5) AND DatabaseCardTxType = 1	THEN l.Id ELSE NULL END)'																													Formula,
						'Black Card POS Tx.#'																																							MetricExplanation,
						adpcr.GeneralCardPosTxCnt																																						CSHARP_TO_PROD_VIEW,
						bdpcr.GeneralCardPosTxCnt																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_D    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource GeneralCardPosTxCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource GeneralCardPosTxVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'GeneralCardPosTxVol'																																							BasedReportTableField,
						'FACT_Transactions;DIM_DatabaseCards'																																					Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;Type;TxAmount'																																		Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'ABS(SUM(CASE WHEN FeatureType = 2 AND [Type] in (4,5) AND DatabaseCardTxType = 1 THEN TxAmount ELSE NULL END))'																		Formula,
						'Black Card POS Tx.V.'																																							MetricExplanation,
						adpcr.GeneralCardPosTxVol																																						CSHARP_TO_PROD_VIEW,
						bdpcr.GeneralCardPosTxVol																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_D    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource GeneralCardPosTxVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource VirtualCardPosTxCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'VirtualCardPosTxCnt'																																							BasedReportTableField,
						'FACT_Transactions;DIM_DatabaseCards'																																					Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;Type;Id'																																			Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN FeatureType = 2 AND [Type] in (3,9,10) AND DatabaseCardTxType = 1 THEN l.Id ELSE NULL END)'																		Formula,
						'Virtual Card POS Tx.#'																																							MetricExplanation,
						adpcr.VirtualCardPosTxCnt																																						CSHARP_TO_PROD_VIEW,
						bdpcr.VirtualCardPosTxCnt																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_D    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource VirtualCardPosTxCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource VirtualCardPosTxVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'VirtualCardPosTxVol'																																						BasedReportTableField,
						'FACT_Transactions;DIM_DatabaseCards'																																					Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;Type;TxAmount'																																		Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'ABS(SUM(CASE WHEN FeatureType = 2 AND [Type] in (3,9,10)	AND DatabaseCardTxType = 1 THEN TxAmount ELSE NULL END))'																	Formula,
						'Virtual Card POS Tx.V.'																																						MetricExplanation,
						adpcr.VirtualCardPosTxVol																																					CSHARP_TO_PROD_VIEW,
						bdpcr.VirtualCardPosTxVol																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_D    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource VirtualCardPosTxVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource GiftCardPosTxCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'GiftCardPosTxCnt'																																							BasedReportTableField,
						'FACT_Transactions;DIM_DatabaseCards'																																					Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;Type;Id'																																			Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN FeatureType = 2 AND [Type] = 9 AND DatabaseCardTxType = 1 THEN L.Id ELSE NULL END)'																				Formula,
						'Gift Card POS Tx.#'																																							MetricExplanation,
						adpcr.GiftCardPosTxCnt																																						CSHARP_TO_PROD_VIEW,
						bdpcr.GiftCardPosTxCnt																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_D    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource GiftCardPosTxCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource GiftCardPosTxVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'GiftCardPosTxVol'																																							BasedReportTableField,
						'FACT_Transactions;DIM_DatabaseCards'																																					Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;Type;TxAmount'																																		Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'SUM(CASE WHEN FeatureType = 2 AND [Type] = 9 AND DatabaseCardTxType = 1 THEN TxAmount ELSE NULL END)'																				Formula,
						'Gift Card POS Tx.V.'																																							MetricExplanation,
						adpcr.GiftCardPosTxVol																																						CSHARP_TO_PROD_VIEW,
						bdpcr.GiftCardPosTxVol																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_D    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource GiftCardPosTxVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource CorporateGiftCardPosTxCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'CorporateGiftCardPosTxCnt'																																					BasedReportTableField,
						'FACT_Transactions;DIM_DatabaseCards'																																					Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;Type;Id'																																			Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN FeatureType = 2 AND [Type] = 12 AND DatabaseCardTxType = 1	THEN L.Id ELSE NULL END)'																				Formula,
						'Corporate Gift Card POS Tx.#'																																					MetricExplanation,
						adpcr.CorporateGiftCardPosTxCnt																																				CSHARP_TO_PROD_VIEW,
						bdpcr.CorporateGiftCardPosTxCnt																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_D    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource CorporateGiftCardPosTxCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource CorporateGiftCardPosTxVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'CorporateGiftCardPosTxVol'																																					BasedReportTableField,
						'FACT_Transactions;DIM_DatabaseCards'																																					Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;Type;TxAmount'																																		Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'SUM(CASE WHEN FeatureType = 2 AND [Type] = 12 AND DatabaseCardTxType = 1 THEN TxAmount ELSE NULL END)'																				Formula,
						'Corporate Gift Card POS Tx.V.'																																					MetricExplanation,
						adpcr.CorporateGiftCardPosTxVol																																				CSHARP_TO_PROD_VIEW,
						bdpcr.CorporateGiftCardPosTxVol																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_D    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource CorporateGiftCardPosTxVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource CorporateCardPosTxCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'CorporateCardPosTxCnt'																																						BasedReportTableField,
						'FACT_Transactions;DIM_DatabaseCards'																																					Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;Type;Id'																																			Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN FeatureType = 2 AND [Type] in (1,11)	AND DatabaseCardTxType = 1 THEN mL.Id ELSE NULL END)'																			Formula,
						'Corporate Card POS Tx.#'																																						MetricExplanation,
						adpcr.CorporateCardPosTxCnt																																					CSHARP_TO_PROD_VIEW,
						bdpcr.CorporateCardPosTxCnt																																					PROD_TO_DWH_VIEW,  0 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_E    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource CorporateCardPosTxCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource CorporateCardPosTxVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'CorporateCardPosTxVol'																																						BasedReportTableField,
						'FACT_Transactions;DIM_DatabaseCards'																																					Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;Type;TxAmount'																																		Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'ABS(SUM(CASE WHEN FeatureType = 2 AND [Type] in (1,11) AND DatabaseCardTxType = 1 THEN TxAmount ELSE NULL END))'																		Formula,
						'Corporate Card POS Tx.V.'																																						MetricExplanation,
						adpcr.CorporateCardPosTxVol																																					CSHARP_TO_PROD_VIEW,
						bdpcr.CorporateCardPosTxVol																																					PROD_TO_DWH_VIEW,  0 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_E    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource CorporateCardPosTxVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource GeneralCardAtmWithdrawalTxCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'GeneralCardAtmWithdrawalTxCnt'																																					BasedReportTableField,
						'FACT_Transactions;DIM_DatabaseCards'																																					Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;Type;Id'																																			Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN FeatureType = 2 AND [Type] in (4,5) AND DatabaseCardTxType = 0	THEN L.Id ELSE NULL END)'																			Formula,
						'Black Card ATM Withdrawal Tx.#'																																				MetricExplanation,
						adpcr.GeneralCardAtmWithdrawalTxCnt																																				CSHARP_TO_PROD_VIEW,
						bdpcr.GeneralCardAtmWithdrawalTxCnt																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_D    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource GeneralCardAtmWithdrawalTxCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource GeneralCardAtmWithdrawalTxVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'GeneralCardAtmWithdrawalTxVol'																																				BasedReportTableField,
						'FACT_Transactions;DIM_DatabaseCards'																																					Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;Type;TxAmount'																																		Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'ABS(SUM(CASE WHEN FeatureType = 2 AND [Type] in (4,5) AND DatabaseCardTxType = 0 THEN TxAmount ELSE NULL END))'																		Formula,
						'Black Card ATM Withdrawal Tx.V.'																																				MetricExplanation,
						adpcr.GeneralCardAtmWithdrawalTxVol																																			CSHARP_TO_PROD_VIEW,
						bdpcr.GeneralCardAtmWithdrawalTxVol																																			PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_D    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource GeneralCardAtmWithdrawalTxVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource GeneralCardAtmDepositTxCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'GeneralCardAtmDepositTxCnt'																																					BasedReportTableField,
						'FACT_Transactions;DIM_DatabaseCards'																																					Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;Type;Id'																																			Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN FeatureType = 2 AND [Type] in (4,5) AND DatabaseCardTxType = 5	THEN L.Id ELSE NULL END)'																			Formula,
						'Black Card ATM Deposit Tx.#'																																					MetricExplanation,
						adpcr.GeneralCardAtmDepositTxCnt																																				CSHARP_TO_PROD_VIEW,
						bdpcr.GeneralCardAtmDepositTxCnt																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_D    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource GeneralCardAtmDepositTxCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource GeneralCardAtmDepositTxVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'GeneralCardAtmDepositTxVol'																																					BasedReportTableField,
						'FACT_Transactions;DIM_DatabaseCards'																																					Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;Type;TxAmount'																																		Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'ABS(SUM(CASE WHEN FeatureType = 2 AND [Type] in (4,5) AND DatabaseCardTxType = 5 THEN TxAmount ELSE NULL END))'																		Formula,
						'Black Card ATM Deposit Tx.V.'																																					MetricExplanation,
						adpcr.GeneralCardAtmDepositTxVol																																				CSHARP_TO_PROD_VIEW,
						bdpcr.GeneralCardAtmDepositTxVol																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_D    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource GeneralCardAtmDepositTxVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource RetailCardAtmDepositTxCnt*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'Tx.#'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'RetailCardAtmDepositTxCnt'																																						BasedReportTableField,
						'FACT_Transactions;DIM_DatabaseCards'																																					Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;Type;Id'																																			Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'Cnt(CASE WHEN FeatureType = 2 AND [Type] in (6,7) AND DatabaseCardTxType = 5	THEN L.Id ELSE NULL END)'																			Formula,
						'Lite Card ATM Deposit Tx.#'																																					MetricExplanation,
						adpcr.RetailCardAtmDepositTxCnt																																					CSHARP_TO_PROD_VIEW,
						bdpcr.RetailCardAtmDepositTxCnt																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_D    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource RetailCardAtmDepositTxCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource RetailCardAtmDepositTxVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'RetailCardAtmDepositTxVol'																																					BasedReportTableField,
						'FACT_Transactions;DIM_DatabaseCards'																																					Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;Type;TxAmount'																																		Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'ABS(SUM(CASE WHEN FeatureType = 2 AND [Type] in (6,7) AND DatabaseCardTxType = 5 THEN TxAmount ELSE NULL END))'																		Formula,
						'Lite Card ATM Deposit Tx.V.'																																					MetricExplanation,
						adpcr.RetailCardAtmDepositTxVol																																				CSHARP_TO_PROD_VIEW,
						bdpcr.RetailCardAtmDepositTxVol																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_D    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource RetailCardAtmDepositTxVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource PremiumCardFeeVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'PremiumCardFeeVol'																																							BasedReportTableField,
						'FACT_Transactions;DIM_DatabaseCards'																																					Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;Type;TxAmount'																																		Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'SUM(CASE WHEN FeatureType = 2 AND [Type] = 8 AND DatabaseCardTxType = 3 THEN TxAmount ELSE NULL END)'																				Formula,
						'Charged Metal Cards Fee Vol'																																				MetricExplanation,
						adpcr.PremiumCardFeeVol																																						CSHARP_TO_PROD_VIEW,
						bdpcr.PremiumCardFeeVol																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_D    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource PremiumCardFeeVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource VoiceCardFeeVol*/
				  SELECT 
						bdpcr.[Date]																																									StreamDate,
						'V.'																																											TestType,
						'FACT_DailyDatabaseCardCSEntityDataSource'																																					BasedReportTable,
						'VoiceCardFeeVol'																																							BasedReportTableField,
						'FACT_Transactions;DIM_DatabaseCards'																																					Tested_DWH_Table,
						'FeatureType;DatabaseCardTxType;Type;TxAmount'																																		Tested_DWH_Table_Field,
						0																																												Currency,
						'N/A'																																											Value1,
						'SUM(CASE WHEN FeatureType = 2 AND [Type] = 15 AND DatabaseCardTxType = 3 THEN TxAmount ELSE NULL END)'																				Formula,
						'Charged Voice Cards Fee Vol'																																				MetricExplanation,
						adpcr.VoiceCardFeeVol																																						CSHARP_TO_PROD_VIEW,
						bdpcr.VoiceCardFeeVol																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_D    bdpcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource adpcr on bdpcr.[Date] = adpcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource VoiceCardFeeVol*/

UNION ALL
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource CashbackCnt*/
				  SELECT 
						 bdpccr.[Date]																																													 StreamDate,
						'Tx.#'																																															 TestType,
						'FACT_DailyDatabaseCardCashbackCSEntityDataSource'																																							 BasedReportTable,
						'CashbackCnt'																																										 			 BasedReportTableField,
						'FACT_Transactions;DIM_CashbackConditions'																																							 Tested_DWH_Table,
						'FeatureType;ConditionId;Id'																																										 Tested_DWH_Table_Field,
						0																																																 Currency,
						 bdpccr.CashbackName																																											 Value1,
						'Cnt(CASE WHEN FeatureType = 15 THEN L.Id ELSE NULL END)'																																		 Formula,
						'Cashback Tx.#'																																											 		 MetricExplanation,
						 adpccr.CashbackCnt																																									 		 CSHARP_TO_PROD_VIEW,
						 bdpccr.CashbackCnt																																											 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource	  bdpccr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource  adpccr on bdpccr.[Date] = adpccr.[Date] AND bdpccr.CashbackName = adpccr.CashbackName
				  WHERE adpccr.CashbackName IN (SELECT
												CashbackName
												FROM 
													(
													  SELECT CashbackName, 
															 Cnt(CashbackName) CntCashbackName
													  FROM #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource 
													  GROUP BY CashbackName 
													  HAVING Cnt(CashbackName) = 1
													  ) U
											   )
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource CashbackCnt*/

UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource CashbackVol*/
				  SELECT 
						 bdpccr.[Date]																																													 StreamDate,
						'V.'																																															 TestType,
						'FACT_DailyDatabaseCardCashbackCSEntityDataSource'																																							 BasedReportTable,
						'CashbackVol'																																										 		 BasedReportTableField,
						'FACT_Transactions;DIM_CashbackConditions'																																							 Tested_DWH_Table,
						'FeatureType;ConditionId;TxAmount'																																									 Tested_DWH_Table_Field,
						0																																																 Currency,
						 bdpccr.CashbackName																																											 Value1,
						'SUM(CASE WHEN FeatureType = 15 THEN TxAmount ELSE NULL END)'																																		 Formula,
						'Cashback Tx.V.'																																											 	 MetricExplanation,
						 adpccr.CashbackVol																																									 		 CSHARP_TO_PROD_VIEW,
						 bdpccr.CashbackVol																																											 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource	  bdpccr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource  adpccr on bdpccr.[Date] = adpccr.[Date] AND bdpccr.CashbackName = adpccr.CashbackName
				  WHERE adpccr.CashbackName IN (SELECT
												CashbackName
												FROM 
													(
													  SELECT CashbackName, 
															 Cnt(CashbackName) CntCashbackName
													  FROM #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource 
													  GROUP BY CashbackName 
													  HAVING Cnt(CashbackName) = 1
													  ) U
											   )
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource CashbackVol*/

UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource EndOfTheMonthCasbacksCnt*/
				  SELECT 
						 bdpccr.[Date]																																													 StreamDate,
						'Tx.#'																																															 TestType,
						'FACT_DailyDatabaseCardCashbackCSEntityDataSource'																																							 BasedReportTable,
						'EndOfTheMonthCasbacksCnt'																																									 BasedReportTableField,
						'FACT_EndOfTheMonthCashbacks'																																							 		 Tested_DWH_Table,
						'ConditionId;Id'																																												 Tested_DWH_Table_Field,
						0																																																 Currency,
						 bdpccr.CashbackName																																											 Value1,
						'Cnt(Id)'																																		 												 Formula,
						'EOM Feature Type Cashback Cnt'																																								 MetricExplanation,
						 adpccr.EndOfTheMonthCasbacksCnt																																								 CSHARP_TO_PROD_VIEW,
						 bdpccr.EndOfTheMonthCasbacksCnt																																								 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource	  bdpccr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource  adpccr on bdpccr.[Date] = adpccr.[Date] AND bdpccr.CashbackName = adpccr.CashbackName
				  WHERE adpccr.CashbackName IN (SELECT
												CashbackName
												FROM 
													(
													  SELECT CashbackName, 
															 Cnt(CashbackName) CntCashbackName
													  FROM #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource 
													  GROUP BY CashbackName 
													  HAVING Cnt(CashbackName) = 1
													  ) U
											   )
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource EndOfTheMonthCasbacksCnt*/

UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource EndOfTheMonthCasbacksVol*/
				  SELECT 
						 bdpccr.[Date]																																													 StreamDate,
						'V.'																																															 TestType,
						'FACT_DailyDatabaseCardCashbackCSEntityDataSource'																																							 BasedReportTable,
						'EndOfTheMonthCasbacksVol'																																									 BasedReportTableField,
						'FACT_EndOfTheMonthCashbacks'																																							 		 Tested_DWH_Table,
						'ConditionId;TxAmount'																																											 Tested_DWH_Table_Field,
						0																																																 Currency,
						 bdpccr.CashbackName																																											 Value1,
						'ABS(SUM(TxAmount))'																																		 										 Formula,
						'EOM Feature Type Cashback Vol'																																								 MetricExplanation,
						 adpccr.EndOfTheMonthCasbacksVol																																								 CSHARP_TO_PROD_VIEW,
						 bdpccr.EndOfTheMonthCasbacksVol																																								 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource	  bdpccr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource  adpccr on bdpccr.[Date] = adpccr.[Date] AND bdpccr.CashbackName = adpccr.CashbackName
				  WHERE adpccr.CashbackName IN (SELECT
												CashbackName
												FROM 
													(
													  SELECT CashbackName, 
															 Cnt(CashbackName) CntCashbackName
													  FROM #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource 
													  GROUP BY CashbackName 
													  HAVING Cnt(CashbackName) = 1
													  ) U
											   )
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource EndOfTheMonthCasbacksVol*/

UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource CasbackUserAttributesDailyCnt*/
				  SELECT 
						 bdpccr.[Date]																																													 StreamDate,
						'UU'																																															 TestType,
						'FACT_DailyDatabaseCardCashbackCSEntityDataSource'																																							 BasedReportTable,
						'CasbackUserAttributesDailyCnt'																																									 	 BasedReportTableField,
						'FACT_Transactions;DIM_CashbackConditions'																																							 Tested_DWH_Table,
						'ConditionId;User_Key'																																											 Tested_DWH_Table_Field,
						0																																																 Currency,
						 bdpccr.CashbackName																																											 Value1,
						'Cnt(DISTINCT CASE WHEN ConditionId is not null THEN User_Key ELSE NULL END)'																													 Formula,
						'Cashback UU'																																								 					 MetricExplanation,
						 adpccr.CasbackUserAttributesDailyCnt																																								 	 CSHARP_TO_PROD_VIEW,
						 bdpccr.CasbackUserAttributesDailyCnt																																								 	 PROD_TO_DWH_VIEW,  1 IsWarningField
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource	  bdpccr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource  adpccr on bdpccr.[Date] = adpccr.[Date] AND bdpccr.CashbackName = adpccr.CashbackName
				  WHERE adpccr.CashbackName IN (SELECT
												CashbackName
												FROM 
													(
													  SELECT CashbackName, 
															 Cnt(CashbackName) CntCashbackName
													  FROM #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource 
													  GROUP BY CashbackName 
													  HAVING Cnt(CashbackName) = 1
													  ) U
											   )
/*END - #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource CasbackUserAttributesDailyCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource PaidWithCreditCardCnt*/
				  SELECT 
						bdcr.[Date]																																									StreamDate,
						'Tx.#'																																										TestType,
						'FACT_DailyCheckoutCSEntityDataSource'																																					BasedReportTable,
						'PaidWithCreditCardCnt'																																					BasedReportTableField,
						'FACT_Payments;FACT_MerchandiserTransactions'																																			Tested_DWH_Table,
						'Id;PaymentMethod;Status'																																					Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(CASE WHEN PaymentMethod = 1 THEN Id ELSE NULL END)...where Status = 1'																								Formula,
						'Checkout Payment Tx.# with Card'																																			MetricExplanation,
						adcr.PaidWithCreditCardCnt																																				CSHARP_TO_PROD_VIEW,
						bdcr.PaidWithCreditCardCnt																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource    bdcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyCheckoutCSEntityDataSource adcr on bdcr.[Date] = adcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource PaidWithCreditCardCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource PaidWithCreditCardVol*/
				  SELECT 
						bdcr.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyCheckoutCSEntityDataSource'																																					BasedReportTable,
						'PaidWithCreditCardVol'																																					BasedReportTableField,
						'FACT_Payments;FACT_MerchandiserTransactions'																																			Tested_DWH_Table,
						'PaymentMethod;Status;TxAmount'																																				Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN PaymentMethod = 1 THEN TxAmount ELSE NULL END)...where Status = 1'																								Formula,
						'Checkout Payment Tx.V. with Card'																																			MetricExplanation,
						adcr.PaidWithCreditCardVol																																				CSHARP_TO_PROD_VIEW,
						bdcr.PaidWithCreditCardVol																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource    bdcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyCheckoutCSEntityDataSource adcr on bdcr.[Date] = adcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource PaidWithCreditCardVol*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource UniqueMerchandisersLastDay*/
				  SELECT 
						bdcr.[Date]																																									StreamDate,
						'UM'																																										TestType,
						'FACT_DailyCheckoutCSEntityDataSource'																																					BasedReportTable,
						'UniqueMerchandisersLastDay'																																					BasedReportTableField,
						'FACT_Payments'																																								Tested_DWH_Table,
						'Merchandiser_Key;Status'																																						Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(DISTINCT Merchandiser_Key)...where Status = 1'																															Formula,
						'Daily Unique Merchandisers recieved Checkout Payment'																															MetricExplanation,
						adcr.UniqueMerchandisersLastDay																																					CSHARP_TO_PROD_VIEW,
						bdcr.UniqueMerchandisersLastDay																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource    bdcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyCheckoutCSEntityDataSource adcr on bdcr.[Date] = adcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource UniqueMerchandisersLastDay*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource UniqueUserAttributesLastDay*/
				  SELECT 
						bdcr.[Date]																																									StreamDate,
						'UU'																																										TestType,
						'FACT_DailyCheckoutCSEntityDataSource'																																					BasedReportTable,
						'UniqueUserAttributesLastDay'																																						BasedReportTableField,
						'FACT_Payments'																																								Tested_DWH_Table,
						'User_Key'																																									Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(DISTINCT User_Key)...where Status = 1'																																Formula,
						'Daily Unique UserAttributes made Checkout Payment'																																	MetricExplanation,
						adcr.UniqueUserAttributesLastDay																																						CSHARP_TO_PROD_VIEW,
						bdcr.UniqueUserAttributesLastDay																																						PROD_TO_DWH_VIEW,  0 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource    bdcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyCheckoutCSEntityDataSource adcr on bdcr.[Date] = adcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource UniqueUserAttributesLastDay*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource CheckoutCnt*/
				  SELECT 
						bdcr.[Date]																																									StreamDate,
						'Tx.#'																																										TestType,
						'FACT_DailyCheckoutCSEntityDataSource'																																					BasedReportTable,
						'CheckoutCnt'																																								BasedReportTableField,
						'FACT_Payments'																																								Tested_DWH_Table,
						'Id;Status'																																									Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(Id)...where Status = 1'																																				Formula,
						'Daily Checkout Tx.Cnt'																																					MetricExplanation,
						adcr.CheckoutCnt																																							CSHARP_TO_PROD_VIEW,
						bdcr.CheckoutCnt																																							PROD_TO_DWH_VIEW,  0 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource    bdcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyCheckoutCSEntityDataSource adcr on bdcr.[Date] = adcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource CheckoutCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource CheckoutVol*/
				  SELECT 
						bdcr.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyCheckoutCSEntityDataSource'																																					BasedReportTable,
						'CheckoutVol'																																							BasedReportTableField,
						'FACT_Payments'																																								Tested_DWH_Table,
						'TxAmount;Status'																																								Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'ABS(SUM(TxAmount))...where Status = 1'																																		Formula,
						'Daily Checkout Tx.Vol'																																					MetricExplanation,
						adcr.CheckoutVol																																							CSHARP_TO_PROD_VIEW,
						bdcr.CheckoutVol																																							PROD_TO_DWH_VIEW,  0 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource    bdcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyCheckoutCSEntityDataSource adcr on bdcr.[Date] = adcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource CheckoutCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource CheckoutFee*/
				  SELECT 
						bdcr.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyCheckoutCSEntityDataSource'																																					BasedReportTable,
						'CheckoutVol'																																							BasedReportTableField,
						'FACT_Payments'																																								Tested_DWH_Table,
						'Fee;Status'																																								Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'ABS(SUM(TxAmount))...where Status = 1'																																		Formula,
						'Daily Checkout Tx.Fee Vol'																																				MetricExplanation,
						adcr.CheckoutFee																																							CSHARP_TO_PROD_VIEW,
						bdcr.CheckoutFee																																							PROD_TO_DWH_VIEW,  0 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource    bdcr
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyCheckoutCSEntityDataSource adcr on bdcr.[Date] = adcr.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource CheckoutCnt*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalInsuranceTx*/
				  SELECT 
						bdir.[Date]																																									StreamDate,
						'Tx.#'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'TotalInsuranceTx'																																							BasedReportTableField,
						'FACT_Transactions;FACT_ExternalTransactions;FACT_InsurancePolicies;TransactionId;IsCancellation;FeatureType'																				Tested_DWH_Table,
						'PolicyId;TransactionsId;ExternalTransactionId'																																		Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(PolicyId)'																																							Formula,
						'Total Insurance Tx.# (Transactionsed)'																																			MetricExplanation,
						adir.TotalInsuranceTx																																						CSHARP_TO_PROD_VIEW,
						bdir.TotalInsuranceTx																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalInsuranceTx*/		
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalInsurancePremiumVol*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'TotalInsurancePremiumVol'																																				BasedReportTableField,
						'FACT_Transactions;FACT_ExternalTransactions;FACT_InsurancePolicies;TransactionId;IsCancellation;FeatureType'																				Tested_DWH_Table,
						'TxAmount;TransactionsId;ExternalTransactionId'																																			Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(TxAmount)'																																								Formula,
						'Total Insurance Premium Vol (Transactionsed)'																																	MetricExplanation,
						adir.TotalInsurancePremiumVol																																			CSHARP_TO_PROD_VIEW,
						bdir.TotalInsurancePremiumVol																																			PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalInsurancePremiumVol*/		
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalInsuranceFee*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'TotalInsuranceFee'																																							BasedReportTableField,
						'FACT_Transactions;FACT_ExternalTransactions;FACT_InsurancePolicies'																													Tested_DWH_Table,
						'TxAmount;TransactionsId;ExternalTransactionId;ProductType;TransactionId;IsCancellation;FeatureType'																						Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN ProductType = 1... THEN TxAmount*@msr/2...[SAME SUM ELEMENTS FOR ProductType={1,2,3,4}]'																		Formula,
						'Total Insurance Fee (Transactionsed)'																																			MetricExplanation,
						adir.TotalInsuranceFee																																						CSHARP_TO_PROD_VIEW,
						bdir.TotalInsuranceFee																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalInsuranceFee*/			
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalInAppPaymentTx*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'Tx.#'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'TotalInAppPaymentTx'																																						BasedReportTableField,
						'FACT_Transactions;FACT_InsurancePolicies'																																		Tested_DWH_Table,
						'PolicyId;TransactionsId;Id;TransactionId;IsCancellation;FeatureType'																												Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(CASE WHEN TransactionsId IS NOT NULL THEN PolicyId ELSE NULL END)'																											Formula,
						'Total In App Payment Tx.# (Transactionsed)'																																		MetricExplanation,
						adir.TotalInAppPaymentTx																																					CSHARP_TO_PROD_VIEW,
						bdir.TotalInAppPaymentTx																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalInAppPaymentTx*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalInAppPaymentVol*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'TotalInAppPaymentVol'																																					BasedReportTableField,
						'FACT_Transactions;FACT_InsurancePolicies'																																		Tested_DWH_Table,
						'PolicyStatus;TransactionsId;TxAmount;;TransactionId;;IsCancellation;FeatureType'																										Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN TransactionsId IS NOT NULL THEN TxAmount ELSE NULL END)'																												Formula,
						'Total Insurance Premium V. (Transactionsed)'																																		MetricExplanation,
						adir.TotalInAppPaymentVol																																				CSHARP_TO_PROD_VIEW,
						bdir.TotalInAppPaymentVol																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalInAppPaymentVol*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalInsuranceTotalFee*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'TotalInsuranceTotalFee'																																					BasedReportTableField,
						'FACT_Transactions;FACT_ExternalTransactions;FACT_InsurancePolicies'																													Tested_DWH_Table,
						'ProductType;TxAmount;TransactionId;IsCancellation;FeatureType'																													Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN ProductType = 1... THEN (TxAmount/(1+@BSMV))*@msr/2...[SAME SUM ELEMENTS FOR ProductType={1,2,3,4}]'															Formula,
						'All Insurance products Gross Fee (Transactionsed [Transactions&ExternalTransactions])'																										MetricExplanation,
						adir.TotalInsuranceTotalFee																																					CSHARP_TO_PROD_VIEW,
						bdir.TotalInsuranceTotalFee																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalInsuranceTotalFee*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalOutAppPaymentTx*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'Tx.#'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'TotalOutAppPaymentTx'																																						BasedReportTableField,
						'FACT_ExternalTransactions;FACT_InsurancePolicies'																																Tested_DWH_Table,
						'PolicyId;ExternalTransactionId;TransactionId;IsCancellation;FeatureType'																										Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(CASE WHEN ExternalTransactionId IS NOT NULL THEN PolicyId ELSE NULL END)'																									Formula,
						'Overall Out App Payment Tx.# (Transactionsed)'																																	MetricExplanation,
						adir.TotalOutAppPaymentTx																																					CSHARP_TO_PROD_VIEW,
						bdir.TotalOutAppPaymentTx																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalOutAppPaymentTx*/			
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalOutAppPaymentVol*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'TotalOutAppPaymentVol'																																					BasedReportTableField,
						'FACT_ExternalTransactions;FACT_InsurancePolicies'																																Tested_DWH_Table,
						'TxAmount;ExternalTransactionId;TransactionId;IsCancellation;FeatureType'																											Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN ExternalTransactionId IS NOT NULL THEN TxAmount ELSE NULL END)'																										Formula,
						'Total Out App Payment V. (Transactionsed [ExternalTransactions])'																														MetricExplanation,
						adir.TotalOutAppPaymentVol																																				CSHARP_TO_PROD_VIEW,
						bdir.TotalOutAppPaymentVol																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalOutAppPaymentVol*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalOutAppPaymentFee*/		
				  SELECT 		
						bdir.[Date]																																										 StreamDate,
						'V.'																																											 TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																					 BasedReportTable,
						'TotalOutAppPaymentFee'																																							 BasedReportTableField,
						'FACT_ExternalTransactions;FACT_InsurancePolicies'																																	 Tested_DWH_Table,
						'TxAmount;ExternalTransactionId;Id;TransactionId;IsCancellation;FeatureType'																												 Tested_DWH_Table_Field,
						0																																												 Currency,
						'N/A'																																											 Value1,
						'SUM(CASE WHEN ExternalTransactionId IS NOT NULL ProductType = 1... THEN TxAmount*@msr/2...[SAME SUM ELEMENTS FOR ProductType={1,2,3,4}]'												 Formula,
						'Total Out App Payment Fee (Transactionsed [ExternalTransactions])'																															 MetricExplanation,
						adir.TotalOutAppPaymentFee																																						 CSHARP_TO_PROD_VIEW,
						bdir.TotalOutAppPaymentFee																																						 PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalOutAppPaymentFee*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource UniqueUserTotal*/
				  SELECT 
						bdir.[Date]																																									StreamDate,
						'UU'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'UniqueUserTotal'																																							BasedReportTableField,
						'FACT_Transactions;FACT_ExternalTransactions;FACT_InsurancePolicies'																													Tested_DWH_Table,
						'TransactionsId;ExternalTransactionId;User_Key;FeatureType;TransactionId;FeatureType'																										Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(DISTINCT User_Key)'																																					Formula,
						'Unique User Cnt (Transactionsed)'																																				MetricExplanation,
						adir.UniqueUserTotal																																						CSHARP_TO_PROD_VIEW,
						bdir.UniqueUserTotal																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource UniqueUserTotal*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneInsuranceTx*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'Tx.#'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'MobilePhoneInsuranceTx'																																					BasedReportTableField,
						'FACT_Transactions;FACT_ExternalTransactions;FACT_InsurancePolicies'																													Tested_DWH_Table,
						'ProductType;ProductId;TransactionsId;ExternalTransactionId;TransactionId;IsCancellation;FeatureType;PolicyId'																			Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(CASE WHEN ProductType = 2 THEN PolicyId ELSE NULL END)'																												Formula,
						'Mobile Phone Insurance Tx.# (Transactionsed)'																																	MetricExplanation,
						adir.MobilePhoneInsuranceTx																																					CSHARP_TO_PROD_VIEW,
						bdir.MobilePhoneInsuranceTx																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneInsuranceTx*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneInsurancePremiumVol*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'MobilePhoneInsurancePremiumVol'																																			BasedReportTableField,
						'FACT_Transactions;FACT_ExternalTransactions;FACT_InsurancePolicies'																													Tested_DWH_Table,
						'ProductType;TransactionsId;ExternalTransactionId;TxAmount;TransactionId;IsCancellation;FeatureType'																						Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN ProductType = 2 THEN TxAmount ELSE NULL END)'																													Formula,
						'Mobile Phone Insurance Premium Vol (Transactionsed)'																															MetricExplanation,
						adir.MobilePhoneInsurancePremiumVol																																		CSHARP_TO_PROD_VIEW,
						bdir.MobilePhoneInsurancePremiumVol																																		PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneInsurancePremiumVol*/			
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalInAppPaymentFee*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'TotalInAppPaymentFee'																																						BasedReportTableField,
						'FACT_Transactions;FACT_InsurancePolicies'																																		Tested_DWH_Table,
						'ProductType;TransactionsId;TxAmount;TransactionId;IsCancellation;FeatureType;PolicyId'																								Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN ProductType = 1... AND fip.TransactionsId IS NOT NULL THEN TxAmount*@msr/2...)[SAME SUM ELEMENTS FOR ProductType={1,2,3,4}]'											Formula,
						'Total In App PaymentFee (Transactionsed [Transactions])'																																MetricExplanation,
						adir.TotalInAppPaymentFee																																					CSHARP_TO_PROD_VIEW,
						bdir.TotalInAppPaymentFee																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalInAppPaymentFee*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneInsuranceFee*/
				  SELECT 
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'MobilePhoneInsuranceFee'																																					BasedReportTableField,
						'FACT_Transactions;FACT_ExternalTransactions;FACT_InsurancePolicies'																													Tested_DWH_Table,
						'ProductType;TransactionsId;ExternalTransactionId;TxAmount;IsCancellation;TransactionId;FeatureType;PolicyId'																				Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN ProductType = 2 THEN TxAmount*@mfr/2 ELSE NULL END)'																											Formula,
						'Mobile Phone InsuranceFee (Transactionsed [Transactions,ExternalTransactions])'																												MetricExplanation,
						adir.MobilePhoneInsuranceFee																																				CSHARP_TO_PROD_VIEW,
						bdir.MobilePhoneInsuranceFee																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneInsuranceFee*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneInAppPaymentTx*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'Tx.#'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'MobilePhoneInAppPaymentTx'																																					BasedReportTableField,
						'FACT_Transactions;FACT_InsurancePolicies;FACT_InsurancePolicies'																																		Tested_DWH_Table,
						'ProductType;PolicyId;TransactionsId;IsCancellation;TransactionId;FeatureType;PolicyId'																								Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(CASE WHEN ProductType = 2 AND TransactionsId IS NOT NULL THEN PolicyId ELSE NULL END)'																						Formula,		
						'Mobile Phone In App PaymentTx (Transactionsed [Transactions,ExternalTransactions])'																											MetricExplanation,		
						adir.MobilePhoneInAppPaymentTx																																				CSHARP_TO_PROD_VIEW,
						bdir.MobilePhoneInAppPaymentTx																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneInAppPaymentTx*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneInAppPaymentVol*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'MobilePhoneInAppPaymentVol'																																				BasedReportTableField,
						'FACT_Transactions;FACT_InsurancePolicies'																																		Tested_DWH_Table,
						'ProductType;TxAmount;TransactionsId;IsCancellation;TransactionId;FeatureType;PolicyId'																								Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN ProductType = 2 AND TransactionsId IS NOT NULL THEN TxAmount ELSE NULL END)'																							Formula,		
						'Mobile Phone In App Payment Vol (Transactionsed [Transactions])'																													MetricExplanation,		
						adir.MobilePhoneInAppPaymentVol																																			CSHARP_TO_PROD_VIEW,
						bdir.MobilePhoneInAppPaymentVol																																			PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneInAppPaymentVol*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneInAppPaymentFee*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'MobilePhoneInAppPaymentFee'																																				BasedReportTableField,
						'FACT_Transactions;FACT_InsurancePolicies'																																		Tested_DWH_Table,
						'ProductType;TxAmount;TransactionsId;IsCancellation;TransactionId;FeatureType;PolicyId'																								Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN ProductType = 2 AND TransactionsId IS NOT NULL	THEN TxAmount*@mfr/2 ELSE NULL END)'																					Formula,		
						'Mobile Phone In App Payment Fee (Transactionsed [Transactions])'																														MetricExplanation,		
						adir.MobilePhoneInAppPaymentFee																																				CSHARP_TO_PROD_VIEW,
						bdir.MobilePhoneInAppPaymentFee																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneInAppPaymentFee*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneOutAppPaymentTx*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'Tx.#'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'MobilePhoneOutAppPaymentTx'																																				BasedReportTableField,
						'FACT_ExternalTransactions;FACT_InsurancePolicies'																																Tested_DWH_Table,
						'ProductType;ExternalTransactionId;TransactionId;IsCancellation;FeatureType;PolicyId'																								Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(CASE WHEN ProductType = 2 AND ExternalTransactionId IS NOT NULL THEN PolicyId ELSE NULL END)'																				Formula,		
						'Mobile Phone Out App Payment Tx.# (Transactionsed [ExternalTransactions])'																												MetricExplanation,		
						adir.MobilePhoneOutAppPaymentTx																																				CSHARP_TO_PROD_VIEW,
						bdir.MobilePhoneOutAppPaymentTx																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneOutAppPaymentTx*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneOutAppPaymentVol*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'MobilePhoneOutAppPaymentVol'																																			BasedReportTableField,
						'FACT_Transactions;FACT_InsurancePolicies'																																		Tested_DWH_Table,
						'ProductType;ExternalTransactionId;TxAmount;TransactionId;IsCancellation;FeatureType;PolicyId'																						Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN ProductType = 2 AND ExternalTransactionId	IS NOT NULL	THEN TxAmount ELSE NULL END)'																					Formula,		
						'Mobile Phone Out App Payment Vol (Transactionsed [ExternalTransactions])'																											MetricExplanation,		
						adir.MobilePhoneOutAppPaymentVol																																			CSHARP_TO_PROD_VIEW,
						bdir.MobilePhoneOutAppPaymentVol																																			PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneOutAppPaymentVol*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneOutAppPaymentFee*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'MobilePhoneOutAppPaymentFee'																																				BasedReportTableField,
						'FACT_ExternalTransactions;FACT_InsurancePolicies'																																Tested_DWH_Table,
						'ProductType;ExternalTransactionId;TxAmount;IsCancellation;TransactionId;FeatureType;PolicyId'																						Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN ProductType = 2 AND ExternalTransactionId	IS NOT NULL	THEN TxAmount*@mfr/2 ELSE NULL END)'																			Formula,		
						'Mobile Phone Out App Payment Fee (Transactionsed [ExternalTransactions])'																												MetricExplanation,		
						adir.MobilePhoneOutAppPaymentFee																																			CSHARP_TO_PROD_VIEW,
						bdir.MobilePhoneOutAppPaymentFee																																			PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneOutAppPaymentFee*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneInsuranceTotalFee*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'MobilePhoneInsuranceTotalFee'																																				BasedReportTableField,
						'FACT_InsurancePolicies;FACT_Transactions;FACT_ExternalTransactions'																													Tested_DWH_Table,
						'ProductType;TransactionsId;ExternalTransactionId;TxAmount;TransactionId;IsCancellation;FeatureType;PolicyId'																				Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN ProductType = 2 THEN (TxAmount/(1+@BSMV))*@mfr ELSE NULL END)'																									Formula,		
						'Mobile Phone Insurance Total Fee (Transactionsed [Transactions,ExternalTransactions])'																										MetricExplanation,		
						adir.MobilePhoneInsuranceTotalFee																																			CSHARP_TO_PROD_VIEW,
						bdir.MobilePhoneInsuranceTotalFee																																			PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneInsuranceTotalFee*/				
 		
			UNION ALL		

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource UniqueUserMobilePhoneInsurance*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'UU'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'UniqueUserMobilePhoneInsurance'																																			BasedReportTableField,
						'FACT_Transactions;FACT_ExternalTransactions;FACT_InsurancePolicies'																													Tested_DWH_Table,
						'ProductType;TransactionsId;ExternalTransactionId;User_Key;IsCancellation;TransactionId;FeatureType'																						Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(DISTINCT CASE WHEN FeatureType = 24 AND ProductType = 2 THEN User_Key'																									Formula,		
						'Unique User Mobile Phone Insurance'																																		MetricExplanation,		
						adir.UniqueUserMobilePhoneInsurance																																			CSHARP_TO_PROD_VIEW,
						bdir.UniqueUserMobilePhoneInsurance																																			PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource UniqueUserMobilePhoneInsurance*/				
		
			UNION ALL	


/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneScreenInsuranceTx*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'Tx.#'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'MobilePhoneScreenInsuranceTx'																																				BasedReportTableField,
						'FACT_Transactions;FACT_ExternalTransactions;FACT_InsurancePolicies'																													Tested_DWH_Table,
						'ProductType;TransactionsId;ExternalTransactionId;PolicyId;TransactionId;IsCancellation;FeatureType'																						Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(CASE WHEN ProductType = 1 THEN PolicyId ELSE NULL END)'																												Formula,		
						'Mobile Phone Screen Insurance Tx.#'																																		MetricExplanation,		
						adir.MobilePhoneScreenInsuranceTx																																			CSHARP_TO_PROD_VIEW,
						bdir.MobilePhoneScreenInsuranceTx																																			PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneScreenInsuranceTx*/				
		
			UNION ALL		
	
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneScreenInsuranceFee*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'MobilePhoneScreenInsuranceFee'																																				BasedReportTableField,
						'FACT_Transactions;FACT_ExternalTransactions;FACT_InsurancePolicies'																													Tested_DWH_Table,
						'ProductType;TransactionsId;ExternalTransactionId;IsCancellation;TxAmount;TransactionId;FeatureType'																						Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN ProductType = 1 THEN TxAmount*@msr/2 ELSE NULL END)'																											Formula,		
						'Mobile Phone Screen Insurance Fee'																																			MetricExplanation,		
						adir.MobilePhoneScreenInsuranceFee																																			CSHARP_TO_PROD_VIEW,
						bdir.MobilePhoneScreenInsuranceFee																																			PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneScreenInsuranceFee*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneScreenInAppPaymentTx*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'Tx.#'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'MobilePhoneScreenInAppPaymentTx'																																			BasedReportTableField,
						'FACT_Transactions;FACT_InsurancePolicies'																																		Tested_DWH_Table,
						'ProductType;TransactionsId;PolicyId;TransactionId;IsCancellation;FeatureType'																										Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(CASE WHEN ProductType = 1 AND TransactionsId IS NOT NULL THEN PolicyId ELSE NULL END)'																						Formula,		
						'Mobile Phone Screen In App Payment Tx.# (Cancellations Excluded)'																											MetricExplanation,		
						adir.MobilePhoneScreenInAppPaymentTx																																		CSHARP_TO_PROD_VIEW,
						bdir.MobilePhoneScreenInAppPaymentTx																																		PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneScreenInAppPaymentTx*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneScreenInAppPaymentVol*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'MobilePhoneScreenInAppPaymentVol'																																		BasedReportTableField,
						'FACT_Transactions;FACT_InsurancePolicies'																																		Tested_DWH_Table,
						'ProductType;TransactionsId;TxAmount;TransactionId;IsCancellation;FeatureType'																										Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN ProductType = 1 AND TransactionsId IS NOT NULL	THEN TxAmount ELSE NULL END)'																							Formula,		
						'Mobile Phone Screen In App Payment Vol (Transactionsed [Transactions])'																												MetricExplanation,		
						adir.MobilePhoneScreenInAppPaymentVol																																	CSHARP_TO_PROD_VIEW,
						bdir.MobilePhoneScreenInAppPaymentVol																																	PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneScreenInAppPaymentVol*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneScreenInAppPaymentFee*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'MobilePhoneScreenInAppPaymentFee'																																			BasedReportTableField,
						'FACT_Transactions;FACT_InsurancePolicies'																																		Tested_DWH_Table,
						'ProductType;TransactionsId;TxAmount;TransactionId;IsCancellation;FeatureType'																										Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN ProductType = 1 AND TransactionsId IS NOT NULL	THEN TxAmount*@msr/2 ELSE NULL END)'																					Formula,		
						'Mobile Phone Screen In App Payment Fee (Transactionsed [Transactions])'																												MetricExplanation,		
						adir.MobilePhoneScreenInAppPaymentFee																																		CSHARP_TO_PROD_VIEW,
						bdir.MobilePhoneScreenInAppPaymentFee																																		PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneScreenInAppPaymentFee*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneScreenOutAppPaymentTx*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'Tx.#'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'MobilePhoneScreenOutAppPaymentTx'																																			BasedReportTableField,
						'FACT_ExternalTransactions;FACT_InsurancePolicies'																																Tested_DWH_Table,
						'ProductType;ExternalTransactionId;PolicyId;TransactionId;IsCancellation;FeatureType'																								Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(CASE WHEN ProductType = 1 AND ExternalTransactionId  IS NOT NULL	THEN PolicyId ELSE NULL END)'																			Formula,		
						'Mobile Phone Screen Out App Payment Tx.# (Transactionsed [ExternalTransactions])'																										MetricExplanation,		
						adir.MobilePhoneScreenOutAppPaymentTx																																		CSHARP_TO_PROD_VIEW,
						bdir.MobilePhoneScreenOutAppPaymentTx																																		PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneScreenOutAppPaymentTx*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneScreenOutAppPaymentVol*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'MobilePhoneScreenOutAppPaymentVol'																																		BasedReportTableField,
						'FACT_ExternalTransactions;FACT_InsurancePolicies'																																Tested_DWH_Table,
						'ProductType;ExternalTransactionId;TxAmount;IsCancellation;TransactionId;FeatureType'																								Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN ProductType = 1 AND ExternalTransactionId  IS NOT NULL THEN TxAmount ELSE NULL END)'																				Formula,		
						'Mobile Phone Screen Out App Payment Vol (Transactionsed [ExternalTransactions])'																									MetricExplanation,		
						adir.MobilePhoneScreenOutAppPaymentVol																																	CSHARP_TO_PROD_VIEW,
						bdir.MobilePhoneScreenOutAppPaymentVol																																	PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneScreenOutAppPaymentVol*/			
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneScreenOutAppPaymentFee*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'MobilePhoneScreenOutAppPaymentFee'																																			BasedReportTableField,
						'FACT_ExternalTransactions;FACT_InsurancePolicies'																																Tested_DWH_Table,
						'ProductType;ExternalTransactionId;TxAmount;IsCancellation;TransactionId;FeatureType'																								Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN ProductType = 1 AND ExternalTransactionId IS NOT NULL THEN TxAmount*@msr/2 ELSE NULL END)'																			Formula,		
						'Mobile Phone Screen Out App Payment Fee (Transactionsed [ExternalTransactions])'																										MetricExplanation,		
						adir.MobilePhoneScreenOutAppPaymentFee																																		CSHARP_TO_PROD_VIEW,
						bdir.MobilePhoneScreenOutAppPaymentFee																																		PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneScreenOutAppPaymentFee*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneScreenInsuranceTotalFee*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'MobilePhoneScreenInsuranceTotalFee'																																		BasedReportTableField,
						'FACT_lTransactions;FACT_InsurancePolicies'																																		Tested_DWH_Table,
						'ProductType;TransactionsId;ExternalTransactionId;TxAmount;IsCancellation;TransactionId;FeatureType'																						Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN ProductType = 1 THEN (TxAmount/(1+@BSMV))*@msr ELSE NULL END)'																									Formula,		
						'Mobile Phone Screen Insurance Total Fee (Transactionsed [Transactions,ExternalTransactions])'																								MetricExplanation,		
						adir.MobilePhoneScreenInsuranceTotalFee																																		CSHARP_TO_PROD_VIEW,
						bdir.MobilePhoneScreenInsuranceTotalFee																																		PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource MobilePhoneScreenInsuranceTotalFee*/				
		
			UNION ALL		

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource UniqueUserMobilePhoneScreenInsurance*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'UU'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'UniqueUserMobilePhoneScreenInsurance'																																		BasedReportTableField,
						'FACT_Transactions;FACT_ExternalTransactions;FACT_InsurancePolicies'																													Tested_DWH_Table,
						'ProductType;User_Key;TransactionsId;ExternalTransactionId;IsCancellation;TransactionId;FeatureType'																						Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(DISTINCT CASE WHEN ProductType = 1 THEN User_Key ELSE NULL END)'																										Formula,		
						'Unique User Mobile Phone Screen Insurance'																																	MetricExplanation,		
						adir.UniqueUserMobilePhoneScreenInsurance																																	CSHARP_TO_PROD_VIEW,
						bdir.UniqueUserMobilePhoneScreenInsurance																																	PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource UniqueUserMobilePhoneScreenInsurance*/			
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource PetInsuranceTx*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'Tx.#'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'PetInsuranceTx'																																							BasedReportTableField,
						'FACT_Transactions;FACT_ExternalTransactions;FACT_InsurancePolicies'																													Tested_DWH_Table,
						'BranchType;TransactionsId;ExternalTransactionId;PolicyId;IsCancellation;TransactionId;IsCancellation;FeatureType'																		Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(CASE WHEN BranchType = 7 THEN PolicyId ELSE NULL END)'																												Formula,		
						'Pet Insurance Tx.# (Transactionsed [Transactions&ExternalTransactions)'																														MetricExplanation,		
						adir.PetInsuranceTx																																							CSHARP_TO_PROD_VIEW,
						bdir.PetInsuranceTx																																							PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource PetInsuranceTx*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource PetInsurancePremiumVol*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'PetInsurancePremiumVol'																																					BasedReportTableField,
						'FACT_Transactions;FACT_ExternalTransactions;FACT_InsurancePolicies'																													Tested_DWH_Table,
						'PolicyStatus;BranchType;TxAmount;IsCancellation;TransactionId;FeatureType'																										Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN BranchType = 7 THEN TxAmount ELSE NULL END)'																													Formula,		
						'Pet Insurance Premium Vol (Transactionsed [Transactions&ExternalTransactions])'																											MetricExplanation,		
						adir.PetInsurancePremiumVol																																				CSHARP_TO_PROD_VIEW,
						bdir.PetInsurancePremiumVol																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource PetInsurancePremiumVol*/			
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource PetInsuranceFee*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'PetInsuranceFee'																																							BasedReportTableField,
						'FACT_Transactions;FACT_ExternalTransactions;FACT_InsurancePolicies'																													Tested_DWH_Table,
						'ProductType;BranchType;TransactionsId;ExternalTransactionId;TxAmount;IsCancellation;TransactionId;FeatureType'																			Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'CASE WHEN BranchType  = 7 AND ProductType = 3 THEN TxAmount*@upr/2... ELSE NULL END)[Same SUM for ProductType 3,4 included]'													Formula,		
						'Pet Insurance Fee (Transactionsed [Transactions,ExternalTransactions])'																														MetricExplanation,		
						adir.PetInsuranceFee																																						CSHARP_TO_PROD_VIEW,
						bdir.PetInsuranceFee																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource PetInsuranceFee*/			
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource PetInsuranceInAppPaymentTx*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'Tx.#'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'PetInsuranceInAppPaymentTx'																																				BasedReportTableField,
						'FACT_Transactions;FACT_InsurancePolicies'																																		Tested_DWH_Table,
						'PolicyStatus;BranchType;TransactionsId;PolicyId;TransactionId;IsCancellation;FeatureType'																							Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(CASE WHEN BranchType = 7 AND TransactionsId IS NOT NULL THEN PolicyId ELSE NULL END)'																						Formula,		
						'Pet Insurance In App Payment Tx.# (Transactionsed [Transactions,ExternalTransactions)'																										MetricExplanation,		
						adir.PetInsuranceInAppPaymentTx																																				CSHARP_TO_PROD_VIEW,
						bdir.PetInsuranceInAppPaymentTx																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource PetInsuranceInAppPaymentTx*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource PetInsuranceInAppPaymentVol*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'PetInsuranceInAppPaymentVol'																																			BasedReportTableField,
						'FACT_Transactions;FACT_InsurancePolicies'																																		Tested_DWH_Table,
						'BranchType;TransactionsId;TxAmount;TransactionId;FeatureType'																														Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN BranchType  = 7 AND TransactionsId IS NOT NULL	THEN TxAmount ELSE NULL END)'																							Formula,		
						'Pet Insurance In App Payment Vol (Transactionsed [Transactions,ExternalTransactions])'																									MetricExplanation,		
						adir.PetInsuranceInAppPaymentVol																																			CSHARP_TO_PROD_VIEW,
						bdir.PetInsuranceInAppPaymentVol																																			PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource PetInsuranceInAppPaymentVol*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource PetInsuranceInAppPaymentFee*/		
				  SELECT 		
						bdir.[Date]																																										 StreamDate,
						'V.'																																											 TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																					 BasedReportTable,
						'PetInsuranceInAppPaymentFee'																																					 BasedReportTableField,
						'FACT_Transactions;FACT_InsurancePolicies'																																			 Tested_DWH_Table,
						'ProductType;BranchType;TransactionsId;TxAmount;TransactionId;FeatureType'																												 Tested_DWH_Table_Field,
						0																																												 Currency,
						'N/A'																																											 Value1,
						'SUM(CASE WHEN BranchType = 7 AND ProductType = 3 AND TransactionsId IS NOT NULL THEN TxAmount*@upr/2... ELSE NULL END)[ProductType 3,4 included]'										 Formula,		
						'Pet Insurance In App Payment Fee (Transactionsed [Transactions,ExternalTransactions])'																											 MetricExplanation,		
						adir.PetInsuranceInAppPaymentFee																																				 CSHARP_TO_PROD_VIEW,
						bdir.PetInsuranceInAppPaymentFee																																				 PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource PetInsuranceInAppPaymentFee*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource PetInsuranceOutAppPaymentTx*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'Tx.#'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'PetInsuranceOutAppPaymentTx'																																				BasedReportTableField,
						'FACT_ExternalTransactions;FACT_InsurancePolicies'																																Tested_DWH_Table,
						'PolicyStatus;BranchType;ExternalTransactionId;PolicyId;TransactionId;IsCancellation;FeatureType'																					Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(CASE WHEN BranchType = 7 AND ExternalTransactionId  IS NOT NULL THEN PolicyId ELSE NULL END)'																				Formula,		
						'Pet Insurance Out App Payment Tx.# (Transactionsed [Transactions,ExternalTransactions])'																										MetricExplanation,		
						adir.PetInsuranceOutAppPaymentTx																																			CSHARP_TO_PROD_VIEW,
						bdir.PetInsuranceOutAppPaymentTx																																			PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource PetInsuranceOutAppPaymentTx*/			
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource PetInsuranceOutAppPaymentVol*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'PetInsuranceOutAppPaymentVol'																																			BasedReportTableField,
						'FACT_ExternalTransactions;FACT_InsurancePolicies'																																Tested_DWH_Table,
						'BranchType;ExternalTransactionId;TxAmount;TransactionId;FeatureType'																												Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN BranchType = 7 AND ExternalTransactionId IS NOT NULL THEN TxAmount ELSE NULL END)'																					Formula,		
						'Pet Insurance Out App Payment Vol (Transactionsed [ExternalTransactions])'																											MetricExplanation,		
						adir.PetInsuranceOutAppPaymentVol																																		CSHARP_TO_PROD_VIEW,
						bdir.PetInsuranceOutAppPaymentVol																																		PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource PetInsuranceOutAppPaymentVol*/			
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource PetInsuranceOutAppPaymentFee*/		
				  SELECT 		
						bdir.[Date]																																									  StreamDate,
						'V.'																																										  TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				  BasedReportTable,
						'PetInsuranceOutAppPaymentFee'																																				  BasedReportTableField,
						'FACT_ExternalTransactions;FACT_InsurancePolicies'																																  Tested_DWH_Table,
						'ProductType;BranchType;ExternalTransactionId;TxAmount;TransactionId;FeatureType'																									  Tested_DWH_Table_Field,
						0																																											  Currency,
						'N/A'																																										  Value1,
						'SUM(CASE WHEN BranchType = 7 AND ProductType = 3 AND ExternalTransactionId IS NOT NULL THEN TxAmount*@upr/2... ELSE NULL END) [ProductType 3,4 included]'							  Formula,		
						'Pet Insurance Out App Payment Fee (Transactionsed [ExternalTransactions])'																												  MetricExplanation,		
						adir.PetInsuranceOutAppPaymentFee																																			  CSHARP_TO_PROD_VIEW,
						bdir.PetInsuranceOutAppPaymentFee																																			  PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource PetInsuranceOutAppPaymentFee*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource UniqueUserPetInsurance*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'UU'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'UniqueUserPetInsurance'																																					BasedReportTableField,
						'FACT_Transactions;FACT_ExternalTransactions;FACT_InsurancePolicies'																													Tested_DWH_Table,
						'TransactionsId;ExternalTransactionId;BranchType;User_Key;TransactionId;FeatureType'																										Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(DISTINCT CASE WHEN BranchType = 7 THEN User_Key ELSE NULL END)'																										Formula,		
						'Unique User Pet Insurance(Transactionsed [Transactions,ExternalTransactions])'																												MetricExplanation,		
						adir.UniqueUserPetInsurance																																					CSHARP_TO_PROD_VIEW,
						bdir.UniqueUserPetInsurance																																					PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource UniqueUserPetInsurance*/			
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource PetInsurancePaymentTotalFee*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'PetInsurancePaymentTotalFee'																																				BasedReportTableField,
						'FACT_Transactions;FACT_ExternalTransactions;FACT_InsurancePolicies'																													Tested_DWH_Table,
						'TransactionsId;ExternalTransactionId;BranchType;TxAmount;TransactionId;FeatureType'																										Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN BranchType = 7 THEN (TxAmount/(1+@BSMV))*@fpr ELSE NULL END)'																									Formula,		
						'Pet Insurance Payment Total Fee (Transactionsed [Transactions,ExternalTransactions])'																										MetricExplanation,		
						adir.PetInsurancePaymentTotalFee																																			CSHARP_TO_PROD_VIEW,
						bdir.PetInsurancePaymentTotalFee																																			PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource PetInsurancePaymentTotalFee*/				

		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TravelHealthInsuranceTx*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'Tx.#'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'TravelHealthInsuranceTx'																																					BasedReportTableField,
						'FACT_Transactions;FACT_ExternalTransactions;FACT_InsurancePolicies'																													Tested_DWH_Table,
						'BranchType;TransactionsId;ExternalTransactionId;PolicyId;IsCancellation;TransactionId;FeatureType'																						Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(CASE WHEN BranchType = 2 THEN PolicyId ELSE NULL END) with [IsCancellation = !1 - 1]'																				Formula,		
						'TravelHealth Insurance Tx.# (Transactionsed [Transactions&ExternalTransactions)'																												MetricExplanation,		
						adir.TravelHealthInsuranceTx																																							CSHARP_TO_PROD_VIEW,
						bdir.TravelHealthInsuranceTx																																							PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TravelHealthInsuranceTx*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TravelHealthInsurancePremiumVol*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'TravelHealthInsurancePremiumVol'																																					BasedReportTableField,
						'FACT_Transactions;FACT_ExternalTransactions;FACT_InsurancePolicies'																													Tested_DWH_Table,
						'PolicyStatus;BranchType;TxAmount;IsCancellation;TransactionId;FeatureType'																										Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN BranchType = 2 THEN TxAmount ELSE NULL END)'																													Formula,		
						'TravelHealth Insurance Premium Vol (Transactionsed [Transactions&ExternalTransactions])'																											MetricExplanation,		
						adir.TravelHealthInsurancePremiumVol																																				CSHARP_TO_PROD_VIEW,
						bdir.TravelHealthInsurancePremiumVol																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TravelHealthInsurancePremiumVol*/			
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TravelHealthInsuranceFee*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'TravelHealthInsuranceFee'																																					BasedReportTableField,
						'FACT_Transactions;FACT_ExternalTransactions;FACT_InsurancePolicies'																													Tested_DWH_Table,
						'ProductType;BranchType;TransactionsId;ExternalTransactionId;TxAmount;IsCancellation;TransactionId;FeatureType'																												Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'CASE WHEN BranchType = 2 AND ProductType = 5 THEN TxAmount*@tsp/2... ELSE NULL END)[Same SUM for ProductType 5,6 included]'													Formula,		
						'TravelHealth Insurance Fee (Transactionsed [Transactions,ExternalTransactions])'																														MetricExplanation,		
						adir.TravelHealthInsuranceFee																																						CSHARP_TO_PROD_VIEW,
						bdir.TravelHealthInsuranceFee																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TravelHealthInsuranceFee*/			
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TravelHealthInsuranceInAppPaymentTx*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'Tx.#'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'TravelHealthInsuranceInAppPaymentTx'																																		BasedReportTableField,
						'FACT_Transactions;FACT_InsurancePolicies'																																		Tested_DWH_Table,
						'PolicyStatus;BranchType;TransactionsId;IsCancellation;TransactionId;FeatureType'																									Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(CASE WHEN BranchType = 2 AND TransactionsId IS NOT NULL THEN PolicyId ELSE NULL END)'																						Formula,		
						'TravelHealth Insurance In App Payment Tx.# (Transactionsed [Transactions,ExternalTransactions)'																								MetricExplanation,		
						adir.TravelHealthInsuranceInAppPaymentTx																																	CSHARP_TO_PROD_VIEW,
						bdir.TravelHealthInsuranceInAppPaymentTx																																	PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TravelHealthInsuranceInAppPaymentTx*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TravelHealthInsuranceInAppPaymentVol*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'TravelHealthInsuranceInAppPaymentVol'																																	BasedReportTableField,
						'FACT_Transactions;FACT_InsurancePolicies'																																		Tested_DWH_Table,
						'BranchType;TransactionsId;TxAmount;IsCancellation;TransactionId;FeatureType'																											Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN BranchType = 2 AND TransactionsId IS NOT NULL	THEN TxAmount ELSE NULL END)'																							Formula,		
						'TravelHealth Insurance In App Payment Vol (Transactionsed [Transactions,ExternalTransactions])'																							MetricExplanation,		
						adir.TravelHealthInsuranceInAppPaymentVol																																CSHARP_TO_PROD_VIEW,
						bdir.TravelHealthInsuranceInAppPaymentVol																																PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TravelHealthInsuranceInAppPaymentVol*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TravelHealthInsuranceInAppPaymentFee*/		
				  SELECT 		
						bdir.[Date]																																										 StreamDate,
						'V.'																																											 TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																					 BasedReportTable,
						'TravelHealthInsuranceInAppPaymentFee'																																			 BasedReportTableField,
						'FACT_Transactions;FACT_InsurancePolicies'																																			 Tested_DWH_Table,
						'ProductType;BranchType;TransactionsId;IsCancellation;TransactionId;FeatureType'																										 Tested_DWH_Table_Field,
						0																																												 Currency,
						'N/A'																																											 Value1,
						'SUM(CASE WHEN BranchType = 2 AND ProductType = 5 AND TransactionsId IS NOT NULL THEN TxAmount*@tsp/2... ELSE NULL END)[ProductType 5,6 included]'										 Formula,		
						'TravelHealth Insurance In App Payment Fee (Transactionsed [Transactions,ExternalTransactions])'																									 MetricExplanation,		
						adir.TravelHealthInsuranceInAppPaymentFee																																		 CSHARP_TO_PROD_VIEW,
						bdir.TravelHealthInsuranceInAppPaymentFee																																		 PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TravelHealthInsuranceInAppPaymentFee*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TravelHealthInsuranceOutAppPaymentTx*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'Tx.#'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'TravelHealthInsuranceOutAppPaymentTx'																																		BasedReportTableField,
						'FACT_ExternalTransactions;FACT_InsurancePolicies'																																Tested_DWH_Table,
						'PolicyStatus;BranchType;ExternalTransactionId;IsCancellation;TransactionId;FeatureType'																							Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(CASE WHEN BranchType = 2 AND ExternalTransactionId  IS NOT NULL THEN PolicyId ELSE NULL END)'																				Formula,		
						'TravelHealth Insurance Out App Payment Tx.# (Transactionsed [Transactions,ExternalTransactions])'																							MetricExplanation,		
						adir.TravelHealthInsuranceOutAppPaymentTx																																	CSHARP_TO_PROD_VIEW,
						bdir.TravelHealthInsuranceOutAppPaymentTx																																	PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TravelHealthInsuranceOutAppPaymentTx*/			
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TravelHealthInsuranceOutAppPaymentVol*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'TravelHealthInsuranceOutAppPaymentVol'																																	BasedReportTableField,
						'FACT_ExternalTransactions;FACT_InsurancePolicies'																																Tested_DWH_Table,
						'BranchType;ExternalTransactionId;Id;TxAmount;IsCancellation;TransactionId;FeatureType'																								Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN BranchType = 2 AND ExternalTransactionId IS NOT NULL THEN TxAmount ELSE NULL END)'																					Formula,		
						'TravelHealth Insurance Out App Payment Vol (Transactionsed [ExternalTransactions])'																									MetricExplanation,		
						adir.TravelHealthInsuranceOutAppPaymentVol																																CSHARP_TO_PROD_VIEW,
						bdir.TravelHealthInsuranceOutAppPaymentVol																																PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TravelHealthInsuranceOutAppPaymentVol*/			
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TravelHealthInsuranceOutAppPaymentFee*/		
				  SELECT 		
						bdir.[Date]																																									  StreamDate,
						'V.'																																										  TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				  BasedReportTable,
						'TravelHealthInsuranceOutAppPaymentFee'																																		  BasedReportTableField,
						'FACT_ExternalTransactions;FACT_InsurancePolicies'																																  Tested_DWH_Table,
						'ProductType;BranchType;ExternalTransactionId;TxAmount;IsCancellation;TransactionId;FeatureType'																						  Tested_DWH_Table_Field,
						0																																											  Currency,
						'N/A'																																										  Value1,
						'SUM(CASE WHEN BranchType = 2 AND ProductType = 5 AND ExternalTransactionId IS NOT NULL THEN TxAmount*@tsp/2... ELSE NULL END) [ProductType 5,6 included]'							  Formula,		
						'TravelHealth Insurance Out App Payment Fee (Transactionsed [ExternalTransactions])'																									  MetricExplanation,		
						adir.TravelHealthInsuranceOutAppPaymentFee																																	  CSHARP_TO_PROD_VIEW,
						bdir.TravelHealthInsuranceOutAppPaymentFee																																	  PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TravelHealthInsuranceOutAppPaymentFee*/				
		
			
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TravelHealthInsurancePaymentTotalFee*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'TravelHealthInsurancePaymentTotalFee'																																		BasedReportTableField,
						'FACT_Transactions;FACT_ExternalTransactions;FACT_InsurancePolicies'																													Tested_DWH_Table,
						'TransactionsId;ExternalTransactionId;BranchType;TxAmount;IsCancellation;TransactionId;FeatureType'																						Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN BranchType = 2 THEN (TxAmount/(1+@BSMV))*@tpp ELSE NULL END)'																									Formula,		
						'TravelHealth Insurance Payment Total Fee (Transactionsed [Transactions,ExternalTransactions])'																								MetricExplanation,		
						adir.TravelHealthInsurancePaymentTotalFee																																	CSHARP_TO_PROD_VIEW,
						bdir.TravelHealthInsurancePaymentTotalFee																																	PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TravelHealthInsurancePaymentTotalFee*/			
			UNION ALL		
	
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalCashback*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'TotalCashback'																																								BasedReportTableField,
						'FACT_Transactions;FACT_InsurancePolicies'																																		Tested_DWH_Table,
						'FeatureType;IsCancellation;TxAmount;IsCancellation;TransactionId;FeatureType'																									Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN L.FeatureType = 15 AND IsCancellation != 1 THEN l.TxAmount ELSE NULL END) [TransactionId JOINED]'																Formula,		
						'Total Cashback(Cancellations Excluded)'																																	MetricExplanation,		
						adir.TotalCashback																																							CSHARP_TO_PROD_VIEW,
						bdir.TotalCashback																																							PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalCashback*/

			UNION ALL
/*Yeni yapida çikarilan FACT_DailyInsuranceCSEntityDataSource alanlari	 --KALDIRILDI 3-4-23 //GERI ALINACAKLAR
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalCanceledInsuranceTx*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'TotalCanceledInsuranceTx'																																					BasedReportTableField,
						'FACT_Transactions;FACT_InsurancePolicies'																																		Tested_DWH_Table,
						'PolicyStatus;Id'																																							Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(CASE WHEN p.PolicyStatus in (6,9) THEN P.Id ELSE NULL END)'																											Formula,		
						'Total Canceled Tx.#'																																						MetricExplanation,		
						adir.TotalCanceledInsuranceTx																																				CSHARP_TO_PROD_VIEW,
						bdir.TotalCanceledInsuranceTx																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalCanceledInsuranceTx*/

			UNION ALL

/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalCanceledInsurancePremiumVol*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'TotalCanceledInsurancePremiumVol'																																		BasedReportTableField,
						'FACT_Transactions;FACT_InsurancePolicies'																																		Tested_DWH_Table,
						'PolicyStatus;Premium'																																						Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN p.PolicyStatus in (6,9) THEN P.Premium ELSE NULL END)'																										Formula,		
						'Total Canceled Tx. Premium'																																				MetricExplanation,		
						adir.TotalCanceledInsurancePremiumVol																																	CSHARP_TO_PROD_VIEW,
						bdir.TotalCanceledInsurancePremiumVol																																	PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalCanceledInsurancePremiumVol*/

			UNION ALL
			
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalCanceledInsuranceFee*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'TotalCanceledInsuranceFee'																																					BasedReportTableField,
						'FACT_Transactions;FACT_InsurancePolicies'																																		Tested_DWH_Table,
						'PolicyStatus;Premium'																																						Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN p.PolicyStatus in (6,9) THEN P.Premium ELSE NULL END) IN EACH PRODUCT with their calculations'																Formula,		
						'Total Canceled Tx. Fee'																																					MetricExplanation,		
						adir.TotalCanceledInsuranceFee																																				CSHARP_TO_PROD_VIEW,
						bdir.TotalCanceledInsuranceFee																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource TotalCanceledInsuranceFee*/

			UNION ALL
*/						
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource MerchandiserIbanRemittanceCnt*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'Tx.#'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'MerchandiserIbanRemittanceCnt'																																							BasedReportTableField,
						'FACT_MerchandiserTransactions'																																										Tested_DWH_Table,
						'FeatureType;Id'																																												Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'Cnt(CASE WHEN FeatureType = 21 THEN Id ELSE NULL END)'																																		Formula,
						'IBAN Transfer by Merchandiser Tx.#'																																							MetricExplanation,
						addwr.MerchandiserIbanRemittanceCnt																																						CSHARP_TO_PROD_VIEW,
						bddwr.MerchandiserIbanRemittanceCnt																																						PROD_TO_DWH_VIEW,
						1 																																															IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource MerchandiserIbanRemittanceCnt*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource MerchandiserIbanRemittanceVol*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'V.'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'MerchandiserIbanRemittanceVol'																																							BasedReportTableField,
						'FACT_MerchandiserTransactions'																																										Tested_DWH_Table,
						'FeatureType;TxAmount'																																											Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'ABS(SUM(CASE WHEN FeatureType = 21 THEN TxAmount ELSE NULL END)'																																Formula,
						'IBAN Transfer by Merchandiser Tx.Vol'																																						MetricExplanation,
						addwr.MerchandiserIbanRemittanceVol																																						CSHARP_TO_PROD_VIEW,
						bddwr.MerchandiserIbanRemittanceVol																																						PROD_TO_DWH_VIEW,
						1 																																															IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource MerchandiserIbanRemittanceVol*/

			UNION ALL
			
			/*BEGIN - FACT_DailyDepositAndWithdrawalCSEntityDataSource MerchandiserIbanRemittanceFee*/
				  SELECT 
						bddwr.[Date]																																												StreamDate,
						'V.'																																														TestType,
						'FACT_DailyDepositAndWithdrawalCSEntityDataSource'																																						BasedReportTable,
						'MerchandiserIbanRemittanceFee'																																								BasedReportTableField,
						'FACT_MerchandiserTransactions'																																										Tested_DWH_Table,
						'FeatureType;Fee'																																												Tested_DWH_Table_Field,
						bddwr.Currency,
						'N/A'																																														Value1,
						'ABS(SUM(CASE WHEN FeatureType = 21 THEN Fee ELSE NULL END)'																																	Formula,
						'IBAN Transfer by Merchandiser Tx.Fee'																																							MetricExplanation,
						addwr.MerchandiserIbanRemittanceFee																																							CSHARP_TO_PROD_VIEW,
						bddwr.MerchandiserIbanRemittanceFee																																							PROD_TO_DWH_VIEW,
						1 																																															IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource	bddwr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource addwr on bddwr.[Date] = addwr.[Date] AND bddwr.Currency = addwr.Currency
			/*END - FACT_DailyDepositAndWithdrawalCSEntityDataSource MerchandiserIbanRemittanceFee*/
			
			UNION ALL
			
			/*BEGIN-FACT_DailyFinancialCSEntityDataSource InvestmentFundingTxVol*/
				  SELECT 
						bdfr.[Date]																																													StreamDate,
						'V.'																																														TestType,
						'FACT_DailyFinancialCSEntityDataSource'																																								BasedReportTable,
						'InvestmentFundingTxVol'																																									BasedReportTableField,
						'FACT_Transactions'																																												Tested_DWH_Table,
						'FeatureType;TxAmount'																																											Tested_DWH_Table_Field,
						bdfr.Currency,
						'N/A'																																														Value1,
						'SUM(CASE WHEN FeatureType = 28 THEN TxAmount ELSE NULL END)'																																	Formula,
						'Investment AcCnt Funding Tx. V.'																																							MetricExplanation,
						adfr.InvestmentFundingTxVol																																								CSHARP_TO_PROD_VIEW,
						bdfr.InvestmentFundingTxVol																																								PROD_TO_DWH_VIEW,
						1 																																															IsWarningField			
				  FROM		 #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource	bdfr
				  INNER JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource adfr on bdfr.[Date] = adfr.[Date] AND bdfr.Currency = adfr.Currency
			/*END-FACT_DailyFinancialCSEntityDataSource InvestmentFundingTxVol*/

			UNION ALL
			
			/*BEGIN - #BI_TransactionsSuperiorityIncompleteDataTest TransactionsSuperiorityDetailsIdCnt*/
				  SELECT 
						bls.[Date]																							StreamDate,
						'Log #'																								TestType,
						'N/A'																								BasedReportTable,
						'N/A'																								BasedReportTableField,
						'FACT_Transactions;FACT_Transactions_Details'																	Tested_DWH_Table,
						'l.Id;ld.Id'																						Tested_DWH_Table_Field,
						bls.Currency,	
						CASE 
							WHEN bls.TransactionsSuperiorityIdCnt < bls.TransactionsSuperiorityDetailsIdCnt
								THEN 'Detail table has repeated data!'
							WHEN bls.TransactionsSuperiorityIdCnt > bls.TransactionsSuperiorityDetailsIdCnt
								THEN 'Detail table has missing Data!'
							WHEN bls.TransactionsSuperiorityIdCnt = bls.TransactionsSuperiorityDetailsIdCnt
								THEN 'Table logs are equally likely'
						END 																								Value1,
						'Cnt(Id) FACT_Transactions l vs FACT_Transactions_Details ld'													Formula,
						'Id Comparing bw FACT_Transactions and FACT_Transactions_Details'												MetricExplanation,
						bls.TransactionsSuperiorityIdCnt																		CSHARP_TO_PROD_VIEW,
						bls.TransactionsSuperiorityDetailsIdCnt																	PROD_TO_DWH_VIEW,
						1 																									IsWarningField			
				  FROM	#BI_TransactionsSuperiorityIncompleteDataTest	bls
				  
			/*END - #BI_TransactionsSuperiorityIncompleteDataTest TransactionsSuperiorityDetailsIdCnt*/

			UNION ALL
			
			/*BEGIN - #BI_UserAttributesSuperiorityIncompleteDataTest UserAttributesSuperiorityIdCnt*/
				  SELECT 
						bus.[Date]																							StreamDate,
						'Log #'																								TestType,
						'N/A'																								BasedReportTable,
						'N/A'																								BasedReportTableField,
						'DIM_UserAttributes;DIM_UserAttributes_Details'																		Tested_DWH_Table,
						'u.Id;ud.Id'																						Tested_DWH_Table_Field,
						-1																									Currency,	
						CASE 
							WHEN bus.UserAttributesSuperiorityIdCnt < bus.UserAttributesSuperiorityDetailsIdCnt
								THEN 'Detail table has repeated data!'
							WHEN bus.UserAttributesSuperiorityIdCnt > bus.UserAttributesSuperiorityDetailsIdCnt
								THEN 'Detail table has missing Data!'
							WHEN bus.UserAttributesSuperiorityIdCnt = bus.UserAttributesSuperiorityDetailsIdCnt
								THEN 'Table logs are equally likely'
						END 																								Value1,
						'Cnt(Id) DIM_UserAttributes u vs DIM_UserAttributes_Details ud'														Formula,
						'Id Comparing bw DIM_UserAttributes and DIM_UserAttributes_Details'													MetricExplanation,
						bus.UserAttributesSuperiorityIdCnt																			CSHARP_TO_PROD_VIEW,
						bus.UserAttributesSuperiorityDetailsIdCnt																	PROD_TO_DWH_VIEW,
						1 																									IsWarningField			
				  FROM	#BI_UserAttributesSuperiorityIncompleteDataTest	bus
				  
			/*END - #BI_UserAttributesSuperiorityIncompleteDataTest UserAttributesSuperiorityIdCnt*/

			UNION ALL
			
			/*BEGIN - #BI_DatabaseCardsSuperiorityIncompleteDataTest DatabaseCardSuperiorityIdCnt*/
				  SELECT 
						pcs.[Date]																							StreamDate,
						'Log #'																								TestType,
						'N/A'																								BasedReportTable,
						'N/A'																								BasedReportTableField,
						'DIM_DatabaseCards;DIM_DatabaseCards_Details'															Tested_DWH_Table,
						'pc.Id;pcd.Id'																						Tested_DWH_Table_Field,
						-1																									Currency,	
						CASE 
							WHEN pcs.DatabaseCardSuperiorityIdCnt < pcs.DatabaseCardSuperiorityDetailsIdCnt
								THEN 'Detail table has repeated data!'
							WHEN pcs.DatabaseCardSuperiorityIdCnt > pcs.DatabaseCardSuperiorityDetailsIdCnt
								THEN 'Detail table has missing Data!'
							WHEN pcs.DatabaseCardSuperiorityIdCnt = pcs.DatabaseCardSuperiorityDetailsIdCnt
								THEN 'Table logs are equally likely'
						END 																								Value1,
						'Cnt(Id) DIM_DatabaseCards pc vs DIM_DatabaseCards_Details pcd'										Formula,
						'Id Comparing bw DIM_DatabaseCards pc and DIM_DatabaseCards_Details'									MetricExplanation,
						pcs.DatabaseCardSuperiorityIdCnt																	CSHARP_TO_PROD_VIEW,
						pcs.DatabaseCardSuperiorityDetailsIdCnt																PROD_TO_DWH_VIEW,
						1 																									IsWarningField			
				  FROM	#BI_DatabaseCardSuperiorityIncompleteDataTest	pcs
				  
			/*END - #BI_DatabaseCardsSuperiorityIncompleteDataTest DatabaseCardSuperiorityIdCnt*/
			

			UNION ALL
			
			/*BEGIN - #BI_DatabaseCardsSuperiorityIncompleteDataTest DatabaseCardSuperiorityUser_KeyCnt*/
				  SELECT 
						pcs.[Date]																							StreamDate,
						'Log #'																								TestType,
						'N/A'																								BasedReportTable,
						'N/A'																								BasedReportTableField,
						'DIM_DatabaseCards;DIM_DatabaseCards_Details'															Tested_DWH_Table,
						'pc.User_Key;pcd.UserId'																			Tested_DWH_Table_Field,
						-1																									Currency,	
						CASE 
							WHEN pcs.DatabaseCardSuperiorityUser_KeyCnt < pcs.DatabaseCardSuperiorityDetailsUserIdCnt
								THEN 'Detail table has less non-null data!'
							WHEN pcs.DatabaseCardSuperiorityUser_KeyCnt > pcs.DatabaseCardSuperiorityDetailsUserIdCnt
								THEN 'Detail table has missing Data!'
							WHEN pcs.DatabaseCardSuperiorityUser_KeyCnt = pcs.DatabaseCardSuperiorityDetailsUserIdCnt
								THEN 'Table logs are equally likely'
						END 																								Value1,
						'Cnt(pc.User_Key|pcd.UserId) DIM_DatabaseCards pc vs DIM_DatabaseCards_Details pcd'					Formula,
						'Id Comparing bw DIM_DatabaseCards pc and DIM_DatabaseCards_Details'									MetricExplanation,
						pcs.DatabaseCardSuperiorityUser_KeyCnt																CSHARP_TO_PROD_VIEW,
						pcs.DatabaseCardSuperiorityDetailsUserIdCnt															PROD_TO_DWH_VIEW,
						1 																									IsWarningField			
				  FROM	#BI_DatabaseCardSuperiorityIncompleteDataTest	pcs

						UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource HomeInsuranceTx*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'Tx.#'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'HomeInsuranceTx'																																							BasedReportTableField,
						'FACT_Transactions;FACT_ExternalTransactions;FACT_InsurancePolicies'																													Tested_DWH_Table,
						'BranchType;TransactionsId;ExternalTransactionId;PolicyId;IsCancellation;TransactionId;FeatureType'																						Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(CASE WHEN BranchType = 10 THEN PolicyId ELSE NULL END) with [IsCancellation = !1 - 1]'																				Formula,		
						'Home Insurance Tx.# (Transactionsed [Transactions&ExternalTransactions)'																														MetricExplanation,		
						adir.HomeInsuranceTx																																						CSHARP_TO_PROD_VIEW,
						bdir.HomeInsuranceTx																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource HomeInsuranceTx*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource HomeInsurancePremiumVol*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'HomeInsurancePremiumVol'																																				BasedReportTableField,
						'FACT_Transactions;FACT_ExternalTransactions;FACT_InsurancePolicies'																													Tested_DWH_Table,
						'PolicyStatus;BranchType;TxAmount;IsCancellation;TransactionId;FeatureType'																										Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN BranchType = 10 THEN TxAmount ELSE NULL END)'																													Formula,		
						'Home Insurance Premium Vol (Transactionsed [Transactions&ExternalTransactions])'																											MetricExplanation,		
						adir.HomeInsurancePremiumVol																																				CSHARP_TO_PROD_VIEW,
						bdir.HomeInsurancePremiumVol																																				PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource HomeInsurancePremiumVol*/			
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource HomeInsuranceFee*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'HomeInsuranceFee'																																							BasedReportTableField,
						'FACT_Transactions;FACT_ExternalTransactions;FACT_InsurancePolicies'																													Tested_DWH_Table,
						'ProductType;BranchType;TransactionsId;ExternalTransactionId;TxAmount;IsCancellation;TransactionId;FeatureType'																			Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'CASE WHEN BranchType = 10 AND ProductType = 7 THEN TxAmount*@hpp/2... ELSE NULL END)[Same SUM for ProductType 8,9 included]'													Formula,		
						'Home Insurance Fee (Transactionsed [Transactions,ExternalTransactions])'																														MetricExplanation,		
						adir.HomeInsuranceFee																																						CSHARP_TO_PROD_VIEW,
						bdir.HomeInsuranceFee																																						PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource HomeInsuranceFee*/			
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource HomeInsuranceInAppPaymentTx*/		
				  SELECT 		
						bdir.[Date]																																							StreamDate,
						'Tx.#'																																								TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																		BasedReportTable,
						'HomeInsuranceInAppPaymentTx'																																		BasedReportTableField,
						'FACT_Transactions;FACT_InsurancePolicies'																																Tested_DWH_Table,
						'PolicyStatus;BranchType;TransactionsId;IsCancellation;TransactionId;FeatureType'																							Tested_DWH_Table_Field,
						0																																									Currency,
						'N/A'																																								Value1,
						'Cnt(CASE WHEN BranchType = 10 AND TransactionsId IS NOT NULL THEN PolicyId ELSE NULL END)'																				Formula,		
						'Home Insurance In App Payment Tx.# (Transactionsed [Transactions,ExternalTransactions)'																								MetricExplanation,		
						adir.HomeInsuranceInAppPaymentTx																																	CSHARP_TO_PROD_VIEW,
						bdir.HomeInsuranceInAppPaymentTx																																	PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource HomeInsuranceInAppPaymentTx*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource HomeInsuranceInAppPaymentVol*/		
				  SELECT 		
						bdir.[Date]																																							StreamDate,
						'V.'																																								TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																		BasedReportTable,
						'HomeInsuranceInAppPaymentVol'																																	BasedReportTableField,
						'FACT_Transactions;FACT_InsurancePolicies'																																Tested_DWH_Table,
						'BranchType;TransactionsId;TxAmount;IsCancellation;TransactionId;FeatureType'																									Tested_DWH_Table_Field,
						0																																									Currency,
						'N/A'																																								Value1,
						'SUM(CASE WHEN BranchType = 10 AND TransactionsId IS NOT NULL	THEN TxAmount ELSE NULL END)'																					Formula,		
						'Home Insurance In App Payment Vol (Transactionsed [Transactions,ExternalTransactions])'																							MetricExplanation,		
						adir.HomeInsuranceInAppPaymentVol																																CSHARP_TO_PROD_VIEW,
						bdir.HomeInsuranceInAppPaymentVol																																PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource HomeInsuranceInAppPaymentVol*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource HomeInsuranceInAppPaymentFee*/		
				  SELECT 		
						bdir.[Date]																																								 StreamDate,
						'V.'																																									 TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																			 BasedReportTable,
						'HomeInsuranceInAppPaymentFee'																																			 BasedReportTableField,
						'FACT_Transactions;FACT_InsurancePolicies'																																	 Tested_DWH_Table,
						'ProductType;BranchType;TransactionsId;IsCancellation;TransactionId;FeatureType'																								 Tested_DWH_Table_Field,
						0																																										 Currency,
						'N/A'																																									 Value1,
						'SUM(CASE WHEN BranchType = 10 AND ProductType = 7 AND TransactionsId IS NOT NULL THEN TxAmount*@hsp/2... ELSE NULL END)[ProductType 8,9 included]'								 Formula,		
						'Home Insurance In App Payment Fee (Transactionsed [Transactions,ExternalTransactions])'																									 MetricExplanation,		
						adir.HomeInsuranceInAppPaymentFee																																		 CSHARP_TO_PROD_VIEW,
						bdir.HomeInsuranceInAppPaymentFee																																		 PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource HomeInsuranceInAppPaymentFee*/				
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource HomeInsuranceOutAppPaymentTx*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'Tx.#'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'HomeInsuranceOutAppPaymentTx'																																				BasedReportTableField,
						'FACT_ExternalTransactions;FACT_InsurancePolicies'																																Tested_DWH_Table,
						'PolicyStatus;BranchType;ExternalTransactionId;IsCancellation;TransactionId;FeatureType'																							Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'Cnt(CASE WHEN BranchType = 10 AND ExternalTransactionId  IS NOT NULL THEN PolicyId ELSE NULL END)'																				Formula,		
						'Home Insurance Out App Payment Tx.# (Transactionsed [Transactions,ExternalTransactions])'																									MetricExplanation,		
						adir.HomeInsuranceOutAppPaymentTx																																			CSHARP_TO_PROD_VIEW,
						bdir.HomeInsuranceOutAppPaymentTx																																			PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource HomeInsuranceOutAppPaymentTx*/			
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource HomeInsuranceOutAppPaymentVol*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'HomeInsuranceOutAppPaymentVol'																																			BasedReportTableField,
						'FACT_ExternalTransactions;FACT_InsurancePolicies'																																Tested_DWH_Table,
						'BranchType;ExternalTransactionId;Id;TxAmount;IsCancellation;TransactionId;FeatureType'																								Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN BranchType = 10 AND ExternalTransactionId IS NOT NULL THEN TxAmount ELSE NULL END)'																					Formula,		
						'Home Insurance Out App Payment Vol (Transactionsed [ExternalTransactions])'																											MetricExplanation,		
						adir.HomeInsuranceOutAppPaymentVol																																		CSHARP_TO_PROD_VIEW,
						bdir.HomeInsuranceOutAppPaymentVol																																		PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource HomeInsuranceOutAppPaymentVol*/			
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource HomeInsuranceOutAppPaymentFee*/		
				  SELECT 		
						bdir.[Date]																																									  StreamDate,
						'V.'																																										  TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				  BasedReportTable,
						'HomeInsuranceOutAppPaymentFee'																																				  BasedReportTableField,
						'FACT_ExternalTransactions;FACT_InsurancePolicies'																																  Tested_DWH_Table,
						'ProductType;BranchType;ExternalTransactionId;TxAmount;IsCancellation;TransactionId;FeatureType'																						  Tested_DWH_Table_Field,
						0																																											  Currency,
						'N/A'																																										  Value1,
						'SUM(CASE WHEN BranchType = 10 AND ProductType = 7 AND ExternalTransactionId IS NOT NULL THEN TxAmount*@hsp/2... ELSE NULL END) [ProductType 8,9 included]'							  Formula,		
						'Home Insurance Out App Payment Fee (Transactionsed [ExternalTransactions])'																											  MetricExplanation,		
						adir.HomeInsuranceOutAppPaymentFee																																			  CSHARP_TO_PROD_VIEW,
						bdir.HomeInsuranceOutAppPaymentFee																																			  PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource HomeInsuranceOutAppPaymentFee*/						
		
			UNION ALL		
		
/*BEGIN - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource HomeInsurancePaymentTotalFee*/		
				  SELECT 		
						bdir.[Date]																																									StreamDate,
						'V.'																																										TestType,
						'FACT_DailyInsuranceCSEntityDataSource'																																				BasedReportTable,
						'HomeInsurancePaymentTotalFee'																																				BasedReportTableField,
						'FACT_Transactions;FACT_ExternalTransactions;FACT_InsurancePolicies'																													Tested_DWH_Table,
						'TransactionsId;ExternalTransactionId;BranchType;TxAmount;IsCancellation;TransactionId;FeatureType'																						Tested_DWH_Table_Field,
						0																																											Currency,
						'N/A'																																										Value1,
						'SUM(CASE WHEN BranchType = 10 THEN (TxAmount/(1+@BSMV))*@hpp ELSE NULL END)'																									Formula,		
						'Home Insurance Payment Total Fee (Transactionsed [Transactions,ExternalTransactions])'																										MetricExplanation,		
						adir.HomeInsurancePaymentTotalFee																																			CSHARP_TO_PROD_VIEW,
						bdir.HomeInsurancePaymentTotalFee																																			PROD_TO_DWH_VIEW,  1 IsWarningField			
				  FROM #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource    bdir		
				  JOIN #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource adir on bdir.[Date] = adir.[Date]		
/*END - #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource HomeInsurancePaymentTotalFee*/
				  
			/*END - #BI_DatabaseCardsSuperiorityIncompleteDataTest DatabaseCardSuperiorityUser_KeyCnt*/

		) TestQueriesX /*Order By'i dogru çalistirabilmesi için UNION ALL'lari parantezleyip select * from TestQueriesX seklinde çektik*/
ORDER BY BasedReportTable, BasedReportTableField, StreamDate
PRINT '42 - Completed - UNION ALL - INSERT INTO DWH_Database.dbo.[FACT_ProdToDWHCompatibilityTestViaCSEntities]' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))
DROP TABLE IF EXISTS #PROD_TO_DWH_VIEW_FACT_DailyMassPaymentCSEntityDataSource
				   , #PROD_TO_DWH_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource
				   , #PROD_TO_DWH_VIEW_FACT_DailyRemittanceCSEntityDataSource
				   , #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A
				   , #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_B
				   , #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_C
				   , #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_D
				   , #PROD_TO_DWH_VIEW_FACT_DailyUserAttributesCSEntityDataSource_E
				   , #PROD_TO_DWH_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource
				   , #PROD_TO_DWH_VIEW_FACT_DailyFinancialCSEntityDataSource				
				   , #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_A
				   , #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_B
				   , #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_C
				   , #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_D
				   , #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_E
				   , #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_F
				   , #PROD_TO_DWH_VIEW_FACT_CSEntityDataSource_G
				   , #PROD_TO_DWH_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource
				   , #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource
				   , #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_A
				   , #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_B
				   , #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_C
				   , #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_D
				   , #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCSEntityDataSource_E	
				   , #PROD_TO_DWH_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource
				   , #PROD_TO_DWH_VIEW_FACT_DailyCheckoutCSEntityDataSource
				   , #PROD_TO_DWH_VIEW_FACT_DailyInsuranceCSEntityDataSource		
				   , #CSHARP_TO_PROD_VIEW_FACT_DailyMassPaymentCSEntityDataSource
				   , #CSHARP_TO_PROD_VIEW_FACT_DailyInvoicePaymentCSEntityDataSource
				   , #CSHARP_TO_PROD_VIEW_FACT_DailyRemittanceCSEntityDataSource
				   , #CSHARP_TO_PROD_VIEW_FACT_DailyUserAttributesCSEntityDataSource_A				
				   , #CSHARP_TO_PROD_VIEW_FACT_DailyPersonalCommercialCSEntityDataSource
				   , #CSHARP_TO_PROD_VIEW_FACT_DailyFinancialCSEntityDataSource	
				   , #CSHARP_TO_PROD_VIEW_FACT_CSEntityDataSource			
				   , #CSHARP_TO_PROD_VIEW_FACT_DailyDepositAndWithdrawalCSEntityDataSource
				   , #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCSEntityDataSource		
				   , #CSHARP_TO_PROD_VIEW_FACT_DailyDatabaseCardCashbackCSEntityDataSource
				   , #CSHARP_TO_PROD_VIEW_FACT_DailyCheckoutCSEntityDataSource		
				   , #CSHARP_TO_PROD_VIEW_FACT_DailyInsuranceCSEntityDataSource
				   , #BI_TransactionsSuperiorityIncompleteDataTest
				   , #BI_UserAttributesSuperiorityIncompleteDataTest
				   , #BI_DatabaseCardSuperiorityIncompleteDataTest
PRINT '<FINAL>- 43 - TEMPORARY TABLES DROPPED - ALL INSERTIONS SUCCESSFULLY COMPLETED! ' + ' -DATETIME : ' + (CONVERT(VARCHAR(24), GETDATE(), 121))