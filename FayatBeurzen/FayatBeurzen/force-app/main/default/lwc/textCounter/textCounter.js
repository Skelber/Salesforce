import { LightningElement, api } from 'lwc';

export default class RichTextCounter extends LightningElement {
    @api maxCharacters;
    @api richTextValue;
    characterCount = 0;
    characterCountExceeded = false;
    disableRichTextField = false;

     get characterCountStyle() {
        return this.characterCountExceeded ? 'color: red;' : '';
    }
    
    handleRichTextChange(event) {
        this.richTextValue = event.detail.value;
        this.characterCount = this.richTextValue.length;
        this.characterCountExceeded = this.characterCount >= this.maxCharacters;
        
        // Pass the richTextValue to the flow
        this.dispatchEvent(new CustomEvent('flowvaluechanged', {
            detail: {
                value: this.richTextValue
            }
        }));
    }
}
