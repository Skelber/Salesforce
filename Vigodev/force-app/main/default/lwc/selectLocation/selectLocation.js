import { LightningElement, api ,track } from 'lwc';
import loationIcon from "@salesforce/resourceUrl/locationIcon";
import getLocation from '@salesforce/apex/WorktypeSelection.getLocations';
import ScreenThreeTitle from "@salesforce/label/c.pbzScreenThreeTitle"


export default class SelectLocation extends LightningElement {

   locationIconURL = loationIcon;
   @api worktype = {}
   @track locations = [];
   locationId;
   @api selectedLocation = {}

   label = {
    ScreenThreeTitle,
   }


   connectedCallback() {
      getLocation({ WorkTypeId: this.worktype.RecordId })
          .then(result => {
            if (typeof result === 'string') {
               try {
                 result = JSON.parse(result);
               } catch (e) {
                 result = [];
               }
             }

             if (Array.isArray(result)) {
               this.locations = result;
               window.requestAnimationFrame(() => {
                this.restoreSelectedStyling();
            });
             }
          })
          .catch(error => {
          });
   }

   restoreSelectedStyling() {
    if (this.selectedLocation?.recordId) {
        const wrapper = this.template.querySelector(`[data-id="${this.selectedLocation.recordId}"]`);
        if (wrapper) {
            const innerDiv = wrapper.querySelector('.locationSelection');
            if (innerDiv) {
                innerDiv.classList.add('selected');
                this.selectedLocationRestored = true;
            } 
        } 
    } 
}

   handleLocationClick(event) {
      this.locationId = event.currentTarget.dataset.id;
      const selectedLocation = this.locations.find(
         location => location.recordId === this.locationId
      );
      this.selectedLocation = selectedLocation
      this.passToParent();

      const previouslySelected = this.template.querySelector('.locationSelection.selected');
       if (previouslySelected) {
           previouslySelected.classList.remove('selected');
       }
   
       const wrapper = this.template.querySelector(`[data-id="${this.locationId}"]`);
       if (wrapper) {
           const innerDiv = wrapper.querySelector('.locationSelection');
           if (innerDiv) {
               innerDiv.classList.add('selected');
           }
       }
   }

   @api passToParent() {
      const locationInfo = new CustomEvent('locationdetails', {
        detail: this.selectedLocation,
        bubbles: true,
        composed: true
      });
      this.dispatchEvent(locationInfo);
    }
}