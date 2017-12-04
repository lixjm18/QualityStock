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
G1=mean(2*(RevY(:,1:3)-RevY(:,2:4))./(abs(RevY(:,2:4))+abs(RevY(:,1:3))),2);
% X1=sum(RevY<0,2)>0;
% G1(X1)=-99;
G2=mean(2*(NPY(:,1:3)-NPY(:,2:4))./(abs(NPY(:,2:4))+abs(NPY(:,1:3))),2);

GS1=std((RevQ(:,1:11)-RevQ(:,2:12))./abs(RevQ(:,2:12)),0,2);
GS2=std((NPQ(:,1:11)-NPQ(:,2:12))./abs(NPQ(:,2:12)),0,2);
GS3_0=NPQ./SEQ;
XS3=SEQ<0;
GS3_0(XS3)=nan;
GS3=std(GS3_0(:,1:11)-GS3_0(:,2:12),0,2);
ROE_M3=mean(GS3_0,2);
GS4_0=NPQ./TAQ;
GS4=std(GS4_0(:,1:11)-GS4_0(:,2:12),0,2);
ROA_M3=mean(GS4_0,2);

%%
V=[table2cell(GrowthRaw(:,1:2)),num2cell([G1,G2,GS1,GS2,GS3,GS4,ROE_M3,ROA_M3])];
%%
write_into_sql_table(V,{'Datetime','Num','Num','Num','Num','Num','Num','Num','Num','Num'},'ShengYunDB..Q_GrowthFactorsEvery2Week',conn);
