import { LightningElement, track, wire } from 'lwc';
import getWorkType from '@salesforce/apex/WorktypeSelection.getJSON';
import bandageIcon from "@salesforce/resourceUrl/bandage";
import prostheticIcon from "@salesforce/resourceUrl/prosthetic";
import orthoticIcon from "@salesforce/resourceUrl/orthotics";

export default class SelectWorktype extends LightningElement {

   workTypes = []
   businessUnits = [];
   @track  productGroups = [];
   showProductGroups = false
   @track productSubGroups = []

   @track appointmentTypes =[]

    connectedCallback(){
        this.getWorkTypes();
    }

    getWorkTypes() {
      getWorkType()
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
  
            // ✅ Extract and store business units
            this.businessUnits = result.map(item => item.businessUnit);
            console.log('Loaded business units:', this.businessUnits);
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
          console.error('Error in getWorkTypes:', error);
        });
  }

    handleBUClick(event) {
      this.activeSection = "B"
      const recordId = event.currentTarget.dataset.id;
      const selected = this.workTypes.find(
          wt => wt.businessUnit?.recordId === recordId
      );
  
      if (selected) {
          this.productGroups = selected.productGroups || [];
          console.log('Filtered productGroups:', this.productGroups);
          this.showProductGroups = true
      } else {
          this.productGroups = [];
          console.warn('No matching business unit found for:', recordId);
      }
      this.productSubGroups = [];
  }

    handlePGClick(event) {
      this.activeSection = "C"
      const index = event.currentTarget.dataset.index;
      const selectedPG = this.productGroups?.[index];
  
      if (selectedPG?.productSubGroups?.length) {
          this.productSubGroups = selectedPG.productSubGroups; // ✅ save for template
          console.log('Loaded Product SubGroups');
      } else {
          this.productSubGroups = [];
          console.warn('No subgroups found for this product group:', selectedPG);
      }
  }

  handlePSGClick(event) {
    this.activeSection = "D"
    const index = event.currentTarget.dataset.index;
    const selectedPSG = this.productSubGroups?.[index];

    if (selectedPSG?.appointmentTypes?.length) {
        console.log('Appointment Types for selected Product SubGroup:');
        selectedPSG.appointmentTypes.forEach(appt => {
            this.appointmentTypes = selectedPSG.appointmentTypes;
            console.log('appointment types = ' + JSON.stringify(this.appointmentTypes))
        });
    } else {
        console.warn('No appointment types found for this sub group:', selectedPSG);
    }
}

    bandageIcon = bandageIcon;
    prostheticIcon = prostheticIcon;
    orthoticIcon = orthoticIcon;
    @track activeSection = "A"

    handleBusinessUnitSelection(event) {
        this.activeSection = "B"
        const recordId = event.currentTarget.dataset.id;
        const selected = this.workTypes.find(
            wt => wt.businessUnit?.recordId === recordId
        );
    
        if (selected) {
            this.productGroups = selected.productGroups || [];
            console.log('Filtered productGroups:', this.productGroups);
            this.showProductGroups = true
        } else {
            this.productGroups = [];
            console.warn('No matching business unit found for:', recordId);
        }
        this.productSubGroups = [];
    }
    handleProductGroupSelection(event){
        this.activeSection = "C"
        const index = event.currentTarget.dataset.index;
        const selectedPG = this.productGroups?.[index];
    
        if (selectedPG?.productSubGroups?.length) {
            this.productSubGroups = selectedPG.productSubGroups;
        } else {
            this.productSubGroups = [];
            console.warn('No subgroups found for this product group:', selectedPG);
        }
    }
    handleProductSubGroupSelection(event) {
      this.activeSection = "D";
      const index = event.currentTarget.dataset.index;
      const selectedPSG = this.productSubGroups?.[index];
  
      if (selectedPSG?.appointmentTypes?.length) {
          console.log('Appointment Types for selected Product SubGroup:');
          selectedPSG.appointmentTypes.forEach(appt => {
              this.appointmentTypes = selectedPSG.appointmentTypes;
              console.log('appointment types = ' + JSON.stringify(this.appointmentTypes))
          });
      } else {
          console.warn('No appointment types found for this sub group:', selectedPSG);
      }
  }

    handleSectionHeaderClick(event){
        this.activeSection = event.target.value
    }
    
}