public class SharePointAllItemWrapper {
    
    public cls_value[] value;
    public class cls_value {
        public String createdDateTime;
        public String eTag;
        public String id;
        public String lastModifiedDateTime;	
        public String webUrl;
        public cls_createdBy createdBy;
        public cls_lastModifiedBy lastModifiedBy;
        public cls_parentReference parentReference;
        public cls_contentType contentType;
        public cls_fields fields;
    }
    public class cls_createdBy {
        public cls_user user;
    }
    public class cls_user {
        public String email;
        public String id;
        public String displayName;
    }
    public class cls_lastModifiedBy {
        public cls_user user;
    }
    public class cls_parentReference {
        public String id;
        public String siteId;
    }
    public class cls_contentType {
        public String id;
        public String name;
        
    }
    
    public class cls_fields{
        public String id;
        public String ContentType;
        public String LinkFilename;
    }
    
    public static SharePointAllItemWrapper parse(String json){
        return (SharePointAllItemWrapper) System.JSON.deserialize(json, SharePointAllItemWrapper.class);
    }
}