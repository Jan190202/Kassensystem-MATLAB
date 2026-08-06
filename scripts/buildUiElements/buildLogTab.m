function tabElements = buildLogTab(tab)
    %% layout config
    tabGrid = [3 1]; % filters; line; table; line; deleteRowMenu
    tabRowHeights = {"0.1x", 1, "1x"};
    tabColWidths = {"1x"};

    filterGrid = [2 7]; %typeMenu, spacing, checkbox, spacing, checkbox, line, dateMenu
    filterRowHeights = {"1x", "1x"};
    filterColWidths = {"1x", 1, "1x", "1x", 20, 1, "1x"};
    filterTabRows = 1;
    filterTabCols = 1;

    filterTypeMenuGrid = [2 1]; %[von, dateSel1; bis, dateSel2]
    filterTypeMenuRowHeights = {"1x", "1x"};
    filterTypeMenuColWidths = {"1x"};
    filterTypeMenuFilterRows = 1;
    filterTypeMenuFilterCols = 1;

    filterDateMenuGrid = [2 2]; %[von, dateSel1; bis, dateSel2]
    filterDateMenuRowHeights = {"1x", "1x"};
    filterDateMenuColWidths = {30, "1x"};
    filterDateMenuFilterRows = 1;
    filterDateMenuFilterCols = 5;

    tableGrid = [1 1]; 
    tableRowHeights = {"1x"};
    tableColWidths = {"1x"};
    tableTabRows = 3;
    tableTabCols = 1;

    %% initial elements
    initDateMenuActive = false;
    initDetailedActive = false;
    initFontSize = 15;
    dateTimeFormat = "eeee, dd.MM.yyyy hh:mm:ss";
    displayedVariables = ["Datum", "Beschreibung", "Kommentar"];
    tableVariableWidths = {200, "4x", "1x"};
   
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

    filterTypeMenuLayout = uigridlayout(filterLayout, filterTypeMenuGrid);
    filterTypeMenuLayout.Padding = [0 0 0 0];
    filterTypeMenuLayout.RowHeight = filterTypeMenuRowHeights;
    filterTypeMenuLayout.ColumnWidth = filterTypeMenuColWidths;
    filterTypeMenuLayout.Layout.Row = filterTypeMenuFilterRows;
    filterTypeMenuLayout.Layout.Column = filterTypeMenuFilterCols;

    filterDateMenuLayout = uigridlayout(filterLayout, filterDateMenuGrid);
    filterDateMenuLayout.Padding = [0 0 0 0];
    filterDateMenuLayout.RowHeight = filterDateMenuRowHeights;
    filterDateMenuLayout.ColumnWidth = filterDateMenuColWidths;
    filterDateMenuLayout.Layout.Row = filterDateMenuFilterRows;
    filterDateMenuLayout.Layout.Column = filterDateMenuFilterCols;

    tableLayout = uigridlayout(tabLayout, tableGrid);
    tableLayout.Padding = [0 0 0 0];
    tableLayout.RowHeight = tableRowHeights;
    tableLayout.ColumnWidth = tableColWidths;
    tableLayout.Layout.Row = tableTabRows;
    tableLayout.Layout.Column = tableTabCols;

    % filterDateMenu
    filterTypeMenuElements = struct("FirstSelect",  uidropdown(filterTypeMenuLayout, "Items", "", "FontSize", initFontSize), ...                                 
                                    "SecondSelect", uidropdown(filterTypeMenuLayout, "Items", "", "FontSize", initFontSize));

    filterDateMenuElements = struct("FromTextLabel",    uilabel(filterDateMenuLayout, "Text", "von:", "HorizontalAlignment", "right"), ...
                                    "FirstDateSelect",  uidatepicker(filterDateMenuLayout, "DisplayFormat", dateTimeFormat, "Enable", initDateMenuActive), ...                                 
                                    "ToTextLabel",      uilabel(filterDateMenuLayout, "Text", "bis:", "HorizontalAlignment", "right"), ...                                
                                    "SecondDateSelect", uidatepicker(filterDateMenuLayout, "DisplayFormat", dateTimeFormat, "Enable", initDateMenuActive));

    % filter
    filterElements =     struct("TypeSelect",           filterTypeMenuElements, ... 
                                "TypeMenuLayout",       filterTypeMenuLayout, ...
                                "DetailedSelect",       uicheckbox(filterLayout, "Text", "Detailansicht", "Value", initDetailedActive), ...
                                "DateMenuActiveSelect", uicheckbox(filterLayout, "Value", initDateMenuActive, "Text", ""), ...
                                "HorizontalAxes",       uiaxes(filterLayout, "FontSize", 0.01, "Visible", "off"), ...
                                "DateMenuLayout",       filterDateMenuLayout, ...
                                "DateMenu",             filterDateMenuElements);

    %draw line and store in userData of axes
    filterElements.HoriontalAxes.UserData = line(filterElements.HorizontalAxes, [0 0], [0 1], "Color", "black");

    filterElements.TypeMenuLayout.Layout.Row = [1 2];
    filterElements.TypeMenuLayout.Layout.Column = 1;
    filterElements.DetailedSelect.Layout.Row = 1;
    filterElements.DetailedSelect.Layout.Column = 3;
    filterElements.DateMenuActiveSelect.Layout.Row = [1 2];
    filterElements.DateMenuActiveSelect.Layout.Column = 5;
    filterElements.HorizontalAxes.Layout.Row = [1 2];
    filterElements.HorizontalAxes.Layout.Column = 6;
    filterElements.DateMenuLayout.Layout.Row = [1 2];
    filterElements.DateMenuLayout.Layout.Column = 7;
    
    % seperation line
    hAxes1 = uiaxes(tabLayout, "FontSize", 0.01, "Visible", "off");
    line(hAxes1, [0 1], [0 0], "Color", "black");
    hAxes1.Layout.Row = 2;
    hAxes1.Layout.Column = 1;

    % table
    tableElements = struct("Table", uitable(tableLayout, "ColumnWidth", tableVariableWidths));


    %% pack content
    tabElements = struct( ...
        "tab", tab, ...
        "tableElements", tableElements, ...
        "filterElements", filterElements, ...
        "initDetailedActive", initDetailedActive, ...
        "dateTimeFormat", dateTimeFormat, ...
        "displayedVariables", displayedVariables);
end