using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OnRender : MonoBehaviour
{
    
    public Material material;
    
    /// <summary>
    /// 该函数得到的源纹理默认是在所有的不透明和透明的Pass执行完毕后调用的
    /// 基于该源纹理进行修改会对游戏场景中所有游戏对象产生影响
    /// 如果想要在不透明的Pass执行完毕后就调用该函数，只需要在该函数前加上 [ImageEffectOpaque]特性
    /// 该函数的目的时来获取当前屏幕画面并利用Shader对该纹理进行自定义处理
    /// 将源纹理(获取到的游戏画面)复制到目标纹理并应用一个材质，source源纹理会被传递给mat材质中Shader中名为_MainTex的纹理属性用于进行处理
    /// </summary>
    /// <param name="source"></param>
    /// <param name="destination"></param>
    //对透明不会产生影响
    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, material);
    }
}
