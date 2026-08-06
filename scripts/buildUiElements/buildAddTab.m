function tabElements = buildAddTab(tab)
    %% variables
    dateToday = datetime("today");

    %% layout config
    tabGrid = [3 1];
    tabRowHeights = {30, 1, "1x"};

    tabColWidths = {"1.5x", "1.5x", "0.5x", "0.5x", "0.75x", "0.75x", "0.75x", "0.75x", "0.9x", "0.9x", "1.5x", 20};
    headerTexts = ["Name", "Produkt", "Menge (l)", "Anzahl", "Teilzahlung (€)", "Bezahlt", "Bilanzierung", "Anteilsfaktor", "Verbrauchsdatum", "Zahlungsdatum", "Kommentar"];
    tabEntryHeights = zeros(100,1) + 30;

    %% setup tab
    tabLayout = uigridlayout(tab, tabGrid);
    tabLayout.RowHeight = tabRowHeights;

    %header
    nHeaderCols = length(tabColWidths);
    headerLayout = uigridlayout(tabLayout, [1, nHeaderCols]);
    headerLayout.Padding = [0 0 0 0];
    headerLayout.ColumnWidth = tabColWidths;    
    headerLabels = cell(length(headerTexts), 1);
    for headerNum = 1:length(headerTexts)
        headerLabels{headerNum} = uilabel(headerLayout, "Text", headerTexts(headerNum));  
    end

    %horizontal line
    hAxes = uiaxes(tabLayout, "Visible", "off", "FontSize",0.01);
    line(hAxes, [0 1], [0 0], "Color", "black")

    %entry list
    nGridRows = 100;
    nGridCols = nHeaderCols;

    entryListLayout = uigridlayout(tabLayout, [nGridRows, nGridCols]);
    entryListLayout.Padding = [0 0 0 0];
    entryListLayout.ColumnWidth = tabColWidths;
    entryListLayout.RowHeight = tabEntryHeights;
    entryListLayout.Scrollable = "on";        

    addButton = uibutton(entryListLayout, "Text", "+");
    addButton.Layout.Row = 1;
    addButton.Layout.Column = [1 nGridCols-1];

    %% pack content
    tabElements = struct( ...
        "tab", tab, ...
        "addButton", addButton, ...
        "entryListLayout", entryListLayout, ...
        "dateToday", dateToday);
end