Shader "Unlit/Cut"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //用于渲染模型背面像素的纹理
        _BackTex ("BackTex", 2D) = "white" {}
        //切割的方向 0-x 1-y 2-z
        _CuttingDir("CuttingDir", Float) = 0
        //是否切割翻转 0-不翻转 1-翻转
        _Invert("Invert", Float) = 0
        //切割的位置
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
                //切割的位置
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
                //是否进行翻转切割
                if (cutValue == 0)
                {
                    clip(-1); //传入-1（小于0） 代表这个片元不会渲染 直接丢弃
                }
                return col;
            }
            ENDCG
        }
    }
}