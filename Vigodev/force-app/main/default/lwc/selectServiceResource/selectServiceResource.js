import { LightningElement, api, track } from 'lwc';
import avatar from "@salesforce/resourceUrl/avatar";
import loationIcon from "@salesforce/resourceUrl/locationIcon";
import clock from "@salesforce/resourceUrl/clock";
import calendar from "@salesforce/resourceUrl/calendar";
import getTimeSlots from '@salesforce/apex/WorktypeSelection.getPossibleTimeslot';
import getTimeSlotsByHour from '@salesforce/apex/WorktypeSelection.getPossibleTimeslotByHour';

export default class SelectServiceResource extends LightningElement {
    @api notBookableViaWebsite = false;
    @api worktype = {};
    @api location = {};
    @track timeValue;
    avatar = avatar;
    clock = clock;
    calendar = calendar;
    locationIcon = loationIcon;
    @track showSlots = false;
    @track showSpinner = false;
    @track selectedSlotRaw = '';

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
        this.timeValue = 'All Day';
    }

    get timeOptions() {
        return [
            { label: "VM", value: 'AM' },
            { label: "NM", value: 'PM' },
            { label: "Hele Dag", value: 'All Day' },
        ];
    }


    handleDateChange(event) {
        this.showSpinner = true;
        this.selectedDate = new Date(event.target.value).toISOString();
        localStorage.setItem("selectedDate", this.selectedDate);
        if(this.selectedDate != null) {
            this.showSlots = true
        } else {
            this.showSlots = false;
        }


        getTimeSlots({
            selectedDate: this.selectedDate,
            locatonId: this.location.recordId,
            workTypeId: this.worktype.RecordId
        })
        .then(result => {
            console.log(JSON.stringify(result))
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
            this.showSpinner = false;
        })
        .catch(error => {
            console.error('Error in getTimeSlots:', error);
        });
    }

    handleNextDate(){
        const d = new Date(this.selectedDate);
        d.setDate(d.getDate() + 1);
        this.selectedDate = d.toISOString()
        this.handleDateChange({target: {value: this.selectedDate}})
    }

    handlePrevDate(){
        const d = new Date(this.selectedDate);
        d.setDate(d.getDate() - 1);
        this.selectedDate = d.toISOString()
        this.handleDateChange({target: {value: this.selectedDate}})
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
                const isSelected = this.selectedSlotRaw === slot && this.selectedResourceId === resourceId;
    
                return {
                    raw: slot,
                    display: date.toISOString().substring(11, 16),
                    cssClass: `slds-col slds-size_1-of-6 slds-align_absolute-center timeslotContainer` +
                              (isSelected ? ' selected' : '')
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
    
        this.selectedSlotRaw = slot;
        this.selectedResourceId = resourceId;
    
        this.selectedSlot = { slot, resourceId, resourceName };
    
        this.processTimeslotMapWithPagination();
    
        this.dispatchEvent(new CustomEvent('slotdetails', {
            detail: { ...this.selectedSlot },
            bubbles: true,
            composed: true
        }));
    }
    

    getTimeslotClass(slotRaw) {
        let base = 'slds-col slds-size_1-of-6 slds-align_absolute-center timeslotContainer';
        if (this.selectedSlotRaw === slotRaw) {
            base += ' selected';
        }
        return base;
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