Shader "Unlit/NormalMap_World"
{
    Properties
    {
        _MainColor("MainColor", Color) = (1,1,1,1)
        //主纹理
        _MainTex ("MainTex", 2D) = "white" { }
        //高光反射材质颜色
        _SpecularColor ("_SpecularColor", Color) = (1, 1, 1, 1)
        //光泽度
        _SpecularNum ("_Glossiness", Range(0, 20)) = 0.5
        //法线纹理
        _BumpMap ("BumpMap", 2D) = "" { }
        //凹凸程度
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
            //纹理的缩放和偏移 x,y缩放 zw偏移
            float4 _MainTex_ST;
            //材质漫反射颜色
            fixed4 _MainColor;
            fixed4 _SpecularColor;
            fixed _SpecularNum;
            sampler2D _BumpMap; //法线纹理
            float4 _BumpMap_ST; //法线纹理的缩放平移
            float _BumpScale; //凹凸程度

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 wpos : TEXCOORD1;
                //切线到世界空间得变换矩阵
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
