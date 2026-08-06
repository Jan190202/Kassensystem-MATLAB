function balance = manageBalanceTypes(balance)
    % desired:
    names = ["ID", "Typ", "Beschreibung", "Betrag", "Buchungsdatum", "Erfassungsdatum", "Kommentar"];
    types= ["double", "string", "string", "double", "datetime", "datetime", "string"];
    
    balance = manageTypes(balance, names, types);
end