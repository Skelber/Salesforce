import { LightningElement } from 'lwc';

export default class P2cParentComponent extends LightningElement {
  carouselData = [
    {
        src: "https://www.lightningdesignsystem.com/assets/images/carousel/carousel-01.jpg",
        header: "First Card",
        description: "First description"
    },
    { 
        src: "https://www.lightningdesignsystem.com/assets/images/carousel/carousel-02.jpg",
        header: "Second Card",
        description: "Second description"
    },
    { 
        src: "https://www.lightningdesignsystem.com/assets/images/carousel/carousel-03.jpg",
        header: "Third Card",
        description: "Third description"
    }
    
  ]

  percentage=10
  changeHandler(event){
    this.percentage = event.target.value
  }

  handleClick(){
    this.template.querySelector('c-p2c-slider-component').resetSlider()
  }
}

