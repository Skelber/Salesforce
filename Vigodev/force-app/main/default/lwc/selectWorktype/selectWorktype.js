import { LightningElement, track, wire, api } from 'lwc';
import getWorkTypologies from '@salesforce/apex/WorktypeSelection.getJSON';
import getWorkType from '@salesforce/apex/WorktypeSelection.getWorkType';
import bandageIcon from "@salesforce/resourceUrl/bandage";
import prostheticIcon from "@salesforce/resourceUrl/prosthetic";
import orthoticIcon from "@salesforce/resourceUrl/orthotics";
import LANG from '@salesforce/i18n/lang';
import basePath from '@salesforce/community/basePath';
import AccordionHeaderOne from "@salesforce/label/c.pbzAccordionheaderOne"
import AccordionHeaderTwo from "@salesforce/label/c.pbzAccordionheaderTwo"
import AccordionHeaderThree from "@salesforce/label/c.pbzAccordionheaderThree"
import AccordionHeaderFour from "@salesforce/label/c.pbzAccordionheaderFour"
import ScreenTwoTitle from "@salesforce/label/c.pbzScreenTwoTitle"

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

   label = {
     AccordionHeaderOne,
     AccordionHeaderTwo,
     AccordionHeaderThree,
     AccordionHeaderFour,
     ScreenTwoTitle,
   }
   

    connectedCallback(){
        this.getWorkTypology();
        this.showProductGroups = true;
        this.showProductSubGroups = true;
        this.showAppointmentTypes = true;
        this.setLang();
        let baseUrl = window.location.origin;
        if (!this.businessUnitId) return;

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

        if (this.productGroups.length === 1) {
          const singlePG = this.productGroups[0];
          const pgId = singlePG.productGroup?.recordId;
      
          if (!pgId) {
              console.warn('Product Group recordId is missing!', singlePG);
              return;
          }
      
          const fakeClickEvent = {
              currentTarget: {
                  dataset: {
                      id: pgId,
                      index: 0
                  }
              }
          };
          setTimeout(() => {
          requestAnimationFrame(() => {
              requestAnimationFrame(() => {
                  // this.applyProductGroupStyling(pgId);
                  this.applySelectionStyling(pgId, 'pgSelection', 'Product Group');
              });
          });
        }, 400)
          setTimeout(() => {
              this.handlePGClick(fakeClickEvent);
      
          }, 800);
      }
        
      } else {
        this.productGroups = [];
      }
      this.productSubGroups = [];

      this.applySelectionStyling(recordId, 'buSelection', 'Business Unit');

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


        if (this.productSubGroups.length === 1) {
          const singlePSG = this.productSubGroups[0];
          const psgId = singlePSG.productSubGroup?.recordId;
      
          if (!psgId) {
              console.warn('Product Sub Group recordId is missing!', singlePSG);
              return;
          }
      
          const fakeClickEvent = {
              currentTarget: {
                  dataset: {
                      id: psgId,
                      index: 0
                  }
              }
          };
          setTimeout(() => {
          requestAnimationFrame(() => {
              requestAnimationFrame(() => {
                  // this.applyProductSubGroupStyling(psgId);
                  this.applySelectionStyling(psgId, 'psgSelection', 'Product Subgroup');
              });
          });
        }, 400)
          setTimeout(() => {
              this.handlePSGClick(fakeClickEvent);
      
          }, 800);
      }
        
      } else {
        this.productSubGroups = [];
      }

      // this.applyProductGroupStyling(this.productGroupId);
      this.applySelectionStyling(this.productGroupId, 'pgSelection', 'Product Group');


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
        return;
    }

    const recordId = target.dataset.id;
    this.appointmentTypeId = recordId;

    this.applySelectionStyling(recordId, 'atSelection', 'Appointment Type');

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


applySelectionStyling(recordId, cardClass, label = 'Record') {
  // Remove previous selection
  const allCards = this.template.querySelectorAll(`.${cardClass}`);
  allCards.forEach(card => card.classList.remove('selected'));

  // Find all wrappers that match the ID
  const allWrappers = this.template.querySelectorAll(`[data-id="${recordId}"]`);
  if (allWrappers.length === 0) {
    console.warn(`No ${label} wrapper found for ID:`, recordId);
  }

  // Add styling to the matching card
  for (const wrapper of allWrappers) {
    const targetCard = wrapper.querySelector(`.${cardClass}`);
    if (targetCard) {
      targetCard.classList.add('selected');
      console.log(`Applied styling to ${label}:`, recordId);
      break;
    }
  }
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