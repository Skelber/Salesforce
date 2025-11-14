import { LightningElement } from 'lwc';
import runBatch from '@salesforce/apex/AccountPlanBatchLauncher.runBatch';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AccountPlanBatchButton extends LightningElement {
    isRunning = false;

    async handleClick() {
        this.isRunning = true;
        try {
            await runBatch();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Account Plan Batch started successfully!',
                    variant: 'success'
                })
            );
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error starting batch',
                    message: error.body ? error.body.message : error.message,
                    variant: 'error'
                })
            );
        } finally {
            this.isRunning = false;
        }
    }
}