using UnityEngine;
using UnityEngine.UI;

namespace NewHelicopter
{
    // USING
    // Input.GetAxis
    //
    public class HelicopterController : MonoBehaviour
    {
        ZmqCommunicator zmqSub;

        public static HelicopterController Instance;

        public Text directionText;
        private string direct;

        public string ip; // tcp://127.0.0.1:5000
        public float updateInterval;

        private string lastAction = "F";

        private string horizontalAxis = "Horizontal";
        private string verticalAxis = "Vertical";
        private string jumpButton = "Jump";

        [Header("Inputs")]
        public bool isVirtualJoystick = false;
        public bool isZMQ_Joystick = false;

        [Header("View")]
        // to helicopter model
        public AudioSource HelicopterSound;
        public Rigidbody HelicopterModel;
        public HeliRotorController MainRotorController;
        public HeliRotorController SubRotorController;
        public DustAirController DustAirController;

        [Header("Fly Settings")]
        public LayerMask GroundMaskLayer = 1;
        public float TurnForce = 3f;
        public float ForwardForce = 10f;
        public float ForwardTiltForce = 20f;
        public float TurnTiltForce = 30f;
        public float EffectiveHeight = 100f;

        public float turnTiltForcePercent = 1.5f;
        public float turnForcePercent = 1.3f;

        private float _engineForce;
        public float EngineForce
        {
            get { return _engineForce; }
            set
            {
                MainRotorController.RotarSpeed = value * 80;
                SubRotorController.RotarSpeed = value * 40;
                HelicopterSound.pitch = Mathf.Clamp(value / 40, 0, 1.2f);
                if (UIGameController.runtime != null && UIGameController.runtime.EngineForceView != null)
                    UIGameController.runtime.EngineForceView.text = string.Format("Engine value [ {0} ] ", (int)value);

                _engineForce = value;
            }
        }


        Transform targetFin;
        Transform targetEli;

        void Awake()
        {

            if (Instance == null)
            {
                Instance = this;
            }
            else if (Instance != this)
            {
                Destroy(gameObject);
                return;
            }

            if (isZMQ_Joystick)
            {
                direct = " ";
                directionText.text = "Action: " + direct;
            }
            else
            {
                directionText.text = " ";
            }

            zmqSub = gameObject.AddComponent<ZmqCommunicator>();
            targetFin = GameObject.FindGameObjectWithTag("Finish").transform;
            targetEli = GameObject.FindGameObjectWithTag("Elicopther").transform;
        }

        private void OnEnable()
        {
            zmqSub.StartSubscriber(ip, updateInterval, ReadMessage);
        }


        public HelicopterController()
        {

            //zmqSub = gameObject.AddComponent<ZmqCommunicator>();
            //zmqSub.StartSubscriber(ip, updateInterval, ReadMessage);
        }

        public float count = 0f;

        void ReadMessage(byte[] bytes) // read message using zmq from matlab
        {
            string msg = System.Text.Encoding.ASCII.GetString(bytes);
            Debug.Log("Received: " + msg);

            if (msg == lastAction)
            {
                count += 1f;
            }
            else
            {
                count = 0f;
            }

            //Todo: check the msg if correct
            lastAction = msg;


            if (msg == "F")
            {
                direct = "Go forward";
                directionText.text = "Action: " + direct;
            }
            else if(msg == "OK")
            {
                direct = "Stay there";
                directionText.text = "Action: " + direct;
            }
            else if(msg == "D")
            {
                direct = "Go Down";
                directionText.text = "Action: " + direct;
            }
            else if(msg == "U")
            {
                direct = "Go up";
                directionText.text = "Action: " + direct;
            }
            else if(msg == "L")
            {
                direct = "Tourn left";
                directionText.text = "Action: " + direct;
            }
            else if (msg == "R")
            {
                direct = "Tourn right";
                directionText.text = "Action: " + direct;
            }
            timeSinceMessage = 0;
        }

        private float distanceToGround ;
        public float DistanceToGround
        {
            get {return distanceToGround; }
        }

        private Vector3 pointToGround;
        public Vector3 PointToGround
        {
            get { return pointToGround; }
        }


        private Vector2 hMove = Vector2.zero;
        private Vector2 hTilt = Vector2.zero;
        private float hTurn = 0f;
        public bool IsOnGround = true;
        private int goHome;
        float timeSinceMessage = 0f;
        float refer = 0f;
        float EngineForceRef;
        Vector3 myVector;



        void FixedUpdate()
        {
            ProcessingInputs();
            LiftProcess();
            MoveProcess();
            TiltProcess();

            Visualize();

            timeSinceMessage += Time.fixedDeltaTime;
            if(timeSinceMessage <= 5f)
            {
                EngineForceRef = EngineForce;
                refer = Vector3.Distance(transform.position, targetFin.position);
            }


            if ((timeSinceMessage > 5f && Vector3.Distance(transform.position, targetFin.position) > 2f) || (count > 5f && Vector3.Distance(transform.position, targetFin.position) > 2f))
            {
                //Go home
                Debug.Log("Going home");

                transform.position = Vector3.MoveTowards(transform.position, targetFin.position, 0.15f);


                if (transform.position.x - targetFin.position.x > 2f || transform.position.z - targetFin.position.z > 2f)
                {
                    if (EngineForce > 10)
                    {
                        myVector = new Vector3(0.0f, transform.position.y, 0.0f);
                        transform.LookAt(targetFin.position + myVector);
                    }

                    if (EngineForce > 10)
                    {
                        EngineForce = Vector3.Distance(transform.position, targetFin.position) / refer * EngineForceRef; // Decrise velocity
                    }
                    else if (distanceToGround > 7)
                    {
                        EngineForce = 10;
                    }
                    else
                    {
                        EngineForce = 8;
                    }


                }

                else
                {
                    EngineForce = 8;
                }

            }
        }

