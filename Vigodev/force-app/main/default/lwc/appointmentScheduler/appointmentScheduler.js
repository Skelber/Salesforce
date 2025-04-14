// LLP-1573

import { LightningElement, api, wire, track } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import {getPicklistValues  } from 'lightning/uiObjectInfoApi';
import NAME_FIELD from '@salesforce/schema/Account.Name'
import MOBILE_FIELD from '@salesforce/schema/Account.PersonMobilePhone'
import EMAIL_FIELD from '@salesforce/schema/Account.PersonEmail'
import SRNAME_FIELD from '@salesforce/schema/ServiceResource.Name'
import LOCATION_NAME_FIELD from '@salesforce/schema/ServiceTerritory.Name'
import WORKTYPE_NAME_FIELD from '@salesforce/schema/WorkType.Name'
import WORKTYPE_DURATION_FIELD from '@salesforce/schema/WorkType.DurationInMinutes'
import PG_FIELD from '@salesforce/schema/WorkTypeGroup.Product_Group__c'
import PSG_FIELD from '@salesforce/schema/WorkTypeGroup.Product_SubGroup__c'
import AT_FIELD from '@salesforce/schema/WorkTypeGroup.Appointment_Type__c'
import BU_FIELD from '@salesforce/schema/WorkTypeGroup.Business_Unit__c'
import getData from '@salesforce/apex/AppointmentSchedulerController.getData';
import getMultiResourceData from '@salesforce/apex/AppointmentSchedulerController.getMultiResourceData';
import getWorkType from '@salesforce/apex/AppointmentSchedulerController.getWorkType';
import getServiceTerritoryIds from '@salesforce/apex/AppointmentSchedulerController.getServiceTerritoryIds';
import createServiceAppointment from '@salesforce/apex/AppointmentSchedulerController.createServiceAppointment';
import calculateWeekDays from '@salesforce/apex/AppointmentSchedulerController.calculateWeekdays';
import calculateDays from '@salesforce/apex/AppointmentSchedulerController.calculatedays';
import setdays from '@salesforce/apex/AppointmentSchedulerController.setDate';
import { NavigationMixin } from "lightning/navigation";
import { createMessageContext, releaseMessageContext, publish, subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';
import serviceAppointmentChannel from '@salesforce/messageChannel/serviceAppointment__c';
import ConfirmationModal from 'c/confirmationModal';
import styles from '@salesforce/resourceUrl/RemoveDateFormatStyle';
import notFound from '@salesforce/resourceUrl/notFound';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference } from 'lightning/navigation';



