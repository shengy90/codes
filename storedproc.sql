DROP TABLE #MTLAMORT
SELECT
FL.DATE_ENTERED, FL.LOAN_CATEGORY, TLED.LOAN_PAID_OFF_DATE, lastpayment.last_due_date, lastpayment.term,
MPA.MPAY_AMORT_KEY, MPA.LOAN_KEY, MPA.PAYMENT_NUM, MPA.ADJUSTED_PAYMENT_DATE, MPA.PAYMENT_AMT, MPA.INTEREST_AMT,


/*Get Principal Due for Bad Debt & Recoveries Prediction*/
CASE
	/*
	1) Loans booked yesterday would not have an entry in mpayinterest yet. Therefore, Princ_Due for first payment
	would be the same as on fact_loans.
	*/
	WHEN CAST(FL.DATE_ENTERED AS DATE)=dateadd(day,-1, cast(getdate() as date)) 
	and mpa.Payment_num = 1 THEN FL.PRINC_AMT

	/*2) If payment isn't due yet, then mpayinterest would not be populated yet. Princ_due is therefore = to the latest
	latest princ due.*/
	WHEN mpa.adjusted_payment_date >= CAST(GETDATE() AS DATE) THEN 
	latestprinc.princ_due else MPI.PRINC_DUE end as princ_due, 


/*Get loan balance*/
CASE 
	/*Similar to Princ_due (see above)*/
	WHEN CAST(FL.DATE_ENTERED AS DATE)=dateadd(day,-1, cast(getdate() as date)) 
	and mpa.Payment_num = 1 THEN FL.LOAN_BALANCE
	WHEN mpa.adjusted_payment_date >= CAST(GETDATE() AS DATE) THEN 
	latestprinc.loan_balance else MPI.loan_balance end as loan_balance
	
	
/*
Get loan status on the payment date. 
Loans that were already in bad standing shouldn't be counted towards default rates!
4 Outcomes:
	1) Early Settled
	2) Defaulted
	3) Good Standing
	4) Not Due
*/
,CASE
	--Check for early settled. Criteria: paid off before last due date, loan status date before current payment date,
	--loan balance = 0
	WHEN CAST(TLED.LOAN_PAID_OFF_DATE AS DATE) < lastpayment.last_due_date 
		AND FL.LOAN_BALANCE <= 0 AND CAST(FL.LOAN_STATUS_DATE AS DATE) < MPA.adjusted_PAYMENT_DATE
		THEN 'Early Settled'
		
	--If loan is already in collections on payment date, mpayinterest will show positive collections_amt
	WHEN MPI.COLLECTIONS_AMT > 0 THEN 'Defaulted'
	
	--if payment date is after today, but the loan is currently in collections
	WHEN MPA.ADJUSTED_PAYMENT_DATE >= CAST(GETDATE() AS DATE) 
	AND latestprinc.COLLECTIONS_AMT > 0  THEN 'Defaulted'
	
	--if collections amount is 0 in mpayinterest, then it's in good standing
	WHEN MPI.COLLECTIONS_AMT = 0 THEN 'Good Standing'
	
	--if payment date is after today then payment isn't due yet
	WHEN MPA.ADJUSTED_PAYMENT_DATE >= CAST(GETDATE() AS DATE) AND 
	(latestprinc.COLLECTIONS_AMT IS NULL OR latestprinc.COLLECTIONS_AMT = 0) THEN 'Not Due'
	
END AS Loan_Stat_On_Payment_date,

PREV.ADJUSTED_PAYMENT_DATE AS PREVPAYMENTDATE,

CASE 	WHEN MPA.PAYMENT_NUM > 1 AND CAST(TLED.LOAN_PAID_OFF_DATE AS DATE) < lastpayment.last_due_date 
		AND CAST(FL.LOAN_STATUS_DATE AS DATE) > PREV.ADJUSTED_PAYMENT_DATE 
		AND FL.LOAN_BALANCE <= 0 AND CAST(FL.LOAN_STATUS_DATE AS DATE) <= MPA.adjusted_PAYMENT_DATE
		THEN 1 
		
		WHEN MPA.PAYMENT_NUM = 1 AND CAST(TLED.LOAN_PAID_OFF_DATE AS DATE) < lastpayment.last_due_date 
		AND FL.LOAN_BALANCE <= 0 AND CAST(FL.LOAN_STATUS_DATE AS DATE) <= MPA.adjusted_PAYMENT_DATE
		THEN 1 
		
		END AS EARLY_SETTLE_FLAG
	
	
