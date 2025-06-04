import { LightningElement, track, api } from 'lwc';

export default class SelectPatient extends LightningElement {
    @track checked;
    contact = {
        firstName: null,
        lastName: null,
        email: null,
        phone: null,
        RSZ: null,
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
        relationToPatient: null,
    }
    contactInfoComplete = false
    birthyearPrefix = "19"
    @api jtp

    connectedCallback() {
        const storedValue = localStorage.getItem('checked');
        this.contact.bookedForSelf = storedValue !== null ? storedValue === 'true' : true;
        console.log('booked for self in connected callback: ' + this.contact.bookedForSelf)   
        this.checked = this.contact.bookedForSelf;
        this.contact.bookedForFirstName = localStorage.getItem('bookedForFirstName') || '';
        this.contact.bookedForLastName = localStorage.getItem('bookedForLastName') || '';
        this.contact.relationToPatient = localStorage.getItem('relationToPatient') || '';
        this.contact.firstName = localStorage.getItem('firstName') || '';
        this.contact.lastName = localStorage.getItem('lastName') || '';
        this.contact.email = localStorage.getItem('email') || '';
        this.contact.phone = localStorage.getItem('phone') || '';
        this.contact.street = localStorage.getItem('contactStreet') || '';
        this.contact.city = localStorage.getItem('contactCity') || '';
        this.contact.country = localStorage.getItem('contactCountry') || '';
        this.contact.birthdate = localStorage.getItem('birthdate') || ''; 
        this.contact.postalCode = localStorage.getItem('contactPostalCode') || '';
        this.contact.province = localStorage.getItem('contactProvince') || '';
        this.checkCompletion();
    }

    disconnectedCallback() {
        this.passToParent();
    }

    get options() {
        return [
            { label: 'Ouder', value: 'Ouder' },
            { label: 'Familielid', value: 'Familielid' },
            { label: 'Voogd', value: 'Voogd' },
            { label: 'Andere', value: 'Andere' },
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
        console.log(this.contact.bookedForSelf)
    }

    handleForContactFirstNameChange(event){
        const value = event.target.value;
        this.contact.bookedForFirstName = value;
        localStorage.setItem('bookedForFirstName', value);
    }

    handleForContactLastNameChange(event){
        const value = event.target.value;
        this.contact.bookedForLastName = value;
        localStorage.setItem('bookedForLastName', value);
    }

    handleRelationToPatient(event){
        const value = event.target.value;
        this.contact.relationToPatient = value;
        localStorage.setItem('relationToPatient', value);
    }

    handleFirstNameChange(event) {
        const value = event.target.value;
        this.contact.firstName = value;
        localStorage.setItem('firstName', value);
        this.checkCompletion()
    }
    handleLastNameChange(event) {
        const value = event.target.value;
        this.contact.lastName = event.target.value;
        localStorage.setItem('lastName', value);
        this.checkCompletion()
    }
    handleEmailChange(event) {
        const value = event.target.value;
        this.contact.email = event.target.value;
        localStorage.setItem('email', value);
        this.checkCompletion()
    }
    handlePhoneChange(event) {
        const value = event.target.value;
        this.contact.phone = event.target.value;
        localStorage.setItem('phone', value);
        this.checkCompletion()
    }

    handleRSZChange(event) {
        var inputCmp = this.template.querySelector('.inputCmp')
        const value = event.target.value;
        if (this.isValidRijksregisternummer(value)) {
            this.contact.RSZ = value;
            localStorage.setItem('contactRSZ', value);
            inputCmp.setCustomValidity('');
            inputCmp.reportValidity();
            this.setBirthDate(value);

        } else {
            inputCmp.setCustomValidity('Incorrecte rijksregister nummer');
            inputCmp.reportValidity();

        }
    }
    
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
        if(this.contact.firstName && this.contact.lastName && this.contact.email && this.contact.phone) {
            this.contactInfoComplete = true;
        } else {
            this.contactInfoComplete = false;
        }

        this.screenOneCompletion()
    }
    

    setBirthDate(value) {
        console.log(value);
        const d = new Date();
        const year = parseInt(this.birthyearPrefix + (value.substring(0, 2)), 10);
        const parsedYear = parseInt(year)
        d.setYear(parsedYear);
        d.setMonth(parseInt(value.substring(2, 4) - 1, 10));
        d.setDate(parseInt(value.substring(4, 6), 10));
        this.contact.birthdate = d.toLocaleDateString('nl-BE');
        localStorage.setItem('birthdate', this.birthdate);
    }

    

    async handleAddressChange(event) {
        this.contact.street = event.target.street;
        this.contact.city = event.target.city;
        this.contact.country = event.target.country;
        this.contact.province= event.target.province;
        this.contact.postalCode = event.target.postalCode;

       this.contact.address = this.contact.street + this.contact.city + this.contact.country +  this.contact.province + this.contact.postalCode        

        localStorage.setItem('contactStreet', this.contact.street);
        localStorage.setItem('contactCity', this.contact.city);
        localStorage.setItem('contactCountry', this.contact.country);
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