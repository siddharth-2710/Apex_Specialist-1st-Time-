public with sharing class MaintenanceRequestHelper
{
    public void createNewMaintenanceRequest(List<Case> newCaseRecordsList)
    {
        Integer avgAmount=10000;
        List<Case> caseRecordsToInsert = new List<Case>();
        List<Id> caseIds = new List<Id>();
        for(Case caseRecord:newCaseRecordsList)
        {
            if((caseRecord.Type=='Repair'||caseRecord.Type=='Routine Maintenance')&&caseRecord.Status=='Closed')
            {
                caseIds.add(caseRecord.Id);
            }
        }
        Map<id,Equipment_Maintenance_Item__c> equip = new map<id,Equipment_Maintenance_Item__c>([Select ID, Equipment__c, Quantity__c,Equipment__r.id,Equipment__r.Maintenance_Cycle__c from Equipment_Maintenance_Item__c ]);
        List<Equipment_Maintenance_Item__c> newEMI = new List<Equipment_Maintenance_Item__c>();
        List<Case> allCaseRecords = [SELECT Id,(SELECT Id,Equipment__c,Quantity__c FROM Equipment_Maintenance_Items__r) FROM Case WHERE Id IN :caseIds WITH SECURITY_ENFORCED];
        for(Case caseRecord:allCaseRecords)
        {
            Case newCaseRecord = new Case();
            newCaseRecord.Vehicle__c=caseRecord.Vehicle__c;
            newCaseRecord.Type='Routine Maintenance';
            newCaseRecord.Status = 'New';
            newCaseRecord.Subject=String.isBlank(caseRecord.Subject) ? 'Routine Maintenance Request' : caseRecord.Subject;
            newCaseRecord.Date_Reported__c=Date.today();
            newCaseRecord.ProductId = caseRecord.ProductId;
            newCaseRecord.Product__c = caseRecord.Product__c;
            newCaseRecord.parentID = caseRecord.Id;
            if(!caseRecord.Equipment_Maintenance_Items__r.isEmpty())
            {
                for(Equipment_Maintenance_Item__c equipMaintainItem:caseRecord.Equipment_Maintenance_Items__r)
                {
                    avgAmount = Math.min(avgAmount,Integer.valueOf(equip.get(equipMaintainItem.id).Equipment__r.Maintenance_Cycle__c));
                    newEMI.add(new Equipment_Maintenance_Item__c(
                    Equipment__c = equip.get(equipMaintainItem.id).Equipment__c,
                    Maintenance_Request__c = caseRecord.id,
                    Quantity__c = equip.get(equipMaintainItem.id).Quantity__c));
                }
                Date dueDate = date.TODAY().adddays(avgAmount);
                newCaseRecord.Date_Due__c =dueDate;
                caseRecordsToInsert.add(newCaseRecord);
            }
        }
        if(!caseRecordsToInsert.isEmpty())
        {
            insert as User caseRecordsToInsert;
        }
        for(Case c2: caseRecordsToInsert)
        {
            for(Equipment_Maintenance_Item__c emi2 : newEmi)
            {
                if(c2.parentID == emi2.Maintenance_Request__c)
                {
                    emi2.Maintenance_Request__c = c2.id;    
                }
            }
        }
        if(newEmi.size()>0)
        {
            Database.insert(newEmi);    
        }     
    }
}
