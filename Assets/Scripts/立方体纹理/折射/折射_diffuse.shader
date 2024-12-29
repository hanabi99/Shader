Shader "Unlit/折射_diffuse"
{
     Properties
    {
       //折射率比值 介质A折射率/介质B折射率
        _RefractRatio("RefractRatio", Range(0.1, 1)) = 0.5
        //立方体纹理贴图
        _Cube("Cubemap", Cube) = ""{}
        //折射程度
        _RefracAmount("RefracAmount", Range(0,1)) = 1
        //漫反射颜色
         _Color("Color", Color) = (1,1,1,1)
        //折射颜色
        _RefractColor("RefractColor", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }

        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            samplerCUBE _Cube;
            fixed _RefractRatio;
            fixed _RefracAmount;
            fixed4 _RefractColor;
            fixed4 _Color;

            struct v2f
            {
                //裁剪空间下顶点坐标
                float4 pos:SV_POSITION;
                float3 w_pos : TEXCOORD0;
                float3 w_nomal : NORMAL;
                //折射向量
                float3 worldRefr:TEXCOORD1;
                SHADOW_COORDS(2)
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                //顶点坐标转换
                o.pos = UnityObjectToClipPos(v.vertex);
                //法线转世界
                o.w_nomal = UnityObjectToWorldNormal(v.normal);
                //顶点转世界
                o.w_pos = mul(unity_ObjectToWorld, v.vertex).xyz;
                //视角方向获取 摄像机 - 顶点位置
                fixed3 worldViewDir = UnityWorldSpaceViewDir(o.w_pos);
                //计算折射向量
                //第三个参数一定是 介质A/介质B的结果 可以声明一个变量在外部算好传进来 这里我们用两个变量只是为了讲解知识
                o.worldRefr = refract(-normalize(worldViewDir), o.w_nomal,_RefractRatio);
                TRANSFER_SHADOW(o)

                return o;
            }

            fixed4 frag(v2f i):SV_TARGET
            {
                 fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.w_pos));
                //漫反射颜色
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(normalize(i.w_nomal), worldLightDir));
                //立方体纹理采样
                fixed4 cubemapColor = texCUBE(_Cube, i.worldRefr) * _RefractColor;

                UNITY_LIGHT_ATTENUATION(atten,i,i.w_pos);
                fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb + lerp(diffuse, cubemapColor.rgb, _RefracAmount) * atten;
                //结合折射程度进行计算返回
                  return fixed4(color, 1.0);
            }

            ENDCG
        }

 Pass
        {
            Tags{"LightMode"="ForwardAdd"}
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd_fullshadows

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            samplerCUBE _Cube;
            fixed _RefractRatio;
            fixed _RefracAmount;
            fixed4 _RefractColor;
            fixed4 _Color;

            struct v2f
            {
                //裁剪空间下顶点坐标
                float4 pos:SV_POSITION;
                float3 w_pos : TEXCOORD0;
                float3 w_nomal : NORMAL;
                //折射向量
                float3 worldRefr:TEXCOORD1;
                SHADOW_COORDS(2)
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                //顶点坐标转换
                o.pos = UnityObjectToClipPos(v.vertex);
                //法线转世界
                o.w_nomal = UnityObjectToWorldNormal(v.normal);
                //顶点转世界
                o.w_pos = mul(unity_ObjectToWorld, v.vertex).xyz;
                //视角方向获取 摄像机 - 顶点位置
                fixed3 worldViewDir = UnityWorldSpaceViewDir(o.w_pos);
                //计算折射向量
                //第三个参数一定是 介质A/介质B的结果 可以声明一个变量在外部算好传进来 这里我们用两个变量只是为了讲解知识
                o.worldRefr = refract(-normalize(worldViewDir), o.w_nomal,_RefractRatio);
                TRANSFER_SHADOW(o)

                return o;
            }

            fixed4 frag(v2f i):SV_TARGET
            {
                 fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.w_pos));
                //漫反射颜色
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(normalize(i.w_nomal), worldLightDir));
                //立方体纹理采样
                fixed4 cubemapColor = texCUBE(_Cube, i.worldRefr) * _RefractColor;

                UNITY_LIGHT_ATTENUATION(atten,i,i.w_pos);
                fixed3 color = lerp(diffuse, cubemapColor.rgb, _RefracAmount) * atten;
                //结合折射程度进行计算返回
                return fixed4(color, 1.0);
            }

            ENDCG
        }
    }
    FallBack "Reflective/VertexLit"
}
