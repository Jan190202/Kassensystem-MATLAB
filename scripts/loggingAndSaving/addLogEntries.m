function data = addLogEntries(data, changes)
    logDetails = data.logDetails;
    logText = data.logText;

    dateNow = datetime("now");
    dateTimeFormat = "dd.MM.yyyy";

    %% pricing
    addedList = [];
    deletedList = [];
    if isfield(changes, "pricing")
        if isfield(changes.pricing, "added")
            addDetailedEntries("Hinzufügen", "Preisliste", changes.pricing.added);
            addedList = changes.pricing.added.ID;
        end
        if isfield(changes.pricing, "deleted")
            addDetailedEntries("Löschen", "Preisliste", changes.pricing.deleted);
            deletedList = changes.pricing.deleted.ID;
        end

        [addedIDs, deletedIDs, changedIDs] = getIDLists(addedList, deletedList);

        for ID = reshape(addedIDs, 1, [])
            row = changes.pricing.added(changes.pricing.added.ID == ID,:);
            description = row.Name + " mit " + row.Menge + "l für " + formatCost(row.Preis) + " hinzugefügt";
            addTextEntry("Hinzufügen", "Preisliste", "-", description);
        end
        for ID = reshape(deletedIDs, 1, [])
            row = changes.pricing.deleted(changes.pricing.deleted.ID == ID,:);
            description = "Löschung von ID " + row.ID;
            addTextEntry("Löschen", "Preisliste", "-", description);
        end
        for ID = reshape(changedIDs, 1, [])
            postRow = changes.pricing.added(changes.pricing.added.ID == ID,:);
            description = "Änderung von ID " + postRow.ID;
            addTextEntry("Ändern", "Preisliste", "-", description);
        end
    end
    %% consumption
    addedList = [];
    deletedList = [];
    if isfield(changes, "consumption")
        if isfield(changes.consumption, "added")
            addDetailedEntries("Hinzufügen", "Verbrauch", changes.consumption.added);
            addedList = changes.consumption.added.ID;
        end
        if isfield(changes.consumption, "deleted")
            addDetailedEntries("Löschen", "Verbrauch", changes.consumption.deleted);
            deletedList = changes.consumption.deleted.ID;
        end

        [addedIDs, deletedIDs, changedIDs] = getIDLists(addedList, deletedList);

        for ID = reshape(addedIDs, 1, [])
            row = changes.consumption.added(changes.consumption.added.ID == ID,:);
            
            if row.Kommentar == "Trinkgeld"
                description = "Trinkgeld: " + formatCost(row.Gesamt) + " hinzugefügt";
                addTextEntry("Hinzufügen", "Verbrauch", row.Name, description);
                continue
            end

            isDirectlyPaid = row.Abbezahlt == "Ja";
            isIrregular = row.Bilanzierung ~= "Ja" | row.Anteilsfaktor ~= 0.15 | row.Kommentar ~= "-";

            paidString = "";
            if isDirectlyPaid
                paidString = ", bezahlt am " + string(row.Zahlungsdatum, dateTimeFormat) + ",";
            end
            irregularString = "";
            if isIrregular
                irregularString = " (irregulär)";
            end
            description = "Verbrauch: " + formatCost(row.Gesamt) + " für " + row.Verbrauchstag + ", " + string(row.Verbrauchsdatum, dateTimeFormat) + paidString + " hinzugefügt" + irregularString;
            addTextEntry("Hinzufügen", "Verbrauch", row.Name, description);
        end

        for ID = reshape(deletedIDs, 1, [])
            row = changes.consumption.deleted(changes.consumption.deleted.ID == ID,:);
            description = "Löschung von ID " + row.ID;
            addTextEntry("Löschen", "Verbrauch", row.Name, description);
        end

        for ID = reshape(changedIDs, 1, [])
            % preRow = changes.consumption.deleted(changes.consumption.deleted.ID == ID,:);
            postRow = changes.consumption.added(changes.consumption.added.ID == ID,:);
            name = postRow.Name;
        
            if isfield(changes.consumption, "clubSharePaid") % paid club share in showBalance tab
                break
            end

            if isfield(changes, "paymentValue") % paid in receivePayment tab
                paymentValue = changes.paymentValue;
                leftOverAmount = changes.leftOverAmount;
                isSaveSurplusActive = changes.isSaveSurplusActive;
                isUseSavingsActive = changes.isUseSavingsActive;
                isName = data.consumption.Name == name;
                debtLeft = sum(data.consumption.Gesamt(isName) - data.consumption.Bezahlt(isName));

                leftOverString = "";
                if leftOverAmount > 0
                    if isSaveSurplusActive
                        leftOverString = ", davon " + formatCost(leftOverAmount) + " überschüssiges Guthaben";
                    else
                        leftOverString = ", davon " + formatCost(leftOverAmount) + " Trinkgeld";
                    end
                end
                
                if isUseSavingsActive
                    % left over not possible using savings
                    description = "Verwendung von Guthaben: " + formatCost(paymentValue) + " (Restschuld " + formatCost(debtLeft) + ")";
                else
                    description = "Zahlung von " + formatCost(paymentValue) + " " + leftOverString + " (Restschuld " + formatCost(debtLeft) + ")";
                end
                
                addTextEntry("Ändern", "Verbrauch", name, description);
                break
            else % payment
                description = "Änderung zu ID " + postRow.ID; 
                % possible if needed: list changed data by comparing preRow and postRow
                addTextEntry("Ändern", "Verbrauch", name, description);
            end
        end
    end
    %% balance
    addedList = [];
    deletedList = [];
    if isfield(changes, "balance")
        if isfield(changes.balance, "added")
            addDetailedEntries("Hinzufügen", "Bilanz", changes.balance.added);
            addedList = changes.balance.added.ID;
        end
        if isfield(changes.balance, "deleted")
            addDetailedEntries("Löschen", "Bilanz", changes.balance.deleted);
            deletedList = changes.balance.deleted.ID;
        end

        [addedIDs, deletedIDs, changedIDs] = getIDLists(addedList, deletedList);

        for ID = reshape(addedIDs, 1, [])
            row = changes.balance.added(changes.balance.added.ID == ID,:);
            description = "'" + row.Beschreibung + "' mit " + formatCost(row.Betrag) + " vom " + string(row.Buchungsdatum, dateTimeFormat) + " hinzugefügt";
            addTextEntry("Hinzufügen", "Bilanz", row.Typ, description);
        end
        for ID = reshape(deletedIDs, 1, [])
            row = changes.balance.deleted(changes.balance.deleted.ID == ID,:);
            description = "Löschung von ID " + row.ID;
            addTextEntry("Löschen", "Bilanz", row.Typ, description);
        end
        for ID = reshape(changedIDs, 1, [])
            postRow = changes.balance.added(changes.balance.added.ID == ID,:);
            description = "Änderung zu ID " + postRow.ID;
            addTextEntry("Ändern", "Bilanz", postRow.Typ, description);
        end
    end
    %% savings
    addedList = [];
    deletedList = [];
    if isfield(changes, "savings")
        if isfield(changes.savings, "added")
            addDetailedEntries("Hinzufügen", "Verbrauch", changes.savings.added);
            addedList = changes.savings.added.ID;
        end
        if isfield(changes.savings, "deleted")
            addDetailedEntries("Löschen", "Verbrauch", changes.savings.deleted);
            deletedList = changes.savings.deleted.ID;
        end

        [addedIDs, deletedIDs, changedIDs] = getIDLists(addedList, deletedList);

        for ID = reshape(addedIDs, 1, [])
            row = changes.savings.added(changes.savings.added.ID == ID,:);
            description = "Guthaben-Änderung: " + formatCost(0) + " -> " + formatCost(row.Guthaben);
            addTextEntry("Hinzufügen", "Verbrauch", row.Name, description);
        end
        for ID = reshape(deletedIDs, 1, [])
            row = changes.savings.deleted(changes.savings.deleted.ID == ID,:);
            description = "Guthaben-Änderung: " + formatCost(row.Guthaben) + " -> " + formatCost(0);
            addTextEntry("Löschen", "Verbrauch", row.Name, description);
        end
        for ID = reshape(changedIDs, 1, [])
            preRow = changes.savings.deleted(changes.savings.deleted.ID == ID,:);
            postRow = changes.savings.added(changes.savings.added.ID == ID,:);
            description = "Guthabenänderung: " + formatCost(preRow.Guthaben) + " -> " + formatCost(postRow.Guthaben);
            addTextEntry("Ändern", "Verbrauch", postRow.Name, description);
        end
    end

    %% deduction
    addedList = [];
    deletedList = [];
    if isfield(changes, "deduction")
        if isfield(changes.deduction, "added")
            addDetailedEntries("Hinzufügen", "Abrechnung", changes.deduction.added);
            addedList = changes.deduction.added.ID;
        end
        if isfield(changes.deduction, "deleted")
            addDetailedEntries("Löschen", "Abrechnung", changes.deduction.deleted);
            deletedList = changes.deduction.deleted.ID;
        end

        [addedIDs, ~, ~] = getIDLists(addedList, deletedList);

        for ID = reshape(addedIDs, 1, [])
            row = changes.deduction.added(changes.deduction.added.ID == ID,:);
            if row.Rundungsfehler > 0
                addedString = " (Unterbezahlung)";
            elseif row.Rundungsfehler < 0
                addedString = " (Überbezahlung)";
            else
                addedString = "";
            end
            description = "Zahlung von " + formatCost(row.Bezahlt) + " mit Rundungsfehler " + formatCost(row.Rundungsfehler) + addedString;
            addTextEntry("Hinzufügen", "Abrechnung", "-", description);
        end
    end

    data.logDetails = logDetails;
    data.logText = logText;


    function [added, deleted, changed] = getIDLists(addedList, deletedList)
        changed = intersect(addedList, deletedList);
        added = setdiff(addedList, changed);
        deleted = setdiff(deletedList, changed);
    end

    function addDetailedEntries(action, type, table)
        for i = 1:height(table)
            logDetails = [logDetails; getDetailedEntry(action, type, getStringFromRow(table(i,:)))]; % concatenation every loop needed so IDs cannot possibly repeat
        end
    end

    function entry = getDetailedEntry(action, type, descriptionString)
        entry = {getID(logDetails.ID), dateNow, action, type, descriptionString, "-"};
    end

    function descriptionString = getStringFromRow(tableRow)
        descriptionString = "";
        variableNames = tableRow.Properties.VariableNames;
        for var = variableNames
            if descriptionString ~= ""
                descriptionString = descriptionString + ", ";
            end

            val = string(tableRow{1,var});
            if ismissing(val)
                val = "";
            end

            descriptionString = descriptionString + var + ": " + val;
        end
    end

    function addTextEntry(action, type, refinement, description)
        logText = [logText; {getID(logText.ID), dateNow, action, type, refinement, description, "-"}];
    end
end