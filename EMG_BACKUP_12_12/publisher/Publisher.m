classdef Publisher<handle
  %  MATLAB class wrapper to the ZMQ publisher
  %   A publisher is an object that opens a socket on a given address, that
  %   can be used to broadcast messages associated with a specific topic.
  %   Messages are published independently from the existance of any 
  %   subscriber listening for them.
  %
  %   When a Publisher is constructed an handle to the underlying object is
  %   returned, together with a flag indicating the successful creation of
  %   the Publisher object. 
  %
  % Publisher methods:
  %   Publisher    - Initialize the publisher istance binding the given adress
  %   publish      - Publish a message with a specific topic
  %   getAddress   - Get the address at which the publisher is registered
  %   delete       - Delete the object, unbinding the socket and freeing all
  %                  the resources.
  %
  %   Example:
  %
  %       % Create a publisher and bind it to the address 127.0.0.1 
  %       % (loopback interface), at the port 5000, using the tcp protocol
  %       address = 'tcp://127.0.0.1:5000';
  %       [pub,valid] = Publisher(address);
  %
  %       % Check if the publisher was correctly setted up
  %       if not(valid)
  %          errormsg('Publisher not initialized correctly');
  %       end
  %
  %       % Publish the string "World" with topic "Hello" on the opened socket
  %       topic = 'Hello';
  %       msg   = 'World';
  %       isDone  = pub.publish(topic, msg)
  %       if not(isDone)
  %          errormsg('Error while publishing');
  %       end
  %
  %       % Destroy the class istance and free the resources
  %       clear pub
  
  properties (SetAccess = private, Hidden = true)
    objectHandle; % Handle to the underlying C++ class instance
  end
      
  methods
    function [this,valid] = Publisher(address)
      [valid,this.objectHandle] = mexPublisher('new', address);
    end
    
    function delete(this)
      mexPublisher('delete', this.objectHandle );
    end
    
    function address = getAddress(this)
      address = mexPublisher('getAddress', this.objectHandle );
    end
    
    function [bool] = publish(this, topic, string)
      bool = mexPublisher('publish', this.objectHandle, topic, string);
    end
  end
  
end

