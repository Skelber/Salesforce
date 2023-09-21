public class MyTasks {
	private Integer tasksCompleted = 0;
    
    private static Integer totalTasksCompleted = 0;
    
    public void doTask() {
        tasksCompleted++;
        totalTasksCompleted++;
    }
    
    public Integer getTasksCompleted(){
        return tasksCompleted;
    }
    
    public static Integer getTotalTasksCompleted(){
        return totalTasksCompleted;
    }
}