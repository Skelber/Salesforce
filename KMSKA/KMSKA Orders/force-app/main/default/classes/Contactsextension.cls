/**
* @author Matias Menafra
* @createdDate 03/08/2010
*/
public with sharing class Contactsextension{

    private final Integer MAX_SIZE          = 131072; // 128Kb
    private final Integer MAX_LENGTH_NAME   = 71;
    private final String  ERROR_NO_SAVE     = 'Please select a file to upload and try again.';
    private final String  ERROR_IMG_TYPE    = 'The image must be .jpg, .gif or .png';  
    private final String  PIC_FILE_NAME 	= 'Contact Picture';

    
    private Set<String> imagesTypes         = new Set<String> {'image/jpeg', 'image/pjpeg', 'image/png', 'image/x-png', 'image/gif'};
    private Set<String> notAllowedTypes     = new Set<String> {'application/octet-stream'};
    
    public Attachment   newAttach           { set; get; }
    public Attachment   file                { set; get; }
    private String      parentId            { set; get; }
    public String       postAction          { set; get; }
    public String       error               { set; get; }
    public Boolean      hasPicture          { set; get; }
    
    /**
    * Constructor
    */ 
    public Contactsextension( ApexPages.StandardController stdController ){
        
        this.parentId       = String.escapeSingleQuotes(stdController.getId());
        this.hasPicture     = false;
        this.newAttach      = new Attachment();
        this.error          = '';
        
        /* ateppo edited 5/13/2020 */
        List<Attachment> attList = new List<Attachment>();
        if (Schema.sObjectType.Attachment.fields.Id.isAccessible() 
            && Schema.sObjectType.Attachment.fields.ParentId.isAccessible()
            && Schema.sObjectType.Attachment.fields.Name.isAccessible()
            && Schema.sObjectType.Attachment.fields.ContentType.isAccessible()
            && Schema.sObjectType.Attachment.fields.BodyLength.isAccessible()) {
            attList = [ Select ParentId, Name, Id, ContentType, BodyLength From Attachment where ParentId =: this.parentId and name = 'Contact Picture' limit 1];
            if( attList.size() > 0 ){
                this.file               = attList.get( 0 );
                this.hasPicture         = true;
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
        } /* */
    }
    
    /**
    * Upload action, store the file or replace if exists
    * @return thePage
    */
    public PageReference uploadAction(){
        
        PageReference thePage = new PageReference( '/'+ parentId );
        thePage.setRedirect( true );
        if( this.validate() ){
            return ( this.saveCurrentPicture() ) ? thePage : null;
        }
        else{
        	this.newAttach = new Attachment();
            return null;
        }
    }
    
    
    /**
    * Save the New Attachment as Contact Picture
    * @return : boolean
    */
    public Boolean saveCurrentPicture(){
	    Savepoint sp = Database.setSavepoint();
	    try{
            /* ateppo edited 5/13/2020 */
            if (!Attachment.sObjectType.getDescribe().isDeletable() || !Attachment.sObjectType.getDescribe().isCreateable()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
                return false;
            }
            else {
                delete [ Select Id From Attachment where ParentId =: this.parentId and name = 'Contact Picture' limit 1 ];
                this.newAttach.parentId = this.parentId;
                this.newAttach.name = 'Contact Picture';
                insert this.newAttach;
                return true;
            } /* */
	    	
	    } 
	    catch( Exception e ){
	    	this.error += ERROR_NO_SAVE+'<br/>';
	    	Database.rollback( sp );
	    	return false;
	    }
    }
    
    
    /**
    * Detele action, delete the curren image
    * @return thePage
    */
    public PageReference deleteAction(){
        PageReference thePage = new PageReference( '/'+ parentId );
        thePage.setRedirect( true );
        /* ateppo edited 5/13/2020 */
        if (Attachment.sObjectType.getDescribe().isDeletable()) {   
            delete this.file;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
        } /* */
        return thePage;
    }
    
    /**
    * Run all verification for the file to upload
    * @return ret
    */
    private Boolean validate(){
        Boolean ret = true;
        this.error = '';
        if( !imagesTypes.contains( newAttach.ContentType ) ){
            this.error += ERROR_IMG_TYPE+'<br/>';
            ret = false;
        }
        return ret;
    }
    
    /**
    * Cancel action
    * @return thePage a page reference
    */
    public PageReference cancel(){
        PageReference thePage = new PageReference( '/'+ parentId );
        thePage.setRedirect( true );
        return thePage;
    }
    

  
}