/*EPDQ Flag*/
,EPDQ.IS_EPDQ_ONLY

/*ACH Outcome Data*/
,ACH_OUTCOME.PROJ_SEND_DATE AS DD_DATE, 
ACH_AMOUNT AS DD_AMT,
ACH_OUTCOME.ACH_RESULT_CODE AS DD_OUTCOME,
ACH_OUTCOME.TRANS_DETAIL_KEY AS ACH_TRANS_DETAIL_KEY,
-ach_rev.amount as ACH_REV, LPM.ADD_TO_COLL, lp.date_entered as add_to_coll_date, 
lpmcc.rem_from_coll, lpcc.date_entered as rem_from_coll_date

/*CC Outcome Data*/

,cc.credit_card_trans_key,
CC.DATE_ENTERED AS CC_DATE,
CC.SUCCESS_FLAG,
CC.CHARGE_AMT,
CC.TRANS_POS_KEY AS CC_TRANS_POS_KEY,
cctl.trans_desc,
cctl.trans_detail_key,
-cc_rev.amount as CC_REV,

statx.date_entered as statusx_date

INTO #MTLAMORT
FROM CORE_CDW..MPAYAMORT MPA

/*Select all MTL loans*/
INNER JOIN WDA_BI..FACT_LOANS FL
	ON FL.LOAN_KEY = MPA.LOAN_KEY
	AND FL.LOAN_PRODUCT_KEY = 16 
	AND FL.EMPLOYER_NAME != 'WDA'
	
/*Get max term and final due date*/		
LEFT JOIN (
	SELECT  LOAN_KEY, MAX(ADJUSTED_PAYMENT_DATE) AS LAST_DUE_DATE, MAX(PAYMENT_NUM) AS TERM
	FROM CORE_CDW..MPAYAMORT  (nolocK)
	GROUP BY LOAN_KEY
	) AS lastpayment
	on lastpayment.loan_key = mpa.loan_key
	
/*Get loan paid off date. This is used to identify early settled loans*/	
LEFT JOIN WDA_BI..TL_LOAN_END_DATES TLED (nolocK)
	ON TLED.LOAN_KEY = MPA.LOAN_KEY

/*Get Latest Princ Due*/
left join (
select
	loan_key, max(mpay_interest_key) as max_mpi_key
	from core_cdw..mpayinterest
	group by loan_key) max_mpi
	on max_mpi.loan_key = mpa.loan_key
left join core_cdw..mpayinterest latestprinc
	on latestprinc.mpay_interest_key = max_mpi.max_mpi_key
	
/*Join on to mpayinterest table to check for loanstatus on loan due date.*/
left join core_cdw..mpayinterest mpi (nolocK)
	on mpi.loan_key = mpa.loan_key
	and cast(mpi.date_entered as date) = mpa.adjusted_payment_date
	/*When there is DD adjustments, duplicate rows occur. Filter them out!*/
	and mpi.IS_ACH_ADJ = 0
	and mpi.IS_ERR_ADJ = 0	
	
/*Identify DD/ EPDQ only Loans*/

left join WDA_BI..REF_EPDQ_LOANS EPDQ
	ON EPDQ.LOAN_KEY = MPA.LOAN_KEY