        private void MoveProcess()
        {
            var turn = TurnForce * Mathf.Lerp(hMove.x, hMove.x * (turnTiltForcePercent - Mathf.Abs(hMove.y)), Mathf.Max(0f, hMove.y));
            hTurn = Mathf.Lerp(hTurn, turn, Time.fixedDeltaTime * TurnForce);
            HelicopterModel.AddRelativeTorque(0f, hTurn * HelicopterModel.mass, 0f);
            HelicopterModel.AddRelativeForce(Vector3.forward * Mathf.Max(0f, hMove.y * ForwardForce * HelicopterModel.mass));
        }

        private void LiftProcess()
        {
            // to ground distance
            RaycastHit hit;

            var direction = transform.TransformDirection(Vector3.down);
            var ray = new Ray(transform.position, direction);
            if (Physics.Raycast(ray, out hit, 300, GroundMaskLayer))
            {
                Debug.DrawLine(transform.position, hit.point, Color.cyan);
                distanceToGround = hit.distance;
                pointToGround = hit.point;

                //isOnGround = hit.distance < 2f;
            }

            var upForce = 1 - Mathf.Clamp(HelicopterModel.transform.position.y / EffectiveHeight, 0, 1);
            upForce = Mathf.Lerp(0f, EngineForce, upForce) * HelicopterModel.mass;
            HelicopterModel.AddRelativeForce(Vector3.up * upForce);
        }

        private void TiltProcess()
        {
            hTilt.x = Mathf.Lerp(hTilt.x, hMove.x * TurnTiltForce, Time.deltaTime);
            hTilt.y = Mathf.Lerp(hTilt.y, hMove.y * ForwardTiltForce, Time.deltaTime);
            HelicopterModel.transform.localRotation = Quaternion.Euler(hTilt.y, HelicopterModel.transform.localEulerAngles.y, -hTilt.x);
        }

        /*
        private void ProcessingMobileInputs()
        {
            if (!IsOnGround)
            {
                hMove.x = Input.GetAxis( horizontalAxis);
                hMove.y = Input.GetAxis( verticalAxis);
            }
            else
            {
                hMove.x = 0;
                hMove.y = 0;
            }

            if (Input.GetAxis(jumpButton) > 0 && EngineForce <= 50)
            {
                EngineForce += 0.1f;
            }
            else
            if (Input.GetAxis(jumpButton) < 0 && EngineForce >= 7)
            {
                EngineForce -= 0.12f;
            }
        }
        */

        private void ProcessingInputs()
        {
            if (!IsOnGround)
            {
                // orizzontal mouvements
                hMove.x = GetInput( horizontalAxis); // move on z axes
                hMove.y = GetInput( verticalAxis);   // move on y axes

                if (Mathf.Abs(hMove.x) > 0 || Mathf.Abs(hMove.y) < 0) 
                {
                    timeSinceMessage = 0;
                }
            }

            if (GetInput(jumpButton) > 0 && EngineForce <= 50)
            {
                EngineForce += 0.1f; // up
                timeSinceMessage = 0;
            }
            else if (GetInput(jumpButton) < 0 && EngineForce >= 8)
            {
                EngineForce -= 0.12f; // down
                timeSinceMessage = 0;

            }


        }

        public void SetIsZMQused(bool val)
        {
            isZMQ_Joystick = val;
        }

        private float GetInput(string input)
        {
            if (isZMQ_Joystick)
                return Evaluate_EMG_Input(input);
            else if (isVirtualJoystick)
                return SimpleInput.GetAxis(input);
            else
                return Input.GetAxis(input);
        }

        private float Evaluate_EMG_Input(string input)
        {   
            if (input == horizontalAxis && lastAction == "R")
            {
                return 0.5f;

            }
            else if(input == horizontalAxis && lastAction == "L")
           {
               return -0.5f;

            }
            else if(input == verticalAxis && lastAction == "F")
            {
                return 1.0f;
            }
            else if (input == jumpButton && lastAction == "U")
            {
                return 1.0f;
            }
            else if (input == jumpButton && lastAction == "D")
            {
                return -1.0f;
            }
            else if (lastAction == "OK")
            {
                return 0.0f;
            }

            return 0.0f;
        }
  

        private void OnCollisionEnter()
        {
            IsOnGround = true;
        }

        private void OnCollisionExit()
        {
            IsOnGround = false;
        }

//TODO temp move to events

        private void Visualize()
        {
            if (DustAirController != null)
            {
                DustAirController.ProgressEngineValue(EngineForce);
                DustAirController.VisualizeDustGround(DistanceToGround, PointToGround);
            }

            if (UIViewController.runtime.HeigthUpView != null)
                UIViewController.runtime.HeigthUpView.text = string.Format("To Ground [ {0} ] m",
                    (int)DistanceToGround);

            if (UIViewController.runtime.EngineForceView != null)
                UIViewController.runtime.EngineForceView.text = string.Format("Engine [ {0} ] ", (int)EngineForce);

            // if (UIViewController.runtime.UpDragView != null)
            //     UIGameController.runtime.UpDragView.text = string.Format("Up Force [ {0} ] f",
            //         (int)CurrentHeightForce);

            if (UIViewController.runtime.HeigthView != null)
                UIViewController.runtime.HeigthView.text = string.Format("Heigth  [ {0} ] m", (int)transform.position.y);
        }

    }
}