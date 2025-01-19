using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaoSi : PostEffectBase
{
    [Range(1,8)]
    public int downSample = 1;
    [Range(1,16)]
    public int ExcuteCount = 1;
    [Range(0,3)]
    public float _BlurInterval;
    protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        //base.OnRenderImage(source, destination);
        if (material != null)
        {
            int rtW = source.width / downSample;
            int rtH = source.height / downSample;
            RenderTexture buffer = RenderTexture.GetTemporary(rtW,rtH, 0);
            //准备一个缓存区
            buffer.filterMode = FilterMode.Bilinear;
            Graphics.Blit(source, buffer);
            for (int i = 0; i < ExcuteCount; i++)
            {
                material.SetFloat("_BlurInterval", 1 + ExcuteCount * _BlurInterval);
                var buffer1 = RenderTexture.GetTemporary(rtW,rtH, 0);
                //进行第一次 水平卷积计算
                Graphics.Blit(buffer, buffer1, material, 0); //Color1
                RenderTexture.ReleaseTemporary(buffer);
                buffer = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW,rtH, 0);
                //进行第二次 垂直卷积计算
                Graphics.Blit(buffer, buffer1, material, 1);
                buffer = buffer1;
            }
            //释放缓存区
            Graphics.Blit(buffer, destination);
            RenderTexture.ReleaseTemporary(buffer);
        }
        else
            Graphics.Blit(source, destination);
    }
}
