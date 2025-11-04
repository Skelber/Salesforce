/**
 * Created by Tom Vanhouche on 29/07/2024.
 */

import { api, LightningElement, wire } from 'lwc';
import getUniqueInvolvements from '@salesforce/apex/UniqueInvolvementsController.getUniqueInvolvements';

export default class UniqueInvolvements extends LightningElement {
    @api recordId;
    @api involvementType;
    uniqueInvolvements;

    @wire(getUniqueInvolvements, {
        recordId: '$recordId',
        involvementType: '$involvementType'
    })
    wiredInvolvements({ error, data }) {
        console.log(error, data);
        if (data) {
            this.uniqueInvolvements = data;
        }
    }
}