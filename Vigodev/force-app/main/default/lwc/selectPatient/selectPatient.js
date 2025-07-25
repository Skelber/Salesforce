import { LightningElement, track, api } from 'lwc';
import LANG from '@salesforce/i18n/lang';
import FirstName from "@salesforce/label/c.pbzInputFirstName"
import LastName from "@salesforce/label/c.pbzInputLastName"
import FirstNamePatient from "@salesforce/label/c.pbzInputFirstNamePatient"
import LastNamePatient from "@salesforce/label/c.pbzInputLastNamePatient"
import BookedForSomeoneElse from "@salesforce/label/c.pbzBookAppointmentForSomeoneElse"
import RSZ from "@salesforce/label/c.pbzInputNationalRegisterNumber"
import NoRSZ from "@salesforce/label/c.pbzDoesNotHaveANationalRegistrationNumber"
import RelationToUser from "@salesforce/label/c.pbzInputRelationToUser"
import YourPhone from "@salesforce/label/c.pbzInputYourPhone"
import YourEmail from "@salesforce/label/c.pbzInputYourEmail"
import Phone from "@salesforce/label/c.pbzInputPhone"
import Address from "@salesforce/label/c.pbzAddress"
import City from "@salesforce/label/c.pbzInputCity"
import Street from "@salesforce/label/c.pbzInputStreet"
import Province from "@salesforce/label/c.pbzInputProvince"
import PostalCode from "@salesforce/label/c.pbzInputPostalCode"
import Country from "@salesforce/label/c.pbzInputCountry"
import PatientEmail from "@salesforce/label/c.pbzInputEmailPatient"
import RSZHelpText from "@salesforce/label/c.pbzHelpTextNationalRegisterNumber"

export default class SelectPatient extends LightningElement {
    @track checked;
    @track hasNoRSZ = false;
    @ track contact = {
        firstName: null,
        lastName: null,
        email: null,
        phone: null,
        RSZ: null,
        hasNoRSZ: false,
        street: null,
        city: null,
        country: null,
        province: null,
        postalCode: null,
        address: null,
        birthdate: null,
        bookedForSelf: null,
        bookedForFirstName : null,
        bookedForLastName: null,
        bookedForEmail:null,
        bookedForPhone:null,
        relationToPatient: null,
    }
    rszRequired = false
    contactInfoComplete = false
    birthyearPrefix = "19"
    @api jtp
    lang = LANG

    connectedCallback() {
        const storedValue = localStorage.getItem('checked');
        this.contact.bookedForSelf = storedValue === 'true'  ? true : false;
        this.checked = this.contact.bookedForSelf;
        this.contact.bookedForFirstName = localStorage.getItem('bookedForFirstName') || '';
        this.contact.bookedForLastName = localStorage.getItem('bookedForLastName') || '';
        this.contact.bookedForEmail = localStorage.getItem('bookedForEmail') || '';
        this.contact.bookedForPhone = localStorage.getItem('bookedForPhone') || '';
        this.contact.relationToPatient = localStorage.getItem('relationToPatient') || '';
        this.contact.firstName = localStorage.getItem('firstName') || '';
        this.contact.lastName = localStorage.getItem('lastName') || '';
        this.contact.email = localStorage.getItem('email') || '';
        this.contact.phone = localStorage.getItem('phone') || '';
        this.contact.RSZ = localStorage.getItem('contactRSZ') || '';
        this.contact.street = localStorage.getItem('contactStreet') || '';
        this.contact.city = localStorage.getItem('contactCity') || '';
        this.contact.country = localStorage.getItem('contactCountry') || '';
        this.contact.birthdate = localStorage.getItem('birthdate') || ''; 
        this.contact.postalCode = localStorage.getItem('contactPostalCode') || '';
        this.contact.province = localStorage.getItem('contactProvince') || '';
        const storedHasRSZ = localStorage.getItem('hasRSZ');
        this.hasNoRSZ = storedHasRSZ === 'true';
        this.checkCompletion(); 
    }

    label = {
        FirstName: FirstName,
        LastName: LastName,
        FirstNamePatient: FirstNamePatient,
        LastNamePatient: LastNamePatient,
        BookedForSomeoneElse: BookedForSomeoneElse,
        RSZ: RSZ,
        NoRSZ: NoRSZ,
        RelationToUser: RelationToUser,
        YourPhone: YourPhone,
        YourEmail: YourEmail,
        Phone: Phone,
        Address: Address,
        Street: Street,
        City: City,
        PostalCode: PostalCode,
        Country: Country,
        Province: Province,
        PatientEmail: PatientEmail,
        RSZHelpText: RSZHelpText,
    }

    disconnectedCallback() {
        if(!this.contact.birthdate){
            this.setBirthDate(this.contact.RSZ)
        }
        this.passToParent();
    }

