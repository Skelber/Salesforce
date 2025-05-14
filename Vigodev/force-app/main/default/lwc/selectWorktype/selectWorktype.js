import { LightningElement, track } from 'lwc';
import bandageIcon from "@salesforce/resourceUrl/bandage";
import prostheticIcon from "@salesforce/resourceUrl/prosthetic";
import orthoticIcon from "@salesforce/resourceUrl/orthotics";

export default class SelectWorktype extends LightningElement {

    bandageIcon = bandageIcon;
    prostheticIcon = prostheticIcon;
    orthoticIcon = orthoticIcon;
    @track activeSection = "A"

    handleBusinessUnitSelection() {
        this.activeSection = "B"
    }
}