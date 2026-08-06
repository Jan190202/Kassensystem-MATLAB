function tabElements = buildBalTab(tab)
    %% initialize needed variables
    earningType = "Einnahme";
    spendingType = "Ausgabe";

    displayedVariables = ["Beschreibung", "Betrag", "Buchungsdatum"];

    consumptionEntryName = "Getränkeverkäufe";
    consumptionEntryComment = "15% aus Gesamteinnahmen. Schuldenbegleichungen aus letzer Abrechnungsperiode unberücksichtigt";
    roundingEntryName = "Rundungsfehler bei Abrechnung";
    roundingEntryComment = "Fehler durch Rundungen bei vergangenen Zahlungen an den Verein";

    dateTimeFormat = "eeee, dd.MM.yyyy";
    dateSavingsTodayFormat = "dd.MM.yyyy";
    dateToday = datetime("today");

    redPale = "#DB7093";
    greenPale = "#98FB98";
    % red = "#FF0000";
    % green = "#00FF00";

    initFontSize = 20;
    initFontSizeSmall = 12;
    initHeadlineFontSize = 40;
    tableSeparationWidth = 3;
    tabSeparationWidth= 3;
    
    %% layout config
    tabGrid = [3 1]; % tables; line; conclusion
    tabRowHeights = {"1x", tabSeparationWidth*3, "0.3x"};
    tabColWidths = {"1x"};
    
        tableGrid = [1 3]; % earnings, line, spendings
        tableRowHeights = {"1x"};
        tableColWidths = {"1x", tableSeparationWidth*3, "1x"};
        tableRow = 1;
        tableCol = 1;
        
            earningsGrid = [4 1]; % earningsTop; table; line; earningsBottom
            earningsRowHeigths = {"0.2x", "1x", 1, "0.1x"};
            earningsColWidths = {"1x"};
            earningsRow = 1;
            earningsCol = 1;

                earningsTopGrid = [1 2];
                earningsTopRowHeights = {"1x"};
                earningsTopColWidths = {"1x", "0.25x"};
                earningsTopRow = 1;
                earningsTopCol = 1;

                earningsBottomGrid = [1 3];
                earningsBottomRowHeights = {"1x"};
                earningsBottomColWidths = {"1x", "0.5x", "1x"};
                earningsBottomRow = 4;
                earningsBottomCol = 1;

            spendingsGrid = [4 1]; % spendingsTop; table; line; spendingsBottom
            spendingsRowHeigths = {"0.2x", "1x", 1, "0.1x"};
            spendingsColWidths = {"1x"};
            spendingsRow = 1;
            spendingsCol = 3;

                spendingsTopGrid = [1 2];
                spendingsTopRowHeights = {"1x"};
                spendingsTopColWidths = {"1x", "0.25x"};
                spendingsTopRow = 1;
                spendingsTopCol = 1;

                spendingsBottomGrid = [1 3];
                spendingsBottomRowHeights = {"1x"};
                spendingsBottomColWidths = {"1x", "0.5x", "1x"};
                spendingsBottomRow = 4;
                spendingsBottomCol = 1;

        conclusionGrid = [1 5]; % savingsPre, line, balance, line, savingsPost
        conclusionRowHeights = {"1x"};
        conclusionColWidths = {"1x", 1, "1x", 1, "1x"};
        conclusionRow = 3;
        conclusionCol = 1;

            savingsPreGrid = [4 3];
            savingsPreRowHeigths = {"1x", "1x", "1x", "0.5x"}; % date; savings; cash; clubShare
            savingsPreColWidths = {"1x", "0.5x", "1x"};
            savingsPreRow = 1;
            savingsPreCol = 1;

            balanceGrid = [2 4];
            balanceRowHeigths = {"1x", "1x"}; % savings balance; cash balance
            balanceColWidths = {"1x", "0.25x", "0.75x", "0.25x"}; % text, spacing, value, spacing
            balanceRow = 1;
            balanceCol = 3;

            savingsPostGrid = [4 3];
            savingsPostRowHeigths = {"1x", "1x", "1x", "0.5x"}; % date; savings; cash; clubShare
            savingsPostColWidths = {"1x", "0.5x", "1x"};
            savingsPostRow = 1;
            savingsPostCol = 5;

                savingsPostCashGrid = [2 2];
                savingsPostCashRowHeigths = {"2x", "1x"}; % postCashValue button; clubShareValue button
                savingsPostCashColWidths = {"2x", "1x"};
                savingsPostCashRow = [3 4];
                savingsPostCashCol = 3;
   
    %% setup tab
    tabLayout = uigridlayout(tab, tabGrid);
    tabLayout.RowHeight = tabRowHeights;
    tabLayout.ColumnWidth = tabColWidths;

        tableLayout = uigridlayout(tabLayout, tableGrid);
        tableLayout.Padding = [0 0 0 0];
        tableLayout.RowHeight = tableRowHeights;
        tableLayout.ColumnWidth = tableColWidths;
        tableLayout.Layout.Row = tableRow;
        tableLayout.Layout.Column = tableCol;

            earningsLayout = uigridlayout(tableLayout, earningsGrid);
            earningsLayout.Padding = [0 0 0 0];
            earningsLayout.RowHeight = earningsRowHeigths;
            earningsLayout.ColumnWidth = earningsColWidths;
            earningsLayout.Layout.Row = earningsRow;
            earningsLayout.Layout.Column = earningsCol;

                earningsTopLayout = uigridlayout(earningsLayout, earningsTopGrid);
                earningsTopLayout.Padding = [0 0 0 0];
                earningsTopLayout.RowHeight = earningsTopRowHeights;
                earningsTopLayout.ColumnWidth = earningsTopColWidths;
                earningsTopLayout.Layout.Row = earningsTopRow;
                earningsTopLayout.Layout.Column = earningsTopCol;

                earningsBottomLayout = uigridlayout(earningsLayout, earningsBottomGrid);
                earningsBottomLayout.Padding = [0 0 0 0];
                earningsBottomLayout.RowHeight = earningsBottomRowHeights;
                earningsBottomLayout.ColumnWidth = earningsBottomColWidths;
                earningsBottomLayout.Layout.Row = earningsBottomRow;
                earningsBottomLayout.Layout.Column = earningsBottomCol;

            spendingsLayout = uigridlayout(tableLayout, spendingsGrid);
            spendingsLayout.Padding = [0 0 0 0];
            spendingsLayout.RowHeight = spendingsRowHeigths;
            spendingsLayout.ColumnWidth = spendingsColWidths;
            spendingsLayout.Layout.Row = spendingsRow;
            spendingsLayout.Layout.Column = spendingsCol;
            
                spendingsTopLayout = uigridlayout(spendingsLayout, spendingsTopGrid);
                spendingsTopLayout.Padding = [0 0 0 0];
                spendingsTopLayout.RowHeight = spendingsTopRowHeights;
                spendingsTopLayout.ColumnWidth = spendingsTopColWidths;
                spendingsTopLayout.Layout.Row = spendingsTopRow;
                spendingsTopLayout.Layout.Column = spendingsTopCol;

                spendingsBottomLayout = uigridlayout(spendingsLayout, spendingsBottomGrid);
                spendingsBottomLayout.Padding = [0 0 0 0];
                spendingsBottomLayout.RowHeight = spendingsBottomRowHeights;
                spendingsBottomLayout.ColumnWidth = spendingsBottomColWidths;
                spendingsBottomLayout.Layout.Row = spendingsBottomRow;
                spendingsBottomLayout.Layout.Column = spendingsBottomCol;

        conclusionLayout = uigridlayout(tabLayout, conclusionGrid);
        conclusionLayout.Padding = [0 0 0 0];
        conclusionLayout.RowHeight = conclusionRowHeights;
        conclusionLayout.ColumnWidth = conclusionColWidths;
        conclusionLayout.Layout.Row = conclusionRow;
        conclusionLayout.Layout.Column = conclusionCol;

            savingsPreLayout = uigridlayout(conclusionLayout, savingsPreGrid);
            savingsPreLayout.Padding = [0 0 0 0];
            savingsPreLayout.RowHeight = savingsPreRowHeigths;
            savingsPreLayout.ColumnWidth = savingsPreColWidths;
            savingsPreLayout.Layout.Row = savingsPreRow;
            savingsPreLayout.Layout.Column = savingsPreCol;

            balanceLayout = uigridlayout(conclusionLayout, balanceGrid);
            balanceLayout.Padding = [0 0 0 0];
            balanceLayout.RowHeight = balanceRowHeigths;
            balanceLayout.ColumnWidth = balanceColWidths;
            balanceLayout.Layout.Row = balanceRow;
            balanceLayout.Layout.Column = balanceCol;

            savingsPostLayout = uigridlayout(conclusionLayout, savingsPostGrid);
            savingsPostLayout.Padding = [0 0 0 0];
            savingsPostLayout.RowHeight = savingsPostRowHeigths;
            savingsPostLayout.ColumnWidth = savingsPostColWidths;
            savingsPostLayout.Layout.Row = savingsPostRow;
            savingsPostLayout.Layout.Column = savingsPostCol;

            savingsPostCashLayout = uigridlayout(savingsPostLayout, savingsPostCashGrid);
            savingsPostCashLayout.Padding = [0 0 0 0];
            savingsPostCashLayout.RowHeight = savingsPostCashRowHeigths;
            savingsPostCashLayout.ColumnWidth = savingsPostCashColWidths;
            savingsPostCashLayout.Layout.Row = savingsPostCashRow;
            savingsPostCashLayout.Layout.Column = savingsPostCashCol;


    % earningsTop
    earningsTopElements =     struct("Headline",          uilabel(earningsTopLayout, "FontSize", initHeadlineFontSize, "Text", "Einnahmen", "HorizontalAlignment", "center", "FontWeight", "bold", "BackgroundColor", greenPale), ...
                                     "NewEntrySelect",    uibutton(earningsTopLayout, "FontSize", initFontSize, "Text", "Neu"));

    % earningsBottom
    earningsBottomElements = struct("SumTextLabel",       uilabel(earningsBottomLayout, "FontSize", initFontSize, "Text", "Summe:", "HorizontalAlignment", "right"), ...
                                    "SumValueLabel",      uilabel(earningsBottomLayout, "FontSize", initFontSize, "Text", "0.00 €", "HorizontalAlignment", "left", "FontWeight", "bold"));
    earningsBottomElements.SumValueLabel.Layout.Column = 3;
                              
        % earnings
        earningsElements =     struct("TopElements",          earningsTopElements, ...
                                      "TopLayout",            earningsTopLayout, ...
                                      "Table",                uitable(earningsLayout), ...
                                      "HorizontalAxes",       uiaxes(earningsLayout, "FontSize", 0.01, "Visible", "off"), ...
                                      "BottomElements",       earningsBottomElements, ...
                                      "BottomLayout",         earningsBottomLayout);
        earningsElements.Table.Layout.Row = 2;
        earningsElements.Table.Layout.Column = 1;
        earningsElements.HorizontalAxes.Layout.Row = 3;
        earningsElements.HorizontalAxes.Layout.Column = 1;

    % spendingsTop
    spendingsTopElements =     struct("Headline",         uilabel(spendingsTopLayout, "FontSize", initHeadlineFontSize, "Text", "Ausgaben", "HorizontalAlignment", "center", "FontWeight", "bold", "BackgroundColor", redPale), ...
                                      "NewEntrySelect",   uibutton(spendingsTopLayout, "FontSize", initFontSize, "Text", "Neu"));

    % spendingsBottom
    spendingsBottomElements = struct("SumTextLabel",      uilabel(spendingsBottomLayout, "FontSize", initFontSize, "Text", "Summe:", "HorizontalAlignment", "right"), ...
                                     "SumValueLabel",     uilabel(spendingsBottomLayout, "FontSize", initFontSize, "Text", "0.00 €", "HorizontalAlignment", "left", "FontWeight", "bold")); 
    spendingsBottomElements.SumValueLabel.Layout.Column = 3;

        % spendings
        spendingsElements = struct("TopElements",             spendingsTopElements, ...
                                   "TopLayout",               spendingsTopLayout, ...
                                   "Table",                   uitable(spendingsLayout), ...
                                   "HorizontalAxes",          uiaxes(spendingsLayout, "FontSize", 0.01, "Visible", "off"), ...
                                   "BottomElements",          spendingsBottomElements, ...
                                   "BottomLayout",            spendingsBottomLayout);
        spendingsElements.Table.Layout.Row = 2;
        spendingsElements.Table.Layout.Column = 1;
        spendingsElements.HorizontalAxes.Layout.Row = 3;
        spendingsElements.HorizontalAxes.Layout.Column = 1;
            
            % tables
            tableElements = struct("EarningsElements",            earningsElements, ...
                                   "EarningsLayout",              earningsLayout, ...
                                   "VerticalAxes",                uiaxes(tableLayout, "FontSize",0.01, "Visible", "off"), ...
                                   "SpendingsElements",           spendingsElements, ...
                                   "SpendingsLayout",             spendingsLayout);
            tableElements.VerticalAxes.Layout.Row = 1;
            tableElements.VerticalAxes.Layout.Column = 2;




    % savingsPre
    savingsPreElements = struct("DateLabel",            uilabel(savingsPreLayout, "Text", "01.01.2024", "FontSize", initFontSize, "HorizontalAlignment", "center", "FontWeight", "bold"), ...
                                "SavingsTextLabel",     uilabel(savingsPreLayout, "Text", "Kassenbestand:", "FontSize", initFontSize, "HorizontalAlignment", "right"), ...
                                "SavingsValueLabel",    uilabel(savingsPreLayout, "Text", "0.00 €", "FontSize", initFontSize, "HorizontalAlignment", "left", "FontWeight", "bold"), ...
                                "CashTextLabel",        uilabel(savingsPreLayout, "Text", "Barvermögen:", "FontSize", initFontSize, "VerticalAlignment", "bottom", "HorizontalAlignment", "right"), ...
                                "CashValueLabel",       uilabel(savingsPreLayout, "Text", "0.00 €", "FontSize", initFontSize, "VerticalAlignment", "bottom", "HorizontalAlignment", "left", "FontWeight", "bold"), ...
                                "ClubShareTextLabel",   uilabel(savingsPreLayout, "Text", "davon Fremdanteil:", "FontSize", initFontSizeSmall, "VerticalAlignment", "top", "HorizontalAlignment", "right"), ...
                                "ClubShareValueLabel",  uilabel(savingsPreLayout, "Text", "0.00 €", "FontSize", initFontSizeSmall, "VerticalAlignment", "top", "HorizontalAlignment", "left", "FontWeight", "bold"));
    savingsPreElements.DateLabel.Layout.Row = 1;
    savingsPreElements.DateLabel.Layout.Column = [1 3];
    savingsPreElements.SavingsTextLabel.Layout.Row = 2;
    savingsPreElements.SavingsTextLabel.Layout.Column = 1;
    savingsPreElements.SavingsValueLabel.Layout.Row = 2;
    savingsPreElements.SavingsValueLabel.Layout.Column = 3;
    savingsPreElements.CashTextLabel.Layout.Row = 3;
    savingsPreElements.CashTextLabel.Layout.Column = 1;
    savingsPreElements.CashValueLabel.Layout.Row = 3;
    savingsPreElements.CashValueLabel.Layout.Column = 3;
    savingsPreElements.ClubShareTextLabel.Layout.Row = 4;
    savingsPreElements.ClubShareTextLabel.Layout.Column = 1;
    savingsPreElements.ClubShareValueLabel.Layout.Row = 4;
    savingsPreElements.ClubShareValueLabel.Layout.Column = 3;


    % balance
    balanceElements = struct("SavingsTextLabel",        uilabel(balanceLayout, "Text", "Kassenbilanz:", "FontSize", initFontSize, "HorizontalAlignment", "right"), ...
                             "SavingsValueLabel",       uilabel(balanceLayout, "Text", "0.00 €", "FontSize", initFontSize, "HorizontalAlignment", "center", "FontWeight", "bold"), ...
                             "CashTextLabel",           uilabel(balanceLayout, "Text", "Barbilanz:", "FontSize", initFontSize, "HorizontalAlignment", "right"), ...
                             "CashValueLabel",          uilabel(balanceLayout, "Text", "0.00 €", "FontSize", initFontSize, "HorizontalAlignment", "center", "FontWeight", "bold"));
    balanceElements.SavingsTextLabel.Layout.Row = 1;
    balanceElements.SavingsTextLabel.Layout.Column = 1;
    balanceElements.SavingsValueLabel.Layout.Row = 1;
    balanceElements.SavingsValueLabel.Layout.Column = 3;
    balanceElements.CashTextLabel.Layout.Row = 2;
    balanceElements.CashTextLabel.Layout.Column = 1;
    balanceElements.CashValueLabel.Layout.Row = 2;
    balanceElements.CashValueLabel.Layout.Column = 3;

    % savingsPost
    savingsPostElements = struct("DateLabel",           uilabel(savingsPostLayout, "Text", string(dateToday, dateSavingsTodayFormat), "FontSize", initFontSize, "HorizontalAlignment", "center", "FontWeight", "bold"), ...
                                 "SavingsTextLabel",    uilabel(savingsPostLayout, "Text", "Kassenbestand:", "FontSize", initFontSize, "HorizontalAlignment", "right"), ...
                                 "SavingsValueLabel",   uilabel(savingsPostLayout, "Text", "0.00 €", "FontSize", initFontSize, "HorizontalAlignment", "left", "FontWeight", "bold"), ...
                                 "CashTextLabel",       uilabel(savingsPostLayout, "Text", "Barvermögen:", "FontSize", initFontSize, "VerticalAlignment", "bottom", "HorizontalAlignment", "right"), ...
                                 "CashValueLabel",      uilabel(savingsPostCashLayout, "Text", "0.00 €", "FontSize", initFontSize, "VerticalAlignment", "bottom", "HorizontalAlignment", "left", "FontWeight", "bold"), ...
                                 "ClubShareTextLabel",  uilabel(savingsPostLayout, "Text", "davon Fremdanteil:", "FontSize", initFontSizeSmall, "VerticalAlignment", "top", "HorizontalAlignment", "right"), ...
                                 "ClubShareValueLabel", uilabel(savingsPostCashLayout, "Text", "0.00 €", "FontSize", initFontSizeSmall, "VerticalAlignment", "top", "HorizontalAlignment", "left", "FontWeight", "bold"), ...
                                 "PayClubShareButton",  uibutton(savingsPostCashLayout, "Icon", "assets\icon_pay.jpg", "HorizontalAlignment", "right", "Text", ""));
    savingsPostElements.DateLabel.Layout.Row = 1;
    savingsPostElements.DateLabel.Layout.Column = [1 3];
    savingsPostElements.SavingsTextLabel.Layout.Row = 2;
    savingsPostElements.SavingsTextLabel.Layout.Column = 1;
    savingsPostElements.SavingsValueLabel.Layout.Row = 2;
    savingsPostElements.SavingsValueLabel.Layout.Column = 3;
    savingsPostElements.CashTextLabel.Layout.Row = 3;
    savingsPostElements.CashTextLabel.Layout.Column = 1;
    savingsPostElements.ClubShareTextLabel.Layout.Row = 4;
    savingsPostElements.ClubShareTextLabel.Layout.Column = 1;

    savingsPostElements.CashValueLabel.Layout.Row = 1;
    savingsPostElements.CashValueLabel.Layout.Column = 1;
    savingsPostElements.ClubShareValueLabel.Layout.Row = 2;
    savingsPostElements.ClubShareValueLabel.Layout.Column = 1;
    savingsPostElements.PayClubShareButton.Layout.Row = [1 2];
    savingsPostElements.PayClubShareButton.Layout.Column = 2;
    

        %conclusion
        conclusionElements = struct("SavingsPreElements",   savingsPreElements, ...
                                    "SavingsPreLayout",     savingsPreLayout, ...
                                    "VerticalAxesLeft",     uiaxes(conclusionLayout, "FontSize",0.01, "Visible", "off"), ...
                                    "BalanceElements",      balanceElements, ...
                                    "BalanceLayout",        balanceLayout, ...
                                    "VerticalAxesRight",    uiaxes(conclusionLayout, "FontSize",0.01, "Visible", "off"), ...
                                    "SavingsPostElements",  savingsPostElements, ...
                                    "SavingsPostLayout",    savingsPostLayout);
        conclusionElements.VerticalAxesLeft.Layout.Row = 1;
        conclusionElements.VerticalAxesLeft.Layout.Column = 2;
        conclusionElements.VerticalAxesRight.Layout.Row = 1;
        conclusionElements.VerticalAxesRight.Layout.Column = 4;

    %draw lines
    line(tableElements.VerticalAxes, [0 0], [0 1], "Color", "black", "LineWidth", tableSeparationWidth);
    line(tableElements.EarningsElements.HorizontalAxes, [0 1], [0 0], "Color", "black");
    line(tableElements.SpendingsElements.HorizontalAxes, [0 1], [0 0], "Color", "black");
    line(conclusionElements.VerticalAxesLeft, [0 0], [0 1], "Color", "black");
    line(conclusionElements.VerticalAxesRight, [0 0], [0 1], "Color", "black");

    hAxes1 = uiaxes(tabLayout, "FontSize", 0.01, "Visible", "off");
    line(hAxes1, [0 1], [0 0], "Color", "black", "LineWidth", tabSeparationWidth);
    hAxes1.Layout.Row = 2;
    hAxes1.Layout.Column = 1;

      
    %% pack content
    tabElements = struct( ...
        "tab", tab, ...
        "tableElements", tableElements, ...
        "conclusionElements", conclusionElements, ...
        "earningType", earningType, ...
        "spendingType", spendingType, ...
        "displayedVariables", displayedVariables, ...
        "consumptionEntryName", consumptionEntryName, ...
        "consumptionEntryComment", consumptionEntryComment, ...
        "roundingEntryName", roundingEntryName, ...
        "roundingEntryComment", roundingEntryComment, ...
        "dateToday", dateToday, ...
        "dateTimeFormat", dateTimeFormat, ...
        "dateSavingsTodayFormat", dateSavingsTodayFormat, ...
        "red", redPale, ...
        "green", greenPale);
end