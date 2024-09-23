Shader "Unlit/Phong_reflect"
{
    Properties
    {
        //�߹ⷴ�������ɫ
       _Specular("_Specular",Color) = (1,1,1,1)
        //�����
       _Glossiness("_Glossiness",Range(0,20)) = 0.5
    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Specular;
            float _Glossiness;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
                float3 wPos : TEXCOORD0;
            };


            v2f vert (appdata_base v)
            {
                v2f v2fData;
                //�ü��ռ�����
                v2fData.pos = UnityObjectToClipPos(v.vertex);
                //��ȡ��������(ת��Ϊ��������)
                v2fData.normal = UnityObjectToWorldNormal(v.normal);
                //v2fData.wPos = mul(UNITY_MATRIX_M,v.vertex).xyz;
                v2fData.wPos = mul(unity_ObjectToWorld,v.vertex);
                //������ɫ��
                //Phong lighting
                //��Դ����ɫ * ���ʸйⷴ����ɫ * max(0,��׼���۲췽��ͱ�׼�����߷���ķ��������ĵ��)
                //��ȡ�ӽ�����(ת��Ϊ��������)
                //float3 vertexWorld = mul(UNITY_MATRIX_M,v.vertex);
                //float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - vertexWorld);
                //��ȡ��������(ת��Ϊ��������)
                //float3 normalWorld = UnityObjectToWorldNormal(v.normal);
                //��ȡ������������ķ�������
                //float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //float3 reflectDir = reflect(-lightDir,normalWorld);
                //Phong_reflect
                //fixed3 color = _LightColor0.rgb * _Specular.rgb  * pow(max(0,dot(viewDir,reflectDir)),_Glossiness);
                //v2fData.color = color;
                return v2fData;      
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Phong lighting
                //��Դ����ɫ * ���ʸйⷴ����ɫ * max(0,��׼���۲췽��ͱ�׼�����߷���ķ��������ĵ��)
                //��ȡ�ӽ�����(ת��Ϊ��������)
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.wPos);
                //��ȡ������������ķ�������
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 reflectDir = reflect(-lightDir,i.normal);
                //Phong
                fixed3 color = _LightColor0.rgb * _Specular.rgb  * pow(max(0,dot(viewDir,reflectDir)),_Glossiness);
                return fixed4(color.rgb, 1);
            }
            ENDCG
        }
    }
}
