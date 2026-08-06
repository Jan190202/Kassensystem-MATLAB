function changes = addChanges(changes, oldPricing, newPricing, oldConsumption, newConsumption, oldBalance, newBalance)
    dateToday = datetime("today");

    %% get deleted or added entries in tables
    % pricing
    [addedPricingIdx, deletedPricingIdx] = getDifferences(oldPricing, newPricing);
    addedPricingEntries = newPricing(addedPricingIdx,:);
    deletedPricingEntries = oldPricing(deletedPricingIdx,:);

    % consumption
    [addedConsumptionIdx, deletedConsumptionIdx] = getDifferences(oldConsumption, newConsumption);
    addedConsumptionEntries = newConsumption(addedConsumptionIdx,:);
    deletedConsumptionEntries = oldConsumption(deletedConsumptionIdx,:);

    % balance
    [addedBalanceIdx, deletedBalanceIdx] = getDifferences(oldBalance, newBalance);
    addedBalanceEntries = newBalance(addedBalanceIdx,:);
    deletedBalanceEntries = oldBalance(deletedBalanceIdx,:);

    %% translate changes and additions to fit changes table
    % every deleted or added entry is converted to a single string, fitting in the description column of deleted

    deletedPricingStrings = strings(height(deletedPricingEntries),1);
    for row = 1:height(deletedPricingEntries)
        varNames = deletedPricingEntries.Properties.VariableNames;
        for column = 1:length(varNames)
            variable = varNames(column);

            if deletedPricingStrings(row) ~= ""
                deletedPricingStrings(row) = deletedPricingStrings(row) + ", ";
            end

            content = string(deletedPricingEntries{row,column});
            if ismissing(content)
                content = "-";
            end

            deletedPricingStrings(row) = deletedPricingStrings(row) + variable + ": " + content;
        end
    end
    addedPricingStrings = strings(height(addedPricingEntries),1);
    for row = 1:height(addedPricingEntries)
        varNames = addedPricingEntries.Properties.VariableNames;
        for column = 1:length(varNames)
            variable = varNames(column);

            if addedPricingStrings(row) ~= ""
                addedPricingStrings(row) = addedPricingStrings(row) + ", ";
            end

            content = string(addedPricingEntries{row,column});
            if ismissing(content)
                content = "-";
            end

            addedPricingStrings(row) = addedPricingStrings(row) + variable + ": " + content;
        end
    end

    deletedConsumptionStrings = strings(height(deletedConsumptionEntries),1);
    for row = 1:height(deletedConsumptionEntries)
        varNames = deletedConsumptionEntries.Properties.VariableNames;
        for column = 1:length(varNames)
            variable = varNames(column);

            if deletedConsumptionStrings(row) ~= ""
                deletedConsumptionStrings(row) = deletedConsumptionStrings(row) + ", ";
            end

            content = string(deletedConsumptionEntries{row,column});
            if ismissing(content)
                content = "-";
            end

            deletedConsumptionStrings(row) = deletedConsumptionStrings(row) + variable + ": " + content;
        end
    end
    addedConsumptionStrings = strings(height(addedConsumptionEntries),1);
    for row = 1:height(addedConsumptionEntries)
        varNames = addedConsumptionEntries.Properties.VariableNames;
        for column = 1:length(varNames)
            variable = varNames(column);

            if addedConsumptionStrings(row) ~= ""
                addedConsumptionStrings(row) = addedConsumptionStrings(row) + ", ";
            end

            content = string(addedConsumptionEntries{row,column});
            if ismissing(content)
                content = "-";
            end

            addedConsumptionStrings(row) = addedConsumptionStrings(row) + variable + ": " + content;
        end
    end

    deletedBalanceStrings = strings(height(deletedBalanceEntries),1);
    for row = 1:height(deletedBalanceEntries)
        varNames = deletedBalanceEntries.Properties.VariableNames;
        for column = 1:length(varNames)
            variable = varNames(column);

            if deletedBalanceStrings(row) ~= ""
                deletedBalanceStrings(row) = deletedBalanceStrings(row) + ", ";
            end

            content = string(deletedBalanceEntries{row,column});
            if ismissing(content)
                content = "-";
            end

            deletedBalanceStrings(row) = deletedBalanceStrings(row) + variable + ": " + content;
        end
    end
    addedBalanceStrings = strings(height(addedBalanceEntries),1);
    for row = 1:height(addedBalanceEntries)
        varNames = addedBalanceEntries.Properties.VariableNames;
        for column = 1:length(varNames)
            variable = varNames(column);

            if addedBalanceStrings(row) ~= ""
                addedBalanceStrings(row) = addedBalanceStrings(row) + ", ";
            end

            content = string(addedBalanceEntries{row,column});
            if ismissing(content)
                content = "-";
            end

            addedBalanceStrings(row) = addedBalanceStrings(row) + variable + ": " + content;
        end
    end

    %% create changes entries

    for i = 1:length(addedPricingStrings)
        content = addedPricingStrings(i);
        changes = [changes; {getID(changes.ID), dateToday, "Preisliste", "hinzugefügt", content}];
    end
    for i = 1:length(deletedPricingStrings)
        content = deletedPricingStrings(i);
        changes = [changes; {getID(changes.ID), dateToday, "Preisliste", "gelöscht", content}];
    end

    for i = 1:length(addedConsumptionStrings)
        content = addedConsumptionStrings(i);
        changes = [changes; {getID(changes.ID), dateToday, "Verbrauch", "hinzugefügt", content}];
    end
    for i = 1:length(deletedConsumptionStrings)
        content = deletedConsumptionStrings(i);
        changes = [changes; {getID(changes.ID), dateToday, "Verbrauch", "gelöscht", content}];
    end

    for i = 1:length(addedBalanceStrings)
        content = addedBalanceStrings(i);
        changes = [changes; {getID(changes.ID), dateToday, "Bilanz", "hinzugefügt", content}];
    end
    for i = 1:length(deletedBalanceStrings)
        content = deletedBalanceStrings(i);
        changes = [changes; {getID(changes.ID), dateToday, "Bilanz", "gelöscht", content}];
    end

    disp(changes)


    function [addIdx, delIdx] = getDifferences(oldTbl, newTbl)
        addIdx = setDiffn(newTbl, oldTbl);
        delIdx = setDiffn(oldTbl, newTbl);
    end

    function entryIndices = setDiffn(tblA, tblB)
        [~, entryIndices] = setdiff(tblA, tblB, "stable");

        counter = 0;
        temp = entryIndices(entryIndices<=height(tblB))';
        equalIdx = false(length(entryIndices),1);
        for idx = temp
            counter = counter + 1;

            if isequaln(tblA(idx,:), tblB(idx,:))
                equalIdx(counter) = true;
            end
        end
        entryIndices(equalIdx) = [];
    end
end