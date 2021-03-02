using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class ZmqSubscriberExample : MonoBehaviour {

    public static ZmqSubscriberExample Instance;

    ZmqCommunicator zmqSub;


    public string ip; // tcp://127.0.0.1:5000

    public float updateInterval;   


    void Awake () {

        if (Instance == null)
        {
            Instance = this;
        }
        else if (Instance != this)
        {
            Destroy(gameObject);
            return;
        }               

        zmqSub = gameObject.AddComponent<ZmqCommunicator>();

    }

    private void OnEnable()
    {
        zmqSub.StartSubscriber(ip, updateInterval, ReadMessage);
    }

    // Update is called once per frame
    void Update () {
		
	}

    private void OnDisable()
    {
        zmqSub.Stop();
    }

    void ReadMessage(byte[] bytes)
    {
        string msg = System.Text.Encoding.ASCII.GetString(bytes);
        Debug.Log("Received: " + msg);



        
    }
}
