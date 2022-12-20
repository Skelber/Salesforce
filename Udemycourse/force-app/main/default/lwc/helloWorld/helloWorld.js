import { LightningElement, track } from 'lwc';

export default class HelloWorld extends LightningElement {

    // properties
    fullname="Zero to hero"
    title="aura"

    changeHandler(event){
        this.title = event.target.value
    }

    @track address={
        city:"Antwerpen",
        postcode:2000,
        country:"Belgium"
    }

    trackHandler(event){
        this.address.city = event.target.value
    }

    //getter example

    users = ["John", "Smith", "Nick"]
    num1 = 10
    num2 = 20

    get firstUser() {
        return this.users[0]
    }

    get multiply() {
        return this.num1 * this.num2
    }
}