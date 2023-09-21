public class MyClass {
	private String firstName;
    
    public void sayHello(){
        System.debug('hello ' + firstName);
    }
    
    public void setFirstName(String name) {
        firstName = name;
    }
}