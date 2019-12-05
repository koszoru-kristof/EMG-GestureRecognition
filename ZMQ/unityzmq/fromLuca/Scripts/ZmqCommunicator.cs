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

namespace MiroZmq
{
    public struct ZmqVelocity
    {
        public const Byte TYPE = 12;
        public float rightSpeed;
        public float leftSpeed;
               

        public Byte[] Serialize()
        {
            Byte[] buffer = new Byte[9];
            int index = 0;

            Array.Copy(BitConverter.GetBytes(TYPE), 0, buffer, index, sizeof(Byte));
            index += sizeof(Byte);

            Array.Copy(BitConverter.GetBytes(rightSpeed), 0, buffer, index, sizeof(float));
            index += sizeof(float);

            Array.Copy(BitConverter.GetBytes(leftSpeed), 0, buffer, index, sizeof(float));
            index += sizeof(float);


            return buffer;
        }

        public bool Deserialize(ref byte[] buffer)
        {
            if (buffer.Length < 9)
            {
                Debug.LogWarning("Message is too short");
                return false;
            }

            int index = 0;
            Byte type = (byte)BitConverter.ToChar(buffer, index);
            index += sizeof(byte);

            if (type != TYPE)
            {
                Debug.LogWarning("Wrong type! expected " + TYPE.ToString() + ", found " + type.ToString());
                return false;
            }

            rightSpeed = BitConverter.ToSingle(buffer, index);
            index += sizeof(float);

            leftSpeed = BitConverter.ToSingle(buffer, index);
            index += sizeof(float);

            return true;
        }

    }

    public struct ZmqAck
    {
        private const Byte TYPE = 11;
        public bool active;
        public int counter;
                
        public Byte[] Serialize()
        {
            Byte[] buffer = new Byte[9];
            int index = 0;

            Array.Copy(BitConverter.GetBytes(TYPE), 0, buffer, index, sizeof(Byte));
            index += sizeof(Byte);

            Array.Copy(BitConverter.GetBytes(active), 0, buffer, index, sizeof(bool));
            index += sizeof(bool);

            Array.Copy(BitConverter.GetBytes(counter), 0, buffer, index, sizeof(int));
            index += sizeof(int);


            return buffer;
        }

        public bool Deserialize(ref byte[] buffer)
        {
            if (buffer.Length < 6)
            {
                Debug.LogWarning("Message is too short");
                return false;
            }

            int index = 0;
            Byte type = (byte)BitConverter.ToChar(buffer, index);
            index += sizeof(byte);

            if (type != TYPE)
            {
                Debug.LogWarning("Wrong type! expected " + TYPE.ToString() + ", found " + type.ToString());
                return false;
            }

            active = BitConverter.ToBoolean(buffer, index);
            index += sizeof(bool);

            counter = BitConverter.ToInt32(buffer, index);
            index += sizeof(int);

            return true;
        }
    }

    public enum NavigationStatus { Idle, Manual, SemiAuto, Tilt, Sleep, Error };

    public struct ZmqStatus
    {
        private const Byte TYPE = 14;
        public NavigationStatus status;
        public int param;

        public Byte[] Serialize()
        {
            Byte[] buffer = new Byte[9];
            int index = 0;

            Array.Copy(BitConverter.GetBytes(TYPE), 0, buffer, index, sizeof(Byte));
            index += sizeof(Byte);

            Array.Copy(BitConverter.GetBytes((int)status), 0, buffer, index, sizeof(int));
            index += sizeof(int);

            Array.Copy(BitConverter.GetBytes(param), 0, buffer, index, sizeof(int));
            index += sizeof(int);


            return buffer;
        }

