Shader "Unlit/折射Base"
{
    Properties
    {
        //介质A折射率
        _RefractiveIndexA("RefractiveIndexA", Range(1,2)) = 1
        //介质B折射率
        _RefractiveIndexB("RefractiveIndexB", Range(1,2)) = 1.3
        //立方体纹理贴图
        _Cube("Cubemap", Cube) = ""{}
        //折射程度
        _RefracAmount("RefracAmount", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            samplerCUBE _Cube;
            fixed _RefractiveIndexA;
            fixed _RefractiveIndexB;
            fixed _RefracAmount;

            struct v2f
            {
                //裁剪空间下顶点坐标
                float4 pos:SV_POSITION;
                //折射向量
                float3 worldRefr:TEXCOORD0;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                //顶点坐标转换
                o.pos = UnityObjectToClipPos(v.vertex);
                //法线转世界
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                //顶点转世界
                fixed3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                //视角方向获取 摄像机 - 顶点位置
                fixed3 worldViewDir = UnityWorldSpaceViewDir(worldPos);
                //计算折射向量
                //第三个参数一定是 介质A/介质B的结果 可以声明一个变量在外部算好传进来 这里我们用两个变量只是为了讲解知识
                o.worldRefr = refract(-normalize(worldViewDir), worldNormal, _RefractiveIndexA / _RefractiveIndexB);

                return o;
            }

            fixed4 frag(v2f i):SV_TARGET
            {
                //立方体纹理采样
                fixed4 cubemapColor = texCUBE(_Cube, i.worldRefr);
                //结合折射程度进行计算返回
                return cubemapColor * _RefracAmount;
            }

            ENDCG
        }
    }
}
