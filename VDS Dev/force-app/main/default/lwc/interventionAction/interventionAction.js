/**
 * Created by admin on 15/05/2025.
 */

import {api, LightningElement, wire} from 'lwc';
import LightningAlert from "lightning/alert";
import getAction from "@salesforce/apex/InterventionActionController.getAction"
import save from "@salesforce/apex/InterventionActionController.save"
import {CloseActionScreenEvent} from "lightning/actions";

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import INTERVENTION_ACTION_OBJECT from '@salesforce/schema/Intervention_Action__c';
import EXECUTION_BY_FIELD from '@salesforce/schema/Intervention_Action__c.Execution_by__c';
import COSTS_FOR_FIELD from '@salesforce/schema/Intervention_Action__c.Costs_for__c';

import COLOUR_LABEL from '@salesforce/label/c.Colour';
import DETAILSEXECUTEDWORKS_LABEL from '@salesforce/label/c.Details_executed_works';
import PRODUCT_LABEL from '@salesforce/label/c.Product';
import PRODUCTSCONSUMED_LABEL from '@salesforce/label/c.Products_Consumed';
import QUANTITY_LABEL from '@salesforce/label/c.Quantity';
import SAVE_LABEL from '@salesforce/label/c.Save';
import TREATEDSURFACE_LABEL from '@salesforce/label/c.Treated_surface';
import WHATEXECUTEDWORKS_LABEL from '@salesforce/label/c.What_are_the_executed_works';
import WHATPROBLEMLOCATION_LABEL from '@salesforce/label/c.What_is_the_problem_location';
import COMBINATIONPIGMENTS_LABEL from '@salesforce/label/c.What_combination_pigments';


export default class InterventionAction extends LightningElement {
    @api recordId;
    interventionActionWrapper;
    loading = false;
    timesheetStartTime;
    timesheetEndTime;

    label = {
            colourLabel: COLOUR_LABEL,
            detailsExecutedWorksLabel : DETAILSEXECUTEDWORKS_LABEL,
            productLabel : PRODUCT_LABEL,
            productsConsumedLabel : PRODUCTSCONSUMED_LABEL,
            quantityLabel : QUANTITY_LABEL,
            saveLabel : SAVE_LABEL,
            treatedSurfaceLabel : TREATEDSURFACE_LABEL + '?',
            executedWorksLabel : WHATEXECUTEDWORKS_LABEL + '?',
            problemLocationLabel : WHATPROBLEMLOCATION_LABEL + '?',
            combinationPigmentsLabel : COMBINATIONPIGMENTS_LABEL + '?'
        }

    async connectedCallback() {
 
        try {
            this.loading = true;
            this.interventionActionWrapper = await getAction({workStepId: this.recordId });
        } catch (e) {
            await this.showError(e);
        } finally {
            this.loading = false;
        }
    }

    get activeSections() {
        return ['general', 'productsConsumed', 'Vehicle', 'Material', 'Time'];
    }

    get interventionAction() {
        return this.interventionActionWrapper ? this.interventionActionWrapper.interventionAction : undefined;
    }

    get productsConsumed() {
        return this.interventionActionWrapper ? this.interventionActionWrapper.productsConsumed : [];
    }

    get showCombinationPigments(){
        return this.interventionActionWrapper? (this.interventionActionWrapper.isTestSurface || this.interventionActionWrapper.isIntervention) && (this.interventionActionWrapper.interventionAction.Type__c == 'Pigmentation' || this.interventionActionWrapper.interventionAction.Type__c == 'Cementing') : false;
    }

    handleDescriptionChange(event) {
        this.interventionActionWrapper = {
            ...this.interventionActionWrapper,
            interventionAction: {
                ...this.interventionActionWrapper.interventionAction,
                Description__c: event.detail.value
            }
        };
    }

    handleProblemLocationChange(event) {
        this.interventionActionWrapper = {
            ...this.interventionActionWrapper,
            interventionAction: {
                ...this.interventionActionWrapper.interventionAction,
                Problem_Location__c: event.detail.value
            }
        };
    }

    handleTreatedSurfaceChange(event) {
        this.interventionActionWrapper = {
            ...this.interventionActionWrapper,
            interventionAction: {
                ...this.interventionActionWrapper.interventionAction,
                Treated_Surface__c: event.detail.value
            }
        };
    }

    handleCombinationPigmentsChange(event) {
        this.interventionActionWrapper = {
            ...this.interventionActionWrapper,
            interventionAction: {
                ...this.interventionActionWrapper.interventionAction,
                Combination_pigments_final__c: event.detail.value
            }
        };
    }

    handleQuantityChange(event) {
        const {idx} = event.target.dataset;
        const productsConsumed = JSON.parse(JSON.stringify(this.productsConsumed));
        productsConsumed[idx].quantity = event.detail.value || 0;
        this.interventionActionWrapper = {
            ...this.interventionActionWrapper,
           productsConsumed
        };
    }

    handleStartTime(event) {
        this.timesheetStartTime = this.combineTodayWithTime(event.target.value);
    }
    
    handleEndTime(event) {
        this.timesheetEndTime = this.combineTodayWithTime(event.target.value);
    }
    
    combineTodayWithTime(timeValue) {
        const today = new Date();
    
        const [hours, minutes] = timeValue.split(':');
    
        today.setHours(parseInt(hours, 10));
        today.setMinutes(parseInt(minutes, 10));
        today.setSeconds(0);
        today.setMilliseconds(0);
    
        return today.toISOString();
    }

    async save() {
        try {
            this.loading = true;
            await save({ 
                workStepId: this.recordId, 
                wrapper: this.interventionActionWrapper,
                startTime: this.timesheetStartTime,
                endTime: this.timesheetEndTime});
            this.dispatchEvent(new CloseActionScreenEvent());
        } catch(e) {
            await this.showError(e);
        } finally {
            this.loading = false;
        }
    }

    async showError(e) {
        await LightningAlert.open({
            message: JSON.stringify(e),
            theme: 'error',
            label: 'Error',
        });
    }
}