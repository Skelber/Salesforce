/**
 * Created by tomva on 17/03/2025.
 */
import {LightningElement, api, wire, track} from 'lwc';
import getAttendances from '@salesforce/apex/WorksiteAttendancesController.getAttendances';
import { CloseActionScreenEvent } from 'lightning/actions';
import save from '@salesforce/apex/WorksiteAttendancesController.save';
import LightningAlert from 'lightning/alert';
import {refreshApex} from "@salesforce/apex";
import {getObjectInfo, getPicklistValues} from "lightning/uiObjectInfoApi";
import WORKSITE_ATTENDANCE_OBJECT from "@salesforce/schema/Worksite_Attendance__c";
import ROLE_FIELD from "@salesforce/schema/Worksite_Attendance__c.Role__c";

export default class WorksiteAttendances extends LightningElement {
    @api recordId;
    workSiteAttendances = [];
    loading = false;

    @wire(getObjectInfo, { objectApiName: WORKSITE_ATTENDANCE_OBJECT })
    worksiteAttendanceObjectInfo;
    @wire(getPicklistValues, { recordTypeId: "$worksiteAttendanceObjectInfo.data.defaultRecordTypeId", fieldApiName: ROLE_FIELD})
    rolePicklistValues;

    async connectedCallback() {
        try {
            this.loading = true;
            this.workSiteAttendances = await getAttendances({ workStepId: this.recordId });
        } catch(e) {
            await this.showError(e);
        } finally {
            this.loading = false;
        }
    }

    async handlePresentChange(event) {
        const checked = event.target.checked;
        const index = event.target.dataset.idx;

        const attendances = JSON.parse(JSON.stringify(this.workSiteAttendances));
        attendances[index].present = checked;
        this.workSiteAttendances = [...attendances];
    }

    async handleReportChange(event) {
        const checked = event.target.checked;
        const index = event.target.dataset.idx;

        const attendances = JSON.parse(JSON.stringify(this.workSiteAttendances));
        attendances[index].report = checked;
        this.workSiteAttendances = [...attendances];
    }

    async handleContactNameChange(event) {
        const index = event.target.dataset.idx;

        const attendances = JSON.parse(JSON.stringify(this.workSiteAttendances));
        attendances[index].contactName = event.target.value;
        this.workSiteAttendances = [...attendances];
    }

    async handleRoleChange(event) {
        const index = event.target.dataset.idx;

        const attendances = JSON.parse(JSON.stringify(this.workSiteAttendances));
        attendances[index].role = event.detail.value;
        this.workSiteAttendances = [...attendances];
    }

    async save() {        
        try {
            this.loading = true;
            await save({ workStepId: this.recordId, attendances: this.workSiteAttendances});
            this.dispatchEvent(new CloseActionScreenEvent());
        } catch(e) {
            await this.showError(e);
        } finally {
            this.loading = false;
        }
    }

    async showError(e) {
        await LightningAlert.open({
            message: JSON.stringify(e),
            theme: 'error',
            label: 'Error',
        });
    }
}