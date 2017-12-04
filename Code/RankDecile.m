%%
addpath('E:\work\MyFun\PortRelated')
addpath('E:\work\MyFun\StatsFun')
addpath('E:\work\DataUpdate\Daily\PPT')
addpath('E:\work\MyClass\Opt300_Performance')
conn=connect_jydb();

setdbprefs('datareturnformat','table')
str1=sprintf(['select TradingDay '...
    ',InnerCode '...
    ',IGroup '...
    ',F_value '...
    ',F_quality_p '...
    ',F_quality_o '...
    ',F_growth '...
    ',F_value_f '...
    ',F_growth_f '...
    ',F_comp_t '...
    ',F_6mm '...
    'from ShengYunDB..[RR_Factor300_Rank] '...
    'order by TradingDay,InnerCode '...
    ]);
curs=exec(conn, str1);
curs1=fetch(curs);
RankRaw = curs1.Data;

%%
IGList=unique(RankRaw.IGroup);
RKList=unique(RankRaw.F_value);
DateList=unique(RankRaw.TradingDay);
Vars=RankRaw.Properties.VariableNames;
FNames=Vars(4:end);
LList0={'RK0','RK1','RK2','RK3','RK4','RK5','RK6','RK7','RK8','RK9'};
%% word�ӿ�
filespec_user = ['E:\work\QualityStock\decile\FactorDecile_betaN.doc'];
% �ж�Word�Ƿ��Ѿ��򿪣����Ѵ򿪣����ڴ򿪵�Word�н��в���������ʹ�Word
try
    % ��Word�������Ѿ��򿪣���������Word
    Word = actxGetRunningServer('Word.Application');
catch
    % ����һ��Microsoft Word�����������ؾ��Word
    Word = actxserver('Word.Application');
end;

% ����Word����Ϊ�ɼ�
Word.Visible = 1;    % ��set(Word, 'Visible', 1);

% �������ļ����ڣ��򿪸ò����ļ��������½�һ���ļ��������棬�ļ���Ϊ����.doc
if exist(filespec_user,'file')==0;
    Document = Word.Documents.Add;
    % Document = invoke(Word.Documents, 'Add');
    Document.SaveAs(filespec_user);
    Content = Document.Content;    % ����Content�ӿھ��
    Selection = Word.Selection;    % ����Selection�ӿھ��
    Paragraphformat = Selection.ParagraphFormat;  % ����ParagraphFormat�ӿھ��
    % ҳ������
    Document.PageSetup.TopMargin = 60;      % �ϱ߾�60��
    Document.PageSetup.BottomMargin = 45;   % �±߾�45��
    Document.PageSetup.LeftMargin = 45;     % ��߾�45��
    Document.PageSetup.RightMargin = 45;    % �ұ߾�45��
    Content.Start = 0;         % �����ĵ����ݵ���ʼλ��
    
    
    %%
    for i1=1:length(IGList)
        IGC=IGList(i1);
        T1=RankRaw(RankRaw.IGroup==IGC,:);
        for i2=1:length(FNames)
            FC=FNames{i2};
            PortCell=cell(1,10);
            for i3=1:length(DateList)
                DateC=DateList{i3};
                DateCN=str2double(datestr(datenum(DateC,'yyyy-mm-dd'),'yyyymmdd'));
                T3=T1(ismember(T1.TradingDay,DateC),:);
                for i4=1:length(RKList)
                    RKC=RKList(i4);
                    eval(['InnerCodeC=T3.InnerCode(T3.',FC,'==RKC);']);
                    PortC=[repmat(DateCN,[length(InnerCodeC),1]),InnerCodeC];
                    PortC(:,3)=1/length(PortC(:,1));
                    PortCell{i4}=[PortCell{i4};PortC];
                end
            end
            T=Opt300_Model_Local_ND_beta(PortCell{1});
            TDListN=datenum(T.TDList,'yyyy-mm-dd');
            RetsMat=T.Rets;
            for i5=2:length(RKList)
                T=Opt300_Model_Local_ND_beta(PortCell{i5});
                try 
                RetsMat=[RetsMat,T.Rets];
                catch err
                    Rets=T.Rets;
                    Rets=[zeros(length(RetsMat(:,1))-length(Rets),1);Rets];
                    RetsMat=[RetsMat,Rets];
                end
            end
            CumRet=cumsum(RetsMat);
            figure();
            plot(TDListN,CumRet);
            set(gcf,'unit','pixel','position',[20 80 1280 720])
            LList=LList0;
            for i6=1:length(LList)
                LList{i6}=[LList{i6},sprintf('=%.3f',CumRet(end,i6))];
            end
            
            legend(LList,'Location','northwest');
            grid minor
            set(gca,'xticklabel',datestr(get(gca,'XTick'),'yyyy/mm/dd'));
            hgexport(gcf, '-clipboard');
            Selection.Start = Content.end;    % �趨�������ݵ���ʼλ��
            xueqi = sprintf('IGroup=%d,FactorName=%s',IGC,FC);
            Selection.Text = xueqi;        % �ڵ�ǰλ��������������
            Selection.Style = '���� 2';
            Selection.MoveDown;
            Selection.TypeParagraph;
            Selection.Paste;
            Selection.MoveDown;
            Selection.TypeParagraph;
            Selection.TypeParagraph;
            close all
        end
    end
end