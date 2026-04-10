import { LightningElement, api } from 'lwc';

export default class ParameterValuesPicklist extends LightningElement {
    @api value;
    @api recordId;
    @api parameterId;
    @api options = [];

    handleChange(event) {
        const selectedValue = event.detail.value;

        this.dispatchEvent(new CustomEvent('valuechange', {
            detail: {
                recordId: this.recordId,
                value: selectedValue
            },
            bubbles: true,
            composed: true
        }));
    }
}