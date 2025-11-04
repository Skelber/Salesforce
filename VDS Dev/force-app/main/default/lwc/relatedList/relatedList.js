/**
 * Created by Tom Vanhouche on 10/04/2024.
 */

import { api, LightningElement } from 'lwc';
import filteredBy from '@salesforce/label/c.Filtered_by';
import sortedBy from '@salesforce/label/c.Sorted_By';
import newRecord from '@salesforce/label/c.New';
import items from '@salesforce/label/c.items';
import RelatedListFilter from 'c/relatedListFilter';
import { NavigationMixin } from "lightning/navigation";

export default class RelatedList extends NavigationMixin(LightningElement) {
    @api
    relatedListData = {};
    @api
    maxRowSelection = 0;
    @api
    showNewButton = false;
    @api
    newActionType = 'standard'; // standard opens the standard__objectPage, custom calls a custom event for the parent component to use
    filteredRecords = [];
    labels = {
        filteredBy,
        sortedBy,
        items,
        newRecord
    };
    sortDirection = 'asc';
    sortedBy;

    get objectType() {
        return this.relatedListData.objectType || '';
    }

    get title() {
        return this.relatedListData.title || '';
    }

    get icon() {
        return this.relatedListData.icon || '';
    }

    get columns() {
        return this.relatedListData.columns || [];
    }

    get records() {
        return this.relatedListData.records || [];
    }

    get recordCount() {
        return (this.filteredRecords || []).length;
    }

    get filters() {
        return this.relatedListData.filters || [];
    }

    get activeFilters() {
        return this.filters.filter((f) => f.selectedValues.length);
    }

    get activeFiltersLabel() {
        return this.activeFilters.map((f) => f.label).join(', ');
    }

    get hasFilters() {
        return this.filters.length;
    }

    get sortedByLabel() {
        return this.sortColumn ? this.sortColumn.label : '';
    }

    get sortColumn() {
        return this.columns.find((c) => {
            return c.fieldName === this.sortedBy;
        });
    }

    get hideCheckboxColumn() {
        return this.maxRowSelection === 0;
    }

    handleRowSelection(event) {
        const selectedIds = event.detail.selectedRows.map(row => {
            return row.Id;
        });
        console.log(selectedIds);
        const customEvent = new CustomEvent('rowselectionchange', {
            detail: selectedIds
        });
        this.dispatchEvent(customEvent);
    }

    newRecord() {
        if (this.newActionType === 'standard') {
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName : this.objectType,
                    actionName: 'new'
                },
            });
            return;
        }

        // custom listener for the parent component
        const customEvent = new CustomEvent('newclick', {});
        this.dispatchEvent(customEvent);
    }

    connectedCallback() {
        this.filteredRecords = this.records.filter((record) => {
            return this.filterRecord(record);
        });

        this.sortedBy = this.relatedListData.sortedBy || '';
        this.sortDirection = this.relatedListData.sortDirection || 'asc';
    }

    async openFilterModal() {
        const result = await RelatedListFilter.open({
            size: 'small',
            filters: this.filters,
            objectLabel: this.title
        });
        if (result) {
            const filters = JSON.parse(result);
            const tempRelatedList = JSON.parse(
                JSON.stringify(this.relatedListData)
            );
            tempRelatedList.filters = filters;
            this.relatedListData = tempRelatedList;

            // filter the records
            this.filteredRecords = this.records.filter((record) => {
                return this.filterRecord(record);
            });
        }
    }

    filterRecord(record) {
        let matches = true;

        for (const filter of this.activeFilters) {
            const selectedValues = filter.selectedValues;
            const fieldValue = record[filter.fieldName];

            if (Array.isArray(fieldValue)) {
                // multi select
                matches = false;
                selectedValues.forEach((selectedValue) => {
                    if (fieldValue.includes(selectedValue)) {
                        matches = true;
                    }
                });
            } else if (!selectedValues.includes(fieldValue)) {
                // single-select, Id
                matches = false;
            }

            if (!matches) {
                break;
            }
        }

        return matches;
    }

    sortRecords(event) {
        const { fieldName, sortDirection } = event.detail;
        this.sortedBy = fieldName;
        this.sortDirection = sortDirection;

        const defaultValue = this.sortColumn.type === 'number' ? 0 : '';
        const recordsToSort = [...this.filteredRecords];
        recordsToSort.sort((a, b) => {
            const valueA = a[fieldName] || defaultValue;
            const valueB = b[fieldName] || defaultValue;

            if (valueA < valueB) {
                return sortDirection === 'asc' ? -1 : 1;
            }

            if (valueA > valueB) {
                return sortDirection === 'asc' ? 1 : -1;
            }

            return 0;
        });
        this.filteredRecords = recordsToSort;
    }
}