function consumption = manageConsumptionTypes(consumption)
    % desired:
    names = ["ID", "Name", "Produkt", "Menge", "Anzahl", "Einzelpreis", "Gesamt", "Bezahlt", "Abbezahlt", "Verbrauchstag", "Verbrauchsdatum", "Erfassungsdatum", "Zahlungsdatum", "Abrechnungsdatum", "Bilanzierung", "Anteilsfaktor", "Eigenanteil", "Fremdanteil", "Abgerechnet", "Kommentar"];
    types= ["double", "string", "string", "double", "double", "double", "double", "double", "string", "string", "datetime", "datetime", "datetime", "datetime", "string", "double", "double", "double", "string", "string"];

    consumption = manageTypes(consumption, names, types);
end