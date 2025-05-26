import { LightningElement, track, wire } from 'lwc';
import getWorkType from '@salesforce/apex/WorktypeSelection.getJSON';
import bandageIcon from "@salesforce/resourceUrl/bandage";
import prostheticIcon from "@salesforce/resourceUrl/prosthetic";
import orthoticIcon from "@salesforce/resourceUrl/orthotics";

export default class SelectWorktype extends LightningElement {

   workTypes = []
   productGroups = [];

    connectedCallback(){
        // console.log('Worktypes ' + JSON.stringify(this.workTypes))
        this.getWorkTypes();
    }

    getWorkTypes() {
        getWorkType()
          .then(result => {
            // 1) If it’s a JSON string, parse it
            if (typeof result === 'string') {
              try {
                result = JSON.parse(result);
              } catch (e) {
                result = {}; 
              }
            }
    
            if (result.workTypeSelector) {
              this.workTypes = Array.from(result.workTypeSelector);
            }
            else if (Array.isArray(result)) {
              this.workTypes = Array.from(result);
            }
            
          })
          .catch(error => {
            console.error('Error in getWorkTypes:', error);
          });

          let i = 0;
          this.workTypes.forEach((businessUnit) =>
            console.log('bu' + businessUnit))

    }

    handleBUClick(event){
        console.log('clicked ' + JSON.stringify(event.target.value))
    }

    bandageIcon = bandageIcon;
    prostheticIcon = prostheticIcon;
    orthoticIcon = orthoticIcon;
    @track activeSection = "A"

    handleBusinessUnitSelection() {
        this.activeSection = "B"
    }
    handleProductGroupSelection(){
        this.activeSection = "C"
    }
    handleProductSubGroupSelection(){
        this.activeSection = "D"
    }

    handleSectionHeaderClick(event){
        this.activeSection = event.target.value
    }
    
}