        public bool Deserialize(ref byte[] buffer)
        {
            if (buffer.Length < 9)
            {
                Debug.LogWarning("Message is too short");
                return false;
            }

            int index = 0;
            Byte type = (byte)BitConverter.ToChar(buffer, index);
            index += sizeof(byte);

            if (type != TYPE)
            {
                Debug.LogWarning("Wrong type! expected " + TYPE.ToString() + ", found " + type.ToString());
                return false;
            }

            status = (NavigationStatus) BitConverter.ToInt32(buffer, index);
            index += sizeof(int);

            param = BitConverter.ToInt32(buffer, index);
            index += sizeof(int);          
            
            return true;
        }

    }

    public struct ZmqBrake
    {
        private const Byte TYPE = 13;
        public bool brakeEnable;
        public bool brakeStatus;               

        public Byte[] Serialize()
        {
            Byte[] buffer = new Byte[3];
            int index = 0;

            Array.Copy(BitConverter.GetBytes(TYPE), 0, buffer, index, sizeof(Byte));
            index += sizeof(Byte);

            Array.Copy(BitConverter.GetBytes(brakeEnable), 0, buffer, index, sizeof(bool));
            index += sizeof(bool);

            Array.Copy(BitConverter.GetBytes(brakeStatus), 0, buffer, index, sizeof(bool));
            index += sizeof(bool);


            return buffer;
        }

        public bool Deserialize(ref byte[] buffer)
        {
            if (buffer.Length < 3)
            {
                Debug.LogWarning("Message is too short");
                return false;
            }

            int index = 0;
            Byte type = (byte)BitConverter.ToChar(buffer, index);
            index += sizeof(byte);

            if (type != TYPE)
            {
                Debug.LogWarning("Wrong type! expected " + TYPE.ToString() + ", found " + type.ToString());
                return false;
            }

            brakeEnable = BitConverter.ToBoolean(buffer, index);
            index += sizeof(bool);

            brakeStatus = BitConverter.ToBoolean(buffer, index);
            index += sizeof(bool);

            return true;
        }
    }

    public struct ZmqMotorEnable
    {
        private const Byte TYPE = 23;
        public bool motorEnable;

        public Byte[] Serialize()
        {
            Byte[] buffer = new Byte[2];
            int index = 0;

            Array.Copy(BitConverter.GetBytes(TYPE), 0, buffer, index, sizeof(Byte));
            index += sizeof(Byte);

            Array.Copy(BitConverter.GetBytes(motorEnable), 0, buffer, index, sizeof(bool));
            index += sizeof(bool);        
            
            return buffer;
        }

        public bool Deserialize(ref byte[] buffer)
        {
            if (buffer.Length < 2)
            {
                Debug.LogWarning("Message is too short");
                return false;
            }

            int index = 0;
            Byte type = (byte)BitConverter.ToChar(buffer, index);
            index += sizeof(byte);

            if (type != TYPE)
            {
                Debug.LogWarning("Wrong type! expected " + TYPE.ToString() + ", found " + type.ToString());
                return false;
            }

            motorEnable = BitConverter.ToBoolean(buffer, index);
            index += sizeof(bool);
            

            return true;
        }
    }

    public struct ZmqVoltage
    {
        private const Byte TYPE = 22;
        public float voltage;

        public Byte[] Serialize()
        {
            Byte[] buffer = new Byte[5];
            int index = 0;

            Array.Copy(BitConverter.GetBytes(TYPE), 0, buffer, index, sizeof(Byte));
            index += sizeof(Byte);

            Array.Copy(BitConverter.GetBytes(voltage), 0, buffer, index, sizeof(float));
            index += sizeof(float);

            return buffer;
        }

        public bool Deserialize(ref byte[] buffer)
        {
            if (buffer.Length < 5)
            {
                Debug.LogWarning("Message is too short");
                return false;
            }

            int index = 0;
            Byte type = (byte)BitConverter.ToChar(buffer, index);
            index += sizeof(byte);

            if (type != TYPE)
            {
                Debug.LogWarning("Wrong type! expected " + TYPE.ToString() + ", found " + type.ToString());
                return false;
            }

            voltage = BitConverter.ToSingle(buffer, index);
            index += sizeof(float);


            return true;
        }
    }

