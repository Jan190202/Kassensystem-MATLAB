function tabElements = buildAdjPriTab(tab)
    %% initialize needed variables
    dateTimeFormat = "eeee, dd.MM.yyyy";
    
    %% create table
    tableGrid = uigridlayout(tab, [1 1]);
    pricingTable = uitable(tableGrid, "ColumnEditable", true);

    %% pack content
    tabElements = struct( ...
        "tab", tab, ...
        "pricingTable", pricingTable, ...
        "dateTimeFormat", dateTimeFormat);
end