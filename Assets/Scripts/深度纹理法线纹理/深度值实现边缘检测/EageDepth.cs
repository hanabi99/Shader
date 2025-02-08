using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EageDepth : PostEffectBase
{
    [Range(0,1)]
    public float edgeOnly = 0;
    public Color edgeColor = Color.black;
    public Color backgroundColor = Color.white;
    public float sampleDistance = 1;
    public float sensitivityDepth = 1;
    public float sensitivityNormal = 1;

    void Start()
    {
        Camera.main.depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    protected override void UpdateProperty()
    {
        if(material != null) 
        {
            material.SetFloat("_EdgeOnly", edgeOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgroundColor", backgroundColor);
            material.SetFloat("_SampleDistance", sampleDistance);
            material.SetFloat("_SensitivityDepth", sensitivityDepth);
            material.SetFloat("_SensitivityNormal", sensitivityNormal);
        }
    }
}