//Import custom labels
import BusinessUnit from "@salesforce/label/c.AppointmentSchedulerBusinessUnitLabel"
import ProductGroup from "@salesforce/label/c.AppointmentSchedulerProductGroup"
import ProductSubGroup from "@salesforce/label/c.AppointmentSchedulerProductSubGroup"
import AppointmentType from "@salesforce/label/c.AppointmentSchedulerAppointmentType"
import PrimaryProvider from "@salesforce/label/c.AppointmentSchedulerPrimaryProvider"
import SecondaryProvider from "@salesforce/label/c.AppointmentSchedulerSecondaryProvider"
import Location from "@salesforce/label/c.AppointmentSchedulerLocation"
import ScheduledDays from "@salesforce/label/c.AppointmentSchedulerScheduledDays"
import Time from "@salesforce/label/c.AppointmentSchedulerTime"
import DatePicker from "@salesforce/label/c.AppointmentSchedulerDateSelection"
import WorkType from "@salesforce/label/c.AppointmentSchedulerWorktype"
import BusinessUnitGuidance from "@salesforce/label/c.AppointmentSchedulerBusinessUnitGuidance"
import BusinessUnitGuidanceSubText from "@salesforce/label/c.AppointmentSchedulerBusinessUnitGuidanceSubtext"
import ProductGroupGuidance from "@salesforce/label/c.AppointmentSchedulerProductGroupGuidingText"
import ProductGroupGuidanceSubText from "@salesforce/label/c.AppointmentSchedulerProductGroupGuidingSubText"
import ProductSubGroupGuidance from "@salesforce/label/c.AppointmentSchedulerProductSubGroupGuidingText"
import ProductSubGroupGuidanceSubText from "@salesforce/label/c.AppointmentSchedulerProductSubGroupGuidingSubText"
import AppointmentTypeGuidance from "@salesforce/label/c.AppointmentSchedulerAppointmentTypeGuidingText"
import AppointmentTypeGuidanceSubText from "@salesforce/label/c.AppointmentSchedulerAppointmentTypeGuidingSubText"
import LocationGuidance from "@salesforce/label/c.AppointmentSchedulerLocationGuidingText"
import LocationGuidanceSubText from "@salesforce/label/c.AppointmentSchedulerLocationGuidingSubText"
import Monday from "@salesforce/label/c.AppointmentSchedulerMonday"
import Tuesday from "@salesforce/label/c.AppointmentSchedulerTuesday"
import Wednesday from "@salesforce/label/c.AppointmentSchedulerWednesday"
import Thursday from "@salesforce/label/c.AppointmentSchedulerThursday"
import Friday from "@salesforce/label/c.AppointmentSchedulerFriday"
import AllDays from "@salesforce/label/c.AppointmentSchedulerDaySelectionAll"
import AllDay from "@salesforce/label/c.AppointmentSchedulerTimeSelectionAllDay"
import AM from "@salesforce/label/c.AppointmentSchedulerTimeSelectionAM"
import PM from "@salesforce/label/c.AppointmentSchedulerTimeSelectionPM"
import Lookup from "@salesforce/label/c.AppointmentSchedulerLookupPlaceholder"
import Today from "@salesforce/label/c.AppointmentSchedulerToday"
import AccountName from "@salesforce/label/c.AppointmentSchedulerAccountName"
import AccountEmail from "@salesforce/label/c.AppointmentSchedulerAccountEmail"
import AccountMobile from "@salesforce/label/c.AppointmentSchedulerAccountMobile"
import ProviderOrLocationGuidance from "@salesforce/label/c.AppointmentSchedulerProviderOrLocationGuidingText"
import NoSlotsAvailable from "@salesforce/label/c.AppointmentSchedulerNoSlotsAvailable"
import DurationInMinutes from "@salesforce/label/c.AppointmentSchedulerDurationInMinutes"
import FirstAvailableLabel from "@salesforce/label/c.AppointmentSchedulerFirstAvailableDate"


import PatientLABEL from "@salesforce/label/c.ConfirmationModalPatient"
import ServiceProviderLABEL from "@salesforce/label/c.ConfirmationModalServiceProvider"
import ServiceLocationLABEL from "@salesforce/label/c.ConfirmationModalServiceLocation"
import WorkTypeLABEL from "@salesforce/label/c.ConfirmationModalWorktype"
import StartTimeLABEL from "@salesforce/label/c.ConfirmationModalStartTime"
import EndTimeLABEL from "@salesforce/label/c.ConfirmationModalEndTime"
import ButtonLabelLABEL from "@salesforce/label/c.ConfirmationModalCreateButton"
import DescriptionLABEL from "@salesforce/label/c.ConfirmationModalDescription"



export default class CalendarTest extends NavigationMixin(LightningElement)  {

    @wire(CurrentPageReference)
    currentPageRef;

    @api recordId;

    get recordId() {
        return this.currentPageRef.state.c__recordId;
    }

