public without sharing class AppointmentCreation {
    
    @AuraEnabled(cacheable=false)
    public static String saveServiceAppointment(Id leadid, Id locationId, Datetime startTime, Integer duration, Id resourceId, Id workTypeId, String description, String rrNr, String email) {
        
        TimeZone tz = Timezone.getTimeZone('Europe/Brussels');
        Integer milliSeconds = tz.getOffset(startTime);
        Integer minutes = milliSeconds / 60000;
        Integer offSetHours = minutes / 60;
        startTime = startTime.addHours(-1*offSetHours);
                    
        ServiceAppointment sa = new ServiceAppointment();
        List<Account> accounts =  [SELECT Id FROM Account WHERE Patient_Insurance_ID__pc = :rrNr LIMIT 1];
		if(accounts <> null && accounts.size() > 0  && rrNr <> '') {
            sa.ParentRecordId = accounts[0].Id;
        } else {
            sa.ParentRecordId = leadid;
        }
        sa.ServiceTerritoryId = locationId;
        sa.Status = 'Scheduled';
        sa.DurationType = 'Minutes';
        sa.SchedStartTime = startTime;
        sa.EarliestStartTime = startTime;
        sa.SchedEndTime = starttime.addMinutes(duration);
        sa.DueDate = starttime.addMinutes(duration);
        sa.workTypeId = workTypeId;
        sa.Description = description;
        sa.Email = email;
        Database.insert(sa, true);
        
        AssignedResource asrec = new AssignedResource();
        asrec.ServiceAppointmentId = sa.Id;
        asrec.ServiceResourceId = resourceId;
        asrec.IsPrimaryResource = true;
        asrec.IsRequiredResource = true;
        Database.insert(asrec, true);
            
        return sa.Id;
    }

}