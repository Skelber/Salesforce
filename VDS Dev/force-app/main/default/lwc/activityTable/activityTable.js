import { api, wire, track, LightningElement } from 'lwc';
import getActivitiesApex from '@salesforce/apex/ActivityUtils.getActivities';
import getLabelsOfTaskSubtype from '@salesforce/apex/ActivityUtils.getLabelsOfTaskSubtype';
import getLabelsOfEventSubtype from '@salesforce/apex/ActivityUtils.getLabelsOfEventSubtype';
import { refreshApex } from '@salesforce/apex';
import getTaskFields from '@salesforce/apex/ActivityUtils.getTaskFields';
import REGISTRATION_LABEL from '@salesforce/label/c.Registration';
import NORESULTS_LABEL from '@salesforce/label/c.No_Results';
import ACTIONRELATES_LABEL from '@salesforce/label/c.Action_relates';
import ACTION_LABEL from '@salesforce/label/c.Action';
import TYPE_LABEL from '@salesforce/label/c.Type';
import ACTIVITYDATE_FIELD from '@salesforce/schema/Task.ActivityDate';

const MILISECONDS_IN_DAY = 86400000;
const TASK_STATUS_COMPLETED = 'Completed';
const TASK_EMAIL = 'Email';
const TODAY = 'today';
const LASTWEEK = 'lastWeek';
const NEXTWEEK = 'nextWeek';
const SETRANGE = 'setRange';
const DEFAULTSORTFIELD = 'dateActivity';
const DEFAULTSORTDIRECTION = 'desc';
const NOSUBJECT_LABEL = 'NoSubject;'
const FIELDNAME_ACTIVITYDATE = 'activitydate';
const FIELDNAME_STATUS = 'status';
const FIELDNAME_SUBJECT = 'subject';
const FIELDNAME_OWNERID = 'ownerid';

export default class ActivityTable extends LightningElement {
    @api recordId;
    @track activitiesWireResult;
    allActivities = [];
    allOwners = [];
    _activities = [];
    types = [];

    _showTable = false;
    showSpinner = true;

    activityFilterFromFilter;
    typeFilter;
    dateActivity;
    owners;
    startDate;
    endDate;
    sortBy;
    sortDirection;

    label = {
        registration: REGISTRATION_LABEL,
        noSubject: NOSUBJECT_LABEL,
        noResultsMessage: NORESULTS_LABEL,
    }

    @wire(getTaskFields)
    taskFields;
    @wire(getLabelsOfTaskSubtype)
    taskSubTypeLabels;
    @wire(getLabelsOfEventSubtype)
    eventSubTypeLabels;

    //get all activities
    @wire(getActivitiesApex, { recordId: '$recordId' })
    activitiesWire(wireResult) {
        this.activitiesWireResult = wireResult;
        const { data, error } = wireResult;
        if (data) {
            if (data != null) {
                let count = 0;
                let activitiesTemp = [];
                let ownersTemp = [];
                let ownerIds = [];
                for (const activity of data) {
                    activitiesTemp.push({
                        id: count++,
                        activityURL: '/' + activity.id,
                        dateActivity: activity.dateActivity,
                        status: activity.status,
                        assignedTo: activity.assignedTo,
                        assignedToId: activity.assignedToId.toString(),
                        subject: activity.subject ? activity.subject : this.label.noSubject,
                        relatedTo: activity.relatedTo,
                        action: activity.action,
                        taskSubType: activity.taskSubType,
                        eventSubType: activity.eventSubType,
                        type: this.setType(activity),
                        actionCase: activity.actionCase
                    })
                    //gather owners to show in the filter possibilities
                    if (ownersTemp.length < 1) {
                        ownerIds.push(activity.assignedToId.toString());
                        ownersTemp.push({
                            label: activity.assignedTo,
                            value: activity.assignedToId.toString(),
                        })
                    } else {
                        if (!ownerIds.includes(activity.assignedToId.toString())) {
                            ownersTemp.push({
                                label: activity.assignedTo,
                                value: activity.assignedToId.toString(),
                            })
                        }
                        ownerIds.push(activity.assignedToId.toString());
                    }
                }
                this.allActivities = JSON.parse(JSON.stringify(activitiesTemp));
                this.activities = this.allActivities;
                this.sortData(DEFAULTSORTFIELD, DEFAULTSORTDIRECTION);
                this.setAllPossibleTypes(this.allActivities);
                this.allOwners = JSON.parse(JSON.stringify(ownersTemp));
                this.showSpinner = false;
            }
        }
        if (error) {
            console.error(error);
        }
    }

