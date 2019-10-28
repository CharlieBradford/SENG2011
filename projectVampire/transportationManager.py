class transportationManager():
 
    def __init__(self, location):
        self.location = location
 
    # Given blood, send it to its destination 
    def sendBlood(self, blood):
        # Get blood destination from system
 
        # Get routing path for blood from routing
 
        # Give blood to transporter (don't need this)
 
        print('Ready to send blood')
    
    def bloodArrival(self, blood):
        # If blood did not arrive at destination
            # If blood was going to a recipient, need to 
            # make a request for blood of same type to recipient's
            # destination
        # Else 
            # Confirm arrival
            # Dispatch to destination
 
        # If blood is lost from donation to pathology or
            # pathology to storage no need to do anything
        print('Success of blood arrival has been')
 
    def dispatchBlood(self, blood):
        # Blood has successfully arrived at the destination, dispatch it
        # If blood needs to be verified
            # Dispatch to pathologist
        # If blood is to be stored
            # Dispatch to storage manager
        # If blood is to be delivered to recipient 
            # Dipatch blood to recipient     
        print('Blood has been dispatched')

