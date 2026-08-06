function [changes, returnState] = showBalance(lowerButtons, tabElements, data)
    progressDlg = uiprogressdlg(tabElements.tab.Parent.Parent.Parent, "Indeterminate", "on");

    %% data
    tab                     = tabElements.tab;
    tableElements           = tabElements.tableElements;
    conclusionElements      = tabElements.conclusionElements;
    earningType             = tabElements.earningType;
    spendingType            = tabElements.spendingType;
    displayedVariables      = tabElements.displayedVariables;
    consumptionEntryName    = tabElements.consumptionEntryName;
    consumptionEntryComment = tabElements.consumptionEntryComment;
    roundingEntryName       = tabElements.roundingEntryName;
    roundingEntryComment    = tabElements.roundingEntryComment;
    dateToday               = tabElements.dateToday;
    dateTimeFormat          = tabElements.dateTimeFormat;
    dateSavingsTodayFormat  = tabElements.dateSavingsTodayFormat;
    red                     = tabElements.red;
    green                   = tabElements.green;
    preBalance              = data.balance;
    postBalance             = data.balance;
    preConsumption          = data.consumption;
    postConsumption         = data.consumption;
    preDeduction            = data.deduction;
    postDeduction           = data.deduction;
    preSavings              = data.savings;
    config                  = jsondecode(fileread("config\config.json"));

    %% declare needed variables
    earnings                   = [];
    spendings                  = [];
    registerBalance            = [];
    cashBalance                = [];
    registerPre                = [];
    cashPre                    = [];
    datePre                    = [];
    registerPost               = [];
    cashPost                   = [];
    consumptionEarnings        = [];
    roundingErrors             = [];
    addedBalanceIDs            = [];
    changedConsumptionIDs      = [];
    addedDeductionIDs          = [];
    decuctedClubSharePost      = [];
    dueClubSharePrecisePre     = [];
    dueClubSharePrecisePost    = [];
    dueClubShareRoundedPost    = [];
    savingsPre                 = [];
    savingsPost                = [];
    changes                    = struct;
    processFinished            = false;

    initializeElements()

    %% callbacks
    lowerButtons.abortButton.ButtonPushedFcn                                    = @exit;
    lowerButtons.applyButton.ButtonPushedFcn                                    = @apply;
    lowerButtons.saveButton.ButtonPushedFcn                                     = @save;
    tab.Parent.SelectionChangedFcn                                              = @discard;
    tableElements.EarningsElements.TopElements.NewEntrySelect.ButtonPushedFcn   = @newEarningSel;
    tableElements.SpendingsElements.TopElements.NewEntrySelect.ButtonPushedFcn  = @newSpendingSel;
    conclusionElements.SavingsPostElements.PayClubShareButton.ButtonPushedFcn   = @payClubShare;

    close(progressDlg)

    %% wait for process to end
    while ~processFinished
        pause(0.05)
    end

    %% helper functions
    function initializeElements()
        setPreAmounts()
        refreshConsumptionEarnings()
        refreshTableElements()
        refreshConslusionElements()
    end

    function setPreAmounts()
        if any(fieldnames(config) == "initialSavings")
            datePre = config.initialSavings.Date;
            registerPre = config.initialSavings.Register;
            cashPre = config.initialSavings.Cash;
            dueClubSharePrecisePre = config.initialSavings.DueClubShare;
            savingsPre = config.initialSavings.Savings;
        else
            datePre = "01.01.24";
            registerPre = 0;
            cashPre = 0;
            dueClubSharePrecisePre = 0;
        end

        conclusionElements.SavingsPreElements.DateLabel.Text = string(datetime(datePre), dateSavingsTodayFormat);
        conclusionElements.SavingsPreElements.SavingsValueLabel.Text = formatCost(registerPre, 3);
        conclusionElements.SavingsPreElements.CashValueLabel.Text = formatCost(cashPre);
        conclusionElements.SavingsPreElements.ClubShareValueLabel.Text = formatCost(dueClubSharePrecisePre, 3);
    end

    function refreshConsumptionEarnings()
        consideredConsumption = preConsumption(preConsumption.Bilanzierung == "Ja", :);

        decuctedClubSharePost = sum(preDeduction.Bezahlt);
        consumptionEarnings = sum(consideredConsumption.Eigenanteil);
        roundingErrors = sum(preDeduction.Rundungsfehler);

        isConsumptionEntry = postBalance.Beschreibung == consumptionEntryName;
        if any(isConsumptionEntry)
            postBalance.Betrag(isConsumptionEntry) = consumptionEarnings;
            postBalance.Buchungsdatum(isConsumptionEntry) = dateToday;
            postBalance.Erfassungsdatum(isConsumptionEntry) = dateToday;
        else
            addEntry(earningType, consumptionEntryName, consumptionEarnings, dateToday, consumptionEntryComment);
        end

        isRoundingEntry = postBalance.Beschreibung == roundingEntryName;
        if any(isRoundingEntry)
            postBalance.Betrag(isRoundingEntry) = roundingErrors;
            postBalance.Buchungsdatum(isRoundingEntry) = dateToday;
            postBalance.Erfassungsdatum(isRoundingEntry) = dateToday;
        else
            addEntry(earningType, roundingEntryName, roundingErrors, dateToday, roundingEntryComment);
        end
    end

    function refreshTableElements()
        tableElements.EarningsElements.Table.Data = postBalance(postBalance.Typ == earningType, displayedVariables);
        tableElements.SpendingsElements.Table.Data = postBalance(postBalance.Typ == spendingType, displayedVariables);
        tableElements.EarningsElements.Table.Data.Buchungsdatum.Format = dateTimeFormat;
        tableElements.SpendingsElements.Table.Data.Buchungsdatum.Format = dateTimeFormat;

        earnings = sum(tableElements.EarningsElements.Table.Data.Betrag);
        spendings = sum(tableElements.SpendingsElements.Table.Data.Betrag);
        tableElements.EarningsElements.BottomElements.SumValueLabel.Text = formatCost(earnings);
        tableElements.SpendingsElements.BottomElements.SumValueLabel.Text = formatCost(spendings);    
    end

    function refreshConslusionElements()
        % balance
        registerBalance = earnings - spendings;

        % EinnahmenMit100%VerbrauchseinnahmenOhneRundungsfehler + Guthaben - Ausgaben - tatsächlichAbgezogenerFremdanteil
        % ohne Rundunsfehler, da diese keine realen Einnahmen sind, sondern weniger abgezogener Fremdanteil, was in deductedClubShare mit innbegriffen ist
        savingsPost = sum(preSavings.Guthaben);
        savingsDelta = savingsPost - savingsPre;
        cashBalance = (earnings - consumptionEarnings - roundingErrors + sum(preConsumption.Bezahlt)) + savingsDelta - spendings - decuctedClubSharePost;

        if registerBalance >= 0
            savingsColor = green;
        else
            savingsColor = red;
        end
        if cashBalance >= 0
            cashColor = green;
        else
            cashColor = red;
        end

        conclusionElements.BalanceElements.SavingsValueLabel.Text = formatCost(registerBalance);
        conclusionElements.BalanceElements.SavingsValueLabel.BackgroundColor = savingsColor;
        conclusionElements.BalanceElements.CashValueLabel.Text = formatCost(cashBalance);
        conclusionElements.BalanceElements.CashValueLabel.BackgroundColor = cashColor;

        % savingsPost
        registerPost = registerPre + registerBalance;
        conclusionElements.SavingsPostElements.SavingsValueLabel.Text = formatCost(registerPost, 3);

        cashPost = cashPre + cashBalance;
        conclusionElements.SavingsPostElements.CashValueLabel.Text = formatCost(cashPost);

        dueClubSharePrecisePost = sum(preConsumption.Fremdanteil(preConsumption.Abgerechnet == "Nein"));
        dueClubShareRoundedPost = round(dueClubSharePrecisePost);
        conclusionElements.SavingsPostElements.ClubShareValueLabel.Text = formatCost(dueClubSharePrecisePost, 3);
    end

    function addEntry(type, description, value, dateBooked, comment)
        ID = getID(postBalance.ID);

        newEntry = {ID, type, description, value, dateBooked, dateToday, comment};
        postBalance = [postBalance; newEntry];
        addedBalanceIDs = [addedBalanceIDs; ID];
        
        refreshTableElements()
        refreshConslusionElements()
    end

    function createEntry(type)
        dlgStrings = ["Beschreibung", "Betrag", "Buchungsdatum", "Kommentar"];
        dlgTitle = type + " hinzufügen";
        dlgFieldWidth = 150;
        dlgFieldSize = repmat([1 dlgFieldWidth], length(dlgStrings), 1);
        
        answer = inputdlg(dlgStrings, dlgTitle, dlgFieldSize);
        
        if isempty(answer)
            return
        else
            description = answer{1};
            value = abs(str2double(answer{2}));
            dateBooked = datetime(answer{3});
            if answer{4} == ""
                comment = "-";
            else
                comment = answer{4};
            end
        end
        
        addEntry(type, description, value, dateBooked, comment);
    end

    function addChanges()
        addedEntries = postBalance(ismember(postBalance.ID, addedBalanceIDs),:);
        if ~isempty(addedEntries)
            changes.balance.added = addedEntries;
        end

        addedEntries = postConsumption(ismember(postConsumption.ID, changedConsumptionIDs),:);
        deletedEntries = preConsumption(ismember(preConsumption.ID, changedConsumptionIDs),:);

        if ~isempty(addedEntries)
            changes.consumption.added = addedEntries;
            changes.consumption.clubSharePaid = true;
        end
        if ~isempty(deletedEntries)
            changes.consumption.deleted = deletedEntries;
        end
        
        addedEntries = postDeduction(ismember(postDeduction.ID, addedDeductionIDs),:);
        if ~isempty(addedEntries)
            changes.deduction.added = addedEntries;
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
    function newEarningSel(~, ~, ~)
        createEntry(earningType)
    end

    function newSpendingSel(~, ~, ~)
        createEntry(spendingType)
    end

    function payClubShare(~, ~, ~)
        headlineStrings = ["Betrag (Achtung: Differenz zu " + dueClubSharePrecisePost + "€ wird zu Kassenguthaben)", ... % absichtlich nicht formatCost(...) verwendet, falls >2 Nachkommastellen
                           "Abrechnungsdatum (Achtung: ALLE nach aktuellem Stand verfügbaren Einträge werden abgerechnet)", ...
                           "Kommentar"]; 
        dlgTitle = "Abrechnung (Bei Änderung NICHT Enter benutzen)";
        textBoxDims = [1 100; 1 100; 1 100];
        stdInputs = [string(dueClubShareRoundedPost), string(dateToday, "dd.MM.yyyy"), "-"];
        answer = inputdlg(headlineStrings, dlgTitle, textBoxDims, stdInputs);
        if isempty(answer)
            return
        end
        paidClubShare = str2double(answer{1});
        datePaid = datetime(answer{2});
        comment = string(answer{3});

        % add changes in consumption
        isChanged = preConsumption.Abgerechnet == "Nein";
        postConsumption.Abgerechnet(isChanged) = "Ja";
        postConsumption.Abrechnungsdatum(isChanged) = datePaid;
        changedConsumptionIDs = postConsumption.ID(isChanged);


        % add changes in deduction
        newID = getID(preDeduction.ID);
        newEntry = {newID, datePaid, dueClubSharePrecisePost, paidClubShare, dueClubSharePrecisePost-paidClubShare, comment};
        postDeduction = [postDeduction; newEntry];
        addedDeductionIDs = [addedDeductionIDs; newID];

        apply()
    end


end