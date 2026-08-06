function tabElements = buildAdjBalTab(tab)
    %% initialize needed variables
    dateTimeFormat = "eeee, dd.MM.yyyy";

    %% create table
    tableGrid = uigridlayout(tab, [1 1]);
    balanceTable = uitable(tableGrid, "ColumnEditable", true);

    %% pack content
    tabElements = struct( ...
        "tab", tab, ...
        "balanceTable", balanceTable, ...
        "dateTimeFormat", dateTimeFormat);
end