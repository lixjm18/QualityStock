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
[~,~,AbTerm]=xlsread('E:\work\QualityStock\数据构建\AbTerms.xlsx',1);

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

%% word接口
filespec_user = ['E:\work\QualityStock\数据构建\数据检查.docx'];
% 判断Word是否已经打开，若已打开，就在打开的Word中进行操作，否则就打开Word
try
    % 若Word服务器已经打开，返回其句柄Word
    Word = actxGetRunningServer('Word.Application');
catch
    % 创建一个Microsoft Word服务器，返回句柄Word
    Word = actxserver('Word.Application');
end;

% 设置Word属性为可见
Word.Visible = 1;    % 或set(Word, 'Visible', 1);

% 若测试文件存在，打开该测试文件，否则，新建一个文件，并保存，文件名为测试.doc
if exist(filespec_user,'file')==0;
    Document = Word.Documents.Add;
    % Document = invoke(Word.Documents, 'Add');
    Document.SaveAs(filespec_user);
    Content = Document.Content;    % 返回Content接口句柄
    Selection = Word.Selection;    % 返回Selection接口句柄
    Paragraphformat = Selection.ParagraphFormat;  % 返回ParagraphFormat接口句柄
    % 页面设置
    Document.PageSetup.TopMargin = 60;      % 上边距60磅
    Document.PageSetup.BottomMargin = 45;   % 下边距45磅
    Document.PageSetup.LeftMargin = 45;     % 左边距45磅
    Document.PageSetup.RightMargin = 45;    % 右边距45磅
    Content.Start = 0;         % 设置文档内容的起始位置
    
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
        Selection.Start = Content.end;    % 设定下面内容的起始位置
        xueqi =CheckList{i1};
        Selection.Text = xueqi;        % 在当前位置输入文字内容
        Selection.Style = '标题 2';
        Selection.MoveDown;
        Selection.TypeParagraph;
        Selection.Paste;
        Selection.MoveDown;
        Selection.TypeParagraph;
        Selection.TypeParagraph;
        close all
    end
end