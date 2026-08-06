function logDetails = manageLogDetailsTypes(logDetails)
    % desired:
    names = ["ID", "Datum", "Aktion", "Typ", "Beschreibung", "Kommentar"];
    types= ["double", "datetime", "string", "string", "string", "string"];

    logDetails = manageTypes(logDetails, names, types);
end