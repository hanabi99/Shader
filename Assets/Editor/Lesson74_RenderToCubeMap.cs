using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class Lesson74_RenderToCubeMap : EditorWindow
{
    private GameObject obj;
    private Cubemap cubeMap;

    [MenuItem("Cube texture dynamic generation/Open the build window")]
    static void OpenWindow()
    {
        Lesson74_RenderToCubeMap window = EditorWindow.GetWindow<Lesson74_RenderToCubeMap>("立方体纹理生成窗口");
        window.Show();
    }

    private void OnGUI()
    {
        GUILayout.Label("Ori Object");
        //用于关联对象的控件
        obj = EditorGUILayout.ObjectField(obj, typeof(GameObject), true) as GameObject;
        GUILayout.Label("Ori CubeMap");
        //用于关联立方体纹理的控件
        cubeMap = EditorGUILayout.ObjectField(cubeMap, typeof(Cubemap), false) as Cubemap;
        //点击按钮后 就去执行生成逻辑
        if(GUILayout.Button("Instantiate CubeMap"))
        {
            if(obj == null || cubeMap == null)
            {
                EditorUtility.DisplayDialog("Tips", "Please associate the corresponding object and cube map first", "OK");
                return;
            }
            //动态的生成立方体纹理
            GameObject tmpObj = new GameObject("临时对象");
            tmpObj.transform.position = obj.transform.position;
            Camera camera = tmpObj.AddComponent<Camera>();
            //关键方法，可以马上生成6张2D纹理贴图 用于立方体纹理
            camera.RenderToCubemap(cubeMap);
            DestroyImmediate(tmpObj);
        }
    }
}
