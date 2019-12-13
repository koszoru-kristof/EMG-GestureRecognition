using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class ZmqPublisherExample : MonoBehaviour {

    public static ZmqPublisherExample Instance;

    ZmqCommunicator zmqPub;

    
    public string ip; // tcp://127.0.0.1:5000

    public string msg;
    public bool send;


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

        zmqPub = gameObject.AddComponent<ZmqCommunicator>();

    }

    private void OnEnable()
    {        
        zmqPub.StartPublisher(ip);
    }

    // Update is called once per frame
    void Update () {
		
        if (send)
        {
            byte[] bytes = System.Text.Encoding.ASCII.GetBytes(msg);
            bool writeok = zmqPub.Write(bytes);
            if (writeok)
            {
                Debug.Log("Message written!");
            } else
            {
                Debug.Log("Error writing message!");
            }

            send = false;
        }


	}

    private void OnDisable()
    {
        zmqPub.Stop();
    }



}