    get activities() {
        return this._activities;
    }

    set activities(value) {
        if (value != null && value != undefined) {
            this._activities = value;
        }
    }

    get showNoResultsMessage() {
        return this.filtered && this.activities?.length < 1 ? true : false;
    }
    
    get filtered(){
        return this.isNotNull(this.typeFilter) || this.isNotNull(this.dateActivity) || this.isNotNull(this.owners) ? true : false;
    }

    get columns() {
        return [
            { label: this.dateLabel, sortable: true, fieldName: 'dateActivity', type: 'date', initialWidth: 95, hideDefaultActions: true },
            { label: this.actionLabel, sortable: true, fieldName: 'actionCase', initialWidth: 95, hideDefaultActions: true },
            { label: this.typeLabel, sortable: true, fieldName: 'type', initialWidth: 100, hideDefaultActions: true },
            { label: this.subjectLabel, sortable: true, fieldName: 'activityURL', hideDefaultActions: true, type: 'url', target: '_self', typeAttributes: { label: { fieldName: 'subject' } } },
            { label: this.statusLabel, sortable: true, fieldName: 'status', initialWidth: 80, hideDefaultActions: true },
            // { label: this.actioncolumnlabel, sortable: true, fieldName: 'action', initialWidth: 170, hideDefaultActions: true },
            { label: this.ownerLabel, sortable: true, fieldName: 'assignedTo', initialWidth: 170, hideDefaultActions: true },
        ];
    }

    get dateLabel() {
        if (this.taskFields && this.taskFields.data) {
            for (const field of this.taskFields.data) {
                if (field.fieldName === FIELDNAME_ACTIVITYDATE) {
                    return field.fieldLabel;
                }
            }
        }
    }

    get statusLabel() {
        if (this.taskFields && this.taskFields.data) {
            for (const field of this.taskFields.data) {
                if (field.fieldName === FIELDNAME_STATUS) {
                    return field.fieldLabel;
                }
            }
        }
    }

    get subjectLabel() {
        if (this.taskFields && this.taskFields.data) {
            for (const field of this.taskFields.data) {
                if (field.fieldName === FIELDNAME_SUBJECT) {
                    return field.fieldLabel;
                }
            }
        }
    }

    get ownerLabel() {
        if (this.taskFields && this.taskFields.data) {
            for (const field of this.taskFields.data) {
                if (field.fieldName === FIELDNAME_OWNERID) {
                    return field.fieldLabel;
                }
            }
        }
    }
    get actioncolumnlabel(){
        return ACTIONRELATES_LABEL;
    }

    get actionLabel(){
        return ACTION_LABEL;
    }

    get typeLabel(){
        return TYPE_LABEL;
    }

    get showTable() {
        if (this.isNotNull(this.columns) && this.taskLabels && this.eventlabels) {
            return true;
        }
        return this._showTable;
    }

    set showTable(value) {
        value != null ? this._showTable = value : false;
    }


    get taskLabels(){
        if (this.taskSubTypeLabels?.data){
            return JSON.parse(JSON.stringify(this.taskSubTypeLabels.data));
        }
    }

    get eventlabels(){
        if(this.eventSubTypeLabels?.data){
            return JSON.parse(JSON.stringify(this.eventSubTypeLabels.data));
        }
    }

    async processActivityFilter(event) {
        this.typeFilter = event.detail.type;
        this.dateActivity = event.detail.dateActivity;
        this.owners = event.detail.owners;
        if (this.dateActivity && this.dateActivity.label === SETRANGE) {
            this.startDate = event.detail.dateRange.startDate;
            this.endDate = event.detail.dateRange.endDate;
        }
        this.showFilterResults();
    }

    setType(activity) {
        if (activity.taskSubType && activity.taskSubType != TASK_EMAIL && activity.status && activity.status === TASK_STATUS_COMPLETED) {
            return this.label.registration;
        } else if (activity.taskSubType && this.taskSubTypeLabels?.data) {
            for (const label in this.taskLabels) {
                if (Object.hasOwnProperty.call(this.taskLabels, label)) {
                    const element = this.taskLabels[ label ];
                    if (label === activity.taskSubType) {
                        return element;
                    }

                }
            }
        } else if (activity.eventSubType) {
            for (const label in this.eventlabels) {
                if (Object.hasOwnProperty.call(this.eventlabels, label)) {
                    const element = this.eventlabels[ label ];
                    if (label === activity.eventSubType) {
                        return element;
                    }
                }
            }
        }
    }

