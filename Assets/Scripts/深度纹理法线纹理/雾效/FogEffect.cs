using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

public class FogEffect : PostEffectBase  
{
    public Color m_FogColor = Color.gray;
    //雾的浓度
    public float m_FogDensity = 1.0f;
    //雾的起始位置
    public float m_FogStart = 0.0f;
    //雾的结束位置
    public float m_FogEnd = 2.0f;
    //装四个顶点的矩阵
    private Matrix4x4 rayMatrix;

    private void Start()
    {
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
    }

    protected override void UpdateProperty()
    {
        if (material != null)
        {
            float near = Camera.main.nearClipPlane;
            float fov = Camera.main.fieldOfView / 2;
            float aspect = Camera.main.aspect;
            float halfH  = near * Mathf.Tan(fov * Mathf.Deg2Rad);
            float halfW = halfH * aspect;
            Vector3 toTop = Camera.main.transform.up * halfH;
            Vector3 toRight = Camera.main.transform.right * halfW;
            //算出指向四个角的顶点的向量
            Vector3 topLeft = Camera.main.transform.forward * near + toTop - toRight;
            Vector3 topRight = Camera.main.transform.forward * near + toTop + toRight;
            Vector3 bottomLeft = Camera.main.transform.forward * near - toTop - toRight;
            Vector3 bottomRight = Camera.main.transform.forward * near - toTop + toRight;
            //求4个点到摄像机的距离（模长） dis/TL = depth/near  dis = depth * TL / near  Scale = TL / near  dis为左上角对应的世界坐标到摄像机的距离
            //左上角像素点对应世界坐标 = 摄像机位置 + TL.Normalized * |TL|/Near * Depth
            //Depth为深度值 利用 LinearEyeDepth 内置函数得到像素到摄像机的实际距离
            var scale = topLeft.magnitude / near;
            //真正的最终想要的四条射线向量
            topLeft= topLeft.normalized * scale;
            topRight = topRight.normalized * scale;
            bottomLeft = bottomLeft.normalized * scale;
            bottomRight = bottomRight.normalized * scale;
            
            rayMatrix.SetRow(0, bottomLeft);
            rayMatrix.SetRow(1, bottomRight);
            rayMatrix.SetRow(2, topRight);
            rayMatrix.SetRow(3, topLeft);
            
            //设置材质球相关属性(Shader属性)
            material.SetColor("_FogColor", m_FogColor);
            material.SetFloat("_FogDensity", m_FogDensity);
            material.SetFloat("_FogStart", m_FogStart);
            material.SetFloat("_FogEnd", m_FogEnd);
            material.SetMatrix("_RayMatrix", rayMatrix);
        }
    }

    protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
           
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
