using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Lesson103_BrightnessSaturationContrast : PostEffectBase
{
    [Range(0,5)]
    public float Brightness = 1;
    [Range(0, 5)]
    public float Saturation = 1;
    [Range(0, 5)]
    public float Contrast = 1;

    /// <summary>
    /// 更新相关属性
    /// </summary>
    protected override void UpdateProperty()
    {
        if (material != null)
        {
            material.SetFloat("_Brightness", Brightness);
            material.SetFloat("_Saturation", Saturation);
            material.SetFloat("_Contrast", Contrast);
        }
    }
}
