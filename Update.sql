insert into ShengYunDB..Q_FundamentalRawMonthly
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
where A.TradingDay='2017-10-31'

select * from ShengYunDB..V_Q_All
where TradingDay='2017-10-31'
order by InnerCode

select *
from ShengYunDB..Q_CreditRatingMonthly
where TradingDay='2017-10-31'

delete from ShengYunDB..Q_FundamentalRawMonthly
where TradingDay='2017-10-31'