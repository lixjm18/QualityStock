%%
conn=connect_jydb();
setdbprefs('datareturnformat','table')
str1=sprintf(['select B.*, '...
    'Cash, '...
    'TA, '...
    'TA_LY, '...
    'RetP, '...
    'SE, '...
    'SE_LY, '...
    'IBD, '...
    'IBD_LY, '...
    'CurDebt, '...
    'TD, '...
    'CFO, '...
    'Div, '...
    'NP, '...
    'NIO, '...
    'NPPar, '...
    'TP, '...
    'Rev, '...
    'Cost '...
    'from ShengYunDB..[V_Q_NV_Check] A '...
    'left join ShengYunDB..V_Q_NonGrowth B '...
    'on A.InnerCode=B.InnerCode '...
    'and A.TradingDay=B.TradingDay '...
    'order by A.TradingDay,A.InnerCode '...
    ]);
curs=exec(conn, str1);
curs1=fetch(curs);
GrowthRaw = curs1.Data;


%%
[~,~,AbTerm]=xlsread('E:\work\QualityStock\���ݹ���\AbTerms.xlsx',1);

%%
VAll=table2array(GrowthRaw(:,3:27));
%%
CheckList={'E2P_LTM'
    'B2P'
    'DivRatio'
    'S2P_LTM'
    'Cash2ShortDebt'
    'Cash2Debt'
    'Cash2Cap'
    'CashFlow2Debt'
    'Debt2Book'
    'Debt2Cap'
    'ShortDebt2Book'
    'Rating_Med'
    'Rating_Min'
    'ROE_LTM'
    'ROA_LTM'
    'CashFlow2Assets_LTM'
    'Grossrofit2Assets'
    'PayoutRatio'
    'DebtIssue2Cap'
    'EquityIssue2Cap'
    'Retained2Book'
    'Operating2Total'
    'NonOperating2Total'
    'Tax2Total'
    'NPDeduct2Total'
    };

%% word�ӿ�
filespec_user = ['E:\work\QualityStock\���ݹ���\���ݼ��.docx'];
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
    GoodIX=sum(table2array(GrowthRaw(:,28:end)),2)==18;
    for i1=1:length(VAll(1,:))
        Abs=AbTerm(i1,:);
        VRaw=VAll(:,i1);
        VGood=VAll(GoodIX,i1);
        if isempty(Abs{1})==1
            VAdj=VRaw;
        else
            eval(['IX=GrowthRaw.',Abs{1},'==1;']);
            for i2=2:3
                if isempty(Abs{i2})==0
                    eval(['IX=IX&GrowthRaw.',Abs{i2},'==1;']);
                end
            end
            VAdj=VRaw(IX);
        end
        figure('visible','off');
        subplot(311)
        hist(VRaw,100);
        grid on
        subplot(312)
        hist(VAdj,100);
        grid on
        if isempty(Abs{1})==1
            title('No Change');
        end
        subplot(313)
        hist(VGood,100);
        grid on
        hgexport(gcf, '-clipboard');
        Selection.Start = Content.end;    % �趨�������ݵ���ʼλ��
        xueqi =CheckList{i1};
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