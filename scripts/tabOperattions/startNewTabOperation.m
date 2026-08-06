function [changes, returnState] = startNewTabOperation(tabGroup, tabElements, lowerButtons, data)
    switch(tabGroup.SelectedTab.Title)
        case "Hinzufügen"
            [changes, returnState] = addEntries(lowerButtons, tabElements.add, data);
        case "Bezahlen"
            [changes, returnState] = receivePayment(lowerButtons, tabElements.pay, data);
        case "Gesamtbilanz"
            [changes, returnState] = showBalance(lowerButtons, tabElements.bal, data);
        case "Log"
            [changes, returnState] = showLog(lowerButtons, tabElements.log, data);
        case "Datenbank - Verbrauch"
            [changes, returnState] = editConsumptionManually(lowerButtons, tabElements.adjCon, data);
        case "Datenbank - Preise"
            [changes, returnState] = editPricingManually(lowerButtons, tabElements.adjPri, data);
        case "Datenbank - Bilanz"
            [changes, returnState] = editBalanceManually(lowerButtons, tabElements.adjBal, data);
    end
end