    public enum TiltType
    {
        Nothing, SeatUp, SeatDown, RearUp, RearDown
    }

    public struct ZmqTilt
    {
        private const Byte TYPE = 21;
        public TiltType tiltType;

        public Byte[] Serialize()
        {
            Byte[] buffer = new Byte[5];
            int index = 0;

            Array.Copy(BitConverter.GetBytes(TYPE), 0, buffer, index, sizeof(Byte));
            index += sizeof(Byte);

            Array.Copy(BitConverter.GetBytes((int)tiltType), 0, buffer, index, sizeof(int));
            index += sizeof(int);
            
            return buffer;
        }

        public bool Deserialize(ref byte[] buffer)
        {
            if (buffer.Length < 5)
            {
                Debug.LogWarning("Message is too short");
                return false;
            }

            int index = 0;
            Byte type = (byte)BitConverter.ToChar(buffer, index);
            index += sizeof(byte);

            if (type != TYPE)
            {
                Debug.LogWarning("Wrong type! expected " + TYPE.ToString() + ", found " + type.ToString());
                return false;
            }

            tiltType = (TiltType)BitConverter.ToInt32(buffer, index);
            index += sizeof(int);
            
            return true;
        }
    }

    public struct ZmqMat
    {
        public Byte _type;
        public int _rows;
        public int _cols;
        public int _dataType;
        public Byte[] _data;

    }

    //public struct ZmqPoisPath
    //{
    //    private const Byte TYPE = 18;
    //    public int nPaths;
    //    public int nPoints;
    //    public short[] xPoints;
    //    public short[] yPoints;
    //    public short[] zPoints;
    //    public short[] ids;
    //    public UInt64 pkgSize;

    //    public bool Deserialize(ref byte[] buffer)
    //    {
    //        if (buffer.Length < 9)
    //        {
    //            Debug.LogWarning("Message is too short");
    //            return false;
    //        }

    //        int index = 0;

    //        Byte type = (byte)BitConverter.ToChar(buffer, index);
    //        index += sizeof(byte);

    //        if (type != TYPE)
    //        {
    //            Debug.LogWarning("Wrong type! expected " + TYPE.ToString() + ", found " + type.ToString());
    //            return false;
    //        }

    //        nPaths = BitConverter.ToInt32(buffer, index);
    //        index += sizeof(int);                       

    //        if (nPaths > 0)
    //        {
    //            nPoints = BitConverter.ToInt32(buffer, index);
    //            index += sizeof(int);

    //            if (buffer.Length < (index + nPoints * nPaths * 3 * sizeof(short) + nPaths * sizeof(short)))
    //            {
    //                Debug.LogWarning("Message is too short");
    //                return false;
    //            }

    //            ids = new short[nPaths];
    //            Buffer.BlockCopy(buffer, index, ids, 0, nPaths * sizeof(short));
    //            index += nPaths * sizeof(short);

    //            // INVERT X-Y TO PASS FROM DESTRORSO TO SINISTRORSO!!!! 
    //            yPoints = new short[nPaths * nPoints];
    //            Buffer.BlockCopy(buffer, index, yPoints, 0, nPaths * nPoints * sizeof(short));
    //            index += nPaths * nPoints * sizeof(short);

    //            xPoints = new short[nPaths * nPoints];
    //            Buffer.BlockCopy(buffer, index, xPoints, 0, nPaths * nPoints * sizeof(short));
    //            index += nPaths * nPoints * sizeof(short);

    //            zPoints = new short[nPaths * nPoints];
    //            Buffer.BlockCopy(buffer, index, zPoints, 0, nPaths * nPoints * sizeof(short));
    //            index += nPaths * nPoints * sizeof(short);                
    //        }

    //        pkgSize = (ulong)buffer.Length;
    //        return true;
    //    }
    //}

    public struct ZmqPoisPath
    {
        private const Byte TYPE = 18;
        public int nPaths;
        public short[] nPoints;
        public short[] xPoints;
        public short[] yPoints;
        public short[] zPoints;
        public short[] ids;
        public Matrix4x4[] transformationMatrixs;
        byte[] busyPath;
        public UInt64 pkgSize;

