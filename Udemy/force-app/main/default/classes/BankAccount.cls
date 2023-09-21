public class BankAccount {
	public Decimal accountBalance = 0;
    
    public static Decimal totalAccountBalance = 0;
    
    public void deposit(Decimal depositValue) {
        accountBalance += depositValue;
        totalAccountBalance += depositValue;
    }
    
    public void withdrawal(Decimal withdrawalValue) {
        accountBalance -= withdrawalValue;
        totalAccountBalance -= withdrawalValue;
    }
    
    public Decimal getAccountBalance(){
        return accountBalance;
    }
    
    public static Decimal getTotalAccountBalance() {
        return totalAccountBalance;
    }
}