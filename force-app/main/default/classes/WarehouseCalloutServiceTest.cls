@isTest
private with sharing class WarehouseCalloutServiceTest 
{
    @isTest
    static void testWareHouseCallout()
    {
        WarehouseCalloutServiceMock mock = new WarehouseCalloutServiceMock();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,mock);
        WarehouseCalloutService.runWarehouseEquipmentSync();
        Test.stopTest();
        System.assertEquals(1,[SELECT count() FROM Product2],'Code Passed');
    }
}
