import { LightningElement, api, track } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import FullCalendarJS from '@salesforce/resourceUrl/Fullcalendar';
import getData from '@salesforce/apex/AppointmentSchedulerController.getData';
import ConfirmationModal from 'c/confirmationModal';



export default class Calendar extends LightningElement {
    @track _events;

    @api
    get events(){
        return this._events
    }
    set events(value){
        this._events=[...value];
    }

    @api
    get eventDataString(){
        return this.events
    }

    set eventDataString(value){
        try 
        {
            this.events=eval(value)
        }
        catch {
            this.events=[]
        }
    }
    @api resourceName;
    @api accountName;
    @api locationName
    @api currentDate;
    @api resourceId;
    @api businessUnit;
    @api productGroup;
    @api productSubGroup;
    @api appointmentType;
    calendar;
    calendarTitle;
    objectApiName = 'Account';
    viewOptions = [
        {
            label: 'Week',
            viewName: 'timeGridWeek',
            duration: {weeks: 1},
            slotDuration: {days: 1},
            checked: false
        }, 
      
    ];

    changeViewHandler(event) {
        const viewName = event.detail.value;
        if(viewName != 'listView') {
            this.calendar.changeView(viewName);
            const viewOptions = [...this.viewOptions];
            for(let viewOption of viewOptions) {
                viewOption.checked = false;
                if(viewOption.viewName === viewName) {
                    viewOption.checked = true;
                }
            }
            this.viewOptions = viewOptions;
            this.calendarTitle = this.calendar.view.title;
        } else {
            this.handleListViewNavigation(this.objectApiName);
        }
    }


    calendarActionsHandler(event) {
    const actionName = event.target.value;
    if(actionName === 'previous') {
        this.calendar.prev();
    } else if(actionName === 'next') {
        this.calendar.next();
    } else if(actionName === 'today') {
        this.calendar.today();
    } 
    // changes the calendar title when switching to different months or days
    this.calendarTitle = this.calendar.view.title;
}

     connectedCallback() {
        this.disableConfirm = true;
        this.actionName = 'today';
        Promise.all([
            loadStyle(this, FullCalendarJS + '/lib/main.css'),
            loadScript(this, FullCalendarJS + '/lib/main.js')
        ])
        .then(() => {
            var eventList = [];
            this.events.forEach(element => {
                const event = {
                    id: element.id,
                    editable: false, 
                    allDay : false,
                    start: element.start,
                    end: element.end,
                    // title: element.title
                }
                eventList.push(event);
            });
            this.eventsList = eventList;
            this.initializeCalendar();
        })
        .catch(error => console.log(error))
    }

    @api initializeCalendar() { 
        const calendarEl = this.template.querySelector('div.fullcalendar');
        const copyOfOuterThis = this;
        const calendar = new FullCalendar.Calendar(calendarEl, {
              eventClick:(info) => {
                  this.confirmedStart = info.event.start;
                  this.confirmedEnd = info.event.end;
                  this.handleClick();
 
            },
            headerToolbar: false,
            initialDate: this.currentDate,
            showNonCurrentDates: false,
            fixedWeekCount: true,
            allDaySlot: false,
            navLinks: false,  
            weekends: false ,
            locale: 'nl',
            scrollTime: '08:00:00', 
            slotMinTime: '08:00:00',
            slotMaxTime: '21:00:00',
            initialView: 'timeGridWeek',
            slotEventOverlap: false,
            events: copyOfOuterThis.eventsList
        });
        calendar.render();
        calendar.setOption('contentHeight', 450);
        this.calendarTitle = calendar.view.title;
        this.calendar = calendar;
    }

    @api receiveData(eventsFromParent){
        if(eventsFromParent) {
            let eventList = [];
            for(let timeSlot of JSON.parse(JSON.stringify(eventsFromParent))) {
                const event = {
                    id: timeSlot.id,
                    editable: false, 
                    allDay : false,
                    start: timeSlot.startTime,
                    end: timeSlot.endTime,
                    title: this.resourceName
                }
                eventList.push(event);
            }
            this.eventsList = eventList;
        }
    }

    logConfirmedInfo(){
        this.showModal = true;
    }

        async handleClick() {
        const result = await ConfirmationModal.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
            Start: this.confirmedStart,
            End: this.confirmedEnd,
            ServiceResource: this.resourceName,
            accountName: this.accountName,
            locationName: this.locationName,
            resourceId: this.resourceId,
            businessUnit: this.businessUnit,
            productGroup: this.productGroup,
            productSubGroup: this.productSubGroup,
            appointmentType: this.appointmentType
        });
        console.log(result);
    }

}