    currentPageRef;
    context = createMessageContext();
    notFoundImg = notFound;
    subscribtion = null;
    @track receivedMessage;
    @api locationRecordId;
    account
    accountId
    @api accName
    @api accMobile
    @api accEmail
    @api locationName;
    availableSlots = [];
    currentDate;
    showCalendar = false;
    showNoDataAvailable = false;
    businessUnit;
    workTypeGroup;
    @api workType;
    workTypeDuration;
    bu;
    location = null;
    locationArray = []
    serviceResources = []
    user;
    primaryServiceResource;
    primaryServiceResourceName;
    user2;
    secondaryServiceResource;
    secondaryServiceResourceName;
    territoryName;
    guidingText = BusinessUnitGuidance
    guidingSubText = BusinessUnitGuidanceSubText
    dayValue;
    timeValue;
    @track PGOptions;
    PGOptionsCopy;
    @track PSGOptions;
    PSGOptionscopy;
    @track ATOptions;
    ATOptionsCopy;
    @track BUOptions;
    confirmedStart;
    confirmedEnd;
    confirmedLocaction;
    showModal = false;
    disableConfirm = false
    disablePrimaryProvider = false
    disableServiceTerritory = false
    resourceCounter = 0;
    disableNavBtn;
    @track buVal;
    @track pgVal;
    @track psgVal;
    @track atVal;
    disableBU;
    disablePG;
    disablePSG;
    disableAT;
    disableSecondaryResource;
    multiResourceBooking = false
    @track events=[];
    @track resourceMap = [];
    @track multipleResourceMap = [];
    calendar;
    showSpinner = false
     @wire(MessageContext)
    messageContext;
    mondayDate;
    colOneHeader;
    tuesdayDate;
    colTwoHeader;
    wednesdayDate;
    colThreeHeader;
    thursdayDate;
    colFourHeader
    fridayDate;
    colFiveHeader;
    colSixHeader;
    headerValues = []
    workTypeName;
    isExpanded = false;
    resourceIds = [];
    multiResourceEvents = [];
    multiResourceEventsLoaded = false
    disableCallForData = false
    PatientLABEL = PatientLABEL
    ServiceProviderLABEL = ServiceProviderLABEL
    ServiceLocationLABEL = ServiceLocationLABEL
    WorkTypeLABEL = WorkTypeLABEL
    StartTimeLABEL = StartTimeLABEL
    EndTimeLABEL = EndTimeLABEL
    ButtonLabelLABEL = ButtonLabelLABEL
    DescriptionLABEL = DescriptionLABEL


    label = {
        BusinessUnit,
        ProductGroup,
        ProductSubGroup,
        AppointmentType,
        PrimaryProvider,
        SecondaryProvider,
        Location,
        ScheduledDays,
        Time,
        DatePicker,
        WorkType,
        Monday,
        Tuesday,
        Wednesday,
        Thursday,
        Friday,
        AllDays,
        AllDay,
        AM,
        PM,
        Lookup,
        Today,
        AccountName,
        AccountEmail,
        AccountMobile,
        NoSlotsAvailable,
        DurationInMinutes,
        FirstAvailableLabel
    }
   

    @wire(getRecord, { recordId: "$recordId", fields: [NAME_FIELD, MOBILE_FIELD, EMAIL_FIELD] })
      record({ error, data }) {
        if (data) {
            this.account = data;
            this.accountId = data.fields.Id;
            this.accName = data.fields.Name.value;
            this.accMobile = data.fields.PersonMobilePhone.value;
            this.accEmail = data.fields.PersonEmail.value;
        } else if (error) {
            this.error = error;
        }
      }

    @wire(getRecord, { recordId: "$location", fields: [LOCATION_NAME_FIELD] })
      locationRecord({ error, data }) {{}
        if (data) {
            this.locationRecord = data;
            this.locationName = data.fields.Name.value;
        } else if (error) {
            this.error = error;
        }
      }

    @wire(getRecord, { recordId: "$workType", fields: [WORKTYPE_NAME_FIELD, WORKTYPE_DURATION_FIELD] })
      worktypeRecord({ error, data }) {
        if (data) {
            this.worktypeRecord = data;
            this.workTypeName = data.fields.Name.value;
            this.workTypeDuration = data.fields.DurationInMinutes.value;
        } else if (error) {
            this.error = error;
        }
      }

        @wire(getRecord, { recordId: "$user", fields: [SRNAME_FIELD]})
      resource({ error, data }) {
        if (data) {
            this.primaryServiceResource = data;
            this.primaryServiceResourceName = data.fields.Name.value;
        } else if (error) {
            this.error = error;
        }
      }

      @wire(getRecord, { recordId: "$user2", fields: [SRNAME_FIELD]})
      resource2({ error, data }) {
        if (data) {
            this.secondaryServiceResource = data;
            this.secondaryServiceResourceName = data.fields.Name.value;
        } else if (error) {
            this.error = error;
        }
      }

    get dayOptions() {
        return [
            { label: this.label.Monday, value: 'Mon' },
            { label: this.label.Tuesday, value: 'Tue' },
            { label: this.label.Wednesday, value: 'Wed' },
            { label: this.label.Thursday, value: 'Thu' },
            { label: this.label.Friday, value: 'Fri' },
            { label: this.label.AllDays, value: 'All' },
        ];
    }

