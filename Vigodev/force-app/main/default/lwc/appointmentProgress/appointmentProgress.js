import { LightningElement, api, track } from 'lwc';

export default class AppointmentProgress extends LightningElement {

    @track currentstep = "1"

    @api
    complete() {
        if (parseInt(this.currentstep) < 4) {
            this.currentstep = String(parseInt(this.currentstep) + 1);
        }
    }

    @api
    previous() {
        if (this.currentstep > 1) {
            this.currentstep = String(parseInt(this.currentstep) - 1);
            
        }
    }
}
