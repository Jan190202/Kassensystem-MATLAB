function logText = manageLogTextTypes(logText)
    % desired:
    names = ["ID", "Datum", "Aktion", "Typ", "Verfeinerung", "Beschreibung", "Kommentar"];
    types= ["double", "datetime", "string", "string", "string", "string", "string"];

    logText = manageTypes(logText, names, types);
end