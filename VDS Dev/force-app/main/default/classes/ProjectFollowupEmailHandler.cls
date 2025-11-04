public class ProjectFollowupEmailHandler implements Messaging.InboundEmailHandler {

    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        System.debug(email.subject);
        System.debug(email.fromAddress);
        System.debug(email.fromName);
        System.debug(email.toAddresses);
        System.debug(email.htmlBody);

        String projectNr = extractProjectNr(email.subject);
        System.debug(projectNr);

        try {
            if (String.isBlank(projectNr)) {
                handleProjectNotFound(projectNr, email);
                return result;
            }

            List<Opportunity> projects = [SELECT Id, Name, Owner.Email FROM Opportunity WHERE projectnr__c = :projectNr LIMIT 1];
            if (projects.size() == 0) {
                handleProjectNotFound(projectNr, email);
                return result;
            }

            Opportunity project = projects.get(0);

            // link EmailMessage to the project
            EmailMessage emailMessage = new EmailMessage();
            emailMessage.Subject = email.subject;
            emailMessage.FromAddress = email.fromAddress;
            emailMessage.ToAddress = String.join(email.toAddresses, ',');
            emailMessage.HtmlBody = email.htmlBody;
            emailMessage.Incoming = true;
            emailMessage.RelatedToId = project.Id;
            emailMessage.MessageDate = Datetime.now();
            emailMessage.Status = '1';
            insert emailMessage;

            // read attachments
            if(email.binaryAttachments != null && email.binaryAttachments.size() > 0){
                Messaging.InboundEmail.BinaryAttachment emailAtt = null;
                String attachmentsExtentions = '';
                for(Messaging.InboundEmail.BinaryAttachment att : email.binaryAttachments){
                    attachmentsExtentions += '** '+ att.fileName + ': type Of File: ' + att.mimeTypeSubType + '\n';
                    if(att.mimeTypeSubType.toLowerCase().contains('pdf') || (att.mimeTypeSubType.toLowerCase().contains('octet-stream') && att.fileName.endsWith('pdf'))){
                        emailAtt = att;
                        break;
                    }
                }

                if(emailAtt != null){
                    ContentVersion cv = new ContentVersion(Title = emailAtt.fileName, PathOnClient = emailAtt.fileName, VersionData = emailAtt.body);
                    insert cv;
                    Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

                    // attach to the EmailMessage
                    ContentDocumentLink emailLink = new ContentDocumentLink();
                    emailLink.ContentDocumentId = contentDocumentId;
                    emailLink.LinkedEntityId = emailMessage.Id;
                    emailLink.ShareType = 'V';
                    emailLink.Visibility = 'AllUsers';
                    insert emailLink;

                    // attach to the Project
                    ContentDocumentLink projectLink = new ContentDocumentLink();
                    projectLink.ContentDocumentId = contentDocumentId;
                    projectLink.LinkedEntityId = project.Id;
                    projectLink.ShareType = 'V';
                    projectLink.Visibility = 'AllUsers';
                    insert projectLink;
                }
            }

            // send mail to project owner
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {project.Owner.Email});
            mail.setSubject('New reply on project ' + project.Name);
            mail.setHtmlBody(email.htmlBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 

            Logger loggerInstance = new Logger();
            loggerInstance.addFunctionName('ProjectFollowupEmailHandler')
                .addMessage('Received an email for projectNr: ' + projectNr)
                .addMethod('handleInboundEmail')
                .addSeverity(Logger.LOG_SEVERITY_INFO)
                .addSourceType(Logger.LOG_SOURCETYPE_APEX)
                .fire();
            result.success = true;
        } catch (Exception exc) {
            Logger loggerInstance = new Logger();
            loggerInstance.addFunctionName('ProjectFollowupEmailHandler')
                .addMessageWithoutDate(exc.getMessage() + ' --- projectNr: ' + projectNr)
                .addMethod('handleInboundEmail')
                .addSeverity(Logger.LOG_SEVERITY_ERROR)
                .addSourceType(Logger.LOG_SOURCETYPE_APEX)
                .addStackTrace(exc.getStackTraceString())
                .fire();
        }

        return result;
    }

    private static void handleProjectNotFound(String projectNr, Messaging.InboundEmail email) {
        Logger loggerInstance = new Logger();
        loggerInstance.addFunctionName('ProjectFollowupEmailHandler')
            .addMessageWithoutDate('No project found for projectNr: ' + projectNr)
            .addMethod('handleInboundEmail')
            .addSeverity(Logger.LOG_SEVERITY_ERROR)
            .addSourceType(Logger.LOG_SOURCETYPE_APEX)
            .fire();

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'s.runhaar@vandersanden.com'});
        mail.setSubject('Project follow up - project not found for number ' + projectNr);
        mail.setHtmlBody(email.htmlBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });                    
    }

    private static String extractProjectNr(String subject) {
        Pattern pattern = Pattern.compile('\\((.*?)\\)');
        Matcher matcher = pattern.matcher(subject);

        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }

}