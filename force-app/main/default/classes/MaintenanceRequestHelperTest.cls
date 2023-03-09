@isTest
public with sharing class MaintenanceRequestHelperTest {
    // implement scheduled code here
    
    private static final String STATUS_NEW = 'New';
    private static final String REPAIR = 'Repair';
    private static final String WORKING = 'Working';
    private static final String CLOSED = 'Closed';
    private static final String REQUEST_TYPE = 'Routine Maintenance';
    private static final String REQUEST_ORIGIN = 'Web';
    private static final String REQUEST_SUBJECT = 'Subject_Test';


    private static Product2 cEquipment() {
        product2 e = new product2(name = 'Equipment_Test',
                                         lifespan_months__c = 10,
                                         maintenance_cycle__c = 10,
                                         replacement_part__c = true);
        return e;
    }
        
    private static Vehicle__c cVehicle() {
		Vehicle__c v = new Vehicle__c(name = 'Vehicle_Test');
        return v;
    }
    
    private static Case cMTRequest(id vId, id eId) {
        case c = new case(Vehicle__c = vId,
                           Type = REPAIR,
                          Status = STATUS_NEW,
                          ProductId = eId,
                          Subject = REQUEST_SUBJECT,
                          Origin = REQUEST_ORIGIN);
        return c;
    }
    
    private static Equipment_Maintenance_Item__c createWorkPart(id eId, id rId) {
        Equipment_Maintenance_Item__c eQT = new Equipment_Maintenance_Item__c(Equipment__c = eId,
                                                                             Maintenance_request__c = rId);
        return eQT;
    }
    
    
    @isTest
    private static void testMaintenanceRequestPositive() {
        Product2 e = cEquipment();
        insert e;
        id eId = e.Id;
        
        Vehicle__c v = cVehicle();
        insert v;
        id vId = v.Id;       
        
        case u = cMTRequest(vId, eId);
        insert u;
        
        Equipment_Maintenance_Item__c eQT = createWorkPart(eId, u.id);
        insert eQT;
        
        Test.startTest();
        u.status = CLOSED;
        update u;
        Test.stopTest();
        
        Case newCase = [SELECT id, subject, type, ProductId, Date_Reported__c, Vehicle__c, Date_Due__c
                      FROM case
                      WHERE status = :STATUS_NEW];
         
        Equipment_Maintenance_Item__c parts = [SELECT id
                                                 FROM Equipment_Maintenance_Item__c
                                                 WHERE Maintenance_Request__c =:newCase.Id];

        System.assertEquals(newCase.Vehicle__c, vId,'Case Passed');
        System.assertEquals(newCase.ProductId, eId,'Case Passed');
        System.assert(newCase.Subject != null,'Case Passed');
        System.assertEquals(newCase.Type, REQUEST_TYPE,'Case Passed');
        System.assert(Parts != null,'Case Passed');
        System.assertEquals(newCase.Date_Reported__c, System.today(),'Case Passed');
    }
    
    @istest
    private static void testMaintenanceRequestNegative(){
        Product2 e = cEquipment();
        insert e;
        id eId = e.Id;
        
        Vehicle__c v = cVehicle();
        insert v;
        id vId = v.Id;
     
        case r = cMTRequest(vId,eId);
        insert r;
        
        Equipment_Maintenance_Item__c eQT = createWorkPart(eId, r.Id);
        insert eQT;
        
        Test.startTest();
        r.Status = WORKING;
        update r;
        Test.stopTest();
        
        list<case> allCases = [SELECT id FROM case];
        
        Equipment_Maintenance_Item__c parts = [SELECT id 
                                                  FROM Equipment_Maintenance_Item__c 
                                                  WHERE Maintenance_Request__c = :r.Id];
        
        system.assert(parts != null,'Case Passed');
        system.assert(allCases.size() == 1,'Case Passed');
    }
    
    @isTest
    private static void testMaintenanceRequestBulk(){
        
        list<Vehicle__C> listOfV = new list<Vehicle__C>();
        list<Product2> listOfE = new list<Product2>();
        list<case> listOfR = new list<case>();
        
        for(integer i = 0; i < 300; i++){
           listOfV.add(cVehicle());
            listOfE.add(cEquipment());
        }
        insert listOfV;
        insert listOfE;
        
        for(integer i = 0; i < 300; i++){
            listOfR.add(cMTRequest(listOfV.get(i).id, listOfE.get(i).id));
        }
        insert listOfR;
        
        
        list<Equipment_Maintenance_Item__c> listOfWp = new list<Equipment_Maintenance_Item__c>();
        
        for(integer i = 0; i < 300; i++){
            listOfWp.add(createWorkPart(listOfE.get(i).id, listOfR.get(i).id));
        }
        insert listOfWp;
        
        
        list<id> oldRIds = new list<id>();
        
        Test.startTest();
        for(case j : listOfR){
            j.Status = CLOSED;
            oldRIds.add(j.Id);
        }
        update listOfR;
        Test.stopTest();
        
        list<case> allCases = [SELECT id FROM case WHERE status =: STATUS_NEW];
        
        list<Equipment_Maintenance_Item__c> parts = [SELECT id 
                                                     FROM Equipment_Maintenance_Item__c
                                                     WHERE Maintenance_Request__c in: oldRIds];
        
        system.assert(allCases.size() == 300,'Case passed');
    }
    
}