/*Get ACH Outcomes*/	
	left join
	/*Get the latest DD request that was sent before the current payment*/
		(select 
			a.mpay_amort_key, a.loan_key, a.payment_date, max(b.ach_history_key) as ach_history_key
			from core_cdw..mpayamort a
			LEFT JOIN --Filter out DDs that are not related to the current payment
				(SELECT
				A.LOAN_KEY, A.PAYMENT_NUM, CASE WHEN A.PAYMENT_NUM= 1 THEN CAST(FL.DATE_ENTERED AS DATE) ELSE B.ADJUSTED_PAYMENT_DATE END AS PAYMENT_DATE
				FROM CORE_CDW..MPAYAMORT A
				LEFT JOIN CORE_CDW..MPAYAMORT B (nolocK)
					ON B.LOAN_KEY = A.LOAN_KEY
					AND A.PAYMENT_NUM = B.PAYMENT_NUM + 1
				LEFT JOIN WDA_BI..FACT_LOANS FL (nolocK)
					ON FL.LOAN_KEY = A.LOAN_KEY
				) AS PREV_PAYMENT --Select date of previous payment. Will be date_entered if payment_num = 1.
				ON PREV_PAYMENT.LOAN_KEY = A.LOAN_KEY
				AND PREV_PAYMENT.PAYMENT_NUM = A.PAYMENT_NUM
			
			--select ach_request that's after previous payment date and before current payment date	
			left join core_cdw..ach_history b (nolocK) --select 
				on b.loan_key = a.loan_key
				and cast(b.proj_send_date as date) <= a.adjusted_payment_date
				and cast(b.proj_send_date as date) > cast(prev_payment.payment_date as date)
	
			group by a.mpay_amort_key, a.loan_key, a.payment_date
		) AS ACH_HISTORY
		ON ACH_HISTORY.mpay_amort_key = mpa.mpay_amort_key
		
	--Get the outcome of the appropriate DD request	
	left join core_cdw..ach_history ACH_OUTCOME (nolocK)
		on ACH_OUTCOME.ACH_HISTORY_KEY = ACH_HISTORY.ACH_HISTORY_KEY
		and 
		(cast(ACH_OUTCOME.PROJ_SEND_DATE as date) <= CAST(TLED.LOAN_PAID_OFF_DATE AS DATE)
		or 
		tled.loan_paid_off_date is null)
		
	--Get the amount of revenue recognised for that DD request
	left join core_cdw..transdetailacct ach_rev
		on ach_rev.trans_detail_key = ACH_OUTCOME.trans_detail_key
		and ach_rev.gl_acct = 403000
		
	--Get the date into collections for the failed DD request
	LEFT JOIN CORE_CDW..LOANPAYMENT LP (nolock)
		ON LP.TRANS_DETAIL_KEY = ACH_OUTCOME.TRANS_DETAIL_KEY
		and ach_outcome.trans_detail_key is not null
		--Select only LP transcode that are payments/ manual defaults
		and lp.trans_code IN (4,16,17,18,19,32,91,40,25)
	LEFT JOIN CORE_CDW..LOANPAYMENTMPAY LPM (nolock)
		--Join to loanpaymentmpay to get the date where loan was put into collections
		ON LP.LOAN_PAYMENT_KEY = LPM.LOAN_PAYMENT_KEY
		AND LPM.ADD_TO_COLL = 1 



/*Get CC Trans Outcome*/
	left join
	/*Get any CC attempts on loan due date*/
		(select
		a.mpay_amort_key, a.loan_key, a.adjusted_payment_date, max(b.credit_card_trans_key) as cc_trans_key
		from core_cdw..mpayamort a
		left join wda_bi..fact_loans fl (nolocK)
			on fl.loan_key = a.loan_key
		left join core_cdw..creditcardtrans b (nolocK)
			on b.loan_key = fl.loan_key
			and cast(b.date_entered as date) = a.adjusted_payment_date
			and b.success_flag = 1
		group by a.mpay_amort_key, a.loan_key, a.adjusted_payment_date
		) AS CC_HISTORY
		ON CC_HISTORY.mpay_amort_key = mpa.mpay_amort_key

	--Get the CC outcome of the appropriate EPDQ request
	left join core_cdw..creditcardtrans cc (nolocK)
		on cc.credit_card_trans_key = CC_HISTORY.cc_trans_key
		and cc.charge_amt > 0.01 --0.01 is card verification. Get rid of all these transactions.
		AND (
		CAST(CC.DATE_ENTERED AS DATE)<=CAST(TLED.LOAN_PAID_OFF_DATE AS DATE)
		or
		tled.loan_paid_off_date is null)
			
	--Get the trans_code of payment transactions
	left join core_cdw..transdetail td
		on td.trans_pos_key = cc.trans_pos_key
		and (td.trans_code in (4,16,17,18,19))
	--Get the outcome of the pament transactions
	left join wda_bi..tl_loans_transactions cctl
		on cctl.trans_detail_key = td.trans_detail_key
		
	--lpmcc checks if the creditcard trans is a collections payment or regular payment.
	--also checks if it's a collections payment then whether or not it cures the payment.
	--Cure flag is needed for bouncers
	left join core_cdw..loanpayment lpcc
		on lpcc.trans_detail_key = cctl.trans_detail_key
	left join core_cdw..loanpaymentmpay lpmcc
		on lpmcc.loan_payment_key = lpcc.loan_payment_key
		
	left join core_cdw..transdetailacct cc_rev
		on cc_rev.trans_detail_key = cctl.trans_detail_key
		and cc_rev.gl_acct = 403000
		
