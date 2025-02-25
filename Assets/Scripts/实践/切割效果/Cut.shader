Shader "Unlit/Cut"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //������Ⱦģ�ͱ������ص�����
        _BackTex ("BackTex", 2D) = "white" {}
        //�и�ķ��� 0-x 1-y 2-z
        _CuttingDir("CuttingDir", Float) = 0
        //�Ƿ��иת 0-����ת 1-��ת
        _Invert("Invert", Float) = 0
        //�и��λ��
        _CuttingPos("CuttingPos", Vector) = (0,0,0,0)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        Cull Off


        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 w_pos : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _BackTex;
            fixed _CuttingDir;
            fixed _Invert;
            float4 _CuttingPos;

            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.w_pos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag(v2f i,fixed face: VFACE) : SV_Target
            {
                fixed4 col = face > 0 ? tex2D(_MainTex, i.uv) : tex2D(_BackTex, i.uv);
                float cutValue = 0;
                //�и��λ��
                if (_CuttingDir == 0)
                {
                    cutValue = i.w_pos.x < _CuttingPos.x ? 0 : 1;
                }
                else if (_CuttingDir == 1)
                {
                    cutValue = i.w_pos.y < _CuttingPos.y ? 0 : 1;
                }
                else if (_CuttingDir == 2)
                {
                    cutValue = i.w_pos.z < _CuttingPos.z ? 0 : 1;
                }
                cutValue = _Invert ? 1 - cutValue : cutValue;
                //�Ƿ���з�ת�и�
                if (cutValue == 0)
                {
                    clip(-1); //����-1��С��0�� �������ƬԪ������Ⱦ ֱ�Ӷ���
                }
                return col;
            }
            ENDCG
        }
    }
}