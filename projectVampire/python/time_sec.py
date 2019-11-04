import datetime
class time_sec:

    time_0 = datetime.datetime.utcfromtimestamp(0)

    @staticmethod
    def get_seconds(time_in):
        diff = (time_in - time_0)
        return diff.total_seconds()
    
    @staticmethod
    def get_now():
        return get_seconds(datetime.datetime.now())

    # Returns the number of full days.
    @staticmethod
    def day_diff(time_1,time_2):
        if (time_1>=time_2):
            diff = time_1-time_2
            days = diff/86400 # 86400 is number of seconds in a day
            return int(days)

