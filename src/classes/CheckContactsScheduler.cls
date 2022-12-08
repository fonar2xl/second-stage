public class CheckContactsScheduler implements Schedulable {
    public void execute(SchedulableContext ctx) {
        CheckContactsBatch batch = new CheckContactsBatch();
        Database.executeBatch(batch);
    }
}