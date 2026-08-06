function [changes, returnState] = editPricingManually(lowerButtons, tabElements, data)
    progressDlg = uiprogressdlg(tabElements.tab.Parent.Parent.Parent, "Indeterminate", "on");

    % data
    tab             = tabElements.tab;
    pricingTable    = tabElements.pricingTable;
    dateTimeFormat  = tabElements.dateTimeFormat;
    prePricing      = data.pricing;
    postPricing     = data.pricing;

    %% declare needed variables
    expandedPricing = [];
    changedIDs      = [];
    deletedIDs      = [];
    processFinished = false;

    initializeElements()

    %% callbacks
    lowerButtons.abortButton.ButtonPushedFcn    = @exit;
    lowerButtons.applyButton.ButtonPushedFcn    = @apply;
    lowerButtons.saveButton.ButtonPushedFcn     = @save;
    tab.Parent.SelectionChangedFcn              = @discard;
    pricingTable.CellEditCallback               = @tableEdited;
    
    close(progressDlg)

    %% wait for process to end
    while ~processFinished
        pause(0.05)
    end

    %% helper functions
    function initializeElements()
        deleteColumn = table(false(height(prePricing),1));
        deleteColumn.Properties.VariableNames = "Loeschen";
        expandedPricing = [deleteColumn prePricing];

        refreshTable()
    end

    function refreshTable()
        pricingTable.Data = expandedPricing;
        pricingTable.Data.Erfassungsdatum.Format = dateTimeFormat;
    end

    function deleteSelectedRows()
        deletedIDs = [deletedIDs; expandedPricing.ID(expandedPricing.Loeschen)];
        expandedPricing(expandedPricing.Loeschen,:) = [];
        refreshTable()
    end

    function addChanges()
        postPricing = expandedPricing(:, 2:end); %everything except deleteSelection
    
        if any(changedIDs)
            changes.pricing.added = postPricing(ismember(postPricing.ID, changedIDs),:);
            changes.pricing.deleted = prePricing(ismember(prePricing.ID, [changedIDs; deletedIDs]),:);
        elseif any(deletedIDs)
            changes.pricing.deleted = prePricing(ismember(prePricing.ID, [changedIDs; deletedIDs]),:);
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

        expandedPricing{row, column} = eventData.NewData;
        if column ~= 1 % delete button
            changedIDs = [changedIDs; expandedPricing.ID(row)];
        end  
    end
end