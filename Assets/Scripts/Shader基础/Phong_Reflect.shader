Shader "Unlit/Phong_reflect"
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
                float3 normal : NORMAL;
                float3 wPos : TEXCOORD0;
            };


            v2f vert (appdata_base v)
            {
                v2f v2fData;
                //裁剪空间坐标
                v2fData.pos = UnityObjectToClipPos(v.vertex);
                //获取法线向量(转换为世界坐标)
                v2fData.normal = UnityObjectToWorldNormal(v.normal);
                //v2fData.wPos = mul(UNITY_MATRIX_M,v.vertex).xyz;
                v2fData.wPos = mul(unity_ObjectToWorld,v.vertex);
                //顶点着色器
                //Phong lighting
                //光源的颜色 * 材质感光反射颜色 * max(0,标准化观察方向和标准化光线方向的反射向量的点积)
                //获取视角向量(转换为世界坐标)
                //float3 vertexWorld = mul(UNITY_MATRIX_M,v.vertex);
                //float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - vertexWorld);
                //获取法线向量(转换为世界坐标)
                //float3 normalWorld = UnityObjectToWorldNormal(v.normal);
                //获取入射光线向量的反射向量
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
                //光源的颜色 * 材质感光反射颜色 * max(0,标准化观察方向和标准化光线方向的反射向量的点积)
                //获取视角向量(转换为世界坐标)
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.wPos);
                //获取入射光线向量的反射向量
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