/*Get status X date*/
left join wda_bi..tl_loans_transactions statx
	on statx.loan_key = mpa.loan_key
	and statx.trans_code = 25
	
left join CORE_CDW..MPAYAMORT PREV
	on PREV.lOAN_KEY = MPA.LOAN_KEY
	and PREV.PAYMENT_NUM +1 = MPA.PAYMENT_NUM
	
	
ORDER BY MPA.LOAN_KEY, MPA.PAYMENT_NUM

DROP TABLE #FP_PREARREARS_DATE
/*Get the latest add_to_coll date for each loan that's before the adjusted_payment_date.*/
SELECT 
A.LOAN_KEY AS B_LOAN_KEY, 
A.PAYMENT_NUM AS B_PAYMENT_NUM, 
A.ADJUSTED_PAYMENT_DATE AS B_ADJUSTED_PAYMENT_DATE, 
B.ADJUSTED_PAYMENT_DATE AS B_PREV_PAYMENT_DATE,
MAX(LP.DATE_ENTERED) AS LATEST_COLL_DATE

INTO #FP_PREARREARS_DATE
FROM #MTLAMORT A
LEFT JOIN #MTLAMORT B
	ON A.LOAN_KEY = B.LOAN_KEY
	AND A.PAYMENT_NUM  = B.PAYMENT_NUM + 1
	
LEFT JOIN CORE_CDW..LOANPAYMENT LP
	ON LP.LOAN_KEY = A.LOAN_KEY
INNER JOIN CORE_CDW..LOANPAYMENTMPAY LPM
	ON LPM.LOAN_PAYMENT_KEY = LP.LOAN_PAYMENT_KEY
	AND LPM.ADD_TO_COLL = 1
	AND CAST(LP.DATE_ENTERED AS DATE)<=A.ADJUSTED_PAYMENT_DATE
		
GROUP BY A.LOAN_KEY, A.PAYMENT_NUM, A.ADJUSTED_PAYMENT_DATE,B.ADJUSTED_PAYMENT_DATE
ORDER BY A.LOAN_KEY, A.PAYMENT_NUM, A.ADJUSTED_PAYMENT_DATE,B.ADJUSTED_PAYMENT_DATE


/*Calculate total supposed to be paid vs total paid*/
DROP TABLE #CUMDUEAMT
SELECT a.loan_key AS C_LOAN_KEY, a.payment_num AS C_PAYMENT_NUM,
sum(case when a.payment_num = 1 then a.payment_amt else b.payment_amt end) as CumDueAmt
into #CUMDUEAMT
from #mtlamort a
left join #mtlamort b
	on b.loan_key = a.loan_Key
	and a.payment_num >= b.payment_num	
group by a.loan_key, a.payment_num
order by a.loan_key, a.payment_num
	
DROP TABLE #CUMPAID
SELECT a.loan_key AS D_LOAN_KEY, a.payment_num AS D_PAYMENT_NUM, 
a.adjusted_payment_date AS D_ADJUSTED_PAYMENT_DATE,
CASE WHEN sum(tl.paid_amt) is NULL then 0 ELSE sum(tl.paid_amt) end as TotalPaid, C.CumDueAmt
INTO #CUMPAID
from #mtlamort a
left join wda_bi..tl_loans_transactions tl
	on tl.loan_key = a.loan_key
	and tl.trans_code in (4,16,17,18,19,32,91)
	and cast(tl.date_entered as date)<= a.adjusted_payment_date
left join #CUMDUEAMT c
	on C.c_loan_key = a.loan_key
	and c.c_payment_num = a.payment_num
