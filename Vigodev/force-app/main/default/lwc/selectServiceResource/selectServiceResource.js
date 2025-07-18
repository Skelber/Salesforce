import { LightningElement, api, track } from 'lwc';
import avatar from "@salesforce/resourceUrl/avatar";
import LANG from '@salesforce/i18n/lang';
import loationIcon from "@salesforce/resourceUrl/locationIcon";
import notFoundIcon from "@salesforce/resourceUrl/notFound2";
import clock from "@salesforce/resourceUrl/clock";
import calendar from "@salesforce/resourceUrl/calendar";
import getTimeSlots from '@salesforce/apex/WorktypeSelection.getPossibleTimeslot';
import saveLead from '@salesforce/apex/WorktypeSelection.saveLead';
import saveTask from '@salesforce/apex/WorktypeSelection.saveTask';
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
    @track selectedSlot = {};

    paginationState = {};

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
        const d = new Date();
        d.setDate(d.getDate() + 1);
        this.selectedDate = d.toISOString()
        if(this.selectedDate != null) {
            this.callForData()
            this.showSlots = true
        } 
        this.timeValue = 'All Day';
        this.timeslotMap = 'All Day';
        this.setLang();
        this.setPrevButtonState()
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
    }

    filterSlotsByTime(timeValue) {
        let filteredMap = JSON.parse(JSON.stringify(this.notFilteredTimeslotMap));
    
        filteredMap.forEach(resource => {
            resource.slots = resource.slots.filter(slotTime => {
                const dateObj = new Date(slotTime);
                const hour = dateObj.getUTCHours(); // Use getHours() for local time
    
                if (timeValue === 'AM') {
                    return hour >= 0 && hour < 12;
                } else if (timeValue === 'PM') {
                    return hour >= 12 && hour < 24;
                } else {
                    return true; // All Day
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
        console.log('selected days:', JSON.stringify([...this.selectedDays]));
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
            console.log('📦 Raw Apex result:', JSON.stringify(result));
    
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
            }
    
            this.showSpinner = false;
        })
        .catch(error => {
            console.error('❌ Error in getTimeSlots:', error);
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
        console.log(this.prescription)
    }

    handleTaskComment(event) {
        this.taskComment = event.target.value;
    }

    handleSubmit() {
        this.disableButton = true;
        this.showSpinner = true;
        saveLead({
            firstName: this.contact.firstName,
            lastName: this.contact.lastName,
            email: this.contact.email,
            phone: this.contact.phone,
            rrNr: this.contact.RSZ,
            noRrNr : this.contact.hasNoRSZ,
            endUserBirthdate: this.contact.birthdate,
            street: this.contact.street,
            postalcode: this.contact.postalCode,
            city: this.contact.city,
            // country: this.contact.country,
            country: 'Belgium',
            onBehalveOf: this.contact.bookedForSelf,
            relationship: this.contact.relationToPatient,
            yourFirstName:this.contact.bookedForFirstName,
            yourLastName:this.contact.bookedForLastName,
            yourEmail: this.contact.bookedForEmail,
            yourPhone:this.contact.bookedForPhone
        }).then(result => {
            console.log('savelead response' + result)
            console.log(JSON.stringify(result))
            saveTask({
                leadid: result,
                worktypeName: this.worktype.WorkTypeName,
                dagdeel: this.timeslotMap.toString(),
                dagen: Array.from(this.selectedDays).join(', '),
                voorschrift: this.prescription,
                opmerkingen: this.taskComment,
                serviceTerritoryName: this.location.recordName,
                rrNr: this.contact.RSZ
            }).then(taskResult => {
                this.showSpinner = false;
                console.log('savetask response ' + taskResult)
                this.response.type = 'success';
                this.response.message = 'Request succesfully created';
                this.showModal = true;
            }).catch(error => {
                this.showSpinner = false;
                console.log('Taskerror' + JSON.stringify(error))
                this.response.type = 'error';
                this.response.message = 'Something went wrong, please try again';
                this.showModal = true;
            })
        }).catch(error => {
            console.log('error' + JSON.stringify(error))
            this.response.type = 'error';
            this.response.message = 'Something went wrong, please try again';
            this.showModal = true;
        })
 }

    handleModalClose() {
        this.showModal = false;
    }

}