    get timeOptions() {
        return [
            { label: this.label.AM, value: 'AM' },
            { label: this.label.PM, value: 'PM' },
            { label: this.label.AllDay, value: 'All Day' },
        ];
    }

    setDayValues(event){
        this.dayValue = event.target.value;
        this.callForData();
    }

    setTimeValues(event){
        this.timeValue = event.target.value;
        this.callForData();
    }

    setCurrentDate(event){
        this.currentDate = event.target.value;
         if(this.dayValue == 'All'){
            this.setDates()
        } else {
            this.setIndividualDates()
        }
        this.callForData();
    }

    setDates(){
        calculateWeekDays({
            startDate: this.currentDate
        }).then((result) => {
            if(this.dayValue == 'All') {
                this.colOneHeader = result.mondayDate;
                this.colTwoHeader = result.tuesdayDate;
                this.colThreeHeader = result.wednesdayDate;
                this.colFourHeader = result.thursdayDate;
                this.colFiveHeader = result.fridayDate;
                this.colSixHeader = result.saturdayDate;
                this.resourceMap = [];
            }
        }).catch(error => console.log(error))
    }

    setIndividualDates(startDate){
        this.headerValues = []
        this.resourceMap =[]
        calculateDays({
            startDate: this.currentDate,
            dayOfWeek: this.dayValue
        }).then((result) => {
            this.colOneHeader = result.mondayDate;
            this.colTwoHeader = result.tuesdayDate;
            this.colThreeHeader = result.wednesdayDate;
            this.colFourHeader = result.thursdayDate;
            this.colFiveHeader = result.fridayDate;
            this.colSixHeader = result.saturdayDate;
            this.resourceMap = [];
        }).catch(error => console.log(error))
    }

    getTerritories(){
        getServiceTerritoryIds({
            serviceResourceIds: this.serviceResources
        }).then((result) =>{
            for(let i = 0; i < result.length; i++){
                this.locationArray.push(result[i])
            }
            this.callForData();
        });
    }

    handleNext(event){
        setdays({
            currentDate: this.currentDate,
            actionName: event.target.value
        }).then((result) => { 
            this.currentDate = result;
            clearTimeout(this.timeout);
            this.timeout = setTimeout(() => {
            this.resetTimeSlots();   
        }, 300);

        });
    }

    jumpToToday(){
        this.currentDate = new Date().toISOString();
        this.callForData();
    }

    jumpToDate(event){
       this.currentDate = new Date(event.target.value).toISOString();
       this.callForData();
    }

     connectedCallback() {
        this.subscribe();
        this.currentDate = new Date().toISOString();
        this.dayValue = 'All';
        this.timeValue = 'All Day';
        this.setDates();
        this.disablePG = true;
        this.disablePSG = true;
        this.disableAT = true;
        this.disablePrimaryProvider = true;
        this.disableSecondaryResource = true;
        this.disableServiceTerritory = true;
    }


    // start Import picklist section

    @wire(getPicklistValues, {recordTypeId: "012000000000000AAA", fieldApiName: BU_FIELD})
    pickListValuesBU({error,data}) {
        if (data) {
            this.BUOptions = data.values.map(plValue => {
                return{
                    label: plValue.label,
                    value: plValue.value
                }
            })
        }
    }

    @wire(getPicklistValues, {recordTypeId: "012000000000000AAA", fieldApiName: PG_FIELD})
    pickListValuesPG({error,data}) {
        if(data){
            this.PGOptions = data;
        } 
    }

    @wire(getPicklistValues, {recordTypeId: "012000000000000AAA", fieldApiName: PSG_FIELD})
    pickListValuesPSG({error,data}) {
        if (data) {
            this.PSGOptions = data;
        } 
    }
    @wire(getPicklistValues, {recordTypeId: "012000000000000AAA", fieldApiName: AT_FIELD})
    pickListValuesAT({error,data}) {
        if (data) {
            this.ATOptions = data;
        } 
    }
 
    //End import picklist section
    
    handleWTChange(event) {
        this.workType = event.detail.recordId;
        if(this.workType){
            this.disableBU = true;
            this.disablePrimaryProvider = false;
            this.disableServiceTerritory = false;
            this.callForData();
        } this.disableBU = false
    }

