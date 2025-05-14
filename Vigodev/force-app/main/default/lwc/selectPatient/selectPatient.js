import { LightningElement, track } from 'lwc';

export default class SelectPatient extends LightningElement {
    @track checked;
    contactFirstName;
    contactLastName;
    contactEmail;
    contactPhone;
    contactRSZ
    contactStreet;
    contactCity;
    contactCountry;
    contactProvince;
    contactPostalCode;
    contactAddress
    birthyearPrefix = "19"
    birthdate

    connectedCallback() {
        this.checked = true;
        this.checked = localStorage.getItem('checked') === 'true';
        this.contactFirstName = localStorage.getItem('contactFirstName') || '';
        this.contactLastName = localStorage.getItem('contactLastName') || '';
        this.contactEmail = localStorage.getItem('contactEmail') || '';
        this.contactPhone = localStorage.getItem('contactPhone') || '';
        this.contactStreet = localStorage.getItem('contactStreet') || '';
        this.contactCity = localStorage.getItem('contactCity') || '';
        this.contactCountry = localStorage.getItem('contactCountry') || '';
        this.birthdate = localStorage.getItem('birthdate') || '';
    }

    handleToggle() {
        this.checked = !this.checked;
    }

    handleFirstNameChange(event) {
        const value = event.target.value;
        this.contactFirstName = value;
        localStorage.setItem('contactFirstName', value);
    }
    handleLastNameChange(event) {
        const value = event.target.value;
        this.contactLastName = event.target.value;
        localStorage.setItem('contactLastName', value);
    }
    handleEmailChange(event) {
        const value = event.target.value;
        this.contactEmail = event.target.value;
        localStorage.setItem('contactEmail', value);
    }
    handlePhoneChange(event) {
        const value = event.target.value;
        this.contactPhone = event.target.value;
        localStorage.setItem('contactPhone', value);
    }

    handleRSZChange(event) {
        var inputCmp = this.template.querySelector('.inputCmp')
        const value = event.target.value;
        if (this.isValidRijksregisternummer(value)) {
            this.contactRSZ = value;
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
        this.birthdate = d.toLocaleDateString('nl-BE');
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

        // const address = event.target.value;
        // console.log('address ' + address)

        // if (address) {
        //     const geolocation = await getGeolocation(address);
    
        //     if (geolocation) {
        //         console.log(`Latitude: ${geolocation.latitude}, Longitude: ${geolocation.longitude}`);
        //     } else {
        //         console.log('Geolocation not found');
        //     }
        // }
    }

    // async getGeolocation(address) {
    //     const url = `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(address)}&format=json&addressdetails=1`;
    
    //     const response = await fetch(url);
    //     const data = await response.json();
    
    //     if (data && data[0]) {
    //         return {
    //             latitude: parseFloat(data[0].lat),
    //             longitude: parseFloat(data[0].lon),
    //         };
    //     }
    
    //     return null;
    // }
    
    
}