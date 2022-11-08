/**
 * Created by alexey on 31/10/2022.
 */

import {LightningElement, api, track} from 'lwc';
import CREATE_DATE_FIELD from '@salesforce/schema/Opportunity.CreatedDate';
import CLOSE_DATE_FIELD from '@salesforce/schema/Opportunity.CloseDate';
import AMOUNT_FIELD from '@salesforce/schema/Opportunity.Amount';
import getClosedOpportunity from '@salesforce/apex/GetCustomerData.getClosedOpportunity';
import getOpportunityProduct from '@salesforce/apex/GetCustomerData.getOpportunityProduct';

const columns = [
    {
        label: 'Opportunity Name', fieldName: 'oppUrl', type: 'url', sortable: true,
        typeAttributes: {label: {fieldName: 'oppName'}}
    },
    {label: 'Created Date', fieldName: CREATE_DATE_FIELD.fieldApiName, type: 'date-local'},
    {label: 'Closed Date', fieldName: CLOSE_DATE_FIELD.fieldApiName, type: 'date'},
    {label: 'Amount', fieldName: AMOUNT_FIELD.fieldApiName, type: 'currency'},
    {
        type: 'button',
        fixedWidth: 120,
        typeAttributes: {
            disabled: false,
            label: 'Products',
            name: 'preview',
            title: 'Click to Preview',
            iconName: 'utility:preview',
        }
    }
];
export default class CustomerData extends LightningElement {
    @api recordId;
    @track previousDisabled = true;
    @track nextDisabled;
    columns = columns;
    showModal;
    noProducts;
    iterationProduct;
    items;
    opportunityProduct;
    page = 1;
    numberOfPages;
    numberOfRows = 10;
    offset = 0;
    searchValue = '';
    isDetailPage;

    async connectedCallback() {
        await this.getData();
    }

    async getData() {
        try {
            const data = await getClosedOpportunity({
                searchString: this.searchValue,
                startIndex: this.offset,
                accountId: this.recordId
            });
            if (this.recordId) {
                this.isDetailPage = false;
                this.items = this.getItems(data);
            } else {
                this.isDetailPage = true;
                this.items = this.getItems(data);
                if (this.items.length === 0) {
                    this.nextDisabled = true;
                    this.numberOfPages = 1;
                } else {
                    this.numberOfPages = Math.ceil(this.items[0].sizeQuery / this.numberOfRows);
                    this.nextDisabled = this.page === this.numberOfPages;
                }
            }
        } catch (e) {
            console.log(e);
        }
    }

    getItems(data) {
        return data.map(itemData => {
            const newArr = [];
            itemData.opportunities.forEach(itemOpp => {
                newArr.push({
                    AccountId: itemOpp.AccountId,
                    oppName: itemOpp.Name,
                    Id: itemOpp.Id,
                    oppUrl: '/' + itemOpp.Id,
                    Amount: itemOpp.Amount,
                    CloseDate: itemOpp.CloseDate,
                    CreatedDate: itemOpp.CreatedDate
                })
            })
            return {
                label: itemData.label,
                opportunities: newArr,
                sizeQuery: itemData.sizeQuery
            };
        });
    }

    async handleKeyChange(event) {
        this.offset = 0;
        this.searchValue = event.target.value;
        setTimeout(() => {
            this.getData();
        }, 1000);
    }

    async previousPage() {
        this.offset -= this.numberOfRows;
        await this.getData();
        this.page -= 1;
        this.nextDisabled = false;
        if (this.page === 1) {
            this.previousDisabled = true;
        }
    }

    async nextPage() {
        this.offset += this.numberOfRows;
        await this.getData();
        this.page += 1;
        this.previousDisabled = false;
        if (this.page === this.numberOfPages) {
            this.nextDisabled = true;
        }
    }

    async getRowActions(event) {
        const recId = event.detail.row.Id;
        await getOpportunityProduct({
            opportunityId: recId
        })
            .then(result => {
                if (result.length !== 0) {
                    this.noProducts = true;
                    this.opportunityProduct = result;
                    this.iterationProduct = true;
                    this.showModal = true;
                } else {
                    this.iterationProduct = false;
                    this.showModal = true;
                    this.noProducts = false;
                }
            })
            .catch(error => {
                console.log(error);
            })
    }

    closeModal() {
        this.showModal = false;
        this.opportunityProduct = {};
    }
}