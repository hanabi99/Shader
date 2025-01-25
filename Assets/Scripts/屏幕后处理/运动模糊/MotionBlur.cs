using UnityEngine;

public class MotionBlur : PostEffectBase
{
    [Range(0,1)]
    public float blurAmount = 0.5f;
    private RenderTexture accumulationTex;
    protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            //初始化堆积纹理 如果为空 或者 屏幕宽高变化了 都需要重新初始化
            if( accumulationTex == null ||
                accumulationTex.width != source.width ||
                accumulationTex.height != source.height)
            {
                DestroyImmediate(accumulationTex);
                //初始化
                accumulationTex = new RenderTexture(source.width, source.height, 0);
                accumulationTex.hideFlags = HideFlags.HideAndDontSave;
                //保证第一次 累积纹理中也是有内容 因为之后 它的颜色 会作为颜色缓冲区中的颜色
                Graphics.Blit(source, accumulationTex);
            }
            //1 - 模糊程度的目的 是因为 希望大到的效果是 模糊程度值越大 越模糊
            //因为Shader中的混合因子的计算方式决定的 因此 我们需要1 - 它
            material.SetFloat("_BlurAmount", 1.0f - blurAmount);

            //利用我们的材质 进行混合处理
            //第二个参数 有内容时  它会作为颜色缓冲区的颜色来进行处理
            //没有直接写入目标中的目的 也是可以通过accumulationTex记录当前渲染结果
            //那么在下一次时 它就相当于是上一次的结果了
            Graphics.Blit(source, accumulationTex, material); 

            Graphics.Blit(accumulationTex, destination);
        }
        else
            Graphics.Blit(source, destination);
    }

    /// <summary>
    /// 如果脚本失活 那么把累积纹理删除掉
    /// </summary>
    private void OnDisable()
    {
        DestroyImmediate(accumulationTex);
    }
}
