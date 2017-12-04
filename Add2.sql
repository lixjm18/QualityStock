drop view V_Q_Add2Raw
create view V_Q_Add2Raw as
select A.TradingDay
,C.InnerCode
,B.EndDate
,B.FCFF
,B_LA.FCFF as FCFF_LA
,B_LY2.FCFF as FCFF_LY
,B.EBITDA
,B_LA.EBITDA as EBITDA_LA
,B_LY2.EBITDA as EBITDA_LY
,J.ClosePrice*J.TotalShares as MKTCap
,B.InterestBearDebt
,D.TotalLiability
,isnull(D.MinorityInterests,0) as MinorityInterests
,isnull(D.EPreferStock,0) as EPreferStock
,isnull(D.CashEquivalents,0) as CashEquivalents
,D.TotalCurrentAssets
,D.TotalCurrentLiability
,isnull(D.NotesPayable,0) as NotesPayable
,isnull(D.NonCurrentLiabilityIn1Year,0) as NonCurrentLiabilityIn1Year
,isnull(D_LY.CashEquivalents,0) as CashEquivalents_LY
,D_LY.TotalCurrentAssets as TotalCurrentAssets_LY
,D_LY.TotalCurrentLiability as TotalCurrentLiability_LY
,isnull(D_LY.NotesPayable,0) as NotesPayable_LY
,isnull(D_LY.NonCurrentLiabilityIn1Year,0) as NonCurrentLiabilityIn1Year_LY
,B.TotalOperatingRevenueTTM
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
left join ShengYunDB..V_EndDate_RK T0
on T0.EndDate=B.EndDate
left join ShengYunDB..V_EndDate_RK T_LY
on T_LY.RK=T0.RK-4
left join ShengYunDB..V_EndDate_RK T_LA
on T_LA.RK=T0.RK-MONTH(B.EndDate)/3
left join ShengYunDB..V_LC_BalanceSheetAll D_LY
on D_LY.CompanyCode=B.CompanyCode
and D_LY.EndDate=T_LY.EndDate
and D_LY.InfoPublDate=(select MAX(InfoPublDate) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LY.CompanyCode and EndDate=D_LY.EndDate and InfoPublDate<=A.TradingDay)
and D_LY.IfAdjusted=(select min(IfAdjusted) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LY.CompanyCode and EndDate=D_LY.EndDate and InfoPublDate=D_LY.InfoPublDate)
left join ShengYunDB..V_LC_FSDerivedData B_LY2
on B_LY2.CompanyCode=B.CompanyCode
and B_LY2.EndDate=T_LY.EndDate
and B_LY2.IfAdjusted=2
and B_LY2.InfoPublDate=(Select MAX(InfoPublDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LY2.CompanyCode and InfoPublDate<=A.TradingDay and EndDate=B_LY2.EndDate and IfAdjusted=2)
left join ShengYunDB..V_LC_FSDerivedData B_LA
on B_LA.CompanyCode=B.CompanyCode
and B_LA.EndDate=T_LA.EndDate
and B_LA.InfoPublDate=(Select MAX(InfoPublDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LA.CompanyCode and InfoPublDate<=A.TradingDay and EndDate=B_LA.EndDate)
and B_LA.IfAdjusted=(select MIN(IfAdjusted) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LA.CompanyCode and EndDate=B_LA.EndDate and InfoPublDate=B_LA.InfoPublDate)
left join ShengYunDB..StockDailyTrading J
on J.TradingDay=A.TradingDay
and J.InnerCode=C.InnerCode
where A.TradingDay<=GETDATE()

drop view V_Q_Add3
create view V_Q_Add3 as
select TradingDay,InnerCode
,(FCFF+FCFF_LA-FCFF_LY)/(MKTCap+TotalLiability+MinorityInterests+EPreferStock-CashEquivalents) as FCFF2EV
,case when TotalOperatingRevenueTTM<=0 then null else (((TotalCurrentAssets-CashEquivalents)-(TotalCurrentLiability-NotesPayable-NonCurrentLiabilityIn1Year))-((TotalCurrentAssets_LY-CashEquivalents_LY)-(TotalCurrentLiability_LY-NotesPayable_LY-NonCurrentLiabilityIn1Year_LY)))/TotalOperatingRevenueTTM end as NWC2TR
,EBITDA+EBITDA_LA-EBITDA_LY as EBITDA_LTM
,MKTCap+TotalLiability+MinorityInterests+EPreferStock-CashEquivalents as EV
,(EBITDA+EBITDA_LA-EBITDA_LY)/(MKTCap+TotalLiability+MinorityInterests+EPreferStock-CashEquivalents) as EBITDA2EV
from V_Q_Add2Raw
order by InnerCode,TradingDay

Create view V_Q_All as
select A.*
,B.G1,B.G2,B.GS1,B.GS2,B.GS3,B.GS4,B.ROE_M3,B.ROA_M3
,C.E2P_M3,C.B2P_M3
,D.FCFF2EV,D.NWC2TR,D.EBITDA2EV
from ShengYunDB..V_Q_NonGrowth A
left join ShengYunDB..Q_GrowthFactors B
on A.InnerCode=B.InnerCode
and A.TradingDay=B.TradingDay
left join ShengYunDB..Q_M3 C
on C.InnerCode=A.InnerCode
and C.TradingDay=A.TradingDay
left join ShengYunDB..V_Q_Add3 D
on D.InnerCode=A.InnerCode and D.TradingDay=A.TradingDay

select *
from V_Q_All
where TradingDay='2017-09-29'
order by G2 desc

V_Q_Add3

select *
from V_Q_Add3
where InnerCode=1492
order by InnerCode,TradingDay

select EndDate,FCFF,EBITDA
from JYDB..LC_FSDerivedData
where CompanyCode=(select CompanyCode from ShengYunDB..V_A_Stock_Universe where InnerCode=1492)
order by EndDate


select *
from V_Q_Add3
where InnerCode=160
order by TradingDay

select TradingDay,InnerCode
,case when TotalOperatingRevenueTTM<=0 then null else (((TotalCurrentAssets-CashEquivalents)-(TotalCurrentLiability-NotesPayable-NonCurrentLiabilityIn1Year))-((TotalCurrentAssets_LY-CashEquivalents_LY)-(TotalCurrentLiability_LY-NotesPayable_LY-NonCurrentLiabilityIn1Year_LY)))/TotalOperatingRevenueTTM end as NWC2TR
,TotalOperatingRevenueTTM
,TotalCurrentAssets,
CashEquivalents,
(TotalCurrentLiability-NotesPayable-NonCurrentLiabilityIn1Year)
,(TotalCurrentAssets_LY-CashEquivalents_LY),
(TotalCurrentLiability_LY-NotesPayable_LY-NonCurrentLiabilityIn1Year_LY)
from V_Q_Add2Raw
where InnerCode=160
order by InnerCode,TradingDay