    setAllPossibleTypes(allActivities) {
        let typesTemp = new Set();
        this.types = [];
        if (allActivities) {
            for (const activity of allActivities) {
                typesTemp.add(activity.type);
            }
        }
        typesTemp.forEach(type => {
            this.types.push({ label: type, value: type });
        });
    }

    

    showFilterResults() {
        let sortedActivities = [];
        for (const activity of this.allActivities) {
            let isValidActivity = true;
            if (this.isNotNull(this.owners) && !this.hasSameOwners(activity)) {
                isValidActivity = false;
            }
            if (this.isNotNull(this.dateActivity) && !this.isSameDateActivity(activity)) {
                isValidActivity = false;
            }
            if (this.isNotNull(this.typeFilter) && !this.hasSameTypes(activity)) {
                isValidActivity = false;
            }
            if (isValidActivity) {
                sortedActivities.push(activity);
            }
        }
        this.activities = sortedActivities;
        this.sortData(DEFAULTSORTFIELD, DEFAULTSORTDIRECTION);
    }

    hasSameOwners(activity) {
        for (const owner of this.owners) {
            if (owner === activity.assignedToId) {
                return true;
            }
        }
        return false;
    }

    isSameDateActivity(activity) {
        if(activity.dateActivity){
            if (this.dateActivity.label === TODAY && activity.dateActivity === this.dateToString(new Date())) {
                return true;
            }
            if (this.dateActivity.label === LASTWEEK) {
                return this.processDateLastWeek(activity);
            }
            if (this.dateActivity.label === NEXTWEEK) {
                return this.processDateNextWeek(activity);
            }
            if (this.dateActivity.label === SETRANGE) {
                return this.processDateRange(activity);
            }
        }
        return false;
    }

    hasSameTypes(activity) {
        for (const type of this.typeFilter) {
            if (type === activity.type) {
                return true;
            }
        }
        return false;
    }

    isNotNull(variable) {
        return variable && variable != null && variable != undefined && variable != '';
    }

    resetFilter() {
        this.typeFilter = [];
        this.dateActivity = null;
        this.owners = [];
        this.activities = this.allActivities;
        this.refreshData();
    }

    async refreshData() {
        if(this.filtered){
            await refreshApex(this.activitiesWireResult);
            this.showFilterResults();
        } else {
            await refreshApex(this.activitiesWireResult);
        }
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.activities));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[ fieldname ];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1 : -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.activities = parseData;
    }

    dateToString(date) {
        let day;
        let month = date.getMonth() < 12 ? date.getMonth() + 1 : 1;
        if (month.toString().length === 1) {
            month = `0${ month }`;
        }
        if (date.getDate().toString().length === 1) {
            day = `0${ date.getDate() }`;
        } else {
            day = date.getDate();
        }
        let dateString = `${ date.getFullYear() }-${ month }-${ day }`;
        return dateString;
    }

    processDateLastWeek(activity) {
        for (let days = 0; days < 7; days++) {
            let dateTemp = new Date();
            let dateToVerify = this.dateToString(new Date(dateTemp.getTime() - (days * MILISECONDS_IN_DAY)));
            if (activity.dateActivity === dateToVerify){
                return true;
            };
        }
        return false;
    }

    processDateNextWeek(activity) {
        for (let days = 0; days < 7; days++) {
            let dateTemp = new Date();
            let dateToVerify = this.dateToString(new Date(dateTemp.getTime() + (days * MILISECONDS_IN_DAY)));
            if (activity.dateActivity === dateToVerify){
                return true;
            }
        }
        return false;
    }

    processDateRange(activity) {
        const startDate = new Date(this.startDate);
        const endDate = new Date(this.endDate);
        let dateDifferenceInMinutes = (endDate.getTime() - startDate.getTime()) / 1000;
        let dateDifferenceInDays = dateDifferenceInMinutes / (60 * 60 * 24);
        for (let days = 0; days <= dateDifferenceInDays; days++) {
            let dateTemp = new Date(startDate);
            let dateToVerify = this.dateToString(new Date(dateTemp.getTime() + (days * MILISECONDS_IN_DAY)));
            if(activity.dateActivity === dateToVerify){
                return true;
            }
        }
        return false;
    }
}