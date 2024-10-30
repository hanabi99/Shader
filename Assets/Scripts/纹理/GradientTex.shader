Shader "Unlit/GradientTex"
{
    Properties
    {
        _MainColor("MainColor", Color) = (1,1,1,1)
        //主纹理
        _RampTex ("_RampTex", 2D) = "" { }
        //高光反射材质颜色
        _SpecularColor ("_SpecularColor", Color) = (1, 1, 1, 1)
        //光泽度
        _SpecularNum ("_Glossiness", Range(0, 20)) = 0.5
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _RampTex;
            //纹理的缩放和偏移 x,y缩放 zw偏移
            float4 _RampTex_ST;
            //材质漫反射颜色
            fixed4 _MainColor;
            fixed4 _SpecularColor;
            float _SpecularNum;
         
            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 wNormal : NORMAL;
                float3 wPos : TEXCOORD1;
            };
            

            v2f vert (appdata_base v)
            {
                v2f data;
                data.pos = UnityObjectToClipPos(v.vertex);
                data.wNormal = UnityObjectToWorldNormal(v.normal);
                data.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return  data;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 light_dir = normalize(_WorldSpaceLightPos0.xyz);
                float3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.wPos);
                fixed gradient = dot(normalize(i.wNormal), light_dir) * 0.5 + 0.5;
                //Lambert
                fixed3 gradientColor = _MainColor.rgb * _LightColor0.rgb * tex2D(_RampTex, float2(gradient,gradient));
                float3 halfDegree = normalize(view_dir + light_dir);
                fixed3 specularColor = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(i.wNormal, halfDegree)), _SpecularNum);
                //bulin
                fixed3 bulinColor = UNITY_LIGHTMODEL_AMBIENT.rgb +  gradientColor + specularColor;

                return fixed4(bulinColor, 1);
            }
            ENDCG
        }
    }
}
