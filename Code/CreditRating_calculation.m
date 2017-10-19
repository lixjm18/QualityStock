%%
conn=connect_jydb();
setdbprefs('datareturnformat','table')
str1=sprintf(['select * '...
    'from ShengYunDB..V_CreditRating_Monthly order by TradingDay,InnerCode '...
    ]);
curs=exec(conn, str1);
curs1=fetch(curs);
RatingRaw = curs1.Data;

%%
Stat = grpstats(RatingRaw,{'TradingDay','InnerCode'},{'median','min'},'DataVars',{'CRCode'});
%%
V=table2cell(Stat(:,{'TradingDay','InnerCode','median_CRCode','min_CRCode'}));
%%
write_into_sql_table(V,{'Datetime','Num','Num','Num'},'ShengYunDB..Q_CreditRatingMonthly',conn);
