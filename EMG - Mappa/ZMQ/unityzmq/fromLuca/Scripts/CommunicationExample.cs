using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class CommunicationWithMaster : MonoBehaviour {

    public static CommunicationWithMaster Instance;
    GameManager manager;

    public ZmqCommunicator statusSub;
    public ZmqCommunicator statusPub;

    MiroZmq.ZmqStatus masterStatus = new MiroZmq.ZmqStatus();

   

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

        statusSub = gameObject.AddComponent<ZmqCommunicator>();

        statusPub = gameObject.AddComponent<ZmqCommunicator>();

    }

    private void OnEnable()
    {
        manager = GameManager.Instance;

        statusSub.StartSubscriber(manager.gameData.zmqStrStatusSub, manager.gameData.zmqTimeStatusSub, ReadMessage);

        statusPub.StartPublisher(manager.gameData.zmqStrStatusPub);
    }

    // Update is called once per frame
    void Update () {
		
	}

    private void OnDisable()
    {
        statusSub.Stop();
        statusPub.Stop();
    }



    public bool Send(MiroZmq.NavigationStatus status, int param)
    {
        MiroZmq.ZmqStatus pkg;
        pkg.status = status;
        pkg.param = param;
        return Send(pkg);
    }

    public bool Send(MiroZmq.ZmqStatus pkg)
    {
        Debug.Log("Asked to change state to: " + (int)pkg.status + " with param= " + pkg.param);
        return statusPub.Write(pkg.Serialize());
    }

    void ReadMessage(byte[] msg)
    {
        // deserialize message
        if (masterStatus.Deserialize(ref msg))
        {
            manager.brakesDisabled = false;
            //manager.motorPowerDisabled = false;

            switch (masterStatus.status)
            {
                case MiroZmq.NavigationStatus.Error:

                    manager.brakesDisabled = (masterStatus.param & (int)2) != 0;
                    //manager.motorPowerDisabled = (masterStatus.param & (int)4) != 0;

                    if (SceneManager.GetActiveScene().name != "sceneIdle")
                    {
                        Debug.Log("Master want to go to " + "sceneIdle");
                        manager.FadeScene("sceneIdle");
                    }
                    break;

                case MiroZmq.NavigationStatus.Idle:
                    if (SceneManager.GetActiveScene().name != "sceneIdle")
                    {
                        Debug.Log("Master want to go to " + "sceneIdle");
                        manager.FadeScene("sceneIdle");
                    }
                    break;

                case MiroZmq.NavigationStatus.Manual:
                    if (SceneManager.GetActiveScene().name != "sceneManualNavigation")
                    {
                        Debug.Log("Master want to go to " + "sceneManualNavigation");
                        manager.FadeScene("sceneManualNavigation");
                    }
                    break;

                case MiroZmq.NavigationStatus.SemiAuto:
                    if (SceneManager.GetActiveScene().name != "sceneAutonomousNavigation")
                    {
                        Debug.Log("Master want to go to " + "sceneAutonomousNavigation");
                        manager.FadeScene("sceneAutonomousNavigation");
                    }
                    break;

                case MiroZmq.NavigationStatus.Sleep:
                    Debug.Log("Master want to go to " + "QUIT");
                    Application.Quit();
                    break;

                case MiroZmq.NavigationStatus.Tilt:
                    if (SceneManager.GetActiveScene().name != "sceneTilt")
                    {
                        Debug.Log("Master want to go to " + "sceneTilt");
                        manager.FadeScene("sceneTilt");
                    }
                    break;
            }
        }
    }
}
