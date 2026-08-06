function [newChanges, returnState] = editChangesManually(lowerButtons, tab, changes)
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

    %% initialize needed variables
    uniqueNames = getUniqueElements();
    filterNameList = ["Alle"; uniqueNames];
    dateTimeFormat = "eeee, dd.MM.yyyy";
    
    deleteColumn = table(false(height(changes),1));
    deleteColumn.Properties.VariableNames = "Loeschen";
    consumptionExpanded = [deleteColumn changes];

    %% initial elements
    if isempty(tab.UserData)
        initName = filterNameList(1);
    else
        if any(filterNameList == tab.UserData)
            initName = tab.UserData;
        else
            initName = filterNameList(1);
        end
    end
    initDateMenuActive = false;
    initFontSize = 15;

    %% configure button callbacks for current tab
    lowerButtons.abortButton.ButtonPushedFcn = @exit;
    lowerButtons.applyButton.ButtonPushedFcn = @apply;
    lowerButtons.saveButton.ButtonPushedFcn = @save;

    %% configure tabChange of tabGroup to exit function
    tab.Parent.SelectionChangedFcn = @discard;
   
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
                                    "FirstDateSelect",  uidatepicker(filterDateMenuLayout, "DisplayFormat", dateTimeFormat, "Enable", initDateMenuActive, "ValueChangedFcn", @filterFirstDateChanged), ...                                 
                                    "ToTextLabel",      uilabel(filterDateMenuLayout, "Text", "bis:", "HorizontalAlignment", "right"), ...                                
                                    "SecondDateSelect", uidatepicker(filterDateMenuLayout, "DisplayFormat", dateTimeFormat, "Enable", initDateMenuActive, "ValueChangedFcn", @filterSecondDateChanged));

    % filter
    filterElements =     struct("NameSelect",           uidropdown(filterLayout, "Items", filterNameList, "Value", initName, "FontSize", initFontSize, "ValueChangedFcn", @filterNameChanged), ...       
                                "DateMenuActiveSelect", uicheckbox(filterLayout, "Value", initDateMenuActive, "Text", "", "ValueChangedFcn", @filterDateMenuActiveChanged), ...
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
    
    % seperation line
    hAxes1 = uiaxes(tabLayout, "FontSize", 0.01, "Visible", "off");
    hLine1 = line(hAxes1, [0 1], [0 0], "Color", "black");
    hAxes1.Layout.Row = 2;
    hAxes1.Layout.Column = 1;

    % table
    tableElements = struct("Table", uitable(tableLayout, "Data", consumptionExpanded, "ColumnEditable", true, "CellEditCallback", @tableEdited));


    %% startup operation

    filterNameChanged(filterElements.NameSelect, 0, 0);

    processFinished = false;
    while ~processFinished
        pause(0.05)
    end

    newChanges = consumptionExpanded(:,2:end); %everything except deleteSelection


    %% bottom button + tab group callbacks

    function exit(~, ~, ~)
        returnState = "exit";
        processFinished = true;
    end

    function apply(~, ~, ~)
        deleteSelectedRows()
        returnState = "apply";
        processFinished = true;
    end

    function save(~, ~, ~)
        deleteSelectedRows()
        returnState = "save";
        processFinished = true;
    end

    function discard(~, ~, ~)
        returnState = "discard";
        processFinished = true;
    end

    %% helper functions

    function names = getUniqueElements()
        names = string(unique(changes.Name));
    end

    function [firstDate, secondDate] = getDates(selectedName)
        if selectedName == "Alle"
            allDates = changes.Verbrauchsdatum;
        else
            allDates = changes.Verbrauchsdatum(changes.Name == selectedName);
        end
        firstDate = min(allDates);
        secondDate = max(allDates);
    end

    function deleteSelectedRows()
        consumptionExpanded(consumptionExpanded.Loeschen,:) = [];
        refreshTable()
    end

    function refreshTable()
        name = string(filterElements.NameSelect.Value);
        firstDate = filterElements.DateMenu.FirstDateSelect.Value;
        secondDate = filterElements.DateMenu.SecondDateSelect.Value;
        
        if name == "Alle"
            nameFilter = true;
        else
            nameFilter = consumptionExpanded.Name == name;
        end
        dateFilter = consumptionExpanded.Verbrauchsdatum >= firstDate & consumptionExpanded.Verbrauchsdatum <= secondDate;
        tableFilter = nameFilter & dateFilter;

        % set filtered table
        filteredTable = consumptionExpanded(tableFilter, :);
        tableElements.Table.Data = filteredTable;
        tableElements.Table.Data.Verbrauchsdatum.Format = dateTimeFormat;
        tableElements.Table.Data.Erfassungsdatum.Format = dateTimeFormat;
        tableElements.Table.Data.Zahlungsdatum.Format = dateTimeFormat;
    end

    %% callback functions
    function filterNameChanged(dropDownHandle, ~, ~)
        name = string(dropDownHandle.Value);

        [firstDate, secondDate] = getDates(name);
        filterElements.DateMenu.FirstDateSelect.Value = firstDate;
        filterElements.DateMenu.SecondDateSelect.Value = secondDate;

        refreshTable()   

        % set as UserData of tab to take it as initial when new operation starts
        tab.UserData = name;
    end

    function filterFirstDateChanged(datePickerHandle, eventData, ~)
        isActive = filterElements.DateMenuActiveSelect.Value;
        if ~isActive
            return
        else
            firstDate = datePickerHandle.Value;
            secondDate = filterElements.DateMenu.SecondDateSelect.Value;

            if firstDate > secondDate
                datePickerHandle.Value = eventData.PreviousValue;
            else
                refreshTable()
            end
        end
    end

    function filterSecondDateChanged(datePickerHandle, ~, ~)
        isActive = filterElements.DateMenuActiveSelect.Value;
        if ~isActive
            return
        else
            firstDate = filterElements.DateMenu.FirstDateSelect.Value;
            secondDate = datePickerHandle.Value;
            
            if secondDate < firstDate
                datePickerHandle.Value = eventData.PreviousValue;
            else
                refreshTable()
            end
        end
    end

    function filterDateMenuActiveChanged(checkBoxHandle, ~, ~)
        isActive = logical(checkBoxHandle.Value);

        filterElements.DateMenu.FirstDateSelect.Enable = isActive;
        filterElements.DateMenu.SecondDateSelect.Enable = isActive;

        if ~isActive
            % reset dates to full range
            [firstDate, secondDate] = getDates(string(filterElements.NameSelect.Value));
            filterElements.DateMenu.FirstDateSelect.Value = firstDate;
            filterElements.DateMenu.SecondDateSelect.Value = secondDate;

            refreshTable()
        end
    end

    function tableEdited(~, eventData, ~)
        row = eventData.Indices(1);
        column = eventData.Indices(2);

        name = string(filterElements.NameSelect.Value);
        firstDate = filterElements.DateMenu.FirstDateSelect.Value;
        secondDate = filterElements.DateMenu.SecondDateSelect.Value;
        
        if name == "Alle"
            nameFilter = true;
        else
            nameFilter = consumptionExpanded.Name == name;
        end
        dateFilter = consumptionExpanded.Verbrauchsdatum >= firstDate & consumptionExpanded.Verbrauchsdatum <= secondDate;
        tableFilter = nameFilter & dateFilter;

        originalRow = find(tableFilter, row); 
        originalRow = originalRow(end); % tableData is subset of consumption using tableFilter. nth row of tableData is row of nth true value in tableFilter

        consumptionExpanded{originalRow, column} = eventData.NewData;
    end
end

