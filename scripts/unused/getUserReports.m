function userReports = getUserReports(consumption, savings)
    uniqueNames = unique(consumption.Name);
    uniqueProducts = unique(consumption.Produkt);
    correspondingNameIdentifiers = "n" + (1:length(uniqueNames));
    correspondingProductIdentifiers = "p" + (1:length(uniqueProducts));

    userReports = struct;
    for name = reshape(uniqueNames, 1, [])
        nameAlias = correspondingNameIdentifiers(uniqueNames == name);
    
        userEntries = consumption(consumption.Name == name,:);
        userProducts = unique(userEntries.Produkt);
        userProductAmounts = struct;
        for product = reshape(userProducts, 1, [])
            productAlias = correspondingProductIdentifiers(uniqueProducts == product);
            userProductAmounts.(productAlias) = unique(userEntries.Menge(userEntries.Produkt == product));
        end
    
        % create table including every product and amount
        entryNum = 0;
        maxEntryNum = height(userEntries);
        userSummary = table('Size', [maxEntryNum, 6], 'VariableTypes', ["string", repmat("double", [1, 5])], 'VariableNames', ["Produkt", "Menge", "Anzahl", "Gesamt", "Bezahlt", "Ausstehend"]);
        for product = reshape(userProducts, 1, [])
            productAlias = correspondingProductIdentifiers(uniqueProducts == product);
            for amount = reshape(userProductAmounts.(productAlias), 1, [])
                % create entry by summing up all entries with current product and amount
                % variables: product, amount, count, single, total, paid, due
                entryNum = entryNum + 1;
                isProduct = userEntries.Produkt == product;
                isAmount = userEntries.Menge == amount;
    
                entry = cell(1,6);
                entry{1} = product;                                                                 % product name
                entry{2} = amount;                                                                  % product amount
                entry{3} = sum(userEntries.Anzahl(isProduct & isAmount));                           % product count
                entry{4} = sum(userEntries.Gesamt(isProduct & isAmount));                           % total cost
                entry{5} = sum(userEntries.Bezahlt(isProduct & isAmount));                          % total paid
                entry{6} = entry{4} - entry{5};                                                     % total due = total cost - total paid
    
                userSummary(entryNum, :) = cell2table(entry);
            end
        end
        userSummary(entryNum+1:maxEntryNum, :) = []; % delete unused preallocated entries
    
        userTotal = sum(userSummary.Gesamt);
        userPaid = sum(userSummary.Bezahlt);
        userDue = sum(userSummary.Ausstehend);
    
        userReports.(nameAlias).entries = userEntries;
        userReports.(nameAlias).products = userProducts;
        userReports.(nameAlias).productAmounts = userProductAmounts;
        userReports.(nameAlias).summary = userSummary;
        userReports.(nameAlias).total = userTotal;
        userReports.(nameAlias).paid = userPaid;
        userReports.(nameAlias).due = userDue;
    end
end