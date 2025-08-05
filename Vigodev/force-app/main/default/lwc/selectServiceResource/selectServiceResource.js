import { LightningElement, api, track } from 'lwc';
import avatar from "@salesforce/resourceUrl/avatar";
import LANG from '@salesforce/i18n/lang';
import loationIcon from "@salesforce/resourceUrl/locationIcon";
import notFoundIcon from "@salesforce/resourceUrl/notFound2";
import clock from "@salesforce/resourceUrl/clock";
import calendar from "@salesforce/resourceUrl/calendar";
import getTimeSlots from '@salesforce/apex/WorktypeSelection.getPossibleTimeslot';
import saveLeadObject from '@salesforce/apex/WorktypeSelection.saveLeadObject';
import saveTaskObject from '@salesforce/apex/WorktypeSelection.saveTaskObject';
import TaskModal from 'c/taskModal';
import ScreenFourTitle from "@salesforce/label/c.pbzScreenFourTitle"
import ScreenFourBTitle from "@salesforce/label/c.pbzScreenFourBTitle"
import DayOptionMonday from "@salesforce/label/c.pbzDayOptionMonday"
import DayOptionTuesday from "@salesforce/label/c.pbzDayOptionTuesday"
import DayOptionWednesday from "@salesforce/label/c.pbzDayOptionWednesday"
import DayOptionThursday from "@salesforce/label/c.pbzDayOptionThursday"
import DayOptionFriday from "@salesforce/label/c.pbzDayOptionFriday"
import TimeOptionAM from "@salesforce/label/c.pbzTimeOptionAM"
import TimeOptionPM from "@salesforce/label/c.pbzTimeOptionPM"
import TimeOptionAllDay from "@salesforce/label/c.pbzTimeOptionAllDay"
import Presciption from "@salesforce/label/c.pbzPrescription"
import TaskReason from "@salesforce/label/c.pbzTaskReason"
import SubmitTask from "@salesforce/label/c.pbzSubmitTask"
import YourAppointment from "@salesforce/label/c.pbzTextYourAppointment"
import Minutes from "@salesforce/label/c.pbzTextMinutes"
import Location from "@salesforce/label/c.pbzProgressStepLocation"



export default class SelectServiceResource extends LightningElement {
    LANG = LANG
    displayEnglish = false;
    displayFrench = false;
    displayDutch = false;
    @api notBookableViaWebsite = false;
    @api contact = {}
    @api worktype = {};
    @api location = {};
    @track timeValue;
    @track dayValue;
    @track selectedDays = new Set();
    prescription = false;
    @track taskComment;
    avatar = avatar;
    clock = clock;
    calendar = calendar;
    locationIcon = loationIcon;
    notFoundIcon = notFoundIcon;
    @track showSlots = false;
    @track showSpinner = false;
    @track selectedSlotRaw = '';
    @track showModal = false; 
    @track response = {
        type: '',
        message: ''
    }
    disableButton = false;
    disablePrevButton = false;

    selectedDate;
    showTimeSlots = false;
    showNoSlotsAvailable = false;

    @track timeslotMap = [];
    @track notFilteredTimeslotMap = [];
    @track paginatedTimeslotMap = [];
    slotsPerPage = 4;
    @api selectedSlot = {};

    paginationState = {};

    task = {
        leadid: '',
        worktypeName: '',
        dagdeel: 'All Day',
        dagen: '',
        voorschrift: false,
        opmerkingen: '',
        serviceTerritoryName: '',
        rrNr: ''
    }

    label = {
        ScreenFourTitle,
        ScreenFourBTitle,
        DayOptionMonday,
        DayOptionTuesday,
        DayOptionWednesday,
        DayOptionThursday,
        DayOptionFriday,
        TimeOptionAM,
        TimeOptionPM,
        TimeOptionAllDay,
        Presciption,
        TaskReason,
        SubmitTask,
        YourAppointment,
        Minutes,
        Location,
    }


    connectedCallback() {
        this.amButtonActive = true;
        this.pmButtonActive = true;
        if(this.selectedSlot) {
            console.log(JSON.stringify(this.selectedSlot))
            const d = new Date(this.selectedSlot.slot);
            this.selectedDate = d.toISOString().split('T')[0];
            this.showSlots = true
        } else {
            const d = new Date();
            d.setDate(d.getDate() + 1);
            this.selectedDate = d.toISOString()
            this.showSlots = true
        }
        if(this.selectedDate != null) {
            this.callForData()
            this.showSlots = true
        } 
        this.timeValue = 'All Day';
        this.timeslotMap = 'All Day';
        this.setLang();
        this.setPrevButtonState()
        this.task.worktypeName = this.worktype.WorkTypeName;
        this.task.serviceTerritoryName = this.location.recordName;
        this.task.rrNr = this.contact.RSZ
        window.requestAnimationFrame(() => {
            this.restoreSelectedSlotStyling();
        });
    }

    // renderedCallback() {
    //     if (!this.selectedSlotRestored) {
    //         this.restoreSelectedSlotStyling();
    //     }
    // }

    restoreSelectedSlotStyling() {
        if (!this.selectedSlot?.slot || !this.selectedSlot?.resourceId) return;
    
        const selector = `[data-slot="${this.selectedSlot.slot}"][data-resourceid="${this.selectedSlot.resourceId}"]`;
        console.log('Looking for selector:', selector);
    
        const slotDiv = this.template.querySelector(selector);
        if (slotDiv) {
            slotDiv.classList.add('selected');
        } 
    }

