import { LightningElement , api, track, wire } from 'lwc';
import INVITATION_HEADER from '@salesforce/resourceUrl/Campaign_Invitation_Header';
import getCampaign from '@salesforce/apex/CampaignInvitationFormController.getCampaign'
import getCampaignMember from '@salesforce/apex/CampaignInvitationFormController.getCampaignMember'
import getTimeSlot from '@salesforce/apex/CampaignInvitationFormController.getTimeSlot'
import saveResponse from '@salesforce/apex/CampaignInvitationFormController.saveResponse'

export default class CampaignInvitationForm extends LightningElement {
    invitationHeader = INVITATION_HEADER;
    @api campId;
    @api conId;
    @api language;
    @track campaignMember; campaign; campaignStartDate;
    @track isDateTimeAvail = false;
    isActive; isPositive;
    isError; campaignNotFound;
    isLoaded; isCompleted = false;
    isErrorMessage = false; errorMessage = '';


    LinkBrokenMessageEN = 'It seems that this link is wrong.'; // Please contact lies.verboven@momu.be';
    LinkBrokenMessageNL = 'Het lijkt erop dat deze link foutief is.'; // Neem contact op lies.verboven@momu.be';
    RSVPMessageEN = 'Registrations for this event are closed.'; //Contact lies.verboven@momu.be.';
    RSVPMessageNL = 'Aanmeldingen voor dit evenement zijn afgesloten.'; // Contacteer lies.verboven@momu.be.';

    timeSlotLst; timeSlotOption = [];

    get optionsNL(){
        return [
            {value: '' , label : ''},
            {value: 'yes' , label : 'Aanwezig'},
            {value: 'no' , label : 'Niet aanwezig'},
        ];
    }

    get optionsEN(){
        return [
            {value: '' , label : ''},
            {value: 'yes' , label : 'Present'},
            {value: 'no' , label : 'Not present'},
        ];
    }

    onOptionChange(event){
        this.campaignMember.registered = event.target.value;
    }

    onTimeSlotChange(event){
        this.campaignMember.timeSlotId = event.target.value;
    }

    onTogleChange(event){
        this.campaignMember.mySelf = event.target.checked;
    }
    
    _campaignResult;
    @wire (getCampaign, { campId : '$campId'})
    wiredCampaign(result){
        this._campaignResult = result;
        const {data , error } = result;
        if(data){
            this.campaign = data;
            if(data.hasOwnProperty('Start_Date_Time__c') && data.Start_Date_Time__c!=undefined && data.Start_Date_Time__c!=null){
                let myDate = new Date(data.Start_Date_Time__c);
                let dayNameString = this.getDayName(myDate.getDay(),this.language);
                let monthNameString = this.getMonthName(myDate.getMonth(),this.language);
                let hourString = String(myDate.getHours()).padStart(2, "0")+':' +  String(myDate.getMinutes()).padStart(2, "0");
                let eventDateString = dayNameString + ' ' + myDate.getDate() + ' ' + monthNameString + ' ' + myDate.getFullYear() + ' , ' + hourString;
                this.campaignStartDate = eventDateString;
            }else{
                this.campaignStartDate = '';
            }

            this.LinkBrokenMessageEN = (data.Incorrect_Link_EN__c!=undefined && data.Incorrect_Link_EN__c!=null) ? data.Incorrect_Link_EN__c : this.LinkBrokenMessageEN;
            this.LinkBrokenMessageNL = (data.Incorrect_Link_NL__c!=undefined && data.Incorrect_Link_NL__c!=null) ? data.Incorrect_Link_NL__c : this.LinkBrokenMessageNL;
            this.RSVPMessageEN = (data.RSVP_Closed_EN__c!=undefined && data.RSVP_Closed_EN__c!=null) ? data.RSVP_Closed_EN__c : this.RSVPMessageEN;
            this.RSVPMessageNL = (data.RSVP_Closed_NL__c!=undefined && data.RSVP_Closed_NL__c!=null) ? data.RSVP_Closed_NL__c : this.RSVPMessageNL;
        
        }else if(error){
            this.isError = true;
            this.campaignNotFound = true;
        }
    }

