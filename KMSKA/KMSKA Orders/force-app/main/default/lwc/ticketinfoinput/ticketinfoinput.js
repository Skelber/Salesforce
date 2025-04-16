import { LightningElement, api, track, wire } from 'lwc';
import { getObjectInfo, getPicklistValues  } from 'lightning/uiObjectInfoApi';
import { getRecord } from "lightning/uiRecordApi";
import PRODNAME_FIELD from '@salesforce/schema/KMSKA_Product__c.NAME'
import NAME_FIELD from '@salesforce/schema/Ticket_info__c.NAME'
import SUBTYPE_FIELD from '@salesforce/schema/Order_Line__c.Sub_Type__c'
import BTW_FIELD from '@salesforce/schema/Ticket_info__c.BTW_Tarief__c'
import PRIJS_FIELD from '@salesforce/schema/Ticket_info__c.Prijs__c'
import PRIJSK_FIELD from '@salesforce/schema/Ticket_info__c.Prijs_Kansentarief__c'
import BESCHIKBARE_PLAATSEN_FIELD from '@salesforce/schema/Ticket_info__c.Beschikbare_plaatsen__c'
import addTicketinfo from '@salesforce/apex/TicketinfoController.addTicketinfo';
import deleteTicketInfo from '@salesforce/apex/TicketinfoController.deleteTickets'
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getTicketinfos from '@salesforce/apex/TicketinfoController.getTicketinfos';
import { refreshApex } from "@salesforce/apex";


export default class TicketInfoInput extends LightningElement {

    @track records = [];
    ticketInfoResponse = [];
    @api fieldColumns = [
        {label: 'Product', fieldName: 'Name'},
        {label: 'Prijs', fieldName: 'Prijs__c'},
        {label: 'Prijs Kansentarief', fieldName: 'Prijs_Kansentarief__c'},
        {label: 'BTW', fieldName: 'BTW_Tarief__c'},
        {label: 'Beschikbaar plaatsen', fieldName: 'Beschikbare_plaatsen__c'},
    ]
    @api recordId;
    ticketinfoid;
    subtypeVal = "";
    prijsVal = 0;
    prijsKVal = 0;
    availableSpaces = 0;
    BeeldmateriaalVal = "";
    @track subtypes
    btwVal;
    @api rowIds = []
    disableButton = false;
    disableDeleteButton = false;
    @track wiredProduct;
    showRecords;

    connectedCallback(){
        this.disableDeleteButton = true;
        this.disableButton = true;
        this.checkCollectionSize();
    }

 

    @wire(getRecord, { recordId: '$recordId', fields:[PRODNAME_FIELD]})
        fetchAcc(response) {
        console.log('Account => ', JSON.stringify(response));
        this.wiredProduct    = response;
    }

    @wire(getTicketinfos, {recordId: '$recordId', fields:[NAME_FIELD, PRIJS_FIELD, PRIJSK_FIELD, BTW_FIELD, BESCHIKBARE_PLAATSEN_FIELD]})
    ticketInfoRecords(response) {
        if(response.data){
            this.ticketInfoResponse = response;
            this.records = response.data;
        } else if(response.error) {
            console.log(error)
        }
    }

    @wire(getPicklistValues, {recordTypeId: "012000000000000AAA", fieldApiName: SUBTYPE_FIELD})
    pickListValues({error,data}) {
        if (data) {
            this.subtypes = data.values.map(plValue => {
                return{
                    label: plValue.label,
                    value: plValue.value
                }
            })
        }
    }

    get BTWOptions() {
        return [
            {label: '0', value: 0},
            {label: '6', value: 6},
            {label: '12', value: 12},
            {label: '21', value: 21}
        ]
    }


    handleChange(event) {
        this.subtypeVal = event.detail.value;
        if(this.subtypeVal) {
            this.disableButton = false
        } else {
            this.disableButton = true
        }
    }
    handlePrijsChange(event) {
        this.prijsVal = event.detail.value;
    }
    handlePrijsKChange(event) {
        this.prijsKVal = event.detail.value;
    }
    handleBtwChange(event) {
        this.btwVal = +event.detail.value;
    }

    handleAvailableSpaces(event){
        this.availableSpaces = event.target.value;
    }

 currentSelectedRows=[]
     getSelectedRows(event) {
            let rows = [];
            const selectedRows = event.detail.selectedRows;
            for (let i = 0; i < selectedRows.length; i++) {
                rows.push(selectedRows[i].Id);
            }
            if (selectedRows.length > 0) {
                this.disableDeleteButton = false;
            } else {
                this.disableDeleteButton = true;
            }
            this.rowIds = rows;
    }

    checkCollectionSize(){
        if (this.ticketInfoRecords.length > 0){
            this.showRecords = true;
        } else {
            this.showRecords = false;
        }
    }

    createTicketInfo() {

        addTicketinfo({
            TckName:this.subtypeVal,
            TckPrijs:this.prijsVal,
            TckKPrijs:this.prijsKVal,
            TckBTW:this.btwVal,
            TckProduct:this.recordId,
            beschikbarePlaatsen: this.availableSpaces
        })
        .then(result => {
            refreshApex(this.ticketInfoResponse);
            const event = new ShowToastEvent({
                title: 'Ticketinfo aangemaakt',
                message: 'Ticket informatie is succesvol aangemaakt',
                variant: 'success'
            });
            this.dispatchEvent(event);
            this.checkCollectionSize();
                refreshApex(this.records)
            this.subtypeVal = "";
            this.prijsVal = "";
            this.prijsKVal = "";
            this.btwVal = "";
            this.availableSpaces = "";
            this.disableButton = true;
        })
        .catch(error => {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Er is een fout opgetreden bij het aanmaken van de ticket info',
                variant: 'error'
            });
            this.dispatchEvent(event);
        })
    }


    deleteTickets(){
        deleteTicketInfo({
             rowIds: this.rowIds
             }).then(result =>{
                 refreshApex(this.ticketInfoResponse)
                 const event = new ShowToastEvent({
                title: 'Ticketinfo verwijderd',
                message: 'Ticket informatie is verwijderd',
                variant: 'success'
            });
            this.disableDeleteButton = true;
            this.dispatchEvent(event);
            this.checkCollectionSize();
                }
            )
        } 

        
    }

