function  [changes, returnState] = addEntries(lowerButtons, tabElements, data)
    progressDlg = uiprogressdlg(tabElements.tab.Parent.Parent.Parent, "Indeterminate", "on");

    %% data
    tab                 = tabElements.tab;
    addButton           = tabElements.addButton;
    entryListLayout     = tabElements.entryListLayout;
    dateToday           = tabElements.dateToday;
    consumption         = data.consumption;
    pricing             = data.pricing;
    favourites          = jsondecode(fileread("config\config.json"));

    %% initialize needed variables
    changes                             = struct;
    [nameList, productList, amountList] = getUniqueElements();
    shareFactor                         = 0.15;
    datePickedManually                  = false;
    userDate                            = NaT;
    entries                             = cell(100, 1);
    nEntries                            = 0;
    processFinished                     = false;

    %% callbacks
    lowerButtons.abortButton.ButtonPushedFcn    = @exit;
    lowerButtons.applyButton.ButtonPushedFcn    = @apply;
    lowerButtons.saveButton.ButtonPushedFcn     = @save;
    tab.Parent.SelectionChangedFcn              = @discard;
    addButton.ButtonPushedFcn                   = @addEntryButtonPressed;

    close(progressDlg)

    %% wait for process to end
    while ~processFinished
        pause(0.05)
    end

    %% helper functions
    function entry = createEntry()
        initName                = getInitName();
        [initProd, initProdNum] = getInitProduct();
        initAmount              = getInitAmount(initProd);
        initCount               = 1;
        initPaidVal             = 0.00;
        paidValStepSize         = 0.01;
        initPaid                = false;
        initBalance             = true;
        [single, total]         = calcPrices(initProd, initAmount, initCount);
        initCost                = " " + formatCost(total);
        initDate                = getInitDate();
        initFactor              = getInitFactor();
        factorStepSize          = 0.01;
        names                   = [nameList; "+"];
        prodList                = [productList; "+"];
        amounts                 = amountList{initProdNum};

        entry = struct;
        entry.nameSelect         = uidropdown   (entryListLayout, "Value", initName, "Items", names, "UserData", nEntries, "ValueChangedFcn", @nameChanged, "CreateFcn", @nameChanged);
        entry.productSelect      = uidropdown   (entryListLayout, "Value", initProd, "Items", prodList, "UserData", nEntries, "ValueChangedFcn", @productChanged);
        entry.amountSelect       = uidropdown   (entryListLayout, "Value", string(initAmount) , "Items", string(amounts), "UserData", nEntries, "ValueChangedFcn", @amountChanged);
        entry.countSelect        = uispinner    (entryListLayout, "Value", initCount, "Limits", [1 inf], "UserData", nEntries, "ValueChangedFcn", @countChanged);
        entry.paidValueSelect    = uispinner    (entryListLayout, "Value", initPaidVal, "Limits", [0 total-0.01], "Step", paidValStepSize, "UserData", nEntries);
        entry.paidSelect         = uicheckbox   (entryListLayout, "Value", initPaid, "Text", initCost, "UserData", [nEntries, single, total], "ValueChangedFcn", @paidChanged);
        entry.balanceSelect      = uicheckbox   (entryListLayout, "Value", initBalance, "Text", "", "UserData", nEntries);
        entry.factorSelect       = uispinner    (entryListLayout, "Value", initFactor, "Limits", [0 1], "Step", factorStepSize, "UserData", nEntries);
        entry.dateConsumedSelect = uidatepicker (entryListLayout, "Value", initDate, "DisplayFormat", "eee, d.M", "UserData", nEntries, "ValueChangedFcn", @dateConChanged);
        entry.datePaidSelect     = uidatepicker (entryListLayout, "Value", initDate, "DisplayFormat", "eee, d.M", "UserData", nEntries, "Enable", false);
        entry.commentSelect      = uitextarea   (entryListLayout, "Value", "");
        entry.deleteButton       = uibutton     (entryListLayout, "Text", "-", "ButtonPushedFcn", @deleteEntry, "UserData", nEntries);

        % set layout positions of elements in entry
        entryElementNames = fieldnames(entry);
        for i = 1:length(entryElementNames)
            uiElement = entry.(entryElementNames{i});
            uiElement.Layout.Row = nEntries;
            uiElement.Layout.Column = i;
        end
    end

    function [single, total] = calcPrices(product, amount, count)
        costArray = pricing.Preis;
        single = costArray(pricing.Name == product & pricing.Menge == amount);
        total = single * count;
    end

    function refreshCost(entryNum)
        % get selection details of an entry and refresh cost display
        prod = entries{entryNum}.productSelect.Value;
        amount = str2double(entries{entryNum}.amountSelect.Value);
        count = entries{entryNum}.countSelect.Value;

        [single, total] = calcPrices(prod, amount, count);

        checkBox = entries{entryNum}.paidSelect;
        checkBox.Text = " " + formatCost(total);
        checkBox.UserData = [checkBox.UserData(1), single, total];
        paidChanged(checkBox,0,0)
    end
   
    function resetFigure()
        % reset figure: delete entries, reset initial values, move addBtn back up
        for i = 1:nEntries
            structfun(@(x) delete(x), entries{i})
        end
        entries = cell(100,1);
        nEntries = 0;

        datePickedManually = false;
        userDate = NaT;

        addButton.Layout.Row = 1;
    end

    function appendNewEntries()
        if nEntries == 0
            return
        end

        allocStrings    = strings(nEntries,1);
        allocZeros      = zeros(nEntries,1);
        allocFalse      = false(nEntries,1);
        allocTrue       = true(nEntries,1);
        allocNaT        = NaT(nEntries,1);

        names               = allocStrings;
        products            = allocStrings;
        amounts             = allocZeros;
        counts              = allocZeros;
        isPaid              = allocFalse;
        isPaidStrings       = allocStrings;
        paidValues          = allocZeros;
        isBalance           = allocTrue;
        isBalanceStrings    = allocStrings;
        factors             = allocZeros + shareFactor;
        singles             = allocZeros;
        totals              = allocZeros;
        datesConsumed       = allocNaT;
        datesPaid           = allocNaT;
        datesDeducted       = allocNaT;
        comments            = allocStrings;
        IDs                 = allocZeros;

        for i = 1:nEntries
            names(i)        = entries{i}.nameSelect.Value;
            products(i)     = entries{i}.productSelect.Value;
            amounts(i)      = str2double(entries{i}.amountSelect.Value);
            counts(i)       = entries{i}.countSelect.Value;
            paidValues(i)   = entries{i}.paidValueSelect.Value;
            isPaid(i)       = entries{i}.paidSelect.Value;   
            isBalance(i)    = entries{i}.balanceSelect.Value;
            factors(i)      = entries{i}.factorSelect.Value;
            singles(i)      = entries{i}.paidSelect.UserData(2);
            totals(i)       = entries{i}.paidSelect.UserData(3);
            if isPaid(i)
                datesPaid(i)        = entries{i}.datePaidSelect.Value;
            end
            datesConsumed(i)        = entries{i}.dateConsumedSelect.Value;
            comments(i)             = entries{i}.commentSelect.Value;
            IDs(i)                  = getID([consumption.ID; IDs]); 
        end

        dayConsumedNames = getWeekday(datesConsumed);

        isPaidStrings(isPaid) = "Ja";
        isPaidStrings(~isPaid) = "Nein";

        isBalanceStrings(isBalance) = "Ja";
        isBalanceStrings(~isBalance) = "Nein";

        intShare = totals .* factors;
        extShare = totals - intShare;

        datesAdded = repmat(dateToday, [nEntries, 1]);
        

        comments(comments == "") = "-";
        comments(comments == "Trinkgeld") = "Trinkgeld (manuell)"; % comment "Trinkgeld" would cause problems with logs, see functionaddLogEntries

        settledWithClub = allocStrings + "Nein";

        addedConsumption = table(IDs, names, products, amounts, counts, singles, totals, paidValues, isPaidStrings, dayConsumedNames, datesConsumed, datesAdded, datesPaid, datesDeducted, isBalanceStrings, factors, intShare, extShare, settledWithClub, comments);
        addedConsumption.Properties.VariableNames = consumption.Properties.VariableNames;
        changes.consumption.added = addedConsumption;

        resetFigure() 
    end

    %% button callback functions
    function exit(~, ~, ~)
        resetFigure() 
        returnState = "exit";
        processFinished = true;
    end

    function apply(~, ~, ~)
        appendNewEntries()
        returnState = "apply";
        processFinished = true;
    end

    function save(~, ~, ~)
        appendNewEntries()
        returnState = "save";
        processFinished = true;
    end

    function discard(~, ~, ~)
        resetFigure() 
        returnState = "discard";
        processFinished = true;
    end

    %% callback functions
    function nameChanged(dropDownHandle, eventData, ~)
        if dropDownHandle.Value == "+"
            % if name list is empty and input dialog is canceled, bring up dialog again
            while true
                newName = inputdlg("Neuen Namen hinzufügen:", "Eingabe", [1 50]);
            
                if isempty(newName)
                    if ~isempty(eventData)
                        dropDownHandle.Value = eventData.PreviousValue;
                    else
                        continue
                    end
                else
                    dropDownHandle.Items(end) = newName;
                    dropDownHandle.Value = string(newName);
                end

                break
            end
        end
    end

    function productChanged(dropDownHandle, eventData, ~)
        newProduct = dropDownHandle.Value;
        entryNum = dropDownHandle.UserData;

        if (newProduct == "+")
            % neues Produkt -> 
            % 1. falls nicht für datenbank: "TMP:" vor namen setzen
            % 2. in pricing abspeichern
            % 3. productList und -amounts neu getten
            % bei save: alle elemente mit "TMP:" beginnend erst löschen

            while true % if "save product" dialog is canceled, jump back to input dialog
                answerCell = inputdlg(["Produktbezeichnung", "Menge in l (z.B. 0.5)", "Preis in € (z.B. '3.50')"], "Eingabe", [1 50; 1 50; 1 50]);
                if isempty(answerCell)
                    dropDownHandle.Value = eventData.PreviousValue;
                    break
                elseif isempty(answerCell{1}) || isempty(answerCell{2}) || isempty(answerCell{3})
                    e = errordlg("Mindestens ein Feld nicht bearbeitet!", "Windowstyle", "modal");
                    uiwait(e)
                    dropDownHandle.Value = eventData.PreviousValue;
                    break
                else
                    saveProd = questdlg("Neuen Eintrag in Datenbank speichern?", "Eingabe");
                    if saveProd ~= "Yes" && saveProd ~= "No"
                        continue
                    end
    
                    newID = getID(pricing.ID);
                    newName = string(answerCell{1}); 
                    newAmount = str2double(answerCell{2});
                    newCost = str2double(answerCell{3});
    
                    dropDownHandle.Items(end) = {convertStringsToChars(newName)};
                    dropDownHandle.Value = newName;
                    entries{entryNum}.amountSelect.Items = {convertStringsToChars(string(newAmount))};
                    entries{entryNum}.paidSelect.Text = " " + formatCost(newCost);
    
                    newPricingEntry = table(newID, newName, newAmount, newCost, dateToday);
                    newPricingEntry.Properties.VariableNames = pricing.Properties.VariableNames;
                    if saveProd == "Yes"
                        changes.pricing.added = newPricingEntry;
                    end
                    break
                end
            end

            return
        elseif newProduct == "EUR"
            countSel = entries{entryNum}.countSelect;
            countSel.Limits = [0 inf];
            countSel.Step = 0.01;
            countSel.Step = 1;
        else
            countSel = entries{entryNum}.countSelect;
            countSel.Limits = [1 inf];
            countSel.Step = 1;
            countSel.Value = 1;
        end

        % get associated amount drop down list
        amountSel = entries{entryNum}.amountSelect;

        %get unique amounts of new product
        amounts = amountList{productList == newProduct};

        amountSel.Items = string(amounts);
        amountSel.Value = string(getInitAmount(newProduct));

        % refresh cost
        refreshCost(entryNum)
    end

    function amountChanged(drowDownHandle, ~, ~)
        entryNum = drowDownHandle.UserData;
        refreshCost(entryNum)
    end

    function countChanged(spinnerHandle, ~, ~)
        entryNum = spinnerHandle.UserData;
        refreshCost(entryNum)        
    end

    function paidChanged(checkBoxHandle, ~, ~)
        entryNum = checkBoxHandle.UserData(1);
        total = checkBoxHandle.UserData(3);

        paidValSel = entries{entryNum}.paidValueSelect;
        datePaidSel = entries{entryNum}.datePaidSelect;

        if checkBoxHandle.Value
            paidValSel.Limits = [0 inf];
            paidValSel.Value = total;
            paidValSel.Enable = false;

            datePaidSel.Enable = true;
        else
            paidValSel.Enable = true;
            paidValSel.Value = 0.00;
            paidValSel.Limits = [0 total-0.01];

            datePaidSel.Enable = false;
        end
    end

    function dateConChanged(datePickerHandle, ~, ~)
        datePickedManually = true;
        userDate = datePickerHandle.Value;
    end

    function deleteEntry(buttonHandle, ~, ~)
        entryToDel = buttonHandle.UserData;
        
        % delete every ui element of entry to delete
        structfun(@(x) delete(x), entries{entryToDel})

        % delete cell of deleted entry
        entries(entryToDel,:) = [];
        nEntries = nEntries - 1;

        % decrease row number of every succeeding row by 1
        % decrease the userData of every succeeding row by 1
        for i = entryToDel:nEntries
            structfun(@decreaseRow, entries{i})
            structfun(@decreaseUserData, entries{i})
        end

        % decrease row number of add button
        decreaseRow(addButton)

        function decreaseRow(uiElement)
            uiElement.Layout.Row = uiElement.Layout.Row - 1;
        end
        function decreaseUserData(uiElement)
            uiElement.UserData = uiElement.UserData - 1;
        end
    end

    function addEntryButtonPressed(buttonHandle, ~, ~)
        nEntries = nEntries + 1;

        % add entry
        entries{nEntries} = createEntry();
        
        % move button
        buttonHandle.Layout.Row = nEntries + 1;
    end

    %% initial values
    function initName = getInitName()
        % get initial name for new entry
        % if available, follow order specified in the config file
        % if not available OR if specified name doesn't exist in list of available names OR entry number is greater than number of specified order entries, return the first element of available names list
        if isfield(favourites, "initNameOrder")
            initNameOrder = favourites.initNameOrder;
            if nEntries <= length(initNameOrder)
                initName = initNameOrder(nEntries);
                if any(nameList == initName)
                    return
                end
            end
        end
        if ~isempty(nameList)
            initName = nameList(1);
        else
            initName = "+";
        end
    end

    function [initProduct, initProductNum] = getInitProduct()
        if (isfield(favourites, "initProduct"))
            initProduct = favourites.initProduct;
        else
            initProduct = productList(1);
        end
        
        if ~any(productList == initProduct)
            error("Favourite pruduct '" + initProduct + "' unknown!");
        end

        initProductNum = find(productList == initProduct);
    end

    function initAmount = getInitAmount(product)
        amounts = amountList{productList == product};
        if (isfield(favourites.initProductAmounts, product))
            initAmount = favourites.initProductAmounts.(product);

            if ~any(amounts == initAmount)
                error("Favourite amount '" + initAmount + "' not included in amount list")
            end
        else
            initAmount = amounts(1);
        end
    end

    function initDate = getInitDate()
        if datePickedManually
            initDate = userDate;
        else
            if (isfield(favourites, "trainingWeekDays"))
                trainingWeekdays = string(favourites.trainingWeekDays);

                trainingWeekdays(trainingWeekdays == "Montag") = "monday";
                trainingWeekdays(trainingWeekdays == "Dienstag") = "tuesday";
                trainingWeekdays(trainingWeekdays == "Mittwoch") = "wednesday";
                trainingWeekdays(trainingWeekdays == "Donnerstag") = "thursday";
                trainingWeekdays(trainingWeekdays == "Freitag") = "friday";
                trainingWeekdays(trainingWeekdays == "Samstag") = "saturday";
                trainingWeekdays(trainingWeekdays == "Sonntag") = "sunday";
            else
                initDate = dateToday;
                return
            end           

            nTrainingDays = length(trainingWeekdays);
            lastTrainingDays = NaT(nTrainingDays,1);
            for i = 1:nTrainingDays
                lastTrainingDays(i) = dateshift(dateToday, "dayofweek", trainingWeekdays(i), "previous");
            end
        
            initDate = max(lastTrainingDays);
        end
    end

    function initFactor = getInitFactor()
        if (isfield(favourites, "initShareFactor"))
            initFactor = favourites.initShareFactor;
        else
            initFactor = 0.15;
        end
    end

    function [names, products, amounts] = getUniqueElements()
        names = string(unique(consumption.Name));
        products = string(unique(pricing.Name));
        amounts = cell(length(products),1);
        for i = 1:length(products)
            amountArray = pricing.Menge(string(pricing.Name) == products(i));
            amounts{i} = amountArray;   
        end
    end
end