    _campaignMemberResult;
    @wire (getCampaignMember, { campId : '$campId' , conId : '$conId'})
    wiredCampaignMember(result){
        this._campaignMemberResult = result;
        const {data , error } = result;
        if(data){
            if(data.isSuccess){
                this.isActive = data.isActive;
                this.campaignMember = JSON.parse(JSON.stringify(data.response));
                if(this.campaignMember.showAvailabilityPicklist){
                    this.getTimeSlotHandler();
                }else{
                    this.isLoaded = true;
                }
            }else{
                this.isError = true;
                this.isLoaded = true;
            }
        }else if(error){
            this.isError = true;
            this.isLoaded = true;
        }
    }

    getTimeSlotHandler(){
        getTimeSlot({campId : this.campId})
        .then(result =>{
            this.timeSlotLst = result;
            this.timeSlotOption = [{value : '', label : ''}];
            var self = this;
            result.forEach(function(timeSlot){
                let label = new Date(timeSlot.Time__c).toISOString().slice(11, 16);
                if(self.campaignMember.showAvailabilityInPicklist){
                    label += ' (' + (self.language=='en' ? 'available '  : 'beschikbaar ') + timeSlot.Remaining__c+')';
                }
                self.timeSlotOption.push({ value : timeSlot.Id, label :  label});
            });
            this.isLoaded = true;
        });
    }

    /*
    @wire(getTimeSlot, {campId : '$campId'})
    wiredgetTimeSlot(result){
        const {data , error } = result;
        if(data){
            this.timeSlotLst = data;
            this.timeSlotOption = [{value : '', label : ''}];
            var self = this;
            data.forEach(function(timeSlot){
                self.timeSlotOption.push({ value : timeSlot.Id, label :  new Date(timeSlot.Time__c).toISOString().slice(11, 16) + ' (' + (self.language=='en' ? 'available '  : 'beschikbaar ') + timeSlot.Remaining__c+')'}); //timeSlot.Time__c
            });
        }
    }
    */

