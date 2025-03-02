using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public class PerlinNoiseTextureTool : EditorWindow
{
    //������
    private int textureWidth = 512;
    private int textureHeight = 512;
    //����
    private int scale = 20;
    //�����������
    private string textureName = "PerlinNoiseTexture";

    [MenuItem("���������������ɹ���/��")]
    public static void ShowWindow()
    {
        GetWindow<PerlinNoiseTextureTool>("���������������ɹ���");
    }

    private void OnGUI()
    {
        GUILayout.Label("����������������");
        textureWidth = EditorGUILayout.IntField("�����", textureWidth);
        textureHeight = EditorGUILayout.IntField("�����", textureHeight);
        scale = EditorGUILayout.IntField("����", scale);

        textureName = EditorGUILayout.TextField("������", textureName);

        if(GUILayout.Button("���ɰ�����������"))
        {
            //���ɰ���������߼�
            //���������ͼƬ���� ȥ�õ���Ӧ������ֵ Ȼ������ֵ �洢����ɫ��Ϣ�� RGB����ͬ
            Texture2D texture = new Texture2D(textureWidth, textureHeight);
            for (int y = 0; y < textureHeight; y++)
            {
                for (int x = 0; x < textureWidth; x++)
                {
                    float noiseValue = Mathf.PerlinNoise((float)x/textureWidth * scale, (float)y / textureHeight * scale);
                    texture.SetPixel(x, y, new Color(noiseValue, noiseValue, noiseValue));
                }
            }
            texture.Apply();
            File.WriteAllBytes("Assets/" + textureName + ".png", texture.EncodeToPNG());
            AssetDatabase.Refresh();

            EditorUtility.DisplayDialog("��ʾ", "�����������ɽ���", "ȷ��");
        }
    }
}
