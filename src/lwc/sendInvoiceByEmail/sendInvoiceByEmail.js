/**
 * Created by alexey on 20/10/2022.
 */

import {LightningElement, api, wire} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import oppRolesAndEmailTemplate from '@salesforce/apex/SendInvoiceByEmailController.oppRolesAndEmailTemplate';
import sendEmailTemplate from '@salesforce/apex/SendInvoiceByEmailController.sendEmailTemplate';
import {CloseActionScreenEvent} from 'lightning/actions';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class My_lwc extends NavigationMixin(LightningElement) {
    @api recordId;
    opportunityRoles = {};
    emailTemplateBody;
    emailSubject;
    contentDocumentId;
    contactId;
    invoiceNumber;
    success = false;
    spinner = false;

    @wire(oppRolesAndEmailTemplate, {ids: '$recordId'})
    resultData(result) {
        if (!result.error && result.data) {
            try {
                this.opportunityRoles = result.data.OpportunityRoles.OpportunityContactRoles[0].Contact;
                this.emailTemplateBody = result.data.EmailTemplate.Body;
                this.emailSubject = result.data.EmailTemplate.Subject;
                this.contactId = result.data.OpportunityRoles.OpportunityContactRoles[0].Contact.Id;
                this.invoiceNumber = result.data.OpportunityRoles.Invoice_Number__c;
                this.contentDocumentId = result.data.contentDocId[0].ContentDocumentId;
                this.spinner = true;
                this.success = true;
                console.log('CON ID = ', this.contentDocumentId);
            } catch (error) {
                console.log(error)
            }
        }
    }

    handleChange(event) {
        this.emailTemplateBody = event.target.value;
    }

    previewHandler() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                recordIds: this.contentDocumentId
            }
        })
    }

    closeQuickAction() {
        sendEmailTemplate({
            emailTemplateBody: this.emailTemplateBody,
            contactId        : this.contactId,
            contentDocId     : this.contentDocumentId
        })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title  : 'Success',
                        message: 'Success send email',
                        variant: 'success'
                    })
                )
            })
            .catch(error => {
                console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title  : 'Error',
                        message: 'Email limit exceeded.',
                        variant: 'error'
                    })
                )
            })
            .finally(() => {
                this.dispatchEvent(new CloseActionScreenEvent());
            })
    }
}