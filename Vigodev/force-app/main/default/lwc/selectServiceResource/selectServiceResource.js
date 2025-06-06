import { LightningElement, api, track } from 'lwc';
import avatar from "@salesforce/resourceUrl/avatar";
import getTimeSlots from '@salesforce/apex/WorktypeSelection.getPossibleTimeslot';

export default class SelectServiceResource extends LightningElement {
    @api notBookableViaWebsite = false;
    @api worktype = {};
    @api location = {};
    avatar = avatar;

    selectedDate;
    showTimeSlots = false;

    @track timeslotMap = [];
    @track paginatedTimeslotMap = [];
    slotsPerPage = 4;
    @track selectedSlot = {};

    paginationState = {};

    @track amButtonActive = false;
    pmButtonActive = false;
    @track amButtonVariant = "brand";
    @track pmButtonVariant = "brand";

    connectedCallback() {
        this.amButtonActive = true;
        this.pmButtonActive = true;
        this.selectedDate = localStorage.getItem("selectedDate") || '';
        this.handleTimeslotSection();
    }

    handleTimeslotSection() {
        this.showTimeSlots = !!this.selectedDate;
    }

    handleDateChange(event) {
        this.selectedDate = new Date(event.target.value).toISOString();
        localStorage.setItem("selectedDate", this.selectedDate);

        getTimeSlots({
            selectedDate: this.selectedDate,
            locatonId: this.location.recordId,
            workTypeId: this.worktype.RecordId
        })
        .then(result => {
            if (typeof result === 'string') {
                try {
                    result = JSON.parse(result);
                } catch (e) {
                    result = [];
                }
            }

            if (Array.isArray(result)) {
                this.timeslotMap = result;
                this.initializePagination();
            }
        })
        .catch(error => {
            console.error('Error in getTimeSlots:', error);
        });
    }

    initializePagination() {
        this.paginationState = {};
        this.timeslotMap.forEach(item => {
            this.paginationState[item.resource.recordId] = 0;
        });
        this.processTimeslotMapWithPagination();
    }

    processTimeslotMapWithPagination() {
        this.paginatedTimeslotMap = this.timeslotMap.map(item => {
            const resourceId = item.resource.recordId;
            const page = this.paginationState[resourceId] || 0;
            const start = page * this.slotsPerPage;
            const end = start + this.slotsPerPage;

            const allSlots = item.slots || [];

            const paginatedSlots = allSlots.slice(start, end).map(slot => {
                const date = new Date(slot);
                return {
                    raw: slot,
                    display: new Intl.DateTimeFormat('nl-BE', {
                        hour: '2-digit',
                        minute: '2-digit',
                        hourCycle: 'h23'
                    }).format(date)
                };
            });

            const slotFillers = Array.from(
                { length: Math.max(0, this.slotsPerPage - paginatedSlots.length) },
                (_, index) => ({ key: `filler-${index}` })
            );

            const hasPrev = page > 0;
            const hasNext = end < allSlots.length;

            return {
                ...item,
                paginatedSlots,
                slotFillers,
                hasPrev,
                hasNext,
                disablePrev: !hasPrev,
                disableNext: !hasNext
            };
        });
    }

    handlePrev(event) {
        const resourceId = event.currentTarget.dataset.resourceid;
        if (this.paginationState[resourceId] > 0) {
            this.paginationState[resourceId]--;
            this.processTimeslotMapWithPagination();
        }
    }

    handleNext(event) {
        const resourceId = event.currentTarget.dataset.resourceid;
        const resource = this.timeslotMap.find(item => item.resource.recordId === resourceId);
        if (!resource) return;

        const maxPages = Math.ceil(resource.slots.length / this.slotsPerPage);
        if (this.paginationState[resourceId] < maxPages - 1) {
            this.paginationState[resourceId]++;
            this.processTimeslotMapWithPagination();
        }
    }

    handleTimeslotClick(event) {
        const slot = event.currentTarget.dataset.slot;
        const resourceId = event.currentTarget.dataset.resourceid;
        const resourceName = event.currentTarget.dataset.resourcename;
    
        this.selectedSlot = {
            slot,
            resourceId,
            resourceName
        };

        const slotInfo = new CustomEvent('slotdetails',{
            detail: {
                ...this.selectedSlot,
                bubbles: true,
                composed: true
            }
        });
        this.dispatchEvent(slotInfo);
    }
    


    handleAMButtonClick() {
        this.amButtonActive = !this.amButtonActive;
        this.amButtonVariant = this.amButtonActive ? "brand" : "neutral";
    }

    handlePMButtonClick() {
        this.pmButtonActive = !this.pmButtonActive;
        this.pmButtonVariant = this.pmButtonActive ? "brand" : "neutral";
    }
}