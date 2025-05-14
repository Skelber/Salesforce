import { LightningElement, api, track } from 'lwc';

export default class AppointmentProgress extends LightningElement {

    @api currentstep = "1"

    @api
    complete() {
        if (parseInt(this.currentstep) < 6) {
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
