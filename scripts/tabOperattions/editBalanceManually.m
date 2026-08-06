function [changes, returnState] = editBalanceManually(lowerButtons, tabElements, data)
    progressDlg = uiprogressdlg(tabElements.tab.Parent.Parent.Parent, "Indeterminate", "on");

    % data
    tab             = tabElements.tab;
    balanceTable    = tabElements.balanceTable;
    dateTimeFormat  = tabElements.dateTimeFormat;
    preBalance      = data.balance;
    postBalance     = data.balance;
    
    %% declare needed variables
    expandedBalance = [];
    changedIDs      = [];
    deletedIDs      = [];
    processFinished = false;

    initializeElements()

    %% callbacks
    lowerButtons.abortButton.ButtonPushedFcn    = @exit;
    lowerButtons.applyButton.ButtonPushedFcn    = @apply;
    lowerButtons.saveButton.ButtonPushedFcn     = @save;
    tab.Parent.SelectionChangedFcn              = @discard;
    balanceTable.CellEditCallback               = @tableEdited;

    close(progressDlg)

    %% wait for process to end
    while ~processFinished
        pause(0.05)
    end

    %% helper functions
    function initializeElements()
        deleteColumn = table(false(height(preBalance),1));
        deleteColumn.Properties.VariableNames = "Loeschen";
        expandedBalance = [deleteColumn preBalance];

        refreshTable()
    end

    function refreshTable()
        balanceTable.Data = expandedBalance;
        balanceTable.Data.Erfassungsdatum.Format = dateTimeFormat;
    end

    function deleteSelectedRows()
        deletedIDs = [deletedIDs; expandedBalance.ID(expandedBalance.Loeschen)];
        expandedBalance(expandedBalance.Loeschen,:) = [];
        refreshTable()
    end

    function addChanges()
        postBalance = expandedBalance(:, 2:end); %everything except deleteSelection
    
        if any(changedIDs)
            changes.balance.added = postBalance(ismember(postBalance.ID, changedIDs),:);
            changes.balance.deleted = preBalance(ismember(preBalance.ID, [changedIDs; deletedIDs]),:);
        elseif any(deletedIDs)
            changes.balance.deleted = preBalance(ismember(preBalance.ID, [changedIDs; deletedIDs]),:);
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
    function tableEdited(~, eventData, ~)
        row     = eventData.Indices(1);
        column  = eventData.Indices(2);

        expandedBalance{row, column} = eventData.NewData;
        if column ~= 1 % delete button
            changedIDs = [changedIDs; expandedBalance.ID(row)];
        end  
    end
end