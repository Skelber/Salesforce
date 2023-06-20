import { LightningElement, api } from 'lwc';

export default class RichTextCounter extends LightningElement {
    @api maxCharacters;
    maxCharacters = 4000;
    richTextValue = '';
    characterCount = 0;
    characterCountExceeded = false;

     get characterCountStyle() {
        return this.characterCountExceeded ? 'color: red;' : '';
    }

    handleRichTextChange(event) {
        this.richTextValue = event.detail.value;
        this.characterCount = this.richTextValue.length;
        this.characterCountExceeded = this.characterCount > this.maxCharacters;
    }
}
