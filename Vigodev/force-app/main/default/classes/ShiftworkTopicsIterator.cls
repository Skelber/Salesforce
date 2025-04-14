public  class ShiftworkTopicsIterator implements Iterator<ShiftWorkTopic> {
 private List<ShiftWorktopic> shiftWorkTopics;
   private Integer currentIndex;
 
   public ShiftworkTopicsIterator(List<ShiftWorktopic> shiftWorkTopics){
       this.shiftWorkTopics = shiftWorkTopics;
       this.currentIndex = 0;
   }
 
   public Boolean hasNext(){ 
       return currentIndex < shiftWorkTopics.size();
   }    
 
   public ShiftWorktopic next(){
       if(hasNext()) {
           return shiftWorkTopics[currentIndex++];
       } else {
           throw new NoSuchElementException('Iterator has no more elements.');
       }
   } 
}