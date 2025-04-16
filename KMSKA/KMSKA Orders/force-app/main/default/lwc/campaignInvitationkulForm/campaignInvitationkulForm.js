import { LightningElement , api, track, wire } from 'lwc';
import INVITATION_HEADER from '@salesforce/resourceUrl/KUL_onderzoek_header';
import KMSKA_LOGO_HEADER from '@salesforce/resourceUrl/KMSKA_BOLD';

import getData from '@salesforce/apex/CampaignInvitationkulFormController.getData'
import getAllPicklistMap from '@salesforce/apex/CampaignInvitationkulFormController.getAllPicklistMap'
import saveResponse from '@salesforce/apex/CampaignInvitationkulFormController.saveResponse'

export default class CampaignInvitationkulForm extends LightningElement {
    invitationHeader = INVITATION_HEADER;
    kmskaLogo = KMSKA_LOGO_HEADER;
    @api contactId;
    isSpinner = false;
    isLoaded = false;
    genderOption = []; highestDegreeOption = []; currentSituationOption = [];
    visitMuseaOption = []; interestOption = []; reasonVisitOption = [];
    studyAreaOption = []; workSectorOption = []; reasonNoVisitOption = [];
    contextVisitOption = [];

    isError = false; 
    saveError = false;
    errorMessage = '';

    isSuccess = false;
    successMessage = 'Bedankt voor je interesse! Wij nemen zo snel mogelijk contact met je op.';


    @track formInfo = {};
    @track contactInfo = {};

    @wire (getData, {contId : '$contactId' })
    wiredgetData(result){
        this.isSpinner = true;
        const {data , error } = result;
        if(data){
            if(data.isSuccess){
                this.formInfo = JSON.parse(JSON.stringify(data.formInfo));
                this.contactInfo = JSON.parse(JSON.stringify(data.contact));
                this.getPicklistList();
            }else if(!data.isSuccess){
                this.isSpinner = false;
                this.isLoaded = true;
                this.isError = true;
                this.errorMessage = data.message;
            }
        }
        if(error){
            this.isLoaded = true;
            this.isSpinner = false;
            this.isError = true;
            this.errorMessage = 'Sorry er heeft zich een fout voorgedaan, gelieve hello@ksmka.be te contacteren.';
        }
    }

    getPicklistList(){
        getAllPicklistMap()
        .then((result) => {
            this.genderOption = this.getFieldOptions(result.getGender , true);
            this.highestDegreeOption = this.getFieldOptions(result.getHighestDegree , true); 
            this.currentSituationOption = this.getFieldOptions(result.getCurrentSituation , true);
            this.visitMuseaOption = this.getFieldOptions(result.getVisitMusea , true); 
            this.interestOption = this.getFieldOptions(result.getInterest , false);
            this.reasonVisitOption = this.getFieldOptions(result.getReasonVisits , false);
            this.reasonNoVisitOption = this.getFieldOptions(result.getReasonNoVisit, false);
            this.contextVisitOption = this.getFieldOptions(result.getContextVisit, false);

            //this.studyAreaOption = this.getFieldOptions(result.getStudyArea , false);
            //this.workSectorOption = this.getFieldOptions(result.getWorkSector , false);
            
            this.isLoaded = true;
            this.isSpinner = false;
        })
        .catch((error) =>{
            console.log(error);
            this.isLoaded = true;
            this.isSpinner = false;
            this.isError = true;
            this.errorMessage = 'Sorry er heeft zich een fout voorgedaan, gelieve hello@ksmka.be te contacteren.';
        });
    }

    getFieldOptions(data,isBlankToAdd){
        let options = [];
        if(isBlankToAdd){
            options.push({ label: '- gelieve keuze te maken -', value : ''});
        }
        for(let key in data){
            options.push({ label : data[key], value : key});
        }
        return options;
    }

    onFormChange(event){
        this.formInfo[event.currentTarget.name] = event.detail.value;
    }

    onContactChange(event){
        this.contactInfo[event.currentTarget.name] = event.detail.value;
    }

    get isOther(){
        return (this.formInfo && this.formInfo.currentSituation && this.formInfo.currentSituation=='Andere') ? true : false;
    }

    get isVisitNiet(){
        return (this.formInfo && this.formInfo.visitMusea && this.formInfo.visitMusea=='Niet') ? true : false;
    }

    get isVisit(){
        return (this.formInfo && this.formInfo.visitMusea && (this.formInfo.visitMusea=='1 tot 2 keer' || this.formInfo.visitMusea=='3 of meerdere keren')) ? true : false;
    }

    get IsReasonNoVisitOther(){
        return (this.formInfo && this.formInfo.reasonNoVisit && (this.formInfo.reasonNoVisit.includes('Andere') || this.formInfo.reasonNoVisit.includes('andere'))) ? true : false;
    }

    get IsContextVisitOther(){
        return (this.formInfo && this.formInfo.contextVisit && this.formInfo.contextVisit.includes('Andere')) ? true : false;
    }

    submitForm(){
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
            ...this.template.querySelectorAll('lightning-combobox'),
            ...this.template.querySelectorAll('lightning-checkbox-group'),
            ...this.template.querySelectorAll('lightning-radio-group')
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allValid) {
            this.isSpinner = true;
            saveResponse({ 
                conInfo : JSON.parse(JSON.stringify(this.contactInfo)),
                 formInfo : JSON.parse(JSON.stringify(this.formInfo)) 
                })
            .then((result) =>{
                if(result.isSuccess){
                    this.isSuccess = true;
                }else{
                    this.saveError = true;
                    this.errorMessage = result.message;
                }
                this.isSpinner = false;
            })
            .catch((error) => {
                console.log(error);
                this.saveError = true;
                this.errorMessage = result.message;
                this.isSpinner = false;
            })
        }

        /*
        var checkboxGroup = this.template.querySelector(
            'lightning-checkbox-group'
        );
        if (checkboxGroup.checkValidity()) {
            this.message = "That's a great selection!";
        } else {
            // Shows the error immediately without user interaction
            checkboxGroup.reportValidity();
            this.message = 'Select your favorite color and try again.';
        }
        */
    }


    /*
    get isStudent(){
        return (this.formInfo && this.formInfo.currentSituation && this.formInfo.currentSituation=='Student') ? true : false;
    }

    get isWerkend(){
        return (this.formInfo && this.formInfo.currentSituation && this.formInfo.currentSituation=='Werkend') ? true : false;
    }

    get isWerkzoekend(){
        return (this.formInfo && this.formInfo.currentSituation && this.formInfo.currentSituation=='Werkzoekend') ? true : false;
    }

    get isGepensioneerd(){
        return (this.formInfo && this.formInfo.currentSituation && this.formInfo.currentSituation=='Gepensioneerd') ? true : false;
    }

    get IsStudyAreaOther(){
        return (this.formInfo && this.formInfo.studyArea && this.formInfo.studyArea.includes('Andere')) ? true : false;
    }

    get IsWorkSectorOther(){
        return (this.formInfo && this.formInfo.workSector && this.formInfo.workSector.includes('Andere')) ? true : false;
    }
    */
}