group by a.loan_key, a.payment_num, a.adjusted_payment_date,C.CumDueAmt
order by a.loan_key, a.payment_num, a.adjusted_payment_date,C.CumDueAmt



DROP TABLE #LATESTCOLLDATE
/*Get the latest add_to_coll date for each loan that's before the adjusted_payment_date.*/
SELECT 
A.LOAN_KEY AS B_LOAN_KEY, 
A.PAYMENT_NUM AS B_PAYMENT_NUM, 
A.ADJUSTED_PAYMENT_DATE AS B_ADJUSTED_PAYMENT_DATE, 
B.ADJUSTED_PAYMENT_DATE AS B_PREV_PAYMENT_DATE,
MAX(LP.DATE_ENTERED) AS LATEST_COLL_DATE

INTO #LATESTCOLLDATE
FROM #MTLAMORT A
LEFT JOIN #MTLAMORT B
	ON A.LOAN_KEY = B.LOAN_KEY
	AND A.PAYMENT_NUM  = B.PAYMENT_NUM + 1
	
LEFT JOIN CORE_CDW..LOANPAYMENT LP
	ON LP.LOAN_KEY = A.LOAN_KEY
INNER JOIN CORE_CDW..LOANPAYMENTMPAY LPM
	ON LPM.LOAN_PAYMENT_KEY = LP.LOAN_PAYMENT_KEY
	AND LPM.ADD_TO_COLL = 1
	AND CAST(LP.DATE_ENTERED AS DATE)<=A.ADJUSTED_PAYMENT_DATE
	AND CAST(LP.DATE_ENTERED AS DATE)> B.ADJUSTED_PAYMENT_DATE
		
GROUP BY A.LOAN_KEY, A.PAYMENT_NUM, A.ADJUSTED_PAYMENT_DATE,B.ADJUSTED_PAYMENT_DATE
ORDER BY A.LOAN_KEY, A.PAYMENT_NUM, A.ADJUSTED_PAYMENT_DATE,B.ADJUSTED_PAYMENT_DATE


/*Default Flags Classification*/
DROP TABLE #MTLAMORT1
SELECT 
A.*, C.CumDueAmt, D.TotalPaid
/*Default Flags*/
,CASE 

	WHEN /*EPDQ Only Loans in Good Standing on Due Date. If failed then default flag = 1.*/
	LOAN_STAT_ON_PAYMENT_DATE = 'Good Standing' and IS_EPDQ_ONLY = 1 AND SUCCESS_FLAG IS NULL 
	AND D.TotalPaid < C.CumDueAmt
	THEN 1
	
	WHEN /*Direct Debit Loans that failed DD*/
	IS_EPDQ_ONLY IS NULL AND LOAN_STAT_ON_PAYMENT_DATE = 'Good Standing' and DD_OUTCOME not in ('PAI','PND')
	AND ADD_TO_COLL = 1 AND SUCCESS_FLAG IS NULL AND D.TotalPaid < C.CumDueAmt THEN 1
	
	WHEN /*Direct Debit Loans that Succeeded but later reversed*/
	IS_EPDQ_ONLY IS NULL AND LOAN_STAT_ON_PAYMENT_DATE = 'Good Standing' and DD_OUTCOME not in ('PAI','PND')
	AND ADD_TO_COLL IS NULL AND SUCCESS_FLAG IS NULL and add_to_coll_date is not null AND D.TotalPaid < C.CumDueAmt 
	THEN 1
	
	WHEN /*Direct Debit Loans that failed both DebitCard and CreditCard*/
	IS_EPDQ_ONLY IS NULL and LOAN_STAT_ON_PAYMENT_DATE = 'Good Standing' AND DD_OUTCOME IS NULL
	AND SUCCESS_FLAG IS NULL AND D.TotalPaid < C.CumDueAmt THEN 1
	
	WHEN /*DD Bouncers*/
	IS_EPDQ_ONLY IS NULL AND DD_OUTCOME IS NULL AND SUCCESS_FLAG = 1
	AND TRANS_DESC = 'Collections Payment' and rem_from_coll = 1 AND D.TotalPaid < C.CumDueAmt
	THEN 1 
	
	WHEN /*EPDQ Bouncers*/
	IS_EPDQ_ONLY =1 AND DD_OUTCOME IS NULL AND SUCCESS_FLAG = 1
	AND TRANS_DESC = 'Collections Payment' and rem_from_coll = 1
	AND LOAN_STAT_ON_PAYMENT_DATE = 'Defaulted' AND D.TotalPaid < C.CumDueAmt
	THEN 1 
		
	END AS DefaultFlag

