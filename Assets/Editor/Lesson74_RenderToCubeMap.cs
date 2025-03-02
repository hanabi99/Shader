using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEditor;
using UnityEngine;

public class Lesson74_RenderToCubeMap : EditorWindow
{
    private GameObject obj;
    private Cubemap cubeMap;

    [MenuItem("Cube texture dynamic generation/Open the build window")]
    static void OpenWindow()
    {
        Lesson74_RenderToCubeMap window = EditorWindow.GetWindow<Lesson74_RenderToCubeMap>("build window");
        window.Show();
    }

    private void OnGUI()
    {
        GUILayout.Label("Ori Object");
        obj = EditorGUILayout.ObjectField(obj, typeof(GameObject), true) as GameObject;
        GUILayout.Label("Ori CubeMap");
        cubeMap = EditorGUILayout.ObjectField(cubeMap, typeof(Cubemap), false) as Cubemap;
        if(GUILayout.Button("Instantiate CubeMap"))
        {
            if(obj == null || cubeMap == null)
            {
                EditorUtility.DisplayDialog("Tips", "Please associate the corresponding object and cube map first", "OK");
                return;
            }
  
            GameObject tmpObj = new GameObject("��ʱ����");
            tmpObj.transform.position = obj.transform.position;
            Camera camera = tmpObj.AddComponent<Camera>();
            camera.RenderToCubemap(cubeMap);
            DestroyImmediate(tmpObj);
        }
    }
}
