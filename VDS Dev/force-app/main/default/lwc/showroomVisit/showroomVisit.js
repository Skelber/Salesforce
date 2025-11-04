/**
 * Created by Tom Vanhouche on 09/09/2024.
 */

import { LightningElement } from 'lwc';

export default class ShowroomVisit extends LightningElement {
    STAGE_APPOINTMENT = 'APPOINTMENT';
    STAGE_CONTACT_DETAILS = 'CONTACT_DETAILS';
    STAGE_PROJECTS = 'PROJECTS';
    STAGE_SUMMARY = 'SUMMARY';
    stages = [
        this.STAGE_APPOINTMENT,
        this.STAGE_CONTACT_DETAILS,
        this.STAGE_PROJECTS,
        this.STAGE_SUMMARY
    ];
    currentStage = this.STAGE_APPOINTMENT;
    visitReportId;
    canGoNext = false;

    get showPrevious() {
        return this.currentStage !== this.STAGE_APPOINTMENT;
    }

    get showAppointments() {
        return this.currentStage === this.STAGE_APPOINTMENT;
    }

    get showContactDetails() {
        return this.currentStage === this.STAGE_CONTACT_DETAILS;
    }

    get showProjects() {
        return this.currentStage === this.STAGE_PROJECTS;
    }

    get showSummary() {
        return this.currentStage === this.STAGE_SUMMARY;
    }

    handlePrevious(event) {
        const idx = this.stages.findIndex((v, _) => v === this.currentStage);
        if (idx !== -1) {
            this.currentStage = this.stages[idx - 1];
        }
    }

    handleNext(event) {
        const idx = this.stages.findIndex((v, _) => v === this.currentStage);
        if (idx !== -1 && this.currentStage !== this.STAGE_SUMMARY) {
            this.currentStage = this.stages[idx + 1];
            return;
        }

        if (this.currentStage === this.STAGE_SUMMARY) {
            this.currentStage = this.STAGE_APPOINTMENT;
            this.visitReportId = undefined;
        }
    }

    handleVisitReportChange(event) {
        this.visitReportId = event.detail;
    }
}