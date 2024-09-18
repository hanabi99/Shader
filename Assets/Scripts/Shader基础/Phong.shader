Shader "Unlit/Lambert"
{
    Properties
    {
       _Specular("_Specular",Color) = (1,1,1,1)
       _Glossiness("_Glossiness",Range(0,1)) = 1
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

            fixed4 _MainColor;

            struct v2f
            {
                fixed3 color: COLOR;
                float4 pos : SV_POSITION;
            };


            v2f vert (appdata_base v)
            {
                v2f v2fData;
                v2fData.pos = UnityObjectToClipPos(v.vertex);
                float3 normal = UnityObjectToWorldNormal(v.normal);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //Phong lighting
                fixed3 color = _MainColor.rgb *  _LightColor0.rgb *  max(0,dot(lightDir,normal));
                v2fData.color = UNITY_LIGHTMODEL_AMBIENT.rgb + color;
                return v2fData;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color.rgb, 1);
            }
            ENDCG
        }
    }
}
