/**
* @author Sebastian Munoz
* @createdDate 04/06/2010
*/
public with sharing class ShowPicture{

	public 	Attachment 	file 		{ set; get; }
	public 	Boolean 	hasPicture 	{ set; get; }
	private String		parentId 	{ set; get; }
	
	/**
	* Constructor
	*/
   	public ShowPicture( ApexPages.StandardController stdController ){
		
       	this.parentId 		= String.escapeSingleQuotes(stdController.getId());
       	this.hasPicture 	= false;

		/* ateppo edited 5/13/2020 */
		List<Attachment> attList = new List<Attachment>();
		if (Schema.sObjectType.Attachment.fields.Id.isAccessible() 
            && Schema.sObjectType.Attachment.fields.ParentId.isAccessible()
            && Schema.sObjectType.Attachment.fields.Name.isAccessible()
            && Schema.sObjectType.Attachment.fields.ContentType.isAccessible()
            && Schema.sObjectType.Attachment.fields.BodyLength.isAccessible()) {       	
       		attList = [ Select ParentId, Name, Id, ContentType, BodyLength 
										From Attachment 
										where ParentId =: this.parentId and name = 'Contact Picture' limit 1];
		} else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
        } /* */
		
       	if( attList.size() > 0 ){
       		this.file 		= attList.get( 0 );
       		this.file.Body 	= Blob.valueOf('AuxString');
       		this.hasPicture = true;
       	}
   	}
	
}