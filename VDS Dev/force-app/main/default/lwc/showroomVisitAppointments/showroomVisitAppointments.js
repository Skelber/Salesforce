import { api, LightningElement, wire } from 'lwc';
import getShowroomAppointments from '@salesforce/apex/ShowroomVisitCreationHelper.getShowroomAppointments';
import createAppointment from '@salesforce/apex/ShowroomVisitCreationHelper.createAppointment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import SHOWROOM_FIELD from '@salesforce/schema/Visit_Report__c.Showroom_Location__c';
import { showInfoToast, showSuccessToast, notifyParent } from 'c/utils';

export default class ShowroomVisitAppointments extends LightningElement {
    visitReports = null;
    loading = false;
    showNewButton = true;
    @api selectedVisitReportId;
    @api availableActions = [];
    @api showroomLocation;

    @wire(getPicklistValues, {
        recordTypeId: '0127Q000000qkoiQAA',
        fieldApiName: SHOWROOM_FIELD
    })
    showroomOptions;

    get showRelatedList() {
        return this.visitReports !== null;
    }

    async handleShowroomChange(event) {
        this.showroomLocation = event.target.value;
        await this.fetchAppointments();
    }

    async fetchAppointments() {
        if (this.showroomLocation) {
            this.visitReports = null;
            this.visitReports = await getShowroomAppointments({
                showroomLocation: this.showroomLocation
            });
        }
    }

    async createNewAppointment() {
        this.loading = true;
        this.showNewButton = false;
        const visitReport = await createAppointment({
            showroomLocation: this.showroomLocation
        });
        this.loading = false;
        this.selectedVisitReportId = visitReport.Id;

        showSuccessToast.call(this, 'Appointment created');
        notifyParent.call(this, 'visitreportchange', this.selectedVisitReportId);
        this.goNext();
    }

    handleVisitReportSelection(event) {
        this.selectedVisitReportId = event.detail[0];
        notifyParent.call(this, 'visitreportchange', this.selectedVisitReportId);
    }

    goNext() {
        if (!this.selectedVisitReportId) {
            showInfoToast.call(this, 'Invalid input', 'Please select an existing appointment or create a new one');
            return;
        }
        notifyParent.call(this, 'next');
    }
}