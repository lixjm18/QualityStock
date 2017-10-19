select A.*,B.*,C.InnerCode,D.*,ISNULL(E.DivRatio,0) as DivRatio
,B.TotalOperatingRevenueTTM
,B.OperatingRevenueTTM
,D.CashEquivalents
,D.TotalCurrentLiability
,D.TotalLiability
,B.NetOperateCashFlowTTM
,F.Rating_Med
,F.Rating_Min
,D_LY.SEWithoutMI as SEWithoutMI_LY
,D.SEWithoutMI
,D_LY.TotalAssets as TotalAssets_LY
,D.TotalAssets
,B.TotalOperatingCostTTM
,B.OperatingPayoutTTM
,B.GrossProfitTTM
,G.TotalCashDiviLTM
,B.InterestBearDebt
,B_LY.InterestBearDebt as InterestBearDebt_LY
,H.MoneyToAccount
,I.MoneyToAccount
,D.RetainedProfit
,B.NIFromOperatingTTM
,B.TotalProfitTTM
,B.NonoperatingNetIncomeTTM
,B.NPDeductNonRecurringPL
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
left join ShengYunDB..V_LC_BalanceSheetAll D_LY
on D_LY.CompanyCode=B.CompanyCode
and D_LY.EndDate=T_LY.EndDate
and D_LY.InfoPublDate=(select MAX(InfoPublDate) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LY.CompanyCode and EndDate=D_LY.EndDate and InfoPublDate<=A.TradingDay)
and D_LY.IfAdjusted=(select min(IfAdjusted) from ShengYunDB..V_LC_BalanceSheetAll where CompanyCode=D_LY.CompanyCode and EndDate=D_LY.EndDate and InfoPublDate=D_LY.InfoPublDate)
left join ShengYunDB..V_Q_CashDividend G
on G.InnerCode=C.InnerCode
and G.EndDate=(select MAX(EndDate) from ShengYunDB..V_Q_CashDividend where InnerCode=G.InnerCode and AdvanceDate between DATEADD(MONTH,-7,A.TradingDay) and A.TradingDay)
left join ShengYunDB..V_LC_FSDerivedData B_LY
on B_LY.CompanyCode=B.CompanyCode
and B_LY.EndDate=T_LY.EndDate
and B_LY.InfoPublDate=(Select MAX(InfoPublDate) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LY.CompanyCode and InfoPublDate<=A.TradingDay and EndDate=B_LY.EndDate)
and B_LY.IfAdjusted=(select MIN(IfAdjusted) from ShengYunDB..V_LC_FSDerivedData where CompanyCode=B_LY.CompanyCode and EndDate=B_LY.EndDate and InfoPublDate=B_LY.InfoPublDate)
left join ShengYunDB..V_Q_LC_ASharePlacement H
on H.InnerCode=C.InnerCode
and H.TradingDay=A.TradingDay
left join ShengYunDB..V_Q_LC_AShareSeasonedNewIssue I
on I.InnerCode=C.InnerCode
and I.TradingDay=A.TradingDay
where A.TradingDay<=GETDATE()
