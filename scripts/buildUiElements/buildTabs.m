function tabElements = buildTabs(tabs)
    tabElements = struct;

    tabElements.add = buildAddTab(tabs.add);
    tabElements.pay = buildPayTab(tabs.pay);
    tabElements.bal = buildBalTab(tabs.bal);
    tabElements.log = buildLogTab(tabs.log);
    tabElements.adjCon = buildAdjConTab(tabs.adjCon);
    tabElements.adjPri = buildAdjPriTab(tabs.adjPri);
    tabElements.adjBal = buildAdjBalTab(tabs.adjBal);
end