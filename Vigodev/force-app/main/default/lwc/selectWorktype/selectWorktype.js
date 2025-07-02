import { LightningElement, track, wire, api } from 'lwc';
import getWorkTypologies from '@salesforce/apex/WorktypeSelection.getJSON';
import getWorkType from '@salesforce/apex/WorktypeSelection.getWorkType';
import bandageIcon from "@salesforce/resourceUrl/bandage";
import prostheticIcon from "@salesforce/resourceUrl/prosthetic";
import orthoticIcon from "@salesforce/resourceUrl/orthotics";
import LANG from '@salesforce/i18n/lang';
import basePath from '@salesforce/community/basePath';

export default class SelectWorktype extends LightningElement {

  LANG = LANG
  baseUrl = window.location.origin;
  basePath = basePath;
   workTypes = []
   businessUnits = [];
   @track  productGroups = [];
   showProductGroups = false
   @track productSubGroups = []
   showProductSubGroups = false
   @track appointmentTypes =[]
   showAppointmentTypes = false
   @api businessUnitId;
   @api productGroupId;
   @api productSubGroupId;
   @api appointmentTypeId;
   displayDutch = false;
   displayEnglish = false;
   displayFrench = false;
   bandageIcon = bandageIcon;
   prostheticIcon = prostheticIcon;
   orthoticIcon = orthoticIcon;
   @track activeSection = "A"
   @track workType = {
    WorkTypeNameFR: null, 
    WorkTypeName: null,
    RecordId: null,
    EstimatedDuration: null,
    Bookable: null,
    buImage: null,
    
   };
   

    connectedCallback(){
        this.getWorkTypology();
        this.showProductGroups = true;
        this.showProductSubGroups = true;
        this.showAppointmentTypes = true;
        this.setLang();
        // this.updateWrapClass();
        // window.addEventListener('resize', this.updateWrapClass.bind(this));
        let baseUrl = window.location.origin;

        console.log('base url =' + this.baseUrl + this.basePath + '/sfsites/c/resource/');
        // this.template.querySelector('.worktypeSelection'))

      
        if (!this.businessUnitId) return;

    // Prevent repeated work if already applied
    if (this.lastStyledBUId === this.businessUnitId) return;

    window.requestAnimationFrame(() => {
      const wrapper = this.template.querySelector(`[data-id="${this.businessUnitId}"]`);
      if (wrapper) {
        const innerDiv = wrapper.querySelector('.buSelection');
        if (innerDiv) {
          // Clear previous selections
          const all = this.template.querySelectorAll('.buSelection.selected');
          all.forEach(el => el.classList.remove('selected'));

          innerDiv.classList.add('selected');
          this.lastStyledBUId = this.businessUnitId;
        } else {
          console.warn('Could not find .buSelection inside wrapper for BU ID:', this.businessUnitId);
        }
      } else {
        console.warn('No wrapper found for BU ID:', this.businessUnitId);
      }
    });
        
    }

