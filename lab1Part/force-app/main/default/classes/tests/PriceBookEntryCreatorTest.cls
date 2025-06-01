@isTest
private class PricebookEntryCreatorTest {
    
    @TestSetup
    static void setupTestData() {
        Id standardPricebookId = Test.getStandardPricebookId();
        
        List<Product2> products = new List<Product2>();
        products.add(new Product2(Name = 'Active Product 1', IsActive = true));
        products.add(new Product2(Name = 'Inactive Product 1', IsActive = false));
        products.add(new Product2(Name = 'Inactive Product 2', IsActive = false));
        insert products;
        
        PricebookEntry existingEntry = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = products[0].Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert existingEntry;
    }
    
    @isTest
    static void testCreateEntriesForInactiveProducts_Success() {
        Id standardPricebookId = Test.getStandardPricebookId();
        
        List<Product2> inactiveProductsBefore = [SELECT Id FROM Product2 WHERE IsActive = false];
        System.assertEquals(2, inactiveProductsBefore.size(), 'There should be 2 inactive products');
        Test.startTest();
        PricebookEntryCreator.createEntriesForInactiveProducts(standardPricebookId, 10, 100);
        Test.stopTest();
        
        List<Product2> inactiveProductsAfter = [SELECT Id FROM Product2 WHERE IsActive = false];
        System.assertEquals(0, inactiveProductsAfter.size(), 'All products should become active');
        
        List<PricebookEntry> entries = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id = :standardPricebookId];
        
        System.assertEquals(3, entries.size(), 'There should be 3 pricebook entries (1 existing + 2 new)');
    }
    
    @isTest
    static void testCreateEntriesForInactiveProducts_EmptyPricebookId() {
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            PricebookEntryCreator.createEntriesForInactiveProducts(null, 10, 100);
        } catch (PricebookEntryCreatorException e) {
            exceptionThrown = true;
            System.assertEquals('Pricebook ID must be specified', e.getMessage());
        }
        Test.stopTest();
        
        System.assert(exceptionThrown, 'An exception should be thrown');
    }
    
    @isTest
    static void testCreateEntriesForInactiveProducts_InvalidPriceRange() {
        Id standardPricebookId = Test.getStandardPricebookId();
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            PricebookEntryCreator.createEntriesForInactiveProducts(standardPricebookId, -10, 100);
        } catch (PricebookEntryCreatorException e) {
            exceptionThrown = true;
            System.assertEquals('Invalid price range', e.getMessage());
        }
        Test.stopTest();
        
        System.assert(exceptionThrown, 'An exception should be thrown');
    }
    
    @isTest
    static void testCreateEntriesForInactiveProducts_NoInactiveProducts() {
        List<Product2> products = [SELECT Id FROM Product2];
        for (Product2 p : products) {
            p.IsActive = true;
        }
        update products;
        
        Id standardPricebookId = Test.getStandardPricebookId();
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            PricebookEntryCreator.createEntriesForInactiveProducts(standardPricebookId, 10, 100);
        } catch (PricebookEntryCreatorException e) {
            exceptionThrown = true;
            System.assertEquals('No inactive products available to create pricebook entries', e.getMessage());
        }
        Test.stopTest();
        
        System.assert(exceptionThrown, 'An exception should be thrown');
    }
    
    @isTest
    static void testGenerateRandomPrice() {
        Decimal min = 10;
        Decimal max = 100;
        
        Test.startTest();
        Decimal price = PricebookEntryCreator.generateRandomPrice(min, max);
        Test.stopTest();
        
        System.assert(price >= min, 'Price should be greater than or equal to minimum');
        System.assert(price <= max, 'Price should be less than or equal to maximum');
    }
}