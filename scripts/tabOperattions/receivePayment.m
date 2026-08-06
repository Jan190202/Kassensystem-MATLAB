function [changes, returnState] = receivePayment(lowerButtons, tabElements, data)
    progressDlg = uiprogressdlg(tabElements.tab.Parent.Parent.Parent, "Indeterminate", "on");

    %% data
    tab                 = tabElements.tab;
    filterElements      = tabElements.filterElements;
    tableElements       = tabElements.tableElements;
    infoElements        = tabElements.infoElements;
    paymentElements     = tabElements.paymentElements;
    dateTimeFormat      = tabElements.dateTimeFormat;
    dateToday           = tabElements.dateToday;
    displayedVariables  = tabElements.displayedVariables;
    styleBgRed          = tabElements.styleBgRed;
    styleBgGreen        = tabElements.styleBgGreen;
    styleBgYellow       = tabElements.styleBgYellow;
    preConsumption      = data.consumption;
    postConsumption     = data.consumption;
    preSavings          = data.savings;
    postSavings         = data.savings;

    %% initialize needed variables
    isDateMenuActive        = [];
    isPayAllActive          = [];
    isUseSavingsActive      = [];
    isSaveSurplusActive     = [];
    isPayAllActiveInit      = [];
    isUseSavingsActiveInit  = [];
    isSaveSurplusActiveInit = [];
    filteredTable           = []; % filtered
    sortedFilteredTable     = []; % filtered, sorted
    displayedTable          = []; % filtered, sorted, trimmed
    tableFilter             = [];
    nameList                = [];
    name                    = [];
    totalAmount             = [];
    paidAmount              = [];
    dueAmount               = [];
    savingsAmount           = [];
    firstDate               = [];
    secondDate              = [];
    paymentSpinnerValue     = [];
    tipID                   = [];
    changedConsumptionIDs   = [];
    addedSavingsIDs         = [];
    deletedSavingsIDs       = [];
    changes                 = struct;
    processFinished         = false;

    initializeElements()

    %% callbacks
    lowerButtons.abortButton.ButtonPushedFcn                    = @exit;
    lowerButtons.applyButton.ButtonPushedFcn                    = @apply;
    lowerButtons.saveButton.ButtonPushedFcn                     = @save;
    tab.Parent.SelectionChangedFcn                              = @discard;
    filterElements.DateMenu.FirstDateSelect.ValueChangedFcn     = @filterFirstDateChanged;
    filterElements.DateMenu.SecondDateSelect.ValueChangedFcn    = @filterSecondDateChanged;
    filterElements.NameSelect.ValueChangedFcn                   = @filterNameChanged;
    filterElements.DateMenuActiveSelect.ValueChangedFcn         = @filterDateMenuActiveChanged;
    paymentElements.PayAllSelect.ValueChangedFcn                = @payAllChanged;
    paymentElements.SaveSurplusSelect.ValueChangedFcn           = @saveSurplusChanged; 
    paymentElements.UseSavingsSelect.ValueChangedFcn            = @useSavingsChanged; 
    paymentElements.PaymentSelect.ValueChangedFcn               = @paymentChanged;

    close(progressDlg)
       
    %% wait for process to end
    while ~processFinished
        pause(0.05)
    end

    %% helper functions
    function initializeElements()
        refreshNames()
        if isempty(tab.UserData)
            if ~isempty(nameList)
                name = nameList(1);
            else
                return
            end
        else
            name = tab.UserData;
        end
        filterElements.NameSelect.Value = name;
        
        isDateMenuActive = logical(filterElements.DateMenuActiveSelect.Value);
        refreshDates();

        isPayAllActiveInit      = logical(paymentElements.PayAllSelect.Value);
        isSaveSurplusActiveInit = logical(paymentElements.SaveSurplusSelect.Value);
        isUseSavingsActiveInit  = logical(paymentElements.UseSavingsSelect.Value);
        resetCheckBoxes()

        refreshTable()
        refreshAmounts() 
        refreshSpinner()
    end

    function refreshNames()
        nameList = string(unique(preConsumption.Name));
        filterElements.NameSelect.Items = nameList;
    end

    function refreshDates()
        allDates = preConsumption.Verbrauchsdatum(preConsumption.Name == name);

        firstDate = min(allDates);
        secondDate = max(allDates);

        filterElements.DateMenu.FirstDateSelect.Value = firstDate;
        filterElements.DateMenu.SecondDateSelect.Value = secondDate;
    end
    
    function refreshTable()
        % filter table
        nameFilter = preConsumption.Name == name;
        dateFilter = preConsumption.Verbrauchsdatum >= firstDate & preConsumption.Verbrauchsdatum <= secondDate;
        tableFilter = nameFilter & dateFilter;
        filteredTable = preConsumption(tableFilter , :);

        % sort table
        [sortedFilteredTable, ~] = sortrows(filteredTable, ["Verbrauchsdatum", "ID"], "descend");

        % set sorted filtered table
        displayedTable = sortedFilteredTable(:, displayedVariables);
        tableElements.Table.Data = displayedTable;
        tableElements.Table.Data.Verbrauchsdatum.Format = dateTimeFormat;

        redRows     = find(displayedTable.Bezahlt == 0);
        yellowRows  = find(displayedTable.Bezahlt > 0 & displayedTable.Bezahlt < displayedTable.Gesamt);
        greenRows   = find(displayedTable.Bezahlt == displayedTable.Gesamt);
        if ~isempty(redRows)
            addStyle(tableElements.Table, styleBgRed, "row", redRows)
        end
        if ~isempty(yellowRows)
            addStyle(tableElements.Table, styleBgYellow, "row", yellowRows)
        end
        if ~isempty(greenRows)
            addStyle(tableElements.Table, styleBgGreen, "row", greenRows)
        end
    end

    function refreshAmounts()
        totalAmount = sum(displayedTable.Gesamt);
        paidAmount = sum(displayedTable.Bezahlt);
        dueAmount = totalAmount - paidAmount;
        savingsAmount = preSavings.Guthaben(preSavings.Name == name);
        if isempty(savingsAmount)
            savingsAmount = 0;
        end

        infoElements.TotalAmountLabel.Text = formatCost(totalAmount);
        infoElements.PaidAmountLabel.Text = formatCost(paidAmount);
        infoElements.DueAmountLabel.Text = formatCost(dueAmount);
        infoElements.SavingsAmountLabel.Text = formatCost(savingsAmount);
    end

    function resetCheckBoxes()
        isPayAllActive      = isPayAllActiveInit;
        isSaveSurplusActive = isSaveSurplusActiveInit;
        isUseSavingsActive  = isUseSavingsActiveInit;

        paymentElements.PayAllSelect.Value      = isPayAllActiveInit;
        paymentElements.SaveSurplusSelect.Value = isSaveSurplusActiveInit;
        paymentElements.UseSavingsSelect.Value  = isUseSavingsActiveInit;
    end

    function refreshSpinner()
        if isPayAllActive
            paymentSpinnerValue = dueAmount;  
        elseif isUseSavingsActive
            paymentSpinnerValue = min([savingsAmount, dueAmount]); % paying with savings, uses up dueAmount at a maximum
        else
            paymentSpinnerValue = 0.00;
        end
        paymentElements.PaymentSelect.Value = paymentSpinnerValue;
        paymentElements.PaymentSelect.Enable = ~(isPayAllActive | isUseSavingsActive);
    end

    function processPayment()
        % loop through unpaid entries and pay until paymentValue is fully used
        totalEntries = sortedFilteredTable.Gesamt;
        paidEntries = sortedFilteredTable.Bezahlt;
        dueEntries = totalEntries - paidEntries;
        IDsToBePaid = flip(sortedFilteredTable.ID(dueEntries > 0)); % flip, so that entries are paid bottom up in displayedTable

        paymentCounter = 0;
        for ID = IDsToBePaid' %loop through entry numbers which arent paid fully
            isID = preConsumption.ID == ID;
            isIDFiltered = sortedFilteredTable.ID == ID;
            paymentLeft = paymentSpinnerValue - paymentCounter;
            dueInEntry = dueEntries(isIDFiltered);

            if paymentLeft >= dueInEntry
                paymentCounter = paymentCounter + dueInEntry;
                postConsumption.Bezahlt(isID) = postConsumption.Gesamt(isID);
                postConsumption.Abbezahlt(isID) = "Ja";
                postConsumption.Zahlungsdatum(isID) = dateToday;
            elseif dueInEntry > paymentLeft && paymentLeft > 0
                paymentCounter = paymentSpinnerValue;
                postConsumption.Bezahlt(isID) =  postConsumption.Bezahlt(isID) + paymentLeft;
            else
                break %paymentLeft == 0
            end

            changedConsumptionIDs = [changedConsumptionIDs; ID]; 
        end

        if isUseSavingsActive
            changeSavings(-paymentCounter)
        end

        leftOverAmount = paymentSpinnerValue - paymentCounter; % create tip entry if member paid more than what was due in total
        if leftOverAmount > 0
            if isSaveSurplusActive
                % add to savings
                changeSavings(leftOverAmount)
            else
                % tip value
                tipID = getID(preConsumption.ID);
                tipEntry = {tipID, name, "EUR", 1, leftOverAmount, 1, leftOverAmount, leftOverAmount, "Ja", ...
                            getWeekday(dateToday), dateToday, dateToday, dateToday, NaT, ...
                            "Ja", 1, leftOverAmount, 0, "Nein", "Trinkgeld"};
                postConsumption = [postConsumption; tipEntry];
            end
        end
                
        % for easier logging (see addLogEntries)
        changes.paymentValue = paymentSpinnerValue;
        changes.isSaveSurplusActive = isSaveSurplusActive;
        changes.leftOverAmount = leftOverAmount;
        changes.isUseSavingsActive = isUseSavingsActive;
    end

    function changeSavings(difference)
        if savingsAmount == 0 && ~any(preSavings.Name == name) % should be same statement, but to be shure
            % create new entry
            savingsID = getID(preSavings.ID);
            savingsEntry = {savingsID, name, difference, dateToday};
            postSavings = [postSavings; savingsEntry];
            
            addedSavingsIDs = [addedSavingsIDs; savingsID];
        else
            % change/delete existing entry
            changedID = preSavings.ID(preSavings.Name == name);
            oldSavingsAmount = preSavings.Guthaben(preSavings.Name == name);
            newSavingsAmount = oldSavingsAmount + difference;

            if newSavingsAmount > 0
                postSavings.Guthaben(postSavings.Name == name) = newSavingsAmount;
                
                addedSavingsIDs = [addedSavingsIDs; changedID];
                deletedSavingsIDs = [deletedSavingsIDs; changedID];
            elseif newSavingsAmount == 0
                postSavings(postSavings.Name == name, :) = [];

                deletedSavingsIDs = [deletedSavingsIDs; changedID];
            else % newSavingsAmount < 0 
                error("Guthaben negativ!")
            end
        end
    end

    function addChanges()
        % consumption
        deletedEntries  = preConsumption(ismember(preConsumption.ID, changedConsumptionIDs),:);
        addedEntries    = postConsumption(ismember(postConsumption.ID, [changedConsumptionIDs; tipID]),:);
        
        if ~isempty(deletedEntries)
            changes.consumption.deleted = deletedEntries;
        end
        if ~isempty(addedEntries)
            changes.consumption.added = addedEntries;
        end

        % savings
        deletedEntries  = preSavings(ismember(preSavings.ID, deletedSavingsIDs),:);
        addedEntries    = postSavings(ismember(postSavings.ID, addedSavingsIDs),:);
        
        if ~isempty(deletedEntries)
            changes.savings.deleted = deletedEntries;
        end
        if ~isempty(addedEntries)
            changes.savings.added = addedEntries;
        end
    end

    %% button callback functions
    function exit(~, ~, ~)
        addChanges()
        returnState = "exit";
        processFinished = true;
    end

    function apply(~, ~, ~)
        processPayment()
        addChanges()
        resetCheckBoxes()
        returnState = "apply";
        processFinished = true;
    end

    function save(~, ~, ~)
        processPayment()
        addChanges()
        resetCheckBoxes()
        returnState = "save";
        processFinished = true;
    end

    function discard(~, ~, ~)
        addChanges()
        returnState = "discard";
        processFinished = true;
    end

    %% callback functions
    function filterNameChanged(dropDownHandle, ~, ~)
        name = string(dropDownHandle.Value);

        refreshDates()
        refreshTable()   
        refreshAmounts()
        resetCheckBoxes()
        refreshSpinner()

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
                refreshAmounts()
                refreshSpinner()
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
                refreshAmounts()
                refreshSpinner()
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
            refreshSpinner()
        end
    end

    function saveSurplusChanged(checkBoxHandle, ~, ~)
        isSaveSurplusActive = logical(checkBoxHandle.Value);
    end

    function payAllChanged(checkBoxHandle, ~, ~)
        isPayAllActive = logical(checkBoxHandle.Value);
        if isPayAllActive
            isUseSavingsActive = false;
            paymentElements.UseSavingsSelect.Value = false;
        end
        refreshSpinner()
    end

    function useSavingsChanged(checkBoxHandle, ~, ~)
        isUseSavingsActive = logical(checkBoxHandle.Value);
        if isUseSavingsActive
            isPayAllActive = false;
            paymentElements.PayAllSelect.Value = false;
        end
        refreshSpinner()
    end

    function paymentChanged(spinnerHandle, ~, ~)
        paymentSpinnerValue = spinnerHandle.Value;
    end
end