    styleSelectedRecords() {
      window.requestAnimationFrame(() => {
        // ----- BUSINESS UNIT -----
        if (this.businessUnitId) {
          this.template.querySelectorAll('.buSelection.selected')
            .forEach(el => el.classList.remove('selected'));
    
          const buWrapper = this.template.querySelector(`[data-id="${this.businessUnitId}"]`);
          if (buWrapper) {
            const innerDiv = buWrapper.querySelector('.buSelection');
            if (innerDiv) {
              innerDiv.classList.add('selected');
            }
          }
        }
    
        // ----- PRODUCT GROUP -----
        if (this.productGroupId) {
          this.template.querySelectorAll('.pgSelection.selected')
            .forEach(el => el.classList.remove('selected'));
    
          const pgWrapper = this.template.querySelector(`[data-id="${this.productGroupId}"]`);
          if (pgWrapper) {
            const innerDiv = pgWrapper.querySelector('.pgSelection');
            if (innerDiv) {
              innerDiv.classList.add('selected');
            }
          }
        }
    
        // ----- PRODUCT SUBGROUP -----
        if (this.productSubGroupId) {
          this.template.querySelectorAll('.psgSelection.selected')
            .forEach(el => el.classList.remove('selected'));
    
          const psgWrapper = this.template.querySelector(`[data-id="${this.productSubGroupId}"]`);
          if (psgWrapper) {
            const innerDiv = psgWrapper.querySelector('.psgSelection');
            if (innerDiv) {
              innerDiv.classList.add('selected');
            }
          }
        }
    
        // ----- APPOINTMENT TYPE -----
        if (this.appointmentTypeId) {
          this.template.querySelectorAll('.atSelection.selected')
            .forEach(el => el.classList.remove('selected'));
    
          const atWrapper = this.template.querySelector(`[data-id="${this.appointmentTypeId}"]`);
          if (atWrapper) {
            const innerDiv = atWrapper.querySelector('.atSelection');
            if (innerDiv) {
              innerDiv.classList.add('selected');
            }
          }
        }
      });
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
    getWorkTypology() {
      getWorkTypologies()
        .then(result => {
          if (typeof result === 'string') {
            try {
              result = JSON.parse(result);
            } catch (e) {
              result = [];
            }
          }
    
          if (Array.isArray(result)) {
            this.workTypes = result;
            this.businessUnits = result.map(item => {
              const bu = { ...item.businessUnit };
    
              if (bu?.Image_Dev_Name) {
                bu.Image_Link = `${this.baseUrl}${this.basePath}/sfsites/c/resource/${bu.Image_Dev_Name}`;
                console.log(bu.Image_Link)
              }
    
              return bu;
            });
    
          } else if (result.workTypeSelector) {
            this.workTypes = Array.from(result.workTypeSelector);
            this.businessUnits = this.workTypes.map(item => {
              const bu = { ...item.businessUnit };
    
              if (bu?.Image_Dev_Name) {
                bu.Image_Link = `${this.baseUrl}${this.basePath}/sfsites/c/resource/${bu.Image_Dev_Name}`;
                console.log(bu.Image_Link)
              }
    
              return bu;
            });
    
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
      console.log('selected BU: ' + JSON.stringify(selected))
      if (selected) {
        this.productGroups = selected.productGroups || [];
        this.productGroups = (selected.productGroups || []).map(pg => {
          const pgCopy = { ...pg };
        
          if (pgCopy.Image_Dev_Name) {
            pgCopy.Image_Link = `${this.baseUrl}${this.basePath}/sfsites/c/resource/${pgCopy.Image_Dev_Name}`;
            pgCopy.Has_Image_Link = true;
          } else {
            pgCopy.Has_Image_Link = false;
          }
        
          return pgCopy;
        });
        this.productSubGroups = [];
        this.appointmentTypeId = [];
        // this.setSectionVisibillity()
        
      } else {
        this.productGroups = [];
        console.warn('No matching business unit found for:', recordId);
      }
      this.productSubGroups = [];

      const previouslySelected = this.template.querySelector('.buSelection.selected');
       if (previouslySelected) {
           previouslySelected.classList.remove('selected');
       }
   
       const wrapper = this.template.querySelector(`[data-id="${recordId}"]`);
       if (wrapper) {
           const innerDiv = wrapper.querySelector('.buSelection');
           if (innerDiv) {
               innerDiv.classList.add('selected');
           }
       }

       setTimeout(() => {
        this.activeSection = "B"
        this.styleSelectedRecords()
        requestAnimationFrame(() => {
          const anchor = this.template.querySelector('[data-scroll-anchor="section-b"]');
          if (anchor) {
            anchor.scrollIntoView({ behavior: 'smooth', block: 'start' });
          }
        });
      }, 300)
    }

    handlePGClick(event) {
      this.productGroupId = event.currentTarget.dataset.id;
      const index = event.currentTarget.dataset.index;
      const selectedPG = this.productGroups?.[index];
      console.log('selected product group ' + JSON.stringify(selectedPG))
      
      if (selectedPG?.productSubGroups?.length) {
        this.productSubGroups = selectedPG.productSubGroups;
        this.productSubGroups = (selectedPG.productSubGroups || []).map(psg => {
          const psgCopy = { ...psg };
        
          if (psgCopy.Image_Dev_Name) {
            psgCopy.Image_Link = `${this.baseUrl}${this.basePath}/sfsites/c/resource/${psgCopy.Image_Dev_Name}`;
            psgCopy.Has_Image_Link = true;
          } else {
            psgCopy.Has_Image_Link = false;
          }
        
          return psgCopy;
        });
       
        this.appointmentTypes = [];
        
      } else {
        this.productSubGroups = [];
        console.warn('No subgroups found for this product group:', selectedPG);
      }

      const previouslySelected = this.template.querySelector('.pgSelection.selected');
       if (previouslySelected) {
           previouslySelected.classList.remove('selected');
       }
   
       const wrapper = this.template.querySelector(`[data-id="${this.productGroupId}"]`);
       if (wrapper) {
           const innerDiv = wrapper.querySelector('.pgSelection');
           if (innerDiv) {
               innerDiv.classList.add('selected');
           }
       }

      setTimeout(() => {
        this.activeSection = "C"
        this.styleSelectedRecords();
        requestAnimationFrame(() => {
          const anchor = this.template.querySelector('[data-scroll-anchor="section-c"]');
          if (anchor) {
              anchor.scrollIntoView({ behavior: 'smooth', block: 'start' });
          }
      });
    }, 300)
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

    const previouslySelected = this.template.querySelector('.psgSelection.selected');
       if (previouslySelected) {
           previouslySelected.classList.remove('selected');
       }
   
       const wrapper = this.template.querySelector(`[data-id="${this.productSubGroupId}"]`);
       if (wrapper) {
           const innerDiv = wrapper.querySelector('.psgSelection');
           if (innerDiv) {
               innerDiv.classList.add('selected');
           }
       }
    setTimeout(() => {
      this.activeSection = "D"
      this.styleSelectedRecords();
      requestAnimationFrame(() => {
        const anchor = this.template.querySelector('[data-scroll-anchor="section-d"]');
        if (anchor) {
          console.log('anchor found')
            anchor.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
      });
  }, 300)
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


handleATClick = (event) => {
    const target = event.currentTarget.closest('[data-id]');
    if (!target) {
        console.warn('No data-id found on click target');
        return;
    }

    const recordId = target.dataset.id;
    this.appointmentTypeId = recordId;

    const previouslySelected = this.template.querySelector('.atSelection.selected');
       if (previouslySelected) {
           previouslySelected.classList.remove('selected');
       }
   
       const wrapper = this.template.querySelector(`[data-id="${recordId}"]`);
       if (wrapper) {
           const innerDiv = wrapper.querySelector('.atSelection');
           if (innerDiv) {
               innerDiv.classList.add('selected');
           }
       }

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
        detail: {
          workType: this.workType,
          businessUnitId: this.businessUnitId,
          productGroupId: this.productGroupId,
          productSubGroupId: this.productSubGroupId,
          appointmentTypeId: this.appointmentTypeId
        },
        bubbles: true,
        composed: true
      });
      this.dispatchEvent(worktypeInfo);
    }
    
}