    handleDurationChange(event){
        this.workTypeDuration = event.target.value;
            clearTimeout(this.timeout);
            this.timeout = setTimeout(() => {
                this.callForData();
                // if (this.workTypeDuration.length >= 2) {
                // }
            }, 500);
    }

    handleBUChange(event){
        this.buVal = event.target.value;
        if(this.buVal){
            this.PGOptionsCopy = this.PGOptions;
            this.disablePG = false
            this.setGuidingText();
            let key = this.PGOptions.controllerValues[event.target.value];
            this.PGOptionsCopy = this.PGOptions.values.filter(opt=> opt.validFor.includes(key));
        } else {
            this.disablePG = true
        }
    }

    handlePGChange(event) {
        this.pgVal = event.target.value;
        if(this.pgVal){
            this.PSGOptionsCopy = this.PSGOptions;
            this.disablePSG = false;
            this.setGuidingText();
            let key = this.PSGOptions.controllerValues[event.target.value];
            this.PSGOptionsCopy = this.PSGOptions.values.filter(opt=> opt.validFor.includes(key));
        } else {
            this.disablePSG = true;
        }
    }

    handlePSGChange(event) {
        this.psgVal = event.target.value;
        if(this.psgVal) {
            this.ATOptionsCopy = this.ATOptions;
            this.disableAT = false;
            this.setGuidingText();
            let key = this.ATOptions.controllerValues[event.target.value];
            this.ATOptionsCopy = this.ATOptions.values.filter(opt=> opt.validFor.includes(key));
        } else {
            this.disableAT = true
        }
    }

    handleATChange(event) {
        this.atVal = event.target.value;
        this.disablePrimaryProvider = false;
        this.disableServiceTerritory = false;
        this.setGuidingText();
        if(this.atVal) {           
            getWorkType({
                 bu: this.buVal,
                 pg: this.pgVal,
                 psg: this.psgVal,
                 at: this.atVal
            }).then((result) => {
                this.workType = result.id;
                this.workTypeDuration = result.duration;
                this.workTypeName = result.name;
                this.setGuidingText();
            })
            .catch((error) => {
            console.log(error);
            });        
            };
        } 
        
    

    handleSTChange(event) {
        this.location = event.detail.recordId;
        this.confirmedLocaction = event.detail.Name;
        this.callForData();
    }
    handleUserChange(event) {
        this.locationArray = [];
        this.user = event.detail.recordId;
        this.serviceResources[0] = event.detail.recordId;
        this.handleMultiResourceBooking()
        if(this.user){
            this.getTerritories();
            this.disableSecondaryResource = false
        } else (
            this.user2 = null,
            this.refs.userPicker2.clearSelection(),
            this.callForData()
        )
    }
    handleUser2Change(event) {
        this.locationArray = [];
        this.user2 = event.detail.recordId;
        this.serviceResources[1] = event.detail.recordId;
        this.handleMultiResourceBooking()
        this.getTerritories();
    }

    handleMultiResourceBooking(event) {
       if(this.user && this.user2){
        this.multiResourceBooking = true
       } else {
        this.multiResourceBooking = false
       }
    }
    
    callForData(){
            if(this.workType && (this.location || this.locationArray.length > 0)){
                this.showCalendar = true;
                this.resetTimeSlots();
            } else if(this.workType && !this.location && this.locationArray ){
                this.showCalendar = false,
                this.guidingText = ProviderOrLocationGuidance;
            }
    }

    resetTimeSlots(){
        this.multiResourceEventsLoaded = false
        this.resourceMap = [];
        this.multipleResourceMap = [];
        this.headerValues = [];
        this.multiResourceEvents = [];
        if(this.dayValue == 'All'){
            this.setDates()
        } else {
            this.setIndividualDates()
        }
            if(this.multiResourceBooking){
                this.getMRTimeSlots();
            } else {
                this.getTimeSlots();
            }
    }

    resetFilter() {
        this.buVal=null;
        this.disablePG = true;
        this.pgVal=null;
        this.disablePSG=true;
        this.psgVal=null;
        this.disableAT=true;
        this.atVal=null;
        this.location = null;
        this.locationArray = []
        this.refs.locationPicker.clearSelection();
        this.workType = null;
        this.refs.workTypePicker.clearSelection();
        this.user = null;
        this.refs.userPicker.clearSelection();
        this.user2 = null;
        this.refs.userPicker2.clearSelection();
        this.showCalendar = false;
        this.dayValue = 'All',
        this.timeValue = 'All Day'
        this.currentDate = new Date().toISOString();
        this.workTypeDuration = null;
        this.setGuidingText();
        this.resetTimeSlots();
    }

