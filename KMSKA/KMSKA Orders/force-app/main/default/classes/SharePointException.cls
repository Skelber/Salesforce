public class SharePointException extends Exception {
    boolean escape ;
    String errMsg ; 
    public SharePointException(String errMsg, boolean escape){
        this.errMsg = errMsg;
        this.escape = escape;
    }
    
    public void addError(String errMsg, boolean escape){
        
    }
    
}