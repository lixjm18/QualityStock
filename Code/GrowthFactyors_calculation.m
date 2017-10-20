%%
conn=connect_jydb();
setdbprefs('datareturnformat','table')
str1=sprintf(['select * '...
    'from ShengYunDB..V_Q_GrowthRaw order by TradingDay,InnerCode '...
    ]);
curs=exec(conn, str1);
curs1=fetch(curs);
GrowthRaw = curs1.Data;

%%
RevY=table2array(GrowthRaw(:,3:6));
NPY=table2array(GrowthRaw(:,7:10));
RevQ=table2array(GrowthRaw(:,11:22));
NPQ=table2array(GrowthRaw(:,23:34));
SEQ=table2array(GrowthRaw(:,35:46));
TAQ=table2array(GrowthRaw(:,47:58));
%%
G1=nanmean(RevY(:,1:3)./RevY(:,2:4)-1,2);
G2=nanmean(NPY(:,1:3)./NPY(:,2:4)-1,2);

GS1=nanstd(RevQ(:,1:11)./RevQ(:,2:12)-1,0,2);
GS2=nanstd(NPQ(:,1:11)./NPQ(:,2:12)-1,0,2);
GS3_0=NPQ./SEQ;
GS3=nanstd(GS3_0(:,1:11)-GS3_0(:,2:12),0,2);
GS4_0=NPQ./TAQ;
GS4=nanstd(GS4_0(:,1:11)-GS4_0(:,2:12),0,2);

%%
V=[table2cell(GrowthRaw(:,1:2)),num2cell([G1,G2,GS1,GS2,GS3,GS4])];
%%
write_into_sql_table(V,{'Datetime','Num','Num','Num','Num','Num','Num','Num'},'ShengYunDB..Q_GrowthFactors',conn);
