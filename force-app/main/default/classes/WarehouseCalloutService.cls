public with sharing class WarehouseCalloutService 
{
    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';

    @future(callout=true)
    public static void runWarehouseEquipmentSync()
    {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        List<Product2> newProductsToInsert = new List<Product2>();
        if(response.getStatusCode() == 200)
        {
            List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
            for (Object i : results){
                Map<String, Object> j = (Map<String, Object>) i;
                Product2 newEQT = new Product2();
                newEQT.Replacement_Part__c = (Boolean) j.get('replacement');
                newEQT.Name = (String) j.get('name');
                newEQT.Maintenance_Cycle__c = (Integer) j.get('maintenanceperiod');
                newEQT.Lifespan_Months__c = (Integer) j.get('lifespan');
                newEQT.Cost__c = (Decimal) j.get('lifespan');
                newEQT.Warehouse_SKU__c = (String) j.get('sku');
                newEQT.Current_Inventory__c = (Double) j.get('quantity');
                newProductsToInsert.add(newEQT);
            }
            if (!newProductsToInsert.isEmpty()){
                upsert as User newProductsToInsert;
                //System.debug('Your equipment was synced with the warehouse one');
                System.debug(newProductsToInsert);
            }
        }
    }
}
