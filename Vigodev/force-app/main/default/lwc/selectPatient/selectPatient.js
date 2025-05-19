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
        birthdate: null
    }
    birthyearPrefix = "19"
    @api jtp

    connectedCallback() {
        this.checked = true;
        this.checked = localStorage.getItem('checked');     
        this.contact.firstName = localStorage.getItem('firstName') || '';
        this.contact.lastName = localStorage.getItem('lastName') || '';
        this.contact.email = localStorage.getItem('email') || '';
        this.contact.phone = localStorage.getItem('phone') || '';
        this.contact.street = localStorage.getItem('street') || '';
        this.contact.city = localStorage.getItem('city') || '';
        this.contact.country = localStorage.getItem('country') || '';
        this.contact.birthdate = localStorage.getItem('birthdate') || ''; 
    }

    disconnectedCallback() {
        console.log('disconnected callback')
        this.passToParent();
    }
    
    handleToggle() {
        this.checked = !this.checked;
        localStorage.setItem('checked', this.checked);
    }

    handleFirstNameChange(event) {
        const value = event.target.value;
        this.contact.firstName = value;
        localStorage.setItem('firstName', value);
    }
    handleLastNameChange(event) {
        const value = event.target.value;
        this.contact.lastName = event.target.value;
        localStorage.setItem('lastName', value);
    }
    handleEmailChange(event) {
        const value = event.target.value;
        this.contact.email = event.target.value;
        localStorage.setItem('email', value);
    }
    handlePhoneChange(event) {
        const value = event.target.value;
        this.contact.phone = event.target.value;
        localStorage.setItem('phone', value);
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
        const streetValue = event.target.street;
        const cityValue = event.target.city;
        const countryValue = event.target.country;
        const provinceValue = event.target.province;
        const postalCodeValue = event.target.postalCode;;

        localStorage.setItem('contactStreet', streetValue);
        localStorage.setItem('contactCity', cityValue);
        localStorage.setItem('contactCountry', countryValue);
        localStorage.setItem('contactProvince', provinceValue);
        localStorage.setItem('contactPostalCode', postalCodeValue);
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