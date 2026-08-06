function tabElements = buildPayTab(tab)
    %% initial variables
    dateTimeFormat = "eeee, dd.MM.yyyy";
    dateToday = datetime("today");
    initDateMenuActive = false;
    initPayAll = false;
    initSaveSurplus = true;
    initUseSavings = false;
    initFontSize = 20;
    displayedVariables = ["Verbrauchsdatum", "Produkt", "Menge", "Anzahl", "Gesamt", "Bezahlt", "Kommentar"];

    %% layout config
    tabGrid = [5 3]; % rows: userSelect; line; info; line; paymentSelect, cols: leftSide, line, table
    tabRowHeights = {"0.1x", 1, "1x", 1, "0.25x"};
    tabColWidths = {"0.5x", 1, "1x"};

    filterGrid = [1 5]; %name, spacing, checkbox, line, dateMenu
    filterRowHeights = {"1x"};
    filterColWidths = {"1x", "1x", 20, 1, "1x"};
    filterTabRows = 1;
    filterTabCols = [1 3];

    filterDateMenuGrid = [2 2]; %[von, dateSel1; bis, dateSel2]
    filterDateMenuRowHeights = {"1x", "1x"};
    filterDateMenuColWidths = {30, "1x"};
    filterDateMenuFilterRows = 1;
    filterDateMenuFilterCols = 5;

    infoGrid = [5 3]; % ["gesamt" spacing "0.00"; "bezahlt" spacing "0.00"; line; "ausstehend" spacing "0.00"; "Guthaben" spacing "0.00"]
    infoRowHeights = {"1x", "1x", 1, "1x", "1x"};
    infoColWidths = {"0.75x", "0.5x", "1x"};
    infoTabRows = 3;
    infoTabCols = 1;

    paymentGrid = [3 6]; %"Zahlung:" x2, spacing, allBtnGroupSel x2, paymentSpinnerSel; SaveSurplusSel
    paymentRowHeights = {"1x", "1x", "1x"};
    paymentColWidths = {"0.75x", "0.75x", "0.5x", "0.5x", "1x", "1x"};
    paymentTabRows = 5;
    paymentTabCols = 1;

    tableGrid = [1 1]; 
    tableRowHeights = {"1x"};
    tableColWidths = {"1x"};
    tableTabRows = [3 5];
    tableTabCols = 3;

    %% setup tab
    tabLayout = uigridlayout(tab, tabGrid);
    tabLayout.RowHeight = tabRowHeights;
    tabLayout.ColumnWidth = tabColWidths;

    filterLayout = uigridlayout(tabLayout, filterGrid);
    filterLayout.Padding = [0 0 0 0];
    filterLayout.RowHeight = filterRowHeights;
    filterLayout.ColumnWidth = filterColWidths;
    filterLayout.Layout.Row = filterTabRows;
    filterLayout.Layout.Column = filterTabCols;

    filterDateMenuLayout = uigridlayout(filterLayout, filterDateMenuGrid);
    filterDateMenuLayout.Padding = [0 0 0 0];
    filterDateMenuLayout.RowHeight = filterDateMenuRowHeights;
    filterDateMenuLayout.ColumnWidth = filterDateMenuColWidths;
    filterDateMenuLayout.Layout.Row = filterDateMenuFilterRows;
    filterDateMenuLayout.Layout.Column = filterDateMenuFilterCols;

    infoLayout = uigridlayout(tabLayout, infoGrid);
    infoLayout.Padding = [0 0 0 0];
    infoLayout.RowHeight = infoRowHeights;
    infoLayout.ColumnWidth = infoColWidths;
    infoLayout.Layout.Row = infoTabRows;
    infoLayout.Layout.Column = infoTabCols;

    paymentLayout = uigridlayout(tabLayout, paymentGrid);
    paymentLayout.Padding = [0 10 0 10]; % upper, lower padding for spinner to be less high
    paymentLayout.RowHeight = paymentRowHeights;
    paymentLayout.ColumnWidth = paymentColWidths;
    paymentLayout.Layout.Row = paymentTabRows;
    paymentLayout.Layout.Column = paymentTabCols;

    tableLayout = uigridlayout(tabLayout, tableGrid);
    tableLayout.Padding = [0 0 0 0];
    tableLayout.RowHeight = tableRowHeights;
    tableLayout.ColumnWidth = tableColWidths;
    tableLayout.Layout.Row = tableTabRows;
    tableLayout.Layout.Column = tableTabCols;

    % filterDateMenu
    filterDateMenuElements = struct("FromTextLabel",    uilabel(filterDateMenuLayout, "Text", "von:", "HorizontalAlignment", "right"), ...
                                    "FirstDateSelect",  uidatepicker(filterDateMenuLayout, "DisplayFormat", dateTimeFormat, "Enable", initDateMenuActive), ...                                 
                                    "ToTextLabel",      uilabel(filterDateMenuLayout, "Text", "bis:", "HorizontalAlignment", "right"), ...                                
                                    "SecondDateSelect", uidatepicker(filterDateMenuLayout, "DisplayFormat", dateTimeFormat, "Enable", initDateMenuActive));

    % filter
    filterElements =     struct("NameSelect",           uidropdown(filterLayout, "Items", "", "FontSize", initFontSize), ...       
                                "DateMenuActiveSelect", uicheckbox(filterLayout, "Value", initDateMenuActive, "Text", ""), ...
                                "HorizontalAxes",       uiaxes(filterLayout, "FontSize",0.01, "Visible", "off"), ...
                                "DateMenuLayout",       filterDateMenuLayout, ...
                                "DateMenu",             filterDateMenuElements);

    %draw line and store in userData of axes
    filterElements.HoriontalAxes.UserData = line(filterElements.HorizontalAxes, [0 0], [0 1], "Color", "black");

    filterElements.NameSelect.Layout.Row = 1;
    filterElements.NameSelect.Layout.Column = 1;
    filterElements.DateMenuActiveSelect.Layout.Row = 1;
    filterElements.DateMenuActiveSelect.Layout.Column = 3;
    filterElements.HorizontalAxes.Layout.Row = 1;
    filterElements.HorizontalAxes.Layout.Column = 4;
    filterElements.filterDateMenuLayout.Layout.Row = 1;
    filterElements.filterDateMenuLayout.Layout.Column = 5;


    % info
    infoElements =     struct("TotalTextLabel",     uilabel(infoLayout, "FontSize", initFontSize, "Text", "Gesamt:", "HorizontalAlignment", "right"), ...
                              "TotalAmountLabel",   uilabel(infoLayout, "FontSize", initFontSize, "Text", "0.00 €", "FontWeight", "Bold"), ...
                              "PaidTextLabel",      uilabel(infoLayout, "FontSize", initFontSize, "Text", "Bezahlt:", "HorizontalAlignment", "right"), ...
                              "PaidAmountLabel",    uilabel(infoLayout, "FontSize", initFontSize, "Text", "0.00 €", "FontWeight", "Bold"), ...
                              "HorizontalAxes",     uiaxes(infoLayout, "FontSize",0.01, "Visible", "off"), ...
                              "DueTextLabel",       uilabel(infoLayout, "FontSize", initFontSize, "Text", "Ausstehend:", "HorizontalAlignment", "right"), ...
                              "DueAmountLabel",     uilabel(infoLayout, "FontSize", initFontSize, "Text", "0.00 €", "FontWeight", "Bold"), ...
                              "SavingsTextLabel",   uilabel(infoLayout, "FontSize", initFontSize, "Text", "Guthaben:", "HorizontalAlignment", "right"), ...
                              "SavingsAmountLabel", uilabel(infoLayout, "FontSize", initFontSize, "Text", "0.00 €", "FontWeight", "Bold"));

    infoElements.TotalTextLabel.Layout.Row =        1;
    infoElements.TotalTextLabel.Layout.Column =     1;
    infoElements.TotalAmountLabel.Layout.Row =      1;
    infoElements.TotalAmountLabel.Layout.Column =   3;
    infoElements.PaidTextLabel.Layout.Row =         2;
    infoElements.PaidTextLabel.Layout.Column =      1;
    infoElements.PaidAmountLabel.Layout.Row =       2;
    infoElements.PaidAmountLabel.Layout.Column =    3;
    infoElements.HorizontalAxes.Layout.Row =        3;
    infoElements.HorizontalAxes.Layout.Column =     [1 3];
    infoElements.DueTextLabel.Layout.Row =          4;
    infoElements.DueTextLabel.Layout.Column =       1;
    infoElements.DueAmountLabel.Layout.Row =        4;
    infoElements.DueAmountLabel.Layout.Column =     3;
    infoElements.SavingsTextLabel.Layout.Row =      5;
    infoElements.SavingsTextLabel.Layout.Column =   1;
    infoElements.SavingsAmountLabel.Layout.Row =    5;
    infoElements.SavingsAmountLabel.Layout.Column = 3;


    %draw line and store in userData of axes
    infoElements.HoriontalAxes.UserData = line(infoElements.HorizontalAxes, [0 1], [0 0], "Color", "black");


    % payment
    paymentElements = struct("PaymentTextLabel",    uilabel(paymentLayout, "Text", "Zahlung:", "FontSize", initFontSize, "HorizontalAlignment", "right"), ...
                             "PayAllSelect",        uicheckbox(paymentLayout, "Value", initPayAll, "Text", "vollständig", "FontSize", initFontSize), ...
                             "PaymentSelect",       uispinner(paymentLayout, "Value", 0.00, "Step", 0.01, "Limits", [0 inf], "Enable", ~initPayAll, "FontSize", initFontSize), ...
                             "UseSavingsSelect",    uicheckbox(paymentLayout, "Value", initUseSavings, "Text", "Guthaben verwenden", "FontSize", initFontSize), ...
                             "SaveSurplusSelect",   uicheckbox(paymentLayout, "Value", initSaveSurplus, "Text", "Überschuss als Guthaben", "FontSize", initFontSize));
    
    paymentElements.PaymentTextLabel.Layout.Row         = [1 2];
    paymentElements.PaymentTextLabel.Layout.Column      = [1 2];

    paymentElements.PaymentSelect.Layout.Row            = [1 2];
    paymentElements.PaymentSelect.Layout.Column         = [3 4];

    paymentElements.PayAllSelect.Layout.Row             = 1;
    paymentElements.PayAllSelect.Layout.Column          = [5 6];

    paymentElements.UseSavingsSelect.Layout.Row         = 2;
    paymentElements.UseSavingsSelect.Layout.Column      = [5 6];

    paymentElements.SaveSurplusSelect.Layout.Row        = 3;
    paymentElements.SaveSurplusSelect.Layout.Column     = [3 6];

    % table
    tableElements = struct("Table", uitable(tableLayout));

    % seperate lines
    hAxes1 = uiaxes(tabLayout, "FontSize", 0.01, "Visible", "off");
    line(hAxes1, [0 1], [0 0], "Color", "black");
    hAxes1.Layout.Row = 2;
    hAxes1.Layout.Column = [1 3];

    hAxes2 = uiaxes(tabLayout, "FontSize", 0.01, "Visible", "off");
    line(hAxes2, [0 1], [0 0], "Color", "black");
    hAxes2.Layout.Row = 4;
    hAxes2.Layout.Column = 1;

    vAxes1 = uiaxes(tabLayout, "FontSize", 0.01, "Visible", "off");
    line(vAxes1, [0 0], [0 1], "Color", "black");
    vAxes1.Layout.Row = [3 5];
    vAxes1.Layout.Column = 2;

    %% pack content
    tabElements = struct( ...
        "tab", tab, ...
        "filterElements", filterElements, ...
        "tableElements", tableElements, ...
        "infoElements", infoElements, ...
        "paymentElements", paymentElements, ...
        "dateTimeFormat", dateTimeFormat, ...
        "dateToday", dateToday, ...
        "displayedVariables", displayedVariables, ...
        "styleBgRed", uistyle("BackgroundColor", "red"), ...
        "styleBgGreen", uistyle("BackgroundColor", "green"), ...
        "styleBgYellow", uistyle("BackgroundColor", "yellow"));
end