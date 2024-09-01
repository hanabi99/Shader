// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Lesson20"
{
    Properties
    {
        _MyColor("MyColor",Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex myVert
            #pragma fragment myFrag


            fixed4 _MyColor;
            //���ݶ������
            struct appdata
            {
              float4  vertex : POSITION;
              float3  normal : NORMAL;
              float2  texcoord : TEXCOORD0;
            };

            struct v2f
            {
              float4  svpos : SV_POSITION;
              float3  normal : NORMAL;
              float2  texcoord : TEXCOORD0;
            };

            //������ɫ�� �ص����� 
            //POSITION �� SV_POSITION��CG���Ե�����
            //POSITION����ģ�͵Ķ���������䵽����Ĳ���v����
            //SV_POSITION��������ɫ������������ǲü��ռ��еĶ�������
            //���û����Щ�������޶��������������Ļ�����ô��Ⱦ������ȫ��֪���û������������ʲô���ͻ�õ������Ч��
            v2f myVert(appdata data)
            {
                //mul��CG�����ṩ�ľ���������ĳ˷����㺯��������һ�����õĺ�����
                //UNITY_MATRIX_MVP ����һ���任���� ��Unity���õ�ģ�͡��۲졢ͶӰ����ļ���
                //UnityObjectToClipPos�������ú�֮ǰ�ľ���˷���һ���ģ���ҪĿ�ľ����ڽ�������任 ֻ�����°汾�����װ������ ʹ�ø��ӷ���
                //mul(UNITY_MATRIX_MVP,v);
                v2f v2data;
                v2data.svpos = UnityObjectToClipPos(data.vertex);
                v2data.normal = data.normal;
                v2data.texcoord = data.texcoord;
                return v2data;
            }


            //ƬԪ��ɫ�� ���������ɶ�����ɫ�����ݹ�����
            //���Է�װ�Ľṹ�廹��Ҫ��Ϊ������ɫ���ķ���ֵ����
            //ƬԪ��ɫ�� �ص�����
            //SV_Target:������Ⱦ�������û������ɫ�洢��һ����ȾĿ���У����ｫ�����Ĭ�ϵ�֡������
            fixed4 myFrag(v2f v2f):SV_Target
            {
                return _MyColor;
            }

            ENDCG
        }
    }
}