    onSave(){
        this.isErrorMessage = false;
        this.errorMessage = '';

        const allValid = [
            ...this.template.querySelectorAll('lightning-input')
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        
        if(allValid){
            saveResponse({ response : JSON.parse(JSON.stringify(this.campaignMember)) })
            .then(result => {
                if(result.isSuccess){
                    this.isCompleted = true;
                    this.isErrorMessage = false; this.errorMessage = '';
                }else{
                    //this.isCompleted = false;
                    this.isErrorMessage = true;
                    if(result.message){
                        this.errorMessage = result.message;
                    }else if(result.person){
                        this.errorMessage = this.language == 'en' ? 
                                            'Sorry, this time slot is only available for ' + result.person + ' person.' 
                                            : 'Sorry, er is nog maar ' + result.person + ' plaats(en) vrij.';
                    }
                }
            })
            .catch(error => {
                this.isErrorMessage = false;
                this.errorMessage = 'Something went wrong!';
                console.log('error : ' + error);
            });
        }
    }

    onAdditionalPersonChange(event){
        this.campaignMember.otherPerson[event.target.dataset.index]['Name'] = event.target.value;
    }

    get isKUL(){
        if(this.campaign && this.campaign.Type_Invitation__c && this.campaign.Type_Invitation__c=='Onderzoek KUL'){
            return true;
        }else{
            return false;
        }
    }

    get valueMissing(){
        return this.language=='en' ? 'Complete this field.' : 'Dit veld is verplicht.';
    }
    
    get campTitle(){
        if(this.campaign){
            return this.language=='en' ? this.campaign.Title_EN__c : this.campaign.Title_NL__c;
        }else{
            return '';
        }
    }

    get options(){
        return this.language=='en' ? this.optionsEN : this.optionsNL;
    }

    get isRegister(){
        return this.campaignMember.registered =='yes';
    }

    get LinkBrokenMessage(){
        return this.language=='en' ? this.LinkBrokenMessageEN : this.LinkBrokenMessageNL;
    }

    get campSubsciption(){
        if(this.campaign) return this.language=='en' ? this.campaign.Text_Subscription_EN__c : this.campaign.Text_Subscription_NL__c;
        return '';
    }

    get toggelLabel(){
        return this.language=='en' ? 'I will attend by myself' : 'Ik kom alleen';
    }

    get otherLabel(){
        //return this.language=='en' ? 'I come with' : 'Ik kom met';
        return this.language=='en' ? 'I will be in attendance with' : 'Ik kom in het gezelschap van';
    }

    get NameLabel(){
        return this.language=='en' ? 'Firstname and lastname' : 'Voornaam en achternaam';
    }

    get TimeSlotLabel(){
        if(this.language=='en' && this.campaign && this.campaign.Timeslot_Label_EN__c){
            return this.campaign.Timeslot_Label_EN__c;
        }else if(this.campaign && this.campaign.Timeslot_Label_NL__c){
            return this.campaign.Timeslot_Label_NL__c;
        }else{
            return 'Timeslot';
        }
    }

    get submitButtonlabel(){
        return this.language=='en' ? 'Submit' : 'Bevestigen';
    }

    get RSVPMessage(){
        return this.language=='en' ? this.RSVPMessageEN : this.RSVPMessageNL;
    }

    get confirmationMessage(){
        return this.language=='en' ? this.campaign.Confirmation_EN__c : this.campaign.Confirmation_NL__c;
    }

    get defaultConfirmationMessage(){
        return this.language=='en' ? 'Thank you for your response.' : 'Bedankt voor je reactie.'
    }

    get messageActive(){
        return this.language=='en' ? 'Yes' : 'Ja';
    }

    get messageInActive(){
        return this.language=='en' ? 'No' : 'Nee';
    }
    
    getDayName( day, lan){
        let dayName;
        switch (day){
            case 0:
                dayName = (lan=='nl')?"Zondag":"Sunday";
                break;
            case 1:
                dayName = (lan=='nl')?"Maandag":"Monday";
                break;
            case 2:
                dayName = (lan=='nl')?"Dinsdag":"Tuesday";
                break;
            case 3:
                dayName = (lan=='nl')?"Woensdag":"Wednesday";
                break;
            case 4:
                dayName = (lan=='nl')?"Donderdag":"Thursday";
                break;
            case 5:
                dayName = (lan=='nl')?"Vrijdag":"Friday";
                break;
            case  6:
                dayName = (lan=='nl')?"Zaterdag":"Saturday";
        }
        return dayName;
    }
    
    getMonthName( month, lan ){
        let MonthName;
        switch (month){
            case 0:
                MonthName = (lan=='nl')?"januari":"January";
                break;
            case 1:
                MonthName = (lan=='nl')?"februari":"February";
                break;
            case 2:
                MonthName = (lan=='nl')?"maart":"March";
                break;
            case 3:
                MonthName = (lan=='nl')?"april":"April";
                break;
            case 4:
                MonthName = (lan=='nl')?"mei":"May";
                break;
            case 5:
                MonthName = (lan=='nl')?"juni":"June";
                break;
            case 6:
                MonthName = (lan=='nl')?"juli":"July";
                break;
            case 7:
                MonthName = (lan=='nl')?"augustus":"August";
                break;
            case 8:
                MonthName = (lan=='nl')?"september":"September";
                break;
            case 9:
                MonthName = (lan=='nl')?"oktober":"October";
                break;
            case 10:
                MonthName = (lan=='nl')?"november":"November";
                break;
            case 11:
                MonthName = (lan=='nl')?"december":"December";
                break;
        }
        return MonthName;
    }
}