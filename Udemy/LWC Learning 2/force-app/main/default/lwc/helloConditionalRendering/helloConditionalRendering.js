import { LightningElement } from 'lwc';

export default class HelloConditionalRendering extends LightningElement {
    isVisible = false
    name
    handleClick(){
        this.isVisible =! this.isVisible
    }

    changeHandler(event){
        this.name = event.target.value
    }

    get helloMethod(){
        return this.name === 'hello'
    }

}