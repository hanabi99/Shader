Shader "Unlit/Bulin_Phong_Reflect"
{
    Properties
    {
        //高光反射材质颜色
       _Specular("_Specular",Color) = (1,1,1,1)
        //光泽度
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
                fixed3 color : COLOR;
            };


            v2f vert (appdata_base v)
            {
                v2f v2fData;
                //裁剪空间坐标
                v2fData.pos = UnityObjectToClipPos(v.vertex);
                //获取法线向量(转换为世界坐标)
                float3 normal = UnityObjectToWorldNormal(v.normal);
                //v2fData.wPos = mul(UNITY_MATRIX_M,v.vertex).xyz;
                float3 wPos = mul(unity_ObjectToWorld,v.vertex);

                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - wPos);

                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                float3 halfDeg = normalize(viewDir + lightDir);

                fixed3 color = _Specular * _LightColor0.rgb * pow(max(0,dot(normal,halfDeg)),_Glossiness);

                v2fData.color = color;

                return v2fData;      
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color, 1);
            }
            ENDCG
        }
    }
}
