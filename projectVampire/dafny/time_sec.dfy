class time_sec{

    var time_0:int;

    static method get_seconds(time_in:int) {
        diff := (time_in - time_0)
        diff
    }

    # Returns the number of full days.
    @staticmethod
    def day_diff(time_1,time_2):
        if (time_1>=time_2):
            diff = time_1-time_2
            days = diff/86400 # 86400 is number of seconds in a day
            return int(days)
}

