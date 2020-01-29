using UnityEngine;
using System.Collections;
using System.Linq;
using System.Security.Policy;
using UnityEngine.UI;

public class CheckpointController : MonoBehaviour
{
    public Checkpoint[] CheckpointsList;
    public LookAtTargetController Arrow;

    public Text scoreText;
    private int win;
    public Text winText;

    private Checkpoint CurrentCheckpoint;
    private int CheckpointId;

	// Use this for initialization
	void Start ()
	{
        if (CheckpointsList.Length==0) return;

        CheckpointId = 0;
        scoreText.text = "Score " + CheckpointId.ToString();

        winText.enabled = false;

        for (int index = 0; index < CheckpointsList.Length; index++)
            CheckpointsList[index].gameObject.SetActive(false);


        SetCurrentCheckpoint(CheckpointsList[CheckpointId]);
	}

    private void SetCurrentCheckpoint(Checkpoint checkpoint)
    {
        if (CurrentCheckpoint != null)
        {
            CurrentCheckpoint.gameObject.SetActive(false);
            CurrentCheckpoint.CheckpointActivated -= CheckpointActivated;
        }

        CurrentCheckpoint = checkpoint;
        CurrentCheckpoint.CheckpointActivated += CheckpointActivated;
        Arrow.Target = CurrentCheckpoint.transform;
        CurrentCheckpoint.gameObject.SetActive(true);
    }

    private void CheckpointActivated()
    {
        CheckpointId++;
        scoreText.text = "Score: " + CheckpointId.ToString();

        if (CheckpointId == 7 )
        {
            winText.text = "You won!!";
            winText.enabled = true;
        }

        if (CheckpointId >= CheckpointsList.Length)
        {
            CurrentCheckpoint.gameObject.SetActive(false);
            CurrentCheckpoint.CheckpointActivated -= CheckpointActivated;
            Arrow.gameObject.SetActive(false);
            return;
        }

        SetCurrentCheckpoint(CheckpointsList[CheckpointId]);
    }

    // Update is called once per frame
	void Update () {
	
	}
}
