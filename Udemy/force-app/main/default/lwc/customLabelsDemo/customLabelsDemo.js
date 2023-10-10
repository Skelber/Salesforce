import { LightningElement } from 'lwc';
import DESCRIPTION_ONE from '@salesforce/label/c.DescriptionOne'
import DESCRIPTION_TWO from '@salesforce/label/c.DescriptionTwo'

export default class CustomLabelsDemo extends LightningElement {
    

    LABELS = {
        descriptionOne : DESCRIPTION_ONE,
        descriptionTwo : DESCRIPTION_TWO
    }
}