    setGuidingText(){
        if (!this.buVal) {
            this.guidingText = BusinessUnitGuidance
            this.guidingSubText = BusinessUnitGuidanceSubText
        } else if (!this.pgVal) {
            this.guidingText = ProductGroupGuidance
            this.guidingSubText = ProductGroupGuidanceSubText
        } else if (!this.psgVal) {
            this.guidingText = ProductSubGroupGuidance
            this.guidingSubText = ProductSubGroupGuidanceSubText
        } else if (!this.atVal) {
            this.guidingText = AppointmentTypeGuidance
            this.guidingSubText = AppointmentTypeGuidanceSubText
        } else if (!this.location || !this.user) {
            this.guidingText = ProviderOrLocationGuidance
            this.guidingSubText = LocationGuidanceSubText
        }  else {
            this.callForData();
        }
    }

    handleHeight(event){
        this.isExpanded = !this.isExpanded;
        let targetId = event.target.value;
        let target = this.template.querySelector(`[data-id="${targetId}"]`);
        if(this.isExpanded){
            target.style.maxHeight = "100rem";
        } else {
            target.style.maxHeight = "25rem"
        }
    }

    getMRTimeSlots(){
        this.resourceMap = [];
        this.resourceIds = [];
        this.multipleResourceMap = [];
        
        if(this.multiResourceBooking){
            this.resourceIds.push(this.user)
            this.resourceIds.push(this.user2)
        } else {
            this.resourceIds.push(this.user)
        }
         if(this.workTypeDuration >= 10 && this.workTypeDuration <= 300){
        getMultiResourceData({
            serviceResourceId: this.resourceIds,
            accountId: this.recordId,
            location: this.location ? this.location : this.locationArray,
            wt: this.workType,
            bu: this.buVal,
            pg: this.pgVal,
            psg: this.psgVal,
            at: this.atVal,
            dayValue: this.dayValue,
            TimeValue: this.timeValue,
            currentDate: this.currentDate,
            duration: this.workTypeDuration
        }).then((result) => {
            console.log('location array ' + this.locationArray)
            console.log(JSON.stringify(result));
             if(result) {
                if(result.length > 0 && this.workTypeDuration >= 10 && this.workTypeDuration <= 300){
                    this.showNoDataAvailable = false;
                } else {
                    this.showNoDataAvailable = true;
                }
             }
             result.forEach(element => {

                console.log(element.territoryName)
                    
                    let multipleResources ={
                        territoryName : element.territoryName,
                        territoryId : element.territoryId,
                    };
                    let hasResults;
                    var events = [];
                    var firstAvailableDate;
                    var weekWithSlots = false;
                    if(element.results) {
                    element.hasResults = true;

                        element.results.forEach(timeSlot => {
                            var event = {
                                id: timeSlot.id,
                                start: timeSlot.startTime,
                                end: timeSlot.endTime,
                                duplicateKey: timeSlot.startTime.toString()+timeSlot.endTime.toString(),
                                startDisplay: timeSlot.startTime.substr(17, 5),
                                endDisplay: timeSlot.endTime.substr(17,5),
                                dayOfWeek: timeSlot.dayOfWeek,
                                territoryName: timeSlot.territoryName,
                                elementTName: element.territoryName,
                                territoryId : timeSlot.territoryId,
                                editable: false, 
                                allDay : false,
                                colOneDate: this.colOneHeader.toString(),
                                isForCurrentTerritory : timeSlot.territoryId === multipleResources.territoryId,
                                isForCurrentweek : new Date(timeSlot.eventDate) >= this.colOneHeader && new Date(timeSlot.eventDate) <= this.colFiveHeader,
                                isForColOne: timeSlot.eventDate.toString() === this.colOneHeader.toString(),
                                isForColTwo: timeSlot.eventDate.toString() === this.colTwoHeader.toString(),
                                isForColThree: timeSlot.eventDate.toString() === this.colThreeHeader.toString(),
                                isForColFour: timeSlot.eventDate.toString() === this.colFourHeader.toString(),
                                isForColFive: timeSlot.eventDate.toString() === this.colFiveHeader.toString(),
                                buttonLabel: new Date(timeSlot.startTime).toTimeString().substring(0,5) + " - " + new Date(timeSlot.endTime).toTimeString().substring(0,5),
                                buttonValue: timeSlot.startTime +"$"+ timeSlot.endTime+"$"+element.id+"$"+element.resourceName+"$"+element.territoryName+"$"+element.territoryId,
                            }
                            events.push(event);
                            
                        })
                        multipleResources.events = events;
                        multipleResources.firstAvailableDate = events[0].start;
                        this.multipleResourceMap.push(multipleResources)
                        if(multipleResources.events[0].start >= this.colOneHeader && multipleResources.events[0].start < this.colSixHeader){
                            multipleResources.weekWithSlots = true;
                        } 
                    } else {
                        element.hasResults = false
                    }
                });
                
                
                
            }).catch((error) => {
                console.log(error);
            });
        } else {
            this.showNoDataAvailable = true
        }
    }
    
