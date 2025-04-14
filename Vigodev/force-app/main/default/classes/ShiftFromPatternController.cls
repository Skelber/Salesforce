// LLP-1573

public with sharing class ShiftFromPatternController {

    @InvocableMethod(label='Create shifts from pattern' description='Create shifts from a pattern whose values are provided in a flow')
    public static void createShifts(List<ShiftInput> shiftInputs) {
        if (shiftInputs == null || shiftInputs.isEmpty()) {
            return;
        }

         ShiftInput input = shiftInputs[0];

        List<Shift_Pattern_Entry__c> patternEntries = [
            SELECT Id, Day__c, Week__c, Shift_Template__r.Start_Time__c, Shift_Template__r.End_Time__c, 
                   Shift_Template__r.Job_Profile__c, Service_Resource__c, Shift_Pattern__r.Service_Territory__c  
            FROM Shift_Pattern_Entry__c 
            WHERE Shift_Pattern__c = :input.shiftPattern
        ];

        Set<String> uniqueShiftSet = new Set<String>();
        List<Shift> shiftsToCreate = new List<Shift>();

        Set<Id> serviceTerritoryIds = new Set<Id>();
        // Manually create a unique list of weeks
        Set<String> weekSet = new Set<String>();
        Set<Id> serviceResourceSet = new Set<Id>();
        for (Shift_Pattern_Entry__c entry : patternEntries) {
            weekSet.add(entry.Week__c);
            serviceTerritoryIds.add(entry.Shift_Pattern__r.Service_Territory__c);
            serviceResourceSet.add(entry.Service_Resource__c);
        }

        List<ServiceTerritory> stList = [SELECT Id, OperatingHoursId FROM ServiceTerritory WHERE Id in :serviceTerritoryIds];
        Set<Id> operatingHourIds = new Set<id>();

        for( ServiceTerritory st : stList ){
            operatingHourIds.add( st.OperatingHoursId );
        }

        List<OperatingHoursHoliday> ohHoliday = [SELECT Id, HolidayId FROM OperatingHoursHoliday WHERE OperatingHoursId = :operatingHourIds];
        system.debug('operatinghoursholidays' + ohHoliday);
        
        Set<Id> holidayIds = new Set<Id>();
        for (OperatingHoursHoliday h : ohHoliday) {
            holidayIds.add(h.HolidayId);
        }
        System.debug('holiday ids = ' + holidayIds);

        Set<Date>HolidaySet = new Set<Date>();
            for (Holiday h : [SELECT Id, ActivityDate FROM Holiday WHERE id in :holidayIds]) {
            HolidaySet.add(h.ActivityDate);
         }

         System.debug('holidayset = ' + HolidaySet);


        List<ResourceAbsence> absences = [
            SELECT Id, ResourceId, Start, End
            FROM ResourceAbsence
            WHERE ResourceId IN :serviceResourceSet
        ];

         Map<Id, List<ResourceAbsence>> resourceAbsenceMap = new Map<Id, List<ResourceAbsence>>();
        for (ResourceAbsence absence : absences) {
            if (!resourceAbsenceMap.containsKey(absence.ResourceId)) {
                resourceAbsenceMap.put(absence.ResourceId, new List<ResourceAbsence>());
            }
            resourceAbsenceMap.get(absence.ResourceId).add(absence);
        }

        List<String> weekList = new List<String>(weekSet);

        Integer totalWeeks = (input.startDate.daysBetween(input.endDate) + 1) / 7;
        Integer weekCycleDays = weekList.size() * 7;

        for (Shift_Pattern_Entry__c entry : patternEntries) {
            Integer baseDayOffset = getDayOffset(entry.Day__c);
            for (Integer cycle = 0; cycle <= totalWeeks / weekList.size(); cycle++) {
                Date shiftDate = calculateShiftDate(input.startDate, entry.Week__c, baseDayOffset, cycle, weekCycleDays);
                System.debug('shiftdate ' + shiftDate);

                // Convert Date to DateTime before adding hours and minutes
                system.debug('before startdatetime');
                DateTime startDateTime = DateTime.newInstance(shiftDate.year(), shiftDate.month(), shiftDate.day(), entry.Shift_Template__r.Start_Time__c.hour(), entry.Shift_Template__r.Start_Time__c.minute(), 0);
                System.debug('after startdatetime  ' + startDateTime);
                DateTime endDateTime = DateTime.newInstance(shiftDate.year(), shiftDate.month(), shiftDate.day(), entry.Shift_Template__r.End_Time__c.hour(), entry.Shift_Template__r.End_Time__c.minute(), 0);

                String uniqueKey = entry.Service_Resource__c + '_' + entry.Shift_Pattern__r.Service_Territory__c + '_' + startDateTime.format() + '_' + endDateTime.format();
                
                if(!holidaySet.contains(shiftDate)){

                
                if (!uniqueShiftSet.contains(uniqueKey)) {

                    List<ResourceAbsence> serviceResourceAbsences = resourceAbsenceMap.get(entry.Service_Resource__c);
                    Boolean hasOverlap = false;

                    if (serviceResourceAbsences != null) {
                        for (ResourceAbsence absence : serviceResourceAbsences) {
                            if ((absence.Start <= startDateTime && absence.End >= startDateTime) ||
                            (absence.Start <= endDateTime && absence.End >= endDateTime) ||
                            (absence.Start >= startDateTime && absence.End <= endDateTime)) {
                                hasOverlap = true;
                                break;
                            }
                        }
                    }

                    Shift newShift = new Shift();
                    newShift.Status = hasOverlap ? 'Tentative' : input.status;
                    newShift.TimeSlotType = 'Normal';
                    newShift.Type = 'Regular';
                    newShift.ServiceResourceId = entry.Service_Resource__c;
                    newShift.ServiceTerritoryId = entry.Shift_Pattern__r.Service_Territory__c;
                    newShift.Job_Profile__c = entry.Shift_Template__r.Job_Profile__c;
                    newShift.StartTime = startDateTime;
                    newShift.EndTime = endDateTime;

                    shiftsToCreate.add(newShift);
                    uniqueShiftSet.add(uniqueKey);
                }
            }
            }
        }

        if (!shiftsToCreate.isEmpty()) {
            insert(shiftsToCreate);
        }
    }

    // Method to calculate the date for the shift based on week and day
    private static Date calculateShiftDate(Date startDate, String week, Integer dayOffset, Integer cycle, Integer weekCycleDays) {
        Integer weekOffset = Integer.valueOf(week) - 1;
        return startDate.toStartOfWeek().addDays(weekOffset * 7 + cycle * weekCycleDays + dayOffset);
    }

    // Method to map day of the week to a number
    private static Integer getDayOffset(String dayOfWeek) {
        Map<String, Integer> dayOffsets = new Map<String, Integer>{
            'Monday' => 0,
            'Tuesday' => 1,
            'Wednesday' => 2,
            'Thursday' => 3,
            'Friday' => 4
        };
        return dayOffsets.get(dayOfWeek);
    }

    public class ShiftInput {
        @InvocableVariable
        public Date startDate;
        @InvocableVariable
        public Date endDate;
        @InvocableVariable
        public String shiftPattern;
        @InvocableVariable
        public String status;     
    }
}
