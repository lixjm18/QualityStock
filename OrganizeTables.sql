select A.TradingDay
,C.InnerCode
,B.EndDate
,B.NPParentCompanyOwnersTTM
,B.TotalOperatingRevenueTTM
,B.OperatingRevenueTTM
,B.NetOperateCashFlowTTM
,B.TotalOperatingCostTTM
,B.OperatingPayoutTTM
,B.GrossProfitTTM
,B.InterestBearDebt
,B.NIFromOperatingTTM
,B.TotalProfitTTM
,B.NonoperatingNetIncomeTTM
,B.NetProfitTTM
,B.NPDeductNonRecurringPL
,B_LY2.NPDeductNonRecurringPL as NPDeductNonRecurringPL_LY
,B_LA.NPDeductNonRecurringPL as NPDeductNonRecurringPL_LA
,D.SEWithoutMI
,D.CashEquivalents
,D.TotalCurrentLiability
,D.TotalLiability
,D.TotalAssets
,D.RetainedProfit
,ISNULL(E.DivRatio,0) as DivRatio
,F.Rating_Med
,F.Rating_Min
,B_MRA.NPParentCompanyOwnersTTM as NPParY
,G.TotalCashDiviLTM
,D_LY.SEWithoutMI as SEWithoutMI_LY
,D_LY.TotalAssets as TotalAssets_LY
,B_LY.InterestBearDebt as InterestBearDebt_LY
,H.MoneyToAccount as PlaceMoney
,I.MoneyToAccount as IssueMoney
into ShengYunDB..Q_FundamentalRawMonthly
from ShengYunDB..V_MonthEnd A
left join ShengYunDB..V_LC_FSDerivedData B
on B.EndDate=(select MAX(EndDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B.CompanyCode and InfoPublDate<=A.TradingDay and EndDate>=DATEADD(MONTH,-7,A.TradingDay))
and B.InfoPublDate=(Select MAX(InfoPublDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B.CompanyCode and InfoPublDate<=A.TradingDay and EndDate=B.EndDate)
and B.IfAdjusted=(select MIN(IfAdjusted) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B.CompanyCode and EndDate=B.EndDate and InfoPublDate=B.InfoPublDate)
inner join ShengYunDB..V_A_Stock_Universe C
on B.CompanyCode=C.CompanyCode
left join ShengYunDB..V_LC_BalanceSheetAll D
on D.CompanyCode=B.CompanyCode
and D.EndDate=B.EndDate
and D.InfoPublDate=(select MAX(InfoPublDate) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D.CompanyCode and EndDate=D.EndDate and InfoPublDate<=A.TradingDay)
and D.IfAdjusted=(select min(IfAdjusted) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D.CompanyCode and EndDate=D.EndDate and InfoPublDate=D.InfoPublDate)
left join ShengYunDB..Fundamental_CashDividend E
on C.InnerCode=E.InnerCode 
and E.EndDate=(select MAX(EndDate) from ShengYunDB..Fundamental_CashDividend where InnerCode=E.InnerCode and ExDiviDate between DATEADD(MONTH,-16,A.TradingDay) and A.TradingDay)
left join ShengYunDB..Q_CreditRatingMonthly F
on F.TradingDay=A.TradingDay
and F.InnerCode=C.InnerCode
left join ShengYunDB..V_EndDate_RK T0
on T0.EndDate=B.EndDate
left join ShengYunDB..V_EndDate_RK T_LY
on T_LY.RK=T0.RK-4
left join ShengYunDB..V_EndDate_RK T_LA
on T_LA.RK=T0.RK-MONTH(B.EndDate)/3
left join ShengYunDB..V_EndDate_RK T_MRA
on T_MRA.RK=T0.RK-case when MONTH(B.EndDate)/3=4 then 0 else MONTH(B.EndDate)/3 end
left join ShengYunDB..V_LC_BalanceSheetAll D_LY
on D_LY.CompanyCode=B.CompanyCode
and D_LY.EndDate=T_LY.EndDate
and D_LY.InfoPublDate=(select MAX(InfoPublDate) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LY.CompanyCode and EndDate=D_LY.EndDate and InfoPublDate<=A.TradingDay)
and D_LY.IfAdjusted=(select min(IfAdjusted) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LY.CompanyCode and EndDate=D_LY.EndDate and InfoPublDate=D_LY.InfoPublDate)

left join ShengYunDB..V_LC_FSDerivedData B_MRA
on B_MRA.CompanyCode=B.CompanyCode
and B_MRA.EndDate=T_MRA.EndDate
and B_MRA.InfoPublDate=(Select MAX(InfoPublDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_MRA.CompanyCode and InfoPublDate<=A.TradingDay and EndDate=B_MRA.EndDate)
and B_MRA.IfAdjusted=(select MIN(IfAdjusted) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_MRA.CompanyCode and EndDate=B_MRA.EndDate and InfoPublDate=B_MRA.InfoPublDate)

left join ShengYunDB..V_Q_CashDividend G
on G.InnerCode=C.InnerCode
and G.EndDate=B_MRA.EndDate
left join ShengYunDB..V_LC_FSDerivedData B_LY
on B_LY.CompanyCode=B.CompanyCode
and B_LY.EndDate=T_LY.EndDate
and B_LY.InfoPublDate=(Select MAX(InfoPublDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LY.CompanyCode and InfoPublDate<=A.TradingDay and EndDate=B_LY.EndDate)
and B_LY.IfAdjusted=(select MIN(IfAdjusted) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LY.CompanyCode and EndDate=B_LY.EndDate and InfoPublDate=B_LY.InfoPublDate)
left join ShengYunDB..V_LC_FSDerivedData B_LY2
on B_LY2.CompanyCode=B.CompanyCode
and B_LY2.EndDate=T_LY.EndDate
and B_LY2.IfAdjusted=2
and B_LY2.InfoPublDate=(Select MAX(InfoPublDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LY.CompanyCode and InfoPublDate<=A.TradingDay and EndDate=B_LY.EndDate and IfAdjusted=2)
left join ShengYunDB..V_LC_FSDerivedData B_LA
on B_LA.CompanyCode=B.CompanyCode
and B_LA.EndDate=T_LA.EndDate
and B_LA.InfoPublDate=(Select MAX(InfoPublDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LA.CompanyCode and InfoPublDate<=A.TradingDay and EndDate=B_LA.EndDate)
and B_LA.IfAdjusted=(select MIN(IfAdjusted) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LA.CompanyCode and EndDate=B_LA.EndDate and InfoPublDate=B_LA.InfoPublDate)
left join ShengYunDB..V_Q_LC_ASharePlacement H
on H.InnerCode=C.InnerCode
and H.TradingDay=A.TradingDay
left join ShengYunDB..V_Q_LC_AShareSeasonedNewIssue I
on I.InnerCode=C.InnerCode
and I.TradingDay=A.TradingDay
where A.TradingDay<=GETDATE()

--drop table Q_FundamentalRawMonthly
select distinct TradingDay,InnerCode
from ShengYunDB..Q_FundamentalRawMonthly
order by TradingDay,InnerCode

create index I_Q_FundamentalRawMonthly on ShengYunDB..Q_FundamentalRawMonthly(TradingDay,InnerCode)

--drop view V_Q_NonGrowth
create view V_Q_NonGrowth as
select A.TradingDay
,A.InnerCode
,(D.ClosePrice*D.TotalShares) as MKTCap
,A.TotalAssets
,isnull(A.TotalOperatingRevenueTTM,A.OperatingRevenueTTM) as Revenue_LTM
,A.NPParentCompanyOwnersTTM/(D.ClosePrice*D.TotalShares) as E2P_LTM
,(A.SEWithoutMI+ISNULL(B.UnreportPlace,0)+ISNULL(C.UnreportIssue,0))/(D.ClosePrice*D.TotalShares) as B2P
,A.DivRatio
,isnull(A.TotalOperatingRevenueTTM,A.OperatingRevenueTTM)/(D.ClosePrice*D.TotalShares) as S2P_LTM
,case when A.TotalCurrentLiability<0 then 99 else A.CashEquivalents/nullif(A.TotalCurrentLiability,0) end as Cash2ShortDebt
,case when A.TotalLiability<0 then 99 else A.CashEquivalents/nullif(A.TotalLiability,0) end as Cash2Debt
,A.CashEquivalents/(D.ClosePrice*D.TotalShares) as Cash2Cap
,case when A.TotalLiability<0 then 99 else A.NetOperateCashFlowTTM/nullif(A.TotalLiability,0) end as CashFlow2Debt
,case when A.TotalLiability<0 then 99 else A.TotalLiability/nullif(A.SEWithoutMI,0) end as Debt2Book
,case when A.TotalLiability<0 then 99 else A.TotalLiability/(D.ClosePrice*D.TotalShares) end as Debt2Cap
,case when A.TotalCurrentLiability<0 then 99 else A.TotalCurrentLiability/nullif(A.SEWithoutMI,0) end as ShortDebt2Book
,A.Rating_Med
,A.Rating_Min
,case when A.SEWithoutMI_LY+A.SEWithoutMI<0 then -99 else 2*A.NPParentCompanyOwnersTTM/(A.SEWithoutMI_LY+A.SEWithoutMI) end as ROE_LTM
,2*A.NPParentCompanyOwnersTTM/(A.TotalAssets_LY+A.TotalAssets) as ROA_LTM
,2*NetOperateCashFlowTTM/(A.TotalAssets_LY+A.TotalAssets) as CashFlow2Assets_LTM
,(isnull(A.TotalOperatingRevenueTTM,A.OperatingRevenueTTM)-isnull(A.TotalOperatingCostTTM,A.OperatingPayoutTTM))/(A.TotalAssets_LY+A.TotalAssets) as Grossrofit2Assets
,case when A.NPParY<0 then 99 else A.TotalCashDiviLTM/A.NPParY end as PayoutRatio
,case when A.InterestBearDebt<0 or A.InterestBearDebt_LY<0 then 99 else (A.InterestBearDebt-A.InterestBearDebt_LY)/(D.ClosePrice*D.TotalShares) end as DebtIssue2Cap
,(isnull(A.PlaceMoney,0)+isnull(A.IssueMoney,0))/(D.ClosePrice*D.TotalShares) as EquityIssue2Cap
,case when A.SEWithoutMI<0 then -99 else A.RetainedProfit/nullif(A.SEWithoutMI,0) end as Retained2Book
,case when TotalProfitTTM<0 then -99 else A.NIFromOperatingTTM/nullif(A.TotalProfitTTM,0) end as Operating2Total
,case when TotalProfitTTM<0 then -99 else A.NonoperatingNetIncomeTTM/nullif(A.TotalProfitTTM,0) end as NonOperating2Total
,case when TotalProfitTTM<0 then -99 else (A.TotalProfitTTM-A.NetProfitTTM)/nullif(A.TotalProfitTTM,0) end as Tax2Total
,case when NPParentCompanyOwnersTTM<0 then -99 else (A.NPDeductNonRecurringPL+A.NPDeductNonRecurringPL_LA-A.NPDeductNonRecurringPL_LY)/nullif(A.NPParentCompanyOwnersTTM,0) end as NPDeduct2Total
from ShengYunDB..Q_FundamentalRawMonthly A
left join ShengYunDB..V_Q_UnreportPlace B
on A.TradingDay=B.TradingDay
and A.InnerCode=B.InnerCode
left join ShengYunDB..V_Q_UnreportIssue C
on A.TradingDay=C.TradingDay
and A.InnerCode=C.InnerCode
left join ShengYunDB..StockDailyTrading D
on A.TradingDay=D.TradingDay
and A.InnerCode=D.InnerCode


select *
from V_Q_NonGrowth
order by InnerCode,TradingDay

--drop view V_Q_GrowthRaw
create view V_Q_GrowthRaw as
select A.TradingDay
,C.InnerCode
,isnull(B_LA.TotalOperatingRevenueTTM,B_LA.OperatingRevenueTTM) as RevY0
,isnull(B_L2A.TotalOperatingRevenueTTM,B_L2A.OperatingRevenueTTM) as RevYL1
,isnull(B_L3A.TotalOperatingRevenueTTM,B_L3A.OperatingRevenueTTM) as RevYL2
,isnull(B_L4A.TotalOperatingRevenueTTM,B_L4A.OperatingRevenueTTM) as RevYL3

,B_LA.NPParentCompanyOwnersTTM as NPY0
,B_L2A.NPParentCompanyOwnersTTM as NPYL1
,B_L3A.NPParentCompanyOwnersTTM as NPYL2
,B_L4A.NPParentCompanyOwnersTTM as NPYL3

,isnull(B.TotalOperatingRevenueTTM,B.OperatingRevenueTTM) as Rev0
,isnull(B_LQ1.TotalOperatingRevenueTTM,B_LQ1.OperatingRevenueTTM) as RevLQ1
,isnull(B_LQ2.TotalOperatingRevenueTTM,B_LQ2.OperatingRevenueTTM) as RevLQ2
,isnull(B_LQ3.TotalOperatingRevenueTTM,B_LQ3.OperatingRevenueTTM) as RevLQ3
,isnull(B_LQ4.TotalOperatingRevenueTTM,B_LQ4.OperatingRevenueTTM) as RevLQ4
,isnull(B_LQ5.TotalOperatingRevenueTTM,B_LQ5.OperatingRevenueTTM) as RevLQ5
,isnull(B_LQ6.TotalOperatingRevenueTTM,B_LQ6.OperatingRevenueTTM) as RevLQ6
,isnull(B_LQ7.TotalOperatingRevenueTTM,B_LQ7.OperatingRevenueTTM) as RevLQ7
,isnull(B_LQ8.TotalOperatingRevenueTTM,B_LQ8.OperatingRevenueTTM) as RevLQ8
,isnull(B_LQ9.TotalOperatingRevenueTTM,B_LQ9.OperatingRevenueTTM) as RevLQ9
,isnull(B_LQ10.TotalOperatingRevenueTTM,B_LQ10.OperatingRevenueTTM) as RevLQ10
,isnull(B_LQ11.TotalOperatingRevenueTTM,B_LQ11.OperatingRevenueTTM) as RevLQ11

,B.NPParentCompanyOwnersTTM as NP0
,B_LQ1.NPParentCompanyOwnersTTM as NPLQ1
,B_LQ2.NPParentCompanyOwnersTTM as NPLQ2
,B_LQ3.NPParentCompanyOwnersTTM as NPLQ3
,B_LQ4.NPParentCompanyOwnersTTM as NPLQ4
,B_LQ5.NPParentCompanyOwnersTTM as NPLQ5
,B_LQ6.NPParentCompanyOwnersTTM as NPLQ6
,B_LQ7.NPParentCompanyOwnersTTM as NPLQ7
,B_LQ8.NPParentCompanyOwnersTTM as NPLQ8
,B_LQ9.NPParentCompanyOwnersTTM as NPLQ9
,B_LQ10.NPParentCompanyOwnersTTM as NPLQ10
,B_LQ11.NPParentCompanyOwnersTTM as NPLQ11

,D.SEWithoutMI as SE0
,D_LQ1.SEWithoutMI as SELQ1
,D_LQ2.SEWithoutMI as SELQ2
,D_LQ3.SEWithoutMI as SELQ3
,D_LQ4.SEWithoutMI as SELQ4
,D_LQ5.SEWithoutMI as SELQ5
,D_LQ6.SEWithoutMI as SELQ6
,D_LQ7.SEWithoutMI as SELQ7
,D_LQ8.SEWithoutMI as SELQ8
,D_LQ9.SEWithoutMI as SELQ9
,D_LQ10.SEWithoutMI as SELQ10
,D_LQ11.SEWithoutMI as SELQ11

,D.TotalAssets as TA0
,D_LQ1.TotalAssets as TALQ1
,D_LQ2.TotalAssets as TALQ2
,D_LQ3.TotalAssets as TALQ3
,D_LQ4.TotalAssets as TALQ4
,D_LQ5.TotalAssets as TALQ5
,D_LQ6.TotalAssets as TALQ6
,D_LQ7.TotalAssets as TALQ7
,D_LQ8.TotalAssets as TALQ8
,D_LQ9.TotalAssets as TALQ9
,D_LQ10.TotalAssets as TALQ10
,D_LQ11.TotalAssets as TALQ11

from ShengYunDB..V_MonthEnd A
left join ShengYunDB..V_LC_FSDerivedData B
on B.EndDate=(select MAX(EndDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B.CompanyCode and InfoPublDate<=A.TradingDay and EndDate>=DATEADD(MONTH,-7,A.TradingDay))
and B.InfoPublDate=(Select MAX(InfoPublDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B.CompanyCode and InfoPublDate<=A.TradingDay and EndDate=B.EndDate)
and B.IfAdjusted=(select MIN(IfAdjusted) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B.CompanyCode and EndDate=B.EndDate and InfoPublDate=B.InfoPublDate)
inner join ShengYunDB..V_A_Stock_Universe C
on B.CompanyCode=C.CompanyCode
left join ShengYunDB..V_EndDate_RK T0
on T0.EndDate=B.EndDate
left join ShengYunDB..V_EndDate_RK T_LA
on T_LA.RK=T0.RK-MONTH(B.EndDate)/3
left join ShengYunDB..V_EndDate_RK T_L2A
on T_L2A.RK=T_LA.RK-4
left join ShengYunDB..V_EndDate_RK T_L3A
on T_L3A.RK=T_LA.RK-8
left join ShengYunDB..V_EndDate_RK T_L4A
on T_L4A.RK=T_LA.RK-12
left join ShengYunDB..V_LC_FSDerivedData B_LA
on B_LA.CompanyCode=B.CompanyCode
and B_LA.EndDate=T_LA.EndDate
and B_LA.InfoPublDate=(Select MAX(InfoPublDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LA.CompanyCode and InfoPublDate<=A.TradingDay and EndDate=B_LA.EndDate)
and B_LA.IfAdjusted=(select MIN(IfAdjusted) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LA.CompanyCode and EndDate=B_LA.EndDate and InfoPublDate=B_LA.InfoPublDate)
left join ShengYunDB..V_LC_FSDerivedData B_L2A
on B_L2A.CompanyCode=B.CompanyCode
and B_L2A.EndDate=T_L2A.EndDate
and B_L2A.InfoPublDate=(Select MAX(InfoPublDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_L2A.CompanyCode and InfoPublDate<=A.TradingDay and EndDate=B_L2A.EndDate)
and B_L2A.IfAdjusted=(select MIN(IfAdjusted) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_L2A.CompanyCode and EndDate=B_L2A.EndDate and InfoPublDate=B_L2A.InfoPublDate)
left join ShengYunDB..V_LC_FSDerivedData B_L3A
on B_L3A.CompanyCode=B.CompanyCode
and B_L3A.EndDate=T_L3A.EndDate
and B_L3A.InfoPublDate=(Select MAX(InfoPublDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_L3A.CompanyCode and InfoPublDate<=A.TradingDay and EndDate=B_L3A.EndDate)
and B_L3A.IfAdjusted=(select MIN(IfAdjusted) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_L3A.CompanyCode and EndDate=B_L3A.EndDate and InfoPublDate=B_L3A.InfoPublDate)
left join ShengYunDB..V_LC_FSDerivedData B_L4A
on B_L4A.CompanyCode=B.CompanyCode
and B_L4A.EndDate=T_L4A.EndDate
and B_L4A.InfoPublDate=(Select MAX(InfoPublDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_L4A.CompanyCode and InfoPublDate<=A.TradingDay and EndDate=B_L4A.EndDate)
and B_L4A.IfAdjusted=(select MIN(IfAdjusted) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_L4A.CompanyCode and EndDate=B_L4A.EndDate and InfoPublDate=B_L4A.InfoPublDate)
left join ShengYunDB..V_EndDate_RK T_LQ1
on T_LQ1.RK=T0.RK-1
left join ShengYunDB..V_EndDate_RK T_LQ2
on T_LQ2.RK=T0.RK-2
left join ShengYunDB..V_EndDate_RK T_LQ3
on T_LQ3.RK=T0.RK-3
left join ShengYunDB..V_EndDate_RK T_LQ4
on T_LQ4.RK=T0.RK-4
left join ShengYunDB..V_EndDate_RK T_LQ5
on T_LQ5.RK=T0.RK-5
left join ShengYunDB..V_EndDate_RK T_LQ6
on T_LQ6.RK=T0.RK-6
left join ShengYunDB..V_EndDate_RK T_LQ7
on T_LQ7.RK=T0.RK-7
left join ShengYunDB..V_EndDate_RK T_LQ8
on T_LQ8.RK=T0.RK-8
left join ShengYunDB..V_EndDate_RK T_LQ9
on T_LQ9.RK=T0.RK-9
left join ShengYunDB..V_EndDate_RK T_LQ10
on T_LQ10.RK=T0.RK-10
left join ShengYunDB..V_EndDate_RK T_LQ11
on T_LQ11.RK=T0.RK-11
left join ShengYunDB..V_LC_FSDerivedData B_LQ1
on B_LQ1.CompanyCode=B.CompanyCode
and B_LQ1.EndDate=T_LQ1.EndDate
and B_LQ1.InfoPublDate=(Select MAX(InfoPublDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LQ1.CompanyCode and InfoPublDate<=A.TradingDay and EndDate=B_LQ1.EndDate)
and B_LQ1.IfAdjusted=(select MIN(IfAdjusted) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LQ1.CompanyCode and EndDate=B_LQ1.EndDate and InfoPublDate=B_LQ1.InfoPublDate)
left join ShengYunDB..V_LC_FSDerivedData B_LQ2
on B_LQ2.CompanyCode=B.CompanyCode
and B_LQ2.EndDate=T_LQ2.EndDate
and B_LQ2.InfoPublDate=(Select MAX(InfoPublDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LQ2.CompanyCode and InfoPublDate<=A.TradingDay and EndDate=B_LQ2.EndDate)
and B_LQ2.IfAdjusted=(select MIN(IfAdjusted) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LQ2.CompanyCode and EndDate=B_LQ2.EndDate and InfoPublDate=B_LQ2.InfoPublDate)
left join ShengYunDB..V_LC_FSDerivedData B_LQ3
on B_LQ3.CompanyCode=B.CompanyCode
and B_LQ3.EndDate=T_LQ3.EndDate
and B_LQ3.InfoPublDate=(Select MAX(InfoPublDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LQ3.CompanyCode and InfoPublDate<=A.TradingDay and EndDate=B_LQ3.EndDate)
and B_LQ3.IfAdjusted=(select MIN(IfAdjusted) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LQ3.CompanyCode and EndDate=B_LQ3.EndDate and InfoPublDate=B_LQ3.InfoPublDate)
left join ShengYunDB..V_LC_FSDerivedData B_LQ4
on B_LQ4.CompanyCode=B.CompanyCode
and B_LQ4.EndDate=T_LQ4.EndDate
and B_LQ4.InfoPublDate=(Select MAX(InfoPublDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LQ4.CompanyCode and InfoPublDate<=A.TradingDay and EndDate=B_LQ4.EndDate)
and B_LQ4.IfAdjusted=(select MIN(IfAdjusted) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LQ4.CompanyCode and EndDate=B_LQ4.EndDate and InfoPublDate=B_LQ4.InfoPublDate)
left join ShengYunDB..V_LC_FSDerivedData B_LQ5
on B_LQ5.CompanyCode=B.CompanyCode
and B_LQ5.EndDate=T_LQ5.EndDate
and B_LQ5.InfoPublDate=(Select MAX(InfoPublDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LQ5.CompanyCode and InfoPublDate<=A.TradingDay and EndDate=B_LQ5.EndDate)
and B_LQ5.IfAdjusted=(select MIN(IfAdjusted) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LQ5.CompanyCode and EndDate=B_LQ5.EndDate and InfoPublDate=B_LQ5.InfoPublDate)
left join ShengYunDB..V_LC_FSDerivedData B_LQ6
on B_LQ6.CompanyCode=B.CompanyCode
and B_LQ6.EndDate=T_LQ6.EndDate
and B_LQ6.InfoPublDate=(Select MAX(InfoPublDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LQ6.CompanyCode and InfoPublDate<=A.TradingDay and EndDate=B_LQ6.EndDate)
and B_LQ6.IfAdjusted=(select MIN(IfAdjusted) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LQ6.CompanyCode and EndDate=B_LQ6.EndDate and InfoPublDate=B_LQ6.InfoPublDate)
left join ShengYunDB..V_LC_FSDerivedData B_LQ7
on B_LQ7.CompanyCode=B.CompanyCode
and B_LQ7.EndDate=T_LQ7.EndDate
and B_LQ7.InfoPublDate=(Select MAX(InfoPublDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LQ7.CompanyCode and InfoPublDate<=A.TradingDay and EndDate=B_LQ7.EndDate)
and B_LQ7.IfAdjusted=(select MIN(IfAdjusted) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LQ7.CompanyCode and EndDate=B_LQ7.EndDate and InfoPublDate=B_LQ7.InfoPublDate)
left join ShengYunDB..V_LC_FSDerivedData B_LQ8
on B_LQ8.CompanyCode=B.CompanyCode
and B_LQ8.EndDate=T_LQ8.EndDate
and B_LQ8.InfoPublDate=(Select MAX(InfoPublDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LQ8.CompanyCode and InfoPublDate<=A.TradingDay and EndDate=B_LQ8.EndDate)
and B_LQ8.IfAdjusted=(select MIN(IfAdjusted) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LQ8.CompanyCode and EndDate=B_LQ8.EndDate and InfoPublDate=B_LQ8.InfoPublDate)
left join ShengYunDB..V_LC_FSDerivedData B_LQ9
on B_LQ9.CompanyCode=B.CompanyCode
and B_LQ9.EndDate=T_LQ9.EndDate
and B_LQ9.InfoPublDate=(Select MAX(InfoPublDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LQ9.CompanyCode and InfoPublDate<=A.TradingDay and EndDate=B_LQ9.EndDate)
and B_LQ9.IfAdjusted=(select MIN(IfAdjusted) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LQ9.CompanyCode and EndDate=B_LQ9.EndDate and InfoPublDate=B_LQ9.InfoPublDate)
left join ShengYunDB..V_LC_FSDerivedData B_LQ10
on B_LQ10.CompanyCode=B.CompanyCode
and B_LQ10.EndDate=T_LQ10.EndDate
and B_LQ10.InfoPublDate=(Select MAX(InfoPublDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LQ10.CompanyCode and InfoPublDate<=A.TradingDay and EndDate=B_LQ10.EndDate)
and B_LQ10.IfAdjusted=(select MIN(IfAdjusted) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LQ10.CompanyCode and EndDate=B_LQ10.EndDate and InfoPublDate=B_LQ10.InfoPublDate)
left join ShengYunDB..V_LC_FSDerivedData B_LQ11
on B_LQ11.CompanyCode=B.CompanyCode
and B_LQ11.EndDate=T_LQ11.EndDate
and B_LQ11.InfoPublDate=(Select MAX(InfoPublDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LQ11.CompanyCode and InfoPublDate<=A.TradingDay and EndDate=B_LQ11.EndDate)
and B_LQ11.IfAdjusted=(select MIN(IfAdjusted) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LQ11.CompanyCode and EndDate=B_LQ11.EndDate and InfoPublDate=B_LQ11.InfoPublDate)
left join ShengYunDB..V_LC_BalanceSheetAll D
on D.CompanyCode=B.CompanyCode
and D.EndDate=B.EndDate
and D.InfoPublDate=(select MAX(InfoPublDate) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D.CompanyCode and EndDate=D.EndDate and InfoPublDate<=A.TradingDay)
and D.IfAdjusted=(select min(IfAdjusted) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D.CompanyCode and EndDate=D.EndDate and InfoPublDate=D.InfoPublDate)
left join ShengYunDB..V_LC_BalanceSheetAll D_LQ1
on D_LQ1.CompanyCode=D.CompanyCode
and D_LQ1.EndDate=T_LQ1.EndDate
and D_LQ1.InfoPublDate=(select MAX(InfoPublDate) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LQ1.CompanyCode and EndDate=D_LQ1.EndDate and InfoPublDate<=A.TradingDay)
and D_LQ1.IfAdjusted=(select min(IfAdjusted) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LQ1.CompanyCode and EndDate=D_LQ1.EndDate and InfoPublDate=D_LQ1.InfoPublDate)
left join ShengYunDB..V_LC_BalanceSheetAll D_LQ2
on D_LQ2.CompanyCode=D.CompanyCode
and D_LQ2.EndDate=T_LQ2.EndDate
and D_LQ2.InfoPublDate=(select MAX(InfoPublDate) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LQ2.CompanyCode and EndDate=D_LQ2.EndDate and InfoPublDate<=A.TradingDay)
and D_LQ2.IfAdjusted=(select min(IfAdjusted) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LQ2.CompanyCode and EndDate=D_LQ2.EndDate and InfoPublDate=D_LQ2.InfoPublDate)
left join ShengYunDB..V_LC_BalanceSheetAll D_LQ3
on D_LQ3.CompanyCode=D.CompanyCode
and D_LQ3.EndDate=T_LQ3.EndDate
and D_LQ3.InfoPublDate=(select MAX(InfoPublDate) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LQ3.CompanyCode and EndDate=D_LQ3.EndDate and InfoPublDate<=A.TradingDay)
and D_LQ3.IfAdjusted=(select min(IfAdjusted) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LQ3.CompanyCode and EndDate=D_LQ3.EndDate and InfoPublDate=D_LQ3.InfoPublDate)
left join ShengYunDB..V_LC_BalanceSheetAll D_LQ4
on D_LQ4.CompanyCode=D.CompanyCode
and D_LQ4.EndDate=T_LQ4.EndDate
and D_LQ4.InfoPublDate=(select MAX(InfoPublDate) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LQ4.CompanyCode and EndDate=D_LQ4.EndDate and InfoPublDate<=A.TradingDay)
and D_LQ4.IfAdjusted=(select min(IfAdjusted) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LQ4.CompanyCode and EndDate=D_LQ4.EndDate and InfoPublDate=D_LQ4.InfoPublDate)
left join ShengYunDB..V_LC_BalanceSheetAll D_LQ5
on D_LQ5.CompanyCode=D.CompanyCode
and D_LQ5.EndDate=T_LQ5.EndDate
and D_LQ5.InfoPublDate=(select MAX(InfoPublDate) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LQ5.CompanyCode and EndDate=D_LQ5.EndDate and InfoPublDate<=A.TradingDay)
and D_LQ5.IfAdjusted=(select min(IfAdjusted) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LQ5.CompanyCode and EndDate=D_LQ5.EndDate and InfoPublDate=D_LQ5.InfoPublDate)
left join ShengYunDB..V_LC_BalanceSheetAll D_LQ6
on D_LQ6.CompanyCode=D.CompanyCode
and D_LQ6.EndDate=T_LQ6.EndDate
and D_LQ6.InfoPublDate=(select MAX(InfoPublDate) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LQ6.CompanyCode and EndDate=D_LQ6.EndDate and InfoPublDate<=A.TradingDay)
and D_LQ6.IfAdjusted=(select min(IfAdjusted) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LQ6.CompanyCode and EndDate=D_LQ6.EndDate and InfoPublDate=D_LQ6.InfoPublDate)
left join ShengYunDB..V_LC_BalanceSheetAll D_LQ7
on D_LQ7.CompanyCode=D.CompanyCode
and D_LQ7.EndDate=T_LQ7.EndDate
and D_LQ7.InfoPublDate=(select MAX(InfoPublDate) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LQ7.CompanyCode and EndDate=D_LQ7.EndDate and InfoPublDate<=A.TradingDay)
and D_LQ7.IfAdjusted=(select min(IfAdjusted) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LQ7.CompanyCode and EndDate=D_LQ7.EndDate and InfoPublDate=D_LQ7.InfoPublDate)
left join ShengYunDB..V_LC_BalanceSheetAll D_LQ8
on D_LQ8.CompanyCode=D.CompanyCode
and D_LQ8.EndDate=T_LQ8.EndDate
and D_LQ8.InfoPublDate=(select MAX(InfoPublDate) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LQ8.CompanyCode and EndDate=D_LQ8.EndDate and InfoPublDate<=A.TradingDay)
and D_LQ8.IfAdjusted=(select min(IfAdjusted) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LQ8.CompanyCode and EndDate=D_LQ8.EndDate and InfoPublDate=D_LQ8.InfoPublDate)
left join ShengYunDB..V_LC_BalanceSheetAll D_LQ9
on D_LQ9.CompanyCode=D.CompanyCode
and D_LQ9.EndDate=T_LQ9.EndDate
and D_LQ9.InfoPublDate=(select MAX(InfoPublDate) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LQ9.CompanyCode and EndDate=D_LQ9.EndDate and InfoPublDate<=A.TradingDay)
and D_LQ9.IfAdjusted=(select min(IfAdjusted) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LQ9.CompanyCode and EndDate=D_LQ9.EndDate and InfoPublDate=D_LQ9.InfoPublDate)
left join ShengYunDB..V_LC_BalanceSheetAll D_LQ10
on D_LQ10.CompanyCode=D.CompanyCode
and D_LQ10.EndDate=T_LQ10.EndDate
and D_LQ10.InfoPublDate=(select MAX(InfoPublDate) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LQ10.CompanyCode and EndDate=D_LQ10.EndDate and InfoPublDate<=A.TradingDay)
and D_LQ10.IfAdjusted=(select min(IfAdjusted) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LQ10.CompanyCode and EndDate=D_LQ10.EndDate and InfoPublDate=D_LQ10.InfoPublDate)
left join ShengYunDB..V_LC_BalanceSheetAll D_LQ11
on D_LQ11.CompanyCode=D.CompanyCode
and D_LQ11.EndDate=T_LQ11.EndDate
and D_LQ11.InfoPublDate=(select MAX(InfoPublDate) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LQ11.CompanyCode and EndDate=D_LQ11.EndDate and InfoPublDate<=A.TradingDay)
and D_LQ11.IfAdjusted=(select min(IfAdjusted) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LQ11.CompanyCode and EndDate=D_LQ11.EndDate and InfoPublDate=D_LQ11.InfoPublDate)
where A.TradingDay<=GETDATE()

go


delete 
from Q_GrowthFactors

ALTER TABLE Q_GrowthFactors
ADD ROE_M3 Float,ROA_M3 Float

select *
from Q_GrowthFactors
order by InnerCode,TradingDay

Create table ShengYunDB..Q_M3(TradingDay DateTime,InnerCode Int,E2P_M3 float, B2P_M3 float)

create Index I_Q_M3 on ShengYunDB..Q_M3(TradingDay,InnerCode)

select *
from ShengYunDB..Q_M3
order by TradingDay,InnerCode

delete from Q_GrowthFactors