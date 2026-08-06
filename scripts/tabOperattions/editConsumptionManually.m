function [changes, returnState] = editConsumptionManually(lowerButtons, tabElements, data)
    progressDlg = uiprogressdlg(tabElements.tab.Parent.Parent.Parent, "Indeterminate", "on");

    %% data
    tab                 = tabElements.tab;
    tableElements       = tabElements.tableElements;
    filterElements      = tabElements.filterElements;
    dateTimeFormat      = tabElements.dateTimeFormat;
    preConsumption      = data.consumption;
    postConsumption     = data.consumption;
    
    %% declare needed variables
    expandedConsumption = [];
    tableFilter         = [];
    sortingVector       = [];
    nameList            = [];
    name                = [];
    isDateMenuActive    = [];
    firstDate           = [];
    secondDate          = [];
    changedIDs          = [];
    deletedIDs          = [];
    processFinished     = false;

    initializeElements()

    %% callbacks
    lowerButtons.abortButton.ButtonPushedFcn                    = @exit;
    lowerButtons.applyButton.ButtonPushedFcn                    = @apply;
    lowerButtons.saveButton.ButtonPushedFcn                     = @save;
    tab.Parent.SelectionChangedFcn                              = @discard;
    filterElements.NameSelect.ValueChangedFcn                   = @filterNameChanged;
    filterElements.DateMenuActiveSelect.ValueChangedFcn         = @filterDateMenuActiveChanged;
    filterElements.DateMenu.FirstDateSelect.ValueChangedFcn     = @filterFirstDateChanged;
    filterElements.DateMenu.SecondDateSelect.ValueChangedFcn    = @filterSecondDateChanged;
    tableElements.Table.CellEditCallback                        = @tableEdited;

    close(progressDlg)

    %% wait for process to end
    while ~processFinished
        pause(0.05)
    end

    %% helper functions
    function initializeElements()
        refreshNames()
        if isempty(tab.UserData)
            if length(nameList) >= 2
                name = nameList(1);
            else
                return  % only "Alle" entry
            end
        else
            if any(nameList == tab.UserData)
                name = tab.UserData;
            else
                name = nameList(1);
            end
        end
        filterElements.NameSelect.Value = name;

        deleteColumn = table(false(height(preConsumption),1));
        deleteColumn.Properties.VariableNames = "Loeschen";
        expandedConsumption = [deleteColumn preConsumption];

        isDateMenuActive = logical(filterElements.DateMenuActiveSelect.Value);
        refreshDates()
        refreshTable()
    end

    function refreshNames()
        nameList = ["Alle"; string(unique(preConsumption.Name))];
        filterElements.NameSelect.Items = nameList;
    end

    function refreshDates()
        if name == "Alle"
            allDates = preConsumption.Verbrauchsdatum;
        else
            allDates = preConsumption.Verbrauchsdatum(preConsumption.Name == name);
        end

        firstDate = min(allDates);
        secondDate = max(allDates);

        filterElements.DateMenu.FirstDateSelect.Value = firstDate;
        filterElements.DateMenu.SecondDateSelect.Value = secondDate;
    end

    function refreshTable()
        % filter table
        if name == "Alle"
            nameFilter = true;
        else
            nameFilter = expandedConsumption.Name == name;
        end

        dateFilter = expandedConsumption.Verbrauchsdatum >= firstDate & expandedConsumption.Verbrauchsdatum <= secondDate;
        
        tableFilter = nameFilter & dateFilter;
        filteredTable = expandedConsumption(tableFilter, :);

        % sort table
        [sortedFilteredTable, sortingVector] = sortrows(filteredTable, ["Verbrauchsdatum", "ID"], "descend");

        % set sorted filtered table
        tableElements.Table.Data = sortedFilteredTable;
        tableElements.Table.Data.Verbrauchsdatum.Format = dateTimeFormat;
        tableElements.Table.Data.Erfassungsdatum.Format = dateTimeFormat;
        tableElements.Table.Data.Zahlungsdatum.Format = dateTimeFormat;
    end

    function deleteSelectedRows()
        deletedIDs = [deletedIDs; expandedConsumption.ID(expandedConsumption.Loeschen)];
        expandedConsumption(expandedConsumption.Loeschen,:) = [];
        refreshTable()
    end

    function addChanges()
        postConsumption = expandedConsumption(:, 2:end); %everything except deleteSelection
    
        if any(changedIDs)
            changes.consumption.added = postConsumption(ismember(postConsumption.ID, changedIDs),:);
            changes.consumption.deleted = preConsumption(ismember(preConsumption.ID, [changedIDs; deletedIDs]),:);
        elseif any(deletedIDs)
            changes.consumption.deleted = preConsumption(ismember(preConsumption.ID, [changedIDs; deletedIDs]),:);
        else
            changes = struct;
        end
    end

    %% button callback functions
    function exit(~, ~, ~)
        returnState = "exit";
        addChanges()
        processFinished = true;
    end

    function apply(~, ~, ~)
        returnState = "apply";
        deleteSelectedRows()
        addChanges()
        processFinished = true;
    end

    function save(~, ~, ~)
        returnState = "save";
        deleteSelectedRows()
        addChanges()
        processFinished = true;
    end

    function discard(~, ~, ~)
        returnState = "discard";
        addChanges()
        processFinished = true;
    end

    %% callback functions
    function filterNameChanged(dropDownHandle, ~, ~)
        name = string(dropDownHandle.Value);
        refreshDates()
        refreshTable()   

        tab.UserData = name;
    end

    function filterFirstDateChanged(datePickerHandle, eventData, ~)
        if ~isDateMenuActive
            return
        else
            firstDate = datePickerHandle.Value;

            if firstDate > secondDate
                prevVal = eventData.PreviousValue;
                datePickerHandle.Value = prevVal;
                firstDate = prevVal;
            else
                refreshTable()
            end
        end        
    end

    function filterSecondDateChanged(datePickerHandle, eventData, ~)
        if ~isDateMenuActive
            return
        else
            secondDate = datePickerHandle.Value;
            
            if secondDate < firstDate
                prevVal = eventData.PreviousValue;
                datePickerHandle.Value = prevVal;
                secondDate = prevVal;
            else
                refreshTable()
            end
        end
    end

    function filterDateMenuActiveChanged(checkBoxHandle, ~, ~)
        isDateMenuActive = logical(checkBoxHandle.Value);
        filterElements.DateMenu.FirstDateSelect.Enable = isDateMenuActive;
        filterElements.DateMenu.SecondDateSelect.Enable = isDateMenuActive;

        if ~isDateMenuActive            
            refreshDates();
            refreshTable()
        end        
    end

    function tableEdited(~, eventData, ~)
        row     = eventData.Indices(1);
        column  = eventData.Indices(2);

        originalRow = retrieveOriginalRow(row, tableFilter, sortingVector);

        expandedConsumption{originalRow, column} = eventData.NewData;
        if column ~= 1 % delete button
            changedIDs = [changedIDs; expandedConsumption.ID(originalRow)];
        end        
    end
end

