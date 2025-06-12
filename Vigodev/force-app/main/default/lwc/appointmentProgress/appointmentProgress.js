import { LightningElement, api, track } from 'lwc';

export default class AppointmentProgress extends LightningElement {

    @api currentstep = "1"
    @api pathType = "path"


    connectedCallback(){
        let width = window.innerWidth;
        console.log('width is ' +width)
        this.setPathVariant(width);
    }

    setPathVariant(width){
        if(width < 768){
            this.pathType = 'base'
        }else{
            this.pathType = 'path'
        }
    }

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