,CASE WHEN 
	/*EPDQ Only Loans in Good Standing on Due Date. 
	If failed then defaulted date = 1 day after CC date.*/
	LOAN_STAT_ON_PAYMENT_DATE = 'Good Standing' and IS_EPDQ_ONLY = 1 AND SUCCESS_FLAG IS NULL 
	AND CC_DATE IS NOT NULL AND D.TotalPaid < C.CumDueAmt
	THEN DATEADD(dd,1,CAST(CC_DATE AS DATE)) 
	
	WHEN 
	/*EPDQ Only Loans in Good Standing on Due Date. 
	If failed then defaulted date = 1 day after CC date.*/
	LOAN_STAT_ON_PAYMENT_DATE = 'Good Standing' and IS_EPDQ_ONLY = 1 AND SUCCESS_FLAG IS NULL 
	AND CC_DATE IS NULL AND D.TotalPaid < C.CumDueAmt
	THEN DATEADD(dd,1,(ADJUSTED_PAYMENT_DATE))
	
	WHEN /*Direct Debit Loans that failed DD*/
	IS_EPDQ_ONLY IS NULL AND LOAN_STAT_ON_PAYMENT_DATE = 'Good Standing' and DD_OUTCOME not in ('PAI','PND')
	AND ADD_TO_COLL = 1 AND SUCCESS_FLAG IS NULL and add_to_coll_date is not null AND D.TotalPaid < C.CumDueAmt
	THEN add_to_coll_date
	
	WHEN /*Direct Debit Loans that Succeeded but later reversed*/
	IS_EPDQ_ONLY IS NULL AND LOAN_STAT_ON_PAYMENT_DATE = 'Good Standing' and DD_OUTCOME not in ('PAI','PND')
	AND ADD_TO_COLL IS NULL AND SUCCESS_FLAG IS NULL and add_to_coll_date is not null AND D.TotalPaid < C.CumDueAmt
	THEN add_to_coll_date
	
	WHEN /*Direct Debit Loans that failed both DebitCard and CreditCard*/
	IS_EPDQ_ONLY IS NULL and LOAN_STAT_ON_PAYMENT_DATE = 'Good Standing' AND DD_OUTCOME IS NULL
	AND SUCCESS_FLAG IS NULL AND D.TotalPaid < C.CumDueAmt
	THEN DATEADD(dd,1,(ADJUSTED_PAYMENT_DATE))
	
	WHEN /*DD Bouncers. Failed DD and but cured on due date.*/
	IS_EPDQ_ONLY IS NULL AND DD_OUTCOME IS NULL AND SUCCESS_FLAG = 1
	AND TRANS_DESC = 'Collections Payment' and rem_from_coll = 1 AND D.TotalPaid < C.CumDueAmt
	THEN DATEADD(dd,1,CAST(CC_DATE AS DATE))
	
	WHEN /*EPDQ Bouncers. If already defaulted on payment date and CC cures the loan,
	it'll bounce back in the next day again.*/
	IS_EPDQ_ONLY =1 AND DD_OUTCOME IS NULL AND SUCCESS_FLAG = 1
	AND TRANS_DESC = 'Collections Payment' and rem_from_coll = 1
	AND LOAN_STAT_ON_PAYMENT_DATE = 'Defaulted' AND D.TotalPaid < C.CumDueAmt
	THEN DATEADD(dd,1,CAST(CC_DATE AS DATE))
	
	END AS DefaultedDate
	
, 
CASE WHEN PAYMENT_NUM = 1 THEN FP.LATEST_COLL_DATE ELSE 
B.LATEST_COLL_DATE END AS LATEST_COLL_DATE


INTO #MTLAMORT1 
FROM #MTLAMORT A
LEFT JOIN #LATESTCOLLDATE B	
	ON B.B_LOAN_KEY = A.LOAN_KEY
	AND B.B_PAYMENT_NUM = A.PAYMENT_NUM
