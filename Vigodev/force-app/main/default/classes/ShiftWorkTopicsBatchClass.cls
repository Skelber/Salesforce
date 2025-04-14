public with sharing class ShiftWorkTopicsBatchClass implements Database.Batchable<ShiftWorkTopic> {
    private List<ShiftWorkTopic> shiftWorkTopicsToCreate;

    public ShiftWorkTopicsBatchClass(List<ShiftWorkTopic> shiftWorkTopicsToCreate) {
        this.shiftWorkTopicsToCreate = shiftWorkTopicsToCreate;
    }

    public List<ShiftWorkTopic> start(Database.BatchableContext info){
    //    return new ShiftworkTopicsIterator(this.shiftWorkTopicsToCreate);
    return shiftWorkTopicsToCreate;
   }
    public void execute(Database.BatchableContext info, List<ShiftWorkTopic> scope){
       List<ShiftWorkTopic> swtsToCreate = new List<ShiftWorkTopic>();
       for(ShiftWorkTopic swt : scope){
           swtsToCreate.add(swt);
       }
    //    system.debug('starting insert swt via batch ' + swtsToCreate.size());
     insert swtsToCreate;
    }
    public void finish(Database.BatchableContext info){
    }
}