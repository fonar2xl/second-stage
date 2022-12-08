/**
 * Created by alexey on 28/11/2022.
 */

import {LightningElement, api, track} from 'lwc';
import runOnceBatch from '@salesforce/apex/BatchLauncherController.runOnceBatch';
import scheduleBatch from '@salesforce/apex/BatchLauncherController.scheduleBatch';
import abortBatch from '@salesforce/apex/BatchLauncherController.abortBatch';
import checkScheduler from '@salesforce/apex/BatchLauncherController.checkScheduler';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class BatchLauncher extends LightningElement {
    @api nameScheduler;
    @api nameBatch;
    buttonRunOnce = true;
    buttonScheduleBatch = true;
    buttonAbortBatch = false;
    spinner = true;
    component = false;
    schedulerId;
    inputDisabled;
    buttonDisabled;

    connectedCallback() {
        checkScheduler({
            nameScheduler: this.nameScheduler
        })
            .then(result => {
                this.schedulerId = result.id;
                console.log(this.schedulerId);
                if (this.schedulerId) {
                    this.buttonScheduleBatch = false;
                    this.buttonAbortBatch = true;
                    this.inputDisabled = true;
                }
            })
            .catch(error => {
                console.log(error);
            })
            .finally(() => {
                this.spinner = false;
                this.component = true;
            })
    }

    buttonOnAndOff(event) {
        this.buttonDisabled = event.target.value === '';
    }

    handleClickRunOnce() {
        runOnceBatch({
            nameBatchClass: this.nameBatch
        })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Batch started.',
                        variant: 'success'
                    })
                )
            })
            .catch(error => {
                console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                )
            })
    }

    handleClickScheduleBatch() {
        const cronExp = (this.template.querySelector('.input-text')).value;
        scheduleBatch({
            cron: cronExp,
            nameScheduler: this.nameScheduler
        })
            .then(result => {
                this.spinner = true;
                this.buttonScheduleBatch = false;
                this.buttonAbortBatch = true;
                this.inputDisabled = true;
                this.schedulerId = result;
                console.log(this.schedulerId);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Scheduler launched successfully.',
                        variant: 'success'
                    })
                )
            })
            .catch(error => {
                console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                )
            })
            .finally(() => {
                this.spinner = false;
            })
    }

    handleClickAbortBatch() {
        abortBatch({
            ids: this.schedulerId
        })
            .then(() => {
                this.buttonScheduleBatch = true;
                this.buttonAbortBatch = false;
                this.inputDisabled = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Scheduler stopped.',
                        variant: 'success'
                    })
                )
            })
            .catch(error => {
                console.error(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                )
            })
    }
}