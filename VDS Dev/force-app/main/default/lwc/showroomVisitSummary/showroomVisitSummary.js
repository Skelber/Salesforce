/**
 * Created by Tom Vanhouche on 09/09/2024.
 */

import { api, LightningElement, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import CONTACT_ID_FIELD from '@salesforce/schema/Visit_Report__c.Contact__c';
import SHOWROOM_LOCATION_FIELD from '@salesforce/schema/Visit_Report__c.Showroom_Location__c';
import START_DATE_FIELD from '@salesforce/schema/Visit_Report__c.Start_Date__c';
import END_DATE_FIELD from '@salesforce/schema/Visit_Report__c.End_Date__c';
import CONTACT_ACCOUNT_FIELD from '@salesforce/schema/Contact.AccountId';
import CONTACT_NAME_FIELD from '@salesforce/schema/Contact.Name';
import CONTACT_EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import CONTACT_LANGUAGE_FIELD from '@salesforce/schema/Contact.Language__c';
import CONTACT_MAILING_ADDRESS_FIELD from '@salesforce/schema/Contact.MailingAddress';
import getProjectVisits from '@salesforce/apex/ShowroomVisitCreationHelper.getProjectVisits';
import { handleException, showInfoToast, showSuccessToast, notifyParent } from 'c/utils';

export default class ShowroomVisitSummary extends LightningElement {
    @api visitReportId;

    visitReportFields = [
        SHOWROOM_LOCATION_FIELD,
        START_DATE_FIELD,
        END_DATE_FIELD,
    ];

    contactFields = [
        CONTACT_NAME_FIELD,
        CONTACT_ACCOUNT_FIELD,
        CONTACT_EMAIL_FIELD,
        CONTACT_LANGUAGE_FIELD,
        CONTACT_MAILING_ADDRESS_FIELD
    ];
    projectVisits = [];

    @wire(getRecord, {
        recordId: '$visitReportId',
        fields: [CONTACT_ID_FIELD]
    })
    wiredVisitReport;

    async connectedCallback() {
        this.projectVisits = await getProjectVisits({visitReportId: this.visitReportId});
    }

    get contactId() {
        return getFieldValue(this.wiredVisitReport.data, CONTACT_ID_FIELD); 
    }
}