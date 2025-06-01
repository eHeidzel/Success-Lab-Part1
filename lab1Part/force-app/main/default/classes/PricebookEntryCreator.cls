public class PricebookEntryCreator {
    
    /**
     * Method to create PricebookEntry records for all active products
     * @param pricebookId ID of the pricebook where entries will be added
     * @param minPrice Minimum price for random price generation
     * @param maxPrice Maximum price for random price generation
     */
    public static void createEntriesForInactiveProducts(Id pricebookId, Decimal minPrice, Decimal maxPrice) {
        if (pricebookId == null) {
            throw new PricebookEntryCreatorException('Pricebook ID must be specified');
        }
        
        if (minPrice < 0 || maxPrice < 0 || minPrice > maxPrice) {
            throw new PricebookEntryCreatorException('Invalid price range');
        }

        List<Product2> inactiveProducts = [
            SELECT Id, Name 
            FROM Product2 
            WHERE IsActive = false
        ];
        
        if (inactiveProducts.isEmpty()) {
            throw new PricebookEntryCreatorException('No inactive products available to create pricebook entries');
        }
        
        List<PricebookEntry> existingEntries = [
            SELECT Product2Id 
            FROM PricebookEntry 
            WHERE Pricebook2Id = :pricebookId
        ];
        
        Set<Id> existingProductIds = new Set<Id>();
        for (PricebookEntry entry : existingEntries) {
            existingProductIds.add(entry.Product2Id);
        }
        
        List<PricebookEntry> newEntries = new List<PricebookEntry>();
        Integer skippedCount = 0;

        List<Product2> products = new List<Product2>();

        if (inactiveProducts != null && !inactiveProducts.isEmpty()) {            
            for (Product2 product : inactiveProducts) {
                product.IsActive = true;
                products.add(product);
            }
            
            if (!products.isEmpty()) {
                try {
                    update products;
                } catch (DmlException e) {
                    System.debug('Error activating products: ' + e.getMessage());
                }
            }
        }
        
        for (Product2 product : products) {
            if (existingProductIds.contains(product.Id)) {
                skippedCount++;
                continue;
            }
            
            PricebookEntry entry = new PricebookEntry();
            entry.Pricebook2Id = pricebookId;
            entry.Product2Id = product.Id;
            entry.UnitPrice = generateRandomPrice(minPrice, maxPrice);
            entry.IsActive = true;
            
            newEntries.add(entry);
        }
        
        if (skippedCount > 0) {
            System.debug('Skipped ' + skippedCount + ' products as they already exist in the pricebook');
        }
        
        if (!newEntries.isEmpty()) {
            try {
                insert newEntries;
                System.debug('Successfully created ' + newEntries.size() + ' PricebookEntry records');
            } catch (DmlException e) {
                throw new PricebookEntryCreatorException('Error creating records: ' + e.getMessage());
            }
        } else {
            System.debug('No new records to create - all active products already exist in the pricebook');
        }
    }
    
    /**
     * Generates a random price within specified range
     * @param min Minimum price
     * @param max Maximum price
     * @return Random price between min and max
     */
    public static Decimal generateRandomPrice(Decimal min, Decimal max) {
        return min + Math.random() * (max - min);
    }
}