      getTimeSlots() {
        this.resourceMap = [];
        this.resourceIds = [];
        this.multipleResourceMap = [];
        
        if(this.multiResourceBooking){
            this.resourceIds.push(this.user)
            this.resourceIds.push(this.user2)
        } else {
            this.resourceIds.push(this.user)
        }
        if(this.workTypeDuration >= 10 && this.workTypeDuration <= 300){
        getData({
            serviceResourceId: this.resourceIds,
            accountId: this.recordId,
            location: this.location ? this.location : this.locationArray,
            wt: this.workType,
            bu: this.buVal,
            pg: this.pgVal,
            psg: this.psgVal,
            at: this.atVal,
            dayValue: this.dayValue,
            TimeValue: this.timeValue,
            currentDate: this.currentDate,
            duration: this.workTypeDuration
        })

        .then((result) => {
            if(result) {
                if(result.length > 0){
                    this.showNoDataAvailable = false;
                } else {
                    this.showNoDataAvailable = true;
                }

                let uniqueEvents = []

                result.forEach(element => {
                    this.resourceCounter++;
                    let resource = {
                        id: element.id,
                        title: element.resourceName,
                        territoryName : element.territoryName,
                        territoryId : element.territoryId,
                    };
                    
                    let multipleResources ={
                        id: element.id,
                        title: element.resourceName,
                        territoryName : element.territoryName,
                        territoryId : element.territoryId
                    };
                    var events = [];
                    var weekWithSlots;
                    var firstAvailableDate;
                    var mrEvents = [];
                    if(element.results) {

                        element.results.forEach(timeSlot => {
                            var event = {
                                id: timeSlot.id,
                                start: timeSlot.startTime,
                                end: timeSlot.endTime,
                                duplicateKey: timeSlot.startTime.toString()+timeSlot.endTime.toString(),
                                startDisplay: timeSlot.startTime.substr(17, 5),
                                endDisplay: timeSlot.endTime.substr(17,5),
                                dayOfWeek: timeSlot.dayOfWeek,
                                title: element.resourceName,
                                territoryName: multipleResources.territoryName,
                                territoryId : timeSlot.territoryId,
                                editable: false, 
                                allDay : false,
                                colOneDate: this.colOneHeader.toString(),
                                isForCurrentWeek : timeSlot.startTime >= this.colOneHeader && timeSlot.endTime <= this.colFiveHeader,
                                isForCurrentTerritory : timeSlot.territoryId === multipleResources.territoryId,
                                isForCurrentweek : new Date(timeSlot.eventDate) >= this.colOneHeader && new Date(timeSlot.eventDate) <= this.colFiveHeader,
                                isForColOne: timeSlot.eventDate.toString() === this.colOneHeader.toString(),
                                isForColTwo: timeSlot.eventDate.toString() === this.colTwoHeader.toString(),
                                isForColThree: timeSlot.eventDate.toString() === this.colThreeHeader.toString(),
                                isForColFour: timeSlot.eventDate.toString() === this.colFourHeader.toString(),
                                isForColFive: timeSlot.eventDate.toString() === this.colFiveHeader.toString(),
                                buttonLabel: new Date(timeSlot.startTime).toTimeString().substring(0,5) + " - " + new Date(timeSlot.endTime).toTimeString().substring(0,5),
                                buttonValue: timeSlot.startTime +"$"+ timeSlot.endTime+"$"+element.id.split("-")[0]+"$"+element.resourceName+"$"+element.territoryName+"$"+element.territoryId,
                            }
                            events.push(event);
                            if(uniqueEvents.includes(event.duplicateKey)){
                                mrEvents.push(event);
                                    this.multiResourceEvents.push(event);
                            } else {
                                uniqueEvents.push(event.duplicateKey)
                            }
                        })
                    }
                    resource.events = events;
                    resource.firstAvailableDate = events[0].start;
                    this.resourceMap.push(resource);
                    if(resource.events[0].start >= this.colOneHeader && resource.events[0].start < this.colSixHeader){
                        resource.weekWithSlots = true;
                    } 

                    console.log('times ' + this.colOneHeader + " " + this.colSixHeader + " "  + resource.events[0].start)
                });
            }  
        })
        .catch((error) => {
            console.log(error);
        });
        } else {
            this.showNoDataAvailable = true;
        }
    }

