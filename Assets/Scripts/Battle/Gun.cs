using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Gun : MonoBehaviour {


    public int speed = 1;
    public float highEnd=350;
    
    public float lowEnd=50;
    public Camera cam;

    //AimLine的上下端坐标
    
	// Use this for initialization
	void Start () {
		
	}
	
    private void ControlByMouse()
    {
        // 获取鼠标在屏幕上的坐标，没有z轴
        Vector3 mouseOrg = Input.mousePosition;
        
        // 计算

        // 仙女棒旋转平面的对应法向量 (！）需要注意切换平面后的问题 这里不能直接用
        Vector3 normVec = transform.parent.forward;

        // 仙女棒旋转平面的绕着旋转轴
        Vector3 rotVec = transform.parent.right;
        // 
        // 获得鼠标坐标到zy平面的距离
        //float h = Vector3.Dot(normVec, mouseOrg);

        // 将鼠标的坐标投影到仙女棒的zy平面 
        //Vector3 dstPos = mouseOrg - rotVec * h;

        // 将仙女棒在zy平面上绕着x轴 旋转直到仙女棒在它父节点的Y轴上投影等于dstPos
        // len: 仙女棒在视野里的长度
        //len = transform.tranpol
        float dstValue = mouseOrg.y;//dstPos.y;

        float rotX;
        //float lowEnd = cam.WorldToScreenPoint(transform.position).y;
        //float highEnd = cam.WorldToScreenPoint(transform.position + new Vector3(0, 0.5f, 0)).y;

        if (dstValue > highEnd)
        {
            dstValue = highEnd;
            rotX = 0;
        }
        else if (dstValue < lowEnd)
        {
            dstValue = lowEnd;
            rotX = 90;
        }
        else
        {
            //Mathf.ar
            rotX = Mathf.Rad2Deg * Mathf.Acos((dstValue - lowEnd) / (highEnd - lowEnd));
        }
        //Debug.Log(dstValue + " " + lowEnd + " " + highEnd + " " + rotX);
        transform.rotation = Quaternion.Euler(rotVec * rotX);// = new Vector3(rotX, 0, 0);     

    }
	// Update is called once per frame
	void Update () {
        ControlByMouse();
	}
}
