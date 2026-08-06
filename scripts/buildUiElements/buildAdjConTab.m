function tabElements = buildAdjConTab(tab)
    %% layout config
    tabGrid = [3 1]; % filters; line; table; line; deleteRowMenu
    tabRowHeights = {"0.1x", 1, "1x"};
    tabColWidths = {"1x"};

    filterGrid = [1 5]; %name, spacing, checkbox, line, dateMenu
    filterRowHeights = {"1x"};
    filterColWidths = {"1x", "1x", 20, 1, "1x"};
    filterTabRows = 1;
    filterTabCols = 1;

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
    initFontSize = 15;
    dateTimeFormat = "eeee, dd.MM.yyyy";
   
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
                                "HorizontalAxes",       uiaxes(filterLayout, "FontSize", 0.01, "Visible", "off"), ...
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
    
    % seperation line
    hAxes1 = uiaxes(tabLayout, "FontSize", 0.01, "Visible", "off");
    line(hAxes1, [0 1], [0 0], "Color", "black");
    hAxes1.Layout.Row = 2;
    hAxes1.Layout.Column = 1;

    % table
    tableElements = struct("Table", uitable(tableLayout, "ColumnEditable", true));


    %% pack content
    tabElements = struct( ...
        "tab", tab, ...
        "tableElements", tableElements, ...
        "filterElements", filterElements, ...
        "dateTimeFormat", dateTimeFormat);
end