LEFT JOIN #FP_PREARREARS_DATE FP	
	ON FP.B_LOAN_KEY = A.LOAN_KEY
	AND FP.B_PAYMENT_NUM = A.PAYMENT_NUM
	
	
LEFT JOIN #CUMDUEAMT C
	ON C.C_LOAN_KEY = A.LOAN_KEY
	AND C.C_PAYMENT_NUM = A.PAYMENT_NUM
LEFT JOIN #CUMPAID D
	ON D.D_LOAN_KEY = A.LOAN_KEY
	AND D.D_payment_num = A.payment_num
	
ORDER BY LOAN_KEY, PAYMENT_NUM



DROP TABLE #MTLAMORT2
/*PREARREARS*/
SELECT A.*

/*Payment Due Flags*/
,CASE 
	WHEN (A.STATUSX_DATE IS NULL OR CAST(A.STATUSX_DATE AS DATE)>A.ADJUSTED_PAYMENT_DATE)
	AND A.LOAN_STAT_ON_PAYMENT_DATE = 'Good Standing' THEN 1 
	
	WHEN A.LOAN_STAT_ON_PAYMENT_DATE = 'Defaulted' 
	AND (A.DD_OUTCOME IS NULL OR A.DD_OUTCOME NOT IN ('PAI','PND')) 
	AND ((A.SUCCESS_FLAG != 1 OR A.SUCCESS_FLAG IS NULL) OR (A.SUCCESS_FLAG = 1 AND A.REM_FROM_COLL != 1))
	AND (B.DefaultFlag != 1 OR B.DefaultFlag IS NULL) 
	AND (A.LATEST_COLL_DATE IS NOT NULL)  THEN 1
	WHEN A.STATUSX_DATE IS NULL AND A.LOAN_STAT_ON_PAYMENT_DATE = 'Not Due' THEN 1
	
	WHEN A.LOAN_STAT_ON_PAYMENT_DATE = 'Early Settled' and A.EARLY_SETTLE_FLAG = 1 then 1
	
	END AS DueFlag

,CASE 
	WHEN A.LOAN_STAT_ON_PAYMENT_DATE = 'Defaulted' 
	AND (A.DD_OUTCOME IS NULL OR A.DD_OUTCOME NOT IN ('PAI','PND')) 
	AND ((A.SUCCESS_FLAG != 1 OR A.SUCCESS_FLAG IS NULL) OR (A.SUCCESS_FLAG = 1 AND A.REM_FROM_COLL != 1))
	AND (B.DefaultFlag != 1 OR B.DefaultFlag IS NULL) 
	AND A.LATEST_COLL_DATE IS NOT NULL THEN 
	1 
	
	/*DD Cancels and is in arrears*/
	WHEN A.DD_OUTCOME = '1' AND A.TotalPaid < A.CumDueAmt THEN 1
	
	ELSE A.DefaultFlag  END AS DefaultedFlag

	
,CASE 
	WHEN A.LOAN_STAT_ON_PAYMENT_DATE = 'Defaulted' AND (A.DD_OUTCOME IS NULL OR A.DD_OUTCOME NOT IN ('PAI','PND')) AND 
	((A.SUCCESS_FLAG != 1 OR A.SUCCESS_FLAG IS NULL) OR (A.SUCCESS_FLAG = 1 AND A.REM_FROM_COLL != 1)) AND 
	(B.DefaultFlag != 1 OR B.DefaultFlag IS NULL) AND A.LATEST_COLL_DATE IS NOT NULL 
		THEN A.LATEST_COLL_DATE 
	
	
	
	ELSE A.DefaultedDate
	END AS DefaultDate
	
INTO #MTLAMORT2
FROM #MTLAMORT1 A 
LEFT JOIN #MTLAMORT1 B
	ON B.LOAN_KEY = A.LOAN_KEY
	AND A.PAYMENT_NUM = B.PAYMENT_NUM +1
order by A.payment_num

ALTER TABLE #MTLAMORT2
DROP COLUMN DefaultFlag, DefaultedDate, Latest_Coll_Date

DROP TABLE ANALYTICS..SHENG_MTLAMORT
SELECT * INTO ANALYTICS..SHENG_MTLAMORT
FROM #MTLAMORT2
ORDER BY LOAN_KEY, PAYMENT_NUM

