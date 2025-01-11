using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(ProceduralTexture))]
public class ProceduralTextureEditor : Editor
{
    public override void OnInspectorGUI()
    {
        //绘制默认参数相关的内容
        DrawDefaultInspector();

        //获取目标脚本
        var scriptObj = (ProceduralTexture)target;

        if(GUILayout.Button("更新程序纹理"))
        {
            scriptObj.UpdateTexture();
        }
    }
}
