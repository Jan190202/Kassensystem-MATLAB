function [mainWindow, tabGroup, tabElements, lowerButtons] = setupMainWindow()
    %% layout config
    mainWindowPos = [0 0 1600 800];
    mainGrid = [2, 4];
    mainRowHeights = {"1x", 50};
    
    %% setup dialog
    mainWindow = uifigure("Name","Kassenverwaltung SVU", "Position", mainWindowPos, "Icon", "assets\icon_cash_register.png");

    % mainWindow.Visible = 'off';    
    % movegui(mainWindow,'center')   
    % mainWindow.Visible = 'on';   
    % drawnow
    mainWindow.WindowState = 'maximized';
    
    mainLayout = uigridlayout(mainWindow, mainGrid);
    mainLayout.RowHeight = mainRowHeights;
    
    %lower buttons
    abortBtn = uibutton(mainLayout,"Text","Beenden");
    applyBtn = uibutton(mainLayout,"Text","Anwenden");
    saveBtn = uibutton(mainLayout,"Text","Speichern");

    abortBtn.Layout.Row = 2;
    abortBtn.Layout.Column = 1;
    applyBtn.Layout.Row = 2;
    applyBtn.Layout.Column = 3;
    saveBtn.Layout.Row = 2;
    saveBtn.Layout.Column = 4;

    lowerButtons = struct("abortButton", abortBtn, ...
                          "applyButton", applyBtn, ...
                          "saveButton", saveBtn);
    
    %tab menu
    tabGroup = uitabgroup(mainLayout);

    tabGroup.Layout.Row = 1;
    tabGroup.Layout.Column = [1 4];
    
    tabs = struct;
    tabs.add    = uitab(tabGroup, "Title", "Hinzufügen");
    tabs.pay    = uitab(tabGroup, "Title", "Bezahlen");
    tabs.bal    = uitab(tabGroup, "Title", "Gesamtbilanz");
    tabs.log    = uitab(tabGroup, "Title", "Log");
    tabs.adjCon = uitab(tabGroup, "Title", "Datenbank - Verbrauch");
    tabs.adjPri = uitab(tabGroup, "Title", "Datenbank - Preise");
    tabs.adjBal = uitab(tabGroup, "Title", "Datenbank - Bilanz");
    
    tabElements = buildTabs(tabs);
end