    get optionsWithClass() {
        return this.options.map(option => {
            return {
                ...option,
                class: `button ${option.value === this.contact.relationToPatient ? 'active' : ''}`
            };
        });
    }

    get options() {
        return [
            { label: 'Ouder', value: 'Parent' },
            { label: 'Familielid', value: 'Family member' },
            { label: 'Voogd', value: 'Guardian' },
            { label: 'Andere', value: 'Other' },
        ];
    }
    
    handleToggle() {
        if(this.contact.bookedForSelf) {
            this.contact.bookedForSelf = false
        } else {
            this.contact.bookedForSelf = true
        }
        const value = this.contact.bookedForSelf;   
        this.checked = this.contact.bookedForSelf;
        localStorage.setItem('checked', value);
        this.checkCompletion();
    }


    handleFieldChange(event){
        const value = event.target.value;
        if(event.target.name == 'bookedForFirstName'){
            this.contact.bookedForFirstName = value;
            localStorage.setItem('bookedForFirstName', value);
            console.log('handlechangefunction working')
        } else if( event.target.name == 'bookedForLastName') {
            this.contact.bookedForLastName = value;
            localStorage.setItem('bookedForLastName', value);
        } else if(event.target.name == 'bookedForEmail'){
            this.contact.bookedForEmail = value;
            localStorage.setItem('bookedForEmail', value);
        } else if(event.target.name == 'bookedForPhone'){
            this.contact.bookedForPhone = value;
            localStorage.setItem('bookedForPhone', value);
        } else if(event.target.name == 'bookedForEmail') {
            this.contact.bookedForEmail = value;
            localStorage.setItem('bookedForEmail', value);
        } else if(event.target.name =='relationToPatient'){
            this.contact.relationToPatient = value;
            localStorage.setItem('relationToPatient', value);
        } else if(event.target.name == 'firstName'){
            this.contact.firstName = value;
            localStorage.setItem('firstName', value);
        } else if(event.target.name == 'lastName'){
            this.contact.lastName = value;
            localStorage.setItem('lastName', value);
        } else if(event.target.name == 'email'){
            this.contact.email = value;
            localStorage.setItem('email', value);
        } else if(event.target.name == 'phone'){
            this.contact.phone = value;
            localStorage.setItem('phone', value);
        } else if(event.target.name == 'NoRSZ'){
            this.hasNoRSZ = event.target.checked;
            this.contact.hasNoRSZ = this.hasNoRSZ;
            localStorage.setItem('hasRSZ', this.hasNoRSZ);
        } else if(event.target.name == 'birthdate'){
            this.contact.birthdate = value;
            localStorage.setItem('birthdate', value);
        } else if(event.target.name == 'RSZ'){
            var inputCmp = this.template.querySelector('.inputCmp')
            const value = event.target.value;
            localStorage.setItem('contactRSZ', value);
            if (this.isValidRijksregisternummer(value)) {
                this.contact.RSZ = value;
                inputCmp.setCustomValidity('');
                inputCmp.reportValidity();
                this.setBirthDate(value);
                
            } else {
                inputCmp.setCustomValidity('Incorrecte rijksregister nummer');
                inputCmp.reportValidity();
                
            }
        }
        this.checkCompletion();
    }

    // handleForContactFirstNameChange(event){
    //     const value = event.target.value;
    //     this.contact.bookedForFirstName = value;
    //     localStorage.setItem('bookedForFirstName', value);
    //     this.checkCompletion()
    // }

    // handleForContactLastNameChange(event){
    //     const value = event.target.value;
    //     this.contact.bookedForLastName = value;
    //     localStorage.setItem('bookedForLastName', value);
    //     this.checkCompletion()
    // }

    // handleForContactEmailChange(event){
    //     const value = event.target.value;
    //     this.contact.bookedForEmail = value;
    //     localStorage.setItem('bookedForEmail', value);
    //     this.checkCompletion()
    // }

    // handleForContactPhoneChange(event){
    //     const value = event.target.value;
    //     this.contact.bookedForPhone = value; 
    //     localStorage.setItem('bookedForPhone', value);
    //     this.checkCompletion()
    // }

    // handleRelationToPatient(event) {
    //     const value = event.target.value;
    //     this.contact.relationToPatient = value;
    //     localStorage.setItem('relationToPatient', value);
    // }

    // handleFirstNameChange(event) {
    //     const value = event.target.value;
    //     this.contact.firstName = value;
    //     localStorage.setItem('firstName', value);
    //     this.checkCompletion()
    // }
    // handleLastNameChange(event) {
    //     const value = event.target.value;
    //     this.contact.lastName = event.target.value;
    //     localStorage.setItem('lastName', value);
    //     this.checkCompletion()
    // }
    // handleEmailChange(event) {
    //     const value = event.target.value;
    //     this.contact.email = event.target.value;
    //     localStorage.setItem('email', value);
    //     this.checkCompletion()
    // }
    // handlePhoneChange(event) {
    //     const value = event.target.value;
    //     this.contact.phone = event.target.value;
    //     localStorage.setItem('phone', value);
    //     this.checkCompletion()
    // }

