function debtTable = createDebtSheet(consumption, savings)
    namesList = unique(consumption.Name);

    names = strings(length(namesList),1);
    debts = zeros(length(namesList),1);

    counter = 0;
    for name = reshape(namesList, 1, [])
        counter = counter + 1;
        isName = consumption.Name == name;
        hasSavings = any(savings.Name == name);

        currentSavings = 0;
        if hasSavings
            currentSavings = savings.Guthaben(savings.Name == name);
        end

        names(counter) = name;
        debts(counter) = sum(consumption.Gesamt(isName) - consumption.Bezahlt(isName)) - currentSavings;
    end

    debtTable = table(names, debts);
    debtTable.Properties.VariableNames = ["Name", "Schulden"];
end