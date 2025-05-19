import { LightningElement, api } from 'lwc';
import avatar from "@salesforce/resourceUrl/avatar";

export default class SelectServiceResource extends LightningElement {
    @api notBookableViaWebsite = false;
    avatar = avatar;

    // connectedCallback(){
    //     this.notBookableViaWebsite = true;
    // }


}