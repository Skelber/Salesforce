import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import FirstName from '@salesforce/schema/Contact.FirstName';
import LastName from '@salesforce/schema/Contact.LastName';
import Id from '@salesforce/schema/Contact.Id';
import AccountId from '@salesforce/schema/Contact.AccountId';

export default class ContactsTable extends LightningElement {

    @api records = [];
    @api allowedContacts;
    collectionSize = 0;
    @api recordId;
    @api fieldColumns = [
        {label: 'Voornaam', fieldName: 'FirstName'},
        {label: 'Achternaam', fieldName: 'LastName'},
    ];
 

      @wire(getRecord, { recordId: "$recordId", fields: [FirstName, LastName, Id, AccountId] })
      record({ error, data }) {
        if (data) {
          // let tempArray = [...this.records];
          this.record = data;
          this.error = undefined;
          } else if (error) {
            this.error = error;
            this.record = undefined;
          }
        }
      

    connectedCallback() {
        this.collectionSize = this.records.length;
    }

    addContact() {
        let tempArray = [...this.records];
        tempArray.push({
        FirstName:getFieldValue( this.record, FirstName)
        ,LastName:getFieldValue( this.record, LastName)
        ,Id:getFieldValue( this.record, Id)
        ,AccountId:getFieldValue( this.record, AccountId)
      });
      this.records = tempArray;
      this.collectionSize = this.records.length;
        
    }

    handleChange(event) {
        this.recordId = event.detail.recordId;
    }


}