    setLang() {
        if (this.LANG == 'en-US') {
          this.displayEnglish = true
        } else if (this.LANG == 'fr') {
          this.displayFrench = true
        } else {
          this.displayDutch = true
        }
      }

    get timeOptionsWithClass() {
        return this.timeOptions.map(option => {
            return {
                ...option,
                class: `button ${option.value === this.timeValue ? 'active' : ''}`
            };
        });
    }
    get dayOptionsWithClass() {
        return this.dayOptions.map(option => {
            return {
                ...option,
                class: `dayButton ${this.selectedDays.has(option.value) ? 'dayActive ' : ''}`
            };
        });
    }
    
    get timeOptions() {
        return [
            { label: TimeOptionAM, value: 'AM' },
            { label: TimeOptionPM, value: 'PM' },
            { label: TimeOptionAllDay, value: 'All Day' },
        ];
    }

    get dayOptions() {
        return [
            { label: DayOptionMonday, value: 'Monday' },
            { label: DayOptionTuesday, value: 'Tuesday' },
            { label: DayOptionWednesday, value: 'Wednesday' },
            { label: DayOptionThursday, value: 'Thursday' },
            { label: DayOptionFriday, value: 'Friday' },
        ];
    }

    setPrevButtonState() {
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const tomorrow = new Date(today);
        tomorrow.setDate(tomorrow.getDate() + 1);
    
        const selected = new Date(this.selectedDate);
        selected.setHours(0, 0, 0, 0);
    
        this.disablePrevButton = selected <= tomorrow;
    }

    handleTimechange(event) {
        this.timeValue = event.currentTarget.dataset.value;
        this.filterSlotsByTime(this.timeValue);
        this.task.dagdeel = event.currentTarget.dataset.value;
    }

    filterSlotsByTime(timeValue) {
        let filteredMap = JSON.parse(JSON.stringify(this.notFilteredTimeslotMap));
    
        filteredMap.forEach(resource => {
            resource.slots = resource.slots.filter(slotTime => {
                const dateObj = new Date(slotTime);
                const hour = dateObj.getUTCHours();
    
                if (timeValue === 'AM') {
                    return hour >= 0 && hour < 12;
                } else if (timeValue === 'PM') {
                    return hour >= 12 && hour < 24;
                } else {
                    return true;
                }
            });
        });
    
        filteredMap = filteredMap.filter(resource => resource.slots.length > 0);
    
        this.timeslotMap = filteredMap;
        this.processTimeslotMapWithPagination();
    }

    handleButtonClick(event) {
        const value = event.currentTarget.dataset.value;
        if (this.selectedDays.has(value)) {
            this.selectedDays.delete(value);
        } else {
            this.selectedDays.add(value);
        }
        this.selectedDays = new Set(this.selectedDays);
        this.task.dagen = Array.from(this.selectedDays).join(', ')
    }


    handleDateChange(event) {
        this.showSpinner = true;
        this.selectedDate = new Date(event.target.value).toISOString();
        if(this.selectedDate != null) {
            this.showSlots = true
        } else {
            this.showSlots = false;
        }
        this.setPrevButtonState()
        this.callForData();
    }

    callForData() {
        this.showSpinner = true;
        getTimeSlots({
            selectedDate: this.selectedDate,
            locatonId: this.location.recordId,
            workTypeId: this.worktype.RecordId
        })
        .then(result => {
            if (result.length == 3) {
                this.showNoSlotsAvailable = true;
            } else {
                this.showNoSlotsAvailable = false;
            }
    
            if (typeof result === 'string') {
                try {
                    result = JSON.parse(result);
                } catch (e) {
                    result = [];
                }
            }
    
            if (Array.isArray(result)) {
                this.notFilteredTimeslotMap = result;
                this.filterSlotsByTime(this.timeValue);
                this.initializePagination();
                console.log(JSON.stringify(this.notFilteredTimeslotMap))
                this.restoreSelectedSlotStyling()
            }
    
            this.showSpinner = false;
        })
        .catch(error => {
            this.showSpinner = false;
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
                    cssClass: `slds-col slds-size_2-of-10 slds-align_absolute-center timeslotContainer` +
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
        let base = 'slds-col slds-size_2-of-10 slds-align_absolute-center timeslotContainer';
        if (this.selectedSlotRaw === slotRaw) {
            base += ' selected';
        }
        return base;
    }

    handlePrescription(event){
        if(this.prescription){
            this.prescription = false
        } else {
            this.prescription = true
        }
        this.task.voorschrift = this.prescription
    }

    handleTaskComment(event) {
        this.taskComment = event.target.value;
        this.task.opmerkingen = this.taskComment;
    }

    handleSubmit() {
        this.disableButton = true;
        this.showSpinner = true;
        saveLeadObject({
            lead: JSON.stringify(this.contact)
        }).then(result => {
            this.task.leadid = result
            saveTaskObject({
                task: JSON.stringify(this.task)
            }).then(taskResult => {
                this.showSpinner = false;
                this.response.type = 'success';
                this.response.message = 'Request succesfully created';
                this.showModal = true;
            }).catch(error => {
                this.showSpinner = false;
                this.response.type = 'error';
                this.response.message = 'Something went wrong, please try again';
                this.showModal = true;
            })
        }).catch(error => {
            this.response.type = 'error';
            this.response.message = 'Something went wrong, please try again';
            this.showModal = true;
        })
 }

    handleModalClose() {
        this.showModal = false;
    }

}