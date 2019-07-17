using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerManager : MonoBehaviour {

    // Use this for initialization
    public int Speed = 10;
    Transform detectGround;
    bool overTurn = true;
    int plane; // 当前在哪一个面

    // 平面坐标轴
    // 用plane

    public Action<int> onPlayerOverturn;

    public struct BasicPlaneAxis
    {
        public Vector3 forward; // 对应z轴
        public Vector3 up;// 对应y轴
        public Vector3 right; // 对应x轴
        public BasicPlaneAxis(Vector3 f, Vector3 u, Vector3 r)
        {
            forward = f;
            up = u;
            right = r;
        }
    };

    // 六个平面 判断当前在哪一个平面上
    public BasicPlaneAxis[] planeAxises =
    {
        new BasicPlaneAxis(new Vector3(0,0,1),new Vector3(0,1,0),new Vector3(1,0,0)),
        new BasicPlaneAxis(new Vector3(0,1,0),new Vector3(0,0,-1),new Vector3(1,0,0)),
        new BasicPlaneAxis(new Vector3(0,1,0),new Vector3(-1,0,0),new Vector3(0,0,1)),
        new BasicPlaneAxis(new Vector3(0,1,0),new Vector3(0,0,-1),new Vector3(-1,0,0)),
        new BasicPlaneAxis(new Vector3(0,1,0),new Vector3(-1,0,0),new Vector3(0,0,-1)),
        new BasicPlaneAxis(new Vector3(0,0,-1),new Vector3(0,-1,0),new Vector3(1,0,0)),
    };


    BasicPlaneAxis planeAxis;
	void Start () {
        detectGround = transform.GetChild(1).transform;
        planeAxis.forward = transform.forward;
        planeAxis.up = transform.up;
        planeAxis.right = transform.right;
	}
	
	// Update is called once per frame
	void Update () {

	}
    void DetectRot(Vector3 mov, Vector3 localMov)
    {
        Ray ray = new Ray(transform.position, detectGround.position - transform.position);
        RaycastHit hit;
        bool isHit = Physics.Raycast(ray, out hit);
        if (isHit)
        {
            // 碰撞检测到脚下是地面，继续前进
            if (hit.collider.tag == "ground")
            {
                transform.Translate(mov, Space.World);
            }
            // 检测到脚下是danger
            else if (hit.collider.tag == "danger")
            {
                //卡住不动
            }

        }
        else if (mov != new Vector3(0, 0, 0) && overTurn)
        // 旋转到另一个平面
        {
            //更改当前平面坐标轴 确认当前旋转到的是哪一个平面
            BasicPlaneAxis newPlaneAxis = new BasicPlaneAxis();
            newPlaneAxis.forward = planeAxis.up * -1;

           
            //将自身的Y轴旋转90度
            // 旋转可能有四种情况 分别
            if (localMov.x != 0 && localMov.y != 0)
            {
                // 同时按了两个方向键 不翻转
            }
            else if (localMov.x != 0)
            {
                // 绕着z轴旋转
                if (localMov.x > 0)
                {
                    transform.Rotate(new Vector3(0, 0, -90f), Space.World);
                    //newPlaneAxis.up = planeAxis.right;
                }
                else
                {
                    transform.Rotate(new Vector3(0, 0, 90f), Space.World);
                    //newPlaneAxis.up = planeAxis.right * -1;
                }
            }
            else
            {
                // 绕着x轴旋转
                if (localMov.z > 0)
                {
                    transform.Rotate(new Vector3(90f, 0, 0), Space.World);
                    //newPlaneAxis.up = planeAxis.forward;
                }
                else
                {
                    transform.Rotate(new Vector3(-90f, 0, 0), Space.World);
                    //newPlaneAxis.up = planeAxis.forward * -1;
                }

            }

            newPlaneAxis.right = Vector3.Cross(newPlaneAxis.forward, newPlaneAxis.up).normalized;
            Debug.Log("PlaneAxis forward " + planeAxis.forward + " up " + planeAxis.up + " right " + planeAxis.right);
            planeAxis = newPlaneAxis;           
            Debug.Log("newPlaneAxis forward " + newPlaneAxis.forward + " up " + newPlaneAxis.up + " right " + newPlaneAxis.right);


            //翻转平面后往前面走一小步 避免反复翻转判断
            //transform.Translate(PlaneToWorld(new Vector3(0, 0, 1)), Space.World);
            overTurn = false;

            //判断去往哪一个平面

           
            //transform.right;

            //Vector3 tmp = planeAxis.forward;
            //planeAxis.forward = planeAxis.right;
            //planeAxis.right = tmp;


        }
        else
        {
            //overTurn = true;
        }
    }
    private Vector3 PlaneToWorld(Vector3 src)
    {
        Vector3 dst = new Vector3(0, 0, 0);
        dst.x = Vector3.Dot(src, planeAxis.right);
            //src * planeAxis.right;
        dst.y = Vector3.Dot(src, planeAxis.up);
        dst.z = Vector3.Dot(src, planeAxis.forward);

        return dst;
    }
    private void ControlByKeyboard()
    {
        // 通过wasd控制移动 
        float xm = 0, ym = 0, zm = 0;
        float m_movSpeed = 5;
        float x_rm = 0;

        // 注意在不同平面上参考的世界坐标轴不一样 需要取保存下来的当前平面三向值
        //按键盘W向上移动
        if (Input.GetKey(KeyCode.W))
        {
            zm += m_movSpeed * Time.deltaTime;
        }
        else if (Input.GetKey(KeyCode.S))//按键盘S向下移动
        {
            zm -= m_movSpeed * Time.deltaTime;
        }

        if (Input.GetKey(KeyCode.A))//按键盘A向左移动
        {
            xm -= m_movSpeed * Time.deltaTime;
        }
        else if (Input.GetKey(KeyCode.D))//按键盘D向右移动
        {
            xm += m_movSpeed * Time.deltaTime;
        }

        // 获取到了平面坐标轴上的坐标
        Vector3 localMov = new Vector3(xm, ym, zm);

        //将平面坐标轴转换到世界坐标轴
        Vector3 mov = PlaneToWorld(localMov);

        // 判断是否要旋转到另一个平面/是否不能继续前进
        DetectRot(mov,localMov);

        // 人物正面朝向 transform.z 
        if (localMov != new Vector3(0, 0, 0))
        {
            //transform.forward = mov;
            Vector3 dstDir = localMov.normalized;

            Vector3 srcDir = PlaneToWorld(transform.forward);

            Vector3 direction = dstDir - srcDir;


            float angle = Vector3.Angle(srcDir, dstDir);
            //float dir = (Vector3.Dot(Vector3.up, Vector3.Cross(srcDir, dstDir)) < 0 ? -1 : 1);
            //angle *= dir;


            transform.Rotate(new Vector3(0, angle, 0) * Time.deltaTime * Speed, Space.Self);

        }
    }
    private void FixedUpdate()
    {
      
        ControlByKeyboard();

        // 
    }

    private void LateUpdate()
    {
        if (!overTurn)
        {
            // 旋转之后通知相机跟随旋转
            onPlayerOverturn(plane);
            overTurn = true;
        }
    }
}
