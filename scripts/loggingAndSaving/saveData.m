function saveData(data)
        % sort data
        data.pricing        = sortrows(data.pricing, "Name");
        data.consumption    = sortrows(data.consumption, {'Verbrauchsdatum', 'Kommentar', 'Name'});
        data.balance        = sortrows(data.balance, "Buchungsdatum");
        data.savings        = sortrows(data.savings, "Name");
        data.deduction      = sortrows(data.deduction, "Datum");
        data.logDetails     = sortrows(data.logDetails, "Datum");
        data.logText        = sortrows(data.logText, "Datum");

        % create date identifier
        today           = datetime("today");
        dayToday        = sprintf("%.2u", day(today));
        monthToday      = sprintf("%.2u", month(today));
        yearToday       = string(year(today)-2000);
        dateIdentifier  = yearToday + monthToday + dayToday;

        % create backup path
        saveIdentifier = 1;
        while isfolder("backups\" + dateIdentifier + "_" + saveIdentifier)
            saveIdentifier = saveIdentifier + 1;
        end
        mkdir("backups\" + dateIdentifier + "_" + saveIdentifier)
        backupPath = "backups\" + dateIdentifier + "_" + saveIdentifier + "\";

        % save .mat files
        save("data\data.mat", "data")
        save(backupPath + "data" + "_" + dateIdentifier + "_" + saveIdentifier + ".mat", "data")

        % save tables in xlsx format in backups folder too for easier use
        debts = createDebtSheet(data.consumption, data.savings);
        tableIdentifiers = struct("Schulden", debts, ...
                                  "Preisliste", data.pricing, ...
                                  "Verbrauch", data.consumption, ...
                                  "Bilanz", data.balance, ...
                                  "Guthaben", data.savings, ...
                                  "Abrechnung", data.deduction, ...
                                  "VerlaufDetails", data.logDetails, ...
                                  "VerlaufText", data.logText);

        for tableName = reshape(string(fieldnames(tableIdentifiers)), 1, [])    
            writetable(tableIdentifiers.(tableName), backupPath + tableName + "_" + dateIdentifier + "_" + saveIdentifier + ".xlsx");
        end
    end