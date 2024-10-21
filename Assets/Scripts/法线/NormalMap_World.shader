Shader "Unlit/NormalMap_World"
{
    Properties
    {
        _MainColor("MainColor", Color) = (1,1,1,1)
        //������
        _MainTex ("MainTex", 2D) = "white" { }
        //�߹ⷴ�������ɫ
        _SpecularColor ("_SpecularColor", Color) = (1, 1, 1, 1)
        //�����
        _SpecularNum ("_Glossiness", Range(0, 20)) = 0.5
        //��������
        _BumpMap ("BumpMap", 2D) = "" { }
        //��͹�̶�
        _BumpScale ("BumpScale", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "LightMode" = "ForwardBase" }
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTex;
            //��������ź�ƫ�� x,y���� zwƫ��
            float4 _MainTex_ST;
            //������������ɫ
            fixed4 _MainColor;
            fixed4 _SpecularColor;
            fixed _SpecularNum;
            sampler2D _BumpMap; //��������
            float4 _BumpMap_ST; //�������������ƽ��
            float _BumpScale; //��͹�̶�

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 wpos : TEXCOORD1;
                //���ߵ�����ռ�ñ任����
                float3x3 rotation : TEXCOORD2;
            };

            v2f vert (appdata_full v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
