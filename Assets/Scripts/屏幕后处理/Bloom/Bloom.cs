using UnityEngine;

public class Bloom : PostEffectBase
{
     //������ֵ����
    [Range(0, 4)]
    public float luminanceThreshold = .5f;

    [Range(1, 8)]
    public int downSample = 1;
    [Range(1, 16)]
    public int iterations = 1;
    [Range(0, 3)]
    public float blurSpread = 0.6f;

    protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material != null)
        {
            //����������ֵ����
            material.SetFloat("_LuminanceThreshold", luminanceThreshold);

            int rtW = source.width / downSample;
            int rtH = source.height / downSample;

            //��Ⱦ��������
            RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 16);
            //����˫���Թ���ģʽ������ ����������Ч����ƽ��
            buffer.filterMode = FilterMode.Bilinear;
            //��һ�� ��ȡ���� �����ǵ���ȡPassȥ�õ���Ӧ��������Ϣ ���뵽������������
            Graphics.Blit(source, buffer, material, 0);

            //�ڶ��� ģ������
            //���ȥִ�� ��˹ģ���߼�
            for (int i = 0; i < iterations; i++)
            {
                //�����Ҫģ���뾶Ӱ��ģ�������ǿ�� ��ƽ��
                //һ����������ǵĵ����н������� �൱��ÿ�ε��������˹ģ��ʱ �����������ǵļ������
                material.SetFloat("_BlurInterval", 1 + i * blurSpread);

                //������һ���µĻ�����
                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 16);

                //��Ϊ������Ҫ������Pass ����ͼ������ 
                //���е�һ�� ˮƽ�������
                Graphics.Blit(buffer, buffer1, material, 1); //Color1
                //��ʱ �ؼ����ݶ���buffer1�� bufferû���� �ͷŵ�
                RenderTexture.ReleaseTemporary(buffer);

                buffer = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                //���еڶ��� ��ֱ�������
                Graphics.Blit(buffer, buffer1, material, 2);//��Color1�Ļ����ϳ���Color2 �õ����յĸ�˹ģ��������
                
                RenderTexture.ReleaseTemporary(buffer);
                //buffer��buffer1ָ��Ķ�����һ�θ�˹ģ������Ľ��
                buffer = buffer1;
            }
            //����ȡ���������ݽ��и�˹ģ���� �洢Shader���е�һ���������
            //����֮����кϳ�
            material.SetTexture("_Bloom", buffer);

            //���� ������ȡЧ��
            Graphics.Blit(buffer, destination);

            RenderTexture.ReleaseTemporary(buffer);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