        showEvent(event) {
            const eventValues = event.target.dataset.id.split( "$" );
            this.confirmedStart = eventValues[0];
            this.confirmedEnd = eventValues[1];
            this.resourceId = eventValues[2];
            this.resourceName = eventValues[3];
            this.territoryName = eventValues[4];
            this.location = eventValues[5];

        const result = ConfirmationModal.open({
            size: 'small',
            Start: this.confirmedStart,
            End: this.confirmedEnd,
            ServiceResource: this.resourceName,
            ServiceResource2: this.resourceName2,
            accountName: this.accName,
            locationName: this.locationName ? this.locationName : this.territoryName,
            resourceId: this.resourceId,
            primaryServiceResourceName: this.primaryServiceResourceName,
            userId: this.user,
            secondaryServiceResourceName: this.secondaryServiceResourceName,
            businessUnit: this.buVal,
            productGroup: this.pgVal,
            productSubGroup: this.psgVal,
            appointmentType: this.atVal,
            workTypeName: this.workTypeName,
            multiRsourceBooking: this.multiResourceBooking,
            PatientLABEL: this.PatientLABEL,
            ServiceProviderLABEL: this.ServiceProviderLABEL,
            ServiceLocationLABEL: this.ServiceLocationLABEL,
            WorkTypeLABEL: this.WorkTypeLABEL,
            StartTimeLABEL: this.StartTimeLABEL,
            EndTimeLABEL: this.EndTimeLABEL,
            ButtonLabelLABEL: this.ButtonLabelLABEL,
            DescriptionLABEL: this.DescriptionLABEL
        });
    }

    handleCloseClick() {
        this.showCalendar = false;
        this.receivedMessage = null;
        this.subscribtion.unsubscribe();
    }
    
    subscribe(){
        if(this.subscribtion){
            return;
        }
        this.subscribtion = subscribe(this.messageContext, serviceAppointmentChannel, (serviceAppointment) => {
            this.handleMessage(serviceAppointment),{scope: APPLICATION_SCOPE};
        });
    }

    handleMessage(serviceAppointment){
        this.receivedMessage = serviceAppointment;
        this.confirmedStart =  this.receivedMessage.start;
        this.confirmedEnd = this.receivedMessage.end;
        this.createSA();
        this.showSpinner = true;     
    }
    
    async createSA(){     
           
      await  createServiceAppointment({
            user: this.multiResourceBooking ? this.user : this.receivedMessage.resourceId,
            user2: this.user2,
            account: this.recordId,
            startTime: this.confirmedStart,
            endTime: this.confirmedEnd,
            Location: this.location,
            workType: this.workType,
            duration: this.workTypeDuration,
            description: this.receivedMessage.description
        }).then((result)=> {
            const evt = new ShowToastEvent({
                title: result.title,
                message: result.message,
                variant: result.type
            })
            this.dispatchEvent(evt);
            this.resourceMap = [];
            this.getTimeSlots();
            if(result.type == 'success'){
                this.NavigateToAccountHome();
            }
            this.showSpinner = false;

            

        }).catch((error) => {
            console.log(error);
        });
    }

    NavigateToAccountHome(){
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.recordId,
            objectApiName: 'Account',
            actionName: 'view'
        },
    });
    }
}