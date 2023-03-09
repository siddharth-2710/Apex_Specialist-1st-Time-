trigger MaintenanceRequest on Case(before insert,after insert,before update,after update,before delete,after delete,after undelete)
{
    MaintenanceRequestHelper obj;
    if(Trigger.isAfter)
    {
        if(Trigger.isUpdate)
        {
            obj.createNewMaintenanceRequest(Trigger.new);
        }
    }
}