Shader "Unlit/菲涅尔Base"
{
    Properties
    {
       _Cube("CubeMap", Cube) = "" {}
        //菲涅耳反射中 对应介质的反射率
       _FresnelScale("FresnelScale", Range(0,1)) = 1
    }
    SubShader
    {
        Tags{"RenderType"="Opaque" "Queue"="Geometry"}

        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            samplerCUBE _Cube;
            float _FresnelScale;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 w_nomal : NORMAL;
                float3 view_dir : TEXCOORD0;
                float3 reflect : TEXCOORD1;
            };
            
            v2f vert (appdata_base v)
            {
               v2f o;
                //顶点坐标转换
                o.pos = UnityObjectToClipPos(v.vertex);
                //计算反射光向量
                //1.计算世界空间下法线向量
                o.w_nomal = UnityObjectToWorldNormal(v.normal);
                //2.世界空间下的顶点坐标
                fixed3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                //3.计算视角方向 内部是用摄像机位置 - 世界坐标位置 
                o.view_dir = UnityWorldSpaceViewDir(worldPos);
                //4.计算反射向量
                o.reflect = reflect(-o.view_dir, o.w_nomal);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 cubemap = texCUBE(_Cube, i.reflect);
                //利用schlick菲涅耳近似等式 计算菲涅耳反射率
                fixed fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(normalize(i.view_dir), normalize(i.w_nomal)), 5);
                return cubemap * _FresnelScale * fresnel;  
            }
            ENDCG
        }
    }
}
