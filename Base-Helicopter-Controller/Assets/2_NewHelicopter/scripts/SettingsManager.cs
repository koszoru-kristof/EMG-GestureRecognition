using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.UI;


public class SettingsManager : MonoBehaviour
{
    public Toggle useZMQToggle;
    public Toggle showJoystickToggle;

    [SerializeField] private bool isUsed;


    public GameSettings gameSettings;
    public NewHelicopter.HelicopterController helicontrol;

    [SerializeField] private GameObject JoystickUI;
    [SerializeField] private GameObject OptionsPanelUI;


    private void Update()
    {
     

        if (isUsed)
        {
            startOptionsUI();
        }
        else
        {
            exitOptionsUI();
        }


    }

    void OnEnable()
    {
        gameSettings = new GameSettings();


        useZMQToggle.onValueChanged.AddListener(delegate { onUseZMQToggle(); });
        showJoystickToggle.onValueChanged.AddListener(delegate { onShowJoystickToggle(); });

        LoadSettings();


    }

    public void onUseZMQToggle()
    {
        gameSettings.useZMQ = useZMQToggle.isOn;
        helicontrol.SetIsZMQused(gameSettings.useZMQ);

        SaveSettings();
    }

    public void onShowJoystickToggle()
    {
        gameSettings.showJoystick = showJoystickToggle.isOn;
        JoystickUI.SetActive(gameSettings.showJoystick);

        SaveSettings();

    }

    public void SaveSettings()
    {
        string JSONdata = JsonUtility.ToJson(gameSettings, true);
        File.WriteAllText(Application.persistentDataPath + "/gamesettings.json", JSONdata);
    }

    public void LoadSettings()
    {
        gameSettings = JsonUtility.FromJson<GameSettings>(File.ReadAllText(Application.persistentDataPath + "/gamesettings.json" ));

        useZMQToggle.isOn = gameSettings.useZMQ;
        showJoystickToggle.isOn = gameSettings.showJoystick;

        onShowJoystickToggle();
        onUseZMQToggle();

    }

    public void startOptionsUI()
    {
        OptionsPanelUI.SetActive(true);
        isUsed = true;

    }

    public void exitOptionsUI()
    {
        OptionsPanelUI.SetActive(false);
        isUsed = false;

    }

}
