public with sharing class FSLScheduleServiceInvoker {

    public class ScheduleRequest {
        @InvocableVariable(required=true)
        public Id schedulingPolicyId;

        @InvocableVariable(required=true)
        public Id serviceAppointmentId;
    }

    public class ScheduleResponse {
        @InvocableVariable
        public Boolean success;

        @InvocableVariable
        public String resultDetails;
    }

    @InvocableMethod(label='Schedule Service Appointment'
                     description='Schedules a Service Appointment using FSL Scheduling Policy')
    public static List<ScheduleResponse> scheduleAppointments(List<ScheduleRequest> requests) {
        List<ScheduleResponse> responses = new List<ScheduleResponse>();

        for (ScheduleRequest req : requests) {
            ScheduleResponse response = new ScheduleResponse();

            try {
                FSL.ScheduleResult result = FSL.ScheduleService.schedule(
                    req.schedulingPolicyId,
                    req.serviceAppointmentId
                    );
                    
                    response.success = true;
                    response.resultDetails = String.valueOf(result);
                    System.debug('scheduling Completed');
                    
                } catch (Exception e) {
                    response.success = false;
                    System.debug('scheduling Failed');
                // response.message = e.getMessage();
            }

            responses.add(response);
        }

        return responses;
    }
}