        public bool Deserialize(ref byte[] buffer)
        {
            if (buffer.Length < 9)
            {
                Debug.LogWarning("Message is too short");
                return false;
            }

            int index = 0;

            Byte type = (byte)BitConverter.ToChar(buffer, index);
            index += sizeof(byte);

            if (type != TYPE)
            {
                Debug.LogWarning("Wrong type! expected " + TYPE.ToString() + ", found " + type.ToString());
                return false;
            }

            nPaths = BitConverter.ToInt32(buffer, index);
            //Debug.LogWarning("N PATH Received: " + nPaths);
            index += sizeof(int);

            if (nPaths > 0)
            {
                ids = new short[nPaths];
                Buffer.BlockCopy(buffer, index, ids, 0, nPaths * sizeof(short));
                index += nPaths * sizeof(short);

                nPoints = new short[nPaths];
                Buffer.BlockCopy(buffer, index, nPoints, 0, nPaths * sizeof(short));
                index += nPaths * sizeof(short);

                for (int ii = 0; ii < nPaths; ii++)
                {
                    //Debug.LogWarning("N POINTS of path: " + ids[ii] + " is equal to: " + nPoints[ii]);
                }

                int nPointsPath = 0;
                for (int ii = 0; ii< nPaths; ii++)
                {
                    //Debug.LogWarning("N POINTS: " + nPoints[ii]);
                    nPointsPath += nPoints[ii];
                }

                //Debug.LogWarning("BUFFER LENGHT: " + (ulong)buffer.Length);
                //Debug.LogWarning("BUFFER LENGHT MEASURED: " + (index + (3 * nPointsPath * sizeof(short)) + (16 * nPaths * sizeof(float)) + (nPaths * sizeof(byte))));


                if (buffer.Length < (index + (3 * nPointsPath * sizeof(short)) + (16 * nPaths * sizeof(float)) + (nPaths * sizeof(byte))))
                {
                    Debug.LogWarning("Message is too short");
                    return false;
                }

                // INVERT X-Y TO PASS FROM DESTRORSO TO SINISTRORSO!!!! 
                yPoints = new short[nPointsPath];
                Buffer.BlockCopy(buffer, index, yPoints, 0, nPointsPath * sizeof(short));
                index += nPointsPath * sizeof(short);

                xPoints = new short[nPointsPath];
                Buffer.BlockCopy(buffer, index, xPoints, 0, nPointsPath * sizeof(short));
                index += nPointsPath * sizeof(short);

                zPoints = new short[nPointsPath];
                Buffer.BlockCopy(buffer, index, zPoints, 0, nPointsPath * sizeof(short));
                index += nPointsPath * sizeof(short);

                //for (int ii = 0; ii < nPointsPath; ii++)
                //{
                //    Debug.LogWarning("POINT  " + ii + ": " + yPoints[ii] + ", " + xPoints[ii] + ", " + zPoints[ii]);
                //}

                transformationMatrixs = new Matrix4x4[nPaths];

                for (int ii = 0; ii < nPaths; ii++)
                {
                    for (int i = 0; i < 4; i++)
                    {
                        Vector4 v = new Vector4();
                        for (int j = 0; j < 4; j++)
                        {
                            v[j] = BitConverter.ToSingle(buffer, index);
                            index += sizeof(float);
                        }
                        transformationMatrixs[ii].SetColumn(i, v);
                    }

                    // INVERT X-Y TO PASS FROM DESTRORSO TO SINISTRORSO!!!! 
                    Vector4 app = transformationMatrixs[ii].GetRow(0);
                    transformationMatrixs[ii].SetRow(0, transformationMatrixs[ii].GetRow(1));
                    transformationMatrixs[ii].SetRow(1, app);

                    /*
                    Debug.LogWarning("TRANSFORMATION MATRIX: ");
                    Debug.LogWarning("L1 | " + transformationMatrixs[ii][0, 0] + " | " + transformationMatrixs[ii][0, 1] + " | " + transformationMatrixs[ii][0, 2] + " | " + transformationMatrixs[ii][0, 3]);
                    Debug.LogWarning("L2 | " + transformationMatrixs[ii][1, 0] + " | " + transformationMatrixs[ii][1, 1] + " | " + transformationMatrixs[ii][1, 2] + " | " + transformationMatrixs[ii][1, 3]);
                    Debug.LogWarning("L3 | " + transformationMatrixs[ii][2, 0] + " | " + transformationMatrixs[ii][2, 1] + " | " + transformationMatrixs[ii][2, 2] + " | " + transformationMatrixs[ii][2, 3]);
                    Debug.LogWarning("L4 | " + transformationMatrixs[ii][3, 0] + " | " + transformationMatrixs[ii][3, 1] + " | " + transformationMatrixs[ii][3, 2] + " | " + transformationMatrixs[ii][3, 3]);
                */
                }

                busyPath = new byte[nPaths];
                Buffer.BlockCopy(buffer, index, busyPath, 0, nPaths * sizeof(byte));
                index += nPaths * sizeof(byte);


            }

            pkgSize = (ulong)buffer.Length;
            return true;
        }
    }