    // handlehasRSZChange(event) {
    //     this.hasNoRSZ = event.target.checked;
    //     this.contact.hasNoRSZ = this.hasNoRSZ;
    //     localStorage.setItem('hasRSZ', this.hasNoRSZ);
    //     this.checkCompletion();
    // }

    // handleBirthdateChange(event){
    //     const value = event.target.value;
    //     this.contact.birthdate = value;
    //     localStorage.setItem('birthdate', value);
    //     this.checkCompletion();
    // }
    

    // handleRSZChange(event) {
    //     var inputCmp = this.template.querySelector('.inputCmp')
    //     const value = event.target.value;
    //     localStorage.setItem('contactRSZ', value);
    //     if (this.isValidRijksregisternummer(value)) {
    //         this.contact.RSZ = value;
    //         inputCmp.setCustomValidity('');
    //         inputCmp.reportValidity();
    //         this.setBirthDate(value);
            
    //     } else {
    //         inputCmp.setCustomValidity('Incorrecte rijksregister nummer');
    //         inputCmp.reportValidity();
            
    //     }
    //     this.checkCompletion()
    // }
    
    isValidRijksregisternummer(value) {
        const numericValue = value.replace(/\D/g, '');
    
        if (numericValue.length !== 11) {
            return false;
        }
    
        const firstNineDigits = parseInt(numericValue.substring(0, 9), 10);
        const lastTwoDigits = parseInt(numericValue.substring(9, 11), 10);
    
        // Calculate checksum for birth before 2000
        let checksum = 97 - (firstNineDigits % 97);
    
        // If the checksum does not match, check for birth after 2000
        if (checksum !== lastTwoDigits) {
            checksum = 97 - ((2000000000 + firstNineDigits) % 97);
            this.birthyearPrefix = "20"
        } else {
            this.birthyearPrefix = "19"
        }
    
        return checksum === lastTwoDigits;
    }

    checkCompletion(){
        if (
            this.contact.firstName &&
            this.contact.lastName &&
            (
                (this.contact.bookedForSelf && this.contact.bookedForEmail) ||
                (!this.contact.bookedForSelf && this.contact.email)
            ) &&
            // this.contact.email &&
            // this.contact.phone &&
            (
                (this.contact.bookedForSelf && this.contact.bookedForPhone) ||
                (!this.contact.bookedForSelf && this.contact.phone)
            ) &&
            (
              (this.contact.RSZ && !this.hasNoRSZ) ||
              (this.hasNoRSZ && this.contact.birthdate)
            )
          ) {
            this.contactInfoComplete = true;
        } else {
            this.contactInfoComplete = false;
        }

        this.screenOneCompletion()
    }
    

    setBirthDate(value) {
        const d = new Date();
        const year = parseInt(this.birthyearPrefix + value.substring(0, 2), 10);
        const month = parseInt(value.substring(2, 4), 10) - 1;
        const day = parseInt(value.substring(4, 6), 10);
    
        d.setFullYear(year);
        d.setMonth(month);
        d.setDate(day);
    
        const formatted = d.toISOString().split('T')[0];

        this.contact.birthdate = formatted;
        localStorage.setItem('birthdate', formatted);
    }

    

    async handleAddressChange(event) {
        this.contact.street = event.target.street;
        this.contact.city = event.target.city;
        this.contact.country = 'Belgium';
        this.contact.province= event.target.province;
        this.contact.postalCode = event.target.postalCode;

       this.contact.address = this.contact.street + this.contact.city + this.contact.country +  this.contact.province + this.contact.postalCode        

        localStorage.setItem('contactStreet', this.contact.street);
        localStorage.setItem('contactCity', this.contact.city);
        localStorage.setItem('contactCountry', 'Belgium');
        localStorage.setItem('contactProvince', this.contact.province);
        localStorage.setItem('contactPostalCode', this.contact.postalCode);
    }

    @api screenOneCompletion() {
        const contactInfoComplete = this.contactInfoComplete
        const patientCompletion = new CustomEvent('screenonecompleted',{
            detail: {
                contactInfoComplete,
                bubbles: true,
                composed: true
            }
        });
        this.dispatchEvent(patientCompletion);
    }
    
    @api passToParent() {
        const patientInfo = new CustomEvent('patientdetails',{
            detail: {
                ...this.contact,
                bubbles: true,
                composed: true
            }
        });
        this.dispatchEvent(patientInfo);
    }

}