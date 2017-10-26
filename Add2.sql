create view V_Q_Add2Raw as
select A.TradingDay
,C.InnerCode
,B.EndDate
,B.FCFF
,B_LA.FCFF as FCFF_LA
,B_LY2.FCFF as FCFF_LY
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


select TradingDay,InnerCode
,(FCFF+FCFF_LA-FCFF_LY)/(MKTCap+InterestBearDebt+MinorityInterests+EPreferStock-CashEquivalents) as FCFF2EV
,case when TotalOperatingRevenueTTM<=0 then null else (((TotalCurrentAssets-CashEquivalents)-(TotalCurrentLiability-NotesPayable-NonCurrentLiabilityIn1Year))-((TotalCurrentAssets_LY-CashEquivalents_LY)-(TotalCurrentLiability_LY-NotesPayable_LY-NonCurrentLiabilityIn1Year_LY)))/TotalOperatingRevenueTTM end as NWC2TR
from V_Q_Add2Raw
order by TradingDay,InnerCode