    public struct ZmqEigenFloatMatrix
    {
        private const Byte TYPE = 19;
        public int rows;
        public int cols;
        public int elementSize;
        public Matrix4x4 matrix;
        public UInt64 pkgSize;

        public bool Deserialize(ref byte[] buffer)
        {
            if (buffer.Length < 13)
            {
                Debug.LogWarning("Message is too short");
                return false;
            }

            int index = 0;
            Byte type = (byte)BitConverter.ToChar(buffer, index);
            index += sizeof(byte);

            if (type != TYPE)
            {
                Debug.LogWarning("Wrong type! expected " + TYPE.ToString() + ", found " + type.ToString());
                return false;
            }

            rows = BitConverter.ToInt32(buffer, index);
            index += sizeof(int);

            cols = BitConverter.ToInt32(buffer, index);
            index += sizeof(int);

            elementSize = BitConverter.ToInt32(buffer, index);
            index += sizeof(int);

            if (buffer.Length < index + elementSize * rows * cols)
            {
                Debug.LogWarning("Message is too short");
                return false;
            }

            if (rows != 4 && cols != 4 && elementSize != 4)
            {
                Debug.LogWarning("Not a 4x4 float matrix!");
                return false;
            }            

            matrix = new Matrix4x4();
            for (int i = 0; i < 4; i++)
            {
                Vector4 v = new Vector4();
                for (int j = 0; j < 4; j++)
                {
                    v[j] = BitConverter.ToSingle(buffer, index);
                    index += sizeof(float);
                }
                matrix.SetColumn(i, v);
            }

            // INVERT X-Y TO PASS FROM DESTRORSO TO SINISTRORSO!!!! 
            Vector4 app = matrix.GetRow(0);
            matrix.SetRow(0, matrix.GetRow(1));
            matrix.SetRow(1, app);

            pkgSize = (ulong)buffer.Length;
            return true;
        }
    }
    
    public struct Zmq2DFloatPoint
    {
        //private const Byte TYPE = 25;
        public float _x;
        public float _y;
        public UInt64 _pkgSize;

        public bool Deserialize(ref byte[] buffer)
        {
            if (buffer.Length < 8)
            {
                Debug.LogWarning("Message is too short");
                return false;
            }

            /*
            _type = (byte)BitConverter.ToChar(buffer, 0);

            if (_type != 19)
            {
                Debug.LogWarning("Wrong type! expected 19, found " + _type.ToString());
                return false;
            }
            */

            _x = BitConverter.ToSingle(buffer, 0);
            _y = BitConverter.ToSingle(buffer, 4);            

            _pkgSize = (ulong)buffer.Length;

            return true;
        }
    }

}