@IsTest
public with sharing class ShowPictureTest {
    public static testMethod void noPicture(){
		
	    Test.startTest();
	    
	    TestUtilities tu = TestUtilities.generateTest();
	    
		ApexPages.StandardController sc = new ApexPages.StandardController( tu.aContac );
        ShowPicture cTest = new ShowPicture( sc );	   
        System.assert( cTest.file == null, 'ERROR: should not an image  ' );	   
	    Test.stopTest();
	}
	
	/**
	* Test method: Environment: a picture was uploaded then replace this with other.
	*/
	public static testMethod void noPictureAndUploadOne(){
		
	    TestUtilities tu = TestUtilities.generateTest();
	    
	    Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController( tu.aContac );

		tu.aAttachment.ParentId = sc.getid();
		tu.aAttachment.name = 'Contact Picture';
		insert tu.aAttachment;

        ShowPicture cTest = new ShowPicture( sc );	   
        System.assert( cTest.file != null, 'Error no file attached' );	   
        System.assert( tu.aAttachment.ParentId == cTest.file.ParentId, 'Error ParentId must be: ' + tu.aAttachment.ParentId );	   
        System.assert( tu.aAttachment.name == cTest.file.name, 'Error name must be: ' + tu.aAttachment.name );
	    Test.stopTest();
	}

	public static testMethod void pictureAndUploadOther(){
		
	    TestUtilities tu = TestUtilities.generateTest();
	    
	    Test.startTest();
		ApexPages.StandardController sc = new ApexPages.StandardController( tu.aContac );

		tu.aAttachment.ParentId = sc.getid();
		tu.aAttachment.name = 'Contact Picture';
		insert tu.aAttachment;
        
        //Replace
        tu.aAttachment.Body = Blob.valueOf('String Othe value');
        update tu.aAttachment;
        ShowPicture cTest = new ShowPicture( sc );
          
        System.assert( tu.aAttachment.ParentId == cTest.file.ParentId, 'Error ParentId must be: ' + tu.aAttachment.ParentId );	   
        System.assert( tu.aAttachment.name == cTest.file.name, 'Error name must be: ' + tu.aAttachment.name );
	    Test.stopTest();
	}
}