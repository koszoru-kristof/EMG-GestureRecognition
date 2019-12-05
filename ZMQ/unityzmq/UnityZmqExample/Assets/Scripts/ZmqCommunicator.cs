using UnityEngine;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using NetMQ;
using NetMQ.Sockets;
using UnityEngine.UI;
using System.Collections;

public enum ZmqCommunicatorType
{
    PUB, SUB
}

public class ZmqCommunicator : MonoBehaviour {

    private ZmqCommunicatorType _type;
    private SubscriberSocket _subSocket;
    private PublisherSocket _pubSocket;

    private string _ip;
    private Msg _receivedMsg = new Msg();
    private Coroutine _coroutine;

    static int INSTANCES = 0;
    
    private void OnDestroy()
    {
        Stop();

        INSTANCES--;

        if (INSTANCES == 0)
        {
            Debug.Log("NetMQConfig.Cleanup()");
            NetMQConfig.Cleanup(true);
        }
    }
    
    private void Start()
    {
        INSTANCES++;
    }

    public void StartPublisher(string ip)
    {
        _type = ZmqCommunicatorType.PUB;
        _ip = ip;

        if (_subSocket != null | _pubSocket != null)
        {
            Debug.LogWarning("ZmqCommunicator already started.");
            return;
        }

        try
        {
            AsyncIO.ForceDotNet.Force();
            _pubSocket = new PublisherSocket();
            _pubSocket.Bind(_ip);
            Debug.Log("ZmqCommunicator Publisher Binded to: " + _ip);
        }
        catch (Exception ex)
        {
            Debug.LogWarning("Got exception when try to start " + _ip + " : " + ex);
        }
        return;

    }

    public void StartSubscriber(string ip, float updateTime, Action<byte[]> action)
    {
        _type = ZmqCommunicatorType.SUB;
        _ip = ip;

        if (_subSocket != null | _pubSocket != null)
        {
            Debug.LogWarning("ZmqCommunicator already started.");
            return;
        }

        try
        {
            AsyncIO.ForceDotNet.Force();
            _subSocket = new SubscriberSocket();
            _subSocket.Options.ReceiveHighWatermark = 100;
            _subSocket.Options.Linger = TimeSpan.Zero;
            _subSocket.SubscribeToAnyTopic();
            _subSocket.Connect(_ip);
            Debug.Log("ZmqCommunicator Subscriber Connected to: " + _ip);
        }
        catch (Exception ex)
        {
            Debug.LogWarning("Got exception when try to start " + _ip + " : " + ex);
        }

        _receivedMsg = new Msg();
        _receivedMsg.InitEmpty();
        _coroutine = StartCoroutine(Worker(updateTime, action));

        return;
    }
       
    public void Stop()
    {
        if (_subSocket != null)
        {
            try
            {
                if (_coroutine != null) StopCoroutine(_coroutine);
                _subSocket.Unsubscribe("");
                _subSocket.Disconnect(_ip);
                _subSocket.Close();
                _subSocket.Dispose();
                _subSocket = null;
                Debug.Log("ZmqCommunicator Subscriber Disconnected from: " + _ip);
            }
            catch (Exception ex)
            {
                Debug.LogWarning("Got exception when try to stop " + _ip + " : " + ex);
            }
        }


        if (_pubSocket != null)
        {
            try
            {
                _pubSocket.Unbind(_ip);
                _pubSocket.Close();
                _pubSocket.Dispose();
                _pubSocket = null;
                Debug.Log("ZmqCommunicator Publisher Unbinded from: " + _ip);
            }
            catch (Exception ex)
            {
                Debug.LogWarning("Got exception when try to stop " + _ip + " : " + ex);
            }
        }  




    }
    
    public bool TryGetLastMessage(ref byte[] msg)
    {
        if (_type != ZmqCommunicatorType.SUB)
        {
            Debug.LogWarning("Wrong Type of ZmqCommunicator.");
            msg = null;
            return false;
        }

        if (_subSocket == null)
        {
            Debug.LogWarning("Subscriber not started.");
            msg = null;
            return false;
        }

        bool retVal = false;
        while (_subSocket.TryReceive(ref _receivedMsg, new TimeSpan(0, 0, 0)))
        {
            msg = _receivedMsg.Data;
            retVal = true;
        }
        
        return retVal;            
    }

    public bool Write(byte[] message)
    {
        if (_type != ZmqCommunicatorType.PUB)
        {
            Debug.LogWarning("Wrong Type of ZmqCommunicator.");
            return false;
        }

        if (_pubSocket == null)
        {
            Debug.LogWarning("Publisher not started.");
            return false;
        }
        
        _pubSocket.SendFrame(message);
        return true;
    }
    
    IEnumerator Worker(float waitTime, Action<byte[]> action)
    {
        byte[] incomingMessage = new byte[1];
        for (; ; )
        {
            // *********** read the message ***********
            if (TryGetLastMessage(ref incomingMessage))
                action(incomingMessage);


            // *********** wait ***********************
            if (waitTime > 0)
                yield return new WaitForSeconds(waitTime);
            else
                yield return null;

        }
    }
    
}
