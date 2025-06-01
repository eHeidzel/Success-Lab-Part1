try {
    Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
    
    PricebookEntryCreator.createEntriesForInactiveProducts(
        standardPricebook.Id, 
        200,
        5000
    );
}
catch (QueryException e) {
    System.debug('Ошибка при получении стандартного прайс-бука: ' + e.getMessage());
}
catch (PricebookEntryCreatorException e) {
    System.debug('Ошибка при создании записей: ' + e.getMessage());
}