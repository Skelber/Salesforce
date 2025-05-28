import { LightningElement, track, wire, api } from 'lwc';
import getWorkTypologies from '@salesforce/apex/WorktypeSelection.getJSON';
import getWorkType from '@salesforce/apex/WorktypeSelection.getWorkType';
import bandageIcon from "@salesforce/resourceUrl/bandage";
import prostheticIcon from "@salesforce/resourceUrl/prosthetic";
import orthoticIcon from "@salesforce/resourceUrl/orthotics";

export default class SelectWorktype extends LightningElement {

   workTypes = []
   businessUnits = [];
   @track  productGroups = [];
   showProductGroups = false
   @track productSubGroups = []
   showProductSubGroups = false
   @track appointmentTypes =[]
   showAppointmentTypes = false
   businessUnitId;
   productGroupId;
   productSubGroupId;
   appointmentTypeId;
   bandageIcon = bandageIcon;
   prostheticIcon = prostheticIcon;
   orthoticIcon = orthoticIcon;
   @track activeSection = "A"
   @track workType = {
    WorkTypeNameFR: null, 
    WorkTypeName: null,
    RecordId: null,
    EstimatedDuration: null,
    Bookable: null
    
   };
   

    connectedCallback(){
        this.getWorkTypology();
        this.showProductGroups = true;
        this.showProductSubGroups = true;
        this.showAppointmentTypes = true;
    }

    getWorkTypology() {
      getWorkTypologies()
        .then(result => {
          // If result is JSON string, parse it
          if (typeof result === 'string') {
            try {
              result = JSON.parse(result);
            } catch (e) {
              result = [];
            }
          }
  
          // Store full selector data
          if (Array.isArray(result)) {
            this.workTypes = result;
  
            this.businessUnits = result.map(item => item.businessUnit);
          } else if (result.workTypeSelector) {
            this.workTypes = Array.from(result.workTypeSelector);
            this.businessUnits = this.workTypes.map(item => item.businessUnit);
            console.log(this.businessUnits)
          } else {
            this.workTypes = [];
            this.businessUnits = [];
          }
        })
        .catch(error => {
          console.error('Error in getWorkTypology:', error);
        });
  }

    handleBUClick(event) {
      this.businessUnitId = event.currentTarget.dataset.id;
      const recordId = event.currentTarget.dataset.id
      const selected = this.workTypes.find(
        wt => wt.businessUnit?.recordId === recordId
      );
      
      if (selected) {
        this.productGroups = selected.productGroups || [];
        this.productSubGroups = [];
        this.appointmentTypeId = [];
        // this.setSectionVisibillity()
        
      } else {
        this.productGroups = [];
        console.warn('No matching business unit found for:', recordId);
      }
      this.productSubGroups = [];
      this.activeSection = "B"
  }

    handlePGClick(event) {
      this.productGroupId = event.currentTarget.dataset.id;
      const index = event.currentTarget.dataset.index;
      const selectedPG = this.productGroups?.[index];
      
      if (selectedPG?.productSubGroups?.length) {
        this.productSubGroups = selectedPG.productSubGroups;
        this.appointmentTypes = [];
        // this.setSectionVisibillity()
        
      } else {
        this.productSubGroups = [];
        console.warn('No subgroups found for this product group:', selectedPG);
      }
      this.activeSection = "C"
  }

  handlePSGClick(event) {
    this.productSubGroupId = event.currentTarget.dataset.id;
    const index = event.currentTarget.dataset.index;
    const selectedPSG = this.productSubGroups?.[index];
    
    if (selectedPSG?.appointmentTypes?.length) {
      selectedPSG.appointmentTypes.forEach(appt => {
        this.appointmentTypes = selectedPSG.appointmentTypes;
      });
      // this.setSectionVisibillity()
    } else {
      console.warn('No appointment types found for this sub group:', selectedPSG);
    }
    this.activeSection = "D"
}

  setSectionVisibillity(){
    if(this.productGroups.length > 0){
      this.showProductGroups = true
    }
    if(this.productSubGroups.length > 0){
      this.showProductSubGroups = true
    }
    if(this.appointmentTypes.length > 0){
      this.showAppointmentTypes = true
    }
  }


  @api handleATClick(event) {
    this.appointmentTypeId = event.currentTarget.dataset.id;
  
    getWorkType({
      BusinessUnitId: this.businessUnitId,
      ProductGroupId: this.productGroupId,
      ProductSubGroupId: this.productSubGroupId,
      AppointmentId: this.appointmentTypeId
    })
    .then(result => {
      if (typeof result === 'string') {
        try {
          result = JSON.parse(result);
        } catch (e) {
          result = {};
        }
      }
  
      this.workType = result;
      this.passToParent();
    })
    .catch(error => {
      console.error('Error in getWorkType:', error);
    });
  }

    handleSectionHeaderClick(event){
        this.activeSection = event.target.value
    }

    @api passToParent() {
      const worktypeInfo = new CustomEvent('worktypedetails', {
        detail: this.workType, // pass the object directly
        bubbles: true,
        composed: true
      });
      this.dispatchEvent(worktypeInfo);
    }
    
    
}