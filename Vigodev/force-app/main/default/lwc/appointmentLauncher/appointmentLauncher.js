import { LightningElement } from 'lwc';
import LightningModal from 'lightning/modal';
import Scheduler from 'c/appointmentScheduler';
import Launcher from 'c/appointmentModal'

export default class AppointmentLauncher extends LightningElement {

openScheduler(){
    console.log('test launcher')
        const result = Launcher.open({
            size: 'medium',
            description: 'Accessible description of modal\'s purpose',
        });
        console.log(result);
    }
}