function [changes, returnState] = showLog(lowerButtons, tabElements, data)
    progressDlg = uiprogressdlg(tabElements.tab.Parent.Parent.Parent, "Indeterminate", "on");

    %% data
    tab                 = tabElements.tab;
    filterElements      = tabElements.filterElements;
    tableElements       = tabElements.tableElements;
    dateTimeFormat      = tabElements.dateTimeFormat;
    displayedVariables  = tabElements.displayedVariables;
    preLogText          = data.logText;
    postLogText         = data.logText;
    preLogDetails       = data.logDetails;

    %% declare needed variables
    isDetailedActive    = [];
    isDateMenuActive    = [];
    activeTable         = [];
    tableFilter         = [];
    sortingVector       = [];
    typeList            = [];
    type                = [];
    refinementList      = [];
    refinement          = [];
    firstDate           = [];
    secondDate          = [];
    changedIDs          = [];
    processFinished     = false;

    initializeElements()

    %% callbacks
    lowerButtons.abortButton.ButtonPushedFcn                    = @exit;
    lowerButtons.applyButton.ButtonPushedFcn                    = @apply;
    lowerButtons.saveButton.ButtonPushedFcn                     = @save;
    tab.Parent.SelectionChangedFcn                              = @discard;
    filterElements.TypeSelect.FirstSelect.ValueChangedFcn       = @filterTypeSelectChanged;
    filterElements.TypeSelect.SecondSelect.ValueChangedFcn      = @filterRefinementSelectChanged;
    filterElements.DetailedSelect.ValueChangedFcn               = @filterDetailSelectActiveChanged;
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
        isDetailedActive = logical(filterElements.DetailedSelect.Value);

        if ~isDetailedActive % normal view
            activeTable = preLogText;
        else % detailed view
            activeTable = preLogDetails;
        end 

        if height(activeTable) == 0 %case: empty log -> stop operation
            close(progressDlg)
            discard(0,0,0)
            pause(1)
            return
        end

        refreshTypes();
        if ~isempty(tab.UserData) && any(typeList == tab.UserData.type)
            type = tab.UserData.type;
        else
            type = typeList(1);
        end
        filterElements.TypeSelect.FirstSelect.Value = type;

        refreshRefinements();
        if ~isempty(tab.UserData) && any(refinementList == tab.UserData.refinement)
            refinement = tab.UserData.refinement;
        else
            refinement = refinementList(1);
        end
        filterElements.TypeSelect.SecondSelect.Value = refinement;

        isDateMenuActive = logical(filterElements.DateMenuActiveSelect.Value);
        refreshDates();
        refreshTable()
    end

    function refreshTypes()
        typeList = ["Alle"; string(unique(activeTable.Typ))];
        filterElements.TypeSelect.FirstSelect.Items = typeList;
    end

    function refreshRefinements()
        if ~isDetailedActive && (type == "Verbrauch" || type == "Bilanz")
            refinementList = ["Alle"; string(unique(activeTable.Verfeinerung(activeTable.Typ == type)))];
            filterElements.TypeSelect.SecondSelect.Enable = true;
            filterElements.TypeSelect.SecondSelect.Items = refinementList;
            refinement = filterElements.TypeSelect.SecondSelect.Value;
        else
            refinementList = "";
            filterElements.TypeSelect.SecondSelect.Enable = false;
            filterElements.TypeSelect.SecondSelect.Items = refinementList;
            refinement = filterElements.TypeSelect.SecondSelect.Value;
        end
    end

    function refreshDates()
        if type == "Alle"
            filter = true(height(activeTable),1);
        elseif ~isempty(refinementList) % detailsActive or Preisliste
            filter = activeTable.Typ == type;
        else
            filter = activeTable.Typ == type & activeTable.Verfeinerung == refinement;
        end
        allDates = activeTable.Datum(filter);

        firstDate = min(allDates);
        secondDate = max(allDates);

        filterElements.DateMenu.FirstDateSelect.Value = firstDate;
        filterElements.DateMenu.SecondDateSelect.Value = secondDate;
    end

    function refreshTable()
        % filter table
        if type == "Alle"
            typeFilter = true;
        else
            typeFilter = activeTable.Typ == type;
        end

        if refinement == "Alle" || isempty(refinement) || refinement == ""
            refinementFilter = true;
        else
            refinementFilter = activeTable.Verfeinerung == refinement;
        end

        dateFilter = activeTable.Datum >= firstDate & activeTable.Datum <= secondDate;
        
        tableFilter = typeFilter & refinementFilter & dateFilter;
        filteredTable = activeTable(tableFilter, :);

        % sort table
        [sortedFilteredTable, sortingVector] = sortrows(filteredTable, ["Datum", "Typ", "ID"], "descend");

        % set sorted filtered table
        tableElements.Table.Data = sortedFilteredTable(:, displayedVariables);
        tableElements.Table.Data.Datum.Format = dateTimeFormat;

        if ~isDetailedActive %normal view
            tableElements.Table.ColumnEditable = tableElements.Table.Data.Properties.VariableNames == "Kommentar";
        else %detailed view
            tableElements.Table.ColumnEditable = false;
        end
    end

    function addChanges()
        if ~isempty(changedIDs)
            changes.logText.deleted = preLogText(ismember(preLogText.ID, changedIDs),:);
            changes.logText.added   = postLogText(ismember(postLogText.ID, changedIDs),:);
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
        addChanges()
        processFinished = true;
    end

    function save(~, ~, ~)
        returnState = "save";
        addChanges()
        processFinished = true;
    end

    function discard(~, ~, ~)
        returnState = "discard";
        addChanges()
        processFinished = true;
    end

    %% callback functions
    function filterTypeSelectChanged(dropDownHandle, ~, ~)
        type = string(dropDownHandle.Value);
        refreshRefinements()
        refreshDates()
        refreshTable()   

        tab.UserData.type = type;
        tab.UserData.refinement = refinement;
    end

    function filterRefinementSelectChanged(dropDownHandle, ~, ~)
        refinement = string(dropDownHandle.Value);
        refreshDates()
        refreshTable()   

        tab.UserData.type = type;
        tab.UserData.refinement = refinement;
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

    function filterDetailSelectActiveChanged(checkBoxHandle, ~, ~)
        isDetailedActive = logical(checkBoxHandle.Value);
        if ~isDetailedActive
            activeTable = postLogText;
        else
            activeTable = preLogDetails; % logDetails cannot be changed
        end

        refreshTypes()
        refreshRefinements()
        refreshDates()
        refreshTable()
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

        postLogText{originalRow, displayedVariables(column)} = eventData.NewData;
        changedIDs = [changedIDs; postLogText.ID(originalRow)];
    end
end

