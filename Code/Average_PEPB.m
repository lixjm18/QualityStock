%%
conn=connect_jydb();
setdbprefs('datareturnformat','table')
str1=sprintf(['select TradingDay,InnerCode,E2P_LTM,B2P from ShengYunDB..V_Q_NonGrowth order by InnerCode,TradingDay '...
    ]);
curs=exec(conn, str1);
curs1=fetch(curs);
EPBPRaw = curs1.Data;

%%
TDList=unique(EPBPRaw.TradingDay);
TDListN=datenum(TDList,'yyyy-mm-dd');

CodeList=unique(EPBPRaw.InnerCode);
M3_Cell=cell(size(EPBPRaw));
%%
C=0;
for i1=1:length(CodeList)
    T1=EPBPRaw(EPBPRaw.InnerCode==CodeList(i1),:);
    TCN=datenum(T1.TradingDay,'yyyy-mm-dd');
    for i2=1:height(T1)
        C=C+1;
        TEnd=TCN(i2);
        TStart=TDListN(max(find(TDListN==TEnd)-36,1));
        i20=find(TCN==TStart);
        E2P_M3=mean(T1.E2P_LTM(i20:i2));
        B2P_M3=mean(T1.B2P(i20:i2));
        M3_Cell(C,:)=[T1.TradingDay(i2),num2cell([CodeList(i1),E2P_M3,B2P_M3])];
    end
end


%%
tic
write_into_sql_table(M3_Cell,{'Datetime','Num','Num','Num'},'ShengYunDB..Q_M3Every2Week',conn);
toc
