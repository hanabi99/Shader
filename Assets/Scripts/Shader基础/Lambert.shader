Shader "Unlit/Lambert"
{
    Properties
    {
       _MainColor("MainColor",Color) = (1,1,1,1)
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
                float4 vertex : SV_POSITION;
            };


            v2f vert (appdata_base v)
            {
                v2f v2fData;
                v2fData.vertex = UnityObjectToClipPos(v.vertex);
                float3 normal = UnityObjectToWorldNormal(v.normal);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //lamber lighting
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
