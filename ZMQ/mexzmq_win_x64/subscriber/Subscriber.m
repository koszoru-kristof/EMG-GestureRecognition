classdef Subscriber<handle
  %  MATLAB class wrapper to the ZMQ subscriber
  %   A subscriber is an object that listens to a socket on a given address, 
  %   that can be used to receive messages associated with a specific topic.
  %
  %   When a Subscriber is constructed an handle to the underlying object is
  %   returned, together with a flag indicating the successful creation of
  %   the Subscriber object. 
  %
  % Subscriber methods:
  %   Subscriber   - Initialize the subscriber istance binding the given
  %                  adress, and listening for messages tagged with the 
  %                  given topic
  %   start        - Start the background thread listening for new
  %                  messages. Only the most recent one is stored.
  %   stop         - Stop the background thread.
  %   isAlive      - Return whether the background thread is currently running  
  %   getData      - Return a flag indicating whether there is a new message
  %                  to be read, and its content
  %   getAddress   - Get the address at which the subscriber is registered
  %   getTopic     - Get the currently subscribed topic
  %   delete       - Delete the object, unbinding the socket and freeing all
  %                  the resources.
  %
  %   Example:
  %
  %       % Create a subscriber and bind it to the address 127.0.0.1 
  %       % (loopback interface), at the port 5000, using the tcp protocol,
  %       % and subscribing to the "Hello" topic
  %       address = 'tcp://127.0.0.1:5000';
  %       topic = 'Hello';
  %       [sub,valid] = Subscriber('tcp://127.0.0.1:5000', 'Hello');
  %
  %       % Check if the subscriber was correctly setted up
  %       if not(valid)
  %          errormsg('Subscriber not initialized correctly');
  %       end
  %
  %       % Start the listening thread
  %       ok = sub.start();
  %       if not(ok)
  %         errormsg('Error while starting subscriber');
  %       end
  %       
  %       % Receive a new message
  %       newData = false;
  %       while not(newData)
  %         [newData, data]  = sub.getData();
  %       end
  %      
  %       % Print the received message
  %       fprintf('%s\n', data);
  %
  %       % Destroy the class istance and free the resources
  %       clear sub
  
  properties (SetAccess = private, Hidden = true)
    objectHandle; % Handle to the underlying C++ class instance
  end
    
  methods
    function [this,valid] = Subscriber(address, topic)
      [valid,this.objectHandle] = mexSubscriber('new', address, topic);
    end
        
    function bool = start(this)
      bool = mexSubscriber('start', this.objectHandle);
    end
        
    function bool = stop(this)
      bool = mexSubscriber('stop', this.objectHandle);
    end
    
    function [newData, data] = getData(this)
      [newData, data] = mexSubscriber('getData', this.objectHandle);  
    end
    
    function bool = isAlive(this)
      bool = mexSubscriber('isAlive', this.objectHandle);              
    end
    
    function address = getAddress(this)
      address = mexSubscriber('getAddress', this.objectHandle);
    end
    
    function address = getTopic(this)
      address = mexSubscriber('getAddress', this.objectHandle);
    end
     
    function delete(this)
      mexSubscriber('delete', this.objectHandle);
    end
    
  end
        
end

