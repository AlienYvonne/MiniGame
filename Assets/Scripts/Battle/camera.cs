using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class camera : MonoBehaviour {

    // Use this for initialization
    GameObject player;
    int cubeLen = 20 / 2;
    Vector3[] cubeVertex = new Vector3[8];
    Vector3[] cubeCamPoses = new Vector3[6];
    Vector3[] cubeCamAngles = new Vector3[6];
    //{
    //new Vector3(20,-45,0),
    //new Vector3(45,-20,135),
    //new Vector3(45,-20,235)
    //}
    float camDis = 50f;
	void Start () {
        // 注册监听overturn

        player = GameObject.FindGameObjectsWithTag("Player")[0];
        player.GetComponent<PlayerManager>().onPlayerOverturn += playerOverturn;

        int[] sum = { 1, -1 };
        int count = 0;
        // 魔方顶点坐标
        foreach(int x in sum)
        {
            foreach(int y in sum)
            {
                foreach(int z in sum)
                {
                    cubeVertex[count] = new Vector3(cubeLen * x, cubeLen * y, cubeLen * z);
                    count++;
                }
            }
        }
        // 魔方六个面各自对应的观察点：1, 3, 2 ,6,7, 5
        // 各自还要对应一个初始观察角度
        int[] pointIndex = { 1,3,2,6,7,5};
        for (count = 0; count < 6; count ++)
        {
            cubeCamPoses[count] = (cubeVertex[pointIndex[7 - count]] - cubeVertex[pointIndex[count]]).normalized * camDis;
            
        }
        //cubeCamAngles[count] =

    }


    public void playerOverturn(int plane) // 在哪一个面
    {
        Debug.Log("cam获得overturn信息");
        // 旋转
        // 根据顶点坐标获得相机的坐标
        // 六个不同平面对应六个不同的摄像机坐标（写死算了
        transform.position = cubeCamPoses[plane];
    }
	
	// Update is called once per frame
	void Update () {
		
	}
    private void LateUpdate()
    {
        
    }
}
